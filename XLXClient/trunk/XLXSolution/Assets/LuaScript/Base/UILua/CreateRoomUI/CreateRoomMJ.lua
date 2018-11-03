local betLevel = 101
local roomCount = 8
local betLevelSlider = nil
local betMinValueText = nil
local RuleEnterInput = nil
local RuleLeaveInput = nil
-- 底注下限 底注上限 陌生人 自摸模式 点杠花模式 呼叫转移  倍率 带幺九 断幺九 将对 门清 天地胡 海底捞月 封顶倍率 局数 入场设定 离场设定
local BetMinValue = 1
local BetMaxValue = 40
local IsLock = 0        -- 是否允许陌生人加入
local ZiMoMode = 2  --  自摸模式(1 自摸不加底 2 自摸加底 3 自摸加倍)
local DianGangHuaMode = 2 --  点杠花模式(1 点杠花当自摸 2 点杠花当点炮)
local HuJiaoZhuanYi= 1 -- 呼叫转移(0 关闭 1 开启)
local DaiYaoJiu = 1 -- 带幺九(0 关闭 1 开启) 
local DuanYaoJiu = 0 -- 断幺九(0 关闭 1 开启) 
local JiangDui = 0  -- 将对(0 关闭 1 开启)
local MenQing = 0  -- 门清(0 关闭 1 开启)
local TianDiHu = 0 -- 天地胡(0 关闭 1 开启)
local HaiDiLaoYue = 1 -- 海底捞月(0 关闭 1 开启)
local HaiDiPao = 1 -- 海底炮(0 关闭 1 开启)
local FengDingBeiLv = 8 -- 封顶倍率(8 16 32)
local JuShu = 8 -- 局数(4 8 16)

local EnterValue = 40
local LeaveValue = 10
-- 房间等级
local RoomLevel = 1
-- 房间类型配置
local mRoomConfigType = 10

local GZBrokerage = 20          -- 馆主抽水
local SystemBrokerage = 5       -- 系统抽水
local GZBrokerageTable = {[1] = 25, [2] = 20, [3] = 15, [4] = 10,}

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    -- 返回按钮
    this.transform:Find('ButtonCreate'):GetComponent("Button").onClick:AddListener(CreateRoomButton_OnClick)
    betLevelSlider = this.transform:Find('BetSetting/Slider'):GetComponent("Slider")
    betLevelSlider.onValueChanged:AddListener(BetLevelSlider_Value_Changed)
    betMinValueText = this.transform:Find('BetSetting/MinValue'):GetComponent("Text")

    -- 入场 离场设定
    RuleEnterInput = this.transform:Find('RuleEnter/EnterInput'):GetComponent("InputField")
    RuleEnterInput.onValueChanged:AddListener(RuleEnterInputValueChanged)
    RuleLeaveInput = this.transform:Find('RuleLeave/LeaveInput'):GetComponent("InputField")
    RuleLeaveInput.onValueChanged:AddListener(RuleLeaveInputValueChanged)

    this.transform:Find('Rule1/Count1'):GetComponent("Toggle").onValueChanged:AddListener(OnLockOnClick)

    this.transform:Find('Rule3/Count1'):GetComponent("Toggle").onValueChanged:AddListener(OnClickGameMode1)
    this.transform:Find('Rule3/Count2'):GetComponent("Toggle").onValueChanged:AddListener(OnClickGameMode2)
    this.transform:Find('Rule3/Count3'):GetComponent("Toggle").onValueChanged:AddListener(OnClickGameMode3)

    this.transform:Find('Rule4/Count1'):GetComponent("Toggle").onValueChanged:AddListener(OnClickDGH1)
    this.transform:Find('Rule4/Count2'):GetComponent("Toggle").onValueChanged:AddListener(OnClickDGH2)

    --this.transform:Find('Rule2/Count1'):GetComponent("Toggle").onValueChanged:AddListener(OnCallTransferOnClick)
    this.transform:Find('Rule2/Count2'):GetComponent("Toggle").onValueChanged:AddListener(OnClickFangXing2)
    this.transform:Find('Rule2/Count3'):GetComponent("Toggle").onValueChanged:AddListener(OnClickFangXing3)
    this.transform:Find('Rule2/Count5'):GetComponent("Toggle").onValueChanged:AddListener(OnClickFangXing5)
    this.transform:Find('Rule2/Count6'):GetComponent("Toggle").onValueChanged:AddListener(OnClickFangXing6)
    this.transform:Find('Rule2/Count7'):GetComponent("Toggle").onValueChanged:AddListener(OnClickFangXing7)

    this.transform:Find('Rule5/Count1'):GetComponent("Toggle").onValueChanged:AddListener(OnClickRate1)
    this.transform:Find('Rule5/Count2'):GetComponent("Toggle").onValueChanged:AddListener(OnClickRate2)
    this.transform:Find('Rule5/Count3'):GetComponent("Toggle").onValueChanged:AddListener(OnClickRate3)

    this.transform:Find('Rule6/Count1'):GetComponent("Toggle").onValueChanged:AddListener(OnClickGameNumber1)
    this.transform:Find('Rule6/Count2'):GetComponent("Toggle").onValueChanged:AddListener(OnClickGameNumber2)
    this.transform:Find('Rule6/Count3'):GetComponent("Toggle").onValueChanged:AddListener(OnClickGameNumber3)

    -- 设置房间开启等级
    local maxLevel = GetOpenRoomMaxLevel()
    betLevelSlider.minValue = 1
    betLevelSlider.maxValue = maxLevel

    this.transform:Find('GZBrokerage/Dropdown'):GetComponent("Dropdown").onValueChanged:AddListener(BrokerageInputValueChanged)
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    betLevel = betLevelSlider.value
    RefreshBetLevel()
end

-- 获取房间开启最大等级
function GetOpenRoomMaxLevel()
    local maxLevel = 1
    for key, config in pairs(data.PublicroomConfig) do
        if config.Type == mRoomConfigType and config.IsOpen == 1 then
            if maxLevel < config.Level then
                maxLevel = config.Level
            end
        end
    end
    return maxLevel
end

-- 刷新显示
function RefreshBetLevel()
    RoomLevel = math.modf(betLevel)
    -- 浮点数取整
    local config = GameConfig.GetPublicRoomConfigDataByTypeLevel(mRoomConfigType,RoomLevel)
    BetMinValue = GameConfig.GetFormatColdNumber(config.LowLimit)
    --BetMaxValue = GameConfig.GetFormatColdNumber(config.HighLimit)
    EnterValue = GameConfig.GetFormatColdNumber(config.EnterLimit)
    LeaveValue = GameConfig.GetFormatColdNumber(config.OutLimit)
    -- 房间类型 = 模板ID
    betMinValueText.text = lua_CommaSeperate(BetMinValue)
    RuleEnterInput.text = lua_CommaSeperate(EnterValue)
    RuleLeaveInput.text = lua_CommaSeperate(LeaveValue)
end

-- 响应 押注等级 改变事件
function BetLevelSlider_Value_Changed(newValue)
    betLevel = newValue
    RefreshBetLevel()
end

-- 入局值设定变化
function RuleEnterInputValueChanged(valueStr)
    if valueStr == nil or valueStr == "" then
        local config = GameConfig.GetPublicRoomConfigDataByTypeLevel(mRoomConfigType,RoomLevel)
        EnterValue = GameConfig.GetFormatColdNumber(config.EnterLimit)
        RuleEnterInput.text = lua_CommaSeperate(EnterValue)
        RuleEnterInput:MoveTextEnd()
        return
    end

    local newValueStr = lua_CommaSeperate(tonumber(lua_Remove_CommaSeperate(valueStr)))
    if valueStr ~= newValueStr then
        RuleEnterInput.text = newValueStr
        RuleEnterInput:MoveTextEnd()
        return
    end
    -- 最低值验证
    EnterValue = tonumber(lua_Remove_CommaSeperate(valueStr))
    local config = GameConfig.GetPublicRoomConfigDataByTypeLevel(mRoomConfigType,RoomLevel)
    if EnterValue < GameConfig.GetFormatColdNumber(config.EnterLimit) then
        EnterValue = GameConfig.GetFormatColdNumber(config.EnterLimit)
        RuleEnterInput.text = lua_CommaSeperate(EnterValue)
        RuleEnterInput:MoveTextEnd()
        return
    end
end

-- 离场值设定变化
function RuleLeaveInputValueChanged(valueStr)
    if valueStr == nil or valueStr == "" then
        local config = GameConfig.GetPublicRoomConfigDataByTypeLevel(mRoomConfigType,RoomLevel)
        LeaveValue = GameConfig.GetFormatColdNumber(config.OutLimit)
        RuleLeaveInput.text = lua_CommaSeperate(LeaveValue)
        RuleLeaveInput:MoveTextEnd()
        return
    end

    local newValueStr = lua_CommaSeperate(tonumber(lua_Remove_CommaSeperate(valueStr)))
    if valueStr ~= newValueStr then
        RuleLeaveInput.text = newValueStr
        RuleLeaveInput:MoveTextEnd()
        return
    end
    -- 最低值验证
    LeaveValue = tonumber(lua_Remove_CommaSeperate(valueStr))
    local config = GameConfig.GetPublicRoomConfigDataByTypeLevel(mRoomConfigType,RoomLevel)
    if LeaveValue < GameConfig.GetFormatColdNumber(config.OutLimit) then
        LeaveValue = GameConfig.GetFormatColdNumber(config.OutLimit)
        RuleLeaveInput.text = lua_CommaSeperate(LeaveValue)
        RuleLeaveInput:MoveTextEnd()
        return
    end
end

-- 呼叫转移开关
function OnCallTransferOnClick(valueChange)
    if valueChange == true then
        HuJiaoZhuanYi = 1
    else
        HuJiaoZhuanYi = 0
    end
end

-- 陌生人加入开关
function OnLockOnClick(valueChange)
    if valueChange == true then
        IsLock = 0
    else
        IsLock = 1
    end
end

-- 自摸不加底开关
function OnClickGameMode1(valueChange)
    if valueChange == true then
        ZiMoMode = 1
    end
end
-- 自摸加底开关
function OnClickGameMode2(valueChange)
    if valueChange == true then
        ZiMoMode = 2
    end
end
-- 自摸加倍开关
function OnClickGameMode3(valueChange)
    if valueChange == true then
        ZiMoMode = 3
    end
end

-- 点杠花当自摸
function OnClickDGH1(valueChange)
    if valueChange == true then
        DianGangHuaMode = 1
    end
end
-- 点杠花当点炮
function OnClickDGH2(valueChange)
    if valueChange == true then
        DianGangHuaMode = 2
    end
end

-- 8倍按钮
function OnClickRate1(valueChange)
    if valueChange == true then
        FengDingBeiLv = 8
    end
end
-- 16倍按钮
function OnClickRate2(valueChange)
    if valueChange == true then
        FengDingBeiLv = 16
    end
end
-- 8倍按钮
function OnClickRate3(valueChange)
    if valueChange == true then
        FengDingBeiLv = 32
    end
end

-- 4局按钮
function OnClickGameNumber1(valueChange)
    if valueChange == true then
        JuShu = 4
    end
end
-- 8局按钮
function OnClickGameNumber2(valueChange)
    if valueChange == true then
        JuShu = 8
    end
end
-- 16局按钮
function OnClickGameNumber3(valueChange)
    if valueChange == true then
        JuShu = 16
    end
end

-- 将对
function OnClickFangXing2(valueChange)
    if valueChange == true then
        JiangDui = 1
    else
        JiangDui = 0
    end
end
-- 天地胡
function OnClickFangXing3(valueChange)
    if valueChange == true then
        TianDiHu = 1
    else
        TianDiHu = 0
    end
end
-- 断幺九
-- 门清
function OnClickFangXing5(valueChange)
    if valueChange == true then
        MenQing = 1
    else
        MenQing = 0
    end
end
-- 海底捞月
function OnClickFangXing6(valueChange)
    if valueChange == true then
        HaiDiLaoYue = 1
    else
        HaiDiLaoYue = 0
    end
end
-- 海底炮
function OnClickFangXing7(valueChange)
    if valueChange == true then
        HaiDiPao = 1
    else
        HaiDiPao = 0
    end
end

-- 创建房间按钮响应
function CreateRoomButton_OnClick()
    -- 数值调整(加上兑换比例)
    BetMinValue = GameConfig.GetLogicColdNumber(BetMinValue)
    --BetMaxValue = GameConfig.GetLogicColdNumber(BetMaxValue)
    EnterValue = GameConfig.GetLogicColdNumber(EnterValue)
    LeaveValue = GameConfig.GetLogicColdNumber(LeaveValue)

    if GameData.RoleInfo.GoldCount < EnterValue then
        local boxData = CS.MessageBoxData()
        boxData.Title = "温馨提示"
        boxData.Content = string.format(data.GetString("JH_Create_Room_Tips"),lua_CommaSeperate(GameConfig.GetFormatColdNumber(EnterValue)))
        boxData.Style = mRoomConfigType
        boxData.OKButtonName = "确定"
        boxData.LuaCallBack = ConfirmOnClick
        CS.MessageBoxUI.Show(boxData)
    else
        local roomStyle = 1
        local systemCost = 10
        local ownerCost = 0
        if GameConfig.CreateRoomUIOpenType == 2 then
            roomStyle = (TeaHouseMgr:CanCreateOwnerTeaRoom() == 0 and 2) or 3
        end
        if roomStyle == 3 then
            local tToggle = this.transform:Find('GZToggle'):GetComponent("Toggle")
            if tToggle.isOn == true then
                systemCost = SystemBrokerage
                ownerCost = GZBrokerage
            else
                roomStyle = 2
            end
        end
        print('房间模式参数:', roomStyle, systemCost, ownerCost)
        RoomLevel=36+RoomLevel
        -- 房间ID 是否加锁 入场限制 离场限制 自摸模式 点杠花模式 呼叫转移 将对 门清 天地胡 海底捞月 海底炮 封顶倍率 局数
        NetMsgHandler.Send_CS_MJ_Room_Create(RoomLevel, IsLock, EnterValue, LeaveValue, ZiMoMode, DianGangHuaMode, JiangDui, MenQing, TianDiHu, HaiDiLaoYue,FengDingBeiLv, JuShu,roomStyle,systemCost,ownerCost)
    end

    -- 数值还原
    BetMinValue = GameConfig.GetFormatColdNumber(BetMinValue)
    --BetMaxValue = GameConfig.GetFormatColdNumber(BetMaxValue)
    EnterValue = GameConfig.GetFormatColdNumber(EnterValue)
    LeaveValue = GameConfig.GetFormatColdNumber(LeaveValue)
end

-- 确认提示框操作结果
function ConfirmOnClick( resultType )
    if resultType == 1 then
        GameData.Exit_MoneyNotEnough = true;
        GameConfig.OpenStoreUI()
    end
end

-- 馆主局档次
function BrokerageInputValueChanged(valueChang)
    GZBrokerage = GZBrokerageTable[valueChang + 1] - SystemBrokerage
end