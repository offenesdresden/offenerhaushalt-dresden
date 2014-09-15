require_relative "spec_helper"

describe SpendingParser::Tables do
  before do
    @tables = SpendingParser::Tables.new(fixture_path("Entwurf-Haushaltsplan-2015-2016-BandI.pdf"))
    #binding.pry
  end
  it "should parse the pdf" do
    @tables.each do |table|
      #binding.pry
    end
  end
end
