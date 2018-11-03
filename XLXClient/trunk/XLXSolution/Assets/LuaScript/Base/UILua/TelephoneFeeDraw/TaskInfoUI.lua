
local Time = CS.UnityEngine.Time
-- 灯光数据组建
local mLightGameObjects = 
{
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
    [6] = nil,
    [7] = nil,
    [8] = nil,
}
-- 箭头目标旋转值
local mLightRotation = {[1] = 0, [2] = 315, [3] = 270, [4] = 225, [5] = 180, [6] = 135, [7] = 90, [8] = 45,}
local mLightTargetTime = {[1] = 0, [2] = 0.2, [3] = 0.4, [4] = 0.6, [5] = 0.8, [6] = 1.0, [7] = 1.2, [8] = 1.4,}

-- 奖励按钮 次数
local mRewardButton = nil
local mRewardButtonImage = nil

-- 轮盘箭头组件
local mRewardPointerGameObject = nil
local mRewardPointerTweenRotation = nil

local mWheelLightTagIndex = 1 -- 目标位置

local Roulette=nil -- 抽奖轮盘
local isRotate=0  --轮盘是否旋转
local mRewardPointerMask=nil --轮盘Mask
local TaskSuccess_Button = nil --任务完成按钮
local TaskInfo_Button=nil
local TaskInfo_Fail=nil
local cngratulationsInterface = nil --恭喜获得界面
local cngratulationsMask = nil  --恭喜获得界面Mask
local cngratulationsText = nil  --恭喜获得界面获得话费
local MeetTask_Position=nil     --接取任务窗口上的TweenPosition组件
local MeetTask_Scale=nil        --接取任务窗口上的TweenScale组件
local MeetTask=nil              --接取任务窗口
local MeetTask_Info = nil       --接取任务窗口任务信息
local TaskInfo=nil              --任务进行中
local TaskSuccess=nil           --任务完成
local TaskFail=nil              --任务失败
local timer=0
local isCountDown=false
local isOpenMeetTask=0  --任务弹窗是否弹出过状态
local isFristOpenMeetTask=false -- 任务弹窗是否是第一次打开
local isFillState=false         --上一状态是否是失败状态
local isTaskHaveIntervalTime=false --任务是否拥有间隔时间
function Awake()

    -- 灯光数据组件
    for index = 1, 8, 1 do
        mLightGameObjects[index] = this.transform:Find("Canvas/Wheel/Light/zp_box_choose"..index).gameObject
    end

    -- 奖励按钮 次数
    mRewardButton = this.transform:Find("Canvas/Wheel/RewardButton"):GetComponent("Button")
    mRewardButton.onClick:AddListener(mRewardButtonOnClick)
    mRewardButtonImage = this.transform:Find("Canvas/Wheel/RewardButton/Image").gameObject

    -- 轮盘箭头组件
    mRewardPointerGameObject  = this.transform:Find("Canvas/Wheel/RewardPointer").gameObject
    mRewardPointerTweenRotation = this.transform:Find("Canvas/Wheel/RewardPointer"):GetComponent("TweenRotation")
    mRewardPointerGameObject:SetActive(true)
    mRewardPointerTweenRotation.enabled = false

    -- 轮盘Mask
    mRewardPointerMask=this.transform:Find("Canvas/Wheel/MaskImage"):GetComponent("Button").onClick:AddListener(MaskOnClick)

    -- 抽奖轮盘
    Roulette=this.transform:Find("Canvas/Wheel").gameObject
    Roulette:SetActive(false)

    -- 恭喜获得界面
    cngratulationsInterface = this.transform:Find("Canvas/ObtainGoods").gameObject
    cngratulationsInterface:SetActive(false)
    --关闭恭喜获得界面按钮
    cngratulationsMask=this.transform:Find("Canvas/ObtainGoods/ObtainGoodsMask"):GetComponent("Button").onClick:AddListener(CloseCongratulationsInterface)
    --恭喜获得界面获得话费
    cngratulationsText=this.transform:Find("Canvas/ObtainGoods/Image/Bill/Text"):GetComponent("Text")

    -- 打开轮盘Button
    TaskSuccess_Button=this.transform:Find('Canvas/TaskContent/TaskSuccess/LuckDrawCountDown'):GetComponent("Button").onClick:AddListener(OpenRoulette)
    TaskInfo_Button=this.transform:Find('Canvas/TaskContent/TaskInfo'):GetComponent("Button").onClick:AddListener(OpenRoulette)
    TaskInfo_Fail=this.transform:Find('Canvas/TaskContent/TaskFail'):GetComponent("Button").onClick:AddListener(OpenRoulette)
    
    TaskInfo=this.transform:Find('Canvas/TaskContent/TaskInfo').gameObject
    TaskSuccess=this.transform:Find('Canvas/TaskContent/TaskSuccess').gameObject
    TaskFail=this.transform:Find('Canvas/TaskContent/TaskFail').gameObject

    --接取任务界面
    MeetTask_Position=this.transform:Find('Canvas/TaskInformation'):GetComponent("TweenPosition")
    MeetTask_Scale=this.transform:Find('Canvas/TaskInformation'):GetComponent("TweenScale")
    MeetTask_Info=this.transform:Find('Canvas/TaskInformation/Text'):GetComponent("Text")
    MeetTask=this.transform:Find('Canvas/TaskInformation').gameObject
    
    HandleUIDefaultShow()
end

-- UI默认状态处理
function HandleUIDefaultShow()
    HandleWheelLightShow(0)
    --MeetTask:SetActive(false)
    DisplayTaskStatus()  
end

--响应点击抽奖按钮
function mRewardButtonOnClick()
    if isRotate == 0 and GameData.ExchangeTelephoneFareInfo.WheelNumber~=0 then
        NetMsgHandler.Send_CS_LuckDraw_Bill()
    end
end

-- 显示任务状态
function DisplayTaskStatus()  
    TaskInfo:SetActive(false)
    TaskSuccess:SetActive(false)
    TaskFail:SetActive(false)
    --timer=GameData.ExchangeTelephoneFareInfo.TaskCountDown
    if GameData.ExchangeTelephoneFareInfo.TaskState == 0 then
        timer=GameData.ExchangeTelephoneFareInfo.TaskCountDown
        GameData.ExchangeTelephoneFareInfo.TaskFailCountDown=60
        isCountDown=true
        CarryOnTheTask()
    elseif GameData.ExchangeTelephoneFareInfo.TaskState == 1 then
        timer=GameData.ExchangeTelephoneFareInfo.TaskCountDown
        if GameData.ExchangeTelephoneFareInfo.WheelNumber==0 then
            if GameData.ExchangeTelephoneFareInfo.TaskCountDown ~=0 then
                isTaskHaveIntervalTime=true
            end
            isCountDown=true
            this.transform:Find("Canvas/TaskContent/TaskSuccess/Image").gameObject:SetActive(false)
            mRewardButtonImage:SetActive(true)
        else
            this.transform:Find("Canvas/TaskContent/TaskSuccess/Image").gameObject:SetActive(true)
            mRewardButtonImage:SetActive(false)
            isCountDown=false
        end
        SuccessTask()
    elseif GameData.ExchangeTelephoneFareInfo.TaskState == 2 then
        CloseCongratulationsInterface()
        
        timer=GameData.ExchangeTelephoneFareInfo.TaskFailCountDown
        if GameData.ExchangeTelephoneFareInfo.TaskFailCountDown ~= 0 then
            Roulette:SetActive(false)
            isFillState=true
            isCountDown=true
        else
            isCountDown=false
            this.transform:Find('Canvas/TaskContent/TaskFail/Text'):GetComponent("Text").text=string.format(data.GetString("All_Task_Success"))
        end
        FailTask()
        isTaskHaveIntervalTime=false
    end
end

-- 任务进行中
function CarryOnTheTask()
    this.transform:Find('Canvas/TaskContent/TaskInfo/TaskName'):GetComponent("Text").text=""..data.TaskConfig[GameData.ExchangeTelephoneFareInfo.TaskIndex].TaskName
    local TaskNeedNumber= GameData.ExchangeTelephoneFareInfo.TaskNeedNumber
    local TaskCompleteNumber= GameData.ExchangeTelephoneFareInfo.TaskCompleteNumber
    local slider =this.transform:Find('Canvas/TaskContent/TaskInfo/CompletionDegree'):GetComponent("Slider")
    slider.value=TaskCompleteNumber/TaskNeedNumber
    this.transform:Find('Canvas/TaskContent/TaskInfo/CompletionDegree/Number'):GetComponent("Text").text=""..TaskCompleteNumber.."/"..TaskNeedNumber
    TaskInfo:SetActive(true)
    mRewardButtonImage:SetActive(true)
    if isOpenMeetTask == 0  then
        if isFillState == true or isFristOpenMeetTask ==false or isTaskHaveIntervalTime == true then
            MeetTaskInterface()
            --[[isFristOpenMeetTask=true
            isFillState=false
            isTaskHaveIntervalTime=false--]]
        --end
    
        elseif GameData.ExchangeTelephoneFareInfo.TaskIndex == 1 and isFristOpenMeetTask ==true then
            MeetTaskInterface()
        end
        isFristOpenMeetTask=true
        isFillState=false
        isTaskHaveIntervalTime=false
    end
end

-- 任务成功
function SuccessTask()
    --this.transform:Find('Canvas/TaskContent/TaskSuccess/LuckDrawCountDown/Text'):GetComponent("Text").text="<size=35>点击开始抽话费</size>"
    this.transform:Find('Canvas/TaskContent/TaskSuccess/LuckDrawCountDown/Text'):GetComponent("Text").text=string.format(data.GetString("Task_Success"))
    TaskSuccess:SetActive(true)
    isOpenMeetTask=0
end

-- 任务失败
function FailTask()
    TaskFail:SetActive(true)
    mRewardButtonImage:SetActive(true)
    isOpenMeetTask=0
end

--任务倒计时
function TaskCountDown()
    if timer>0 then
        local second=math.floor((timer % 3600) % 60)
        local Minute = math.floor((timer % 3600) / 60)
        --local Hour=math.floor(baoziLastTime / 3600)
        if Minute <=9 then
            Minute="0"..Minute
        end
        if second <=9 then
            second="0"..second
        end
        if GameData.ExchangeTelephoneFareInfo.TaskState == 0 then
            this.transform:Find('Canvas/TaskContent/TaskInfo/TaskCountDown'):GetComponent("Text").text=""..Minute..":"..second
        elseif GameData.ExchangeTelephoneFareInfo.TaskState == 1 and GameData.ExchangeTelephoneFareInfo.WheelNumber==0 then
            --this.transform:Find('Canvas/TaskContent/TaskSuccess/LuckDrawCountDown/Text'):GetComponent("Text").text="<size=30>下一任务时间:"..Minute..":"..second.."</size>"
            this.transform:Find('Canvas/TaskContent/TaskSuccess/LuckDrawCountDown/Text'):GetComponent("Text").text=string.format(data.GetString("Task_Interval_Time"),Minute,second)
        elseif GameData.ExchangeTelephoneFareInfo.TaskState == 2 then
            --this.transform:Find('Canvas/TaskContent/TaskFail/FailCountDown'):GetComponent("Text").text=""..Minute..":"..second
            this.transform:Find('Canvas/TaskContent/TaskFail/Text'):GetComponent("Text").text=string.format(data.GetString("Task_Fail"),Minute,second)
        end
    else
        local second="00"
        local Minute="00"
        if GameData.ExchangeTelephoneFareInfo.TaskState == 0 then
            this.transform:Find('Canvas/TaskContent/TaskInfo/TaskCountDown'):GetComponent("Text").text=""..Minute..":"..second
        elseif GameData.ExchangeTelephoneFareInfo.TaskState == 1 and GameData.ExchangeTelephoneFareInfo.WheelNumber==0 then
            this.transform:Find('Canvas/TaskContent/TaskSuccess/LuckDrawCountDown/Text'):GetComponent("Text").text=string.format(data.GetString("Task_Interval_Time"),Minute,second)
        elseif GameData.ExchangeTelephoneFareInfo.TaskState == 2 then
            this.transform:Find('Canvas/TaskContent/TaskFail/Text'):GetComponent("Text").text=string.format(data.GetString("Task_Fail"),Minute,second)
        end
    end
end

-- 轮盘动画
function HandleWheelAnimation()
    HandleWheelLightShow(0)
    isRotate=1
    mRewardPointerGameObject:SetActive(true)
    this:DelayInvoke(0,function() 
        mRewardPointerTweenRotation.duration = 0.6
        mRewardPointerTweenRotation:ResetToBeginning()
        mRewardPointerTweenRotation:Play(true)
        PlaySoundEffect('WheelStart')
    end)
    this:DelayInvoke(0.6,function() 
        mRewardPointerTweenRotation.duration = 0.5
        mRewardPointerTweenRotation:ResetToBeginning()
    end)
    -- 快速旋转5圈 0.3秒一圈
    this:DelayInvoke(1.1,function() 
        mRewardPointerTweenRotation.duration = 0.3
        mRewardPointerTweenRotation:ResetToBeginning()
    end)
    -- 放慢速度1圈 0.5秒1圈
    this:DelayInvoke(2.6,function() 
        mRewardPointerTweenRotation.duration = 0.5
        mRewardPointerTweenRotation:ResetToBeginning()
    end)
    local tDelayTime = 3.1
    -- 缓慢旋转至对应奖励 （1.6秒1圈，1个格子0.2秒）
    this:DelayInvoke(3.1,function()
        --mRewardPointerTweenRotation.enabled = false
        mRewardPointerTweenRotation.duration = 1.6
        mRewardPointerTweenRotation:ResetToBeginning()
        
    end)

    mWheelLightTagIndex=GameData.ExchangeTelephoneFareInfo.WinningPosition
    local tTagetIndex = mWheelLightTagIndex
    local tTagetAnglesZ = mLightRotation[tTagetIndex]
    tDelayTime = tDelayTime + mLightTargetTime[tTagetIndex]
    print("旋转位置：",tTagetIndex,tDelayTime)
    -- 旋转至对应格子 停止旋转
    this:DelayInvoke(tDelayTime,function() 
        mRewardPointerTweenRotation.enabled = false
        mRewardPointerTweenRotation.transform.localEulerAngles = CS.UnityEngine.Vector3(0,0,tTagetAnglesZ)
    end)
    -- 对应位置播放缓慢结束音效
    for index = 1, tTagetIndex , 1 do
        local tTime = 2.9 + 0.2 * index
        this:DelayInvoke(tTime,function()  PlaySoundEffect('WheelEnd') end)
    end
    -- 量出对应格子选中状态
    tDelayTime = tDelayTime + 0.4
    this:DelayInvoke(tDelayTime,function()
        HandleWheelLightShow(tTagetIndex)
    end)
    -- 弹出得倒奖励提示
    tDelayTime = tDelayTime + 0.5
    this:DelayInvoke(tDelayTime,function()
        isRotate=0
        PlaySoundEffect('WheelGold')
        CongratulationsInterface()
    end)
end

-- 弹出恭喜获得界面
function CongratulationsInterface()
    cngratulationsText.text="+"..GameConfig.GetFormatColdNumber(GameData.ExchangeTelephoneFareInfo.WinnerBill)
    cngratulationsInterface:SetActive(true)
end

-- 关闭恭喜获得界面
function CloseCongratulationsInterface()
    HandleWheelLightShow(0)
    cngratulationsInterface:SetActive(false)
end

-- 音效播放
function PlaySoundEffect(musicid)
    MusicMgr:PlaySoundEffect(musicid)
end

-- 处理轮盘显示
function HandleWheelLightShow(_showPos)
    for index = 1, 8, 1 do
        local tShowParam = _showPos == index
        if mLightGameObjects[index].activeSelf ~= tShowParam then
            mLightGameObjects[index]:SetActive(tShowParam)
        end
    end
end

-- 弹出接取任务窗口
function MeetTaskInterface()
    isOpenMeetTask=1
    MeetTask_Info.text=""..data.TaskConfig[GameData.ExchangeTelephoneFareInfo.TaskIndex].TaskPrompt
    MeetTask:SetActive(true)
    MeetTask_Position.duration=0.5
    MeetTask_Scale.duration=0.5
    MeetTask_Position:ResetToBeginning()
    MeetTask_Scale:ResetToBeginning()
    MeetTask_Position:Play(true)
    MeetTask_Scale:Play(true)
    this:DelayInvoke(1.5,function() 
        MeetTask:SetActive(false)
    end)
end

-- 点击轮盘Mask
function MaskOnClick()
    if isRotate == 0 then
        Roulette:SetActive(false)
        if GameData.ExchangeTelephoneFareInfo.TaskState == 0 and isOpenMeetTask == 0 and isFristOpenMeetTask == true and isFillState == false and isTaskHaveIntervalTime == false then
            MeetTaskInterface()
        end
    end
end

-- 响应点击任务完成按钮打开抽奖轮盘
function OpenRoulette()
    PlaySoundEffect('2')
    Roulette:SetActive(true)
    mRewardPointerTweenRotation.transform.localEulerAngles = CS.UnityEngine.Vector3(0,0,0)
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAccept_LuckDraw_Bill, HandleWheelAnimation)--开始抽奖
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptTaskInfo, HandleUIDefaultShow)--处理基本配置
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAccept_LuckDraw_Bill, HandleWheelAnimation)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptTaskInfo, HandleUIDefaultShow)
end

-- Unity MonoBehavior Update 时调用此方法
function Update()
    if isCountDown then
        timer=timer-Time.deltaTime
        TaskCountDown()
        --GameData.ExchangeTelephoneFareInfo.TaskCountDown=timer
    end

end