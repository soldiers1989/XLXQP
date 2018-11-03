
local UniWebView = nil


function Awake()
	AddButtonHandlers()
	ResetStoreUI()
end

function Start()
	OpenWebInterface()
end

function WindowOpened()
end

function WindowClosed()
end

function ResetStoreUI()
	UniWebView = this.transform:Find('Canvas/Window/GameObject'):GetComponent('UniWebView')
end

-- 按钮响应事件绑定
function AddButtonHandlers()
	this.transform:Find('Canvas/Window/CloseBtn'):GetComponent("Button").onClick:AddListener(CloseStoreButtonOnClick)
end

-- 拉起网页
function OpenWebInterface()
	local url = GameConfig.ZhiFuURL
	local RechargeMode = GameData.BankInformation.RechargeMode
	local RechargeAmountValue = GameData.BankInformation.RechargeAmountValue
	url = url .. "?id=" .. GameData.RoleInfo.AccountID .. "&pay_type=" .. RechargeMode .. "&amount=" .. RechargeAmountValue
	local currentPlatform = CS.Utility.GetCurrentPlatform()
	if 3 == currentPlatform then
		-- ios 平台
		UniWebView:Load(url,true)
		UniWebView:Show(false)
	elseif 2 == currentPlatform then
		-- android 平台
		UniWebView:Load(url,false)
		UniWebView:Show(false)
	else
		--window平台测试用
		CS.Utility.OpenURL(url)
	end
end

-- 关闭商城界面
function CloseStoreButtonOnClick()
	CS.WindowManager.Instance:CloseWindow('UniWebViewUI', false)
end
