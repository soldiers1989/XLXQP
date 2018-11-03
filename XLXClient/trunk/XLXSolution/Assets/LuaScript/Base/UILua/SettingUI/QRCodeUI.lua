function Awake()
	this.transform:Find('Canvas/Window/Title/ReturnButton'):GetComponent("Button").onClick:AddListener(CloseButton_OnClick)
	this.transform:Find('Canvas/Mask'):GetComponent("Button").onClick:AddListener(CloseButton_OnClick)
	this.transform:Find('Canvas/Window/Content/Button_Save'):GetComponent("Button").onClick:AddListener(Button_Save_OnClick)
	this.transform:Find('Canvas/Window/Content/Text_Name'):GetComponent("Text").text = GameData.RoleInfo.AccountName
	this.transform:Find('Canvas/Window/Content/Button_Share'):GetComponent("Button").onClick:AddListener(Button_Share_OnClick)
	this.transform:Find('Canvas/Window/Content/Text (4)').gameObject:SetActive(GameData.ShowQRCodeTips)

	this.transform:Find('Canvas/Window/Content/Image_Icon2'):GetComponent("Image"):ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.RoleInfo.AccountIcon))
end

function NotifyHeadIconChange(icon)
    -- body
    
end

function RefreshWindowData(windowData)
	local url = string.format("%s?referralsID=%d&sid=%d&referralsChannel=%s&GameID=%d",GameConfig.InviteUrl, GameData.RoleInfo.AccountID, GameData.ServerID , GameData.ChannelCode, CS.AppDefine.GameID)
	local Img = this.transform:Find('Canvas/Window/Content/RawImage'):GetComponent("RawImage")
	CS.Utility.CreateBarcode(Img, url, 256, 256)
end

function CloseButton_OnClick()
	CS.WindowManager.Instance:CloseWindow('QRCodeUI', false)
end

function Button_Save_OnClick()
	this:DelayInvoke(0.6 , function()
		CS.BubblePrompt.Show("个人二维码已保存至系统相册！", "QRCCodeUI")
	end)
	local Img = this.transform:Find('Canvas/Window/Content/RawImage'):GetComponent("RawImage")
	CS.Utility.SaveImg()
end

function Button_Share_OnClick()
	
end