<?php

namespace Home\Controller;
class TurnoverController extends BaseController
{
    public function index()
    {
        $this->show();
    }

    //游戏流水-牛牛
    public function niuNiu()
    {
        $where_data = array();
        $data = array();
        $layui_data = array();
        $room = C('room');
        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $layui_data['page'] = I('get.page/d');
        $order = "log_ID desc";
        $layui_data['count'] = M('log_niuniuliushui')->where($where_data)->count() / 1;
        $Query = M('log_niuniuliushui')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_niuniuliushui')->where($where_data)->sum("log_varygold") / 10000;
        $layui_data['yazhu_total'] = abs(M('log_niuniuliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum("log_varygold") / 10000);
        $layui_data['fajiang_total'] = M('log_niuniuliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum("log_varygold") / 10000;

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
            $this->setExeclData(C('cellName.niuniu_turnover'), $layui_data['data'], '牛牛流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏流水-炸金花
    public function yingSanZhang()
    {

        $where_data = array();
        $data = array();
        $layui_data = array();
        $room = C('room');
        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');
        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }
        if (I('get.nickname') != "") {
            $where_data['log_Name'] = I('get.nickname');
        }
        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = "log_ID desc";
        $layui_data['count'] = M('log_yingsanzhangliushui')->where($where_data)->count();
        $Query = M('log_yingsanzhangliushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_yingsanzhangliushui')->where($where_data)->sum("log_varygold") / 10000;
        $layui_data['yazhu_total'] = abs(M('log_yingsanzhangliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum("log_varygold") / 10000);
        $layui_data['fajiang_total'] = M('log_yingsanzhangliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum("log_varygold") / 10000;

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
            $this->setExeclData(C('cellName.yingsanzhang_turnover'), $layui_data['data'], '炸金花流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏流水-推筒子
    public function tuiTongZi()
    {

        $where_data = array();
        $data = array();
        $layui_data = array();

        $room = C('room');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = "log_ID desc";
        $layui_data['count'] = M('log_tuitongziliushui')->where($where_data)->count();
        $Query = M('log_tuitongziliushui')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_tuitongziliushui')->where($where_data)->sum("log_varygold") / 10000;
        $layui_data['yazhu_total'] = abs(M('log_tuitongziliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum("log_varygold") / 10000);
        $layui_data['fajiang_total'] = M('log_tuitongziliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum("log_varygold") / 10000;

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
            $this->setExeclData(C('cellName.tuitongzi_turnover'), $layui_data['data'], '推筒子流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏流水-红包接龙
    public function hongBaoJieLong()
    {

        $where_data = array();
        $data = array();
        $layui_data = array();

        $room = C('room');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = "log_ID desc";
        $layui_data['count'] = M('log_hongbaojielongliushui')->where($where_data)->count();
        $Query = M('log_hongbaojielongliushui')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_hongbaojielongliushui')->where($where_data)->sum("log_varygold") / 10000;
        $layui_data['yazhu_total'] = abs(M('log_hongbaojielongliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum("log_varygold") / 10000);
        $layui_data['fajiang_total'] = M('log_hongbaojielongliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum("log_varygold") / 10000;

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
            $this->setExeclData(C('cellName.hongbaojielong_turnover'), $layui_data['data'], '红包接龙流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏流水-百人金花
    public function baiRenJinHua()
    {
        $where_data = array();
        $data = array();
        $layui_data = array();

        $room = C('room_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');
        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = "log_ID desc";
        $layui_data['count'] = M('log_bairenjinhualiushui')->where($where_data)->count();
        $Query = M('log_bairenjinhualiushui')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        $layui_data['vary_gold_total'] = M('log_bairenjinhualiushui')->where($where_data)->sum("log_varygold") / 10000;
        $layui_data['yazhu_total'] = abs(M('log_bairenjinhualiushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum("log_varygold") / 10000);
        $layui_data['fajiang_total'] = M('log_bairenjinhualiushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum("log_varygold") / 10000;

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
            $this->setExeclData(C('cellName.bairenjinhua_turnover'), $layui_data['data'], '百人金花流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏流水-龙虎斗
    public function longHuDou()
    {

        $where_data = array();
        $data = array();
        $layui_data = array();

        $room = C('room_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = "log_ID desc";
        $layui_data['count'] = M('log_longhudouliushui')->where($where_data)->count();
        $Query = M('log_longhudouliushui')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_longhudouliushui')->where($where_data)->sum("log_varygold") / 10000;
        $layui_data['yazhu_total'] = abs(M('log_longhudouliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum("log_varygold") / 10000);
        $layui_data['fajiang_total'] = M('log_longhudouliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum("log_varygold") / 10000;

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
            $this->setExeclData(C('cellName.longhudou_turnover'), $layui_data['data'], '龙虎斗流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏流水-百家乐
    public function baiJiaLe()
    {

        $where_data = array();
        $data = array();
        $layui_data = array();

        $room = C('room_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = "log_ID desc";
        $layui_data['count'] = M('log_baijialeliushui')->where($where_data)->count();
        $Query = M('log_baijialeliushui')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_baijialeliushui')->where($where_data)->sum("log_varygold") / 10000;
        $layui_data['yazhu_total'] = abs(M('log_baijialeliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum("log_varygold") / 10000);
        $layui_data['fajiang_total'] = M('log_baijialeliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum("log_varygold") / 10000;

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
            $this->setExeclData(C('cellName.baijiale_turnover'), $layui_data['data'], '百家乐流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏流水-跑得快
    public function paoDeKuai()
    {

        $where_data = array();
        $data = array();
        $layui_data = array();

        $room = C('room');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = "log_ID desc";
        $layui_data['count'] = M('log_paodekuailiushui')->where($where_data)->count();
        $Query = M('log_paodekuailiushui')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_paodekuailiushui')->where($where_data)->sum("log_varygold") / 10000;
        $layui_data['yazhu_total'] = abs(M('log_paodekuailiushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum("log_varygold") / 10000);
        $layui_data['fajiang_total'] = M('log_paodekuailiushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum("log_varygold") / 10000;

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
            $this->setExeclData(C('cellName.paodekuai_turnover'), $layui_data['data'], '跑得快流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏流水-时时彩
    public function shiShiCai()
    {

        $where_data = array();
        $data = array();
        $layui_data = array();

        $ssc = C('ssc');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = "log_ID desc";
        $layui_data['count'] = M('log_shishicailiushui')->where($where_data)->count();
        $Query = M('log_shishicailiushui')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_shishicailiushui')->where($where_data)->sum("log_VaryGold") / 10000;
        $layui_data['yazhu_total'] = abs(M('log_shishicailiushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum("log_VaryGold") / 10000);
        $layui_data['fajiang_total'] = M('log_shishicailiushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum("log_VaryGold") / 10000;

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
            $this->setExeclData(C('cellName.shishicai_turnover'), $layui_data['data'], '时时彩流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏流水-幸运转盘
    public function xingYunZhuanPan()
    {

        $where_data = array();
        $data = array();
        $layui_data = array();

        $room = C('room_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = "log_ID desc";
        $layui_data['count'] = M('log_xingyunzhuanpanliushui')->where($where_data)->count();
        $Query = M('log_xingyunzhuanpanliushui')->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_xingyunzhuanpanliushui')->where($where_data)->sum("log_varygold") / 10000;
        $layui_data['yazhu_total'] = abs(M('log_xingyunzhuanpanliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum("log_varygold") / 10000);
        $layui_data['fajiang_total'] = M('log_xingyunzhuanpanliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum("log_varygold") / 10000;

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
            $this->setExeclData(C('cellName.xingyunzhuanpan_turnover'), $layui_data['data'], '幸运转盘流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏流水-奔驰宝马
    public function benChiBaoMa()
    {

        $where_data = array();
        $data = array();
        $layui_data = array();

        $room = C('room_');
        $bcbm_result = C('bcbm_result');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['log_Name'] = I('get.nickname');
        }

        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
        }
        $where_data['log_Time'] = array('between', array($s_time, $e_time));

        $order = "log_ID desc";
        $layui_data['count'] = M('log_benchibaomaliushui')->where($where_data)->count();
        $Query = M('log_benchibaomaliushui')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $layui_data['sql'] = M('log_benchibaomaliushui')->getLastSql();

        $data_list = $Query->select();

        $layui_data['vary_gold_total'] = M('log_benchibaomaliushui')->where($where_data)->sum("log_varygold") / 10000;
        $layui_data['yazhu_total'] = abs(M('log_benchibaomaliushui')->where($where_data + ['log_VaryGold' => ['lt', 0]])->sum("log_varygold") / 10000);
        $layui_data['fajiang_total'] = M('log_benchibaomaliushui')->where($where_data + ['log_VaryGold' => ['gt', 0]])->sum("log_varygold") / 10000;

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
            $this->setExeclData(C('cellName.benchibaoma_turnover'), $layui_data['data'], '奔驰宝马流水');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏流水汇总
    public function allGames()
    {

        $where_data = array();
        $data = array();
        $layui_data = array();

        $reason = C('operate');
        $game = C('games');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        if (I('get.account/d') == "" && I('get.start_time') == "" && I('get.end_time') == "" && I('get.game/d') <= 0 && I('get.minAmount') <= 0 && I('get.maxAmount') <= 0) {
            if (1 == I('get.isExecl/d')) $this->setExeclData(C('cellName.all_turnover'), $layui_data['data'], '游戏流水汇总');
            $this->ajaxReturn(array('code' => 0));
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['log_AccountID'] = I('get.account/d');
        }

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

        $gameTurnover = I('get.game/d');

        switch ($gameTurnover) {
            case 2:
                $where_data['_string'] = 'log_Operate=2 OR log_Operate=3 OR log_Operate=4 OR log_Operate=5 OR log_Operate=6';   //百人金花
                break;
            case 3:
                $where_data['_string'] = 'log_Operate=19 OR log_Operate=20 OR log_Operate=21';   //龙虎斗
                break;
            case 4:
                $where_data['_string'] = 'log_Operate=23 OR log_Operate=24';   //百家乐
                break;
            case 5:
                $where_data['_string'] = 'log_Operate=31 OR log_Operate=32';   //时时彩
                break;
            case 6:
                $where_data['_string'] = 'log_Operate=33 OR log_Operate=34 OR log_Operate=35 OR log_Operate=36';   //奔驰宝马
                break;
            case 7:
                $where_data['_string'] = 'log_Operate=37 OR log_Operate=38';   //幸运转盘
                break;
            case 8:
                $where_data['_string'] = 'log_Operate=7 OR log_Operate=8';   //炸金花
                break;
            case 9:
                $where_data['log_Operate'] = $gameTurnover;   //抢庄牛牛
                break;
            case 10:
                $where_data['_string'] = 'log_Operate=11 OR log_Operate=12';   //红包接龙
                break;
            case 11:
                $where_data['log_Operate'] = $gameTurnover;   //推筒子
                break;
            case 13:
                $where_data['_string'] = 'log_Operate=26 OR log_Operate=27';   //跑得快
                break;
            default:
                $where_data['log_IsGameChange'] = 1;
        }

        if (I('get.minAmount') != '' && I('get.maxAmount') != '') {
            $where_data['log_ChangeValue'] = array(array('between', array(I('get.minAmount') * 10000, I('get.maxAmount') * 10000)), array('between', array(-I('get.maxAmount') * 10000, -I('get.minAmount') * 10000)), 'or');
        }

        if (I('get.minAmount') > 0 && I('get.maxAmount') <= 0) {
            $where_data['log_ChangeValue'] = array(array('gt', I('get.minAmount') * 10000), array('lt', -I('get.minAmount') * 10000), 'or');
        }

        if (I('get.maxAmount') > 0 && I('get.minAmount') <= 0) {
            $where_data['log_ChangeValue'] = array('between', array(-I('get.maxAmount') * 10000, I('get.maxAmount') * 10000));
        }

        $order = "log_ID desc";
        $layui_data['count'] = M('bk_games_gold')->where($where_data)->count();
        $Query = M('bk_games_gold')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();
        $layui_data['sql'] = $Query->getLastSql();

        foreach ($data_list as $key => $val) {
            $data['account'] = $val['log_accountid'];
            $data['nickname'] = $val['gd_name'];
            $data['game'] = $game[$val['log_scenetype']];
            $data['vary'] = $val['log_changevalue'] / 10000;
            $data['reason'] = $reason[$val['log_operate']];
            $data['balance'] = $val['log_value'] / 10000;
            $data['time'] = date('Y-m-d H:i:s', $val['log_time']);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.all_turnover'), $layui_data['data'], '游戏流水汇总');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }
}