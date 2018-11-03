local  MyTransform=nil

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    MyTransform = this.transform
    --找到代理界面的Button组件
    MyTransform:Find('Canvas/Window/Title/CloseBtn'):GetComponent("Button").onClick:AddListener(CloseButtonOnclick)
    MyTransform:Find('Canvas/Window/OKButton'):GetComponent("Button").onClick:AddListener(ButtonOKOnclick)
end

--关闭该页面
function CloseButtonOnclick()
    CS.WindowManager.Instance:CloseWindow('AgentPromotion', false)
end

--关闭该界面 直接跳转到我的代理界面
function ButtonOKOnclick()
    if GameData.AgencyInfo.IsAgent ~= SALESMAN.NULL then
        GameData.RoleInfo.IsEnterTGFF = true
    end
    CS.WindowManager.Instance:CloseWindow('AgentPromotion', false)
    CS.WindowManager.Instance:OpenWindow("AgencyUI")
end