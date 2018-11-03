--[[
   文件名称:BJLRoom.lua
   创 建 人:
   创建时间：2018.06
   功能描述：
]]--

if BJLRoom == nil then
    BJLRoom = {}
end

function BJLRoom:New()
    local  tNode = 
    {
        -- 房间ID
        RoomID = 10,
        -- 房间名称
        RoomName = '小龙虾[龙虎斗]',
        -- 房间模板配置ID
        TemplateID = 0,
        -- 房间类型
        RoomType = ROOM_TYPE.BJLRoom,
        -- 房主ID
        MasterID = 0,
        -- 房间人数
        RoleCount = 0,
        -- 最大游戏局数
        MaxRound = 64,
        -- 当前第几局
        CurrentRound = 0,
        -- 房间当前阶段
        RoomState = BJL_ROOM_STATE.WAIT,
        -- 倒计时
        CountDown = 20,
        -- 剩余牌数量
        CardCount = 123,
        -- 剩余牌缓存数量
        CacheCardCount = 123,
        -- 切牌(CUT)Pos
        CutAniIndex = 32,
        -- 切牌(CUT)数据(花色，点数)
        CutPoker = {},

        -- 自己各个区域下注数据
        BetValues = {},
        --  各区域总下注数据
        TotalBetValues = {},
        -- 当前桌面已有筹码信息
        CurrentRoomChips = {},
        -- 本局闲家牌数据
        PokersX = {},
        -- 本局庄家牌数据
        PokersZ = {},

        -- 庄家信息
        BankerInfo = { ID = 0, Name = "", Gold = 0, LeftCount = 0, HeadIcon = 0, strLoginIP = "", IsLastForceDownBanker = false, },
        
        -- 赢取的金币 (各个区域赢钱数据)
        WinGold = { },

        -- 玩家自己本局赢钱具体数据
        MasterWinGold = 0,
        MasterCurrentGold = 0,

        -- 当前选择下注的金额
        SelectBetValue = 0,
        -- 下注庄闲下限
        BetZXMin = 0,
        -- 下注庄闲上限
        BetZXMax = 0,
        -- 下注庄闲对下限
        BetZXDMin = 0,
        -- 下注庄闲对上限
        BetZXDMax = 0,
        -- 下注和下限
        BetHeMin = 0,
        -- 下注和上限
        BetHeMax = 0,
    }
    Extends(tNode, self)
    return tNode
end

function BJLRoom:Init( isInitAll, roomTypeParam)
    if isInitAll == true  then
        self:SetRoomState(BJL_ROOM_STATE.WAIT)
    end
    self.RoomType = roomTypeParam
end

function BJLRoom:SetRoomState(nState, nNextTime)
    local nRoomType = self.RoomType
    local nStateTime = 0
    if nNextTime == nil then
        nStateTime = data.Get_ROOM_STATE_TIME(ROOM_TYPE.BJLRoom, nState)
    end
    local nTime = nNextTime or nStateTime
    self.RoomState = nState
    self.CountDown = nTime
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateRoomState, nState)
    return nTime
end

--==============================--
--desc:获取房间当前人数
--time:2018-01-25 02:22:03
--@return 
--==============================--
function BJLRoom:PlayerCount()
    return self.RoleCount
end
