<?php

namespace Home\Controller;
class GameDataController extends BaseController
{
    public function index() {
        $this->show();
    }

    // 经济概况
    // 游戏经济
    public function gameEconomic() {
        $where_data = array();
        $data = array();
        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');
        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_jingjigaikuang')->where($where_data)->count();
        $order = 'log_Time desc';
        $Query = M('log_jingjigaikuang')->where($where_data)->order($order);
        if (I('get.isExecl/d') == 0) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        $layui_data['sql'] = $Query->getLastSql();
        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);    // 日期
            $data['total_gold'] = $val['log_totalgold'] / 10000; // 总金币
            $data['active_gold'] = $val['log_activegold'] / 10000;   // 活跃金币
            $data['yuebao_stock'] = $val['log_yuebaostock'] / 10000;  // 余额宝库存
            $data['yuebao_interest'] = $val['log_yuebaointerest'] / 10000;    // 总利息
            $data['tx_amount'] = $val['log_tixianamount'] / 10000;  // 提现金额
            $data['tx_tgy'] = $val['log_proxygetcommission'] / 10000; // 推广员提取佣金
            $data['charge_grant'] = $val['log_chargegrant'] / 10000;    // 充值发放
            $data['xx_amount'] = $val['log_dailichargegrant'] / 10000;    // 线下充值
            $data['sm_amount'] = $val['log_gfsmchargegrant'] / 10000;    // 官方扫码充值发放
            $data['charge_rebate'] = $val['log_chargerebate'] / 10000;  // 充值返利
            $data['register_grant'] = $val['log_registergold'] / 10000; // 注册发放
            $data['bind_grant'] = $val['log_bindgold'] / 10000; // 绑定发放
            $data['fenxiang_grant'] = $val['log_sharegold'] / 10000; // 分享发放
            $data['backstage_grant'] = $val['log_backstagegrant'] / 10000;  // 后台发放
            $data['proxy_rebate'] = $val['log_proxyrebate'] / 10000;    // 代理返利
            $data['backstage_recover'] = $val['log_backstagerecover'] / 10000;  // 后台回收
            $data['system_recover'] = $val['log_systemrecover'] / 10000; // 系统回收
            $data['game_choushui'] = $val['log_gamechoushui'] / 10000;   // 游戏抽水
            $data['zhongYaZhu'] = $val['log_gamebet'] / 10000;   // 总押注
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.game_economic'), $layui_data['data'], '游戏经济');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 金币排行榜
    public function goldLeaderBoard()
    {
        $channel = $data = array();
        $channel_list = M('bk_channel')->select();
        foreach ($channel_list as $key => $val) {
            $channel[$val['bk_channelid']] = $val['bk_channel'];
        }

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $order = 'gd_Gold desc';
        $field = 'gd_AccountID, gd_Name, gd_ChannelID, gd_Last_LoginTime, gd_Gold';
        $data_list = M('gd_account')->field($field)->order($order)->limit(300)->select();
        $number = 1;
        foreach ($data_list as $key => $val) {
            $data['rank'] = $number;
            $data['account'] = $val['gd_accountid'];
            $data['nickname'] = $val['gd_name'];
            $data['channel'] = $channel[$val['gd_channelid']];
            $data['time'] = date('Y-m-d H:i:s', $val['gd_last_logintime']);
            $data['gold'] = ($val['gd_gold'] / 10000);
            $layui_data['data'][] = $data;

            $number++;
        }

        $layui_data['time'] = G('begin', 'end') . 's';
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 游戏经济
    // 牛牛概况
    public function niuNiu() {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allniuniugaikuang')->where($where_data)->count();
        $order = 'log_Time desc';
        $Query = M('log_allniuniugaikuang')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);
            $data['count'] = $val['log_player'];
            $data['count1'] = $val['log_oneminute'];
            $data['count2'] = $val['log_tenminutes'];
            $data['count3'] = $val['log_halfhour'];
            $data['count4'] = $val['log_onehour'];
            $data['count5'] = $val['log_twohours'];
            $data['count6'] = $val['log_morethantwohours'];
            $data['count7'] = $val['log_threeminutes'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = $val['log_totaltouzhu'];
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.overview1'), $layui_data['data'], '牛牛概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 牛牛房间数据
    public function niuNiuRoom() {
        $where_data = array();
        $data = array();
        $room = C('ROOM');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = (I('get.start_time') == '' ? '2018-08-16' : I('get.start_time'));
            $e_time = (I('get.end_time') == '' ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        switch (I('get.room/d')) {
            case 1:
                $where_data['log_Level'] = 1;
                break;
            case 2:
                $where_data['log_Level'] = 2;
                break;
            case 3:
                $where_data['log_Level'] = 3;
                break;
            case 4:
                $where_data['log_Level'] = 4;
                break;
        }

        $layui_data['count'] = M('log_niuniugaikuang')->where($where_data)->count();
        $order = 'log_Time desc, log_Level asc';
        $Query = M('log_niuniugaikuang')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = $val['log_time'];
            $data['room'] = $room[$val['log_level']];
            $data['count_sum'] = $val['log_totaljushu'];
            $data['count_cy'] = $val['log_joinjushu'];
            $data['count_zb'] = $val['log_zuobijushu'];
            $data['count'] = $val['log_player'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['amount_yz'] = ($val['log_totalyazhu'] / 10000);
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $data['amount_fl'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.room1'), $layui_data['data'], '牛牛房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 炸金花概况
    public function yingSanZhang() {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allyingsanzhanggaikuang')->where($where_data)->count();
        $order = 'log_Time desc';

        $Query = M('log_allyingsanzhanggaikuang')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);
            $data['count'] = $val['log_player'];
            $data['count1'] = $val['log_oneminute'];
            $data['count2'] = $val['log_tenminutes'];
            $data['count3'] = $val['log_halfhour'];
            $data['count4'] = $val['log_onehour'];
            $data['count5'] = $val['log_twohours'];
            $data['count6'] = $val['log_morethantwohours'];
            $data['count7'] = $val['log_threeminutes'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['result'] = ($val['log_totalfajiang'] - $val['log_totalyazhu']) / 10000;
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.yingsanzhang_overview'), $layui_data['data'], '炸金花概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 炸金花房间数据
    public function yingSanZhangRoom() {
        $where_data = array();
        $data = array();
        $room = C('ROOM');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = (I('get.start_time') == '' ? '2018-08-16' : I('get.start_time'));
            $e_time = (I('get.end_time') == '' ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        switch (I('get.room/d')) {
            case 1:
                $where_data['log_Level'] = 1;
                break;
            case 2:
                $where_data['log_Level'] = 2;
                break;
            case 3:
                $where_data['log_Level'] = 3;
                break;
            case 4:
                $where_data['log_Level'] = 4;
                break;
        }

        $layui_data['count'] = M('log_yingsanzhanggaikuang')->where($where_data)->count();
        $order = 'log_Time desc, log_Level asc';
        $Query = M('log_yingsanzhanggaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = $val['log_time'];
            $data['room'] = $room[$val['log_level']];
            $data['count_sum'] = $val['log_totaljushu'];
            $data['count_cy'] = $val['log_joinjushu'];
            $data['count_zb'] = $val['log_zuobijushu'];
            $data['count'] = $val['log_player'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['amount_yz'] = ($val['log_totalyazhu'] / 10000);
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $data['amount_fl'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.yingsanzhang_room'), $layui_data['data'], '炸金房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 推筒子概况
    public function tuiTongZi() {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_alltuitongzigaikuang')->where($where_data)->count();
        $order = 'log_Time desc';

        $Query = M('log_alltuitongzigaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);
            $data['count'] = $val['log_player'];
            $data['count1'] = $val['log_oneminute'];
            $data['count2'] = $val['log_tenminutes'];
            $data['count3'] = $val['log_halfhour'];
            $data['count4'] = $val['log_onehour'];
            $data['count5'] = $val['log_twohours'];
            $data['count6'] = $val['log_morethantwohours'];
            $data['count7'] = $val['log_threeminutes'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.overview1'), $layui_data['data'], '推筒子概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 推筒子房间数据
    public function tuiTongZiRoom() {
        $where_data = array();
        $data = array();

        $room = C('ROOM');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = (I('get.start_time') == '' ? '2018-08-16' : I('get.start_time'));
            $e_time = (I('get.end_time') == '' ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        switch (I('get.room/d')) {
            case 1:
                $where_data['log_Level'] = 1;
                break;
            case 2:
                $where_data['log_Level'] = 2;
                break;
            case 3:
                $where_data['log_Level'] = 3;
                break;
            case 4:
                $where_data['log_Level'] = 4;
                break;
        }

        $layui_data['count'] = M('log_tuitongzigaikuang')->where($where_data)->count();
        $order = 'log_Time desc, log_Level asc';
        $Query = M('log_tuitongzigaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = $val['log_time'];
            $data['room'] = $room[$val['log_level']];
            $data['count_sum'] = $val['log_totaljushu'];
            $data['count_cy'] = $val['log_joinjushu'];
            $data['count_zb'] = $val['log_zuobijushu'];
            $data['count'] = $val['log_player'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['amount_yz'] = ($val['log_totalyazhu'] / 10000);
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $data['amount_fl'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.room1'), $layui_data['data'], '推筒子房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 红包接龙概况
    public function hongBaoJieLong() {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allhongbaojielonggaikuang')->where($where_data)->count();
        $order = 'log_Time desc';

        $Query = M('log_allhongbaojielonggaikuang')->where($where_data)->group('log_Time')->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);
            $data['count'] = $val['log_player'];
            $data['count1'] = $val['log_oneminute'];
            $data['count2'] = $val['log_tenminutes'];
            $data['count3'] = $val['log_halfhour'];
            $data['count4'] = $val['log_onehour'];
            $data['count5'] = $val['log_twohours'];
            $data['count6'] = $val['log_morethantwohours'];
            $data['count7'] = $val['log_threeminutes'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.overview1'), $layui_data['data'], '红包接龙概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 红包接龙房间数据
    public function hongBaoJieLongRoom() {
        $where_data = array();
        $data = array();
        $room = C('ROOM');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = (I('get.start_time') == '' ? '2018-08-16' : I('get.start_time'));
            $e_time = (I('get.end_time') == '' ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        switch (I('get.room/d')) {
            case 1:
                $where_data['log_Level'] = 1;
                break;
            case 2:
                $where_data['log_Level'] = 2;
                break;
            case 3:
                $where_data['log_Level'] = 3;
                break;
            case 4:
                $where_data['log_Level'] = 4;
                break;
        }

        $layui_data['count'] = M('log_hongbaojielonggaikuang')->where($where_data)->count();
        $order = 'log_Time desc, log_Level asc';
        $Query = M('log_hongbaojielonggaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = $val['log_time'];
            $data['room'] = $room[$val['log_level']];
            $data['count_sum'] = $val['log_totaljushu'];
            $data['count_cy'] = $val['log_joinjushu'];
            $data['count_zb'] = $val['log_zuobijushu'];
            $data['count'] = $val['log_player'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['amount_yz'] = $val['log_totalyazhu'] / 10000;
            $data['amount_cs'] = $val['log_choushui'] / 10000;
            $data['amount_hs'] = $val['log_systemhuishou'] / 10000;
            $data['amount_fl'] = $val['log_proxyfanli'] / 10000;
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.room1'), $layui_data['data'], '红包接龙房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 百人金花概况
    public function baiRenJinHua() {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allbairenjinhuagaikuang')->where($where_data)->count();
        $order = 'log_Time desc';

        $Query = M('log_allbairenjinhuagaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);
            $data['count'] = $val['log_player'];
            $data['count1'] = $val['log_oneminute'];
            $data['count2'] = $val['log_tenminutes'];
            $data['count3'] = $val['log_halfhour'];
            $data['count4'] = $val['log_onehour'];
            $data['count5'] = $val['log_twohours'];
            $data['count6'] = $val['log_morethantwohours'];
            $data['count7'] = $val['log_threeminutes'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.overview1'), $layui_data['data'], '百人金花概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 百人金花房间数据
    public function baiRenJinHuaRoom() {
        $where_data = array();
        $data = array();
        $room = C('ROOM_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = (I('get.start_time') == '' ? '2018-08-16' : I('get.start_time'));
            $e_time = (I('get.end_time') == '' ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        switch (I('get.room/d')) {
            case 1:
                $where_data['log_Level'] = 1;
                break;
            case 2:
                $where_data['log_Level'] = 2;
                break;
            case 3:
                $where_data['log_Level'] = 3;
                break;
        }

        $layui_data['count'] = M('log_bairenjinhuagaikuang')->where($where_data)->count();
        $order = 'log_Time desc, log_Level asc';
        $Query = M('log_bairenjinhuagaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = $val['log_time'];
            $data['room'] = $room[$val['log_level']];
            $data['count_sum'] = $val['log_totaljushu'];
            $data['count_cy'] = $val['log_joinjushu'];
            $data['count_zb'] = $val['log_zuobijushu'];
            $data['count'] = $val['log_player'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['count_long'] = $val['log_longkaijiang'];
            $data['count_hu'] = $val['log_hukaijiang'];
            $data['count_he'] = $val['log_hekaijiang'];
            $data['count_ljh'] = $val['log_longjinhuakaijiang'];
            $data['count_lhbz'] = $val['log_longhubaozikaijiang'];
            $data['count_hjh'] = $val['log_hujinhuakaijiang'];
            $data['amount_long'] = ($val['log_longyazhu'] / 10000);
            $data['amount_hu'] = ($val['log_huyazhu'] / 10000);
            $data['amount_ljh'] = ($val['log_longjinhuayazhu'] / 10000);
            $data['amount_lhbz'] = ($val['log_longhubaoziyazhu'] / 10000);
            $data['amount_ljh'] = ($val['log_hujinhuayazhu'] / 10000);
            $data['count_system'] = ($val['log_systemjushu']);
            $data['amount_system'] = ($val['log_systemshuying'] / 10000);
            $data['amount_s_cs'] = ($val['log_systemchoushui'] / 10000);
            $data['count_player'] = $val['log_playerjushu'];
            $data['amount_player'] = ($val['log_playershuying'] / 10000);
            $data['amount_p_cs'] = ($val['log_playerchoushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $data['amount_fl'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.room1'), $layui_data['data'], '百人金花房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 龙虎斗概况
    public function longHuDou() {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_alllonghudougaikuang')->where($where_data)->count();
        $order = 'log_Time desc';

        $Query = M('log_alllonghudougaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);
            $data['count'] = $val['log_player'];
            $data['count1'] = $val['log_oneminute'];
            $data['count2'] = $val['log_tenminutes'];
            $data['count3'] = $val['log_halfhour'];
            $data['count4'] = $val['log_onehour'];
            $data['count5'] = $val['log_twohours'];
            $data['count6'] = $val['log_morethantwohours'];
            $data['count7'] = $val['log_threeminutes'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.overview1'), $layui_data['data'], '龙虎斗概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 龙虎斗房间数据
    public function longHuDouRoom() {
        $where_data = array();
        $data = array();
        $room = C('ROOM_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = (I('get.start_time') == '' ? '2018-08-16' : I('get.start_time'));
            $e_time = (I('get.end_time') == '' ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        switch (I('get.room/d')) {
            case 1:
                $where_data['log_Level'] = 1;
                break;
            case 2:
                $where_data['log_Level'] = 2;
                break;
            case 3:
                $where_data['log_Level'] = 3;
                break;
        }

        $layui_data['count'] = M('log_longhudougaikuang')->where($where_data)->count();
        $order = 'log_Time desc, log_Level asc';
        $Query = M('log_longhudougaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = $val['log_time'];
            $data['room'] = $room[$val['log_level']];
            $data['count_sum'] = $val['log_totaljushu'];
            $data['count_cy'] = $val['log_joinjushu'];
            $data['count_zb'] = $val['log_zuobijushu'];
            $data['count'] = $val['log_player'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['count_long'] = $val['log_longkaijiang'];
            $data['count_hu'] = $val['log_hukaijiang'];
            $data['count_he'] = $val['log_hekaijiang'];
            $data['amount_long'] = ($val['log_longyazhu'] / 10000);
            $data['amount_hu'] = ($val['log_huyazhu'] / 10000);
            $data['amount_he'] = ($val['log_heyazhu'] / 10000);
            $data['count_system'] = $val['log_systemjushu'];
            $data['amount_system'] = ($val['log_systemshuying'] / 10000);
            $data['amount_s_cs'] = ($val['log_systemchoushui'] / 10000);
            $data['count_player'] = $val['log_playerjushu'];
            $data['amount_player'] = ($val['log_playershuying'] / 10000);
            $data['amount_p_cs'] = ($val['log_playerchoushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $data['amount_fl'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.longhudou_room'), $layui_data['data'], '龙虎斗房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 百家乐概况
    public function baiJiaLe() {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allbaijialegaikuang')->where($where_data)->count();
        $order = 'log_Time desc';
        $Query = M('log_allbaijialegaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);
            $data['count'] = $val['log_player'];
            $data['count1'] = $val['log_oneminute'];
            $data['count2'] = $val['log_tenminutes'];
            $data['count3'] = $val['log_halfhour'];
            $data['count4'] = $val['log_onehour'];
            $data['count5'] = $val['log_twohours'];
            $data['count6'] = $val['log_morethantwohours'];
            $data['count7'] = $val['log_threeminutes'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.overview1'), $layui_data['data'], '百家乐概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 百家乐房间数据
    public function baiJiaLeRoom() {
        $where_data = array();
        $data = array();
        $room = C('ROOM_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = (I('get.start_time') == '' ? '2018-08-16' : I('get.start_time'));
            $e_time = (I('get.end_time') == '' ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        switch (I('get.room/d')) {
            case 1:
                $where_data['log_Level'] = 1;
                break;
            case 2:
                $where_data['log_Level'] = 2;
                break;
            case 3:
                $where_data['log_Level'] = 3;
                break;
        }

        $layui_data['count'] = M('log_baijialegaikuang')->where($where_data)->count();
        $order = 'log_Time desc, log_Level asc';
        $Query = M('log_baijialegaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = $val['log_time'];
            $data['room'] = $room[$val['log_level']];
            $data['count_sum'] = $val['log_totaljushu'];
            $data['count_cy'] = $val['log_joinjushu'];
            $data['count_zb'] = $val['log_zuobijushu'];
            $data['count'] = $val['log_player'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['count_z'] = $val['log_zhuang'];
            $data['count_x'] = $val['log_xian'];
            $data['count_h'] = $val['log_he'];
            $data['count_zd'] = $val['log_zhuangduizi'];
            $data['count_xd'] = $val['log_xianduizi'];
            $data['amount_z'] = ($val['log_zhuangyazhu'] / 10000);
            $data['amount_x'] = ($val['log_xianyazhu'] / 10000);
            $data['amount_h'] = ($val['log_heyazhu'] / 10000);
            $data['amount_zd'] = ($val['log_zhuangduiziyazhu'] / 10000);
            $data['amount_xd'] = ($val['log_xianduiziyazhu'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_fl'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.baijiale_room'), $layui_data['data'], '百家乐房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //跑得快概况
    public function paoDeKuai() {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allpaodekuaigaikuang')->where($where_data)->count();
        $order = 'log_Time desc';
        $Query = M('log_allpaodekuaigaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);
            $data['count'] = $val['log_player'];
            $data['count1'] = $val['log_oneminute'];
            $data['count2'] = $val['log_tenminutes'];
            $data['count3'] = $val['log_halfhour'];
            $data['count4'] = $val['log_onehour'];
            $data['count5'] = $val['log_twohours'];
            $data['count6'] = $val['log_morethantwohours'];
            $data['count7'] = $val['log_threeminutes'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.overview1'), $layui_data['data'], '跑得快概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 跑得快房间数据
    public function paoDeKuaiRoom() {
        $where_data = array();
        $data = array();
        $room = C('ROOM');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = (I('get.start_time') == '' ? '2018-08-16' : I('get.start_time'));
            $e_time = (I('get.end_time') == '' ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        switch (I('get.room/d')) {
            case 1:
                $where_data['log_Level'] = 1;
                break;
            case 2:
                $where_data['log_Level'] = 2;
                break;
            case 3:
                $where_data['log_Level'] = 3;
                break;
            case 4:
                $where_data['log_Level'] = 4;
                break;
        }

        $layui_data['count'] = M('log_paodekuaigaikuang')->where($where_data)->count();
        $order = 'log_Time desc, log_Level asc';
        $Query = M('log_paodekuaigaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = $val['log_time'];
            $data['room'] = $room[$val['log_level']];
            $data['count_sum'] = $val['log_totaljushu'];
            $data['count_cy'] = $val['log_joinjushu'];
            $data['count_zb'] = $val['log_zuobijushu'];
            $data['count'] = $val['log_player'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['amount_yz'] = ($val['log_totalyazhu'] / 10000);
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $data['amount_fl'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.room1'), $layui_data['data'], '跑得快房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 时时彩概况
    public function shiShiCai() {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allshishicaigaikuang')->where($where_data)->count();
        $order = 'log_Time desc';
        $Query = M('log_allshishicaigaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);
            $data['count'] = $val['log_player'];
            $data['count1'] = $val['log_oneminute'];
            $data['count2'] = $val['log_tenminutes'];
            $data['count3'] = $val['log_halfhour'];
            $data['count4'] = $val['log_onehour'];
            $data['count5'] = $val['log_twohours'];
            $data['count6'] = $val['log_morethantwohours'];
            $data['count7'] = $val['log_threeminutes'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['result'] = (($val['log_totalfajiang'] - $val['log_totalyazhu']) / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.shishicai_overview'), $layui_data['data'], '时时彩概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 时时彩房间数据
    public function shiShiCaiRoom() {
        $where_data = array();
        $data = array();
        $room = C('ROOM_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = (I('get.start_time') == '' ? '2018-08-16' : I('get.start_time'));
            $e_time = (I('get.end_time') == '' ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        if (I('get.room/d') > 0) {
            $where_data['log_Level'] = 1;
        }

        $layui_data['count'] = M('log_shishicaigaikuang')->where($where_data)->count();
        $order = 'log_Time desc, log_Level asc';
        $Query = M('log_shishicaigaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = $val['log_time'];
            $data['room'] = $room[$val['log_level']];
            $data['count_sum'] = $val['log_totaljushu'];
            $data['count_cy'] = $val['log_joinjushu'];
            $data['count_zb'] = $val['log_zuobijushu'];
            $data['count'] = $val['log_player'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['count_sp'] = $val['log_sanpai'];
            $data['count_dz'] = $val['log_duizi'];
            $data['count_sz'] = $val['log_shunzi'];
            $data['count_jh'] = $val['log_jinhua'];
            $data['count_sj'] = $val['log_shunjin'];
            $data['count_bz'] = $val['log_baozi'];
            $data['amount_sp'] = ($val['log_sanpaiyazhu'] / 10000);
            $data['amount_dz'] = ($val['log_duiziyazhu'] / 10000);
            $data['amount_sz'] = ($val['log_shunziyazhu'] / 10000);
            $data['amount_jh'] = ($val['log_jinhuayazhu'] / 10000);
            $data['amount_sj'] = ($val['log_shunjinyazhu'] / 10000);
            $data['amount_bz'] = ($val['log_baoziyazhu'] / 10000);
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.shishicai_room'), $layui_data['data'], '时时彩房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 幸运转盘概况
    public function xingYunZhuanPan() {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allxingyunzhuanpangaikuang')->where($where_data)->count();
        $order = 'log_Time desc';
        $Query = M('log_allxingyunzhuanpangaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);
            $data['count'] = $val['log_player'];
            $data['count1'] = $val['log_oneminute'];
            $data['count2'] = $val['log_tenminutes'];
            $data['count3'] = $val['log_halfhour'];
            $data['count4'] = $val['log_onehour'];
            $data['count5'] = $val['log_twohours'];
            $data['count6'] = $val['log_morethantwohours'];
            $data['count7'] = $val['log_threeminutes'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['result'] = (($val['log_totalfajiang'] - $val['log_totalyazhu']) / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.xingyunzhuanpan_overview'), $layui_data['data'], '幸运转盘概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 幸运转盘房间数据
    public function xingYunZhuanPanRoom() {
        $where_data = array();
        $data = array();
        $room = C('ROOM_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = (I('get.start_time') == '' ? '2018-08-16' : I('get.start_time'));
            $e_time = (I('get.end_time') == '' ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        switch (I('get.room/d')) {
            case 1:
                $where_data['log_Level'] = 1;
                break;
            case 2:
                $where_data['log_Level'] = 2;
                break;
            case 3:
                $where_data['log_Level'] = 3;
                break;
        }

        $layui_data['count'] = M('log_xingyunzhuanpangaikuang')->where($where_data)->count();
        $order = 'log_Time desc, log_Level asc';
        $Query = M('log_xingyunzhuanpangaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = $val['log_time'];
            $data['room'] = $room[$val['log_level']];
            $data['count_sum'] = $val['log_joinjushu'];
            $data['amount_sum'] = $val['log_totalyazhu'];
            $data['count'] = $val['log_player'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['count1'] = $val['log_gradeone'];
            $data['count2'] = $val['log_gradetwo'];
            $data['count3'] = $val['log_gradethree'];
            $data['count4'] = $val['log_gradefour'];
            $data['count5'] = $val['log_gradefive'];
            $data['count6'] = $val['log_gradesix'];
            $data['count7'] = $val['log_gradeseven'];
            $data['count8'] = $val['log_gradeeight'];
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.xingyunzhuanpan_room'), $layui_data['data'], '幸运转盘房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 奔驰宝马概况
    public function benChiBaoMa() {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allbenchibaomagaikuang')->where($where_data)->count();
        $order = 'log_Time desc';
        $Query = M('log_allbenchibaomagaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d', $val['log_time']);
            $data['count'] = $val['log_player'];
            $data['count1'] = $val['log_oneminute'];
            $data['count2'] = $val['log_tenminutes'];
            $data['count3'] = $val['log_halfhour'];
            $data['count4'] = $val['log_onehour'];
            $data['count5'] = $val['log_twohours'];
            $data['count6'] = $val['log_morethantwohours'];
            $data['count7'] = $val['log_threeminutes'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['result'] = (($val['log_totalfajiang'] - $val['log_totalyazhu']) / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.benchibaoma_overview'), $layui_data['data'], '奔驰宝马概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 奔驰宝马房间数据
    public function benChiBaoMaRoom() {
        $where_data = array();
        $data = array();
        $room = C('ROOM_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = (I('get.start_time') == '' ? '2018-08-16' : I('get.start_time'));
            $e_time = (I('get.end_time') == '' ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        switch (I('get.room/d')) {
            case 1:
                $where_data['log_Level'] = 1;
                break;
            case 2:
                $where_data['log_Level'] = 2;
                break;
            case 3:
                $where_data['log_Level'] = 3;
                break;
        }

        $layui_data['count'] = M('log_benchibaomagaikuang')->where($where_data)->count();
        $order = 'log_Time desc, log_Level asc';
        $Query = M('log_benchibaomagaikuang')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['time'] = $val['log_time'];
            $data['room'] = $room[$val['log_level']];
            $data['count_sum'] = $val['log_totaljushu'];
            $data['count_cy'] = $val['log_joinjushu'];
            $data['count_zb'] = $val['log_zuobijushu'];
            $data['count'] = $val['log_player'];
            $data['count_win'] = $val['log_winplayer'];
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf('%.4f', $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['count1'] = $val['log_ferrari'];
            $data['count2'] = $val['log_lamborghini'];
            $data['count3'] = $val['log_maserati'];
            $data['count4'] = $val['log_porsche'];
            $data['count5'] = $val['log_benz'];
            $data['count6'] = $val['log_bmw'];
            $data['count7'] = $val['log_honda'];
            $data['count8'] = $val['log_vw'];
            $data['amount1'] = ($val['log_ferrariyazhu'] / 10000);
            $data['amount2'] = ($val['log_lamborghiniyazhu'] / 10000);
            $data['amount3'] = ($val['log_maseratiyazhu'] / 10000);
            $data['amount4'] = ($val['log_porscheyazhu'] / 10000);
            $data['amount5'] = ($val['log_benzyazhu'] / 10000);
            $data['amount6'] = ($val['log_bmwyazhu'] / 10000);
            $data['amount7'] = ($val['log_hondayazhu'] / 10000);
            $data['amount8'] = ($val['log_vwyazhu'] / 10000);
            $data['count_s'] = $val['log_systemjushu'];
            $data['amount_ssy'] = ($val['log_systemshuying'] / 10000);
            $data['amount_scs'] = ($val['log_systemchoushui'] / 10000);
            $data['count_p'] = $val['log_playerjushu'];
            $data['amount_psy'] = ($val['log_playershuying'] / 10000);
            $data['amount_pcs'] = ($val['log_playerchoushui'] / 10000);
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.benchibaoma_room'), $layui_data['data'], '奔驰宝马房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 实时输赢
    // 实时输赢
    public function realTimeWinLose() {
        $where_data = array();
        $sum = '';
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        G('begin');

        switch (I('get.dayTime/d')) {
            case 3:
                $start_time = strtotime(date('Y-m-d', time() - 3 * 24 * 60 * 60));
                $end_time = time();
                break;
            case 7:
                $start_time = strtotime(date('Y-m-d', time() - 7 * 24 * 60 * 60));
                $end_time = time();
                break;
            case 1:
                $start_time = 0;
                $end_time = time();
                break;
            case 0:
                if (I('get.start_time') != '' || I('get.end_time') != '') {
                    $start_time = strtotime(I('get.start_time'));
                    $end_time = strtotime(I('get.end_time'));
                    if (I('get.start_time') == '') {
                        $start_time = 1;
                    }
                    if (I('get.end_time') == '') {
                        $end_time = time();
                    }
                }

                if (I('get.start_time') == '' && I('get.end_time') == '') {
                    $start_time = strtotime(date('Y-m-d'));
                    $end_time = $start_time + 24 * 60 * 60;
                }
        }

        if (isset($start_time)) {
            $where_data['log_DailyTime'] = array('between', array($start_time, $end_time));
        }

        if (I('get.uid/d') > 0) {
            $where_data['log_AccountID'] = I('get.uid/d');
        }

        switch (I('get.gameid/d')) {
            case 0:
                $sum = 'log_ALL';
                break;
            case 2:
                $sum = 'log_BRJH';
                break;
            case 3:
                $sum = 'log_LHD';
                break;
            case 4:
                $sum = 'log_BJL';
                break;
            case 5:
                $sum = 'log_SSC';
                break;
            case 6:
                $sum = 'log_BCBM';
                break;
            case 8:
                $sum = 'log_JH';
                break;
            case 9:
                $sum = 'log_NN';
                break;
            case 10:
                $sum = 'log_HB';
                break;
            case 11:
                $sum = 'log_TTZ';
                break;
            case 13:
                $sum = 'log_PDK';
                break;
        }

        $filed = "sum($sum) as win, log_AccountID, log_Name";
        if (I('get.yinshu') == 'yin') {
            $order = 'desc';
        } else {
            $order = 'asc';
        }

        $rows = M('log_shishishuying')->field($filed)->where($where_data)->group('log_AccountID')->order("win {$order}")->limit(50)->select();
        $num = 1;
        foreach ($rows as $key => $val) {
            if ($val['win'] < 0 && I('get.yinshu') == 'yin') break;
            if ($val['win'] > 0 && I('get.yinshu') == 'shu') break;
            $row_data['num'] = $num;
            $row_data['id'] = $val['log_accountid'];
            $row_data['name'] = $val['log_name'];
            $row_data['changevalue'] = $val['win'] / 10000;
            $num++;
            $data['data'][] = $row_data;
        }

        G('end');
        $data['sql'] = M('log_shishishuying')->getLastSql();
        $data['time'] = G('begin', 'end') . 's';
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    // 每日输赢
    // 每日输赢
    public function everydayLoseOrWin() {
        if (!IS_AJAX) {
            $this->show();
            return;
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
        }

        if (isset($start_time)) {
            $where['log_DailyTime'] = array('between', array($start_time, $end_time));
        }

        $sum = '';
        switch (I('get.SceneType/d')) {
            case 0:
                $sum = 'log_ALL';
                break;
            case 2:
                $sum = 'log_BRJH';
                break;
            case 3:
                $sum = 'log_LHD';
                break;
            case 4:
                $sum = 'log_BJL';
                break;
            case 5:
                $sum = 'log_SSC';
                break;
            case 6:
                $sum = 'log_BCBM';
                break;
            case 8:
                $sum = 'log_JH';
                break;
            case 9:
                $sum = 'log_NN';
                break;
            case 10:
                $sum = 'log_HB';
                break;
            case 11:
                $sum = 'log_TTZ';
                break;
            case 13:
                $sum = 'log_PDK';
                break;
        }

        $where['log_AccountID'] = I('get.accountid/d');
        $field = "sum($sum) as changevalue, log_AccountID, log_Name, log_DailyTime";
        $rows = M('log_shishishuying')->field($field)->where($where)->group('log_DailyTime')->order('log_DailyTime desc')->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        foreach ($rows as $row) {
            $row_data['date'] = date('Y-m-d', $row['log_DailyTime']);
            $row_data['uid'] = $row['log_accountid'];
            $row_data['name'] = $row['log_name'];
            $row_data['changevalue'] = $row['changevalue'] / 10000; //每日输赢
            $data['data'][] = $row_data;
        }
        $data['sql'] = M('log_shishishuying')->getLastSql();
        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        $this->ajaxReturn($data);
    }

    // 游戏流水
    // 游戏流水-牛牛
    public function niuNiuLS() {
        $where_data = $data = $layui_data = array();
        $room = C('ROOM');
        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != '') {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $layui_data['page'] = I('get.page/d');
        $order = 'log_ID desc';
        $layui_data['count'] = M('log_niuniuliushui')->where($where_data)->count() / 1;
        $Query = M('log_niuniuliushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_niuniuliushui')->where($where_data)->sum('log_varygold') / 10000;
        $layui_data['yazhu_total'] = abs(M('log_niuniuliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum('log_varygold') / 10000);
        $layui_data['fajiang_total'] = M('log_niuniuliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum('log_varygold') / 10000;

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['level'] = $room[$val['log_level']];
            $data['room_id'] = $val['log_roomid'];
            $data['vary_gold'] = ($val['log_varygold']) / 10000;
            $data['begin_gold'] = $val['log_begingold'] / 10000;
            $data['end_gold'] = $val['log_endgold'] / 10000;
            $data['id_z'] = $val['log_zhuangjia_accountid'];
            $data['result'] = $val['log_result'];
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.niuniu_turnover'), $layui_data['data'], '牛牛流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 游戏流水-炸金花
    public function yingSanZhangLS() {
        $where_data = $data = $layui_data = array();
        $room = C('ROOM');
        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');
        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }
        if (I('get.nickname') != '') {
            $where_data['log_Name'] = I('get.nickname');
        }
        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = 'log_ID desc';
        $layui_data['count'] = M('log_yingsanzhangliushui')->where($where_data)->count();
        $Query = M('log_yingsanzhangliushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_yingsanzhangliushui')->where($where_data)->sum('log_varygold') / 10000;
        $layui_data['yazhu_total'] = abs(M('log_yingsanzhangliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum('log_varygold') / 10000);
        $layui_data['fajiang_total'] = M('log_yingsanzhangliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum('log_varygold') / 10000;

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['level'] = $room[$val['log_level']];
            $data['room_id'] = $val['log_roomid'];
            $data['vary_gold'] = $val['log_varygold'] / 10000;
            $data['begin_gold'] = $val['log_begingold'] / 10000;
            $data['end_gold'] = $val['log_endgold'] / 10000;
            $data['id_z'] = $val['log_zhuangjia_accountid'];
            $data['result'] = $val['log_result'];
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.yingsanzhang_turnover'), $layui_data['data'], '炸金花流水');
        }

        $layui_data['code'] = 0;
        $layui_data['time'] = G('begin', 'end') . 's';
        $this->ajaxReturn($layui_data);
    }

    // 游戏流水-推筒子
    public function tuiTongZiLS() {
        $where_data = $data = $layui_data = array();
        $room = C('ROOM');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != '') {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = 'log_ID desc';
        $layui_data['count'] = M('log_tuitongziliushui')->where($where_data)->count();
        $Query = M('log_tuitongziliushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_tuitongziliushui')->where($where_data)->sum('log_varygold') / 10000;
        $layui_data['yazhu_total'] = abs(M('log_tuitongziliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum('log_varygold') / 10000);
        $layui_data['fajiang_total'] = M('log_tuitongziliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum('log_varygold') / 10000;

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['level'] = $room[$val['log_level']];
            $data['room_id'] = $val['log_roomid'];
            $data['vary_gold'] = ($val['log_varygold']) / 10000;
            $data['begin_gold'] = $val['log_begingold'] / 10000;
            $data['end_gold'] = $val['log_endgold'] / 10000;
            $data['id_z'] = $val['log_zhuangjia_accountid'];
            $data['result'] = $val['log_result'];
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.tuitongzi_turnover'), $layui_data['data'], '推筒子流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 游戏流水-红包接龙
    public function hongBaoJieLongLS() {
        $where_data = $data = $layui_data = array();
        $room = C('ROOM');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != '') {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = 'log_ID desc';
        $layui_data['count'] = M('log_hongbaojielongliushui')->where($where_data)->count();
        $Query = M('log_hongbaojielongliushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_hongbaojielongliushui')->where($where_data)->sum('log_varygold') / 10000;
        $layui_data['yazhu_total'] = abs(M('log_hongbaojielongliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum('log_varygold') / 10000);
        $layui_data['fajiang_total'] = M('log_hongbaojielongliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum('log_varygold') / 10000;

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['level'] = $room[$val['log_level']];
            $data['room_id'] = $val['log_roomid'];
            $data['vary_gold'] = ($val['log_varygold']) / 10000;
            $data['begin_gold'] = $val['log_begingold'] / 10000;
            $data['end_gold'] = $val['log_endgold'] / 10000;
            $data['jie_long'] = $val['log_jielong_accountid'];
            $data['result'] = $val['log_result'];
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.hongbaojielong_turnover'), $layui_data['data'], '红包接龙流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 游戏流水-百人金花
    public function baiRenJinHuaLS() {
        $where_data = $data = $layui_data = array();
        $room = C('ROOM_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');
        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != '') {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = 'log_ID desc';
        $layui_data['count'] = M('log_bairenjinhualiushui')->where($where_data)->count();
        $Query = M('log_bairenjinhualiushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_bairenjinhualiushui')->where($where_data)->sum('log_varygold') / 10000;
        $layui_data['yazhu_total'] = abs(M('log_bairenjinhualiushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum('log_varygold') / 10000);
        $layui_data['fajiang_total'] = M('log_bairenjinhualiushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum('log_varygold') / 10000;

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['level'] = $room[$val['log_level']];
            $data['room_id'] = $val['log_roomid'];
            $data['vary_gold'] = ($val['log_varygold']) / 10000;
            $data['begin_gold'] = $val['log_begingold'] / 10000;
            $data['end_gold'] = $val['log_endgold'] / 10000;
            $data['is_zj'] = $val['log_iszhuangjia'] == 0 ? '否' : '是';
            $data['long_yz'] = $val['log_longyazhu'] / 10000;
            $data['hu_yz'] = $val['log_huyazhu'] / 10000;
            $data['ljh_yz'] = $val['log_longjinhuayazhu'] / 10000;
            $data['lhbz_yz'] = $val['log_longhubaoziyazhu'] / 10000;
            $data['hjh_yz'] = $val['log_hujinhuayazhu'] / 10000;
            if (0 == I('get.isExecl/d')) {
                $result = explode(',', $val['log_cardtype_result']);
                $data['result1'] = $result[0];
                $data['result2'] = $result[1];
                $flag = explode(',', $val['log_result']);
                $data['flag1'] = $flag[0];
                $data['flag2'] = $flag[1];
                $data['flag3'] = $flag[2];
                $data['flag4'] = $flag[3];
            }
            if (1 == I('get.isExecl/d')) $data['result'] = $val['log_cardtype_result'];
            $data['result'] = $val['log_cardtype_result'];
            $data['is_bz'] = $val['log_isbaozhuang'] == 0 ? '否' : '是';
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.bairenjinhua_turnover'), $layui_data['data'], '百人金花流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 游戏流水-龙虎斗
    public function longHuDouLS() {
        $where_data = $data = $layui_data = array();
        $room = C('ROOM_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != '') {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));
        $order = 'log_ID desc';
        $layui_data['count'] = M('log_longhudouliushui')->where($where_data)->count();
        $Query = M('log_longhudouliushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_longhudouliushui')->where($where_data)->sum('log_varygold') / 10000;
        $layui_data['yazhu_total'] = abs(M('log_longhudouliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum('log_varygold') / 10000);
        $layui_data['fajiang_total'] = M('log_longhudouliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum('log_varygold') / 10000;

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['level'] = $room[$val['log_level']];
            $data['room_id'] = $val['log_roomid'];
            $data['vary_gold'] = ($val['log_varygold']) / 10000;
            $data['begin_gold'] = $val['log_begingold'] / 10000;
            $data['end_gold'] = $val['log_endgold'] / 10000;
            $data['is_zj'] = $val['log_iszhuangjia'] == 0 ? '否' : '是';
            $data['long_yz'] = $val['log_longyazhu'] / 10000;
            $data['hu_yz'] = $val['log_huyazhu'] / 10000;
            $data['he_yz'] = $val['log_heyazhu'] / 10000;
            if (0 == I('get.isExecl/d')) {
                $result = explode(',', $val['log_cardtype_result']);
                $data['result1'] = $result[0];
                $data['result2'] = $result[1];
                $data['flag'] = $val['log_result'];
            }
            if (1 == I('get.isExecl/d')) $data['result'] = $val['log_cardtype_result'];
            $data['is_bz'] = $val['log_isbaozhuang'] == 0 ? '否' : '是';
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.longhudou_turnover'), $layui_data['data'], '龙虎斗流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 游戏流水-百家乐
    public function baiJiaLeLS() {
        $where_data = $data = $layui_data = array();
        $room = C('ROOM_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != '') {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = 'log_ID desc';
        $layui_data['count'] = M('log_baijialeliushui')->where($where_data)->count();
        $Query = M('log_baijialeliushui')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_baijialeliushui')->where($where_data)->sum('log_varygold') / 10000;
        $layui_data['yazhu_total'] = abs(M('log_baijialeliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum('log_varygold') / 10000);
        $layui_data['fajiang_total'] = M('log_baijialeliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum('log_varygold') / 10000;

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['level'] = $room[$val['log_level']];
            $data['room_id'] = $val['log_roomid'];
            $data['vary_gold'] = ($val['log_varygold']) / 10000;
            $data['begin_gold'] = $val['log_begingold'] / 10000;
            $data['end_gold'] = $val['log_endgold'] / 10000;
            $data['z_amount'] = $val['log_zhuangyazhu'] / 10000;
            $data['x_amount'] = $val['log_xianyazhu'] / 10000;
            $data['h_amount'] = $val['log_heyazhu'] / 10000;
            $data['zd_amount'] = $val['log_zhuangduiziyazhu'] / 10000;
            $data['xd_amount'] = $val['log_xianduiziyazhu'] / 10000;
            $data['result'] = $val['log_cardtype_result'];
            if (0 == I('get.isExecl/d')) {
                $result = explode(',', $val['log_cardtype_result']);
                $data['result1'] = $result[0];
                $data['result2'] = $result[1];
                $flag = explode(',', $val['log_result']);
                $data['flag1'] = $flag[0];
                $data['flag2'] = $flag[1];
                $data['flag3'] = $flag[2];
            }
            if (1 == I('get.isExecl/d')) $data['result'] = $val['log_cardtype_result'];
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.baijiale_turnover'), $layui_data['data'], '百家乐流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 游戏流水-跑得快
    public function paoDeKuaiLS() {
        $where_data = $data = $layui_data = array();
        $room = C('ROOM');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != '') {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));
        $order = 'log_ID desc';
        $layui_data['count'] = M('log_paodekuailiushui')->where($where_data)->count();
        $Query = M('log_paodekuailiushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_paodekuailiushui')->where($where_data)->sum('log_varygold') / 10000;
        $layui_data['yazhu_total'] = abs(M('log_paodekuailiushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum('log_varygold') / 10000);
        $layui_data['fajiang_total'] = M('log_paodekuailiushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum('log_varygold') / 10000;

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['level'] = $room[$val['log_level']];
            $data['room_id'] = $val['log_roomid'];
            $data['vary_gold'] = ($val['log_varygold']) / 10000;
            $data['begin_gold'] = $val['log_begingold'] / 10000;
            $data['end_gold'] = $val['log_endgold'] / 10000;
            $data['result'] = $val['log_result'];
            $data['result1'] = $val['log_result1'];
            $data['result2'] = $val['log_result2'];
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.paodekuai_turnover'), $layui_data['data'], '跑得快流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 游戏流水-时时彩
    public function shiShiCaiLS() {
        $where_data = $data = $layui_data = array();
        $ssc = C('SSC');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != '') {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));
        $order = 'log_ID desc';
        $layui_data['count'] = M('log_shishicailiushui')->where($where_data)->count();
        $Query = M('log_shishicailiushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_shishicailiushui')->where($where_data)->sum('log_varygold') / 10000;
        $layui_data['yazhu_total'] = abs(M('log_shishicailiushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum('log_varygold') / 10000);
        $layui_data['fajiang_total'] = M('log_shishicailiushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum('log_varygold') / 10000;

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['vary_gold'] = $val['log_varygold'] / 10000;
            $data['begin_gold'] = $val['log_begingold'] / 10000;
            $data['end_gold'] = $val['log_endgold'] / 10000;
            $data['result'] = $ssc[$val['log_cardtype_result']];
            $data['san_pai'] = $val['log_sanpaiyazhu'] / 10000;
            $data['dui_zi'] = $val['log_duiziyazhu'] / 10000;
            $data['shun_zi'] = $val['log_shunziyazhu'] / 10000;
            $data['jin_hua'] = $val['log_jinhuayazhu'] / 10000;
            $data['shun_jin'] = $val['log_shunjinyazhu'] / 10000;
            $data['bao_zi'] = $val['log_baoziyazhu'] / 10000;
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.shishicai_turnover'), $layui_data['data'], '时时彩流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 游戏流水-幸运转盘
    public function xingYunZhuanPanLS() {
        $where_data = $data = $layui_data = array();
        $room = C('ROOM_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != '') {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));
        $order = 'log_ID desc';
        $layui_data['count'] = M('log_xingyunzhuanpanliushui')->where($where_data)->count();
        $Query = M('log_xingyunzhuanpanliushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_xingyunzhuanpanliushui')->where($where_data)->sum('log_varygold') / 10000;
        $layui_data['yazhu_total'] = abs(M('log_xingyunzhuanpanliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum('log_varygold') / 10000);
        $layui_data['fajiang_total'] = M('log_xingyunzhuanpanliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum('log_varygold') / 10000;

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['level'] = $room[$val['log_level']];
            $data['vary_gold'] = ($val['log_varygold']) / 10000;
            $data['begin_gold'] = $val['log_begingold'] / 10000;
            $data['end_gold'] = $val['log_endgold'] / 10000;
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.xingyunzhuanpan_turnover'), $layui_data['data'], '幸运转盘流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 游戏流水-奔驰宝马
    public function benChiBaoMaLS() {
        $where_data = $data = $layui_data = array();
        $room = C('ROOM_');
        $bcbm_result = C('BCBM_RESULT');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != '') {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));
        $order = 'log_ID desc';
        $layui_data['count'] = M('log_benchibaomaliushui')->where($where_data)->count();
        $Query = M('log_benchibaomaliushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $layui_data['sql'] = M('log_benchibaomaliushui')->getLastSql();

        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_benchibaomaliushui')->where($where_data)->sum('log_varygold') / 10000;
        $layui_data['yazhu_total'] = abs(M('log_benchibaomaliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum('log_varygold') / 10000);
        $layui_data['fajiang_total'] = M('log_benchibaomaliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum('log_varygold') / 10000;

        foreach ($data_list as $key => $val) {
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['level'] = $room[$val['log_level']];
            $data['vary_gold'] = ($val['log_varygold']) / 10000;
            $data['begin_gold'] = $val['log_begingold'] / 10000;
            $data['end_gold'] = $val['log_endgold'] / 10000;
            $data['result'] = $bcbm_result[$val['log_cardtype_result']];
            $data['ferrari'] = $val['log_ferrari'] / 10000;
            $data['lamborghini'] = $val['log_lamborghini'] / 10000;
            $data['maserati'] = $val['log_maserati'] / 10000;
            $data['porsche'] = $val['log_porsche'] / 10000;
            $data['benz'] = $val['log_benz'] / 10000;
            $data['bmw'] = $val['log_bmw'] / 10000;
            $data['honda'] = $val['log_honda'] / 10000;
            $data['vw'] = $val['log_vw'] / 10000;
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.benchibaoma_turnover'), $layui_data['data'], '奔驰宝马流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 游戏流水汇总
    public function allGamesLS() {
        $where_data = $data = $layui_data = array();
        $reason = C('OPERATE');
        $game = C('GAMES');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        if (I('get.account/d') == '' && I('get.start_time') == '' && I('get.end_time') == '' && I('get.game/d') <= 0 && I('get.minAmount') <= 0 && I('get.maxAmount') <= 0) {
            if (1 == I('get.isExecl/d')) $this->doExcelData(C('cellName.all_turnover'), $layui_data['data'], '游戏流水汇总');
            $this->ajaxReturn(array('code' => 0));
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $where_data['log_IsGameChange'] = 1;
        if (I('get.game/d') != 0) {
            $where_data['log_SceneType'] = I('get.game/d');
        }
        if (I('get.minAmount') != '' && I('get.maxAmount') != '') {
            $where_data['log_ChangeValue'] = array(array('between', array(I('get.minAmount/d') * 10000, I('get.maxAmount/d') * 10000)), array('between', array(-I('get.maxAmount/d') * 10000, -I('get.minAmount/d') * 10000)), 'or');
        }
        if (I('get.minAmount/d') > 0 && I('get.maxAmount/d') <= 0) {
            $where_data['log_ChangeValue'] = array(array('gt', I('get.minAmount/d') * 10000), array('lt', -I('get.minAmount/d') * 10000), 'or');
        }
        if (I('get.maxAmount/d') > 0 && I('get.minAmount/d') <= 0) {
            $where_data['log_ChangeValue'] = array('between', array(-I('get.maxAmount/d') * 10000, I('get.maxAmount/d') * 10000));
        }

        $order = 'log_ID desc';
        $layui_data['count'] = M('log_gold')->where($where_data)->count();
        $Query = M('log_gold')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        $layui_data['sql'] = $Query->getLastSql();

        foreach ($data_list as $key => $val) {
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['log_name'];
            $data['game'] = $game[$val['log_scenetype']];
            $data['vary'] = $val['log_changevalue'] / 10000;
            $data['reason'] = $reason[$val['log_operate']];
            $data['balance'] = $val['log_value'] / 10000;
            $data['time'] = $val['log_time'];
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.all_turnover'), $layui_data['data'], '游戏流水汇总');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 推广员统计
    // 推广员概况
    public function promotersStatistics() {
        $where = array();
        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->show();
            return;
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
            $where['log_ID'] = array('between', array($start_time, $end_time));
        }

        $Query = M('log_proxygaikuang')->where($where)->order('log_ID desc');
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();
        $data['count'] = M('log_proxygaikuang')->count();
        foreach ($rows as $row) {
            $row_data['CountTime'] = date('Y-m-d', $row['log_id']);  // 日期
            $row_data['ProxyTotalNum'] = $row['log_allnum'];  // 总人数
            $row_data['ProxyTotalokNum'] = $row['log_proxynum'];  // 推广员总人数
            $row_data['UserTotalNum'] = $row['log_membernum'];  // 会员总人数
            $row_data['DayProxyTotalNum'] = $row['log_newproxynum'];  // 新增推广员人数
            $row_data['DayNewUserTotalNum'] = $row['log_newmembernum'];  // 新增会员人数
            $row_data['UserPayTotal'] = $row['log_membercharge'];  // 会员充值总额
            $row_data['DayUserPayTotal'] = $row['log_todaymembercharge'];  // 今日会员充值额
            $row_data['UserOutTotal'] = $row['log_memberbet'] / 10000;  // 会员下注总额
            $row_data['DayUserOutTotal'] = $row['log_todaymemberbet'] / 10000;  // 今日会员下注额
            $row_data['CommissionTotal'] = $row['log_allcommission'] / 10000;  // 总佣金
            $row_data['DayCommissionTotal'] = $row['log_todaycommission'] / 10000;  // 今日佣金
            $row_data['DayOutCommissionTotal'] = $row['log_todaytakecommission'] / 10000;  // 今日提取佣金
            $row_data['SurplusCommissionTotal'] = $row['log_leavecommission'] / 10000;  // 剩余佣金

            $data['data'][] = $row_data;
        }
        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        if (1 == I('get.isExecl/d')) ($this->doExcelData(C('cellName.gameOverview_promotersStatistics'), $data['data'], '推广员概况'));
        $this->ajaxReturn($data);
    }

    // 佣金变化明细
    public function yongJinDetail() {
        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->show();
            return;
        }

        if (I('get.proxyid/d') == 0 && I('get.uid/d') == 0) {
            $data['code'] = 0;
            $this->ajaxReturn($data);
            return;
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
            $where['log_Time'] = array('between', array($start_time, $end_time));
        }
        $where = array();
        if (I('get.proxyid/d') != 0) {
            $where ['log_AccountID'] = I('get.proxyid/d');
        }
        if (I('get.uid/d') != 0) {
            $where ['log_Offer_AccountID'] = I('get.uid/d');
        }

        $field = 'log_AccountID, log_Offer_AccountID, log_VaryYongJin, log_BeginYongJin, log_EndYongJin, log_Time';
        $Query = M('log_yongjinliushui')->field($field)->where($where)->order('log_ID desc');
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();
        $data['sql'] = M('log_yongjinliushui')->getLastSql();
        $data['count'] = M('log_yongjinliushui')->where($where)->count();
        foreach ($rows as $key => $row) {
            $row_data['AccountID'] = $row['log_accountid'];
            $row_data['OfferAccountID'] = $row['log_offer_accountid'];
            $row_data['VaryYongJin'] = $row['log_varyyongjin'] / 10000;
            $row_data['BeginYongJin'] = $row['log_beginyongjin'] / 10000;
            $row_data['EndYongJin'] = $row['log_endyongjin'] / 10000;
            $row_data['LogTime'] = date('Y-m-d H:i:s', $row['log_time']);
            $data['data'][] = $row_data;
        }

        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        if (1 == I('get.isExecl/d')) ($this->doExcelData(C('cellName.gameOverview_yongJinDetail'), $data['data'], '佣金明细'));
        $this->ajaxReturn($data);
    }

    // 推广员明细
    public function proxyList() {
        $where_data = array();
        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->show();
            return;
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
        }

        if (isset($start_time)) {
            $where_data['log_Time'] = array('between', array($start_time, $end_time));
        }

        if (I('get.proxyid/d') > 0) {
            $where_data['log_AccountID'] = I('get.proxyid/d');
        }

        if (I('get.uid/d') > 0) {
            $where_data['log_Member_AccountID'] = I('get.uid/d');
        }

        $sub1 = M('gd_proxy')->field('gd_JsonBetCommission')->where(['gd_AccountID = log_AccountID'])->buildSql();
        $sub2 = M('gd_proxy')->field('gd_JsonOneDayBetCommission')->where(['gd_AccountID = log_AccountID'])->buildSql();
        $field = "log_AccountID, log_Name, log_Type, log_Member_AccountID, log_Member_Name, log_Member_Reg_Time,
        log_Time, $sub1 AS sub1, $sub2 AS sub2";

        $Query = M('log_proxymingxi')->field($field)->where($where_data)->order('log_Time desc');
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();
        $data['sql'] = M('log_proxymingxi')->getLastSql();
        $data['count'] = M('log_proxymingxi')->where($where_data)->count();
        foreach ($rows as $val) {
            $row_data['accountid'] = $val['log_accountid'];
            $row_data['proxyname'] = $val['log_name'];
            $row_data['type'] = ($val['log_type'] == 1) ? '直属会员' : '其它会员';
            $row_data['userid'] = $val['log_member_accountid'];
            $row_data['userName'] = $val['log_member_name'];
            $row_data['userRegTime'] = date('Y-m-d H:i:s', $val['log_member_reg_time']);
            $row_data['BindTime'] = date('Y-m-d H:i:s', $val['log_time']);
            $sub1_data = json_decode($val['sub1'], true);
            if (isset($sub1_data[$val['log_member_accountid']])) {
                $row_data['NTotalBet'] = $sub1_data[$val['log_member_accountid']]['nBet'] / 10000;
                $row_data['VaryYongJin'] = $sub1_data[$val['log_member_accountid']]['nCommission'] / 10000;
            } else {
                $row_data['NTotalBet'] = 0;
                $row_data['VaryYongJin'] = 0;
            }
            $sub2_data = json_decode($val['sub2'], true);
            if (isset($sub2_data[$val['log_member_accountid']])) {
                $row_data['DayTotalOutMoney'] = $sub2_data[$val['log_member_accountid']]['nBet'] / 10000;
                $row_data['DayOfferYingjin'] = $sub2_data[$val['log_member_accountid']]['nCommission'] / 10000;
            } else {
                $row_data['DayTotalOutMoney'] = 0;
                $row_data['DayOfferYingjin'] = 0;
            }

            $data['data'][] = $row_data;
        }

        $data['code'] = 0;
        if (1 == I('get.isExecl/d')) ($this->doExcelData(C('cellName.gameOverview_proxyList'), $data['data'], '推广员明细'));
        $this->ajaxReturn($data);
    }

    // 推广员榜
    function proxyTop() {
        $where_data = array();
        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->show();
            return;
        }
        if (I('get.proxyid/d') > 0) {
            $where_data['gd_AccountID'] = I('get.proxyid/d');
        }

        $day_zero_time = strtotime(date('Y-m-d', time()));

        $field = 'gd_AccountID, gd_Name, gd_AllCommission, gd_CanTakeCommission, gd_JsonOneDayBetCommission, gd_JsonBetCommission,
        gd_DirectMember, gd_OtherMember';
        $Query = M('gd_proxy')->field($field)->where($where_data)->order('gd_AllCommission desc');
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();
        $data['count'] = M('gd_proxy')->where($where_data)->count();
        $num = (I('get.page/d') - 1) * I('get.limit/d') + 1;
        foreach ($rows as $val) {
            $row_data['Num'] = $num; //名次
            $row_data['ProxyId'] = $val['gd_accountid']; //推广员ID
            $row_data['Proxyname'] = $val['gd_name']; //推广员昵称
            $row_data['YongjinTotal'] = $val['gd_allcommission'] / 10000; //总佣金
            $row_data['ShengYuYongjinTotal'] = $val['gd_cantakecommission'] / 10000; //剩余佣金
            $one_day = json_decode($val['gd_jsononedaybetcommission'], true);
            $new_yongjin = $new_bet = $new_member = 0;
            $new_charge_member = $new_charge_num = 0;
            foreach ($one_day as $k => $v) {
                if ($v['nTime'] == $day_zero_time) {
                    $new_yongjin += $v['nCommission'];
                    $new_bet += $v['nBet'];
                    $new_member += 1;
                    if ($v['nCharge'] > 0) {
                        $new_charge_member += 1;
                        $new_charge_num += $v['nCharge'];
                    }
                }
            }
            $row_data['XinZengYongjinTotal'] = $new_yongjin / 10000;
            $row_data['XiazhuNewUsdtTotal'] = $new_bet / 10000;
            $row_data['NewUserTotal'] = $new_member;
            $row_data['NewUserPayTotal'] = $new_charge_member;
            $row_data['NewMoneyPayTotal'] = $new_charge_num;
            $all_day = json_decode($val['gd_jsonbetcommission'], true);
            $zhishu_yongjin = $other_yongjin = $zhishu_bet = $other_bet = $zhishu_member = $other_member = 0;
            $zhishu_charge_member = $zhishu_charge_num = $other_charge_member = $other_charge_num = 0;
            foreach ($all_day as $k => $v) {
                if ($v['nType'] == 1) {
                    $zhishu_yongjin += $v['nCommission'];
                    $zhishu_bet += $v['nBet'];
                    $zhishu_member += 1;
                    if ($v['nCharge'] > 0) {
                        $zhishu_charge_member += 1;
                        $zhishu_charge_num += $v['nCharge'];
                    }
                } elseif ($v['nType'] == 2) {
                    $other_yongjin += $v['nCommission'];
                    $other_bet += $v['nBet'];
                    $other_member += 1;
                    if ($v['nCharge'] > 0) {
                        $other_charge_member += 1;
                        $other_charge_num += $v['nCharge'];
                    }
                }
            }
            $row_data['ZhishuYongjinTotal'] = $zhishu_yongjin / 10000;
            $row_data['XiazhuzhishuTotal'] = $zhishu_bet / 10000;
            $row_data['ZhishuUserTotal'] = $zhishu_member;
            $row_data['OtherYongjinTotal'] = $other_yongjin / 10000;
            $row_data['XiazhuOtherTotal'] = $other_bet / 10000;
            $row_data['OtherUserTotal'] = $other_member;
            $row_data['XiazhuTotal'] = ($zhishu_bet + $other_bet) / 10000;
            $row_data['UserTotal'] = $zhishu_member + $other_member;
            $row_data['OneUserPayTotal'] = $zhishu_charge_member;
            $row_data['OtherUserPayTotal'] = $other_charge_member;
            $row_data['UserPayTotal'] = $zhishu_charge_member + $other_charge_member;
            $row_data['OneMoneyPayTotal'] = $zhishu_charge_num;
            $row_data['OtheMoneyPayTotal'] = $other_charge_num;
            $row_data['MoneyPayTotal'] = $zhishu_charge_num + $other_charge_num;

            if (0 == I('get.isExecl/d')) $row_data['url'] = U('GameOverview/proxyUserDate', array('accountid' => $row_data['proxyId']));
            $data['data'][] = $row_data;
            $num++;
        }

        $data['code'] = 0;
        if (1 == I('get.isExecl/d')) ($this->doExcelData(C('cellName.gameOverview_proxyTop'), $data['data'], '推广员榜'));
        $this->ajaxReturn($data);
    }

    // 推广员个人按日期统计
    public function proxyUserDate() {
        $where_data = array();
        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->show();
            return;
        }
        if (I('get.accountid/d') == 0) {
            $data['code'] = 0;
            $this->ajaxReturn($data);
            return;
        }

        $where = array();
        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $start_time = strtotime(I('get.start_time'));
            $end_time = strtotime(I('get.end_time')) + 24 * 3600 - 1;
            if (I('get.start_time') == '') {
                $start_time = 1;
            }
            if (I('get.end_time') == '') {
                $end_time = time();
            }
            $where['log_ID'] = array('between', array($start_time, $end_time));
        }

        $sub1 = M('gd_proxy')->field('gd_Name')->where(['gd_AccountID' => I('get.accountid/d')])->buildSql();
        $sub2 = M('log_yongjinliushui')->field('MAX(log_EndYongJin)')->where(['log_DailyTime = a.log_ID', 'log_AccountID' => I('get.accountid/d')])->buildSql();
        $sub3 = M('gd_proxy')->field('gd_JsonOneDayBetCommission')->where(['gd_AccountID' => I('get.accountid/d')])->buildSql();
        $sub4 = M('log_yongjinliushui')->field('MAX(log_DirectCommission)')->where(['log_DailyTime = a.log_ID', 'log_IsDirectMember' => 1, 'log_AccountID' => I('get.accountid/d')])->buildSql();
        $sub5 = M('log_yongjinliushui')->field('MAX(log_OtherCommission)')->where(['log_DailyTime = a.log_ID', 'log_IsDirectMember' => 0, 'log_AccountID' => I('get.accountid/d')])->buildSql();
        $sub6 = M('log_yongjinliushui')->field('MAX(log_DirectBet)')->where(['log_DailyTime = a.log_ID', 'log_IsDirectMember' => 1, 'log_AccountID' => I('get.accountid/d')])->buildSql();
        $sub7 = M('log_yongjinliushui')->field('MAX(log_OtherBet)')->where(['log_DailyTime = a.log_ID', 'log_IsDirectMember' => 0, 'log_AccountID' => I('get.accountid/d')])->buildSql();
        $sub8 = M('log_yongjinliushui')->field('MAX(log_DirectMember)')->where(['log_DailyTime = a.log_ID', 'log_AccountID' => I('get.accountid/d')])->buildSql();
        $sub9 = M('log_yongjinliushui')->field('MAX(log_OtherMember)')->where(['log_DailyTime = a.log_ID', 'log_AccountID' => I('get.accountid/d')])->buildSql();
        $sub10 = M('log_yongjinliushui')->field('MAX(log_DirectChargeMember)')->where(['log_DailyTime = a.log_ID', 'log_AccountID' => I('get.accountid/d')])->buildSql();
        $sub11 = M('log_yongjinliushui')->field('MAX(log_OtherChargeMember)')->where(['log_DailyTime = a.log_ID', 'log_AccountID' => I('get.accountid/d')])->buildSql();
        $sub12 = M('log_yongjinliushui')->field('MAX(log_DirectChargeNum)')->where(['log_DailyTime = a.log_ID', 'log_AccountID' => I('get.accountid/d')])->buildSql();
        $sub13 = M('log_yongjinliushui')->field('MAX(log_OtherChargeNum)')->where(['log_DailyTime = a.log_ID', 'log_AccountID' => I('get.accountid/d')])->buildSql();

        $filed = "log_ID, $sub1 AS sub1, $sub2 AS sub2, $sub3 AS sub3, $sub4 AS sub4, $sub5 AS sub5, $sub6 AS sub6,
        $sub7 AS sub7, $sub8 AS sub8, $sub9 AS sub9, $sub10 AS sub10, $sub11 AS sub11, $sub12 AS sub12, $sub13 AS sub13";
        $Query = M('log_jingjigaikuang')->alias('a')->field($filed)->where($where)->group('log_ID')->order('log_ID asc');
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();

        $data['sql'] = M('log_jingjigaikuang')->getLastSql();
        $data['count'] = M('log_jingjigaikuang')->count();
        $tmp1 = $tmp2 = $tmp3 = $tmp4 = $tmp5 = $tmp6 = $tmp7 = $tmp8 = $tmp9 = $tmp10 = $tmp11 = $tmp12 = 0;
        foreach ($rows as $val) {
            $one_day = json_decode($val['sub3'], true);
            $new_yongjin = $new_bet = $new_member = 0;
            $new_charge_member = $new_charge_num = 0;
            foreach ($one_day as $k => $v) {
                if ($v['nTime'] == $val['log_id']) {
                    $new_yongjin += $v['nCommission'];
                    $new_bet += $v['nBet'];
                    $new_member += 1;
                    if ($v['nCharge'] > 0) {
                        $new_charge_member += 1;
                        $new_charge_num += $v['nCharge'];
                    }
                }
            }
            $row_data['LogTime'] = date('Y-m-d', $val['log_id']);  // 日期
            $row_data['ProxyId'] = I('get.accountid/d');  // 推广员ID
            $row_data['Proxyname'] = $val['sub1'];  // 推广员昵称
            $row_data['ShenYongjinTotal'] = $val['sub2'] == NULL ? $tmp2 : $val['sub2'] / 10000;  // 剩余佣金
            $tmp2 = $row_data['ShenYongjinTotal'];
            $row_data['XinZhenYongjinTotal'] = $new_yongjin;  // 新增会员佣金
            $row_data['ZhishuYongjinTotal'] = $val['sub4'] == NULL ? $tmp3 : $val['sub4'] / 10000;  // 直属会员佣金
            $tmp3 = $row_data['ZhishuYongjinTotal'];
            $row_data['OtherYongjinTotal'] = $val['sub5'] == NULL ? $tmp4 : $val['sub5'] / 10000;  // 其他会员佣金
            $tmp4 = $row_data['OtherYongjinTotal'];
            $row_data['YongjinTotal'] = $row_data['ZhishuYongjinTotal'] + $row_data['OtherYongjinTotal'];  // 总佣金
            $row_data['XiazhuzhishuTotal'] = $val['sub6'] == NULL ? $tmp5 : $val['sub6'] / 10000;  // 直属会员下注总额
            $tmp5 = $row_data['XiazhuzhishuTotal'];
            $row_data['XiazhuOtherTotal'] = $val['sub7'] == NULL ? $tmp6 : $val['sub7'] / 10000;  // 其他会员下注总额
            $tmp6 = $row_data['XiazhuOtherTotal'];
            $row_data['XiazhuTotal'] = $row_data['XiazhuzhishuTotal'] + $row_data['XiazhuOtherTotal'];  // 会员下注总额
            $row_data['XiazhuNewUsdtTotal'] = $new_bet;  // 新增会员下注总
            $row_data['ZhishuUserTotal'] = $val['sub8'] == NULL ? $tmp7 : $val['sub8'] / 1;  // 直属会员人数
            $tmp7 = $row_data['ZhishuUserTotal'];
            $row_data['OtherUserTotal'] = $val['sub9'] == NULL ? $tmp8 : $val['sub9'] / 1;  // 其他会员人数
            $tmp8 = $row_data['OtherUserTotal'];
            $row_data['UserTotal'] = $row_data['ZhishuUserTotal'] + $row_data['OtherUserTotal'];  // 会员总数
            $row_data['NewUserTotal'] = $new_member;  // 新增会员人数
            $row_data['NewUserPayTotal'] = $new_charge_member;  // 新增会员充值人数
            $row_data['OneUserPayTotal'] = $val['sub10'] == NULL ? $tmp9 : $val['sub10'] / 1;  // 直属会员充值人数
            $tmp9 = $row_data['OneUserPayTotal'];
            $row_data['OtherUserPayTotal'] = $val['sub11'] == NULL ? $tmp10 : $val['sub11'] / 1;  // 其他会员充值人数
            $tmp10 = $row_data['OtherUserPayTotal'];
            $row_data['UserPayTotal'] = $row_data['OneUserPayTotal'] + $row_data['OtherUserPayTotal'];  // 会员充值总人数
            $row_data['OneMoneyPayTotal'] = $val['sub12'] == NULL ? $tmp11 : $val['sub12'] / 1;  // 直属会员充值金额
            $tmp11 = $row_data['OneMoneyPayTotal'];
            $row_data['OtheMoneyPayTotal'] = $val['sub13'] == NULL ? $tmp12 : $val['sub13'] / 1;  // 其他会员充值金额
            $tmp12 = $row_data['OtheMoneyPayTotal'];
            $row_data['MoneyPayTotal'] = $row_data['OneMoneyPayTotal'] + $row_data['OtheMoneyPayTotal'];  // 会员充值总金额
            $row_data['NewMoneyPayTotal'] = $new_charge_num;  // 新增会员充值金额

            $data['data'][] = $row_data;
        }

        $data['data'] = array_reverse($data['data']);
        $data['code'] = 0;
        if (1 == I('get.isExecl/d')) ($this->doExcelData(C('cellName.gameOverview_proxyUserDate'), $data['data'], '推广员查询'));
        $this->ajaxReturn($data);
    }

    // 代理统计
    // 银商发钱明细
    public function emailDetail() {
        $where = array();
        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->show();
            return;
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
        } else {
            $start_time = strtotime(date('Y-m-d'));
            $end_time = time();
        }

        if (isset($start_time)) $where['bk_RecieveTime'] = array('between', array($start_time, $end_time));

        $sendid = I('get.sendid');
        if (!empty($sendid)) {
            $sendid = explode(',', $sendid);
            $where['bk_DailiID'] = array('in', $sendid);
        }

        $receiverid = I('get.receiverid');
        if (!empty($receiverid)) {
            $receiverid = explode(',', $receiverid);
            $where['bk_PlayerID'] = array('in', $receiverid);
        }

        $Query = M('bk_dailichargeliushui')->where($where)->order('bk_ID desc');
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();
        $data['count'] = M('bk_dailichargeliushui')->where($where)->count();

        $data['TotalMoney'] = M('bk_dailichargeliushui')->where($where)->sum('bk_ChangeGold') / 10000;

        foreach ($rows as $key => $row) {
            $row_data['id'] = $row['bk_id'];  //序号
            $row_data['DailiID'] = $row['bk_dailiid'];  //发送方ID
            $row_data['DailiName'] = $row['bk_dailiname']; //发送方昵称
            $row_data['DailiBefore'] = $row['bk_dailibefore'] / 10000; //发送前金币
            $row_data['DailiEnd'] = $row['bk_dailiend'] / 10000;  //发送后金币
            $row_data['ChargeTime'] = date('Y-m-d H:i:s', $row['bk_chargetime']);  //发送时间
            $row_data['PlayerID'] = $row['bk_playerid'];  //接收方ID
            $row_data['PlayerName'] = $row['bk_playername'];  //接收昵称
            $row_data['PlayerBefore'] = $row['bk_playerbefore'] / 10000;  //接收前金币
            $row_data['PlayerEnd'] = $row['bk_playerend'] / 10000;  //接收后金币
            $row_data['RecieveTime'] = date('Y-m-d H:i:s', $row['bk_recievetime']);  //接收时间
            $row_data['ChangeGold'] = $row['bk_changegold'] / 10000;  //本次变更金币
            $data['data'][] = $row_data;
        }

        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        if (1 == I('get.isExecl/d')) ($this->doExcelData(C('cellName.gameOverview_emailDetail'), $data['data'], '代理充值明细'));
        $this->ajaxReturn($data);
    }

    // 银商发送量统计
    public function emailSendCount() {
        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->show();
            return;
        }

        $where = $subWhere = array();
        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $start_time = strtotime(I('get.start_time'));
            $end_time = strtotime(I('get.end_time')) + 24 * 3600 - 1;
            if (I('get.start_time') == '') {
                $start_time = 1;
            }
            if (I('get.end_time') == '') {
                $end_time = time();
            }
        }

        if (isset($start_time)) {
            $where['bk_DailyTime'] = array('between', array($start_time, $end_time));
        }

        $number = I('get.number/d');
        if ($number != 0) {
            $subWhere['bk_Number'] = $number;
        }

        $sub1 = M('bk_dailichargeliushui')->field('COUNT(bk_DailiID)')->where($where + $subWhere + ['bk_DailyTime = a.bk_DailyTime'])->buildSql();
        $sub2 = M('bk_dailichargeliushui')->field('COUNT(DISTINCT bk_DailiID)')->where($where + $subWhere + ['bk_DailyTime = a.bk_DailyTime'])->buildSql();
        $sub3 = M('bk_dailichargeliushui')->field('COUNT(DISTINCT bk_PlayerID)')->where($where + $subWhere + ['bk_DailyTime = a.bk_DailyTime'])->buildSql();
        $sub4 = M('bk_dailichargeliushui')->field('COUNT(bk_IsFirst)')->where($where + $subWhere + ['bk_DailyTime = a.bk_DailyTime', 'bk_IsFirst = 1'])->buildSql();
        $sub5 = M('bk_dailichargeliushui')->field('SUM(bk_ChangeGold)')->where($where + $subWhere + ['bk_DailyTime = a.bk_DailyTime', 'bk_IsFirst = 1'])->buildSql();
        $sub6 = M('bk_dailichargeliushui')->field('SUM(bk_ChangeGold)')->where($where + $subWhere + ['bk_DailyTime = a.bk_DailyTime'])->buildSql();
        $field = "bk_DailyTime, $sub1 AS sub1, $sub2 AS sub2, $sub3 AS sub3, $sub4 AS sub4, $sub5 AS sub5, $sub6 AS sub6";
        $Query = M('bk_dailichargeliushui')->alias('a')->field($field)->where($where)->group('bk_DailyTime')->order('bk_DailyTime desc');
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();
        $data['sql'] = M('bk_dailichargeliushui')->getLastSql();
        $data['count'] = M('bk_dailichargeliushui')->where($where)->group('bk_DailyTime')->count();

        foreach ($rows as $key => $row) {
            $row_data['ChargeTime'] = date('Y-m-d', $row['bk_dailytime']);  // 日期
            $row_data['ZongCiShu'] = $row['sub1'];  // 总次数
            $row_data['ZongRenShu'] = $row['sub2'];  // 发送人数
            $row_data['JieShouZongRenShu'] = $row['sub3'];  // 接收人数
            $row_data['NewJieShouZongRenShu'] = $row['sub4'];  // 接收新增人数
            $row_data['NewJieShouZongTotal'] = $row['sub5'] / 10000;  // 新增接收数量
            $row_data['SendGoldTotal'] = $row['sub6'] / 10000;  // 发送数量
            $row_data['ReceiveGoldTotal'] = $row_data['SendGoldTotal'];  // 接收数量

            $data['data'][] = $row_data;
        }

        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        if (1 == I('get.isExecl/d')) ($this->doExcelData(C('cellName.gameOverview_emailSendCount'), $data['data'], '发送量统计'));
        $this->ajaxReturn($data);
    }

    // 余额宝统计
    // 余额宝配置
    public function yuebaoConfig() {
        $up_date = array();  // 数据库更新
        $flag = '';  // 配置标签
        $data = '';  // 配置值

        // 当前配置
        $data_list = M('bk_yuebaoconfig')->where(array('bk_ID' => 1))->find();
        $default_data['bk_rate'] = $data_list['bk_rate'] / 10000;
        $default_data['bk_rate1'] = $data_list['bk_rate1'] / 10000;
        $default_data['bk_rate2'] = $data_list['bk_rate2'] / 10000;
        $default_data['bk_rate3'] = $data_list['bk_rate3'] / 10000;
        $default_data['bk_yuebaorate'] = $data_list['bk_yuebaorate'] / 10000;
        $default_data['bk_amountrate'] = $data_list['bk_amountrate'] / 10000;
        $default_data['bk_amountrate1'] = $data_list['bk_amountrate1'] / 10000;
        $default_data['bk_amountrate2'] = $data_list['bk_amountrate2'] / 10000;
        $default_data['bk_amountrate3'] = $data_list['bk_amountrate3'] / 10000;
        $default_data['bk_price1'] = $data_list['bk_price1'] / 10000;
        $default_data['bk_price2'] = $data_list['bk_price2'] / 10000;
        $default_data['bk_price3'] = $data_list['bk_price3'] / 10000;
        $default_data['bk_periodhour'] = $data_list['bk_periodhour'] / 10000;
        $default_data['bk_period1'] = $data_list['bk_period1'] / 10000;
        $default_data['bk_period2'] = $data_list['bk_period2'] / 10000;
        $default_data['bk_period3'] = $data_list['bk_period3'] / 10000;
        $default_data['bk_attenuation'] = $data_list['bk_attenuation'] / 10000;
        if (!IS_AJAX) {
            $this->assign(data_list, $default_data);
            $this->show();
            return;
        }

        $up_date['bk_Record'] = $data_list['bk_record'];   // 操作记录
        if (I('post.rate') == '' && I('post.rate1') == '' && I('post.rate2') == '' && I('post.rate3') == ''
            && I('post.yuebaoRate') == '' && I('post.amountrate') == '' && I('post.amountrate1') == ''
            && I('post.amountrate2') == '' && I('post.amountrate3') == '' && I('post.bk_Price1') == ''
            && I('post.bk_Price2') == '' && I('post.bk_Price3') == '' && I('post.periodHour') == ''
            && I('post.period1') == '' && I('post.period2') == '' && I('post.period3') == ''
            && I('post.attenuation') == '') {
            $this->ajaxReturn(['code' => 1]);
        }
        if (I('post.rate') != '') {
            $up_date['bk_Rate'] = I('post.rate') * 10000;   // 日化利率万分比
            $flag .= '1,';
            $data .= I('post.rate') * 10000 . ',';
            $up_date['bk_Record'] .= '日化利率万分比:' . $default_data['bk_rate'] . '-->' . I('post.rate') . ',';
        }
        if (I('post.rate1') != '') {
            $up_date['bk_Rate1'] = I('post.rate1') * 10000; // 产品1利率占比
            $flag .= '2,';
            $data .= I('post.rate1') * 10000 . ',';
            $up_date['bk_Record'] .= '产品1利率占比:' . $default_data['bk_rate1'] . '-->' . I('post.rate1') . ',';
        }
        if (I('post.rate2') != '') {
            $up_date['bk_Rate2'] = I('post.rate2') * 10000; // 产品2利率占比
            $flag .= '3,';
            $data .= I('post.rate2') * 10000 . ',';
            $up_date['bk_Record'] .= '产品2利率占比:' . $default_data['bk_rate2'] . '-->' . I('post.rate2') . ',';
        }
        if (I('post.rate3') != '') {
            $up_date['bk_Rate3'] = I('post.rate3') * 10000; // 产品3利率占比
            $flag .= '4,';
            $data .= I('post.rate3') * 10000 . ',';
            $up_date['bk_Record'] .= '产品3利率占比:' . $default_data['bk_rate3'] . '-->' . I('post.rate3') . ',';
        }
        if (I('post.yuebaoRate') != '') {
            $up_date['bk_YuebaoRate'] = I('post.yuebaoRate') * 10000;   // 余额宝(百分比)
            $flag .= '5,';
            $data .= I('post.yuebaoRate') * 10000 . ',';
            $up_date['bk_Record'] .= '余额宝(百分比):' . $default_data['bk_yuebaorate'] . '-->' . I('post.yuebaoRate') . ',';
        }
        if (I('post.amountrate') != '') {
            $up_date['bk_AmountRate'] = I('post.amountrate') * 10000;   // 日化(百分比)
            $flag .= '6,';
            $data .= I('post.amountrate') * 10000 . ',';
            $up_date['bk_Record'] .= '日化(百分比):' . $default_data['bk_amountrate'] . '-->' . I('post.amountrate') . ',';
        }
        if (I('post.amountrate1') != '') {
            $up_date['bk_AmountRate1'] = I('post.amountrate1') * 10000; // 产品1(百分比)
            $flag .= '7,';
            $data .= I('post.amountrate1') * 10000 . ',';
            $up_date['bk_Record'] .= '产品1(百分比):' . $default_data['bk_amountrate1'] . '-->' . I('post.amountrate1') . ',';
        }
        if (I('post.amountrate2') != '') {
            $up_date['bk_AmountRate2'] = I('post.amountrate2') * 10000; // 产品2(百分比)
            $flag .= '8,';
            $data .= I('post.amountrate2') * 10000 . ',';
            $up_date['bk_Record'] .= '产品2(百分比):' . $default_data['bk_amountrate2'] . '-->' . I('post.amountrate2') . ',';
        }
        if (I('post.amountrate3') != '') {
            $up_date['bk_AmountRate3'] = I('post.amountrate3') * 10000; // 产品3(百分比)
            $flag .= '9,';
            $data .= I('post.amountrate3') * 10000 . ',';
            $up_date['bk_Record'] .= '产品3(百分比):' . $default_data['bk_amountrate3'] . '-->' . I('post.amountrate3') . ',';
        }
        if (I('post.price1') != '') {
            $up_date['bk_Price1'] = I('post.price1') * 10000;   // 产品1单价调整
            $flag .= '10,';
            $data .= I('post.price1') * 10000 . ',';
            $up_date['bk_Record'] .= '产品1单价调整:' . $default_data['bk_price1'] . '-->' . I('post.price1') . ',';
        }
        if (I('post.price2') != '') {
            $up_date['bk_Price2'] = I('post.price2') * 10000;   // 产品2单价调整
            $flag .= '11,';
            $data .= I('post.price2') * 10000 . ',';
            $up_date['bk_Record'] .= '产品2单价调整:' . $default_data['bk_price2'] . '-->' . I('post.price2') . ',';
        }
        if (I('post.price3') != '') {
            $up_date['bk_Price3'] = I('post.price3') * 10000;   // 产品3单价调整
            $flag .= '12,';
            $data .= I('post.price3') * 10000 . ',';
            $up_date['bk_Record'] .= '产品3单价调整:' . $default_data['bk_price3'] . '-->' . I('post.price3') . ',';
        }
        if (I('post.period1') != '') {
            $up_date['bk_Period1'] = I('post.period1') * 10000;    // 产品1周期
            $flag .= '13,';
            $data .= I('post.period1') * 10000 . ',';
            $up_date['bk_Record'] .= '产品1周期:' . $default_data['bk_period1'] . '-->' . I('post.period1') . ',';
        }
        if (I('post.period2') != '') {
            $up_date['bk_Period2'] = I('post.period2') * 10000;    // 产品2周期
            $flag .= '14,';
            $data .= I('post.period2') * 10000 . ',';
            $up_date['bk_Record'] .= '产品2周期:' . $default_data['bk_period2'] . '-->' . I('post.period2') . ',';
        }
        if (I('post.period3') != '') {
            $up_date['bk_Period3'] = I('post.period3') * 10000;    // 产品3周期
            $flag .= '15,';
            $data .= I('post.period3') * 10000 . ',';
            $up_date['bk_Record'] .= '产品3周期:' . $default_data['bk_period3'] . '-->' . I('post.period3') . ',';
        }
        if (I('post.attenuation') != '') {
            $up_date['bk_Attenuation'] = I('post.attenuation') * 10000; // 日化利率衰减百分比
            $flag .= '16,';
            $data .= I('post.attenuation') * 10000 . ',';
            $up_date['bk_Record'] .= '日化利率衰减百分比:' . $default_data['bk_attenuation'] . '-->' . I('post.attenuation') . ',';
        }
        if (I('post.periodHour') != '') {
            $up_date['bk_PeriodHour'] = I('post.periodHour') * 10000;    // 日化周期(小时) 排在最后
            $flag .= '17,';
            $data .= I('post.periodHour') * 10000 . ',';
            $up_date['bk_Record'] .= '日化周期(小时):' . $default_data['bk_periodhour'] . '-->' . I('post.periodHour') . ',';
        }
        $up_date['bk_Record'] .= $this->login_admin_info['bk_name'] . '在' . date('Y-m-d H:i:s', time()) . '更改,';    // 操作记录
        $flag = substr($flag, 0, strlen($flag) - 1);   // 配置标签
        $data = substr($data, 0, strlen($data) - 1);   // 配置值
        $result = M('bk_yuebaoconfig')->where(['bk_ID' => 1])->save($up_date); // 数据库更新

        if (intval($result) <= 0) {
            $this->ajaxReturn(['code' => 1]);
        }
        // 服务器通信
        $str = pack("S", strlen($flag)) . $flag . pack("S", strlen($data)) . $data;
        sendToGame(C('socket_ip'), 30000, 1650, $str);

        $this->ajaxReturn(['code' => 0, 'flag' => $flag, 'data' => $data]);
    }

    // 余额宝明细
    public function yuebaoDetail() {
        $platform = C('PLATFORM');  // 平台
        $type = C('YUEBAO_TYPE');   // 余额宝类型
        $vary = C('YUEBAO_VARY');   // 余额宝变化类型
        $apk = $channel = $where_data = array();

        $apk_list = M('bk_apk')->select(); // apk
        foreach ($apk_list as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }
        $channel_list = M('bk_channel')->select(); // 渠道
        foreach ($channel_list as $key => $val) {
            $channel[$val['bk_channelid']] = $val['bk_channel'];
        }
        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->assign('platform', $platform);
            $this->assign('apk', $apk);
            $this->assign('channel', $channel);
            $this->assign('type', $type);
            $this->assign('varyType', $vary);
            $this->show();
            return;
        }

        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');   // 玩家ID
        }
        if (I('get.nickname') != '') {
            $where_data['bk_Name'] = I('get.nickname'); // 玩家昵称
        }
        if (I('get.platform/d') > 0) {
            $where_data['bk_PlatformID'] = I('get.platform/d'); // 平台
        }
        if (I('get.apk/d') > 0) {
            $where_data['bk_ApkID'] = I('get.apk/d');   // apk
        }
        if (I('get.channel/d') > 0) {
            $where_data['bk_ChannelID'] = I('get.channel/d');   // 渠道
        }
        if (I('get.type/d') > 0) {
            $where_data['bk_Type'] = I('get.type/d');   // 余额宝类型
        }
        if (I('get.varyType/d') > 0) {
            $where_data['bk_VaryType'] = I('get.varyType/d');   // 余额宝变化类型
        }
        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['bk_Time'] = array('between', array($s_time, $e_time)); // 起始时间
        }

        $layui_data['page'] = I('get.page/d');
        $layui_data['count'] = M('bk_yuebaodetail')->where($where_data)->count();
        $order = 'bk_Time desc';
        $Query = M('bk_yuebaodetail')->where($where_data)->order($order);
        if (I('get.isExecl/d') == 0) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        foreach ($data_list as $key => $val) {
            $data['platform'] = $platform[$val['bk_platformid']];   // 平台
            $data['apk'] = $apk[$val['bk_apkid']];  // apk
            $data['channel'] = $channel[$val['bk_channelid']];  // 渠道
            $data['account'] = $val['bk_accountid'];    // 玩家ID
            $data['nickname'] = $val['bk_name'];    // 玩家昵称
            $data['gold'] = $val['bk_gold'] / 10000;    // 金币
            $data['interest'] = $val['bk_interest'] / 10000;    // 利息
            $data['time'] = $val['bk_time'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_time']);   // 时间(指该笔余额宝发生变化的时间)
            $data['interestTime'] = $val['bk_interesttime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_interesttime']);   // 利息产生时间(利息产生的第一个收益日)
            $data['buyTime'] = $val['bk_buytime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_buytime']);  // 购买时间
            $data['sellTime'] = $val['bk_selltime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_selltime']);   // 卖出时间
            $data['rate'] = $val['bk_interestrate'] / 10000 / 100 . '%';    // 利率
            $data['copies'] = $val['bk_copies'];    // 份数
            $data['stock'] = $val['bk_stock'];  // 库存
            $data['type'] = $type[$val['bk_type']]; // 余额宝类型
            $data['varyType'] = $vary[$val['bk_varytype']]; // 余额宝变化类型
            $layui_data['data'][] = $data;
        }

        if (I('get.isExecl/d') == 1) {
            $this->doExeclData(C('cellName.yuebao_detail'), $layui_data['data'], '余额宝明细');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 余额宝统计
    public function yuebaoStatistics() {
        $where_data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }
        
        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data['bk_Time'] = array('between', array($s_time, $e_time)); // 起始时间
        }

        $layui_data['page'] = I('get.page/d');
        $layui_data['count'] = M('bk_yuebaostatistics')->where($where_data)->count();
        $order = 'bk_Time desc';
        $Query = M('bk_yuebaostatistics')->where($where_data)->order($order);
        if (I('get.isExecl/d') == 0) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        foreach ($data_list as $key => $val) {
            $data['date'] = date('Y-m-d', $val['bk_time']); // 日期
            $data['yuebao'] = $val['bk_yuebaototall'] / 10000;  // 余额宝总金额
            $data['yuebao_'] = $val['bk_regularyuebao'] / 10000; // 定期总额
            $data['vary'] = $val['bk_yuebaovary'] / 10000;    // 余额宝变化
            $data['interest'] = ($val['bk_currentinterest'] + $val['bk_seveninterest'] + $val['bk_fifteeninterest'] + $val['bk_thirtyinterest']) / 10000;    // 总利息
            $data['interest_'] = $val['bk_currentinterest'] / 10000;   // 活期利息
            $data['interest7'] = $val['bk_seveninterest'] / 10000;   // 7日利息
            $data['interest15'] = $val['bk_fifteeninterest'] / 10000;  // 15日利息
            $data['interest30'] = $val['bk_thirtyinterest'] / 10000;  // 30日利息
            $data['copies7'] = $val['bk_sevencopies'];  // 7日定存份数
            $data['total7'] = $val['bk_seventotall'] / 10000;   // 7日定存总额
            $data['copies15'] = $val['bk_fifteencopies'];   // 15日定存份数
            $data['total15'] = $val['bk_fifteentotall'] / 10000;    // 15日定存总额
            $data['copies30'] = $val['bk_thirtycopies'];    // 30日定存份数
            $data['total30'] = $val['bk_thirtytotall'] / 10000; // 30日定存总额
            $data['ios'] = $val['bk_ios'];  // IOS人数
            $data['android'] = $val['bk_android'];  // 安卓人数
            $data['newStock'] = $val['bk_newyuebaototall'] / 10000; // 新增余额宝库存
            $data['newTotal'] = $val['bk_newregularyuebao'] / 10000;    // 新增定期总额
            $data['newVary'] = $val['bk_newyuebaovary'] / 10000;    // 新增余额宝变化
            $data['newIOS'] = $val['bk_newios'];    // 新增IOS人数
            $data['newAndroid'] = $val['bk_newandroid'];    // 新增安卓人数
            $layui_data['data'][] = $data;
        }

        if (I('get.isExecl/d') == 1) {
            $this->doExeclData(C('cellName.yuebao_statistics'), $layui_data['data'], '余额宝统计');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 余额宝排行榜
    public function yuebaoLeaderboard() {
        $where_data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');
        }

        $order = 'bk_YuebaoTotall desc';
        $Query = M('bk_yuebaoleaderboard')->where($where_data)->order($order);
        if (I('get.isExecl/d') == 0) {
            $Query->limit(100);
        }
        $data_list = $Query->select();
        $number = 1;
        foreach ($data_list as $key => $val) {
            $data['rank'] = $number;    // 名次
            $data['account'] = $val['bk_accountid'];    // 玩家ID
            $data['nickname'] = $val['bk_name'];    // 玩家昵称
            $data['yuebao'] = $val['bk_yuebaototall'] / 10000;  // 余额宝总金币
            $data['yuebao_'] = $val['bk_yuebao'] / 10000;   // 余额宝金币
            $data['seven'] = $val['bk_seven'] / 10000;  // 7日定存金币
            $data['seven_'] = $val['bk_sevencopies'];   // 7日定存份数
            $data['fifteen'] = $val['bk_fifteen'] / 10000;  // 15日定存金币
            $data['fifteen_'] = $val['bk_fifteencopies'];   // 15日定存份数
            $data['thirty'] = $val['bk_thirty'] / 10000;    // 30日定存金币
            $data['thirty_'] = $val['bk_thirtycopies']; // 30日定存份数
            $data['interest'] = $val['bk_interest'] / 10000;    // 总利息
            $layui_data['data'][] = $data;
            $number++;
        }

        if (I('get.isExecl/d') == 1) {
            $this->doExeclData(C('cellName.yuebao_leaderboard'), $layui_data['data'], '余额宝排行榜');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 金币流水
    // 金币流水
    public function goldLS() {
        $where = array();
        $operate = C('OPERATE');
        $operate_type = C('OPERATE_TYPE');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->assign('type', $operate_type);
            $this->show();
            return;
        }

        if (I('get.account') == '') {
            $this->ajaxReturn(['code' => 0]);
            $this->show();
            return;
        } else {
            $where['log_AccountID'] = I('get.account/d');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where['log_Time'] = array('between', array($s_time, $e_time)); // 起始时间
        }

        if (I('get.type') != '') {
            $where['log_Type'] = I('get.type/d');
        }

        if (I('get.change') != '') {
            $change = explode(',', I('get.change'));
            $where['log_ChangeValue'] = array('between', [intval($change[0]) * 10000, intval($change[1]) * 10000]);
        }

        $layui_data['page'] = I('get.page/d');
        $layui_data['count'] = M('log_gold_gaikuang')->where($where)->count();
        $order = 'log_ID desc';
        $Query = M('log_gold_gaikuang')->where($where)->order($order);
        if (I('get.isExecl/d') == 0) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        foreach ($data_list as $key => $val) {
            $data['Date'] = date('Y-m-d H:i:s', $val['log_time']);   // 时间
            $data['ID'] = $val['log_accountid'];   // 玩家ID
            $data['ChangeGold'] = $val['log_changevalue'] / 10000;  // 变更数量
            $data['Operate'] = $operate[$val['log_operate']];   // 类型
            $data['Name'] = $val['log_name'];  // 玩家昵称
            $data['BeginGold'] = ($val['log_value'] - $val['log_changevalue']) / 10000;   // 变更前金币
            $data['EndGold'] = $val['log_value'] / 10000;  // 变更后金币
            $layui_data['data'][] = $data;
            $number++;
        }

        if (I('get.isExecl/d') == 1) {
            $this->doExeclData(C('cellName.gold_liushui'), $layui_data['data'], '金币流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }
}