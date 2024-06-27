require "pry"
require "date"
require "rule_rover"

class Portfolio
  def initialize(cash: 100_000)
    @stocks = {} # { Stock => quantity }
    @cash = cash
  end

  attr_reader :stocks, :cash

  def value
    stocks.sum { |stock, quantity| stock.price * quantity } + cash
  end

  def add_cash(amount)
    @cash += amount
  end

  def remove_cash(amount)
    if cash >= amount
      @cash -= amount
    else
      raise "Insufficient funds"
    end
  end

  def add_stock(stock, qty)
    if stocks.keys.include?(stock)
      stocks[stock] += qty
    else
      stocks[stock] = qty
    end
  end

  def remove_stock(stock, qty)
    if stocks.keys.include?(stock) && stocks[stock] > qty
      stocks[stock] -= qty
    elsif stocks.keys.include?(stock) && stocks[stock] == qty
      stocks.delete(stock)
    else
      raise "Insufficient stock"
    end
  end
end


class Broker
  def initialize(portfolio: Portfolio.new)
    @protfolio = portfolio
  end

  attr_reader :portfolio

  def buy(stock, qty)
    portfolio.remove_cash(stock.price * qty)
    portfolio.add_stock(stock, qty)
  rescue => e
    false
  end

  def sell(stock, qty)
    portfolio.remove_stock(stock, qty)
    portfolio.add_cash(stock.price * qty)
  rescue => e
    false
  end
end

Stock = Struct.new(:symbol, :price, :date)
broker = Broker.new

kb = RuleRover.knowledge_base(system: :first_order, engine: :backward_chaining) do
  # assert "stock", "periods", "date", :moving_average_is, "average"
  # assert "stock", "date", :costs, "price"
  # assert "stock", :buy, "qty"
  # assert "stock", :sell,  "qty"
  # NOTEL date is in the stock struct
  # assert "stock", :cross_above, "average"
  # assert "stock", :cross_below, "average"
  # assert "stock", :greater_than, "average"
  # assert "stock", :less_than, "average"

  rule [["stock", :greater_than, "average"], :and, ["prevstock", :less_than, "prevaverage"]], :then, ["stock", :cross_above, "average"]

  rule [["stock", :less_than, "average"], :and, ["prevstock", :greater_than, "prevaverage"]], :then, ["stock", :cross_below, "average"]

  rule ["stock", :cross_above, "average"], :then, ["stock", :buy, "qty"] do
    do_action :execute_buy_trade, stock: "stock", qty: "qty" do |stock:, qty:|
      broker.buy(stock, qty)
    end
  end

  rule ["stock", :cross_below, "average"], :then, ["stock", :sell, "qty"] do
    do_action :execute_sell_trade, stock: "stock", qty: "qty" do |stock:, qty:|
      broker.sell(stock, qty)
    end
  end
end

kb.assert(:@today, Date.new(2023, 9, 1))
binding.pry
kb.retract(:@today, "x")


# kb.assert(Stock.new("AAPL"), Date.new(2024, 1, 1), :costs, 100)
# kb.assert(Stock.new("AAPL"), Date.new(2024, 2, 1), :costs, 101)
# kb.assert(Stock.new("AAPL"), Date.new(2024, 3, 1), :costs, 102)
# kb.assert(Stock.new("AAPL"), Date.new(2024, 4, 1), :costs, 103)
# kb.assert(Stock.new("AAPL"), Date.new(2024, 5, 1), :costs, 104)
# kb.assert(Stock.new("AAPL"), Date.new(2024, 6, 1), :costs, 105)
# kb.assert(Stock.new("AAPL"), Date.new(2024, 7, 1), :costs, 106)
# kb.assert(Stock.new("CMG"), Date.new(2024, 1, 1), :costs, 65)
# matches = kb.match?("y", Date.new(2024, 1, 1), :costs, "x")


# matches = kb.match?(Stock.new("CMG"), Date.new(2024, 1, 1), 65)
# assert(Stock.new("AAPL", 100, Date.today.strftime("%m-%d-%Y")))
# assert(Stock.new("AAPL", 101, Date.today.strftime("%m-%d-%Y")))
# assert(Stock.new("AAPL", 101, Date.today.strftime("%m-%d-%Y")))

stock_updates = [
  Stock.new("AAPL", 91.0, Date.new(2023, 10, 1)),
  Stock.new("AAPL", 94.0, Date.new(2023, 11, 1)),
  Stock.new("AAPL", 98.0, Date.new(2023, 12, 1)),
  Stock.new("AAPL", 100.0, Date.new(2024, 1, 1)),
  Stock.new("AAPL", 110.0, Date.new(2024, 2, 1)),
  Stock.new("AAPL", 107.0, Date.new(2024, 3, 1)),
  Stock.new("AAPL", 106.0, Date.new(2024, 4, 1)),
  Stock.new("AAPL", 113.0, Date.new(2024, 5, 1)),
  Stock.new("AAPL", 112.0, Date.new(2024, 6, 1))
]

def moving_average(quotes, period, date)
  quotes = quotes.select { |price| price.date <= date }
  quotes = quotes.last(period)
  quotes.sum(&:price) / quotes.size.to_f
end

stock_updates.each do |stock|
  # kb.retract(:@today, stock.date)
  # kb.assert(*[:@today, stock.date])
  current_date = stock.date
  kb.assert(Stock.new(stock.symbol), stock.date, :costs, stock.price)
  stocks_prices = kb.match?(Stock.new(stock.symbol), "y", :costs, "x")


  stocks = stocks_prices.map do |stck|
    s = stck.subjects.find { |subject| subject.name.is_a?(Stock) }.name
    quote_date = stck.subjects.find { |subject| subject.name.is_a?(Date) }.name
    price = stck.objects.find { |object| object.name.is_a?(Float) }.name
    Stock.new(symbol: s.symbol, date: quote_date, price: price)
  end

  moving_avg = moving_average(stocks, 3, current_date)
  kb.assert(Stock.new(stock.symbol), current_date, :moving_average_is, moving_avg)
end

moving_avgs = kb.match?("stock", "date", :moving_average_is, "average")

binding.pry

