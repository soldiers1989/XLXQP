
MJGameUI={}
local mTime = CS.UnityEngine.Time
local Screen = CS.UnityEngine.Screen
-- 当前房间信息数据
local mRoomData = { }
-- 主角数据
local mMasterData = {}
-- UI组件根节点
local mMyTransform = nil


local mReturnGameObject = nil                   -- 返回菜单组件
local mZBButtonGameObject = nil                 -- 准备按钮组件
local mRoomNumberGameObject = nil               -- 房间密码组件
local mRoomNumberText = nil                     -- 房间密码Text
local mExitButtonScript = nil                   -- 退出房间按钮组件Script
local mResultGameObject = nil                   -- 结算组件
local mCountDownLight={}                        -- 倒计时光圈
local mErrorHintsGameObject = nil               -- 错误提示
local mPlayerUINodes = {}
local mCountingPlateGameObject =nil             -- 计数板组件
local mCountingPlateText = {}                   -- 计数Text
local mPromptButtonGameObject = nil             -- 提示按钮组件
local mOutPokerButtonGameObject = nil           -- 出牌按钮组件
local mOutPokerButton = nil                     -- 出牌按钮
local mSetInterfaceObject = nil                 -- 设置界面

local mPlayerPokerGameObject1 = nil             -- 玩家1扑克牌显示组件
local mPlayerPokerGameObject2 = nil             -- 玩家2扑克牌显示组件
local mPlayerPokerGameObject3 = nil             -- 玩家3扑克牌显示组件
local mPlayerPokerNumberText1 = nil             -- 玩家1剩余扑克牌数量Text
local mPlayerPokerNumberText2 = nil             -- 玩家2剩余扑克牌数量Text
local mPlayerPokerNumberObject1 = nil           -- 玩家1当前扑克牌数量
local mPlayerPokerNumberObject2 = nil           -- 玩家2当前扑克牌数量

local mPlayerRemainingPokerCards1={}            -- 结算状态玩家1剩余扑克
local mPlayerRemainingPokerCards2={}            -- 结算状态玩家2剩余扑克

local mCanceRobotButtonlObject = nil             -- 取消托管组件
local mRobotButtonlObject = nil                  -- 托管组件
local mRobotPokerMaskObject = nil                -- 托管遮罩
local BetMin1 = nil                    -- 底注Text1
local BetMin2 = nil                    -- 底注Text2

-- 玩家本身扑克牌组件
local PlayerHavePoker={}
-- 玩家1发牌组件
local Player1HavePoker = {}
-- 玩家2发牌组件
local Player2HavePoker = {}
-- 玩家1手牌
local Player1CardTable={}
-- 玩家2手牌
local Player2CardTable={}
-- 玩家本身扑克牌图片
local PlayerPokersImage = {}
-- 玩家扑克牌状态(1未选中 2已选中 3已出牌)
local SelectState={}
-- 玩家扑克牌Y轴
local PokerPosition_Y = 0
-- 玩家手牌GridLayoutGroup组件
local PlayerGrid=nil
-- 玩家出牌信息
local OutCard={}
-- 玩家检查扑克牌信息
local CheckPokerState = {}

-- 玩家出牌模板
local OutCardTemplate = nil
-- 玩家出牌起点
local OutCardStart={}
-- 玩家本身扑克牌位置组件
local Player3PokerPosition={}
-- 玩家扑克牌y轴位置
local Player3PokerPosition_Y={}
-- 玩家出牌终点
local OutCardEnt = nil
-- 玩家出牌终点2
local OutCardEnt2 = nil
-- 玩家出牌Tween组件
local OutCardTween = nil
-- 牌型艺术字
local OutPokerType = nil
-- 牌型艺术字Tween组件
local OutPokerTypeTween = nil
-- 牌型艺术字Image组件
local OutPokerImage =nil
-- 牌型艺术字起点
local OutPokerTypePosition={}

-- 💣图片
local BombAnimtionObject = nil
-- 💣光焰
local BombLightAnimtionObject = nil
-- 💣位置
local BombPosition={}

-- ✈图片1
local PlanAnimtionObject1 = nil
-- ✈图片2
local PlanAnimtionObject2 = nil

-- 黑桃3
local PokerThree = nil
-- 飞牌目标位置
local PlyPokerPosition = {}

-- 桌面Loading动画
local LoadingObject=nil

--TUDOU
-- 结算特效
local particleEffect_JieSuan = nil;

-- 玩家UI节点
local PlayerUINode = 
{
    RootGameObject = nil,
    HeadRoot = nil,
    HeadIcon = nil,
    NameText = nil,
    GoldText = nil,
    ZBImage = nil,
    Points = { },
    WinText = nil,                              -- 赢钱Text
    LoseText = nil,                             -- 输钱Text
    CountDownObject = nil,
    CountDownText = nil,
    YaoBuQi = nil,
    AllClose = nil,
    AllPay = nil,
    Alert = nil,
}

-- 结算界面UI节点
local mSettlementGameObject =
{
    Object = nil,                               -- 结算界面
    GoldText1 = nil,                            -- 玩家本局金币+变化Text
    GoldText2 = nil,                            -- 玩家本局金币-变化Text
    GoldTextObject1 = nil,                      -- 玩家金币Text1组件
    GoldTextObject2 = nil,                      -- 玩家金币Text2组件
    CardsText = nil,                            -- 赢牌数量Text
    BombsText = nil,                            -- 💣数量Text
    AgainButton = nil,                          -- 继续游戏Button
    ExitButton = nil,                           -- 换桌Button
    Victory = nil,                              -- 胜利图标
    VictoryLight = nil,                         -- 胜利光圈
    VictoryLight2 = nil,                        -- 胜利光圈2
    Fail = nil,                                 -- 失败图标
    FailLight = nil,                            -- 失败光圈
    CountDownText1 = nil,                       -- 倒计时文本1
    CountDownText2 = nil,                       -- 倒计时文本2
    Player1 =                                   -- 1号位置玩家UI节点
    {
        NameText = nil,                         -- 1号位置玩家名字Text
        CardsText = nil,                        -- 1号位置玩家余牌数量Text
        BombsText = nil,                        -- 1号位置玩家💣数量Text
        GoldText = nil,                         -- 1号位置玩家金币变化Text
    },
    Player2 =                                   -- 2号位置玩家UI节点
    {
        NameText = nil,                         -- 2号位置玩家名字Text
        CardsText = nil,                        -- 2号位置玩家余牌数量Text
        BombsText = nil,                        -- 2号位置玩家💣数量Text
        GoldText = nil,                         -- 2号位置玩家金币变化Text
    }
}

-- 规则界面UI节点
local mGameRuleGameObject = 
{
    Object = nil,                               -- 规则界面
    Rule = nil,                                 -- 基本规则
    PokerType = nil,                            -- 基本牌型
    Settlement = nil,                           -- 结算
    SpecialType = nil,                          -- 特殊牌型
    RuleText = {},                             -- 基本规则字
}

local mMasterPosition = MAX_PDKZUJU_ROOM_PLAYER

local DownTime=0
-- 倒计时三秒音乐
local CountDowenMusic = true
-- 结算倒计时
local SettlementCountDown = false

-- 先手倒计时
local FristPlayerOutTime = false

-- 玩家剩余扑克牌
local CountingPlateCardNumber = {3,1,4,4,4,4,4,4,4,4,4,4,4}

local m_CheckColorOf1 = CS.UnityEngine.Color(41 / 255, 243 / 255, 0)
local m_CheckColorOf2 = CS.UnityEngine.Color(230 / 255, 251 / 255, 34 / 255)
local m_CheckColorOf3 = CS.UnityEngine.Color(227 / 255, 50 / 255, 8 / 255)

-- 两家要不起
local YaoBuQiNumber = 0

-- 是否开始等待准备倒计时
local IsReadCountDown=false

function InitUIElement()
    mReturnGameObject = mMyTransform:Find('Canvas/ReturnButton/ReturnButton1').gameObject
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/MaskButton').gameObject:SetActive(true)
    mZBButtonGameObject = mMyTransform:Find('Canvas/MasterInfo/ZBButton').gameObject
    LoadingObject = mMyTransform:Find('Canvas/Loading').gameObject
    mRoomNumberGameObject = mMyTransform:Find('Canvas/RoomNumber').gameObject
    mRoomNumberText = mMyTransform:Find('Canvas/RoomNumber/Text'):GetComponent("Text")
    BetMin1 = mMyTransform:Find('Canvas/RoomInfo/BetMin1/Text'):GetComponent('Text')
    BetMin2 = mMyTransform:Find('Canvas/RoomInfo/BetMin2/Text'):GetComponent('Text')
    mExitButtonScript = mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/ExitButton'):GetComponent('Button')
    mCountingPlateGameObject = mMyTransform:Find('Canvas/CountingPlate').gameObject
    for Index = 1, 13, 1 do
        mCountingPlateText[Index] = mCountingPlateGameObject.transform:Find('Bank/PromptNumber/Text'..Index):GetComponent('Text')
    end
    mRobotPokerMaskObject = mMyTransform:Find('Canvas/PlayerCard/PokerMask').gameObject
    mSettlementGameObject.Object = mMyTransform:Find('Canvas/SettlementInterface').gameObject
    mSettlementGameObject.GoldText1 = mSettlementGameObject.Object.transform:Find('GameObject/Gold/Text1'):GetComponent("Text")
    mSettlementGameObject.GoldText2 = mSettlementGameObject.Object.transform:Find('GameObject/Gold/Text2'):GetComponent("Text")
    mSettlementGameObject.GoldTextObject1 = mSettlementGameObject.Object.transform:Find('GameObject/Gold/Text1').gameObject
    mSettlementGameObject.GoldTextObject2 = mSettlementGameObject.Object.transform:Find('GameObject/Gold/Text2').gameObject
    mSettlementGameObject.CardsText = mSettlementGameObject.Object.transform:Find('GameObject/Cards'):GetComponent("Text")
    mSettlementGameObject.BombsText = mSettlementGameObject.Object.transform:Find('GameObject/Booms'):GetComponent("Text")
    mSettlementGameObject.Victory = mSettlementGameObject.Object.transform:Find('GameObject/Canvas/Victory').gameObject
    --TUDOU
    mSettlementGameObject.ParticleEffect = mSettlementGameObject.Object.transform:Find("GameObject/jiesuan_win").gameObject;
    mSettlementGameObject.VictoryLight = mSettlementGameObject.Object.transform:Find('GameObject/VictoryLight').gameObject
    mSettlementGameObject.VictoryLight2 = mSettlementGameObject.Object.transform:Find('GameObject/VictoryLight2').gameObject
    mSettlementGameObject.Fail = mSettlementGameObject.Object.transform:Find('GameObject/Fail').gameObject
    mSettlementGameObject.FailLight = mSettlementGameObject.Object.transform:Find('GameObject/FailLight').gameObject
    mSettlementGameObject.Player1.NameText = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player1/Name'):GetComponent("Text")
    mSettlementGameObject.Player1.CardsText = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player1/Cards'):GetComponent("Text")
    mSettlementGameObject.Player1.BombsText = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player1/Booms'):GetComponent("Text")
    mSettlementGameObject.Player1.GoldText = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player1/Gold'):GetComponent("Text")
    mSettlementGameObject.Player2.NameText = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player2/Name'):GetComponent("Text")
    mSettlementGameObject.Player2.CardsText = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player2/Cards'):GetComponent("Text")
    mSettlementGameObject.Player2.BombsText = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player2/Booms'):GetComponent("Text")
    mSettlementGameObject.Player2.GoldText = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player2/Gold'):GetComponent("Text")
    mSettlementGameObject.CountDownText1 = mSettlementGameObject.Object.transform:Find('GameObject/Again/Text'):GetComponent("Text")
    mSettlementGameObject.CountDownText2 = mMyTransform:Find('Canvas/Buttons/AgainButton/Text'):GetComponent("Text")
    mSettlementGameObject.ExitButton = mMyTransform:Find('Canvas/Buttons/ExitButton').gameObject
    mSettlementGameObject.AgainButton = mMyTransform:Find('Canvas/Buttons/AgainButton').gameObject
    
    mGameRuleGameObject.Object = mMyTransform:Find('Canvas/Rule').gameObject
    mGameRuleGameObject.Rule = mMyTransform:Find('Canvas/Rule/Bank/Info/Rule').gameObject
    mGameRuleGameObject.PokerType = mMyTransform:Find('Canvas/Rule/Bank/Info/Type').gameObject
    mGameRuleGameObject.Settlement = mMyTransform:Find('Canvas/Rule/Bank/Info/Settlement').gameObject
    mGameRuleGameObject.SpecialType = mMyTransform:Find('Canvas/Rule/Bank/Info/SpecialType').gameObject

    mCanceRobotButtonlObject = mMyTransform:Find('Canvas/Buttons/CanceRobotButtonl').gameObject
    mRobotButtonlObject = mMyTransform:Find('Canvas/Buttons/RobotButton'):GetComponent("Button")

    for Index = 1,4,1 do
        mGameRuleGameObject.RuleText[Index] = mMyTransform:Find('Canvas/Rule/Bank/Button/Toggle'..Index..'/Background/Checkmark/Image').gameObject
    end
    
    PokerThree = mMyTransform:Find("Canvas/PlayerCard/poker").gameObject
    mSetInterfaceObject = mMyTransform:Find("Canvas/Setting").gameObject

    mErrorHintsGameObject = mMyTransform:Find("Canvas/TiShi").gameObject

    mPlayerPokerGameObject1 = mMyTransform:Find('Canvas/PlayerCard/player1').gameObject
    mPlayerPokerGameObject2 = mMyTransform:Find('Canvas/PlayerCard/player2').gameObject
    mPlayerPokerGameObject3 = mMyTransform:Find('Canvas/PlayerCard/player3').gameObject
    mPlayerPokerNumberText1 = mPlayerPokerGameObject1.transform:Find('Card/Number'):GetComponent("Text")
    mPlayerPokerNumberText2 = mPlayerPokerGameObject2.transform:Find('Card/Number'):GetComponent("Text")
    mPlayerPokerNumberObject1 = mPlayerPokerGameObject1.transform:Find('Card').gameObject
    mPlayerPokerNumberObject2 = mPlayerPokerGameObject2.transform:Find('Card').gameObject

    for Index=1,16,1 do
        Player1HavePoker[Index] = mMyTransform:Find('Canvas/PlayerCard/player1/Cards/poker'..Index).gameObject
        Player2HavePoker[Index] = mMyTransform:Find('Canvas/PlayerCard/player2/Cards/poker'..Index).gameObject
        PlayerHavePoker[Index] = mPlayerPokerGameObject3.transform:Find('Card/Poker'..Index).gameObject
        Player3PokerPosition[Index] = mMyTransform:Find('Canvas/PlayerCard/player3pokers/Card/Poker'..Index).gameObject
        Player3PokerPosition_Y[Index] = mPlayerPokerGameObject3.transform:Find('Card_y/Poker'..Index).gameObject
        PlayerPokersImage[Index] = PlayerHavePoker[Index].transform:GetComponent("Image")
        mPlayerRemainingPokerCards1[Index] = mMyTransform:Find('Canvas/RemainingPokerCards/player1/Card/Poker'..Index).gameObject
        mPlayerRemainingPokerCards2[Index] = mMyTransform:Find('Canvas/RemainingPokerCards/player2/Card/Poker'..Index).gameObject
        GameObjectSetActive(mPlayerRemainingPokerCards1[Index],false)
        GameObjectSetActive(mPlayerRemainingPokerCards2[Index],false)
        SelectState[Index]=1
        CheckPokerState[Index]=PlayerHavePoker[Index].transform:GetComponent("PDKCheckPokerState")
    end
    
    for position = 1, MAX_PDKZUJU_ROOM_PLAYER, 1 do
        local childItem = mMyTransform:Find('Canvas/Players/Player'..position)
        mPlayerUINodes[position] = clone(PlayerUINode)
        mPlayerUINodes[position].RootGameObject = childItem.gameObject
        mPlayerUINodes[position].HeadRoot = childItem:Find('Head').gameObject
        mPlayerUINodes[position].HeadIcon = childItem:Find('Head/Icon'):GetComponent('Image')
        mPlayerUINodes[position].NameText = childItem:Find('Head/NameText'):GetComponent('Text')
        mPlayerUINodes[position].GoldText = childItem:Find('Head/Image/GoldText'):GetComponent('Text')
        mPlayerUINodes[position].WinText = mMyTransform:Find('Canvas/Result/Player'..position..'/WinText'):GetComponent('Text')
        mPlayerUINodes[position].LoseText = mMyTransform:Find('Canvas/Result/Player'..position..'/LoseText'):GetComponent('Text')
        mPlayerUINodes[position].CountDownObject = childItem:Find('Head/CountDown'..position).gameObject
        mPlayerUINodes[position].CountDownText = childItem:Find('Head/CountDown'..position):GetComponent("Text")
        mPlayerUINodes[position].Alert = childItem:Find("Alert").gameObject
        OutCardStart[position] = mMyTransform:Find('Canvas/OutPokerPosition/PlayerPosition'..position).gameObject
        OutPokerTypePosition[position] = mMyTransform:Find('Canvas/OutPokerPosition/TypePosition'..position).gameObject
        PlyPokerPosition[position] = mMyTransform:Find('Canvas/PlayerCard/poker'..position).gameObject
        BombPosition[position] = mMyTransform:Find('Canvas/OutPokerPosition/BombPosition'..position).gameObject
    end
    for Index=1,2,1 do
        mCountDownLight[Index]=mMyTransform:Find('Canvas/Players/Player'..Index..'/Head/CountDown'..Index).gameObject
        mPlayerUINodes[Index].YaoBuQi = mMyTransform:Find('Canvas/Players/Player'..Index..'/YaoBuQi').gameObject
        mPlayerUINodes[Index].ZBImage = mMyTransform:Find('Canvas/Players/Player'..Index..'/ZBImage').gameObject
        ResetPDKPlayerUINode(mPlayerUINodes[position])
    end
    mCountDownLight[3] = mMyTransform:Find('Canvas/Players/CountDown3').gameObject
    mPlayerUINodes[3].YaoBuQi = mMyTransform:Find('Canvas/Players/YaoBuQi').gameObject
    mPlayerUINodes[3].ZBImage = mMyTransform:Find('Canvas/Players/ZBImage').gameObject
    ResetPDKPlayerUINode(mPlayerUINodes[3])
    for Index=1,10,1 do
        Player1CardTable[Index] = mMyTransform:Find('Canvas/PlayerCard/player1/Poker/poker'..Index).gameObject
        Player2CardTable[Index] = mMyTransform:Find('Canvas/PlayerCard/player2/Poker/poker'..Index).gameObject
    end
    mPlayerUINodes[3].AllClose = mSettlementGameObject.Object.transform:Find('GameObject/AllClose').gameObject
    mPlayerUINodes[1].AllClose = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player1/AllClose').gameObject
    mPlayerUINodes[2].AllClose = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player2/AllClose').gameObject
    mPlayerUINodes[3].AllPay = mSettlementGameObject.Object.transform:Find('GameObject/AllPay').gameObject
    mPlayerUINodes[1].AllPay = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player1/AllPay').gameObject
    mPlayerUINodes[2].AllPay = mSettlementGameObject.Object.transform:Find('GameObject/PlayerInfo/player2/AllPay').gameObject

    PokerPosition_Y = this.transform:Find("Canvas/PlayerCard/player3/Card/Poker1").gameObject.transform.localPosition.y
    PlayerGrid = this.transform:Find("Canvas/PlayerCard/player3/Card"):GetComponent("GridLayoutGroup")
    mPromptButtonGameObject = mMyTransform:Find('Canvas/Buttons/PromptButton').gameObject
    mOutPokerButtonGameObject = mMyTransform:Find('Canvas/Buttons/OutPokerButton').gameObject
    mOutPokerButton = mOutPokerButtonGameObject.transform:GetComponent("Button")

    OutCardTemplate = mMyTransform:Find('Canvas/OutPoker').gameObject
    OutCardEnt = mMyTransform:Find('Canvas/OutPokerPosition/EndPosition').gameObject
    OutCardEnt2 = mMyTransform:Find('Canvas/OutPokerPosition/EndPosition2').gameObject

    OutPokerType = mMyTransform:Find('Canvas/OutPokerPosition/Type').gameObject
    OutPokerTypeTween = OutPokerType:GetComponent("TweenPosition")
    OutPokerImage = OutPokerType:GetComponent("Image")

    BombAnimtionObject = mMyTransform:Find('Canvas/OutPokerPosition/Boom').gameObject
    BombLightAnimtionObject = mMyTransform:Find('Canvas/OutPokerPosition/BoomLight').gameObject

    PlanAnimtionObject1 = mMyTransform:Find('Canvas/OutPokerPosition/Plan/Plan1').gameObject
    PlanAnimtionObject2 = mMyTransform:Find('Canvas/OutPokerPosition/Plan/Plan2').gameObject

    --个人信息 增加音乐和音效
	mMyTransform:Find('Canvas/Setting/Window/Panel/Switch1'):GetComponent("SwitchControl").IsOn = MusicMgr.isMuteBackMusic
    mMyTransform:Find('Canvas/Setting/Window/Panel/Switch2'):GetComponent("SwitchControl").IsOn = MusicMgr.isMuteSoundEffect
    
    -- 由于 SwitchControl 状态变化会触发回调 导致开启界面就会播放音效 因此滞后于状态值设置
	mMyTransform:Find('Canvas/Setting/Window/Panel/Switch1'):GetComponent("SwitchControl").onValueChanged:AddListener(BackMusicSwithControl_OnValueChanged)
	mMyTransform:Find('Canvas/Setting/Window/Panel/Switch2'):GetComponent("SwitchControl").onValueChanged:AddListener(EffectMusicSwithControl_OnValueChanged)

    mErrorHintsGameObject:SetActive(false)
    mSettlementGameObject.ParticleEffect:SetActive(false);
    mSettlementGameObject.Object:SetActive(false)
    mReturnGameObject:SetActive(false)
    mZBButtonGameObject:SetActive(false)
    mPlayerPokerGameObject1:SetActive(false)
    mPlayerPokerGameObject2:SetActive(false)
    mPlayerPokerGameObject3:SetActive(false)
    mCountingPlateGameObject:SetActive(false)

    --TUDOU
    particleEffect_JieSuan = this.transform:Find("Canvas/SettlementInterface/GameObject/jiesuan_win").gameObject;

end

function AddButtonHandlers()
    mMyTransform:Find('Canvas/ReturnButton'):GetComponent("Button").onClick:AddListener(ReturnTransformSetActive)
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1'):GetComponent("Button").onClick:AddListener(ReturnTransformSetActive)
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/MaskButton'):GetComponent("Button").onClick:AddListener(ReturnTransformSetActive)
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/ExitButton'):GetComponent("Button").onClick:AddListener(ExitButton_OnClick)
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/Set'):GetComponent("Button").onClick:AddListener(function ()SetInterfaceDisplay(true)end)
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/Rank'):GetComponent("Button").onClick:AddListener(RankButtonOnClick)

    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/GameRuleButton'):GetComponent("Button").onClick:AddListener(function() GameRuleDisplay(true) end)
    mMyTransform:Find("Canvas/Setting/Window/Title/ReturnButton"):GetComponent("Button").onClick:AddListener(function ()SetInterfaceDisplay(false)end)
    mMyTransform:Find('Canvas/MasterInfo/ZBButton'):GetComponent("Button").onClick:AddListener(PlayerSendRead)

    mMyTransform:Find('Canvas/PlayerCard/Mask'):GetComponent('Button').onClick:AddListener(PokerMaskButtonOnClick)

    mMyTransform:Find('Canvas/Buttons/ButtonInvite1'):GetComponent('Button').onClick:AddListener( ButtonInvite_OnClick)
    mMyTransform:Find('Canvas/Buttons/OutPokerButton'):GetComponent('Button').onClick:AddListener( PlayerOutCard)
    mMyTransform:Find('Canvas/Buttons/PromptButton'):GetComponent('Button').onClick:AddListener( PromptButtonOnClick)
    mMyTransform:Find('Canvas/Buttons/StoreButton'):GetComponent('Button').onClick:AddListener( StoreDisplay)
    mMyTransform:Find('Canvas/Buttons/RobotButton'):GetComponent('Button').onClick:AddListener( function () CanceRobotButtonlOnDisplay(1) end)
    mMyTransform:Find('Canvas/Buttons/CanceRobotButtonl'):GetComponent('Button').onClick:AddListener( function () CanceRobotButtonlOnDisplay(0) end)
    mSettlementGameObject.Object.transform:Find('Close'):GetComponent("Button").onClick:AddListener(function () ExitButtonAndAgainButtonDisplay(true) end)
    mSettlementGameObject.Object.transform:Find('GameObject/ChangeTable'):GetComponent("Button").onClick:AddListener(ExitButton_OnClick)
    mSettlementGameObject.Object.transform:Find('GameObject/Again'):GetComponent("Button").onClick:AddListener(PlayerSendRead)
    mMyTransform:Find('Canvas/Buttons/ExitButton'):GetComponent('Button').onClick:AddListener( ExitButton_OnClick)
    mMyTransform:Find('Canvas/Buttons/AgainButton'):GetComponent('Button').onClick:AddListener( PlayerSendRead)

    mMyTransform:Find('Canvas/Rule/Bank/Button/Toggle1'):GetComponent("Toggle").onValueChanged:AddListener(GameRuleButtonOnClick)
    mMyTransform:Find('Canvas/Rule/Bank/Button/Toggle2'):GetComponent("Toggle").onValueChanged:AddListener(GameRulePokerTypeButtonOnClick)
    mMyTransform:Find('Canvas/Rule/Bank/Button/Toggle3'):GetComponent("Toggle").onValueChanged:AddListener(GameRuleSettlementButtonOnClick)
    mMyTransform:Find('Canvas/Rule/Bank/Button/Toggle4'):GetComponent("Toggle").onValueChanged:AddListener(GameRuleSpecialPokerType)
    mMyTransform:Find('Canvas/Rule/Bank/Title/Close'):GetComponent("Button").onClick:AddListener(function() GameRuleDisplay(false) end)

    for Index=1,16,1 do
        PlayerHavePoker[Index].transform:GetComponent("PDKCheckPokerState").onPressed:AddListener(function() GreyIsDownPoker(Index) end)
        PlayerHavePoker[Index].transform:GetComponent("PDKCheckPokerState").onLongPressed:AddListener(WhiteIsDownPoker)
    end
end

--==============================--
--desc:返回菜单显示状态
--time:2018-03-01 09:46:42
--@isShow:
--@return 
--==============================--
function ReturnTransformSetActive()
    if mReturnGameObject.activeSelf then
        GameObjectSetActive(mReturnGameObject, false)
        this.transform:Find('Canvas/ReturnButton/true').gameObject:SetActive(true)
        this.transform:Find('Canvas/ReturnButton/false').gameObject:SetActive(false)
    else
        this.transform:Find('Canvas/ReturnButton/true').gameObject:SetActive(false)
        this.transform:Find('Canvas/ReturnButton/false').gameObject:SetActive(true)
        GameObjectSetActive(mReturnGameObject, true)
        mExitButtonScript.interactable = PDKCheckQuitGame()
    end
end

-- 玩家能否离开游戏检测
function PDKCheckQuitGame( )
    local quit = true
    if (mRoomData.RoomState >= PlayerStateEnumPDK.SETTLEMENT) or (mRoomData.RoomState < PlayerStateEnumPDK.JoinOK) then
        quit = true
        local num = mRoomData:ReadPlayerCount()
        if mRoomData:ReadPlayerCount()==3 then
            quit = false
        end
    else
        quit = false
    end
    return quit
end

-- 请求离开房间
function ExitButton_OnClick()
    if PDKCheckQuitGame() then
        NetMsgHandler.Send_CS_PDK_Leave_Room()
    end
end

-- 玩家请求准备
function PlayerSendRead()
    mSettlementGameObject.ParticleEffect:SetActive(false);
    if mRoomData.PDKPlayerList[3].PlayerState ~= PlayerStateEnumPDK.Ready then
        NetMsgHandler.Send_CS_PDK_Ready()
        if mRoomData.PDKPlayerList[3].IsRobot == 1 then
            NetMsgHandler.Send_CS_PDK_ROBOT(0)
        end
    end
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
function ResetPDKGameRoomToRoomState(roomState)
    lua_Call_GC()
    mRoomData = GameData.RoomInfo.CurrentRoom
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
    BrokenWireReconnection()
    InitPDKRoomBaseInfos()
    RefreshPDKGameRoomToGameState(roomState,true)
    InitRoomChange()
end

-- 断线重连
function BrokenWireReconnection()
    mOutPokerButton.enabled=true
    if OutCardEnt.transform:Find('OutCard1') ~= nil then
        local destoryCopy = OutCardEnt.transform:Find('OutCard1').gameObject
        CS.UnityEngine.Object.Destroy(destoryCopy)
    end
    if OutCardEnt.transform:Find('OutCard2') ~= nil then
        local destoryCopy = OutCardEnt.transform:Find('OutCard2').gameObject
        CS.UnityEngine.Object.Destroy(destoryCopy)
    end
    ZBButtonISShow(true)
    GameObjectSetActive(LoadingObject,false)
    mSettlementGameObject.ParticleEffect:SetActive(false);
    GameObjectSetActive(mSettlementGameObject.Object,false)
    GameObjectSetActive(OutPokerType,false)
    GameObjectSetActive(BombAnimtionObject,false)
    GameObjectSetActive(BombLightAnimtionObject,false)
    GameObjectSetActive(PlanAnimtionObject1,false)
    GameObjectSetActive(PlanAnimtionObject2,false)
    GameObjectSetActive(PokerThree,false)
    local PokerBank={}
    for Index=1,16,1 do
        PokerBank[Index]=PlayerHavePoker[Index].transform:Find("Image").gameObject
        PokerBank[Index]:GetComponent("Image").enabled=false
    end

    for Count=1,3,1 do
        for Index=1,11,1 do
            local AllCloseObject = this.transform:Find('Canvas/Players/Player'..Count..'/AllCloseAnmation/Image'..Index).gameObject
            GameObjectSetActive(AllCloseObject,false)
        end
    end
    
    for Index=1,13,1 do
        CountingPlateCardNumber[Index] = mRoomData.PokerNumber[Index]
    end
    for Index=1,3,1 do
        GameObjectSetActive(mPlayerUINodes[Index].Alert,false)
        local spriteAnimation = mPlayerUINodes[Index].Alert.transform:GetComponent('UGUISpriteAnimation')
        spriteAnimation.enabled=false
    end
    if mRoomData.RoomState > ROOM_STATE_PDK.DEAL and mRoomData.RoomState < ROOM_STATE_PDK.SETTLEMENT then
        for Index = 1,3,1 do
            if mRoomData.PDKPlayerList[Index].PokerNumber == 1 or mRoomData.PDKPlayerList[Index].PokerNumber == 2 then
                GameObjectSetActive(mPlayerUINodes[Index].Alert,true)
                local spriteAnimation = mPlayerUINodes[Index].Alert.transform:GetComponent('UGUISpriteAnimation')
                spriteAnimation.enabled=true
            end
        end
    end
    for Index = 1,#mRoomData.PDKPlayerList[3].Pokers,1 do
        CountingPlateCardNumber[mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber]=CountingPlateCardNumber[mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber]-1
    end
    CardNumberDisplay()
    CanceRobotButtonlDisplay()
    local count = #mRoomData.PDKPlayerList[3].Pokers + 1
    if count > 16 then
        count = 16
    end
    for Index = count,16,1 do
        CheckPokerState[Index].PokerState = 3
    end
    for Index = 1,count , 1 do
        CheckPokerState[Index].PokerState = 1
    end
    PlayerPokerDisplay()
    this:DelayInvoke(0.1,function ()
        PokerPosition()
    end)
    for Index = 1,3,1 do
        GameObjectSetActive(mPlayerUINodes[Index].YaoBuQi,false)
    end

    if mRoomData.RoomState == ROOM_STATE_PDK.CHUPAI or mRoomData.RoomState == ROOM_STATE_PDK.WAITCHUPAI then
        if OutCardEnt.transform:Find('OutCard1') ~= nil then
            local destoryCopy = OutCardEnt.transform:Find('OutCard1').gameObject
            CS.UnityEngine.Object.Destroy(destoryCopy)
        end
        if OutCardEnt.transform:Find('OutCard2') ~= nil then
            local destoryCopy = OutCardEnt.transform:Find('OutCard2').gameObject
            CS.UnityEngine.Object.Destroy(destoryCopy)
        end
        if #mRoomData.OutCardInfo >= 1 then
            local Copy=CS.UnityEngine.Object.Instantiate(OutCardTemplate)
            CS.Utility.ReSetTransform(Copy.transform,OutCardEnt.transform)
            Copy.name = "OutCard1"
            Copy.transform.localPosition = CS.UnityEngine.Vector3.zero
            for Index=1,#mRoomData.OutCardInfo,1 do
                local Poker = Copy.transform:Find('Card/Poker'..Index).gameObject
                Poker.transform:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(mRoomData.OutCardInfo[Index]))
                --print("!!!!!!玩家出的牌",Index,mRoomData.OutCardInfo[Index].PokerType,mRoomData.OutCardInfo[Index].PokerNumber)
                GameObjectSetActive(Poker,true)
            end
            local Tween = Copy.transform:GetComponent("TweenPosition")
            GameObjectSetActive(Copy,true)
        end
    end
    if mRoomData.RoomState<ROOM_STATE_PDK.DEAL or mRoomData.RoomState> ROOM_STATE_PDK.SETTLEMENT then
        LoadingAnitationDispaly()
    end
end

-- 初始化房间到初始状态
function InitPDKRoomBaseInfos()
    SetPDKRoomBaseInfo()
    GameObjectSetActive(mReturnGameObject, false)
    ResetPDKGamePositionInfo()
    ResetPDKWinGold()
end

-- 设置房间基础信息
function SetPDKRoomBaseInfo()
    mRoomNumberText.text = tostring(mRoomData.RoomID)
    BetMin1.text= ""..lua_NumberToStyle1String(mRoomData.MinBet)
end

-- 获取房间规则显示描述1
function MJGetRoomRuleTips(nBet)
    local ruleTips =string.format( data.GetString("TTZ_Rule_Tip"),lua_NumberToStyle1String(mRoomData.MinBet))
        if mRoomData.RoomType == ROOM_TYPE.ZuJuMaJiang then
            ruleTips = string.format( data.GetString("TTZ_Rule_Tip"),lua_NumberToStyle1String(mRoomData.MinBet))
        end
    return ruleTips
end

-- 重置游戏座位信息
function ResetPDKGamePositionInfo()
    -- 重置座位信息
    for position = 1, MAX_PDKZUJU_ROOM_PLAYER, 1 do
        ResetPDKPlayerUINode(mPlayerUINodes[position])
        SetPDKPlayerSitdownState(position)
        SetPDKPlayerBaseInfo(position)
    end
end

-- 重置玩家信息归零
function ResetPDKPlayerUINode(tPlayer)
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
function OnNotifyPDKAddPlayerEvent( positionParam )
        SetPDKPlayerSitdownState(positionParam)
        SetPDKPlayerBaseInfo(positionParam)
        LoadingAnitationDispaly()
        ZBImageIsShow(positionParam,true)
        -- 进入音效
        PlayAudioClip('NN_enter')
end

--==============================--
--desc:离开一个玩家
--time:2018-02-28 08:44:55
--@positionParam:
--@return 
--==============================--
function OnNotifyPDKDeletePlayerEvent( positionParam )
    if mRoomData.RoomState < ROOM_STATE_MJ.DEAL or mRoomData.RoomState >= PlayerStateEnumPDK.SETTLEMENT then
        SetPDKPlayerSitdownState(positionParam)
        SetPDKPlayerBaseInfo(positionParam)
        LoadingAnitationDispaly()
        ZBImageIsShow(positionParam,false)
    end
end

-- 设置玩家坐下状态
function SetPDKPlayerSitdownState(positionParam)
    if mPlayerUINodes[positionParam] == nil then
        return
    end
    if mRoomData.PDKPlayerList[positionParam].PlayerState == PlayerStateEnumPDK.NULL or mRoomData.PDKPlayerList[positionParam].ID==0 then
        mPlayerUINodes[positionParam].HeadRoot.gameObject:SetActive(false)
        mPlayerUINodes[positionParam].ZBImage:SetActive(false)
    else
        mPlayerUINodes[positionParam].HeadRoot.gameObject:SetActive(true)
    end
end

-- 设置玩家名称 头像 金币
function SetPDKPlayerBaseInfo(positionParam)
    local showObj = mPlayerUINodes[positionParam]
    local showData = mRoomData.PDKPlayerList[positionParam]
    if (showData.PlayerState >= PlayerStateEnumPDK.Ready and showData.PlayerState <= PlayerStateEnumPDK.LookOn) and showData.ID~=0 then
        showObj.NameText.text = showData.strLoginIP
        showObj.GoldText.text = tostring(lua_GetPreciseDecimal(showData.Gold,2))
        showObj.HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(showData.HeadIcon))
        if mRoomData.PDKPlayerList[positionParam].PlayerState == PlayerStateEnumPDK.Ready then
            ZBImageIsShow(positionParam,true)
        end
    else
        showObj.NameText.text = ""
        showObj.GoldText.text = ""
    end
end


-- 房间状态刷新
function RefreshMJGameRoomByRoomStateSwitchTo( roomState )
    -- body
    RefreshPDKGameRoomToGameState(roomState,true)

end

--==============================--
--desc:刷新房间到指定状态
--time:2018-02-28 08:13:07
--@roomState:
--@isInit:
--@return 
--==============================--
function RefreshPDKGameRoomToGameState( roomState, isInit )
    --RefreshPDKSTARTPartOfGameRoomByState( roomState, isInit )
    RefreshPDKREADYPartOfGameRoomByState(roomState, isInit)
    RefreshPDKREADYPartOfGameRoomByDEAL ( roomState, isInit )
    RefreshPDKWaitFlyPoker(roomState, isInit)
    RefreshPDKREADYPartOfGameRoomByCHUPAI( roomState, isInit )
    RefreshPDKREADYPartOfGameRoomByWaitCHUPAI( roomState, isInit )
    RefreshPDKSettlementPartOfGameRoomByState( roomState, isInit )
end


-- 重置跑的快数据
function RestPDKData()
    
    for index = 1,MAX_PDKZUJU_ROOM_PLAYER,1 do
        mCountDownLight[index]:SetActive(false)
        mRoomData.PDKPlayerList[index].Pokers={}
        mRoomData.PDKPlayerList[index].SurplusPokerPokers={}
    end
    for Index=1,16,1 do
        CheckPokerState[Index].PokerState = 1
        GameObjectSetActive(Player3PokerPosition[Index],true)
        GameObjectSetActive(PlayerHavePoker[Index],true)
    end
    if OutCardEnt.transform:Find('OutCard1') ~= nil then
        local destoryCopy = OutCardEnt.transform:Find('OutCard1').gameObject
        CS.UnityEngine.Object.Destroy(destoryCopy)
    end
    if OutCardEnt.transform:Find('OutCard2') ~= nil then
        local destoryCopy = OutCardEnt.transform:Find('OutCard2').gameObject
        CS.UnityEngine.Object.Destroy(destoryCopy)
    end
    this.transform:Find('Canvas/Players/CountDown3_2').gameObject:SetActive(false)
    local CountingPlateCardNumber = {3,1,4,4,4,4,4,4,4,4,4,4,4}
    mRoomData.WaitCardType=nil
    mRoomData.WaitCardNumber=nil
    mRoomData.OutCardInfo={}
end

-- 重回等待开始游戏状态
function RefreshPDKSTARTPartOfGameRoomByState( roomState, isInit )
    if roomState == ROOM_STATE_PDK.START and true == isInit then
        RestPDKData()
    end
end

-- 准备阶段
function RefreshPDKREADYPartOfGameRoomByState ( roomState, isInit )
    if roomState == ROOM_STATE_PDK.READY and true == isInit then
        DisplayPlayer1Player2Pokers(false)
        RestPDKData()
        InitPDKRoomBaseInfos()
    end
end

-- 发牌状态
function RefreshPDKREADYPartOfGameRoomByDEAL ( roomState, isInit )
    if roomState == ROOM_STATE_PDK.DEAL and true == isInit then
        CountingPlateCardNumber = {3,1,4,4,4,4,4,4,4,4,4,4,4}
        YaoBuQiNumber = 0
        for Index=1,#mRoomData.PDKPlayerList[3].Pokers,1 do
            CountingPlateCardNumber[mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber]=CountingPlateCardNumber[mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber]-1
        end
        for Index=1,16,1 do
            CheckPokerState[Index].PokerState = 1
        end
        if OutCardEnt.transform:Find('OutCard1') ~= nil then
            local destoryCopy = OutCardEnt.transform:Find('OutCard1').gameObject
            CS.UnityEngine.Object.Destroy(destoryCopy)
        end
        if OutCardEnt.transform:Find('OutCard2') ~= nil then
            local destoryCopy = OutCardEnt.transform:Find('OutCard2').gameObject
            CS.UnityEngine.Object.Destroy(destoryCopy)
        end
        for Index=1,MAX_PDKZUJU_ROOM_PLAYER,1 do
            if mRoomData.PDKPlayerList[Index].PlayerState ~= PlayerStateEnumPDK.Out then
                mRoomData.PDKPlayerList[Index].PlayerState = PlayerStateEnumPDK.WaitOut
            end
            mPlayerUINodes[Index].ZBImage:SetActive(false)
        end
        PlayerPokerDisplay()
        this:DelayInvoke(0.3,function ()
            if GameData.PDKIsPlay == true then
                PokerPosition()
            else
                PokerPosition()
                GivePokerAnimtion()
            end
        end)
        this:DelayInvoke(1.8,function ()
            if GameData.PDKIsPlay == true then
                Player1PokerTableDispaly()
                Player2PokerTableDispaly()
            end
        end)
    end
end

-- 确定先手状态
function RefreshPDKWaitFlyPoker(roomState, isInit)
    if roomState == ROOM_STATE_PDK.DECISION and true == isInit then
        CardNumberDisplay()
        PokerFlyAnimtion()
        local delinvokeTime=data.PublicConfig.PDK_ROOM_TIME[ROOM_STATE_PDK.DECISION]
        this:DelayInvoke(delinvokeTime,function ()
            FristPlayerOutTime=true
            mOutPokerButton.interactable=false
            OutButtonPromptButtonDisplay()
        end)
    else
        FristPlayerOutTime=false
    end
end
-- 出牌状态
function RefreshPDKREADYPartOfGameRoomByCHUPAI( roomState, isInit )
    if roomState == ROOM_STATE_PDK.CHUPAI and true == isInit then
        GameData.PDKIsPlay = false
        HavePlayerOutCard(mRoomData.LastPosition)
        OutButtonPromptButtonDisplay()
        for Index=1,MAX_PDKZUJU_ROOM_PLAYER,1 do
            mCountDownLight[Index].gameObject:SetActive(false)
        end
        this.transform:Find('Canvas/Players/CountDown3_2').gameObject:SetActive(false)
        if mRoomData.LastPosition == 2  then
            local tCard={}
            for Index=1,16,1 do
                if CheckPokerState[Index].PokerState == 2 then
                    table.insert(tCard,mRoomData.PDKPlayerList[3].Pokers[Index])
                    if tCard[#tCard].PokerNumber == 2 then
                        tCard[#tCard].PokerNumber=15
                    elseif tCard[#tCard].PokerNumber == 1 then
                        tCard[#tCard].PokerNumber=14
                    end
                end
            end
            OutPokerButtonInteractable(tCard)
            if YaoBuQiNumber>=2 then
                if OutCardEnt.transform:Find('OutCard1') ~= nil then
                    local destoryCopy = OutCardEnt.transform:Find('OutCard1').gameObject
                    CS.UnityEngine.Object.Destroy(destoryCopy)
                end
                if OutCardEnt.transform:Find('OutCard2') ~= nil then
                    local destoryCopy = OutCardEnt.transform:Find('OutCard2').gameObject
                    CS.UnityEngine.Object.Destroy(destoryCopy)
                end
                YaoBuQiNumber=0
            else
                YaoBuQiNumber=0
            end
        end
    end
end

-- 等待出牌阶段
function RefreshPDKREADYPartOfGameRoomByWaitCHUPAI( roomState, isInit )
    if roomState == ROOM_STATE_PDK.WAITCHUPAI and true == isInit then
        GameData.PDKIsPlay = false
        HavePlayerOutCard(mRoomData.LastPosition)
        GameObjectSetActive(mPromptButtonGameObject,false)
        GameObjectSetActive(mOutPokerButtonGameObject,false)
        for Index=1,MAX_PDKZUJU_ROOM_PLAYER,1 do
            mCountDownLight[Index].gameObject:SetActive(false)
        end
        this.transform:Find('Canvas/Players/CountDown3_2').gameObject:SetActive(false)
        if mRoomData.LastPosition == 2  then
            YaoBuQiNumber = 0
        end
        if mRoomData.PDKPlayerList[mRoomData.LastPosition].PokerNumber == 0 then
            for Index=1,MAX_PDKZUJU_ROOM_PLAYER,1 do
                if mRoomData.PDKPlayerList[Index].PokerNumber == 16 then
                    this:DelayInvoke(1,function ()
                        PlayerAllCloseAnimation(Index)
                    end)
                end
            end
        end
    end
end

-- 结算状态
function RefreshPDKSettlementPartOfGameRoomByState( roomState, isInit )
    if roomState == ROOM_STATE_PDK.SETTLEMENT and true == isInit then
        --print('===================进入结算状态=====================')
        lua_Call_GC()
        GameData.PDKIsPlay = false
        SettlementCountDown = true
        for Index=1,3,1 do
            GameObjectSetActive(mPlayerUINodes[Index].Alert,false)
            local spriteAnimation = mPlayerUINodes[Index].Alert.transform:GetComponent('UGUISpriteAnimation')
            spriteAnimation.enabled=false
        end
        DisplayPlayer1Player2Pokers(true)
        OutButtonPromptButtonDisplay()
        SettlementInterfaceDisplayInfo(true)
        if mRoomData.PDKPlayerList[3].IsRobot == 0 then
            mRobotButtonlObject.interactable = false
        end
    else
        SettlementCountDown = false
        if mRoomData.PDKPlayerList[3].IsRobot == 0 then
            if mRoomData.RoomState > ROOM_STATE_PDK.DEAL and mRoomData.RoomState < ROOM_STATE_PDK.SETTLEMENT then
                mRobotButtonlObject.interactable = true
            else
                mRobotButtonlObject.interactable = false
            end
        end
    end
end

-- 飞牌动画
function PokerFlyAnimtion()
    local position = 1
    for Index=1,MAX_PDKZUJU_ROOM_PLAYER,1 do
        if mRoomData.PDKPlayerList[Index].PlayerState == PlayerStateEnumPDK.Out then
            position = Index
        end
    end
    local tweenScale = PokerThree:GetComponent("TweenScale")
    local tweenPosition = PokerThree:GetComponent("TweenPosition")
    local tweenColor = PokerThree:GetComponent("TweenColor")
    local tweenRotation = PokerThree:GetComponent("TweenRotation")
    GameObjectSetActive(PokerThree,true)
    local people=math.random(2)
    local IsMan = false
    for k=1, #data.PublicConfig.HeadIconMan, 1 do
        if mRoomData.PDKPlayerList[position].HeadIcon == data.PublicConfig.HeadIconMan[k] then
            IsMan = true
            break
        end
    end
    if IsMan then
        PlayAudioClip("PDK_FristOutCard1")
    else
        PlayAudioClip("PDK_FristOutCard2")
    end
    PokerThree.transform:GetComponent("Image").color = CS.UnityEngine.Color(255,255,255,1)
    PokerThree.transform.localPosition = CS.UnityEngine.Vector3(0,85,0)
    PokerThree.transform.localEulerAngles  = CS.UnityEngine.Vector3(0,0,0)
    tweenScale.from = CS.UnityEngine.Vector3(0.85,0.85,0.85)
    tweenScale.to = CS.UnityEngine.Vector3(1,1,1)
    tweenScale.duration = 0.3
    tweenScale:ResetToBeginning()
    tweenScale:Play(true)
    this:DelayInvoke(0.3,function ()
        
        tweenScale.from = CS.UnityEngine.Vector3(1,1,1)
        tweenScale.to = CS.UnityEngine.Vector3(0.85,0.85,0.85)
        tweenScale.duration = 0.3
        tweenScale:ResetToBeginning()
        tweenScale:Play(true)
    end)
    this:DelayInvoke(0.6,function ()
        
        tweenScale.from = CS.UnityEngine.Vector3(0.85,0.85,0.85)
        tweenScale.to = CS.UnityEngine.Vector3(1,1,1)
        tweenScale.duration = 0.3
        tweenScale:ResetToBeginning()
        tweenScale:Play(true)
    end)
    
    this:DelayInvoke(0.9,function ()
        tweenScale.enabled=false
        local position_z = 0
        if position == 1 then
            position_z = 90
        elseif position == 2 then
            position_z = -90
        end
        
        tweenRotation.from = CS.UnityEngine.Vector3.zero
        tweenRotation.to = CS.UnityEngine.Vector3(0,0,position_z)
        tweenRotation:ResetToBeginning()
        tweenRotation:Play(true)
    end)
    this:DelayInvoke(1.2,function ()
        tweenScale.from = CS.UnityEngine.Vector3(1,1,1)
        tweenScale.to = CS.UnityEngine.Vector3(0.7,0.7,0.7)
        tweenScale.duration = 0.3
        tweenScale:ResetToBeginning()
        tweenScale:Play(true)
        tweenPosition.from = CS.UnityEngine.Vector3(PokerThree.transform.localPosition.x,PokerThree.transform.localPosition.y,PokerThree.transform.localPosition.z)
        tweenPosition.to=CS.UnityEngine.Vector3(PlyPokerPosition[position].transform.localPosition.x,PlyPokerPosition[position].transform.localPosition.y,0)
        tweenPosition.duration=0.5
        tweenPosition:ResetToBeginning()
        tweenPosition:Play(true)
        tweenColor:ResetToBeginning()
        tweenColor:Play(true)
    end)
    this:DelayInvoke(1.8,function ()
        GameObjectSetActive(PokerThree,false)
    end)
end

-- 结算状态显示玩家1和玩家2的剩余扑克牌
function DisplayPlayer1Player2Pokers(mShow)
    if mShow then
        GameObjectSetActive(mPlayerPokerNumberObject1,false)
        GameObjectSetActive(mPlayerPokerNumberObject2,false)
        for Index=1,16,1 do
            GameObjectSetActive(mPlayerRemainingPokerCards1[Index],false)
            GameObjectSetActive(mPlayerRemainingPokerCards2[Index],false)
            --GameObjectSetActive(PlayerHavePoker[Index],false)
            GameObjectSetActive(Player3PokerPosition[Index],false)
        end
        for Index=1,10,1 do
            GameObjectSetActive(Player1CardTable[Index],false)
            GameObjectSetActive(Player2CardTable[Index],false)
        end
        if #mRoomData.PDKPlayerList[1].SurplusPokerPokers > 0 then
            GameObjectSetActive(mPlayerPokerGameObject1,true)
        else
            GameObjectSetActive(mPlayerPokerGameObject1,false)
        end
        if #mRoomData.PDKPlayerList[2].SurplusPokerPokers > 0 then
            GameObjectSetActive(mPlayerPokerGameObject2,true)
        else
            GameObjectSetActive(mPlayerPokerGameObject2,false)
        end

        for Index=1,#mRoomData.PDKPlayerList[1].SurplusPokerPokers,1 do
            GameObjectSetActive(mPlayerRemainingPokerCards1[Index],true)
            
            mPlayerRemainingPokerCards1[Index]:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(mRoomData.PDKPlayerList[1].SurplusPokerPokers[Index]))
        end 
        for Index=1,#mRoomData.PDKPlayerList[2].SurplusPokerPokers,1 do
            GameObjectSetActive(mPlayerRemainingPokerCards2[Index],true)
            mPlayerRemainingPokerCards2[Index]:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(mRoomData.PDKPlayerList[2].SurplusPokerPokers[Index]))
        end 
    else
        for Index=1,16,1 do
            GameObjectSetActive(mPlayerRemainingPokerCards1[Index],false)
            GameObjectSetActive(mPlayerRemainingPokerCards2[Index],false)
            GameObjectSetActive(PlayerHavePoker[Index],false)
            GameObjectSetActive(Player3PokerPosition[Index],false)
        end
    end

end

-- 结算面板显示
function SettlementInterfaceDisplayInfo(mShow)
    if mSettlementGameObject.activeSelf == mShow then
        return 
    end
    if mShow then
        GameObjectSetActive(LoadingObject,false)
        GameObjectSetActive(mPromptButtonGameObject,false)
        GameObjectSetActive(mOutPokerButtonGameObject,false)
        for Index=1,MAX_PDKZUJU_ROOM_PLAYER,1 do
            mCountDownLight[Index].gameObject:SetActive(false)
        end
        this.transform:Find('Canvas/Players/CountDown3_2').gameObject:SetActive(false)
        this:DelayInvoke(1,function ()
            GameObjectSetActive(mSettlementGameObject.Object,true)
            SettlementAnimation()
            mSettlementGameObject.GoldText1.text = "+"..mRoomData.PDKPlayerList[3].WinGold
            mSettlementGameObject.GoldText2.text = ""..mRoomData.PDKPlayerList[3].WinGold
            mSettlementGameObject.BombsText.text = "炸弹 "..mRoomData.PDKPlayerList[3].BombNumber

            mSettlementGameObject.Player1.NameText.text = ""..mRoomData.PDKPlayerList[1].SettlementName
            mSettlementGameObject.Player1.BombsText.text = ""..mRoomData.PDKPlayerList[1].BombNumber
            
            mSettlementGameObject.Player1.GoldText.text = ""..mRoomData.PDKPlayerList[1].WinGold

            mSettlementGameObject.Player2.NameText.text = ""..mRoomData.PDKPlayerList[2].SettlementName
            mSettlementGameObject.Player2.BombsText.text = ""..mRoomData.PDKPlayerList[2].BombNumber
            
            mSettlementGameObject.Player2.GoldText.text = ""..mRoomData.PDKPlayerList[2].WinGold
            if mRoomData.PDKPlayerList[3].WinGold > 0 then
                mSettlementGameObject.CardsText.text="赢牌 "..mRoomData.PDKPlayerList[3].SettlementPokerNumber.." 张"
                GameObjectSetActive(mSettlementGameObject.GoldTextObject1,true)
                GameObjectSetActive(mSettlementGameObject.GoldTextObject2,false)
                PlayAudioClip("PDK_WIN")
            else
                local num = -(mRoomData.PDKPlayerList[3].SettlementPokerNumber)
                mSettlementGameObject.CardsText.text="输牌 "..num.." 张"
                GameObjectSetActive(mSettlementGameObject.GoldTextObject2,true)
                GameObjectSetActive(mSettlementGameObject.GoldTextObject1,false)
                PlayAudioClip("PDK_LOSE")
            end
            if mRoomData.PDKPlayerList[1].WinGold > 0 then
                mSettlementGameObject.Player1.CardsText.text = "0"
                mSettlementGameObject.Player1.GoldText.text = "+"..mRoomData.PDKPlayerList[1].WinGold
            else
                local num = -(mRoomData.PDKPlayerList[1].SettlementPokerNumber)
                mSettlementGameObject.Player1.CardsText.text = ""..num
            end
            if mRoomData.PDKPlayerList[2].WinGold > 0 then
                mSettlementGameObject.Player2.CardsText.text = "0"
                mSettlementGameObject.Player2.GoldText.text = "+"..mRoomData.PDKPlayerList[2].WinGold
            else
                local num = -(mRoomData.PDKPlayerList[2].SettlementPokerNumber)
                mSettlementGameObject.Player2.CardsText.text = ""..num
            end
            for Index = 1, 3 , 1 do
                GameObjectSetActive(mPlayerUINodes[Index].AllClose,false)
                GameObjectSetActive(mPlayerUINodes[Index].AllPay,false)
                SetPDKPlayerBaseInfo(Index)
                if mRoomData.PDKPlayerList[Index].WinGold < 0 then
                    if mRoomData.PDKPlayerList[Index].SettlementPokerNumber == -16 then
                        GameObjectSetActive(mPlayerUINodes[Index].AllClose,true)
                    end
                    local Value = mRoomData.PDKPlayerList[Index].SettlementPokerNumber * mRoomData.MinBet
                    --print("$$$$$$$$$$$$$$$$$",Index,mRoomData.PDKPlayerList[Index].WinGold,Value,(Value*2))
                    if mRoomData.PDKPlayerList[Index].WinGold < Value then
                        if (Value*2) ~= mRoomData.PDKPlayerList[Index].WinGold then
                            GameObjectSetActive(mPlayerUINodes[Index].AllPay,true)
                        end
                    end
                end
            end
        end)
    else
        local tweenRotation = mSettlementGameObject.VictoryLight:GetComponent("TweenRotation")
        local tweenRotation1 = mSettlementGameObject.VictoryLight2:GetComponent("TweenScale")
        local tweenRotation2 = mSettlementGameObject.FailLight:GetComponent("TweenScale")
        tweenRotation.enabled = false
        tweenRotation1.enabled = false
        tweenRotation2.enabled = false
        GameObjectSetActive(mSettlementGameObject.Object,false)
        if mRoomData.RoomState == ROOM_STATE_PDK.SETTLEMENT and mRoomData.PDKPlayerList[3].PlayerState == PlayerStateEnumPDK.Ready then
            for Index=1,2,1 do
                GameObjectSetActive(mCountDownLight[Index],false)
            end
        end
        for Count=1,3,1 do
            for Index=1,11,1 do
                local AllCloseObject = this.transform:Find('Canvas/Players/Player'..Count..'/AllCloseAnmation/Image'..Index).gameObject
                GameObjectSetActive(AllCloseObject,false)
            end
        end
        LoadingAnitationDispaly()
    end
end

-- 结算动画
function SettlementAnimation()
    mSettlementGameObject.Victory:SetActive(false)
    mSettlementGameObject.VictoryLight:SetActive(false)
    mSettlementGameObject.VictoryLight2:SetActive(false)
    mSettlementGameObject.Fail:SetActive(false)
    mSettlementGameObject.FailLight:SetActive(false)
    local tweenScale = mSettlementGameObject.Object.transform:Find('GameObject'):GetComponent("TweenScale")
    tweenScale:ResetToBeginning()
    tweenScale:Play(true)
    if mRoomData.PDKPlayerList[3].WinGold > 0 then
        local tweenScale2 = mSettlementGameObject.VictoryLight2:GetComponent("TweenScale")
        local tweenRotation = mSettlementGameObject.VictoryLight:GetComponent("TweenRotation")
        mSettlementGameObject.Victory:SetActive(true)
        tweenScale:ResetToBeginning()
        tweenScale:Play(true)
        --TUDOU
        mSettlementGameObject.ParticleEffect:SetActive(true);
        this:DelayInvoke(15, function()
            mSettlementGameObject.ParticleEffect:SetActive(false);
        end)
        this:DelayInvoke(0.5,function ()
            mSettlementGameObject.VictoryLight:SetActive(true)
            mSettlementGameObject.VictoryLight2:SetActive(true)
            tweenRotation.enabled = true
            tweenRotation:ResetToBeginning()
            tweenRotation:Play(true)
            tweenScale2:ResetToBeginning()
            tweenScale2:Play(true)
        end)
        
    else
        mSettlementGameObject.ParticleEffect:SetActive(false);
        mSettlementGameObject.Fail:SetActive(true)
        tweenScale:ResetToBeginning()
        tweenScale:Play(true)
    end
end

-- 显示离开和继续游戏按钮
function ExitButtonAndAgainButtonDisplay(mShow)
    if mShow then
        SettlementInterfaceDisplayInfo(false)
        GameObjectSetActive(mSettlementGameObject.ExitButton,true)
        GameObjectSetActive(mSettlementGameObject.AgainButton,true)
    else
        GameObjectSetActive(mSettlementGameObject.ExitButton,false)
        GameObjectSetActive(mSettlementGameObject.AgainButton,false)
    end
end

-- 玩家扑克牌初始化显示
function PlayerPokerDisplay()
    this:DelayInvoke(0,function ()
    end)
    if mRoomData.PDKPlayerList[1].PokerNumber ~=nil  then
        if mRoomData.PDKPlayerList[1].PokerNumber > 0 then
            GameObjectSetActive(mPlayerPokerGameObject1,true)
            if mRoomData.RoomState >= ROOM_STATE_PDK.DEAL and  mRoomData.RoomState < ROOM_STATE_PDK.SETTLEMENT then
                GameObjectSetActive(mPlayerPokerNumberObject1,true)
                mPlayerPokerNumberText1.text = tostring(mRoomData.PDKPlayerList[1].PokerNumber)
            else
                GameObjectSetActive(mPlayerPokerNumberObject1,false)
            end
        end
    else
        GameObjectSetActive(mPlayerPokerGameObject1,false)
    end
    if mRoomData.PDKPlayerList[2].PokerNumber ~= nil then
        if mRoomData.PDKPlayerList[2].PokerNumber > 0 then
            GameObjectSetActive(mPlayerPokerGameObject2,true)
            if mRoomData.RoomState >= ROOM_STATE_PDK.DEAL and  mRoomData.RoomState < ROOM_STATE_PDK.SETTLEMENT then
                GameObjectSetActive(mPlayerPokerNumberObject2,true)
                mPlayerPokerNumberText2.text = tostring(mRoomData.PDKPlayerList[2].PokerNumber)
            else
                GameObjectSetActive(mPlayerPokerNumberObject2,false)
            end
        end
    else
        GameObjectSetActive(mPlayerPokerGameObject2,false)
    end
    if #mRoomData.PDKPlayerList[3].Pokers > 0 then
        GameObjectSetActive(mPlayerPokerGameObject3,true)
    else
        GameObjectSetActive(mPlayerPokerGameObject3,false)
    end
    for Index = #mRoomData.PDKPlayerList[3].Pokers,16,1 do
        if Index <= 0 then
            break
        end
        GameObjectSetActive(PlayerHavePoker[Index],false)
        GameObjectSetActive(Player3PokerPosition[Index],false)
    end
    for Index=1,#mRoomData.PDKPlayerList[3].Pokers,1 do
        PlayerHavePoker[Index].transform:GetComponent("Image").enabled=false
        GameObjectSetActive(Player3PokerPosition[Index],true)
        GameObjectSetActive(PlayerHavePoker[Index],true)
        PlayerPokersImage[Index]:ResetSpriteByName(GameData.GetPokerCardSpriteName(mRoomData.PDKPlayerList[3].Pokers[Index]))
    end
    
    this:DelayInvoke(0.2,function ()
    end)
end

-- 玩家扑克牌位置
function PokerPosition()
    local angl = 1.8
    local pokerIndexTable={}
    for Index =1,16,1 do
        if PlayerHavePoker[Index].activeSelf == true then
            table.insert(pokerIndexTable,Index)
        end
    end
    local  mlength=#pokerIndexTable
    if mlength == 0 then
        return
    end
    for Index=1,mlength,1 do
        PlayerHavePoker[pokerIndexTable[Index]].transform.localEulerAngles =CS.UnityEngine.Vector3(0,0,1.8*((mlength/2)-Index+1))
    end
    if mlength == 1 then
        PlayerHavePoker[pokerIndexTable[1]].transform.localEulerAngles =CS.UnityEngine.Vector3(0,0,0)
    end
    local PositionxIndex=8
    local PositionxIndex2=9
    if mlength %2 == 0 then
        local count=mlength/2
        local CopyPositionxIndex = PositionxIndex
        for Index=count,1,-1 do
            local position_x = Player3PokerPosition[pokerIndexTable[Index]].transform.localPosition.x
            local position_y = Player3PokerPosition_Y[CopyPositionxIndex].transform.localPosition.y
            PlayerHavePoker[pokerIndexTable[Index]].transform.localPosition = CS.UnityEngine.Vector3(position_x,position_y,0)
            CopyPositionxIndex=CopyPositionxIndex-1
        end
        local num=count+1
        local CopyPositionxIndex2 = PositionxIndex2
        for Index=num,mlength,1 do
            local position_x = Player3PokerPosition[pokerIndexTable[Index]].transform.localPosition.x
            local position_y = Player3PokerPosition_Y[CopyPositionxIndex2].transform.localPosition.y
            PlayerHavePoker[pokerIndexTable[Index]].transform.localPosition = CS.UnityEngine.Vector3(position_x,position_y,0)
            CopyPositionxIndex2=CopyPositionxIndex2+1
        end
    else
        local count = (mlength+1)/2
        local CopyPositionxIndex = PositionxIndex
        for Index=count,1,-1 do
            local position_x = Player3PokerPosition[pokerIndexTable[Index]].transform.localPosition.x
            local position_y = Player3PokerPosition_Y[CopyPositionxIndex].transform.localPosition.y
            PlayerHavePoker[pokerIndexTable[Index]].transform.localPosition = CS.UnityEngine.Vector3(position_x,position_y,0)
            CopyPositionxIndex=CopyPositionxIndex-1
        end
        local num=count+1
        local CopyPositionxIndex2 = PositionxIndex2
        for Index=num,mlength,1 do
            local position_x = Player3PokerPosition[pokerIndexTable[Index]].transform.localPosition.x
            local position_y = Player3PokerPosition_Y[CopyPositionxIndex2].transform.localPosition.y
            PlayerHavePoker[pokerIndexTable[Index]].transform.localPosition = CS.UnityEngine.Vector3(position_x,position_y,0)
            CopyPositionxIndex2=CopyPositionxIndex2+1
        end
    end
    local tCard={}
    for Index = 1, 16, 1 do
        PlayerPokersImage[Index].color=CS.UnityEngine.Color.white
        if CheckPokerState[Index].PokerState == 1 then
            PlayerHavePoker[Index].transform:GetComponent("Image").enabled=true
            local Position_y = PlayerHavePoker[Index].transform.localPosition.y--+50
            PlayerHavePoker[Index].transform.localPosition=CS.UnityEngine.Vector3(PlayerHavePoker[Index].transform.localPosition.x,Position_y,0)
        elseif CheckPokerState[Index].PokerState == 2 then
            PlayerHavePoker[Index].transform:GetComponent("Image").enabled=true
            local Position_y = PlayerHavePoker[Index].transform.localPosition.y+50--110
            PlayerHavePoker[Index].transform.localPosition=CS.UnityEngine.Vector3(PlayerHavePoker[Index].transform.localPosition.x,Position_y,0)
            table.insert(tCard, {PokerType=mRoomData.PDKPlayerList[3].Pokers[Index].PokerType,PokerNumber =mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber })
            if tCard[#tCard].PokerNumber == 2 then
                tCard[#tCard].PokerNumber=15
            elseif tCard[#tCard].PokerNumber == 1 then
                tCard[#tCard].PokerNumber=14
            end
        end
    end
    OutPokerButtonInteractable(tCard)
end

-- 玩家点击扑克牌
function PlayerClickPoker(Index)
    if CheckPokerState[Index].PokerState == 1 then
        table.insert(OutCard,mRoomData.PDKPlayerList[3].Pokers[Index] )
        CheckPokerState[Index].PokerState = 2
    elseif CheckPokerState[Index].PokerState == 2 then
        for Count = #OutCard, #OutCard, -1 do
            if (OutCard[Count].PokerType == mRoomData.PDKPlayerList[3].Pokers[Index].PokerType) and (OutCard[Count].PokerNumber == mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber) then
                table.remove(OutCard, Count)
                CheckPokerState[Index].PokerState = 1
            end
        end
    end
    PokerPosition()
end

-- 玩家请求出牌
function PlayerOutCard()
    OutCard={}
    for Index=1,16,1 do
        if CheckPokerState[Index].PokerState == 2 then
            table.insert(OutCard,{PokerType = mRoomData.PDKPlayerList[3].Pokers[Index].PokerType,PokerNumber=mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber} )
        end
    end
    NetMsgHandler.Send_CS_PDK_PlayerOutPoker(OutCard)
    mOutPokerButton.enabled=false
    this:DelayInvoke(1,function ()
        mOutPokerButton.enabled=true
    end)
end

-- 有玩家出牌
function HavePlayerOutCard(position)
    if  #mRoomData.OutCardInfo < 1 or mRoomData.OutPokerTypre == 0 then
        if mRoomData.DesktopCard ~= position then
            PlayerYaoBuQi(position)
        end
        return 
    end
    OutCardAudio(position)
    if mRoomData.LastPosition == 3 then
        if #mRoomData.OutCardInfo >= 1 then
            for Count=1,#mRoomData.OutCardInfo,1 do
                for Index=1,#mRoomData.PDKPlayerList[3].Pokers,1 do
                    if mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber == 14 then
                        mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber=1
                    elseif mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber == 15 then
                        mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber=2
                    end
                    if mRoomData.PDKPlayerList[3].Pokers[Index].PokerType == mRoomData.OutCardInfo[Count].PokerType and mRoomData.PDKPlayerList[3].Pokers[Index].PokerNumber == mRoomData.OutCardInfo[Count].PokerNumber then
                        CheckPokerState[Index].PokerState = 3
                        mRoomData.PDKPlayerList[3].PokerNumber = mRoomData.PDKPlayerList[position].PokerNumber-1
                        GameObjectSetActive(Player3PokerPosition[Index],false)
                        GameObjectSetActive (PlayerHavePoker[Index],false)
                    end
                end
            end
            this:DelayInvoke(0.2,function ()
                PokerPosition()
            end)
            OutCardAnimation(position)
            PokerTypeAnimation(position)
            if mRoomData.PDKPlayerList[3].PokerNumber == 2 or mRoomData.PDKPlayerList[3].PokerNumber == 1 then
                GameObjectSetActive(mPlayerUINodes[position].Alert,true)
                local spriteAnimation = mPlayerUINodes[position].Alert.transform:GetComponent('UGUISpriteAnimation')
                spriteAnimation.enabled=true
            else
                GameObjectSetActive(mPlayerUINodes[position].Alert,false)
                local spriteAnimation = mPlayerUINodes[position].Alert.transform:GetComponent('UGUISpriteAnimation')
                spriteAnimation.enabled=false
            end
            if mRoomData.PDKPlayerList[3].PokerNumber == 2 then
                local people=math.random(2)
                local IsMan = false
                for k=1, #data.PublicConfig.HeadIconMan, 1 do
                    if mRoomData.PDKPlayerList[position].HeadIcon == data.PublicConfig.HeadIconMan[k] then
                        IsMan = true
                        break
                    end
                end
                if IsMan == true then
                    this:DelayInvoke(0.5,function ()
                        PlayAudioClip("PDK_Alert")
                    end)
                    this:DelayInvoke(1.5,function ()
                        local MusicidName ="PDK_man_Left2"
                        PlayAudioClip(MusicidName)
                    end)
                else
                    this:DelayInvoke(0.5,function ()
                        PlayAudioClip("PDK_Alert")
                    end)
                    this:DelayInvoke(1.5,function ()
                        local MusicidName ="PDK_woman_Left2"
                        PlayAudioClip(MusicidName)
                    end)
                end
            elseif mRoomData.PDKPlayerList[3].PokerNumber == 1 then
                local people=math.random(2)
                local IsMan = false
                for k=1, #data.PublicConfig.HeadIconMan, 1 do
                    if mRoomData.PDKPlayerList[position].HeadIcon == data.PublicConfig.HeadIconMan[k] then
                        IsMan = true
                        break
                    end
                end
                if IsMan == true then
                    this:DelayInvoke(0.5,function ()
                        PlayAudioClip("PDK_Alert")
                    end)
                    this:DelayInvoke(1.5,function ()
                        local MusicidName ="PDK_man_Left1"
                        PlayAudioClip(MusicidName)
                    end)
                else
                this:DelayInvoke(0.5,function ()
                    PlayAudioClip("PDK_Alert")
                end)
                this:DelayInvoke(1.5,function ()
                    local MusicidName ="PDK_woman_Left1"
                    PlayAudioClip(MusicidName)
                end)
            end
        end
    end 
    elseif mRoomData.LastPosition == 1 or mRoomData.LastPosition == 2 then
        OutCardAnimation(position)
        PokerTypeAnimation(position)
        UpdatePlayer1Player2PokerNumber(position)
    end
    if mRoomData.OutPokerTypre == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_BOMB then
        this:DelayInvoke(0.5,function ()
            TextBomb()
        end)
        
    elseif mRoomData.OutPokerTypre == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_PLANE then
        PlanAnimtion()
    end
end

-- 更新玩家1玩家2剩余扑克数量
function UpdatePlayer1Player2PokerNumber(position)
        mRoomData.PDKPlayerList[position].PokerNumber= mRoomData.PDKPlayerList[position].PokerNumber - #mRoomData.OutCardInfo
        if position == 1 then
            Player1PokerTableDispaly()
            mPlayerPokerNumberText1.text = tostring(mRoomData.PDKPlayerList[1].PokerNumber)
        elseif position == 2 then
            Player2PokerTableDispaly()
            mPlayerPokerNumberText2.text = tostring(mRoomData.PDKPlayerList[2].PokerNumber)
        end
        if mRoomData.PDKPlayerList[position].PokerNumber == 2 or mRoomData.PDKPlayerList[position].PokerNumber == 1 then
            GameObjectSetActive(mPlayerUINodes[position].Alert,true)
            local spriteAnimation = mPlayerUINodes[position].Alert.transform:GetComponent('UGUISpriteAnimation')
            spriteAnimation.enabled=true
        end
        
        if mRoomData.PDKPlayerList[position].PokerNumber == 1 then
            local people=math.random(2)
            local IsMan = false
            for k=1, #data.PublicConfig.HeadIconMan, 1 do
                if mRoomData.PDKPlayerList[position].HeadIcon == data.PublicConfig.HeadIconMan[k] then
                    IsMan = true
                    break
                end
            end
            if IsMan == true then
                this:DelayInvoke(0.5,function ()
                    PlayAudioClip("PDK_Alert")
                end)
                this:DelayInvoke(1.5,function ()
                    local MusicidName ="PDK_man_Left1"
                    PlayAudioClip(MusicidName)
                end)
            else
                this:DelayInvoke(0.5,function ()
                    PlayAudioClip("PDK_Alert")
                end)
                this:DelayInvoke(1.5,function ()
                    local MusicidName ="PDK_woman_Left1"
                    PlayAudioClip(MusicidName)
                end)
            end
        elseif mRoomData.PDKPlayerList[position].PokerNumber == 2 then
            local people=math.random(2)
            local IsMan = false
            for k=1, #data.PublicConfig.HeadIconMan, 1 do
                if mRoomData.PDKPlayerList[position].HeadIcon == data.PublicConfig.HeadIconMan[k] then
                    IsMan = true
                    break
                end
            end
            if IsMan == true then
                this:DelayInvoke(0.5,function ()
                    PlayAudioClip("PDK_Alert")
                end)
                this:DelayInvoke(1.5,function ()
                    local MusicidName ="PDK_man_Left2"
                    PlayAudioClip(MusicidName)
                end)
            else
                this:DelayInvoke(0.5,function ()
                    PlayAudioClip("PDK_Alert")
                end)
                this:DelayInvoke(1.5,function ()
                    local MusicidName ="PDK_woman_Left2"
                    PlayAudioClip(MusicidName)
                end)
            end
        end
end

-- 玩家出牌动画
function OutCardAnimation(position)
    if OutCardEnt.transform:Find('OutCard1') ~= nil then
        local destoryCopy = OutCardEnt.transform:Find('OutCard1').gameObject
        CS.UnityEngine.Object.Destroy(destoryCopy)
    end
    if OutCardEnt.transform:Find('OutCard2') ~= nil then
        local destoryCopy = OutCardEnt.transform:Find('OutCard2').gameObject
        CS.UnityEngine.Object.Destroy(destoryCopy)
    end
    if position == 3 then
        Player3OutPokerPosition(position)
    else
        Player1Player2OutPokerPosition(position)
    end
end

-- 玩家3出牌
function Player3OutPokerPosition(position)
    local Copy=CS.UnityEngine.Object.Instantiate(OutCardTemplate)
    CS.Utility.ReSetTransform(Copy.transform,OutCardEnt.transform)
    Copy.name = "OutCard2"
    for Index=1,#mRoomData.OutCardInfo,1 do
        local Poker = Copy.transform:Find('Card/Poker'..Index).gameObject
        Poker.transform:GetComponent("TweenColor").enabled=true
        Poker.transform:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(mRoomData.OutCardInfo[Index]))
        GameObjectSetActive(Poker,true)
    end
    local Tween = Copy.transform:GetComponent("TweenPosition")
    local tweenScale = Copy.transform:GetComponent("TweenScale")
    local tweenRotation = Copy.transform:GetComponent("TweenRotation")
    
    this:DelayInvoke(0.1,function ()
        GameObjectSetActive(Copy,true)
        if position == 1 then
            tweenRotation.from = CS.UnityEngine.Vector3(0,0,90)
            tweenRotation.to = CS.UnityEngine.Vector3.zero
            tweenRotation:ResetToBeginning()
            tweenRotation:Play(true)
        elseif position == 2 then
            tweenRotation.from = CS.UnityEngine.Vector3(0,0,-90)
            tweenRotation.to = CS.UnityEngine.Vector3.zero
            tweenRotation:ResetToBeginning()
            tweenRotation:Play(true)
        end
        local form_position_x = OutCardStart[position].transform.localPosition.x
        local form_position_y = OutCardStart[position].transform.localPosition.y
        local to_position_x = OutCardEnt.transform.localPosition.x
        local to_position_y = OutCardEnt.transform.localPosition.y
        Tween.from = CS.UnityEngine.Vector3(form_position_x,form_position_y,0)
        Tween.to = CS.UnityEngine.Vector3(to_position_x,0,0)
        Tween:ResetToBeginning()
        Tween:Play(true)
        tweenScale:ResetToBeginning()
        tweenScale:Play(true)
        
    end)
end

-- 玩家1玩家2出牌
function Player1Player2OutPokerPosition(position)
    local OutPokerBank = this.transform:Find('Canvas/PlayeOutPoke').gameObject

    local Tween = OutPokerBank.transform:GetComponent("TweenPosition")
    local tweenRotation = OutPokerBank.transform:GetComponent("TweenRotation")
    local tweenScale = OutPokerBank.transform:GetComponent("TweenScale")
    local Count =#mRoomData.OutCardInfo

    local CopyPokers = CS.UnityEngine.Object.Instantiate(OutCardTemplate)
    CS.Utility.ReSetTransform(CopyPokers.transform,OutCardEnt.transform)
    CopyPokers.name = "OutCard1"
    GameObjectSetActive(CopyPokers,true)
    local Grid = CopyPokers.transform:Find('Card'):GetComponent('GridLayoutGroup')
    for Index=1,#mRoomData.OutCardInfo,1 do
        local Poker = CopyPokers.transform:Find('Card/Poker'..Index).gameObject
        Poker.transform:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(mRoomData.OutCardInfo[Index]))
        Poker.transform:GetComponent("Image").enabled=false
        CountingPlateCardNumber[mRoomData.OutCardInfo[Index].PokerNumber]=CountingPlateCardNumber[mRoomData.OutCardInfo[Index].PokerNumber]-1
        if CountingPlateCardNumber[mRoomData.OutCardInfo[Index].PokerNumber] < 0 then
            CountingPlateCardNumber[mRoomData.OutCardInfo[Index].PokerNumber] = 0
        end
        mCountingPlateText[mRoomData.OutCardInfo[Index].PokerNumber].text = "<color=white>"..tostring(CountingPlateCardNumber[mRoomData.OutCardInfo[Index].PokerNumber]).."</color>"
        GameObjectSetActive(Poker,true)
    end
    OutPokerBank.transform:Find("Image"):GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(mRoomData.OutCardInfo[1]))

    this:DelayInvoke(0.1,function ()
        GameObjectSetActive(OutPokerBank,true)
        if position == 1 then
            tweenRotation.from = CS.UnityEngine.Vector3(0,0,90)
            tweenRotation.to = CS.UnityEngine.Vector3.zero
            tweenRotation:ResetToBeginning()
            tweenRotation:Play(true)
        elseif position == 2 then
            tweenRotation.from = CS.UnityEngine.Vector3(0,0,-90)
            tweenRotation.to = CS.UnityEngine.Vector3.zero
            tweenRotation:ResetToBeginning()
            tweenRotation:Play(true)
        end
        
        local form_position_x = OutCardStart[position].transform.localPosition.x
        local form_position_y = OutCardStart[position].transform.localPosition.y
        local to_position_x = OutCardEnt.transform.localPosition.x
        local to_position_y = OutCardEnt.transform.localPosition.y
        Tween.from = CS.UnityEngine.Vector3(form_position_x,form_position_y,0)
        Tween.to = CS.UnityEngine.Vector3(to_position_x,to_position_y,0)
        Tween:ResetToBeginning()
        Tween:Play(true)
        tweenScale:ResetToBeginning()
        tweenScale:Play(true)
    end)

    this:DelayInvoke(0.5,function ()
        GameObjectSetActive(OutPokerBank,false)
        Grid.enabled=false
        for Index=1,Count,1 do
            local Poker = CopyPokers.transform:Find('Card/Poker'..Index).gameObject
            Poker.transform:GetComponent("Image").enabled=true
            local tweenPosition2 = Poker.transform:GetComponent("TweenPosition")
            tweenPosition2.from = CS.UnityEngine.Vector3(0,Poker.transform.localPosition.y,0)
            tweenPosition2.to = CS.UnityEngine.Vector3(Poker.transform.localPosition.x,Poker.transform.localPosition.y,0)
            tweenPosition2:ResetToBeginning()
            tweenPosition2:Play(true)
        end
    end)
end



local OutPokerMusicidType={"Single","Pair","Three","Bomb","3W1","1SQ","2SQ","3SQ","3W2","4W3","Plane","4W2"}
-- 出牌音效
function OutCardAudio(position)
    local people=math.random(2)
    local MusicidName =""
    local IsMan = false
    for k=1, #data.PublicConfig.HeadIconMan, 1 do
        if mRoomData.PDKPlayerList[position].HeadIcon == data.PublicConfig.HeadIconMan[k] then
            IsMan = true
            break
        end
    end
    if mRoomData.OutPokerTypre <= GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_COUPLE then
        
        if IsMan then
            MusicidName="PDK_man_"..OutPokerMusicidType[mRoomData.OutPokerTypre]..mRoomData.OutCardInfo[1].PokerNumber
        else
            MusicidName="PDK_woman_"..OutPokerMusicidType[mRoomData.OutPokerTypre]..mRoomData.OutCardInfo[1].PokerNumber
        end
    else
        local Count = mRoomData.OutPokerTypre
        if IsMan then
            MusicidName="PDK_man_"..OutPokerMusicidType[Count]
        else
            MusicidName="PDK_woman_"..OutPokerMusicidType[Count]
        end
    end
    PlayAudioClip(MusicidName)
end

-- 牌型艺术字动画
function PokerTypeAnimation(position)
    if mRoomData.OutPokerTypre > GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_COUPLE then
        local OutPokerTypeName = "sprite_Game_Note_Type_PDK"..mRoomData.OutPokerTypre
        if OutPokerType.activeSelf == true then
            GameObjectSetActive(OutPokerType,false)
        end
        OutPokerImage:ResetSpriteByName(OutPokerTypeName)
        
        local StartPosition = position
        if StartPosition > 2 then
            StartPosition = 2
        end
        local tweenColor = OutPokerType.transform:GetComponent("TweenColor")
        local tweenScale = OutPokerType.transform:GetComponent("TweenScale")
        this:DelayInvoke(0.5,function ()
            GameObjectSetActive(OutPokerType,true)
            local form_position_x = OutPokerTypePosition[StartPosition].transform.localPosition.x
            local form_position_y = OutPokerTypePosition[StartPosition].transform.localPosition.y
            local to_position_x = OutCardEnt2.transform.localPosition.x
            local to_position_y = OutCardEnt2.transform.localPosition.y
            OutPokerTypeTween.from = CS.UnityEngine.Vector3(to_position_x,to_position_x,0)
            OutPokerTypeTween.to = CS.UnityEngine.Vector3(to_position_x,to_position_y,0)
            OutPokerTypeTween.duration=0.000000001
            OutPokerTypeTween:ResetToBeginning()
            OutPokerTypeTween:Play(true)
            tweenColor.from = CS.UnityEngine.Color(255 , 255, 255 , 0)
            tweenColor.to = CS.UnityEngine.Color(255 , 255, 255 , 1)
            tweenColor.duration = 0.00001
            tweenColor:ResetToBeginning()
            tweenColor:Play(true)
            tweenScale:ResetToBeginning()
            tweenScale:Play(true)
        end)

        this:DelayInvoke(1.1,function ()
            local Index = 1
            if StartPosition == 1 then
                Index = 2
            end
            local form_position_x = OutPokerTypePosition[1].transform.localPosition.x
            local form_position_y = OutPokerTypePosition[1].transform.localPosition.y
            local to_position_x = OutCardEnt2.transform.localPosition.x
            local to_position_y = OutCardEnt2.transform.localPosition.y
            OutPokerTypeTween.from = CS.UnityEngine.Vector3(to_position_x,to_position_y,0)
            OutPokerTypeTween.to = CS.UnityEngine.Vector3(form_position_x,form_position_y,0)
            OutPokerTypeTween.duration=0.1
            OutPokerTypeTween:ResetToBeginning()
            OutPokerTypeTween:Play(true)
            tweenColor.from = CS.UnityEngine.Color(255, 255, 255,1)
            tweenColor.to = CS.UnityEngine.Color(255, 255, 255,0)
            tweenColor.duration = 0.1
            tweenColor:ResetToBeginning()
            tweenColor:Play(true)
        end)
        
        this:DelayInvoke(1.3,function ()
            GameObjectSetActive(OutPokerType,false)
        end)
    end
end

-- 玩家要不起
function PlayerYaoBuQi(position)
    if mPlayerUINodes[position].YaoBuQi.activeSelf == true then
        return 
    else
        if position ~= 3 then
            YaoBuQiNumber=YaoBuQiNumber+1
            if mRoomData.PDKPlayerList[position].PokerNumber > 16 then
                return
            end
        else
            YaoBuQiNumber=0
        end
        mPlayerUINodes[position].YaoBuQi:SetActive(true)
        local Index =math.random(2)
        local people = math.random(2)
        local IsMan = false
        for k=1,#data.PublicConfig.HeadIconMan,1 do
            if mRoomData.PDKPlayerList[position].HeadIcon == data.PublicConfig.HeadIconMan[k] then
                IsMan = true
                break
            end
        end
        local MusicidName="PDK_man_Pass"..Index
        if IsMan == false then
            MusicidName = "PDK_woman_Pass"..Index
        end
        PlayAudioClip(MusicidName)
        this:DelayInvoke(1.5,function ()
            mPlayerUINodes[position].YaoBuQi:SetActive(false)
        end)
    end
end


-- 恢复选中扑克牌
function WhiteIsDownPoker(value)
    if value == true then
        for Index = 1,16,1 do
            if CheckPokerState[Index].IsOk == true then
                for Count =1,16,1 do
                    PlayerPokersImage[Count].color=CS.UnityEngine.Color.white
                end
                PokerPosition()
                return 
            end
        end
    end
end

-- 灰化选中扑克牌
function GreyIsDownPoker(mIndex)
    if CheckPokerState[mIndex].isDown == true then
        PlayerPokersImage[mIndex].color=CS.UnityEngine.Color.grey
    end
end

-- 出牌按钮，提示按钮显示
function OutButtonPromptButtonDisplay()
    if mRoomData.PDKPlayerList[MAX_PDKZUJU_ROOM_PLAYER].PlayerState == PlayerStateEnumPDK.Out then
        GameObjectSetActive(mPromptButtonGameObject,true)
        GameObjectSetActive(mOutPokerButtonGameObject,true)
        if mRoomData.PDKPlayerList[3].IsRobot == 1 then
            GameObjectSetActive(mPromptButtonGameObject,false)
            GameObjectSetActive(mOutPokerButtonGameObject,false)
        end
    else
        GameObjectSetActive(mPromptButtonGameObject,false)
        GameObjectSetActive(mOutPokerButtonGameObject,false)
    end
    
end

-- 玩家点击提示按钮
function PromptButtonOnClick()
    NetMsgHandler.Send_CS_PDK_Prompt()
end

-- 反馈玩家点击提示
function FeedbackPromptButtonOnClick()
    for Num=1,16,1 do
        if CheckPokerState[Num].PokerState == 2 then
            CheckPokerState[Num].PokerState = 1
        end
    end
    
    for Index=1,#mRoomData.Prompt,1 do
        for Count=1,#mRoomData.PDKPlayerList[3].Pokers,1 do
            if mRoomData.Prompt[Index].PokerType == mRoomData.PDKPlayerList[3].Pokers[Count].PokerType and mRoomData.Prompt[Index].PokerNumber == mRoomData.PDKPlayerList[3].Pokers[Count].PokerNumber then
                CheckPokerState[Count].PokerState = 2
                break
            end
        end
    end
    PokerPosition()
end

function mOutPokerButtoninteractable()
    local display = false
    for Index = 1,16,1 do
        if CheckPokerState[Index].PokerState == 2 then
            display = true
            return display
        end
    end
    return display
end

-- 确定先手状态倒计时
function DellCountDown()
    for Index=1,MAX_PDKZUJU_ROOM_PLAYER,1 do
        if mRoomData.PDKPlayerList[Index].PlayerState == PlayerStateEnumPDK.Out then
            mRoomData.PlardCardPosition = Index
            PlayerLightDisplay()
        end
    end
end

-- 更新倒计时
function UpdateCountDown()
    if FristPlayerOutTime then
        DellCountDown()
    end
    if mRoomData.RoomState == ROOM_STATE_PDK.CHUPAI  then
        PlayerLightDisplay()
    end
    if SettlementCountDown then
        CountDownDisplay()
    end
end


-- 结算倒计时显示
function CountDownDisplay()
    mRoomData.CountDown=mRoomData.CountDown-mTime.deltaTime
    local second=mRoomData.CountDown
    local maxValue = data.PublicConfig.PDK_ROOM_TIME[ROOM_STATE_PDK.SETTLEMENT]
    if second < 0 then
        second = 0
        mSettlementGameObject.ParticleEffect:SetActive(false);
    end
    local mSecond = tostring(math.ceil(second))
    mSettlementGameObject.CountDownText1.text="继续(<color=#FF0000>"..mSecond.."s</color>)"
    mSettlementGameObject.CountDownText2.text="继续(<color=#FF0000>"..mSecond.."s</color>)"
    
end

-- 玩家头顶光圈
function PlayerLightDisplay()
    local checkCountDown = mCountDownLight[mRoomData.PlardCardPosition]
    local maxValue = data.PublicConfig.PDK_ROOM_TIME[ROOM_STATE_PDK.CHUPAI]
    mRoomData.CountDown=mRoomData.CountDown-mTime.deltaTime
    local second=mRoomData.CountDown
    if second < 0 then
        second = 0
    end
    if checkCountDown ~= nil then
        checkCountDown.gameObject:SetActive(true)
        local mfillAmount = second / maxValue
        local countDownProgress =nil
        if mRoomData.PlardCardPosition == 3 then
            this.transform:Find('Canvas/Players/CountDown3_2').gameObject:SetActive(true)
            countDownProgress = this.transform:Find('Canvas/Players/CountDown3_2/Image'):GetComponent("Image")
            this.transform:Find('Canvas/Players/CountDown3/ValueText'):GetComponent("Text").text = tostring(math.ceil(second))
        else
            countDownProgress = checkCountDown.transform:Find('Image'):GetComponent("Image")
            checkCountDown.transform:Find('ValueText'):GetComponent("Text").text = tostring(math.ceil(second))
            
        end
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

-- 桌面Loading动画显示
function LoadingAnitationDispaly()
    if mRoomData:PlayerCount() < 3 and ((mRoomData.RoomState < ROOM_STATE_PDK.DEAL) or(mRoomData.RoomState >= ROOM_STATE_PDK.SETTLEMENT)) then
        GameObjectSetActive(LoadingObject,true)
    else
        GameObjectSetActive(LoadingObject,false)
    end
end

-- 准备按钮是否显示
function ZBButtonISShow(mShow)
    if mZBButtonGameObject.activeSelf == mShow then
        return
    end
    if mShow then
        if mRoomData.PDKPlayerList[3].PlayerState == PlayerStateEnumPDK.LookOn and mRoomData.RoomState == ROOM_STATE_PDK.READY then
            mZBButtonGameObject:SetActive(mShow)
        else
            mZBButtonGameObject:SetActive(false)
        end
    else
        mZBButtonGameObject:SetActive(mShow)
    end
    
    
end

-- 准备图标显示
function ZBImageIsShow(mPosition,mShow)
    if mRoomData.RoomState >ROOM_STATE_PDK.DELAY and mRoomData.RoomState < ROOM_STATE_PDK.SETTLEMENT then
        return 
    end
    if mPosition == 3 then
        SettlementInterfaceDisplayInfo(false)
        ExitButtonAndAgainButtonDisplay(false)
        ZBButtonISShow(false)
        for Index=1,3,1 do
            ClosePlayerShowPoker(Index)
        end
        if OutCardEnt.transform:Find('OutCard1') ~= nil then
            local destoryCopy = OutCardEnt.transform:Find('OutCard1').gameObject
            CS.UnityEngine.Object.Destroy(destoryCopy)
        end
        if OutCardEnt.transform:Find('OutCard2') ~= nil then
            local destoryCopy = OutCardEnt.transform:Find('OutCard2').gameObject
            CS.UnityEngine.Object.Destroy(destoryCopy)
        end
    end
    
    if mRoomData.PDKPlayerList[mPosition].PlayerState ~= PlayerStateEnumPDK.Ready then
        mPlayerUINodes[mPosition].ZBImage:SetActive(false)
    else
        mPlayerUINodes[mPosition].ZBImage:SetActive(true)
    end
    
end

-- 关闭玩家展示手牌
function ClosePlayerShowPoker(position)
    if position == 1 then
        for Index=1,16,1 do
            GameObjectSetActive(mPlayerRemainingPokerCards1[Index],false)
        end
    elseif position == 2 then
        for Index=1,16,1 do
            GameObjectSetActive(mPlayerRemainingPokerCards2[Index],false)
        end
    elseif position == 3 then
        for Index=1,16,1 do
            GameObjectSetActive(Player3PokerPosition[Index],false)
            GameObjectSetActive(PlayerHavePoker[Index],false)
        end
    end
end

-- 因为炸弹改变金币
function BombChangeGold()
    GoldAddReduceAnimtion(mRoomData.ChangeGoldList,MAX_PDKZUJU_ROOM_PLAYER,1)
end

-- 金币加减动画
function GoldAddReduceAnimtion(PDKGoldList,UPGoldPlayerNumber,CloseTime)
    for positionParam=1,UPGoldPlayerNumber,1 do
        local position=PDKGoldList[positionParam].position
        local updateGold = PDKGoldList[positionParam].Gold
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
        local showData = mRoomData.PDKPlayerList[position]
        showObj.GoldText.text = tostring(lua_GetPreciseDecimal(showData.Gold,2))
    end

    this:DelayInvoke(CloseTime,function()
        ResetPDKWinGold()
    end)
end

-- 重置玩家输赢金币值
function ResetPDKWinGold()
    for position = 1, MAX_PDKZUJU_ROOM_PLAYER, 1 do
        mPlayerUINodes[position].WinText.text = ''
        mPlayerUINodes[position].LoseText.text = ''
    end
end

--==============================--
--desc:准备按钮call
--time:2018-02-27 08:26:07
--@return 
--==============================--
function ZBButtonOnClick()
    NetMsgHandler.Send_CS_MJ_Prepare_Game()
end

-- 规则界面显示
function GameRuleDisplay(mShow)
    if mShow then
        ReturnTransformSetActive()
    end
    GameObjectSetActive(mGameRuleGameObject.Object,mShow)
end

-- 规则界面基本规则
function GameRuleButtonOnClick(valueChange)
    if valueChange then
        for Index=1,4,1 do
            GameObjectSetActive(mGameRuleGameObject.RuleText[Index],false)
        end
        GameObjectSetActive(mGameRuleGameObject.RuleText[1],true)
        GameObjectSetActive(mGameRuleGameObject.PokerType,false)
        GameObjectSetActive(mGameRuleGameObject.Settlement,false)
        GameObjectSetActive(mGameRuleGameObject.SpecialType,false)
        GameObjectSetActive(mGameRuleGameObject.Rule,true)
    end
end

-- 规则界面基本牌型
function GameRulePokerTypeButtonOnClick(valueChange)
    if valueChange then
        for Index=1,4,1 do
            GameObjectSetActive(mGameRuleGameObject.RuleText[Index],false)
        end
        GameObjectSetActive(mGameRuleGameObject.RuleText[2],true)
        GameObjectSetActive(mGameRuleGameObject.PokerType,true)
        GameObjectSetActive(mGameRuleGameObject.Settlement,false)
        GameObjectSetActive(mGameRuleGameObject.SpecialType,false)
        GameObjectSetActive(mGameRuleGameObject.Rule,false)
    end
end

-- 规则界面结算
function GameRuleSettlementButtonOnClick(valueChange)
    if valueChange then
        for Index=1,4,1 do
            GameObjectSetActive(mGameRuleGameObject.RuleText[Index],false)
        end
        GameObjectSetActive(mGameRuleGameObject.RuleText[3],true)
        GameObjectSetActive(mGameRuleGameObject.PokerType,false)
        GameObjectSetActive(mGameRuleGameObject.Settlement,true)
        GameObjectSetActive(mGameRuleGameObject.SpecialType,false)
        GameObjectSetActive(mGameRuleGameObject.Rule,false)
    end
end

-- 规则界面特殊牌型
function GameRuleSpecialPokerType(valueChange)
    if valueChange then
        for Index=1,4,1 do
            GameObjectSetActive(mGameRuleGameObject.RuleText[Index],false)
        end
        GameObjectSetActive(mGameRuleGameObject.RuleText[4],true)
        GameObjectSetActive(mGameRuleGameObject.PokerType,false)
        GameObjectSetActive(mGameRuleGameObject.Settlement,false)
        GameObjectSetActive(mGameRuleGameObject.SpecialType,true)
        GameObjectSetActive(mGameRuleGameObject.Rule,false)
    end
end

--==============================--
--desc:邀请按钮1显示状态更新
--time:2018-01-25 02:30:13
--@return 
--==============================--
function UpdateButtonInvite1ShowState()
    local showParam = true
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

-- 错误提示
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

-- 敬请期待
function JingQingQiDai()
    ErrorHints("敬请期待")
end

-- 💣动画
function TextBomb()
    local tWeenPosition = BombAnimtionObject:GetComponent("TweenPosition")
    local tweenRotation = BombAnimtionObject:GetComponent("TweenRotation")
    local tweenScale = BombAnimtionObject:GetComponent("TweenScale")
    local SpriteAnimation = BombLightAnimtionObject:GetComponent("UGUISpriteAnimation")
    GameObjectSetActive(BombAnimtionObject,true)
    tWeenPosition:ResetToBeginning()
    tWeenPosition.from = CS.UnityEngine.Vector3(BombPosition[mRoomData.LastPosition].transform.localPosition.x,BombPosition[mRoomData.LastPosition].transform.localPosition.y,0)
    tWeenPosition:Play(true)
    tweenRotation:ResetToBeginning()
    tweenRotation:Play(true)
    tweenScale:ResetToBeginning()
    tweenScale:Play(true)
    this:DelayInvoke(0.5,function ()
        GameObjectSetActive(BombAnimtionObject,false)
        GameObjectSetActive(BombLightAnimtionObject,true)
        PlayAudioClip("PDK_Special_Bomb")
        SpriteAnimation:RePlay()
    end)
    this:DelayInvoke(1,function ()
        GameObjectSetActive(BombLightAnimtionObject,false)
    end)
end

-- ✈动画
function PlanAnimtion()
    local tWeenPosition = PlanAnimtionObject1:GetComponent("TweenPosition")
    local tweenRotation = PlanAnimtionObject1:GetComponent("TweenRotation")
    local tweenScale = PlanAnimtionObject1:GetComponent("TweenScale")
    local twennPosition2 = PlanAnimtionObject2:GetComponent("TweenPosition")
    GameObjectSetActive(PlanAnimtionObject1,true)
    PlayAudioClip("PDK_Special_Plane")
    tWeenPosition:ResetToBeginning()
    tWeenPosition:Play(true)
    tweenRotation:ResetToBeginning()
    tweenRotation:Play(true)
    tweenScale:ResetToBeginning()
    tweenScale:Play(true)
    this:DelayInvoke(0.7,function ()
        GameObjectSetActive(PlanAnimtionObject1,false)
        GameObjectSetActive(PlanAnimtionObject2,true)
        twennPosition2:ResetToBeginning()
        twennPosition2:Play(true)
    end)
    this:DelayInvoke(1.2,function ()
        GameObjectSetActive(PlanAnimtionObject2,false)
    end)
end

-- 音乐开关
function BackMusicSwithControl_OnValueChanged(isOn)
	MusicMgr:MuteBackMusic(isOn)
	MusicMgr:PlaySoundEffect('2')
end
-- 音效开关
function EffectMusicSwithControl_OnValueChanged(isOn)
	MusicMgr:PlaySoundEffect('2')
	MusicMgr:MuteSoundEffect(isOn)
end

-- 打开设置界面
function SetInterfaceDisplay(mShow)
    GameObjectSetActive(mSetInterfaceObject,mShow)
end

-- 打开银行
function StoreDisplay()
    CS.WindowManager.Instance:OpenWindow("UIExtract")
end

-- 是否读取本地排行榜信息
function JudgmentTimeInterval(windowData)
    if GameData.RankInfo.PdkRankTime == 0 then
        return true
    end
    local time1 = os.time()
    if time1 - GameData.RankInfo.PdkRankTime >= 60 then
        return true
    end
    return false
end

-- 响应排行榜按钮点击事件
function RankButtonOnClick()
    ReturnTransformSetActive()
    local initParam = CS.WindowNodeInitParam("PDKRank")
    initParam.WindowData = GAME_RANK_TYPE.PDK_MONEY
    CS.WindowManager.Instance:OpenWindow(initParam)
    if JudgmentTimeInterval(GAME_RANK_TYPE.PDK_MONEY) == true then
        NetMsgHandler.SendRequestRanks(GAME_RANK_TYPE.PDK_MONEY)
    end
end

-- 记分板显示
function CardNumberDisplay()
    if mRoomData.RoomState > ROOM_STATE_PDK.DEAL and mRoomData.RoomState <= ROOM_STATE_PDK.SETTLEMENT then
        GameObjectSetActive(mCountingPlateGameObject,true)
        for Index=1,13,1 do
            if CountingPlateCardNumber[Index] >= 4 then
                mCountingPlateText[Index].text = "<color=red>"..tostring(CountingPlateCardNumber[Index]).."</color>"
            else
                mCountingPlateText[Index].text = "<color=white>"..tostring(CountingPlateCardNumber[Index]).."</color>"
            end
        end
    else
        GameObjectSetActive(mCountingPlateGameObject,false)
    end
end

-- 玩家请求托管
function CanceRobotButtonlOnDisplay(mType)
    NetMsgHandler.Send_CS_PDK_ROBOT(mType)
end

-- 取消托管按钮显示
function CanceRobotButtonlDisplay()
    if mRoomData.PDKPlayerList[3].IsRobot == 0 then
        GameObjectSetActive(mCanceRobotButtonlObject,false)
        mRobotButtonlObject.interactable = true
        if mRoomData.PDKPlayerList[3].PlayerState < PlayerStateEnumPDK.DECISION then
            mRobotButtonlObject.interactable = false
        end
        
        GameObjectSetActive(mRobotPokerMaskObject,false)
        OutButtonPromptButtonDisplay()
    else
        GameObjectSetActive(mCanceRobotButtonlObject,true)
        mRobotButtonlObject.interactable = false
        GameObjectSetActive(mRobotPokerMaskObject,true)
        OutButtonPromptButtonDisplay()
    end
    
end

-- 发牌动画
function GivePokerAnimtion()
    GameData.PDKIsPlay = true
    local PokerBank={}
    for Index=1,16,1 do
        PokerBank[Index]=PlayerHavePoker[Index].transform:Find("Image").gameObject
        PokerBank[Index]:GetComponent("Image").enabled=false
        PlayerHavePoker[Index].transform:GetComponent("Image").enabled = false
        GameObjectSetActive(Player3PokerPosition[Index],true)
        GameObjectSetActive(PlayerHavePoker[Index],true)
    end
    local player3giveposition = this.transform:Find('Canvas/PlayerCard/Player2GivePoker/GameObject').gameObject
    local player1havepokers = this.transform:Find('Canvas/PlayerCard/Player3GivePoker/GameObject').gameObject
    local player1giveposition = this.transform:Find('Canvas/PlayerCard/player1/Poker').gameObject
    local player2giveposition = this.transform:Find('Canvas/PlayerCard/player2/Poker').gameObject
    local Player1tweenPosition = player1giveposition.transform:GetComponent("TweenPosition")
    local Player2tweenPosition = player2giveposition.transform:GetComponent("TweenPosition")
    GameObjectSetActive(mPlayerPokerGameObject3,true)
    GameObjectSetActive(player1giveposition,false)
    GameObjectSetActive(player2giveposition,false)
    for Index = 1,10,1 do
        Player1CardTable[Index].transform.localEulerAngles =CS.UnityEngine.Vector3(0,0,0)
        Player2CardTable[Index].transform.localEulerAngles =CS.UnityEngine.Vector3(0,0,0)
    end
    
    this:DelayInvoke(0.5,function ()
        GameObjectSetActive(player1giveposition,true)
        GameObjectSetActive(player2giveposition,true)
        for Index=1,10,1 do
            GameObjectSetActive(Player1CardTable[Index],true)
            GameObjectSetActive(Player2CardTable[Index],true)
        end
        Player1tweenPosition.to=CS.UnityEngine.Vector3(player1giveposition.transform.localPosition.x,player1giveposition.transform.localPosition.y,0)
        Player1tweenPosition:ResetToBeginning()
        Player1tweenPosition:Play(true)
        Player2tweenPosition.to=CS.UnityEngine.Vector3(player2giveposition.transform.localPosition.x,player2giveposition.transform.localPosition.y,0)
        Player2tweenPosition:ResetToBeginning()
        Player2tweenPosition:Play(true)
    end)
    this:DelayInvoke(0.8,function ()
        for Index = 1,10,1 do
            local player1tweenRotation=Player1CardTable[Index].transform:GetComponent('TweenRotation')
            local player2tweenRotation=Player2CardTable[Index].transform:GetComponent('TweenRotation')
            player1tweenRotation:ResetToBeginning()
            player1tweenRotation:Play(true)
            player2tweenRotation:ResetToBeginning()
            player2tweenRotation:Play(true)
        end
    end)
    local giveTimeTable={0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,1.1,1.2,1.3,1.4,1.5,1.6,1.7}
    local giveTime=giveTimeTable[#giveTimeTable]
    local fanpaiTime = giveTime
    local AddPosition = 0
    -- 往玩家手里发牌
    for Index=1,16,1 do
        this:DelayInvoke(giveTimeTable[Index],function ()
            --PlayerGrid.enabled=false
            local tweenPosition = PlayerHavePoker[Index].transform:GetComponent("TweenPosition")
            local tweenScale = PlayerHavePoker[Index].transform:GetComponent("TweenScale")
            PokerBank[Index]:GetComponent("Image").enabled=true
            PlayerHavePoker[Index].transform.localEulerAngles =CS.UnityEngine.Vector3(0,0,1.8*((16-1)/2-Index+1))
            GameObjectSetActive(PlayerHavePoker[Index],true)
            local position_y = Player3PokerPosition_Y[Index].transform.localPosition.y
            tweenPosition.to = CS.UnityEngine.Vector3(PlayerHavePoker[Index].transform.localPosition.x,position_y,0)
            tweenPosition:ResetToBeginning()
            tweenPosition:Play(true)
            tweenScale:ResetToBeginning()
            tweenScale:Play(true)
            PlayAudioClip("3")
        end)
        giveTime=giveTime+0.04
        fanpaiTime = giveTime+0.1
        local tweenRotation = PlayerHavePoker[Index].transform:GetComponent("TweenRotation")
        -- 翻牌
        this:DelayInvoke(giveTime,function ()
            PlayerHavePoker[Index].transform:GetComponent("Image").enabled = true
            PokerBank[Index]:GetComponent("Image").enabled=false
            PlayAudioClip("4")
        end)
    end
end

-- 点击空白处扑克牌归位
function PokerMaskButtonOnClick()
    for Index=1,16,1 do
        if CheckPokerState[Index].PokerState == 2 then
            CheckPokerState[Index].PokerState = 1
        end
    end
    PokerPosition()
end

-- 玩家1扇形扑克角度
function Player1PokerTableDispaly()
    local player1giveposition = this.transform:Find('Canvas/PlayerCard/player1/Poker').gameObject
    GameObjectSetActive(player1giveposition,true)
    local num=mRoomData.PDKPlayerList[1].PokerNumber
    local angl=10
    if num >= 7 then
        num = 10
        for Index=1,num,1 do
            Player1CardTable[Index].transform.localEulerAngles =CS.UnityEngine.Vector3(0,0,angl*((num-1)/2-Index))
            GameObjectSetActive(Player1CardTable[Index],true)
        end
    elseif num> 1 and num <7 then
        for Index=num,10,1 do
            GameObjectSetActive(Player1CardTable[Index],false)
        end
        for Index=1,num,1 do
            Player1CardTable[Index].transform.localEulerAngles =CS.UnityEngine.Vector3(0,0,angl*((num-1)/2-Index))
            GameObjectSetActive(Player1CardTable[Index],true)
        end
    elseif num == 1 then
        for Index=num,10,1 do
            GameObjectSetActive(Player1CardTable[Index],false)
        end
        Player1CardTable[num].transform.localEulerAngles =CS.UnityEngine.Vector3(0,0,0)
        GameObjectSetActive(Player1CardTable[num],true)
    elseif num == 0 then
        for Index=1,10,1 do
            GameObjectSetActive(Player1CardTable[Index],false)
        end
    end
end

-- 玩家2扇形扑克角度
function Player2PokerTableDispaly()
    local num=mRoomData.PDKPlayerList[2].PokerNumber
    local player2giveposition = this.transform:Find('Canvas/PlayerCard/player2/Poker').gameObject
    GameObjectSetActive(player2giveposition,true)
    local angl=10
    if num >= 7 then
        num = 10
        for Index=1,num,1 do
            Player2CardTable[Index].transform.localEulerAngles =CS.UnityEngine.Vector3(0,0,angl*((num-1)/2-Index))
            GameObjectSetActive(Player2CardTable[Index],true)
        end
    elseif num> 1 and num <7 then
        for Index=num,10,1 do
            GameObjectSetActive(Player2CardTable[Index],false)
        end
        for Index=1,num,1 do
            Player2CardTable[Index].transform.localEulerAngles =CS.UnityEngine.Vector3(0,0,angl*((num-1)/2-Index))
            GameObjectSetActive(Player2CardTable[Index],true)
        end
    elseif num == 1 then
        for Index=num,10,1 do
            GameObjectSetActive(Player2CardTable[Index],false)
        end
        Player2CardTable[num].transform.localEulerAngles =CS.UnityEngine.Vector3(0,0,0)
        GameObjectSetActive(Player2CardTable[num],true)
    elseif num == 0 then
        for Index=1,10,1 do
            GameObjectSetActive(Player2CardTable[Index],false)
        end
    end
end

-- 全关动画
function PlayerAllCloseAnimation(position)
    local AllCloseObject = this.transform:Find('Canvas/Players/Player'..position..'/AllCloseAnmation').gameObject
    local LockBank = AllCloseObject.transform:Find('Image10').gameObject
    local tweenScale =  LockBank.transform:GetComponent('TweenScale')
    local tweenColor = LockBank.transform:GetComponent('TweenColor')
    local Lock = AllCloseObject.transform:Find('Image11').gameObject
    local lockColor = Lock.transform:GetComponent('TweenColor')
    local lockPosition = Lock.transform:GetComponent('TweenPosition')
    local lockRotation = Lock.transform:GetComponent('TweenRotation')
    local AllCloseTime = 0
    for Index=1,9,1 do
        this:DelayInvoke(AllCloseTime,function ()
            local ImageObject = AllCloseObject.transform:Find('Image'..Index).gameObject
            local tweenPosition = ImageObject.transform:GetComponent('TweenPosition')
            local tweenColor = ImageObject.transform:GetComponent('TweenColor')
            GameObjectSetActive(ImageObject,true)
            tweenPosition:ResetToBeginning()
            tweenPosition:Play(true)
            tweenColor:ResetToBeginning()
            tweenColor:Play(true)
        end)
        AllCloseTime=AllCloseTime+0.07
    end
    this:DelayInvoke(AllCloseTime,function ()
        GameObjectSetActive(LockBank,true)
        tweenScale:ResetToBeginning()
        tweenScale:Play(true)
        tweenColor:ResetToBeginning()
        tweenColor:Play(true)
    end)
    AllCloseTime=AllCloseTime+0.07
    this:DelayInvoke(AllCloseTime,function ()
        GameObjectSetActive(Lock,true)
        lockColor:ResetToBeginning()
        lockColor:Play(true)
        lockPosition:ResetToBeginning()
        lockPosition:Play(true)
    end)
    AllCloseTime=AllCloseTime+0.07
    this:DelayInvoke(AllCloseTime,function ()
        lockRotation:ResetToBeginning()
        lockRotation:Play(true)
    end)
    
end

--=================3局切换房间黑屏表现=====================

local mRoomChangeGameObject = nil

function InitRoomChange()
    mRoomChangeGameObject = this.transform:Find('Canvas/RoomChange').gameObject
    GameObjectSetActive(mRoomChangeGameObject, false)
end

function OnNotifyRoomChangeEvent()
    mRoomChangeGameObject = this.transform:Find('Canvas/RoomChange').gameObject
    GameObjectSetActive(mRoomChangeGameObject, true)
    this:DelayInvoke(1.0, function ()
        GameObjectSetActive(mRoomChangeGameObject, false)
        CS.BubblePrompt.Show(data.GetString("T_430_1"), "HallUI")
    end)
end

-- ==================检测牌型=======================

function OutPokerButtonInteractable(tCard)
    
    if mRoomData.PDKPlayerList[3].PlayerState == PlayerStateEnumPDK.Out then
        local IsInteractable=false
        --print("$$$$$$$$检测牌型",mRoomData.DesktopCard,mRoomData.DesktopCardType,#tCard,#mRoomData.DesktopCardTable)
        if mRoomData.DesktopCard == 3 then
            IsInteractable=DontConsiderOtherPlayer(tCard)
        else
            IsInteractable=NeedConsiderOtherPlayer(mRoomData.DesktopCardTable,tCard)
        end
        mOutPokerButton.interactable = IsInteractable
    end
    
end

-- 测试专用
function TestData()
    local OutCardInfo={}
    OutCardInfo = 
    {
        {PokerNumber=12,PokerType=1},{PokerNumber=12,PokerType=2},{PokerNumber=12,PokerType=4},{PokerNumber=11,PokerType=4},
        {PokerNumber=11,PokerType=2},{PokerNumber=11,PokerType=1},{PokerNumber=10,PokerType=1},{PokerNumber=10,PokerType=1},
        --{PokerNumber=10,PokerType=2},{PokerNumber=7,PokerType=2},{PokerNumber=7,PokerType=1},{PokerNumber=6,PokerType=2},
        {PokerNumber=5,PokerType=1},--{PokerNumber=5,PokerType=2},{PokerNumber=4,PokerType=2},--{PokerNumber=4,PokerType=2},
    }
    local DesktopCard={}
    DesktopCard = 
    {
        --{PokerNumber=3,PokerType=1},{PokerNumber=4,PokerType=2},{PokerNumber=5,PokerType=1},{PokerNumber=5,PokerType=2},
        {PokerNumber=6,PokerType=4},{PokerNumber=6,PokerType=4},{PokerNumber=9,PokerType=2},--{PokerNumber=9,PokerType=1},
        {PokerNumber=10,PokerType=2},{PokerNumber=10,PokerType=2},{PokerNumber=10,PokerType=1},--{PokerNumber=10,PokerType=2},
        {PokerNumber=11,PokerType=1},{PokerNumber=11,PokerType=2},{PokerNumber=11,PokerType=2},--{PokerNumber=4,PokerType=2},
    }
    mRoomData.OutPokerTypre = GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_PLANE
    local a=NeedConsiderOtherPlayer(DesktopCard,OutCardInfo)
    
end

-- 检测牌型时不需考虑上家
function DontConsiderOtherPlayer(tCard)
    if #tCard == 1 then
        return true
    elseif #tCard == 2 then
        return PDKDoublePick(tCard)
    elseif #tCard == 3 then
        if mRoomData.PDKPlayerList[3].Pokers == 3 then
            return PDKThreePick(tCard)
        end
        return false
    elseif #tCard == 4 then
        return PDKFourPick(tCard)
    elseif #tCard == 5 then
        return PDKFivePick(tCard)
    elseif #tCard == 6 then
        return PDKSixPick(tCard)
    elseif #tCard == 7 then
        return PDKSevenPick(tCard)
    elseif #tCard == 8 then
        return PDKEightPick(tCard)
    elseif #tCard == 9 then
        return PDKNinePick(tCard)
    elseif #tCard == 10 then
        return PDKTenPick(tCard)
    elseif #tCard == 11 then
        return PDKElevenPick(tCard)
    elseif #tCard == 12 then
        return PDKTwelvePick(tCard)
    elseif #tCard == 13 then
        return PDKThirteenPick(tCard)
    elseif #tCard == 14 then
        return PDKFourteenPick(tCard)
    elseif #tCard == 15 then
        return PDKFifteenPick(tCard)
    elseif #tCard == 16 then
        return PDKSixteenPick(tCard)
    end
    return false
end

-- 检测牌型时需要考虑上家
function NeedConsiderOtherPlayer(DesktopCard,tCard)
    -- 上一玩家出牌牌型为单张
    if mRoomData.DesktopCardType == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_SINGLE then
        if PDKBombPick(tCard) then
            return true
        end
        if #DesktopCard ~= #tCard then
            return false
        end
        if tCard[1].PokerNumber == 1 then
            tCard[1].PokerNumber = 14
        elseif tCard[1].PokerNumber == 2 then
            tCard[1].PokerNumber = 15
        end
        if DesktopCard[1].PokerNumber < tCard[1].PokerNumber then
            return true
        end

    -- 上一玩家出牌牌型为对子
    elseif mRoomData.DesktopCardType == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_COUPLE then
        if PDKBombPick(tCard) then
            return true
        end
        if #DesktopCard ~= #tCard then
            return false
        end
        if PDKDoublePick(tCard) then
            if DesktopCard[1].PokerNumber < tCard[1].PokerNumber then
                return true
            end
        end

    -- 上一玩家出牌牌型为三张不带
    elseif mRoomData.DesktopCardType == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_THREE then
        if PDKBombPick(tCard) then
            return true
        end
        if #DesktopCard ~= #tCard then
            return false
        end
        if PDKThreePick(tCard) then
            if DesktopCard[1].PokerNumber < tCard[1].PokerNumber then
                return true
            end
        end

    -- 上一玩家出牌牌型为炸弹
    elseif mRoomData.DesktopCardType == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_BOMB then
        if PDKBombPick(tCard) then
            if DesktopCard[1].PokerNumber < tCard[1].PokerNumber then
                return true
            end
        end

    -- 上一玩家出牌牌型为单顺
    elseif mRoomData.DesktopCardType == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_1SQ then
        if PDKBombPick(tCard) then
            return true
        end
        if #DesktopCard ~= #tCard then
            return false
        end
        return GAME_NOTE_TYPE_PDK_1SQPick(DesktopCard,tCard)

    -- 上一玩家出牌牌型为双顺
    elseif mRoomData.DesktopCardType == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_2SQ then
        if PDKBombPick(tCard) then
            return true
        end
        if #DesktopCard ~= #tCard then
            return false
        end
        local Count=(#DesktopCard)/2
        if GAME_NOTE_TYPE_PDK_2SQPick(tCard,Count) then
            if DesktopCard[#DesktopCard].PokerNumber < tCard[1].PokerNumber then
                return true
            end
        end
        return false

    -- 上一玩家出牌牌型为三顺
    elseif mRoomData.DesktopCardType == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_3SQ then

        if PDKBombPick(tCard) then
            return true
        end
        if #DesktopCard ~= #tCard then
            return false
        end
        local Count=(#DesktopCard)/3
        if GAME_NOTE_TYPE_PDK_3SQ(tCard,Count) then
            if DesktopCard[#DesktopCard].PokerNumber < tCard[1].PokerNumber then
                return true
            end
        end
        return false

    -- 上一玩家出牌牌型为三带二
    elseif mRoomData.DesktopCardType == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_3W2 then
        if PDKBombPick(tCard) then
            return true
        end
        if #DesktopCard ~= #tCard then
            return false
        end
        return GAME_NOTE_TYPE_PDK_3W2(DesktopCard,tCard)

    -- 上一玩家出牌牌型为四带三
    elseif mRoomData.DesktopCardType == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_4W3 then
        if #DesktopCard ~= #tCard then
            return false
        end
        return GAME_NOTE_TYPE_PDK_4W3(DesktopCard,tCard)

    -- 上一玩家出牌牌型为飞机
    elseif mRoomData.DesktopCardType == GAME_NOTE_TYPE_PDK.GAME_NOTE_TYPE_PDK_PLANE then
        if PDKBombPick(tCard) then
            return true
        end
        if #DesktopCard ~= #tCard then
            return false
        end
        return GAME_NOTE_TYPE_PDK_PLANE(DesktopCard,tCard)
    end
    return false
end

-- 检测是否连对
function GAME_NOTE_TYPE_PDK_2SQPick(tCard,Count)
    local PokerValue={}
    local DoubleCardTable={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 2 then
            table.insert(DoubleCardTable,v.PokerNumber)
        end
    end
    local IsDouble=true
    local IsFour = true
    for k,v in pairs(PokerValue) do
        if v ~= 2 then
            IsDouble=false
        end
    end

    if IsDouble == true then
        table.sort(DoubleCardTable)
    end
    local IsLianXu=true
    if #DoubleCardTable == Count then
        for Index=1,#DoubleCardTable-1,1 do
            if DoubleCardTable[Index]+1 ~=DoubleCardTable[Index+1] then
                IsLianXu=false
            end
        end
    else
        IsLianXu=false
    end
    
    if IsLianXu == true then
        return IsLianXu
    end
    return false
end

-- 检测顺子是否大过上家
function GAME_NOTE_TYPE_PDK_1SQPick(DesktopCard,tCard)
    if PDKStraightPick(tCard) == false then
        return false
    end
    if tCard[1].PokerNumber > DesktopCard[#DesktopCard].PokerNumber then
        return true
    else
        return false
    end
end

-- 检测是否三顺
function GAME_NOTE_TYPE_PDK_3SQ(tCard,Count)
    local PokerValue={}
    local ThreeCardTable={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 3 then
            table.insert(ThreeCardTable,v.PokerNumber)
        end
    end
    local IsDouble=true
    local IsFour = true
    for k,v in pairs(PokerValue) do
        if v ~= 3 then
            IsDouble=false
        end
    end

    if IsDouble == true then
        table.sort(ThreeCardTable)
    end
    local IsLianXu=true
    if #ThreeCardTable == Count then
        for Index=1,#ThreeCardTable-1,1 do
            if ThreeCardTable[Index]+1 ~=ThreeCardTable[Index+1] then
                IsLianXu=false
            end
        end
    else
        IsLianXu=false
    end
    
    if IsLianXu == true then
        return IsLianXu
    end
    return false
end

-- 检测三带二是否大过上家
function GAME_NOTE_TYPE_PDK_3W2(DesktopCard,tCard)
    local PokerValue={}
    local PokerValue2={}
    local Number=0
    local Number2=0
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
            PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 3 then
            Number=v.PokerNumber            
        end
    end
    for k,v in ipairs(DesktopCard) do
        if PokerValue2[v.PokerNumber]== nil then
            PokerValue2[v.PokerNumber]=0
        end
        PokerValue2[v.PokerNumber]=PokerValue2[v.PokerNumber]+1
        if PokerValue2[v.PokerNumber] == 3 then
            Number2=v.PokerNumber            
        end
    end
    if Number ~= 0 then
        if Number > Number2 then
            return true
        end
    else
        return false
    end
    return false
end

-- 检测四带三是否大过上家
function GAME_NOTE_TYPE_PDK_4W3(DesktopCard,tCard)
    local PokerValue={}
    local PokerValue2={}
    local Number=0
    local Number2=0
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 4 then
            Number=v.PokerNumber
        end
    end
    for k,v in ipairs(DesktopCard) do
        if PokerValue2[v.PokerNumber]== nil then
            PokerValue2[v.PokerNumber]=0
        end
        PokerValue2[v.PokerNumber]=PokerValue2[v.PokerNumber]+1
        if PokerValue2[v.PokerNumber] == 4 then
            Number2=v.PokerNumber
        end
    end
    if Number ~= 0 then
        if Number > Number2 then
            return true
        end
    else
        return false
    end
end

-- 检测飞机是否大过上家
function GAME_NOTE_TYPE_PDK_PLANE(DesktopCard,tCard)
    if #DesktopCard == 15 then
        return FifteenPLANE(DesktopCard,tCard)
    else
        return NinePLANE(DesktopCard,tCard)
    end
end

-- 检测十五张牌的飞机
function FifteenPLANE(DesktopCard,tCard)
    -- 检测3个三张
    local PokerValue={}
    local ThreeCardTable={}
    local DesktopThreeCardTable={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 3 then
            table.insert(ThreeCardTable,v.PokerNumber)
        end
    end
    
    local IsThree=true
    if #ThreeCardTable < 3 then
        IsThree=false
    end

    if IsThree == true then
        table.sort(ThreeCardTable)
        for k,v in ipairs(DesktopCard) do
            if PokerValue[v.PokerNumber]== nil then
                PokerValue[v.PokerNumber]=0
            end
            PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
            if PokerValue[v.PokerNumber] == 3 then
                table.insert(DesktopThreeCardTable,v.PokerNumber)
            end
        end
        table.sort(DesktopThreeCardTable)
    end

    local IsLianXu=true
    local num=0
    local num2=0
    local Number=0
    local Number2=0
    if #ThreeCardTable>=3 then
        for Index=1,#ThreeCardTable,1 do
            for J=2,#ThreeCardTable,1 do
                if ThreeCardTable[Index]+1== ThreeCardTable[J] then
                    num=num+1
                    if num >= 2 then
                        Number = ThreeCardTable[J]
                    end
                end
            end
        end
        for Index=1,#DesktopThreeCardTable,1 do
            for J=2,#DesktopThreeCardTable,1 do
                if DesktopThreeCardTable[Index]+1== DesktopThreeCardTable[J] then
                    num2=num2+1
                    if num2 >= 2 then
                        Number2 = DesktopThreeCardTable[J]
                    end
                end
            end
        end
        if num ~= 0 and Number > Number2 then
            return true
        end
    end
    return false
end

-- 检测九张牌的飞机
function NinePLANE(DesktopCard,tCard)
    local PokerValue={}
    local ThreeCardTable = {}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        
        if PokerValue[v.PokerNumber] == 3 then
            table.insert(ThreeCardTable,v.PokerNumber)
        end
    end
    table.sort(ThreeCardTable)
    if #ThreeCardTable == 2 then
        if math.abs(ThreeCardTable[1]-ThreeCardTable[2]) ~= 1 then
            return false
        end
    elseif #ThreeCardTable == 3 then
        table.sort(ThreeCardTable)
        if math.abs(ThreeCardTable[1]-ThreeCardTable[2]) ~= 1 and math.abs(ThreeCardTable[2]-ThreeCardTable[3]) ~= 1 then
            return false
        end
    end

    local PokerValue2={}
    local ThreeCardTable2 = {}
    for k,v in ipairs(DesktopCard) do
        if PokerValue2[v.PokerNumber]== nil then
            PokerValue2[v.PokerNumber]=0
        end
        PokerValue2[v.PokerNumber]=PokerValue2[v.PokerNumber]+1
        
        if PokerValue2[v.PokerNumber] == 3 then
            table.insert(ThreeCardTable2,v.PokerNumber)
        end
    end
    table.sort(ThreeCardTable2)
    local num=0
    if #ThreeCardTable == 2 then
        if ThreeCardTable[2] - ThreeCardTable[1] == 1 then
            num = ThreeCardTable[2]
        end
    elseif #ThreeCardTable == 3 then
        if ThreeCardTable[3]-ThreeCardTable[2] == 1 then
            num=ThreeCardTable[3]
        elseif ThreeCardTable[2]-ThreeCardTable[1] == 1 then
            num=ThreeCardTable[2]
        end  
    end
    if num ~= 0 then
        if #ThreeCardTable2 == 2 then
            if num > ThreeCardTable2[2] then
                return true
            end
        elseif #ThreeCardTable2 == 3 then
            if ThreeCardTable2[3]-ThreeCardTable2[2] == 1 then
                if num > ThreeCardTable2[3] then
                    return true
                end
            elseif ThreeCardTable2[2]-ThreeCardTable2[1] == 1 then
                if num > ThreeCardTable2[2] then
                    return true
                end
            end
        end
    end
    return false
end


-- 检测两张牌
function PDKDoublePick(tCard)
    if tCard[1].PokerNumber == tCard[2].PokerNumber then
        return true
    else
        return  false
    end
end

-- 检测顺子
function PDKStraightPick(tCard)
    local num=0
    local Count=#tCard-1
    for Index=1,Count,1 do
        if tCard[Index].PokerNumber-1 == tCard[Index+1].PokerNumber then
            num=num+1
            if num == Count then
                return true
            end
        end
    end
    return false
end

-- 检测炸弹
function PDKBombPick(tCard)
    local PokerValue={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 4 then
            return true
        end
    end
    return false
end

-- 检测三张牌
function PDKThreePick(tCard)
    if tCard[1].PokerNumber == tCard[2].PokerNumber and tCard[1].PokerNumber == tCard[3].PokerNumber then
        return true
    else
        return  false
    end
end

-- 检测四张牌
function PDKFourPick(tCard)
    if PDKBombPick(tCard) then
        return true
    end
    local PokerValue={}
    local DoubleCardTable={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 2 then
            table.insert(DoubleCardTable,v.PokerNumber)
        end
    
    end
    local IsDouble=true
    for k,v in pairs(PokerValue) do
        if v ~= 2 then
            IsDouble=false
        end
    end

    if IsDouble == true then
        table.sort(DoubleCardTable)
    end
    local IsLianXu=true
    if #DoubleCardTable == 2 then
        for Index=1,#DoubleCardTable-1,1 do
            if DoubleCardTable[Index]+1 ~=DoubleCardTable[Index+1] then
                IsLianXu=false
            end
        end
    else
        IsLianXu=false
    end
    if IsLianXu == true then
        return IsLianXu
    end
    if mRoomData.PDKPlayerList[3].PokerNumber == 4 then
        for k,v in pairs(PokerValue) do
            if v==3 then
                return true
            end
        end
    end
    return false
end

-- 检测五张牌
function PDKFivePick(tCard)
    if PDKThreePick(tCard) then
        return true
    end
    local PokerValue={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
    end
    for k,v in pairs(PokerValue) do
        if v==3 then
            return true
        end
    end
    if PDKStraightPick(tCard) == true then
        return true
    end
    return false
end

-- 检测六张牌
function PDKSixPick(tCard)
    local PokerValue={}
    local DoubleCardTable={}
    local ThreeCardTable={}
    local FourCardTable = {}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 2 then
            table.insert(DoubleCardTable,v.PokerNumber)
        elseif PokerValue[v.PokerNumber] == 3 then
            table.insert(ThreeCardTable,v.PokerNumber)
        elseif PokerValue[v.PokerNumber] == 4 then
            table.insert(FourCardTable,v.PokerNumber)
        end
    end
    local IsDouble=true
    local IsThree = true
    if #FourCardTable==1 and #mRoomData.PDKPlayerList[3].Pokers then
        return true
    end
    for k,v in pairs(PokerValue) do
        if v ~= 2 then
            IsDouble=false
        end
        if v~= 3 then
            IsThree = false
        end
    end

    if IsDouble == true then
        table.sort(DoubleCardTable)
    end
    if IsThree == true then
        table.sort(ThreeCardTable)
    end
    local IsLianXu=true
    if #DoubleCardTable == 3 then
        for Index=1,#DoubleCardTable-1,1 do
            if DoubleCardTable[Index]+1 ~=DoubleCardTable[Index+1] then
                IsLianXu=false
            end
        end
    else
        IsLianXu=false
    end
    
    if IsLianXu == true then
        return IsLianXu
    end
    if IsThree == true then
        if #ThreeCardTable == 2 and math.abs(ThreeCardTable[1]-ThreeCardTable[2]) == 1 then
            return IsThree
        end
    end

    if PDKStraightPick(tCard) == true then
        return true
    end
    return false
end

-- 检测七张牌
function PDKSevenPick(tCard)
    if PDKBombPick(tCard) then
        return true
    end
    if PDKStraightPick(tCard) == true then
        return true
    end
    return false
end

-- 检测八张牌
function PDKEightPick(tCard)

    local PokerValue={}
    local DoubleCardTable={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 2 then
            table.insert(DoubleCardTable,v.PokerNumber)
        end
    end
    local IsDouble=true
    local IsFour = true
    for k,v in pairs(PokerValue) do
        if v ~= 2 then
            IsDouble=false
        end
    end

    if IsDouble == true then
        table.sort(DoubleCardTable)
    end
    local IsLianXu=true
    if #DoubleCardTable == 4 then
        for Index=1,#DoubleCardTable-1,1 do
            if DoubleCardTable[Index]+1 ~=DoubleCardTable[Index+1] then
                IsLianXu=false
            end
        end
    else
        IsLianXu=false
    end
    
    if IsLianXu == true then
        return IsLianXu
    end
    
    if PDKStraightPick(tCard) == true then
        return true
    end
    return false
end

-- 检测九张牌
function PDKNinePick(tCard)

    local PokerValue={}
    local DoubleCardTable={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 3 then
            table.insert(DoubleCardTable,v.PokerNumber)
        end
        
    end
    local IsThree=true
    for k,v in pairs(PokerValue) do
        if v ~= 3 then
            IsThree=false
        end
    end
    if IsThree == true then
        table.sort(DoubleCardTable)
    end
    local IsLianXu = true
    if #DoubleCardTable == 3 then
        for Index=1,#DoubleCardTable-1,1 do
            if DoubleCardTable[Index]+1 ~= DoubleCardTable[Index+1] then
                IsLianXu=false
            end
        end
    else
        IsLianXu=false
    end

    if IsLianXu == true then
        return IsLianXu
    end
    if PDKStraightPick(tCard) == true then
        return true
    end
    return false
end

-- 检测十张牌
function PDKTenPick(tCard)

    local PokerValue={}
    local DoubleCardTable={}
    local ThreeCardTable = {}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 2 then
            table.insert(DoubleCardTable,v.PokerNumber)
        end
        
        if PokerValue[v.PokerNumber] == 3 then
            table.insert(ThreeCardTable,v.PokerNumber)
        end
    end
    local IsDouble=true
    local IsThree = true
    for k,v in pairs(PokerValue) do
        if v ~= 2 then
            IsDouble=false
        end
    end

    local IsDoubleLianXu = true
    if #DoubleCardTable == 5 and IsDouble == true then
        for Index=1,#DoubleCardTable-1,1 do
            if DoubleCardTable[Index]-1 ~= DoubleCardTable[Index+1] then
                IsDoubleLianXu=false
            end
        end
    else
        IsDoubleLianXu=false
    end

    if IsDoubleLianXu == true then
        return IsDoubleLianXu
    end

    if #ThreeCardTable == 2 then
        if math.abs(ThreeCardTable[1]-ThreeCardTable[2]) == 1 then
            return true
        end
    elseif #ThreeCardTable == 3 then
        table.sort(ThreeCardTable)
        if math.abs(ThreeCardTable[1]-ThreeCardTable[2]) == 1 or math.abs(ThreeCardTable[2]-ThreeCardTable[3]) == 1 then
            return true
        end
    end
    

    if PDKStraightPick(tCard) == true then
        return true
    end
    return false
end

-- 检测十一张牌
function PDKElevenPick(tCard)
    if PDKStraightPick(tCard) == true then
        return true
    end
    return false
end

-- 检测十二张牌
function PDKTwelvePick(tCard)

    local PokerValue={}
    local DoubleCardTable={}
    local ThreeCardTable={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 2 then
            table.insert(DoubleCardTable,v.PokerNumber)
        end
        if PokerValue[v.PokerNumber] == 3 then
            table.insert(ThreeCardTable,v.PokerNumber)
        end
        
    end
    local IsDouble=true
    local IsThree = true
    for k,v in pairs(PokerValue) do
        if v ~= 2 then
            IsDouble=false
        end
        if v ~= 3 then
            IsThree = false
        end
    end

    if IsDouble == true then
        table.sort(DoubleCardTable)
    end

    -- 检测6个对子
    local IsLianXu=true
    if #DoubleCardTable == 6 then
        for Index=1,#DoubleCardTable-1,1 do
            if DoubleCardTable[Index]+1 ~=DoubleCardTable[Index+1] then
                IsLianXu=false
            end
        end
    else
        IsLianXu=false
    end
    if IsLianXu == true then
        return IsLianXu
    end

    -- 检测4个三张
    local IsThreeLianXu = true
    if #ThreeCardTable == 4 then
        for Index=1,#ThreeCardTable-1,1 do
            if ThreeCardTable[Index]-1 ~=ThreeCardTable[Index+1] then
                IsThreeLianXu=false
            end
        end
    else
        IsThreeLianXu = false
    end

    if IsThreeLianXu == true then
        return IsThreeLianXu
    end

    if PDKStraightPick(tCard) == true then
        return true
    end
    return false
end

-- 检测十三张牌
function PDKThirteenPick(tCard)
    if PDKStraightPick(tCard) == true then
        return true
    end
    return false
end

-- 检测十四张牌
function PDKFourteenPick(tCard)

    local PokerValue={}
    local DoubleCardTable={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 2 then
            table.insert(DoubleCardTable,v.PokerNumber)
        end
        
    end
    local IsDouble=true
    for k,v in pairs(PokerValue) do
        if v ~= 2 then
            IsDouble=false
        end
    end

    if IsDouble == true then
        table.sort(DoubleCardTable)
    end

    -- 检测7个对子
    local IsLianXu=true
    if #DoubleCardTable == 7 then
        for Index=1,#DoubleCardTable-1,1 do
            if DoubleCardTable[Index]+1 ~=DoubleCardTable[Index+1] then
                IsLianXu=false
            end
        end
    else
        IsLianXu=false
    end
    if IsLianXu == true then
        return IsLianXu
    end

    return false
end

-- 检测十五张牌
function PDKFifteenPick(tCard)

    -- 检测3个三张
    local PokerValue={}
    local DoubleCardTable={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 3 then
            table.insert(DoubleCardTable,v.PokerNumber)
        end
    end
    local IsThree=true
    if #DoubleCardTable < 3 then
        IsThree=false
    end

    if IsThree == true then
        table.sort(DoubleCardTable)
    end

    local IsLianXu=true
    local num=0
    if #DoubleCardTable>=3 then
        for Index=1,#DoubleCardTable,1 do
            for J=2,#DoubleCardTable,1 do
                if DoubleCardTable[Index]+1== DoubleCardTable[J] then
                    num=num+1
                    if num == 2 then
                        return true
                    end
                end
            end
        end
    end

    return false
end

-- 检测十六张牌
function PDKSixteenPick(tCard)

    local PokerValue={}
    local DoubleCardTable={}
    for k,v in ipairs(tCard) do
        if PokerValue[v.PokerNumber]== nil then
            PokerValue[v.PokerNumber]=0
        end
        PokerValue[v.PokerNumber]=PokerValue[v.PokerNumber]+1
        if PokerValue[v.PokerNumber] == 2 then
            table.insert(DoubleCardTable,v.PokerNumber)
        end
    end
    local IsDouble=true
    for k,v in pairs(PokerValue) do
        if v ~= 2 then
            IsDouble=false
        end
    end

    if IsDouble == true then
        table.sort(DoubleCardTable)
    end

    -- 检测8个对子
    local IsLianXu=true
    if #DoubleCardTable == 8 then
        for Index=1,#DoubleCardTable-1,1 do
            if DoubleCardTable[Index]+1 ~=DoubleCardTable[Index+1] then
                IsLianXu=false
            end
        end
    else
        IsLianXu=false
    end
    if IsLianXu == true then
        return IsLianXu
    end
    return false
end


-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened( )
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.InitRoomState, ResetPDKGameRoomToRoomState)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPDKRoomAddPlayer, OnNotifyPDKAddPlayerEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPDKDeletePlayerEvent, OnNotifyPDKDeletePlayerEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateRoomState, RefreshMJGameRoomByRoomStateSwitchTo)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPDKZJPlayerReadyEvent, ZBImageIsShow)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMJErrorHints, ErrorHints)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPDKRobotEvent, CanceRobotButtonlDisplay)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPDKPromptEvent, FeedbackPromptButtonOnClick)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyPDKBombChangeGoldEvent, BombChangeGold)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyRoomChangeEvent, OnNotifyRoomChangeEvent)
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.InitRoomState, ResetPDKGameRoomToRoomState)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPDKRoomAddPlayer, OnNotifyPDKAddPlayerEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPDKDeletePlayerEvent, OnNotifyPDKDeletePlayerEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateRoomState, RefreshMJGameRoomByRoomStateSwitchTo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPDKZJPlayerReadyEvent, ZBImageIsShow)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMJErrorHints, ErrorHints)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPDKRobotEvent, CanceRobotButtonlDisplay)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPDKPromptEvent, FeedbackPromptButtonOnClick)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyPDKBombChangeGoldEvent, BombChangeGold)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyRoomChangeEvent, OnNotifyRoomChangeEvent)
end


-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
    mMyTransform = this.transform
    mRoomData = GameData.RoomInfo.CurrentRoom
    InitUIElement()
    AddButtonHandlers()
    ResetPDKGameRoomToRoomState(mRoomData.RoomState)
    OutButtonPromptButtonDisplay()
    CanceRobotButtonlDisplay()
    LoadingAnitationDispaly()
    if mRoomData.PDKPlayerList[3].IsRobot == 0 then
        if mRoomData.RoomState > ROOM_STATE_PDK.DEAL and mRoomData.RoomState < ROOM_STATE_PDK.SETTLEMENT then
            mRobotButtonlObject.interactable = true
        else
            mRobotButtonlObject.interactable = false
        end
    end
    InitRoomChange()

    if GameConfig.IsSpecial()  then
        this.transform:Find('Canvas/ReturnButton/ReturnButton1/Rank').gameObject:SetActive(false)
        this.transform:Find('Canvas/ReturnButton/ReturnButton1/GameRuleButton').gameObject:SetActive(false)
    end
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    CS.MatchLoadingUI.Hide()
    MusicMgr:PlayBackMusic("BG_PDK")
    -- 切换屏幕横屏
    CS.Utility.AutorotateToLandscapeLeft()
end

-- Unity MonoBehavior Update 时调用此方法
function Update()
    UpdateCountDown()
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    if GameConfig.IsSpecial()  then
        if CS.AppDefine.GameID == 2 then
            -- 不需要切屏 因为是一致方向
            return
        else
            -- 其他情况
        end
    end
    -- 切换竖屏
    CS.Utility.AutorotateToPortrait()
end

