require "optparse"

module SpendingParser
  module Application
    def self.run(argv)
      opts = parse_args(argv)

      tables = SpendingParser::Tables.new(opts.pdf_path, opts.from_page, opts.to_page)
      extractor = SpendingParser::ProductExtractor.new(tables)
      t = SpendingParser::Serialisation.new(extractor.products)
      puts(t.to_csv)
    end

    Options = Struct.new(:from_page, :to_page, :pdf_path)
    def self.parse_args(argv)
      options = Options.new
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename $0} [options] PDFFILE"
        opts.separator "Extract product sorted financial data from PDFs"
        opts.on("-f", "--from-page PAGE", "Page to start extracting") do |p|
          options.from_page = p.to_i
        end
        opts.on("-t", "--to-page PAGE", "Page to stop extracting") do |p|
          options.to_page = p.to_i
        end
        opts.on("-h", "--help", "Show this help.") do
          puts opts
          exit
        end
      end
      parser.parse!(argv)
      if argv.first.nil?
        puts "Specify at lease on pdf file"
        puts parser.summarize.join
        exit 1
      else
        options.pdf_path = argv.first
      end
      if options.to_page.nil? || options.from_page.nil?
        puts "--to-page and --from-page must be specified"
        puts parser.summarize.join
        exit 1
      end
      options
    end
  end
end
