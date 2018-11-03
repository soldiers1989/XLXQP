-- 更新日志信息
local UpdateNoticeInfo =
"　<size=48><color=#03BEDAFF>v1.2.4更新内容:</color></size>\n\n" ..
"　1.新增'新老玩家体验大礼包'\n\n" ..
"　2.优化部分游戏体验\n\n"


function Awake()
    this.transform:Find('Canvas/Window/Title/ButtonClose'):GetComponent("Button").onClick:AddListener(CloseButton_OnClick)
    this.transform:Find('Canvas/Mask'):GetComponent("Button").onClick:AddListener(CloseButton_OnClick)
    InitNoticeContent()
end

function InitNoticeContent()
    local noticeContent = this.transform:Find('Canvas/Window/Content/Notice/Viewport/Content/Text'):GetComponent("Text")
    noticeContent.text = UpdateNoticeInfo
    noticeContent.rectTransform.sizeDelta = CS.UnityEngine.Vector2(noticeContent.rectTransform.sizeDelta.x, math.max(noticeContent.preferredHeight, 600))
end

function CloseButton_OnClick()
    CS.WindowManager.Instance:CloseWindow('GameNoticeUI', false)
end