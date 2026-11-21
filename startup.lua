---
--- Created by luedalsa
--- DateTime: 11/21/26 11:27 AM
---

local periph = require("peripherals")
periph.register("monitor_principal", "left")
periph.registerType("almacen", "minecraft:chest")
local mon = periph.get("monitor_principal")