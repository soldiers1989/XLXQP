

local mTime = CS.UnityEngine.Time
-- 玩家UI信息
local PlayerUIInfo =
{
    PlayerRoot,
    Name,
    WinText,
    LoseText,
    HeadIcon,
    HeadBack,
    Sitdown,
    GoldText,
    BankerTips1,
    BankerTips2,
    BankerTips3,
    WinTips1,
    WinTips2,
}

-- 红包飞的位置
local HBFlyPosition={}
-- 飞行红包的父节点
local HBPrintObject = nil
-- 飞行红包模板
local HBTemplate = nil

-- 红包出现位置
local mAppearPosition_X = {[1]=389,[2]=389,[3]=389,[4]=9,[5]=-385,[6]=-385,[7]=-385,[8]=11,};
local mAppearPosition_Y = {[1]=-514,[2]=-110,[3]=265,[4]=533,[5]=269,[6]=-113,[7]=-515,[8]=-788,};
-- 红包终点位置
local mEndPosition_X=-10
local mEndPosition_Y=52

-- 金币终点位置
local mGoldPosition_X = {[1]=382,[2]=382,[3]=382,[4]=0,[5]=-394,[6]=-394,[7]=-394,[8]=0,};
local mGoldPosition_Y = {[1]=-461,[2]=-68,[3]=316,[4]=584,[5]=316,[6]=-67.5,[7]=-468,[8]=-736,};

-- 玩家槽位信息
local mPLAYERS_SLOT = { }
-- 菜单组件
local mReturnCaiDan = nil
-- 游戏规则组件
local mGameRule = nil
local ClosemGameRule=nil

-- 玩家UI元素集合
local mPlayersUIInfo = { }
-- 提示
local TiShi=nil
local TiShiObject=nil

-- 游戏结算组件
local mGameResult = nil
local RoomInfo=nil

-- 庄家标签
local mBankerTips = nil

-- 筹码
--local Chips={}
local ChipsTween={}

-- 游戏模式
local GameType=1

--发红包组件
local FaHongBaoZuJia=
{
    Interface=nil,
    Number=nil,
    Gold=nil,
    CloseButton=nil,
    OKButton=nil,
    FHBButton=nil,
    FHBButtonObject=nil,
}
--抢红包组件
local QiangHongBaoZuJian=
{
    Interface=nil,
    Interface1=nil,
    Button=nil,
    TWEEN_SCALE=nil,
    TWEEN_POSITION=nil,
    HB_SCALE=nil,
    GOLD_IMAGE=nil,
    GOLD_IMAGE_Objice=nil,
    TiShi=nil,
    HBObject={},
}

--结算组件
local JieSuanZuJian=
{
    Interface=nil,
    Clone=nil,
    Name=nil,
    HeadIcon=nil,
    HeadUrl=nil,
    GoldText=nil,
    My=nil,
    JieLong=nil,
    CloseButton=nil,
    MyObject=nil,
    JieLongObject=nil,
    FaHBPlayerName=nil,
    CloseButtonObject=nil,
}

-- 结算玩家信息
local SettlementPlayerInfo =
{
    InfoObject={},
    Icon = {},
    MyObject = {},
    NameText = {},
    GoldValueText = {},
    JLBack = {},
    JLImage = {},
}

--庄家组件
local ZhuangJaiZuJian=
{
    ZJ_Object=nil,
    GoldText=nil,
    NameText=nil,
    HeadIcon=nil,
}

-- 结算信息位置
local SettlementPosition=0

-- 当前房间信息数据
local mRoomData = { }

-- 是否开始倒计时
local IsUpdateTime = false

-- 退出房间按钮
local exitBtn = nil;

-- 初始化玩家信息
function PlayerPositionInfo()
    mRoomData = GameData.RoomInfo.CurrentRoom
    PrintTable(GameData.RoomInfo.CurrentRoom, "GameData.RoomInfo.CurrentRoom");
    for position=1,MAX_HBZUJU_ROOM_PLAYER do
        SetPlayerSitdownState(position)
        SetPlayerBaseInfo(position)
    end
end

-- 初始化玩家信息
function InitPlayerInfoElement()
    local playerRoot = this.transform:Find('Canvas/Players')
    for playerIndex=1,MAX_HBZUJU_ROOM_PLAYER do
        mPLAYERS_SLOT[playerIndex] = lua_NewTable(PlayerUIInfo)
        mPLAYERS_SLOT[playerIndex].playerRoot = playerRoot:Find('Player' .. playerIndex)
        local childRoot = mPLAYERS_SLOT[playerIndex].playerRoot
        mPLAYERS_SLOT[playerIndex].Name = childRoot:Find('Head/Name'):GetComponent('Text')
        mPLAYERS_SLOT[playerIndex].HeadIcon = childRoot:Find('Head/HeadIcon/Icon'):GetComponent('Image')
        mPLAYERS_SLOT[playerIndex].HeadBack = childRoot:Find('Head/HeadIcon')
        mPLAYERS_SLOT[playerIndex].GoldText = childRoot:Find('Head/GoldText'):GetComponent('Text')
        mPLAYERS_SLOT[playerIndex].Sitdown = childRoot:Find('Head/Sitdown').gameObject
        mPLAYERS_SLOT[playerIndex].BankerTips1 = childRoot:Find('Head/BankerTips1')
        mPLAYERS_SLOT[playerIndex].BankerTips2 = childRoot:Find('Head/BankerTips2')
        mPLAYERS_SLOT[playerIndex].BankerTips3 = childRoot:Find('Head/BankerTips3')
        mPLAYERS_SLOT[playerIndex].WinTips1 = childRoot:Find('Head/WinTips1')
        mPLAYERS_SLOT[playerIndex].WinTips2 = childRoot:Find('Head/WinTips2')
        mPLAYERS_SLOT[playerIndex].JLImage = childRoot:Find('Continue').gameObject
    end

    -- 显示状态默认
    for index = 1, MAX_HBZUJU_ROOM_PLAYER, 1 do
        ResetPlayerInfo(mPLAYERS_SLOT[index])
    end
end

-- 重置玩家信息归零
function ResetPlayerInfo(tPlayer)
    
    if nil == tPlayer then
        error('玩家组件为nil')
        return
    end
    tPlayer.Name.text = ""
    --tPlayer.HeadBack.gameObject:SetActive(false)
    tPlayer.playerRoot.gameObject:SetActive(false)
    tPlayer.GoldText.text = ""
    tPlayer.JLImage:SetActive(false)
    tPlayer.Sitdown:SetActive(false)
    tPlayer.BankerTips1.gameObject:SetActive(false)
    tPlayer.BankerTips2.gameObject:SetActive(false)
    tPlayer.BankerTips3.gameObject:SetActive(false)
    tPlayer.WinTips1.gameObject:SetActive(false)
    tPlayer.WinTips2.gameObject:SetActive(false)
end

-- 初始化房间其他信息
function InitGameRoomOtherRelative()
    GameType = GameData.RoomInfo.CurrentRoom.GameMode
    this.transform:Find('Canvas/Buttons').gameObject:SetActive(true)
    mReturnCaiDan = this.transform:Find('Canvas/ReturnCaiDan').gameObject
    mGameRule = this.transform:Find('Canvas/GameRule').gameObject
    mChipRoot = this.transform:Find('Canvas/Result/ChipRoot')
    TiShi=this.transform:Find('Canvas/RoomRule_2/Text'):GetComponent('Text')
    TiShiObject=this.transform:Find('Canvas/RoomRule_2').gameObject
    RoomInfo=this.transform:Find('Canvas/RoomRule'):GetComponent('Text')

    -- 发红包组件
    FaHongBaoZuJia.Interface = this.transform:Find("Canvas/GiveRedEnvelopes"..GameType).gameObject
    FaHongBaoZuJia.Number = this.transform:Find("Canvas/GiveRedEnvelopes"..GameType.."/BackgroundImage/PlayerNum/Number"):GetComponent('Text')
    FaHongBaoZuJia.Gold = this.transform:Find("Canvas/GiveRedEnvelopes"..GameType.."/BackgroundImage/GoldNum/Gold"):GetComponent('Text')
    FaHongBaoZuJia.OKButton= this.transform:Find("Canvas/GiveRedEnvelopes"..GameType.."/BackgroundImage/Button/Button"):GetComponent('Button').onClick:AddListener(BankerRequestFaHongBao)
    FaHongBaoZuJia.Number.text=tostring(data.HongbaoroomConfig[1].BeginPlayer)
    FaHongBaoZuJia.Gold.text=tostring(math.floor(GameConfig.GetFormatColdNumber(GameData.RoomInfo.CurrentRoom.BetMin)))
    FaHongBaoZuJia.FHBButtonObject=this.transform:Find("Canvas/Buttons/FHBButton").gameObject
    FaHongBaoZuJia.FHBButton=this.transform:Find("Canvas/Buttons/FHBButton"):GetComponent("Button")
    FaHongBaoZuJia.FHBButton.onClick:AddListener(function()FHBButtonOnClick(true)end)

    -- 抢红包组件
    QiangHongBaoZuJian.Interface = this.transform:Find("Canvas/RedEnvelopes").gameObject
    QiangHongBaoZuJian.Interface1 = this.transform:Find("Canvas/RedEnvelopes1").gameObject
    --this.transform:Find("Canvas/RedEnvelopes/Image"):GetComponent("Button").onClick:AddListener(PlayerRobHongBao)
    this.transform:Find("Canvas/RedEnvelopes1/Button"):GetComponent("Button").onClick:AddListener(PlayerRobHongBao)
    QiangHongBaoZuJian.TWEEN_SCALE = this.transform:Find("Canvas/RedEnvelopes"):GetComponent("TweenScale")
    QiangHongBaoZuJian.TWEEN_POSITION = this.transform:Find("Canvas/RedEnvelopes"):GetComponent("TweenPosition")
    QiangHongBaoZuJian.HB_SCALE= this.transform:Find("Canvas/RedEnvelopes/Image"):GetComponent("TweenScale")
    QiangHongBaoZuJian.GOLD_IMAGE_Objice=this.transform:Find("Canvas/GoldImage").gameObject
    QiangHongBaoZuJian.TiShi=this.transform:Find("Canvas/RedEnvelopes/TiShi").gameObject
    -- 结算组件
    JieSuanZuJian.Interface=this.transform:Find("Canvas/Settlement").gameObject
    JieSuanZuJian.Clone=this.transform:Find("Canvas/Settlement/Back/GameObject/ChipsItem").gameObject
    JieSuanZuJian.Name=this.transform:Find("Canvas/Settlement/Back/GameObject/ChipsItem/Name"):GetComponent('Text')
    JieSuanZuJian.HeadIcon=this.transform:Find("Canvas/Settlement/Back/GameObject/ChipsItem/HeadPortrait/HeadImage"):GetComponent('Image')
    JieSuanZuJian.Gold=this.transform:Find("Canvas/Settlement/Back/GameObject/ChipsItem/Gold/Text"):GetComponent('Text')
    JieSuanZuJian.MyObject=this.transform:Find("Canvas/Settlement/Back/GameObject/ChipsItem/HeadPortrait/Image").gameObject
    JieSuanZuJian.JieLongObject=this.transform:Find("Canvas/Settlement/Back/GameObject/ChipsItem/ContinueImage").gameObject
    JieSuanZuJian.My=this.transform:Find("Canvas/Settlement/Back/GameObject/ChipsItem/HeadPortrait/Image"):GetComponent('Image')
    JieSuanZuJian.JieLong=this.transform:Find("Canvas/Settlement/Back/GameObject/ChipsItem/ContinueImage"):GetComponent('Image')
    JieSuanZuJian.CloseButtonObject=this.transform:Find("Canvas/Settlement/Mask").gameObject
    JieSuanZuJian.CloseButton=this.transform:Find("Canvas/Settlement/Mask"):GetComponent('Button')
    JieSuanZuJian.CloseButton.onClick:AddListener(CloseHB_SETTLEMENT_Interface)
    JieSuanZuJian.FaHBPlayerName=this.transform:Find("Canvas/Settlement/Back/Name"):GetComponent('Text')
    -- 筹码组件
    --[[for index=1,MAX_HBZUJU_ROOM_PLAYER do
        Chips[index]=this.transform:Find("Canvas/RedEnvelopes/Chips/Chip"..index).gameObject
        ChipsTween[index]=this.transform:Find("Canvas/RedEnvelopes/Chips/Chip"..index):GetComponent("TweenPosition")
    end--]]
    for Index=1,5,1 do
        QiangHongBaoZuJian.HBObject[Index]=QiangHongBaoZuJian.Interface1.transform:Find('Hand1/HB'..Index).gameObject
        SettlementPlayerInfo.InfoObject[Index] = this.transform:Find('Canvas/BackGround/Open/SettlementMask/Back/Player'..Index).gameObject
        SettlementPlayerInfo.MyObject[Index] = SettlementPlayerInfo.InfoObject[Index].transform:Find('My').gameObject
        SettlementPlayerInfo.JLBack[Index] = SettlementPlayerInfo.InfoObject[Index].transform:Find('Image').gameObject
        SettlementPlayerInfo.JLImage[Index] = SettlementPlayerInfo.InfoObject[Index].transform:Find('JL').gameObject
        SettlementPlayerInfo.Icon[Index] = SettlementPlayerInfo.InfoObject[Index].transform:Find('HeadIcon'):GetComponent('Image')
        SettlementPlayerInfo.NameText[Index] = SettlementPlayerInfo.InfoObject[Index].transform:Find('Text'):GetComponent('Text')
        SettlementPlayerInfo.GoldValueText[Index] = SettlementPlayerInfo.InfoObject[Index].transform:Find('Gold/Value'):GetComponent('Text')
    end

    for Index=1,8,1 do
        HBFlyPosition[Index] = this.transform:Find('Canvas/RedEnvelopes1/player'..Index).gameObject
    end
    HBPrintObject = this.transform:Find('Canvas/RedEnvelopes1').gameObject
    HBTemplate = this.transform:Find('Canvas/RedEnvelopes1/HB').gameObject

    local Settlement = this.transform:Find('Canvas/BackGround/Open/SettlementMask/Back').gameObject
    SettlementPosition = Settlement.transform.localPosition.y

    this.transform:Find('Canvas/RoomNumber'):GetComponent('Text').text = "房间号:"..tostring(GameData.RoomInfo.CurrentRoom.RoomID)
    if mRoomData.SubType == 2 then
        this.transform:Find('Canvas/RoomNumber').gameObject:SetActive(false)
    elseif mRoomData.SubType == 1 then
        this.transform:Find('Canvas/PositionBack').gameObject:SetActive(false)
    end

    QiangHongBaoZuJian.GOLD_IMAGE_Objice:SetActive(false)
    --QiangHongBaoZuJian.TiShi:SetActive(false)
    TiShiObject:SetActive(false)
    FaHongBaoZuJia.FHBButtonObject:SetActive(false)
    JieSuanZuJian.CloseButtonObject:SetActive(false)
    JieSuanZuJian.MyObject:SetActive(false)
    JieSuanZuJian.JieLongObject:SetActive(false)
    QiangHongBaoZuJian.Interface1:SetActive(false)
    FaHongBaoZuJia.Interface:SetActive(false)
    mReturnCaiDan:SetActive(false)
    mGameRule:SetActive(false)
    local Gold=lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(GameData.RoomInfo.CurrentRoom.BetMin))
    if GameData.RoomInfo.CurrentRoom.GameMode == 1 then
        RoomInfo.text="底注："..Gold
    end

    if GameConfig.IsSpecial() == true then
        this.transform:Find('Canvas/Buttons/StoreButton').gameObject:SetActive(false)
        this.transform:Find('Canvas/Notice').gameObject:SetActive(false)
        this.transform:Find('Canvas/NotifyButtons').gameObject:SetActive(false)
    end

    exitBtn = this.transform:Find('Canvas/Buttons/ButtonExit'):GetComponent("Button");
end

-- 设置玩家名称 头像 金币
function SetPlayerBaseInfo(positionParam)
    local showObj = mPLAYERS_SLOT[positionParam]
    if mRoomData.HongBaoPlayers[positionParam] == nil then
        return
    end
    local showData = mRoomData.HongBaoPlayers[positionParam]
        
    if showData.Name ~= nil and showData.GoldValue ~= nil and showData.HeadIcon ~=nil then
        showObj.Name.text = showData.strLoginIP
        showObj.GoldText.text = tostring(lua_GetPreciseDecimal(showData.GoldValue,2))
        showObj.HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(showData.HeadIcon))
        
    else
        showObj.Name.text = ""
        showObj.GoldText.text = ""
    end

    

    if mRoomData.FaHBID~=0 then
        if showData.ID==mRoomData.FaHBID then
            this:DelayInvoke(0.1,function()
                JLImageDisplay(positionParam,true)
            end)
            
        else
            JLImageDisplay(positionParam,false)
        end
    end
end

-- 新增一个玩家
function OnNotifyHBRoomAddPlayer(positionParam)
    SetPlayerSitdownState(positionParam)
    SetPlayerBaseInfo(positionParam)
end

-- 删除一个玩家
function OnNotifyHBRoomDeletePlayer(positionParam)
    SetPlayerSitdownState(positionParam)
    SetPlayerBaseInfo(positionParam)
    JLImageDisplay(positionParam,false)
end

-- 设置玩家坐下状态
function SetPlayerSitdownState(positionParam)
    
        if mPLAYERS_SLOT[positionParam] == nil then
            return
        end
        if mRoomData.HongBaoPlayers[positionParam] == nil then
            mPLAYERS_SLOT[positionParam].playerRoot.gameObject:SetActive(false)
        else
            mPLAYERS_SLOT[positionParam].playerRoot.gameObject:SetActive(true)
        end
    
end

-- 刷新游戏房间进入到指定房间状态
function RefreshGameRoomByRoomStateSwitchTo(roomState)
    mRoomData = GameData.RoomInfo.CurrentRoom
    --this.transform:Find('Canvas/Buttons/ButtonExit'):GetComponent("Button").interactable = CheckCanQuitGame
    RefreshGameRoomToEnterGameState(roomState, false)
end

-- 刷新游戏房间到游戏状态
function RefreshGameRoomToEnterGameState(roomState, isInit)
    --选发红包人员状态
    RefreshXuanDoublePartOfGameRoomByState(roomState, isInit)
    --发红包状态
    BankerFaHongBaoInterface(roomState, isInit)
    --抢红包状态
    RobHongBao(roomState, isInit)
    --结算状态
    --HB_SETTLEMENT_Interface(roomState, isInit)
    waitInterface(roomState,isInit)
    UpdateHB_SETTLEMENT_Interface(roomState, isInit)
end

-- 选发红包玩家
function RefreshXuanDoublePartOfGameRoomByState(roomStateParam, initParam)
    CloseHB_SETTLEMENT_Interface()
    if roomStateParam == ROOM_STATE_HB.XUAN_ZHUANG then
        local tBankerJoin = { }
        for position = 1, MAX_HBZUJU_ROOM_PLAYER, 1 do
            if mRoomData.HongBaoPlayers[position] ~=nil then
                table.insert(tBankerJoin, position)
            end
        end

        local bankerCount = #tBankerJoin
        if bankerCount > 1 then

            local tRoundResult = { }
            local circleCount = 3

            if bankerCount > 5 then
                circleCount = 2
            end

            -- 转2,3圈
            for index = 1, circleCount, 1 do
                for k1, v1 in pairs(tBankerJoin) do
                    table.insert(tRoundResult, v1)
                end
            end
            -- TODO 最后添加庄家进来
            local bankerPos = mRoomData.BankerID
            for index = 1, bankerPos, 1 do
                    if mRoomData.HongBaoPlayers[index] ~= nil then
                        if mRoomData.HongBaoPlayers[index].PlayerState ~=nil then
                            if mRoomData.HongBaoPlayers[index].PlayerState == PlayerStateEnumHB.FaHongBaoOK then
                                table.insert(tRoundResult, index)
                            end
                        end
                    end
                --end
            end
            -- 每次停留时间
            local onceTime = 0.2
            for k2, v2 in pairs(tRoundResult) do
                if mRoomData.HongBaoPlayers[v2]~=nil then
                    this:DelayInvoke((k2 - 1) * onceTime,
                    function()
                        mPLAYERS_SLOT[v2].BankerTips1.gameObject:SetActive(true)
                        this:DelayInvoke(onceTime,
                        function()
                            mPLAYERS_SLOT[v2].BankerTips1.gameObject:SetActive(false)
                        end )
                    end )
                end
            end
            -- 最后定庄显示
            if mRoomData.HongBaoPlayers[bankerPos]~=nil then
                this:DelayInvoke(#tRoundResult * onceTime,
                function()
                    -- 定庄特效
                    ShowBankerEffect(bankerPos, true)
                end )
            end
            if mRoomData.HongBaoPlayers[bankerPos]~=nil then
                this:DelayInvoke(#tRoundResult * onceTime + 1,
                function()
                    -- 接龙图片显示
                    JLImageDisplay(bankerPos, true)
                end )
            end

        else
            -- 无庄家
            print('本局无庄家*****')
        end
    end
end

-- 显示定庄特效
function ShowBankerEffect(positionParam, showParam)
    -- 定庄特效
    if mRoomData.HongBaoPlayers[positionParam]~=nil then
        mPLAYERS_SLOT[positionParam].BankerTips3.gameObject:SetActive(showParam)
        if true == showParam then
            local spriteAnimation = mPLAYERS_SLOT[positionParam].BankerTips3:GetComponent('UGUISpriteAnimation')
            if mRoomData.HongBaoPlayers[positionParam]~=nil then
                PlaySoundEffect('11')
                spriteAnimation:RePlay()
                -- 延迟隐藏
                this:DelayInvoke(1.2,
                function()
                    mPLAYERS_SLOT[positionParam].BankerTips3.gameObject:SetActive(false)

                end )
            end
        end
    end
end

-- 接龙图片显示
function JLImageDisplay(positionParam, showParam)
    if true == showParam then
        mPLAYERS_SLOT[positionParam].JLImage.gameObject:SetActive(showParam)
    
    elseif false == showParam then
        mPLAYERS_SLOT[positionParam].JLImage.gameObject:SetActive(showParam)
    end
    if exitBtn == 8 then
        exitBtn.interactable = false;
    end
end

-- 庄家信息
function BankerInfo(positionParam)
    if this.transform:Find('Canvas/Players/Banker/BankerInfo(Clone)')~=nil then
        local destoryCopy=this.transform:Find('Canvas/Players/Banker/BankerInfo(Clone)').gameObject
        GameObjectSetActive(destoryCopy,false)
        CS.UnityEngine.Object.Destroy(destoryCopy)
    end
    --this:DelayInvoke(timer,function()
    local chips=this.transform:Find('Canvas/Players/Banker').gameObject
    local CopyItem=this.transform:Find('Canvas/Players/Player'..positionParam).gameObject
    local Copy=CS.UnityEngine.Object.Instantiate(CopyItem)
    --Copy.transform.parent=chips.transform
    Copy.name="BankerInfo(Clone)"
    --Copy.transform.localScale=CS.UnityEngine.Vector3.one
    CS.Utility.ReSetTransform(Copy.transform,chips.transform)
    Copy.transform:Find('Continue').gameObject:SetActive(true)
    Copy:SetActive(true)
end

-- 庄家显示发红包按钮
function BankerFaHongBaoInterface(roomStateParam, showParam)
    CloseHB_SETTLEMENT_Interface()
    if roomStateParam == ROOM_STATE_HB.FA_HONGBAO then
        GameData.HBJL.JS_isOpen = 1
        local bankerID = GameData.RoomInfo.CurrentRoom.FaHBID
        if bankerID == GameData.RoleInfo.AccountID then
            if FaHongBaoZuJia.Interface.activeSelf == false then
                FaHongBaoZuJia.FHBButtonObject:SetActive(true)
            end
        else
            FaHongBaoZuJia.FHBButtonObject:SetActive(false)
        end
        local tRoomData = GameData.RoomInfo.CurrentRoom
        local nextName=tRoomData.FaHBID
        local flag = true;
        for index=1,MAX_HBZUJU_ROOM_PLAYER do
            if tRoomData.HongBaoPlayers[index]~=nil then
                if nextName == tRoomData.HongBaoPlayers[index].ID then
                    BankerInfo(index)
                    if index == 8 then
                        flag = false;
                    end
                end
            end
        end
        exitBtn.interactable = flag;
    else
        FaHongBaoZuJia.Interface:SetActive(false)
        if this.transform:Find('Canvas/Players/Banker/BankerInfo(Clone)')~=nil then
            local destoryCopy=this.transform:Find('Canvas/Players/Banker/BankerInfo(Clone)').gameObject
            GameObjectSetActive(destoryCopy,false)
            CS.UnityEngine.Object.Destroy(destoryCopy)
        end
    end
end

-- 响应庄家点击发红包按钮
function FHBButtonOnClick(showParam)
    if true==showParam then
        FaHongBaoZuJia.Interface:SetActive(true)
        FaHongBaoZuJia.FHBButtonObject:SetActive(false)
    else
        FaHongBaoZuJia.Interface:SetActive(false)
    end
end

-- 庄家请求发红包
function  BankerRequestFaHongBao()
    PlaySoundEffect('2')
    print("请求发红包")
    NetMsgHandler.Send_CS_HB_Banker_FaHongBao()
    exitBtn.interactable = true;
end

-- 抢红包界面显示
function RobHongBao(roomStateParam, showParam)
    if roomStateParam == ROOM_STATE_HB.QIANG_HONGBAO then
        
        local Print = this.transform:Find('Canvas/Players/Banker').gameObject
        local count=Print.transform.childCount
        for Index = 1 ,count, 1 do
            if this.transform:Find('Canvas/Players/Banker/BankerInfo(Clone)')~=nil then
                local destoryCopy=this.transform:Find('Canvas/Players/Banker/BankerInfo(Clone)').gameObject
                GameObjectSetActive(destoryCopy,false)
                CS.UnityEngine.Object.DestroyImmediate(destoryCopy)
            end
        end
        
        local ButtonOnject = this.transform:Find('Canvas/RedEnvelopes1/Button'):GetComponent('Button')
        if GameData.HBJL.RobRedEnvelopes == 0 then
            ButtonOnject.interactable = true
        end
        IsUpdateTime=true
        local mNameText = QiangHongBaoZuJian.Interface1.transform:Find('Name'):GetComponent('Text')
        mNameText.text="来自"..mRoomData.FaHongBaoPlayerStrLoginIP.."发的红包"
        FHBButtonOnClick(false)
        QiangHongBaoZuJian.Interface1:SetActive(true)
        if mRoomData.SurplusHBNumber == nil then
            mRoomData.SurplusHBNumber = 5
        end
        HBSurplusNumberDisplay()
        if GameData.HBJL.HB_isFly==1 then
            RobHongBaoAnimation()
        end
        this:DelayInvoke(0.1,function()
            TiShi.text=""
            TiShiObject:SetActive(false)
        end)
        --[[for index=1,MAX_HBZUJU_ROOM_PLAYER do
            if mRoomData.HongBaoPlayers[index] ~=nil then
                if mRoomData.FaHBID == mRoomData.HongBaoPlayers[index].ID then
                    mPLAYERS_SLOT[index].GoldText.text = lua_NumberToStyle1String(mRoomData.FHB_GOLD)
                    mRoomData.HongBaoPlayers[index].GoldValue=mRoomData.FHB_GOLD
                end
            end
        end--]]
    else      
        IsUpdateTime = false
    end
end

-- 抢红包界面动画
function RobHongBaoAnimation()
    GameData.HBJL.HB_isFly=2
    --[[local count=0
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local nextName=tRoomData.FaHBID
    for index=1,MAX_HBZUJU_ROOM_PLAYER do
        if tRoomData.HongBaoPlayers[index]~=nil then
            if nextName == tRoomData.HongBaoPlayers[index].ID then
                count=index
            end
        end
    end--]]
    local mNameText = QiangHongBaoZuJian.Interface1.transform:Find('Name'):GetComponent('Text')
    mNameText.text="来自"..mRoomData.FaHongBaoPlayerStrLoginIP.."发的红包"
    local mNumberText = QiangHongBaoZuJian.Interface1.transform:Find('Number'):GetComponent('Text')
    mNumberText.text = ""..mRoomData.SurplusHBNumber
    local mTweenScale = QiangHongBaoZuJian.Interface1.transform:GetComponent('TweenScale')
    mTweenScale:ResetToBeginning()
    mTweenScale:Play(true)
    FaHongBaoZuJia.FHBButtonObject:SetActive(false)

end

-- 玩家请求抢红包
function PlayerRobHongBao()
    print("玩家请求抢红包")
    NetMsgHandler.Send_CS_HB_Player_QiangHongBao()
end

-- 有人抢红包
function FlyChip(position)
    PlaySoundEffect('7')

    HBSurplusNumberDisplay()
    local ButtonOnject = this.transform:Find('Canvas/RedEnvelopes1/Button'):GetComponent('Button')
    local CopyHB =CS.UnityEngine.Object.Instantiate(HBTemplate)
    CopyHB.transform.name = "HBCopy"
    CS.Utility.ReSetTransform(CopyHB.transform, HBPrintObject.transform)
    local tweenPosition = CopyHB.transform:GetComponent('TweenPosition')
    local tweenColor = CopyHB.transform:GetComponent('TweenColor')
    local tweenScale = CopyHB.transform:GetComponent('TweenScale')
    GameObjectSetActive(CopyHB,true)
    tweenPosition.to = CS.UnityEngine.Vector3(HBFlyPosition[position].transform.localPosition.x,HBFlyPosition[position].transform.localPosition.y,0)
    tweenPosition:ResetToBeginning()
    tweenPosition:Play(true)
    tweenPosition.duration = 0.5
    tweenScale:ResetToBeginning()
    tweenScale:Play(true)
    tweenScale.duration = 0.5
    this:DelayInvoke(0.25,function ()
        tweenColor:ResetToBeginning()
        tweenColor:Play(true)
        tweenColor.duration = 0.5
    end)
    
    this:DelayInvoke(0.6,function ()
        CS.UnityEngine.Object.Destroy(CopyHB)
    end)
    if position == 8 then
        ButtonOnject.interactable = false
        exitBtn.interactable = false;
    end
end

-- 红包个数显示
function HBSurplusNumberDisplay()
    if mRoomData.SurplusHBNumber == 5 then
        for Index=1,5,1 do
            GameObjectSetActive(QiangHongBaoZuJian.HBObject[Index],true)
        end
    elseif mRoomData.SurplusHBNumber == 4 then
        for Index=1,5,1 do
            GameObjectSetActive(QiangHongBaoZuJian.HBObject[Index],true)
        end
        GameObjectSetActive(QiangHongBaoZuJian.HBObject[3],false)
    elseif mRoomData.SurplusHBNumber == 3 then
        for Index=1,5,1 do
            GameObjectSetActive(QiangHongBaoZuJian.HBObject[Index],true)
        end
        GameObjectSetActive(QiangHongBaoZuJian.HBObject[1],false)
        GameObjectSetActive(QiangHongBaoZuJian.HBObject[2],false)
    elseif mRoomData.SurplusHBNumber == 2 then
        for Index=1,5,1 do
            GameObjectSetActive(QiangHongBaoZuJian.HBObject[Index],true)
        end
        for Index=1,3,1 do
            GameObjectSetActive(QiangHongBaoZuJian.HBObject[Index],false)
        end
    elseif mRoomData.SurplusHBNumber == 1 then
        for Index=1,5,1 do
            GameObjectSetActive(QiangHongBaoZuJian.HBObject[Index],false)
        end
        GameObjectSetActive(QiangHongBaoZuJian.HBObject[3],true)
    elseif mRoomData.SurplusHBNumber == 0 then
        for Index=1,5,1 do
            GameObjectSetActive(QiangHongBaoZuJian.HBObject[Index],false)
        end
    end
end

-- 结算动画显示
function SettlementSprinkledCoins()
    local SprinkledCoinsInterface = this.transform:Find('Canvas/BackGround').gameObject
    local CloseInterface = SprinkledCoinsInterface.transform:Find('Close').gameObject
    local OpenInterface = SprinkledCoinsInterface.transform:Find('Open').gameObject
    local CloseTween = SprinkledCoinsInterface.transform:Find('Close'):GetComponent('TweenPosition')
    local SettlementMask = OpenInterface.transform:Find('SettlementMask').gameObject
    local SettlementTweenPosition = SettlementMask.transform:Find('Back'):GetComponent('TweenPosition')
    local SettlementObject = SettlementMask.transform:Find('Back').gameObject
    local NameObject = OpenInterface.transform:Find('Image/Text').gameObject
    
    local LiziObject = this.transform:Find('Canvas/BackGround/Canvas/jingbipengse/01').gameObject
    local LiZi = this.transform:Find('Canvas/BackGround/Canvas/jingbipengse/01'):GetComponent('ParticleSystem')
    local TopHB = SprinkledCoinsInterface.transform:Find('Image').gameObject
    local NameText = TopHB.transform:Find('Text'):GetComponent('Text')
    local TopHBtween = SprinkledCoinsInterface.transform:Find('Image'):GetComponent('TweenPosition')
    NameText.text = "<color=#09FF00FF>"..mRoomData.FaHongBaoPlayerStrLoginIP.."</color>发的红包"
    TopHBtween.enabled =false
    GameObjectSetActive(LiziObject,false)
    SettlementObject.transform.localPosition = CS.UnityEngine.Vector3(SettlementObject.transform.localPosition.x,SettlementPosition,SettlementObject.transform.localPosition.z)
    GameObjectSetActive(SettlementObject,false)
    GameObjectSetActive(NameObject,false)
    for Index=1,5,1 do
        GameObjectSetActive(SettlementPlayerInfo.InfoObject[Index],false)
    end
    GameObjectSetActive(SprinkledCoinsInterface,true)
    GameObjectSetActive(TopHB,true)
    GameObjectSetActive(CloseInterface,true)
    GameObjectSetActive(OpenInterface,false)
    CloseTween.from = CS.UnityEngine.Vector3(-10,CloseInterface.transform.localPosition.y,0)
    CloseTween.to = CS.UnityEngine.Vector3(10,CloseInterface.transform.localPosition.y,0)
    CloseTween:ResetToBeginning()
    CloseTween:Play(true)
    TopHBtween.enabled = true
    TopHBtween.from = CS.UnityEngine.Vector3(-10,TopHB.transform.localPosition.y,0)
    TopHBtween.to = CS.UnityEngine.Vector3(10,TopHB.transform.localPosition.y,0)
    TopHBtween:ResetToBeginning()
    TopHBtween:Play(true)
    this:DelayInvoke(0.5,function ()
        TopHBtween.enabled = false
        GameObjectSetActive(CloseInterface,false)
        TopHB.transform.localPosition = CS.UnityEngine.Vector3(OpenInterface.transform.localPosition.x,TopHB.transform.localPosition.y,0)
        GameObjectSetActive(OpenInterface,true)
        GameObjectSetActive(LiziObject,true)
        LiZi:Play(true)
    end)
    local mTimeCount=0.5
    PlaySoundEffect('HB_Gold')
    --for Index=1,17,1 do
        this:DelayInvoke(mTimeCount,function ()
            PlaySoundEffect('HB_Gold')
        end)
        --mTimeCount=mTimeCount+0.05
    --end
    this:DelayInvoke(2,function ()
        EnterMusic()
        GameObjectSetActive(NameObject,true)
        GameObjectSetActive(LiziObject,false)
        for index=1,mRoomData.QHB_Count do
            GameObjectSetActive(SettlementPlayerInfo.InfoObject[index],true)
            local mName = mRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeStrLoginIP
            local mHeadIcon = mRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeHeadIcon
            local HeadUrl = mRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeHeadUrl
            local GoldValue = mRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeGold
            local playerID = mRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeplayerID
            if playerID == GameData.RoleInfo.AccountID then
                GameObjectSetActive(SettlementPlayerInfo.MyObject[index],true)
            else
                GameObjectSetActive(SettlementPlayerInfo.MyObject[index],false)
            end
            if playerID == GameData.RoomInfo.CurrentRoom.FaHBID then
                GameObjectSetActive(SettlementPlayerInfo.JLBack[index],true)
                GameObjectSetActive(SettlementPlayerInfo.JLImage[index],true)
            else
                GameObjectSetActive(SettlementPlayerInfo.JLBack[index],false)
                GameObjectSetActive(SettlementPlayerInfo.JLImage[index],false)
            end
            SettlementPlayerInfo.NameText[index].text=""..mName
            SettlementPlayerInfo.GoldValueText[index].text=tostring(lua_GetPreciseDecimal(GoldValue,2))
            SettlementPlayerInfo.Icon[index]:ResetSpriteByName(GameData.GetRoleIconSpriteName(mHeadIcon))
        end
        for count=1,MAX_HBZUJU_ROOM_PLAYER do
            if mRoomData.HongBaoPlayers[count]~=nil then
                if playerID == mRoomData.HongBaoPlayers[count].ID then
                    mPLAYERS_SLOT[count].GoldText.text = tostring(lua_GetPreciseDecimal(mRoomData.HongBaoPlayers[count].GoldValue,2))
                end
            end
        end
        GameObjectSetActive(SettlementMask,true)
        GameObjectSetActive(SettlementObject,true)
        SettlementTweenPosition.from = CS.UnityEngine.Vector3(SettlementObject.transform.localPosition.x,SettlementPosition,SettlementObject.transform.localPosition.z)
        SettlementTweenPosition.to = CS.UnityEngine.Vector3(SettlementObject.transform.localPosition.x,SettlementPosition-700,SettlementObject.transform.localPosition.z)
        SettlementTweenPosition:ResetToBeginning()
        SettlementTweenPosition:Play(true)
    end)
end

-- 结算界面显示
--[[function SettlementInterfaceDisplay(showParam)
    QiangHongBaoZuJian.Interface1:SetActive(false)
    if showParam == true then
        for index=1,8 do
            if this.transform:Find('Canvas/Settlement/Back/GameObject/Player/Player'..index..'/ChipsItem(Clone)')~=nil then
                local destoryCopy=this.transform:Find('Canvas/Settlement/Back/GameObject/Player/Player'..index..'/ChipsItem(Clone)').gameObject
                CS.UnityEngine.Object.Destroy(destoryCopy)
            end
        end
        GameData.HBJL.JS_isOpen = 2
        JieSuanZuJian.Interface:SetActive(true)
        JieSuanZuJian.CloseButtonObject:SetActive(false)
        local tRoomData = GameData.RoomInfo.CurrentRoom
        JieSuanZuJian.FaHBPlayerName.text=tRoomData.FaHongBaoPlayerStrLoginIP.."发的红包"
        for index=1,tRoomData.QHB_Count do
            local mName = tRoomData.GrabRedEnvelopeInfo[index].strLoginIP
            local mHeadIcon = tRoomData.GrabRedEnvelopeInfo[index].HeadIcon
            local HeadUrl = tRoomData.GrabRedEnvelopeInfo[index].HeadUrl
            --print("名字%s，Icon%s，Url%s"..Name,HeadIcon,HeadUrl)
            if mName == GameData.RoleInfo.AccountName then
                JieSuanZuJian.MyObject:SetActive(true)
            else
                JieSuanZuJian.MyObject:SetActive(false)
            end
            JieSuanZuJian.JieLongObject:SetActive(false)
            JieSuanZuJian.Name.text=tostring(mName)
            JieSuanZuJian.Gold.text="未知"
            local chips = this.transform:Find('Canvas/Settlement/Back/GameObject/Player/Player'..index).gameObject
            local Copy=CS.UnityEngine.Object.Instantiate(JieSuanZuJian.Clone)
            CS.Utility.ReSetTransform(Copy.transform, chips.transform)            
            --Copy.transform.parent=chips.transform
            --Copy.transform.localPosition=CS.UnityEngine.Vector3.zero
            --Copy.transform.localScale=CS.UnityEngine.Vector3.one
            Copy:SetActive(true)

            local HeadIconImage = Copy.transform:Find('HeadPortrait/HeadImage'):GetComponent('Image')
            HeadIconImage:ResetSpriteByName(GameData.GetRoleIconSpriteName(mHeadIcon))
        end
    else
        JieSuanZuJian.Interface:SetActive(false)
        local tRoomData = GameData.RoomInfo.CurrentRoom
        for index=1,8 do
            if this.transform:Find('Canvas/Settlement/Back/GameObject/Player/Player'..index..'/ChipsItem(Clone)')~=nil then
                local destoryCopy=this.transform:Find('Canvas/Settlement/Back/GameObject/Player/Player'..index..'/ChipsItem(Clone)').gameObject
                GameObjectSetActive(destoryCopy,false)
                CS.UnityEngine.Object.Destroy(destoryCopy)
            end
        end
    end

end--]]

-- 切换到结算状态
function UpdateHB_SETTLEMENT_Interface(roomStateParam, showParam)
    if roomStateParam == ROOM_STATE_HB.SETTLEMENT then
        if mRoomData.CountDown > data.PublicConfig.HB_TIME[4]-1 then
            for Index=1,MAX_HBZUJU_ROOM_PLAYER,1 do
                JLImageDisplay(Index,false)
            end
            this:DelayInvoke(0.5,function ()
                GameData.HBJL.JS_isOpen = 1
                GameData.HBJL.HB_isFly=1
                QiangHongBaoZuJian.Interface1:SetActive(false)
                SettlementSprinkledCoins()
            end)
            this:DelayInvoke(3,function()
                for Index = 1, MAX_HBZUJU_ROOM_PLAYER, 1 do
                    SetPlayerBaseInfo(Index)
                end
            end)
        end
    else
    end
end

-- 关闭结算界面
function CloseHB_SETTLEMENT_Interface()
    local SprinkledCoinsInterface = this.transform:Find('Canvas/BackGround').gameObject
    GameObjectSetActive(SprinkledCoinsInterface,false)
    --JieSuanZuJian.Interface:SetActive(false)
end

--等待状态
function waitInterface(roomStateParam, showParam)
    if roomStateParam == ROOM_STATE_HB.WAIT then
        GameData.HBJL.HB_isFly=1
        GameData.HBJL.JS_isOpen = 1
        TiShiObject:SetActive(true)
        TiShi.text=string.format(data.GetString("HB_State_1"))
    elseif roomStateParam == ROOM_STATE_HB.FA_HONGBAO then
        GameData.HBJL.HB_isFly=1
        local count=ID_Banker_Position()
        if count ~= 0 then
            if mRoomData.HongBaoPlayers[count].ID == GameData.RoleInfo.AccountID then
                TiShi.text=string.format(data.GetString("HB_State_3"))
            else
                local name=mRoomData.HongBaoPlayers[count].strLoginIP
                TiShi.text=string.format(data.GetString("HB_State_2"),name)
            end
            TiShiObject:SetActive(true)
        else
            TiShi.text=string.format(data.GetString("HB_State_4"))
            TiShiObject:SetActive(true)
        end
    else
        TiShiObject:SetActive(false)
    end
end

-- 添加UI按钮事件响应
function AddButtonHandlers()
    
    this.transform:Find('Canvas/Buttons/ButtonCaiDan1'):GetComponent("Button").onClick:AddListener(ButtonCaiDan_OnClick)
    this.transform:Find('Canvas/Buttons/ButtonCaiDan2'):GetComponent("Button").onClick:AddListener(ButtonCaiDan_OnClick)
    this.transform:Find('Canvas/ReturnCaiDan/ImageMask'):GetComponent("Button").onClick:AddListener(ButtonCaiDan_OnClick)
    this.transform:Find('Canvas/Buttons/ButtonExit'):GetComponent("Button").onClick:AddListener(ButtonExit_OnClick)
    this.transform:Find('Canvas/ReturnCaiDan/ButtonGameRule'):GetComponent("Button").onClick:AddListener(ButtonGameRuleOnClick)
    this.transform:Find('Canvas/GameRule/CloseBtn'):GetComponent("Button").onClick:AddListener(ButtonGameRuleOnClickClose)
    this.transform:Find('Canvas/Buttons/StoreButton'):GetComponent("Button").onClick:AddListener(StoreButtonOnClick)
    this.transform:Find('Canvas/ReturnCaiDan/RankButton'):GetComponent("Button").onClick:AddListener(RankButtonOnClick)
end

-- 菜单组件隐藏
function OnCaidanHideClick()
    -- body
    SetCaidanShow(false)
end

-- 菜单组件显示设置
function SetCaidanShow(showParam)
    -- body
    if mReturnCaiDan.activeSelf == showParam then
        return
    end
    mReturnCaiDan:SetActive(showParam)
end

    -------------------------------退出菜单模块------------------------
-- 菜单选择按钮call
function ButtonCaiDan_OnClick()
    
    if mReturnCaiDan.activeSelf then
        ReturnCaiDanShow(false)
        this.transform:Find('Canvas/Buttons/ButtonCaiDan1').gameObject:SetActive(true)
        this.transform:Find('Canvas/Buttons/ButtonCaiDan2').gameObject:SetActive(false)
    else
        ReturnCaiDanShow(true)
        this.transform:Find('Canvas/Buttons/ButtonCaiDan1').gameObject:SetActive(false)
        this.transform:Find('Canvas/Buttons/ButtonCaiDan2').gameObject:SetActive(true)
        --this.transform:Find('Canvas/Buttons/ButtonCaiDan'):GetComponent("Button").interactable = true;
    end
end

-- 推出房间按钮call
function ButtonExit_OnClick()
    --this.transform:Find('Canvas/ReturnCaiDan/ButtonExit'):GetComponent("Button").interactable = CheckCanQuitGame()
    local tQuit = true
    if tQuit == true  then
        NetMsgHandler.Send_CS_HB_Leave_Room(GameData.RoomInfo.CurrentRoom.RoomID)
    end
    ReturnCaiDanShow(false)
end

-- 菜单栏显示接口
function ReturnCaiDanShow(isShow)
    if isShow then
        if GameData.HBJL.RobRedEnvelopes == 1 then
             this.transform:Find('Canvas/Buttons/ButtonExit'):GetComponent('Button').interactable = false
        else
            if GameData.RoomInfo.CurrentRoom.RoomState == ROOM_STATE_HB.FA_HONGBAO and GameData.RoomInfo.CurrentRoom.FaHBID == GameData.RoleInfo.AccountID then
                this.transform:Find('Canvas/Buttons/ButtonExit'):GetComponent('Button').interactable = false
            else
                this.transform:Find('Canvas/Buttons/ButtonExit'):GetComponent('Button').interactable = true
            end
             
        end 
    end
    mReturnCaiDan:SetActive(isShow)
end

-- 邀请按钮call
function ButtonInvite_OnClick()
    print("邀请按钮call")
    local tRoomID = mRoomData.RoomID
    local tRoomType =ROOM_TYPE.HongBao
    local tBet = GameConfig.GetFormatColdNumber(mRoomData.BetMin)
    local tEnterLimit = GameConfig.GetFormatColdNumber(mRoomData.BetMin) * 10
    local tBet = lua_NumberToStyle1String(tBet)
    local tEnterLimit = lua_NumberToStyle1String(tEnterLimit)
    GameData.OpenIniteUI(tRoomID, tRoomType, tBet, tEnterLimit)
end

-- 响应规则按钮
function ButtonGameRuleOnClick ()
    mGameRule:SetActive(true)
    ButtonCaiDan_OnClick()
end
--关闭规则面板
function ButtonGameRuleOnClickClose()
    mGameRule:SetActive(false)
end

-- 商城按钮
function StoreButtonOnClick()
    GameConfig.OpenStoreUI()
end

-- 结算音效
function EnterMusic()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local nextName=tRoomData.FaHBID
    for index=1,MAX_HBZUJU_ROOM_PLAYER do
        if tRoomData.GrabRedEnvelopeInfo[index]~=nil then
            if tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeplayerID == GameData.RoleInfo.AccountID then
                if tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeplayerID == nextName then
                    PlaySoundEffect('NN_lost')
                else
                    PlaySoundEffect('NN_win')
                end
            end
        end
    end
end

-- 音效
function PlaySoundEffect(musicid)
    MusicMgr:PlaySoundEffect(musicid)
end

-- 根据ID查找发红包玩家位置
function ID_Banker_Position()
    local position=0
    local id = mRoomData.FaHBID
    for index=1,MAX_HBZUJU_ROOM_PLAYER do
        if mRoomData.HongBaoPlayers[index]~=nil then
            if mRoomData.HongBaoPlayers[index].ID == id then
                position=index
            end
        end
    end
    return position
end

-- 更新房间总信息
function DisplayRoomInfo()
    PlayerPositionInfo()
    if GameData.RoomInfo.CurrentRoom.RoomState ~= ROOM_STATE_HB.FA_HONGBAO then
        if this.transform:Find('Canvas/Players/Banker/BankerInfo(Clone)')~=nil then
            local destoryCopy=this.transform:Find('Canvas/Players/Banker/BankerInfo(Clone)').gameObject
            GameObjectSetActive(destoryCopy,false)
            CS.UnityEngine.Object.DestroyImmediate(destoryCopy)
        end
    end
    RefreshGameRoomByRoomStateSwitchTo(mRoomData.RoomState)
    HBSurplusNumberDisplay()
end

-- 是否读取本地排行榜信息
function JudgmentTimeInterval(windowData)
    if GameData.RankInfo.HbRankTime == 0 then
        return true
    end
    local time1 = os.time()
    if time1 - GameData.RankInfo.HbRankTime >= 60 then
        return true
    end
    return false
end

-- 响应排行榜按钮点击事件
function RankButtonOnClick()
    local initParam = CS.WindowNodeInitParam("UIRoomRank")
    initParam.WindowData = GAME_RANK_TYPE.HB_MONEY
    CS.WindowManager.Instance:OpenWindow(initParam)
    if JudgmentTimeInterval(GAME_RANK_TYPE.HB_MONEY) == true then
        NetMsgHandler.SendRequestRanks(GAME_RANK_TYPE.HB_MONEY)
    end
    ButtonCaiDan_OnClick()
end

function Awake()
    CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
    mRoomData = GameData.RoomInfo.CurrentRoom
    InitGameRoomOtherRelative()
    InitPlayerInfoElement()
    AddButtonHandlers()
    OnCaidanHideClick()
    PlayerPositionInfo()
    if GameData.RoomInfo.CurrentRoom.RoomState ~= ROOM_STATE_HB.FA_HONGBAO then
        if this.transform:Find('Canvas/Players/Banker/BankerInfo(Clone)')~=nil then
            local destoryCopy=this.transform:Find('Canvas/Players/Banker/BankerInfo(Clone)').gameObject
            GameObjectSetActive(destoryCopy,false)
            CS.UnityEngine.Object.DestroyImmediate(destoryCopy)
        end
    end
    RefreshGameRoomByRoomStateSwitchTo(mRoomData.RoomState)
    HBSurplusNumberDisplay()
    --BankerInfo()
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    CS.MatchLoadingUI.Hide()
end

-- Unity MonoBehavior Update 时调用此方法
function Update()
    if IsUpdateTime then
        mRoomData.CountDown = mRoomData.CountDown - mTime.deltaTime
        local mNumberText = QiangHongBaoZuJian.Interface1.transform:Find('Number'):GetComponent('Text')
        local secoud = math.ceil(mRoomData.CountDown)
        if secoud <= 0 then
            secoud = 0
            IsUpdateTime = false
        end
        mNumberText.text = ""..secoud
    end
end

function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyEnterGameEvent, DisplayRoomInfo)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHBRoomAddPlayer, OnNotifyHBRoomAddPlayer)--新增一个玩家
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHBRoomDeleteplayerPlayer, OnNotifyHBRoomDeletePlayer)--删除一个玩家
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateRoomState, RefreshGameRoomByRoomStateSwitchTo)--更新游戏房间状态
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateSettlementInterfaceDisplay, FlyChip)--更新结算界面显示
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdatePlayerPosition, DisplayRoomInfo)-- 初始化房间玩家位置
    MusicMgr:PlayBackMusic("BG_HBJL")
end

function WindowClosed()
    GameData.HBJL.JS_isOpen = 1
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyEnterGameEvent, DisplayRoomInfo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHBRoomAddPlayer, OnNotifyHBRoomAddPlayer)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHBRoomDeleteplayerPlayer, OnNotifyHBRoomDeletePlayer)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateRoomState, RefreshGameRoomByRoomStateSwitchTo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateSettlementInterfaceDisplay, FlyChip)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdatePlayerPosition, DisplayRoomInfo)
end

function OnDestroy()
    lua_Call_GC()
end
