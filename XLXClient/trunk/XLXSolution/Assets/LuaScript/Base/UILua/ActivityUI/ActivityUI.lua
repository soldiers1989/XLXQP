function Awake()
    -- body
    this.transform:Find('Canvas/Window/Title/ButtonClose'):GetComponent("Button").onClick:AddListener(CloseActivityUI)
    this.transform:Find("Canvas/Window/RewardButton"):GetComponent("Button").onClick:AddListener(ReceiveReward)
    this.transform:Find("Canvas/Image"):GetComponent("Button").onClick:AddListener(CloseActivityUI)
    HandleConfigInfo()
end

-- UI刷新
function RefreshWindowData(windowData)
    HandleSigninInformation()
    HandleRewardButtonState()
end

-- 关闭UIcall
function CloseActivityUI()
    CS.WindowManager.Instance:CloseWindow("UIActivity",false)
end

--领取签到奖励call
function ReceiveReward()
    NetMsgHandler.Send_CS_Player_NewToStarcom()
end

-- 处理配置相关数据
function HandleConfigInfo()
    for index = 1, 7, 1 do
        local _itemTransform = this.transform:Find('Canvas/Window/Content/OneDay'..index)
        local _configData = data.NewcongressConfig[index]
        if _itemTransform ~= nil and _configData ~= nil then
            _itemTransform:Find('Text'):GetComponent('Text').text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(_configData.Num))
        else
            print("*****签到信息配置有误:",index)
        end
    end
end

-- 处理签到详情信息
function HandleSigninInformation()
    local _WeekDay = GameData.RoleInfo.WeekDay
    local _ContinuousSign = GameData.RoleInfo.ContinuousSign
    for index = 1 , 7 , 1 do
        local DayOne =this.transform:Find("Canvas/Window/Content/OneDay"..index)
        -- 已经领取标签
        if _ContinuousSign == 1 then
            DayOne:Find("BackGroundOn").gameObject:SetActive(index <= _WeekDay)
            DayOne:Find("Receive").gameObject:SetActive(index <= _WeekDay)
        else
            DayOne:Find("BackGroundOn").gameObject:SetActive(index < _WeekDay)
            DayOne:Find("Receive").gameObject:SetActive(index < _WeekDay)
        end
        --当前天数标签
        DayOne:Find("SelectImage").gameObject:SetActive(index == _WeekDay)
    end
end

-- 处理领取按钮显示状态
function HandleRewardButtonState()
    local _ContinuousSign = GameData.RoleInfo.ContinuousSign
    if _ContinuousSign == 1 then
        this.transform:Find("Canvas/Window/RewardButton"):GetComponent("Button").interactable = false
    end
end
