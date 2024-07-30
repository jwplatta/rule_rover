# Trading Strategy

The core example is here.
```rb
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
```