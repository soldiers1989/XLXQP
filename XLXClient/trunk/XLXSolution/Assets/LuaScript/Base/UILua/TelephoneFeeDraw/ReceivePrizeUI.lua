
local Small = nil
local Middle = nil
local Large = nil

function  Awake()
    --知道按钮
    this.transform:Find('Canvas/PrizeInfo/PrizePicture/Small/Know_Button'):GetComponent("Button").onClick:AddListener(KonwButtonOnClick)
    this.transform:Find('Canvas/PrizeInfo/PrizePicture/Middle/Know_Button'):GetComponent("Button").onClick:AddListener(KonwButtonOnClick)
    this.transform:Find('Canvas/PrizeInfo/PrizePicture/Large/Know_Button'):GetComponent("Button").onClick:AddListener(KonwButtonOnClick)

    -- 兑换按钮
    this.transform:Find('Canvas/PrizeInfo/PrizePicture/Small/Exchange_Button'):GetComponent("Button").onClick:AddListener(ExchangeButtonOnClick)
    this.transform:Find('Canvas/PrizeInfo/PrizePicture/Middle/Exchange_Button'):GetComponent("Button").onClick:AddListener(ExchangeButtonOnClick)
    this.transform:Find('Canvas/PrizeInfo/PrizePicture/Large/Exchange_Button'):GetComponent("Button").onClick:AddListener(ExchangeButtonOnClick)

    Small=this.transform:Find('Canvas/PrizeInfo/PrizePicture/Small').gameObject
    Middle=this.transform:Find('Canvas/PrizeInfo/PrizePicture/Middle').gameObject
    Large=this.transform:Find('Canvas/PrizeInfo/PrizePicture/Large').gameObject
    HandleUIDefaultShow()
end

-- UI默认状态处理
function HandleUIDefaultShow()

    Small:SetActive(false)
    Middle:SetActive(false)
    Large:SetActive(false)

    if  GameData.ExchangeTelephoneFareInfo.ConvertibilityState == 1 then
        this.transform:Find('Canvas/PrizeInfo/PrizePicture/Small/Have/Text'):GetComponent("Text").text=""..string.format("%0.1f",GameConfig.GetFormatColdNumber(GameData.ExchangeTelephoneFareInfo.PlayerTelephoneRate))
        this.transform:Find('Canvas/PrizeInfo/PrizePicture/Small/Lack/Bill'):GetComponent("Text").text=""..string.format("%0.1f",GameConfig.GetFormatColdNumber(GameData.ExchangeTelephoneFareInfo.LackBill))
        this.transform:Find('Canvas/PrizeInfo/PrizePicture/Small/Lack/Text'):GetComponent("Text").text=""..string.format(data.GetString("CueOfExchange_1"),GameData.ExchangeTelephoneFareInfo.CannotConvertibility)
        Small:SetActive(true)
    elseif GameData.ExchangeTelephoneFareInfo.ConvertibilityState == 2 then
        this.transform:Find('Canvas/PrizeInfo/PrizePicture/Middle/Have/Text'):GetComponent("Text").text=""..string.format("%0.1f",GameConfig.GetFormatColdNumber(GameData.ExchangeTelephoneFareInfo.PlayerTelephoneRate))
        this.transform:Find('Canvas/PrizeInfo/PrizePicture/Middle/Convertible'):GetComponent("Text").text=""..string.format(data.GetString("CueOfExchange_2"),GameData.ExchangeTelephoneFareInfo.Convertible)
        this.transform:Find('Canvas/PrizeInfo/PrizePicture/Middle/Lack/Bill'):GetComponent("Text").text=""..string.format("%0.1f",GameConfig.GetFormatColdNumber(GameData.ExchangeTelephoneFareInfo.LackBill))
        this.transform:Find('Canvas/PrizeInfo/PrizePicture/Middle/Lack/Text (1)'):GetComponent("Text").text="即可兑换 <color=#00FF00>"..GameData.ExchangeTelephoneFareInfo.CannotConvertibility.."</color>"
        Middle:SetActive(true)
    elseif GameData.ExchangeTelephoneFareInfo.ConvertibilityState == 3 then
        this.transform:Find('Canvas/PrizeInfo/PrizePicture/Large/Have/Text'):GetComponent("Text").text=""..string.format("%0.1f",GameConfig.GetFormatColdNumber(GameData.ExchangeTelephoneFareInfo.PlayerTelephoneRate))
        this.transform:Find('Canvas/PrizeInfo/PrizePicture/Large/Convertible'):GetComponent("Text").text=""..string.format(data.GetString("CueOfExchange_2"),GameData.ExchangeTelephoneFareInfo.Convertible)
        Large:SetActive(true)
    end
    
end

--响应知道按钮点击
function KonwButtonOnClick()
    PlaySoundEffect('2')
    CS.WindowManager.Instance:CloseWindow("UIReceivePrize",false)

end 

-- 音效播放
function PlaySoundEffect(musicid)
    MusicMgr:PlaySoundEffect(musicid)
end

--响应兑换按钮点击
function ExchangeButtonOnClick()
    PlaySoundEffect('2')
    CS.WindowManager.Instance:CloseWindow("UIReceivePrize",false)
    --CS.WindowManager.Instance:OpenWindow("UIExchangeTelephoneFare")
    NetMsgHandler.Send_CS_Exchange_Bill_Info()
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptPrizeInfo, HandleUIDefaultShow)
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptPrizeInfo, HandleUIDefaultShow)
end