
function Awake()
    this.transform:Find('Canvas/Back/Close'):GetComponent('Button').onClick:AddListener(CloseButtonOnClick)
    this.transform:Find('Canvas/Back/Button'):GetComponent('Button').onClick:AddListener(GoBindingButtonOnClick)
end

function CloseButtonOnClick()
    CS.WindowManager.Instance:CloseWindow('UIBndingBankCard', false)
end

function GoBindingButtonOnClick()
    -- body
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPlayerBankiCardInfo,2)
    CS.WindowManager.Instance:CloseWindow('UIYuebao', false)
    CS.WindowManager.Instance:CloseWindow('UIBndingBankCard', false)
end
