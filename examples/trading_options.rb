require "pry"
require "date"
require "rule_rover"

# - NOTE: Trading Covered Calls and Puts
# - Write a script that is in a loop listening for stock price updates.
# - When the a new price comes in, the knowledge base asserts the new price and retracts the old price
# - Then query the knowledge base to see whether to buy, sell, hold, or do nothing.
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
  rule ["x", :greater, "y"], :then, [:@buys, "x"] do
    do_action :execute_buy_trade, stock: "x" do |stock:|
      broker.buy(stock)
    end
  end
  rule ["x", :less_than, "y"], :then, [:@buys, "x"] do
    do_action :execute_sell_trade, stock: "x" do |stock:|
      broker.sell(stock)
    end
  end
end

kb.assert(Stock.new("AAPL"), :costs, 100)
kb.assert(Stock.new("AAPL"), :costs, 101)
kb.assert(Stock.new("AAPL"), :costs, 102)

matches = kb.match?(Stock.new("AAPL"), :costs, "x")
binding.pry

# assert(Stock.new("AAPL", 100, Date.today.strftime("%m-%d-%Y")))
# assert(Stock.new("AAPL", 101, Date.today.strftime("%m-%d-%Y")))
# assert(Stock.new("AAPL", 101, Date.today.strftime("%m-%d-%Y")))

price_updates = [
  Stock.new("AAPL", 100, "01-01-2024"),
  Stock.new("AAPL", 101, "02-01-2024"),
  Stock.new("AAPL", 102, "03-01-2024")
]

price_updates.each do |price|
end

# while True
#   price = Stock.new("AAPL", 102, Date.today.strftime("%m-%d-%Y"))
#   kb.assert(price)
#   kb.retract(Stock.new("AAPL", 101, Date.today.strftime("%m-%d-%Y")))
#   kb.call_rule_actions(price)
#   query_buy =
#   kb.ential? query_buy
#   query_sell =
#   kb.entail? query_sell
# end