<?php

namespace Home\Controller;
class DailyController extends BaseController
{

    //日报
    public function dayReport()
    {
        $where_data = array();
        $_where = ['1000' => '1000'];
        $_luiCun_where = [];
        $data = array();
        $channel_list = array();
        $platform = C('platform');
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }

        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }

        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->assign('channel_list', $channel_list);
            $this->assign('platform', $platform);
            $this->assign('apk', $apk);
            $this->show();
            return;
        }
        $data['all_start'] = time();
        $data['page'] = I('get.page/d');
        if (I('get.platform/d') > 0) {
            // $where_data['gd_PlatformID'] = I('get.platform/d');
            $_where['gd_PlatformID'] = I('get.platform/d');
            $_luiCun_where['log_PlatformID'] = I('get.platform/d');
            $where['bk_platform_id'] = I('get.platform/d');
            $where_data['log_ChannelID'] = I('get.channe/d');
        }
        if (I('get.channe/d') > 0) {
            // $where_data['gd_ChannelID'] = I('get.channe/d');
            $_where['gd_ChannelID'] = I('get.channe/d');
            $_luiCun_where['log_ChannelID'] = I('get.channe/d');
            $where['bk_channel_id'] = I('get.channe/d');
        }
        if (I('get.apkid/d') > 0) {
            // $where_data['gd_ChannelID'] = I('get.channe/d');
            $_where['gd_ApkID'] = I('get.apkid/d');
            $_luiCun_where['log_ApkID'] = I('get.apkid/d');
            $where['bk_apk_id'] = I('get.apkid/d');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $start_time = strtotime(I('get.start_time'));
            $end_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $start_time = 1;
            }
            if (I('get.end_time') == '') {
                $end_time = time();
            }
            $where_data['log_Time'] = array('between', array($start_time, $end_time));
            $where['bk_data'] = array('between', array($start_time, $end_time));
        }

        $where_data['log_LiuCunLvType'] = 1;
        $where_data += $_luiCun_where;

        $field = 'bk_data, bk_channel_id, bk_platform_id, bk_apk_id, sum(bk_new_device) as bk_new_device, sum(bk_reg_number) as bk_reg_number, sum(bk_new_reg_number_rate) as bk_new_reg_number_rate, sum(bk_active_number) as bk_active_number, sum(bk_payment_amount) as bk_payment_amount, sum(bk_payment_user_number) as bk_payment_user_number, sum(bk_payment_number) as bk_payment_number, sum(bk_new_payment_user_number) as bk_new_payment_user_number, sum(bk_new_payment_amount) as bk_new_payment_amount, sum(bk_agent_payment_amount) as bk_agent_payment_amount, sum(bk_agent_payment_user_number) as bk_agent_payment_user_number, sum(bk_new_agent_payment_amount) as bk_new_agent_payment_amount, sum(bk_new_agent_payment_user_number) as bk_new_agent_payment_user_number, sum(bk_tixian_amount) as bk_tixian_amount, sum(bk_tixian_user) as bk_tixian_user, sum(bk_new_tixian_amount) as bk_new_tixian_amount, sum(bk_new_tixian_user) as bk_new_tixian_user, sum(bk_luichun1) as bk_luichun1, sum(bk_luichun2) as bk_luichun2, sum(bk_luichun6) as bk_luichun6 ';
        $data['history_start'] = time();
        $rows = M('bk_day_report', 'bk_', 'DB_CONFIG1')->field($field)->page(I('get.page/d'))->limit(I('get.limit/d'))->where($where)->group('bk_data')->order('bk_data desc')->select();
        $data['history_end'] = time() - $data['history_start'];
        $filed = 'log_Time, sum(log_TodayRegister) as log_TodayRegister, sum(log_TodayActive) as log_TodayActive, sum(log_liucunlv1) as log_liucunlv1, sum(log_liucunlv2) as log_liucunlv2, sum(log_liucunlv6) as log_liucunlv6';

        $data['liucunlvs_start'] = time();
        $liucunRows = M('bk_liucunlvs', 'bk_', 'DB_CONFIG1')->field($filed)->where($where_data)->group("log_Time")->order('log_Time desc')->select();
        foreach ($liucunRows as $row) {
            $liucun_data[$row['log_time']]['bk_luichun1'] = $row['log_liucunlv1'];
            $liucun_data[$row['log_time']]['bk_luichun2'] = $row['log_liucunlv2'];
            $liucun_data[$row['log_time']]['bk_luichun6'] = $row['log_liucunlv6'];
            $liucun_data[$row['log_time']]['bk_reg_number'] = $row['log_todayregister'];
        }

        $data['liucunlvs_end'] = time() - $data['liucunlvs_start'];
        $subQuery = M('bk_day_report', 'bk_', 'DB_CONFIG1')->where($where)->group('bk_data')->buildSql();
        $data['count'] = M('bk_day_report', 'bk_', 'DB_CONFIG1')->table($subQuery . ' a')->count();
        $todayonline = 0;
        foreach ($rows as $row) {
            $bk_data = $row['bk_data'];
            $row['bk_data'] = date('Y-m-d', $row['bk_data']);
            if ($row['bk_data'] == date('Y-m-d')) {
                $data['today_start'] = time();
                $row = dayReport($row['bk_data'], $_where, $_luiCun_where);
                $data['today_end'] = time() - $data['today_start'];
            }

            if (intval($_where['gd_PlatformID']) == 0) {
                $row['bk_platform_id'] = "全部";
            } else {
                $row['bk_platform_id'] = $platform[$_where['gd_PlatformID']];
            }

            if (intval($_where['gd_ApkID']) == 0) {
                $row['bk_apk_id'] = "全部";
            } else {
                $row['bk_apk_id'] = $apk[$_where['gd_ApkID']];
            }

            if (intval($_where['gd_ChannelID']) == 0) {
                $row['bk_channel_id'] = "全部";
            } else {
                $row['bk_channel_id'] = $channel_list[$_where['gd_ChannelID']];
            }

            if (strtotime($row['bk_data']) !== strtotime(date('Y-m-d'))) {
                $row['ok'] = $row['bk_data'] . '|' . date('Y-m-d');
                $row['bk_new_reg_number_rate'] = sprintf("%.2f %%", $row['bk_new_reg_number_rate'] / $row['bk_reg_number'] * 100);
                $row['bk_new_agent_payment_amount'] = ($row['bk_new_agent_payment_amount'] / 10000);
                $row['bk_agent_payment_amount'] = ($row['bk_agent_payment_amount'] / 10000);
                $row['bk_luichun1'] = sprintf("%.2f %%", $liucun_data[$bk_data]['bk_luichun1'] / $liucun_data[$bk_data]['bk_reg_number'] * 100);
                $row['bk_luichun2'] = sprintf("%.2f %%", $liucun_data[$bk_data]['bk_luichun2'] / $liucun_data[$bk_data]['bk_reg_number'] * 100);
                $row['bk_luichun6'] = sprintf("%.2f %%", $liucun_data[$bk_data]['bk_luichun6'] / $liucun_data[$bk_data]['bk_reg_number'] * 100);
            }

            $row['bk_agent_payment_amount'] = sprintf("%d", $row['bk_agent_payment_amount']);
            $row['bk_payment_amount'] = sprintf("%d", $row['bk_payment_amount']);

            $row['bk_arppu'] = sprintf("%.2f", $row['bk_payment_amount'] / $row['bk_payment_user_number']); //ARPPU
            $row['bk_arpu'] = sprintf("%.2f", $row['bk_payment_amount'] / $row['bk_active_number']); //ARPU
            $row['bk_payment_rate'] = sprintf("%.2f %%", $row['bk_payment_user_number'] / $row['bk_active_number'] * 100); //付费率

            $row['bk_new_payment_amount'] = sprintf("%d", $row['bk_new_payment_amount']);
            $row['bk_tixian_amount'] = sprintf("%d", $row['bk_tixian_amount']);
            $row['bk_new_tixian_amount'] = sprintf("%d", $row['bk_new_tixian_amount']);
            $a_start = time();
            $acu = M('bk_todayonline')->field('(sum(log_Online)/1440) as acu')->where(['log_LiuCunLvType' => 1, 'log_Time' => array('between', array(strtotime($row['bk_data']), strtotime($row['bk_data']) + 24 * 60 * 60))])->find();
            $row['bk_acu'] = intval($acu['acu']);
            $pcu = M('bk_todayonline')->where(['log_Time' => array('between', array(strtotime($row['bk_data']), strtotime($row['bk_data']) + 24 * 60 * 60))])->max('log_Online');
            $row['bk_pcu'] = intval($pcu);
            $todayonline += time() - $a_start;
            if (0 == I('get.isExecl/d')) $row['day_all_reg_channe_url'] = U('Daily/dayAllRegChanne', ['date' => $row['bk_data']]);
            $data['data'][] = $row;
        }
        $data['acu_pcu'] = $todayonline;

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.daily_dayReport'), $data['data'], '运营日报');
        }
        $data['all_end'] = time() - $data['all_start'];
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //某日所有渠道所有注册信息(按渠道分类)
    public function dayAllRegChanne()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }

        //GET信息
        $start_time = I('get.date');
        //$end_time = date('Y-m-d', strtotime('+1 day',strtotime($start_time)));

        $where['bk_data'] = strtotime($start_time);
        //$rows = M("bk_loginout")->where($where)->group('gd_ChannelID')->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        $field = 'bk_data, bk_channel_id, bk_platform_id, bk_apk_id, sum(bk_new_device) as bk_new_device, sum(bk_reg_number) as bk_reg_number, sum(bk_new_reg_number_rate) as bk_new_reg_number_rate, sum(bk_active_number) as bk_active_number, sum(bk_payment_amount) as bk_payment_amount, sum(bk_payment_user_number) as bk_payment_user_number, sum(bk_payment_number) as bk_payment_number, sum(bk_new_payment_user_number) as bk_new_payment_user_number, sum(bk_new_payment_amount) as bk_new_payment_amount, sum(bk_agent_payment_amount) as bk_agent_payment_amount, sum(bk_agent_payment_user_number) as bk_agent_payment_user_number, sum(bk_new_agent_payment_amount) as bk_new_agent_payment_amount, sum(bk_new_agent_payment_user_number) as bk_new_agent_payment_user_number, sum(bk_tixian_amount) as bk_tixian_amount, sum(bk_tixian_user) as bk_tixian_user, sum(bk_new_tixian_amount) as bk_new_tixian_amount, sum(bk_new_tixian_user) as bk_new_tixian_user, sum(bk_luichun1) as bk_luichun1, sum(bk_luichun2) as bk_luichun2, sum(bk_luichun6) as bk_luichun6 ';

        $rows = M('bk_day_report', 'bk_', 'DB_CONFIG1')->field($field)->where($where)->group('bk_channel_id')->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        $subQuery = M('bk_day_report', 'bk_', 'DB_CONFIG1')->where($where)->group('bk_channel_id')->buildSql();
        $data['count'] = M('bk_day_report', 'bk_', 'DB_CONFIG1')->table($subQuery . 'a')->count();

        $filed = 'log_ChannelID, log_Time, sum(log_TodayRegister) as log_TodayRegister, sum(log_TodayActive) as log_TodayActive, sum(log_liucunlv1) as log_liucunlv1, sum(log_liucunlv2) as log_liucunlv2, sum(log_liucunlv6) as log_liucunlv6';
        $liucunRows = M('bk_liucunlvs', 'bk_', 'DB_CONFIG1')->field($filed)->where(['log_LiuCunLvType' => 1, 'log_Time' => strtotime($start_time)])->group("log_ChannelID")->select();
        foreach ($liucunRows as $row) {
            $liucun_data[$row['log_channelid']]['bk_luichun1'] = $row['log_liucunlv1'];
            $liucun_data[$row['log_channelid']]['bk_luichun2'] = $row['log_liucunlv2'];
            $liucun_data[$row['log_channelid']]['bk_luichun6'] = $row['log_liucunlv6'];
            $liucun_data[$row['log_channelid']]['bk_reg_number'] = $row['log_todayregister'];
        }
        foreach ($rows as $row) {
            $bk_data = $row['bk_data'];
            $row['bk_data'] = date('Y-m-d', $row['bk_data']);
            $row['bk_platform_id'] = '全部'; //平台
            $row['channel'] = $channel_list[$row['bk_channel_id']]; //注册渠道
            $row['bk_new_reg_number_rate'] = sprintf("%.2f %%", $row['bk_new_reg_number_rate'] / $row['bk_reg_number'] * 100);
            $row['bk_new_agent_payment_amount'] = ($row['bk_new_agent_payment_amount'] / 10000);
            $row['bk_agent_payment_amount'] = ($row['bk_agent_payment_amount'] / 10000);
            $row['bk_luichun1'] = sprintf("%.2f %%", $liucun_data[$bk_data]['bk_luichun1'] / $liucun_data[$bk_data]['bk_reg_number'] * 100);
            $row['bk_luichun2'] = sprintf("%.2f %%", $liucun_data[$bk_data]['bk_luichun2'] / $liucun_data[$bk_data]['bk_reg_number'] * 100);
            $row['bk_luichun6'] = sprintf("%.2f %%", $liucun_data[$bk_data]['bk_luichun6'] / $liucun_data[$bk_data]['bk_reg_number'] * 100);

            $row['bk_agent_payment_amount'] = sprintf("%d", $row['bk_agent_payment_amount']);
            $row['bk_payment_amount'] = sprintf("%d", $row['bk_payment_amount']);

            $row['bk_arppu'] = sprintf("%.2f", $row['bk_payment_amount'] / $row['bk_payment_user_number']); //ARPPU
            $row['bk_arpu'] = sprintf("%.2f", $row['bk_payment_amount'] / $row['bk_active_number']); //ARPU
            $row['bk_payment_rate'] = sprintf("%.2f %%", $row['bk_payment_user_number'] / $row['bk_active_number'] * 100); //付费率

            $row['bk_new_payment_amount'] = sprintf("%d", $row['bk_new_payment_amount']);
            $row['bk_tixian_amount'] = sprintf("%d", $row['bk_tixian_amount']);
            $row['bk_new_tixian_amount'] = sprintf("%d", $row['bk_new_tixian_amount']);

            $acu = M('bk_todayonline')->field('(sum(log_Online)/1440) as acu')->where(['log_LiuCunLvType' => 1, 'log_Time' => array('between', array(strtotime($row['bk_data']), strtotime($row['bk_data']) + 24 * 60 * 60))])->find();
            $row['bk_acu'] = intval($acu['acu']);
            $pcu = M('bk_todayonline')->where(['log_Time' => array('between', array(strtotime($row['bk_data']), strtotime($row['bk_data']) + 24 * 60 * 60))])->max('log_Online');
            $row['bk_pcu'] = intval($pcu);

            $row['bk_luichun1'] = sprintf("%.2f %%", $liucun_data[$row['bk_channel_id']]['bk_luichun1'] / $liucun_data[$row['bk_channel_id']]['bk_reg_number'] * 100);
            $row['bk_luichun2'] = sprintf("%.2f %%", $liucun_data[$row['bk_channel_id']]['bk_luichun2'] / $liucun_data[$row['bk_channel_id']]['bk_reg_number'] * 100);
            $row['bk_luichun6'] = sprintf("%.2f %%", $liucun_data[$row['bk_channel_id']]['bk_luichun6'] / $liucun_data[$row['bk_channel_id']]['bk_reg_number'] * 100);

//            $row_data['register_time'] = $start_time; //日期
//            $row_data['platform'] = '全部'; //平台
//            $row_data['channel'] =  $channel_list[$row['gd_channelid']]; //注册渠道
//            $row_data['shebeixinzhen'] = M('bk_accountv')->where([
//                'gd_IsNewDeviceCode' => 1,
//                'gd_ChannelID' => $row['gd_channelid'] ,
//                'gd_RegisterTime' => [ 'between' , array( $start_time, $end_time ) ],
//            ])->count(); //设备新增
//            $row_data['shebeixinzhen'] = intval($row_data['shebeixinzhen']);
//            $row_data['register'] =  M('bk_accountv')->where([
//                'gd_ChannelID' => $row['gd_channelid'] ,
//                'gd_RegisterTime' =>  [ 'between' , array( $start_time, $end_time ) ],
//            ])->count();  //注册
//
//            $row_data['gameflaglv'] = M('bk_games_gold')->where([
//                'gd_ChannelID' => $row['gd_channelid'] ,
//                'from_unixtime(log_Time, "%Y-%m-%d")' => $row_data['register_time'],
//                'date_format(gd_RegisterTime, "%Y-%m-%d")' => $row_data['register_time'],
//                'log_IsGameChange' => 1
//            ])->count('DISTINCT log_AccountID');  //新增游戏率
//
//            $row_data['gameflaglv'] =  sprintf("%.2f %%", $row_data['gameflaglv'] / $row_data['register']*100);
//
//            $row_data['loginnum'] = M('bk_loginout')->where([
//                'gd_ChannelID' => $row['gd_channelid'] ,
//                'log_login' => array('between', array( strtotime($row_data['register_time']), strtotime($row_data['register_time']) + 24*60*60 ))
//            ])->count('distinct(log_AccountID)');  //活跃人数
//
//            $row_data['moneytotal'] = M('bk_payorder')->alias('a')->join("LEFT JOIN bk_accountv b ON a.bk_AccountID = b.gd_AccountID")->
//                                        where([ 'gd_ChannelID' =>  $row['gd_channelid']  ,'bk_PayTime' => array( 'between' , array( $start_time, $end_time ) )])->sum('bk_Amount') ;//充值金额
//            $row_data['moneytotal'] = intval($row_data['moneytotal']);
//            $row_data['chargenum'] = M('bk_payorder')->alias('a')->join("LEFT JOIN bk_accountv b ON a.bk_AccountID = b.gd_AccountID")->
//                                        where([ 'gd_ChannelID' =>  $row['gd_channelid']  ,'bk_PayTime' => array( 'between' , array( $start_time, $end_time ) )])->count('distinct a.bk_AccountID '); //充值人数
//
//            $row_data['chongzhichishu'] = M('bk_payorder')->field('(a.bk_AccountID )')->alias('a')->join("LEFT JOIN bk_accountv b ON a.bk_AccountID = b.gd_AccountID")->
//                                        where([ 'gd_ChannelID' =>  $row['gd_channelid']  ,'bk_PayTime' => array( 'between' , array( $start_time, $end_time ) )])->count();  //充值次数
//            $row_data['ARPPU'] = sprintf("%.2f",$row_data['moneytotal'] / $row_data['chargenum']); //ARPPU
//            $row_data['ARPU'] = sprintf("%.2f",$row_data['moneytotal'] / $row_data['loginnum']); //ARPU
//            $row_data['fufeilv'] = sprintf("%.2f %%",$row_data['chargenum'] / $row_data['loginnum']*100) ; //付费率
//            $row_data['xinzhenchongzhi'] = M('bk_payorder')->alias('a')->join("LEFT JOIN bk_accountv b ON a.bk_AccountID = b.gd_AccountID")
//                                            ->where([ 'gd_ChannelID' =>  $row['gd_channelid'],
//                                                'bk_PayTime' => array( 'between' , array( $start_time, $end_time )),
//                                                'gd_RegisterTime'  => array( 'between' , array( $start_time, $end_time ))
//                                                ])->count('distinct a.bk_AccountID') ;  //新增充值人数
//
//            $row_data['xianXiaChongZhiMoney'] = M('bk_account_dailichargeliushui')->where( [ 'gd_ChannelID' =>  $row['gd_channelid'], 'bk_ChargeTime' => ['between', [strtotime($start_time), strtotime($end_time)]  ] ])->sum('bk_ChangeGold')/10000;  //线下充值金额
//            $row_data['xianXiaChongZhiRenShu'] = M('bk_account_dailichargeliushui')->where( [ 'gd_ChannelID' =>  $row['gd_channelid'], 'bk_ChargeTime' => ['between', [strtotime($start_time), strtotime($end_time)]  ] ])->count('distinct bk_PlayerID');  //线下充值人数
//            $row_data['xianXiaChongNewZhiMoney'] = M('bk_account_dailichargeliushui')->where( [ 'gd_ChannelID' =>  $row['gd_channelid'], 'bk_ChargeTime' => ['between', [strtotime($start_time), strtotime($end_time)]], 'gd_RegisterTime' => date("Ymd", strtotime($start_time))])->sum('bk_ChangeGold')/10000;  //线下新增充值金额
//            $row_data['xianXiaNewZhiRenShu'] = M('bk_account_dailichargeliushui')->where( [ 'gd_ChannelID' =>  $row['gd_channelid'], 'bk_ChargeTime' => ['between', [strtotime($start_time), strtotime($end_time)]] ,'gd_RegisterTime' => date("Ymd", strtotime($start_time)) ])->count('distinct bk_PlayerID'); //线下新增充值人数
//
//            $row_data['tiXianMoney'] =  M('bk_todaytixian')->where( [ 'gd_ChannelID' =>  $row['gd_channelid'], 'bk_DakuanTime' => ['between',[strtotime($start_time), strtotime($end_time)] ] ])->sum('bk_TixianRMB')/1;   //提现金额
//            $row_data['tiXianRenShu'] = M('bk_todaytixian')->where( [ 'gd_ChannelID' =>  $row['gd_channelid'], 'bk_DakuanTime' => ['between', [strtotime($start_time), strtotime($end_time)] ] ])->count('distinct bk_AccountID');  //提现人数
//            $row_data['newTiXianMoney'] =  M('bk_todaytixian')->where( [ 'gd_ChannelID' =>  $row['gd_channelid'], 'date_format(gd_RegisterTime, "%Y%m%d")' => date("Ymd", strtotime($start_time)), 'bk_DakuanTime' => ['between', [strtotime($start_time), strtotime($end_time)] ] ])->sum('bk_TixianRMB')/1;  //线下新增充值金额
//
//            $row_data['newTiXianRenShu'] =  M('bk_todaytixian')->where([ 'gd_ChannelID' =>  $row['gd_channelid'],  'date_format(gd_RegisterTime, "%Y%m%d")' => date("Ymd", strtotime($start_time)), 'bk_DakuanTime' => ['between', [strtotime($start_time), strtotime($end_time)] ] ])->count('distinct bk_AccountID');  //线下新增充值人数
//
//            $row_data['xinzhenchongmoney'] = M('bk_payorder')->alias('a')->join("LEFT JOIN bk_accountv b ON a.bk_AccountID = b.gd_AccountID")
//                ->where([ 'gd_ChannelID' =>  $row['gd_channelid'],
//                    'bk_PayTime' => array( 'between' , array( $start_time, $end_time )),
//                    'gd_RegisterTime' => array( 'between' , array( $start_time, $end_time ))
//                ])->sum('bk_Amount') ; //新增充值金额
//            $row_data['xinzhenchongmoney'] = intval($row_data['xinzhenchongmoney']);
//
//            $liucunlv_row = M('bk_liucunlvs','bk_','DB_CONFIG1')->field('sum(log_liucunlv1) as liucunlv1 , sum(log_liucunlv2)  as liucunlv2, sum(log_liucunlv6) as liucunlv6, sum(log_TodayRegister) as log_TodayRegister')->where([ 'log_Time' => strtotime($start_time), 'log_ChannelID' => $row['gd_channelid'], 'log_LiuCunLvType' => 1 ])->find(); //次日留存率
//
//            $row_data['liucunlv1'] = sprintf('%.2f %%', $liucunlv_row['liucunlv1']/$liucunlv_row['log_todayregister']*100);
//            $row_data['liucunlv3'] = sprintf('%.2f %%', $liucunlv_row['liucunlv2']/$liucunlv_row['log_todayregister']*100);
//            $row_data['liucunlv7'] = sprintf('%.2f %%', $liucunlv_row['liucunlv6']/$liucunlv_row['log_todayregister']*100);

            $data['data'][] = $row;
        }
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //周报
    public function weekReport()
    {
        $where_data = array();
        $data = array();
        $channel_list = array();
        $platform = C('platform');
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }
        if (!IS_AJAX) {
            $this->assign('channel_list', $channel_list);
            $this->assign('platform', $platform);
            $this->show();
            return;
        }
        $data['page'] = I('get.page/d');
        if (I('get.platform/d') > 0) {
            $where_data['platformID'] = I('get.platform/d');
        }
        if (I('get.channe/d') > 0) {
            $where_data['channelID'] = I('get.channe/d');
        }
        if (I('get.start_time') != '' && I('get.end_time') != '') {
            $where_data['d.countTime'] = array('between', array(strtotime(I('get.start_time')), strtotime(I('get.end_time'))));
        }
    }

    //月报
    public function monthReport()
    {

        if (!IS_AJAX) {
            $this->show();
            return;
        }
    }

    //实时在线
    public function realTimeOnline()
    {
        $platform = C('platform');
        $games = C('games');
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }

        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }

        if (!IS_AJAX) {
            $this->assign('channel_list', $channel_list);
            $this->assign('platform', $platform);
            $this->assign('games', $games);
            $this->assign('apk', $apk);
            $this->show();
            return;
        }

        if (I('post.start_time') != '' && I('post.end_time') != '') {
            $firstTime = strtotime(I('post.end_time'));
            $towTime = strtotime(I('post.start_time'));
            $data['today']['label'] = I('post.end_time');
            $data['yestoday']['label'] = I('post.start_time');
        } else {
            $firstTime = strtotime(date('Y-m-d', time())) - 24 * 60 * 60;
            $towTime = strtotime(date('Y-m-d', time()));
        }

        if (I('post.platform/d') > 0) {
            $where_data['log_PlatformID'] = I('post.platform/d');
        }
        if (I('post.channe/d') > 0) {
            $where_data['log_ChannelID'] = I('post.channe/d');
        }

        $time = 57600;
        for ($i = 0; $i < 60 * 24; $i++) {
            $data['xAxis'][] = date("H:i", $time);
            $time += 60;
        }

        $where_data['log_Time'] = array('between', array($firstTime, $firstTime + 24 * 60 * 60));
        $field = 'log_Time, sum(log_ZongRenShu) as log_ZongRenShu ,log_PlatformID , log_ChannelID, sum(log_Game1) as log_Game1, sum(log_Game2) as log_Game2, sum(log_Game3) as log_Game3, sum(log_Game4) as log_Game4, sum(log_Game5) as log_Game5, sum(log_Game6) as log_Game6, sum(log_Game7) as  log_Game7, sum(log_Game8) as log_Game8, sum(log_Game9) as log_Game9, sum(log_Game10) as log_Game10, sum(log_Game11) as log_Game11, sum(log_Game12) as log_Game12,	sum(log_Game13) as log_Game13';
        $row = M("bk_realtimeonline")->field($field)->where($where_data)->group('log_Time')->order("log_Time asc")->select();
        foreach ($row as $val) {
            $data['today']['ren'][date("H:i", $val['log_time'])] = (I('post.gameid/d') == 0) ? $val['log_zongrenshu'] : $val['log_game' . I('post.gameid/d')];
        }
        $data_ren = array();
        $time = 57600;
        for ($i = 0; $i < 60 * 24; $i++) {
            $Hi = date("H:i", $time);
            if (!isset($data['today']['ren'][$Hi])) {
                $data_ren[] = 0;
            } else {
                $data_ren[] = $data['today']['ren'][$Hi];
            }
            $time += 60;
        }
        $data['today']['ren'] = $data_ren;
        $where_data['log_Time'] = array('between', array($towTime, $towTime + 24 * 60 * 60));
        $row = M("bk_realtimeonline")->field($field)->where($where_data)->group('log_Time')->order("log_Time asc")->select();
        unset($data_time);
        unset($data_ren);
        foreach ($row as $val) {
            $data['yestoday']['ren'][date("H:i", $val['log_time'])] = (I('post.gameid/d') == 0) ? $val['log_zongrenshu'] : $val['log_game' . I('post.gameid/d')];
        }
        $data_ren = array();
        $time = 57600;

        for ($i = 0; $i < 60 * 24; $i++) {
            $Hi = date("H:i", $time);
            if ($Hi == date("H:i", time())) break;
            //echo $data['yestoday']['ren'][$Hi];
            if (!isset($data['yestoday']['ren'][$Hi])) {
                $data_ren[] = 0;
            } else {
                $data_ren[] = $data['yestoday']['ren'][$Hi];
            }
            $time += 60;
        }
        $data['yestoday']['ren'] = $data_ren;
        $this->ajaxReturn(array('lineData' => $data));
    }

    //时实在线会员列表
    function realTimeOnlineUsetList()
    {
        $channel_list = array();
        $games = C('games');

        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }

        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }

        $data = array();
        $layui_where = array();
        if (I('get.gameid/d') == 0) {
            $layui_where['gd_OnlineState'] = array("neq", 0);
        } else {
            $layui_where['gd_OnlineState'] = I('get.gameid/d');
        }

        if (I('get.platform/d') > 0) {
            $layui_where['gd_PlatformID'] = I('get.platform/d');
        }

        if (I('get.channe/d') > 0) {
            $layui_where['gd_ChannelID'] = I('get.channe/d');
        }

        if (I('get.apkid/d') > 0) {
            // $where_data['gd_ChannelID'] = I('get.channe/d');
            $layui_where['gd_ApkID'] = I('get.apkid/d');
        }

        $Query = M('bk_accountv')->where($layui_where);
        (0 == I('get.isExecl/d')) && $Query->page($data['page'])->limit(I('get.limit/d'));
        $row = $Query->select();

        $data['count'] = M('bk_accountv')->where($layui_where)->count();
        $data['page'] = I('get.page/d');
        $data['limit'] = I('get.limit/d');
        $data['code'] = 0;

        foreach ($row as $val) {
            $data_row['account'] = $val['gd_accountid'];
            $data_row['name'] = $val['gd_name'];
            $data_row['activetime'] = $val['gd_activetime'];
            $data_row['apk'] = $apk[$val['gd_apkid']];
            $data_row['channel'] = $channel_list[$val['gd_channelid']];
            $data_row['registerip'] = $val['gd_registerip'];
            $data_row['ogintime'] = date('Y-m-d H:i:s', $val['gd_last_logintime']);
            $data_row['loginip'] = $val['gd_last_loginip'];
            $data_row['loginarea'] = $val['gd_last_loginarea'];
            $data_row['todaymoney'] = $amount = M('bk_todaymoney')->where(array(
                "bk_AccountID" => $val['gd_account'],
                "bk_PayTime" => array('gt', date("Y-m-d H:i:s"))
            ))->getField("bk_Amount");
            $data_row['todaymoney'] = intval($data_row['todaymoney']);
            $data_row['totalMoney'] = $amount = M('bk_todaymoney')->where(array(
                "bk_AccountID" => $val['gd_account']
            ))->sum("bk_Amount");
            $data_row['totalMoney'] = intval($data_row['totalMoney']);
            $chongzhiTotal = M('bk_payorder')->where(array("bk_AccountID" => $val['gd_accountid']))->sum("bk_GetGold") / 10000;
            $dailiChongzhi = M('bk_dailichargeliushui')->where(['bk_PlayerID' => $val['gd_accountid']])->sum('bk_ChangeGold') / 10000;
            $data_row['totalMoney'] = $chongzhiTotal + $dailiChongzhi . ' = ' . $chongzhiTotal . ' + ' . $dailiChongzhi;
            $data_row['viplv'] = $val['gd_viplv'];
            $data_row['gold'] = $val['gd_gold'] / 10000;
            if ($val['gd_onlinestate'] == 0) {
                $data_row['onlinestate'] = '离线';
            } else {
                $data_row['onlinestate'] = $games[$val['gd_onlinestate']];
            }
            $data['data'][] = $data_row;
        }
        (1 == I('get.isExecl/d')) && $this->setExeclData(C('cellName.daily_realTimeOnlineUsetList'), $data['data'], '实时在线会员');
        $this->ajaxReturn($data);
    }

    public function regLuicun()
    {
        $data = array();
        $channel_list = array();
        $platform = C('platform');
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }

        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }

        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->assign('channel_list', $channel_list);
            $this->assign('platform', $platform);
            $this->assign('apk', $apk);
            $this->assign('luicunType', I('param.luicunType/d') == 0 ? 1 : I('param.luicunType/d'));
            $this->show();
            return;
        }
        $where_data['log_LiuCunLvType'] = I('param.luicunType/d') == 0 ? 1 : I('param.luicunType/d');

        if (I('get.platform/d') > 0) {
            $where_data['log_PlatformID'] = I('get.platform/d');
        }
        if (I('get.channe/d') > 0) {
            $where_data['log_ChannelID'] = I('get.channe/d');
        }
        if (I('get.apkid/d') > 0) {
            $where_data['log_APKID'] = I('get.apkid/d');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $start_time = strtotime(I('get.start_time'));
            $end_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $start_time = 1;
            }
            if (I('get.end_time') == '') {
                $end_time = time();
            }
            $where_data['log_Time'] = array('between', array($start_time, $end_time));
        }
        $filed = 'log_Time, sum(log_TodayRegister) as log_TodayRegister, sum(log_TodayActive) as log_TodayActive';
        for ($i = 1; $i < 30; $i++) {
            $filed .= ", sum(log_liucunlv{$i}) as log_liucunlv{$i}";
        }

        $Query = M('bk_liucunlvs', 'bk_', 'DB_CONFIG1')->field($filed)->where($where_data)->group("log_Time")->order('log_Time desc');
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();
        $data['sql'] = $Query->GetLastsql();
        $subQuery = M('bk_liucunlvs', 'bk_', 'DB_CONFIG1')->where($where_data)->group("log_Time")->buildSql();
        $data['count'] = M('bk_liucunlvs', 'bk_', 'DB_CONFIG1')->table($subQuery . ' a')->count();

        $data['page'] = I('get.page/d');
        $data['limit'] = I('get.limit/d');
        $data['code'] = 0;

        foreach ($rows as $val) {
            if (intval($where_data['log_PlatformID']) == 0) {
                $val['platform'] = "全部";
            } else {
                $val['platform'] = $platform[$where_data['log_PlatformID']];
            }

            if (intval($where_data['log_APKID']) == 0) {
                $val['apk'] = "全部";
            } else {
                $val['apk'] = $apk[$where_data['log_APKID']];
            }

            if (intval($where_data['log_ChannelID']) == 0) {
                $val['channe'] = "全部";
            } else {
                $val['channe'] = $channel_list[$where_data['log_ChannelID']];
            }
            $val['log_time'] = date('Y-m-d', $val['log_time']);
            for ($i = 1; $i < 30; $i++) {
                if ($val['log_liucunlv' . $i] == 0) {
                    $val['log_liucunlv' . $i] = 0;
                } else {
                    if (I('get.luicunType/d') == 2) {
                        $val['log_liucunlv' . $i] = sprintf("%.2f %%", $val['log_liucunlv' . $i] / $val['log_todayactive'] * 100);
                    } else {
                        $val['log_liucunlv' . $i] = sprintf("%.2f %%", $val['log_liucunlv' . $i] / $val['log_todayregister'] * 100);
                    }
                }
            }
            $data['data'][] = $val;
        }

        if (1 == I('get.isExecl/d')) ($this->setExeclData(C('cellName.daily_regLuicun'), $data['data'], '注册留存率'));
        $this->ajaxReturn($data);
    }

    //渠道数据
    public function channelData()
    {
        $channel_list = array();
        $platform = C('platform');

        G('begin');
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }
        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->assign('channel_list', $channel_list);
            $this->assign('platform', $platform);
            $this->assign('apk', $apk);
            $this->show();
            return;
        }
        $_where = $where_data = array();
        $data['page'] = I('get.page/d');
        if (I('get.platform/d') > 0) {
            $_where['gd_PlatformID'] = I('get.platform/d');
        }

        if (I('get.channe/d') > 0) {
            $_where['gd_ChannelID'] = I('get.channe/d');
        }

        if (I('get.apkid/d') > 0) {
            $_where['gd_ApkID'] = I('get.apkid/d');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $start_time = strtotime(I('get.start_time'));
            $end_time = strtotime(I('get.end_time')) + 24 * 3600 - 1;
            if (I('get.start_time') == '') {
                $start_time = 1;
            }
            if (I('get.end_time') == '') {
                $end_time = time();
            }
            $where_data['log_Time'] = array('between', array($start_time, $end_time));
        }

        $data['count'] = M('log_jingjigaikuang')->where($where_data)->count();

        $sub1 = M('gd_register')->field('SUM(gd_IsNewDeviceCode)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub2 = M('gd_register')->field('COUNT(gd_AccountID)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub3 = M('gd_register')->field('SUM(gd_TodayBindFlag)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub4 = M('gd_register')->field('SUM(gd_TodayIsCharge)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub5 = M('gd_register')->field('SUM(gd_TodayChargeRMB)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub6 = M('gd_register')->field('SUM(gd_TwoDaysBindFlag)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub7 = M('gd_register')->field('SUM(gd_TwoDaysIsCharge)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub8 = M('gd_register')->field('SUM(gd_TwoDaysChargeRMB)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub9 = M('gd_register')->field('SUM(gd_ThreeDaysBindFlag)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub10 = M('gd_register')->field('SUM(gd_ThreeDaysBindFlag)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub11 = M('gd_register')->field('SUM(gd_ThreeDaysBindFlag)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub12 = M('gd_register')->field('SUM(gd_SevenDaysBindFlag)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub13 = M('gd_register')->field('SUM(gd_SevenDaysBindFlag)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();
        $sub14 = M('gd_register')->field('SUM(gd_SevenDaysBindFlag)')->where(['gd_DailyTime=log_ID'] + $_where)->buildSql();

        $field = "log_ID, $sub1 AS sub1, $sub2 AS sub2, $sub3 AS sub3, $sub4 AS sub4, $sub5 AS sub5, $sub6 AS sub6,
        $sub7 AS sub7, $sub8 AS sub8, $sub9 AS sub9, $sub10 AS sub10, $sub11 AS sub11, $sub12 AS sub12, $sub13 AS sub13,
        $sub14 AS sub14";
        $Query = M('log_jingjigaikuang')->where($where_data)->field($field)->group("log_ID")->order("log_ID desc");
        if (0 == I('get.isExecl/d')) {
            $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        }
        $rows = $Query->select();

        foreach ($rows as $key => $row) {
            $row_data['date'] = date('Y-m-d', $row['log_id']);
            if (intval($_where['gd_PlatformID']) == 0) {
                $row_data['platform'] = "全平台";
            } else {
                $row_data['platform'] = $platform[$_where['gd_PlatformID']];
            }

            if (intval($_where['gd_ApkID']) == 0) {
                $row_data['apk'] = "全包";
            } else {
                $row_data['apk'] = $apk[$_where['gd_ApkID']];
            }

            if (intval($_where['gd_ChannelID']) == 0) {
                $row_data['channe'] = "全渠道";
            } else {
                $row_data['channe'] = $channel_list[$_where['gd_ChannelID']];
            }

            $row_data['NewDeviceCount'] = $row['sub1'] / 1;
            $row_data['register'] = $row['sub2'] / 1;
            $row_data['bindNum'] = $row['sub3'] / 1;
            $row_data['chongZhiRenShu'] = $row['sub4'] / 1;
            $row_data['oneDayTotalPay'] = $row['sub5'] / 1;
            $row_data['twoDayBindUsers'] = $row['sub6'] / 1;
            $row_data['twoDayPayUsers'] = $row['sub7'] / 1;
            $row_data['twoDayTotalPay'] = $row['sub8'] / 1;
            $row_data['threeDayBindUsers'] = $row['sub9'] / 1;
            $row_data['threeDayPayUsers'] = $row['sub10'] / 1;
            $row_data['threeDayTotalPay'] = $row['sub11'] / 1;
            $row_data['sevenDayBindUsers'] = $row['sub12'] / 1;
            $row_data['sevenDayPayUsers'] = $row['sub13'] / 1;
            $row_data['sevenDayTotalPay'] = $row['sub14'] / 1;

            $data['data'][] = $row_data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.channel_data'), $data['data'], '渠道数据');
        }

        G('end');
        $data['code'] = 0;
        $data['time'] = G('begin', 'end') . 's';
        $this->ajaxReturn($data);
    }

    //历史
    public function historReport()
    {
        $channel_list = array();
        $platform = C('platform');
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }
        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {

        }

        if (!IS_AJAX) {
            $this->assign('channel_list', $channel_list);
            $this->assign('platform', $platform);
            $this->assign('apk', $apk);
            $this->show();
            return;
        }
    }
}