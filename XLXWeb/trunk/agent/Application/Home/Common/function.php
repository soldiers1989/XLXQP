<?php
/**
 * Created by PhpStorm.
 * User: Asus
 * Date: 2018/7/21
 * Time: 14:49
 */


function SendToGame( $ip, $port, $protocol, $body ) {
    $socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
    if ( $socket == false ) {
        return false;
    }

    $socket_result = socket_connect($socket, $ip, $port);
    if ( $socket_result == false ) {
        echo "连接失败";
        socket_close($socket);
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

    while (true)
    {
        $send_len  = socket_write($socket, $data, $data_len);
        if ($send_len == $data_len)
        {
            break;
        }
        if ($send_len == false)
        {
            socket_shutdown($socket);
            socket_close($socket);
            return false;
        }
        if ($send_len < $data_len)
        {
            $data = substr($data, $send_len);
            $data_len -= $send_len;
        }
    }

    socket_shutdown($socket);
    socket_close($socket);
    return true;
}
