local changeNameConsume = 0
function Awake()
    this.transform:Find('Canvas/Window/Title/ReturnButton'):GetComponent("Button").onClick:AddListener(CloseButton_OnClick)
    this.transform:Find('Canvas/Mask'):GetComponent("Button").onClick:AddListener(CloseButton_OnClick)
    
    this.transform:Find('Canvas/Window/Content/Menu_3/Value'):GetComponent("InputField").onEndEdit:AddListener(AccountName_OnEndEdit)
    this.transform:Find('Canvas/Window/Content/Menu_3/Modify'):GetComponent("Button").onClick:AddListener(EditAccountNameButton_OnClick)
    
    this.transform:Find('Canvas/Window/Content/Menu_4'):GetComponent("Button").onClick:AddListener(Menu_4_OnClick)
    this.transform:Find('Canvas/Window/Content/Menu_5'):GetComponent("Button").onClick:AddListener(Menu_5_OnClick)
    this.transform:Find('Canvas/Window/Content/Menu_1/RoleIcon'):GetComponent("Button").onClick:AddListener(HeadIcon_OnClick)
    this.transform:Find('Canvas/Window/Content/Menu_6/Text_ID'):GetComponent("Text").text = tostring(GameData.RoleInfo.VipLevel)
    
    this.transform:Find('Canvas/Window/Button_Change'):GetComponent("Button").onClick:AddListener(Change_OnClick)--修改
    NotifyHeadIconChange(0)
    AchievementUIOpen()

    --个人信息 增加音乐和音效
    this.transform:Find('Canvas/Window/Panel/Switch1'):GetComponent("SwitchControl").IsOn = MusicMgr.isMuteBackMusic
    this.transform:Find('Canvas/Window/Panel/Switch2'):GetComponent("SwitchControl").IsOn = MusicMgr.isMuteSoundEffect
    -- 由于 SwitchControl 状态变化会触发回调 导致开启界面就会播放音效 因此滞后于状态值设置
    this.transform:Find('Canvas/Window/Panel/Switch1'):GetComponent("SwitchControl").onValueChanged:AddListener(BackMusicSwithControl_OnValueChanged)
    this.transform:Find('Canvas/Window/Panel/Switch2'):GetComponent("SwitchControl").onValueChanged:AddListener(EffectMusicSwithControl_OnValueChanged)

    this.transform:Find('Canvas/Window/Content/Menu_2/CopyButton'):GetComponent('Button').onClick:AddListener(CopyIdButtonOnClick)
    this.transform:Find('Canvas/Window/Content/Menu_3/CopyButton'):GetComponent('Button').onClick:AddListener(CopyNameButtonOnClick)
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

-- 玩家头像变化(使用微信头像URL)
function NotifyHeadIconChange(icon)
    -- body
    local _roleIcon = this.transform:Find('Canvas/Window/Content/Menu_1/RoleIcon'):GetComponent("Image")
    _roleIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.RoleInfo.AccountIcon))
end

function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHeadIconChange, NotifyHeadIconChange)
end
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHeadIconChange, NotifyHeadIconChange)
end

--切换账号
function Change_OnClick()
    PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_WEIXIN, PLATFORM_FUNCTION_ENUM.FUNCTION_WX_LOGOUT, "logout")
    CS.WindowManager.Instance:CloseWindow('PersonalUI', false)
    GameData.HallData.SelectType = 0
    NetMsgHandler.ReturnLogin(12)
end

function CloseButton_OnClick()
    CS.WindowManager.Instance:CloseWindow('PersonalUI', false)
end

function RefreshWindowData(windowData)
    this.transform:Find('Canvas/Window/Content/Menu_2/Text_ID'):GetComponent("Text").text = tostring(GameData.RoleInfo.AccountID)
    this.transform:Find('Canvas/Window/Content/Menu_3/Text_Name'):GetComponent("Text").text = tostring(GameData.RoleInfo.AccountName)
    --this.transform:Find('Canvas/Window/Content/Menu_3/Value'):GetComponent("InputField").text = GameData.RoleInfo.AccountName

    if changeNameConsume > GameData.RoleInfo.GoldCount then
        this.transform:Find('Canvas/Window/Content/Menu_3/Modify'):GetComponent("Button").interactable = false
    else
        this.transform:Find('Canvas/Window/Content/Menu_3/Modify'):GetComponent("Button").interactable = true
    end
    RefreshCheckNameTime()
end

function HallUI_HeadIconOnClick()
    local openParam = CS.WindowNodeInitParam("PersonalUI")
    openParam.WindowData = 0
    CS.WindowManager.Instance:OpenWindow(openParam)
end

function HeadIcon_OnClick()
    -- 打开头像编辑UI
    openparam = CS.WindowNodeInitParam("PlayerIconChangeUI")
    CS.WindowManager.Instance:OpenWindow(openparam)
end

function Menu_4_OnClick()
    GameData.ShowQRCodeTips = true
    CS.WindowManager.Instance:OpenWindow("QRCodeUI")
end

function Menu_5_OnClick()
    
end

function RefreshCheckNameTime()
    local tipsContent = "修改昵称"
    changeNameConsume = data.PublicConfig.CHANGE_NAME_COST
    if changeNameConsume > 0 then
        tipsContent = tipsContent.."将消耗"..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(changeNameConsume)).."金币"
    end
    this.transform:Find('Canvas/Window/Content/Menu_3/Tips'):GetComponent("Text").text =  tipsContent

end

function AccountName_OnEndEdit(accountName)
    this.transform:Find('Canvas/Window/Content/Menu_3/Modify'):GetComponent("Button").interactable = true
    this.transform:Find('Canvas/Window/Content/Menu_3/Mask').gameObject:SetActive(true)
    CheckInputedAccountName()
end


function EditAccountNameButton_OnClick()
    this.transform:Find('Canvas/Window/Content/Menu_3/Modify'):GetComponent("Button").interactable = false
    this.transform:Find('Canvas/Window/Content/Menu_3/Mask').gameObject:SetActive(false)
    this.transform:Find('Canvas/Window/Content/Menu_3/Value'):GetComponent("InputField"):Select()
    this.transform:Find('Canvas/Window/Content/Menu_3/Value'):GetComponent("InputField"):MoveTextEnd()
end

-- 校验账号名称
function CheckInputedAccountName()
    --屏蔽字检查，如果有屏蔽字，弹出提示框提醒玩家
    local accountNameInputField = this.transform:Find('Canvas/Window/Content/Menu_3/Value'):GetComponent("InputField")
    local indexs
    local charNum
    local strReplace = ''
    local newAccountName = accountNameInputField.text
    if newAccountName == GameData.RoleInfo.AccountName then
        return
    end
    
    if newAccountName == '' then
        CS.BubblePrompt.Show(data.GetString("Change_Name_Error_5"), "MasterInfoUI")
        accountNameInputField.text = GameData.RoleInfo.AccountName
        return
    end
    
    local csharpcharNum = CS.Utility.UTF8Stringlength(newAccountName)
    local luacharNum = string.len(newAccountName)
    local zwNum = (luacharNum - csharpcharNum) / 2
    local finalNum = zwNum + csharpcharNum
    print('csharp length = ', csharpcharNum, ' luacharNum = ', luacharNum, ' zwNum = ', zwNum)
    if finalNum > 12 then
        CS.BubblePrompt.Show(data.GetString("Change_Name_Error_6"), "MasterInfoUI")
        accountNameInputField.text = GameData.RoleInfo.AccountName
        return
    end
    
    for k, v in pairs(data.MaskConfig) do
        indexs = string.find(newAccountName, v.Value)
        if indexs ~= nil then
            CS.BubblePrompt.Show(data.GetString("Change_Name_Error_4"), "MasterInfoUI")
            accountNameInputField.text = GameData.RoleInfo.AccountName
            return
        end
    end
    
    NetMsgHandler.SendModifyName(newAccountName)
end

function  AchievementUIOpen()
    this.transform:Find('Canvas/Window/Content/Menu_4').gameObject:SetActive(false)
    this.transform:Find('Canvas/Window/Content/Menu_5').gameObject:SetActive(false)
end

-- 复制ID
function CopyIdButtonOnClick()
    -- body
    local CopyString = tostring(GameData.RoleInfo.AccountID)
    local currentPlatform = CS.Utility.GetCurrentPlatform()
    PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, CopyString)
    CS.BubblePrompt.Show("复制成功", "PersonalUI")
end

-- 复制昵称
function CopyNameButtonOnClick( )
    -- body
    local CopyString = tostring(GameData.RoleInfo.AccountName)
    local currentPlatform = CS.Utility.GetCurrentPlatform()
    PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, CopyString)
    CS.BubblePrompt.Show("复制成功", "PersonalUI")
end
