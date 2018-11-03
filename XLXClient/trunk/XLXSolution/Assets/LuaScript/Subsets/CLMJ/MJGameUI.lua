
MJGameUI={}
local mTime = CS.UnityEngine.Time
local Screen = CS.UnityEngine.Screen
-- 当前房间信息数据
local mRoomData = { }
-- 主角数据
local mMasterData = {}
-- UI组件根节点
local mMyTransform = nil

-- 玩家本身拥有麻将
local mMyHaveMahjong = {}

-- 下叫指示
local mXiaJiaoZhiShi={}

local mReturnGameObject = nil                   -- 返回菜单组件
local mSettlementGameObject = nil                -- 游戏结算界面
local mRecordInterGameObject = nil              -- 对局流水界面组件
local mRoomPlayGameObject = nil                 -- 房间玩法组件
local mGameWaterObject = nil                    -- 本局房间流水
local mRoomWaterObject = nil                    -- 房间流水
local mGameRankObject = nil                     -- 房间排行
local mGamePlayButton1 = nil                    -- 房间玩法按钮1
local mGamePlayButton2 = nil                    -- 房间玩法按钮2
local mGameWaterButton1 = nil                   -- 房间总流水按钮1
local mGameWaterButton2 = nil                   -- 房间总流水按钮2
local mGameRankButton1 = nil                    -- 房间排行按钮1
local mGameRankButton2 = nil                    -- 房间排行按钮2
local mTingPaiInterface = nil                   -- 听牌界面组件
local mTingButtonObject = nil                   -- 听牌按钮
local mGangPaiInterface = nil                   -- 杠牌选择界面
local mZBButtonGameObject = nil                 -- 准备按钮组件
local mWaitTips2GameObject = nil                -- 等待下一局开始Tips
local mWaitTips3GameObject = nil                -- 结束等待Tips
local mRoomNumberGameObject = nil               -- 房间密码组件
local mRoomNumberText = nil                     -- 房间密码Text
local mGameNumberGameObject = nil               -- 房间局数组件
local mGameNumberText = nil                     -- 房间局数Text
local mMahJongGangObject = nil                  -- 麻将剩余数量组件
local mMahJongText = nil                        -- 麻将剩余数量Text
local mCountDownGameObject = nil                -- CD组件
local mCountDownText = nil                      -- CD组件Text
local mExitButtonScript = nil                   -- 退出房间按钮组件Script
local mBankerTipsGameObject = nil               -- 庄家图标
local mPengPaiGameObject = nil                  -- 碰牌按钮
local mGangPaiGameObject = nil                  -- 杠牌按钮
local mHupaiGameObject = nil                    -- 胡牌按钮
local mGuoGameObject = nil                      -- 过按钮
local mResultGameObject = nil                   -- 结算组件
local mChipItems = {}                           -- 筹码Items
local mZhiZhenGameObject = nil                  -- 指针组件
local mPromptGameObject1 = nil                  -- 提示组件1
local mPromptGameObject2 = nil                  -- 提示组件2
local mPromptGameObject3 = nil                  -- 提示组件3
local mCountDownLight={}                        -- 倒计时光圈
local mCardMaskGameObject = nil                 -- 空白地方
local mErrorHintsGameObject = nil               -- 错误提示
local mHuPaiGameObject = nil
local mPlayerUINodes = {}
local playerIcon={}

local playerOutCardaNum={[1]=0,[2]=0,[3]=0,[4]=0}

local playerBanker1=1  local playerBanker2=1  local playerBanker3=1  local playerBanker4=1

-- 听牌
local TingPaiCard={}

-- 手上可杠牌
local GangGroud = {}


-- 玩家UI节点
local PlayerUINode = 
{
    RootGameObject = nil,
    HeadRoot = nil,
    HeadIcon = nil,
    NameText = nil,
    GoldText = nil,
    ZBImage = nil,
    Fail = nil,
    Points = { },
    WinText = nil,                              -- 赢钱Text
    LoseText = nil,                             -- 输钱Text
}

local mMasterPosition = MAX_MJZUJU_ROOM_PLAYER

-- 点击听牌按钮听牌显示界面位置大小
local TingPosition={}
local TingInterface_Position_X1 = {[1]=630,[2]=524,[3]=416,[4]=309,[5]=205,[6]=417,[7]=309,[8]=309,[9]=200}
local TingInterface_Position_Y1 = {[1]=-210,[2]=-210,[3]=-210,[4]=-210,[5]=-210,[6]=-130,[7]=-130,[8]=-130,[9]=-130}
local TingInterface_Scale_X1 = {[1]=377,[2]=588,[3]=805,[4]=1020,[5]=1228,[6]=803,[7]=1024,[8]=1024,[9]=1235}
local TingInterface_Scale_Y1 = {[1]=260,[2]=260,[3]=260,[4]=260,[5]=260,[6]=406,[7]=406,[8]=406,[9]=406}

local pengganghuCardNumber={[1]=0,[2]=0,[3]=0,[4]=0}
local player4CardPosition={}
local IsLiuJu = false

-- 玩家碰杠胡列表
local MJPLAYERPGLIST=
{
    [1]={},
    [2]={},
    [3]={},
    [4]={}
}

local tHuType = {
    PINGHU = 1,         -- 平胡
    PENGPENGHU = 2,     -- 碰碰胡(对对胡)
    QINGYISE = 3,       -- 清一色
    ANQIDUI = 4,        -- 暗七对
    JINGOUDIAO = 5,     -- 金钩钓
    QINGPENG = 6,       -- 清一色碰碰胡
    LONGQIDUI = 7,      -- 龙七对
    QINGANQIDUI = 8,    -- 清暗七对
    QINGJINGOUDIAO = 9, -- 清金钩钓
    TIANHU = 10,        -- 天胡
    DIHU = 11,          -- 地胡
    QINGLONGQIDUI = 12, -- 清龙七对
    SHIBALUOHAN = 13,   -- 十八罗汉
    QINGSHIBA = 14,     -- 清十八罗汉
}

local tHuRate = {0, 1, 2, 2, 2, 3, 3, 4, 4, 5, 5, 4, 5, 5}
local tHuBeiShu = {1, 2, 4, 4, 4, 8, 8, 16, 16, 32, 32, 16, 32, 32}

local DownTime=0
local CountDowenMusic = true



function InitUIElement()
    mReturnGameObject = mMyTransform:Find('Canvas/ReturnButton/ReturnButton1').gameObject
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/MaskButton').gameObject:SetActive(true)
    mZBButtonGameObject = mMyTransform:Find('Canvas/MasterInfo/ZBButton').gameObject


    mRoomNumberGameObject = mMyTransform:Find('Canvas/RoomNumber').gameObject
    mRoomNumberText = mMyTransform:Find('Canvas/RoomNumber/Text'):GetComponent("Text")
    mGameNumberGameObject = mMyTransform:Find('Canvas/GameNumber').gameObject
    mGameNumberText = mMyTransform:Find('Canvas/GameNumber/Text'):GetComponent("Text")
    mMahJongGangObject = mMyTransform:Find('Canvas/MahJongNumber').gameObject
    mMahJongText = mMyTransform:Find('Canvas/MahJongNumber/Text'):GetComponent("Text")
    mCountDownGameObject = mMyTransform:Find('Canvas/CountDown').gameObject
    mCountDownText = mMyTransform:Find('Canvas/CountDown/ValueText'):GetComponent("Text")
    mResultGameObject = mMyTransform:Find('Canvas/Result').gameObject
    mExitButtonScript = mMyTransform:Find('Canvas/ReturnButton'):GetComponent('Button')

    mGameWaterObject=mMyTransform:Find('Canvas/GameWater').gameObject
    mRecordInterGameObject = mMyTransform:Find('Canvas/TurnoverInterface').gameObject
    mRoomPlayGameObject = mMyTransform:Find('Canvas/TurnoverInterface/GamePlay').gameObject
    mRoomWaterObject=mMyTransform:Find('Canvas/TurnoverInterface/GameWater').gameObject
    mGameRankObject=mMyTransform:Find('Canvas/TurnoverInterface/MatchRank').gameObject
    mGamePlayButton1=mMyTransform:Find('Canvas/TurnoverInterface/Back/Title/RoomPlay1').gameObject
    mGamePlayButton2=mMyTransform:Find('Canvas/TurnoverInterface/Back/Title/RoomPlay2').gameObject
    mGameWaterButton1=mMyTransform:Find('Canvas/TurnoverInterface/Back/Title/GameChess1').gameObject
    mGameWaterButton2=mMyTransform:Find('Canvas/TurnoverInterface/Back/Title/GameChess2').gameObject
    mGameRankButton1=mMyTransform:Find('Canvas/TurnoverInterface/Back/Title/GamgRank1').gameObject
    mGameRankButton2=mMyTransform:Find('Canvas/TurnoverInterface/Back/Title/GamgRank2').gameObject


    mPengPaiGameObject=mMyTransform:Find('Canvas/Buttons/PGHGButton/Viewport/Content/Peng').gameObject
    mGangPaiGameObject=mMyTransform:Find('Canvas/Buttons/PGHGButton/Viewport/Content/Gang').gameObject
    mHuPaiGameObject=mMyTransform:Find('Canvas/Buttons/PGHGButton/Viewport/Content/Hu').gameObject
    mGuoGameObject=mMyTransform:Find('Canvas/Buttons/PGHGButton/Viewport/Content/Guo').gameObject

    mSettlementGameObject = mMyTransform:Find('Canvas/SettlementInterface').gameObject

    mZhiZhenGameObject= mMyTransform:Find('Canvas/PlayerCardPosition/ZhiZhen').gameObject

    mTingPaiInterface = mMyTransform:Find('Canvas/TingPaiInterface').gameObject
    mTingButtonObject = mMyTransform:Find('Canvas/Buttons/TingButton').gameObject

    mPromptGameObject1=mMyTransform:Find("Canvas/Prompt1").gameObject
    mPromptGameObject2=mMyTransform:Find("Canvas/Prompt2").gameObject
    mPromptGameObject3=mMyTransform:Find("Canvas/Prompt3").gameObject

    mCardMaskGameObject = mMyTransform:Find("Canvas/Card/Mask").gameObject

    mErrorHintsGameObject = mMyTransform:Find("Canvas/TiShi").gameObject

    mGangPaiInterface = mMyTransform:Find("Canvas/GangPaiChoice").gameObject

    for position = 1, MAX_MJZUJU_ROOM_PLAYER, 1 do
        local childItem = mMyTransform:Find('Canvas/Players/Player'..position)
        mPlayerUINodes[position] = clone(PlayerUINode)
        mPlayerUINodes[position].RootGameObject = childItem.gameObject
        mPlayerUINodes[position].HeadRoot = childItem:Find('Head').gameObject
        mPlayerUINodes[position].HeadIcon = childItem:Find('Head/Icon'):GetComponent('Image')
        mPlayerUINodes[position].NameText = childItem:Find('Head/NameText'):GetComponent('Text')
        mPlayerUINodes[position].GoldText = childItem:Find('Head/Image/GoldText'):GetComponent('Text')
        mPlayerUINodes[position].ZBImage = childItem:Find('ZBImage').gameObject
        mPlayerUINodes[position].Fail = childItem:Find('Fail').gameObject
        mPlayerUINodes[position].WinText = mMyTransform:Find('Canvas/Result/Player'..position..'/WinText'):GetComponent('Text')
        mPlayerUINodes[position].LoseText = mMyTransform:Find('Canvas/Result/Player'..position..'/LoseText'):GetComponent('Text')
        mCountDownLight[position]=childItem:Find('Head/CountDown'..position).gameObject
        ResetMJPlayerUINode(mPlayerUINodes[position])
    end

    for index=1, 14, 1 do
        mMyHaveMahjong[index]=mMyTransform:Find('Canvas/Card/Player4/Mahjong'..index).gameObject
        mXiaJiaoZhiShi[index]=mMyTransform:Find('Canvas/Card/Player4/Mahjong'..index.."/XiaJiaoZhiShi").gameObject
        mMyHaveMahjong[index]:SetActive(false)
        mXiaJiaoZhiShi[index]:SetActive(false)
    end

    for Index=1,11,1 do
        TingPosition[Index]=this.transform:Find("Canvas/TingPaiInterfacePosition/Position"..Index).gameObject
    end

    mGangPaiInterface:SetActive(false)
    mErrorHintsGameObject:SetActive(false)
    mCardMaskGameObject:SetActive(false)
    mPromptGameObject1:SetActive(false)
    mPromptGameObject2:SetActive(false)
    mPromptGameObject3:SetActive(false)
    mTingButtonObject:SetActive(false)
    mTingPaiInterface:SetActive(false)
    mZhiZhenGameObject:SetActive(false)
    mSettlementGameObject:SetActive(false)
    mGameWaterObject:SetActive(false)
    mGameRankObject:SetActive(false)
    mRecordInterGameObject:SetActive(false)
    mReturnGameObject:SetActive(false)
    mZBButtonGameObject:SetActive(false)
    mCountDownGameObject:SetActive(false)
    mPengPaiGameObject:SetActive(false)
    mGangPaiGameObject:SetActive(false)
    mHuPaiGameObject:SetActive(false)
    mGuoGameObject:SetActive(false)

end

function AddButtonHandlers()
    mMyTransform:Find('Canvas/ReturnButton'):GetComponent("Button").onClick:AddListener(ExitButton_OnClick)
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1'):GetComponent("Button").onClick:AddListener(function() ReturnTransformSetActive(false) end)
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/MaskButton'):GetComponent("Button").onClick:AddListener(function() ReturnTransformSetActive(false) end)
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/ExitButton'):GetComponent("Button").onClick:AddListener(ExitButton_OnClick)

    mMyTransform:Find('Canvas/MasterInfo/ZBButton'):GetComponent("Button").onClick:AddListener(ZBButtonOnClick)

    mMyTransform:Find('Canvas/Buttons/PGHGButton/Viewport/Content/Peng'):GetComponent("Button").onClick:AddListener(function() PengGangHuGuoButtonOnClick(2,0,0) end)
    mMyTransform:Find('Canvas/Buttons/PGHGButton/Viewport/Content/Gang'):GetComponent("Button").onClick:AddListener(GangButtonOnClick)
    mMyTransform:Find('Canvas/Buttons/PGHGButton/Viewport/Content/Hu'):GetComponent("Button").onClick:AddListener(function() PengGangHuGuoButtonOnClick(4,0,0) end)
    mMyTransform:Find('Canvas/Buttons/PGHGButton/Viewport/Content/Guo'):GetComponent("Button").onClick:AddListener(function() PengGangHuGuoButtonOnClick(5,0,0) end)

    mMyTransform:Find('Canvas/DingQue/Image1'):GetComponent("Button").onClick:AddListener(function() DingQueButtonOnClick(1) end)
    mMyTransform:Find('Canvas/DingQue/Image2'):GetComponent("Button").onClick:AddListener(function() DingQueButtonOnClick(2) end)
    mMyTransform:Find('Canvas/DingQue/Image3'):GetComponent("Button").onClick:AddListener(function() DingQueButtonOnClick(3) end)

    mMyTransform:Find('Canvas/GameNumber'):GetComponent("Button").onClick:AddListener(function() RecordInterfaceDisplay(true,3) end)
    mMyTransform:Find('Canvas/TurnoverInterface/Back/Title/CloseButton'):GetComponent("Button").onClick:AddListener(function() RecordInterfaceDisplay(false,0) end)
    mGamePlayButton1:GetComponent("Button").onClick:AddListener(function() RecordInterfaceButtonOnClick(3) end)
    mGameWaterButton1:GetComponent("Button").onClick:AddListener(function() RecordInterfaceButtonOnClick(2) end)
    mGameRankButton1:GetComponent("Button").onClick:AddListener(function() RecordInterfaceButtonOnClick(1) end)


    mMyTransform:Find('Canvas/Buttons/NotepadButton'):GetComponent("Button").onClick:AddListener(RequestNowGameWaterInfo)
    mMyTransform:Find('Canvas/GameWater/CloseButton'):GetComponent('Button').onClick:AddListener( function() NowGameWaterDisplay(false) end)
    mMyTransform:Find('Canvas/GameWater/Close'):GetComponent('Button').onClick:AddListener( function() NowGameWaterDisplay(false) end)

    mSettlementGameObject.transform:Find('CloseButton'):GetComponent('Button').onClick:AddListener(function() SettlementInterfaceGameObjectDisplay(false) end)
    mSettlementGameObject.transform:Find('NewGame'):GetComponent('Button').onClick:AddListener(SettlementInterfaceNextGameButtonOnClick)

    mMyTransform:Find('Canvas/Buttons/TingButton'):GetComponent("Button").onClick:AddListener(function() TingPaiButtonOnClick(true) end)
    mTingPaiInterface.transform:Find('Close'):GetComponent("Button").onClick:AddListener(function() TingPaiButtonOnClick(false) end)

    mCardMaskGameObject.transform:GetComponent("Button").onClick:AddListener(KongBaiButtonOnClick)

    mMyTransform:Find('Canvas/Buttons/ButtonInvite1'):GetComponent('Button').onClick:AddListener( ButtonInvite_OnClick)

    mGameRankObject.transform:Find("Exit"):GetComponent("Button").onClick:AddListener(ExitButton_OnClick)
    -- 发送表情ID
    for index=1,14 do
        mMyTransform:Find('Canvas/Card/Player4/Mahjong'..index):GetComponent("Button").onClick:AddListener(function() MahjongInTheHand(index) end)
    end

    -- 杠牌选择界面按钮点击
    for Index=1,4,1 do
        mGangPaiInterface.transform:Find("BaiSeDi/HuangSeDi/GameObject/Convent/Template"..Index):GetComponent("Button").onClick:AddListener(function() GangPaiChoice(Index)end)
    end
end

function GetSetPlayer4CardPosition()
    local mPrint=this.transform:Find('Canvas/Card/Player4').gameObject
    local Subclass=mPrint.transform.childCount
    for mIndex=1,Subclass,1 do
        table.insert( player4CardPosition, {X=mMyHaveMahjong[mIndex].transform.localPosition.x,Y=mMyHaveMahjong[mIndex].transform.localPosition.y,Z=mMyHaveMahjong[mIndex].transform.localPosition.z} )
    end
end

-- 重置玩家信息归零
function ResetMJPlayerUINode(tPlayer)
    if nil == tPlayer then
        return
    end
    tPlayer.NameText.text = ""
    tPlayer.GoldText.text = ""
    tPlayer.HeadRoot:SetActive(false)
    tPlayer.ZBImage:SetActive(false)
end

--==============================--
--desc:返回菜单显示状态
--time:2018-03-01 09:46:42
--@isShow:
--@return 
--==============================--
function ReturnTransformSetActive(isShow)
    --GameObjectSetActive(mReturnGameObject, isShow)
    --if isShow then
        mExitButtonScript.interactable = MJCheckQuitGame()
        ExitButton_OnClick()
    --end
end

-- 玩家能否离开游戏检测
function MJCheckQuitGame( )
    local quit = true
    if mRoomData.MJPlayerList[4].PlayerState < PlayerStateEnumMJ.JoinOK or mRoomData.MJPlayerList[4].PlayerState >= PlayerStateEnumMJ.HU then
        quit = true
    else
        quit = false
    end
    return quit
end

-- 请求离开房间
function ExitButton_OnClick()
    --ReturnTransformSetActive(false)
    --if MJCheckQuitGame() then
        NetMsgHandler.Send_CS_MJ_LEAVE_ROOM()
    --end
end

--==============================--
--desc:邀请按钮call
--time:2018-02-27 08:18:26
--@return 
--==============================--
function InviteButton_OnClick()
    local tRoomID = mRoomData.RoomID
    local tRoomType = mRoomData.RoomType
    local tBet = mRoomData.MinBet
    local tEnterLimit = mRoomData.MinBet * 200
    local tBet = lua_NumberToStyle1String(tBet)
    local tEnterLimit = lua_NumberToStyle1String(tEnterLimit)
    GameData.OpenIniteUI(tRoomID, tRoomType, tBet, tEnterLimit)
end

--==============================--
--desc:重置房间到指定状态
--time:2018-02-28 08:02:35
--@roomState:
--@return 
--==============================--
function ResetMJGameRoomToRoomState(roomState)
    mRoomData = GameData.RoomInfo.CurrentRoom
    --mMasterData = mRoomData.MJPlayerList[MAX_MJZUJU_ROOM_PLAYER]
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
    InitMJRoomBaseInfos()
    RefreshMJGameRoomToGameState(roomState,true)
end

-- 初始化房间到初始状态
function InitMJRoomBaseInfos()
    SetMJRoomBaseInfo()
    HuImageDisaply(false)
    GameObjectSetActive(mReturnGameObject, false)
    GameObjectSetActive(mCountDownGameObject,false)
    ResetMJGamePositionInfo()
    ResetMJWinGold()
    ReconnectionDisplay()
    UpdateMahJongNumber()
end

-- 设置房间基础信息
function SetMJRoomBaseInfo()
    
    mRoomNumberText.text = tostring(mRoomData.RoomID)
    local gameNumber="<color=#B71B1BFF>"..mRoomData.BoardCurrentNumber.."</color>/"..mRoomData.BoardMaxNumber
    mGameNumberText.text = tostring(gameNumber)
    --mMahJongText.text = tostring(mRoomData.CardsSurplusNumber)
    this.transform:Find('Canvas/RoomRule/dizhu'):GetComponent('Text').text = "底注:"..(lua_NumberToStyle1String(mRoomData.MinBet))
    --this.transform:Find('Canvas/RoomRule/dizhu'):GetComponent('Text').text = MJGetRoomRuleTips(mRoomData.MinBet)
    GameObjectSetActive(mRoomNumberGameObject,mRoomData.RoomType == ROOM_TYPE.ZuJuMaJiang) 
    mPromptGameObject1:SetActive(false)
    mPromptGameObject2:SetActive(false)
    mPromptGameObject3:SetActive(false)
end

-- 获取房间规则显示描述1
function MJGetRoomRuleTips(nBet)
    --local ruleTips = string.format( data.GetString(string.format( "TTZ_Rule_Tip_%d_%d",mRoomData.LightPoker,mRoomData.CompensateType )),lua_NumberToStyle1String(mRoomData.MinBet))
    local ruleTips =string.format( data.GetString("TTZ_Rule_Tip"),lua_NumberToStyle1String(mRoomData.MinBet))
        if mRoomData.RoomType == ROOM_TYPE.ZuJuMaJiang then
            ruleTips = string.format( data.GetString("TTZ_Rule_Tip"),lua_NumberToStyle1String(mRoomData.MinBet))
        end
    return ruleTips
end

-- 重置游戏座位信息
function ResetMJGamePositionInfo()
    -- 重置座位信息
    for position = 1, MAX_MJZUJU_ROOM_PLAYER, 1 do
        ResetMJPlayerUINode(mPlayerUINodes[position])
        SetMJPlayerSitdownState(position)
        SetMJPlayerBaseInfo(position)
    end
end

-- 重置玩家信息归零
function ResetMJPlayerUINode(tPlayer)
    if nil == tPlayer then
        return
    end
    tPlayer.NameText.text = ""
    tPlayer.GoldText.text = ""
    tPlayer.HeadRoot:SetActive(false)
    tPlayer.ZBImage:SetActive(false)
end

--==============================--
--desc:进入一个玩家
--time:2018-02-28 08:43:11
--@args:
--@return 
--==============================--
function OnNotifyMJAddPlayerEvent( positionParam )
    if mRoomData.RoomState < ROOM_STATE_MJ.RANDOM then
        SetMJPlayerSitdownState(positionParam)
        SetMJPlayerBaseInfo(positionParam)
        --RefreshMJPlayerWaitTipsAndGoldText(positionParam, mRoomData.RoomState <= ROOM_STATE_TTZ.DEAL)
        UpdateButtonInvite1ShowState()
        ZBButtonISShow(true)
        -- 进入音效
        PlayAudioClip('NN_enter')
    end
end

--==============================--
--desc:离开一个玩家
--time:2018-02-28 08:44:55
--@positionParam:
--@return 
--==============================--
function OnNotifyMJDeletePlayerEvent( positionParam )
    if mRoomData.RoomState < ROOM_STATE_MJ.RANDOM then
        SetMJPlayerSitdownState(positionParam)
        SetMJPlayerBaseInfo(positionParam)
        UpdateButtonInvite1ShowState()
        ZBButtonISShow(false)
    end
end

-- 设置玩家坐下状态
function SetMJPlayerSitdownState(positionParam)
    --if mPlayerUINodes[positionParam] == nil then
      --  return
    --end
    if mRoomData.MJPlayerList[positionParam].PlayerState == PlayerStateEnumMJ.NULL or mRoomData.MJPlayerList[positionParam].ID==0 then
        mPlayerUINodes[positionParam].HeadRoot.gameObject:SetActive(false)
        mPlayerUINodes[positionParam].ZBImage:SetActive(false)
    else
        mPlayerUINodes[positionParam].HeadRoot.gameObject:SetActive(true)
    end
end

-- 设置玩家名称 头像 金币
function SetMJPlayerBaseInfo(positionParam)
    local showObj = mPlayerUINodes[positionParam]
    local showData = mRoomData.MJPlayerList[positionParam]
    if showData.PlayerState >= PlayerStateEnumMJ.LookOn and showData.ID~=0 then
        showObj.NameText.text = showData.strLoginIP
        showObj.GoldText.text = lua_NumberToStyle1String(showData.Gold)
        showObj.HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(showData.HeadIcon))
        if mRoomData.MJPlayerList[positionParam].PlayerState == PlayerStateEnumMJ.Ready then
            ZBImageIsShow(positionParam,true)
        end
    else
        showObj.NameText.text = ""
        showObj.GoldText.text = ""
    end
end

-- 设置断线重连后麻将显示数据
function ReconnectionDisplay()
    mTingButtonObject:SetActive(false)
    mErrorHintsGameObject:SetActive(false)
    --mTingPaiInterface:SetActive(false)
    for Index=1,11,1 do
        if TingPosition[Index].transform:Find("TingInterface")~=nil then
            local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
            CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
        end
    end
    this.transform:Find('Canvas/ReasonImage/LiuJu').gameObject:SetActive(false)
    this.transform:Find('Canvas/ReasonImage/GameOver').gameObject:SetActive(false)
    if mRoomData.RoomState >= ROOM_STATE_MJ.RANDOM then
        DXNBposition()
        for Index=1,4,1 do
            for index1=1,4,1 do
                mMyTransform:Find('Canvas/CountDown/position'..Index..'/Image_'..index1).gameObject:SetActive(false)
            end
        end
        mMyTransform:Find('Canvas/CountDown/position1/Image_'..playerBanker1).gameObject:SetActive(true)
        mMyTransform:Find('Canvas/CountDown/position2/Image_'..playerBanker2).gameObject:SetActive(true)
        mMyTransform:Find('Canvas/CountDown/position3/Image_'..playerBanker3).gameObject:SetActive(true)
        mMyTransform:Find('Canvas/CountDown/position4/Image_'..playerBanker4).gameObject:SetActive(true)
    end
    if mRoomData.RoomState >= ROOM_STATE_MJ.DEAL then
        for count1=1,4,1 do
            if mRoomData.MJPlayerList[count1]~=nil then
                if mRoomData.MJPlayerList[count1].ChuPokers ~= nil then
                    if #mRoomData.MJPlayerList[count1].ChuPokers>0 then
                        for index=1,#mRoomData.MJPlayerList[count1].ChuPokers,1 do
                            if index <28 then
                                local chupaitype=mRoomData.MJPlayerList[count1].ChuPokers[index].PokerType
                                local chupainumber=mRoomData.MJPlayerList[count1].ChuPokers[index].PokerNumber
                                this.transform:Find('Canvas/PlayerCardPosition/player'..count1..'/Viewpot/Content/MaJong'..index).gameObject:SetActive(true)
                                this.transform:Find('Canvas/PlayerCardPosition/player'..count1..'/Viewpot/Content/MaJong'..index..'/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(chupaitype,chupainumber))
                            end
                        end
                    end
                end
            end
        end
    end
    if mRoomData.RoomState >= ROOM_STATE_MJ.DEAL then
        MahJongFaPaiPaiXu()
        if mRoomData.RoomState >= ROOM_STATE_MJ.QUE then
            MahJongFaPaiPaiXu()
            if mRoomData.RoomState >= ROOM_STATE_MJ.QUE_END then
                --MahJongDingQue(4)
                PlayerDingQueIcon(true)
                if mRoomData.RoomState >= ROOM_STATE_MJ.CHUPAI then
                    MaJongChuPaiSort()
                    ConutDownDisplay(true)
                    ReconnectionPengGangCardDisplay()
                    OutCardClickCardSame(0,false)
                    for position=1,4,1 do
                        if mMyTransform:Find('Canvas/ReasonImage/position'..position.."/1")~=nil then
                            local mPriant = mMyTransform:Find('Canvas/ReasonImage/position'..position.."/1").gameObject
                            CS.UnityEngine.Object.Destroy(mPriant)
                        end
                    end
                end
            end
        end
    end
    if mRoomData.RoomState >= ROOM_STATE_MJ.DEAL then
        mMJShow()
    end
    if mRoomData.RoomState<=ROOM_STATE_MJ.READY then
        -- body
    end
    
    for mIndex=1,4,1 do
        if mRoomData.MJPlayerList[mIndex].PlayerState==PlayerStateEnumMJ.HU then
            --this.transform:Find('Canvas/Players/Player'..mIndex..'/HU').gameObject:SetActive(false)
            this.transform:Find('Canvas/Players/Player'..mIndex..'/HUImage').gameObject:SetActive(true)
            this.transform:Find("Canvas/HuCardPostion/player"..mIndex).gameObject:SetActive(true)
            if mRoomData.MJPlayerList[mIndex].IsYPDX == 1 then
                this.transform:Find('Canvas/HuCardPostion/player'..mIndex):GetComponent("Image").color=CS.UnityEngine.Color(255, 255, 255, 0.5) 
            else
                this.transform:Find('Canvas/HuCardPostion/player'..mIndex):GetComponent("Image").color=CS.UnityEngine.Color(255, 255, 255, 1) 
            end
            local HUtype = mRoomData.MJPlayerList[mIndex].HUtype
            local number = mRoomData.MJPlayerList[mIndex].HUnumber
            this.transform:Find("Canvas/HuCardPostion/player"..mIndex.."/Image"):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(HUtype,number))
        else
            this.transform:Find('Canvas/Players/Player'..mIndex..'/HUImage').gameObject:SetActive(false)
        end
    end
end

-- 断线重连后处理碰杠牌显示
function ReconnectionPengGangCardDisplay()
    DestoryPengGangCards()
    for mmIndex=1,4,1 do
        MJPLAYERPGLIST[mmIndex]={}
        if mRoomData.MJPlayerList[mmIndex]~=nil then
            if mRoomData.MJPlayerList[mmIndex].PengPokers~=nil then
                if #mRoomData.MJPlayerList[mmIndex].PengPokers>0 then
                    for mCount=1,#mRoomData.MJPlayerList[mmIndex].PengPokers,1 do
                        local triggerPlayerPosition = #MJPLAYERPGLIST[mmIndex]+1
                        local table1={Mode=1,PokerType=mRoomData.MJPlayerList[mmIndex].PengPokers[mCount].PokerType, PokerNumber = mRoomData.MJPlayerList[mmIndex].PengPokers[mCount].PokerNumber,triggerPlayerPosition=triggerPlayerPosition}
                        table.insert( MJPLAYERPGLIST[mmIndex],table1 )
                    end
                end
            end
            if mRoomData.MJPlayerList[mmIndex].GangPokers~=nil then
                if #mRoomData.MJPlayerList[mmIndex].GangPokers>0 then
                    for mCount=1,#mRoomData.MJPlayerList[mmIndex].GangPokers,1 do
                        local triggerPlayerPosition = #MJPLAYERPGLIST[mmIndex]+1
                        local table1={Mode=2,PokerType=mRoomData.MJPlayerList[mmIndex].GangPokers[mCount].PokerType, PokerNumber = mRoomData.MJPlayerList[mmIndex].GangPokers[mCount].PokerNumber,breed=mRoomData.MJPlayerList[mmIndex].GangPokers[mCount].GangType,triggerPlayerPosition=triggerPlayerPosition}
                        table.insert( MJPLAYERPGLIST[mmIndex],table1 )
                    end
                end
            end
        end
    end
    for mIndexTwo=1,4,1 do
        if MJPLAYERPGLIST[mIndexTwo]~=nil then
            if #MJPLAYERPGLIST[mIndexTwo]>0 then
                for mCoutTwo=1,#MJPLAYERPGLIST[mIndexTwo],1 do
                    
                    local PGTYPE=MJPLAYERPGLIST[mIndexTwo][mCoutTwo].PokerType
                    local PGNUMBER=MJPLAYERPGLIST[mIndexTwo][mCoutTwo].PokerNumber
                    if MJPLAYERPGLIST[mIndexTwo][mCoutTwo].Mode==1 then
                        local card = this.transform:Find("Canvas/GangPengPaiPosition/player"..mIndexTwo.."/Template1").gameObject
                        local copy = CS.UnityEngine.Object.Instantiate(card)
                        local chips=this.transform:Find('Canvas/GangPengPaiPosition/player'..mIndexTwo..'/Scroll View/Viewport/Content').gameObject
                        pengganghuCardNumber[mIndexTwo]=mCoutTwo
                        copy.transform.name="Copy_"..mCoutTwo
                        copy.transform.parent=chips.transform
                        copy.transform.localPosition=CS.UnityEngine.Vector3(copy.transform.localPosition.x,copy.transform.localPosition.y,0)
                        copy.transform.localScale=CS.UnityEngine.Vector3(1,1,0)
                        copy.transform:Find('Image4').gameObject:SetActive(false)
                        copy:SetActive(true)
                        for mIndexThree=1,4,1 do
                            copy.transform:Find('Image'..mIndexThree..'/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(PGTYPE,PGNUMBER))
                        end
                    elseif MJPLAYERPGLIST[mIndexTwo][mCoutTwo].Mode==2 then
                        local card=nil
                        local copy = nil
                        if MJPLAYERPGLIST[mIndexTwo][mCoutTwo].breed==1 then
                            card = this.transform:Find("Canvas/GangPengPaiPosition/player"..mIndexTwo.."/Template2").gameObject
                        elseif MJPLAYERPGLIST[mIndexTwo][mCoutTwo].breed==2 then
                            card = this.transform:Find("Canvas/GangPengPaiPosition/player"..mIndexTwo.."/Template1").gameObject
                        elseif MJPLAYERPGLIST[mIndexTwo][mCoutTwo].breed==3 then
                            card = this.transform:Find("Canvas/GangPengPaiPosition/player"..mIndexTwo.."/Template1").gameObject
                        end
                        copy = CS.UnityEngine.Object.Instantiate(card)
                        local chips=this.transform:Find('Canvas/GangPengPaiPosition/player'..mIndexTwo..'/Scroll View/Viewport/Content').gameObject
                        pengganghuCardNumber[mIndexTwo]=mCoutTwo
                        copy.transform.name="Copy_"..mCoutTwo
                        copy.transform.parent=chips.transform
                        copy.transform.localPosition=CS.UnityEngine.Vector3(copy.transform.localPosition.x,copy.transform.localPosition.y,0)
                        copy.transform.localScale=CS.UnityEngine.Vector3(1,1,0)
                        copy:SetActive(true)
                        if MJPLAYERPGLIST[mIndexTwo][mCoutTwo].breed==1 then
                            copy.transform:Find('Image/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(PGTYPE,PGNUMBER))
                        else
                            for mIndexThree=1,4,1 do
                                copy.transform:Find('Image'..mIndexThree..'/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(PGTYPE,PGNUMBER))
                            end
                        end
                    end

                end
            end
        end
    end
end

-- 房间状态刷新
function RefreshMJGameRoomByRoomStateSwitchTo( roomState )
    -- body
    RefreshMJGameRoomToGameState(roomState,true)

end

--==============================--
--desc:刷新房间到指定状态
--time:2018-02-28 08:13:07
--@roomState:
--@isInit:
--@return 
--==============================--
function RefreshMJGameRoomToGameState( roomState, isInit )
    --RefreshMJSTARTPartOfGameRoomByState( roomState, isInit )
    RefreshMJREADYPartOfGameRoomByState(roomState, isInit)
    RefreshMJRANDOMPartOfGameRoomByState(roomState, isInit)
    RefreshMJDEALPartOfGameRoomByState(roomState, isInit)
    RefreshMJQUEPartOfGameRoomByState(roomState, isInit)
    RefreshMJQUEOVERPartOfGameRoomByState(roomState, isInit)
    RefreshMJCHUPAIPartOfGameRoomByState(roomState, isInit)
    RefreshMJWaitPengGangHuPartOfGameRoomByState(roomState, isInit)
    RefreshMJWaitPengGangHuEndPartOfGameRoomByState(roomState, isInit)
    RefreshMJSettlementPartOfGameRoomByState(roomState, isInit)
    RefreshMJFlowBureauOfGameRoomByState(roomState, isInit)
end

-- 胡牌Image显示
function HuImageDisaply(mShow)
    for count=1,4,1 do
        this.transform:Find('Canvas/Players/Player'..count..'/HUImage').gameObject:SetActive(mShow)
    end
    if mShow == false then
        for count=1,4,1 do
            local TweenObject = this.transform:Find('Canvas/Players/Player'..count..'/HUImage'):GetComponent("TweenPosition")
            TweenObject.enabled=false
        end
    end
end

-- 麻将排序
function MahjongSort1(tCard1, tCard2)
    return tCard1.PokerType == tCard2.PokerType and (tCard1.PokerNumber < tCard2.PokerNumber and true or false) or (tCard1.PokerType < tCard2.PokerType and true or false)
end

--庄家定缺前排序
function MahJongFaPaiPaiXu()
    local TiaoTable={}
    local WanTable={}
    if #mRoomData.MJPlayerList[4].OnlyPokers==1 then
        table.insert(mRoomData.MJPlayerList[4].Pokers, {PokerType=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType, PokerNumber=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber})
    end
    --获取手牌中牌型为"条"的牌
    for i=#mRoomData.MJPlayerList[4].Pokers,1,-1 do
        if mRoomData.MJPlayerList[4].Pokers[i].PokerType==2 then
            table.insert(TiaoTable,mRoomData.MJPlayerList[4].Pokers[i])
            table.remove(mRoomData.MJPlayerList[4].Pokers,i)
        end
    end
    --获取手牌中牌型为"万"的牌
    for i=#mRoomData.MJPlayerList[4].Pokers,1,-1 do
        if mRoomData.MJPlayerList[4].Pokers[i].PokerType==3 then
            table.insert(WanTable,mRoomData.MJPlayerList[4].Pokers[i])
            table.remove(mRoomData.MJPlayerList[4].Pokers,i)
        end
    end
    table.sort( mRoomData.MJPlayerList[4].Pokers, MahjongSort1 )
    table.sort( TiaoTable, MahjongSort1 )
    table.sort( WanTable, MahjongSort1 )
    for k,v in ipairs(TiaoTable) do
        table.insert( mRoomData.MJPlayerList[4].Pokers,v)
    end
    for k,v in ipairs(WanTable) do
        table.insert( mRoomData.MJPlayerList[4].Pokers,v)
    end
    if #mRoomData.MJPlayerList[4].OnlyPokers==1 then
        mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType=mRoomData.MJPlayerList[4].Pokers[#mRoomData.MJPlayerList[4].Pokers].PokerType
        mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber=mRoomData.MJPlayerList[4].Pokers[#mRoomData.MJPlayerList[4].Pokers].PokerNumber
        table.remove( mRoomData.MJPlayerList[4].Pokers, #mRoomData.MJPlayerList[4].Pokers)
    end
end

-- 麻将定缺后排序
function MahJongDingQue(Position)
    local TiaoTable={}
    local WanTable={}
    if  #mRoomData.MJPlayerList[Position].Pokers == nil or #mRoomData.MJPlayerList[Position].Pokers == 0 then
        return
    end
    if #mRoomData.MJPlayerList[Position].OnlyPokers==1 then
        table.insert(mRoomData.MJPlayerList[Position].Pokers, {PokerType=mRoomData.MJPlayerList[Position].OnlyPokers[1].PokerType, PokerNumber=mRoomData.MJPlayerList[Position].OnlyPokers[1].PokerNumber})
    end
    --获取手牌中牌型为"条"的牌
    for i=#mRoomData.MJPlayerList[Position].Pokers,1,-1 do
        if mRoomData.MJPlayerList[Position].Pokers[i].PokerType==2 then
            table.insert(TiaoTable,mRoomData.MJPlayerList[Position].Pokers[i])
            table.remove(mRoomData.MJPlayerList[Position].Pokers,i)
        end
    end
    --获取手牌中牌型为"万"的牌
    for i=#mRoomData.MJPlayerList[Position].Pokers,1,-1 do
        if mRoomData.MJPlayerList[Position].Pokers[i].PokerType==3 then
            table.insert(WanTable,mRoomData.MJPlayerList[Position].Pokers[i])
            table.remove(mRoomData.MJPlayerList[Position].Pokers,i)
        end
    end
    table.sort( TiaoTable, MahjongSort1 )
    table.sort( WanTable, MahjongSort1 )
    for k,v in ipairs(TiaoTable) do
        table.insert( mRoomData.MJPlayerList[Position].Pokers,v)
    end
    for k,v in ipairs(WanTable) do
        table.insert( mRoomData.MJPlayerList[Position].Pokers,v)
    end
    local TemporaryTable={}
    for i=#mRoomData.MJPlayerList[Position].Pokers,1,-1 do
        if mRoomData.MJPlayerList[Position].Pokers[i].PokerType==mRoomData.MJPlayerList[Position].QueType then
            table.insert(TemporaryTable,mRoomData.MJPlayerList[Position].Pokers[i])
            table.remove(mRoomData.MJPlayerList[Position].Pokers,i)
        end
    end
    table.sort( TemporaryTable, MahjongSort1 )
    for k,v in ipairs(TemporaryTable) do
        table.insert( mRoomData.MJPlayerList[Position].Pokers,v)
    end
    if #mRoomData.MJPlayerList[Position].OnlyPokers==1 then
        mRoomData.MJPlayerList[Position].OnlyPokers[1].PokerType=mRoomData.MJPlayerList[Position].Pokers[#mRoomData.MJPlayerList[Position].Pokers].PokerType
        mRoomData.MJPlayerList[Position].OnlyPokers[1].PokerNumber=mRoomData.MJPlayerList[Position].Pokers[#mRoomData.MJPlayerList[Position].Pokers].PokerNumber
        table.remove(mRoomData.MJPlayerList[Position].Pokers,#mRoomData.MJPlayerList[Position].Pokers)
    end
end

-- 麻将出牌后排序
function MaJongChuPaiSort()
    local TemporaryTable={}
    local count=mRoomData.MJPlayerList[4].PokerNumber
    for i=#mRoomData.MJPlayerList[4].Pokers,1,-1 do
        if mRoomData.MJPlayerList[4].Pokers[i].PokerType==mRoomData.MJPlayerList[4].QueType then
            table.insert(TemporaryTable,mRoomData.MJPlayerList[4].Pokers[i])
            table.remove(mRoomData.MJPlayerList[4].Pokers,i)
        end
    end
    table.sort( TemporaryTable, MahjongSort1 )
    for k,v in ipairs(TemporaryTable) do
        table.insert( mRoomData.MJPlayerList[4].Pokers,v)
    end
end

-- 重置麻将数据
function RestMahJongData()
    mjIsShow()
    HuImageDisaply(false)
    ConutDownDisplay(false)
    HuPaiDisplay(0,false)
    DestoryPengGangCards()
    
    for index = 1,4,1 do
        mRoomData.MJPlayerList[index].PokerNumber=0
        mRoomData.MJPlayerList[index].Pokers={}
        mRoomData.MJPlayerList[index].onlyPokerNumber=0
        mRoomData.MJPlayerList[index].OnlyPokers={}
        mRoomData.MJPlayerList[index].QueType=nil
        mRoomData.MJPlayerList[index].ChuPokers={}
        mRoomData.MJPlayerList[index].pengPokerNumber=0
        mRoomData.MJPlayerList[index].PengPokers={}
        mRoomData.MJPlayerList[index].gangPokerNumber=0
        mRoomData.MJPlayerList[index].GangPokers={}
        mRoomData.MJPlayerList[index].HUtype=nil
        mRoomData.MJPlayerList[index].HUnumber=nil
        mRoomData.MJPlayerList[index].IsYPDX=0
        MJPLAYERPGLIST[index]={}
        mCountDownLight[index]:SetActive(false)
        this.transform:Find('Canvas/Players/Player'..index..'/HUImage').gameObject:SetActive(false)
        this.transform:Find("Canvas/HuCardPostion/player"..index):GetComponent("Image").color=CS.UnityEngine.Color(255, 255, 255, 1)
    end
    for Index=1,14,1 do
        mXiaJiaoZhiShi[Index]:SetActive(false)
    end
    PlayerThrowInTheTowel(false)
    PlayerDingQueIcon(false)
    TingPaiCard={}
    playerOutCardaNum={[1]=0,[2]=0,[3]=0,[4]=0}
    pengganghuCardNumber={[1]=0,[2]=0,[3]=0,[4]=0}
    mRoomData.WaitCardType=nil
    mRoomData.WaitCardNumber=nil
    mRoomData.pengganghuType=nil
    mRoomData.pengganghuNumber=nil
    mRoomData.LastOutCardPlayer=0
    mCardMaskGameObject:SetActive(false)
    mTingButtonObject:SetActive(false)
    --mTingPaiInterface:SetActive(false)
    for Index=1,11,1 do
        if TingPosition[Index].transform:Find("TingInterface")~=nil then
            local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
            CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
        end
    end
    IsLiuJu=false
    ResetMJGamePositionInfo()
    OutCardClickCardSame(0,false)
end

-- 重回等待开始游戏状态
function RefreshMJSTARTPartOfGameRoomByState( roomState, isInit )
    if roomState == ROOM_STATE_MJ.START and true == isInit then
        RestMahJongData()
    end
end

-- 准备阶段
function RefreshMJREADYPartOfGameRoomByState ( roomState, isInit )
    if roomState == ROOM_STATE_MJ.READY and true == isInit then
        RestMahJongData()
        ZBButtonISShow(true)
        UpdateMahJongNumber()
        UpdateButtonInvite1ShowState()
    else
        ZBButtonISShow(false)
    end
end

-- 摇色子阶段
function RefreshMJRANDOMPartOfGameRoomByState( roomState, isInit )
    if roomState == ROOM_STATE_MJ.RANDOM then
        for index= 1,4,1 do
            if mRoomData.MJPlayerList[index].Name~="" then
                if mRoomData.MJPlayerList[index].PlayerState > PlayerStateEnumMJ.NULL then
                    mRoomData.MJPlayerList[index].PlayerState=PlayerStateEnumMJ.JoinOK
                end
            end
        end
        mjIsShow()
        ZBImageIsShow(5,false)
        UpdateCurrentNumberOfBureaus()
        DXNBposition()
        UpdateMahJongNumber()
        for Index=1,4,1 do
            for index1=1,4,1 do
                mMyTransform:Find('Canvas/CountDown/position'..Index..'/Image_'..index1).gameObject:SetActive(false)
            end
        end
        mMyTransform:Find('Canvas/CountDown/position1/Image_'..playerBanker1).gameObject:SetActive(true)
        mMyTransform:Find('Canvas/CountDown/position2/Image_'..playerBanker2).gameObject:SetActive(true)
        mMyTransform:Find('Canvas/CountDown/position3/Image_'..playerBanker3).gameObject:SetActive(true)
        mMyTransform:Find('Canvas/CountDown/position4/Image_'..playerBanker4).gameObject:SetActive(true)
    end
end

-- 发牌阶段
function RefreshMJDEALPartOfGameRoomByState(roomState, isInit)
    if roomState == ROOM_STATE_MJ.DEAL then
        for index= 1,4,1 do
            if mRoomData.MJPlayerList[index].Name~="" then
                if mRoomData.MJPlayerList[index].PlayerState~=PlayerStateEnumMJ.NULL then
                    mRoomData.MJPlayerList[index].PlayerState=PlayerStateEnumMJ.JoinOK
                end
            end
        end
        MahJongFaPaiDongHua()
        this:DelayInvoke(0.9,function()
            MahJongFaPaiPaiXu()
            mMJShow()
        end)
    end
end

-- 定缺阶段
function RefreshMJQUEPartOfGameRoomByState(roomState, isInit)
    if roomState == ROOM_STATE_MJ.QUE then
        DingQueImage(true)
        DingQueZhong(true)
        local count=mRoomData.MJPlayerList[4].PokerNumber
        if count>1 then
            table.sort(mRoomData.MJPlayerList[4].Pokers, MahjongSort1 )
            mMJShow()
        end
    else
        DingQueImage(false)
        DingQueZhong(false)
    end
end

function RandomQue(tCard)
    local nTongNum = 0
    local nTiaoNum = 0
    local nWanNum = 0
    for k,v in pairs(tCard) do
        if v.PokerType == MJ_QUE_Card_Type.Tong then
            nTongNum = nTongNum + 1
        elseif v.PokerType == MJ_QUE_Card_Type.Tiao then
            nTiaoNum = nTiaoNum + 1
        elseif v.PokerType == MJ_QUE_Card_Type.Wan then
            nWanNum = nWanNum + 1
        end
    end
    local nMin = math.min(nTongNum, nTiaoNum, nWanNum)
    if nMin == nTongNum then
        return MJ_QUE_Card_Type.Tong
    elseif nMin == nTiaoNum then
        return MJ_QUE_Card_Type.Tiao
    elseif nMin == nWanNum then
        return MJ_QUE_Card_Type.Wan
    end
    return MJ_QUE_Card_Type.Tong
end


function DingQueZhong(mShow)
    if mShow then
        for index=1,3,1 do
            this.transform:Find('Canvas/Players/Player'..index..'/DingQue').gameObject:SetActive(mShow)
        end
    else
        for index=1,3,1 do
            this.transform:Find('Canvas/Players/Player'..index..'/DingQue').gameObject:SetActive(mShow)
        end
    end
end

-- 定缺结束
function RefreshMJQUEOVERPartOfGameRoomByState(roomState, isInit)
    if roomState == ROOM_STATE_MJ.QUE_END then
        PlayerDingQueAnimtion(0)
        this:DelayInvoke(0.5,function ()
            PlayerDingQueIcon(true)
        end)
        MahJongDingQue(4)
        mMJShow()
    end
end

-- 玩家出牌阶段
function RefreshMJCHUPAIPartOfGameRoomByState(roomState, isInit)
    
    if roomState == ROOM_STATE_MJ.CHUPAI then
        CountDowenMusic=true
        for Index=1,4,1 do
            mCountDownLight[Index].gameObject:SetActive(false)
        end
        if mRoomData.PlardCardPosition ==4 then
            --mTingButtonObject:SetActive(false)
            TingButtonDisplay()
            mPromptGameObject2:SetActive(false)
            for Index=1,#mRoomData.MJPlayerList[4].Pokers,1 do
                if mRoomData.MJPlayerList[4].Pokers[Index].PokerType == mRoomData.MJPlayerList[4].QueType then
                    mPromptGameObject2:SetActive(true)
                end
            end
            if #mRoomData.MJPlayerList[4].OnlyPokers==1 then
                if mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType == mRoomData.MJPlayerList[4].QueType then
                    mPromptGameObject2:SetActive(true)
                end
            end
            if mRoomData.BankerPosition == 4 and mRoomData.CardsSurplusNumber==55 then
                mPromptGameObject2:SetActive(false)
                mPromptGameObject1:SetActive(true)

            end
        else
            mGangPaiInterface:SetActive(false)
            mPromptGameObject1:SetActive(false)
            for Index=1,14,1 do
                mXiaJiaoZhiShi[Index]:SetActive(false)
            end
        end
        ConutDownDisplay(true)
        if mRoomData.PlardCardPosition == 4 then
            mPromptGameObject3:SetActive(false)
            if mRoomData.MJPlayerList[4].IsPeng == 1 then
                if #mRoomData.MJPlayerList[4].OnlyPokers == 1 and mRoomData.MJPlayerList[4].RaoPao == 1 then
                    HuPaiButtonDisplay(CheckCanHu(mRoomData.MJPlayerList[4].Pokers, mRoomData.MJPlayerList[4].QueType, mRoomData.MJPlayerList[4].OnlyPokers[1]))
                end
                local IsGang=CheckAAAACard(mRoomData.MJPlayerList[4].Pokers,mRoomData.MJPlayerList[4].QueType)
                if mRoomData.CardsSurplusNumber > 0 then
                    if IsGang == true then
                        GangPaiButtonDisplay(true)
                    else
                        if #mRoomData.MJPlayerList[4].OnlyPokers == 1 then
                            IsGang=CheckCanGang(mRoomData.MJPlayerList[4].Pokers,mRoomData.MJPlayerList[4].QueType,mRoomData.MJPlayerList[4].OnlyPokers[1])
                            GangPaiButtonDisplay(IsGang)
                            if IsGang == false then
                                mGangPaiGameObject:SetActive(false)
                            end
                        end
                    end
                end
                
                if #MJPLAYERPGLIST[4]>0 and IsGang == false then
                    local LinShi = {}
                    for index = 1, #mRoomData.MJPlayerList[4].Pokers, 1 do
                        LinShi[index]= mRoomData.MJPlayerList[4].Pokers[index]
                    end
                    if #mRoomData.MJPlayerList[4].OnlyPokers==1 then
                        table.insert( LinShi,{PokerNumber=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber,PokerType=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType})
                    end
                    if mRoomData.CardsSurplusNumber > 0 then
                        GangPaiButtonDisplay(CheckCanBuGang(LinShi,mRoomData.MJPlayerList[4].QueType,MJPLAYERPGLIST[4]))
                    end
                    
                end
                
                GuoButtonDisplay()
            end
            
        end
    end
end

-- 等待碰杠胡阶段
function RefreshMJWaitPengGangHuPartOfGameRoomByState(roomState, isInit)
    if roomState == ROOM_STATE_MJ.WAIT and mRoomData.WaitPGHPlayerPosition ~=4 then
        mPromptGameObject3:SetActive(false)
        local playCard={PokerType=mRoomData.WaitCardType,PokerNumber=mRoomData.WaitCardNumber}
        if mRoomData.MJPlayerList[4].PlayerState ~=PlayerStateEnumMJ.HU then
            local KePeng = CheckCanPeng(mRoomData.MJPlayerList[4].Pokers,mRoomData.MJPlayerList[4].QueType,playCard)
            if KePeng then
                local PengDispaly = true
                if mRoomData.MJPlayerList[4].GuoPeng~=0 then
                    for Index1=1,#mRoomData.MJPlayerList[4].GuoPengTable,1 do
                        for Index=1,#mRoomData.MJPlayerList[4].Pokers,1 do
                            if mRoomData.MJPlayerList[4].GuoPengTable[Index1].PokerType == mRoomData.MJPlayerList[4].Pokers[Index].PokerType then
                                if mRoomData.MJPlayerList[4].GuoPengTable[Index1].PokerNumber == mRoomData.MJPlayerList[4].Pokers[Index].PokerNumber then
                                    PengDispaly=false
                                    break
                                end
                            end
                        end
                    end
                end
                if PengDispaly then
                    PengPaiButtonDisplay(PengDispaly)
                else
                    mPromptGameObject3:SetActive(true)
                    mPromptGameObject3.transform:Find("Image/Text"):GetComponent("Text").text="过碰不碰"
                end

            end
            --PengPaiButtonDisplay(CheckCanPeng(mRoomData.MJPlayerList[4].Pokers,mRoomData.MJPlayerList[4].QueType,playCard))
            if mRoomData.CardsSurplusNumber > 0 then
                GangPaiButtonDisplay(CheckCanGang(mRoomData.MJPlayerList[4].Pokers,mRoomData.MJPlayerList[4].QueType,playCard))
            end
            
            if mRoomData.MJPlayerList[4].RaoPao == 1 then
                mPromptGameObject3:SetActive(false)
                HuPaiButtonDisplay(CheckCanHu(mRoomData.MJPlayerList[4].Pokers, mRoomData.MJPlayerList[4].QueType, playCard))
            else
                local KeHu = CheckCanHu(mRoomData.MJPlayerList[4].Pokers, mRoomData.MJPlayerList[4].QueType, playCard)
                if KeHu then
                    mPromptGameObject3:SetActive(true)
                    mPromptGameObject3.transform:Find("Image/Text"):GetComponent("Text").text="过胡不胡"
                end
            end
        end
        GuoButtonDisplay()
    end
end

-- 碰杠胡阶段结束
function RefreshMJWaitPengGangHuEndPartOfGameRoomByState(roomState, isInit)
    if roomState == ROOM_STATE_MJ.WAIT_END then
        PengPaiButtonDisplay(false)
        GangPaiButtonDisplay(false)
        HuPaiButtonDisplay(false)
        GuoButtonDisplay()
    end
end

--结算阶段
function RefreshMJSettlementPartOfGameRoomByState(roomState, isInit)
    if roomState == ROOM_STATE_MJ.SETTLEMENT then
        FlowBureauCardDisplay(true)
        this:DelayInvoke(1,function()
            SettlementInterfaceGameObjectDisplay(true)
        end)
    else
        FlowBureauCardDisplay(false)
    end
end

-- 流局阶段
function RefreshMJFlowBureauOfGameRoomByState(roomState, isInit)
    if roomState == ROOM_STATE_MJ.LIUJU then
        --print("进入流局阶段")
        local LiuJu = this.transform:Find('Canvas/ReasonImage/LiuJu').gameObject
        IsLiuJu=true
        if LiuJu.activeSelf == false then
            --print("打开流局界面")
            local TweenObject=LiuJu:GetComponent("TweenScale")
            LiuJu:SetActive(true)
            TweenObject:ResetToBeginning()
            TweenObject:Play(true)
            this:DelayInvoke(2,function ()
                LiuJu:SetActive(false)
            end)
        end
        
    else
        this.transform:Find('Canvas/ReasonImage/LiuJu').gameObject:SetActive(false)
    end
end

-- 麻将发牌动画
function MahJongFaPaiDongHua()
    PlayAudioClip("MJ_FaPai")
    this:DelayInvoke(0,function()
        for Index=1,14,1 do
            this.transform:Find('Canvas/Card/Player4/Mahjong'..Index):GetComponent("Image").color=CS.UnityEngine.Color.white
            mMyHaveMahjong[Index].transform.localPosition=CS.UnityEngine.Vector3(player4CardPosition[Index].X,player4CardPosition[Index].Y,player4CardPosition[Index].Z)
        end
        for mIndex=1,4,1 do
            if mRoomData.MJPlayerList[mIndex].PokerNumber~=nil and mRoomData.MJPlayerList[mIndex].PokerNumber>0 then
                for mCount=1,4,1 do
                    this.transform:Find('Canvas/Card/Player'..mIndex..'/Mahjong'..mCount).gameObject:SetActive(true)
                    if mIndex==4 then
                        local PokerType = mRoomData.MJPlayerList[4].Pokers[mCount].PokerType
                        local PokerNumber = mRoomData.MJPlayerList[4].Pokers[mCount].PokerNumber
                        this.transform:Find('Canvas/Card/Player4/Mahjong'..mCount..'/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(PokerType,PokerNumber))
                    end
                end
            end
        end
        mMahJongText.text="92"
    end)
    this:DelayInvoke(0.25,function()
        for mIndex=1,4,1 do
            if mRoomData.MJPlayerList[mIndex].PokerNumber~=nil and mRoomData.MJPlayerList[mIndex].PokerNumber>0 then
                for mCount=5,8,1 do
                    this.transform:Find('Canvas/Card/Player'..mIndex..'/Mahjong'..mCount).gameObject:SetActive(true)
                    if mIndex==4 then
                        local PokerType = mRoomData.MJPlayerList[4].Pokers[mCount].PokerType
                        local PokerNumber = mRoomData.MJPlayerList[4].Pokers[mCount].PokerNumber
                        this.transform:Find('Canvas/Card/Player4/Mahjong'..mCount..'/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(PokerType,PokerNumber))
                    end
                end
            end
        end
        mMahJongText.text="76"
    end)
    this:DelayInvoke(0.5,function()
        for mIndex=1,4,1 do
            if mRoomData.MJPlayerList[mIndex].PokerNumber~=nil and mRoomData.MJPlayerList[mIndex].PokerNumber>0 then
                for mCount=8,12,1 do
                    this.transform:Find('Canvas/Card/Player'..mIndex..'/Mahjong'..mCount).gameObject:SetActive(true)
                    if mIndex==4 then
                        local PokerType = mRoomData.MJPlayerList[4].Pokers[mCount].PokerType
                        local PokerNumber = mRoomData.MJPlayerList[4].Pokers[mCount].PokerNumber
                        this.transform:Find('Canvas/Card/Player4/Mahjong'..mCount..'/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(PokerType,PokerNumber))
                    end
                end
            end
        end
        mMahJongText.text="60"
    end)
    this:DelayInvoke(0.75,function()
        for mIndex=1,4,1 do
            if mRoomData.MJPlayerList[mIndex].PokerNumber~=nil and mRoomData.MJPlayerList[mIndex].PokerNumber>0 then
                this.transform:Find('Canvas/Card/Player'..mIndex..'/Mahjong13').gameObject:SetActive(true)
                if mIndex==4 then
                    local PokerType = mRoomData.MJPlayerList[4].Pokers[13].PokerType
                    local PokerNumber = mRoomData.MJPlayerList[4].Pokers[13].PokerNumber
                    this.transform:Find('Canvas/Card/Player4/Mahjong13/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(PokerType,PokerNumber))
                end
                if mRoomData.MJPlayerList[mIndex].onlyPokerNumber~=nil and mRoomData.MJPlayerList[mIndex].onlyPokerNumber>0 then
                    this.transform:Find('Canvas/Card/Player'..mIndex..'/Mahjong14').gameObject:SetActive(true)
                    if mIndex==4 then
                        local PokerType = mRoomData.MJPlayerList[4].Pokers[1].PokerType
                        local PokerNumber = mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber
                        this.transform:Find('Canvas/Card/Player4/Mahjong14/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(PokerType,PokerNumber))
                    end
                end
            end
            mMahJongText.text="55"
        end
    end)
end

-- 出牌显示
function OutOfTheCardDisplay()
    local position= mRoomData.PlardCardPosition
end

-- 更新当前局数
function UpdateCurrentNumberOfBureaus()
    local gameNumber="<color=#B71B1BFF>"..mRoomData.BoardCurrentNumber.."</color>/"..mRoomData.BoardMaxNumber
    mGameNumberText.text=tostring(gameNumber)
end

-- 更新当前倒计时
function UpdateCountDownTiemDisolay()
    local second=math.ceil(mRoomData.MJCountDown)
    mCountDownText.text=""..second
end

local m_CheckColorOf1 = CS.UnityEngine.Color(41 / 255, 243 / 255, 0)
local m_CheckColorOf2 = CS.UnityEngine.Color(230 / 255, 251 / 255, 34 / 255)
local m_CheckColorOf3 = CS.UnityEngine.Color(227 / 255, 50 / 255, 8 / 255)

-- 玩家头顶光圈
function PlayerLightDisplay()
    local checkCountDown = mCountDownLight[mRoomData.PlardCardPosition]
    local maxValue = 16
    local second=mRoomData.MJCountDown
    if checkCountDown ~= nil then
        checkCountDown.gameObject:SetActive(true)
        local mfillAmount = second / maxValue
        local countDownProgress = checkCountDown.transform:Find('Image'):GetComponent("Image")
        checkCountDown.transform:Find('ValueText'):GetComponent("Text").text = tostring(math.ceil(second))
        if math.ceil(second) <= 3 then
            if CountDowenMusic == true then
                PlayAudioClip("8")
                this:DelayInvoke(1,function ()
                    PlayAudioClip("8")
                end)
                this:DelayInvoke(2,function ()
                    PlayAudioClip("8")
                end)
                CountDowenMusic=false
            end
        end
        countDownProgress.fillAmount = mfillAmount
        if mfillAmount > 0.63 then
            countDownProgress.color = m_CheckColorOf1
        elseif mfillAmount > 0.38 then
            countDownProgress.color = m_CheckColorOf2
        else
            countDownProgress.color = m_CheckColorOf3
        end
    end
end


--更新当前麻将剩余数量
function UpdateMahJongNumber()
    if  mRoomData.RoomState<=ROOM_STATE_MJ.READY then
        mMahJongText.text="0"
    elseif mRoomData.RoomState==ROOM_STATE_MJ.RANDOM then
        mMahJongText.text="108"
    elseif mRoomData.RoomState>=ROOM_STATE_MJ.DEAL then
        mMahJongText.text=tostring(mRoomData.CardsSurplusNumber)
    end
end

-- 等待开始阶段隐藏桌面麻将
function mjIsShow()
    for count=1,4,1 do
        for index=1,27,1 do
            this.transform:Find('Canvas/PlayerCardPosition/player'..count..'/Viewpot/Content/MaJong'..index).gameObject:SetActive(false)
        end
    end
    for count=1,4,1 do
        for index=1,14,1 do
            this.transform:Find('Canvas/Card/Player'..count..'/Mahjong'..index).gameObject:SetActive(false)
        end
    end
end
--麻将显示
function mMJShow()
    for mIIdex=1,14,1 do
        local position_x = player4CardPosition[mIIdex].X
        local position_y = player4CardPosition[mIIdex].Y
        local TweenOBJ= mMyHaveMahjong[mIIdex].transform:GetComponent("TweenPosition")
        --TweenOBJ.enabled=true
        TweenOBJ:ResetToBeginning()
        TweenOBJ.from=CS.UnityEngine.Vector3(position_x,position_y,0)
        TweenOBJ.to = CS.UnityEngine.Vector3(position_x,position_y,0)
        TweenOBJ.duration=0.00001
        TweenOBJ:Play(true)
        mMyHaveMahjong[mIIdex].transform.localPosition=CS.UnityEngine.Vector3(position_x,position_y,0)
        if mIIdex<=#mRoomData.MJPlayerList[4].Pokers then
            mMyHaveMahjong[mIIdex]:SetActive(true)
            local PokerType = mRoomData.MJPlayerList[4].Pokers[mIIdex].PokerType
            local PokerNumber = mRoomData.MJPlayerList[4].Pokers[mIIdex].PokerNumber
            mMyHaveMahjong[mIIdex].transform:Find("Image"):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(PokerType,PokerNumber))
        else
            mMyHaveMahjong[mIIdex]:SetActive(false)
        end
    end
    for count1 = 1,4,1 do
        if mRoomData.MJPlayerList[count1].PokerNumber ~= 0 and mRoomData.MJPlayerList[count1].PokerNumber ~= nil then
            for index1=mRoomData.MJPlayerList[count1].PokerNumber,14,1 do
                this.transform:Find('Canvas/Card/Player'..count1..'/Mahjong'..index1).gameObject:SetActive(false)
            end
        end
    end
    for index=1,mRoomData.MJPlayerList[4].PokerNumber,1 do
        this.transform:Find('Canvas/Card/Player4/Mahjong'..index).gameObject:SetActive(true)
        local PokerType = mRoomData.MJPlayerList[4].Pokers[index].PokerType
        local PokerNumber = mRoomData.MJPlayerList[4].Pokers[index].PokerNumber
        this.transform:Find('Canvas/Card/Player4/Mahjong'..index..'/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(PokerType,PokerNumber))
        if PokerType == mRoomData.MJPlayerList[4].QueType then
            this.transform:Find('Canvas/Card/Player4/Mahjong'..index):GetComponent("Image").color=CS.UnityEngine.Color.grey
        else
            if mRoomData.MJPlayerList[4].PlayerState >= PlayerStateEnumMJ.HU then
                this.transform:Find('Canvas/Card/Player4/Mahjong'..index):GetComponent("Image").color=CS.UnityEngine.Color.grey
            else
                this.transform:Find('Canvas/Card/Player4/Mahjong'..index):GetComponent("Image").color=CS.UnityEngine.Color.white
            end
        end
    end
    if mRoomData.MJPlayerList[4].onlyPokerNumber == 1 then
        local onlyCard=this.transform:Find('Canvas/Card/Player4/Mahjong14').gameObject
        local handCard=this.transform:Find('Canvas/Card/Player4/Mahjong'..mRoomData.MJPlayerList[4].PokerNumber).gameObject
        --local xl = handCard:GetComponent("RectTransform").sizeDelta.x
        --xl=xl*1.5
        local POSITION_X=handCard.transform.localPosition.x+185
        local POSITION_Y=-454
        onlyCard.transform.localPosition=CS.UnityEngine.Vector3(POSITION_X,POSITION_Y,0)
        onlyCard:SetActive(true)
        local PokerType = mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType
        local PokerNumber = mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber
        this.transform:Find('Canvas/Card/Player4/Mahjong14/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(PokerType,PokerNumber))
        if PokerType == mRoomData.MJPlayerList[4].QueType then
            this.transform:Find('Canvas/Card/Player4/Mahjong14'):GetComponent("Image").color=CS.UnityEngine.Color.grey
        else
            this.transform:Find('Canvas/Card/Player4/Mahjong14'):GetComponent("Image").color=CS.UnityEngine.Color.white
        end
    else
        this.transform:Find('Canvas/Card/Player4/Mahjong14').gameObject:SetActive(false)
    end
    for index = 1,3,1 do
        if mRoomData.MJPlayerList[index].PokerNumber ~= nil then
            local number=mRoomData.MJPlayerList[index].PokerNumber
            for count = 1,number,1 do
                this.transform:Find('Canvas/Card/Player'..index..'/Mahjong'..count).gameObject:SetActive(true)
            end
        end
        if mRoomData.MJPlayerList[index].onlyPokerNumber == 1 then
            if index == 2 then
                local onlyCard=this.transform:Find('Canvas/Card/Player'..index..'/Mahjong14').gameObject
                local handCard=this.transform:Find('Canvas/Card/Player'..index..'/Mahjong'..mRoomData.MJPlayerList[index].PokerNumber).gameObject
                local POSITION_X=handCard.transform.localPosition.x-80
                local POSITION_Y=handCard.transform.localPosition.y
                onlyCard.transform.localPosition=CS.UnityEngine.Vector3(POSITION_X,POSITION_Y,0)
                onlyCard:SetActive(true)
            elseif index == 1 then
                local onlyCard=this.transform:Find('Canvas/Card/Player'..index..'/Mahjong14').gameObject
                local handCard=this.transform:Find('Canvas/Card/Player'..index..'/Mahjong'..mRoomData.MJPlayerList[index].PokerNumber).gameObject
                local POSITION_X=handCard.transform.localPosition.x-23.4
                local POSITION_Y=handCard.transform.localPosition.y+72.8
                onlyCard.transform.localPosition=CS.UnityEngine.Vector3(POSITION_X,POSITION_Y,0)
                onlyCard:SetActive(true)
            elseif index == 3 then
                local onlyCard=this.transform:Find('Canvas/Card/Player'..index..'/Mahjong14').gameObject
                local handCard=this.transform:Find('Canvas/Card/Player'..index..'/Mahjong'..mRoomData.MJPlayerList[index].PokerNumber).gameObject
                local yl = handCard:GetComponent("RectTransform").sizeDelta.y
                local POSITION_X=handCard.transform.localPosition.x-29.7
                local POSITION_Y=handCard.transform.localPosition.y-95.3
                onlyCard.transform.localPosition=CS.UnityEngine.Vector3(POSITION_X,POSITION_Y,0)
                onlyCard:SetActive(true)
            end
        else
            this.transform:Find('Canvas/Card/Player'..index..'/Mahjong14').gameObject:SetActive(false)
        end
    end
end

-- 准备按钮是否显示
function ZBButtonISShow(mShow)
    if mShow then
        if mRoomData:PlayerCount() >3 then
            mZBButtonGameObject:SetActive(true)
            if mRoomData.MJPlayerList[4].PlayerState >= PlayerStateEnumMJ.Ready then
                mZBButtonGameObject:SetActive(false)
            else
                if mRoomData.BoardMaxNumber == mRoomData.BoardCurrentNumber then
                    mZBButtonGameObject:SetActive(false)
                end
            end
        else
            mZBButtonGameObject:SetActive(false)
        end
    else
        mZBButtonGameObject:SetActive(mShow)
    end
    
end

-- 准备图标显示
function ZBImageIsShow(mPosition,mShow)
    if mPosition == 4 then
        ZBButtonISShow(false)
    end
    if mPosition ~=5 then
        mPlayerUINodes[mPosition].ZBImage:SetActive(true)
    else
        for index = 1,4,1 do
            mPlayerUINodes[index].ZBImage:SetActive(false)
        end
    end
end

-- 定缺图标显示
function DingQueImage(mShow)
    this.transform:Find('Canvas/DingQue').gameObject:SetActive(mShow)
    
    if mShow then
        for Index=1,3,1 do
            this.transform:Find('Canvas/DingQue/Image'..Index..'/Image').gameObject:SetActive(false)
        end
        local tCardType={}
        for Index=1,#mRoomData.MJPlayerList[4].Pokers,1 do
            tCardType[Index]=mRoomData.MJPlayerList[4].Pokers[Index]
        end
        if #mRoomData.MJPlayerList[4].OnlyPokers==1 then
            table.insert( tCardType, mRoomData.MJPlayerList[4].OnlyPokers[1] )
        end
        local tQue = RandomQue(tCardType)
        this.transform:Find('Canvas/DingQue/Image'..tQue..'/Image').gameObject:SetActive(true)
    end
end

-- 玩家定缺动画
function PlayerDingQueAnimtion(position)
    if position == 4 then
        local DQ=this.transform:Find('Canvas/DingQueDongHua/Player4').gameObject
        local mTweenPosition = DQ.transform:GetComponent('TweenPosition')
        for Inde=1,3,1 do
            DQ.transform:Find("Image"..Inde).gameObject:SetActive(false)
        end
        DQ:SetActive(true)
        DQ.transform:Find("Image"..mRoomData.MJPlayerList[position].QueType).gameObject:SetActive(true)
        mTweenPosition:ResetToBeginning()
        mTweenPosition.duration=0.3
        mTweenPosition:Play(true)
        
        this:DelayInvoke(0.3,function ()
            DQ:SetActive(false)
            this.transform:Find('Canvas/Players/Player4/DingZhuang/'..mRoomData.MJPlayerList[4].QueType).gameObject:SetActive(true)
        end)
    else
        for Index=1,3,1 do
            if mRoomData.MJPlayerList[Index]~=nil then
                if mRoomData.MJPlayerList[Index].QueType~=nil then
                    local DQ=this.transform:Find('Canvas/DingQueDongHua/Player'..Index).gameObject
                    DQ:SetActive(true)
                    for Inde=1,3,1 do
                        DQ.transform:Find("Image"..Inde).gameObject:SetActive(false)
                    end
                    DQ.transform:Find("Image"..mRoomData.MJPlayerList[Index].QueType).gameObject:SetActive(true)
                    local mTweenScale = DQ.transform:GetComponent('TweenScale')
                    local mTweenPosition = DQ.transform:GetComponent('TweenPosition')
                    mTweenPosition.enabled=false
                    mTweenScale:ResetToBeginning()
                    mTweenScale.duration=0.1
                    mTweenScale:Play(true)
                    this:DelayInvoke(0.6,function ()
                    mTweenPosition.enabled=true
                    mTweenPosition.duration=0.2
                    mTweenPosition:Play(true)
                    mTweenScale:ResetToBeginning()
                    mTweenScale.duration=0.2
                    mTweenScale:Play(false)
                    end)
                    this:DelayInvoke(0.8,function ()
                        DQ:SetActive(false)
                        this.transform:Find('Canvas/Players/Player'..Index..'/DingZhuang/'..mRoomData.MJPlayerList[Index].QueType).gameObject:SetActive(true)
                    end)
                end
            end
        end
    end
end

-- 东西南北位置
function DXNBposition()
    if mRoomData.BankerPosition == 1 then
        playerBanker1=1;  playerBanker3=2;  playerBanker2=3;  playerBanker4=4
    elseif mRoomData.BankerPosition == 2 then
        playerBanker1=4;  playerBanker3=3;  playerBanker2=1;  playerBanker4=2
    elseif mRoomData.BankerPosition == 3 then
        playerBanker1=2;  playerBanker3=1;  playerBanker2=4;  playerBanker4=3
    elseif mRoomData.BankerPosition == 4 then
        playerBanker1=3;  playerBanker3=4;  playerBanker2=2;  playerBanker4=1
    end
end

-- 倒计时显示
function ConutDownDisplay(mShow)
    if mShow then
        DXNBposition()
        mCountDownGameObject:SetActive(mShow)
        local index=1
        if mRoomData.PlardCardPosition == 1 then
            index =playerBanker1
        elseif mRoomData.PlardCardPosition == 2 then
            index =playerBanker2
        elseif mRoomData.PlardCardPosition == 3 then
            index =playerBanker3
        elseif mRoomData.PlardCardPosition == 4 then
            index =playerBanker4
        end
        for count=1,4,1 do
            for index1=1,4,1 do
                mCountDownGameObject.transform:Find('position'..count..'/Image'..index1).gameObject:SetActive(false)
            end
        end
        if mRoomData.PlardCardPosition > 0 then
            mCountDownGameObject.transform:Find('position'..mRoomData.PlardCardPosition..'/Image'..index).gameObject:SetActive(true)
            local mCountTween=mCountDownGameObject.transform:Find('position'..mRoomData.PlardCardPosition..'/Image'..index):GetComponent("TweenScale")
            mCountTween:Play(true)
            mCountTween:ResetToBeginning()
        end
    else
        mCountDownGameObject:SetActive(mShow)
        for count=1,4,1 do
            for index1=1,4,1 do
                mMyTransform:Find('Canvas/CountDown/position'..count..'/Image_'..index1).gameObject:SetActive(false)
                mMyTransform:Find('Canvas/CountDown/position'..count..'/Image'..index1).gameObject:SetActive(false)
            end
        end
    end
end


-- 碰杠胡过请求
function PengGangHuGuoButtonOnClick(mtype,Mode,Bumber)
    if mtype == 5 and mHuPaiGameObject.activeInHierarchy == true then
        mRoomData.MJPlayerList[4].RaoPao = 0
    end
    if mtype == 5 and mPengPaiGameObject.activeInHierarchy == true then
        table.insert(mRoomData.MJPlayerList[4].GuoPengTable,{PokerType=mRoomData.WaitCardType,PokerNumber=mRoomData.WaitCardNumber} )
        mRoomData.MJPlayerList[4].GuoPeng=#mRoomData.MJPlayerList[4].GuoPengTable
    end
    NetMsgHandler.Send_CS_MJ_PengGangHu(mtype,Mode,Bumber)
end

-- 已出牌和点击牌一致提示
function OutCardClickCardSame(position,mShow)
    if mShow then
        for Index=1,4,1 do
            for Count=1,27,1 do
                this.transform:Find('Canvas/PlayerCardPosition/player'..Index..'/Viewpot/Content/MaJong'..Count):GetComponent("Image").color=CS.UnityEngine.Color.white
            end
            for PGH=1,#MJPLAYERPGLIST[Index],1 do
                if MJPLAYERPGLIST[Index][PGH].Mode == 1 then
                    local pos=MJGameMgr.MJpghPlayerPosition(Index,MJPLAYERPGLIST[Index][PGH].triggerPlayerPosition)
                    for Count=1,3,1 do
                        local PengCard = this.transform:Find('Canvas/GangPengPaiPosition/player'..Index..'/Scroll View/Viewport/Content/Copy_'..PGH..'/Image'..Count).gameObject
                        PengCard.transform:GetComponent("Image").color=CS.UnityEngine.Color.white
                    end
                elseif MJPLAYERPGLIST[Index][PGH].Mode == 2 then
                    if MJPLAYERPGLIST[Index][PGH].breed == 1 then
                        local pos=MJGameMgr.MJpghPlayerPosition(Index,MJPLAYERPGLIST[Index][PGH].triggerPlayerPosition)
                        local PengCard = this.transform:Find('Canvas/GangPengPaiPosition/player'..Index..'/Scroll View/Viewport/Content/Copy_'..PGH..'/Image').gameObject
                        PengCard.transform:GetComponent("Image").color=CS.UnityEngine.Color.white
                    else
                        local pos=MJGameMgr.MJpghPlayerPosition(Index,MJPLAYERPGLIST[Index][PGH].triggerPlayerPosition)
                        for Count=1,4,1 do
                            local PengCard = this.transform:Find('Canvas/GangPengPaiPosition/player'..Index..'/Scroll View/Viewport/Content/Copy_'..PGH..'/Image'..Count).gameObject
                            PengCard.transform:GetComponent("Image").color=CS.UnityEngine.Color.white
                        end
                    end
                end
            end
        end
        
        local CardType = nil
        local CardNumber = nil
        if position==14 then
            CardType = mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType
            CardNumber = mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber
        else
            CardType = mRoomData.MJPlayerList[4].Pokers[position].PokerType
            CardNumber = mRoomData.MJPlayerList[4].Pokers[position].PokerNumber
        end
        for Index=1,4,1 do
            for PGH=1,#MJPLAYERPGLIST[Index],1 do
                if MJPLAYERPGLIST[Index][PGH].PokerType==CardType and MJPLAYERPGLIST[Index][PGH].PokerNumber==CardNumber then
                    if MJPLAYERPGLIST[Index][PGH].Mode == 1 then
                        local pos=MJGameMgr.MJpghPlayerPosition(Index,MJPLAYERPGLIST[Index][PGH].triggerPlayerPosition)
                        for Count=1,3,1 do
                            local PengCard = this.transform:Find('Canvas/GangPengPaiPosition/player'..Index..'/Scroll View/Viewport/Content/Copy_'..PGH..'/Image'..Count).gameObject
                            PengCard.transform:GetComponent("Image").color=CS.UnityEngine.Color.grey
                        end
                    elseif MJPLAYERPGLIST[Index][PGH].Mode == 2 then
                        if MJPLAYERPGLIST[Index][PGH].breed == 1 then
                            local pos=MJGameMgr.MJpghPlayerPosition(Index,MJPLAYERPGLIST[Index][PGH].triggerPlayerPosition)
                            local PengCard = this.transform:Find('Canvas/GangPengPaiPosition/player'..Index..'/Scroll View/Viewport/Content/Copy_'..PGH..'/Image').gameObject
                            PengCard.transform:GetComponent("Image").color=CS.UnityEngine.Color.grey
                        else
                            local pos=MJGameMgr.MJpghPlayerPosition(Index,MJPLAYERPGLIST[Index][PGH].triggerPlayerPosition)
                            for Count=1,4,1 do
                                local PengCard = this.transform:Find('Canvas/GangPengPaiPosition/player'..Index..'/Scroll View/Viewport/Content/Copy_'..PGH..'/Image'..Count).gameObject
                                PengCard.transform:GetComponent("Image").color=CS.UnityEngine.Color.grey
                            end
                        end
                    end
                end
            end
            if mRoomData.MJPlayerList[Index]~=nil and mRoomData.MJPlayerList[Index].ChuPokers~=nil then
                local Num=#mRoomData.MJPlayerList[Index].ChuPokers
                if Num>27 then
                    Num=27
                end
                for Count=1,Num,1 do
                    if mRoomData.MJPlayerList[Index].ChuPokers[Count].PokerType==CardType and mRoomData.MJPlayerList[Index].ChuPokers[Count].PokerNumber == CardNumber then
                        this.transform:Find('Canvas/PlayerCardPosition/player'..Index..'/Viewpot/Content/MaJong'..Count):GetComponent("Image").color=CS.UnityEngine.Color.grey
                    end
                end
            end
        end
    else
        for Index=1,4,1 do
            for Count=1,27,1 do
                this.transform:Find('Canvas/PlayerCardPosition/player'..Index..'/Viewpot/Content/MaJong'..Count):GetComponent("Image").color=CS.UnityEngine.Color.white
            end
            for PGH=1,#MJPLAYERPGLIST[Index],1 do
                if MJPLAYERPGLIST[Index][PGH].Mode == 1 then
                    local pos=MJGameMgr.MJpghPlayerPosition(Index,MJPLAYERPGLIST[Index][PGH].triggerPlayerPosition)
                    for Count=1,3,1 do
                        local PengCard = this.transform:Find('Canvas/GangPengPaiPosition/player'..Index..'/Scroll View/Viewport/Content/Copy_'..PGH..'/Image'..Count).gameObject
                        PengCard.transform:GetComponent("Image").color=CS.UnityEngine.Color.white
                    end
                elseif MJPLAYERPGLIST[Index][PGH].Mode == 2 then
                    if MJPLAYERPGLIST[Index][PGH].breed == 1 then
                        local pos=MJGameMgr.MJpghPlayerPosition(Index,MJPLAYERPGLIST[Index][PGH].triggerPlayerPosition)
                        local PengCard = this.transform:Find('Canvas/GangPengPaiPosition/player'..Index..'/Scroll View/Viewport/Content/Copy_'..PGH..'/Image').gameObject
                        PengCard.transform:GetComponent("Image").color=CS.UnityEngine.Color.white
                    else
                        local pos=MJGameMgr.MJpghPlayerPosition(Index,MJPLAYERPGLIST[Index][PGH].triggerPlayerPosition)
                        for Count=1,4,1 do
                            local PengCard = this.transform:Find('Canvas/GangPengPaiPosition/player'..Index..'/Scroll View/Viewport/Content/Copy_'..PGH..'/Image'..Count).gameObject
                            PengCard.transform:GetComponent("Image").color=CS.UnityEngine.Color.white
                        end
                    end
                end
            end
        end
        
    end
end

-- 点击空白处手牌麻将回归原位
function KongBaiButtonOnClick()
    mCardMaskGameObject:SetActive(false)
    for Index=1,14,1 do
        local position_x=mMyHaveMahjong[Index].transform.localPosition.x
        local position_z=mMyHaveMahjong[Index].transform.localPosition.z
        mMyHaveMahjong[Index].transform.localPosition = CS.UnityEngine.Vector3(position_x,-454,position_z)
    end
    OutCardClickCardSame(0,false)
end

-- 点击手牌麻将
function MahjongInTheHand(index)

    if mMyHaveMahjong[index].transform.localPosition.y ~= -454 then
        if mRoomData.PlardCardPosition == 4 then
            if index ~=14 then
                GiveMahjong(mRoomData.MJPlayerList[4].Pokers[index].PokerType,mRoomData.MJPlayerList[4].Pokers[index].PokerNumber,index)
            else
                GiveMahjong(mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType,mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber,0)
            end
            mCardMaskGameObject:SetActive(false)
            --mTingPaiInterface:SetActive(false)
            --mTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3(630,-210,0)
            for Index=1,11,1 do
                if TingPosition[Index].transform:Find("TingInterface")~=nil then
                    local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
                    CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
                end
            end
        else
            local position_x=mMyHaveMahjong[index].transform.localPosition.x
            local position_z=mMyHaveMahjong[index].transform.localPosition.z
            mMyHaveMahjong[index].transform.localPosition = CS.UnityEngine.Vector3(position_x,-454,position_z)
        end
    else
        for i=1,14,1 do
            local position_x=mMyHaveMahjong[i].transform.localPosition.x
            local position_z=mMyHaveMahjong[i].transform.localPosition.z
            mMyHaveMahjong[i].transform.localPosition = CS.UnityEngine.Vector3(position_x,-454,position_z)
        end
        local position_x=mMyHaveMahjong[index].transform.localPosition.x
        local position_z=mMyHaveMahjong[index].transform.localPosition.z
        mMyHaveMahjong[index].transform.localPosition = CS.UnityEngine.Vector3(position_x,-405,position_z)
        mCardMaskGameObject:SetActive(true)
        OnClickTingCard(index,true)
        OutCardClickCardSame(index,true)

    end
end

-- 点击听牌
function OnClickTingCard(index,mShow)
    local tCard=clone(mRoomData.MJPlayerList[4].Pokers)
    local tTable={}
    if mXiaJiaoZhiShi[index].activeSelf==true and mShow then
        local print1 = mTingPaiInterface.transform:Find('BaiSeDi/HuangSeDi/GameObject/Convent').gameObject
        if print1.transform.childCount > 0 then
            local count=print1.transform.childCount
            for i=count,0,-1 do
                if print1.transform:Find("Ting"..i)~=nil then
                    local copy= print1.transform:Find("Ting"..i).gameObject
                    CS.UnityEngine.Object.Destroy (copy)
                end
            end
        end
        if index ~= 14 then
            table.remove( tCard, index )
            if #mRoomData.MJPlayerList[4].OnlyPokers==1 then
                table.insert( tCard, mRoomData.MJPlayerList[4].OnlyPokers[1] )
            end
        end
        local GnagTable={}
        local PengTable={}
        for Index=1,#MJPLAYERPGLIST[4],1 do
            if MJPLAYERPGLIST[4][Index].Mode == 1 then
                table.insert( PengTable, MJPLAYERPGLIST[4][Index])
            elseif MJPLAYERPGLIST[4].Mode == 2 then
                table.insert( GnagTable, MJPLAYERPGLIST[4][Index])
            end
        end
        tTable=CheckTingPaiMaybeType(tCard,PengTable,GnagTable,mRoomData.MJPlayerList[4].QueType)
        for Index=1,11,1 do
            if TingPosition[Index].transform:Find("TingInterface")~=nil then
                local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
                CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
            end
        end
        local mCopyTingPaiInterface = CS.UnityEngine.Object.Instantiate(mTingPaiInterface)
        if #tTable <=5 then
            --mTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3(0,-210,0)
            mCopyTingPaiInterface.transform.parent=TingPosition[10].transform
        else
            --mTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3(0,-140,0)
            mCopyTingPaiInterface.transform.parent=TingPosition[11].transform
        end
        mCopyTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3.zero
        mCopyTingPaiInterface.transform.localScale=CS.UnityEngine.Vector3.one
        mCopyTingPaiInterface.transform.name="TingInterface"
        mCopyTingPaiInterface:SetActive(true)
        --mTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3(TingInterface_Position_X1[#tTable],TingInterface_Position_Y1[#tTable],0)
        mCopyTingPaiInterface.transform:GetComponent("RectTransform").sizeDelta = CS.UnityEngine.Vector2(TingInterface_Scale_X1[#tTable],TingInterface_Scale_Y1[#tTable])
        local TingInfo= mCopyTingPaiInterface.transform:Find('BaiSeDi/HuangSeDi/GameObject/Template').gameObject
        local TingInfoPrint = mCopyTingPaiInterface.transform:Find('BaiSeDi/HuangSeDi/GameObject/Convent').gameObject
        mCopyTingPaiInterface.transform:Find("Close"):GetComponent("Button").onClick:AddListener(function() TingPaiButtonOnClick(false) end)
        for Index=1,#tTable,1 do
            local CopyObject = CS.UnityEngine.Object.Instantiate(TingInfo)
            CopyObject.transform.parent=TingInfoPrint.transform
            CopyObject.transform.localPosition=CS.UnityEngine.Vector3.zero
            CopyObject.transform.localScale=CS.UnityEngine.Vector3.one
            CopyObject.transform.name="Ting"..Index
            CopyObject:SetActive(true)
            CopyObject.transform:Find('MahJong/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(tTable[Index][1],tTable[Index][2]))
            CopyObject.transform:Find('LV'):GetComponent("Text").text=""..tHuBeiShu[tTable[Index][3]].."倍"
            local Surplus=ACardHowManyPiecesAreLeft(tTable[Index][1],tTable[Index][2])
            CopyObject.transform:Find('Num'):GetComponent("Text").text=""..Surplus.."张"
            if Surplus == 0 then
                CopyObject.transform:Find('MahJong'):GetComponent("Image").color=CS.UnityEngine.Color.grey
            end
        end
    else
        --mTingPaiInterface:SetActive(false)
        --mTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3(630,-210,0)
        for Index=1,11,1 do
            if TingPosition[Index].transform:Find("TingInterface")~=nil then
                local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
                CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
            end
        end
        
    end
end

-- 检测一张牌还剩多少张没出
function ACardHowManyPiecesAreLeft(tTableType,tTableNumber)
    local CardType=nil
    local CardNumber=nil
    local PengTable={}
    local GangTable={}
    local Count=4
    CardType=tTableType
    CardNumber=tTableNumber
    for PLAYER=1,4,1 do
        for PGH=1,#MJPLAYERPGLIST[PLAYER],1 do
            if MJPLAYERPGLIST[PLAYER][PGH].Mode == 1 then
                table.insert( PengTable, MJPLAYERPGLIST[PLAYER][PGH])
            elseif MJPLAYERPGLIST[PLAYER][PGH].Mode == 2 then
                table.insert( GangTable, MJPLAYERPGLIST[PLAYER][PGH])
            end
        end
    end
    for Player=1,4,1 do
        if mRoomData.MJPlayerList[Player]~=nil then
            if mRoomData.MJPlayerList[4].PlayerState == PlayerStateEnumMJ.HU then
                if mRoomData.MJPlayerList[Player].IsYPDX ~= 1 then
                    if mRoomData.MJPlayerList[Player].HUtype ==CardType and mRoomData.MJPlayerList[Player].HUnumber ==CardNumber then
                        Count=Count-1
                        if Count <= 0 then
                            Count=0
                            return Count
                        end
                    end
                end
            end
        end
        if mRoomData.MJPlayerList[Player].ChuPokers~=nil then
            for Chu=1,#mRoomData.MJPlayerList[Player].ChuPokers,1 do
                if mRoomData.MJPlayerList[Player].ChuPokers[Chu].PokerType==CardType and mRoomData.MJPlayerList[Player].ChuPokers[Chu].PokerNumber ==CardNumber then
                    Count=Count-1
                    if Count <= 0 then
                        Count=0
                        return Count
                    end
                end
            end
        end
    end
    for Peng=1,#PengTable,1 do
        if PengTable[Peng].PokerType==CardType and PengTable[Peng].PokerNumber==CardNumber then
            Count=Count-3
            if Count <= 0 then
                Count=0
                return Count
            end
        end
    end
    for Gang=1,#GangTable,1 do
        if GangTable[Gang].PokerType==CardType and GangTable[Gang].PokerNumber==CardNumber then
            Count=Count-4
            if Count <= 0 then
                Count=0
                return Count
            end
        end
    end
    for HandCardNum=1,#mRoomData.MJPlayerList[4].Pokers,1 do
        if mRoomData.MJPlayerList[4].Pokers[HandCardNum].PokerType==CardType and mRoomData.MJPlayerList[4].Pokers[HandCardNum].PokerNumber==CardNumber then
            Count=Count-1
            if Count <= 0 then
                Count=0
                return Count
            end
        end
    end
    if #mRoomData.MJPlayerList[4].OnlyPokers==1 then
        if mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType==CardType and mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber==CardNumber then
            Count=Count-1
            if Count <= 0 then
                Count=0
                return Count
            end
        end
    end
    return Count 
end

function WenZiDongHua1(GangImage,position)
    local GangImagePosition = mMyTransform:Find('Canvas/ReasonImage/position'..position).gameObject
    local CopyObject = CS.UnityEngine.Object.Instantiate(GangImage)
    CopyObject.transform.parent=GangImagePosition.transform
    CopyObject.transform.localPosition=CS.UnityEngine.Vector3.zero
    CopyObject.transform.localScale=CS.UnityEngine.Vector3.one
    CopyObject.transform.name="1"
    local TweenObject = CopyObject.transform:GetComponent("TweenScale")
    CopyObject:SetActive(true)
    TweenObject:ResetToBeginning()
    TweenObject:Play(true)
    this:DelayInvoke(1,function ()
        CS.UnityEngine.Object.Destroy(CopyObject)
    end)
end

function WenZiDongHua(GangImage,position)
    local GangImagePosition = mMyTransform:Find('Canvas/ReasonImage/position'..position).gameObject
    local CopyObject = CS.UnityEngine.Object.Instantiate(GangImage)
    CopyObject.transform.parent=GangImagePosition.transform
    CopyObject.transform.localPosition=CS.UnityEngine.Vector3.zero
    CopyObject.transform.localScale=CS.UnityEngine.Vector3.one
    local GangImage1=CopyObject.transform:Find("Image1").gameObject
    local GangImage2=CopyObject.transform:Find("Image2").gameObject
    local GangImage3=CopyObject.transform:Find("Image3").gameObject
    local TweenObject = CopyObject.transform:GetComponent("TweenScale")
    CopyObject:SetActive(true)
    TweenObject:ResetToBeginning()
    TweenObject.duration=1
    TweenObject:Play(true)
    this:DelayInvoke(0,function ()
        GangImage1:SetActive(true)
    end)
    this:DelayInvoke(0.3,function ()
        GangImage2:SetActive(true)
        GangImage1:SetActive(false)
    end)
    this:DelayInvoke(0.6,function ()
        GangImage2:SetActive(false)
        GangImage3:SetActive(true)
        
    end)
    this:DelayInvoke(1,function ()
        CS.UnityEngine.Object.Destroy(CopyObject)
    end)
end

-- 花猪
function HuaZhu(position)
    local GangImage = mMyTransform:Find('Canvas/ReasonImage/HuaZhu').gameObject
    local GangImagePosition = mMyTransform:Find('Canvas/ReasonImage/position'..position).gameObject
    local CopyObject = CS.UnityEngine.Object.Instantiate(GangImage)
    CopyObject.transform.parent=GangImagePosition.transform
    CopyObject.transform.localPosition=CS.UnityEngine.Vector3.zero
    CopyObject.transform.localScale=CS.UnityEngine.Vector3.one
    CopyObject.transform.name="1"
    local TweenObject = CopyObject.transform:GetComponent('TweenPosition')
    CopyObject:SetActive(true)
    TweenObject:ResetToBeginning()
    TweenObject.duration=0.5
    TweenObject:Play(true)
    this:DelayInvoke(2,function()
        CS.UnityEngine.Object.Destroy(CopyObject)
    end)
    local MJGoldList = {}
    for Index=1,#mRoomData.MJHuaZhuGoldList,1 do
        MJGoldList[Index]=mRoomData.MJHuaZhuGoldList[Index]
    end
    local UPGoldPlayerNumber = mRoomData.HUAZHUNUMBER
    GoldAddReduceAnimtion(MJGoldList,UPGoldPlayerNumber,1.5)
end

function ChaJiao(position)
    local GangImage = mMyTransform:Find('Canvas/ReasonImage/ChaJiao').gameObject
    local GangImagePosition = mMyTransform:Find('Canvas/ReasonImage/position'..position).gameObject
    local CopyObject = CS.UnityEngine.Object.Instantiate(GangImage)
    CopyObject.transform.parent=GangImagePosition.transform
    CopyObject.transform.localPosition=CS.UnityEngine.Vector3.zero
    CopyObject.transform.localScale=CS.UnityEngine.Vector3.one
    CopyObject.transform.name="1"
    local TweenObject = CopyObject.transform:GetComponent('TweenPosition')
    CopyObject:SetActive(true)
    TweenObject:ResetToBeginning()
    TweenObject.duration=0.5
    TweenObject:Play(true)
    this:DelayInvoke(2,function()
        CS.UnityEngine.Object.Destroy(CopyObject)
    end)
    local MJGoldList = {}
    for Index=1,#mRoomData.MJChaJiaoGoldList,1 do
        MJGoldList[Index]=mRoomData.MJChaJiaoGoldList[Index]
    end
    local UPGoldPlayerNumber = mRoomData.CHAJIAONUMBER
    GoldAddReduceAnimtion(MJGoldList,UPGoldPlayerNumber,1.5)
    
end

function TuiShui(position)
    local GangImage = mMyTransform:Find('Canvas/ReasonImage/TuiShui').gameObject
    local GangImagePosition = mMyTransform:Find('Canvas/ReasonImage/position'..position).gameObject
    local CopyObject = CS.UnityEngine.Object.Instantiate(GangImage)
    CopyObject.transform.parent=GangImagePosition.transform
    CopyObject.transform.localPosition=CS.UnityEngine.Vector3.zero
    CopyObject.transform.localScale=CS.UnityEngine.Vector3.one
    CopyObject.transform.name="1"
    local TweenObject = CopyObject.transform:GetComponent('TweenPosition')
    CopyObject:SetActive(true)
    TweenObject:ResetToBeginning()
    TweenObject.duration=0.5
    TweenObject:Play(true)
    this:DelayInvoke(2,function()
        CS.UnityEngine.Object.Destroy(CopyObject)
    end)
    local MJGoldList = {}
    for Index=1,#mRoomData.MJTuiShuiGoldList,1 do
        MJGoldList[Index]=mRoomData.MJTuiShuiGoldList[Index]
    end
    local UPGoldPlayerNumber = mRoomData.TUISHUINUMBER
    GoldAddReduceAnimtion(MJGoldList,UPGoldPlayerNumber,1.5)
end

-- 金币加减动画
function GoldAddReduceAnimtion(MJGoldList,UPGoldPlayerNumber,CloseTime)
    for positionParam=1,UPGoldPlayerNumber,1 do
        local position=MJGoldList[positionParam].position
        local updateGold = MJGoldList[positionParam].Gold
        if updateGold >= 0 then
            mPlayerUINodes[position].WinText.text = '+' .. lua_CommaSeperate(updateGold)
            local tweenposition = mPlayerUINodes[position].WinText.transform:GetComponent('TweenPosition')
            tweenposition:ResetToBeginning()
            tweenposition:Play(true)
            local tweenalpha = mPlayerUINodes[position].WinText.transform:GetComponent('TweenAlpha')
            tweenalpha:ResetToBeginning()
            tweenalpha:Play(true)
        elseif updateGold < 0 then
            mPlayerUINodes[position].LoseText.text = lua_CommaSeperate(updateGold)
            local tweenposition = mPlayerUINodes[position].LoseText.transform:GetComponent('TweenPosition')
            tweenposition:ResetToBeginning()
            tweenposition:Play(true)
            local tweenalpha = mPlayerUINodes[position].LoseText.transform:GetComponent('TweenAlpha')
            tweenalpha:ResetToBeginning()
            tweenalpha:Play(true)
        end
        local showObj = mPlayerUINodes[position]
        local showData = mRoomData.MJPlayerList[position]
        showObj.GoldText.text = lua_NumberToStyle1String(showData.Gold)
    end

    this:DelayInvoke(CloseTime,function()
        ResetMJWinGold()
    end)
end

-- 胡字动画
function HuDongHua(Position)
    local HuObject = this.transform:Find("Canvas/Players/Player"..Position.."/HUImage").gameObject
    local TweenObject = HuObject.transform:GetComponent("TweenPosition")
    HuObject:SetActive(true)
    TweenObject.enabled=true
    TweenObject:ResetToBeginning()
    TweenObject:Play(true)
    this:DelayInvoke(0.5,function ()
        TweenObject.enabled=false
    end)
end

-- 玩家更新金币
function UpdateGoldNumber()
    --(点炮胡 自摸 将对 门清 抢杠胡 都只显示胡)
    --(点杠 暗杠 补杠 都只显示杠)
    --（花猪查叫退税）
    --金币改变原因(1 开局 2点杠 3暗杠 4补杠 5点炮胡 6自摸 7将对 8门清 9杠上花 10杠上炮 11海底捞 12海底炮 13抢杠胡 14一炮多响 15花猪 16查叫 17退税)
    local GangImage=nil
    local GangImagePosition=nil
    local CopyObject=nil
    local MJGoldList = {}
    for Index=1,#mRoomData.MJGoldList,1 do
        MJGoldList[Index]=mRoomData.MJGoldList[Index]
    end
    local UPGoldPlayerNumber = mRoomData.UPGoldPlayerNumber
    if mRoomData.GoldChangetReason == 1 then
        --GoldAddReduceAnimtion(MJGoldList,UPGoldPlayerNumber,2)
        mPromptGameObject3:SetActive(true)
        local Gold1 = lua_NumberToStyle1String(mRoomData.MJGoldList[1].Gold)
        local Gold2 =string.sub(Gold1, 2, -1)
        mPromptGameObject3.transform:Find("Image/Text"):GetComponent("Text").text="本局扣除手续费<color=#00ffffff>"..Gold2.."</color>金币"
        this:DelayInvoke(2,function ()
            mPromptGameObject3:SetActive(false)
        end)
        return
    elseif mRoomData.GoldChangetReason == 6 then
        GangImage = mMyTransform:Find('Canvas/ReasonImage/ZiMo1').gameObject
        WenZiDongHua1(GangImage,mRoomData.pengganghuPosition)
        
        this:DelayInvoke(1,function  ()
            HuDongHua(mRoomData.pengganghuPosition)
        end)
    elseif mRoomData.GoldChangetReason == 2 or mRoomData.GoldChangetReason == 3 or mRoomData.GoldChangetReason == 4 then
        GangImage = mMyTransform:Find('Canvas/ReasonImage/Gang1').gameObject
        WenZiDongHua1(GangImage,mRoomData.pengganghuPosition)
    elseif mRoomData.GoldChangetReason == 5 or mRoomData.GoldChangetReason == 7 or mRoomData.GoldChangetReason == 8 or mRoomData.GoldChangetReason == 13 then
        GangImage = mMyTransform:Find('Canvas/ReasonImage/HU1').gameObject
        WenZiDongHua1(GangImage,mRoomData.pengganghuPosition)
        this:DelayInvoke(1,function  ()
            HuDongHua(mRoomData.pengganghuPosition)
        end)
    elseif mRoomData.GoldChangetReason == 9 then
        GangImage = mMyTransform:Find('Canvas/ReasonImage/GangShangHua1').gameObject
        WenZiDongHua1(GangImage,mRoomData.pengganghuPosition)
        this:DelayInvoke(1,function  ()
            HuDongHua(mRoomData.pengganghuPosition)
        end)
    elseif mRoomData.GoldChangetReason == 10 then
        GangImage = mMyTransform:Find('Canvas/ReasonImage/GangShangPao1').gameObject
        WenZiDongHua1(GangImage,mRoomData.pengganghuPosition)
        this:DelayInvoke(1,function  ()
            HuDongHua(mRoomData.pengganghuPosition)
        end)
    elseif mRoomData.GoldChangetReason == 11 then
        GangImage = mMyTransform:Find('Canvas/ReasonImage/HaiDiLaoYue1').gameObject
        WenZiDongHua1(GangImage,mRoomData.pengganghuPosition)
        this:DelayInvoke(1,function  ()
            HuDongHua(mRoomData.pengganghuPosition)
        end)
    elseif mRoomData.GoldChangetReason == 12 then
        GangImage = mMyTransform:Find('Canvas/ReasonImage/HaiDiLaoPao1').gameObject
        WenZiDongHua1(GangImage,mRoomData.pengganghuPosition)
        this:DelayInvoke(1,function  ()
            HuDongHua(mRoomData.pengganghuPosition)
        end)
    elseif mRoomData.GoldChangetReason == 14 then
        GangImage = mMyTransform:Find('Canvas/ReasonImage/YiPaoDuoXiang1').gameObject
        WenZiDongHua1(GangImage,mRoomData.pengganghuPosition)
        this:DelayInvoke(1,function  ()
            for Index=1,mRoomData.UPGoldPlayerNumber,1 do
                if mRoomData.MJGoldList[Index].Gold > 0 then
                    HuDongHua(mRoomData.MJGoldList[Index].position)
                end
            end
        end)
        for positionParam=1,4,1 do
            if mRoomData.MJPlayerList[positionParam].PlayerState > PlayerStateEnumMJ.NULL then
                if mRoomData.MJPlayerList[positionParam].PlayerState == PlayerStateEnumMJ.HU then
                    local YPDX =mRoomData.MJPlayerList[positionParam].IsYPDX
                    if YPDX == 1 then
                        this.transform:Find("Canvas/HuCardPostion/player"..positionParam):GetComponent("Image").color=CS.UnityEngine.Color(255, 255, 255, 0.5)
                    end
                end
            end
        end
    end
    --print("更新金币原因",mRoomData.GoldChangetReason)
    GoldAddReduceAnimtion(MJGoldList,UPGoldPlayerNumber,1.5)
end

-- 重置玩家输赢金币值
function ResetMJWinGold()
    for position = 1, 4, 1 do
        mPlayerUINodes[position].WinText.text = ''
        mPlayerUINodes[position].LoseText.text = ''
    end
end

-- 请求出牌
function GiveMahjong(cardType,cardNumber,index)
    NetMsgHandler.Send_CS_MJ_PlayerChuPai(cardType,cardNumber,index)
end

-- 有玩家出牌
function PlayerChuPai()
    
    local position=mRoomData.NowPlayerCPPosition
    local CPtype=mRoomData.NowPlayerCPType
    local number=mRoomData.NowPlayerCPNumber
    table.insert( mRoomData.MJPlayerList[position].ChuPokers, {PokerType=CPtype,PokerNumber=number} )
    mRoomData.MJPlayerList[position].yichupaishuliang=#mRoomData.MJPlayerList[position].ChuPokers
    mRoomData.LastOutCardPlayer=mRoomData.NowPlayerCPPosition
    if #mRoomData.MJPlayerList[position].ChuPokers <28 then
        local chupaitype=mRoomData.MJPlayerList[position].ChuPokers[#mRoomData.MJPlayerList[position].ChuPokers].PokerType
        local chupainumber=mRoomData.MJPlayerList[position].ChuPokers[#mRoomData.MJPlayerList[position].ChuPokers].PokerNumber
        this.transform:Find('Canvas/PlayerCardPosition/player'..position..'/Viewpot/Content/MaJong'..#mRoomData.MJPlayerList[position].ChuPokers).gameObject:SetActive(true)
        this.transform:Find('Canvas/PlayerCardPosition/player'..position..'/Viewpot/Content/MaJong'..#mRoomData.MJPlayerList[position].ChuPokers..'/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(chupaitype,chupainumber))
    end
    LastPlayerOutCardPosition()
    OutCardMusic(CPtype,number)
    if position ~= 4 then
        if mRoomData.MJPlayerList[position].onlyPokerNumber ~=0 then
            mRoomData.MJPlayerList[position].onlyPokerNumber=0
        else
            mRoomData.MJPlayerList[position].PokerNumber=mRoomData.MJPlayerList[position].PokerNumber-1
        end
        mMJShow()
    else
        GangPaiButtonDisplay(false)
        PengPaiButtonDisplay(false)
        HuPaiButtonDisplay(false)
        GuoButtonDisplay()
        OutCardClickCardSame(0,false)
        --mTingPaiInterface:SetActive(false)
        mPromptGameObject2:SetActive(false)
        mRoomData.MJPlayerList[4].IsPeng=1
        --mTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3(630,-210,0)
        for Index=1,11,1 do
            if TingPosition[Index].transform:Find("TingInterface")~=nil then
                local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
                CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
            end
        end
        local print1 = mTingPaiInterface.transform:Find('BaiSeDi/HuangSeDi/GameObject/Convent').gameObject
        if print1.transform.childCount > 0 then
            local count=print1.transform.childCount
            for i=count,0,-1 do
                if print1.transform:Find("Ting"..i)~=nil then
                    local copy= print1.transform:Find("Ting"..i).gameObject
                    CS.UnityEngine.Object.Destroy (copy)
                end
            end
        end
        for Index=1,14,1 do
            mXiaJiaoZhiShi[Index]:SetActive(false)
        end
        
        if mRoomData.NowPlayerCPCardPosition == 0 then
            mRoomData.MJPlayerList[4].onlyPokerNumber=0
            mRoomData.MJPlayerList[4].OnlyPokers={}
            this.transform:Find('Canvas/Card/Player4/Mahjong14').gameObject:SetActive(false)
            local position_x=mMyHaveMahjong[14].transform.localPosition.x
            local position_z=mMyHaveMahjong[14].transform.localPosition.z
            if mMyHaveMahjong[14].transform.localPosition.y~=-454 then
                mCardMaskGameObject:SetActive(false)
            end
            mMyHaveMahjong[14].transform.localPosition = CS.UnityEngine.Vector3(position_x,-454,position_z)
            local tCard=clone(mRoomData.MJPlayerList[4].Pokers)
            if CheckIsTingPai(tCard,mRoomData.MJPlayerList[4].QueType) == false then
                mTingButtonObject:SetActive(false)
                --mTingPaiInterface:SetActive(false)
                --mTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3(630,-210,0)
                for Index=1,11,1 do
                    if TingPosition[Index].transform:Find("TingInterface")~=nil then
                        local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
                        CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
                    end
                end
            else
                mTingButtonObject:SetActive(true)
            end
            

        else
            table.remove(mRoomData.MJPlayerList[4].Pokers,mRoomData.NowPlayerCPCardPosition)
            mRoomData.MJPlayerList[4].PokerNumber=#mRoomData.MJPlayerList[4].Pokers
            this.transform:Find('Canvas/Card/Player4/Mahjong'..mRoomData.NowPlayerCPCardPosition).gameObject:SetActive(false)
            local position_x=mMyHaveMahjong[mRoomData.NowPlayerCPCardPosition].transform.localPosition.x
            local position_z=mMyHaveMahjong[mRoomData.NowPlayerCPCardPosition].transform.localPosition.z
            if mMyHaveMahjong[mRoomData.NowPlayerCPCardPosition].transform.localPosition.y~=-454 then
                mCardMaskGameObject:SetActive(false)
            end
            mMyHaveMahjong[mRoomData.NowPlayerCPCardPosition].transform.localPosition = CS.UnityEngine.Vector3(position_x,-454,position_z)
            local tCard=clone(mRoomData.MJPlayerList[4].Pokers)
            if mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType~=nil and mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber ~= nil then
                table.insert( tCard, {PokerType=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType,PokerNumber=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber})
            end
            if CheckIsTingPai(tCard,mRoomData.MJPlayerList[4].QueType) == false then
                mTingButtonObject:SetActive(false)
                --mTingPaiInterface:SetActive(false)
                --mTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3(630,-210,0)
                for Index=1,11,1 do
                    if TingPosition[Index].transform:Find("TingInterface")~=nil then
                        local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
                        CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
                    end
                end
            elseif CheckIsTingPai(tCard,mRoomData.MJPlayerList[4].QueType) == true then
                mTingButtonObject:SetActive(true)
            end
        end
        PlayerChuPaiDongHua(mRoomData.NowPlayerCPCardPosition)
        
    end
    
end

--当玩家手上有单牌，但是出的是手牌时，单牌插入手排位置
function ChaPaiPosition(mPokerType,mPokerNumber)
    local Index = 0
    for mIIdex=1,#mRoomData.MJPlayerList[4].Pokers,1 do
        if mRoomData.MJPlayerList[4].Pokers[mIIdex].PokerType==mPokerType and mRoomData.MJPlayerList[4].Pokers[mIIdex].PokerNumber==mPokerNumber then
            Index=mIIdex
            return Index
        end
    end
    if Index == 0 then
        for mIIdex=#mRoomData.MJPlayerList[4].Pokers,1,-1 do
            if mRoomData.MJPlayerList[4].Pokers[mIIdex].PokerType==mPokerType then
                if mRoomData.MJPlayerList[4].Pokers[mIIdex].PokerNumber<mPokerNumber then
                    Index=mIIdex
                    return Index
                end
            end
        end
    end
end

-- 单牌移动动画
function DanPaiMoveDongHua(mChaPaiPosition)
    local fromPosition1_x=0
    local fromPosition1_y=0
    local toPosition1_x=0
    local toPosition1_y=0

    local fromPosition2_x=0
    local fromPosition2_y=0
    local toPosition2_x=0
    local toPosition2_y=0

    local fromPosition3_x=0
    local fromPosition3_y=0
    local toPosition3_x=0
    local toPosition3_y=0
    --print("----------------------插牌移动动画开始----------------------")
    this:DelayInvoke(0,function()
        --print("..............单牌抬起.................")
        toPosition1_x=mMyHaveMahjong[14].transform.localPosition.x
        toPosition1_y=-280
        fromPosition1_x=mMyHaveMahjong[14].transform.localPosition.x
        fromPosition1_y=mMyHaveMahjong[14].transform.localPosition.y

        local DanTween=mMyHaveMahjong[14].transform:GetComponent("TweenPosition")
        DanTween:ResetToBeginning()
        DanTween.from = CS.UnityEngine.Vector3(fromPosition1_x,fromPosition1_y,0)
        DanTween.to = CS.UnityEngine.Vector3(toPosition1_x,toPosition1_y,0)
        DanTween.duration=0.3
        DanTween:Play(true)
    end)
    this:DelayInvoke(0.35,function()
        --print("..............单牌移动.................")
        toPosition2_x=player4CardPosition[mChaPaiPosition].X
        toPosition2_y=mMyHaveMahjong[14].transform.localPosition.y
        fromPosition2_x=mMyHaveMahjong[14].transform.localPosition.x
        fromPosition2_y=mMyHaveMahjong[14].transform.localPosition.y
        local DanTween2= mMyHaveMahjong[14].transform:GetComponent("TweenPosition")
        DanTween2:ResetToBeginning()
        DanTween2.from = CS.UnityEngine.Vector3(fromPosition2_x,fromPosition2_y,0)
        DanTween2.to = CS.UnityEngine.Vector3(toPosition2_x,toPosition2_y,0)
        DanTween2.duration=0.3
        DanTween2:Play(true)
    end)
    this:DelayInvoke(0.7,function()
        --print("..............单牌落下.................")
        toPosition3_x=player4CardPosition[mChaPaiPosition].X
        toPosition3_y=player4CardPosition[mChaPaiPosition].Y
        fromPosition3_x=mMyHaveMahjong[14].transform.localPosition.x
        fromPosition3_y=mMyHaveMahjong[14].transform.localPosition.y
        local DanTween3= mMyHaveMahjong[14].transform:GetComponent("TweenPosition")
        DanTween3:ResetToBeginning()
        DanTween3.from = CS.UnityEngine.Vector3(fromPosition3_x,fromPosition3_y,0)
        DanTween3.to = CS.UnityEngine.Vector3(toPosition3_x,toPosition3_y,0)
        DanTween3.duration=0.3
        DanTween3:Play(true)
        --print("----------------------插牌移动动画结束----------------------")
    end)
    
end

-- 玩家出牌动画
function PlayerChuPaiDongHua(ChuPaiPosition)
    if ChuPaiPosition == 14 then
        return
    else
        if #mRoomData.MJPlayerList[4].OnlyPokers == 1 then
            table.insert(mRoomData.MJPlayerList[4].Pokers,mRoomData.MJPlayerList[4].OnlyPokers[1])
            table.sort(mRoomData.MJPlayerList[4].Pokers, MahjongSort1 )
            MaJongChuPaiSort()
            local mChaPaiPosition=ChaPaiPosition(mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType,mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber)
            mRoomData.MJPlayerList[4].onlyPokerNumber=0
            mRoomData.MJPlayerList[4].OnlyPokers={}
            local mCount=0
            --print("+++++++++++++++++++++++++++++++++++出牌位置，插排位置，手牌加单牌数量",ChuPaiPosition,mChaPaiPosition,#mRoomData.MJPlayerList[4].Pokers)
            if mChaPaiPosition==ChuPaiPosition then
                if mChaPaiPosition == #mRoomData.MJPlayerList[4].Pokers then
                    --print("插牌位置等于出排位置，并且插排位置为手牌最后一位11111111111111111111")
                    local TweenOBJ = mMyHaveMahjong[14].transform:GetComponent("TweenPosition")
                    local position_x=player4CardPosition[mChaPaiPosition].X
                    local position_y=player4CardPosition[mChaPaiPosition].Y
                    TweenOBJ:ResetToBeginning()
                    --print("==========================",mMyHaveMahjong[14].transform.localPosition.x,position_x)
                    TweenOBJ.from=CS.UnityEngine.Vector3(mMyHaveMahjong[14].transform.localPosition.x,player4CardPosition[mChaPaiPosition].Y,0)
                    TweenOBJ.to = CS.UnityEngine.Vector3(position_x,position_y,0)
                    TweenOBJ.duration=0.4
                    TweenOBJ:Play(true)
                    this:DelayInvoke(0.4,function()
                    mRoomData.MJPlayerList[4].PokerNumber=#mRoomData.MJPlayerList[4].Pokers
                    mMJShow()
                    end)
                else
                    --print("插牌位置等于出排位置")
                    -- 把单排移动到插排位置
                    DanPaiMoveDongHua(mChaPaiPosition)
                    this:DelayInvoke(1.05,function()
                    mRoomData.MJPlayerList[4].PokerNumber=#mRoomData.MJPlayerList[4].Pokers
                    
                    mMJShow()
                    end)
                end
            elseif mChaPaiPosition<ChuPaiPosition then
                --print("插排位置小于出牌位置")
                mCount=ChuPaiPosition-1
                local mCount1=mChaPaiPosition
                for mIndex=mCount1,mCount,1 do
                    --从出牌位置到插排位置的所有牌X轴往右移动
                    local mCounta=mIndex+1
                    local position_x=player4CardPosition[mCounta].X
                    local position_y=player4CardPosition[mCounta].Y
                    local TweenOBJ= mMyHaveMahjong[mIndex].transform:GetComponent("TweenPosition")
                    TweenOBJ:ResetToBeginning()
                    TweenOBJ.from=CS.UnityEngine.Vector3(mMyHaveMahjong[mIndex].transform.localPosition.x,mMyHaveMahjong[mIndex].transform.localPosition.y,0)
                    TweenOBJ.to = CS.UnityEngine.Vector3(position_x,position_y,0)
                    TweenOBJ.duration=0.2
                    TweenOBJ:Play(true)
                end
                this:DelayInvoke(0,function()
                    DanPaiMoveDongHua(mChaPaiPosition)
                end)
                this:DelayInvoke(1.1,function()
                    mRoomData.MJPlayerList[4].PokerNumber=#mRoomData.MJPlayerList[4].Pokers
                    mMJShow()
                end)
                -- 把单牌移动到插排位置
            elseif mChaPaiPosition>ChuPaiPosition then
                --print("插排位置大于出牌位置")
                mCount=ChuPaiPosition+1
                local mCount1=mChaPaiPosition
                for mIndex=mCount,mCount1,1 do
                    --从出牌位置到插排位置的所有牌X轴往左移动
                    local mCounta=mIndex-1
                    local position_x=player4CardPosition[mCounta].X
                    local position_y=player4CardPosition[mCounta].Y
                    local TweenOBJ= mMyHaveMahjong[mIndex].transform:GetComponent("TweenPosition")
                    TweenOBJ:ResetToBeginning()
                    TweenOBJ.from=CS.UnityEngine.Vector3(mMyHaveMahjong[mIndex].transform.localPosition.x,mMyHaveMahjong[mIndex].transform.localPosition.y,0)
                    TweenOBJ.to = CS.UnityEngine.Vector3(position_x,position_y,0)
                    TweenOBJ.duration=0.2
                    TweenOBJ:Play(true)
                end
                this:DelayInvoke(0,function()
                    DanPaiMoveDongHua(mChaPaiPosition)
                end)
                this:DelayInvoke(1.1,function()
                    mRoomData.MJPlayerList[4].PokerNumber=#mRoomData.MJPlayerList[4].Pokers
                    mMJShow()
                end)
            elseif mChaPaiPosition == #mRoomData.MJPlayerList[4].Pokers then
                --print("插排位置为手牌最后一位22222222222222222")
                local TweenOBJ = mMyHaveMahjong[14].transform:GetComponent("TweenPosition")
                local position_x=player4CardPosition[mChaPaiPosition].X
                local position_y=player4CardPosition[mChaPaiPosition].Y
                TweenOBJ:ResetToBeginning()
                --print("///////////////////////////",mMyHaveMahjong[14].transform.localPosition.x,position_x)
                TweenOBJ.from=CS.UnityEngine.Vector3(mMyHaveMahjong[14].transform.localPosition.x,player4CardPosition[mChaPaiPosition].Y,0)
                TweenOBJ.to = CS.UnityEngine.Vector3(position_x,position_y,0)
                TweenOBJ.duration=0.2
                TweenOBJ:Play(true)
                this:DelayInvoke(0.4,function()
                mRoomData.MJPlayerList[4].PokerNumber=#mRoomData.MJPlayerList[4].Pokers
                mMJShow()
                end)
            end
            
        end
    end
    
    
end

-- 上一玩家出牌位置指示
function LastPlayerOutCardPosition()
    if mRoomData.LastOutCardPlayer ~= 0 then
        local Count=#mRoomData.MJPlayerList[mRoomData.LastOutCardPlayer].ChuPokers
        local chips=nil
        if mRoomData.MJPlayerList[mRoomData.LastOutCardPlayer].PlayerState == PlayerStateEnumMJ.HU then
            chips=this.transform:Find('Canvas/HuCardPostion/player'..mRoomData.LastOutCardPlayer..'/Image').gameObject
        elseif Count<28 then
            chips=this.transform:Find('Canvas/PlayerCardPosition/player'..mRoomData.LastOutCardPlayer..'/Viewpot/Content/MaJong'..Count).gameObject
        elseif Count>27 then
            chips=this.transform:Find('Canvas/PlayerCardPosition/player'..mRoomData.LastOutCardPlayer..'/Viewpot/Content/MaJong27').gameObject
        end
        mZhiZhenGameObject.transform.parent=chips.transform
        mZhiZhenGameObject.transform.localPosition=CS.UnityEngine.Vector3(0,50,0)
        mZhiZhenGameObject.transform.localScale=CS.UnityEngine.Vector3(1,1,0)
        mZhiZhenGameObject:SetActive(true)
        local mZhiZhenTween = mZhiZhenGameObject.transform:GetComponent("TweenPosition")
        mZhiZhenTween:Play(true)
    else
        mZhiZhenGameObject:SetActive(false)
    end
end

--有玩家碰杠胡
function playerPengPai()
    if mRoomData.playerCaoZuo == 6 or mRoomData.pengganghuPosition == 4 then
        GangPaiButtonDisplay(false)
        PengPaiButtonDisplay(false)
        HuPaiButtonDisplay(false)
        GuoButtonDisplay()
    end
    local cztype =mRoomData.playerCaoZuo
    PGHMusic(cztype)
    if mRoomData.pengganghuPosition == 4 then
        OutCardClickCardSame(0,false)
    end
    if cztype == 2 then
        -- 碰牌
        mRoomData.LastOutCardPlayer=0
        PengPaiPaiZuDisplay()
        local count=0
        if mRoomData.pengganghuPosition == 4 then
            mRoomData.MJPlayerList[4].IsPeng=0
            for index=#mRoomData.MJPlayerList[4].Pokers,1,-1 do
                if mRoomData.MJPlayerList[4].Pokers[index].PokerType==mRoomData.pengganghuType and mRoomData.MJPlayerList[4].Pokers[index].PokerNumber==mRoomData.pengganghuNumber then
                    table.remove(mRoomData.MJPlayerList[4].Pokers,index)
                    this.transform:Find('Canvas/Card/Player4/Mahjong'..index).gameObject:SetActive(false)
                    count=count+1
                    if count == 2 then
                        break
                    end
                end
            end
            mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PokerNumber=mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PokerNumber-2
            table.sort(mRoomData.MJPlayerList[4].Pokers, MahjongSort1 )
            local changdu=#mRoomData.MJPlayerList[4].Pokers
            mRoomData.MJPlayerList[4].OnlyPokers={}
            table.insert(mRoomData.MJPlayerList[4].OnlyPokers, {PokerType=mRoomData.MJPlayerList[4].Pokers[changdu].PokerType, PokerNumber=mRoomData.MJPlayerList[4].Pokers[changdu].PokerNumber})
            mRoomData.MJPlayerList[4].onlyPokerNumber=#mRoomData.MJPlayerList[4].OnlyPokers
            table.remove( mRoomData.MJPlayerList[4].Pokers, changdu)
            mRoomData.MJPlayerList[4].PokerNumber=#mRoomData.MJPlayerList[4].Pokers
            MahJongDingQue(4)
            MaJongChuPaiSort()
            mRoomData.NowPlayerCPType=nil
            mRoomData.NowPlayerCPNumber=nil
        else
            mRoomData.NowPlayerCPType=nil
            mRoomData.NowPlayerCPNumber=nil
            mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PokerNumber=mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PokerNumber-2
        end
        mRoomData.pengganghuPosition=0
    elseif cztype == 3 then
        mRoomData.LastOutCardPlayer=0
        -- 杠牌
        GangPaiPaiZuDisplay()
        if mRoomData.pengganghuPosition == 4 then
            if mRoomData.MJPlayerList[4].onlyPokerNumber==1 then
                if mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType ==mRoomData.pengganghuType and mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber == mRoomData.pengganghuNumber then
                    mRoomData.MJPlayerList[4].onlyPokerNumber=0 
                    mRoomData.MJPlayerList[4].OnlyPokers={}
                else
                    table.insert(mRoomData.MJPlayerList[4].Pokers, {PokerType=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType, PokerNumber=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber})
                end
            end
            for index=#mRoomData.MJPlayerList[4].Pokers,1,-1 do
                if mRoomData.MJPlayerList[4].Pokers[index].PokerType == mRoomData.pengganghuType and mRoomData.MJPlayerList[4].Pokers[index].PokerNumber == mRoomData.pengganghuNumber then
                    table.remove(mRoomData.MJPlayerList[4].Pokers,index)
                    this.transform:Find('Canvas/Card/Player4/Mahjong'..index).gameObject:SetActive(false)
                end
            end
            mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PokerNumber=#mRoomData.MJPlayerList[4].Pokers
            mRoomData.MJPlayerList[4].onlyPokerNumber=0 
            mRoomData.MJPlayerList[4].OnlyPokers={}
            table.sort(mRoomData.MJPlayerList[4].Pokers, MahjongSort1 )
            MaJongChuPaiSort()
            mRoomData.NowPlayerCPType=nil
            mRoomData.NowPlayerCPNumber=nil
        else
            mRoomData.NowPlayerCPType=nil
            mRoomData.NowPlayerCPNumber=nil
            if mRoomData.pengganghuMA == 1 then
                mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PokerNumber=mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PokerNumber-3
            elseif mRoomData.pengganghuMA == 2 then
                mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PokerNumber=mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PokerNumber-3
            elseif mRoomData.pengganghuMA == 3 then
                mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PokerNumber=mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PokerNumber-0
            end
        end
    elseif cztype == 4 then
        mRoomData.LastOutCardPlayer=0
        -- 胡牌
        if mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PlayerState>PlayerStateEnumMJ.NULL then
            mRoomData.MJPlayerList[mRoomData.pengganghuPosition].PlayerState=PlayerStateEnumMJ.HU
        end
        HuPaiDisplay(mRoomData.pengganghuPosition,true)
        if mRoomData.pengganghuPosition == 4 then
            for Index=1,14,1 do
                mXiaJiaoZhiShi[Index]:SetActive(false)
            end
            --mTingPaiInterface:SetActive(false)
            --mTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3(630,-210,0)
            for Index=1,11,1 do
                if TingPosition[Index].transform:Find("TingInterface")~=nil then
                    local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
                    CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
                end
            end
            local print1 = mTingPaiInterface.transform:Find('BaiSeDi/HuangSeDi/GameObject/Convent').gameObject
            if print1.transform.childCount > 0 then
                local count=print1.transform.childCount
                for i=count,0,-1 do
                    if print1.transform:Find("Ting"..i)~=nil then
                        local copy= print1.transform:Find("Ting"..i).gameObject
                        CS.UnityEngine.Object.Destroy (copy)
                    end
                end
            end
            TingPaiCard={}
        end
        
    elseif cztype == 5 then
        GangPaiButtonDisplay(false)
        PengPaiButtonDisplay(false)
        HuPaiButtonDisplay(false)
        GuoButtonDisplay()
    end
    mMJShow()

end

-- 有玩家被抢杠胡
function PlayerQiangGangHu()
    local mPosition = mRoomData.BQGHplayerPosition
    if mPosition == 4 then
        local BQGHtype= mRoomData.BQGHtype
        local BQGHnumber = mRoomData.BQGHnumber
        if #mRoomData.MJPlayerList[mPosition].OnlyPokers==1 then
            if mRoomData.MJPlayerList[mPosition].OnlyPokers[1].PokerType == BQGHtype and mRoomData.MJPlayerList[mPosition].OnlyPokers[1].PokerNumber == BQGHnumber then
                mRoomData.MJPlayerList[mPosition].onlyPokerNumber=0
                mRoomData.MJPlayerList[mPosition].OnlyPokers={}
            end
        else
            for mCount=1,#mRoomData.MJPlayerList[mPosition].Pokers,1 do
                if mRoomData.MJPlayerList[mPosition].Pokers[mCount].PokerType == BQGHtype and mRoomData.MJPlayerList[mPosition].Pokers[mCount].PokerNumber == BQGHnumber then
                    table.remove( mRoomData.MJPlayerList[mPosition].Pokers, mCount )
                    mRoomData.MJPlayerList[mPosition].PokerNumber=#mRoomData.MJPlayerList[mPosition].Pokers
                end
            end
        end
    else
        if #mRoomData.MJPlayerList[mPosition].OnlyPokers==1 then
            mRoomData.MJPlayerList[mPosition].onlyPokerNumber=0
            mRoomData.MJPlayerList[mPosition].OnlyPokers={}
        else
            mRoomData.MJPlayerList[mPosition].PokerNumber=mRoomData.MJPlayerList[mPosition].PokerNumber-1
        end
    end
    mMJShow()
end
-- 显示碰牌牌组
function PengPaiPaiZuDisplay()

    local GangImage=mMyTransform:Find('Canvas/ReasonImage/Peng1').gameObject
    WenZiDongHua1(GangImage,mRoomData.pengganghuPosition)

    local num=#mRoomData.MJPlayerList[mRoomData.triggerPlayerPosition].ChuPokers
    if num<28 then
        this.transform:Find("Canvas/PlayerCardPosition/player"..mRoomData.triggerPlayerPosition.."/Viewpot/Content/MaJong"..num).gameObject:SetActive(false)
    end
    table.remove( mRoomData.MJPlayerList[mRoomData.triggerPlayerPosition].ChuPokers, #mRoomData.MJPlayerList[mRoomData.triggerPlayerPosition].ChuPokers )
    local count=MJGameMgr.MJpghPlayerPosition(mRoomData.pengganghuPosition,mRoomData.triggerPlayerPosition)
    local HUtype = mRoomData.pengganghuType
    local number = mRoomData.pengganghuNumber
    local card = this.transform:Find("Canvas/GangPengPaiPosition/player"..mRoomData.pengganghuPosition.."/Template1").gameObject
    local copy = CS.UnityEngine.Object.Instantiate(card)
    local chips=this.transform:Find('Canvas/GangPengPaiPosition/player'..mRoomData.pengganghuPosition..'/Scroll View/Viewport/Content').gameObject
    pengganghuCardNumber[mRoomData.pengganghuPosition]=pengganghuCardNumber[mRoomData.pengganghuPosition]+1
    local TriggerPlayerPosition = #MJPLAYERPGLIST[mRoomData.pengganghuPosition]+1
    copy.transform.name="Copy_"..TriggerPlayerPosition
    copy.transform.parent=chips.transform
    copy.transform.localPosition=CS.UnityEngine.Vector3(copy.transform.localPosition.x,copy.transform.localPosition.y,0)
    copy.transform.localScale=CS.UnityEngine.Vector3(1,1,0)
    copy.transform:Find('Image4').gameObject:SetActive(false)
    copy:SetActive(true)
    for index=1,4,1 do
        copy.transform:Find('Image'..index..'/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(HUtype,number))
    end
    --local TriggerPlayerPosition =mRoomData.triggerPlayerPosition
    
    local table1={Mode=1,PokerType=HUtype,PokerNumber=number,TriggerPlayerPosition=mRoomData.triggerPlayerPosition}
    table.insert( MJPLAYERPGLIST[mRoomData.pengganghuPosition],table1 )
end

-- 显示杠牌牌组
function GangPaiPaiZuDisplay()
    --(1暗杠2明杠3补杠)
    if mRoomData.pengganghuMA == 2 then
        local num=#mRoomData.MJPlayerList[mRoomData.triggerPlayerPosition].ChuPokers
        if num<28 then
            this.transform:Find("Canvas/PlayerCardPosition/player"..mRoomData.triggerPlayerPosition.."/Viewpot/Content/MaJong"..num).gameObject:SetActive(false)
        end
        table.remove( mRoomData.MJPlayerList[mRoomData.triggerPlayerPosition].ChuPokers, #mRoomData.MJPlayerList[mRoomData.triggerPlayerPosition].ChuPokers )

    end
    local index = MJGameMgr.MJpghPlayerPosition(mRoomData.pengganghuPosition,mRoomData.triggerPlayerPosition)
    local HUtype = mRoomData.pengganghuType
    local number = mRoomData.pengganghuNumber
    local card=nil
    local triggerPlayerPosition= #MJPLAYERPGLIST[mRoomData.pengganghuPosition]+1
    if mRoomData.pengganghuMA == 3 then
        for i=1,#MJPLAYERPGLIST[mRoomData.pengganghuPosition],1 do
            if MJPLAYERPGLIST[mRoomData.pengganghuPosition][i].PokerType==HUtype and MJPLAYERPGLIST[mRoomData.pengganghuPosition][i].PokerNumber==number then
                local index=mRoomData.pengganghuPosition
                --local count=#MJPLAYERPGLIST[mRoomData.pengganghuPosition]
                local pos=MJGameMgr.MJpghPlayerPosition(mRoomData.pengganghuPosition,MJPLAYERPGLIST[mRoomData.pengganghuPosition][i].triggerPlayerPosition)
                this.transform:Find('Canvas/GangPengPaiPosition/player'..index..'/Scroll View/Viewport/Content/Copy_'..i..'/Image4').gameObject:SetActive(true)
                MJPLAYERPGLIST[mRoomData.pengganghuPosition][i].Mode=2
                MJPLAYERPGLIST[mRoomData.pengganghuPosition][i].breed=mRoomData.pengganghuMA
            end
        end
    elseif mRoomData.pengganghuMA == 2 then
        card = this.transform:Find("Canvas/GangPengPaiPosition/player"..mRoomData.pengganghuPosition.."/Template1").gameObject
        local copy = CS.UnityEngine.Object.Instantiate(card)
        local chips=this.transform:Find('Canvas/GangPengPaiPosition/player'..mRoomData.pengganghuPosition..'/Scroll View/Viewport/Content').gameObject
        pengganghuCardNumber[mRoomData.pengganghuPosition]=pengganghuCardNumber[mRoomData.pengganghuPosition]+1
        local TriggerPlayerPosition = #MJPLAYERPGLIST[mRoomData.pengganghuPosition]+1
        copy.transform.name="Copy_"..triggerPlayerPosition
        copy.transform.parent=chips.transform
        copy.transform.localPosition=CS.UnityEngine.Vector3(copy.transform.localPosition.x,copy.transform.localPosition.y,0)
        copy.transform.localScale=CS.UnityEngine.Vector3(1,1,0)
        copy:SetActive(true)
    elseif mRoomData.pengganghuMA == 1 then
        card = this.transform:Find("Canvas/GangPengPaiPosition/player"..mRoomData.pengganghuPosition.."/Template2").gameObject
        local copy = CS.UnityEngine.Object.Instantiate(card)
        local chips=this.transform:Find('Canvas/GangPengPaiPosition/player'..mRoomData.pengganghuPosition..'/Scroll View/Viewport/Content').gameObject
        pengganghuCardNumber[mRoomData.pengganghuPosition]=pengganghuCardNumber[mRoomData.pengganghuPosition]+1
        local TriggerPlayerPosition = #MJPLAYERPGLIST[mRoomData.pengganghuPosition]+1
        copy.transform.name="Copy_"..triggerPlayerPosition
        copy.transform.parent=chips.transform
        copy.transform.localPosition=CS.UnityEngine.Vector3(copy.transform.localPosition.x,copy.transform.localPosition.y,0)
        copy.transform.localScale=CS.UnityEngine.Vector3(1,1,0)
        copy:SetActive(true)
    end
    if mRoomData.pengganghuMA == 1 then
        local num=mRoomData.pengganghuPosition
        local count=pengganghuCardNumber[mRoomData.pengganghuPosition]
        this.transform:Find('Canvas/GangPengPaiPosition/player'..num..'/Scroll View/Viewport/Content/Copy_'..triggerPlayerPosition..'/Image/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(HUtype,number))
    elseif mRoomData.pengganghuMA == 2 then
        for index=1,4,1 do
            local num=mRoomData.pengganghuPosition
            local count=pengganghuCardNumber[mRoomData.pengganghuPosition]
            this.transform:Find('Canvas/GangPengPaiPosition/player'..num..'/Scroll View/Viewport/Content/Copy_'..triggerPlayerPosition..'/Image'..index..'/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(HUtype,number))
        end
    end
    if mRoomData.pengganghuMA ==1 and mRoomData.pengganghuMA == 2 then
        -- 类型(1碰 2杠),牌型,牌点数,触发玩家位置,杠类型(1暗杠 2明杠 3点杠)
        local triggerPlayerPosition= #MJPLAYERPGLIST[mRoomData.pengganghuPosition]+1
        local table1={Mode=2,PokerType=HUtype,PokerNumber=number,triggerPlayerPosition=triggerPlayerPosition,breed=mRoomData.pengganghuMA}
        table.insert( MJPLAYERPGLIST[mRoomData.pengganghuPosition],table1 )
    end

end

-- 显示胡牌
function HuPaiDisplay(position,mShow)
    if mShow and position ~=0 then
        this.transform:Find("Canvas/HuCardPostion/player"..position).gameObject:SetActive(true)
        if mRoomData.MJPlayerList[position].IsYPDX == 1 then
            this.transform:Find('Canvas/HuCardPostion/player'..position):GetComponent("Image").color=CS.UnityEngine.Color(255, 255, 255, 0.5)
        else
            this.transform:Find('Canvas/HuCardPostion/player'..position):GetComponent("Image").color=CS.UnityEngine.Color(255, 255, 255, 1)
        end
        local HUtype = mRoomData.pengganghuType
        local number = mRoomData.pengganghuNumber
        mRoomData.MJPlayerList[position].HUtype=HUtype
        mRoomData.MJPlayerList[position].HUnumber=number
        this.transform:Find("Canvas/HuCardPostion/player"..position.."/Image"):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(HUtype,number))
        if mRoomData.pengganghuZMtype == 1 then
            mRoomData.MJPlayerList[position].onlyPokerNumber=0
            mRoomData.MJPlayerList[position].OnlyPokers={}
            this.transform:Find('Canvas/Card/Player'..position..'/Mahjong14').gameObject:SetActive(false)
        else
            local num=#mRoomData.MJPlayerList[mRoomData.triggerPlayerPosition].ChuPokers
            if num>0 then
                if mRoomData.MJPlayerList[mRoomData.triggerPlayerPosition].ChuPokers[num].PokerType == HUtype and mRoomData.MJPlayerList[mRoomData.triggerPlayerPosition].ChuPokers[num].PokerNumber == number then
                    if num <28 then
                        this.transform:Find("Canvas/PlayerCardPosition/player"..mRoomData.triggerPlayerPosition.."/Viewpot/Content/MaJong"..num).gameObject:SetActive(false)
                    end
                    table.remove( mRoomData.MJPlayerList[mRoomData.triggerPlayerPosition].ChuPokers, #mRoomData.MJPlayerList[mRoomData.triggerPlayerPosition].ChuPokers )
                end
            end
        end
    else
        for position1=1,4,1 do
            this.transform:Find('Canvas/HuCardPostion/player'..position1).gameObject:SetActive(false)
            this.transform:Find('Canvas/HuCardPostion/player'..position1):GetComponent("Image").color=CS.UnityEngine.Color(255, 255, 255, 255)
        end
    end
end

-- 玩家认输
function PlayerThrowInTheTowel(mShow)
    if  mShow then
        for positionParam =1,4,1 do
            if mRoomData.MJPlayerList[positionParam].PlayerState > PlayerStateEnumMJ.NULL then
                if mRoomData.MJPlayerList[positionParam].PlayerState==PlayerStateEnumMJ.Fail then
                    local showObj=mPlayerUINodes[positionParam].HeadIcon
                    --头像灰化
                    showObj:GetComponent("Image").color=CS.UnityEngine.Color.grey
                    --牌组灰化
                    if positionParam == 4 then
                        for index=1,mRoomData.MJPlayerList[positionParam].PokerNumber,1 do
                            --this.transform:Find('Canvas/Card/Player4/Mahjong'..index).gameObject:SetActive(true)
                            this.transform:Find('Canvas/Card/Player'..positionParam..'/Mahjong'..index):GetComponent("Image").color=CS.UnityEngine.Color.grey
                            this.transform:Find('Canvas/Card/Player'..positionParam..'/Mahjong'..index):GetComponent("Button").enabled=false
                        end
                    else
                        for index=1,mRoomData.MJPlayerList[positionParam].PokerNumber,1 do
                            --this.transform:Find('Canvas/Card/Player4/Mahjong'..index).gameObject:SetActive(true)
                            this.transform:Find('Canvas/Card/Player'..positionParam..'/Mahjong'..index):GetComponent("Image").color=CS.UnityEngine.Color.grey
                        end
                    end
                    --显示认输标志
                    local Fail = mPlayerUINodes[positionParam].Fail
                    Fail:SetActive(true)
                end
            end
        end
    else
        for index=1,4,1 do
            local showObj=mPlayerUINodes[index].HeadIcon
            local Fail = mPlayerUINodes[index].Fail
            --头像解除灰化
            showObj:GetComponent("Image").color=CS.UnityEngine.Color.white
            -- 隐藏认输标志
            Fail:SetActive(false)
            for count=1,14,1 do
                -- 牌组解除灰化
                this.transform:Find('Canvas/Card/Player'..index..'/Mahjong'..count):GetComponent("Image").color=CS.UnityEngine.Color.white
            end
        end
        for count=1,14,1 do
            this.transform:Find('Canvas/Card/Player4/Mahjong'..count):GetComponent("Button").enabled=true
        end
    end
end

-- 删除碰牌和杠牌
function DestoryPengGangCards()
    for index=1,4,1 do
        local print1 = this.transform:Find('Canvas/GangPengPaiPosition/player'..index..'/Scroll View/Viewport/Content').gameObject
        if print1.transform.childCount > 0 then
            local count=print1.transform.childCount
            for i=count,0,-1 do
                if print1.transform:Find("Copy_"..i)~=nil then
                    print("....................",count,i)
                    local copy= print1.transform:Find("Copy_"..i).gameObject
                    CS.UnityEngine.Object.Destroy (copy)
                end
            end
        end
    end
end

-- 玩家摸牌
function playerMoPai(position)
    UpdateMahJongNumber()
    if position == 4 then
        mRoomData.MJPlayerList[4].RaoPao = 1
        mRoomData.MJPlayerList[4].GuoPeng = 0
        mRoomData.MJPlayerList[4].GuoPengTable={}
        local onlyCard=this.transform:Find('Canvas/Card/Player4/Mahjong14').gameObject
        local handCard=this.transform:Find('Canvas/Card/Player4/Mahjong'..mRoomData.MJPlayerList[4].PokerNumber).gameObject
        local POSITION_X=handCard.transform.localPosition.x+185
        local POSITION_Y=handCard.transform.localPosition.y
        local POSITION_Y_2 =POSITION_Y+200
        local Cardtype = mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType
        local number = mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber
        if Cardtype == mRoomData.MJPlayerList[4].QueType then
            this.transform:Find('Canvas/Card/Player4/Mahjong14'):GetComponent("Image").color=CS.UnityEngine.Color.grey
        else
            this.transform:Find('Canvas/Card/Player4/Mahjong14'):GetComponent("Image").color=CS.UnityEngine.Color.white
        end
        this.transform:Find('Canvas/Card/Player4/Mahjong14/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(Cardtype,number))
        
        onlyCard:SetActive(true)
        local TweenOBJ=onlyCard.transform:GetComponent("TweenPosition")
        TweenOBJ:ResetToBeginning()
        TweenOBJ.from=CS.UnityEngine.Vector3(POSITION_X,POSITION_Y_2,0)
        TweenOBJ.to = CS.UnityEngine.Vector3(POSITION_X,POSITION_Y,0)
        TweenOBJ.duration=0.3
        TweenOBJ:Play(true)
        this:DelayInvoke(0.3,function()
            onlyCard.transform.localPosition=CS.UnityEngine.Vector3(POSITION_X,POSITION_Y,0)
        end)
        OutCardClickCardSame(14,true)
    else
        if position == 2 then
            local onlyCard=this.transform:Find('Canvas/Card/Player'..position..'/Mahjong14').gameObject
            local handCard=this.transform:Find('Canvas/Card/Player'..position..'/Mahjong'..mRoomData.MJPlayerList[position].PokerNumber).gameObject
            local POSITION_X=handCard.transform.localPosition.x-80
            local POSITION_Y=handCard.transform.localPosition.y
            onlyCard.transform.localPosition=CS.UnityEngine.Vector3(POSITION_X,POSITION_Y,0)
            onlyCard:SetActive(true)
        elseif position == 1 then
            local onlyCard=this.transform:Find('Canvas/Card/Player'..position..'/Mahjong14').gameObject
            local handCard=this.transform:Find('Canvas/Card/Player'..position..'/Mahjong'..mRoomData.MJPlayerList[position].PokerNumber).gameObject
            local POSITION_X=handCard.transform.localPosition.x-23.4
            local POSITION_Y=handCard.transform.localPosition.y+72.4
            onlyCard.transform.localPosition=CS.UnityEngine.Vector3(POSITION_X,POSITION_Y,0)
            onlyCard:SetActive(true)
        elseif position == 3 then
            local onlyCard=this.transform:Find('Canvas/Card/Player'..position..'/Mahjong14').gameObject
            local handCard=this.transform:Find('Canvas/Card/Player'..position..'/Mahjong'..mRoomData.MJPlayerList[position].PokerNumber).gameObject
            local POSITION_X=handCard.transform.localPosition.x-29.2
            local POSITION_Y=handCard.transform.localPosition.y-95.3
            onlyCard.transform.localPosition=CS.UnityEngine.Vector3(POSITION_X,POSITION_Y,0)
            onlyCard:SetActive(true)
        end
    end
end

-- 结算手牌显示
function FlowBureauCardDisplay(mShow)
    if mShow then
        for count=1,4,1 do
            for index=1,14,1 do
                this.transform:Find('Canvas/Card/Player'..count..'/Mahjong'..index).gameObject:SetActive(false)
            end
            MahJongDingQue(count)
            for num=1,mRoomData.MJPlayerList[count].PokerNumber,1 do
                local Card = this.transform:Find('Canvas/FlowBureauCard/player'..count..'/Image'..num).gameObject
                Card:SetActive(true)
                local Cardtype = mRoomData.MJPlayerList[count].Pokers[num].PokerType
                local number = mRoomData.MJPlayerList[count].Pokers[num].PokerNumber
                Card.transform:Find('Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(Cardtype,number))
            end
        end
    else
        for index=1,4,1 do
            for count=1,13,1 do
                this.transform:Find('Canvas/FlowBureauCard/player'..index..'/Image'..count).gameObject:SetActive(false)
            end
        end
    end
end

-- 房间信息界面按钮点击
function RecordInterfaceButtonOnClick(mIndex)
    mGamePlayButton1:SetActive(false)
    mGamePlayButton2:SetActive(false)
    mGameWaterButton1:SetActive(false)
    mGameWaterButton2:SetActive(false)
    mGameRankButton1:SetActive(false)
    mGameRankButton2:SetActive(false)
    if mIndex == 1 then
        mGamePlayButton1:SetActive(true)
        mGameWaterButton1:SetActive(true)
        mGameRankButton2:SetActive(true)
        mRoomPlayGameObject:SetActive(false)
        mRoomWaterObject:SetActive(false)
        RequestRoomGameRanInfo()
    elseif mIndex == 2 then
        mGameWaterButton2:SetActive(true)
        mGamePlayButton1:SetActive(true)
        mGameRankButton1:SetActive(true)
        mRoomPlayGameObject:SetActive(false)
        mGameRankObject:SetActive(false)
        RequestRoomGameWaterInfo()
    elseif mIndex == 3 then
        mGamePlayButton2:SetActive(true)
        mGameWaterButton1:SetActive(true)
        mGameRankButton1:SetActive(true)
        mRoomWaterObject:SetActive(false)
        mGameRankObject:SetActive(false)
        RoomPlayDisplay(3)
    end
end

-- 房间信息界面显示
function RecordInterfaceDisplay(mShow,Index)
    mRecordInterGameObject:SetActive(mShow)
    if mShow == false then
        mRoomPlayGameObject:SetActive(false)
        mRoomWaterObject:SetActive(false)
        mGameRankObject:SetActive(false)
    end
    RecordInterfaceButtonOnClick(Index)
end

-- 房间信息选项显示
function GameInfoOption(mIndex)
    RoomGameRanInfoDisplay(mIndex)
    RoomGameWaterInfoDisplay(mIndex)
    RoomPlayDisplay(mIndex)
end

-- 房间玩法显示
function RoomPlayDisplay(mIndex)
    if mIndex == 3 then
        mRoomPlayGameObject:SetActive(true)
        local LV=string.format(data.GetString("MJ_FengDing_" .. mRoomData.FengDingBeiLv))
        mRoomPlayGameObject.transform:Find('Image/Text/Text'):GetComponent("Text").text="血战到底"..LV
        local ZiMoMode=string.format(data.GetString("MJ_ZiMoMode_" .. mRoomData.ZiMoMode))
        local DGH=string.format(data.GetString("MJ_DianGangHuaMode_" .. mRoomData.DianGangHuaMode))
        mRoomPlayGameObject.transform:Find('Image/Text1/Text'):GetComponent("Text").text=ZiMoMode..DGH
        local jiangdui=""       local menqing=""         local tiandihu=""        local haidilaoyue=""
        if mRoomData.JiangDui == 1 then
            jiangdui="将对"
        end
        if mRoomData.JiangDui == 1  then
            if mRoomData.MenQing == 1 then
                menqing=",门清"
            end
        else
            if mRoomData.MenQing == 1 then
                menqing="门清"
            end
        end
        if mRoomData.JiangDui==1 or mRoomData.MenQing == 1 then
            if mRoomData.TiandiaHu == 1 then
                tiandihu=",天地胡"
            end
        elseif mRoomData.JiangDui==0 and mRoomData.MenQing == 0 then
            if mRoomData.TiandiaHu == 1 then
                tiandihu="天地胡"
            end
        end
        if mRoomData.JiangDui==1 or mRoomData.MenQing == 1 or mRoomData.TiandiaHu == 1 then
            if mRoomData.HaiDiLaoYue == 1 then
                haidilaoyue=",海底捞月"
            end
        elseif mRoomData.JiangDui==0 and mRoomData.MenQing == 0 and mRoomData.TiandiaHu == 0 then
            if mRoomData.HaiDiLaoYue == 1 then
                haidilaoyue="海底捞月"
            end
        end
        mRoomPlayGameObject.transform:Find('Image/Text2/Text'):GetComponent("Text").text=jiangdui..menqing..tiandihu..haidilaoyue
    else
        mRoomPlayGameObject:SetActive(false)
    end
end

-- 请求房间总对局流水信息
function RequestRoomGameWaterInfo()
    if mRoomWaterObject.gameObject.activeSelf == false then
        NetMsgHandler.Send_CS_MJ_GameWater()
    end
end

-- 房间总对局流水显示
function RoomGameWaterInfoDisplay(mIndex)
    if mIndex == 2 then
        local print1=mRoomWaterObject.transform:Find('Scroll View/Viewport/Content').gameObject
        if print1.transform.childCount > 0 then
            local count=print1.transform.childCount
            for i=count,0,-1 do
                if print1.transform:Find("Copy_"..i)~=nil then
                    local copy= print1.transform:Find("Copy_"..i).gameObject
                    CS.UnityEngine.Object.Destroy (copy)
                end
            end
        end
        mRoomWaterObject:SetActive(true)
        for index=1,mRoomData.GameWaterNumber,1 do
            local card=mRoomWaterObject.transform:Find('GameInfo').gameObject
            local copy = CS.UnityEngine.Object.Instantiate(card)
            local chips=mRoomWaterObject.transform:Find('Scroll View/Viewport/Content').gameObject
            copy.transform.name="Copy_"..index
            copy.transform.parent=chips.transform
            copy.transform.localPosition=CS.UnityEngine.Vector3(copy.transform.localPosition.x,copy.transform.localPosition.y,0)
            copy.transform.localScale=CS.UnityEngine.Vector3(1,1,0)
            copy:SetActive(true)
            copy.transform:Find('Image/Text'):GetComponent("Text").text=""..index
            for count=1,mRoomData.GameWaterInfo[index].playerCount,1 do
                copy.transform:Find('player'..count).gameObject:SetActive(true)
                local HeadIcon = copy.transform:Find('player'..count):GetComponent("Image")
                HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(mRoomData.GameWaterInfo[index].GameWaterLiet[count].Icon))
                copy.transform:Find('player'..count..'/Name'):GetComponent("Text").text=mRoomData.GameWaterInfo[index].GameWaterLiet[count].Name
                local gold = GameConfig.GetFormatColdNumber(mRoomData.GameWaterInfo[index].GameWaterLiet[count].Gold)
                if gold >=0 then
                    copy.transform:Find('player'..count..'/Gold'):GetComponent("Text").text='+' .. lua_NumberToStyle1String(gold)
                else
                    copy.transform:Find('player'..count..'/Gold'):GetComponent("Text").text=lua_NumberToStyle1String(gold)
                end
            end
        end
    else
        mRoomWaterObject:SetActive(false)
        local print1=mRoomWaterObject.transform:Find('Scroll View/Viewport/Content').gameObject
        if print1.transform.childCount > 0 then
            local count=print1.transform.childCount
            for i=count,0,-1 do
                if print1.transform:Find("Copy_"..i)~=nil then
                    local copy= print1.transform:Find("Copy_"..i).gameObject
                    CS.UnityEngine.Object.Destroy (copy)
                end
            end
        end

    end
end

-- 请求房间对局排行信息
function RequestRoomGameRanInfo()
    if mGameRankObject.activeSelf == false then
        NetMsgHandler.Send_CS_MJ_GameRank()
    end
end

-- 房间对局排行显示
function RoomGameRanInfoDisplay(mIndex)
    if mIndex == 1 then
        if mGameRankObject.activeSelf == false then
            local print1=mGameRankObject.transform:Find('Scroll View/Viewport/Content').gameObject
            if print1.transform.childCount > 0 then
                local count=print1.transform.childCount
                for i=count,0,-1 do
                    if print1.transform:Find("Copy_"..i)~=nil then
                        local copy= print1.transform:Find("Copy_"..i).gameObject
                        CS.UnityEngine.Object.Destroy (copy)
                    end
                end
            end
            mGameRankObject:SetActive(true)
            if mRoomData.BoardMaxNumber == mRoomData.BoardCurrentNumber then
                if mRoomData.RoomState < ROOM_STATE_MJ.RANDOM or mRoomData.RoomState > ROOM_STATE_MJ.RAWAIT_ENDNDOM then
                    mGameRankObject.transform:Find("Exit").gameObject:SetActive(true)
                    mRecordInterGameObject.transform:Find("Back/Title/CloseButton").gameObject:SetActive(false)
                end
            end
            for index=1,mRoomData.GameRankNumber,1 do
                local card=mGameRankObject.transform:Find('Template').gameObject
                local copy = CS.UnityEngine.Object.Instantiate(card)
                local chips=mGameRankObject.transform:Find('Scroll View/Viewport/Content').gameObject
                copy.transform.name="Copy_"..index
                copy.transform.parent=chips.transform
                copy.transform.localPosition=CS.UnityEngine.Vector3(copy.transform.localPosition.x,copy.transform.localPosition.y,0)
                copy.transform.localScale=CS.UnityEngine.Vector3(1,1,0)
                copy:SetActive(true)
                local HeadIcon = copy.transform:Find('Image/Icon'):GetComponent("Image")
                HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(mRoomData.GameRankInfo[index].Icon))
                copy.transform:Find('Image/NO_'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJRankSpriteName(index))
                if index <=3 then
                    copy.transform:Find('Image/NO_/Text').gameObject:SetActive(false)
                else
                    copy.transform:Find('Image/NO_/Text').gameObject:SetActive(true)
                    copy.transform:Find('Image/NO_/Text'):GetComponent("Text").text=""..index
                end
                copy.transform:Find('Image/Name'):GetComponent("Text").text=mRoomData.GameRankInfo[index].Name
                copy.transform:Find('Image/GameNumber'):GetComponent("Text").text="总对局"..mRoomData.GameRankInfo[index].GameNumber
                copy.transform:Find('Image/VictoryNumber'):GetComponent("Text").text="胜局"..mRoomData.GameRankInfo[index].VictoryNumber
                local gold=GameConfig.GetFormatColdNumber(mRoomData.GameRankInfo[index].Gold)
                if gold >=0 then
                    copy.transform:Find('Image/Gold'):GetComponent("Text").text='+' .. lua_NumberToStyle1String(gold)
                else
                    copy.transform:Find('Image/Gold'):GetComponent("Text").text=lua_NumberToStyle1String(gold)
                end
            end
        end
        
    else
        mGameRankObject:SetActive(false)
        local print1=mGameRankObject.transform:Find('Scroll View/Viewport/Content').gameObject
        if print1.transform.childCount > 0 then
            local count=print1.transform.childCount
            for i=count,0,-1 do
                if print1.transform:Find("Copy_"..i)~=nil then
                    local copy= print1.transform:Find("Copy_"..i).gameObject
                    CS.UnityEngine.Object.Destroy (copy)
                end
            end
        end
    end
end

-- 请求本局对局流水信息
function RequestNowGameWaterInfo()
    NetMsgHandler.Send_CS_MJ_TheBureauGameWater()
    --[[local aaa = this.transform:Find("Canvas/ReasonImage/HU1").gameObject
    local Position = 4
    WenZiDongHua1(aaa,Position)
    this:DelayInvoke(1,function()
        HuDongHua(4)
    end)
    for index=1,3,1 do
        mRoomData.MJPlayerList[index]={}
        mRoomData.MJPlayerList[index].QueType=1
    end
    mRoomData.MJPlayerList[4].QueType=1
    PlayerDingQueAnimtion(4)--]]
end

-- 本局房间流水界面显示
function NowGameWaterDisplay(mShow)
    if mShow then
        if mGameWaterObject.activeSelf == false then
            local print1=mGameWaterObject.transform:Find('Scroll View/Viewport/Content').gameObject
            if print1.transform.childCount > 0 then
                local count=print1.transform.childCount
                for i=count,0,-1 do
                    if print1.transform:Find("Copy_"..i)~=nil then
                        local copy= print1.transform:Find("Copy_"..i).gameObject
                        CS.UnityEngine.Object.Destroy (copy)
                    end
                end
            end
            mGameWaterObject:SetActive(true)
        
            if mRoomData.TheBureauGameWaterCount == 0 then
                mGameWaterObject.transform:Find('GamgGold').gameObject:SetActive(false)
            else
                local Gold=0
                for index=1,mRoomData.TheBureauGameWaterCount,1 do
                    Gold=Gold+GameConfig.GetFormatColdNumber(mRoomData.TheBureauGameWaterInfo[index].Gold)
                end
                mGameWaterObject.transform:Find('GamgGold').gameObject:SetActive(true)
                if Gold >= 0 then
                    mGameWaterObject.transform:Find('GamgGold/Text'):GetComponent("Text").text="+"..lua_CommaSeperate(Gold)
                else
                    mGameWaterObject.transform:Find('GamgGold/Text'):GetComponent("Text").text=lua_CommaSeperate(Gold)
                end
            end
            for index=1,mRoomData.TheBureauGameWaterCount,1 do
                local card=mGameWaterObject.transform:Find('Template').gameObject
                local copy = CS.UnityEngine.Object.Instantiate(card)
                local chips=mGameWaterObject.transform:Find('Scroll View/Viewport/Content').gameObject
                copy.transform.name="Copy_"..index
                copy.transform.parent=chips.transform
                copy.transform.localPosition=CS.UnityEngine.Vector3(copy.transform.localPosition.x,copy.transform.localPosition.y,0)
                copy.transform.localScale=CS.UnityEngine.Vector3(1,1,0)
                local position=MJGameMgr.MJpghPlayerPosition(4,mRoomData.TheBureauGameWaterInfo[index].position)
                local position1=""
                if position == 1 then
                    position1="下家"
                elseif position == 2 then
                    position1="对家"
                elseif position == 3 then
                    position1="上家"
                elseif position == 4 then
                    position1="本家"
                end
                if mRoomData.TheBureauGameWaterInfo[index].Changetype <=14 then
                    if mRoomData.TheBureauGameWaterInfo[index].HuType == 1 and mRoomData.DianGangHuaMode == 1 then
                        if mRoomData.TheBureauGameWaterInfo[index].Gold >=0 then
                            if mRoomData.TheBureauGameWaterInfo[index].Players == 1 then
                                position1="一家"
                            elseif mRoomData.TheBureauGameWaterInfo[index].Players == 2 then
                                position1="两家"
                            elseif mRoomData.TheBureauGameWaterInfo[index].Players == 3 then
                                position1="三家"
                            end
                        end
                    end
                elseif mRoomData.TheBureauGameWaterInfo[index].Changetype ==16 or mRoomData.TheBureauGameWaterInfo[index].Changetype ==17 then
                    if mRoomData.TheBureauGameWaterInfo[index].Gold >=0 then
                        if mRoomData.TheBureauGameWaterInfo[index].Players == 1 then
                            position1="一家"
                        elseif mRoomData.TheBureauGameWaterInfo[index].Players == 2 then
                            position1="两家"
                        elseif mRoomData.TheBureauGameWaterInfo[index].Players == 3 then
                            position1="三家"
                        end
                    end
                end

                copy:SetActive(true)
                copy.transform:Find('Image/Text'):GetComponent("Text").text=TheBureauGameWaterListInfo(mRoomData.TheBureauGameWaterInfo[index])
                copy.transform:Find('Image/position'):GetComponent("Text").text=""..position1
                copy.transform:Find('Image/LV'):GetComponent("Text").text=mRoomData.TheBureauGameWaterInfo[index].LV.."倍"
                if GameConfig.GetFormatColdNumber(mRoomData.TheBureauGameWaterInfo[index].Gold)>=0 then
                    copy.transform:Find('Image/Gold'):GetComponent("Text").text="+"..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(mRoomData.TheBureauGameWaterInfo[index].Gold))
                else
                    copy.transform:Find('Image/Gold'):GetComponent("Text").text=lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(mRoomData.TheBureauGameWaterInfo[index].Gold))
                end
            end
        end
        
    else
        mGameWaterObject:SetActive(false)
        local print1=mGameWaterObject.transform:Find('Scroll View/Viewport/Content').gameObject
        if print1.transform.childCount > 0 then
            local count=print1.transform.childCount
            for i=count,0,-1 do
                if print1.transform:Find("Copy_"..i)~=nil then
                    local copy= print1.transform:Find("Copy_"..i).gameObject
                    CS.UnityEngine.Object.Destroy (copy)
                end
            end
        end
    end
end

-- 本局金币改变原因
function TheBureauGameWaterListInfo(mtable)
    local mInfo=""
    local ZMtype=""  local HUtype=""  local gen=""  local jiangdui=""  local menqing=""  local gangshanghua=""  local haidilao ="" local qiangganghu=""
    local before = false
    if mtable.Changetype<=14 then
        if mtable.HuType == 1 then
            if mtable.Gold>=0 then
                ZMtype="自摸"
            else
                ZMtype="被自摸"
            end
        else
            if mtable.Gold>=0 then
                ZMtype="胡"
            else
                ZMtype="点炮"
            end
        end
        HUtype=MJSettlementInfo[mtable.Changetype]
        if HUtype~="" then
            before=true
        end
        if mtable.Gen ~= 0 and before==false then
            gen=mtable.Gen.."根"
            before=true
        elseif mtable.Gen ~= 0 and before==true then
            gen=","..mtable.Gen.."根"
        end
        if mtable.JiangDui == 1 and before==true then
            jiangdui=",将对"
        elseif mtable.JiangDui == 1 and before==false then
            jiangdui="将对"
            before=true
        end
        if mtable.MenQing == 1 and before==true then
            menqing=",门清"
        elseif mtable.MenQing == 1 and before==false then
            menqing="门清"
            before=true
        end
        if mtable.GangShang == 1 and mtable.HuType == 1 then
            if before==true then
                gangshanghua=",杠上花"
            else
                gangshanghua="杠上花"
                before=true
            end
            if mRoomData.DianGangHuaMode == 2 then
                ZMtype="杠上花"
            end
        elseif mtable.GangShang == 1 and mtable.HuType == 2 then
            if before==true then
                gangshanghua=",杠上炮"
            else
                gangshanghua="杠上炮"
                before=true
            end
            
        end
        if mtable.HaidiLao == 1 and mtable.HuType == 1 then
            if before==true then
                haidilao=",海底捞月"
            else
                haidilao="海底捞月"
                before=true
            end
        elseif mtable.HaidiLao == 1 and mtable.HuType == 2 then
            if before==true then
                haidilao=",海底炮"
            else
                haidilao="海底炮"
                before=true
            end
        end
        if mtable.QiangGangHu == 1 and before==true then
            qiangganghu=",抢杠胡"
        elseif mtable.QiangGangHu == 0 and before==false then
            qiangganghu="抢杠胡"
            before=true
        end
    elseif mtable.Changetype>14 and mtable.Changetype<18 then
        if mtable.Gold>=0 then
            ZMtype=""..MJSettlementInfo[mtable.Changetype]
        elseif mtable.Gold<0 then
            if mtable.Changetype == 15 then
                ZMtype="点"..MJSettlementInfo[mtable.Changetype]
            else
                ZMtype="被"..MJSettlementInfo[mtable.Changetype]
            end
            
        end
    elseif mtable.Changetype>=18 then
    ZMtype=""..MJSettlementInfo[mtable.Changetype]
    end
    if before==true then
        mInfo=ZMtype.."("..HUtype..gen..jiangdui..menqing..gangshanghua..haidilao..qiangganghu..")"
    else
        mInfo=ZMtype..HUtype..gen..jiangdui..menqing..gangshanghua..haidilao..qiangganghu
    end
    print("本局金币改变原因",mInfo)
    return mInfo
end

-- 房间结算界面显示
function SettlementInterfaceGameObjectDisplay(mShow)
    if mShow then
        local print1=mSettlementGameObject.transform:Find('player4/Scroll View/Viewport/Content').gameObject
        if print1.transform.childCount > 0 then
            local count=print1.transform.childCount
            for i=count,0,-1 do
                if print1.transform:Find("Copy_"..i)~=nil then
                    local copy= print1.transform:Find("Copy_"..i).gameObject
                    CS.UnityEngine.Object.Destroy (copy)
                end
            end
        end
        local openTime = 0
        if IsLiuJu == false then
            local GangImage = mMyTransform:Find('Canvas/ReasonImage/GameOver').gameObject
            GangImage:SetActive(true)
            local TweenObject = GangImage.transform:GetComponent('TweenScale')
            TweenObject:ResetToBeginning()
            TweenObject.duration=0.5
            TweenObject:Play(true)
            this:DelayInvoke(2,function()
                GangImage:SetActive(false)
            end)
            openTime=openTime+2
        end
        
        for Index=1,4,1 do
            if mRoomData.MJPlayerList[Index]~=nil then
                if mRoomData.MJPlayerList[Index].ID~=nil then
                    if mRoomData.MJPlayerList[Index].ID~=0 then
                        mPlayerUINodes[Index].GoldText.text=lua_NumberToStyle1String(mRoomData.MJPlayerList[Index].Gold)
                    end
                end
            end
        end
        local print1=mSettlementGameObject.transform:Find('player4/Scroll View/Viewport/Content').gameObject
        if print1.transform.childCount > 0 then
            local count=print1.transform.childCount
            for i=count,0,-1 do
                if print1.transform:Find("Copy_"..i)~=nil then
                    local copy= print1.transform:Find("Copy_"..i).gameObject
                    CS.UnityEngine.Object.Destroy (copy)
                end
            end
        end
        
        if mRoomData.HAVEHUZHU == 1 then
            this:DelayInvoke(openTime,function()
                for Index=1,mRoomData.HUAZHUNUMBER,1 do
                    if mRoomData.MJHuaZhuGoldList[Index].IsHuaZhu == 1 then
                        HuaZhu(mRoomData.MJHuaZhuGoldList[Index].position)
                    end
                end
                
            end)
            openTime=openTime+2
        end
        if mRoomData.HAVECHAJIAO == 1 then
            if mRoomData.HAVEHUZHU == 0 then
                this:DelayInvoke(openTime,function()
                    for Index=1,mRoomData.CHAJIAONUMBER,1 do
                        if mRoomData.MJChaJiaoGoldList[Index].IsChaJiao == 1 then
                            ChaJiao(mRoomData.MJChaJiaoGoldList[Index].position)
                        end
                    end
                end)
                openTime=openTime+2
            end
        end
        if mRoomData.HAVETUISHUI == 1 then
            this:DelayInvoke(openTime,function()
                for Index=1,mRoomData.TUISHUINUMBER,1 do
                    if mRoomData.MJTuiShuiGoldList[Index].Gold < 0 then
                        TuiShui(mRoomData.MJTuiShuiGoldList[Index].position)
                    end
                end
            end)
            openTime=openTime+2
        end
        this:DelayInvoke(openTime,function()
            mSettlementGameObject:SetActive(true)
            if mRoomData.BoardMaxNumber == mRoomData.BoardCurrentNumber then
                mSettlementGameObject.transform:Find("NewGame/Text"):GetComponent("Text").text="确定"
            end
        for index=1,mRoomData.SettlementPlayerNumber,1 do
            local position = mRoomData.SettlementPlayer[index].position
            local HeadIcon = mRoomData.SettlementPlayer[index].ID
            local HeadIconUrl = mRoomData.SettlementPlayer[index].URL
            mSettlementGameObject.transform:Find("player"..position.."/Name"):GetComponent("Text").text=mRoomData.SettlementPlayer[index].Name
            local HeadObj= mSettlementGameObject.transform:Find("player"..position.."/Image/Head"):GetComponent("Image")
            HeadObj:ResetSpriteByName(GameData.GetRoleIconSpriteName(HeadIcon))
            if GameConfig.GetFormatColdNumber(mRoomData.SettlementPlayer[index].Gold)>=0 then
                mSettlementGameObject.transform:Find("player"..position.."/Gold/Text"):GetComponent("Text").text="<color=#CDCD00>+"..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(mRoomData.SettlementPlayer[index].Gold)).."</color>"
            else
                mSettlementGameObject.transform:Find("player"..position.."/Gold/Text"):GetComponent("Text").text="<color=#98F5FF>"..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(mRoomData.SettlementPlayer[index].Gold)).."</color>"
            end
            if mRoomData.SettlementPlayer[index].position == 4 then
                local print1 = mSettlementGameObject.transform:Find('player4/Scroll View/Viewport/Content').gameObject
                if print1.transform.childCount > 0 then
                    local mCount=print1.transform.childCount
                    for i=mCount,0,-1 do
                        if print1.transform:Find("Copy_"..i)~=nil then
                            local copy= print1.transform:Find("Copy_"..i).gameObject
                            CS.UnityEngine.Object.Destroy (copy)
                        end
                    end
                end
                for count=1,mRoomData.SettlementPlayer[index].Count,1 do
                    local card=mSettlementGameObject.transform:Find('player4/Template').gameObject
                    local copy = CS.UnityEngine.Object.Instantiate(card)
                    local chips=mSettlementGameObject.transform:Find('player4/Scroll View/Viewport/Content').gameObject
                    copy.transform.name="Copy_"..count
                    copy.transform.parent=chips.transform
                    copy.transform.localPosition=CS.UnityEngine.Vector3(copy.transform.localPosition.x,copy.transform.localPosition.y,0)
                    copy.transform.localScale=CS.UnityEngine.Vector3(1,1,0)
                    local position2=MJGameMgr.MJpghPlayerPosition(4,mRoomData.ChangeGoldReason[count].position)
                    local position1=""
                    if position2 == 1 then
                        position1="下家"
                    elseif position2 == 2 then
                        position1="对家"
                    elseif position2 == 3 then
                        position1="上家"
                    elseif position2 == 4 then
                        position1="本家"
                    end
                    if mRoomData.ChangeGoldReason[count].Changetype <=14 then
                        if mRoomData.ChangeGoldReason[count].HuType == 1 and mRoomData.DianGangHuaMode == 1 then
                            if mRoomData.ChangeGoldReason[count].Gold >=0 then
                                if mRoomData.ChangeGoldReason[count].PlayersNumber == 1 then
                                    position1="一家"
                                elseif mRoomData.ChangeGoldReason[count].PlayersNumber == 2 then
                                    position1="两家"
                                elseif mRoomData.ChangeGoldReason[count].PlayersNumber == 3 then
                                    position1="三家"
                                end
                            end
                        end
                    elseif mRoomData.ChangeGoldReason[count].Changetype ==16 or mRoomData.ChangeGoldReason[count].Changetype ==17 then
                        if mRoomData.ChangeGoldReason[count].Gold >=0 then
                            if mRoomData.ChangeGoldReason[count].PlayersNumber == 1 then
                                position1="一家"
                            elseif mRoomData.ChangeGoldReason[count].PlayersNumber == 2 then
                                position1="两家"
                            elseif mRoomData.ChangeGoldReason[count].PlayersNumber == 3 then
                                position1="三家"
                            end
                        end
                    end
                    
                    copy:SetActive(true)
                    copy.transform:Find('Text'):GetComponent("Text").text=TheBureauGameWaterListInfo(mRoomData.ChangeGoldReason[count])
                    copy.transform:Find('Position'):GetComponent("Text").text=""..position1
                    copy.transform:Find('LV'):GetComponent("Text").text=mRoomData.ChangeGoldReason[count].LV.."倍"
                    if GameConfig.GetFormatColdNumber(mRoomData.ChangeGoldReason[count].Gold)>=0 then
                        copy.transform:Find('Gold/Text'):GetComponent("Text").text="+"..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(mRoomData.ChangeGoldReason[count].Gold))
                    else
                        copy.transform:Find('Gold/Text'):GetComponent("Text").text=lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(mRoomData.ChangeGoldReason[count].Gold))
                    end
                end
            end
        end
        end)
        
    else
        mSettlementGameObject:SetActive(false)
        local print1=mSettlementGameObject.transform:Find('player4/Scroll View/Viewport/Content').gameObject
        if print1.transform.childCount > 0 then
            local count=print1.transform.childCount
            for i=count,0,-1 do
                if print1.transform:Find("Copy_"..i)~=nil then
                    local copy= print1.transform:Find("Copy_"..i).gameObject
                    CS.UnityEngine.Object.Destroy (copy)
                end
            end
        end
    end
end

-- 房间结算界面下一局按钮
function SettlementInterfaceNextGameButtonOnClick()
    SettlementInterfaceGameObjectDisplay(false)
    if mRoomData.BoardMaxNumber == mRoomData.BoardCurrentNumber then
        RecordInterfaceDisplay(true,1)
    else
        ZBButtonISShow(true)
        --ZBButtonOnClick()
        UpdateButtonInvite1ShowState()
    end
    
end

-- 听牌指示针按钮显示
function TingButtonDisplay()
    local function CheckCardInTable(tCardGroup, tCard)
        for k,v in ipairs(tCardGroup) do
            if v.PokerType == tCard.PokerType and v.PokerNumber == tCard.PokerNumber then
                return true
            end
        end
        return false
    end
    local tCard={}
    local tYiCha={}
    local XiangTong=false
    local tTry = {}
    local tTryCard = {}
    TingPaiCard={}
    tCard=clone(mRoomData.MJPlayerList[4].Pokers)
    if #mRoomData.MJPlayerList[4].OnlyPokers == 1 then
        table.insert( tCard, {PokerType=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType,PokerNumber=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber} )
    end
    for Index=1,#tCard,1 do
        if CheckCardInTable(tYiCha,tCard[Index])==false then
            table.insert(tYiCha,{PokerType=tCard[Index].PokerType,PokerNumber= tCard[Index].PokerNumber})
            local tTmpCard = clone(tCard)
            table.remove(tTmpCard, Index)
            table.insert(tTry, tTmpCard)
            table.insert(tTryCard, tCard[Index])
        end
    end
    local nFlag = 0
    for Index= 1,#tTry,1 do
        
        if CheckIsTingPai(tTry[Index], mRoomData.MJPlayerList[4].QueType) then
            nFlag = 1
            table.insert( TingPaiCard, {PokerType=tTryCard[Index].PokerType,PokerNumber=tTryCard[Index].PokerNumber} )
        end
    end
    if nFlag == 1 then
        for  Count = 1, 14, 1 do
            mXiaJiaoZhiShi[Count]:SetActive(false)
        end
        --mTingButtonObject:SetActive(true)
        for Count=1,#TingPaiCard,1 do
            for Index=1,#mRoomData.MJPlayerList[4].Pokers,1 do
                if mRoomData.MJPlayerList[4].Pokers[Index].PokerType == TingPaiCard[Count].PokerType and mRoomData.MJPlayerList[4].Pokers[Index].PokerNumber == TingPaiCard[Count].PokerNumber then
                    mXiaJiaoZhiShi[Index]:SetActive(true)
                    --break
                end
            end
        end
        if #mRoomData.MJPlayerList[4].OnlyPokers == 1 then
            for Count=1,#TingPaiCard,1 do
                if mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType == TingPaiCard[Count].PokerType and mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber == TingPaiCard[Count].PokerNumber then
                    mXiaJiaoZhiShi[14]:SetActive(true)
                    break
                end
            end
        end
    else
        --mTingPaiInterface:SetActive(false)
        mTingButtonObject:SetActive(false)
        for Index=1,11,1 do
            if TingPosition[Index].transform:Find("TingInterface")~=nil then
                local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
                CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
            end
        end
    end

end

--玩家点击听牌按钮
function TingPaiButtonOnClick(mShow)
    if mShow then
        for Index=1,11,1 do
            if TingPosition[Index].transform:Find("TingInterface")~=nil then
                local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
                CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
            end
        end
        local tCard=clone(mRoomData.MJPlayerList[4].Pokers)
        local tTable={}

        local GnagTable={}
        local PengTable={}
        for Index=1,#MJPLAYERPGLIST[4],1 do
            if MJPLAYERPGLIST[4][Index].Mode == 1 then
                table.insert( PengTable, MJPLAYERPGLIST[4][Index])
            elseif MJPLAYERPGLIST[4].Mode == 2 then
                table.insert( GnagTable, MJPLAYERPGLIST[4][Index])
            end
        end
        tTable=CheckTingPaiMaybeType(tCard,PengTable,GnagTable,mRoomData.MJPlayerList[4].QueType)
        for Index=1,11,1 do
            if TingPosition[Index].transform:Find("TingInterface")~=nil then
                local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
                CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
            end
        end
        --mTingPaiInterface:SetActive(true)
        local mCopyTingPaiInterface = CS.UnityEngine.Object.Instantiate(mTingPaiInterface)
        mCopyTingPaiInterface.transform.parent=TingPosition[#tTable].transform
        mCopyTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3.zero
        mCopyTingPaiInterface.transform.localScale=CS.UnityEngine.Vector3.one
        mCopyTingPaiInterface.transform.name="TingInterface"
        mCopyTingPaiInterface:SetActive(true)
        mCopyTingPaiInterface.transform:Find("Close"):GetComponent("Button").onClick:AddListener(function() TingPaiButtonOnClick(false) end)
        --mTingPaiInterface.transform.localPosition=CS.UnityEngine.Vector3(TingInterface_Position_X1[#tTable],TingInterface_Position_Y1[#tTable],0)
        mCopyTingPaiInterface.transform:GetComponent("RectTransform").sizeDelta = CS.UnityEngine.Vector2(TingInterface_Scale_X1[#tTable],TingInterface_Scale_Y1[#tTable])
        local TingInfo= mCopyTingPaiInterface.transform:Find('BaiSeDi/HuangSeDi/GameObject/Template').gameObject
        local TingInfoPrint = mCopyTingPaiInterface.transform:Find('BaiSeDi/HuangSeDi/GameObject/Convent').gameObject
        for Index=1,#tTable,1 do
            local CopyObject = CS.UnityEngine.Object.Instantiate(TingInfo)
            CopyObject.transform.parent=TingInfoPrint.transform
            CopyObject.transform.localPosition=CS.UnityEngine.Vector3.zero
            CopyObject.transform.localScale=CS.UnityEngine.Vector3.one
            CopyObject.transform.name="Ting"..Index
            CopyObject:SetActive(true)
            CopyObject.transform:Find('MahJong/Image'):GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(tTable[Index][1],tTable[Index][2]))
            CopyObject.transform:Find('LV'):GetComponent("Text").text=""..tHuBeiShu[tTable[Index][3]].."倍"
            local Surplus= ACardHowManyPiecesAreLeft(tTable[Index][1],tTable[Index][2])
            CopyObject.transform:Find('Num'):GetComponent("Text").text=""..Surplus.."张"
            if Surplus == 0 then
                CopyObject.transform:Find('MahJong'):GetComponent("Image").color=CS.UnityEngine.Color.grey
            end
        end
    else
        --mTingPaiInterface:SetActive(false)
        for Index=1,11,1 do
            if TingPosition[Index].transform:Find("TingInterface")~=nil then
                local mCopyTingPaiInterface = TingPosition[Index].transform:Find("TingInterface").gameObject
                CS.UnityEngine.Object.Destroy (mCopyTingPaiInterface)
            end
        end
    end
end

-- 玩家定缺显示
function PlayerDingQueIcon(mShow)
    if mShow then
        for count=1,4,1 do
            if mRoomData.MJPlayerList[count].QueType~=nil and mRoomData.MJPlayerList[count].PlayerState >= PlayerStateEnumMJ.QUE then
                this.transform:Find('Canvas/Players/Player'..count..'/DingZhuang/'..mRoomData.MJPlayerList[count].QueType).gameObject:SetActive(mShow)
            else
                for mCout=1,3,1 do
                    this.transform:Find('Canvas/Players/Player'..count..'/DingZhuang/'..mCout).gameObject:SetActive(false)
                end
            end
        end
    else
        for count=1,4,1 do
            if mRoomData.MJPlayerList[count].QueType==nil then
                for index=1,3,1 do
                    this.transform:Find('Canvas/Players/Player'..count..'/DingZhuang/'..index).gameObject:SetActive(mShow)
                end
            end
        end
    end
end

-- 响应定缺按钮点击
function DingQueButtonOnClick(queType)
    NetMsgHandler.Send_CS_MJ_DingQue(queType)
    DingQueImage(false)
end

--==============================--
--desc:准备按钮call
--time:2018-02-27 08:26:07
--@return 
--==============================--
function ZBButtonOnClick()
    NetMsgHandler.Send_CS_MJ_Prepare_Game()
end

--==============================--
--desc:邀请按钮1显示状态更新
--time:2018-01-25 02:30:13
--@return 
--==============================--
function UpdateButtonInvite1ShowState()
    local showParam = true
    if mRoomData:PlayerCount() >3 then
        showParam = false
    end
    if mRoomData.RoomType ~= ROOM_TYPE.ZuJuMaJiang then
       showParam = false 
    end
    if mRoomData.RoomState ~= ROOM_STATE_MJ.READY then
        showParam = false 
    end
    local ButtonInvite1GameObject = mMyTransform:Find('Canvas/Buttons/ButtonInvite1').gameObject
    ButtonInvite1GameObject:SetActive(showParam)
end

-- 杠牌显示
function GangPaiButtonDisplay(mShow)
    mGangPaiInterface:SetActive(false)
    mGangPaiGameObject:SetActive(mShow)
end

-- 杠牌点击
function GangButtonOnClick()
    local tCardGroup = {}
    for Index=1,#mRoomData.MJPlayerList[4].Pokers,1 do
        tCardGroup[Index]=mRoomData.MJPlayerList[4].Pokers[Index]
    end
    if #mRoomData.MJPlayerList[4].OnlyPokers==1 then
        table.insert( tCardGroup,{PokerType=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerType, PokerNumber=mRoomData.MJPlayerList[4].OnlyPokers[1].PokerNumber})
    end
    local tPengGroup = {}
    for Index=1,#MJPLAYERPGLIST[4],1 do
        if MJPLAYERPGLIST[4][Index].Mode==1 then
            table.insert( tPengGroup, MJPLAYERPGLIST[4][Index] )
        end
    end
    GangGroud = {}
    GangGroud=GetPerCardCountList(tCardGroup,tPengGroup)
    if #GangGroud>=2 then
        GangPaiChoiceIntefaceDisolay()
    else
        PengGangHuGuoButtonOnClick(3,0,0)
    end

end

local GangInterface_X={[1]=290,[2]=400,[3]=525,[4]=630}

-- 杠牌选择界面是否打开
function GangPaiChoiceIntefaceDisolay()
    mGangPaiGameObject:SetActive(false)
    mGangPaiInterface.transform:GetComponent("RectTransform").sizeDelta = CS.UnityEngine.Vector2(GangInterface_X[#GangGroud],265)
    mGangPaiInterface.transform.localPosition = CS.UnityEngine.Vector3(0,-210,0)
    mGangPaiInterface:SetActive(true)
    for Index=1,#GangGroud,1 do
        local GangImage = mGangPaiInterface.transform:Find("BaiSeDi/HuangSeDi/GameObject/Convent/Template"..Index.."/MahJong/Image").gameObject
        local GangType = GangGroud[Index].PokerType
        local GangNumber = GangGroud[Index].PokerNumber
        GangImage.transform:GetComponent("Image"):ResetSpriteByName(GameData.GetMJPokerCardBackSpriteName(GangType,GangNumber))
    end
end

-- 手牌多杠选择
function GangPaiChoice(Index)
    mGangPaiInterface:SetActive(false)
    PengGangHuGuoButtonOnClick(6,GangGroud[Index].PokerType,GangGroud[Index].PokerNumber)
end

-- 碰牌显示
function PengPaiButtonDisplay(mShow)
    mPengPaiGameObject:SetActive(mShow)
end

-- 胡牌显示
function HuPaiButtonDisplay(mShow)
    mHuPaiGameObject:SetActive(mShow)
end

-- 过按钮显示
function GuoButtonDisplay()
    if mGangPaiGameObject.activeInHierarchy == true or mPengPaiGameObject.activeInHierarchy == true or mHuPaiGameObject.activeInHierarchy == true then
        mGuoGameObject:SetActive(true)
    else
        mGuoGameObject:SetActive(false)
    end
end

-- 随机音效索引
function RandomMusicIndex(number)
    return math.random(number)
end

-- 碰杠胡音效
function PGHMusic(Musictype)
    local index=0
    if Musictype == 2 then
        index = RandomMusicIndex(7)
        local music="MJ_peng_"..index
        PlayAudioClip(music)
    elseif Musictype == 3 then
        index = RandomMusicIndex(4)
        local music="MJ_gang_"..index
        PlayAudioClip(music)
    elseif Musictype == 4 then
        if mRoomData.pengganghuZMtype == 1 then
            index = RandomMusicIndex(2)
            local music="MJ_zimo_"..index
            PlayAudioClip(music)
        else
            index = RandomMusicIndex(6)
            local music="MJ_hu_"..index
            PlayAudioClip(music)
        end
    end
end

-- 出牌音效
function OutCardMusic(Musictype,number)
    local index=0
    if Musictype == MJ_QUE_Card_Type.Tong then
        if number == 1 then
            index = RandomMusicIndex(8)
        elseif number == 3 or number == 4 or number == 5 or number == 8 then
            index = RandomMusicIndex(6)
        elseif number == 2 or number == 9 then
            index = RandomMusicIndex(4)
        elseif number == 6 or number == 7 then
            index = RandomMusicIndex(2)
        end
        local music="MJ_Tong_"..number.."_"..index
        PlayAudioClip(music)
    elseif Musictype == MJ_QUE_Card_Type.Tiao then
        if number == 1 or number == 2 or number == 8 then
            index = RandomMusicIndex(8)
        elseif number == 4 or number == 6 or number == 9 then
            index = RandomMusicIndex(4)
        elseif number == 3 or number == 5 or number == 7 then
            index = RandomMusicIndex(2)
        end
        local music="MJ_Tiao_"..number.."_"..index
        PlayAudioClip(music)
    elseif Musictype == MJ_QUE_Card_Type.Wan then
        if number == 1 or number == 4 then
            index = RandomMusicIndex(6)
        elseif number == 2 or number == 3 or number == 9 then
            index = RandomMusicIndex(4)
        elseif number == 5 or number == 6 or number == 7 or number == 8 then
            index = RandomMusicIndex(2)
        end
        local music="MJ_Wan_"..number.."_"..index
        PlayAudioClip(music)
    end
    
end

-- 邀请按钮call
function ButtonInvite_OnClick()
    local tRoomID = mRoomData.RoomID
    local tRoomType = mRoomData.RoomType
    local tBet = mRoomData.MinBet
    local tEnterLimit = mRoomData.EnterBet
    local tBet = lua_NumberToStyle1String(tBet)
    local tEnterLimit = lua_NumberToStyle1String(tEnterLimit)
    GameData.OpenIniteUI(tRoomID, tRoomType, tBet, tEnterLimit)
end

--==============================--
--desc:音效播放接口
--time:2018-02-28 09:14:54
--@musicid:
--@return 
--==============================--
function PlayAudioClip(musicid)
    MusicMgr:PlaySoundEffect(musicid)
end

-- 麻将错误提示
function ErrorHints (mErrorHintsText)
    if mErrorHintsGameObject.activeSelf == false then
        local ErrorText=mErrorHintsGameObject.transform:Find("Text"):GetComponent("Text")
        local ErrorTween = mErrorHintsGameObject.transform:GetComponent("TweenPosition")
        ErrorText.text=mErrorHintsText
        mErrorHintsGameObject:SetActive(true)
        ErrorTween:ResetToBeginning()
        ErrorTween.duration=0.6
        ErrorTween:Play(true)
        this:DelayInvoke(1.5,function ()
            mErrorHintsGameObject:SetActive(false)
        end)
    end
end 


-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened( )
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.InitRoomState, ResetMJGameRoomToRoomState)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJAddPlayerEvent, OnNotifyMJAddPlayerEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJDeletePlayerEvent, OnNotifyMJDeletePlayerEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateRoomState, RefreshMJGameRoomByRoomStateSwitchTo)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJZBButtonOnClick, ZBImageIsShow)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJPlayerChuPai, PlayerChuPai)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJPlayerMoPai, playerMoPai)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJPlayerPengPai, playerPengPai)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJPlayerUpdateGold, UpdateGoldNumber)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJPlayerRank, GameInfoOption)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJGameWater, GameInfoOption)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJTheBureauGameWater, NowGameWaterDisplay)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJPlayerAdmitDefeat, PlayerThrowInTheTowel)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJPlayerBQGH, PlayerQiangGangHu)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJDQButtonOnClick, PlayerDingQueAnimtion)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJErrorHints, ErrorHints)
    
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.InitRoomState, ResetMJGameRoomToRoomState)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJAddPlayerEvent, OnNotifyMJAddPlayerEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJDeletePlayerEvent, OnNotifyMJDeletePlayerEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateRoomState, RefreshMJGameRoomByRoomStateSwitchTo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJZBButtonOnClick, ZBImageIsShow)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJPlayerChuPai, PlayerChuPai)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJPlayerMoPai, playerMoPai)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJPlayerPengPai, playerPengPai)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJPlayerUpdateGold, UpdateGoldNumber)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJPlayerRank, GameInfoOption)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJGameWater, GameInfoOption)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJTheBureauGameWater, NowGameWaterDisplay)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJPlayerAdmitDefeat, PlayerThrowInTheTowel)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJPlayerBQGH, PlayerQiangGangHu)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJDQButtonOnClick, PlayerDingQueAnimtion)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJErrorHints, ErrorHints)
    
end

-- 判断是否可以碰
function CheckCanPeng(tCardGroup, nQue, tSingleCard)
    if nQue == tSingleCard.PokerType then
        return false
    end
    local nNum = 0
    for k,v in ipairs(tCardGroup) do
        if v.PokerType == tSingleCard.PokerType and v.PokerNumber == tSingleCard.PokerNumber then
            nNum = nNum + 1
        end
    end
    if nNum >= 2 then
        return true
    end
    return false
end

-- 判断是否可以补杠
function CheckCanBuGang(tCardGroup,nQue, tSingleCard)
    for k,v in ipairs(tSingleCard) do
        if v.Mode == 1 then
            for k1,v1 in ipairs(tCardGroup) do
                if v1.PokerType == v.PokerType and v1.PokerNumber == v.PokerNumber then
                    return true
                end
            end
        end
    end

    return false
end

-- 判断是否可以杠
function CheckCanGang(tCardGroup,nQue, tSingleCard)
    if nQue == tSingleCard.PokerType then
        return false
    end
    local nNum = 0
    for k,v in ipairs(tCardGroup) do
        if v.PokerType == tSingleCard.PokerType and v.PokerNumber == tSingleCard.PokerNumber then
            nNum = nNum + 1
        end
    end
    if nNum >= 3 then
        return true
    end
    return false
end

function CheckSameCard(tCard1, tCard2)
    return tCard1.PokerType == tCard2.PokerType and tCard1.PokerNumber == tCard2.PokerNumber
end

-- 获得牌组花色数
function GetTypeNum(tCardGroup)
    local tTmp = {}
    for k,v in ipairs(tCardGroup) do
        tTmp[v.PokerType] = 1
    end
    return table.count(tTmp)
end

-- 判断玩家定缺牌型是否在牌组中
function CheckQueCardInGroup(tCardGroup, nQue)
    for k,v in ipairs(tCardGroup) do
        if v.PokerType == nQue then
            return true
        end
    end
    return false
end

-- 判断是否有四张相同的牌
function CheckAAAACard(tCardGroup, nQue)
    local tCount = {}
    for k,v in ipairs(tCardGroup) do
        if tCount[v.PokerType] == nil then
            tCount[v.PokerType] = {}
        end
        if tCount[v.PokerType][v.PokerNumber] == nil then
            tCount[v.PokerType][v.PokerNumber] = 0
        end
        tCount[v.PokerType][v.PokerNumber] = tCount[v.PokerType][v.PokerNumber] + 1
        if tCount[v.PokerType][v.PokerNumber] >= 4 and v.PokerType ~= nQue then
            return true, v.PokerType, v.PokerNumber
        end
    end
    return false, 0, 0
end

-- 将列表拼接为字符串
function GetStrByList(tList)
    local str = ""
    for k,v in ipairs(tList) do
        str = str .. v
    end
    return str
end

-- 将字符串数字转为table
function GetListByStr(strNum)
    local tNum = {}
    for i=1,#strNum do
        table.insert(tNum, string.sub(strNum, i, i))
    end
    return tNum
end

-- 将字符串数字每一位相加
function GetSumByStrNum(strNum)
    local nLen = string.len(strNum)
    local nSum = 0
    for i=1,nLen do
        nSum = nSum + tonumber(string.sub(strNum, i, i))
    end
    return nSum
end

-- 拆分表
local tSplit = {
    [3] = 3, [4] = 3,
    [31] = 30, [32] = 30, [33] = 33, [34] = 33, [44] = 33,
    [111] = 111, [112] = 111, [113] = 111, [114] = 114,
    [122] = 111, [123] = 111, [124] = 111,
    [133] = 111, [134] = 111,
    [141] = 141, [142] = 141, [143] = 141, [144] = 144,
    [222] = 222, [223] = 222, [224] = 222,
    [233] = 222, [234] = 222,
    [244] = 222,
    [311] = 300, [312] = 300, [313] = 300, [314] = 300,
    [322] = 300, [323] = 300, [324] = 300,
    [331] = 330, [332] = 330, [333] = 333, [334] = 333,
    [341] = 330, [342] = 330, [343] = 330, [344] = 333,
    [411] = 411, [412] = 411, [413] = 411, [414] = 414,
    [422] = 411, [423] = 411, [424] = 411,
    [433] = 411, [434] = 411,
    [441] = 441, [442] = 441, [443] = 441, [444] = 444
}

-- 胡牌可能的数量判断表
local tHuNum = {
    [2] = true, [5] = true, [8] = true, [11] = true, [14] = true
}

-- 检查段
function CheckPerDuan(nNum)
    while nNum ~= 0 do
        local strNum = tostring(nNum)
        if tSplit[tonumber(string.sub(strNum, 1, 3))] == nil then
            if tSplit[tonumber(string.sub(strNum, 1, 2))] == nil then
                if tSplit[tonumber(string.sub(strNum, 1, 1))] == nil then
                    return false
                else
                    nNum = tonumber(tostring(tonumber(string.sub(strNum, 1, 1)) - tSplit[tonumber(string.sub(strNum, 1, 1))]) .. string.sub(strNum, 2, string.len(strNum)))
                end
            else
                nNum = tonumber(tostring(tonumber(string.sub(strNum, 1, 2)) - tSplit[tonumber(string.sub(strNum, 1, 2))]) .. string.sub(strNum, 3, string.len(strNum)))
            end
        else
            nNum = tonumber(tostring(tonumber(string.sub(strNum, 1, 3)) - tSplit[tonumber(string.sub(strNum, 1, 3))]) .. string.sub(strNum, 4, string.len(strNum)))
        end
    end
    return true
end

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

-- 获取table中的元素个数, 包含map和array两部分的元素个数
function table.count(tTable)	
	if type(tTable) ~= "table" then
		return 0
	end
	
	local nCount = 0
	for _,v in pairs(tTable) do
		nCount = nCount + 1
	end
	return nCount
end

------------------------总体思路--------------------------
--1、将牌按连续性进行拆分，拆出的组合为3*n 或 3*n + 2，如果有例外，则不能胡。
--2、检查数量为3*n的连续段是否满足胡牌条件，如果都能满足，再用方法3检查3*n+2
--3、在连续的牌中，牌张数为3*n + 2的张数拆出可能的将牌
--4、扣除将牌后，分别检查各连续的段是否满足胡牌

--检查段的思路：
   --例：连续段为 1筒1筒1筒2筒3筒3筒4筒4筒5筒
       --数字表示为 31221

   --a、取3位数为key，从下表查询，如果有结果则扣除这个数字。
      --312取到结果330，则余下数字为1221
   --b、如果a步骤没有结果，则取2位数为key
   --c、如果b步骤没有结果，则取1位数为key
   --如果c失败，则不能胡
------------------------总体思路---------------------------
-- 判断是否胡牌
function CheckCanHu(tCardGroup, nQue, tSingleCard)
    local tCloneCardGroup = clone(tCardGroup)
    if tSingleCard ~= nil then
        table.insert(tCloneCardGroup, tSingleCard)
    end
    if tHuNum[#tCloneCardGroup] == nil then
        return false
    end
    if CheckQueCardInGroup(tCloneCardGroup, nQue) == true then
        return false
    end
    table.sort(tCloneCardGroup, MahjongSort1)

    if #tCloneCardGroup == 14 then
        -- 对对胡
        if CheckSameCard(tCloneCardGroup[1], tCloneCardGroup[2]) == true and CheckSameCard(tCloneCardGroup[3], tCloneCardGroup[4]) == true and
        CheckSameCard(tCloneCardGroup[5], tCloneCardGroup[6]) == true and CheckSameCard(tCloneCardGroup[7], tCloneCardGroup[8]) == true and 
        CheckSameCard(tCloneCardGroup[9], tCloneCardGroup[10]) == true and CheckSameCard(tCloneCardGroup[11], tCloneCardGroup[12]) == true and
        CheckSameCard(tCloneCardGroup[13], tCloneCardGroup[14]) == true then
            return true
        end
    end

    -- 将牌搭子胡
    local tTimesCount = {}  -- 各牌出现次数
    for k,v in ipairs(tCloneCardGroup) do
        if tTimesCount[v.PokerType] == nil then
            tTimesCount[v.PokerType] = {}
        end
        if tTimesCount[v.PokerType][v.PokerNumber] == nil then
            tTimesCount[v.PokerType][v.PokerNumber] = 0
        end
        tTimesCount[v.PokerType][v.PokerNumber] = tTimesCount[v.PokerType][v.PokerNumber] + 1
    end
    local tLianXuDuan = {}
    for k,v in pairs(tTimesCount) do
        local i = 1
        local tTmp = {}
        while i < 10 do
            if v[i] ~= nil then
                table.insert(tTmp, v[i])
            else
                if #tTmp ~= 0 then
                    table.insert(tLianXuDuan, tonumber(GetStrByList(tTmp)))
                    tTmp = {}
                end
            end
            i = i + 1
            if i == 10 and #tTmp ~= 0 then
                table.insert(tLianXuDuan, tonumber(GetStrByList(tTmp)))
            end
        end
    end
    local nZero = 0
    local tZero = {}
    local nOne = 0
    local nTwo = 0
    local tTwo = {}
    for k,v in ipairs(tLianXuDuan) do
        local nSum = GetSumByStrNum(tostring(v))
        if nSum % 3 == 0 then
            nZero = nZero + 1
            table.insert(tZero, v)
        elseif nSum % 3 == 1 then
            nOne = nOne + 1
        elseif nSum % 3 == 2 then
            nTwo = nTwo + 1
            table.insert(tTwo, v)
        end
    end
    if nOne ~= 0 or nTwo > 1 then
        return false
    end
    for k,v in ipairs(tZero) do
        if CheckPerDuan(v) == false then
            return false
        end
    end
    local tRemoveJiang = {}
    local nFlag = 0
    local bTmp = false
    for k,v in ipairs(tTwo) do
        local tTmp = {}
        local strNum = tostring(v)
        for i=1,#strNum do
            if tonumber(string.sub(strNum, i, i)) >= 2 then
                table.insert(tTmp, i)
            end
        end
        for k1,v1 in ipairs(tTmp) do
            local tNum = GetListByStr(strNum)
            nFlag = 1
            if v1 ~= 1 and v1 ~= #strNum and tonumber(string.sub(strNum, v1, v1)) == 2 then
                table.insert(tRemoveJiang, tonumber(string.sub(strNum, 1, v1-1)))
                table.insert(tRemoveJiang, tonumber(string.sub(strNum, v1+1, #strNum)))
                if CheckPerDuan(tonumber(string.sub(strNum, 1, v1-1))) and CheckPerDuan(tonumber(string.sub(strNum, v1+1, #strNum))) then
                    bTmp = true
                    break
                end
            else
                if tonumber(string.sub(strNum, v1, v1)) == 2 then
                    table.remove(tNum, v1)
                else
                    tNum[v1] = tostring(tonumber(tNum[v1]) - 2)
                end
                table.insert(tRemoveJiang, tonumber(GetStrByList(tNum)))
                local nNum = tonumber(GetStrByList(tNum))
                if nNum == nil or CheckPerDuan(nNum) == true then
                    bTmp = true
                    break
                end
            end
        end
    end
    if bTmp == true then
        return true
    end

    return false
end

-- 判断胡牌类型
function CheckHuType(tCardGroup, tCardPeng, tCardGang, tSingleCard)
    local tCloneCardGroup = clone(tCardGroup)
    if tSingleCard ~= nil then
        table.insert(tCloneCardGroup, tSingleCard)
    end
    table.sort(tCloneCardGroup, MahjongSort1)

    local nTypeNum = GetTypeNum(tCloneCardGroup)
    if #tCloneCardGroup == 14 then
        -- 对对胡
        if CheckSameCard(tCloneCardGroup[1], tCloneCardGroup[2]) == true and CheckSameCard(tCloneCardGroup[3], tCloneCardGroup[4]) == true and
        CheckSameCard(tCloneCardGroup[5], tCloneCardGroup[6]) == true and CheckSameCard(tCloneCardGroup[7], tCloneCardGroup[8]) == true and 
        CheckSameCard(tCloneCardGroup[9], tCloneCardGroup[10]) == true and CheckSameCard(tCloneCardGroup[11], tCloneCardGroup[12]) == true and
        CheckSameCard(tCloneCardGroup[13], tCloneCardGroup[14]) == true then
            if nTypeNum == 1 then
                if CheckAAAACard(tCloneCardGroup) == true then
                    -- 清龙七对
                    return tHuType.QINGLONGQIDUI
                else
                    -- 清暗七对
                    return tHuType.QINGANQIDUI
                end
            else
                if CheckAAAACard(tCloneCardGroup) == true then
                    -- 龙七对
                    return tHuType.LONGQIDUI
                else
                    -- 暗七对
                    return tHuType.ANQIDUI
                end
            end
        end
    end

    local tTimesCount = {}  -- 各牌出现次数
    for k,v in ipairs(tCloneCardGroup) do
        if tTimesCount[v.PokerType] == nil then
            tTimesCount[v.PokerType] = {}
        end
        if tTimesCount[v.PokerType][v.PokerNumber] == nil then
            tTimesCount[v.PokerType][v.PokerNumber] = 0
        end
        tTimesCount[v.PokerType][v.PokerNumber] = tTimesCount[v.PokerType][v.PokerNumber] + 1
    end
    local nOne = 0
    local nTwo = 0
    local nThree = 0
    local nFour = 0
    for k,v in pairs(tTimesCount) do
        for k1,v1 in pairs(v) do
            if v1 == 1 then
                nOne = nOne + 1
            elseif v1 == 2 then
                nTwo = nTwo + 1
            elseif v1 == 3 then
                nThree = nThree + 1
            else
                nFour = nFour + 1
            end
        end
    end
    -- 碰碰胡
    if nOne == 0 and nTwo == 1 and nThree > 0 and nFour == 0 then
        if nTypeNum == 1 then
            return tHuType.QINGPENG
        end
        return tHuType.PENGPENGHU
    -- 金钩钓or十八罗汉
    elseif nOne == 0 and nTwo == 1 and nThree == 0 and nFour == 0 then
        local tTmp = {}
        for k,v in ipairs(tCloneCardGroup) do
            tTmp[v.PokerType] = 1
        end
        for k,v in ipairs(tCardPeng) do
            tTmp[v.PokerType] = 1
        end
        for k,v in ipairs(tCardGang) do
            tTmp[v.PokerType] = 1
        end
        -- 十八罗汉
        if #tCardPeng == 0 then
            if table.count(tTmp) == 1 then
                return tHuType.QINGSHIBA
            end
            return tHuType.SHIBALUOHAN
        -- 金钩钓
        else
            if table.count(tTmp) == 1 then
                return tHuType.QINGJINGOUDIAO
            end
            return tHuType.JINGOUDIAO
        end
    end

    -- 清一色
    if nTypeNum == 1 then
        return tHuType.QINGYISE
    end
    -- 平胡
    return tHuType.PINGHU
end

function CheckCardIsInCardGroup(tCardGroup, tCard)
    for k,v in pairs(tCardGroup) do
        if CheckSameCard(v, tCard) then
            return true
        end
    end
    return false
end

function PushNotSameCardIntoList(tList, tCard)
    if CheckCardIsInCardGroup(tList, tCard) == false then
        table.insert(tList, tCard)
    end
end
-- 是否听牌(要检验的牌组，定的缺)
function CheckIsTingPai(tCardGroup, nQue)
    local tTryCard = {}
    for k,v in ipairs(tCardGroup) do
        if v.PokerType == nQue then
            return false
        end
        PushNotSameCardIntoList(tTryCard, v)
        if v.PokerNumber == 1 then
            PushNotSameCardIntoList(tTryCard, {PokerType=v.PokerType, PokerNumber=2})
        elseif v.PokerNumber == 9 then
            PushNotSameCardIntoList(tTryCard, {PokerType=v.PokerType, PokerNumber=8})
        else
            PushNotSameCardIntoList(tTryCard, {PokerType=v.PokerType, PokerNumber=v.PokerNumber-1})
            PushNotSameCardIntoList(tTryCard, {PokerType=v.PokerType, PokerNumber=v.PokerNumber+1})
        end
    end
    for k,v in ipairs(tTryCard) do
        if CheckCanHu(tCardGroup, nQue, v) then
            return true
        end
    end
    return false
end

function CheckTingPaiMaybeType(tCardGroup, tPengCard, tGangCard, nQue)
    local tTryCard = {}
    for k,v in ipairs(tCardGroup) do
        if v.PokerType == nQue then
            return false
        end
        PushNotSameCardIntoList(tTryCard, v)
        if v.PokerNumber == 1 then
            PushNotSameCardIntoList(tTryCard, {PokerType=v.PokerType, PokerNumber=2})
        elseif v.PokerNumber == 9 then
            PushNotSameCardIntoList(tTryCard, {PokerType=v.PokerType, PokerNumber=8})
        else
            PushNotSameCardIntoList(tTryCard, {PokerType=v.PokerType, PokerNumber=v.PokerNumber-1})
            PushNotSameCardIntoList(tTryCard, {PokerType=v.PokerType, PokerNumber=v.PokerNumber+1})
        end
    end
    local tResult = {}
    for k,v in ipairs(tTryCard) do
        if CheckCanHu(tCardGroup, nQue, v) then
            local nType = CheckHuType(tCardGroup, tPengCard, tGangCard, v)
            table.insert(tResult, {v.PokerType, v.PokerNumber, nType})
        end
    end
    return tResult
end

-- 获取手牌可杠数量
-- 如果有单牌，把单牌传进来

function GetPerCardCountList(tCardGroup,tPengGroup)
                                --(手牌，碰牌)
    local JieGuo = {}
    local tTimesCount = {}
    for k,v in ipairs(tCardGroup) do
        if tTimesCount[v.PokerType] == nil then
            tTimesCount[v.PokerType] = {}
        end
        if tTimesCount[v.PokerType][v.PokerNumber] == nil then
            tTimesCount[v.PokerType][v.PokerNumber] = 0
        end
        tTimesCount[v.PokerType][v.PokerNumber] = tTimesCount[v.PokerType][v.PokerNumber] + 1
        if tTimesCount[v.PokerType][v.PokerNumber] >= 4 then
            table.insert( JieGuo, {PokerType=v.PokerType,PokerNumber=v.PokerNumber})
        end
        for Index=1,#tPengGroup,1 do
            if v.PokerType == tPengGroup[Index].PokerType and  v.PokerNumber == tPengGroup[Index].PokerNumber then
                table.insert( JieGuo, {PokerType=v.PokerType,PokerNumber=v.PokerNumber} )
            end
        end
    end
    return JieGuo
end

--=============================LBS位置信息模块 Start=========================

--=============================LBS位置信息模块 End=========================

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    mMyTransform = this.transform
    mRoomData = GameData.RoomInfo.CurrentRoom
    InitUIElement()
    AddButtonHandlers()
    GetSetPlayer4CardPosition()
    ResetMJGameRoomToRoomState(mRoomData.RoomState)
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    local mScreen = CS.UnityEngine.Screen
    mScreen.autorotateToLandscapeLeft = true  
    mScreen.autorotateToLandscapeRight = false
    mScreen.autorotateToPortrait = false
    mScreen.autorotateToPortraitUpsideDown = false
    mScreen.orientation = 3

    -- CS.Utility.AutorotateToLandscapeLeft()
    
    MusicMgr:PlayBackMusic("playingInMJGame")
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    local mScreen = CS.UnityEngine.Screen
    mScreen.autorotateToLandscapeLeft = false  
    mScreen.autorotateToLandscapeRight = false
    mScreen.autorotateToPortrait = true
    mScreen.autorotateToPortraitUpsideDown = false

    mScreen.orientation = CS.UnityEngine.ScreenOrientation.Portrait
end

-- Unity MonoBehavior Update 时调用此方法
function Update()
    if mRoomData.RoomState >= ROOM_STATE_MJ.CHUPAI and mRoomData.RoomState <= ROOM_STATE_MJ.WAIT_END then
        mRoomData.MJCountDown=mRoomData.MJCountDown-mTime.deltaTime
        if mRoomData.MJCountDown <= 0 then
            mRoomData.MJCountDown = 0
        end
        UpdateCountDownTiemDisolay()
        PlayerLightDisplay()
    end
end