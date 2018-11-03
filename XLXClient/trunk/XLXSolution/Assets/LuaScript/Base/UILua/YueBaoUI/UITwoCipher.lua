
local PassWord1 = ""
local PassWord2 = ""

function Awake()
    this.transform:Find('Canvas/Back/Close'):GetComponent('Button').onClick:AddListener(CloseButtonOnClick)
    this.transform:Find('Canvas/Back/Button'):GetComponent('Button').onClick:AddListener(OKButtonOnClick)
    this.transform:Find('Canvas/Back/InputField1'):GetComponent("InputField").onValueChanged:AddListener(InputPassWord1)
    this.transform:Find('Canvas/Back/InputField2'):GetComponent("InputField").onValueChanged:AddListener(InputPassWord2)
end

function CloseButtonOnClick()
    CS.WindowManager.Instance:CloseWindow('UITwoCipher', false)
end

function OpenYueBaoHome()
    NetMsgHandler.Send_CS_YuEBao_Info()
    CloseButtonOnClick()
end

function OKButtonOnClick()
    if PassWord1 == "" then
        CS.BubblePrompt.Show(data.GetString("请输入密码"),"UITwoCipher")
        return
    end
    if #PassWord1 < 3 then
        CS.BubblePrompt.Show(data.GetString("请输入3~8为数字和英文组合"),"UITwoCipher")
        return
    end
    if PassWord2 == "" then
        CS.BubblePrompt.Show(data.GetString("请输入二次确认密码"),"UITwoCipher")
        return 
    end
    if PassWord1 ~= PassWord2 then
        CS.BubblePrompt.Show(data.GetString("两次密码不一致"),"UITwoCipher")
        return 
    end
    NetMsgHandler.Send_CS_YueBaoPassWord(PassWord1,PassWord2)
end

function InputPassWord1(mailContent)
    PassWord1 = mailContent
end

function InputPassWord2(mailContent)
    PassWord2 = mailContent
end

function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyYueBaoFirstPassWord, OpenYueBaoHome)
end

function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyYueBaoFirstPassWord, OpenYueBaoHome)
end