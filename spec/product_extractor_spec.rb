# coding: utf-8
require_relative "spec_helper"
require 'csv'

describe SpendingParser::ProductExtractor do
  let(:pdf_path) { fixture_path("Entwurf-Haushaltsplan-2015-2016-BandI.pdf") }
  let(:from_page) { 119 }
  let(:to_page) { 119 }
  let(:tables) { SpendingParser::Tables.new(pdf_path, from_page, to_page) }
  before do
    extractor = SpendingParser::ProductExtractor.new(tables)
    @products = extractor.products
  end
  it "should parse the pdf" do
    product = @products.first
    product.id.must_equal "11"
    product.name.must_equal "Innere Verwaltung"
    product.header[1].must_equal "Steuern und ähnliche Abgaben"
    product.subproducts.size.must_equal 1
    product.subproducts.first.subproducts.size.must_equal 0
    data = product.data
    data[0].must_equal "3" # id row
    data[1].must_equal "0"
    data[2].must_equal "1.691.828"
  end
end
