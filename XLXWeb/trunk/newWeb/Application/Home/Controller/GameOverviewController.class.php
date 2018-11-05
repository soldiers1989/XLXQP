<?php

namespace Home\Controller;
class GameOverviewController extends BaseController
{
    public function index()
    {
        $this->show();
    }

    //牛牛概况
    public function niuNiu()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allniuniugaikuang')->where($where_data)->count();
        $order = "log_Time desc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = $val['log_totaltouzhu'];
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.overview1'), $layui_data['data'], '牛牛概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //牛牛房间数据
    public function niuNiuRoom()
    {

        $where_data = array();
        $data = array();

        $room = C('room');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = (I('get.start_time') == "" ? "2018-08-16" : I('get.start_time'));
            $e_time = (I('get.end_time') == "" ? date('Y-m-d', time()) : I('get.end_time'));
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
        $order = "log_Time desc, log_Level asc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['amount_yz'] = ($val['log_totalyazhu'] / 10000);
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $data['amount_fl'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.room1'), $layui_data['data'], '牛牛房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //炸金花概况
    public function yingSanZhang()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allyingsanzhanggaikuang')->where($where_data)->count();
        $order = "log_Time desc";

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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
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
            $this->setExeclData(C('cellName.yingsanzhang_overview'), $layui_data['data'], '炸金花概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //炸金花房间数据
    public function yingSanZhangRoom()
    {

        $where_data = array();
        $data = array();

        $room = C('room');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = (I('get.start_time') == "" ? "2018-08-16" : I('get.start_time'));
            $e_time = (I('get.end_time') == "" ? date('Y-m-d', time()) : I('get.end_time'));
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
        $order = "log_Time desc, log_Level asc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['amount_yz'] = ($val['log_totalyazhu'] / 10000);
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $data['amount_fl'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.yingsanzhang_room'), $layui_data['data'], '炸金房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //推筒子概况
    public function tuiTongZi()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_alltuitongzigaikuang')->where($where_data)->count();
        $order = "log_Time desc";

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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.overview1'), $layui_data['data'], '推筒子概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //推筒子房间数据
    public function tuiTongZiRoom()
    {

        $where_data = array();
        $data = array();

        $room = C('room');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = (I('get.start_time') == "" ? "2018-08-16" : I('get.start_time'));
            $e_time = (I('get.end_time') == "" ? date('Y-m-d', time()) : I('get.end_time'));
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
        $order = "log_Time desc, log_Level asc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['amount_yz'] = ($val['log_totalyazhu'] / 10000);
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $data['amount_fl'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.room1'), $layui_data['data'], '推筒子房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //红包接龙概况
    public function hongBaoJieLong()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allhongbaojielonggaikuang')->where($where_data)->count();
        $order = "log_Time desc";

        $Query = M('log_allhongbaojielonggaikuang')->where($where_data)->group("log_Time")->order($order);

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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.overview1'), $layui_data['data'], '红包接龙概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //红包接龙房间数据
    public function hongBaoJieLongRoom()
    {

        $where_data = array();
        $data = array();

        $room = C('room');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = (I('get.start_time') == "" ? "2018-08-16" : I('get.start_time'));
            $e_time = (I('get.end_time') == "" ? date('Y-m-d', time()) : I('get.end_time'));
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
        $order = "log_Time desc, log_Level asc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['amount_yz'] = $val['log_totalyazhu'] / 10000;
            $data['amount_cs'] = $val['log_choushui'] / 10000;
            $data['amount_hs'] = $val['log_systemhuishou'] / 10000;
            $data['amount_fl'] = $val['log_proxyfanli'] / 10000;
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.room1'), $layui_data['data'], '红包接龙房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //百人金花概况
    public function baiRenJinHua()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allbairenjinhuagaikuang')->where($where_data)->count();
        $order = "log_Time desc";

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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.overview1'), $layui_data['data'], '百人金花概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //百人金花房间数据
    public function baiRenJinHuaRoom()
    {

        $where_data = array();
        $data = array();

        $room = C('room_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = (I('get.start_time') == "" ? "2018-08-16" : I('get.start_time'));
            $e_time = (I('get.end_time') == "" ? date('Y-m-d', time()) : I('get.end_time'));
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
        $order = "log_Time desc, log_Level asc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
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
            $this->setExeclData(C('cellName.room1'), $layui_data['data'], '百人金花房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //龙虎斗概况
    public function longHuDou()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_alllonghudougaikuang')->where($where_data)->count();
        $order = "log_Time desc";

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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.overview1'), $layui_data['data'], '龙虎斗概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //龙虎斗房间数据
    public function longHuDouRoom()
    {

        $where_data = array();
        $data = array();

        $room = C('room_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = (I('get.start_time') == "" ? "2018-08-16" : I('get.start_time'));
            $e_time = (I('get.end_time') == "" ? date('Y-m-d', time()) : I('get.end_time'));
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
        $order = "log_Time desc, log_Level asc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
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
            $this->setExeclData(C('cellName.longhudou_room'), $layui_data['data'], '龙虎斗房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //百家乐概况
    public function baiJiaLe()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allbaijialegaikuang')->where($where_data)->count();
        $order = "log_Time desc";

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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.overview1'), $layui_data['data'], '百家乐概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //百家乐房间数据
    public function baiJiaLeRoom()
    {

        $where_data = array();
        $data = array();

        $room = C('room_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = (I('get.start_time') == "" ? "2018-08-16" : I('get.start_time'));
            $e_time = (I('get.end_time') == "" ? date('Y-m-d', time()) : I('get.end_time'));
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
        $order = "log_Time desc, log_Level asc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
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
            $this->setExeclData(C('cellName.baijiale_room'), $layui_data['data'], '百家乐房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //跑得快概况
    public function paoDeKuai()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allpaodekuaigaikuang')->where($where_data)->count();

        $order = "log_Time desc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['proxy_rebate'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.overview1'), $layui_data['data'], '跑得快概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //跑得快房间数据
    public function paoDeKuaiRoom()
    {

        $where_data = array();
        $data = array();

        $room = C('room');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = (I('get.start_time') == "" ? "2018-08-16" : I('get.start_time'));
            $e_time = (I('get.end_time') == "" ? date('Y-m-d', time()) : I('get.end_time'));
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
        $order = "log_Time desc, log_Level asc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['amount_yz'] = ($val['log_totalyazhu'] / 10000);
            $data['amount_cs'] = ($val['log_choushui'] / 10000);
            $data['amount_hs'] = ($val['log_systemhuishou'] / 10000);
            $data['amount_fl'] = ($val['log_proxyfanli'] / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.room1'), $layui_data['data'], '跑得快房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //时时彩概况
    public function shiShiCai()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allshishicaigaikuang')->where($where_data)->count();
        $order = "log_Time desc";

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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
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
            $this->setExeclData(C('cellName.shishicai_overview'), $layui_data['data'], '时时彩概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //时时彩房间数据
    public function shiShiCaiRoom()
    {

        $where_data = array();
        $data = array();

        $room = C('room_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = (I('get.start_time') == "" ? "2018-08-16" : I('get.start_time'));
            $e_time = (I('get.end_time') == "" ? date('Y-m-d', time()) : I('get.end_time'));
            $where_data['log_time'] = array('between', array($s_time, $e_time));
        }

        if (I('get.room/d') > 0) {
            $where_data['log_Level'] = 1;
        }

        $layui_data['count'] = M('log_shishicaigaikuang')->where($where_data)->count();
        $order = "log_Time desc, log_Level asc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
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
            $this->setExeclData(C('cellName.shishicai_room'), $layui_data['data'], '时时彩房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //幸运转盘概况
    public function xingYunZhuanPan()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allxingyunzhuanpangaikuang')->where($where_data)->count();
        $order = "log_Time desc";

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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
            $data['choushui'] = ($val['log_choushui'] / 10000);
            $data['recover'] = ($val['log_systemhuishou'] / 10000);
            $data['sum_yazhu'] = ($val['log_totaltouzhu']);
            $data['sum_amount'] = ($val['log_totalyazhu'] / 10000);
            $data['sum_award'] = ($val['log_totalfajiang'] / 10000);
            $data['result'] = (($val['log_totalfajiang'] - $val['log_totalyazhu']) / 10000);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.xingyunzhuanpan_overview'), $layui_data['data'], '幸运转盘概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //幸运转盘房间数据
    public function xingYunZhuanPanRoom()
    {

        $where_data = array();
        $data = array();

        $room = C('room_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = (I('get.start_time') == "" ? "2018-08-16" : I('get.start_time'));
            $e_time = (I('get.end_time') == "" ? date('Y-m-d', time()) : I('get.end_time'));
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
        $order = "log_Time desc, log_Level asc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
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
            $this->setExeclData(C('cellName.xingyunzhuanpan_room'), $layui_data['data'], '幸运转盘房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //奔驰宝马概况
    public function benChiBaoMa()
    {
        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('log_allbenchibaomagaikuang')->where($where_data)->count();

        $order = "log_Time desc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
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
            $this->setExeclData(C('cellName.benchibaoma_overview'), $layui_data['data'], '奔驰宝马概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //奔驰宝马房间数据
    public function benChiBaoMaRoom()
    {

        $where_data = array();
        $data = array();

        $room = C('room_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = (I('get.start_time') == "" ? "2018-08-16" : I('get.start_time'));
            $e_time = (I('get.end_time') == "" ? date('Y-m-d', time()) : I('get.end_time'));
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
        $order = "log_Time desc, log_Level asc";
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
            $data['count_win_'] = ($val['log_winplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_winplayer'] / $val['log_player']) * 100 . '%');
            $data['count_lose'] = $val['log_loseplayer'];
            $data['count_lose_'] = ($val['log_loseplayer'] == 0 || $val['log_player'] == 0 ? '0%' : sprintf("%.4f", $val['log_loseplayer'] / $val['log_player']) * 100 . '%');
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
            $this->setExeclData(C('cellName.benchibaoma_room'), $layui_data['data'], '奔驰宝马房间数据');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //实时输赢
    public function realTimeWinLose()
    {
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
            $order = "desc";
        } else {
            $order = "asc";
        }

        $rows = M("log_shishishuying")->field($filed)->where($where_data)->group("log_AccountID")->order("win {$order}")->limit(50)->select();
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
        $data['sql'] = M("log_shishishuying")->getLastSql();
        $data['time'] = G('begin', 'end') . 's';
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //推广员概况
    public function promotersStatistics()
    {
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

        $Query = M('log_proxygaikuang')->where($where)->order("log_ID desc");
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
        if (1 == I('get.isExecl/d')) ($this->setExeclData(C('cellName.gameOverview_promotersStatistics'), $data['data'], '推广员概况'));
        $this->ajaxReturn($data);
    }

    // 佣金变化明细
    public function yongJinDetail()
    {
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
        G('begin');
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

        G('end');
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $data['time'] = G('begin', 'end') . 's';
        if (1 == I('get.isExecl/d')) ($this->setExeclData(C('cellName.gameOverview_yongJinDetail'), $data['data'], '佣金明细'));
        $this->ajaxReturn($data);
    }

    //推广员明细
    public function proxyList()
    {
        $where_data = array();
        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->show();
            return;
        }

        G('begin');

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

        $Query = M('log_proxymingxi')->field($field)->where($where_data)->order("log_Time desc");
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
        G('end');

        $data['code'] = 0;
        $data['time'] = G('begin', 'end') . 's';
        if (1 == I('get.isExecl/d')) ($this->setExeclData(C('cellName.gameOverview_proxyList'), $data['data'], '推广员明细'));
        $this->ajaxReturn($data);
    }

    //推广员榜
    function proxyTop()
    {
        $where_data = array();
        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->show();
            return;
        }
        if (I('get.proxyid/d') > 0) {
            $where_data['gd_AccountID'] = I('get.proxyid/d');
        }

        $day_zero_time = strtotime(date('Y-m-d', time()));

        $field = "gd_AccountID, gd_Name, gd_AllCommission, gd_CanTakeCommission, gd_JsonOneDayBetCommission, gd_JsonBetCommission,
        gd_DirectMember, gd_OtherMember";

        $Query = M('gd_proxy')->field($field)->where($where_data)->order("gd_AllCommission desc");
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

            if (0 == I('get.isExecl/d')) $row_data['url'] = U('GameOverview/proxyUserDate', array("accountid" => $row_data['proxyId']));
            $data['data'][] = $row_data;
            $num++;
        }

        $data['code'] = 0;
        if (1 == I('get.isExecl/d')) ($this->setExeclData(C('cellName.gameOverview_proxyTop'), $data['data'], '推广员榜'));
        $this->ajaxReturn($data);
    }

    //推广员个人按日期统计
    public function proxyUserDate()
    {
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

        G('begin');

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

        G('end');
        $data['data'] = array_reverse($data['data']);
        $data['code'] = 0;
        $data['time'] = G('begin', 'end') . 's';
        if (1 == I('get.isExecl/d')) ($this->setExeclData(C('cellName.gameOverview_proxyUserDate'), $data['data'], '推广员查询'));
        $this->ajaxReturn($data);
    }

    //银商发钱明细
    public function emailDetail()
    {
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
            $where['bk_DailiID'] = array("in", $sendid);
        }

        $receiverid = I('get.receiverid');
        if (!empty($receiverid)) {
            $receiverid = explode(',', $receiverid);
            $where['bk_PlayerID'] = array("in", $receiverid);
        }

        $Query = M("bk_dailichargeliushui")->where($where)->order("bk_ID desc");
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();
        $data['count'] = M("bk_dailichargeliushui")->where($where)->count();

        $data['TotalMoney'] = M("bk_dailichargeliushui")->where($where)->sum('bk_ChangeGold') / 10000;

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
        if (1 == I('get.isExecl/d')) ($this->setExeclData(C('cellName.gameOverview_emailDetail'), $data['data'], '代理充值明细'));
        $this->ajaxReturn($data);
    }

    //银商发送量统计
    public function emailSendCount()
    {
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

        G('begin');

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
        $Query = M('bk_dailichargeliushui')->alias('a')->field($field)->where($where)->group("bk_DailyTime")->order("bk_DailyTime desc");
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();
        $data['sql'] = M('bk_dailichargeliushui')->getLastSql();
        $data['count'] = M('bk_dailichargeliushui')->where($where)->group("bk_DailyTime")->count();

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

        G('end');
        $data['code'] = 0;
        $data['time'] = G('begin', 'end') . 's';
        $data['page'] = I('get.page/d');
        if (1 == I('get.isExecl/d')) ($this->setExeclData(C('cellName.gameOverview_emailSendCount'), $data['data'], '发送量统计'));
        $this->ajaxReturn($data);
    }

    //分组清单
    public function groupDetail()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $date_send = I('get.start_time');
        if (trim($date_send) != "") {
            $where['log_SendTime_day'] = $date_send;
        } else {
            $where['log_SendTime_day'] = date('Y-m-d', time());
        }
        $where['bk_Number'] = array('gt', 0);
        $rows = M('bk_dailichargeliushui')->where($where)->group('bk_Number')->page(I('get.page/d'))->limit(I('get.limit/d'))->select();

        $data['count'] = M('bk_ddaili_group')->where($where)->count();

        foreach ($rows as $key => $row) {

            //  $data['data'][] = $row_data;

        }
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //

    //邮件聊天
    public function emailChat()
    {
        $where = array();
        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->show();
            return;
        }

        $where['log_SendGold'] = 0;
        $where['log_Type'] = 2;

        $Query = M('bk_allemail')->where($where)->order("log_ID desc");
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();
        $data['count'] = M('bk_allemail')->where($where)->count();

        foreach ($rows as $val => $row) {
            $row_data['id'] = $row['log_id'];
            $row_data['senderid'] = $row['log_senderid']; //发送人ID
            $row_data['senderName'] = M('bk_accountv')->where(array('gd_AccountID' => $row['log_senderid']))->getField('gd_Name'); //发送人昵称
            $row_data['SendTime'] = date('Y-m-d', $row['log_sendtime']); //发送时间
            $row_data['content'] = $row['log_content'];//内容
            $row_data['receiverid'] = $row['log_receiverid'];//接收人ID
            $row_data['receivername'] = M('bk_accountv')->where(array('gd_AccountID' => $row['log_receiverid']))->getField('gd_Name');//接收人昵称
            $row_data['receiveTime'] = date('Y-m-d', $row['log_receivetime']); //阅读时间
            $data['data'][] = $row_data;
        }
        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        if (1 == I('get.isExecl/d')) ($this->setExeclData(C('cellName.gameOverview_emailDetail'), $data['data'], '邮件聊天'));
        $this->ajaxReturn($data);
    }

    //删除邮件
    public function delEmail()
    {
        $id = I('post.id/d');
        $this->ajaxReturn(array('code' => 0));
    }

    //每日输赢
    public function everydayLoseOrWin()
    {
        if (!IS_AJAX) {
            $games = C('games');
            $this->assign('games', $games);
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

    //金额变化
    public function goldDedtail()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $where = [];
        $rows = M('bk_games_gold')->where($where)->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        foreach ($rows as $row) {
            // $row_data[''] = $row['']
        }
    }

    //取各游戏金币变化ID
    public function getGameGoldId($gid)
    {
        switch ($gid) {
            case 0: //全部
                return array(2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 19, 20, 21, 23, 24, 26, 27, 31, 32, 33, 34, 35, 36, 37, 38);
                break;
            case 9; //牛牛
                return array(9);
                break;
            case 8; //炸金花
                return array(7, 8);
                break;
            case 11; //推筒子
                return array(10);
                break;
            case 10; //红包接龙
                return array(11, 12);
                break;
            case 2; //百人金花
                return array(2, 3, 4, 5, 6);
                break;
            case 3; //龙虎斗
                return array(19, 20, 21);
                break;
            case 4; //百家乐
                return array(23, 24);
                break;
            case 13; //跑的快
                return array(36, 37);
                break;
            case 5; //时时彩
                return array(31, 32);
                break;
            case 7; //幸运转盘
                return array(37, 38);
                break;
            case 6; //奔驰宝马
                return array(33, 34, 35, 36);
                break;
        }
    }

}