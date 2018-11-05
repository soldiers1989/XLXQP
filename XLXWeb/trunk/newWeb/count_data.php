<?php
ini_set('date.timezone','Asia/Shanghai');
$luicunlv_arr = array(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,59);
$count_send_time = strtotime('2018-8-15');
while (true) {
    $s_time = time();
    printf("开始时间 %s \r\n", date('Y-m-d H:i:s'));
    luichun();
    printf("暂时2小时:本次用 %f \r\n", $s_time-time());
    sleep(2*60*60);
}

function luichun(){
//    $db_r = new MySQLi("localhost","backstageR","Xiaolongxia518@","backstage");
//    $db_w = new MySQLi("172.31.74.221","backstageW","xiaolongxia518","backstage");

    $db_r = new MySQLi("localhost","backstageR","Xiaolongxia518@","backstage");
    $db_w = new MySQLi("localhost","manager",'$s2C93gwcIy#JCoZ',"manager");

    $Channet = getChannetList($db_r);
    $ApkList = getApkList($db_r);
    $Platform = getPlatform();
    foreach ( $Platform as $val ) {
        foreach ( $Channet as $cval ) {
            foreach ( $ApkList as $apk) {
                echo date('Y-m-d H:i:s',time()). '：留存率计算（注册）' ."\r\n";
                luiCunLv($val, $cval, $apk, $db_r, $db_w);
                echo date('Y-m-d H:i:s',time()). '：留存率计算（活跃）' ."\r\n";
                luiCunLvHuoYue($val, $cval, $apk, $db_r, $db_w);
                echo date('Y-m-d H:i:s',time()). '：留存率计算（冲值）' ."\r\n";
                luiCunLvChongZi($val, $cval, $apk, $db_r, $db_w);
            }
        }
    }
    $db_r->close();
    $db_w->close();
}

//留存率计算（注册）
function luiCunLv($platform, $Channet, $apk, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    while (1 == 1) {
        $send_time += 24 * 60 * 60;
        $end_time = $send_time + 24 * 60 * 60;
        $send_time_str = date("Y-m-d", $send_time);
        $end_time_str = date("Y-m-d", $end_time);
        if ($end_time > time()+24 * 60 * 60) {
            break;
        }

        $sql = "select count(*) from bk_accountv where gd_RegisterTime between '{$send_time_str}' and '{$end_time_str}' AND gd_PlatformID = {$platform} AND gd_ChannelID = {$Channet} and gd_ApkID = {$apk}";
        $reslut = $db_r->query($sql);
        $arr = $reslut->fetch_row();
        $newRegNum = intval($arr[0]); //当日新注册用户
        $sql = "select count(*) from bk_liucunlvs where log_Time = {$send_time} AND log_PlatformID = {$platform} AND log_ChannelID = {$Channet} AND log_LiuCunLvType = 1 AND log_APKID = {$apk}";
        $reslut = $db_r->query($sql);
        $arr = $reslut->fetch_row();

        //活跃人数
        $sql = "select count( distinct log_AccountID ) from bk_loginout where log_login_str =  '".date('Y-m-d', $send_time)."' AND gd_PlatformID = {$platform} AND gd_ChannelID = {$Channet} AND gd_ApkID = {$apk}";
        $reslut = $db_r->query($sql);
        $log_TodayActive = $reslut->fetch_row();
        $log_TodayActive = intval($log_TodayActive[0]);
        if ( intval($arr[0]) == 0 ) {
            echo $sql = "insert into bk_liucunlvs (log_PlatformID, log_ChannelID, log_TodayRegister, log_Time, log_LiuCunLvType, log_APKID, log_TodayActive )values($platform, $Channet, $newRegNum, $send_time, 1, $apk, $log_TodayActive)";
            $db_w->query($sql);
        }else{
            $sql = "update bk_liucunlvs set log_TodayActive = {$log_TodayActive}, log_TodayRegister = {$newRegNum}  where log_Time = {$send_time} AND log_PlatformID = {$platform} AND log_ChannelID = {$Channet} AND log_LiuCunLvType = 1 and log_APKID = {$apk}";
            $db_w->query($sql);
        }

        $liucunlv = [];
       foreach ( $GLOBALS['luicunlv_arr'] as $val ){
            $lc_send_time = $send_time + $val * 24 * 60 * 60;
            $sql = "select count( distinct log_AccountID ) from bk_loginout where log_login_str =  '".date('Y-m-d', $lc_send_time)."' AND gd_RegisterTime  between '{$send_time_str}' AND '{$end_time_str}' AND gd_PlatformID = {$platform} AND gd_ChannelID = {$Channet} AND gd_ApkID = {$apk}";
            $reslut = $db_r->query($sql);
            $arr = $reslut->fetch_row();
            $liucunlv[] = 'log_liucunlv' . $val . '=' . $arr[0];
       }

        $sql = "update bk_liucunlvs set ".implode(',', $liucunlv)." where log_Time = {$send_time} AND log_PlatformID = {$platform} AND log_ChannelID = {$Channet} AND log_LiuCunLvType = 1 and log_APKID = {$apk}";
        $db_w->query($sql);
    }
}

//留存率计算（活跃）
function luiCunLvHuoYue($platform, $Channet, $apk, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    while (1 == 1) {
        $newRegNum = 0;
        $send_time += 24 * 60 * 60;
        $end_time = $send_time + 24 * 60 * 60;
        $send_time_str = date("Y-m-d", $send_time);
        $end_time_str = date("Y-m-d", $end_time);
        $newData = array();
        if ($end_time > time()+24 * 60 * 60) {
            break;
        }
        $sql = "select count(distinct log_AccountID) from bk_loginout where log_login_str = '{$send_time_str}' AND gd_PlatformID = {$platform} AND gd_ChannelID = {$Channet} AND gd_ApkID = {$apk}";
        $DayHuoYue = "select distinct log_AccountID from bk_loginout where log_login_str = '{$send_time_str}' AND gd_PlatformID = {$platform} AND gd_ChannelID = {$Channet} AND gd_ApkID = {$apk}";
        $reslut = $db_r->query($sql);
        $row = $reslut->fetch_row();
        $newRegNum = intval($row[0]); //当日活跃用户
        $sql = "select count(*) from bk_liucunlvs where log_Time = {$send_time} AND log_PlatformID = {$platform} AND log_ChannelID = {$Channet} AND log_LiuCunLvType = 2 AND log_APKID = {$apk}";
        $reslut = $db_r->query($sql);
        $arr = $reslut->fetch_row();
        if ( intval($arr[0]) == 0 ) {
            $sql = "insert into bk_liucunlvs (log_PlatformID, log_ChannelID, log_TodayActive, log_Time, log_LiuCunLvType, log_APKID )values($platform, $Channet, $newRegNum, $send_time, 2, $apk)";
            $db_w->query($sql);
        }else{
            $sql = "update bk_liucunlvs set log_TodayActive = {$newRegNum}  where log_Time = {$send_time} AND log_PlatformID = {$platform} AND log_ChannelID = {$Channet} AND log_LiuCunLvType = 2 AND log_APKID = {$apk}";
            $db_w->query($sql);
        }
        $liucunlv = null;
        foreach ( $GLOBALS['luicunlv_arr'] as $val ) {
            $lc_send_time = $send_time + $val * 24 * 60 * 60;
            $lc_end_time = $lc_send_time + 24 * 60 * 60;
            $sql = "select count(distinct log_AccountID)  from bk_loginout  where log_login between {$lc_send_time} AND {$lc_end_time} and log_AccountID in ($DayHuoYue)";
            $reslut = $db_r->query($sql);
            $row = $reslut->fetch_row();
            $liucunlv[] = 'log_liucunlv' . $val . '=' . $row[0];
        }
        $sql = "update bk_liucunlvs set ".implode(',', $liucunlv)." where log_Time = {$send_time} AND log_PlatformID = {$platform} AND log_ChannelID = {$Channet} AND log_LiuCunLvType = 2 AND log_APKID = {$apk}";
        $db_w->query($sql);
    }
}

//留存率计算（冲值）
function luiCunLvChongZi($platform, $Channet, $apk, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    while (1 == 1) {
        $newRegNum = 0;
        $newHuoYueNum = 0;
        $send_time += 24 * 60 * 60;
        $end_time = $send_time + 24 * 60 * 60;
        $send_time_str = date("Y-m-d", $send_time);
        $end_time_str = date("Y-m-d", $end_time);
        $newData = array();
        if ($end_time > time()+24 * 60 * 60) {
            break;
        }
        $sql = "select count(distinct log_AccountID) from bk_loginout where log_login_str = '{$send_time_str}' AND gd_PlatformID = {$platform} AND gd_ChannelID = {$Channet} AND gd_ApkID = {$apk}";
        $reslut = $db_r->query($sql);
        $row = $reslut->fetch_row() ;
        $newHuoYueNum = intval($row[0]); //当日活跃用户
        $sql = "select count(distinct bk_AccountID) from bk_payorder_account where bk_PayTime between '{$send_time_str}' and '{$end_time_str}' AND gd_PlatformID = {$platform} AND gd_ChannelID = {$Channet} AND gd_ApkID = {$apk} ";
        $dayChongZhiSql = "select distinct bk_AccountID from bk_payorder_account where bk_PayTime between '{$send_time_str}' and '{$end_time_str}' AND gd_PlatformID = {$platform} AND gd_ChannelID = {$Channet} AND gd_ApkID = {$apk} ";
        $reslut = $db_r->query($sql);
        $row = $reslut->fetch_row();
        $newRegNum = intval( $row[0]); //当日冲值用户
        $sql = "select count(*) from bk_liucunlvs where log_Time = {$send_time} AND log_PlatformID = {$platform} AND log_ChannelID = {$Channet} AND log_LiuCunLvType = 3 AND log_APKID = {$apk}";
        $reslut = $db_r->query($sql);
        $arr = $reslut->fetch_row();
        if ( intval($arr[0]) == 0 ) {
            $sql = "insert into bk_liucunlvs (log_PlatformID, log_ChannelID, log_TodayRegister, log_TodayActive, log_Time, log_LiuCunLvType, log_APKID )values($platform, $Channet, $newRegNum, $newHuoYueNum, $send_time, 3, {$apk})";
            $db_w->query($sql);
        }else{
            $sql = "update bk_liucunlvs set log_TodayActive = {$newHuoYueNum}, log_TodayRegister = {$newRegNum}  where log_Time = {$send_time} AND log_PlatformID = {$platform} AND log_ChannelID = {$Channet} AND log_LiuCunLvType = 3 AND log_APKID = {$apk}";
            $db_w->query($sql);
        }
        $liucunlv = [];
        foreach ( $GLOBALS['luicunlv_arr'] as $val ) {
            $lc_send_time = $send_time + $val * 24 * 60 * 60;
            $lc_end_time = $lc_send_time + 24 * 60 * 60;
            $sql = "select count(distinct log_AccountID) from bk_loginout  where log_AccountID in ($dayChongZhiSql) AND log_login between {$lc_send_time} AND {$lc_end_time}";
            $reslut = $db_r->query($sql);
            $row = $reslut->fetch_row();
            $liucunlv[] = 'log_liucunlv' . $val . '=' . intval($row[0]);
        }
        echo $sql = "update bk_liucunlvs set ".implode(',', $liucunlv)." where log_Time = {$send_time} AND log_PlatformID = {$platform} AND log_ChannelID = {$Channet} AND log_LiuCunLvType = 3 AND log_APKID = {$apk}";
        echo "\r\n";
        $db_w->query($sql);
    }
}

function getChannetList ($db) {
    $arr = array();
    $sql = "SELECT * FROM bk_channel WHERE 1 =1";
    $reslut = $db->query($sql);
    while( $row = $reslut->fetch_array() ) {
        $arr[] =$row['bk_ChannelID'];
    }
    return $arr;
}
function getApkList($db){
    $arr = array();
    $sql = "SELECT * FROM bk_apk WHERE 1 =1";
    $reslut = $db->query($sql);
    while( $row = $reslut->fetch_array() ) {
        $arr[] =$row['bk_ApkID'];
    }
    return $arr;
}
function getPlatform() {
    return array( 1 , 2, 3 ,4 );
}
?>