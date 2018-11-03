local closeBtn = nil
local confirmButton = nil
local buttonLabel = nil
local advertiseImage = nil
local textContent = nil

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    --各个按键
    closeBtn = this.transform:Find('Canvas/Window/Notice/CloseBtn'):GetComponent("Button").onClick:AddListener(CloseBtnOnclick)
    confirmButton = this.transform:Find('Canvas/Window/ConfirmButton'):GetComponent("Button").onClick:AddListener(ConfirmButtonOnclick)
    buttonLabel = this.transform:Find('Canvas/Window/ConfirmButton/OKText'):GetComponent("Text")
    buttonLabel.text = ""
    advertiseImage = this.transform:Find('Canvas/Window/Image'):GetComponent("Image")
    textContent = this.transform:Find('Canvas/Window/Text'):GetComponent("Text")
end

--关闭公告
function CloseBtnOnclick ()
    CS.WindowManager.Instance:CloseWindow("Notice",false)
end

--确认
function ConfirmButtonOnclick ()
    CS.WindowManager.Instance:CloseWindow("Notice",false)
    if GameData.NoticeGotoID ~= "0" and GameData.NoticeGotoID ~= "" then
        CS.WindowManager.Instance:OpenWindow(GameData.NoticeGotoID)
    end
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()

end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()

end

-- 对应脚本的刷新数据方法
function RefreshWindowData(windowData)

end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    if GameData.NoticeContent == nil or GameData.NoticeContent == "" then
		textContent.text = ""
        local imageUrl = GameConfig.AdvertiseContentUrl..GameData.NoticeImageID..".jpg"
        this:StartCoroutine(advertiseImage:ResetSpriteByRemoteUrlOrLocal(imageUrl, "", true))
    else
        textContent.text = GameData.NoticeContent
    end

    if GameData.NoticeGotoID == "0" or GameData.NoticeGotoID == "" then
        buttonLabel.text = "确定"
    else
        buttonLabel.text = "去看看"
    end
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()

end