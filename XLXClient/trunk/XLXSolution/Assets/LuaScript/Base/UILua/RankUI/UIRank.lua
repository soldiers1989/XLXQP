local RankType = 1

--TUDOU
local table_Cups = {};
local isPlayCupAnimation = true;
local Animation_Cup_Counter = 0
local flag_One = true;
local flag_Two = true;
local flag_Three = true;

local table_Animation = {}

local IsMusicPlay = false
local No_Object = {}
local No_HeadIcon = {}
local No_Name = {}
local No_VIP = {}
local No_Gold = {}
--TUDOU
local window_ContactAgency = nil;
local window_ContactAgency_qq = nil;
local window_ContactAgency_wechat = nil;
local window_ContactAgency_CloseBtn = nil;
local window_ContactAgency_CopyBtn1 = nil;
local window_ContactAgency_CopyBtn2 = nil;
local window_ContactAgency_Item1 = nil;
local window_ContactAgency_Item2 = nil;
local window_ContactAgency_Complain = nil;
local window_ServiceCenter = nil;
local Window_ServiceCenter_ResetBtn = nil;
local window_ServiceCenter_SubmitBtn = nil;
local window_ServiceCenter_CloseBtn = nil;
local window_ServiceCenter_Text = nil;
local complainText = "";            -- 投诉代理信息
local contactCustomerText = "";     -- 联系客服中心
local name_Agency = nil;
local qq_Agency = nil;
local wechat_Agency = nil;
local mask = nil;
local maskBtn = nil;


function Awake()
    this.transform:Find('Canvas/Window/Title/ReturnButton'):GetComponent("Button").onClick:AddListener(CloseButtonOnClick)
    this.transform:Find('Canvas/Mask'):GetComponent("Button").onClick:AddListener(CloseButtonOnClick)
    if GameData.GameState == GAME_STATE.HALL then
        --TUDOU
        mask = this.transform:Find("Canvas/Window/Mask").gameObject;
        maskBtn = this.transform:Find("Canvas/Window/Mask"):GetComponent("Button").onClick:AddListener(function()
            if window_ServiceCenter.gameObject.activeSelf then
                window_ServiceCenter.gameObject:SetActive(false);
                mask.gameObject:SetActive(false);
            end
            if window_ContactAgency.gameObject.activeSelf then
                window_ContactAgency.gameObject:SetActive(false);
                mask.gameObject:SetActive(false);
            end
        end)
        window_ContactAgency = this.transform:Find("Canvas/Window/Window_ContactAgency").gameObject;
        window_ContactAgency_qq = window_ContactAgency.transform:Find("Info/Center/Item1/Text2"):GetComponent("Text");
        window_ContactAgency_wechat = window_ContactAgency.transform:Find("Info/Center/Item2/Text2"):GetComponent("Text");
        window_ContactAgency_CloseBtn = window_ContactAgency.transform:Find("Title/Close"):GetComponent("Button");
        window_ContactAgency_CopyBtn1 = window_ContactAgency.transform:Find("Info/Center/Item1/Button"):GetComponent("Button");
        window_ContactAgency_Item1 = window_ContactAgency.transform:Find("Info/Center/Item1").gameObject;
        window_ContactAgency_Item2 = window_ContactAgency.transform:Find("Info/Center/Item2").gameObject;
        window_ContactAgency_Complain = window_ContactAgency.transform:Find("Title/ComplaintDaiLi"):GetComponent("Button");
        window_ServiceCenter = this.transform:Find("Canvas/Window/Window_ServiceCenter").gameObject;
        window_ServiceCenter_Text = window_ServiceCenter.transform:Find("Center/InputField/Text"):GetComponent("Text");
        Window_ServiceCenter_ResetBtn = window_ServiceCenter.transform:Find("Button_Reset"):GetComponent("Button");
        window_ServiceCenter_SubmitBtn = window_ServiceCenter.transform:Find("Button_Submit"):GetComponent("Button");
        window_ServiceCenter_CloseBtn = window_ServiceCenter.transform:Find("Title/Close"):GetComponent("Button");
        window_ContactAgency_Complain.onClick:AddListener(function()
            GameObjectSetActive(window_ContactAgency,false)
            GameObjectSetActive(window_ServiceCenter,true)
            window_ServiceCenter.transform:Find('Center/InputField/Placeholder'):GetComponent("Text").text = name_Agency;

            complainText = "代理名："..name_Agency;
            if wechat_Agency ~= "" then
                complainText = complainText.."\n\n".."微信号："..wechat_Agency;
            end
            if qq_Agency ~= "" then
                complainText = complainText.."\n\n".."QQ："..qq_Agency;
            end
        end)
        window_ContactAgency_CopyBtn1.onClick:AddListener(function()
            ReplicatingShearPlate(1);
        end)
        window_ContactAgency_CopyBtn2 = window_ContactAgency.transform:Find("Info/Center/Item2/Button"):GetComponent("Button");
        window_ContactAgency_CopyBtn2.onClick:AddListener(function ()
            ReplicatingShearPlate(2);
        end)
        window_ContactAgency_CloseBtn.onClick:AddListener(function()
            window_ContactAgency:SetActive(false);
            mask.gameObject:SetActive(false);
        end)
        window_ServiceCenter_CloseBtn.onClick:AddListener(function()
            window_ServiceCenter:SetActive(false);
            mask.gameObject:SetActive(false);
        end)
        Window_ServiceCenter_ResetBtn.onClick:AddListener(ResetContactCustomerText);
        window_ServiceCenter_SubmitBtn.onClick:AddListener(SubmitCustomerText);
        window_ServiceCenter_Text = window_ServiceCenter.transform:Find("Center/InputField/Text"):GetComponent("Text");

        window_ContactAgency:SetActive(false);
        window_ServiceCenter:SetActive(false);
        mask.gameObject:SetActive(false);
    end


    -- this.transform:Find('Canvas/Window/ToggleGroup/Toggle1/Background/Checkmark').gameObject:SetActive(true);
    this.transform:Find('Canvas/Window/ToggleGroup/Toggle1'):GetComponent('Toggle').onValueChanged:AddListener(function (changeValue) RankTypeButtonOnClick(changeValue, 1) end)
    this.transform:Find('Canvas/Window/ToggleGroup/Toggle2'):GetComponent('Toggle').onValueChanged:AddListener(function (changeValue) RankTypeButtonOnClick(changeValue, 3) end)


    isPlayCupAnimation = true;
    Animation_Cup_Counter = 0;
    -- this:DelayInvoke(3, function()
    --     Switch_GetCups();
    -- end)
    

end

--清除  空的 字符串
function trim (s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))

end

-- 重置联系客服信息
function ResetContactCustomerText()
    complainText = ""
    contactCustomerText = ""
    window_ServiceCenter_Text.text = "";
    window_ServiceCenter.transform:Find('Center/InputField'):GetComponent("InputField").text = contactCustomerText
end

-- 提交客服
function SubmitCustomerText()
    contactCustomerText = name_Agency;
    complainText = window_ServiceCenter_Text.text;
    local tses = trim(contactCustomerText)
    if tses ~=""  then
        contactCustomerText = contactCustomerText .. complainText
        NetMsgHandler.Send_CS_ComplaintAgent(contactCustomerText)
        ResetContactCustomerText()
    else
        CS.BubblePrompt.Show(data.GetString("请输入有效信息"),"UIRank")
        ResetContactCustomerText()
    end
end

--复制并打开
function ReplicatingShearPlate(mType)
    local currentPlatform = CS.Utility.GetCurrentPlatform()
    local input = ""
    if 3 == currentPlatform then
        -- ios 平台
        if mType == 1 then
            --GameData.BankInformation.DaiLiInfo[DaiLiIndex].QQ = "1455469239"
            input = ""..qq_Agency;
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, input)
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_QQCHAT, input)
        else
            input = ""..wechat_Agency
            local currentPlatform = CS.Utility.GetCurrentPlatform()
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, input)
            CS.BubblePrompt.Show("复制成功", "UIRank")
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_WXCHAT, input)
        end
    elseif 2 == currentPlatform then
        -- android 平台
        if mType == 1 then
            --GameData.BankInformation.DaiLiInfo[DaiLiIndex].QQ = "1455469239"
            local inputString = "mqqwpa://im/chat?chat_type=wpa&uin="..qq_Agency;
            input = ""..qq_Agency
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, input)
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_QQCHAT, inputString)
        elseif mType == 2 then
            input = ""..wechat_Agency
            local currentPlatform = CS.Utility.GetCurrentPlatform()
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, input)
            CS.BubblePrompt.Show("复制成功", "UIRank")
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_WXCHAT, input)
        end
    else
        --window平台测试用
    end
end

-- 数据刷新
function RefreshWindowData(windowData)
    RankType = windowData
    local rankItemParent = this.transform:Find('Canvas/Window/Content/RankList/Viewport/Content')
    lua_Transform_ClearChildren(rankItemParent, true)
    local rankItem = this.transform:Find('Canvas/Window/Content/RankList/Viewport/Content/RankItem')
    rankItem.gameObject:SetActive(false)
    if windowData ~= nil and windowData >= 1 then
        if windowData <=3 then
            if IsMusicPlay == false then
                IsMusicPlay = true
                local Index =math.random(2)
            	local musicid = "OpenRank"..Index
                MusicMgr:PlaySoundEffect(musicid)
            end
        end
        if rankItemParent.transform.childCount > 0 then
            local count=rankItemParent.transform.childCount
            for i=count,0,-1 do
                if rankItemParent.transform:Find("RankItem(Clone)")~=nil then
                    local copy= rankItemParent.transform:Find("RankItem(Clone)").gameObject
                    CS.UnityEngine.Object.Destroy (copy)
                end
            end
        end
        
        --local richList = GameData.RankInfo.RichList
        local richList = RankTypeInfo(windowData)
        table_Cups = {};
        if richList ~= nil then
            local newRankItem = nil
            for key, rankInfo in ipairs(richList) do
                newRankItem = CS.UnityEngine.Object.Instantiate(rankItem)
                CS.Utility.ReSetTransform(newRankItem, rankItemParent)
                ResetRankRichListItem(newRankItem, rankInfo)
                newRankItem.gameObject:SetActive(true)
                --TUDOU
                if RankType == 1 and rankInfo.VipLevel >= 9 then
                    local tempButton = newRankItem.transform:GetComponent("Button");
                    tempButton.onClick:AddListener(function()
                        if rankInfo ~= nil then
                            OpenDialog(RankType, rankInfo);
                        end
                    end);
                    if key >= 1 and key <= 3 and  GameData.GameState == GAME_STATE.HALL then
                        local tempTopBtn = No_Object[key].transform:GetComponent("Button")
                        tempTopBtn.onClick:AddListener(function()
                            if rankInfo ~= nil then
                                OpenDialog(RankType, rankInfo);
                            end
                        end);
                    end
                else
                end
                if key >= 1 and key <= 3 then
                    table_Cups[key] = newRankItem;
                    -- local ani = {}
                    -- if newRankItem ~= nil then
                    --     ani[1] = newRankItem.transform:Find("RankFlag/Image").gameObject;
                    --     ani[2] = newRankItem.transform:Find("RankFlag/Image"):GetComponent("UGUISpriteAnimation");
                    --     ani[3] = newRankItem.transform:Find("Animation_Cup_Star").gameObject;
                    --     ani[4] = newRankItem.transform:Find("Animation_Cup_Star"):GetComponent("TweenScale")
                    --     ani[5] = newRankItem.transform:Find("Animation_Cup_Star"):GetComponent("TweenRotation");
                    --     table_Animation[key] = ani
                    -- end
                    if No_Object[key] ~= nil then
                        GameObjectSetActive(No_Object[key],true)
                        No_HeadIcon[key]:ResetSpriteByName(GameData.GetRoleIconSpriteName(rankInfo.HeadIcon))
                        No_Name[key].text = rankInfo.AccountName
                        No_VIP[key].text = tostring(rankInfo.VipLevel)
                        No_Gold[key].text = tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(rankInfo.RichValue),2))
                    end
                end
            end
        end
    end
end

function OpenDialog(tempRankType, dataTable)
    if tempRankType == 1 then
        name_Agency = dataTable.AccountName;
        window_ContactAgency_qq.text = dataTable.qq;
        qq_Agency = dataTable.qq;
        if dataTable.qq == nil or dataTable.qq == "" then
            window_ContactAgency_Item1:SetActive(false);
        else
            window_ContactAgency_Item1:SetActive(true);
        end
        window_ContactAgency_wechat.text = dataTable.wechat;
        wechat_Agency = dataTable.wechat;
        if dataTable.wechat == nil or dataTable.wechat == "" then
            window_ContactAgency_Item2:SetActive(false);
        else
            window_ContactAgency_Item2:SetActive(true);
        end
        window_ContactAgency:SetActive(true);
        mask.gameObject:SetActive(true);
    end
end

-- 排行榜信息
function RankTypeInfo(windowData)
    if windowData == 1 then
        return GameData.RankInfo.CaiFuRank
    elseif windowData == 2 then
        return GameData.RankInfo.ChongZhiRank
    elseif windowData == 3 then
        return GameData.RankInfo.RiZhuanRank
    elseif windowData == 4 then
        return GameData.RankInfo.TiXianRank
    elseif windowData == 5 then
        return GameData.RankInfo.LhtRank
    elseif windowData == 6 then
        return GameData.RankInfo.JhRank
    elseif windowData == 7 then
        return GameData.RankInfo.NnRank
    elseif windowData == 8 then
        return GameData.RankInfo.TtzRank
    elseif windowData == 9 then
        return GameData.RankInfo.HbRank
    elseif windowData == 10 then
        return GameData.RankInfo.LhdRank
    elseif windowData == 11 then
        return GameData.RankInfo.BjlRank
    elseif windowData == 12 then
        return GameData.RankInfo.SscRank
    elseif windowData == 13 then
        return GameData.RankInfo.BcbmRank
    elseif windowData == 14 then
        return GameData.RankInfo.PdkRank
    elseif windowData == 21 then
        return GameData.RankInfo.DaiLiRiBang
    elseif windowData == 22 then
        return GameData.RankInfo.DaiLiZhouBang
    elseif windowData == 23 then
        return GameData.RankInfo.DaiLiYueBang
    end
end

-- 关闭按钮响应
function CloseButtonOnClick()
    if RankType <= 3 then
        CS.WindowManager.Instance:CloseWindow('UIRank', false)
    else
        if RankType == 14 then
            CS.WindowManager.Instance:CloseWindow('PDKRank', false)
        else
            CS.WindowManager.Instance:CloseWindow('UIRoomRank', false)
        end
    end
    GameData.RankInfo.RichList={}
end

-- 刷新排行榜数据
function ResetRankRichListItem(rankItem, rankInfo)
    -- Switch_GetCups();
    if rankInfo.RankID > 3 then
        rankItem:Find('RankBg').gameObject:SetActive(true)
        rankItem:Find('RankID'):GetComponent("Text").text = tostring(rankInfo.RankID)
        rankItem:Find('RankID').gameObject:SetActive(true)
        rankItem:Find('RankFlag').gameObject:SetActive(false)
    else
        rankItem:Find('RankFlag'):GetComponent("Image"):ResetSpriteByName("sprite_No".. rankInfo.RankID)
        rankItem:Find('RankID').gameObject:SetActive(false)
        rankItem:Find('RankBg').gameObject:SetActive(false)
        rankItem:Find('RankFlag').gameObject:SetActive(true)
    end
    -- rankItem:Find('AccountID'):GetComponent("Text").text = "ID:" .. tostring(rankInfo.AccountID)
    rankItem:Find('ItemBack').gameObject:SetActive(lua_Math_Mod(rankInfo.RankID, 2) == 1)
    rankItem:Find('AccountName'):GetComponent("Text").text = rankInfo.AccountName
    if RankType == 2 then
        rankItem:Find('RichValue'):GetComponent("Text").text = tostring(lua_GetPreciseDecimal(rankInfo.RichValue,2))
    else
        rankItem:Find('RichValue'):GetComponent("Text").text = tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(rankInfo.RichValue),2))
    end
    
    rankItem:Find('HeadIcon/VipLevel/Value'):GetComponent("Text").text = tostring(rankInfo.VipLevel);
    local tHeadIcon = rankItem:Find('HeadIcon'):GetComponent("Image")

    tHeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(rankInfo.HeadIcon))
end

function RankTypeButtonOnClick(changeValue, rankType)
    -- this.transform:Find('Canvas/Window/ToggleGroup/Toggle1/Text2').gameObject:SetActive(true);
    -- this.transform:Find('Canvas/Window/ToggleGroup/Toggle2/Text2').gameObject:SetActive(true);
    if rankType == 1 then
        this.transform:Find('Canvas/Window/ToggleGroup/Toggle1/Background/Checkmark').gameObject:SetActive(true);
        this.transform:Find('Canvas/Window/ToggleGroup/Toggle2/Background/Checkmark').gameObject:SetActive(false);
    elseif rankType == 3 then
        this.transform:Find('Canvas/Window/ToggleGroup/Toggle1/Background/Checkmark').gameObject:SetActive(false);
        this.transform:Find('Canvas/Window/ToggleGroup/Toggle2/Background/Checkmark').gameObject:SetActive(true);
    end

    if changeValue then
        if JudgmentTimeInterval(rankType) == true then
            GameData.RankInfo.RichList={}
            NetMsgHandler.SendRequestRanks(rankType)
        else
            local rankUI = nil
            if rankType <= 3 then
                rankUI = CS.WindowManager.Instance:FindWindowNodeByName("UIRank")
            elseif rankType >= 5 and rankType<21 then
                rankUI = CS.WindowManager.Instance:FindWindowNodeByName("UIRoomRank")
            elseif rankType>21 then
                
            end
            if rankUI ~= nil then
                if rankType<21 then
                    rankUI.WindowData = rankType
                end
            end
        end
    end
end

-- 是否读取本地排行榜信息
function JudgmentTimeInterval(windowData)
    if windowData == 1 then
        if GameData.RankInfo.CaiFuRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.CaiFuRankTime >= 60 then
            return true
        end
    elseif windowData == 2 then
        if GameData.RankInfo.ChongZhiRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.ChongZhiRankTime >= 60 then
            return true
        end
    elseif windowData == 3 then
        if GameData.RankInfo.RiZhuanRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.RiZhuanRankTime >= 60 then
            return true
        end
    elseif windowData == 4 then
        if GameData.RankInfo.TiXianRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.TiXianRankTime >= 60 then
            return true
        end
    elseif windowData == 5 then
        if GameData.RankInfo.LhtRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.LhtRankTime >= 60 then
            return true
        end
    elseif windowData == 6 then
        if GameData.RankInfo.JhRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.JhRankTime >= 60 then
            return true
        end
    elseif windowData == 7 then
        if GameData.RankInfo.NnRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.NnRankTime >= 60 then
            return true
        end
    elseif windowData == 8 then
        if GameData.RankInfo.TtzRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.TtzRankTime >= 60 then
            return true
        end
    elseif windowData == 9 then
        if GameData.RankInfo.HbRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.HbRankTime >= 60 then
            return true
        end
    elseif windowData == 10 then
        if GameData.RankInfo.LhdRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.LhdRankTime >= 60 then
            return true
        end
    elseif windowData == 11 then
        if GameData.RankInfo.BjlRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.BjlRankTime >= 60 then
            return true
        end
    elseif windowData == 12 then
        if GameData.RankInfo.SscRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.SscRankTime >= 60 then
            return true
        end
    elseif windowData == 13 then
        if GameData.RankInfo.BcbmRankTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.BcbmRankTime >= 60 then
            return true
        end
    elseif windowData == 21 then
        if GameData.RankInfo.DaiLiRiBangTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.DaiLiRiBangTime >= 60 then
            return true
        end
    elseif windowData == 22 then
        if GameData.RankInfo.DaiLiZhouBangTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.DaiLiZhouBangTime >= 60 then
            return true
        end
    elseif windowData == 23 then
        if GameData.RankInfo.DaiLiYueBangTime == 0 then
            return true
        end
        local time1 = os.time()
        if time1 - GameData.RankInfo.DaiLiYueBangTime >= 60 then
            return true
        end
    end
    return false
end


---------_________TUDOU_________---------

local Time = CS.UnityEngine.Time
function Update()
    
end