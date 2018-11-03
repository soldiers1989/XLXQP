local GameRuleUI = nil				-- 游戏规则UI
local GameShowUI = nil				-- 咪牌演示UI
local GameExplainUI = nil			-- 路单说明UI
local toggleText1 = nil
local toggleText2 = nil
local toggleText3 = nil


function Awake()
	GameRuleUI = this.transform:Find('Canvas/Window/GameRule')
	GameShowUI = this.transform:Find('Canvas/Window/GameShow')
	GameExplainUI = this.transform:Find('Canvas/Window/GameExplain')

	toggleText1 = this.transform:Find('Canvas/Window/ToggleGroup/GameRuleToggle/Text2').gameObject
	toggleText1:SetActive(false)
	toggleText2 = this.transform:Find('Canvas/Window/ToggleGroup/GameShowToggle/Text2').gameObject
	toggleText3 = this.transform:Find('Canvas/Window/ToggleGroup/GameExplainToggle/Text2').gameObject
	this.transform:Find('Canvas/Window/ToggleGroup/GameRuleToggle'):GetComponent("Toggle").onValueChanged:AddListener( function (isOn) OnToggle_OnValue_Changed(isOn, 1) end)
	this.transform:Find('Canvas/Window/ToggleGroup/GameShowToggle'):GetComponent("Toggle").onValueChanged:AddListener( function (isOn) OnToggle_OnValue_Changed(isOn, 2) end)
	this.transform:Find('Canvas/Window/ToggleGroup/GameExplainToggle'):GetComponent("Toggle").onValueChanged:AddListener( function (isOn) OnToggle_OnValue_Changed(isOn, 3) end)
	this.transform:Find('Canvas/Window/Title/ReturnButton'):GetComponent("Button").onClick:AddListener(ReturnButtonButtonOnClick)
	GameRuleUI.gameObject:SetActive(true)
	GameShowUI.gameObject:SetActive(false)
	GameExplainUI.gameObject:SetActive(false)
end

-- 返回按钮回调
function ReturnButtonButtonOnClick()
	CS.WindowManager.Instance:CloseWindow('UIHelp', false)
end

-- UI显示切换
function OnToggle_OnValue_Changed(isOn, page)
	toggleText1:SetActive(true);
	toggleText2:SetActive(true);
	toggleText3:SetActive(true);

	if isOn then
		GameRuleUI.gameObject:SetActive(false)
		GameShowUI.gameObject:SetActive(false)
		GameExplainUI.gameObject:SetActive(false)

		if page == 1 then
			GameRuleUI.gameObject:SetActive(true)
			toggleText1:SetActive(false);
		elseif page == 2 then
			GameShowUI.gameObject:SetActive(true)
			toggleText2:SetActive(false);
		else
			GameExplainUI.gameObject:SetActive(true)
			toggleText3:SetActive(false);
		end
	end
end
