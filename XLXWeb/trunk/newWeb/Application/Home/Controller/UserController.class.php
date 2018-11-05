<?php

namespace Home\Controller;
class UserController extends BaseController
{
    //注册明细
    public function userList()
    {
        $where_data = array();
        $data = array();
        $channel_list = array();

        G('begin');

        $platform = C('platform');
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }

        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }

        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->assign('channel_list', $channel_list);
            $this->assign('platform', $platform);
            $this->assign('apk', $apk);
            $this->show();
            return;
        }

        if (I('get.platform/d') > 0) {
            $where_data['gd_PlatformID'] = I('get.platform/d');
        }

        if (I('get.channe/d') > 0) {
            $where_data['gd_ChannelID'] = I('get.channe/d');
        }

        if (I('get.apkid/d') > 0) {
            $where_data['gd_ApkID'] = I('get.apkid/d');
        }

        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $start_time = I('get.start_time');
            $end_time = I('get.end_time');
            if (I('get.start_time') == '') {
                $start_time = '2015-01-01';
            }
            if (I('get.end_time') == '') {
                $end_time = '2215-01-01';;
            }
        }
        if (I('get.start_time') == '' && I('get.end_time') == '') {
            $start_time = date('Y-m-d', time());
            $end_time = date('Y-m-d', time() + 24 * 60 * 60);
        }

        $where_data['gd_RegisterTime'] = array('between', array($start_time, $end_time));
        $layui_data['count'] = M('gd_register')->where($where_data)->count();
        $Query = M('gd_register')->where($where_data)->order("gd_RegisterTime desc");
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $data_list = $Query->select();
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['gd_accountid'];
            $data['name'] = $val['gd_name'];
            $data['platform'] = $platform[$val['gd_platformid']];
            $data['apk'] = $apk[$val['gd_apkid']];
            $data['channel'] = $channel_list[$val['gd_channelid']];
            $data['ip'] = $val['gd_registerip'];
            $data['devicecode'] = $val['gd_devicecode'];
            $data['addtime'] = $val['gd_registertime'];
            $data['gold'] = $val['gd_gold'] / 10000;
            $data['todaybindflag'] = $val['gd_todaybindflag'] == 0 ? '否 ' : '是';
            $data['todaygameflag'] = $val['gd_todaygameflag'] == 0 ? '否' : '是';
            $data['todayischarge'] = $val['gd_todayischarge'] == 0 ? '否 ' : '是';
            $data['todaychargermb'] = $val['gd_todaychargermb'];
            $layui_data['data'][] = $data;
        }
        G('end');
        $layui_data['time'] = G('begin', 'end') . 's';
        $layui_data['page'] = I('get.page/d');
        $layui_data['code'] = 0;
        if (1 == I('get.isExecl/d')) ($this->setExeclData(C('cellName.user_userList'), $layui_data['data'], '注册明细'));

        $this->ajaxReturn($layui_data);
    }

    //LTV值
    public function ltvList()
    {
        $where_data = array();
        $data = array();

        $platform = C('platform');
        $apk = array();
        $channel = array();

        $channel_list = M('bk_apk')->select();
        foreach ($channel_list as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }

        $channel_list = M('bk_channel')->select();
        foreach ($channel_list as $key => $val) {
            $this->assign('platform', $platform);
            $this->assign('apk', $apk);
            $this->assign('channel', $channel);
        }

        if (!IS_AJAX) {
            $this->assign('channel', $channel);
            $this->assign('platform', $platform);
            $this->show();
            return;
        }

        if (I('get.platform/d') > 0) {
            $where_data['log_PlatformID'] = I('get.platform/d');
        }

        if (I('get.apk/d') > 0) {
            $where_data['log_APKID'] = I('get.apk/d');
        }

        if (I('get.channel/d') > 0) {
            $where_data['log_ChannelID'] = I('get.channel/d');
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

        $fields = array('log_Time', 'log_PlatformID', 'log_APKID', 'log_ChannelID', 'sum(log_TodayRegister) as count', 'sum(log_ltv1) as sum1', 'sum(log_ltv2) as sum2',
            'sum(log_ltv3) as sum3', 'sum(log_ltv4) as sum4', 'sum(log_ltv5) as sum5', 'sum(log_ltv6) as sum6',
            'sum(log_ltv7) as sum7', 'sum(log_ltv8) as sum8', 'sum(log_ltv9) as sum9', 'sum(log_ltv10) as sum10',
            'sum(log_ltv11) as sum11', 'sum(log_ltv12) as sum12', 'sum(log_ltv13) as sum13', 'sum(log_ltv14) as sum14',
            'sum(log_ltv15) as sum15', 'sum(log_ltv16) as sum16', 'sum(log_ltv17) as sum17', 'sum(log_ltv18) as sum18',
            'sum(log_ltv19) as sum19', 'sum(log_ltv20) as sum20', 'sum(log_ltv21) as sum21', 'sum(log_ltv22) as sum22',
            'sum(log_ltv23) as sum23', 'sum(log_ltv24) as sum24', 'sum(log_ltv25) as sum25', 'sum(log_ltv26) as sum27',
            'sum(log_ltv28) as sum28', 'sum(log_ltv29) as sum29', 'sum(log_ltv30) as sum30', 'sum(log_ltv35) as sum35',
            'sum(log_ltv40) as sum40', 'sum(log_ltv50) as sum50');

        $subQuery = M('bk_ltv')->field("log_Time")->where($where_data)->group("log_Time")->buildSql();
        $layui_data['count'] = M('bk_ltv')->table($subQuery . ' a')->count();
        $order = "log_Time desc";
        $data_list = M('bk_ltv')->field($fields)->where($where_data)->group('log_Time')->order($order)
            ->page(I('page/d'))->limit(I('limit/d'))->select();

        foreach ($data_list as $key => $val) {
            $data['date'] = date('Y-m-d', $val['log_time']);
            $data['platform'] = I('get.platform/d') == 0 ? '全平台' : $platform[$val['log_platformid']];
            $data['apk'] = I('get.apk/d') == 0 ? '全apk包' : $apk[$val['log_apkid']];
            $data['channel'] = I('get.channel/d') == 0 ? '全渠道' : $channel[$val['log_channelid']];
            $data['count'] = $val['count'];
            $data['ltv1'] = $val['count'] == 0 || $val['sum1'] == 0 ? '0' : sprintf("%.2f", $val['sum1'] / $val['count']);
            $data['ltv2'] = $val['count'] == 0 || $val['sum2'] == 0 ? '0' : sprintf("%.2f", $val['sum2'] / $val['count']);
            $data['ltv3'] = $val['count'] == 0 || $val['sum3'] == 0 ? '0' : sprintf("%.2f", $val['sum3'] / $val['count']);
            $data['ltv4'] = $val['count'] == 0 || $val['sum4'] == 0 ? '0' : sprintf("%.2f", $val['sum4'] / $val['count']);
            $data['ltv5'] = $val['count'] == 0 || $val['sum5'] == 0 ? '0' : sprintf("%.2f", $val['sum5'] / $val['count']);
            $data['ltv6'] = $val['count'] == 0 || $val['sum6'] == 0 ? '0' : sprintf("%.2f", $val['sum6'] / $val['count']);
            $data['ltv7'] = $val['count'] == 0 || $val['sum7'] == 0 ? '0' : sprintf("%.2f", $val['sum7'] / $val['count']);
            $data['ltv8'] = $val['count'] == 0 || $val['sum8'] == 0 ? '0' : sprintf("%.2f", $val['sum8'] / $val['count']);
            $data['ltv9'] = $val['count'] == 0 || $val['sum9'] == 0 ? '0' : sprintf("%.2f", $val['sum9'] / $val['count']);
            $data['ltv10'] = $val['count'] == 0 || $val['sum10'] == 0 ? '0' : sprintf("%.2f", $val['sum10'] / $val['count']);
            $data['ltv11'] = $val['count'] == 0 || $val['sum11'] == 0 ? '0' : sprintf("%.2f", $val['sum11'] / $val['count']);
            $data['ltv12'] = $val['count'] == 0 || $val['sum12'] == 0 ? '0' : sprintf("%.2f", $val['sum12'] / $val['count']);
            $data['ltv13'] = $val['count'] == 0 || $val['sum13'] == 0 ? '0' : sprintf("%.2f", $val['sum13'] / $val['count']);
            $data['ltv14'] = $val['count'] == 0 || $val['sum14'] == 0 ? '0' : sprintf("%.2f", $val['sum14'] / $val['count']);
            $data['ltv15'] = $val['count'] == 0 || $val['sum15'] == 0 ? '0' : sprintf("%.2f", $val['sum15'] / $val['count']);
            $data['ltv16'] = $val['count'] == 0 || $val['sum16'] == 0 ? '0' : sprintf("%.2f", $val['sum16'] / $val['count']);
            $data['ltv17'] = $val['count'] == 0 || $val['sum17'] == 0 ? '0' : sprintf("%.2f", $val['sum17'] / $val['count']);
            $data['ltv18'] = $val['count'] == 0 || $val['sum18'] == 0 ? '0' : sprintf("%.2f", $val['sum18'] / $val['count']);
            $data['ltv19'] = $val['count'] == 0 || $val['sum19'] == 0 ? '0' : sprintf("%.2f", $val['sum19'] / $val['count']);
            $data['ltv20'] = $val['count'] == 0 || $val['sum20'] == 0 ? '0' : sprintf("%.2f", $val['sum20'] / $val['count']);
            $data['ltv21'] = $val['count'] == 0 || $val['sum21'] == 0 ? '0' : sprintf("%.2f", $val['sum21'] / $val['count']);
            $data['ltv22'] = $val['count'] == 0 || $val['sum22'] == 0 ? '0' : sprintf("%.2f", $val['sum22'] / $val['count']);
            $data['ltv23'] = $val['count'] == 0 || $val['sum23'] == 0 ? '0' : sprintf("%.2f", $val['sum23'] / $val['count']);
            $data['ltv24'] = $val['count'] == 0 || $val['sum24'] == 0 ? '0' : sprintf("%.2f", $val['sum24'] / $val['count']);
            $data['ltv25'] = $val['count'] == 0 || $val['sum25'] == 0 ? '0' : sprintf("%.2f", $val['sum25'] / $val['count']);
            $data['ltv26'] = $val['count'] == 0 || $val['sum26'] == 0 ? '0' : sprintf("%.2f", $val['sum26'] / $val['count']);
            $data['ltv27'] = $val['count'] == 0 || $val['sum27'] == 0 ? '0' : sprintf("%.2f", $val['sum27'] / $val['count']);
            $data['ltv28'] = $val['count'] == 0 || $val['sum28'] == 0 ? '0' : sprintf("%.2f", $val['sum28'] / $val['count']);
            $data['ltv29'] = $val['count'] == 0 || $val['sum29'] == 0 ? '0' : sprintf("%.2f", $val['sum29'] / $val['count']);
            $data['ltv30'] = $val['count'] == 0 || $val['sum30'] == 0 ? '0' : sprintf("%.2f", $val['sum30'] / $val['count']);
            $data['ltv35'] = $val['count'] == 0 || $val['sum35'] == 0 ? '0' : sprintf("%.2f", $val['sum35'] / $val['count']);
            $data['ltv40'] = $val['count'] == 0 || $val['sum40'] == 0 ? '0' : sprintf("%.2f", $val['sum40'] / $val['count']);
            $data['ltv50'] = $val['count'] == 0 || $val['sum50'] == 0 ? '0' : sprintf("%.2f", $val['sum50'] / $val['count']);
            $layui_data['data'][] = $data;
        }
        $layui_data['page'] = I('get.page/d');
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);

    }
}

