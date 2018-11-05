<?php
//时间转换
function timeToDataTime($array , $Field ,$timeFormat = "Y-m-d H:i:s") {
    foreach($array as $k=>$v )
    {
        if( is_array($Field) )
        {
            foreach( $Field as $vv )
            {
                $v[$vv] = date( $timeFormat, $v[$vv] );
            }
        }else{
            $v[$Field] = date($timeFormat, $v[$Field]);
        }
        $array[$k] = $v;
    }
    return $array;
}


function xeq( $a, $b, $c ,$d = false){
    if( $a == $b ){
        return $c;
    }else{
        return $d;
    }
}

function x_in_array($a, $b, $c, $d = false){
    if ( in_array($a, $b) ){
        return $c;
    }else{
        return $d;
    }
}

function getClientIp($type = 0) {
    $type       =  $type ? 1 : 0;
    static $ip  =   NULL;
    if ($ip !== NULL) return $ip[$type];
    if($_SERVER['HTTP_X_REAL_IP']){//nginx 代理模式下，获取客户端真实IP
        $ip=$_SERVER['HTTP_X_REAL_IP'];
    }elseif (isset($_SERVER['HTTP_CLIENT_IP'])) {//客户端的ip
        $ip     =   $_SERVER['HTTP_CLIENT_IP'];
    }elseif (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {//浏览当前页面的用户计算机的网关
        $arr    =   explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
        $pos    =   array_search('unknown',$arr);
        if(false !== $pos) unset($arr[$pos]);
        $ip     =   trim($arr[0]);
    }elseif (isset($_SERVER['REMOTE_ADDR'])) {
        $ip     =   $_SERVER['REMOTE_ADDR'];//浏览当前页面的用户计算机的ip地址
    }else{
        $ip=$_SERVER['REMOTE_ADDR'];
    }
    // IP地址合法验证
    $long = sprintf("%u",ip2long($ip));
    $ip   = $long ? array($ip, $long) : array('0.0.0.0', 0);
    return $ip[$type];
}

function SendToGame($ip, $port, $protocol, $body) {
    $socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
    if ($socket == false)
    {
        return false;
    }

    $socket_result = socket_connect($socket, $ip, $port);
    if ($socket_result == false)
    {
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


function secsToStr($secs) {
    if($secs>=86400){$days=floor($secs/86400);
        $secs=$secs%86400;
        $r=$days.'天';
        if($days<>1){$r.='秒';}
        if($secs>0){$r.='';}}
    if($secs>=3600){$hours=floor($secs/3600);
        $secs=$secs%3600;
        $r.=$hours.'小时';
        if($hours<>1){$r.='';}
        if($secs>0){$r.='';}}
    if($secs>=60){$minutes=floor($secs/60);
        $secs=$secs%60;
        $r.=$minutes.'分';
        if($minutes<>1){$r.='';}
        if($secs>0){$r.='';}}
    $r.=$secs.'秒';
    if($secs<>1){$r.='';
    }
    return $r;
}

// 提现管理-预警配置
function earlyWarning($account, $amount, $overage, $time) {
    // 获取预警配置
    $result = M('bk_earlywarningconfig')->where( array('bk_ID' => 2) )->find();
    $condition1 = $result['bk_condition1'];
    $condition2 = $result['bk_condition2'];
    $condition3 = $result['bk_condition3'];
    $condition4 = $result['bk_condition4'];
    $condition5 = $result['bk_condition5'];
    $condition6 = $result['bk_condition6'];

    $str_time = date('Y-m-d H:i:s', $time);
    $sum_ycz_gf = M('bk_payorder')->where(['bk_AccountID' => $account, 'bk_PayTime' => ['elt', $str_time]])->sum('bk_Amount'); // 查询用户当前通过官方充值总额
    $sum_ycz_dl = M('bk_dailichargeliushui')->where(['bk_PlayerID' => $account, 'bk_RecieveTime' => ['between', [1, $time]]])->sum('bk_ChangeGold'); // 查询用户当前通过代理充值总额
    $sum_ycz = $sum_ycz_gf + $sum_ycz_dl; // 用户当前已充值金额  官方+代理

    $where_data_withdraw['bk_AccountID'] = $account;
    $where_data_withdraw['bk_OrderState'] = 5;
    $where_data_withdraw['bk_DakuanTime'] = array('between', array( 1, $time));
    $count_ytx = M('bk_tixianorder')->where($where_data_withdraw)->count();   // 查询用户当前已提现次数
    $sum_ytx = M('bk_tixianorder')->where($where_data_withdraw)->sum('bk_TixianRMB'); // 查询用户当前已提现总额

    // 判断是否满足预警
    $flag = ''; // 预警标志
    // 单次提现超过xxx元,进行预警
    if ( $condition1 != 0 && $amount > $condition1 ) {
        $flag .= '单次提现超过' . $condition1 . '元;';
    }

    // 未充值用户,到达xxx次提现及以上,进行预警
    if ( $condition2 != 0 &&  $sum_ycz == 0 && $count_ytx >= $condition2 ) {
        $flag .= '未充值用户,达到' . $condition2 .'次提现及以上;';
    }

    // 未充值用户,本次提现额+已提现额≥xxx元,进行预警
    if ( $condition3 != 0 &&  $sum_ycz == 0 && ( $sum_ytx + $amount ) >= $condition3 ) {
        $flag .= '未充值用户,本次提现额+已提现额≥' . $condition3 . '元;';
    }

    // 1000元以下充值用户,本次提现额+已提现额+余额≥充值总额,进行预警
    if ( $condition4 != 0 &&  $sum_ycz < 1000 && $sum_ycz > 0 &&( $sum_ytx + $amount + $overage - $sum_ycz ) >= $condition4 ) {
        $flag .= '1000元以下充值用户,本次提现额+已提现额+余额≥充值总额' . $condition4 . '元;';
    }

    // 1000元及以上充值用户,本次提现额+已提现额+余额≥充值总额,进行预警
    if ( $condition5 != 0 &&  $sum_ycz >= 1000 && ( $sum_ytx + $amount + $overage ) >= ( $sum_ycz * $condition5 ) ) {
        $flag .= '1000元及以上充值用户,本次提现额+已提现额+余额≥充值总额' . $condition5 . '倍;';
    }

     //连续提现（期间无充值),超过xxx次,进行预警
    if ( $condition6 != 0 && $count_ytx >= $condition6 ) {
        $order = "bk_DakuanTime desc";
        $subQuery  = M('bk_tixianorder')->where($where_data_withdraw)->order($order)->limit($condition6)->buildSql();
        $ytx_time = M('bk_tixianorder')->table($subQuery.' a')->order('bk_DakuanTime asc')->getField('bk_DakuanTime');

        $where_data_duration['bk_AccountID'] = $account;
        $where_data_duration['bk_PayTime'] = array('between', array(date('Y-m-d H:i:s', $ytx_time), date('Y-m-d H:i:s', $time)));
        $count_charge = M('bk_payorder')->where($where_data_duration)->count();  // 查询用户在连续xxx次期间是否有充值行为
        $sql = M('bk_payorder')->getLastSql();

        if ( $count_charge < 1 ) {
            $flag .= '连续提现（期间无充值),超过' . $condition6 . '次;';
        }
    }

    return $flag == '' ? '' : substr($flag, 0 , strlen($flag) - 1);
}
?>