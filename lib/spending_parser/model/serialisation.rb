module SpendingParser
  class Serialisation
    def initialize(products)
      @products = products
    end

    def to_csv
      header = %w{uid part-id part-name group-id group-name subgroup-id subgroup-name row-index row-name time amount direction}
      lines = []
      CSV.generate do |csv|
        csv << header
        @products.each do |product|
          product.each do |line|
            csv << line
          end
        end
      end
    end
  end
end
