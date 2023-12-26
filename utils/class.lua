-- classlib.lua

-- Utility functions
local getmetatable, setmetatable = getmetatable, setmetatable
local tonumber, tostring = tonumber, tostring

local strToIntCache = {
    ["vector2"] = 2,
    ["vector3"] = 3,
    ["vector4"] = 4,
}

oopUtil = {
    classReg = {},
    classMetaReg = {},
    instanceReg = setmetatable({}, { __mode = "kv" }),
    eventHandler = {},

    transfromEventName = function(eventName, isReverse)
        return isReverse and (eventName:sub(3, 3):lower() .. eventName:sub(4)) or ("on" .. eventName:sub(1, 1):upper() .. eventName:sub(2))
    end,

    getVectorType = function(vec)
        if type(vec) == "userdata" then
            local typeName = getUserdataType(vec)
            if typeName == "vector" then
                return strToIntCache[typeName]
            end
        end
        return false
    end,

    deepCopyWithMeta = function(obj)
        local function copy(obj)
            if type(obj) ~= "table" then return obj end
            local newTable = {}
            for k, v in pairs(obj) do
                newTable[copy(k)] = copy(v)
            end
            return setmetatable(newTable, getmetatable(obj))
        end
        return copy(obj)
    end,

    splitKeyValue = function(theTable)
        local keyTable, valueTable = {}, {}
        for key, value in pairs(theTable) do
            keyTable[#keyTable + 1] = key
            valueTable[#valueTable + 1] = value
        end
        return keyTable, valueTable
    end,

    deepCopy = function(obj, parent)
        local function copy(obj)
            if type(obj) ~= "table" then return obj end
            local newTable = {}
            for k, v in pairs(obj) do
                newTable[copy(k)] = (k == "parent") and parent or copy(v, obj)
            end
            return newTable
        end
        return copy(obj)
    end,

    shallowCopy = function(obj)
        local copy = {}
        for k, v in pairs(obj) do
            copy[k] = v
        end
        return copy
    end,

    assimilate = function(t1, t2, except)
        if not t1 or not t2 then return end
        local exceptTable = {}
        if type(except) == "table" then
            for i = 1, #except do
                exceptTable[except[i]] = true
            end
        end
        for k, v in pairs(t2) do
            if not exceptTable[k] then
                t1[k] = v
            end
        end
    end,

    spreadFunctionsForClass = function(class, classTemplate)
        oopUtil.assimilate(class, classTemplate, { "expose", "constructor", "default" })
        oopUtil.assimilate(class.default, classTemplate)
    end,
}

function class(name)
    return function(classTable)
        oopUtil.classReg[name] = classTable
        oopUtil.classMetaReg[name] = { __index = {} }
        local meta = {
            __call = function(classTemplate, ...)
                local newInstance = {}
                setmetatable(newInstance, oopUtil.classMetaReg[name])
                if classTemplate.constructor then
                    classTemplate.constructor(newInstance, ...)
                else
                    local copyData = ...
                    if type(copyData) == "table" then
                        for k, v in pairs(copyData) do
                            newInstance[k] = v
                        end
                    end
                end
                return newInstance
            end,
        }

        if classTable.extend then
            local extendClasses = type(classTable.extend) == "table" and classTable.extend or { classTable.extend }
            for _, extendClass in ipairs(extendClasses) do
                local parentClass = oopUtil.classReg[extendClass]
                for extKey, extFunction in pairs(parentClass) do
                    if classTable[extKey] == nil then
                        classTable[extKey] = extFunction
                    end
                end
            end
        end

        if classTable.inject then
            for theType, space in pairs(classTable.inject) do
                local injectedData = oopUtil.classReg[theType] or {}
                for name, fnc in pairs(space) do
                    injectedData[name] = fnc
                end
                oopUtil.classReg[theType] = injectedData
            end
        end

        if classTable.methodContinue then
            classTable.methodContinueList = classTable.methodContinueList or {}
            for fncName, method in pairs(classTable.methodContinue) do
                if not classTable.methodContinueList[fncName] then
                    classTable.methodContinueList[fncName] = { classTable[fncName] }
                    classTable.methodContinueList[fncName][#classTable.methodContinueList[fncName] + 1] = method
                    if fncName == "getSize" then
                        classTable[fncName] = function(self, ...)
                            local fncs = classTable.methodContinueList[fncName]
                            local size = 0
                            for i = 1, #fncs do
                                if not fncs[i] then
                                    local db = debug.getinfo(2)
                                    print(db.source .. ":" .. db.currentline .. ": Bad continue at @" .. name)
                                end
                                local dSize = fncs[i](self, ...)
                                if not dSize then
                                    local db = debug.getinfo(2)
                                    print(db.source .. ":" .. db.currentline .. ": Bad size at @" .. name)
                                end
                                size = size + dSize
                            end
                            return size
                        end
                    else
                        classTable[fncName] = function(self, ...)
                            local fncs = classTable.methodContinueList[fncName]
                            for i = 1, #fncs do
                                if not fncs[i] then
                                    local db = debug.getinfo(2)
                                    print(db.source .. ":" .. db.currentline .. ": Bad continue at @" .. name)
                                end
                                fncs[i](self, ...)
                            end
                            return true
                        end
                    end
                else
                    local continueList = classTable.methodContinueList[fncName]
                    continueList[#continueList + 1] = method
                end
            end
            classTable.methodContinue = nil
        end

        meta.__index = { class = name }
        setmetatable(classTable, meta)
        oopUtil.spreadFunctionsForClass(oopUtil.classMetaReg[name].__index, classTable)
        oopUtil.classMetaReg[name].__index.class = name
        oopUtil.classMetaReg[name].__index.instance = true
        if not classTable.expose then
            _G[name] = classTable
        elseif oopUtil.classMetaReg[classTable.expose] then
            oopUtil.classMetaReg[classTable.expose].__index[name] = function(self, ...)
                return classTable(...)
            end
        end
    end
end

function recastClass(inst, newClass)
    setmetatable(inst, oopUtil.classMetaReg[newClass.class])
end

oopUtil.class = class

-- Section class
class "Section" {
    type = false,
    size = false,
    version = false,
    sizeVersion = false, -- Record size change

    read = function(self, readStream)
        if self.version then return end -- Already read
        if not readStream then
            local db = debug.getinfo(3)
            print(db.source .. ":" .. db.currentline .. ": Bad readStream at @" .. self.class)
        end
        self.type = readStream:read(uint32)
        self.size = readStream:read(uint32)
        self.version = readStream:read(uint32)
        self.sizeVersion = 0
        if self.typeID and self.typeID ~= self.type then
            local db = debug.getinfo(3)
            print(db.source .. ":" .. db.currentline .. ": Bad typeID at @" .. self.class .. ", expected " .. self.typeID .. ", got " .. self.type)
        end
    end,

    write = function(self, writeStream)
        self:getSize()

        if not writeStream then
            local db = debug.getinfo(3)
            print(db.source .. ":" .. db.currentline .. ": Bad writeStream at @" .. self.class)
        end
        if not tonumber(self.type) then
            local db = debug.getinfo(3)
            print(db.source .. ":" .. db.currentline .. ": Bad type at @" .. self.class)
        end
        if not tonumber(self.size) then
            local db = debug.getinfo(3)
            print(db.source .. ":" .. db.currentline .. ": Bad size at @" .. self.class)
        end
        if not tonumber(self.version) then
            local db = debug.getinfo(3)
            print(db.source .. ":" .. db.currentline .. ": Bad version at @" .. self.class)
        end

        writeStream:write(self.type, uint32)
        writeStream:write(self.size, uint32)
        writeStream:write(self.version, uint32)
    end,

    getSize = function(self, excludeSection)
        return excludeSection and 0 or 12
    end,

    convert = function(self, targetVersion)
        self.version = targetVersion
    end,
}

-- Struct class
class "Struct" {
    typeID = 0x01,
    extend = "Section",

    init = function(self, version)
        self.size = 0
        self.version = version
        self.type = Struct.typeID
        return self
    end,
}

-- Extension class
class "Extension" {
    typeID = 0x03,
    extend = "Section",

    init = function(self, version)
        self.size = 0
        self.version = version
        self.type = Extension.typeID
        return self
    end,

    update = function(self)
        self.size = self:getSize(true)
    end,
}