-- 全局事件定义
EventDefine =
{
    -- 玩家金币变化
    NotifyGoldUpdateEvent = "NotifyGoldUpdateEvent",
    -- 同步更新角色金币
    SyncUpdateGold = "SyncUpdateGold",
    -- 钻石更新事件
    NotifyUpdateDiamondEvent = "NotifyUpdateDiamondEvent",
    -- 房卡更新事件
    NotifyUpdateRoomCardEvent = "NotifyUpdateRoomCardEvent",
    -- 充值RMB通知
    NotifyUpdateChargeEvent = "NotifyUpdateChargeEvent",
    -- 更新大厅布局
    NotifyUpdateHallLayout = "NotifyUpdateHallLayout",
    -- 登陆成功
    NotifyLoginSuccessEvent = "NotifyLoginSuccessEvent",
    -- 玩家绑定状态更改
    NotifyUpdateIsBindAccount = "NotifyUpdateIsBindAccount",

    -- 更新房间状态
    UpdateRoomState = "UpdateRoomState",
    -- 初始化房间状态
    InitRoomState = "InitRoomState",
    -- 扑克牌可见改变
    PokerVisibleChanged = "PokerVisibleChanged",
    -- 更新游戏结果
    UpdateGameResult = "UpdateGameResult",
    -- 某张牌发牌结束
    DealOnePokerEnd = "DealOnePokerEnd",
    -- 更新统计信息
    UpdateStatistics = "UpdateStatistics",
    -- 更新统计信息
    UpdateStatistics_New8 = "UpdateStatistics_New8",
    -- 更新押注金额
    UpdateBetValue = "UpdateBetValue",
    -- 更新房间人数
    UpdateRoleCount = "UpdateRoleCount",
    -- 更新庄家信息
    UpdateBankerInfo = "UpdateBankerInfo",
    -- 更新押注排行榜
    UpdateBetRankList = "UpdateBetRankList",
    -- 通知赢取的金币结果
    NotifyWinGold = "NotifyWinGold",
    -- 通知停止押注
    NotifyBetEnd = "NotifyBetEnd",
    -- 刷新当前可视的大UI（主界面级别的UI）的内容
    UpdateCurrentBigUIInfo = "UpdateCurrentBigUIInfo",
    -- 更新庄家列表
    UpdateBankerList = "UpdateBankerList",
    -- 通知游戏结束
    NotifyEndGame = "NotifyEndGame",
    -- 通知添加筹码事件	
    NotifyBetResult = "NotifyBetResult",
    -- 更新邮件信息
    UpdateEmailInfo = "UpdateEmailInfo",
    updateEmailAttachment = "updateEmailAttachment",
    -- 通知角色账号信息
    NotifyEmailRoleInfo = "NotifyEmailRoleInfo",
    -- 通知邮件发送结果
    NotifySendMailResult = "NotifySendMailResult",
    -- 更新未处理的标志
    UpdateUnHandleFlag = "UpdateUnHandleFlag",
    --增加 未读的客服中心的信息
    UpdateKFZXRed="UpdateKFZXRed",
    -- 连接游戏服务器失败
    ConnectGameServerFail = "ConnectGameServerFail",
    -- 连接游戏服务器超时
    ConnectGameServerTimeOut = "ConnectGameServerTimeOut",
    -- 更新扑克牌
    UpdateHandlePoker = "UpdateHandlePoker",
    -- 通知有玩家搓牌尖叫
    NotifyCutPokerType = "NotifyCutPokerType",
    -- VIP玩家聊天泡泡
    NotifyChatPaoPao = "NotifyChatPaoPao",
    -- 玩家头像ID变化
    NotifyHeadIconChange = "NotifyHeadIconChange",
    -- 玩家昵称变化
    NotifyChangeAccountName = "NotifyChangeAccountName",
    -- 玩家语音聊天
    NotifyPlayerYuYinChat = "NotifyPlayerYuYinChat",
    -- 游客登录开关检测通知
    NotifyVisitorCheckEvent = "NotifyVisitorCheckEvent",

    -- 通知创建房间成功
    NotifyCreateRoomSuccess = "NotifyCreateRoomSuccess",
    -- 通知进入游戏房间
    NotifyEnterGameEvent = "NotifyEnterGameEvent",
    -- 回到大厅,大厅刷新
    NotifyHallUpdateEvent = "NotifyHallUpdateEvent",
    -- 更新幸运轮盘玩家中奖信息
    NotifyWheelUpdateWinInfo = "NotifyWheelUpdateWinInfo",
    --
    -- 获取幸运转盘的抽奖纪录
    NotifyWheelWinRecord = "NotifyWheelWinRecord",
    -- 更新奔驰宝马玩家中奖信息
    NotifyCarUpdateWinInfo = "NotifyCarUpdateWinInfo",
    -- 更新时时彩玩家中奖信息
    NotifySscUpdateWinInfo = "NotifySscUpdateWinInfo",
    -- 房间在线玩家列表更新
    NotifyUpdateRoomPlayerList = "NotifyUpdateRoomPlayerList",
    -- 对战房间3局换桌提示
    NotifyRoomChangeEvent = 'NotifyRoomChangeEvent',
    --排行榜刷新
    NotifyRankEvent = "NotifyRankEvent",
    -- 请求房间列表配置
    NotifRoomListRoomTyleInfo = "NotifRoomListRoomTyleInfo",
--=========================金花组局相关============================
    -- 组局厅玩家准备状态通知
    NotifyZUJUPlayerReadyStateEvent = "NotifyZUJUPlayerReadyStateEvent",
    -- 组局厅添加玩家通知
    NotifyZUJUAddPlayerEvent = "NotifyZUJUAddPlayerEvent",
    -- 组局厅删除玩家通知
    NotifyZUJUDeletePlayerEvent = "NotifyZUJUDeletePlayerEvent",
    -- 组局厅玩家下注通知
    NotifyZUJUBettingEvent = "NotifyZUJUBettingEvent",
    -- 组局厅玩家弃牌通知
    NotifyZUJUDropCardEvent = "NotifyZUJUDropCardEvent",
    -- 组局厅玩家看牌通知
    NotifyZUJULookCardEvent = "NotifyZUJULookCardEvent",
    -- 组局厅房间列表更新
    NotifyZUJURoomListUpdateEvent = "NotifyZUJURoomListUpdateEvent",
    -- 焖鸡房间在线人数更新
    NotifyMenJiRoomOnlineEvent = "NotifyMenJiRoomOnlineEvent",
    -- 焖鸡房间切换房间成功
    NotifyMenJiRoomChangeEvent = "NotifyMenJiRoomChangeEvent",
    -- 轮盘领奖结果通知
    NotifyWheelRewardEvent = "NotifyWheelRewardEvent",
    -- 服务器反馈时时彩消息
    NotifyAcceptLotteryInfo = "NotifyAcceptLotteryInfo",
    -- 发送下注信息成功
    SendTheMessageToBeSuccessful = "SendTheMessageToBeSuccessful",
    -- 服务器发送玩家押中信息
    NotifyAcceptBetVictory = "NotifyAcceptBetVictory",
    -- 组局厅服务器发送玩家金币数量
    NotZUJU_Gold_Update = "NotZUJU_Gold_Update",
    -- 金花历史房间记录事件
    NotifyHistoryRoomJHZUJUEvent = 'NotifyHistoryRoomJHZUJUEvent',

    -- 打开时时彩界面是否是开牌阶段
    NotifyOpenCard ="NotifyOpenCard",
    -- 奔驰宝马信息更新
    NotifyAcceptCarInfo = "NotifyAcceptCarInfo",
    -- 奔驰宝马切换房间状态
    NotifyNextRoomState = "NotifyNextRoomState",
    -- 奔驰宝马庄家信息更新
    NotifyAcceptCarBankerInfo = "NotifyAcceptCarBankerInfo",
    -- 奔驰宝马下注信息更新
    NotifyAcceptCarBankerBetInfo = "NotifyAcceptCarBankerBetInfo",
    -- 奔驰宝马庄家列表信息更新
    NotifyAcceptCarBankerListInfo = "NotifyAcceptCarBankerListInfo",
    -- 奔驰宝马开始抽奖
    NotifyAcceptStartTheLottery = "NotifyAcceptStartTheLottery",
    -- 奔驰宝马玩家押中
    NotifyAcceptCarInterfacePlayerBetVictory="NotifyAcceptCarInterfacePlayerBetVictory",
    -- 弹出庄家盈利界面
    NotifyAcceptCarInterfaceBankerBetVictory="NotifyAcceptCarInterfaceBankerBetVictory",
    -- 推广员抽iPhone信息更新
    NotifyAcceptIPHONE_Info = "NotifyAcceptIPHONE_Info",
    -- 推广员抽iPhone抽奖信息
    NotifyAcceptIPHONE_LotteryInfo="NotifyAcceptIPHONE_LotteryInfo",
    -- 兑换话费成功
    NotifyAccept_Exchange_Bill="NotifyAccept_Exchange_Bill",
    -- 玩家抽话费
    NotifyAccept_LuckDraw_Bill="NotifyAccept_LuckDraw_Bill",
    -- 领奖啦信息
    NotifyAcceptPrizeInfo="NotifyAcceptPrizeInfo",
    -- 玩牌抽话费任务信息
    NotifyAcceptTaskInfo="NotifyAcceptTaskInfo",
    -- 商城玩家充钱可达到VIP等级
    NotifyAcceptStoreVIP_Lv="NotifyAcceptStoreVIP_Lv",

    --=========================组局牛牛相关==============================
    -- 组局牛牛玩家准备
    NotifyNNZJPlayerReadyEvent = "NotifyNNZJPlayerReadyEvent",
    -- 组局厅添加玩家
    NotifyZJRoomAddPlayer = "NotifyZJRoomAddPlayer",
    -- 组局厅删除玩家
    NotifyZJRoomDeletePlayer = "NotifyZJRoomDeletePlayer",
    -- 通知更新组局厅房间信息
    NotifyNNRoomInfo = "NotifyNNRoomInfo",
    
    -- 通知组局厅玩家抢庄参与
    NotifyZJRoomPlayerQiangZhuang = "NotifyZJRoomPlayerQiangZhuang",
    -- 通知组局厅玩家加倍状态
    NotifyZJRoomPlayerDouble = "NotifyZJRoomPlayerDouble",
    -- 通知组局厅搓牌结果
    NotifyZJRoomPlayerCuoPai = "NotifyZJRoomPlayerCuoPai",
    -- 通知进入房间失败原因
    NotifyEnterRoonErrorResult = 'NotifyEnterRoonErrorResult',
    -- 通知牛牛历史房间记录信息
    NotifyNNHistoryRoomEvent = 'NotifyNNHistoryRoomEvent',
    -- 牛牛匹配房间在线人数
    NotifyNNPPRoomOnlineEvent = 'NotifyNNPPRoomOnlineEvent',

    --=========================红包接龙相关=============================
    --红包接龙房间列表更新
    NotifyHongBaoRoomListUpdateEvent = 'NotifyHongBaoRoomListUpdateEvent',
    --红包接龙历史关联房间更新
    NotifyHBHistoryRoomEvent = 'NotifyHBHistoryRoomEvent',
    --红包接龙新增一个玩家
    NotifyHBRoomAddPlayer = 'NotifyHBRoomAddPlayer',
    --红包接龙删除一个玩家
    NotifyHBRoomDeleteplayerPlayer = "NotifyHBRoomAddPlayer",
    --红包接龙更新结算界面显示信息
    UpdateSettlementInterfaceDisplay = "UpdateSettlementInterfaceDisplay",
    -- 红包接龙初始化玩家位置信息
    UpdatePlayerPosition="UpdatePlayerPosition",
    -- 匹配红包请求房间在线人数
    NotifyHongBaoRoomOnlineEvent = "NotifyHongBaoRoomOnlineEvent",

    --=========================推筒子相关================================
    -- 推筒子创建房间成功
    NotifyTTZCreateRoomEvent = "NotifyTTZCreateRoomEvent",
    -- 推筒子进入房间失败原因
    NotifyTTZEnterRoomEvent = 'NotifyTTZEnterRoomEvent',
    -- 推筒子添加玩家
    NotifyTTZAddPlayerEvent = "NotifyTTZAddPlayerEvent",
    -- 推筒子删除玩家
    NotifyTTZDeletePlayerEvent = "NotifyTTZDeletePlayerEvent",
    -- 推筒子玩家准备
    NotifyTTZPlayerReadyEvent = "NotifyTTZPlayerReadyEvent",
    -- 推筒子玩家抢庄参与
    NotifyTTZPlayerQiangZhuangEvent = "NotifyTTZPlayerQiangZhuangEvent",
    -- 推筒子玩家加倍状态
    NotifyTTZPlayerDoubleEvent = "NotifyTTZPlayerDoubleEvent",
    -- 推筒子看牌状态
    NotifyTTZPlayerKanPaiEvent = "NotifyTTZPlayerKanPaiEvent",

    --=========================麻将相关===============================--
    -- 麻将进入一个玩家
    NotifyMJAddPlayerEvent = "NotifyMJAddPlayerEvent",
    -- 麻将进入一个玩家
    NotifyMJDeletePlayerEvent = "NotifyMJDeletePlayerEvent",
    -- 玩家点击准备按钮
    NotifyMJZBButtonOnClick = "NotifyMJZBButtonOnClick",
    -- 玩家出牌
    NotifyMJPlayerChuPai = "NotifyMJPlayerChuPai",
    -- 玩家摸牌
    NotifyMJPlayerMoPai = "NotifyMJPlayerMoPai",
    -- 玩家碰杠胡
    NotifyMJPlayerPengPai = "NotifyMJPlayerPengPai",
    -- 更新玩家金币
    NotifyMJPlayerUpdateGold = "NotifyMJPlayerUpdateGold",
    -- 玩家排行
    NotifyMJPlayerRank = "NotifyMJPlayerRank",
    -- 房间总流水
    NotifyMJGameWater = "NotifyMJGameWater",
    -- 本局房间流水
    NotifyMJTheBureauGameWater = "NotifyMJTheBureauGameWater",
    -- 玩家认输
    NotifyMJPlayerAdmitDefeat = "NotifyMJPlayerAdmitDefeat",
    -- 有玩家被抢杠胡
    NotifyMJPlayerBQGH = "NotifyMJPlayerBQGH",
    -- 麻将玩家定缺
    NotifyMJDQButtonOnClick = "NotifyMJDQButtonOnClick",
    -- 麻将错误码反馈
    NotifyMJErrorHints = "NotifyMJErrorHints",

    --=========================丫丫语音相关===============================--
    -- 呀呀语音停止录音事件
    NotifyYYIMRecordStopEvent = "NotifyYYIMRecordStopEvent",
    -- 呀呀语音上传录音事件
    NotifyYYIMUploadFileEvent = "NotifyYYIMUploadFileEvent",
    -- 呀呀语音识别语音事件
    NotifyYYIMSpeechStopEvent = "NotifyYYIMSpeechStopEvent",
    -- 呀呀语音下载语音事件
    NotifyYYIMDownLoadFileEvent = "NotifyYYIMDownLoadFileEvent",
    -- 播放录音结束事件
    NotifyYYIMRecordFinishPlayEvent = "NotifyYYIMRecordFinishPlayEvent",
    -- 呀呀语音停止播放事件
    NotifyYYIMRecordStopPlayEvent = "NotifyYYIMRecordStopPlayEvent",
    -- 呀呀语音录音音量变化
    NotifyYYIMRecordVolumeEvent = "NotifyYYIMRecordVolumeEvent",
    -- 呀呀语音聊天通知
    NotifyYYIMChatEvent = "NotifyYYIMChatEvent",
    -- 呀呀语音请求
    NotifyYYIMChatRequestEvent = "NotifyYYIMChatRequestEvent",


    --=========================茶馆相关===============================--
    -- 通知茶馆详情反馈
    NotifyTeaInfoEvent = "NotifyTeaInfoEvent",
    -- 通知馆主有玩家申请
    NotifyTeaNewApplyEvent = "NotifyTeaNewApplyEvent",
    -- 通知茶馆成员列表信息
    NotifyTeaMemberEvent = "NotifyTeaMemberEvent",
    -- 茶馆升级成功
    NotifyTeaUpgradeEvent = "NotifyTeaUpgradeEvent",
    -- 申请列表
    NotifyTeaApplyListEvent = "NotifyTeaApplyListEvent",
    -- 馆主逐条处理申请
    NotifyTeaApplyHandleEvent = "NotifyTeaApplyHandleEvent",
    -- 馆主全部处理申请
    NotifyTeaApplyAllEvent = "NotifyTeaApplyAllEvent",
    -- 馆主提出某位成员
    NotifyTeaDelMemberEvent = "NotifyTeaDelMemberEvent",
    -- 玩家被提出茶馆通知
    NotifyTeaKickoutEvent = "NotifyTeaKickoutEvent",
    -- 玩家请求茶馆牌局列表
    NotifyTeaRoomEvent = "NotifyTeaRoomEvent",
    -- 玩家主动退出茶馆
    NotifyTeaMemberQuitEvent = "NotifyTeaMemberQuitEvent",


    --=========================邀请空闲玩家一起游戏===============================--
    -- 获取空闲玩家列表
    NotifyInviteListEvent = "NotifyInviteListEvent",
    -- 邀请发送结果事件
    NotifyInviteSuccessEvent = "NotifyInviteSuccessEvent",

    --==========================直充直兑相关=======================--
    -- 玩家获取银行信息
    NotifyPlayerBindingBankCard = "NotifyPlayerBindingBankCard",
    -- 玩家获取账单信息
    NotifyPlayerBillDetailed = "NotifyPlayerBillDetailed",
    -- 玩家绑定银行卡成功
    NotifyPlayerBindingBankCardOK = "NotifyPlayerBindingBankCardOK",
    -- 玩家获取提现界面信息
    NotifyPlayerPutForwardInfo = "NotifyPlayerPutForwardInfo",
    -- 玩家请求绑定银行卡信息
    NotifyPlayerBankiCardInfo = "NotifyPlayerBankiCardInfo",
    -- 玩家请求提现
    NotifyPlayerRequestPutForward = "NotifyPlayerRequestPutForward",
    -- 玩家请求订单信息
    NotifyOrderInformation = "NotifyOrderInformation",
    
    --==========================推广员相关 Begin=======================--
    --推广员详情通知
    NotifyAgencyEvent = "NotifyAgencyEvent",
    --推广员佣金提取事件
    NotifyAgencyCommissionEvent= "NotifyAgencyCommissionEvent",
    --推广员佣金提取详情数据
    NotifyAgencyExtractEvent = "NotifyAgencyExtractEvent",
    --推广员会员详情
    NotifyAgencyMemberEvent = "NotifyAgencyMemberEvent",
    -- 分享链接
    NotifyShareURL = "NotifyShareURL",

    --==========================推广员相关 End=======================--
    --幸运转盘选择等级
    NotifyXYZPRoomListUpdateEvent = 'NotifyXYZPRoomListUpdateEvent',

    --==========================跑的快相关=======================--
    -- 跑得快房间添加一个玩家
    NotifyPDKRoomAddPlayer = "NotifyPDKRoomAddPlayer",
    -- 跑得快玩家请求准备游戏
    NotifyPDKZJPlayerReadyEvent = "NotifyPDKZJPlayerReadyEvent",
    -- 跑得快房间删除一个玩家
    NotifyPDKDeletePlayerEvent = "NotifyPDKDeletePlayerEvent",
    -- 跑得快房间玩家请求托管
    NotifyPDKRobotEvent = "NotifyPDKRobotEvent",
    -- 跑的快玩家点击提现
    NotifyPDKPromptEvent = "NotifyPDKPromptEvent",
    -- 跑得快玩家炸弹结算通知
    NotifyPDKBombChangeGoldEvent = "NotifyPDKBombChangeGoldEvent",

    --==========================[龙虎斗]相关=======================--
    -- [龙虎斗]大厅路单统计信息更新

    --==========================[客服咨询]相关=======================--
    -- 返回 客服咨询 发送的消息
    --返回玩家发送的数据
    NotifyKFZXBackInfo= "NotifyKFZXBackInfo",
    --服务器发送数据
    NotifyKFZXSendInfo= "NotifyKFZXSendInfo",
    --玩家拉取数据
    NotifyKFZXPlayerPullInfo= "NotifyKFZXPlayerPullInfo",
    -- 获取官方信息
    NotifyKFZXOfficialInfo = "NotifyKFZXOfficialInfo",

    --服务器发来的公告 数据
    NotifyNoticeNew= "NotifyNoticeNew",
    --服务器发来的邮件 数据
    NotifyMailNew = "NotifyMailNew",

    -- ========================[蜘蛛纸牌相关] ================= -- 
    -- 充值成功
    NotifyZZZPUpdateGoldValue = "NotifyZZZPUpdateGoldValue",

    -- 请求代理充值信息
    NotifyDaiLiRechargeInfo = "NotifyDaiLiRechargeInfo",
    -- 玩家请求充值界面信息
    NotifyRechargeInterfaceInfo = "NotifyRechargeInterfaceInfo",
    -- ========================[用户协议同意]================
    -- 用户隐私协议同意
    NotifyAgreementEvent = "NotifyAgreementEvent",


    -- 刷新公告列表
    UPDATE_ADVERTISE_LIST = "update_advertise_list",
    -- 刷新公告标签
    UPDATE_ADVERTISE_NAME = "update_advertise_name",

    -- =========================[余额宝相关]================= --
    -- 余额宝首次设置密码
    NotifyYueBaoFirstPassWord = "NotifyYueBaoFirstPassWord",
    -- 玩家请求线性时间
    NotifyYueBaoLineTime = "NotifyYueBaoLineTime",
    -- 余额宝玩家存入金额成功
    NotifyYueBaoIntoGoldValue = "NotifyYueBaoIntoGoldValue",
    -- 余额宝玩家购买定存
    NotifyYueBaoBuy = "NotifyYueBaoBuy",
    -- 余额宝玩家所有购买定存信息
    NotifyYueBaoMyBuyInfo = "NotifyYueBaoMyBuyInfo",
    -- 余额宝玩家卖出成功
    NotifyYueBaoSellOut = "NotifyYueBaoSellOut",
    -- 余额宝玩家余额宝明细
    NotifyYueBaoDetailed = "NotifyYueBaoDetailed",
    -- 余额宝修改密码成功
    NotifyYueBaoChangePassword = "NotifyYueBaoChangePassword",
}