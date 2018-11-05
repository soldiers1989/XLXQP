<?php
/**
 * Created by PhpStorm.
 * User: Asus
 * Date: 2018/9/5
 * Time: 16:39
 */


//计算日报
function dayReport($date ,$_where, $_luiCun_where ){
    $row_data = null;

    $_where_reg_date['gd_RegisterTime'] = array('between', array( $date, date("Y-m-d",strtotime("{$date} +1 day"))));
    if ( intval($_where['gd_PlatformID']) == 0 ) {
        $row_data['bk_platform_id'] = "0";
    }else {
        $row_data['bk_platform_id'] = $_where['gd_PlatformID'];
    }

    if ( intval($_where['gd_ApkID']) == 0 ) {
        $row_data['bk_apk_id'] = "0";
    }else {
        $row_data['bk_apk_id'] = $_where['gd_ApkID'];
    }

    if ( intval($_where['gd_ChannelID']) == 0 ) {
        $row_data['bk_channel_id'] = "0";
    }else {
        $row_data['bk_channel_id'] = $_where['gd_ChannelID'];
    }

    $id = M('bk_day_report','bk_','DB_CONFIG1')->where($row_data)->getField("bk_id");
    if( intval($id) != 0 && $date != date('Y-m-d') ){
        return;
    }

    $row_data['bk_data'] = $date;
    $row_data['bk_new_device'] = M('bk_accountv')->where( array_merge( $_where, $_where_reg_date, ['gd_IsNewDeviceCode' => 1]) )->count(); //设备新增
    $row_data['bk_reg_number'] = M('bk_accountv')->where( array_merge( $_where, $_where_reg_date) )->count(); //注册

    $row_data['bk_new_reg_number_rate'] = M('bk_games_gold')->where([
            'log_Time_str' => ['between' , [$date, date("Y-m-d", strtotime($date)+24*60*60)] ] ,
            'gd_RegisterTime' => ['between' , [$date, date("Y-m-d", strtotime($date)+24*60*60)] ] ,
            'log_IsGameChange' => 1
        ]+$_where)->count('DISTINCT log_AccountID');  //新增游戏率
    $row_data['bk_new_reg_number_rate'] = sprintf("%0.2f %%", $row_data['bk_new_reg_number_rate']/$row_data['bk_reg_number']*100);

    $row_data['bk_active_number'] =  M('bk_loginout')->where( array_merge( $_where, [
        'log_login' => array('between', array( strtotime($date), strtotime( $date ) + 24*60*60 )),
    ]))->count('distinct(log_AccountID)');  //活跃人数

    $row_data['bk_payment_amount'] =  M('bk_payorder')->alias('a')->join("LEFT JOIN __ACCOUNTV__ b ON a.bk_AccountID = b.gd_AccountID")->
    where( array_merge( $_where, ['bk_PayTime' =>['between', [$date, date("Y-m-d", strtotime($date)+24*60*60)]]]))->sum('bk_Amount') ;//充值金额

    $row_data['bk_payment_amount'] = intval( $row_data['bk_payment_amount']);

    $row_data['bk_payment_user_number'] = M('bk_payorder')->alias('a')->join("LEFT JOIN __ACCOUNTV__ b ON a.bk_AccountID = b.gd_AccountID")->
    where(array_merge( $_where, ['bk_PayTime' => ['between', [$date, date("Y-m-d", strtotime($date)+24*60*60)]]]))->count('distinct a.bk_AccountID'); //充值人数

    $row_data['bk_payment_number'] = M('bk_payorder')->field('(a.bk_AccountID )')->alias('a')->join("LEFT JOIN __ACCOUNTV__ b ON a.bk_AccountID = b.gd_AccountID")->
    where( array_merge( $_where, ['bk_PayTime' => ['between', [$date, date("Y-m-d", strtotime($date)+24*60*60)] ]]))->count(); //充值次数
    $row_data['sql'] = M('bk_payorder')->getLastSql();
    $row_data['bk_arppu'] = sprintf("%.2f",$row_data['bk_payment_amount'] / $row_data['bk_payment_user_number'] ); //ARPPU
    $row_data['bk_arpu'] = sprintf("%.2f",$row_data['bk_payment_amount'] / $row_data['bk_active_number']); //ARPU
    $row_data['bk_payment_rate'] = sprintf("%.2f", $row_data['bk_payment_user_number'] / $row_data['bk_active_number']*100) ; //付费率

    $row_data['bk_new_payment_user_number'] = M('bk_payorder')->alias('a')->join("LEFT JOIN __ACCOUNTV__ b ON a.bk_AccountID = b.gd_AccountID")
        ->where(array_merge($_where, [
            'unix_timestamp(bk_PayTime)' => array( 'between' , array( strtotime($date), strtotime( $date) + 24*60*60 ) ),
            'unix_timestamp(gd_RegisterTime)'  => array( 'between' , array( strtotime($date), strtotime( $date) + 24*60*60 ))
        ]))->count('distinct a.bk_AccountID') ; //新增充值人数

    $row_data['bk_new_payment_amount'] = M('bk_payorder')->alias('a')->join("LEFT JOIN __ACCOUNTV__ b ON a.bk_AccountID = b.gd_AccountID")
        ->where(array_merge($_where, [
            'bk_PayTime' => ['between', [$date, date("Y-m-d", strtotime($date)+24*60*60)] ],
            'gd_RegisterTime'  =>['between', [$date, date("Y-m-d", strtotime($date)+24*60*60)] ]
        ]))->sum('bk_Amount'); //新增充值金额

    $row_data['bk_agent_payment_amount'] = M('bk_account_dailichargeliushui')->where($_where+ [ 'bk_ChargeTime' => ['between', [strtotime($date), strtotime( $date) + 24*60*60]  ] ])->sum('bk_ChangeGold')/10000;   //线下充值金额
    $row_data['bk_agent_payment_user_number'] = M('bk_account_dailichargeliushui')->where($_where+ [ 'bk_ChargeTime'=> ['between', [strtotime($date), strtotime( $date) + 24*60*60]  ] ])->count('distinct bk_PlayerID');  //线下充值人数

    $row_data['bk_new_agent_payment_amount'] = M('bk_account_dailichargeliushui')->where($_where+ [ 'bk_ChargeTime' =>['between', [strtotime($date), strtotime( $date) + 24*60*60]], 'gd_RegisterTime' => date("Ymd", strtotime($date))])->sum('bk_ChangeGold')/10000;  //线下新增充值金额
    $row_data['bk_new_agent_payment_user_number'] = M('bk_account_dailichargeliushui')->where($_where+ [ 'bk_ChargeTime' => ['between', [strtotime($date), strtotime( $date ) + 24*60*60]] ,'gd_RegisterTime' => date("Ymd",strtotime($date)) ])->count('distinct bk_PlayerID'); //线下新增充值人数

    $row_data['bk_tixian_amount'] =  M('bk_todaytixian')->where($_where+ [ 'bk_DakuanTime' => ['between', [strtotime($date), strtotime( $date ) + 24*60*60] ] ])->sum('bk_TixianRMB-bk_nShouXuFei/10000');   //提现金额
    $row_data['bk_tixian_user'] = M('bk_todaytixian')->where($_where+ [ 'bk_DakuanTime' => ['between', [strtotime($date), strtotime($date) + 24*60*60] ] ])->count('distinct bk_AccountID');  //提现人数
    $row_data['bk_new_tixian_amount'] =  M('bk_todaytixian')->where($_where+ [ 'gd_RegisterTime' => ['between' , [$date, date("Y-m-d", strtotime($date)+24*60*60)] ], 'bk_DakuanTime' => ['between', [strtotime($date), strtotime( $date) + 24*60*60] ] ])->sum('bk_TixianRMB-bk_nShouXuFei/10000')/1;  //线下新增充值金额
    $row_data['bk_new_tixian_user'] =  M('bk_todaytixian')->where($_where+ [ 'gd_RegisterTime' => ['between' , [$date, date("Y-m-d", strtotime($date)+24*60*60)] ], 'bk_DakuanTime' => ['between', [strtotime($date), strtotime( $date) + 24*60*60] ] ])->count('distinct bk_AccountID');  //线下新增充值人数

    $liucunlv_row = M('bk_liucunlvs','bk_','DB_CONFIG1')->field('sum(log_liucunlv1) as liucunlv1 , sum(log_liucunlv2)  as liucunlv2, sum(log_liucunlv6) as liucunlv6, sum(log_TodayRegister) as log_TodayRegister')->where(($_luiCun_where + ['log_LiuCunLvType' => 1, 'log_Time' => array( 'between', array( strtotime($date), strtotime( $date ) + 24*60*60-1 ))]))->find(); //次日留存率
    $row_data['bk_luichun1'] = sprintf('%.2f', $liucunlv_row['liucunlv1']/$liucunlv_row['log_todayregister']*100);
    $row_data['bk_luichun2'] = sprintf('%.2f', $liucunlv_row['liucunlv2']/$liucunlv_row['log_todayregister']*100);
    $row_data['bk_luichun6'] = sprintf('%.2f', $liucunlv_row['liucunlv6']/$liucunlv_row['log_todayregister']*100);
    return $row_data;
}

//计算日报
function allReport($date ,$_where, $_luiCun_where, $data ){
    $row_data = null;
    $row_data['bk_data'] = strtotime($date);
    $_where_reg_date['gd_RegisterTime'] = array('between', array( $date, date("Y-m-d",strtotime("{$date} +1 day"))));
    if ( intval($_where['gd_PlatformID']) == 0 ) {
        $row_data['bk_platform_id'] = "0";
    }else {
        $row_data['bk_platform_id'] = $_where['gd_PlatformID'];
    }

    if ( intval($_where['gd_ApkID']) == 0 ) {
        $row_data['bk_apk_id'] = "0";
    }else {
        $row_data['bk_apk_id'] = $_where['gd_ApkID'];
    }

    if ( intval($_where['gd_ChannelID']) == 0 ) {
        $row_data['bk_channel_id'] = "0";
    }else {
        $row_data['bk_channel_id'] = $_where['gd_ChannelID'];
    }

    //设备新增
    $row_data['bk_new_device'] = intval(@$data['Account']['IsNewDevice'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]);
    //注册
    $row_data['bk_reg_number'] = intval(@$data['Account'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]);

    //新增游戏率
    $row_data['bk_new_reg_number_rate'] = @isset($data['gameGold'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][$row_data['bk_apk_id']])?(count($data['gameGold'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][$row_data['bk_apk_id']])):0;

    //活跃人数
    $row_data['bk_active_number'] = @isset($data['Loginout'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?count($data['Loginout'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]):0;

    //充值金额
    $row_data['bk_payment_amount'] = isset($data['Payorder'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?$data['Payorder'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]:0;

    //充值人数
   $row_data['bk_payment_user_number'] = isset($data['Payorder']['user_number'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?count($data['Payorder']['user_number'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]):0;

    //充值次数
    $row_data['bk_payment_number'] = isset($data['Payorder']['number'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?$data['Payorder']['number'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]:0;

    //新增充值人数
    $row_data['bk_new_payment_user_number'] = isset($data['Payorder']['new_payment_user_number'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?(count($data['Payorder']['new_payment_user_number'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])):0;

    //新增充值金额
    $row_data['bk_new_payment_amount'] = isset($data['Payorder']['new_payment_amount'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?$data['Payorder']['new_payment_amount'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]:0;

    //线下充值金额
     $row_data['bk_agent_payment_amount'] = isset($data['Daili']['payment_amount'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?$data['Daili']['payment_amount'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]:0;
     //线下充值人数
    $row_data['bk_agent_payment_user_number'] = isset($data['Daili']['user_number'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?(count($data['Daili']['user_number'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])):0;

    //线下新增充值金额
    $row_data['bk_new_agent_payment_amount'] = isset($data['Daili']['new_payment_amount'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?$data['Daili']['new_payment_amount'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]:0;
    //线下新增充值人数
    $row_data['bk_new_agent_payment_user_number'] = isset($data['Daili']['new_user_number'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?($data['Daili']['new_user_number'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]):0;

    //提现金额
    $row_data['bk_tixian_amount'] = isset($data['Todaytixian']['tixian_amount'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?$data['Todaytixian']['tixian_amount'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]:0;

    //提现人数
    $row_data['bk_tixian_user'] = isset($data['Todaytixian']['tixian_user'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?(count($data['Todaytixian']['tixian_user'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])):0;

    //线下新增充值金额
    $row_data['bk_new_tixian_amount'] = isset($data['Todaytixian']['new_tixian_amount'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?($data['Todaytixian']['new_tixian_amount'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']]):0;

    //线下新增充值人数
    $row_data['bk_new_tixian_user'] = isset($data['Todaytixian']['new_tixian_user'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])?(count($data['Todaytixian']['new_tixian_user'][$date][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][ $row_data['bk_apk_id']])):0;

    //$liucunlv_row = M('bk_liucunlvs','bk_','DB_CONFIG1')->field('sum(log_liucunlv1) as liucunlv1 , sum(log_liucunlv2)  as liucunlv2, sum(log_liucunlv6) as liucunlv6, sum(log_TodayRegister) as log_TodayRegister')->where(($_luiCun_where + ['log_LiuCunLvType' => 1, 'log_Time' => array( 'between', array( strtotime($date), strtotime( $date ) + 24*60*60-1 ))]))->find(); //次日留存率
    $row_data['bk_luichun1'] = $data['Luichun'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][$row_data['bk_apk_id']]['log_liucunlv1'];
    $row_data['bk_luichun2'] = $data['Luichun'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][$row_data['bk_apk_id']]['log_liucunlv2'];
    $row_data['bk_luichun6'] = $data['Luichun'][$date][$row_data['bk_platform_id']][$row_data['bk_channel_id']][$row_data['bk_apk_id']]['log_liucunlv6'];

    if( !isset($data['DayReport'][strtotime($date)][$row_data['bk_platform_id']][$row_data['bk_channel_id']][$row_data['bk_apk_id']]) ){
        M('bk_day_report','bk_','DB_CONFIG1')->add($row_data);
    }else{
        M('bk_day_report','bk_','DB_CONFIG1')->where(['bk_id' =>$data['DayReport'][strtotime($date)][$row_data['bk_platform_id']][$row_data['bk_channel_id']][$row_data['bk_apk_id']]])->save($row_data);
    }

    $myfile = fopen("/home/as/".time().".txt", "w") or die("Unable to open file!");
    $txt = "Bill Gates\n"; fwrite($myfile, $txt);
    $txt = "Steve Jobs\n"; fwrite($myfile, $txt);
    fclose($myfile);
}

//注册
function GetAccount($date){
    if ( is_array($date) ) {
        $where['gd_RegisterTime'] = ['between', [$date[0], $date[1]]];
    }else{
        $where['gd_RegisterTime'] = ['between', [ $date, date("Y-m-d", strtotime($date)+24*60*60)]];
    }

    $rows = M('bk_accountv')->field('gd_PlatformID, gd_ChannelID, gd_ApkID, gd_IsNewDeviceCode, gd_RegisterTime')->where($where)->select();
    foreach ( $rows as $row ){
        $date = date('Y-m-d', strtotime($row['gd_registertime']));
        $d[$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']] = isset($d[$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']])?($d[$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']]+1):1;
        if( $row['gd_isnewdevicecode'] == 1 ) {
            $d['IsNewDevice'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']] = isset($d['IsNewDevice'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']])?($d['IsNewDevice'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']]+1):1;
        }
    }
    return $d;
}

function getLoginout($date){
    if ( is_array($date) ) {
        $where['log_login'] = ['between', [strtotime($date[0]), strtotime($date[1])]];
    }else{
        $where['log_login'] = ['between', [ strtotime($date),  strtotime($date)+24*60*60]];
    }

    $rows = M('bk_loginout')->field('log_AccountID, log_login, gd_PlatformID, gd_ChannelID, gd_ApkID')->where($where)->select();
    foreach ( $rows as $row ){
        $data = date('Y-m-d', $row['log_login']);
        if( intval($row['gd_platformid']) > 0 ){
            $d[$data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']][$row['log_accountid']] = $row['log_accountid'];
        }
    }
    return $d;
}

function getPayorderAccount($date) {

    if ( is_array($date) ) {
        $where['bk_PayTime'] = ['between', [$date[0], $date[1]]];
    }else{
        $where['bk_PayTime'] = ['between', [ $date, date("Y-m-d", strtotime($date)+24*60*60)]];
    }

    $rows = M('bk_payorder_account')->field('gd_RegisterTime, bk_AccountID, bk_Amount, bk_PayTime, gd_PlatformID, gd_ChannelID, gd_ApkID')->where($where)->select();
    $m = 0;
    foreach ( $rows as $row ) {
        $date = date('Y-m-d', strtotime($row['bk_paytime']));
        $reg_data = date('Y-m-d', strtotime($row['gd_registertime']));
        $d[$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']] = isset($d[$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']])?($d[$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']]+$row['bk_amount']):$row['bk_amount'];
        $d['number'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']] = isset($d['number'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']])?($d['number'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']]+1):1;
        $d['user_number'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']][$row['bk_accountid']] = $row['bk_accountid'];
        $d['new_payment_user_number'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']][$row['bk_accountid']] = $row['bk_accountid'];
        //新增充值金额
        $d['new_payment_amount'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']] = isset($d['new_payment_amount'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']])?($d['new_payment_amount'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']]+$row['bk_amount']):$row['bk_amount'];

    }
    return $d;
}

function accountDailichargeliushui($date) {
    if ( is_array($date) ) {
        $where['bk_RecieveTime'] = ['between', [strtotime($date[0]), strtotime($date[1])]];
    }else{
        $where['bk_RecieveTime'] = ['between', [strtotime($date), strtotime($date)+24*60*60]];
    }
    $rows = M('bk_account_dailichargeliushui')->field('bk_PlayerID, bk_ChangeGold, bk_RecieveTime, gd_RegisterTime, gd_PlatformID, gd_ChannelID, gd_ApkID')->where($where)->select();
    $m =0;
    foreach ( $rows as $row ){
        $date = date('Y-m-d', $row['bk_recievetime']);
        $reg_data = substr($row['gd_registertime'],0, 4).'-'.substr($row['gd_registertime'],4, 2).'-'.substr($row['gd_registertime'],6, 2);
        $d['payment_amount'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']] = isset($d['payment_amount'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']])?($d['payment_amount'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']]+$row['bk_changegold']):$row['bk_changegold'];
        $d['user_number'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']][$row['bk_playerid']] = $row['bk_playerid'];
        $d['new_payment_amount'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']] = isset($d['new_payment_amount'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']])?($d['new_payment_amount'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']]+$row['bk_changegold']):$row['bk_changegold'];
        //线下新增充值人数
        $d['new_user_number'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']][$row['bk_playerid']] = $row['bk_playerid'];
        if( $reg_data == $date ) {
            $m += $d['new_payment_amount'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']];
        }
    }
    return $d;
}

// 提现
function getTodaytixian($date){
    if ( is_array($date) ) {
        $where['bk_DakuanTime'] = ['between', [ strtotime($date[0]), strtotime($date[1])]];
    }else{
        $where['bk_DakuanTime'] = ['between', [ strtotime($date),  strtotime($date)+24*60*60]];
    }
    $rows = M('bk_todaytixian')->field('bk_AccountID, (bk_TixianRMB-bk_nShouXuFei/10000) as bk_TixianRMB, bk_DakuanTime, gd_RegisterTime, gd_PlatformID, gd_ChannelID, gd_ApkID')->where($where)->select();
    foreach ( $rows as $row ) {
        $date = date('Y-m-d', $row['bk_dakuantime']);
        $reg_data = date('Y-m-d', strtotime($row['gd_registertime']));
        $d['tixian_amount'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']] = isset($d['tixian_amount'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']])?($d['tixian_amount'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']]+$row['bk_tixianrmb']):$row['bk_tixianrmb'];
        $d['tixian_user'][$date][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']][$row['bk_accountid']] = $row['bk_accountid'];
        $d['new_tixian_amount'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']] = isset($d['new_tixian_amount'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']])?($d['new_tixian_amount'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']]+$row['bk_tixianrmb']):$row['bk_tixianrmb'];
        //线下新增充值人数
        $d['new_tixian_user'][$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']][$row['bk_accountid']] = $row['bk_accountid'];
    }
    return $d;
}

//留存
function GetLuichun($date){
    if ( is_array($date) ) {
        $where['log_Time'] = ['between' , [strtotime($date[0]),strtotime($date[1])]];
    }else{
        $where['log_Time'] = ['between' , [ strtotime($date), strtotime($date)+24*60*60]];
    }
    $where['log_LiuCunLvType'] = 1;
    $rows = M('bk_liucunlvs','bk_','DB_CONFIG1')->field('log_liucunlv1, log_liucunlv2, log_liucunlv6,  log_TodayRegister, log_Time, log_platformid, log_channelid, log_apkid')->where($where)->select(); //次日留存率
    $s = 0;
    foreach ( $rows as $row ) {
        $date = date('Y-m-d', $row['log_time']);
        $d[$date][$row['log_platformid']][$row['log_channelid']][$row['log_apkid']] = [
            'log_liucunlv1' => $row['log_liucunlv1'],
            'log_liucunlv2' =>  $row['log_liucunlv2'],
            'log_liucunlv6' =>  $row['log_liucunlv6']
        ];
        if($date == '2018-08-17')$s += $row['log_liucunlv1'];
    }
    return $d;
}

function GetGoldgame($date){
    if ( is_array($date) ) {
        $where['log_Time'] = ['between' , [strtotime($date[0]), strtotime($date[1])]];
    }else{
        $where['log_Time'] = ['between' , [ strtotime($date), strtotime($date)+24*60*60]];
    }
    $where['log_IsGameChange'] = 1;
    $rows = M('bk_games_gold')->field('log_Time, gd_RegisterTime, log_AccountID, gd_PlatformID, gd_ChannelID, gd_ApkID')->where($where)->select();
    foreach ( $rows as $row ){
        $date = date('Y-m-d', $row['log_time']);
        $reg_data = date('Y-m-d', strtotime($row['gd_registertime']));
        $d[$date][$reg_data][$row['gd_platformid']][$row['gd_channelid']][$row['gd_apkid']][$row['log_accountid']] = $row['log_accountid'];
    }
    return $d;
}

function GetDayReport(){
    $rows = M('bk_day_report','bk_','DB_CONFIG1')->field('bk_data, bk_channel_id, bk_platform_id, bk_apk_id, bk_id')->select();
    foreach ( $rows as $row ){
        $d[$row['bk_data']][$row['bk_platform_id']][$row['bk_channel_id']][$row['bk_apk_id']] = $row['bk_id'];
    }
    return $d;
}