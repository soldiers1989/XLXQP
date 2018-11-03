--Export by excel config file, don't modify this file!
--[[
ID(Column[A] Type[int] Desc[序号]
EXCHANGE_GOLD(Column[N] Type[array] Desc[钻石兑换金币配置]
EXCHANGE_ROOMCARD(Column[O] Type[array] Desc[钻石兑换房卡配置]
EMAIL_GIFT_GOLD(Column[AA] Type[array] Desc[邮件赠送金币上下限]
PLAYER_GOLD_ALERT(Column[AC] Type[int] Desc[玩家携带金币警戒值]
PLAYER_GOLD_LIMIT(Column[AD] Type[int] Desc[玩家携带金币极限值]
CHAT_PAOPAO_COOL_TIME(Column[AE] Type[int] Desc[发言泡泡冷却时间]
CHAT_PAOPAO_SHOW_TIME(Column[AF] Type[int] Desc[发言泡泡显示时间]
CHANGE_NAME_COST(Column[AL] Type[int] Desc[改名收取费用]
URL_NAME(Column[AM] Type[string] Desc[后台网站域名地址]
ROLE_ICON_MAX(Column[AN] Type[int] Desc[玩家Icon最大数量]
VOICE_INTERVAL(Column[AP] Type[int] Desc[语音冷却间隔时间]
DEALER_PAOPAO_MAX(Column[AQ] Type[int] Desc[荷官泡泡语言计数]
CHIP_VALUE(Column[AR] Type[map] Desc[筹码对应的值]
DEALER_PAOPAO_RATE(Column[AS] Type[int] Desc[荷官泡泡发言概率(0~100)%]
CUT_OUT_RETURN_LOGIN_TIME(Column[AT] Type[int] Desc[切出时长退回登陆(秒)]
GOLD_TO_RMB_RATE(Column[AU] Type[int] Desc[金币和人民币兑换比]
VALID_DECIMAL(Column[AV] Type[int] Desc[有效小数]
CUT_OUT_CAN_ENTER_ROOM_TIME(Column[AW] Type[int] Desc[切回游戏能进入房间的时限]
NN_ZUJU_BET(Column[BD] Type[array] Desc[（牛牛组局厅）底注上下限]
NN_ZUJU_ADMISSION(Column[BE] Type[int] Desc[（牛牛组局厅）入场要求底注倍数]
NN_ZUJU_COMPENSATE(Column[BF] Type[map] Desc[（牛牛组局厅）赔率]
NN_ZUJU_ROOM_NAME_SUFFIX(Column[BG] Type[string] Desc[（牛牛组局厅）房间名默认后缀]
NN_ZUJU_JIABEI(Column[BH] Type[int] Desc[（牛牛组局厅）默认最大牌型赔率最高倍数]
NN_ZUJU_BET_MIN(Column[BI] Type[int] Desc[(牛牛组局)下注最小倍数]
NN_ZUJU_BET_MAX(Column[BJ] Type[int] Desc[(牛牛组局)下注最大倍数]
HB_TIME(Column[BL] Type[array] Desc[(红包接龙)各阶段时间]
NN_BET_GUDING(Column[BM] Type[array] Desc[(牛牛)固定倍率]
NNQZ_ROOM_TIME(Column[BN] Type[map] Desc[(牛牛组局厅)抢庄模式各阶段时间]
TTZ_BET_MIN(Column[BO] Type[int] Desc[(推筒子)下注最小倍数:浮动]
TTZ_BET_MAX(Column[BP] Type[int] Desc[(推筒子)下注最大倍数:浮动]
TTZ_BET_GUDING(Column[BQ] Type[array] Desc[(推筒子)固定倍率]
TTZ_ROOM_TIME(Column[BR] Type[map] Desc[(推筒子)各阶段时间]
TTZ_JIABEI(Column[BS] Type[int] Desc[（推筒子）默认最大牌型赔率最高倍数]
TTZ_COMPENSATE(Column[BT] Type[map] Desc[（推筒子）各种牌型赔率]
MJ_ROOM_TIME(Column[BU] Type[array] Desc[(麻将)各阶段时间]
LHD_ROOM_TIME(Column[BV] Type[array] Desc[（龙虎斗)各阶段时间]
BJL_ROOM_TIME(Column[BX] Type[map] Desc[(百家乐)各阶段时间]
CG_CREATE_VIP(Column[BZ] Type[int] Desc[茶馆创建所需vip等级]
CG_LEVEL_UP_VIP(Column[CA] Type[int] Desc[茶馆升级所需vip等级]
CG_LEVEL_UP_MEMBER(Column[CB] Type[int] Desc[茶馆升级所需成员人数]
RECHARGE_AMOUNT_VALUE_MIN(Column[CC] Type[int] Desc[充值金额最低下线]
RECHARGE_AMOUNT_VALUE_MAX_0(Column[CD] Type[int] Desc[支付宝充值金额最大上线]
RECHARGE_AMOUNT_VALUE_MAX_1(Column[CE] Type[int] Desc[微信充值金额最大上线]
RECHARGE_AMOUNT_VALUE_MAX_2(Column[CF] Type[int] Desc[银行卡充值金额最大上线]
RECHARGE_AMOUNT_VALUE_MAX_3(Column[CG] Type[int] Desc[QQ钱包充值金额最大上线]
RECHARGE_AMOUNT_VALUE_MAX_4(Column[CH] Type[int] Desc[网银充值金额最大上线]
WITHDRAW_MONEY_VALUE_MIN(Column[CI] Type[int] Desc[提现金额最低下限]
WITHDRAW_MONEY_VALUE_MAX(Column[CJ] Type[int] Desc[提现金额最大上限]
PDK_ROOM_TIME(Column[CK] Type[map] Desc[(跑得快)各阶段时间]
HeadIconMan(Column[CL] Type[array] Desc[玩家头像性别_男]
HeadIconWoman(Column[CM] Type[array] Desc[玩家头像性别_女]
URL_OfficialWebsite(Column[CR] Type[string] Desc[官网链接]
WealthQQ(Column[CS] Type[string] Desc[财富QQ]
OfficialQQ(Column[CT] Type[string] Desc[官方QQ]
OfficialWX(Column[CU] Type[string] Desc[官方微信]
HallRoomTypeUpdateTime(Column[CW] Type[int] Desc[大厅按钮布局按钮刷新时间]
]]--

data.PublicConfig =
{
    EXCHANGE_GOLD = { 10, 10000 },
    EXCHANGE_ROOMCARD = { 10, 1 },
    EMAIL_GIFT_GOLD = { 10, 100000 },
    PLAYER_GOLD_ALERT = 4500000,
    PLAYER_GOLD_LIMIT = 5000000,
    CHAT_PAOPAO_COOL_TIME = 3,
    CHAT_PAOPAO_SHOW_TIME = 3,
    CHANGE_NAME_COST = 100,
    URL_NAME = "jhysz.bk.changlaith.com/login.php",
    ROLE_ICON_MAX = 16,
    VOICE_INTERVAL = 10,
    DEALER_PAOPAO_MAX = 4,
    CHIP_VALUE = { [1] = 1, [2] = 5, [3] = 10, [4] = 50, [5] = 100, [6] = 500, [7] = 1000, [8] = 5000, [9] = 10000, [10] = 50000, [11] = 10000000, [12] = 50000000 },
    DEALER_PAOPAO_RATE = 20,
    CUT_OUT_RETURN_LOGIN_TIME = 300,
    GOLD_TO_RMB_RATE = 10000,
    VALID_DECIMAL = 2,
    CUT_OUT_CAN_ENTER_ROOM_TIME = 60,
    NN_ZUJU_BET = { 10000, 10000000000000 },
    NN_ZUJU_ADMISSION = 50,
    NN_ZUJU_COMPENSATE = { [0] = 1, [1] = 2, [2] = 2, [3] = 2, [4] = 3, [5] = 3, [6] = 3, [7] = 4, [8] = 4, [9] = 4, [10] = 5 },
    NN_ZUJU_ROOM_NAME_SUFFIX = "俱乐部",
    NN_ZUJU_JIABEI = 5,
    NN_ZUJU_BET_MIN = 5,
    NN_ZUJU_BET_MAX = 20,
    HB_TIME = { 5, 10, 17, 7 },
    NN_BET_GUDING = { 5, 10, 15, 20 },
    NNQZ_ROOM_TIME = { [1] = 0, [2] = 5, [3] = 3, [4] = 4, [5] = 6, [6] = 1, [7] = 3, [8] = 6, [9] = 2, [10] = 8, [11] = 2, [12] = 6 },
    TTZ_BET_MIN = 2,
    TTZ_BET_MAX = 200,
    TTZ_BET_GUDING = { 2, 5, 10, 20 },
    TTZ_ROOM_TIME = { [0] = 0, [1] = 5, [2] = 3, [3] = 6, [4] = 1, [5] = 3, [6] = 5, [7] = 2, [8] = 6, [9] = 2, [10] = 6 },
    TTZ_JIABEI = 5,
    TTZ_COMPENSATE = { [1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5 },
    MJ_ROOM_TIME = { 2, 2, 8, 3, 16, 8, 2, 3, 7, 1, 1, 1 },
    LHD_ROOM_TIME = { 1, 4, 3, 18, 2, 9 },
    BJL_ROOM_TIME = { [1] = 1, [2] = 4, [3] = 3, [4] = 18, [5] = 5, [6] = 8 },
    CG_CREATE_VIP = 6,
    CG_LEVEL_UP_VIP = 8,
    CG_LEVEL_UP_MEMBER = 50,
    RECHARGE_AMOUNT_VALUE_MIN = 10,
    RECHARGE_AMOUNT_VALUE_MAX_0 = 4999,
    RECHARGE_AMOUNT_VALUE_MAX_1 = 199,
    RECHARGE_AMOUNT_VALUE_MAX_2 = 4999,
    RECHARGE_AMOUNT_VALUE_MAX_3 = 999,
    RECHARGE_AMOUNT_VALUE_MAX_4 = 4999,
    WITHDRAW_MONEY_VALUE_MIN = 100,
    WITHDRAW_MONEY_VALUE_MAX = 100000,
    PDK_ROOM_TIME = { [1] = 5, [2] = 1, [3] = 3, [4] = 3, [5] = 20, [6] = 2, [7] = 15 },
    HeadIconMan = { 1, 2, 3, 4, 5, 6, 7, 8 },
    HeadIconWoman = { 9, 10, 11, 12, 13, 14, 15, 16 },
    URL_OfficialWebsite = "www.889527.com",
    WealthQQ = "931666699",
    OfficialQQ = "官方 QQ:123456789",
    OfficialWX = "官方微信:9527YLC",
    HallRoomTypeUpdateTime = 300,
}

