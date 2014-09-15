require "tabula"

module SpendingParser
  class Tables
    def initialize(file_path)
      @file_path = file_path
    end
    def each
      extractor = Tabula::Extraction::ObjectExtractor.new(@file_path.to_s, :all)
      n = 0
      extractor.extract.each do |pdf_page|
        n += 1
        yield pdf_page
        next if n < 153
        return if n > 167
        pdf_page.spreadsheets.each do |spreadsheet|
          yield spreadsheet
          $stdout << spreadsheet.to_csv
          $stdout << "\n\n"
        end
      end
      out.close
    end
  end
end
