-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function lua_string_split(str, split_char)
    local sub_str_tab = { }
    while (true) do
        local pos = string.find(str, split_char)
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str
            break
        end
        local sub_str = string.sub(str, 1, pos - 1)
        sub_str_tab[#sub_str_tab + 1] = sub_str
        str = string.sub(str, pos + #split_char, #str)
    end
    return sub_str_tab
end

-- 参数:数字
-- 返回:table 按照数字的大小排序
function lua_number_sort(...)
    local arg = { ...}
    table.sort(arg)
    return arg
end

-- 扩展传入table，让他具有vmt的功能
-- 暂时放這里等有了合适的地方再挪过去 by hc 2017-3-5
function Extends(tTable, vmt)
    local mt = { __index = vmt }
    setmetatable(tTable, mt)
    return tTable
end

-- 创建扩展表结果
function lua_NewTable(SourceTable)
    local tTable = { }
    local mt = { __index = SourceTable }
    setmetatable(tTable, SourceTable)
    return tTable
end

function lua_Transform_ClearChildren(transform, keepFirst)
    if transform ~= nil then
        local childCount = transform.childCount
        if childCount ~= 0 then
            local endFlag = 0
            if keepFirst then
                endFlag = 1
            end
            for index = childCount - 1, endFlag, -1 do
                CS.UnityEngine.Object.Destroy(transform:GetChild(index).gameObject)
            end
        end
    end
end

-- 删除指定名称的子Transform
function lua_Transform_RemoveChildByName(transform, removeWithName)
    if transform ~= nil and removeWithName ~= nil then
        local childCount = transform.childCount
        if childCount ~= 0 then
            for index = childCount - 1, 0, -1 do
                if transform:GetChild(index).gameObject.name == removeWithName then
                    CS.UnityEngine.Object.Destroy(transform:GetChild(index).gameObject)
                end
            end
        end
    end
end

-- 粘贴Transform 的值(本地位置，缩放，朝向)
function lua_Paste_Transform_Value(transA, transB)
    if transA ~= nil and transB ~= nil then
        transA.localPosition = transB.localPosition
        transA.localRotation = transB.localRotation
        transA.localScale = transB.localScale
    end
end

function lua_RandomXYOfVector3(minX, maxX, minY, maxY)
    local localX = math.random(minX, maxX)
    local localY = math.random(minY, maxY)
    return CS.UnityEngine.Vector3(localX, localY, 0)
end

-- lua table 值包含解析
function lua_TableContainsValue(sourceTable, value)
    if sourceTable ~= nil then
        for k, v in pairs(sourceTable) do
            if v == value then
                return true
            end
        end
    end
    return false
end

-- 删除数字字符串的 逗号分隔符
function lua_Remove_CommaSeperate(numberStr)
    return(string.gsub(numberStr, ",", ""))
end

-- 给数字添加上万分号(1,2345,6789)
function lua_CommaSeperate(number)
    return lua_AddSplitCharToNumber(number, ",", 4)
end

-- 添加分割字符的标号
function lua_AddSplitCharToNumber(number, splitChar, interval)
    if number == nil then
        number = 0
    end

    if splitChar == nil then
        splitChar = ","
    end

    local sign = ""
    if math.abs(number) ~= number then
        sign = "-"
        number = math.abs(number)
    end

    t1, t2 = math.modf(number)
    -- print("整数 = "..t1.."小数 = "..t2)

    number = t1

    if interval == nil then
        interval = 1
    else
        interval = math.floor(interval)
        if interval < 1 then
            interval = 1
        end
    end

    local valueStr = tostring(number)
    local resultStr = ""
    while true do
        local strLength = #valueStr
        if strLength > interval then
            resultStr = splitChar .. string.sub(valueStr, strLength - interval + 1, strLength) .. resultStr
            valueStr = string.sub(valueStr, 1, strLength - interval)
        else
            resultStr = valueStr .. resultStr
            break
        end
    end

    if t2 < 0.01 then
        return sign .. resultStr
    else
        t3 = GameData.SubFloatZeroPart(string.format("%.2f", t2))
        t3 = string.sub(t3, 2)
        -- print("t3 = "..t3)
        -- t2 = string.format(".%d", math.floor(math.abs(t2) * 100))
        return sign .. resultStr .. t3
    end

end

-- 返回带有加减号的格式化字符串
function lua_ToFloatFormatStringWhitFlag(number, floatLenght)
    local resultNumber = lua_GetPreciseDecimal(number, floatLenght)
    print("lua_ToFloatFormatStringWhitFlag", number, resultNumber)
    if resultNumber >= 0 then
        return '+' .. resultNumber
    else
        return '' .. resultNumber
    end
end

-- 截断浮点数，最大保留多少小数位
-- eg: 1.9909 保留1位结果：1.9 保留2位结果:1.99 保留三位  1.99 保留4 位 1.9909
-- eg: -1.9909 保留1位结果：-1.9 保留2位结果:-1.99 保留3位  -1.99 保留4位 -1.9909
function lua_GetPreciseDecimal(number, length)
    -- 非数字类型，直接返回
    if type(number) ~= "number" then
        return number
    end

    length = length or 0;
    length = math.floor(length)
    -- 是否是负数
    local isNegative =(number < 0)
    -- 数字取整，便于运算
    number = math.abs(number)

    local resultNumber = 0
    if length > 0 then
        local nDecimal = 10 ^ length
        resultNumber = math.floor(number * nDecimal) / nDecimal
    else
        resultNumber = math.floor(number)
    end

    -- 避免出现 1.0 这种情况
    local temp = math.floor(resultNumber)
    if resultNumber == temp then
        resultNumber = temp
    end

    -- 如果结果是0 则返回0
    if resultNumber == 0 then
        return 0
    else
        if isNegative then
            return - resultNumber
        else
            return resultNumber
        end
    end
end

-- Bool 变量取反
function lua_NOT_BOLEAN(value)
    if value then
        return false
    else
        return true
    end
end

-- Bool 字符串输出
function lua_BOLEAN_String(value)
    if value then
        return 'true'
    else
        return 'false'
    end
end

-- 数字转换为显示的字符串(如：2.00亿， 1.95万 )
function lua_NumberToStyle1String(number)
    if number == nil then
        return "0"
    end

    if number >= 100000000 or number <= -100000000  then
        return GameData.SubFloatZeroPart(string.format("%.2f", number / 100000000)) .. "亿"
    elseif number >= 10000 or number <= -10000  then
        return GameData.SubFloatZeroPart(string.format("%.2f", number / 10000)) .. "万"
    else
        return GameData.SubFloatZeroPart(string.format("%.2f", number))
    end
end

-- 数字转换为显示的字符串(如：2.00亿， 1.95万 )
function lua_NumberToStyle1String1(number)
    if number == nil then
        return "0"
    end

    if number >= 100000000 or number <= -100000000  then
        return GameData.SubFloatZeroPart(string.format("%.2f", number / 100000000)) .. "亿"
    elseif number >= 10000 or number <= -10000  then
        return GameData.SubFloatZeroPart(string.format("%.2f", number / 10000)) .. "万"
    elseif number >= 1000 or number <= -1000  then
        return GameData.SubFloatZeroPart(string.format("%.2f", number / 1000)) .. "仟"
    else
        return GameData.SubFloatZeroPart(string.format("%.2f", number))
    end
end

function lua_Clear_AllUITweener(transform)
    CS.Utility.ClearAllUITweener(transform)
end

function lua_Call_GC()
    CS.Utility.CallGC()
end

function lua_Math_Mod(v1, v2)
    return CS.Utility.GetLuaMod(v1, v2)
end

-- 获得指定时间戳对应一年中的第几天
-- 第一参数: 系统时间戳
-- 参数说明: 若不传参数或参数小于等于2015-10-1日时间戳, 返回当前系统时间戳对应的天数
-- 返回说明: 起始时间从1970-01-01 08:00:00
-- 返回说明: 返回值为整型 (单位天)
function lua_GetTimeToYearDay(nTimestamp)
    if nTimestamp == nil or nTimestamp <= 1443628800 then
        local strDay = os.date("%j")
        return tonumber(strDay)
    else
        local strDay = os.date("%j", nTimestamp)
        return tonumber(strDay)
    end
end



-- 获得当前系统时间戳的格式化参数表
-- 第一参数: 若为nil, 返回当前时间戳对应的时间table
-- 第一参数: 若非nil, 返回指定时间戳对应的时间table
-- 返回说明: 返回格式化后的新表, 新表有以下字段
-- : year  : 年    例如2015	
-- : month : 月    取值范围[1~12]
-- : day   : 日    取值范围[1~31]
-- : hour  : 小时  取值范围[0~23]
-- : min   : 分钟  取值范围[0~59]
-- : sec   : 秒数  取值范围[0~59]
function GetTimeToTable(nTimestamp)
    nTimestamp = nTimestamp or os.time()
    local tDate = os.date("*t", nTimestamp)
    local tFormat = { }
    tFormat.year = tDate.year
    tFormat.month = tDate.month
    tFormat.day = tDate.day
    tFormat.hour = tDate.hour
    tFormat.min = tDate.min
    tFormat.sec = tDate.sec
    return tFormat
end

-- 获取系统时间戳的字符串
-- 参数说明: 系统时间戳
-- 参数说明: 若不传参数或参数小于等于2015-10-1日时间戳, 返回当前系统时间戳的字符串
-- 返回说明: 起始时间从1970-01-01 08:00:00
-- 返回说明: 返回值为字符串, 格式 2015-09-26 23:59:59
function GetTimeToString(nTimestamp)
    if nTimestamp == nil or nTimestamp <= 1443628800 then
        return os.date("%Y-%m-%d %X")
    else
        return os.date("%Y-%m-%d %X", nTimestamp)
    end
end

-- 格式化为倒计时样式
function lua_FormatToCountdownStyle(number)
    return string.format("%02d", math.ceil(number))
end


-- 截取中英混合的UTF8字符串，endIndex可缺省
function lua_SubStringUTF8(str, startIndex, endIndex)
    str = str or ''
    if startIndex < 0 then
        startIndex = SubStringGetTotalCount(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = SubStringGetTotalCount(str) + endIndex + 1;
    end

    if endIndex == nil then
        return string.sub(str, SubStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, SubStringGetTrueIndex(str, startIndex), SubStringGetTrueIndex(str, endIndex + 1) -1);
    end
end

--==============================--
--desc:获取中英混合UTF8字符串的真实字符数量
--time:2018-02-27 08:37:20
--@str:字符串
--@return 字符串长度
--==============================--
function SubStringGetTotalCount(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until (lastCount == 0);
    return curIndex - 1;
end

function SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat
        lastCount = SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until (curIndex >= index);
    return i - lastCount;
end

-- 返回当前字符实际占用的字符数
function SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte >= 192 and curByte <= 223 then
        byteCount = 2
    elseif curByte >= 224 and curByte <= 239 then
        byteCount = 3
    elseif curByte >= 240 and curByte <= 247 then
        byteCount = 4
    end
    return byteCount;
end

--==============================--
--desc:组件显示状态设置通用接口
--time:2018-02-27 08:37:20
--@gameObject:
--@isActive:
--@return 
--==============================--
function GameObjectSetActive( gameObject, isActive )
    if gameObject == nil or gameObject.activeSelf == isActive then
        return
    end
    gameObject:SetActive(isActive)
end

--==============================--
--desc:平面2点间的距离
--time:2018-03-20 08:37:20
--@x1:
--@y1:
--@x2:
--@y2:
--@return 
--==============================--
function lua_TwoPointToDistance( x1, y1, x2, y2 )
    return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end

--==============================--
--desc:计算table表元素个数
--time:2018-03-20 08:37:20
--@tbData:
--@return 
--==============================--
function lua_CountTB( tbData )
    local count = 0
    if tbData then
        for i, val in pairs(tbData) do
            count = count + 1
        end
    end
    return count
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

-- 分隔字符串
--function string.split(sep)
--    local sep, fields = sep or "\t", {}
--    local pattern = string.format("([^%s]+)", sep)
--    string.gsub(pattern, function(c) fields[#fields+1] = c end)
--    return fields
--end
function string.split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

-- 主要用于显示表格, 表格，标识,显示表格的深度，默认3级
function PrintTable(value, desciption, nesting, show_meta)
    if type(nesting) ~= "number" then nesting = 3 end

    show_meta = show_meta or false
    local lookupTable = {}
    local result = {}
    local traceback = string.split(debug.traceback("", 2), "\n")

    local function dump_(value, desciption, indent, nest, keylen)
        desciption ="<color=#FF00FF> "..desciption.."</color>" or "<color=#bb5555> <table> </color>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep("", keylen - string.len(dump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)

                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, desciption, "\n", 1)
    local outStr="";
    for i, line in ipairs(result) do
        outStr = outStr..line
    end
    print(outStr)
    return outStr
end