require 'csv'

module SpendingParser
  class ProductExtractor
    def initialize(tables)
      @tables = tables
    end

    PART     = 0
    GROUP    = 1
    SUBGROUP = 2
    YEAR     = 3
    DATA_ROW = 4

    def products
      rows = concate_rows
      data = rows[DATA_ROW, rows.size]
      width = rows.first.size

      parts, groups, subgroups = [], [], []
      part, group = nil, nil

      (0..width).each do |j|
        if !blank?(rows[PART][j])
          part = product(data, j)
          begin
            part.name_and_id_from_cell = rows[PART][j]
          rescue Errors::ParseError => e
            # WORKAROUND: In rare cases (at least ones) the part summary is one page
            # earlier, while the rest of the part including part name is one column later
            part.name_and_id_from_cell = rows[PART][j + 1]
            unless rows[PART][j].start_with?(part.id)
              raise e
            end
          end
          part.year_from_cell = rows[YEAR][j]
          parts << part
        elsif !blank?(rows[GROUP][j])
          group = product(data, j)
          group.name_and_id_from_cell = rows[GROUP][j]
          group.year = part.year
          part.subproducts << group
        elsif !blank?(rows[SUBGROUP][j])
          product = product(data, j)
          product.name_and_id_from_cell = rows[SUBGROUP][j]
          product.year = part.year
          group.subproducts << product
        end
      end

      return parts

      #write_csv(splits[0], "/tmp/file.csv")
    end

    def product(data, idx)
      Product.new(@tables.header, data.map { |d| d[idx] })
    end

    def concate_rows
      concated_rows = Array.new(Tables::ROWS_HEIGHT)

      @tables.each do |rows, page_number|
        if rows.size != Tables::ROWS_HEIGHT
          msg = "expect table on page #{page_number} to have: #{Tables::ROWS_HEIGHT} rows, got: #{rows.size}:\n"
          msg += pretty_print_table(rows)

          raise Errors::ParseError.new(msg)
        end

        rows.each_with_index do |row, i|
          # normalize whitespace
          row.each {|v| v.gsub!(/\s+/, " ") }
          concated_rows[i] ||= []
          # skip header
          data = row[2, row.size]
          # remove empty cells, which occurs in year line
          if row[0] == "Angaben in EUR"
            data.delete_if {|cell| cell == "" }
          end
          concated_rows[i].concat(data)
        end
      end
      concated_rows
    end

    def blank?(s)
      s.nil? || s == "" || s =~ /^\s+$/
    end

    def write_csv(array, path)
      CSV.open(path, "wb") do |csv|
        array.each do |row|
          csv << row
        end
      end
    end
  end
end
