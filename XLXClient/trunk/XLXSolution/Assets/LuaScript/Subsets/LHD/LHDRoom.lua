--[[
   文件名称:LHDRoom.lua
   创 建 人:
   创建时间：2018.06
   功能描述：
]]--

-- 【推筒子组局】玩家信息
if LHDPlayer == nil  then
    LHDPlayer = {}
end

function LHDPlayer:New(  )
    local tObj = 
    {
        -- 玩家ID
        ID = 0,
        -- 玩家位置
        Position = 1,
        -- 玩家名称
        Name = '张三',
        -- 玩家头像ID
        HeadIcon = 0,
        -- 玩家微信头像Url
        HeadIconUrl = '',
        -- 玩家金币值
        Gold = 0,

        -- 玩家状态 (0 空位 1 旁观者 2 已经准备 3参与游戏 4 抢庄 5 不抢庄 6 加倍 7 不加倍 8 看牌)
        PlayerState = PlayerStateEnumTTZ.NULL,
        -- 玩家可以下注倍率
        nCanCompensate = 0,
        -- 玩家下注倍率
        nBetCompensate = 0,

        -- 玩家的扑克信息 格式为: [1] = {PokerType = 1, PokerNumber = 13, Visible = false,}
        Pokers = 
        {
            [1] = {PokerType = 1, PokerNumber = 1, Visible = false,},
            [2] = {PokerType = 1, PokerNumber = 2, Visible = false,},
        },
        -- 玩家赢取金币数量
        WinGold = 0,
        -- 是否搓牌 0未搓 1已经搓牌
        IsCuoPai = 0,
    }
    Extends(tObj, self)
    return tObj
end 


if LHDRoom == nil then
    LHDRoom = {}
end

function LHDRoom:New()
    local  tNode = 
    {
        -- 房间ID
        RoomID = 10,
        -- 房间名称
        RoomName = '小龙虾[龙虎斗]',
        -- 房间模板配置ID
        TemplateID = 0,
        -- 房间类型
        RoomType = ROOM_TYPE.LHDRoom,
        -- 房主ID
        MasterID = 0,
        -- 房间人数
        RoleCount = 0,
        -- 最大游戏局数
        MaxRound = 64,
        -- 当前第几局
        CurrentRound = 0,
        -- 房间当前阶段
        RoomState = LHD_ROOM_STATE.WAIT,
        -- 倒计时
        CountDown = 20,
        -- 自己各个区域下注数据
        BetValues = {},
        --  各区域总下注数据
        TotalBetValues = {},
        -- 当前桌面已有筹码信息
        CurrentRoomChips = {},
        -- 本局牌数据
        Pokers = {},

        -- 庄家信息
        BankerInfo = { ID = 0, Name = "", Gold = 0, LeftCount = 0, HeadIcon = 0, strLoginIP = "", IsLastForceDownBanker = false, },
        -- 上庄列表信息
        BankerList = {},
        
        -- 赢取的金币 (各个区域赢钱数据)
        WinGold = { },

        -- 玩家自己本局赢钱具体数据
        MasterWinGold = 0,
        MasterCurrentGold = 0,

        -- 当前选择下注的金额
        SelectBetValue = 0,
        -- 投注龙虎下限
        BetLongHuMin = 0,
        -- 投注龙虎上限
        BetLongHuMax = 0,
        -- 投注和下限
        BetHeMin = 0,
        -- 投注和上限
        BetHeMax = 0,

    }
    Extends(tNode, self)
    return tNode
end

function LHDRoom:Init( isInitAll, roomTypeParam)
    if isInitAll == true  then
        self:SetRoomState(LHD_ROOM_STATE.WAIT)
    end
    self.RoomType = roomTypeParam
end

function LHDRoom:SetRoomState(nState, nNextTime)
    local nRoomType = self.RoomType
    local nStateTime = 0
    if nNextTime == nil then
        nStateTime = data.Get_ROOM_STATE_TIME(ROOM_TYPE.LHDRoom, nState)
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
function LHDRoom:PlayerCount()
    return self.RoleCount
end
