module SpendingParser
  class Product
    def initialize(header, data)
      @header = header
      @data = data
      @subproducts = []
    end

    ID_ROW = 0
    INCOME_RANGE = 1..9
    SPENDING_RANGE = 11..17
    INCOME = "Ertrag"
    SPENDING = "Aufwendung"

    def year_from_cell=(cell)
      unless cell =~ /Ansatz (\d+)$/
        e = "failed to extract year from first row \n"
        e += "cell content is: '#{cell}'"
        raise StandardError.new(e)
      end
      @year = $1
    end

    def name_and_id_from_cell=(cell)
      unless cell =~ /(\S+)\s+(.+)/
        e = "failed to extract name and id from first cell of product\n"
        e += "cell content is: '#{cell}'"
        raise StandardError.new(e)
      end
      @id, @name = $1, $2
      # normalize hyphen
      @name.gsub!(/-\s/, "")
    end

    attr_accessor :year, :name, :id, :subproducts, :header
    attr_reader :data

    # format:
    # uid | part.id | part.name | group.id | group.name | subgroup.id | subgroup.name | row index | row name | time | amount | direction | IntExt

    def each(part=nil,group=nil)
      if subproducts.nil? || subproducts.empty?
        INCOME_RANGE.each do |i|
          row = row_with_metadata(part, group, i)
          binding.pry if @data[i].nil?
          row << amount(@data[i])
          row << INCOME
          yield row
        end

        SPENDING_RANGE.each do |i|
          row = row_with_metadata(part, group, i)
          binding.pry if @data[i].nil?
          row << amount(@data[i])
          row << SPENDING
          yield row
        end
      else
        subproducts.each do |subproduct|
          if part.nil?
            subproduct.each(self) { |line| yield line }
          else
            subproduct.each(part, self) { |line| yield line }
          end
        end
      end
    end

    # format:
    # uid = (part|group|subgroup).id, row index

    def uid(idx)
      sprintf("%s%.2d", id, idx)
    end

    def amount(value)
      value.gsub(/\./, "").to_i
    end

    def row_with_metadata(part, group, idx)
      row = [uid(idx)]

      if part
        row.concat([part.id, part.name])
        if group
          row.concat([group.id, group.name, id, name])
        else
          row.concat([id, name, "", ""])
        end
      else
        row.concat([id, name, "", "", "", ""])
      end

      row.concat([idx, @header[idx], @year])
      row
    end
  end
end
