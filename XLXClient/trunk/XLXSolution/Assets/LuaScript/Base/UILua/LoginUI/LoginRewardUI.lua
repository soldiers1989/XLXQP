local MyTransform = nil

-- 确认登录
function OnConfirmBtnClick()
    NetMsgHandler.Send_CS_NEW_REWARD()
end

function Awake()
    MyTransform = this.transform
    MyTransform:Find('Canvas/Window/ActionArea/ButtonOK'):GetComponent("Button").onClick:AddListener(OnConfirmBtnClick)
    MyTransform:Find('Canvas/Window/Content/Value'):GetComponent('Text').text = ""..data.GetString('LoginRewardPrompt')
end

function Start()

end

function OnDestroy()
    
end
