GameData =
{
    LoginInfo =
    {
        -- 登陆的平台(平台类型: 1 windows 2 android 3 ios 4 macos)
        PlatformType = PLATFORM_TYPE.PLATFORM_TOURISTS,
        -- 登陆方式( 1，游客登陆，2，账号+密码，3 账号+验证码 )
        LoginType = LOGIN_TYPE.VISITOR,
        -- 登陆的账号信息
        Account = "",
        -- 登录密码
        Password = "",
        -- 登陆账号名称
        NickName = "",
    },

    OnlineCount = 
    {
      
    },
    BMBCOnlineCount = 
    {
       
    },
    -- 游戏玩法显示相关
    GameTypeDisplay = 
    {

    },
    -- 游戏房间列表信息
    GameTypeListInfo =
    {

    },
    -- 角色的相关信息
    RoleInfo =
    {
        -- 账号
        Account = "",
        -- 账号ID
        AccountID = 0,
        -- 账号名称
        AccountName = "",
        -- 角色头像信息
        AccountIcon = 0,
        --当前房间内玩家数
        PlayerCount = 0,
        -- 角色头像URL
        HeadUrl = "",
        -- 砖石数量
        DiamondCount = 0,
        -- 金币数量
        GoldCount = 0,
        -- 显示金币数量
        DisplayGoldCount = 0,
        -- 房卡数量
        RoomCardCount = 0,
        -- 免费金币数
        FreeGoldCount = 0,
        -- 显示的免费金币数量
        DisplayFreeGoldCount = 0,
        -- Vip 等级
        VipLevel = 0,
        -- 充值数量
        ChargeCount = 0,
        -- 登陆IP信息
        LoginIPAddress = "",
        -- 登陆IP是否改变
        IPAddressIsChange = false,
        -- 玩家IP地理位置
        IPLocation = "中国.香港",
        -- 是否发送给服务器
        IPSend2Server = 0,
        -- 上次发送给服务器原因
        IPReason = 0,

        Cache =
        {
            ChangedGoldCount = 0,
            ChangedFreeGoldCount = 0
        },
        -- 是否是推广员  0 不是推广员 1 正在申请推广员 2 普通推广员 3 总推广员 (废弃==》新的推广模式)
        PromoterStep = 0,
        -- 是否已经填写过邀请码
        InviteCode = 0,
        -- 是否已绑定账号
        IsBindAccount = false,
        -- 是否绑定银行卡
        IsBindBank = false,
        -- 是否绑定支付宝
        IsBindZhifubao = false,
        -- 未读邮件数量
        UnreadMailCount = 0,
        -- 修改名称次数
        ModifyNameCount = 0,
        --连续签到的天数
        WeekDay = 0,
        --传输的登录时是否已经签到领取
        ContinuousSign = 0 ,
        -- 玩家再冲多少钱升VIP等级
        PlayerNeedRechargeGold = 0,
        --玩家可以升到的VIP等级
        PlayerUpgradeVip_LV = 0,
        -- 玩家断线重新进入 可能会有目前正在进行的游戏局
        -- 玩家正在玩的房间ID
        PlayRoomID = 0,
        -- 玩家正在玩的房间类型
        PlayRoomType = 0,
        -- 玩家正在玩的游戏的房间数量    TUDOU
        RoomAmount = 0,
        BRTRoomAmount = 0;
        -- 官方QQ
        OfficialQQ = "",
        -- 官方微信
        OfficialWX = "",
        -- 官方网站
        OfficialUrl = "",
        -- 大厅房间上次刷新时间
        HallRoomTypeUpdateTime = 0,
        -- 是否分享朋友圈
        IsSharePYQ = 0,
        -- 是否进入推广方法
        IsEnterTGFF = false,
    },
    
    -- 房间的相关信息
    RoomInfo =
    {

        -- 房间类型
        RoomList_Type = 0,
        -- 当前房间信息
        CurrentRoom = { },
        -- [1] = {[10000] ={ Count = 5, [1] = {X = 1, Y = 1, Owner = 10001, }
        RelationRooms = { },
        -- 统计信息
        CurrentRoomChips = { },
        -- 房间路单信息
        StatisticsInfo = { },
        -- 玩家牛牛组局历史房间列表
        HistoryRoomNN = {},
        -- 百人厅房间配置
        BRTRoomConfiguration = {},
        -- 非百人厅房间配置
        RoomConfiguration = {}
    },
    --客服咨询相关信息
    KFZX =
    {
        --服务器是否发消息到玩家
        ServerIsSendToPlayer=false,
        --所有的条数 包括玩家，服务器
        InfoTotalNumber=0,
        --用来存储所有的消息的table
        Info = {},
		BasicQuestionCount = 0,
    },
    --玩家自己发的
    Player =
    {
        --消息发送的时间
        Sender = "",
        --发送的内容
        Content = "",
        --发送的时间
        Time = "",
    },
    --服务器发的
    Server =
    {
        --消息发送的时间
        Sender = "",
        --发送的内容
        Content = "",
        --发送的时间
        Time = "",
    },
	-- 【客服中心】常见问题
    basicQuestion = {

    },
    -- 【客服中心】常见问题答案
    basicAnswer = {

    },
    --用来存储所有的聊天数据
    DataInfo = nil
   ,
    -- 排行榜数据
    RankInfo =
    {
        -- [1] = { RankID = 1, AccountName = "", AccountID = 0, VipLevel = 0, HeadIcon = "", HeadUrl = "", RichValue = 0}
        RichList = nil,
        CaiFuRank = {},     -- 财富榜
        ChongZhiRank = {},  -- 充值榜
        RiZhuanRank = {},   -- 日赚榜
        TiXianRank = {},    -- 提现榜
        LhtRank = {},       -- 龙虎厅收益榜
        JhRank = {},        -- 金花收益榜
        NnRank = {},        -- 牛牛收益榜
        TtzRank = {},       -- 推筒子收益榜
        HbRank = {},        -- 红包收益榜
        LhdRank = {},       -- 龙虎斗收益榜
        BjlRank = {},       -- 百家乐收益榜
        SscRank = {},       -- 时时彩乐收益榜
        BcbmRank = {},      -- 奔驰宝马收益榜
        PdkRank = {},       -- 跑得快收益榜
        DaiLiRiBang = {},   -- 代理提取佣金日榜
        DaiLiZhouBang = {}, -- 代理提取佣金周榜
        DaiLiYueBang = {},  -- 代理提取佣金月榜

        CaiFuRankTime = 0,     -- 财富榜点击时间
        ChongZhiRankTime = 0,  -- 充值榜点击时间
        RiZhuanRankTime = 0,   -- 日赚榜点击时间
        TiXianRankTime = 0,    -- 提现榜点击时间
        LhtRankTime = 0,       -- 龙虎厅收益榜点击时间
        JhRankTime = 0,        -- 金花收益榜点击时间
        NnRankTime = 0,        -- 牛牛收益榜点击时间
        TtzRankTime = 0,       -- 推筒子收益榜点击时间
        HbRankTime = 0,        -- 红包收益榜点击时间
        LhdRankTime = 0,       -- 龙虎斗收益榜点击时间
        BjlRankTime = 0,      -- 百家乐收益榜点击时间
        SscRankTime = 0,      -- 时时彩乐收益榜点击时间
        BcbmRankTime = 0,     -- 奔驰宝马收益榜点击时间
        PdkRankTime = 0,       -- 跑得快收益榜点击时间
        DaiLiRiBangTime = 0,   -- 代理提取佣金日榜点击时间
        DaiLiZhouBangTime = 0, -- 代理提取佣金周榜点击时间
        DaiLiYueBangTime = 0,  -- 代理提取佣金月榜点击时间
        -- 总资产财富榜
        DayOfYear = 0,-- 获取排行榜数据时的日期（一年中的第几天）
    },
    -- 邮件信息
    EmailInfo =
    {
    },
    -- 时时彩相关信息
    LotteryInfo =
    {
        -- 头像ID
        WinnerID = 0,
        -- 账号名称
        WinnerName = "",
        -- 角色头像URL
        WinnerHeadUrl = "",
        -- 角色头像信息
        WinnerIcon =0,
        -- Vip 等级
        WinnerVipLevel = 0,
        --当前房间内玩家人数
        PlayerCount = 0,
        -- 赢家获利数
        Winner_Gold = 0,
        -- 奖金池
        GoldPool = 0,
        -- 当前状态
        NowState = 0,
        -- 倒计时
        CountDown =0,
        -- 牌数量
        PokersNum = 0,
        Pokers = {},
        -- 牌花色
        PokerColor = {},
        -- 牌大小
        PokerSize = {},
        -- 上一次豹子出现距离现在时间
        LastBaoziTime = 0,
        -- 本轮押注信息      
        Bet={},
        -- 玩家本身押注信息
        myBet={},
        -- 近30轮开牌结果
        OpenCardHistory={},
        -- 押注按钮类型()
        Bet_Button_Type =0,
        -- 玩家押注金额
        MyBet_Gold =0,
        -- 押注获胜金额
        Bet_Victory_Gold=0,
        -- 押注是否获胜
        is_Bet_Victory=0,
        -- 倒计时秒数
        timer =0,
        -- 历史开牌数量
        OpenCardNum=0,
        -- 获胜牌型
        Victory_Card_Type=0,
        -- 玩家拥有金币数量
        HaveGoldNumber= 0,
        -- 时时彩是否打开
        ssc_isOpen=0,
        -- 下注数量
        BetNumber=100,
        -- 翻倍数量
        DoubleNumber=1,
    },
    -- 奔驰宝马相关信息
    CarInfo=
    {
        -- 场次(1初级场 2中级场 3高级场)
        Type = 1,
        -- 当前状态
        Level=0,
        -- 当前状态
        NowState=0,
        -- 各阶段剩余时间
        ResidualTimeOfEachStage=0,
        -- 法拉利上次出现时间
        LastFerrariTime=0,
        -- 兰博基尼上次出现时间
        LastLamborghiniTime=0,
        --上轮抽奖目标
        LastLotteryTarget = 0;
        -- 本轮抽奖目标
        LotteryTarget=0,
        -- 庄家信息
        BankerAccountID=0,
        BankerName="",      -- 庄家名字
        BankerID=0,         -- 庄家头像ID
        BankerVipLevel=0,    -- 庄家VIP等级
        BankerHeadUrl="",   -- 庄家头像Url
        BankerGold=0,       -- 庄家拥有金币
        -- 上轮赢家信息
        WinnerName="",      -- 上轮赢家名字
        WinnerID=0,         -- 上轮赢家头像ID
        WinnerVipLevel=0,    -- 上轮赢家VIP等级
        WinnerHeadUrl="",   -- 上轮赢家头像Url
        WinnerGold=0,       -- 上轮赢家拥有金币
        -- 本轮玩家下注信息
        myBet={},
        -- 本轮所有玩家下注信息
        AllBet={},
        -- 车类型
        --CarType={"fll","lb","msld","bsj","bc","bmw","bt","dz"},
        -- 历史押中数量
        LastBetNum=0,
        -- 历史押中结果
        LastBetResult={},
        -- 下注类型
        BetType=0,
        -- 下注金额
        myBetGold=0,
        -- 当前状态是上庄还是下庄
        isBanker=0,
        -- 庄家结算
        BankerSettlement_Gold=0,
        -- 庄家是否胜利
        isBankerWinner=0,
        -- 庄家列表
        BankerRemainder=0,--当前庄家剩余局数
        BankerNumber=0,  -- 当前排队人数
        BankerListVIP={}, -- 当前排队庄家vip等级
        BankersName={},   -- 当前排队庄家的名字
        BankersGold={},   -- 当前排队庄家的金币
        BankerStrLoginIP = {}; --登陆IP地址
        -- 是否是刚打开
        isNewOpen=0,
        -- 延迟时间
        delayTime=0,
        --玩家押中金币
        BetWinner_Gold=0,
        -- 默认筹码高亮位置
        ChipsPosition=1,
        -- 上庄最低限额
        UpperBankersGold = 0,
        -- 筹码值
        ChipsValue = {},
        -- 是否下过注
        IsBet = false,
    },
    --TUDOU
    -- 幸运转盘相关信息
    FortunateInfo = 
    {
        --获得总金币
        allMoney = 0;
        --旋转次数
        time_Lottery = 0;
        --奖励的金币表
        table_RewardMoney = {};
        --最后一次转动转盘获得奖励档次
        level_LastLottery = 0;
        --玩家当前金币
        playerMoney = 0;
        --转盘纪录数量
        recordCount = 0;
        ------转盘获奖纪录表
        table_Record = {
            date = "";
            time = "";
            count = 0;
            money = 0;
        };
        -- 转动一次花费
        RotateOnceGold = 0,
        -- 中奖档次金币
        WinningGradegOLD = {},
    },
    Exit_MoneyNotEnough = false;
    -- 抽 iPhone 相关信息
    iPoneLotteryInfo=
    {
        -- 当前状态
        NowState=0,
        -- 距离活动时间还有多久
        StartTime=0,
        --玩家抽奖次数
        LotteryNumberOfTimes=0,
        -- 抽中坐标
        LotteryTarget=0,
        -- iphone活动是否结束
        iPhoneButton=1,
    },

    -- 玩牌抽话费信息
    ExchangeTelephoneFareInfo=
    {
        -- 兑换按钮索引
        ButtonIndex=0,
        -- 玩家金币
        PlayerGold=0,
        -- 玩家拥有话费
        PlayerTelephoneRate=0,
        -- 中奖索引
        WinningPosition=0,
        -- 抽奖次数
        LuckDrawNumber=1,
        -- 玩家抽中话费
        WinnerBill=0,
        -- 玩家缺少话费
        LackBill=0,
        -- 玩家能够兑换
        Convertible="",
        -- 玩家不能兑换
        CannotConvertibility="",
        -- 兑换状态
        ConvertibilityState=0,
        -- 任务索引
        TaskIndex=0,
        -- 任务需要完成次数
        TaskNeedNumber=0,
        -- 任务已完成次数
        TaskCompleteNumber=0,
        -- 任务倒计时
        TaskCountDown=0,
        -- 任务当前状态
        TaskState=0,
        -- 轮盘次数
        WheelNumber=0,
        -- 任务失败倒计时
        TaskFailCountDown=60,
    },

    -- 直充直兑信息
    BankInformation=
    {
        -- 可用额度
        AvailableCredit = 0,
        -- 可提现额度
        AmountExtraction = 0,
        --提现的手续费
        ChargeOfWithdraw = 0;
        --提现的金额
        AmountOfWithdraw = 0;
        --请求提现信息还是确定提现(1：请求提现信息，2：确定提现)
        isGetData = 0;
        -- 银行卡是否绑定
        IsBankCardBinding = 0,
        -- 账单数量
        BillCount = 0,
        -- 明细信息
        BillInfo={},
        -- 绑定银行名称
        BankName="",
        -- 绑定银行尾号
        BankNumber="",
        -- 玩家名字
        BankPlayerName="",
        -- 银行名称
        BankName ="",
        -- 银行卡号
        BankCardNumber="",
        -- 是否可修改绑定(0否 1是)
        ChangeBindFlag = 0,
        -- 开户省份
        --BankProvince="",
        -- 开户城市
        --BankCity="",
        -- 开户支行
        --BankSubbranch="",
        -- 支付宝是否绑定
        ZhiFuBaoIsBinding = 0,
        -- 支付宝实名制姓名
        ZhiFuBaoName="",
        -- 支付宝账号
        ZhiFuBaoAccount="",
        -- 充值方式
        RechargeMode = 0,
        -- 充值金额
        RechargeAmountValue = 0,
        -- 代理充值区域一文字
        RegionalOneText = "",
        -- 代理充值区域二文字
        RegionalTwoText = "",
        --代理数量
        DaiLiCount = 0,
        -- 代理信息
        DaiLiInfo = {},
        -- 人气代理信息
        HotDaiLiInfo = {},
        -- 普通代理信息
        NoHotDaiLiInfo = {},
        -- 充值方式信息
        RechargeTypeInfo = {},
        -- 当前选择充值方式
        NowRechargeIndex = 0,
        -- 是否直接打开绑定
        IsOpenBind = false,
        -- 订单号
        OrderInformation = "",
        -- 订单时间
        Time = "",
    },
    -- 红包接龙
    HBJL=
    {
        -- 结算界面是否打开
        JS_isOpen=1,
        -- 红包是否飞过
        HB_isFly=1,
        -- 房间等级
        RoomLevel=0,
        -- 是否抢过红包（0没抢过 1 抢过）
        RobRedEnvelopes = 0,
    },

    --=============[推广员]相关================================
    AgencyInfo =
    {
        IsAgent = 0,                        -- 是否推广员(0 不是 1是)
        ZRTotalCommission = 0,              -- 昨日总业绩
        ZRZSCommission = 0,                 -- 昨日直属会员业绩
        ZRQTCommission = 0,                 -- 昨日其他会员业绩
        TotalCommission = 0 ,               -- 总佣金
        PayableCommission = 0,              -- 可提取佣金
        isGetData = 0,                      -- 是否获取数据
        ChargeCount = 0,                    -- 手续费
        ZSTotalMember = 0,                  -- 我的直属会员数量
        ZSWeekMember = 0,                   -- 本周直属会员新增
        ZSMonthMember = 0,                  -- 本月直属会员新增
        QTTotalMember = 0,                  -- 我的其他会员数量
        QTWeekMember = 0,                   -- 本周其他会员新增
        QTMonthMember = 0,                  -- 本月其他会员新增

        ExtractData = {},                   -- 提取详情
        ZSMemberDetails = {},               -- 直属会员贡献详情
        ServerTime = 0,                     -- 服務器時間

        RedFlag = true,                     -- 推广功能红点标识(今日是否访问)
    },

    --=================[余额宝]相关======================= --
    YueBaoInfo = 
    {
        -- 主页
        Homepage = 
        {
            AllGoldValue = 0,               -- 总金额
            YesterdayProfit = 0,            -- 昨日收益
            AllProfit = 0,                  -- 累计收益
            DayInterestRate = 0,            -- 日化利率
            DayProfit = 0,                  -- 日化收益
            QiDayInterestRate = 0,          -- 七日利率
            ShiWuDayInterestRate = 0,       -- 十五日利率
            SanShiDayInterestRate = 0,      -- 三十日利率
            IntoAllValue = 0,               -- 可转入额度
            IntoValue = 0,                  -- 本次转入额度
            TurnOutAllValue = 0,            -- 可转出额度
            TurnOutValue = 0,               -- 本次转出额度
            QiDayPrice = 0,                 -- 七日投资价格
            QiDayNumber = 0,                -- 七日投资起买分数
            ShiWuDayPrice = 0,              -- 十五日投资价格
            ShiWuDayNumber = 0,             -- 十五日投资起买分数
            SanShiDayPrice = 0,             -- 三十日投资价格
            SanShiDayNumber = 0,            -- 三十日投资起买分数
            Binding = false,                -- 没绑定过余额宝密码
            BindingPassword = "",           -- 余额宝密码
            ShouYiTime = {},                -- 收益时间
            Name1 = "",                     -- 产品名字1
            Name2 = "",                     -- 产品名字2
            Name3 = "",                     -- 产品名字3
        },
        -- 投资买入界面
        Investment = 
        {
            BuyingTime = {},                -- 买入时间
            BuyOkTime = {},                 -- 成交时间
            YieldTime = {},                 -- 收益时间
            ExpiryTime = {},                -- 到期时间
            SurplusBuyValue = 0,            -- 剩余数量
            AllBuyValue = 0,                -- 总数量
        },
        -- 明细
        DetailedInfo = {},
        -- 我的买入信息
        MyBuyInfo = {},
    },

    -- 跑得快是否播过飞牌动画（false 未播过 true 以播过）
    PDKIsPlay = false,

    -- 游戏APP的状态
    GameState = 0,
    -- 大厅操作数据便于返回大厅时
    HallData = { },

    -- 上一次发送小喇叭的时间
    LastSmallHornTime = 0,
    -- 服务器ID
    ServerID = 0,

    --增加 游戏服务器的状态
    GameServerStatus=0,

    --增加 ISHasNotice
    ISHasNotice = 0,
    -- 公告开启次数(策划需求 启动游戏 只主动开启1次)
    AutoOpenNoticeTimes = 0,

    --增加 公告标题 公告内容
    NoticeTitle="",
    NoticeContent="",
    NoticeImageID = 0,
    NoticeGotoID = "0",

    --增加 红点是否显示
    NoticeRed = 1,
    --增加 客服提示小红点 0无 1有
    kefuIsRed = 0,
    --邮件红点
    MailRed = 0,
    
    --增加 客服中心的发送时间
    lastSendTime = 15,
    --增加 客服中心button按键开关
    ISEnable = true,
    
    -- 是否开启苹果支付,此值在登陆的时候由服务器初始化
    IsOpenApplePay = 0,
    -- 是否输入了邀请提示
    IsPromptedInviteTips = true,
    -- App版本检查结果
    AppVersionCheckResult = - 2,
    -- 是否同意协议
    IsAgreement = true,
    -- 游戏历史数据
    GameHistory = { MaxCount = 0, RequestedPage = 0, Datas = { } },
    -- 玩家注册渠道ID 默认渠道168(小龙虾棋牌) 默认渠道2(常来耍大牌)
    ChannelCode = 168,
    
    -- 是否已经确认平台ID
    ConfirmChannelCode = false,

    -- OpenInstall推荐人ID
    OpenInstallReferralsID = -1,
    -- OpenInstall推荐人渠道ID
    OpenInstallReferralsChannel = -1,
    -- OpenInstall推荐人GameID
    OpenInstallReferralsGameID = 0,

    -- 大厅组局房间列表 {[1]}
    ZJRoomList = { },
    -- 焖鸡房在线人数列表{[1]={OnlineCount = 1,}}
    MJRoomOnlineCount = {},
    -- 每日转盘信息(剩余可领取次数)
    WheelTimes = 0,
    -- 轮盘奖励档次
    WheelRewardPos = 1,
    -- 轮盘界面中奖玩家信息
    WheelWinInfo={},
    -- 奔驰宝马中奖信息
    CarWinnInfo={},
    -- 时时彩中奖信息
    SscWinnInfo={},
    --大厅红包接龙房间列表
    HBRoomList = { },
    -- 匹配红包在线人数
    PPHBRoomOnlineCount = {},
    --请求房间等级
    XYZPChooseRoomLevel = 0,

    -- 是否首次登陆(用于自动登陆时处理)
    IsFirstLogin = true,
};

function GameData.Init()
    GameData.InitCurrentRoomInfo(ROOM_TYPE.BRJH,0)
    GameData.InitHallData()
end

function GameData.InitHallData()
    GameData.HallData = { }
    -- 默认选择 大厅中心
    GameData.HallData.SelectType = 0

    GameData.HallData.Data = { }
    -- 竞咪厅默认选择 4
    GameData.HallData.Data[1] = 1
    -- 试水厅默认选择 201
    GameData.HallData.Data[2] = 201
    -- Vip 厅默认选择 1
    GameData.HallData.Data[3] = 1
end

function GameData.InitCurrentRoomInfo(roomTypeParam, nRoomID)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    if roomTypeParam == ROOM_TYPE.BRJH then
        GameData.InitRoomInfoJHBR()
    elseif roomTypeParam == ROOM_TYPE.MenJi or roomTypeParam == ROOM_TYPE.ZuJu then
        JHGameMgr:InitRoomInfoJHWR(roomTypeParam)
    elseif roomTypeParam == ROOM_TYPE.ZuJuNN or roomTypeParam == ROOM_TYPE.PiPeiNN then
        NNGameMgr:InitRoomInfoNNWR(roomTypeParam)
    elseif roomTypeParam == ROOM_TYPE.HongBao or roomTypeParam == ROOM_TYPE.PPHongBao then
        GameData.InitRoomInfoHBBR(roomTypeParam)
    elseif roomTypeParam == ROOM_TYPE.ZuJuTTZ or roomTypeParam == ROOM_TYPE.PiPeiTTZ then
        TTZGameMgr:InitRoomInfo(roomTypeParam)
    elseif roomTypeParam == ROOM_TYPE.ZuJuMaJiang then
        MJGameMgr:InitRoomInfo(roomTypeParam)
    elseif roomTypeParam == ROOM_TYPE.PiPeiPDK then
        PDKGameMgr:InitRoomInfoPDKWR(roomTypeParam)
    elseif roomTypeParam == ROOM_TYPE.LHDRoom then
        LHDGameMgr:InitRoomInfo(roomTypeParam)
    elseif roomTypeParam == ROOM_TYPE.BJLRoom then
        BJLGameMgr:InitRoomInfo(roomTypeParam)
    end

    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.RoomID = nRoomID
    tRoomData.RoomType = roomTypeParam
end

-- (百人房间)数据初始化
function GameData.InitRoomInfoJHBR()
    GameData.RoomInfo.CurrentRoom =
    {
        -- 房间ID
        RoomID = 0,
        -- 房间类型
        RoomType = ROOM_TYPE.BRJH,

        -- 房主ID
        MasterID = 0,
        -- 房间当前阶段
        RoomState = 1,
        -- 倒计时
        CountDown = 20,
        -- 房间模板ID
        TemplateID = 0,
        -- 是否是试水厅
        IsFreeRoom = false,
        -- 是否是VIP厅
        IsVipRoom = false,
        -- 房间人数
        RoleCount = 0,
        -- 存储当前收到的扑克牌信息 格式为：[1] = {PokerType = 1, PokerNumber = 14, Visible = true,}
        Pokers = { },
        -- 最大局数
        MaxRound = 0,
        -- 当前局数
        CurrentRound = 0,
        -- 庄家信息
        BankerInfo = { ID = 0, Name = "", Gold = 0, LeftCount = 0, HeadIcon = 0, HeadUrl = '', },
        -- 龙信息
        CheckRole1 = { ID = 0, Name = "", Icon = 1, HeadUrl = '', },
        -- 虎信息
        CheckRole2 = { ID = 0, Name = "", Icon = 1, HeadUrl = '', },
        -- 本局结果信息 位运算：1 龙赢，2 虎赢，4 和，8 龙金花 16 龙豹子 32 龙金花
        GameResult = 0,
        -- 赢取的金币
        WinGold = { },
        -- 当前选择下注的金额
        SelectBetValue = 0,

        -- [4(区域编号)] = {[0(自己)]={Value(值) = 0, Rank(排行) = 0 },[1(排行榜1)] = {Name(名称) ="", Value(值) = 0}},
        BetRankList = { },
        -- 自己的押注信息
        BetValues = { },
        -- {[1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0},
        -- 总计押注金额
        TotalBetValues = { },

        BankerList = { },
        -- 切牌动画中，切的是第几张扑克牌
        CutAniIndex = 0,
        -- 本局追加统计信息事件参数
        AppendStatisticsEventArgs = nil,

        -- 是否进入过(0 没有进过 1 进过)
        IsJoin=0,

        -- 金花下注下限
        BetJinHuaMin = 0,
        -- 金花下注上限
        BetJinHuaMax = 0,
        -- 豹子下注下限
        BetBaoZiMin = 0,
        -- 豹子下注上限
        BetBaoZiMax = 0,
        -- 龙虎下注下限
        BetLongHuMin = 0,
        -- 龙虎下注上限
        BetLongHuMax = 0,
    }

end

-- =============================聚龙厅 模块 Start======================================--

-- 聚龙厅清理本局数据
function GameData.ClearCurrentRoundData()
    GameData.RoomInfo.CurrentRoom.BetRankList = { }
    GameData.RoomInfo.CurrentRoom.BetValues = { }
    GameData.RoomInfo.CurrentRoom.TotalBetValues = { }
    GameData.RoomInfo.CurrentRoom.WinGold = { }
    GameData.RoomInfo.CurrentRoom.Pokers = { }
    GameData.RoomInfo.CurrentRoom.GameResult = 0
    GameData.RoomInfo.CurrentRoom.CheckRole1 = { ID = 0, Name = "", Icon = "", }
    -- 龙信息
    GameData.RoomInfo.CurrentRoom.CheckRole2 = { ID = 0, Name = "", Icon = "", }
    -- 虎信息
    GameData.RoomInfo.CurrentRoom.CutAniIndex = 0
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBetValue, nil)
end

function GameData.SubFloatZeroPart(valueStr)
    local index = string.find(valueStr, ".")
    if index ~= nil then
        local strLength = #valueStr
        for i = strLength, 1, -1 do
            local endChar = string.sub(valueStr, -1)
            if endChar == "0" then
                valueStr = string.sub(valueStr, 1, #valueStr - 1)
            elseif endChar == "." then
                valueStr = string.sub(valueStr, 1, #valueStr - 1)
                break
            else
                break
            end
        end
    end

    return valueStr
end

-- 设置百人厅房间状态
function GameData.SetRoomState(roomState)
    GameData.RoomInfo.CurrentRoom.RoomState = roomState
    GameData.RoomInfo.CurrentRoom.CountDown = ROOM_TIME[roomState]
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateRoomState, roomState)
end

-- 聚龙厅 阶段CD更新
function GameData.ReduceRoomCountDownValue(deltaValue)
    GameData.RoomInfo.CurrentRoom.CountDown = GameData.RoomInfo.CurrentRoom.CountDown - deltaValue
end

-- =============================聚龙厅 模块 End======================================--

--==============================--
--desc:邀请朋友一起玩(微信分享)
--time:2017-11-27 03:03:55
--@count:
--@reason:
--@return 
--==============================--
function GameData.ShowInvite(roomID, roomType, betParam1, betParam2)
    
end

--==============================--
--desc:邀请朋友一起玩(微信分享)
--time:2017-11-27 03:03:55
--@roomID: 房间ID
--@roomType: 房间类型
--@betParam1: 底注
--@betParam2: 入场
--@return 
--==============================--
function GameData.OpenIniteUI(roomID, roomType, betParam1, betParam2)
    
    local tData = {}
    tData.RoomID = roomID
    tData.RoomType = roomType
    tData.Bet = betParam1
    tData.BetEnter = betParam2

    local openparam = CS.WindowNodeInitParam("InviteGameUI")
    openparam.NodeType = 0
    openparam.WindowData = tData
    CS.WindowManager.Instance:OpenWindow(openparam)
end



function GameData.UpdateGoldCount(count, reason)
    if reason == 4 or reason == 5 or reason == 20 or reason == 21 or reason == 24 or reason == 38 then
        -- [百人金花 4 5 ] 结算 庄家结算
        -- [龙虎斗 20 21]  结算 庄家结算
        -- [百家乐 24]     结算
        -- [幸运转盘 38]   结算 (幸运转盘抽奖))
        GameData.RoleInfo.Cache.ChangedGoldCount = count - GameData.RoleInfo.GoldCount
        GameData.RoleInfo.GoldCount = count
    else
        GameData.RoleInfo.GoldCount = count
        GameData.SyncDisplayGoldCount()
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyGoldUpdateEvent, nil)
end

function GameData.UpdateFreeGoldCount(count, reason)
    if reason == 4 or reason == 5 then
        -- [百人金花] 结算 庄家结算
        GameData.RoleInfo.Cache.ChangedFreeGoldCount = count - GameData.RoleInfo.FreeGoldCount
        GameData.RoleInfo.FreeGoldCount = count
    else
        GameData.RoleInfo.FreeGoldCount = count
        GameData.SyncDisplayGoldCount()
    end
end

function GameData.SyncDisplayGoldCount()
    if GameData.RoleInfo.DisplayGoldCount ~= GameData.RoleInfo.GoldCount then
        GameData.RoleInfo.DisplayGoldCount = GameData.RoleInfo.GoldCount
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.SyncUpdateGold, 1)
        GameData.RoleInfo.Cache.ChangedGoldCount = 0
    elseif GameData.RoleInfo.DisplayFreeGoldCount ~= GameData.RoleInfo.FreeGoldCount then
        GameData.RoleInfo.DisplayFreeGoldCount = GameData.RoleInfo.FreeGoldCount
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.SyncUpdateGold, 2)
        GameData.RoleInfo.Cache.ChangedFreeGoldCount = 0
    else
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.SyncUpdateGold, 0)
        GameData.RoleInfo.Cache.ChangedGoldCount = 0
        GameData.RoleInfo.Cache.ChangedFreeGoldCount = 0
    end
end

-- 设置未读邮件数量
function GameData.ResetUnreadMailCount(count)
    GameData.RoleInfo.UnreadMailCount = count
    local eventArg = GameData.CreateUnHandleEventArgsOfEmail(count)
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateUnHandleFlag, eventArg)
end

--设置
function GameData.CreateUnHandleEventArgsOfEmail(count)
    if count == nil then
        count = 0
    end
    local eventArg = lua_NewTable(UuHandleFlagEventArgs)
    eventArg.ContainsUnHandle = count > 0
    eventArg.UnHandleCount = count
    return eventArg
end

-- 获取时时彩开牌区扑克名称
function GameData.GetLotteryPokerSpriteName(pokerType,pokerNum)
    local cardSpriteName ="sprite_" .. data.ShishicaiConfig.POKER_IMAGE_NAME[pokerType] .. "_" .. pokerNum;
    return cardSpriteName
end

--获取奔驰宝马倒计时图片资源
function GameData.GetCar_CountDown_Name(time)
    local carSpriteName ="sprite_number_" .. time;
    return carSpriteName
end

-- 获取扑克牌的贴图资源名称
function GameData.GetPokerCardSpriteName(pokerCard)
    local cardSpriteName = "sprite_" .. Poker_Type_Define[pokerCard.PokerType] .. "_" .. pokerCard.PokerNumber;
    return cardSpriteName
end

-- 获取麻将的贴图资源名称
function GameData.GetMJPokerCardBackSpriteName(pokerType,pokerNum)
    local cardSpriteName = "sprite_" .. MJ_Card_Type[pokerType] .. "_" .. pokerNum;
    return cardSpriteName
end

-- 获取麻将排行资源名称
function GameData.GetMJRankSpriteName(index)
    if index<=3 then
        local cardSpriteName = "sprite_MJ_Rank_NO_" .. index;
        return cardSpriteName
    else
        local cardSpriteName = "sprite_MJ_Rank"
        return cardSpriteName
    end

end

function GameData.GetPokerCardSpriteNameOfBig(pokerCard)
    local cardSpriteName = "sprite_" .. Poker_Type_Define[pokerCard.PokerType] .. "_b_" .. pokerCard.PokerNumber
    return cardSpriteName
end

function GameData.GetPokerCardBackSpriteNameOfBig(pokerCard)
    return "sprite_Poker_Back_b_01";
end

function GameData.GetPokerDisplaySpriteName(pokerCard)
    if pokerCard ~= nil and pokerCard.Visible then
        return GameData.GetPokerCardSpriteName(pokerCard);
    else
        return GameData.GetPokerCardBackSpriteName(pokerCard);
    end
end

function GameData.GetRolePokerTypeDisplayName(roleType)
    return data.GetString("BRAND_TYPE_" .. GameData.GetRolePokerType(roleType))
end

function GameData.GetRolePokerType(roleType)
    local pokerCards = GameData.RoomInfo.CurrentRoom.Pokers
    if roleType == 1 then
        local pokerCard1 = pokerCards[1]
        local pokerCard2 = pokerCards[2]
        local pokerCard3 = pokerCards[3]
        return GameData.GetPokerType(pokerCard1, pokerCard2, pokerCard3)
    elseif roleType == 2 then
        local pokerCard1 = pokerCards[4]
        local pokerCard2 = pokerCards[5]
        local pokerCard3 = pokerCards[6]
        return GameData.GetPokerType(pokerCard1, pokerCard2, pokerCard3)
    else
        return "角色不正确"
    end
end

-- 获取牌行描述显示Name
function GameData.GetPokerTypeDisplayName(pokerCard1, pokerCard2, pokerCard3)
    return data.GetString("BRAND_TYPE_" .. GameData.GetPokerType(pokerCard1, pokerCard2, pokerCard3))
end

function GameData.GetPokerType(pokerCard1, pokerCard2, pokerCard3)
    if pokerCard1 == nil or pokerCard2 == nil or pokerCard3 == nil then
        return BRAND_TYPE.SANPAI
    end

    if pokerCard1.PokerNumber == pokerCard2.PokerNumber
        or pokerCard1.PokerNumber == pokerCard3.PokerNumber
        or pokerCard2.PokerNumber == pokerCard3.PokerNumber then
        if pokerCard1.PokerNumber == pokerCard2.PokerNumber and pokerCard2.PokerNumber == pokerCard3.PokerNumber then
            return BRAND_TYPE.BAOZI
        else
            return BRAND_TYPE.DUIZI
        end
    else
        -- 检验是否是金花
        local isJinHua = false
        if pokerCard1.PokerType == pokerCard2.PokerType then
            if pokerCard1.PokerType == pokerCard3.PokerType then
                isJinHua = true
            end
        end

        local isSunZi = false
        local sortedNumbers = lua_number_sort(pokerCard1.PokerNumber, pokerCard2.PokerNumber, pokerCard3.PokerNumber)
        -- 检验是否是顺子
        if (sortedNumbers[1] + 1) == sortedNumbers[2] then
            if (sortedNumbers[2] + 1) == sortedNumbers[3] then
                isSunZi = true
            end
        end

        if isJinHua and isSunZi then
            return BRAND_TYPE.SHUNJIN
        elseif isJinHua then
            return BRAND_TYPE.JINHUA
        elseif isSunZi then
            return BRAND_TYPE.SHUNZI
        else
            return BRAND_TYPE.SANPAI
        end
    end
end

function GameData.GetPokerCardBackSpriteName(pokerCard)
    return "sprite_Poker_Back_01";
end

function GameData.GetTrendResultSpriteOfTrendItem(roundResult)
    if CS.Utility.GetLogicAndValue(roundResult, WIN_CODE.LONG) == WIN_CODE.LONG then
        return 'sprite_Trend_Icon_1'
    elseif CS.Utility.GetLogicAndValue(roundResult, WIN_CODE.HU) == WIN_CODE.HU then
        return 'sprite_Trend_Icon_2'
    elseif CS.Utility.GetLogicAndValue(roundResult, WIN_CODE.HE) == WIN_CODE.HE then
        return 'sprite_Trend_Icon_4'
    else
        return 'sprite_Trend_Icon_1'
    end
end

-- 获取玩家头像的的贴图资源名称
function GameData.GetRoleIconSpriteName(iconid)
    -- 由于老账号记录为0
    if iconid == 0 then
        iconid = 1
    end
    local iconSpriteName = "sprite_RoleIcon_" .. iconid;
    return iconSpriteName
end


-- 时时彩倒计时
function GameData.LotteryInfoCountDown(deltaValue)
    GameData.LotteryInfo.timer = GameData.LotteryInfo.timer + deltaValue
    if GameData.LotteryInfo.timer >= 0.9999 then
        GameData.LotteryInfo.CountDown = GameData.LotteryInfo.CountDown - 1
        GameData.LotteryInfo.timer = 0
    end
end

-- 奔驰宝马倒计时
function GameData.CarInfoCountDown(deltaValue)
    GameData.LotteryInfo.timer = GameData.LotteryInfo.timer + deltaValue
    if GameData.LotteryInfo.timer>=0.9999 then
    GameData.CarInfo.ResidualTimeOfEachStage = GameData.CarInfo.ResidualTimeOfEachStage - 1
    GameData.LotteryInfo.timer=0
    end
end

-- =============================【大厅=>红包接龙厅】 Start======================================--

--==============================--
--desc:获取组局房间信息
--time:2017-11-30 08:12:26
--@indexParam:选择房间Item标识
--@pageParam: 当前第几页
--@onePageParam:一页 多少条目
--@return 
--==============================--
function GameData.GetHongBaoRoomDataByRoomIndex( indexParam , pageParam, onePageParam)
    -- body
    local _data = nil
    local _count = #GameData.HBRoomList
    local tagIndex  = (pageParam - 1) * onePageParam + indexParam
    if tagIndex <= _count and tagIndex > 0 then
        -- body
        _data = GameData.HBRoomList[tagIndex]
    end
    return _data
end



-- =============================【大厅=>组局厅】 End======================================--

-----------------------------红包接龙数据模块---------------------
-- (红包接龙)数据初始化
function GameData.InitRoomInfoHBBR()
    GameData.RoomInfo.CurrentRoom =
    {
        -- 房间ID
        RoomID = 0,
        -- 房间主类型
        RoomType = ROOM_TYPE.HongBao,

        -- 房主ID
        MasterID = 1,
        -- 房间子类型
        SubType = 0,
        -- 房间模式(接龙 1大接龙)
        GameMode = 1,
        -- 比闷模式(必闷1圈 必闷3圈)
        --MenJiRound = 1,
        -- 是否允许陌生人加入(0 开放 1关闭)
        IsLock = 0,
        -- 是否进入过(0 没有进过 1 进过)
        IsJoin=0,

        -- 房间红包金额
        BetMin = 10,
        -- 房间状态
        RoomState = ROOM_STATE_HB.Wait,
        -- 当前状态CD
        CountDown = 0,
        -- 房间人数
        playerCount = 0,
        -- 玩家自己位置
        SelfPosition = 0,
        -- 庄家位置
        BankerPosition = 1,

        -- 房间对应位置玩家详细数据
        HongBaoPlayers = { },
        -- 当前房间所有下注情况
        AllBetInfo = { },
        -- =========挑战数据========
        -- 当前抢红包玩家信息
        GrabRedEnvelopeInfo={},
        -- 抢红包人数
        QHB_Count=0,
        -- 抢红包玩家位置
        GrabRedEnvelopePosition=0,
        -- 发红包人的名字
        FaHongBaoPlayerName="",
        -- 发红包玩家ID
        FaHBID=0,
        -- 发红包玩家位置
        BankerID=0,
        -- 抢红包玩家位置
        QHBposition={},
        -- 发红包玩家金额
        FHB_GOLD=0,
        -- 离开玩家信息
        KickOutPlayerInfo={},
    }
end

-- 红包接龙玩家显示位置转换
function GameData.PlayerPositionConvert8ShowPosition(tagPositionParam)
    local position = 0
    if tagPositionParam > 0 then
        position =(MAX_HBZUJU_ROOM_PLAYER - GameData.RoomInfo.CurrentRoom.SelfPosition + tagPositionParam - 1) % MAX_HBZUJU_ROOM_PLAYER + 1
    else
        
    end
    return position
end

-- 设置红包接龙房间状态
function GameData.SetHBRoomState(roomState)
    GameData.RoomInfo.CurrentRoom.RoomState = roomState
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateRoomState, roomState)
end

