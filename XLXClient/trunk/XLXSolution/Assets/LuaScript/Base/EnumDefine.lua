--- 登陆方式枚举
--- (0, 不可用，1，游客登陆，2，账号+密码，3 账号+验证码)
LOGIN_TYPE =
{
    -- 无
    NONE = 0,
    -- 游客
    VISITOR = 1,
    -- 账号+密码
    MobilePassword = 2,
    -- 账号+验证码
    MobileSMSCode = 3,
    -- 微信登录方式
    WeChat = 4,
}

-- 平台类型 （1 windows 2 android 3 ios 4 macos）
PLATFORM_TYPE =
{
    -- Windows
    PLATFORM_TOURISTS = 1,
    -- android
    PLATFORM_ANDROID = 2,
    -- IOS(iphone+pad)
    PLATFORM_IOS = 3,
    -- macos(macbook)
    PLATFORM_STANDLONE_OSX = 4,
    -- APP_STORE
    PLATFORM_APP_STORE = 150,
    -- QQ
    PLATFORM_QQ = 151,
    -- 微信
    PLATFORM_WEIXIN = 152,
    -- Alipay
    PLATFORM_ALIPAY = 153,
    -- 胜付通
    PLATFORM_SDO = 154,
}

PLATFORM_FUNCTION_ENUM =
{
    -- SDK登陆(OpenInstall)
    PLATFORM_FUNCTION_SDKREG = 1,
    -- SDK渠道ID(OpenInstall)
    PLATFORM_FUNCTION_SDKCODE= 2,
    -- SDK邀请码(自动绑定上级代理:OpenInstall)
    PLATFORM_FUNCTION_SDKINVITE = 3,
    -- SDK数据清理(绑定数据使用后需要清理)
    PLATFORM_FUNCTION_SDKCLEAR = 4,
    -- 支付
    PLATFORM_FUNCTION_PAY = 5,
    -- 调用剪切板
    PLATFORM_SHEARPLATE = 6,
    -- 跳转QQ临时会话界面
    PLATFORM_QQCHAT = 7,
    -- 跳转到微信会话
    PLATFORM_WXCHAT = 8,

    -- 微信安装检查
    FUNCTION_WX_INSTALLED = 11,
    -- 微信分享
    FUNCTION_WX_SHARE = 12,
    -- 微信分享朋友圈
    FUNCTION_WX_SHARE_PYQ = 13,
    -- 微信登录
    FUNCTION_WX_LOGIN = 14,
    -- 绑定微信
    FUNCTION_WX_BIND = 15,
    -- 微信自动登录检查
    FUNCTION_WX_AUTO_LOGIN_CHECK = 16,
    -- 微信注销(清除缓存信息)
    FUNCTION_WX_LOGOUT = 17,

}

-- 性别
SEX =
{
    BOY = 1,
    -- 男
    GIRL = 2,-- 女
}

--玩家推广类型
SALESMAN = 
{
    NULL			= 0,		-- 非推广员
    YES			    = 1,		-- 推广员
}

-- 扑克牌花色定义
Poker_Type =
{
    -- 黑桃
    Spade = 4,
    -- 红桃
    Hearts = 3,
    -- 梅花
    Club = 2,
    -- 方块
    Diamond = 1,
}

-- 扑克牌花色Icon抬头定义
Poker_Type_Define =
{
    [Poker_Type.Spade] = "Spade",
    -- 黑桃
    [Poker_Type.Hearts] = "Hearts",
    -- 红桃
    [Poker_Type.Club] = "Club",
    -- 梅花
    [Poker_Type.Diamond] = "Diamond",-- 方块
}

-- 房间类型
ROOM_TYPE =
{
    -- 大厅中心
    None = 0,
    -- 百人金花     百人房
    BRJH = 1,
    -- 焖鸡厅       五人房
    MenJi = 2,
    -- 组局厅       五人房
    ZuJu = 3,
    -- 组局牛牛     五人房
    ZuJuNN = 4,
    -- 牛牛匹配     六人房
    PiPeiNN = 5,
    -- 红包接龙     八人房
    HongBao = 6,
    -- 红包接龙     匹配场
    PPHongBao = 7,
    -- 推筒子组局
    ZuJuTTZ = 8,
    -- 推筒子匹配
    PiPeiTTZ = 9,
    -- 组局麻将
    ZuJuMaJiang = 10,
    --幸运转盘
    LuckyWheel = 11,
    --宝马奔驰
    BMWBENZ = 12,
    -- 时时彩
    SSC = 13,
    -- 匹配跑的快
    PiPeiPDK = 14,
    -- 龙虎斗
    LHDRoom = 15,
    -- 百家乐
    BJLRoom = 16,
}

-- 游戏模式(普通:2~A 激情:7~A)
GameModeEnum =
{
    -- 普通模式()
    Common = 0,
    -- 激情模式
    Passion = 1,
}

-- 房间子类型(主要用于焖鸡房间)
SubTypeEnum =
{
    -- 默认类型(保留)
    None = 0,
    -- 焖鸡新
    SubLv1 = 1,
    -- 焖鸡初
    SubLv2 = 2,
    -- 焖鸡中
    SubLv3 = 3,
    -- 焖鸡高
    SubLv4 = 4,
    -- 焖鸡大R
    SubLv5 = 5,
    -- 焖鸡极品
    SubLv6 = 6,
}

GAME_STATE =
{
    -- 更新
    UPDATE = 1,
    -- 加载
    LOADING = 2,
    -- 登陆
    LOGIN = 3,
    -- 大厅
    HALL = 4,
    -- 房间
    ROOM = 5,
 
}

-- 百人厅 房间状态
ROOM_STATE =
{
    -- 开始
    START = 1,
    -- 等待
    WAIT = 2,
    -- 洗牌
    SHUFFLE = 3,
    -- 假发牌
    FALSEDEAL = 4,
    -- 押注
    BET = 5,
    -- 发牌
    DEAL = 6,
    -- 结算
    SETTLEMENT = 7,
}

-- 百人厅 各房间状态CD时间
ROOM_TIME =
{
    [ROOM_STATE.START] = 0,
    [ROOM_STATE.WAIT] = 1,
    [ROOM_STATE.SHUFFLE] = 3,
    [ROOM_STATE.FALSEDEAL] = 5,
    [ROOM_STATE.BET] = 16,
    [ROOM_STATE.DEAL] = 2,
    [ROOM_STATE.SETTLEMENT] = 8,
}

MOVE_NOTICE_CONFIG =
{
    MOVE_SPEED = 100,
    LIST_LENGTH = 10,
    -- 小喇叭冷却时间
    SMALL_HORN_COOL_TIME = 1,
}

EMAIL_CONFIG =
{
    -- GIFT_GOLD_LOW = 500,
    -- GIFT_GOLD_HIGH = 999999,
    SEND_CONTENT_MAX = 50,
    SEND_CONTENT_MIN = 1,
    GIFT_SEND_RULE = '1. 赠送金币最低额度<color=#D8AD15>500</color>。\n\n2. 系统将从赠送金币中，抽取<color=#D8AD15>5%</color>手续费。\n\n3. VIP9级玩家赠送金币，抽取<color=#D8AD15>1%</color>手续费。\n\n4. 给VIP9玩家赠送金币，抽取<color=#D8AD15>1%</color>手续费。',
}

FEEDBACK_CONFIG =
{
    SEND_CONTENT_MAX=200,
    SEND_CONTACT_CONTENT_MAX=40,
}

CHIP_VALUE = {
    [1] = 10000,
    [2] = 50000,
    [3] = 100000,
    [4] = 500000,
    [5] = 1000000,
    [6] = 5000000,
    [7] = 10000000,
    [8] = 50000000,
    [9] = 100000000,
    [10] = 500000000,
}

-- 胜负编号
WIN_CODE =
{
    LONG = 1,
    HU = 2,
    HE = 4,
    LONGJINHUA = 8,
    LONGHUBAOZI = 16,
    HUJINHUA = 32,
}

-- 区域胜负结果码
AREA_WIN_CODE =
{
    [1] = WIN_CODE.LONGJINHUA,
    [2] = WIN_CODE.LONGHUBAOZI,
    [3] = WIN_CODE.HUJINHUA,
    [4] = WIN_CODE.LONG,
    [5] = WIN_CODE.HU,
}

-- 胜负结果转区域码
WIN_AREA_CODE =
{
    [WIN_CODE.LONGJINHUA] = 1,
    [WIN_CODE.LONGHUBAOZI] = 2,
    [WIN_CODE.HUJINHUA] = 3,
    [WIN_CODE.LONG] = 4,
    [WIN_CODE.HU] = 5,
    [WIN_CODE.HE] = 0,-- 无此条
}

-- 押注区域
BETTING =
{
    LONG_JINHUA = 1,
    -- 龙金花
    LONGHU_BAOZI = 2,
    -- 龙虎豹子
    HU_JINHUA = 3,
    -- 虎金花
    LONG = 4,
    -- 龙
    HU = 5,-- 虎
}

COMPENSATE =
{
    [BETTING.LONG_JINHUA] = 8,
    -- 龙金花赔付比例
    [BETTING.LONGHU_BAOZI] = 16,
    -- 虎豹子赔付比例
    [BETTING.HU_JINHUA] = 8,
    -- 虎金花赔付比例
    [BETTING.LONG] = 1,
    -- 龙赔付比例
    [BETTING.HU] = 1,-- 虎赔付比例
}

-- 组局厅创建房间倍率设置(底注下限,底注上，入场设定，离场设定)
CREATE_ROOM_CONSUME =
{
    [1] = { BetMin = 1, BetMax = 40, EnterLimit = 40, LeaveLimit = 10 },
    [2] = { BetMin = 5, BetMax = 200, EnterLimit = 200, LeaveLimit = 50 },
    [3] = { BetMin = 10, BetMax = 400, EnterLimit = 400, LeaveLimit = 100 },
    [4] = { BetMin = 50, BetMax = 2000, EnterLimit = 2000, LeaveLimit = 500 },
    [5] = { BetMin = 100, BetMax = 4000, EnterLimit = 4000, LeaveLimit = 1000 },
}


BRAND_TYPE =
{
    -- 散牌
    SANPAI = 1,
    -- 对子
    DUIZI = 2,
    -- 顺子
    SHUNZI = 3,
    -- 金花
    JINHUA = 4,
    -- 顺金
    SHUNJIN = 5,
    -- 豹子
    BAOZI = 6,
}

-- 邮件类型
MAIL_TYPE =
{
    SYSTEM = 1,
    PLAYER = 2,
    INVITE = 3,
    PROMOTER = 4,
    PASSWORD = 5,
    REBATE = 6,
    EXCHANGE = 7,
}

-- 玩家游戏状态
PlayerStateEnum =
{
    -- 位置空闲
    None = 0,
    -- 坐下未参与游戏
    JoinNO = 1,
    -- 参与游戏
    JoinOK = 2,
}

-- 【金花五人】房间状态
ROOM_STATE_JHWR =
{
    -- 开始(等待服务器自动开始)
    Start = 0,
    -- 等待准备
    Wait = 1,
    -- 收取底注
    SubduceBet = 2,
    -- 发牌
    Deal = 3,
    -- 下注阶段
    Betting = 4,
    -- 比牌阶段
    CardVS = 5,
    -- 结算阶段
    Settlement = 6,
}

-- 【金花五人】 房间状态CD时间
ROOM_TIME_JHWR =
{
    [ROOM_STATE_JHWR.Start] = 99,
    [ROOM_STATE_JHWR.Wait] = 5,
    [ROOM_STATE_JHWR.SubduceBet] = 2,
    [ROOM_STATE_JHWR.Deal] = 2,
    [ROOM_STATE_JHWR.Betting] = 20,
    [ROOM_STATE_JHWR.CardVS] = 4,
    [ROOM_STATE_JHWR.Settlement] = 4,
}

-- 金花明牌(看牌)下注倍率
JHMingPaiRate =
{
    [1] = 2,
    [2] = 5,
    [3] = 10,
    [4] = 20,
    [5] = 40,
}

-- 金花暗牌(焖鸡)下注倍率
JHDarkPaiRate =
{
    [1] = 1,
    [2] = 2,
    [3] = 5,
    [4] = 10,
    [5] = 20,
}



-----------------------------------------组局牛牛相关-----------------------------------

-- 【牛牛组局】房间状态
ROOM_STATE_NN =
{
    -- 开始
    START = 1,
    -- 等待
    WAIT = 2,
    -- 洗牌
    SHUFFLE = 3,
    -- 发牌
    DEAL = 4,
    -- 抢庄
    QIANG_ZHUANG = 5,
    -- 抢庄结束(客户端表现展示)
    QIANG_ZHUANG_OVER = 6,
    -- 选庄
    XUAN_ZHUANG = 7,
    -- 选择加倍
    XUAN_DOUBLE = 8,
    -- 加倍结束状态
    OVER_DOUBLE = 9,
    -- 搓牌
    CUO = 10,
    -- 结束搓牌状态
    OVER_CUO = 11,
    -- 结算
    SETTLEMENT = 12,
}

-- 牛牛组局厅玩家状态
PlayerStateEnumNN =
{
    -- 空位状态
    NULL = 0,
    -- 未参与游戏(旁观者)
    JoinNO = 1,
    -- 已经准备
    ZhunBeiOK = 2,
    -- 参与游戏
    JoinOK = 3,
    -- 抢庄
    QiangZhuangOK = 4,
    -- 不抢庄
    QiangZhuangNO = 5,
    -- 加倍
    DoubleOK = 6,
    -- 不加倍
    DoubleNO = 7,
}


------------------------------------------------红包接龙相关--------------------------------------------

-- 【红包接龙】房间状态
ROOM_STATE_HB =
{
    -- 等待
    WAIT = 1,
    -- 选庄
    XUAN_ZHUANG = 2,
    -- 发红包
    FA_HONGBAO=3,
    -- 强红包
    QIANG_HONGBAO=4,
    -- 结算
    SETTLEMENT = 5,
}

-- 红包接龙玩家状态
PlayerStateEnumHB =
{
    -- 空位状态
    NULL = 0,
    -- 未参与游戏(旁观者)
    JoinNO = 1,
    -- 参与游戏
    JoinOK = 2,
    -- 抢红包
    QiangHongBaoOK = 3,
    -- 发红包
    FaHongBaoOK = 4,
}
--红包游戏模式
HBGameModeEnum=
{
    XiaoJieLong=1,
    DaJieLong=2,
}

-----------------------------------------组局推筒子相关-----------------------------------

-- 【推筒子组局】房间状态
ROOM_STATE_TTZ =
{
    -- 等待开始
    START = 0,
    -- 玩家准备
    READY = 1,
    -- 发牌
    DEAL = 2,
    -- 抢庄
    QIANG_ZHUANG = 3,
    -- 抢庄结束(客户端表现展示)
    QIANG_ZHUANG_OVER = 4,
    -- 确认庄家
    SET_ZHUANG = 5,
    -- 选择加倍
    XUAN_DOUBLE = 6,
    -- 加倍结束状态
    OVER_DOUBLE = 7,
    -- 看牌阶段
    KANPAI = 8,
    -- 结束看牌状态
    OVER_KANPAI = 9,
    -- 结算
    SETTLEMENT = 10,
}

-- 【推筒子组局】玩家状态
PlayerStateEnumTTZ =
{
    -- 空位状态
    NULL = 0,
    -- 坐下未参与游戏(旁观者)
    LookOn = 1,
    -- 已经准备
    Ready = 2,
    -- 参与游戏
    JoinOK = 3,
    -- 抢庄
    QZOK = 4,
    -- 不抢庄
    QZNO = 5,
    -- 加倍
    JiaBeiOK = 6,
    -- 不加倍
    JiaBeiNO = 7,
    -- 已经看牌
    KanPai = 8,
}

-- 【推筒子组局】牌型
TTZ_Card_Type =
{
    -- 散牌1(0点～7点半)
    SANPAI1 = 1,
    -- 散牌2(8点～9点半)
    SANPAI2 = 2,
    -- 28杠
    GANG28 = 3,
    -- 豹子
    BAOZI = 4,
    --  至尊
    ZHIZUN = 5,
}

-----------------------------------------组局麻将相关-----------------------------------

-- 【麻将组局】房间状态
ROOM_STATE_MJ =
{
    -- 等待开始
    START = 0,
    -- 玩家准备
    READY = 1,
    --  摇色子
    RANDOM = 2,
    -- 发牌
    DEAL = 3,
    -- 定缺
    QUE = 4,
    -- 定缺结束(客户端表现展示)
    QUE_END = 5,
    -- 玩家出牌
    CHUPAI = 6,
    -- 强制出牌
    FORCE_CHUPAI = 7,
    -- 等待碰杠胡阶段
    WAIT = 8,
    -- 碰杠胡结束阶段
    WAIT_END = 9,
    -- 流局
    LIUJU=10,
    -- 结算阶段
    SETTLEMENT =11,
}

-- 【麻将组局】玩家状态
PlayerStateEnumMJ =
{
    -- 空位状态
    NULL = 0,
    -- 坐下未参与游戏(旁观者)
    LookOn = 1,
    -- 已经准备
    Ready = 2,
    -- 参与游戏
    JoinOK = 3,
    -- 定缺
    QUE = 4,
    -- 已经胡牌
    HU = 5,
    -- 认输
    Fail = 6,
}

--[麻将组句]玩家缺牌类型
MJ_QUE_Card_Type = 
{
    -- 筒
    Tong = 1,
    -- 条
    Tiao = 2,
    -- 万
    Wan = 3,
}

--[组局麻将]牌型
MJ_Card_Type=
{
    [1]="Tong",
    [2]="Tiao", 
    [3]="Wan",
}

--[组局麻将]更改金币原因
MJ_GOLD_CHANGE=
{
    ANTES = 1,             --开局收取底注
    DIANGANG = 2,          --点杠
    ANGANG = 3,            --暗杠
    BUGANG = 4,            --补杠
}

MJGoldChangeContent = 
{
    PINGHU = 1,          -- 平胡
    PENGPENGHU = 2,      -- 碰碰胡(对对胡)
    QINGYISE = 3,        -- 清一色
    ANQIDUI = 4,         -- 暗七对
    JINGOUDIAO = 5,      -- 金钩钓
    QINGPENG = 6,        -- 清一色碰碰胡
    LONGQIDUI = 7,       -- 龙七对
    QINGANQIDUI = 8,     -- 清暗七对
    QINGJINGOUDIAO = 9,  -- 清金钩钓
    TIANHU = 10,         -- 天胡
    DIHU = 11,           -- 地胡
    QINGLONGQIDUI = 12,  -- 清龙七对
    SHIBALUOHAN = 13,    -- 十八罗汉
    QINGSHIBA = 14,      -- 清十八罗汉
    MINGGANG = 15,       -- 刮风
    ANGANG = 16,         -- 下雨
    BUGANG = 17,         -- 补杠
    HUAZHU = 18,         -- 花猪
    CHADAJIAO = 19,      -- 查叫
    TUISHUI = 20,        -- 退税
}

MJSettlementInfo=
{
    [1]="平胡",
    [2]="碰碰胡",
    [3]="清一色",
    [4]="暗七对",
    [5]="金钩钓",
    [6]="清一色碰碰胡",
    [7]="龙七对",
    [8]="清暗七对",
    [9]="清金钩钓",
    [10]="天胡",
    [11]="地胡",
    [12]="清龙七对",
    [13]="十八罗汉",
    [14]="清十八罗汉",
    [15]="杠",
    [16]="暗杠",
    [17]="补杠",
    [18]="花猪",
    [19]="查叫",
    [20]="退税",
}


-----------------------------------------匹配跑的快相关-----------------------------------
-- 【跑的快组局】房间状态
ROOM_STATE_PDK =
{
    -- 大厅
    HALL = 0,
    -- 玩家准备
    READY = 1,
    -- 延迟时间
    DELAY =2,
    -- 发牌
    DEAL = 3,
    -- 决定出牌玩家
    DECISION=4,
    -- 玩家出牌
    CHUPAI = 5,
    -- 等待出牌
    WAITCHUPAI = 6,
    -- 结算阶段
    SETTLEMENT =7,
    -- 等待开始
    START = 8,
    -- 观战
    LOOK = 9,
}

-- 【跑的快组局】玩家状态
PlayerStateEnumPDK =
{
    -- 空位状态
    NULL = 0,
    
    -- 已经准备
    Ready = 1,
    -- 延迟时间
    DELAY =2,
    -- 开始游戏
    JoinOK = 3,
    -- 决定出牌玩家
    DECISION=4,
    -- 出牌
    Out = 5,
    -- 等待出牌
    WaitOut = 6,
    -- 结算
    SETTLEMENT = 7,
    -- 坐下未参与游戏(旁观者)
    LookOn = 8,
    -- 旁观
    Look = 9,
}

-- [跑的快]牌型
GAME_NOTE_TYPE_PDK =
{
    GAME_NOTE_TYPE_PDK_SINGLE   = 1,        -- 单张
    GAME_NOTE_TYPE_PDK_COUPLE   = 2,        -- 对子
    GAME_NOTE_TYPE_PDK_THREE    = 3,        -- 三张不带
    GAME_NOTE_TYPE_PDK_BOMB     = 4,        -- 炸弹
    GAME_NOTE_TYPE_PDK_3W1      = 5,        -- 三带一
    GAME_NOTE_TYPE_PDK_1SQ      = 6,        -- 单顺
    GAME_NOTE_TYPE_PDK_2SQ      = 7,        -- 双顺
    GAME_NOTE_TYPE_PDK_3SQ      = 8,        -- 三顺
    GAME_NOTE_TYPE_PDK_3W2      = 9,        -- 三带二
    GAME_NOTE_TYPE_PDK_4W3      = 10,       -- 四带三
    GAME_NOTE_TYPE_PDK_PLANE    = 11,       -- 飞机
    GAME_NOTE_TYPE_PDK_4W2      = 12,       -- 四带二
}


-- [龙虎斗] 房间状态
LHD_ROOM_STATE =
{
    -- 等待
    WAIT = 1,
    -- 洗牌
    SHUFFLE = 2,
    -- 发牌
    DEAL = 3,
    -- 下注
    BET = 4,
    -- 亮牌
    CHECK = 5,
    -- 结算
    SETTLEMENT = 6,
}

-- [龙虎斗]: 胜负编号
LHD_WIN_CODE =
{
    LONG = 1,
    HU = 2,
    HE = 4,
}

-- [龙虎斗]: 区域胜负结果码
LHD_AREA_WIN_CODE =
{
    [1] = LHD_WIN_CODE.LONG,
    [2] = LHD_WIN_CODE.HU,
    [3] = LHD_WIN_CODE.HE,
}

-- [龙虎斗]: 胜负结果转区域码
LHD_WIN_AREA_CODE =
{
    [LHD_WIN_CODE.LONG] = 1,
    [LHD_WIN_CODE.HU] = 2,
    [LHD_WIN_CODE.HE] = 3,
}

-- [龙虎斗]: 押注区域
LHD_BETTING =
{
    -- 龙区域
    LONG = 1,
    -- 虎区域
    HU = 2,
    -- 和区域
    HE = 3,
}
-- [龙虎斗]: 各个区域赔付比例
LHD_COMPENSATE =
{
    -- 龙赔付比例
    [LHD_BETTING.LONG] = 1,
    --虎赔付比例
    [LHD_BETTING.HU] = 1,
    -- 和赔付比例
    [LHD_BETTING.HE] = 8,
}

--=================[百家乐 配置相关]===========================================
-- [百家乐] 房间状态
BJL_ROOM_STATE =
{
    -- 等待
    WAIT = 1,
    -- 洗牌
    SHUFFLE = 2,
    -- 丢牌动画
    CUTANI = 3,
    -- 下注
    BET = 4,
    -- 亮牌
    CHECK = 5,
    -- 结算
    SETTLEMENT = 6,
}

-- [百家乐]: 胜负编号
BJL_WIN_CODE =
{
    LONG = 1,
    HU = 2,
    HE = 4,
    LONGDUIZI = 8,
    HUDUIZI = 16,
}

-- [百家乐]: 区域==>胜负结果码
BJL_AREA_WIN_CODE =
{
    [1] = BJL_WIN_CODE.LONG,
    [2] = BJL_WIN_CODE.HU,
    [3] = BJL_WIN_CODE.HE,
    [4] = BJL_WIN_CODE.LONGDUIZI,
    [5] = BJL_WIN_CODE.HUDUIZI,
}

-- [百家乐]: 胜负结果==>转区域码
BJL_WIN_AREA_CODE =
{
    [BJL_WIN_CODE.LONG] = 1,
    [BJL_WIN_CODE.HU] = 2,
    [BJL_WIN_CODE.HE] = 3,
    [BJL_WIN_CODE.LONGDUIZI] = 4,
    [BJL_WIN_CODE.HUDUIZI] = 5,
}

-- [百家乐]: 押注区域
BJL_BETTING =
{
    -- 龙区域
    LONG = 1,
    -- 虎区域
    HU = 2,
    -- 和区域
    HE = 3,
    -- 闲家对子
    LONGDUIZI = 4,
    -- 庄家对子
    HUDUIZI = 5,
}
-- [百家乐]: 各个区域赔付比例
BJL_COMPENSATE =
{
    -- 龙赔付比例
    [BJL_BETTING.LONG] = 1,
    --虎赔付比例
    [BJL_BETTING.HU] = 1,
    -- 和赔付比例
    [BJL_BETTING.HE] = 8,
    -- 闲家对子比例
    [BJL_BETTING.LONGDUIZI] = 11,
    -- 庄家对子比例
    [BJL_BETTING.HUDUIZI] = 11,
}

--=================[排行榜 配置相关]===========================================
-- 排行榜类型(1,财富榜，2充值榜，3日赚榜 4体现榜 5龙虎厅收益榜   6金花收益榜  7牛牛收益榜  
            --8推筒子收益榜  9红包收益榜  14跑得快收益榜 21代理提取佣金日榜 22代理提取佣金周榜 23代理提取佣金月榜)
GAME_RANK_TYPE =
{
    WEALTH = 1,
    RECHARGE = 2,
    DAY_MONEY = 3,
    EXTRACT = 4,
    LHD_MONEY = 5,
    JH_MONEY = 6,
    NN_MONEY = 7,
    TTZ_MONEY = 8,
    HB_MONEY = 9,
    LHD_Money = 10,
    PDK_MONEY = 14,
    DL_EXTRACT_DAY = 21,
    DL_EXTRACT_WEEK = 22,
    DL_EXTRACT_MONTH = 23,
    SSC_MONEY = 12,
    BCBM_MONEY = 13,
}

-- ==========================[大厅布局配置相关]============================= --
-- 大厅游戏类型
HallGameType =
{
    [1] = "",                       -- 大厅
    [2] = "sprite_playType_brjh",   -- 百人金花
    [3] = "sprite_playType_lhd",    -- 龙虎斗
    [4] = "sprite_playType_bjl",    -- 百家乐
    [5] = "sprite_playType_ssc",    -- 时时彩
    [6] = "sprite_playType_bcbm",   -- 奔驰宝马
    [7] = "sprite_playType_xyzp",   -- 幸运转盘
    [8] = "sprite_playType_zjh",    -- 扎金花
    [9] = "sprite_playType_qznn",   -- 牛牛
    [10] = "sprite_playType_hbjl",  -- 红包接龙
    [11] = "sprite_playType_ttz",   -- 推筒子
    [12] = "",                      -- 麻将
    [13] = "sprite_playType_pdk",   -- 跑得快
}

-- 大厅房间类型
HALL_ROOM_TYPE = 
{
    [1] = ROOM_TYPE.None,           -- 大厅中心
    [2] = ROOM_TYPE.BRJH,           -- 百人金花     百人房
    [3] = ROOM_TYPE.LHDRoom,        -- 龙虎斗       百人房
    [4] = ROOM_TYPE.BJLRoom,        -- 百家乐       百人房
    [5] = ROOM_TYPE.SSC,            -- 时时彩     
    [6] = ROOM_TYPE.BMWBENZ,        -- 奔驰宝马
    [7] = ROOM_TYPE.LuckyWheel,     -- 幸运转盘
    [8] = ROOM_TYPE.MenJi,          -- 焖鸡房     五人房
    [9] = ROOM_TYPE.PiPeiNN,        -- 抢庄牛牛
    [10] = ROOM_TYPE.PPHongBao,     -- 匹配红包
    [11] = ROOM_TYPE.PiPeiTTZ,      -- 推筒子
    [12] = ROOM_TYPE.ZuJuMaJiang ,  -- 组局麻将 
    [13] = ROOM_TYPE.PiPeiPDK,      -- 跑得快
}

-- 房间类型索引
RoomTypeIndex =
{
    -- 百人金花
    [ROOM_TYPE.BRJH] = 2,
    -- 龙虎斗
    [ROOM_TYPE.LHDRoom] = 3,
    -- 百家乐
    [ROOM_TYPE.BJLRoom] = 4,
     -- 焖鸡厅       五人房
     [ROOM_TYPE.MenJi] = 8,
     -- 牛牛匹配     六人房
     [ROOM_TYPE.PiPeiNN] = 9,
     -- 红包接龙     匹配场
     [ROOM_TYPE.PPHongBao] = 10,
     -- 推筒子匹配
     [ROOM_TYPE.PiPeiTTZ] = 11,
     --幸运转盘
     [ROOM_TYPE.LuckyWheel] = 7,
     --宝马奔驰
     [ROOM_TYPE.BMWBENZ] = 6,
     -- 时时彩
     [ROOM_TYPE.SSC] = 5,
     -- 匹配跑的快
     [ROOM_TYPE.PiPeiPDK] = 13,
}

---------------------------------------- 奔驰宝马相关 ----------------------------------
BenChiBaoMa_State = 
{
    DAOJISHI            = 1,        -- 倒计时
    BET                 = 2,        -- 押注
    XUANZHUAN           = 3,        -- 客户端光标旋转
    JIESUAN             = 4,        -- 结算
    WAIT                = 5,        -- 等待
}


-- ========= 时时彩 =========>>

ShiShiCai_State = {
    BET           = 0,        -- 押注
    SETTLEMENT         = 1,        -- 结算
    WAIT            = 2,        -- 等待
}
ShiShiCai_StateTime = {
    YAZHU_1         = 21,       -- 【开始下注】动画播放时间
    YAZHU_2         = 19,       -- 可下注阶段
    YAZHU_3         = 3,        -- 停止下注
    JIESUAN_1       = 7,        -- 开牌动画
    JIESUAN_2       = 3,        -- 奖励面板显示
    WAIT_1          = 2,        -- 等待阶段
}

-- ========= 时时彩 =========<<
