require "pry"
require "date"
require "rule_rover"

##################################
### Trading Simulation Classes ###
##################################
class Portfolio
  def initialize(cash: 100_000)
    @stocks = {} # { Stock => quantity }
    @cash = cash
  end

  attr_reader :stocks, :cash

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

Stock = Struct.new(:symbol, :price, :date, :volume, :rsi) do
  def eql?(other)
    symbol == other.symbol && price == other.price && date == other.date && volume == other.volume && rsi == other.rsi
  end

  def ==(other)
    symbol == other.symbol && price == other.price && date == other.date && volume == other.volume && rsi == other.rsi
  end
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
    volumes = []
    prices = []
    stock_prices.each do |stock|
      puts stock.to_s

      clear_knowledge_base(stock.symbol)

      prices << stock.price
      volumes << stock.volume

      knowledge_base.assert stock.symbol, :costs, stock.price
      knowledge_base.assert stock.symbol, :rsi, stock.rsi
      knowledge_base.assert stock.symbol, :volume, stock.volume

      avg_vol = mov_avg(volumes, 5)
      short_avg = mov_avg(prices, 5)
      long_avg = mov_avg(prices, 15)
      std = std_dev(prices, 15)

      if stock.price > long_avg and stock.price >= std * 2
        knowledge_base.assert stock.symbol, :two_std_above, long_avg
      elsif stock.price > long_avg and stock.price >= std
        knowledge_base.assert stock.symbol, :one_std_above, long_avg
      elsif stock.price < long_avg and stock.price >= std * 2
        knowledge_base.assert stock.symbol, :two_std_below, long_avg
      elsif stock.price < long_avg and stock.price >= std
        knowledge_base.assert stock.symbol, :one_std_below, long_avg
      end

      if stock.volume >= avg_vol
        knowledge_base.assert stock.symbol, :above_avg_vol, stock.volume
      else
        knowledge_base.assert stock.symbol, :below_avg_vol, stock.volume
      end

      if stock.rsi < 70
        knowledge_base.assert stock.symbol, :rsi_below_70, stock.rsi
        knowledge_base.assert stock.symbol, :rsi_below_30, stock.rsi if stock.rsi < 30
      elsif stock.rsi >= 30
        knowledge_base.assert stock.symbol, :rsi_above_30, stock.rsi
        knowledge_base.assert stock.symbol, :rsi_above_70, stock.rsi if stock.rsi >= 70
      end

      knowledge_base.entail? stock.symbol, :buy, "x"
      knowledge_base.entail? stock.symbol, :sell, "x"
    end
  end

  private

  def clear_knowledge_base(symbol)
    knowledge_base.retract symbol, :costs, "x"
    knowledge_base.retract symbol, :rsi, "x"
    knowledge_base.retract symbol, :volume, "x"
    knowledge_base.retract symbol, :two_std_above, "x"
    knowledge_base.retract symbol, :one_std_above, "x"
    knowledge_base.retract symbol, :two_std_below, "x"
    knowledge_base.retract symbol, :one_std_below, "x"
    knowledge_base.retract symbol, :above_avg_vol, "x"
    knowledge_base.retract symbol, :below_avg_vol, "x"
    knowledge_base.retract symbol, :rsi_below_30, "x"
    knowledge_base.retract symbol, :rsi_above_30, "x"
    knowledge_base.retract symbol, :rsi_below_70, "x"
    knowledge_base.retract symbol, :rsi_above_70, "x"
  end

  def mov_avg(values, period)
    values.last(period).sum.to_f / period
  end

  def std_dev(values, period)
    return 0 if values.empty?

    period_vals = values.last(period)

    mean = period_vals.sum.to_f / period_vals.size
    variance = period_vals.map { |value| (value - mean) ** 2 }.sum.to_f / (period_vals.size - 1)

    Math.sqrt(variance) or 0
  end
end

###########################
### EXAMPLE STARTS HERE ###
###########################
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

BROKER = Broker.new

kb = RuleRover.knowledge_base(system: :first_order, engine: :backward_chaining) do
  action :execute_buy_10 do |stock:,  price:|
    BROKER.buy stock, price, 10
  end

  action :execute_buy_20 do |stock:,  price:|
    BROKER.buy stock, price, 20
  end

  action :execute_sell_10 do |stock:, price:|
    BROKER.sell stock, price, 10
  end

  action :execute_sell_20 do |stock:, price:|
    BROKER.sell stock, price, 20
  end

  # NOTE: buy signals
  rule ["stock", :two_std_above, "long_avg"], :then, [:@strong_buy_signal, "stock"]
  rule ["stock", :one_std_above, "long_avg"], :then, [:@weak_buy_signal, "stock"]
  rule [[:@weak_buy_signal, "stock"], :and, ["stock", :above_avg_vol, "volume"]], :then, [:@strong_buy_signal, "stock"]
  rule [[:@weak_buy_signal, "stock"], :and, ["stock", :below_avg_vol, "volume"]], :then, [:@check_rsi, "stock"]
  rule [[:@check_rsi, "stock"], :and, ["stock", :rsi_below_30, "rsi"]], :then, [:@strong_buy_signal, "stock"]
  rule [[:@check_rsi, "stock"], :and, ["stock", :rsi_above_30, "rsi"]], :then, [:@buy_signal, "stock"]
  rule [[:@strong_buy_signal, "stock"], :and, ["stock", :costs, "price"]], :then, ["stock", :buy, "20"] do
    do_action :execute_buy_20, stock: "stock", price: "price"
  end
  rule [[:@buy_signal, "stock"], :and, ["stock", :costs, "price"]], :then, ["stock", :buy, "10"] do
    do_action :execute_buy_10, stock: "stock", price: "price"
  end

  # NOTE: sell signals
  rule ["stock", :two_std_below, "long_avg"], :then, [:@strong_sell_signal, "stock"]
  rule ["stock", :one_std_below, "long_avg"], :then, [:@weak_sell_signal, "stock"]
  rule [[:@weak_sell_signal, "stock"], :and, ["stock", :above_avg_vol, "volume"]], :then, [:@strong_sell_signal, "stock"]
  rule [[:@weak_sell_signal, "stock"], :and, ["stock", :below_avg_vol, "volume"]], :then, [:@check_rsi, "stock"]
  rule [[:@check_rsi, "stock"], :and, ["stock", :rsi_below_70, "rsi"]], :then, [:@strong_sell_signal, "stock"]
  rule [[:@check_rsi, "stock"], :and, ["stock", :rsi_above_70, "rsi"]], :then, [:@sell_signal, "stock"]

  rule [[:@strong_sell_signal, "stock"], :and, ["stock", :costs, "price"]], :then, ["stock", :sell, 20] do
    do_action :execute_sell_20, stock: "stock", price: "price"
  end
  rule [[:@sell_signal, "stock"], :and, ["stock", :costs, "price"]], :then, ["stock", :sell, 10] do
    do_action :execute_sell_10, stock: "stock", price: "price"
  end
end


MarketSimulation.run(stock_updates, kb)

puts BROKER.portfolio.cash, BROKER.portfolio.stocks