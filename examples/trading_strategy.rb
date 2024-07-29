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

Stock = Struct.new(:symbol, :price, :date, :volumne, :rsi) do
  def eql?(other)
    symbol == other.symbol && price == other.price && date == other.date && volume == other.volume && rsi == other.rsi
  end

  def ==(other)
    symbol == other.symbol && price == other.price && date == other.date && volume == other.volume && rsi == other.rsi
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

  # if today's price is above the 10 day average, then check_average_volume
  # if check_average_volume and the volume is greater than the average volume, then check_rsi_strong
  # if check_rsi_strong and the RSI is less than 30, then buy 20
  # if check_rsi_strong and the RSI is greater than or equal to 30, then buy 10

  # if check_average_volume and the volume is less than or equal to average volume, then check_rsi_weak
  # if check_rsi_weak and the RSI is less than 30, then buy 20
  # if check_rsi_weak and the RSI is greater than or equal to 30, then buy 10

  # if today's price is less than the 10 day average, then sell_signal
  # if sell_signal and volume is greater than average volume, then sell_signal_strong
  # if sell_signal_strong and RSI is greater than 70, then sell 20


  # if today's price equals the 10 day average, then hold

  rule [[[:@today, "date"], :and, ["stock", "date", :costs, "price"]], :and, ["price", :below, BUY_THRESHOLD]], :then, ["stock", :buy, "qty"] do
    do_action :execute_buy_trade, stock: "stock", qty: "qty", price: "price"
  end

  rule [[[:@today, "date"], :and, ["stock", "date", :costs, "price"]], :and, ["price", :above, SELL_THRESHOLD]], :then, ["stock", :sell, "qty"] do
    do_action :execute_sell_trade, stock: "stock", qty: "qty", price: "price"
  end
end

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
  Stock.new("ACME", 250.00, Date.new(2023, 6, 1), 15000000, 55),
  Stock.new("ACME", 252.00, Date.new(2023, 6, 2), 15500000, 57),
  Stock.new("ACME", 251.50, Date.new(2023, 6, 3), 14800000, 54),
  Stock.new("ACME", 253.00, Date.new(2023, 6, 4), 16000000, 60),
  Stock.new("ACME", 255.00, Date.new(2023, 6, 5), 16200000, 65),
  Stock.new("ACME", 257.00, Date.new(2023, 6, 6), 15800000, 68),
  Stock.new("ACME", 256.50, Date.new(2023, 6, 7), 15900000, 67),
  Stock.new("ACME", 258.00, Date.new(2023, 6, 8), 16100000, 70),
  Stock.new("ACME", 259.00, Date.new(2023, 6, 9), 16300000, 72),
  Stock.new("ACME", 260.00, Date.new(2023, 6, 10), 16400000, 75),
  Stock.new("ACME", 261.00, Date.new(2023, 6, 11), 16500000, 77),
  Stock.new("ACME", 262.00, Date.new(2023, 6, 12), 16600000, 78),
  Stock.new("ACME", 263.00, Date.new(2023, 6, 13), 16700000, 80),
  Stock.new("ACME", 262.50, Date.new(2023, 6, 14), 16650000, 79),
  Stock.new("ACME", 261.00, Date.new(2023, 6, 15), 16500000, 75),
  Stock.new("ACME", 259.00, Date.new(2023, 6, 16), 16400000, 70),
  Stock.new("ACME", 257.50, Date.new(2023, 6, 17), 16300000, 65),
  Stock.new("ACME", 256.00, Date.new(2023, 6, 18), 16200000, 60),
  Stock.new("ACME", 255.00, Date.new(2023, 6, 19), 16100000, 58),
  Stock.new("ACME", 254.50, Date.new(2023, 6, 20), 16050000, 55),
  Stock.new("ACME", 253.00, Date.new(2023, 6, 21), 16000000, 53),
  Stock.new("ACME", 252.00, Date.new(2023, 6, 22), 15950000, 50),
  Stock.new("ACME", 251.00, Date.new(2023, 6, 23), 15900000, 48),
  Stock.new("ACME", 250.00, Date.new(2023, 6, 24), 15850000, 46),
  Stock.new("ACME", 249.50, Date.new(2023, 6, 25), 15800000, 45),
  Stock.new("ACME", 248.00, Date.new(2023, 6, 26), 15750000, 43),
  Stock.new("ACME", 247.00, Date.new(2023, 6, 27), 15700000, 42),
  Stock.new("ACME", 246.00, Date.new(2023, 6, 28), 15650000, 40),
  Stock.new("ACME", 245.00, Date.new(2023, 6, 29), 15600000, 38),
  Stock.new("ACME", 244.00, Date.new(2023, 6, 30), 15550000, 35)
]

MarketSimulation.run(stock_updates, kb)