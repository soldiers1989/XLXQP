------------ 主页---------------
local AllGoldValueText = nil            -- 总金额
local YesterdayProfitText = nil         -- 昨日收益
local AllProfitText = nil               -- 累计收益
local DayInterestRateText = nil         -- 日化利率
local DayProfitText = nil               -- 日化收益
local QiDayInterestRateText = nil       -- 七日利率
local ShiWuDayInterestRateText = nil    -- 十五日利率
local SanShiDayInterestRateText = nil   -- 三十日利率
local QiDayPriceText = nil              -- 七日投资描述
local ShiWuDayPriceText = nil           -- 十五日投资描述
local SanShiDayPriceText = nil          -- 三十日投资描述
local HomepageTurnOutButton = nil       -- 主页转出按钮
local HomepageTurnOutText = nil         -- 主页转出字体

------------ 投资买入------------
local BuyOkTimeText = nil               -- 预计成交时间Text
local YieldTimeText = nil               -- 产生收益时间Text
local ExpiryTimeText = nil              -- 到期时间Text
local SurplusBuyValueText = nil         -- 剩余数量Text
local QiDayInterestRateText2 = nil      -- 七日利率
local ShiWuDayInterestRateText2 = nil   -- 十五日利率
local SanShiDayInterestRateText2 = nil  -- 三十日利率
local InvestmentTypeText = nil          -- N日Text
local InvestmentButtonType = {}         -- 投资选项Button
local InvestmentButtonImageType = {}    -- 投资选项选中图片
local QiDayPriceText2 = nil             -- 七日投资描述
local ShiWuDayPriceText2 = nil          -- 十五日投资描述
local SanShiDayPriceText2 = nil         -- 三十日投资描述
local BuyHelpValueText = nil            -- 定存万份收益

------------- 转入界面 -------------
local IntoGoldValueText = nil           -- 可转入余额
local IntoPromptText = nil              -- 最大转入额度提示
local IntoButton = nil                  -- 转入按钮
local IntoInputField = nil              -- 转入界面输入框
local IntoPrompt = nil                  -- 提示

------------- 转出界面 --------------
local TurnOutGoldValueText = nil        -- 可转出余额
local TurnOutPromptText = nil           -- 提示
local TurnOutButton = nil               -- 转出按钮
local TurnOutInputField = nil           -- 转出界面输入框

--------------- 系统提示 --------------
local PromptNameObject = {}             -- 系统提示名字
local PromptGoldValue  = nil            -- 系统提示金币值
local PromptInfoText = nil

---------------- 购买成功系统提示 ----------
local BuyGoldValueText = nil            -- 花费金币
local BuyInfoText = nil                 -- 购买信息

----------------- 购买界面-----------------
local BuyAllGoldValueText = nil         -- 拥有金币值
local BuyNumberText = nil               -- 购买份数
local BuyValueText = nil                -- 花费金额

------------------ 我的买入界面 ------------
local MyBuyItem = nil                   -- 买入信息模板
local MyBuyParent = nil                 -- 买入信息父节点
local MyBuyOption = nil                 -- 我的买入筛选界面
local MyBuyAllImage = nil               -- 全部按钮选中图片
local MyBuyAllText = nil                -- 全部按钮选中文字
local MyBuyQiDayImage = nil             -- 七日按钮选中图片
local MyBuyQiDayText = nil              -- 七日按钮选中文字
local MyBuyShiWuDayImage = nil          -- 十五日按钮选中图片
local MyBuyShiWuDayText = nil           -- 十五日按钮选中文字
local MyBuySanShiDayImage = nil         -- 三十日按钮选中图片
local MyBuySanShiDayText = nil          -- 三十日按钮选中文字
local MyBuySellOutObject = nil          -- 卖出提示界面

--------------------- 明细界面 ---------------------
local DetailedItem = nil                -- 明细信息模板
local DetailedParent = nil              -- 明细信息父节点
local DetailedOption = nil              -- 明细筛选界面
local DetailedAllImage = nil            -- 全部按钮选中图片
local DetailedAllText = nil             -- 全部按钮选中文字
local DetailedIntoImage = nil           -- 存入按钮选中图片
local DetailedIntoText = nil            -- 存入按钮选中文字
local DetailedProfitImage = nil         -- 收益日按钮选中图片
local DetailedProfitText = nil          -- 收益日按钮选中文字
local DetailedTurnOutImage = nil        -- 转出日按钮选中图片
local DetailedTurnOutText = nil         -- 转出日按钮选中文字

----------------------- 身份验证 -------------------------
local AuthenticationInputField = nil    -- 身份验证界面InPutField

----------------------- 修改密码 -------------------------
local CP_NewPasswordInputField = nil    -- 新密码
local CP_TwoPassWordInputField = nil    -- 二次确认
local CP_PhoneNumberInputField = nil    -- 手机号
local CP_CodeInputField = nil           -- 验证码

local HomepageObject = nil              -- 主页
local InvestmentWindow = nil            -- 投资买入界面
local IntoWindowObject = nil            -- 转入界面
local TurnOutWindowObject = nil         -- 转出界面
local PrompyWindowOnject = nil          -- 提示界面
local BuyPromptWindow = nil             -- 购买定存成功界面
local BuyWindow = nil                   -- 购买界面
local MyInvestmentWindow = nil          -- 我的买入界面
local DetailedWindow = nil              -- 明细界面
local AuthenticationWindow = nil        -- 身份验证界面
local ChangePasswordWindow = nil        -- 修改密码界面
local HelpWindow = nil                  -- 帮助界面

local mValidationCD = nil               -- 验证码倒计时
local isUpdateCodeCountDown = false     -- 是否开始倒计时

local InvestmentType = 1                -- 选中投资类型
local IntoValue = 0                     -- 转入值
local TurnOutValue = 0                  -- 转出值
local BuyNuamber = 1                    -- 购买次数
local BuyValue = 0                      -- 单次购买价格
local SellOutIndex = 0                  -- 卖出索引
local AuthenticationValue = ""          -- 身份验证界面密码
local NewPassword = ""                  -- 新密码
local TwoPassword = ""                  -- 二次确认密码
local PhoneNumber = ""                  -- 手机号
local VerificationCode = ""             -- 验证码

local DayTable = {"7","15","30"}

-- 初始化UI
function InitializationUI()

    HomepageObject = this.transform:Find('Canvas/YuebaoWindow/Homepage').gameObject
    InvestmentWindow = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow').gameObject
    IntoWindowObject = this.transform:Find('Canvas/YuebaoWindow/IntoWindow').gameObject
    TurnOutWindowObject = this.transform:Find('Canvas/YuebaoWindow/TurnOutWindow').gameObject
    PrompyWindowOnject = this.transform:Find('Canvas/YuebaoWindow/PromptWindow').gameObject
    BuyPromptWindow = this.transform:Find('Canvas/YuebaoWindow/BuyPromptWindow').gameObject
    BuyWindow = this.transform:Find('Canvas/YuebaoWindow/BuyWindow').gameObject
    MyInvestmentWindow = this.transform:Find('Canvas/YuebaoWindow/MyInvestment').gameObject
    DetailedWindow = this.transform:Find('Canvas/YuebaoWindow/Detailed').gameObject
    AuthenticationWindow = this.transform:Find('Canvas/YuebaoWindow/AuthenticationWindow').gameObject
    ChangePasswordWindow = this.transform:Find('Canvas/YuebaoWindow/ChangePasswordWindow').gameObject
    HelpWindow = this.transform:Find('Canvas/YuebaoWindow/HelpWidow').gameObject
    -- body
    ------------ 主页---------------
    AllGoldValueText = this.transform:Find('Canvas/YuebaoWindow/Homepage/Title/AllGoldText'):GetComponent('Text')
    YesterdayProfitText = this.transform:Find('Canvas/YuebaoWindow/Homepage/Title/YesterdyProfitText'):GetComponent('Text')
    AllProfitText = this.transform:Find('Canvas/YuebaoWindow/Homepage/Profit/TotalProfitText'):GetComponent('Text')
    DayInterestRateText = this.transform:Find('Canvas/YuebaoWindow/Homepage/Profit/ProfitPercentText'):GetComponent('Text')
    DayProfitText = this.transform:Find('Canvas/YuebaoWindow/Homepage/Profit/DayProfitText'):GetComponent('Text')
    QiDayInterestRateText =  this.transform:Find('Canvas/YuebaoWindow/Homepage/Recommend/Scroll View/Viewport/Content/Item1/Value'):GetComponent('Text')
    ShiWuDayInterestRateText =  this.transform:Find('Canvas/YuebaoWindow/Homepage/Recommend/Scroll View/Viewport/Content/Item2/Value'):GetComponent('Text')
    SanShiDayInterestRateText =  this.transform:Find('Canvas/YuebaoWindow/Homepage/Recommend/Scroll View/Viewport/Content/Item3/Value'):GetComponent('Text')
    QiDayPriceText = this.transform:Find('Canvas/YuebaoWindow/Homepage/Recommend/Scroll View/Viewport/Content/Item1/Button/Text'):GetComponent('Text')
    ShiWuDayPriceText = this.transform:Find('Canvas/YuebaoWindow/Homepage/Recommend/Scroll View/Viewport/Content/Item2/Button/Text'):GetComponent('Text')
    SanShiDayPriceText = this.transform:Find('Canvas/YuebaoWindow/Homepage/Recommend/Scroll View/Viewport/Content/Item3/Button/Text'):GetComponent('Text')
    HomepageTurnOutButton = this.transform:Find('Canvas/YuebaoWindow/Homepage/TakeInButton'):GetComponent('Button')
    HomepageTurnOutText = this.transform:Find('Canvas/YuebaoWindow/Homepage/TakeInButton/Text1').gameObject

    ------------ 投资买入------------
    BuyOkTimeText = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Help/Image/Value1'):GetComponent('Text')
    YieldTimeText = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Help/Image/Value2'):GetComponent('Text')
    ExpiryTimeText = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Help/Image/Value3'):GetComponent('Text')
    SurplusBuyValueText = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Help/Value'):GetComponent('Text')
    QiDayInterestRateText2 = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Recommend/Scroll View/Viewport/Content/Item1/Value'):GetComponent('Text')
    ShiWuDayInterestRateText2 = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Recommend/Scroll View/Viewport/Content/Item2/Value'):GetComponent('Text')
    SanShiDayInterestRateText2 = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Recommend/Scroll View/Viewport/Content/Item3/Value'):GetComponent('Text')
    QiDayPriceText2 = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Recommend/Scroll View/Viewport/Content/Item1/Button/Text'):GetComponent('Text')
    ShiWuDayPriceText2 = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Recommend/Scroll View/Viewport/Content/Item2/Button/Text'):GetComponent('Text')
    SanShiDayPriceText2 = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Recommend/Scroll View/Viewport/Content/Item3/Button/Text'):GetComponent('Text')
    InvestmentTypeText = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Help/Day'):GetComponent('Text')
    BuyHelpValueText = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Help/Value/Value'):GetComponent('Text')

    ------------ 转入界面 --------------
    IntoGoldValueText = IntoWindowObject.transform:Find('Back/GoldValue'):GetComponent('Text')
    IntoPromptText = IntoWindowObject.transform:Find('Back/InputField/Placeholder'):GetComponent('Text')
    IntoButton = IntoWindowObject.transform:Find('Back/Button'):GetComponent('Button')
    IntoInputField = IntoWindowObject.transform:Find('Back/InputField'):GetComponent("InputField")
    IntoPrompt = IntoWindowObject.transform:Find('Back/Prompt'):GetComponent('Text')

    ------------ 转出界面 --------------
    TurnOutGoldValueText = TurnOutWindowObject.transform:Find('Back/GoldValue'):GetComponent('Text')
    TurnOutPromptText = TurnOutWindowObject.transform:Find('Back/InputField/Placeholder'):GetComponent('Text')
    TurnOutButton = TurnOutWindowObject.transform:Find('Back/Button'):GetComponent('Button')
    TurnOutInputField = TurnOutWindowObject.transform:Find('Back/InputField'):GetComponent("InputField")

    ------------- 系统提示界面 ------------
    PromptGoldValue = PrompyWindowOnject.transform:Find('Back/Value'):GetComponent('Text')
    PromptInfoText = PrompyWindowOnject.transform:Find('Back/Text'):GetComponent('Text')

    ------------- 购买成功系统提示 -----------
    BuyGoldValueText = BuyPromptWindow.transform:Find('Back/Value'):GetComponent('Text')
    BuyInfoText = BuyPromptWindow.transform:Find('Back/Info'):GetComponent('Text')

    ------------- 购买界面 ------------
    BuyAllGoldValueText = BuyWindow.transform:Find('Back/GoldValue'):GetComponent('Text')
    BuyNumberText = BuyWindow.transform:Find('Back/InputField'):GetComponent('InputField')
    BuyValueText = BuyWindow.transform:Find('Back/Content'):GetComponent('Text')

    ------------- 我的买入界面 ----------
    MyBuyItem = MyInvestmentWindow.transform:Find('Content/RankList/Viewport/Item').gameObject
    MyBuyParent = MyInvestmentWindow.transform:Find('Content/RankList/Viewport/Content').gameObject
    MyBuyOption = MyInvestmentWindow.transform:Find('Option').gameObject
    MyBuyAllImage = MyBuyOption.transform:Find('AllButton/Image1').gameObject
    MyBuyAllText = MyBuyOption.transform:Find('AllButton/Text1').gameObject
    MyBuyQiDayImage = MyBuyOption.transform:Find('QiDayButton/Image1').gameObject 
    MyBuyQiDayText = MyBuyOption.transform:Find('QiDayButton/Text1').gameObject
    MyBuyShiWuDayImage = MyBuyOption.transform:Find('ShiWuDayButton/Image1').gameObject
    MyBuyShiWuDayText = MyBuyOption.transform:Find('ShiWuDayButton/Text1').gameObject 
    MyBuySanShiDayImage = MyBuyOption.transform:Find('SanShiDayButton/Image1').gameObject 
    MyBuySanShiDayText = MyBuyOption.transform:Find('SanShiDayButton/Text1').gameObject 
    MyBuySellOutObject = MyInvestmentWindow.transform:Find('SellOutPrompt').gameObject

    -------------明细界面 ----------
    DetailedItem = DetailedWindow.transform:Find('Content/RankList/Viewport/Item').gameObject
    DetailedParent = DetailedWindow.transform:Find('Content/RankList/Viewport/Content').gameObject
    DetailedOption = DetailedWindow.transform:Find('Option').gameObject
    DetailedAllImage = DetailedOption.transform:Find('AllButton/Image1').gameObject
    DetailedAllText = DetailedOption.transform:Find('AllButton/Text1').gameObject
    DetailedIntoImage = DetailedOption.transform:Find('IntoButton/Image1').gameObject 
    DetailedIntoText = DetailedOption.transform:Find('IntoButton/Text1').gameObject
    DetailedProfitImage = DetailedOption.transform:Find('ProfitButton/Image1').gameObject
    DetailedProfitText = DetailedOption.transform:Find('ProfitButton/Text1').gameObject 
    DetailedTurnOutImage = DetailedOption.transform:Find('TurnOutButton/Image1').gameObject 
    DetailedTurnOutText = DetailedOption.transform:Find('TurnOutButton/Text1').gameObject 

    ------------- 身份验证-----------
    AuthenticationInputField = AuthenticationWindow.transform:Find('Back/InputField'):GetComponent("InputField")

    ------------- 修改密码 -------------
    CP_NewPasswordInputField = ChangePasswordWindow.transform:Find('Back/InputField1'):GetComponent("InputField")
    CP_TwoPassWordInputField = ChangePasswordWindow.transform:Find('Back/InputField2'):GetComponent("InputField")
    CP_PhoneNumberInputField = ChangePasswordWindow.transform:Find('Back/InputField3'):GetComponent("InputField")
    CP_CodeInputField = ChangePasswordWindow.transform:Find('Back/InputField4'):GetComponent("InputField")
    mValidationCD = ChangePasswordWindow.transform:Find('Back/CodeButton/CountDown'):GetComponent('Text')

    for i = 1, 3 do
        InvestmentButtonType[i] = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Recommend/Scroll View/Viewport/Content/Item'..i):GetComponent('Button')
        InvestmentButtonImageType[i] = this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Recommend/Scroll View/Viewport/Content/Item'..i..'/Yuan/Image').gameObject
    end

    for i = 1, 2 do
        PromptNameObject[i] = PrompyWindowOnject.transform:Find('Back/Text'..i).gameObject
    end

end

-- 按钮响应事件绑定
function AddButtonHandlers()

    this.transform:Find('Canvas/YuebaoWindow/Homepage/Title/BackButton'):GetComponent('Button').onClick:AddListener(CloseYueBao)
    this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Title/Back'):GetComponent('Button').onClick:AddListener(InvestmentWindowClose)
    this.transform:Find('Canvas/YuebaoWindow/Homepage/TakeOutButton'):GetComponent('Button').onClick:AddListener(OpenIntoWindow)
    this.transform:Find('Canvas/YuebaoWindow/Homepage/TakeInButton'):GetComponent('Button').onClick:AddListener(OpenTurnOutWindow)
    this.transform:Find('Canvas/YuebaoWindow/Homepage/Title/MyFundButton'):GetComponent('Button').onClick:AddListener(MyBuyButtonOnClick)
    this.transform:Find('Canvas/YuebaoWindow/Homepage/Title/BillButton'):GetComponent('Button').onClick:AddListener(DetailedButtonOnClick)
    this.transform:Find('Canvas/YuebaoWindow/Homepage/Title/HelpButton'):GetComponent('Button').onClick:AddListener(OpenHelpWindow)

    HelpWindow.transform:Find('Close'):GetComponent('Button').onClick:AddListener(CloseHelpWindow)

    InvestmentWindow.transform:Find('Button'):GetComponent('Button').onClick:AddListener(OpenBuyWindow)

    IntoWindowObject.transform:Find('Back/InputField'):GetComponent("InputField").onValueChanged:AddListener(GetIntoValue)
    IntoWindowObject.transform:Find('Back/AllButton'):GetComponent('Button').onClick:AddListener(IntoAllButtonOnClick)
    IntoWindowObject.transform:Find('Back/CloeButton'):GetComponent('Button').onClick:AddListener(CloseIntoWindow)
    IntoButton.onClick:AddListener(IntoButonOnClick)

    TurnOutWindowObject.transform:Find('Back/InputField'):GetComponent("InputField").onValueChanged:AddListener(GetTurnOutValue)
    TurnOutWindowObject.transform:Find('Back/InputField'):GetComponent("InputField").onEndEdit:AddListener(OnYuEEndEdit)
    TurnOutWindowObject.transform:Find('Back/AllButton'):GetComponent('Button').onClick:AddListener(TurnOutAllButtonOnClick)
    TurnOutWindowObject.transform:Find('Back/CloeButton'):GetComponent('Button').onClick:AddListener(CloseTurnOutWindow)
    TurnOutButton.onClick:AddListener(TurnOutButonOnClick)

    PrompyWindowOnject.transform:Find('Back/Btton'):GetComponent('Button').onClick:AddListener(ClosePromptWindow)

    BuyNumberText.onValueChanged:AddListener(InputBuyNumber)
    BuyWindow.transform:Find('Back/CloeButton'):GetComponent('Button').onClick:AddListener(CloseBuyWindow)
    BuyWindow.transform:Find('Back/Button'):GetComponent('Button').onClick:AddListener(BuyButtonOnClick)
    BuyWindow.transform:Find('Back/Add'):GetComponent('Button').onClick:AddListener(BuyAddNumber)
    BuyWindow.transform:Find('Back/Reduce'):GetComponent('Button').onClick:AddListener(BuyReduceNumber)

    BuyPromptWindow.transform:Find('Back/Button'):GetComponent('Button').onClick:AddListener(CloseBuyPromptWindow)

    MyInvestmentWindow.transform:Find('Title/Back'):GetComponent('Button').onClick:AddListener(CloseMyInvestmentWindow)
    MyInvestmentWindow.transform:Find('Title/Choice'):GetComponent('Button').onClick:AddListener(OpenMyBuyOption)
    MyBuyOption.transform:Find('Back'):GetComponent('Button').onClick:AddListener(CloseMyInvestmentWindow)
    MyBuyOption.transform:Find('Choice'):GetComponent('Button').onClick:AddListener(CloseMyBuyOption)
    MyBuyOption.transform:Find('AllButton'):GetComponent('Button').onClick:AddListener(function ()MyBuyOptionButtonOnClick(0)end)
    MyBuyOption.transform:Find('QiDayButton'):GetComponent('Button').onClick:AddListener(function ()MyBuyOptionButtonOnClick(1)end)
    MyBuyOption.transform:Find('ShiWuDayButton'):GetComponent('Button').onClick:AddListener(function ()MyBuyOptionButtonOnClick(2)end)
    MyBuyOption.transform:Find('SanShiDayButton'):GetComponent('Button').onClick:AddListener(function ()MyBuyOptionButtonOnClick(3)end)
    MyBuySellOutObject.transform:Find('Back/Button1'):GetComponent('Button').onClick:AddListener(SureToSellButtonOnClick)
    MyBuySellOutObject.transform:Find('Back/Button2'):GetComponent('Button').onClick:AddListener(CloseSellOutObject)

    DetailedWindow.transform:Find('Title/Back'):GetComponent('Button').onClick:AddListener(CloseDetailedWindow)
    DetailedWindow.transform:Find('Title/Choice'):GetComponent('Button').onClick:AddListener(OpenDetailedOption)
    DetailedOption.transform:Find('Back'):GetComponent('Button').onClick:AddListener(CloseDetailedWindow)
    DetailedOption.transform:Find('Choice'):GetComponent('Button').onClick:AddListener(CloseDetailedOption)
    DetailedOption.transform:Find('AllButton'):GetComponent('Button').onClick:AddListener(function ()DetailedOptionButtonOnClick(0)end)
    DetailedOption.transform:Find('IntoButton'):GetComponent('Button').onClick:AddListener(function ()DetailedOptionButtonOnClick(1)end)
    DetailedOption.transform:Find('ProfitButton'):GetComponent('Button').onClick:AddListener(function ()DetailedOptionButtonOnClick(2)end)
    DetailedOption.transform:Find('TurnOutButton'):GetComponent('Button').onClick:AddListener(function ()DetailedOptionButtonOnClick(3)end)

    AuthenticationInputField.onValueChanged:AddListener(GetAuthenticationPassWordValue)
    AuthenticationWindow.transform:Find('Back/Close'):GetComponent('Button').onClick:AddListener(CloseAuthenticationWindow)
    AuthenticationWindow.transform:Find('Back/Button'):GetComponent('Button').onClick:AddListener(RequestTurnOut)
    AuthenticationWindow.transform:Find('Back/ChangePawwWord'):GetComponent('Button').onClick:AddListener(OpenChangePasswordWindow)

    ChangePasswordWindow.transform:Find('Back/CodeButton'):GetComponent('Button').onClick:AddListener(OnValidationBtnClick)
    ChangePasswordWindow.transform:Find('Back/Close'):GetComponent('Button').onClick:AddListener(CloseChangePasswordWindow)
    ChangePasswordWindow.transform:Find('Back/Button'):GetComponent('Button').onClick:AddListener(ConfirmPasswordChange)
    CP_NewPasswordInputField.onValueChanged:AddListener(GetNewPassword)
    CP_TwoPassWordInputField.onValueChanged:AddListener(GetTwoPassword)
    CP_PhoneNumberInputField.onValueChanged:AddListener(GetPhoneNumber)
    CP_CodeInputField.onValueChanged:AddListener(GetVerificationCode)

    for i = 1, 3 do
        this.transform:Find('Canvas/YuebaoWindow/Homepage/Recommend/Scroll View/Viewport/Content/Item'..i):GetComponent('Button').onClick:AddListener(function()HomepageInvestmentTypeButtonOnClcik(i)end)
        this.transform:Find('Canvas/YuebaoWindow/InvestmentWindow/Recommend/Scroll View/Viewport/Content/Item'..i):GetComponent('Button').onClick:AddListener(function()InvestmentTypeButtonOnClcik(i)end)
    end
end

-- 初始化数据显示
function InitializationDataDisplay()
    AllGoldValueText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2))
    YesterdayProfitText.text = tostring(GameData.YueBaoInfo.Homepage.YesterdayProfit)
    AllProfitText.text = tostring(lua_NumberToStyle1String(GameData.YueBaoInfo.Homepage.AllProfit))
    DayInterestRateText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.DayInterestRate,2))
    DayProfitText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.DayProfit,5))
    QiDayInterestRateText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.QiDayInterestRate,2))
    ShiWuDayInterestRateText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.ShiWuDayInterestRate,2))
    SanShiDayInterestRateText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.SanShiDayInterestRate,2))
    QiDayPriceText.text = ""..lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.QiDayPrice,2)..'元1份,'..GameData.YueBaoInfo.Homepage.QiDayNumber.."份起买"
    ShiWuDayPriceText.text = ""..lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.ShiWuDayPrice,2)..'元1份,'..GameData.YueBaoInfo.Homepage.ShiWuDayNumber.."份起买"
    SanShiDayPriceText.text = ""..lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.SanShiDayPrice,2)..'元1份,'..GameData.YueBaoInfo.Homepage.SanShiDayNumber.."份起买"
    QiDayPriceText2.text = ""..lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.QiDayPrice,2)..'元1份,'..GameData.YueBaoInfo.Homepage.QiDayNumber.."份起买"
    ShiWuDayPriceText2.text = ""..lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.ShiWuDayPrice,2)..'元1份,'..GameData.YueBaoInfo.Homepage.ShiWuDayNumber.."份起买"
    SanShiDayPriceText2.text = ""..lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.SanShiDayPrice,2)..'元1份,'..GameData.YueBaoInfo.Homepage.SanShiDayNumber.."份起买"
    if lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2) <= 0 then
        HomepageTurnOutButton.interactable = false
        GameObjectSetActive(HomepageTurnOutText,true)
    else
        HomepageTurnOutButton.interactable = true
        GameObjectSetActive(HomepageTurnOutText,false)
    end
    mValidationCD.text = ""
end

--  投资类型按钮点击
function HomepageInvestmentTypeButtonOnClcik(mIndex)
    -- body
    InvestmentType = mIndex
    NetMsgHandler.Send_CS_YueBaoLineTime(mIndex,true)
end

--  主页投资类型按钮点击
function InvestmentTypeButtonOnClcik(mIndex)
    -- body
    InvestmentType = mIndex
    NetMsgHandler.Send_CS_YueBaoLineTime(mIndex,false)
end

-- 打开投资买入界面
function InvestmentWindowOpen()
    -- body
    if HomepageObject.activeSelf == true then
        GameObjectSetActive(HomepageObject,false)
        GameObjectSetActive(InvestmentWindow,true)
        QiDayInterestRateText2.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.QiDayInterestRate,2))
        ShiWuDayInterestRateText2.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.ShiWuDayInterestRate,2))
        SanShiDayInterestRateText2.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.SanShiDayInterestRate,2)) 
    end
    for i = 1, 3 do
        if InvestmentType == i then
            InvestmentButtonType[i].interactable = false
            GameObjectSetActive(InvestmentButtonImageType[i],true)
        else
            InvestmentButtonType[i].interactable = true
            GameObjectSetActive(InvestmentButtonImageType[i],false)
        end
    end
    InvestmentTypeText.text=DayTable[InvestmentType]
    BuyOkTimeText.text = GameData.YueBaoInfo.Investment.BuyOkTime.month.."-"..GameData.YueBaoInfo.Investment.BuyOkTime.day
    YieldTimeText.text = GameData.YueBaoInfo.Investment.YieldTime.month.."-"..GameData.YueBaoInfo.Investment.YieldTime.day
    ExpiryTimeText.text = GameData.YueBaoInfo.Investment.ExpiryTime.month.."-"..GameData.YueBaoInfo.Investment.ExpiryTime.day
    SurplusBuyValueText.text = tostring(GameData.YueBaoInfo.Investment.SurplusBuyValue)
    if InvestmentType == 1 then
        BuyHelpValueText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.QiDayInterestRate,2))
    elseif InvestmentType == 2 then
        BuyHelpValueText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.ShiWuDayInterestRate,2))
    elseif InvestmentType == 3 then
        BuyHelpValueText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.SanShiDayInterestRate,2)) 
    end
end

-- 关闭投资买入界面
function InvestmentWindowClose()
    -- body
    GameObjectSetActive(HomepageObject,true)
    GameObjectSetActive(InvestmentWindow,false)
end

-- 刷新余额宝金额
function UpdateYueBaoGoldValue( mType )
    -- body
    if mType == 1 then
        IntoGoldValueSuccess()
    else
        TurnGoldValueSuccess()
    end
end

-- 转入界面全部按钮
function IntoAllButtonOnClick()
    -- body
    IntoValue = math.floor(GameData.YueBaoInfo.Homepage.IntoAllValue)
    IntoInputField.text =tostring(math.floor(GameData.YueBaoInfo.Homepage.IntoAllValue))
    IntoButtonIsClick()
end

-- 获取转入额度
function GetIntoValue(mailContent)
    IntoValue = mailContent
    IntoButtonIsClick()
end

-- 转入按钮是否可点
function IntoButtonIsClick()
    -- body
    if IntoValue == "" or IntoValue == nil then
        IntoButton.interactable = false
        IntoPrompt.text = "请输入转入金额"
        return
    end
    if tonumber(string.sub(IntoValue,1,1)) == 0 then
        IntoButton.interactable = false
        IntoPrompt.text = "输入有效转入金额"
        return
    end
    if 1 > tonumber(IntoValue) then
        IntoButton.interactable = false
        IntoPrompt.text = "低于最小转入金额下限"
        return
    end
    if 1 <= tonumber(IntoValue) and tonumber(IntoValue) <= GameData.YueBaoInfo.Homepage.IntoAllValue then
        IntoButton.interactable = true
        IntoPrompt.text = ""
    else
        IntoButton.interactable = false
        IntoPrompt.text = "超出最大可转入金额上限"
    end
end

-- 点击转入按钮
function IntoButonOnClick()
    -- body
    NetMsgHandler.Send_CS_YueBaoIntoValue(IntoValue)
end

-- 转入金额成功
function IntoGoldValueSuccess()
    -- body
    CloseIntoWindow()
    AllGoldValueText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2))
    IntoValue = 0
    OpenPromptWindow(1,GameData.YueBaoInfo.Homepage.IntoValue)
    if lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2) < 0 then
        HomepageTurnOutButton.interactable = false
        GameObjectSetActive(HomepageTurnOutText,true)
    else
        HomepageTurnOutButton.interactable = true
        GameObjectSetActive(HomepageTurnOutText,false)
    end
end

-- 打开转入界面
function OpenIntoWindow()
    -- body
    if GameData.RoleInfo.IsBindAccount == false then
        local carRotation = CS.WindowManager.Instance:FindWindowNodeByName("UIBndingBankCard")
        if carRotation == nil then
            CS.WindowManager.Instance:OpenWindow("UIBndingBankCard")
        end
        return 
    end
    if GameData.YueBaoInfo.Homepage.Binding == false then
        local carRotation = CS.WindowManager.Instance:FindWindowNodeByName("UITwoCipher")
        if carRotation == nil then
            CS.WindowManager.Instance:OpenWindow("UITwoCipher")
        end
        return 
    end
    IntoValue = 0
    GameObjectSetActive(IntoWindowObject,true)
    IntoInputField.text = ""
    IntoGoldValueText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.IntoAllValue,2))
    IntoPromptText.text = "本次最多转入"..lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.IntoAllValue,2).."元"
end

-- 关闭转入界面
function CloseIntoWindow()
    GameObjectSetActive(IntoWindowObject,false)
end

-- 转出界面全部按钮
function TurnOutAllButtonOnClick()
    -- body
    TurnOutValue = lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2)
    TurnOutInputField.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2))
    TurnOutButtonIsClick()
end

-- 获取转出额度
function GetTurnOutValue(mailContent)
    TurnOutValue = mailContent
    TurnOutButtonIsClick()
end

-- 获取转出额度结束
function OnYuEEndEdit( valueEnd )
    -- body
    if tonumber(valueEnd) * 10000 % 10000 > 0 then
        -- body
        -- 有小数
      local value2  = lua_GetPreciseDecimal(tonumber(valueEnd),2)
      TurnOutValue = value2
      TurnOutInputField.text = tostring(value2)
      TurnOutInputField:MoveTextEnd()
    end
end

-- 转出按钮是否可点
function TurnOutButtonIsClick()
    -- body
    if TurnOutValue == "" or TurnOutValue == nil then
        TurnOutButton.interactable = false
        return
    end
    if tonumber(string.sub(TurnOutValue,1,1)) == 0 then
        TurnOutButton.interactable = false
        return
    end
    if 1<=tonumber(TurnOutValue) and tonumber(TurnOutValue) <=GameData.YueBaoInfo.Homepage.AllGoldValue then
        TurnOutButton.interactable = true
    else
        TurnOutButton.interactable = false
    end
end

-- 点击转出按钮
function TurnOutButonOnClick()
    -- body
    GameObjectSetActive(TurnOutWindowObject,false)
    GameObjectSetActive(AuthenticationWindow,true)
    AuthenticationInputField.text = ""
    AuthenticationValue = ""
end

-- 获取身份验证密码
function GetAuthenticationPassWordValue(mailContent)
    AuthenticationValue = mailContent
    AuthenticationInputField.text = AuthenticationValue
end

-- 请求转出
function RequestTurnOut()
    if AuthenticationValue == nil or AuthenticationValue == "" then
        CS.BubblePrompt.Show(data.GetString("请输入二级密码"),"UIYuebao")
        return 
    end
    if AuthenticationValue ~= GameData.YueBaoInfo.Homepage.BindingPassword then
        CS.BubblePrompt.Show(data.GetString("密码不正确"),"UIYuebao")
        return 
    end
    local glodValue = tonumber(TurnOutValue)
    glodValue = math.floor( glodValue * 10000 )
    NetMsgHandler.Send_CS_YueBaoTurnOutValue(glodValue)
end

-- 关闭转出按钮
function CloseAuthenticationWindow( )
    -- body
    GameObjectSetActive(AuthenticationWindow,false)
end

-- 转出金额成功
function TurnGoldValueSuccess()
    -- body
    GameObjectSetActive(AuthenticationWindow,false)
    CloseAuthenticationWindow( )
    AllGoldValueText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2))
    DayProfitText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.DayProfit,5))
    TurnOutValue = 0
    OpenPromptWindow(2,GameData.YueBaoInfo.Homepage.TurnOutValue)
    if lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2) < 0 then
        HomepageTurnOutButton.interactable = false
        GameObjectSetActive(HomepageTurnOutText,true)
    else
        HomepageTurnOutButton.interactable = true
        GameObjectSetActive(HomepageTurnOutText,false)
    end
end

-- 打开转出界面
function OpenTurnOutWindow()
    -- body
    TurnOutValue = 0
    GameObjectSetActive(TurnOutWindowObject,true)
    TurnOutInputField.text = ""
    TurnOutGoldValueText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2))
    TurnOutPromptText.text = "本次最多转出"..lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2).."元"
end

-- 关闭转出界面
function CloseTurnOutWindow()
    GameObjectSetActive(TurnOutWindowObject,false)
end

-- 打开系统提示界面
function OpenPromptWindow(mIndex,GoldValue)
    -- body
    GameObjectSetActive(PrompyWindowOnject,true)
    for i = 1, 2 do
        if i == mIndex then
            GameObjectSetActive(PromptNameObject[i],true)
        else
            GameObjectSetActive(PromptNameObject[i],false)
        end
    end
    PromptGoldValue.text = tostring(GoldValue)
    if mIndex == 1 then
        PromptInfoText.text = "8小时后产生第一笔收益"
    else
        PromptInfoText.text = ""
    end
end

-- 打开修改密码界面
function OpenChangePasswordWindow()
    -- body
    CloseTurnOutWindow()
    CloseAuthenticationWindow( )
    GameObjectSetActive(ChangePasswordWindow,true)
    NewPassword = ""
    TwoPassword = ""
    PhoneNumber = ""
    VerificationCode = ""
    CP_NewPasswordInputField.text = NewPassword
    CP_TwoPassWordInputField.text = TwoPassword
    CP_PhoneNumberInputField.text = PhoneNumber
    CP_CodeInputField.text = VerificationCode
end

-- 获取新密码
function GetNewPassword( mailContent )
    -- body
    NewPassword = mailContent
    CP_NewPasswordInputField.text = NewPassword
end

-- 获取二次确认密码
function GetTwoPassword(mailContent)
    TwoPassword = mailContent
    CP_TwoPassWordInputField.text = TwoPassword
end

-- 获取手机号
function GetPhoneNumber(mailContent)
    PhoneNumber = mailContent
    CP_PhoneNumberInputField.text = PhoneNumber
end

-- 验证码
function GetVerificationCode(mailContent)
    VerificationCode = mailContent
    CP_CodeInputField.text = VerificationCode
end

-- 获取验证码
function OnValidationBtnClick()
    -- 首先检查90秒限制
    -- 最后发送短信时间
    local tLastErrorCode = CS.SMSManager.Instance().LastSendSMSErrorCode
    local tLastTime = CS.SMSManager.Instance().LastSendSMSTime
    tLastTime = tonumber(tLastTime)

    -- 当前时间 秒
    local tNowTime = os.time()
    local passTime = tNowTime - tLastTime
    if passTime <= 0 then
       passTime = 0 
    end
    print("===time:", tNowTime, tLastTime, passTime)
    if passTime < 90 then
        CS.BubblePrompt.Show('获取验证码太频繁,请稍等:'..(90 - passTime), "UIYuebao")
        CS.SMSManager.Instance().IsUpdateCD = true
        CS.SMSManager.Instance().SMSCDTime = (90 -passTime) * 1.0
        isUpdateCodeCountDown = true
        return
    elseif passTime < 3600 then
        -- 重复过滤 建议减少每小时发送数量
        if tLastErrorCode == "isv.BUSINESS_LIMIT_CONTROL" then
            CS.BubblePrompt.Show('获取验证码太频繁,请1小时后再获取', "UIYuebao")
            return
        end
    elseif passTime < 86400 then
        if tLastErrorCode == "VALVE:D_MC" then
            -- 重复过滤 建议减少每天发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请24小时后再获取', "UIYuebao")
            return 
        end
    end

    local strAccount = PhoneNumber
    local tmpLength = SubStringGetTotalCount(strAccount)
    if tmpLength ~= 11 then
        CS.BubblePrompt.Show('请输入正确的手机号码', "UIYuebao")
        return
    end

    local tCode = CS.SMSManager.Instance():SMSRandomCode()

    CS.SMSManager.Instance().LastSendSMSTime = tostring(tNowTime)
    CS.SMSManager.Instance().LastSMSCode = tostring(tCode)
    CS.SMSManager.Instance().LastPhoneNumber = strAccount
    isUpdateCodeCountDown = true

    local code = string.format("{\"code\":\"%s\"}", tostring(tCode))

    local tdata = CS.SMSManager.SendSms(strAccount, "SMS_135270123", code,"")
    if tdata ~= nil then
        CS.SMSManager.Instance().IsUpdateCD = true
        CS.SMSManager.Instance().SMSCDTime = 90
        
        if tdata.Code == "OK" then
            -- TODO 验证码发送成功
            CS.BubblePrompt.Show("验证码获取成功", "UILogin")
        elseif tdata.Code == "isv.MOBILE_NUMBER_ILLEGAL" then
            -- 非法手机号 建议使用正确的手机号
        elseif tdata.Code == "VALVE:D_MC" then
            -- 重复过滤 建议减少每天发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请24小时后再获取', "UIYuebao")
        elseif tdata.Code == "VALVE::H_MC" then
            -- 重复过滤 建议减少每小时发送数量
            CS.BubblePrompt.Show('获取验证码太频繁,请1小时后再获取', "UIYuebao")
        elseif tdata.Code == "VALVE::M_MC" then
            -- 重复过滤 建议减少每分钟发送数量()
            CS.BubblePrompt.Show('获取验证码太频繁,请等90秒再获取', "UIYuebao")
        else
            CS.BubblePrompt.Show('获取验证码太频繁,稍后获取', "UIYuebao")
        end
        CS.SMSManager.Instance().LastSendSMSErrorCode = tdata.Code
        -- print("Send SMS Code:", tdata.Code, tdata.Message)
        -- print("Send SMS BizId", tdata.BizId, tdata.RequestId)
    else
        CS.SMSManager.Instance().LastSendSMSErrorCode = "1"
        CS.BubblePrompt.Show('获取验证码太频繁,稍后获取', "UIYuebao")
    end

end

-- 关闭修改界面
function CloseChangePasswordWindow()
    GameObjectSetActive(ChangePasswordWindow,false)
end

-- 确认修改密码
function ConfirmPasswordChange()
    local accountText = tostring(PhoneNumber)
    local tmpLength = SubStringGetTotalCount(accountText)
    if NewPassword == "" or NewPassword == nil then
        CS.BubblePrompt.Show(data.GetString("请输入新密码"),"UIYuebao")
        return 
    end
    if #NewPassword < 3 then
        CS.BubblePrompt.Show(data.GetString("请输入3~8为数字和英文组合"),"UIYuebao")
        return
    end
    if TwoPassword == "" or TwoPassword == nil then
        CS.BubblePrompt.Show(data.GetString("请输入二次确认密码"),"UIYuebao")
        return 
    end
    if NewPassword ~= TwoPassword then
        CS.BubblePrompt.Show(data.GetString("两次密码不一致"),"UIYuebao")
        return 
    end

    if PhoneNumber == "" or PhoneNumber == nil then
        CS.BubblePrompt.Show(data.GetString("请输入手机号"),"UIYuebao")
        return 
    end

    if #PhoneNumber ~= 11 then
        CS.BubblePrompt.Show('请输入正确的手机号码', "UIYuebao")
        return
    end

    if VerificationCode == "" or VerificationCode == nil then
        CS.BubblePrompt.Show('请输入验证码', "UIYuebao")
        return
    end

    local codeText = VerificationCode
    tmpLength = SubStringGetTotalCount(codeText)
    if  codeText =="" or tmpLength ~= 6 or
            CS.SMSManager.Instance().LastSendSMSErrorCode ~= "OK" or
            CS.SMSManager.Instance().LastSMSCode ~= codeText then
        CS.BubblePrompt.Show('验证码无效!', "UIYuebao")
        return
    end

    -- 当前号码是否是接受验证码的手机好吗
    if accountText ~= CS.SMSManager.Instance().LastPhoneNumber then
        CS.BubblePrompt.Show('前后输入的手机号不一致...', "UIYuebao")
        return
    end
    NetMsgHandler.Send_CS_ChangeYueBaoPassWord(NewPassword,TwoPassword,accountText)
end

-- 关闭系统提示界面
function ClosePromptWindow(  )
    -- body
    GameObjectSetActive(PrompyWindowOnject,false)
end

-- 打开帮助界面
function OpenHelpWindow()
    -- body
    GameObjectSetActive(HelpWindow,true)
end

-- 关闭帮助界面
function CloseHelpWindow()
    -- body
    GameObjectSetActive(HelpWindow,false)
end

-- 打开购买界面
function OpenBuyWindow()
    GameObjectSetActive(BuyWindow,true)
    if InvestmentType == 1 then
        BuyValue = GameData.YueBaoInfo.Homepage.QiDayPrice
    elseif InvestmentType == 2 then
        BuyValue = GameData.YueBaoInfo.Homepage.ShiWuDayPrice
    elseif InvestmentType == 3 then
        BuyValue = GameData.YueBaoInfo.Homepage.SanShiDayPrice
    end
    BuyNuamber = 1
    BuyNumberText.text = tostring(BuyNuamber)
    BuyAllGoldValueText.text = tostring(GameData.YueBaoInfo.Homepage.AllGoldValue)
    BuyValueText.text = "共计:".. tostring(BuyNuamber*BuyValue) .. "元"
end

-- 购买界面加次数
function BuyAddNumber()
    BuyNuamber = BuyNuamber + 1
    BuyNumberText.text = tostring(BuyNuamber)
    BuyValueText.text = "共计:".. tostring(BuyNuamber*BuyValue) .. "元"
end

-- 购买界面减次数
function BuyReduceNumber()
    BuyNuamber = BuyNuamber - 1
    if BuyNuamber < 0 then
        BuyNuamber = 0
    end
    BuyNumberText.text = tostring(BuyNuamber)
    BuyValueText.text = "共计:".. tostring(BuyNuamber*BuyValue) .. "元"
end

-- 玩家输入购买次数
function InputBuyNumber(mailContent)
    BuyNuamber = mailContent
    if BuyNuamber == "" or BuyNuamber == nil then
        BuyNuamber = 0
    end
    if string.len(BuyNuamber)  == 2 then
        if string.sub(BuyNuamber,1,1) == 0 or string.sub(BuyNuamber,1,1) == "0" then
            -- body
            BuyNuamber = string.sub(BuyNuamber,2)
            BuyNumberText.text = tostring(BuyNuamber)
        end
    end
    BuyNuamber = tonumber(BuyNuamber)
    BuyValueText.text = "共计:".. tostring(BuyNuamber*BuyValue) .. "元"
end

-- 关闭购买界面
function CloseBuyWindow()
    -- body
    GameObjectSetActive(BuyWindow,false)
end

-- 点击购买
function BuyButtonOnClick()
    NetMsgHandler.Send_CS_YueBaoInvestmentType(InvestmentType,BuyNuamber)
end

-- 打开购买成功提示界面
function OpenBuyPromptWindow(ResultTable)
    -- body
    CloseBuyWindow()
    GameObjectSetActive(BuyPromptWindow,true)
    BuyGoldValueText.text = "共计<color=red>"..ResultTable.SpendGold.."</color>"
    BuyInfoText.text = "成功买入<color=red>"..DayTable[ResultTable.tType].."</color>日定存<color=red>"..ResultTable.Number.."</color>份"
    AllGoldValueText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2))
    SurplusBuyValueText.text = tostring(ResultTable.SpareNumber)
    if lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2) < 0 then
        HomepageTurnOutButton.interactable = false
        GameObjectSetActive(HomepageTurnOutText,true)
    else
        HomepageTurnOutButton.interactable = true
        GameObjectSetActive(HomepageTurnOutText,false)
    end
end

-- 关闭购买成功提示界面
function CloseBuyPromptWindow()
    -- body
    GameObjectSetActive(BuyPromptWindow,false)
end

-- 点击我的买入按钮
function MyBuyButtonOnClick( )
    -- body
    NetMsgHandler.Send_CS_YueBaoMyBuyInfo()
end

-- 打开我的买入界面
function OpenMyInvestmentWindow()
    -- body
    GameObjectSetActive(HomepageObject,false)
    GameObjectSetActive(MyInvestmentWindow,true)
    GameObjectSetActive(MyBuyOption,false)
    if MyBuyParent.transform.childCount > 0 then
        local count=MyBuyParent.transform.childCount
        for i = 1,count do
            if MyBuyParent.transform:Find("Item"..i)~=nil then
                local copy= MyBuyParent.transform:Find("Item"..i).gameObject
                CS.UnityEngine.Object.Destroy (copy)
            end
        end
    end
    for i = 1, #GameData.YueBaoInfo.MyBuyInfo do
        local Item = CS.UnityEngine.Object.Instantiate(MyBuyItem)
        CS.Utility.ReSetTransform(Item.transform, MyBuyParent.transform)
        Item.gameObject:SetActive(true)
        Item.transform.name = "Item"..i
        Item.transform:Find('Type'):GetComponent('Text').text = DayTable[GameData.YueBaoInfo.MyBuyInfo[i].Type]..'日定存<size=30>('..GameData.YueBaoInfo.MyBuyInfo[i].StartTime.month..'月'..GameData.YueBaoInfo.MyBuyInfo[i].StartTime.day..'日算起)</size>'
        Item.transform:Find('Time'):GetComponent('Text').text = GameData.YueBaoInfo.MyBuyInfo[i].BuyTime
        Item.transform:Find('Gold1'):GetComponent('Text').text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.MyBuyInfo[i].BuyGold,2))
        Item.transform:Find('Gold2'):GetComponent('Text').text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.MyBuyInfo[i].OnlyGold,2))..'*1份'
        Item.transform:Find('Mode'):GetComponent('Text').text  = "(万元每日收益:"..lua_GetPreciseDecimal(GameData.YueBaoInfo.MyBuyInfo[i].LiLv,2)..")"
        Item.transform:Find('SellOut'):GetComponent('Button').onClick:AddListener(function() SellOutButtonOnClick(i) end)
    end
    GameObjectSetActive(MyBuyAllImage,true)
    GameObjectSetActive(MyBuyAllText,true)
    GameObjectSetActive(MyBuyQiDayImage,false)
    GameObjectSetActive(MyBuyQiDayText,false)
    GameObjectSetActive(MyBuyShiWuDayImage,false)
    GameObjectSetActive(MyBuyShiWuDayText,false)
    GameObjectSetActive(MyBuySanShiDayImage,false)
    GameObjectSetActive(MyBuySanShiDayText,false)
end

-- 点击卖出按钮
function SellOutButtonOnClick(Index)
    SellOutIndex = Index
    GameObjectSetActive(MyBuySellOutObject,true)
end

-- 关闭卖出二次确认界面
function CloseSellOutObject( )
    -- body
    GameObjectSetActive(MyBuySellOutObject,false)
end

-- 确定卖出
function SureToSellButtonOnClick()
    -- body
    NetMsgHandler.Send_CS_YueBaoSellOut(GameData.YueBaoInfo.MyBuyInfo[SellOutIndex].ID)
end

-- 卖出成功
function SuccessfulSelling()
    -- body
    CloseSellOutObject( )
    if MyBuyParent.transform:Find('Item'..SellOutIndex) ~= nil then
        local copy=  MyBuyParent.transform:Find('Item'..SellOutIndex).gameObject
        CS.UnityEngine.Object.Destroy (copy)
    end
    AllGoldValueText.text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2))
    AllProfitText.text = tostring(lua_NumberToStyle1String(GameData.YueBaoInfo.Homepage.AllProfit))
    SellOutIndex = 0
    if lua_GetPreciseDecimal(GameData.YueBaoInfo.Homepage.AllGoldValue,2) < 0 then
        HomepageTurnOutButton.interactable = false
        GameObjectSetActive(HomepageTurnOutText,true)
    else
        HomepageTurnOutButton.interactable = true
        GameObjectSetActive(HomepageTurnOutText,false)
    end
end

-- 打开我的买入筛选界面
function OpenMyBuyOption()
    GameObjectSetActive(MyBuyOption,true)
end

-- 我的买入界面进行筛选
function MyBuyOptionButtonOnClick(Index)
    GameObjectSetActive(MyBuyAllImage,false)
    GameObjectSetActive(MyBuyAllText,false)
    GameObjectSetActive(MyBuyQiDayImage,false)
    GameObjectSetActive(MyBuyQiDayText,false)
    GameObjectSetActive(MyBuyShiWuDayImage,false)
    GameObjectSetActive(MyBuyShiWuDayText,false)
    GameObjectSetActive(MyBuySanShiDayImage,false)
    GameObjectSetActive(MyBuySanShiDayText,false)
    SellOutIndex = 0
    if Index == 0 then
        GameObjectSetActive(MyBuyAllImage,true)
        GameObjectSetActive(MyBuyAllText,true)
        for i = 1, #GameData.YueBaoInfo.MyBuyInfo do
            if MyBuyParent.transform:Find('Item'..i) ~= nil then
                MyBuyParent.transform:Find('Item'..i).gameObject:SetActive(true)
            end
        end
    else
        if Index == 1 then
            GameObjectSetActive(MyBuyQiDayImage,true)
            GameObjectSetActive(MyBuyQiDayText,true)
        elseif Index == 2 then
            GameObjectSetActive(MyBuyShiWuDayImage,true)
            GameObjectSetActive(MyBuyShiWuDayText,true)
        elseif Index == 3 then
            GameObjectSetActive(MyBuySanShiDayImage,true)
            GameObjectSetActive(MyBuySanShiDayText,true)
        end
        for i = 1, #GameData.YueBaoInfo.MyBuyInfo do
            if MyBuyParent.transform:Find('Item'..i) ~= nil then
                if GameData.YueBaoInfo.MyBuyInfo[i].Type == Index then
                    MyBuyParent.transform:Find('Item'..i).gameObject:SetActive(true)
                else
                    MyBuyParent.transform:Find('Item'..i).gameObject:SetActive(false)
                end
            end
        end
    end
end

-- 关闭我的买入筛选界面
function CloseMyBuyOption()
    GameObjectSetActive(MyBuyOption,false)
end

-- 关闭我的买入界面
function CloseMyInvestmentWindow()
    -- body
    GameObjectSetActive(HomepageObject,true)
    GameObjectSetActive(MyInvestmentWindow,false)
end

-- 点击明细按钮
function DetailedButtonOnClick( )
    -- body
    NetMsgHandler.Send_CS_YueBaoDetailed()
end

local DetailedMode = {'转入','收益','转出'}

-- 打开明细界面
function OpenDetailedWindow()
    GameObjectSetActive(HomepageObject,false)
    GameObjectSetActive(DetailedWindow,true)
    GameObjectSetActive(DetailedOption,false)
    if DetailedParent.transform.childCount > 0 then
        local count=DetailedParent.transform.childCount
        for i = 1,count do
            if DetailedParent.transform:Find("Item"..i)~=nil then
                local copy= DetailedParent.transform:Find("Item"..i).gameObject
                CS.UnityEngine.Object.Destroy (copy)
            end
        end
    end
    for i = 1, #GameData.YueBaoInfo.DetailedInfo do
        local Item = CS.UnityEngine.Object.Instantiate(DetailedItem)
        CS.Utility.ReSetTransform(Item.transform, DetailedParent.transform)
        Item.gameObject:SetActive(true)
        Item.transform.name = "Item"..i
        Item.transform:Find('Type'):GetComponent('Text').text = DetailedMode[GameData.YueBaoInfo.DetailedInfo[i].Type]
        Item.transform:Find('Time'):GetComponent('Text').text = GameData.YueBaoInfo.DetailedInfo[i].ChangeTime
        if GameData.YueBaoInfo.DetailedInfo[i].ChangeValue > 0 then
            Item.transform:Find('Gold1'):GetComponent('Text').text = "+"..tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.DetailedInfo[i].ChangeValue,2))
        elseif GameData.YueBaoInfo.DetailedInfo[i].ChangeValue < 0 then
            Item.transform:Find('Gold1'):GetComponent('Text').text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.DetailedInfo[i].ChangeValue,2))
        end
        Item.transform:Find('Gold2'):GetComponent('Text').text = tostring(lua_GetPreciseDecimal(GameData.YueBaoInfo.DetailedInfo[i].AfterChangeValue,2))

        if GameData.YueBaoInfo.DetailedInfo[i].Type == 1 then
            if GameData.YueBaoInfo.DetailedInfo[i].InfoTable.Mode == 1 then
                --Item.transform:Find('Mode'):GetComponent('Text').text = "("..GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyType ..'日定存本金)'
                Item.transform:Find('Mode'):GetComponent('Text').text = string.format(data.GetString('YueBaoDetailedInfo_1'),DayTable[GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyType])
            elseif GameData.YueBaoInfo.DetailedInfo[i].InfoTable.Mode == 2 then
                --Item.transform:Find('Mode'):GetComponent('Text').text = "(卖出"..GameData.YueBaoInfo.DetailedInfo[i].InfoTable.NDay ..'日定存)'
                Item.transform:Find('Mode'):GetComponent('Text').text = string.format(data.GetString('YueBaoDetailedInfo_2'),GameData.YueBaoInfo.DetailedInfo[i].InfoTable.NDay)
            else
                --Item.transform:Find('Mode'):GetComponent('Text').text = "(转到余额宝)"
                Item.transform:Find('Mode'):GetComponent('Text').text = string.format(data.GetString('YueBaoDetailedInfo_3'))
            end
        elseif GameData.YueBaoInfo.DetailedInfo[i].Type == 2 then
            if GameData.YueBaoInfo.DetailedInfo[i].InfoTable.Mode == 1 then
                --Item.transform:Find('Mode'):GetComponent('Text').text = "("..GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyTime.month..'月'..GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyTime.day..'日买入的'..DayTable[GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyType]..'日定存利息)'
                Item.transform:Find('Mode'):GetComponent('Text').text = string.format(data.GetString('YueBaoDetailedInfo_4'),GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyTime.month,GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyTime.day,DayTable[GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyType])
            elseif GameData.YueBaoInfo.DetailedInfo[i].InfoTable.Mode == 2 then
                --Item.transform:Find('Mode'):GetComponent('Text').text = "(卖出后按日化利率结算的利息)"
                Item.transform:Find('Mode'):GetComponent('Text').text = string.format(data.GetString('YueBaoDetailedInfo_5'))
            elseif GameData.YueBaoInfo.DetailedInfo[i].InfoTable.Mode == 3 then
                --Item.transform:Find('Mode'):GetComponent('Text').text = "(日化利率利息)"
                Item.transform:Find('Mode'):GetComponent('Text').text = string.format(data.GetString('YueBaoDetailedInfo_6'))
            end
        elseif GameData.YueBaoInfo.DetailedInfo[i].Type == 3 then
            if GameData.YueBaoInfo.DetailedInfo[i].InfoTable.Mode == 1 then
                --Item.transform:Find('Mode'):GetComponent('Text').text = "("..GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyTime.month..'月'..GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyTime.day..'日买入的'..DayTable[GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyType]..'日定存)'
                Item.transform:Find('Mode'):GetComponent('Text').text = string.format(data.GetString('YueBaoDetailedInfo_7'),GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyTime.month,GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyTime.day,DayTable[GameData.YueBaoInfo.DetailedInfo[i].InfoTable.BuyType])
            else
                --Item.transform:Find('Mode'):GetComponent('Text').text = "(转入到个人游戏账户)"
                Item.transform:Find('Mode'):GetComponent('Text').text = string.format(data.GetString('YueBaoDetailedInfo_8'))
            end
        end
    end
    GameObjectSetActive(DetailedAllImage,true)
    GameObjectSetActive(DetailedAllText,true)
    GameObjectSetActive(DetailedIntoImage,false)
    GameObjectSetActive(DetailedIntoText,false)
    GameObjectSetActive(DetailedProfitImage,false)
    GameObjectSetActive(DetailedProfitText,false)
    GameObjectSetActive(DetailedTurnOutImage,false)
    GameObjectSetActive(DetailedTurnOutText,false)
end

-- 打开明细筛选界面
function OpenDetailedOption()
    GameObjectSetActive(DetailedOption,true)
end

-- 明细界面进行筛选
function DetailedOptionButtonOnClick(Index)
    GameObjectSetActive(DetailedAllImage,false)
    GameObjectSetActive(DetailedAllText,false)
    GameObjectSetActive(DetailedIntoImage,false)
    GameObjectSetActive(DetailedIntoText,false)
    GameObjectSetActive(DetailedProfitImage,false)
    GameObjectSetActive(DetailedProfitText,false)
    GameObjectSetActive(DetailedTurnOutImage,false)
    GameObjectSetActive(DetailedTurnOutText,false)
    if Index == 0 then
        GameObjectSetActive(DetailedAllImage,true)
        GameObjectSetActive(DetailedAllText,true)
        for i = 1, #GameData.YueBaoInfo.DetailedInfo do
            if DetailedParent.transform:Find('Item'..i) ~= nil then
                DetailedParent.transform:Find('Item'..i).gameObject:SetActive(true)
            end
        end
    else
        if Index == 1 then
            GameObjectSetActive(DetailedIntoImage,true)
            GameObjectSetActive(DetailedIntoText,true)
        elseif Index == 2 then
            GameObjectSetActive(DetailedProfitImage,true)
            GameObjectSetActive(DetailedProfitText,true)
        elseif Index == 3 then
            GameObjectSetActive(DetailedTurnOutImage,true)
            GameObjectSetActive(DetailedTurnOutText,true)
        end
        for i = 1, #GameData.YueBaoInfo.DetailedInfo do
            if DetailedParent.transform:Find('Item'..i) ~= nil then
                if GameData.YueBaoInfo.DetailedInfo[i].Type == Index then
                    DetailedParent.transform:Find('Item'..i).gameObject:SetActive(true)
                else
                    DetailedParent.transform:Find('Item'..i).gameObject:SetActive(false)
                end
            end
        end
    end
end

-- 关闭明细筛选界面
function CloseDetailedOption()
    GameObjectSetActive(DetailedOption,false)
end

-- 关闭明细界面
function CloseDetailedWindow()
    GameObjectSetActive(HomepageObject,true)
    GameObjectSetActive(DetailedWindow,false)
end

-- 关闭余额宝界面
function CloseYueBao()
    -- body
    NetMsgHandler.Send_CS_Player_BindingBankCard()
    CS.WindowManager.Instance:CloseWindow('UIYuebao', false)
end

function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyYueBaoLineTime, InvestmentWindowOpen)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyYueBaoIntoGoldValue, UpdateYueBaoGoldValue)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyYueBaoBuy, OpenBuyPromptWindow)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyYueBaoMyBuyInfo, OpenMyInvestmentWindow)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyYueBaoSellOut, SuccessfulSelling)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyYueBaoDetailed, OpenDetailedWindow)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyYueBaoChangePassword, CloseChangePasswordWindow)
    HandleRefreshHallUIShowState(false)
end

function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyYueBaoLineTime, InvestmentWindowOpen)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyYueBaoIntoGoldValue, UpdateYueBaoGoldValue)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyYueBaoBuy, OpenBuyPromptWindow)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyYueBaoMyBuyInfo, OpenMyInvestmentWindow)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyYueBaoSellOut, SuccessfulSelling)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyYueBaoDetailed, OpenDetailedWindow)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyYueBaoChangePassword, CloseChangePasswordWindow)
    HandleRefreshHallUIShowState(true)
end

function Awake()
    InitializationUI()
    AddButtonHandlers()
    InitializationDataDisplay()
    local carRotation = CS.WindowManager.Instance:FindWindowNodeByName("UITwoCipher")
    if carRotation ~= nil then
        CS.WindowManager.Instance:CloseWindow('UITwoCipher', false)
    end
end

function Start()
    -- body
end

function OnDestory()
    -- body
    lua_Call_GC()
end

function Update()
    UpdateCodeCD()
end

function UpdateCodeCD()
    if not isUpdateCodeCountDown then
        return
    end
    if mValidationCD == nil then
        return
    end
    if CS.SMSManager.Instance().IsSMSCD == false then
        GameObjectSetActive(mValidationCD.gameObject, false)
        return
    end
    GameObjectSetActive(mValidationCD.gameObject, true)
    local tCountDown = math.ceil(CS.SMSManager.Instance().SMSCDTime)
    if tCountDown < 0 then
        tCountDown = 0
        isUpdateCodeCountDown = false
    end
    if mValidationCountDown ~= tCountDown then
        mValidationCountDown = tCountDown
        mValidationCD.text = lua_FormatToCountdownStyle(mValidationCountDown)
        if tCountDown == 0 then
            mValidationCD.text = ""
        end
    end
end