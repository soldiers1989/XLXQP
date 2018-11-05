<?php

namespace Home\Controller;

use Think\Controller;

class CurlController extends Controller
{
    public function allReport()
    {
        $data = strtotime(date('Y-m-d')) - 2 * 24 * 60 * 60;
        while (1 == 1) {
            if ($data > time()) {
                die();
            }
            echo date('Y-m-d', $data);
            echo "\r\n";
            $this->dayReport(date('Y-m-d', $data));
            $data += 24 * 60 * 60;
        }
        //$this->dayReport('2018-09-10');
    }

    public function dayReport($data)
    {
        $start_time = time();
        $channel_rows = M('bk_channel')->select();
        $apk_rows = M('bk_apk')->select();
        $platform = C('platform');
        $accountDailichargeliushui = accountDailichargeliushui($data);
        $game_lold = GetGoldgame($data);
        $GetAccount = GetAccount($data);
        $getLoginout = getLoginout($data);
        $PayorderAccount = getPayorderAccount($data);

        $Todaytixian = getTodaytixian($data);
        $Luichun = GetLuichun($data);
        $GetDayReport = GetDayReport();

        foreach ($channel_rows as $row_channel) {
            foreach ($apk_rows as $row_apk) {
                foreach ($platform as $key => $row_platform) {
                    allReport(
                        $data,
                        ['gd_PlatformID' => $key, 'gd_ChannelID' => $row_channel['bk_channelid'], 'gd_ApkID' => $row_apk['bk_apkid']],
                        ['log_PlatformID' => $key, 'log_ChannelID' => $row_channel['bk_channelid'], 'log_ApkID' => $row_apk['bk_apkid']],
                        ['gameGold' => $game_lold, 'Account' => $GetAccount, 'Loginout' => $getLoginout, 'Payorder' => $PayorderAccount, 'Daili' => $accountDailichargeliushui, 'Todaytixian' => $Todaytixian, 'Luichun' => $Luichun, 'DayReport' => $GetDayReport]
                    );
                }
            }
        }
    }
}