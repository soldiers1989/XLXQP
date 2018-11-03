--[[
   文件名称:NNHallPiPei.lua
   创 建 人: 
   创建时间：2017.12
   功能描述：
]]--

local  UINode = 
{

}

-- 刷新焖鸡房间基础数据
function RefreshPiPeiNNRoomBaseInfo()
    local menjiRootTransform = this.transform
    for index = 1, 4, 1 do
        local config = GameConfig.GetPublicRoomConfigDataByTypeLevel(4,index)
        local childTransform = menjiRootTransform:Find('RoomInfo' .. index)
        if config ~= nil and childTransform ~= nil then
            childTransform:Find('BetLimit/ChipMinTitle/ChipMin'):GetComponent('Text').text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(config.LowLimit))
            childTransform:Find('BetLimit/ChipLimitTitle/ChipLimit'):GetComponent('Text').text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(config.EnterLimit))
        end
    end
end


--==============================--
--desc:进入牛牛匹配房间
--time:2018-01-29 03:38:22
--@subTypeParam:
--@return 
--==============================--
function EnterNPiPeiRoom(subTypeParam)
    
        local _canEnter = true
        if subTypeParam > 0 then
            local _config = GameConfig.GetPublicRoomConfigDataByTypeLevel(4,subTypeParam)
            if GameData.RoleInfo.GoldCount < _config.EnterLimit then
                _canEnter = false
                local boxData = CS.MessageBoxData()
                boxData.Title = "温馨提示"
                boxData.Content = string.format(data.GetString("JH_Enter_MJRoom_Tips"),lua_CommaSeperate(GameConfig.GetFormatColdNumber(_config.EnterLimit)),_config.Name)
                boxData.Style = 3
                boxData.OKButtonName = "确定"
                boxData.LuaCallBack = nil
                CS.MessageBoxUI.Show(boxData)
            end
        end
        if _canEnter then
            Send_CS_NNPP_Enter_Room(subTypeParam,0)
        end
    end


function HandleNotifyNNPPRoomOnlineEvent()
    for index = 1, 4, 1 do
        local  _data  = NNGameMgr.NNRoomPPOnline[index]
        local childTransform = this.transform:Find('RoomInfo' .. index)
        if _data ~= nil and childTransform ~= nil then
            childTransform:Find('Online/Text'):GetComponent('Text').text = tostring(_data.OnlineCount)
        else
            childTransform:Find('Online/Text'):GetComponent('Text').text = tostring(0)
        end
    end
end

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    RefreshPiPeiNNRoomBaseInfo()
    this.transform:Find('RoomInfo1'):GetComponent("Button").onClick:AddListener( function() EnterNPiPeiRoom(1) end)
    this.transform:Find('RoomInfo2'):GetComponent("Button").onClick:AddListener( function() EnterNPiPeiRoom(2) end)
    this.transform:Find('RoomInfo3'):GetComponent("Button").onClick:AddListener( function() EnterNPiPeiRoom(3) end)
    this.transform:Find('RoomInfo4'):GetComponent("Button").onClick:AddListener( function() EnterNPiPeiRoom(4) end)


    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyNNPPRoomOnlineEvent, HandleNotifyNNPPRoomOnlineEvent)
end

-- Unity MonoBehavior Start 时调用此方法
function Start()

end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyNNPPRoomOnlineEvent, HandleNotifyNNPPRoomOnlineEvent)
end