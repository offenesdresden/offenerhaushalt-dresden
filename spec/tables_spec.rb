require_relative "spec_helper"

describe SpendingParser::Tables do
  let(:pdf_path) { fixture_path("Entwurf-Haushaltsplan-2015-2016-BandI.pdf") }
  let(:from_page) { 119 }
  let(:to_page) { 120 }
  before do
    @tables = SpendingParser::Tables.new(pdf_path, from_page, to_page)
  end
  it "should parse the pdf" do
    n = 0
    @tables.each do |rows, page|
      n += 1
    end
    n.must_equal 2
  end
end
