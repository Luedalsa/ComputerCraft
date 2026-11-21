-- peripherals.lua
-- Registro compartido de perifericos: id (string) -> periferico.
--
-- Uso:
--   local periph = require("peripherals")
--   periph.register("monitor_principal", "top")
--   periph.registerType("almacen", "minecraft:chest")
--   local mon = periph.get("monitor_principal")
--
-- El registro vive en _G, asi que todos los scripts que hagan require
-- (aunque sean programas distintos o pestanas de multishell) ven los mismos ids.

local REGISTRY_KEY = "__peripherals_registry"

local registry = rawget(_G, REGISTRY_KEY)
if not registry then
    registry = {}
    rawset(_G, REGISTRY_KEY, registry)
end

local M = {}

local function checkId(id)
    if type(id) ~= "string" or id == "" then
        error("el id debe ser un string no vacio", 3)
    end
end

--- Registra un periferico bajo un id.
-- @param id string  identificador unico (ej. "monitor_principal")
-- @param target string|table  nombre/lado del periferico ("top", "monitor_3")
--                             o un periferico ya envuelto con peripheral.wrap
-- @param overwrite boolean  permite reemplazar un id ya existente (por defecto false)
-- @return boolean, string|nil
function M.register(id, target, overwrite)
    checkId(id)

    local name = target
    if type(target) == "table" then
        name = peripheral.getName(target)
    end
    if type(name) ~= "string" then
        return false, "target debe ser el nombre del periferico o un periferico envuelto"
    end
    if not peripheral.isPresent(name) then
        return false, "no hay ningun periferico conectado en '" .. name .. "'"
    end
    if registry[id] and not overwrite then
        return false, "el id '" .. id .. "' ya esta registrado"
    end

    registry[id] = { name = name, type = peripheral.getType(name) }
    return true
end

--- Busca el primer periferico de un tipo y lo registra bajo un id.
-- @param id string
-- @param ptype string  tipo (ej. "monitor", "modem", "minecraft:chest")
-- @param overwrite boolean
-- @return boolean, string|nil
function M.registerType(id, ptype, overwrite)
    checkId(id)
    local found = peripheral.find(ptype)
    if not found then
        return false, "no se encontro ningun periferico de tipo '" .. tostring(ptype) .. "'"
    end
    return M.register(id, found, overwrite)
end

--- Devuelve el periferico envuelto asociado al id.
-- Se vuelve a envolver en cada llamada, asi que es seguro si el periferico
-- se desconecto y reconecto.
-- @return table|nil, string|nil
function M.get(id)
    checkId(id)
    local entry = registry[id]
    if not entry then
        return nil, "id no registrado: '" .. id .. "'"
    end
    local obj = peripheral.wrap(entry.name)
    if not obj then
        return nil, "el periferico '" .. entry.name .. "' (id '" .. id .. "') no esta conectado"
    end
    return obj
end

--- Igual que get, pero lanza error si no se puede obtener.
function M.require(id)
    local obj, err = M.get(id)
    if not obj then error(err, 2) end
    return obj
end

--- Indica si el id esta registrado.
function M.has(id)
    checkId(id)
    return registry[id] ~= nil
end

--- Indica si el id esta registrado y su periferico esta conectado ahora.
function M.isConnected(id)
    checkId(id)
    local entry = registry[id]
    return entry ~= nil and peripheral.isPresent(entry.name)
end

--- Nombre fisico (lado o nombre de red) asociado al id.
function M.getName(id)
    checkId(id)
    local entry = registry[id]
    return entry and entry.name or nil
end

--- Tipo del periferico asociado al id.
function M.getType(id)
    checkId(id)
    local entry = registry[id]
    return entry and entry.type or nil
end

--- Elimina un id del registro.
function M.remove(id)
    checkId(id)
    local existed = registry[id] ~= nil
    registry[id] = nil
    return existed
end

--- Lista ordenada de todos los ids registrados.
function M.ids()
    local list = {}
    for id in pairs(registry) do list[#list + 1] = id end
    table.sort(list)
    return list
end

--- Vacia todo el registro.
function M.clear()
    for id in pairs(registry) do registry[id] = nil end
end

return M
