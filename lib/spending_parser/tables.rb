require "tabula"
require 'set'

module SpendingParser
  class Tables
    # match header in first header and remove everything unknown,
    # if heuristic fails for example
    PRODUCT_HEADER = ["Produktbereiche", "Produktgruppen", "Produktuntergruppen", "Angaben in EUR"]
    ENTRY_NUMBERS   = (1..19).map(&:to_s)
    FIRST_COLUMN_WHITELIST = Set.new(PRODUCT_HEADER + ENTRY_NUMBERS)
    # +1 because the '1' appears two times
    ROWS_HEIGHT = FIRST_COLUMN_WHITELIST.size + 1

    def initialize(file_path, from_page, to_page)
      @file_path = file_path
      @from_page = from_page
      @to_page = to_page
    end

    attr_reader :header

    def each
      extractor = Tabula::Extraction::ObjectExtractor.new(@file_path.to_s, @from_page..@to_page)
      page_number = @from_page
      extractor.extract.each do |pdf_page|
        page_number += 1
        pdf_page.spreadsheets.each do |spreadsheet|
          rows = spreadsheet.to_a
          if rows.size == 0
            next
          end
          rows.delete_if do |row|
            !FIRST_COLUMN_WHITELIST.include?(row.first)
          end
          @header ||= rows.reduce([]) do |memo, row|
            if row[0].to_i > 0
              memo << row[1]
            end
            memo
          end
          yield rows, page_number
        end
      end
    end
  end
end
