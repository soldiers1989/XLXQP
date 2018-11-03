--[[
   文件名称:PDKRoom.lua
   创 建 人: 
   创建时间：2017.12
   功能描述：
]]--

-- 【跑的快组局厅】玩家信息
if PDKPlayer == nil  then
    PDKPlayer = {}
end

function PDKPlayer:New(  )
    local tObj = 
    {
        -- 玩家ID
        ID = 0,
        -- 是否有效 0 (无效,空位无人坐下) 1(有效,有玩家坐下但是这局没有参与游戏) 2(有人坐下这局有参与游戏)
        IsValid = 0,
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

        -- 玩家状态 (0 空位 1 旁观者 2 参与游戏 3参与抢庄 4 不抢庄 5 选择加倍 6 不加倍)
        PlayerState = PlayerStateEnumPDK.NULL,
        -- 玩家可以下注倍率
        nCompensate = 0,
        -- 玩家下注倍率
        nBetCompensate = 0,

        -- 玩家的扑克信息 格式为: [1] = {PokerType = 1, PokerNumber = 13, Visible = false,}
        Pokers = 
        {
            [1] = {PokerType = 1, PokerNumber = 1, Visible = false,},
            [2] = {PokerType = 1, PokerNumber = 2, Visible = false,},
            [3] = {PokerType = 1, PokerNumber = 3, Visible = false,},
            [4] = {PokerType = 1, PokerNumber = 4, Visible = false,},
            [5] = {PokerType = 1, PokerNumber = 5, Visible = false,},
        },
        -- 玩家赢取金币数量
        WinGold = 0,
        -- 是否搓牌 0未搓 1已经搓牌
        IsCuoPai = 0,
        -- 是否需要展示分牌动画
        CanPlaySplitPkoerAnimation = false,
    }
    Extends(tObj, self)
    return tObj
end 


if PDKRoom == nil then
    PDKRoom = {}
end

function PDKRoom:New()
    local  tNode = 
    {
        -- 房间ID
        RoomID = 10,
        -- 房间类型
        RoomType = ROOM_TYPE.PiPeiPDK,

        -- 房主ID
        MasterID = 0,
        -- 房间人数
        RoleCount = 0,
        -- 最大人数
        MaxRoleCount = 3,
        -- 房间当前阶段
        RoomState = ROOM_STATE_PDK.START,
        -- 房间等级
        RoomLevel = 1,
        -- 倒计时
        CountDown = 20,
        -- 庄家ID(0无庄家)
        BankerID = 1,
        -- 玩家自己所在位置
        SelfPosition = 1,
        -- 组局厅玩家列表 [1] = PDKPlayer,[2] = PDKPlayer
        PDKPlayerList = {},
        -- 房间名称
        RoomName = '帝豪俱乐部',
        -- 底注
        MinBet = 10,
        -- 上一出牌玩家位置
        LastPosition = 0,
        -- 出牌数量
        OutCardNumber = 0,
        -- 出牌信息
        OutCardInfo = {},
        -- 牌局次数
        BoardNumber = 0,
    }
    Extends(tNode, self)
    return tNode
end

function PDKRoom:Init( isInitAll, roomTypeParam)
    if isInitAll == true  then
        self.PDKPlayerList = {}
        for i=1,MAX_PDKZUJU_ROOM_PLAYER do
            local tNode = PDKPlayer:New()
            self.PDKPlayerList[i] = tNode
        end
        self:SetRoomState(ROOM_STATE_PDK.START)
    end
    self.RoomType = roomTypeParam
end

function PDKRoom:SetRoomState(nState, nNextTime)
    local nRoomType = self.RoomType
    local nStateTime = 0
    if nNextTime == nil then
        if nRoomType == ROOM_TYPE.PiPeiPDK then
            nStateTime = data.Get_ROOM_STATE_TIME(ROOM_TYPE.PiPeiPDK, nState)
        else
            -- 其他模式
            nStateTime = data.Get_ROOM_STATE_TIME(ROOM_TYPE.PiPeiPDK, nState)
        end
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
function PDKRoom:PlayerCount()
    local tCount = 0
    for i = 1,MAX_PDKZUJU_ROOM_PLAYER, 1 do
        if self.PDKPlayerList[i].PlayerState > PlayerStateEnumPDK.NULL then
            tCount = tCount + 1
        end
    end
    return tCount
end

--==============================--
--desc:获取房间当前准备人数
--time:2018-01-25 02:22:03
--@return 
function PDKRoom:ReadPlayerCount()
    local tCount = 0
    for i = 1,MAX_PDKZUJU_ROOM_PLAYER, 1 do
        if self.PDKPlayerList[i].PlayerState == PlayerStateEnumPDK.Ready then
            tCount = tCount + 1
        end
    end
    return tCount
end

--==============================--
--desc:获取房间玩家位置(通过账号ID)
--time:2018-01-25 02:22:03
--@accountid: 玩家账号ID  
--@return 
--==============================--
function PDKRoom:GetPlayerPosition(accountid)
    local position = 6
    for i = 1,MAX_PDKZUJU_ROOM_PLAYER, 1 do
        if self.PDKPlayerList[i].ID == accountid then
            position = i
            break
        end
    end
    return position
end
