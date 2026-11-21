---
--- Created by luedalsa
--- DateTime: 11/21/26 11:27 AM
---

local periph = require("peripherals")
periph.register("stock_ticker", "right")
local stock_ticker = periph.get("stock_ticker")
print(stock_ticker.stock())