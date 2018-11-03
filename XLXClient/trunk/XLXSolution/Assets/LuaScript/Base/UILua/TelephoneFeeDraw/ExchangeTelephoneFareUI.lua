
function  Awake()

    -- 获取到关闭按钮
    this.transform:Find('Canvas/Window/Title/ButtonClose'):GetComponent("Button").onClick:AddListener(CloseUI)
     --打开商城按钮
     this.transform:Find('Canvas/Window/Button/Gold'):GetComponent("Button").onClick:AddListener(StoreButtonOnClick)
     --获取到关闭恭喜界面按钮
     this.transform:Find('Canvas/Window/RewardImage/MaskImage'):GetComponent("Button").onClick:AddListener(CloseCongratulationsInterface)
     -- 兑换按钮
     for index=1,9 do
        this.transform:Find('Canvas/Window/ExchangeButton/Viewport/Content/Prize'..index..'/Button'):GetComponent("Button").onClick:AddListener(function() ExchangeButtonOnClick(index) end)
     end
     HandleInfo()
     --NetMsgHandler.Send_CS_Exchange_Bill_Info()
end

--响应关闭按钮
function CloseUI()
    PlaySoundEffect('2')
    CS.WindowManager.Instance:CloseWindow("UIExchangeTelephoneFare",false)
end

-- 处理配置相关信息
function HandleInfo()
    PlayerGold()
    PlayerTelephoneRate()
end

-- 玩家金币
function PlayerGold()
    local Gold = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount))
    this.transform:Find('Canvas/Window/Button/Gold/Number'):GetComponent("Text").text=""..Gold
end

-- 玩家话费 Player
function PlayerTelephoneRate()
    local TelephoneRate = GameConfig.GetFormatColdNumber(GameData.ExchangeTelephoneFareInfo.PlayerTelephoneRate)
    print("话费"..TelephoneRate)
    this.transform:Find('Canvas/Window/Button/TelephoneRate/Number'):GetComponent("Text").text=lua_NumberToStyle1String(TelephoneRate)
end

-- 响应兑换按钮
function ExchangeButtonOnClick(index)
    PlaySoundEffect('2')
    GameData.ExchangeTelephoneFareInfo.ButtonIndex=index
    NetMsgHandler.Send_CS_Exchange_Bill()
end

-- 响应商场按钮点击事件
function StoreButtonOnClick()
    GameConfig.OpenStoreUI()
end
-- 音效播放
function PlaySoundEffect(musicid)
    MusicMgr:PlaySoundEffect(musicid)
end

-- 弹出恭喜获得页面
function CongratulationsInterface()
    PlaySoundEffect('game_win')
    local index = GameData.ExchangeTelephoneFareInfo.ButtonIndex
    --local info = GameData.ExchangeTelephoneFareInfo.GoodsName[index]
    local info = data.MenjitaskConfig.CALLS_GOODS_NAME[index]
    if index ~= 1 then
        this.transform:Find('Canvas/Window/RewardImage/Info'):GetComponent("Text").text="您获得一个<color=#00FF00>"..info.."</color>，邮件查看详情"
    else
        this.transform:Find('Canvas/Window/RewardImage/Info'):GetComponent("Text").text="您获得<color=#00FF00>"..info.."</color>"
    end
    this.transform:Find('Canvas/Window/RewardImage').gameObject:SetActive(true)
    PlayerTelephoneRate()
end

-- 关闭恭喜获得界面
function CloseCongratulationsInterface()
    this.transform:Find('Canvas/Window/RewardImage').gameObject:SetActive(false)
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarInfo, HandleInfo)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAccept_Exchange_Bill, CongratulationsInterface)-- 兑换话费成功
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyGoldUpdateEvent,PlayerGold)    --更新玩家金币数量
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarInfo, HandleInfo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAccept_Exchange_Bill, CongratulationsInterface)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyGoldUpdateEvent, PlayerGold)
end