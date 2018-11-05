<?php
// 获取用户登录IP
function getClientIp($type = 0) {
    $type = $type ? 1 : 0;
    static $ip = NULL;
    if ($ip !== NULL) return $ip[$type];
    if ($_SERVER['HTTP_X_REAL_IP']) {
        $ip = $_SERVER['HTTP_X_REAL_IP'];   // nginx 代理模式下,获取客户端真实IP
    }elseif (isset($_SERVER['HTTP_CLIENT_IP'])) {
        $ip = $_SERVER['HTTP_CLIENT_IP'];   // //客户端的ip
    }elseif (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $arr = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
        $pos = array_search('unknown',$arr);
        if ($pos != false) unset($arr[$pos]);
        $ip = trim($arr[0]);    // 浏览当前页面的用户计算机的网关
    }elseif (isset($_SERVER['REMOTE_ADDR'])) {
        $ip = $_SERVER['REMOTE_ADDR'];  // 浏览当前页面的用户计算机的ip地址
    }else {
        $ip = $_SERVER['REMOTE_ADDR'];
    }

    // IP地址合法检验
    $long = sprintf("%u",ip2long($ip));
    $ip   = $long ? array($ip, $long) : array('0.0.0.0', 0);
    return $ip[$type];
}

//  判断是否选择(区间)
function isCheckedArray($a, $b, $c ,$d = false) {
    if (in_array($a, $b)){
        return $c;
    } else {
        return $d;
    }
}

//  判断是否选择(单个)
function isChecked($a, $b, $c ,$d = false) {
    if ($a == $b) {
        return $c;
    } else {
        return $d;
    }
}

// 与服务器通信
function sendToGame($ip, $port, $protocol, $body) {
    $socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP); // 创建一个套接字(socket),失败返回false
    if ($socket == false) return false;
    $socket_result = socket_connect($socket, $ip, $port);   // 开启一个套接字连接,失败返回false
    if ($socket_result == false) {
        socket_close($socket);
        return false;
    }

    $webIP = getHostByName(getHostName());  // getHostName—获取主机名,getHostByName-获取主机名对应的IPv4地址列表
    $webIP_len = strlen($webIP);

    $body_len = strlen($body);
    $main_id = pack("C", 134);
    $main_type = pack("C", 1);
    $pack_code = pack("S", $protocol);
    $pack_size = pack("S", (8 + $webIP_len + $body_len));
    $webIP_len = pack("S", $webIP_len);

    $data = $main_id . $main_type . $pack_code . $pack_size . $webIP_len . $webIP . $body;
    $data_len = strlen($data);

    while (true) {
        $send_len  = socket_write($socket, $data, $data_len);
        if ($send_len == $data_len) break;
        if ($send_len == false) {
            socket_shutdown($socket);
            socket_close($socket);
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

// POST请求-第三方支付
function http_request($url, $data) {
    $curl = curl_init();    // 初始化curl会话
    curl_setopt($curl, CURLOPT_URL, $url);  // 设置url
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, FALSE);  // 禁止curl验证对等证书
    curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, 0);  // 不检查共用名
    if (!empty($data)) {
        curl_setopt($curl, CURLOPT_POST, TRUE); // true时会发送post请求
        curl_setopt($curl, CURLOPT_POSTFIELDS, $data);  // 全部数据使用http协议中的post操作发送
    }
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);    // true时将curl_exec()获取的信息以字符串返回，而不是直接输出
    $output = curl_exec($curl); // 执行curl会话
    curl_close($curl);  // 关闭curl会话
    return $output;
}
?>