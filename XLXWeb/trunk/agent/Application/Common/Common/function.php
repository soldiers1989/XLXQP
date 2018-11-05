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

?>