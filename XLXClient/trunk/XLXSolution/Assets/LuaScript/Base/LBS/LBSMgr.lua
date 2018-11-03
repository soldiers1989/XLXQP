--[[
   文件名称:LBSMgr.lua
   创 建 人: 
   创建时间：2018.03
   功能描述：
]]--

if LBSMgr == nil then
    LBSMgr =
    {
        -- 维度值(最大，最小) 经度值(最大，最小)
        BigArea = {18.00, 53.45, 73.72, 135.06}
    }
end

--==============================--
--desc:获取位置信息(维度，经度)
--time:2017-11-27 10:41:25
--@fLatitude: 维度值
--@fLongitude: 经度值
--@return 区域ID, 区域配置数据, 区域描述
function LBSMgr:GetLBSInfo(fLatitude, fLongitude)
    -- 大区域检测
    if fLatitude < LBSMgr.BigArea[1] or   fLatitude > LBSMgr.BigArea[2] or  fLongitude < LBSMgr.BigArea[3] or fLongitude > LBSMgr.BigArea[4] then
        return 0, nil, '未知区域'
    end
    local tLatitudeMin = fLatitude - 1
    local tLatitudeMax = fLatitude + 1
    local tLongitudeMin = fLongitude - 2
    local tLongitudeMax = fLongitude + 2

    local tResult = {}
    local tAreaID = 0
    for key, node in pairs(data.LBSAreaConfig) do
        if (node.Latitude >= tLatitudeMin and node.Latitude <= tLatitudeMax) and ( node.Longitude >= tLongitudeMin and node.Longitude <= tLongitudeMax) then
            tResult[key] = node
            tAreaID = key
        end
    end
    local tCount = lua_CountTB(tResult)
    if tCount > 0 then
        if tCount == 1 then
            return tAreaID,data.LBSAreaConfig[tAreaID],string.format('%s.%s',tResult[tAreaID].Province, tResult[tAreaID].City)  
        else
            local tMinDistance = lua_TwoPointToDistance(fLatitude, fLongitude, tResult[tAreaID].Latitude, tResult[tAreaID].Longitude)
            local tmpDistance = 0
            for k2,tNode in pairs(tResult) do
                tmpDistance = lua_TwoPointToDistance(fLatitude, fLongitude, tNode.Latitude, tNode.Longitude)
                if tmpDistance <= tMinDistance then
                    tMinDistance = tmpDistance
                    tAreaID = k2
                end
            end
            return tAreaID,data.LBSAreaConfig[tAreaID], string.format('%s.%s',tResult[tAreaID].Province, tResult[tAreaID].City)  
        end
    else
        return 0, nil, '未知区域'
    end
end

--==============================--
--desc:获取两点之间的距离
--time:2018-03-20 08:37:20
--@lat1: 目标点1 维度
--@lng1: 目标点1 经度
--@lat2: 目标点2 维度
--@lng2: 目标点2 经度
--@return 
--==============================--
function LBSMgr:GetDistance(lat1, lng1, lat2, lng2)
    local distance = CS.TileSystem.GetDistance(lat1,lng1, lat2,lng2)
    if distance < 10000 then
        return string.format('%d 米', math.ceil(distance))
    else
        return string.format('%.2f 千米', distance / 1000)
    end
end

--==============================--
--desc:随机一个地理位置
--time:
--@return 
--==============================--
function LBSMgr:RandomLocation()
    local tRandom = math.random(100,2395)
    local tData = data.LBSAreaConfig[tRandom]
    if tData ~= nil then
        return  string.format('%s.%s',tData.Province, tData.City)
    end
    print("==============111111111111=========地理位置:",tRandom)
    return "中国.台湾"
end