

local Light_Position_Y={[1]=0,[2]=-176,[3]=-352,[4]=-528,[5]=-704,[6]=-880,[7]=-1056}
local mLightTargetTime = {[1] = 0.2, [2] = 0.4, [3] = 0.6, [4] = 0.8, [5] = 1.0, [6] = 1.2, [7] = 1.4,}
local isClick=false
local lotteryButton=nil
local OnClick=nil
--local target={[1]=1,[2]=2,[3]=3,[4]=7,[5]=4,[6]=6,[7]=5,}
function Awake()
    -- 获取到关闭按钮
    this.transform:Find('Canvas/Window/Title/ButtonClose'):GetComponent("Button").onClick:AddListener(CloseUI)

    -- 获取到抽奖按钮
    this.transform:Find('Canvas/Window/Button/LotteryButton'):GetComponent("Button").onClick:AddListener(LotteryButtonOnClick)
    lotteryButton = this.transform:Find('Canvas/Window/Button/LotteryButton').gameObject
    OnClick= this.transform:Find('Canvas/Window/Button/OnClick').gameObject
    
    -- 获取到抽奖图片
    local Viewport = this.transform:Find('Canvas/Window/PrizeContent/Viewport').gameObject
    Viewport:SetActive(false)
    local Content=this.transform:Find('Canvas/Window/PrizeContent/Viewport/Content'):GetComponent("TweenPosition")
    Content.enabled=false

    -- 获取到弹窗关闭按钮
    this.transform:Find('Canvas/Window/RewardImage/MaskImage'):GetComponent("Button").onClick:AddListener(ClosePrizeInfo)

    --NetMsgHandler.Send_CS_iPhone_Info()
    HandleInfo()
end

--响应关闭按钮
function CloseUI()
    CS.WindowManager.Instance:CloseWindow("iphoneLuckDraw",false)
end

-- 处理配置相关信息
function HandleInfo()
    startTime()             -- 离活动开始的时间
    LotteryNumberOfTimes()  -- 剩余抽奖次数
end

-- 离活动开始的时间
function startTime()
    this.transform:Find('Canvas/Window/Button/LotteryButton/Text').gameObject:SetActive(false)
    this.transform:Find('Canvas/Window/Button/LotteryButton/Text (1)').gameObject:SetActive(false)
    this.transform:Find('Canvas/Window/Button/LotteryButton/Text (2)').gameObject:SetActive(false)
    if GameData.iPoneLotteryInfo.StartTime~=0 then
        local time = GameData.iPoneLotteryInfo.StartTime
        time=math.floor(time/3600/24)
        this.transform:Find('Canvas/Window/Button/LotteryButton/Text'):GetComponent("Text").text="离抽奖还有:"..time.."天"
        this.transform:Find('Canvas/Window/Button/LotteryButton/Text').gameObject:SetActive(true)
        this.transform:Find('Canvas/Window/Button/LotteryButton/Text (1)').gameObject:SetActive(true)
    else
        this.transform:Find('Canvas/Window/Button/LotteryButton/Text (2)').gameObject:SetActive(true)
    end
end

-- 剩余抽奖次数
function LotteryNumberOfTimes()
    if GameData.iPoneLotteryInfo.LotteryNumberOfTimes~=nil then
    local num=GameData.iPoneLotteryInfo.LotteryNumberOfTimes
    this.transform:Find('Canvas/Window/LuckDrawRule/LotteryNumberOfTimes/Text'):GetComponent("Text").text="您当前拥有的抽奖次数:"..num
    else
        this.transform:Find('Canvas/Window/LuckDrawRule/LotteryNumberOfTimes/Text'):GetComponent("Text").text="您当前拥有的抽奖次数:0"
    end
end

-- 响应抽奖按钮
function LotteryButtonOnClick()
    PlaySoundEffect('2')
    if isClick == false then
    NetMsgHandler.Send_CS_iPhone_LuckDraw()
    end
    --GameData.iPoneLotteryInfo.LotteryTarget=5
    --LotteryInfo()
end

-- 处理抽奖信息
function LotteryInfo()
    lotteryButton:SetActive(false)
    OnClick:SetActive(true)
    LuckDrawMusic()
    LotteryNumberOfTimes()
    isClick=true
    local Package =  this.transform:Find('Canvas/Window/PrizeContent/Prize8/Image').gameObject
    Package:SetActive(false)
    local Viewport = this.transform:Find('Canvas/Window/PrizeContent/Viewport').gameObject
    Viewport:SetActive(true)
    local Content=this.transform:Find('Canvas/Window/PrizeContent/Viewport/Content'):GetComponent("TweenPosition")
    Content.enabled=true
    this:DelayInvoke(0,function() 
        Content.duration=1
        Content:ResetToBeginning()
        Content:Play(true)
    end)
    this:DelayInvoke(1,function() 
        
        Content:ResetToBeginning()
        Content.from = CS.UnityEngine.Vector3(0,101.5,0)
        Content.to = CS.UnityEngine.Vector3(0,-1218,0)
        Content.duration=0.8
        Content:Play(true)
    end)
    local time = 1.8
    for index=1,2 do
        this:DelayInvoke(time,function() 
            Content:ResetToBeginning()
            Content.from = CS.UnityEngine.Vector3(0,101.5,0)
            Content.to = CS.UnityEngine.Vector3(0,-1218,0)
            Content.duration=0.5
            Content:Play(true)
        end)
        time= time+0.5
    end
    for index=1,1 do
        this:DelayInvoke(time,function() 
            Content:ResetToBeginning()
            Content.from = CS.UnityEngine.Vector3(0,101.5,0)
            Content.to = CS.UnityEngine.Vector3(0,-1218,0)
            Content.duration=0.8
            Content:Play(true)
        end)
        time= time+0.8
    end
    local position=Light_Position_Y[GameData.iPoneLotteryInfo.LotteryTarget]
    local StopTime=mLightTargetTime[GameData.iPoneLotteryInfo.LotteryTarget]
    this:DelayInvoke(time,function() 
        Content:ResetToBeginning()
        Content.from = CS.UnityEngine.Vector3(0,101.5,0)
        Content.to = CS.UnityEngine.Vector3(0,position,0)
        Content.duration=StopTime
        Content:Play(true)
    end)
    time=time+StopTime+0.5
    --[[local Light = this.transform:Find('Canvas/Window/PrizeContent/Light').gameObject
    this:DelayInvoke(time,function() 
        Light:SetActive(true)
    end)
    time=time+1.2
    this:DelayInvoke(time,function() 
        Light:SetActive(false)
    end)--]]
    this:DelayInvoke(time,function() 
        PrizeInfo()
    end)
end

--处理抽奖音效
function  LuckDrawMusic()
    local index=GameData.iPoneLotteryInfo.LotteryTarget
    PlaySoundEffect('Iphone_LuckDraw_'..index)
end

-- 弹出获得物品信息
function PrizeInfo()
    PlaySoundEffect('game_win')
    local notice = this.transform:Find('Canvas/Window/RewardImage').gameObject
    notice:SetActive(true)
    local info = data.SalesmaniphoneConfig.LUCK_DRAW_REWARD_NAME[GameData.iPoneLotteryInfo.LotteryTarget]
    this.transform:Find('Canvas/Window/RewardImage/Info'):GetComponent("Text").text="恭喜您获得:<color=#00ff00>"..info..'</color>'
    this:DelayInvoke(2,function() 
        notice:SetActive(false)
        local Package =  this.transform:Find('Canvas/Window/PrizeContent/Prize8/Image').gameObject
        Package:SetActive(true)
        local Viewport = this.transform:Find('Canvas/Window/PrizeContent/Viewport').gameObject
        Viewport:SetActive(false)
        local Content=this.transform:Find('Canvas/Window/PrizeContent/Viewport/Content'):GetComponent("TweenPosition")
        Content.enabled=false
        lotteryButton:SetActive(true)
        OnClick:SetActive(false)
    end)
    isClick=false
end

--关闭物品信息
function ClosePrizeInfo()
    local notice = this.transform:Find('Canvas/Window/RewardImage').gameObject
    notice:SetActive(false)
    local Package =  this.transform:Find('Canvas/Window/PrizeContent/Prize8/Image').gameObject
    Package:SetActive(true)
    local Viewport = this.transform:Find('Canvas/Window/PrizeContent/Viewport').gameObject
    Viewport:SetActive(false)
    local Content=this.transform:Find('Canvas/Window/PrizeContent/Viewport/Content'):GetComponent("TweenPosition")
    Content.enabled=false
    isClick=false
    this:StopAllDelayInvoke()
    lotteryButton:SetActive(true)
    OnClick:SetActive(false)
end
-- 音效播放
function PlaySoundEffect(musicid)
    MusicMgr:PlaySoundEffect(musicid)
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptIPHONE_Info, HandleInfo) -- 处理基本配置
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptIPHONE_LotteryInfo, LotteryInfo) -- 处理抽奖信息
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptIPHONE_Info, HandleInfo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptIPHONE_LotteryInfo, LotteryInfo)
end

-- Unity MonoBehavior Update 时调用此方法
function Update()
end