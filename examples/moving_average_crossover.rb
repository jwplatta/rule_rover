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
    @portfolio = portfolio
  end

  attr_reader :portfolio

  def buy(stock, price, qty)
    portfolio.remove_cash(price * qty)
    portfolio.add_stock(stock, qty)
  rescue => e
    false
  end

  def sell(stock, price, qty)
    portfolio.remove_stock(stock, qty)
    portfolio.add_cash(price * qty)
  rescue => e
    false
  end
end

Stock = Struct.new(:symbol, :price, :date) do
  def eql?(other)
    symbol == other.symbol && price == other.price && date == other.date
  end

  def ==(other)
    symbol == other.symbol && price == other.price && date == other.date
  end
end

BROKER = Broker.new
BUY_THRESHOLD = 95
SELL_THRESHOLD = 105

kb = RuleRover.knowledge_base(system: :first_order, engine: :backward_chaining) do
  action :execute_buy_trade do |stock:, qty:, price:|
    BROKER.buy stock, price, qty
  end

  action :execute_sell_trade do |stock:, qty:, price:|
    BROKER.sell stock, price, qty
  end

  rule [[[:@today, "date"], :and, ["stock", "date", :costs, "price"]], :and, ["price", :below, BUY_THRESHOLD]], :then, ["stock", :buy, "qty"] do
    do_action :execute_buy_trade, stock: "stock", qty: "qty", price: "price"
  end

  rule [[[:@today, "date"], :and, ["stock", "date", :costs, "price"]], :and, ["price", :above, SELL_THRESHOLD]], :then, ["stock", :sell, "qty"] do
    do_action :execute_sell_trade, stock: "stock", qty: "qty", price: "price"
  end
end

# class Indicator
#   def initialize(stock, period)
#     @stock = stock
#     @period = period
#   end

#   attr_reader :stock, :period

#   def calculate
#     moving_average = moving_average(stock, period)
#   end
# end

def moving_average(prices, period)
  prices = prices.last(period)
  prices.sum(&:price) / prices.size.to_f
end

class MarketSimulation
  class << self
    def run(stock_prices, knowledge_base)
      new(stock_prices, knowledge_base).run
    end
  end

  def initialize(stock_prices, knowledge_base)
    @stock_prices = stock_prices
    @knowledge_base = knowledge_base
  end

  attr_reader :stock_prices, :knowledge_base

  def run
    # NOTE: main loop
    stock_prices.each do |stock|
      puts stock.to_s
      # STEP: add market data for the day
      #  - update stock prices
      #  - update moving averages and other indicators

      curr_date = stock.date
      knowledge_base.retract :@today, "x"
      knowledge_base.retract [stock.symbol, "y"], :costs, "x"

      knowledge_base.assert :@today, curr_date.to_s
      knowledge_base.assert [stock.symbol, stock.date.to_s], :costs, stock.price

      if stock.price > SELL_THRESHOLD
        knowledge_base.assert stock.price, :above, SELL_THRESHOLD
        # NOTE: why not just write broker.sell(stock, 1) here?
        # A more sophisticated strategy would string together many rules
        # in order to determine when to sell.
        knowledge_base.entail? stock.symbol, :sell, 10
      elsif stock.price < BUY_THRESHOLD
        knowledge_base.assert stock.price, :below, BUY_THRESHOLD
        # NOTE: why not just write broker.buy(stock, 1) here?
        knowledge_base.entail? stock.symbol, :buy, 10
      end
    end
  end
end

stock_updates = [
  Stock.new("ACME", 91.0, Date.new(2023, 10, 1)),
  Stock.new("ACME", 94.0, Date.new(2023, 11, 1)),
  Stock.new("ACME", 98.0, Date.new(2023, 12, 1)),
  Stock.new("ACME", 100.0, Date.new(2024, 1, 1)),
  Stock.new("ACME", 110.0, Date.new(2024, 2, 1)),
  Stock.new("ACME", 107.0, Date.new(2024, 3, 1)),
  Stock.new("ACME", 102.0, Date.new(2024, 4, 1)),
  Stock.new("ACME", 94.0, Date.new(2024, 5, 1)),
  Stock.new("ACME", 99.0, Date.new(2024, 6, 1))
]

MarketSimulation.run(stock_updates, kb)