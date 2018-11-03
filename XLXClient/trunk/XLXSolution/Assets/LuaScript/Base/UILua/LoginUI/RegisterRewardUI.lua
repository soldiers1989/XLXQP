local MyTransform = nil

-- 确认登录
function OnCloseBtnClick()
    CloseUI()
end

-- 注册账号
function OnRegisterBtnClick()
    GameData.BankInformation.IsOpenBind = true
    CS.WindowManager.Instance:OpenWindow("UIPutForward")
    CloseUI()
end

-- 已有账号登录
function OnLoginBtnClick()
    CS.WindowManager.Instance:OpenWindow("UserReturn")
    CloseUI()
end

function CloseUI()
    CS.WindowManager.Instance:CloseWindow('RegisterRewardUI', false)
end

function Awake()
    MyTransform = this.transform
    MyTransform:Find('Canvas/Mask'):GetComponent("Button").onClick:AddListener(OnCloseBtnClick)
    MyTransform:Find('Canvas/Image/RegisterBtn'):GetComponent("Button").onClick:AddListener(OnRegisterBtnClick)
    MyTransform:Find('Canvas/Image/LoginBtn'):GetComponent("Button").onClick:AddListener(OnLoginBtnClick)
    MyTransform:Find('Canvas/Image/LoginBtn').gameObject:SetActive(GameData.RoleInfo.IsUserReturn)
end