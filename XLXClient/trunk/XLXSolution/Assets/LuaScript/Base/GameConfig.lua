data = {};

GameConfig = {
    -- ==========================================================
    -- ==========================================================
    -- 开发测试阶段可开启 *****正式版本一定要记住关闭该功能*****
    -- 开发测试阶段可开启 *****正式版本一定要记住关闭该功能*****
    -- 开发测试阶段可开启 *****正式版本一定要记住关闭该功能*****
    IsDebug = false,
    -- 是否是审核版本
    IsShenHeiVision = false,
    -- 是否游客登录
    CanVisitorLogin = false,

    -- ==========================================================
    -- ========================服务器域名相关=====================
    -- ==========================================================
    -- 连接的HubServerURL 域名:
    -- 正式  服务器:9527.hub.9527youxi.com          39.106.126.15
    -- 苹果审核域名:xlx168.v101hub.sylyedu.com      47.254.64.25
    -- 外网测  试服:xlx168.hub.out.sylyedu.com      47.75.241.60
    -- 本地服  务器:192.168.50.101
    HubServerURL = "192.168.50.102",
    -- HubServerURL = "47.75.241.60",
    -- HubServerURL = "9527.hub.9527youxi.com",
    -- 服务器地址由hub服务器分发
    GameServerURL = "47.95.193.224",
    -- 链接服务器地址 由服务器下发
    HubServerPort = 20000,
    GameServerIP = "",
    GameServerPort = 30000,

    -- ==========================================================
    -- ========================游戏内相关URL=====================
    -- 微信分享连接
    WXSharedUrl = "http://vip.appurl.me/22559157",
    -- 推广分享连接
    TGSharedUrl = "http://tgy.ios007.com/",
    -- 客服中心官方网站
    KFUrl = "889527.com",
    -- IP地理位置解析URL
    MobileIPLocationUrl = "http://update.sylyedu.com/server/tool/getipinfo.php",
    -- 支付URL
    ZhiFuURL = "http://hnxcysw.com/server/Pay/chooseczpass.php",
    -- 充值测试URL
    CZCSurl = "http://103.48.171.161/server/Pay/chooseczpass.php",
    -- 公告url 正式服47.75.169.181
    AdvertiseContentUrl = "http://47.75.169.181/Public/upload/images/content",
    AdvertiseBannerUrl = "http://47.75.169.181/Public/upload/images/banner",

    -- ====================================================
    -- IP位置校验Url
    IPAddressUrl = "http://update.sylyedu.com/server/tool/getip.php",
    -- IP地址是否获取完毕
    IPHandle = false,
    IPAddress = "",

}

-- 牛牛组局房间最大人数
MAX_NNZUJU_ROOM_PLAYER = 6
-- 金花组局房间最大人数
JHZUJU_ROOM_PLAYER_MAX = 6
-- 推筒子组局房间最大人数
MAX_TTZZUJU_ROOM_PLAYER = 6
-- 麻将组局房间最大人数
MAX_MJZUJU_ROOM_PLAYER = 4

-- 红包接龙房间最大人数
MAX_HBZUJU_ROOM_PLAYER = 8

-- 跑的快组局放进啊最大人数
MAX_PDKZUJU_ROOM_PLAYER = 3

-- 获取字符串，如果没找到则返回Key
function data.GetString(strKey)
    local result = data.StringConfig[strKey]
    if result ~= nil then
        return result.Value_CN
    end
    return strKey
end

-- 未处理事件参数
UuHandleFlagEventArgs = {
    -- 是否包含未处理
    ContainsUnHandle = false,
    -- 未处理的数量
    UnHandleCount = 0,
}

-- 搓牌进度事件参数
HandlePokerEventArgs = {
    HandlerID = 0,
    PokerIndex = 0,
    IsRotate = false,
    FlipMode = 0,
    MoveX = 0,
    MoveY = 0,
}

function GameConfig.Init()
    require 'Base/Config/RoomConfig'
    require 'Base/Config/VipConfig'
    require 'Base/Config/StringConfig'
    require 'Base/Config/RunHorseConfig'
    require 'Base/Config/MaskConfig'
    require 'Base/Config/StoreConfig'
    require 'Base/Config/PublicConfig'
    require 'Base/Config/MusicConfig'
    require 'Base/Config/MailContentConfig'
    require 'Base/Config/MusicGroupConfig'
    require 'Base/Config/NewcongressConfig'
    require 'Base/Config/PublicroomConfig'
    require 'Base/Config/TurnTableConfig'
    require 'Base/Config/ShishicaiConfig'
    require 'Base/Config/TaskConfig'
    require 'Base/Config/SalesmaniphoneConfig'
    require 'Base/Config/MenjitaskConfig'
    require 'Base/Config/BenchibaomaConfig'
    require 'Base/Config/HongbaoroomConfig'
    require 'Base/Config/LBSAreaConfig'
    require 'Base/Config/HallLayoutConfig'
    require 'Base/Config/BankConfig'

    GameConfig.InitChipValueByConfig()
    print('Inited game configs')
end

function GameConfig.InitChipValueByConfig()
    if data.PublicConfig ~= nil and data.PublicConfig.CHIP_VALUE ~= nil then
        CHIP_VALUE = {}
        for k, value in ipairs(data.PublicConfig.CHIP_VALUE) do
            CHIP_VALUE[k] = value * 10000
        end
    end
end

-- 格式化金币的显示
function GameConfig.GetFormatColdNumber(logicGold)
    -- data.PublicConfig.GOLD_TO_RMB_RATE
    -- data.PublicConfig.VALID_DECIMAL
    local formatGold = logicGold / data.PublicConfig.GOLD_TO_RMB_RATE
    return formatGold
end

-- 金币的值逆转
function GameConfig.GetLogicColdNumber(formatGold)
    local logicGold = formatGold * data.PublicConfig.GOLD_TO_RMB_RATE
    return logicGold
end

--==============================--
--desc:获取房间配置数据(焖鸡房,组局房)
--time:2017-11-28 07:25:38
--@typeParam:
--@levelParam:
--@return PublicroomConfig
--==============================--
function GameConfig.GetPublicRoomConfigDataByTypeLevel(typeParam, levelParam)
    local tmpData = {}
    for key, config in pairs(data.PublicroomConfig) do
        if config.Type == typeParam and config.Level == levelParam then
            tmpData = config
            break
        end
    end
    return tmpData
end


--==============================--
--desc: 获取组局牛牛各个状态时间
--time:2018-01-02 02:56:21
--@roomType:
--@roomState:
--@return 
--==============================--
function data.Get_ROOM_STATE_TIME(roomType, roomState)
    local stateTime
    if roomType == ROOM_TYPE.ZuJuNN or roomType == ROOM_TYPE.PiPeiNN then
        stateTime = data.PublicConfig.NNQZ_ROOM_TIME[roomState]
    elseif roomType == ROOM_TYPE.ZuJuTTZ or roomType == ROOM_TYPE.PiPeiTTZ then
        stateTime = data.PublicConfig.TTZ_ROOM_TIME[roomState]
    elseif roomType == ROOM_TYPE.LHDRoom then
        stateTime = data.PublicConfig.LHD_ROOM_TIME[roomState]
    elseif roomType == ROOM_TYPE.BJLRoom then
        stateTime = data.PublicConfig.BJL_ROOM_TIME[roomState]
    end
    if stateTime == nil then
        stateTime = 1
        print(string.format("Time error of room type[%d] of room state [%d], use default time 1s", roomType, roomState))
    end
    return stateTime
end

--==============================--
--desc:获取房间配置数据(红包接龙)
--time:2018-01-19 16:53:22
--@typeParam:
--@levelParam:
--@return HongbaoroomConfig
--==============================--
function GameConfig.HongbaoroomConfigDataByTypeLevel(typeParam, levelParam)
    local tmpData = {}
    for key, config in pairs(data.HongbaoroomConfig) do
        if config.Type == typeParam and config.RoomLevel == levelParam then
            tmpData = config
            break
        end
    end
    return tmpData
end

-- 美国IP检测
function GameConfig.ReqIPAddress()
    print("=====111============IP Address Time1:", CS.UnityEngine.Time.time)
    GameConfig.IPHandle = false
    local paramTable = {}
    paramTable['aid'] = tostring(CS.UnityEngine.SystemInfo.deviceUniqueIdentifier)
    -- 平台标识
    paramTable['tid'] = "ios"
    CS.LuaAsynFuncMgr.Instance:HttpPost(GameConfig.IPAddressUrl, paramTable, GameConfig.CallUSIPCheck)
end

-- IP位置校验
function GameConfig.CallUSIPCheck(paramResult)
    print("=====222============IP Address Time2:", CS.UnityEngine.Time.time, paramResult)
    if nil == paramResult then
        GameConfig.IPHandle = false
    else
        GameConfig.IPHandle = true
        local tPos = string.find(paramResult, 'ip=')
        if tPos ~= nil and tPos == 1 then
            GameConfig.IPAddress = string.sub(paramResult, tPos + 3)
        else
            GameConfig.IPHandle = false
        end
    end
end

-- 检测是否SH or 特殊地址
function GameConfig.IsSpecial()

    if GameConfig.IsShenHeiVision or GameData.IsOpenApplePay == 1 then
        return true
    else
        return false
    end
end

-- 开启商城UI 适配审核版商城
function GameConfig.OpenStoreUI()

    local UIName = 'UIExtract'
    if GameConfig.IsSpecial() then
        UIName = 'UIStoreIOS'
        return
    end

    local tUINode = CS.WindowManager.Instance:FindWindowNodeByName(UIName)
    if tUINode == nil then
        CS.WindowManager.Instance:OpenWindow(UIName)
    end
end

--==============================--
--desc:开启创建房间UI
--time:
--@roomType: 游戏房间类型
--@openType: 开启类型(1 全局类型 2茶馆类型)
--@return 
--==============================--
function GameConfig.OpenCreateRoomUI(roomType, openType)
    GameConfig.CreateRoomUIOpenType = openType
    local openparam = CS.WindowNodeInitParam("CreateRoomUI")
    openparam.NodeType = 0
    openparam.WindowData = { RoomType = roomType, OpenType = openType }
    CS.WindowManager.Instance:OpenWindow(openparam)
end

-- 更新玩家IP地址
function GameConfig.UpdateIPAddress(ipAddress)

    if ipAddress ~= GameData.RoleInfo.LoginIPAddress then
        GameData.RoleInfo.LoginIPAddress = ipAddress
        GameData.RoleInfo.IPAddressIsChange = true
    else
        GameData.RoleInfo.IPAddressIsChange = false
    end
end

function GameConfig.HandleMoblieIPLocation()
    if GameData.RoleInfo.IPSend2Server >= 3 and not GameData.RoleInfo.IPAddressIsChange then
        -- IP 地址并未发生变化 并且已经上传当前地理位置
        return
    end
    print("=====11111===== IP 请求:", CS.UnityEngine.Time.time)
    local IPURL = GameConfig.MobileIPLocationUrl
    local paramTable = {}
    paramTable['accountid'] = GameData.RoleInfo.AccountID
    paramTable['ip'] = GameData.RoleInfo.LoginIPAddress

    CS.LuaAsynFuncMgr.Instance:HttpPost(IPURL, paramTable, GameConfig.CallMobileIPLocation)
end

function GameConfig.CallMobileIPLocation(paramResult)
    print("*****位置解析反馈 1:", paramResult)
    local tIPLocation = "未知区域..."
    local tISCN = true
    if nil == paramResult then
        tIPLocation = "未知区域..."
        tISCN = false
    else
        local index1 = string.find(paramResult, 'ipinfo=')
        if index1 == 0 or index1 == nil then
            tIPLocation = "未知区域..."
            tISCN = false
        else
            -- IP信息：1:code 2:account 3:ip 4:country 5:region(省) 6:city(市) 7:county(郡县) 8:country_id
            -- {"code":0,"data":{"ip":"62.164.192.0","country":"英国","region":"XX","city":"XX","county":"XX","country_id":"GB"}}
            -- 0,99887765412,110.165.63.255,    香港,香港,XX,XX,HK
            -- 0,99887765412,052.000.000.000,   美国,弗吉尼亚,阿什本,XX,US
            -- 0,99887765412,38.31.145.0,       美国,XX,XX,XX,US
            -- 0,99887765412,43.229.0.1,        印度,古吉拉特,XX,XX,IN
            -- 0,99887765412,219.144.25.5,      中国,陕西,延安,XX,CN
            -- 0,99887765412,212.63.191.40,     德国,XX,XX,XX,DE
            -- 0,99887765412,130.153.0.0,       日本,XX,XX,XX,JP
            -- 0,99887765412,203.79.132.0,      台湾,台湾,XX,XX,TW
            -- 0,99887765412,192.168.0.1,       XX,XX,内网IP,内网IP,xx
            local ipinfo = string.sub(paramResult, index1 + 7)
            local tLocation = lua_string_split(ipinfo, ',')
            if #tLocation ~= 8 then
                tIPLocation = "未知区域..."
                tISCN = false
            else
                if tLocation[4] == "xx" or tLocation[4] == "XX" then
                    tIPLocation = "未知区域..."
                elseif tLocation[5] == "xx" or tLocation[5] == "XX" then
                    tIPLocation = tLocation[4]
                elseif tLocation[6] == "xx" or tLocation[6] == "XX" then
                    tIPLocation = string.format("%s.%s", tLocation[4], tLocation[5])
                elseif tLocation[7] == "xx" or tLocation[7] == "XX" then
                    tIPLocation = string.format("%s.%s", tLocation[5], tLocation[6])
                else
                    tIPLocation = "未知区域..."
                end
                if tLocation[8] == "CN" or tLocation[8] == "TW" or tLocation[8] == "HK" then
                    -- 检查是否属于国内IP
                    tISCN = true
                else
                    tISCN = false
                end
            end
        end
    end
    if not tISCN then
        tIPLocation = LBSMgr:RandomLocation()
    end
    print("=====11111===== IP 位置:", CS.UnityEngine.Time.time, tIPLocation)
    GameData.RoleInfo.IPLocation = tIPLocation
    NetMsgHandler.Send_CS_IP_LOCATION()
end