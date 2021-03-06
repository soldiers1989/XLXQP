local betLevel = 101
local roomCount = 8
local betLevelSlider = nil
local betMinValueText = nil
local RuleEnterInput = nil
local RuleLeaveInput = nil
-- 底注下限 底注上限 陌生人 (明牌,暗牌) 倍率 入场设定 离场设定
local BetMinValue = 1
local BetMaxValue = 40
local IsLock = 0        -- 是否允许陌生人加入
local GameMode = 1  --  游戏模式(0 明牌 1暗牌)
local Rate = 1    -- (浮动倍率 固定倍率)
local EnterValue = 40
local LeaveValue = 10
-- 房间等级
local RoomLevel = 1
-- 房间类型配置
local mRoomConfigType = 8
local GZBrokerage = 1           -- 馆主抽水
local SystemBrokerage = 1       -- 系统抽水
local GZBrokerageTable = {[1] = 5, [2] = 4, [3] = 3, [4] = 2,}

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
    this.transform:Find('Rule2/Count1'):GetComponent("Toggle").onValueChanged:AddListener(OnClickGameMode1)
    this.transform:Find('Rule2/Count2'):GetComponent("Toggle").onValueChanged:AddListener(OnClickGameMode2)
    this.transform:Find('Rule3/Count1'):GetComponent("Toggle").onValueChanged:AddListener(OnClickRate1)
    this.transform:Find('Rule3/Count2'):GetComponent("Toggle").onValueChanged:AddListener(OnClickRate2)

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

-- 陌生人加入开关
function OnLockOnClick(valueChange)
    if valueChange == true then
        IsLock = 0
    else
        IsLock = 1
    end
end

-- 明牌选择开关
function OnClickGameMode1(valueChange)
    if valueChange == true then
        GameMode = 1
    end
end
-- 暗牌选择开关
function OnClickGameMode2(valueChange)
    if valueChange == true then
        GameMode = 2
    end
end

-- 选择浮动倍率
function OnClickRate1(valueChange)
    if valueChange == true then
        Rate = 1
    end
end
-- 选择固定倍率
function OnClickRate2(valueChange)
    if valueChange == true then
        Rate = 2
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
        local systemCost = 5
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
        RoomLevel=24+RoomLevel
        print('房间模式参数:', roomStyle, systemCost, ownerCost)
        NetMsgHandler.Send_CS_TTZ_Room_Create(RoomLevel, IsLock, EnterValue, LeaveValue, GameMode, Rate, roomStyle, systemCost, ownerCost)
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
        GameData.xit_MoneyNotEnough = true;
        GameConfig.OpenStoreUI()
    end
end

-- 馆主局档次
function BrokerageInputValueChanged(valueChang)
    GZBrokerage = GZBrokerageTable[valueChang + 1] - SystemBrokerage
end
