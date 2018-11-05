<?php
ini_set('date.timezone','Asia/Shanghai');

// some code
$db_r = new MySQLi("localhost","backstageR","Xiaolongxia518@","backstage");
$db_w = new MySQLi("172.31.74.221","backstageW","xiaolongxia518","backstage");

$count_send_time = strtotime('2018-08-15 00:00:00');

//平台 apk包 渠道
$platform = getPlatform();
$apk = getApkList($db_r);
$channel = getChannetList($db_r);
foreach ( $platform as $val_p ) {

    foreach ( $apk as $val_a ) {

        foreach ( $channel as $val_c ) {

            todayActive($val_p, $val_a, $val_c, $db_r, $db_w);
            todayAmount($val_p, $val_a, $val_c, $db_r, $db_w);
            todayCount($val_p, $val_a, $val_c, $db_r, $db_w);
            todaySum($val_p, $val_a, $val_c, $db_r, $db_w);
            todayCountFirst($val_p, $val_a, $val_c, $db_r, $db_w);
            todayAmountFirst($val_p, $val_a, $val_c, $db_r, $db_w);
            todayCountNew($val_p, $val_a, $val_c, $db_r, $db_w);
            todayAmountNew($val_p, $val_a, $val_c, $db_r, $db_w);
            todayCountWechat($val_p, $val_a, $val_c, $db_r, $db_w);
            todayAmountWechat($val_p, $val_a, $val_c, $db_r, $db_w);
            todayCountAlipay($val_p, $val_a, $val_c, $db_r, $db_w);
            todayAmountAlipay($val_p, $val_a, $val_c, $db_r, $db_w);
            todayCountQQ($val_p, $val_a, $val_c, $db_r, $db_w);
            todayAmountQQ($val_p, $val_a, $val_c, $db_r, $db_w);
            todayCountBank($val_p, $val_a, $val_c, $db_r, $db_w);
            todayAmountBank($val_p, $val_a, $val_c, $db_r, $db_w);
//            calcLTV($val_p, $val_a, $val_c, $db_r, $db_w);
        }
    }
}

$db_r->close();
$db_w->close();

//当日活跃人数
function todayActive($platform, $apk, $channel, $db_r, $db_w) {
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT count(DISTINCT log_AccountID) FROM bk_loginout WHERE gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND log_login BETWEEN '{$send_time}' AND '{$end_time}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();

        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_Active ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_Active = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日充值金额
function todayAmount($platform, $apk, $channel, $db_r, $db_w) {
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 - 1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT sum(bk_Amount) FROM bk_todaymoney WHERE gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND bk_PayTime BETWEEN '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();
        $arr[0] = ( $arr[0] == null ? 0 : $arr[0] );

        echo  $sql ."\r\n";


        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();

        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_Amount ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_Amount = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}
//当日充值人数(去重)
function todayCount($platform, $apk, $channel, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT count(DISTINCT bk_AccountID) FROM bk_todaymoney WHERE gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND bk_PayTime BETWEEN '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();

        echo  $sql ."\r\n";

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_Count ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_Count = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日充值次数
function todaySum($platform, $apk, $channel, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT count(*) FROM bk_todaymoney WHERE gd_PlatformID = {$platform} AND gd_ApkID = {$apk} and gd_ChannelID = {$channel} and bk_PayTime between '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();

        echo  $sql ."\r\n";

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_Sum ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_Sum = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日历史上首次充值人数
function todayCountFirst($platform, $apk, $channel, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT count(bk_AccountID) FROM bk_firstcharge WHERE gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} and bk_PayTime between '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();

        echo $sql ."\r\n";

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_CountFirst ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_CountFirst = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日历史上首次充值金额总和
function todayAmountFirst($platform, $apk, $channel, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT sum(bk_Amount) FROM bk_firstcharge WHERE gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} and bk_PayTime between '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();
        $arr[0] = ( $arr[0] == null ? 0 : $arr[0] );

        echo  $sql ."\r\n";

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_AmountFirst ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_AmountFirst = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日新增充值人数
function todayCountNew($platform, $apk, $channel, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT count(*) FROM bk_register WHERE gd_TodayIsCharge = 1 AND gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND gd_RegisterTime between '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();

        echo  $sql ."\r\n";

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_CountNew ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_CountNew = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日新增充值金额
function todayAmountNew($platform, $apk, $channel, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT sum(gd_TodayChargeRMB) FROM bk_register WHERE gd_TodayIsCharge = 1 AND gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND gd_RegisterTime between '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();
        $arr[0] = ( $arr[0] == null ? 0 : $arr[0] );

        echo  $sql ."\r\n";

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_AmountNew ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_AmountNew = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日微信充值人数（去重）
function todayCountWechat($platform, $apk, $channel, $db_r, $db_w) {
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT count(DISTINCT bk_AccountID) FROM bk_todaymoney WHERE bk_PayChannel = 3 and gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND bk_PayTime BETWEEN '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();

        echo  $sql ."\r\n";

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_CountWechat ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_CountWechat = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日微信充值金额
function todayAmountWechat($platform, $apk, $channel, $db_r, $db_w) {
    $send_time = $GLOBALS['count_send_time'] ;
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT sum(bk_Amount) FROM bk_todaymoney WHERE bk_PayChannel = 3 AND  gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND bk_PayTime BETWEEN '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();
        $arr[0] = ( $arr[0] == null ? 0 : $arr[0] );

        echo  $sql ."\r\n";

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_AmountWechat ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_AmountWechat = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日支付宝充值人数（去重）
function todayCountAlipay($platform, $apk, $channel, $db_r, $db_w) {
    $send_time = $GLOBALS['count_send_time'] ;
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT count(DISTINCT bk_AccountID) FROM bk_todaymoney WHERE bk_PayChannel = 1 and gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} and bk_PayTime between '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();

        echo  $sql ."\r\n";

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_CountAlipay ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_CountAlipay = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日支付宝充值金额
function todayAmountAlipay($platform, $apk, $channel, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while (1 == 1) {
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s", $send_time);
        $end_time_str = date("Y-m-d H:i:s", $end_time);
        if ($end_time > $e_time ){
            break;
        }
        $sql = "SELECT sum(bk_Amount) FROM bk_todaymoney WHERE bk_PayChannel = 1 AND  gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND bk_PayTime BETWEEN '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();
        $arr[0] = ( $arr[0] == null ? 0 : $arr[0] );

        echo  $sql ."\r\n";

        $incomeoverview_id = function () use ($send_time, $platform, $apk, $channel, $db_r) {
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ($io_id == 0) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_AmountAlipay ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        } else {
            $sql = "UPDATE bk_incomeoverview SET bk_AmountAlipay = {$arr[0]} WHERE bk_ID = " . $io_id;
        }
        echo $sql . "\r\n";
        $db_w->query($sql);
    }
}

//当日QQ充值人数（去重）
function todayCountQQ($platform, $apk, $channel, $db_r, $db_w) {
    $send_time = $GLOBALS['count_send_time'] ;
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT count(DISTINCT bk_AccountID) FROM bk_todaymoney WHERE bk_PayChannel = 2 and gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND bk_PayTime BETWEEN '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();

        echo  $sql ."\r\n";

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_CountQQ ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_CountQQ = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日QQ充值金额
function todayAmountQQ($platform, $apk, $channel, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while (1 == 1) {
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s", $send_time);
        $end_time_str = date("Y-m-d H:i:s", $end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT sum(bk_Amount) FROM bk_todaymoney WHERE bk_PayChannel = 2 AND  gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND bk_PayTime BETWEEN '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();
        $arr[0] = ( $arr[0] == null ? 0 : $arr[0] );

        echo  $sql ."\r\n";

        $incomeoverview_id = function () use ($send_time, $platform, $apk, $channel, $db_r) {
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ($io_id == 0) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_AmountQQ ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        } else {
            $sql = "UPDATE bk_incomeoverview SET bk_AmountQQ = {$arr[0]} WHERE bk_ID = " . $io_id;
        }
        echo $sql . "\r\n";
        $db_w->query($sql);
    }
}

//当日银联快捷充值人数（去重）
function todayCountBank($platform, $apk, $channel, $db_r, $db_w) {
    $send_time = $GLOBALS['count_send_time'] ;
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while ( 1 == 1 ){
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s" ,$send_time);
        $end_time_str = date("Y-m-d H:i:s" ,$end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT count(DISTINCT bk_AccountID) FROM bk_todaymoney WHERE bk_PayChannel = 4 AND gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND bk_PayTime BETWEEN '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();

        echo  $sql ."\r\n";

        $incomeoverview_id = function ()use ($send_time, $platform, $apk, $channel, $db_r){
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_CountBank ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        }else{
            $sql = "UPDATE bk_incomeoverview SET bk_CountBank = {$arr[0]} WHERE bk_ID = " .$io_id;
        }
        echo  $sql ."\r\n";
        $db_w->query($sql);
    }
}

//当日银联快捷充值金额
function todayAmountBank($platform, $apk, $channel, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while (1 == 1) {
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s", $send_time);
        $end_time_str = date("Y-m-d H:i:s", $end_time);
        if ( $end_time > $e_time ){
            break;
        }
        $sql = "SELECT sum(bk_Amount) FROM bk_todaymoney WHERE bk_PayChannel = 4 AND gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} AND bk_PayTime BETWEEN '{$send_time_str}' AND '{$end_time_str}'";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();

        echo  $sql ."\r\n";

        $incomeoverview_id = function () use ($send_time, $platform, $apk, $channel, $db_r) {
            $sql = "SELECT bk_ID FROM bk_incomeoverview WHERE bk_PlatformID = {$platform} AND bk_ApkID = {$apk} AND bk_ChannelID = {$channel} AND bk_Time = {$send_time} ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $incomeoverview_id();
        if ($io_id == 0) {
            $sql = "INSERT INTO bk_incomeoverview ( bk_PlatformID, bk_ApkID, bk_ChannelID ,bk_Time, bk_AmountBank ) VALUES($platform, $apk, $channel, {$send_time}, {$arr[0]})";
        } else {
            $sql = "UPDATE bk_incomeoverview SET bk_AmountBank = {$arr[0]} WHERE bk_ID = " . $io_id;
        }
        echo $sql . "\r\n";
        $db_w->query($sql);
    }
}

//LTV值计算
function calcLTV($platform, $apk, $channel, $db_r, $db_w){
    $send_time = $GLOBALS['count_send_time'];
    $e_time = mktime(0,0,0,date('m'),date('d')+1,date('Y'))-1;

    while (1 == 1) {
        $send_time += 24*60*60;
        $end_time = $send_time + 24*60*60 -1;
        $send_time_str = date("Y-m-d H:i:s", $send_time);
        $end_time_str = date("Y-m-d H:i:s", $end_time);
        if ( $end_time > $e_time ) {
            break;
        }
        $sql = "SELECT count(*) FROM bk_register WHERE gd_RegisterTime BETWEEN '{$send_time_str}' AND '{$end_time_str}' AND gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel} ";
        $result = $db_r->query($sql);
        $arr = $result->fetch_row();
        $newRegNum = intval($arr[0]); //当日新注册用户

        echo  $sql ."\r\n";

        $ltv_id = function () use ($send_time, $platform, $apk, $channel, $db_r) {
            $sql = "SELECT log_ID FROM bk_ltv WHERE log_Time = {$send_time} AND log_PlatformID = {$platform} AND log_ApkID = {$apk} AND log_ChannelID = {$channel}  ";
            $result = $db_r->query($sql);
            $t_count = $result->fetch_row();
            return intval($t_count[0]);
        };
        $io_id = $ltv_id();

        if ( $io_id == 0 ) {
            $sql = "INSERT INTO bk_ltv (log_PlatformID, log_ApkID, log_ChannelID, log_TodayRegister, log_Time ) VALUES($platform, $apk, $channel, $newRegNum, $send_time)";
            $db_w->query($sql);
        }else{
            $sql = "UPDATE bk_ltv SET log_TodayRegister = {$newRegNum}  WHERE log_ID = " . $io_id;
            $db_w->query($sql);
        }

        $ltv_arr = array(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,35,40,50);
        foreach ( $ltv_arr as $val ){
            $ltv_start_time = $send_time + ($val - 1) * 24*60*60;
            $ltv_end_time = $ltv_start_time + 24*60*60 - 1;
            $ltv_start_time_str = date("Y-m-d H:i:s", $ltv_start_time);
            $ltv_end_time_str = date("Y-m-d H:i:s", $ltv_end_time);


            //当日充值金额
            echo $sql_charge = "SELECT sum(bk_Amount) FROM bk_todaymoney  WHERE bk_PayTime BETWEEN '{$ltv_start_time_str}' AND '{$ltv_end_time_str}'  AND gd_RegisterTime  BETWEEN '{$send_time_str}' AND '{$end_time_str}' AND gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel}";
            $result_charge = $db_r->query($sql_charge);
            $arr_charge = $result_charge->fetch_row();
            $arr_charge[0] = ( $arr_charge[0] == null ? 0 : $arr_charge[0] );

            //当日提现金额
            echo $sql_tixian = "SELECT  sum(bk_TixianRMB) FROM bk_todaytixian  WHERE bk_DakuanTime BETWEEN '{$ltv_start_time_str}' AND '{$ltv_end_time_str}'  AND gd_RegisterTime  BETWEEN '{$send_time_str}' AND '{$end_time_str}' AND gd_PlatformID = {$platform} AND gd_ApkID = {$apk} AND gd_ChannelID = {$channel}";
            $result_tixian = $db_r->query($sql_charge);
            $arr_tixian = $result_tixian->fetch_row();
            $arr_tixian[0] = ( $arr_tixian[0] == null ? 0 : $arr_tixian[0] );

            $ltv = ( $arr_charge[0] - $arr_tixian[0] );
            echo $sql = "UPDATE bk_ltv SET log_ltv{$val} = {$ltv} WHERE log_ID = " . $io_id;
            $db_w->query($sql);
            echo "\r\n";
        }
    }
}



function getApkList($db) {
    $arr = array();
    $sql = "SELECT * FROM bk_apk WHERE 1 =1";
    $reslut = $db->query($sql);
    while( $row = $reslut->fetch_array() ) {
        $arr[] =$row['bk_ApkID'];
    }
    return $arr;
}

function getChannetList($db) {
    $arr = array();
    $sql = "SELECT * FROM bk_channel WHERE 1 =1";
    $reslut = $db->query($sql);
    while( $row = $reslut->fetch_array() ) {
        $arr[] =$row['bk_ChannelID'];
    }
    return $arr;
}

function getPlatform() {
    return array( 1, 2, 3, 4 );
}
?>