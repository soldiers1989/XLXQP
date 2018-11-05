<?php
/**
 * Created by PhpStorm.
 * User: Asus
 * Date: 2018/7/30
 * Time: 16:10
 */

//构建Socket数据
//游戏类型 UINT32
$gid = pack("L", 13 );
//游戏等级 UINT32
$cid = pack("L", 1 );
//增加频率 UINT32
$rate = pack("L", 1000);
//增加万分比 UINT32
$ratio = pack("L", 10000);
//增加时长 UINT32
$stime = pack("L", 10000);
//期望增加金额 UINT32
$expect_amount = pack("L", 30000);
//增加原因 STRING
$add_text_len = pack("S", strlen('增加原因'));
$add_text = '增加原因';
//增加或者减少 1减少   0增加
$type = pack("L", 0);
// 数据库语句 UINT32
$uid = pack("L", 30);

$body = $gid . $cid . $rate . $ratio . $stime . $expect_amount . $add_text_len. $add_text . $type . $uid ;
$i = 0;
while (1 ==1 ){
    $socket_result = SendToGame( '192.168.8.102', 30000, 1403, $body );
    echo sprintf("第%s次完成\r\n", $i);
    sleep(10);
    $i++;
}


function SendToGame( $ip, $port, $protocol, $body ) {
    $socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
    if ( $socket == false ) {
        return false;
    }

    $socket_result = socket_connect($socket, $ip, $port);
    if ( $socket_result == false ) {
        socket_close($socket);
        die("连接失败");
        return false;
    }

    $webip = getHostByName(getHostName());
    $webip_len = strlen($webip);

    $body_len = strlen($body);
    $main_id = pack("C", 134);
    $main_type = pack("C", 1);
    $pack_code = pack("S", $protocol);
    $pack_size = pack("S", (8 + $webip_len + $body_len));
    $webip_len = pack("S", $webip_len);

    $data = $main_id . $main_type . $pack_code . $pack_size . $webip_len . $webip . $body;
    $data_len = strlen($data);

    while ( true ) {
        $send_len  = socket_write($socket, $data, $data_len);
        if ($send_len == $data_len) {
            break;
        }

        if ($send_len == false)  {
            socket_shutdown($socket);
            socket_close($socket);
            die("发送失败");
            return false;
        }

        if ($send_len < $data_len) {
            $data = substr($data, $send_len);
            $data_len -= $send_len;
        }

    }

    socket_shutdown($socket);
    socket_close($socket);
    return true;
}