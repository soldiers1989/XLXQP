ProtrocolID =
{    --Hub服务器协议
    CS_SEND_CODE_TO_HUB                      = 110,-- 给服务器发送验证code
    CS_SEND_CREATE_ORDER_TO_HUB              = 111,-- 给服务器发送创建订单协议
    
    
    S_SFT_PAY_RESULT                         = 113,-- 服务器通知盛付通支付结果
    CS_Visitor_Check                         = 198,-- 游客登录开关验证
    CS_Request_Game_Server                   = 199,-- 请求登陆服务器
    
    --gameserver服务器协议
    CS_Login                                 = 200,-- 登陆
    S_Disconnect                             = 201,-- 断开连接
    CS_User_Return                           = 202,-- 老玩家回归
    S_Update_Diamond                         = 203,-- 更新钻石数量
    S_Update_Gold                            = 204,-- 更新金币数量
    CS_Update_FreeGold                       = 205,-- 更新免费金币(马甲小游戏金币扣除增加协议)
    S_Update_RoomCard                        = 206,-- 更新房卡数量
    S_Update_Charge                          = 207,-- 更新充值人名币
    CS_Convert_Gold                          = 208,-- 兑换金币
    CS_Convert_RoomCard                      = 209,-- 兑换房卡

    CS_BIND_ACCOUNT                          = 213,-- 绑定账号交互
    CS_Store_Upgrade_Vip                     = 214,-- 再充值多少钱升VIP等级
    CS_Contact_CustomerService               = 215,-- 玩家联系客服
    CS_YYIM_REQUEST                          = 216,-- 语音请求
    CS_YYIM_FORWARDING                       = 217,-- 语音转发

    CS_TEA_JOIN                              = 218,-- 加入茶馆
    S_TEA_JOIN_NOTIFY                        = 219,-- (馆主)新人申请
    CS_TEA_CREATE                            = 220,-- 创建茶馆
    CS_TEA_INFO                              = 221,-- 茶馆详情
    CS_TEA_MEMBER                            = 222,-- 茶馆成员列表
    CS_TEA_UPGRADE                           = 223,-- (馆主)升级茶馆
    CS_TEA_APPLY                             = 224,-- (馆主)获取申请列表
    CS_TEA_APPLY_HANDLE                      = 225,-- (馆主)处理申请列表
    S_TEA_APPLY_FEEDBACK                     = 226,-- (申请者)收到申请处理反馈
    S_TEA_NEW_MEMBER                         = 227,-- 新人加入工会
    CS_TEA_APPLY_ALL                         = 228,-- (馆主)全部同意加入申请
    CS_TEA_DEL_MEMBER                        = 229,-- (馆主)踢出某位成员
    S_TEA_KICKOUT                            = 230,-- 玩家被提出工会
    CS_TEA_QUIT                              = 231,-- 玩家退出公会
    CS_TEA_ROOMLIST                          = 232,-- 茶馆牌局列表
    S_TEA_QUIT_MEMBER                        = 233,-- 馆主收到玩家主动退出
    CS_INVITE_FREE_MEMBER                    = 234,-- 请求空闲玩家列表
    CS_INVITE_FREE_GAME                      = 235,-- 邀请空闲玩家游戏
    S_INVITE_PLAY                            = 236,-- 玩家收到被邀请一起游戏
    CS_DaiLiRechargeInfo                     = 237,-- 请求代理充值信息
    CS_ComplaintAgent                        = 238,-- 玩家请求投诉代理

    CS_NEW_REWARD                            = 240,-- 玩家领取新人奖励
    CS_IP_LOCATION                           = 241,-- 玩家最近登陆IP位置信息
    CS_WECHAT_SHARE                          = 242,-- 玩家分享微信成功
    CS_HALL_SHARE_URL                        = 243,-- 玩家请求大厅分享链接

    CS_ADVERTISE_INFO                        = 244,-- 公告协议

    CS_Player_Recharge                       = 251,-- 玩家充值
    CS_Player_Extract                        = 252,-- 玩家提现
    CS_Player_BindingBankCard                = 253,-- 玩家绑定银行卡
    CS_Player_BankInformation                = 254,-- 玩家银行信息
    CS_Player_BillDetailed                   = 255,-- 玩家账单信息
    CS_Player_ExtractInfo                    = 256,-- 玩家点击提现按钮
    CS_Player_BankiCardInfo                  = 257,-- 请求玩家绑定银行卡信息
    CS_Player_ZFBInfo                        = 258,-- 请求玩家支付宝绑定信息
    CS_Player_BindingZhiFuBao                = 259,-- 玩家绑定支付宝
    CS_Player_RechargeInterfaceInfo          = 260,-- 玩家请求充值界面信息
    CS_Official_Recharge                     = 261,-- 玩家提交官方充值订单
    CS_Official_OrderInformation             = 262,-- 玩家请求订单信息

    S_Player_BecomeAgent                     = 271,-- [代理模块]玩家成为代理提示
    CS_Open_MyAgency                         = 272,-- [代理模块]玩家获取代理详情
    CS_Get_AgencyCommission                  = 273,-- [代理模块]玩家提取佣金
    CS_Agency_Extract_Data                   = 274,-- [代理模块]玩家佣金提取详情列表
    CS_Open_MenberDetail                     = 275,-- [代理模块]玩家代理会员详情

    S_Notify_FalseDeal_Start                 = 331, -- 进入假发牌状态
    S_Notify_Wait_State                      = 352, -- 进入等待状态
    S_Notify_Shuffle_State                   = 353, -- 进入洗牌状态
    S_Notify_Cut_State                       = 354, -- 进入切牌状态
    S_Notify_Play_Cut_State                  = 355, -- 进入切牌动画
    S_Notify_Bet_State                       = 356, -- 进入押注状态
    S_Notify_Deal_State                      = 357, -- 进入发牌状态
    S_Notify_Long_Check_State                = 358, -- 进入龙看牌
    S_Notify_Hu_Check_State                  = 359, -- 进入虎看牌
    S_Notify_Settlement_State                = 360, -- 进入结算状态
    S_Notify_Check1_Over                     = 361, -- 龙看牌结束
    S_Notify_Check2_Over                     = 362, -- 虎看牌结束
    
    CS_Enter_Room                            = 400, -- 进入房间
    CS_Exit_Room                             = 401, -- 请求离开房间
    CS_Create_Room                           = 402, -- 创建Vip房间
    CS_Bet                                   = 403, -- 下注
    CS_Check_Card_Process                    = 404, -- 客户端看牌过程
    CS_Checked_Card                          = 405, -- 客户端明牌数量
    S_Bet_Rank_List                          = 406, -- 押注排行榜
    CS_BRJH_Hall_Request_Statistics          = 407, -- [百人金花]请求大厅房间统计信息
    S_BRJH_Game_Statistics                   = 408, -- [百人金花]游戏房间统计信息
    S_BRJH_Game_Append_Statistics            = 409, -- [百人金花]游戏房间统计信息追加
        
    CS_Request_Relative_Room                 = 410, -- 请求关联的房间列表
    S_Set_Bet_First                          = 411, -- 设置龙虎排行榜第一名
    S_Set_Game_Data                          = 412, -- 服务器设置游戏数据        
    CS_Vip_Start_Game                        = 413, -- 请求开始VIP房间游戏
    S_Notify_Game_End                        = 414, -- 通知房间局数已结束    
    CS_Request_Continue_Game                 = 415, -- 请求续局    
    S_Notify_Game_Player_Count               = 416, -- 服务器设置房间内人数
    CS_Up_Banker                             = 417, -- 申请上庄    
    CS_Up_Banker_List                        = 418, -- 请求上庄列表
    
    S_Notify_Win_Gold                        = 420, -- 通知赢钱数量
    S_Update_Banker                          = 421, -- 更新庄家信息
    S_Update_Banker_Gold                     = 422, -- 通知更新庄家金币
    CS_Cut_Card                              = 423, -- 庄家切牌
    CS_Request_Role_List                     = 424, -- 请求玩家列表
    CS_Player_Cut_Type                       = 425, -- 玩家搓牌扑克花色尖叫
    CS_Player_Icon_Change                    = 426, -- 玩家头像Icon切换
    CS_Player_YuYinChat                      = 427, -- 玩家语音聊天    
    CS_Apply_Down_Banker                     = 428, -- 庄家申请下庄
    CS_Apply_Banker_State                    = 429, -- 庄家请求当前的状态
    S_Room_Change                            = 430, -- 对战房间3局换桌转换提示

    CS_Player_BeneFit                        = 431, -- 踢出房间
    --CS_Player_NewToStarcom                   = 432, --新手大放送
    CS_JH_XYZPRoomList                       = 432, --请求转盘人数信息
    CS_Daily_Wheel_Info                      = 433, --每日轮盘信息
    CS_Daily_Wheel_Reward                    = 434, -- 每日轮盘奖励领取
    CS_CDK_Reward                            = 435, -- 领取CDK奖励
    CS_IPHONE_INFO                           = 436, -- 抽IPHONE信息
    CS_IPHONE_Reward                         = 437,-- 抽IPHONE奖励领取
    CS_Wheel_Record                          = 438, -- 获取玩家幸运转盘抽奖纪录
    CS_Exit_Wheel                            = 439, -- 请求离开幸运转盘
    S_Wheel_WinningInfo                      = 440, -- 每日转盘获奖玩家信息
    S_Car_WinningInfo                        = 441, -- 奔驰宝马中奖玩家信息
    S_SSC_WinningInfo                        = 442, -- 时时彩中奖玩家信息
    CS_BRJH_Hall_Request_Statistics_New8     = 443, -- [百人金花]游戏房间统计信息追加 新包(GameID=8)

    
    ------------------------------------------------------游戏周边协议从这里开始定义--------------------------------------------

    S_Add_MoveNotice                         = 500,    -- 服务器通知添加跑马灯消息
    CS_SmallHorn                             = 501,    -- 请求发送小喇叭
    CS_SEND_EMAIL                            = 502,    -- 客户端请求发送邮件
    CS_CHECK_ACCOUNTID                       = 503,    -- 请求检查账号是否有效
    CS_OTHER_PLAYER_INFO                     = 504,    -- 请求其他玩家信息
    C_CHANGE_EMAIL_TO_READED                 = 505,    -- 请求改变邮件状态为已读
    CS_GET_EMAIL_REWARD                      = 506,    -- 请求领取邮件内奖励
    CS_ADD_EMAILS                            = 507,    -- 服务器发送邮件给客户端
    CS_DELETE_EMAIL                          = 508,    -- 客户端请求删除邮件
    CS_MODIFY_NAME                           = 509,    -- 客户端请求修改昵称
    CS_ALL_RANK                              = 510,    -- 请求产排行榜数据
    C_RETURN_GAME                            = 511,    -- 客户端从切出状态返回游戏(**作废**)
    CS_PAOPAO_CHAT                           = 512,    -- 房间聊天泡泡交互协议
    CS_Request_Game_History                  = 513,    -- 请求游戏历史记录
    --------------------------------------------------------------------------------------------

    CS_Invite_Code                           = 601, -- 邀请码
    S_Update_Promoter                        = 602, -- 更新推广员状态
    CS_SALESMAN_INFO                         = 603, -- 获取推广员信息

    --=========================红包接龙相关协议==================================
    CS_HB_RoomList                           = 711,  -- (红包接龙)请求房间列表
    CS_HB_Create_Room                        = 712,  -- (红包接龙)请求创建房间
    CS_HB_Enter_Room                         = 713,  -- (红包接龙)请求进入房间
    CS_HB_Room_History                       = 714,  -- (红包接龙)历史房间记录列表
    S_HB_Set_Game_Date                       = 715,  -- (红包接龙)反馈房间详细信息
    CS_HB_Leave_Room                         = 716,  -- (红包接龙)离开房间
    S_HB_Next_State                          = 717,  -- (红包接龙)通知房间下一阶段
    CS_HB_Banker_FaHongBao                   = 721,  -- (红包接龙)庄家请求发红包
    CS_HB_Player_QiangHongBao                = 722,  -- (红包接龙)玩家请求抢红包
    S_HB_Add_Player                          = 724,  -- (红包接龙)通知新增一个玩家
    S_HB_Delete_Player                       = 725,  -- (红包接龙)通知删除一个玩家
    CS_PPHB_OnlineNumber                     = 729,  -- (匹配红包)请求房间在线人数

    --===================================【推筒子协议】--------------------------------------------------------
    CS_TTZ_PIPEI_ONLINE                      = 740,              -- (匹配推筒子)房间在线人数
    CS_TTZ_ZUJU_ROOM_LIST                    = 741,              -- (组局推筒子)请求房间列表
    CS_TTZ_ZUJU_CREATE                       = 742,              -- (组局推筒子)创建房间
    CS_TTZ_ZUJU_ENTER_ROOM                   = 743,              -- (推筒子)进入房间
    CS_TTZ_PIPEI_ENTER_ROOM                  = 744,              -- (匹配推筒子)进入房间
    CS_TTZ_LEAVE_ROOM                        = 745,              -- (组局推筒子)离开房间
    S_TTZ_ROOM_DATA                          = 746,              -- (组局推筒子)获得房间数据
    S_TTZ_NEXT_STATE                         = 747,              -- (组局推筒子)房间进入一下状态
    S_TTZ_ADD_PLAYER                         = 748,              -- (组局推筒子)添加玩家
    S_TTZ_REMOVE_PLAYER                      = 749,              -- (组局推筒子)删除玩家
    CS_TTZ_READY                             = 750,              -- (组局推筒子)玩家准备
    CS_TTZ_QIANG_ZHUANG                      = 751,              -- (组局推筒子)抢庄
    CS_TTZ_BETTING                           = 752,              -- (组局推筒子)玩家下注倍率
    CS_TTZ_KANPAI                            = 753,              -- (组局推筒子)完成看牌通知

    --===================================【麻将协议】--------------------------------------------------------
    CS_MJ_ZUJU_ROOM_LIST                     = 761,              -- (组句麻将)请求房间列表
    CS_MJ_ZUJU_CREATE                        = 762,              -- (组句麻将)请求创建房间
    CS_MJ_ZUJU_ENTER_ROOM                    = 763,              -- (组局麻将)请求进入房间
    CS_MJ_LEAVE_ROOM                         = 764,              -- (组局麻将)请求离开房间
    S_MJ_ROOM_DATA                           = 765,              -- (组句麻将)获得房间数据
    S_MJ_NEXT_STATE                          = 766,              -- (组句麻将)房间进入下一状态
    S_MJ_ADD_PLAYER                          = 767,              -- (组局麻将)添加玩家
    S_MJ_REMOVE_PLAYER                       = 768,              -- (组局麻将)删除玩家
    CS_MJ_Prepare_Game                       = 769,              -- (组局麻将)准备游戏
    CS_MJ_DingQue                            = 770,              -- (组句麻将)玩家请求定缺
    CS_MJ_PlayerChuPai                       = 771,              -- (组局麻将)玩家出牌
    CS_MJ_PengGangHu                         = 772,              -- (组局麻将)玩家请求碰杠胡(1碰2杠3胡4过)
    S_MJ_MoPai                               = 773,              -- (组局麻将)玩家摸牌
    S_MJ_UpdateGold                          = 774,              -- (组局麻将)玩家更新金币
    CS_MJ_TheBureauGameWater                 = 775,              -- (组局麻将)玩家请求本局流水信息
    CS_MJ_GameWater                          = 776,              -- (组局麻将)玩家请求房间总流水
    CS_MJ_GameRank                           = 777,              -- (组局麻将)玩家请求房间排行
    S_MJ_PLAYERTRANSPORT                     = 778,              -- (组局麻将)玩家认输
    S_MJ_QIANGGANGHU                         = 779,              -- (组局麻将)有玩家抢杠胡

    --=========================组局厅相关协议=====================================
    CS_Enter_JZ_RoomID                       = 800,  -- 请求进入房间
    CS_JH_Create_Room                        = 801,  -- 组局厅请求创建房间
    CS_JH_Enter_Room1                        = 802,  -- 组局厅请求进入组局房间
    CS_JH_Enter_Room2                        = 803,  -- 组局厅请求进入闷鸡房间
    S_JH_Set_Game_Data                       = 804,  -- 组局厅反馈房间详细信息
    S_JH_Next_State                          = 805,  -- 组局厅通知房间下一阶段
    S_JH_Add_Player                          = 806,  -- 组局厅通知新增一个玩家
    S_JH_Delete_Player                       = 807,  -- 组局厅通知删除一个玩家
    CS_JH_Exit_Room                          = 808,  -- 组局厅请求离开房间(以及反馈)
    CS_JH_Ready                              = 809,  -- 组局厅玩家准备(以及反馈)
    CS_JH_Betting                            = 810,  -- 组局厅玩家下注(加注,跟注)
    CS_JH_VS_Card                            = 811,  -- 组局厅玩家请求比牌(反馈)
    CS_JH_Drop_Card                          = 812,  -- 组局厅玩家请求弃牌(反馈广播)
    CS_JH_Look_Card                          = 813,  -- 组局厅玩家请求看牌(反馈广播)
    S_JH_Notify_Look_Card                    = 814,  -- 服务器广播**看牌
    CS_JH_ZuJuRoomList                       = 815,  -- 组局厅房间列表(请求==反馈)
    CS_JH_MenJiRoomOnlineCount               = 816,  -- 焖鸡厅各个房间在线人数(请求==反馈)
    CS_JH_Change_MenJiRoom                   = 817,  -- 焖鸡厅玩家请求换桌(请求==反馈)
    S_JH_Kick_Out                            = 818,  -- 玩家金币不足被踢出房间
    S_JH_Gold_Update                         = 820,  -- 更新玩家金币

    --TUDOU
    CS_ShiShiCaiInRoom                       = 830,  -- 进入时时彩房间时信息反馈
    
    CS_Lottery_Info                          = 831,  -- 请求时时彩信息
    CS_Lottery_Bet                           = 832,  -- 请求时时彩下注
    S_Bet_Victory                            = 833,  -- 服务器发送玩家胜利消息
    C_QuitLottery                            = 834,  -- 退出时时彩界面

    CS_SSCRoomPlayerList                    = 836,  -- 时时彩请求玩家列表
    --TUDOU
    CS_BCBMRoomPlayerList                    = 840,  -- 奔驰宝马请求玩家列表
    CS_CarInfoInRoom                         = 842,  -- 玩家进入奔驰宝马时请求信息

    CS_CarPrizeDraw_BankerListInfo           = 837,  -- 请求奔驰宝马界面庄家列表信息
    C_CarPrizeDraw_Quit                      = 838,  -- 退出奔驰宝马界面
    CS_CarPrizeDraw_Info                     = 843,  -- 请求奔驰宝马信息
    CS_CarPrizeDraw_Bet                      = 844,  -- 请求奔驰宝马下注
    CS_CarPrizeDraw_DoBanker                 = 845,  -- 请求奔驰宝马上庄
    CS_CarPrizeDraw_NotDoBanker              = 846,  -- 请求奔驰宝马下庄
    S_CarPrizeDraw_Winning                   = 847,  -- 反馈奔驰宝马押中得奖
    S_CarPrizeDraw_ChangeBanker              = 848,  -- 反馈奔驰宝马庄家更换
    S_CarPrizeDraw_BankerSettlement          = 849,  -- 反馈奔驰宝马庄家结算

    CS_JH_BMBCRoomList                       = 1152, --请求奔驰宝马的房间列表在线人数
    S_KickOutBankerList                      = 1154, -- 玩家被踢出上庄列表



    ---------------------------组局牛牛相关协议--------------------------------------------------
    CS_NN_RoomList                           = 850,  -- (组局牛牛)请求房间列表
    CS_NN_Room_Create                        = 851,  -- (组局牛牛)请求创建房间
    CS_NN_Enter_Room                         = 852,  -- (组局牛牛)进入房间
    CS_NN_Leave_Room                         = 853,  -- (组局牛牛)离开房间
    S_NN_Get_Game_Data                       = 854,  -- (组局牛牛)发送房间详细数据
    S_NN_Enter_Next_State                    = 855,  -- (组局牛牛)通知房间下一阶段
    S_NN_AddPlayer                           = 856,  -- (组局牛牛)通添加玩家
    S_NN_DeletePlayer                        = 857,  -- (组局牛牛)通删除玩家
    CS_NN_Ready                              = 858,  -- (组局牛牛)请求开始组局房间(准备开始)
    CS_NN_QiangZhuang                        = 859,  -- (组局牛牛)抢庄请求
    CS_NN_JiaBei                             = 860,  -- (组局牛牛)选择加倍
    CS_NN_CuoPai                             = 861,  -- (组局牛牛)搓牌完成请求和通知
    CS_NN_Room_History                       = 862,  -- (组局牛牛)历史房间记录列表
    CS_NNPP_Room_OnLine                      = 863,  -- (牛牛匹配)在线玩家数量
    CS_NNPP_Enter_Room                       = 864,  -- (牛牛匹配)进入房间

    --------------------------玩牌抽话费相关协议--------------------------------------------------
    S_Task_Fail                              = 880,  -- 任务失败
    S_Task_Info                              = 881,  -- 任务通知
    S_Task_Success                           = 882,  -- 任务完成
    S_Update_TaskCompleteNumber              = 883,  -- 任务完成次数
    CS_LuckDraw_Bill                         = 884,  -- 请求抽话费
    CS_Bill_Exchange                         = 885,  -- 请求兑换话费
    CS_Bill_Exchange_Info                    = 886,  -- 请求兑换话费信息
    S_PrizeInfo                              = 887,  -- 请求打开领奖啦界面
    
    --------------------------------------------------------------------------------------------
    CS_Buy_Goods                             = 900, -- 购买商品


    --------------------------------------------------------------------------------------------
    CS_PlayerSendInfo                        = 1008, -- 玩家发送消息
    S_SendToPlayer                           = 1009, --服务器回复玩家的消息
    CS_PlayerPullInfo                        = 1010, --玩家拉取历史消息
    CS_PlayerOpenUI                          = 1011, --玩家打开界面
    CS_PlayerCloseUI                         = 1012, --玩家关闭界面
    S_NoticeNew                              = 1019, --服务器发来的新的公告

    S_Playing_Room                           = 1155, -- 玩家正在该房间进行游戏

    CS_ADVERTISE_NAME                        = 1156, -- 公告标签协议

    ---------------------------匹配跑的快相关协议--------------------------------------------------
    CS_PDKPP_Room_OnLine                     = 1200,  -- (匹配跑的快)请求跑的快房间列表在线人数
    CS_PDK_Ready                             = 1203,  -- (匹配跑的快)玩家发送准备请求
    CS_PDK_PlayerChuPai                      = 1206,  -- (匹配跑的快)玩家请求出牌
    CS_PDK_Leave_Room                        = 1208,  -- (匹配跑的快)请求离开跑的快房间
    S_PDK_Enter_Next_State                   = 1210,  -- (匹配跑的快)通知房间下一阶段
    S_PDK_DeletePlayer                       = 1211,  -- (匹配跑的快)通知删除玩家
    CS_PDKPP_Enter_Room                      = 1212,  -- (匹配跑的快)请求进入跑的快匹配房间
    S_PDK_AddPlayer                          = 1213,  -- (匹配跑的快)通知添加玩家
    S_PDK_GAME_DATA                          = 1214,  -- (匹配跑的快)发送房间详细数据
    CS_PDK_ROBOT                             = 1217,  -- (匹配跑的快)请求托管
    CS_PDK_Prompt                            = 1218,  -- (匹配跑的快)请求提示
    S_PDK_BombChangeGold                     = 1219,  -- (匹配跑的快)炸弹实时结算通知


    ---------------------------[龙虎斗]相关协议--------------------------------------------------
    CS_LHD_Hall_Room                         = 1251,  -- [龙虎斗]大厅房间列表信息
    CS_LHD_Enter_Room                        = 1252,  -- [龙虎斗]进入房间
    S_LHD_GameData                           = 1253,  -- [龙虎斗]房间详情
    S_LHD_Game_Statistics                    = 1254,  -- [龙虎斗]房间统计路单详情(全局)
    S_LHD_Game_Append_Statistics             = 1255,  -- [龙虎斗]追加房间统计路单
    CS_LHD_Exit_Room                         = 1256,  -- [龙虎斗]退出房间
    S_LHD_Kick_Room                          = 1257,  -- [龙虎斗]被提出房间
    S_LHD_Next_State                         = 1258,  -- [龙虎斗]游戏下一状态
    CS_LHD_Bet                               = 1259,  -- [龙虎斗]玩家下注
    S_LHD_Game_Player_Count                  = 1260,  -- [龙虎斗]设置房间内玩家人数
    S_LHD_Update_Banker                      = 1261,  -- [龙虎斗]更新庄家信息
    S_LHD_Update_Banker_Gold                 = 1262,  -- [龙虎斗]更新庄家金币信息
    CS_LHD_Request_Role_List                 = 1263,  -- [龙虎斗]获取房间玩家列表
    CS_LHD_Up_Banker_List                    = 1264,  -- [龙虎斗]获取上庄列表
    CS_LHD_Up_Banker                         = 1265,  -- [龙虎斗]玩家请求上庄
    CS_LHD_Down_Banker                       = 1266,  -- [龙虎斗]玩家请求下庄
    CS_LHD_Hall_Room_New8                    = 1267,  -- [龙虎斗]大厅房间列表信息新包(GameID = 8)

    ---------------------------[百家乐]相关协议--------------------------------------------------
    CS_BJL_Hall_Room                         = 1271,  -- [百家乐]大厅房间列表信息
    CS_BJL_Enter_Room                        = 1272,  -- [百家乐]进入房间
    S_BJL_GameData                           = 1273,  -- [百家乐]房间详情
    S_BJL_Game_Statistics                    = 1274,  -- [百家乐]房间统计路单详情(全局)
    S_BJL_Game_Append_Statistics             = 1275,  -- [百家乐]追加房间统计路单
    CS_BJL_Exit_Room                         = 1276,  -- [百家乐]退出房间
    S_BJL_Next_State                         = 1277,  -- [百家乐]游戏下一状态
    CS_BJL_Bet                               = 1278,  -- [百家乐]玩家下注
    S_BJL_Game_Player_Count                  = 1279,  -- [百家乐]设置房间内玩家人数
    CS_BJL_Request_Role_List                 = 1280,  -- [百家乐]获取房间玩家列表
    CS_BJL_Hall_Room_New8                    = 1281,  -- [百家乐]大厅房间列表信息新包(GameID = 8)

    ------------------------------ 房间维护推送协议-----------------------------------
    S_RoomMaintainNews                       = 1504,  -- 房间维护推送协议
    CS_RoomListRoommTypeInfo                 = 1505,  -- 请求房间列表配置信息

    ------------------------------ 余额宝相关信息 -----------------------------------
    CS_YueBaoPassWord                        = 1601,  -- 余额宝初次设置密码
    CS_PassWordYanZheng                      = 1602,  -- 余额宝金额转出身份确认
    CS_ChangeYueBaoPassWord                  = 1604,  -- 余额宝修改密码
    CS_YueBaoTurnOutValue                    = 1605,  -- 余额宝转出额度
    CS_YueBaoIntoValue                       = 1606,  -- 余额宝存入金额
    CS_YueBaoInvestmentType                  = 1607,  -- 余额宝投资类型
    CS_YueBaoLineTime                        = 1608,  -- 余额宝投资买入界面信息
    CS_YueBaoDetailed                        = 1610,  -- 余额宝明细
    CS_YueBaoMyBuyInfo                       = 1611,  -- 余额宝我的买入
    CS_YueBaoSellOut                         = 1612,  -- 余额宝卖出
    CS_YuEBao_Info                           = 1613,  -- 余额宝主页信息
}