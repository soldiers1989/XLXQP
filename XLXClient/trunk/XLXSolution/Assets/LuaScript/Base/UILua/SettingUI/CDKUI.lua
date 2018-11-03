function Awake()
	this.transform:Find('Canvas/Window/Bottom/ButtonClose'):GetComponent("Button").onClick:AddListener(CloseButtonOnClick)
	this.transform:Find('Canvas/Window/Bottom/ButtonOK'):GetComponent("Button").onClick:AddListener(OKButtonOnClick)
end

function WindowOpened()
	this.transform:Find('Canvas/Window/Content/CodeInput'):GetComponent("InputField").text = ''
end

-- 关闭按钮响应
function CloseButtonOnClick()
	CS.WindowManager.Instance:CloseWindow('CDKUI', false)
end

-- 确定按钮按钮
function OKButtonOnClick()
	local tcdk = this.transform:Find('Canvas/Window/Content/CodeInput'):GetComponent("InputField").text
	if #tcdk > 0 then
		NetMsgHandler.Send_CS_CDK_Reward(tcdk)
	end
	this.transform:Find('Canvas/Window/Content/CodeInput'):GetComponent("InputField").text = ''
end