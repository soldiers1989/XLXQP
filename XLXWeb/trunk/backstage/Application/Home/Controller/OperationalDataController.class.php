<?php

namespace Home\Controller;
class OperationalDataController extends BaseController
{
    public function index() {
        $this->show();
    }

    // 收入数据
    // 充值明细
    public function rechargeList() {
        $where_data = array();
        $where_data_total = array();
        $data = array();

        $platform = C('PLATFORM');
        $payorder_state = C('PAYORDER_STATE');
        $apk = array();
        $channel = array();
        $pay = C('PAYMENT_TYPE');
        $appid = array();

        $apk_list = M('bk_apk')->select();
        foreach ($apk_list as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }

        $channel_list = M('bk_channel')->select();
        foreach ($channel_list as $key => $val) {
            $channel[$val['bk_channelid']] = $val['bk_channel'];
        }

        $appid_list = M('bk_chargepassconf')->select();
        foreach ($appid_list as $key => $val) {
            $appid[$val['bk_passid']] = $val['bk_passname'];
        }

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->assign('state', $payorder_state);
            $this->assign('platform', $platform);
            $this->assign('apk', $apk);
            $this->assign('channel', $channel);
            $this->assign('pay', $pay);
            $this->show();
            return;
        }

        // 超过30分钟的未处理的新订单刷新为失败订单
        $row = M('bk_createorder')->where(array('bk_IsSuccess' => 3))->select();
        foreach ($row as $key => $val) {
            if (($val['bk_createtime'] + 30 * 60) < time()) {
                $up_date['bk_IsSuccess'] = 0;
                $up_date['bk_ResultTime'] = time();
                M('bk_createorder')->where(array('bk_MerchantOrder' => $val['bk_merchantorder']))->save($up_date);
            }
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.order') != '') {
            $where_data['bk_MerchantOrder'] = I('get.order');
            $where_data_total['bk_MerchantOrder'] = I('get.order');
        }

        if (I('get.state') != '') {
            $where_data['bk_IsSuccess'] = I('get.state');
        }

        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');
            $where_data_total['bk_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != '') {
            $where_data['gd_Name'] = I('get.nickname');
            $where_data_total['bk_Name'] = I('get.nickname');
        }

        if (I('get.platform/d') > 0) {
            $where_data['bk_PlatformID'] = I('get.platform/d');
        }

        if (I('get.pay/d') > 0) {
            $where_data['bk_PayType'] = I('get.pay/d');
            $where_data_total['bk_PayType'] = I('get.pay/d');
        }

        if (I('get.channel/d') > 0) {
            $where_data['bk_ChannelID'] = I('get.channel/d');
            $where_data_total['bk_ChannelID'] = I('get.channel/d');
        }

        if (I('get.apk/d') > 0) {
            $where_data['bk_ApkID'] = I('get.apk/d');
            $where_data_total['bk_ApkID'] = I('get.apk/d');
        }

        $selectTime = 'bk_ResultTime';
        if (I('get.selectTime') == 'CreateTime') {
            $selectTime = 'bk_CreateTime';
        }

        if (I('get.start_time') == '' && I('get.end_time') == '') {
            $s_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
            $where_data[$selectTime] = array('between', array($s_time, $e_time));
            if ($selectTime == 'bk_PayTime') {
                $where_data[$selectTime] = array('between', array(date('Y-m-d H:i:s', $s_time), date('Y-m-d H:i:s', $e_time)));
            }

            $where_data_total['bk_ResultTime'] = array('between', array($s_time, $e_time));
        } else {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $s_time = 1;
            }
            if (I('get.end_time') == '') {
                $e_time = time();
            }
            $where_data[$selectTime] = array('between', array($s_time, $e_time));
            if ($selectTime == 'bk_PayTime') {
                $where_data[$selectTime] = array('between', array(date('Y-m-d H:i:s', $s_time), date('Y-m-d H:i:s', $e_time)));
            }
            $where_data_total['bk_ResultTime'] = array('between', array($s_time, $e_time));
        }

        // 总充值金额  ios充值人数  安卓充值人数
        $where_data_total['bk_IsSuccess'] = 2;
        $layui_data['total']['amount'] = M('bk_createorder')->where($where_data_total)->sum('bk_RealAmount') / 1;
        $layui_data['total']['ios'] = I('get.platform') == '' || I('get.platform/d') == 3 ? M('bk_createorder')->where($where_data_total + ['bk_PlatformID' => 3])->count('distinct bk_AccountID') : 0;
        $layui_data['total']['android'] = I('get.platform') == '' || I('get.platform/d') == 2 ? M('bk_createorder')->where($where_data_total + ['bk_PlatformID' => 2])->count('distinct bk_AccountID') : 0;

        // 新增充值总金额  新增ios充值人数  新增android充值人数
        $layui_data['total']['new_amount'] = M('bk_createorder')->where($where_data_total + ['bk_RegTime' => array('between', array($s_time, $e_time))])->sum("bk_RealAmount") / 1;
        $layui_data['total']['new_ios'] = I('get.platform') == '' || I('get.platform/d') == 3 ? M('bk_createorder')->where($where_data_total + ['bk_PlatformID' => 3] + ['bk_RegTime' => array('between', array($s_time, $e_time))])->count('distinct bk_AccountID') : 0;
        $layui_data['total']['new_android'] = I('get.platform') == '' || I('get.platform/d') == 2 ? M('bk_createorder')->where($where_data_total + ['bk_PlatformID' => 2] + ['bk_RegTime' => array('between', array($s_time, $e_time))])->count('distinct bk_AccountID') : 0;

        // 表格数据
        $layui_data['count'] = M('bk_createorder')->where($where_data)->count();
        $fileds = array('bk_MerchantOrder', 'bk_PlatformID', 'bk_ChannelID', 'bk_PayType', 'bk_AccountID', 'bk_Name',
            'bk_PayAmount', 'bk_IsSuccess', 'bk_CreateTime', 'bk_ResultTime', 'bk_Reissue', 'bk_PassID', 'bk_BeginGold',
            'bk_GetGold', 'bk_EndGold');
        $order = 'bk_CreateTime desc';
        $Query = M('bk_createorder')->field($fileds)->where($where_data)->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        foreach ($data_list as $key => $val) {
            $data['order'] = $val['bk_merchantorder'];  // 订单号
            $data['platform'] = $platform[$val['bk_platformid']];   // 平台
            $data['channel'] = $channel[$val['bk_channelid']];  // 注册渠道
            $data['pay'] = $pay[$val['bk_paytype']];   // 支付方式
            $data['appid'] = $appid[$val['bk_passid']]; // 用支付通道id去找
            $data['account'] = $val['bk_accountid'];    // 玩家ID
            $data['nickname'] = $val['bk_name'];    // 玩家昵称
            $data['amount'] = $val['bk_payamount'];     // 充值金额
            $data['begin'] = $val['bk_begingold'] / 10000;    // 充值前金币
            $data['get'] = $val['bk_getgold'] / 10000;    // 充值金币
            $data['end'] = $val['bk_endgold'] / 10000;    // 充值后金币
            $data['updateTime'] = ($val['bk_resulttime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_resulttime']));    // 更新时间
            $data['state'] = $payorder_state[$val['bk_issuccess']];  //状态
            $data['createTime'] = date('Y-m-d H:i:s', $val['bk_createtime']); //创建时间
            $data['remark'] = ($val['bk_reissue'] == '0' ? '' : $val['bk_reissue']);//备注

            if (1 != I('get.isExecl/d')) $data['flag'] = $val['bk_issuccess'];
            if (1 != I('get.isExecl/d')) $data['reissueURL'] = U("recharge/orderReissue", array('order' => $val['bk_merchantorder']));
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.recharge_rechargeList'), $layui_data['data'], '充值明细');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 对失败/支付成功的订单进行补发(玩家未收到金币)
    public function orderReissue() {
        $row = M('bk_createorder')->where(array('bk_MerchantOrder' => I('get.order')))->find();
        $this->assign('order', $row);
        $this->show();
    }

    // 订单补发
    public function doOrderReissue() {
        if (I('post.order') == '' || I('post.amount/d') <= 0 || I('post.desc') == '' || I('post.id/d') <= 0 || I('post.ip') == '' || I('post.pass_id/d') <= 0 || I('post.reason') == '') {
            $this->ajaxReturn(array('code' => 1));
        }

        $order = I('post.order');
        $str = explode(',', I('post.desc'));
        $pay = $str[0];
        $id = I('post.id/d');
        $amount = I('post.amount/d');
        $ip = I('post.ip');
        $pass_id = I('post.pass_id/d');

        $up_data['bk_IsSuccess'] = 2;
        $up_data['bk_ResultTime'] = time();
        $up_data['bk_Reissue'] = $this->login_admin_info['bk_name'] . '在' . date('Y-m-d H:i:s', $up_data['bk_ResultTime']) . '时进行了补发操作,补发原因:' . I('post.reason');
        $result = M('bk_createorder')->where(array('bk_MerchantOrder' => I('post.order')))->save($up_data);

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        // 与服务器通信
        $str = pack('S', strlen($order)) . $order . pack('C', $pay) . pack('L', $id) . pack('L', $amount) . pack('S', strlen($ip)) . $ip . pack('L', $pass_id);
        SendToGame(C('socket_ip'), 30000, 1007, $str);

        $this->ajaxReturn(array('code' => 0));
    }

    // 收入概况
    public function incomeOverview() {
        $where_data = $data = $apk = $channel = array();
        $platform = C('PLATFORM');

        $channel_list = M('bk_apk')->select();
        foreach ($channel_list as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }

        $channel_list = M('bk_channel')->select();
        foreach ($channel_list as $key => $val) {
            $channel[$val['bk_channelid']] = $val['bk_channel'];
        }

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->assign('platform', $platform);
            $this->assign('apk', $apk);
            $this->assign('channel', $channel);
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.platform/d') > 0) {
            $where_data['bk_PlatformID'] = I('get.platform/d');
        }

        if (I('get.apk/d') > 0) {
            $where_data['bk_ApkID'] = I('get.apk/d');
        }

        if (I('get.channel/d') > 0) {
            $where_data['bk_ChannelID'] = I('get.channel/d');
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
            $where_data['bk_Time'] = array('between', array($s_time, $e_time));
        }

        $fields = array('bk_Time', 'bk_PlatformID', 'bk_ApkID', 'bk_ChannelID', 'sum(bk_Active) as sum1', 'sum(bk_Amount) as sum2',
            'sum(bk_Count) as sum3', 'sum(bk_Sum) as sum4', 'sum(bk_CountFirst) as sum5', 'sum(bk_AmountFirst) as sum6', 'sum(bk_CountNew) as sum7',
            'sum(bk_AmountNew) as sum8', 'sum(bk_CountWechat) as sum9', 'sum(bk_AmountWechat) as sum10', 'sum(bk_CountAlipay) as sum11',
            'sum(bk_AmountAlipay) as sum12', 'sum(bk_CountQQ) as sum13', 'sum(bk_AmountQQ) as sum14', 'sum(bk_CountBank) as sum15', 'sum(bk_AmountBank) as sum16');

        $subQuery = M('bk_incomeoverview')->field('bk_Time')->where($where_data)->group('bk_Time')->buildSql();
        $layui_data['count'] = M('bk_incomeoverview')->table($subQuery . ' a')->count();

        $order = 'bk_Time desc';
        $Query = M('bk_incomeoverview')->field($fields)->where($where_data)->group('bk_Time')->order($order);
        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['date'] = date('Y-m-d', $val['bk_time']);
            $data['platform'] = (I('get.platform/d') == 0 ? '全平台' : $platform[$val['bk_platformid']]);
            $data['apk'] = (I('get.apk/d') == 0 ? '全apk包' : $apk[$val['bk_apkid']]);
            $data['channel'] = (I('get.channel/d') == 0 ? '全渠道' : $channel[$val['bk_channelid']]);
            $data['active'] = $val['sum1'];
            $data['amount'] = $val['sum2'];
            $data['count'] = $val['sum3'];
            $data['sum'] = $val['sum4'];
            $data['rate'] = ($val['sum1'] == 0 || $val['sum3'] == 0 ? '0%' : sprintf("%.4f", $val['sum3'] / $val['sum1']) * 100 . '%');
            $data['arppu'] = ($val['sum2'] == 0 || $val['sum3'] == 0 ? '0' : sprintf("%.2f", $val['sum2'] / $val['sum3']));
            $data['arpu'] = ($val['sum1'] == 0 || $val['sum2'] == 0 ? '0' : sprintf("%.2f", $val['sum2'] / $val['sum1']));
            $data['count_first'] = $val['sum5'];
            $data['amount_first'] = $val['sum6'];
            $data['count_new'] = $val['sum7'];
            $data['amount_new'] = $val['sum8'];
            $data['count_wechat'] = $val['sum9'];
            $data['amount_wechat'] = $val['sum10'];
            $data['count_alipay'] = $val['sum11'];
            $data['amount_alipay'] = $val['sum12'];
            $data['count_qq'] = $val['sum13'];
            $data['amount_qq'] = $val['sum14'];
            $data['count_bank'] = $val['sum15'];
            $data['amount_bank'] = $val['sum16'];
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.income_overview'), $layui_data['data'], '收入概况');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 时段收入
    public function timeSlotIncome() {
        $data = array();

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        if (I('get.start_time') != '' && I('get.end_time') != '') {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
        } else {
            $s_time = mktime(0, 0, 0, date('m'), date('d') - 1, date('Y'));
            $e_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
        }

        $timeSlot = array('0-1点', '1-2点', '2-3点', '3-4点', '4-5点', '5-6点', '6-7点', '7-8点', '8-9点', '9-10点',
            '10-11点', '11-12点', '12-13点', '13-14点', '14-15点', '15-16点', '16-17点', '17-18点', '18-19点',
            '19-20点', '20-21点', '21-22点', '22-23点', '23-24点');
        for ($i = 0; $i < 24; $i++) {
            // 对比时间段1
            $end_time1 = $s_time + 3600 * ($i + 1);
            $where_data1['bk_DailyTime'] = $s_time;
            $where_data1['bk_ResultTime'] = array('between', array($s_time + 3600 * $i, $s_time + 3600 * ($i + 1)));
            $where_data1['bk_IsSuccess'] = 2;

            $field = array('SUM(bk_RealAmount) AS amount1', 'COUNT(bk_AccountID) AS count1', 'COUNT(DISTINCT bk_AccountID) AS count2',
                "(SELECT COUNT(DISTINCT bk_AccountID) FROM bk_createorder WHERE bk_DailyTime=$s_time AND bk_IsSuccess BETWEEN 1 AND 2 AND bk_ResultTime BETWEEN $s_time AND $end_time1) AS count5");
            $data_list = M('bk_createorder')->field($field)->where($where_data1)->select();
            foreach ($data_list as $key => $val) {
                $data['order'] = $i + 1;
                $data['timeSlot'] = $timeSlot[$i];
                $data['amount1'] = ($val['amount1'] == '' ? 0 : $val['amount1']);
                $data['count1'] = $val['count1'];
                $data['count2'] = $val['count2'];
                $data['sum1'] = $val['count5'];
            }

            // 对比时间段2
            $end_time2 = $e_time + 3600 * ($i + 1);
            $where_data2['bk_DailyTime'] = $e_time;
            $where_data2['bk_ResultTime'] = array('between', array($e_time + 3600 * $i, $e_time + 3600 * ($i + 1)));
            $where_data2['bk_IsSuccess'] = 2;

            $field = array('SUM(bk_RealAmount) AS amount2', 'COUNT(bk_AccountID) AS count3', 'COUNT(DISTINCT bk_AccountID) AS count4',
                "(SELECT COUNT(DISTINCT bk_AccountID) FROM bk_createorder WHERE bk_DailyTime=$e_time AND bk_IsSuccess BETWEEN 1 AND 2 AND bk_ResultTime BETWEEN $e_time AND $end_time2) AS count6");
            $data_list = M('bk_createorder')->field($field)->where($where_data2)->select();
            foreach ($data_list as $key => $val) {
                if (($s_time + 3600 * $i) <= time()) {
                    $data['amount2'] = ($val['amount2'] == '' ? 0 : $val['amount2']);
                    $data['count3'] = $val['count3'];
                    $data['count4'] = $val['count4'];
                    $data['sum2'] = $val['count6'];
                } else {
                    $data['amount2'] = '';
                    $data['count3'] = '';
                    $data['count4'] = '';
                    $data['sum2'] = '';
                }
            }
            $layui_data['data'][] = $data;
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 充值排行榜
    public function leaderBoard() {
        $where_data = $where_data_daili = $where_data_tixian = array();
        $data = array();

        $channel_list = M('bk_channel')->select();
        foreach ($channel_list as $key => $val) {
            $channel[$val['bk_channelid']] = $val['bk_channel'];
        }

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        switch (I('get.dayTime/d')) {
            case 3:
                $start_time = mktime(0, 0, 0, date('m'), date('d') - 2, date('Y'));
                $end_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
                break;
            case 7:
                $start_time = mktime(0, 0, 0, date('m'), date('d') - 6, date('Y'));
                $end_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
                break;
            case 1:
                $start_time = 1;
                $end_time = time();
                break;
            case 0:
                if (I('get.start_time') != '' || I('get.end_time') != '') {
                    $start_time = strtotime(I('get.start_time'));
                    $end_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
                    if (I('get.start_time') == '') {
                        $start_time = 1;
                    }
                    if (I('get.end_time') == '') {
                        $end_time = time();
                    }
                } else {
                    $start_time = mktime(0, 0, 0, date('m'), date('d'), date('Y'));
                    $end_time = mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1;
                }
        }

        if (isset($start_time, $end_time)) {
            $where_data_daili['bk_RecieveTime'] = array('between', array($start_time, $end_time));  // 代理充值(线下)
            $where_data_tixian['bk_DakuanTime'] = array('between', array($start_time, $end_time));  // 提现
            $where_data['bk_ResultTime'] = array('between', array($start_time, $end_time));   // 充值(线上)
        }

        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');
        }

        $where_data['bk_IsSuccess'] = 2;
        $filed = array('bk_AccountID as account', 'bk_Name as nickname', 'bk_ChannelID as channel', 'SUM(bk_RealAmount) as amount', 'COUNT(bk_AccountID) as count',
            "(SELECT FLOOR(IFNULL(SUM(bk_ChangeGold/10000),0)) FROM bk_dailichargeliushui WHERE bk_PlayerID=a.bk_AccountID and bk_RecieveTime BETWEEN $start_time AND $end_time) AS xx_amount",
            "(SELECT count(bk_PlayerID) FROM bk_dailichargeliushui WHERE bk_PlayerID=a.bk_AccountID and bk_RecieveTime BETWEEN $start_time AND $end_time) AS xx_count",
            "(SELECT IFNULL(SUM(bk_RealAmount), 0) FROM bk_createorder WHERE bk_AccountID=a.bk_AccountID AND bk_IsSuccess BETWEEN 1 and 2) AS h_xs_amount",
            "(SELECT count(bk_AccountID) FROM bk_createorder WHERE bk_AccountID=a.bk_AccountID AND bk_IsSuccess BETWEEN 1 and 2) AS h_xs_count",
            "(SELECT FLOOR(IFNULL(SUM(bk_ChangeGold/10000),0)) FROM bk_dailichargeliushui WHERE bk_PlayerID=a.bk_AccountID) AS h_xx_amount",
            "(SELECT count(bk_PlayerID) FROM bk_dailichargeliushui WHERE bk_PlayerID=a.bk_AccountID) AS h_xx_count",
            "(SELECT FLOOR(IFNULL(SUM(bk_TixianRMB-bk_nShouXuFei/10000), 0)) FROM bk_tixianorder WHERE bk_AccountID=a.bk_AccountID and bk_OrderState=5 and bk_DakuanTime BETWEEN $start_time AND $end_time) AS tx_amount",
            "(SELECT count(bk_AccountID) FROM bk_tixianorder WHERE bk_AccountID=a.bk_AccountID and bk_OrderState=5 and bk_DakuanTime BETWEEN $start_time AND $end_time) AS tx_count",
            "(SELECT FLOOR(IFNULL(SUM(bk_TixianRMB-bk_nShouXuFei/10000), 0)) FROM bk_tixianorder WHERE bk_AccountID=a.bk_AccountID and bk_OrderState=5) AS h_tx_amount",
            "(SELECT count(bk_AccountID) FROM bk_tixianorder WHERE bk_AccountID=a.bk_AccountID and bk_OrderState=5) AS h_tx_count");
        $order = '(h_xs_amount+h_xx_amount) desc';
        $data_list = M('bk_createorder')->field($filed)->alias('a')->where($where_data)->group('bk_AccountID')->order($order)->limit(200)->select();

        $leadeboard = 1;
        foreach ($data_list as $key => $val) {
            $data['order'] = $leadeboard;
            $data['account'] = $val['account'];
            $data['nickname'] = $val['nickname'];
            $data['channel'] = $channel[$val['channel']];
            $data['xs_amount'] = $val['amount'];   //统计线上充值金额
            $data['xs_count'] = $val['count'];   //统计线上充值次数
            $data['xx_amount'] = $val['xx_amount'];   //线下充值金额
            $data['xx_count'] = $val['xx_count'];   //线下充值次数
            $data['h_xs_amount'] = $val['h_xs_amount'];   //历史线上充值金额
            $data['h_xs_count'] = $val['h_xs_count'];   //历史线上充值次数
            $data['h_xx_amount'] = $val['h_xx_amount'];   //历史线下充值金额
            $data['h_xx_count'] = $val['h_xx_count'];   //历史线下充值次数
            $data['tx_amount'] = $val['tx_amount'];   //统计提现金额
            $data['tx_count'] = $val['tx_count'];   //统计提现次数
            $data['h_tx_amount'] = $val['h_tx_amount'];   //历史提现金额
            $data['h_tx_count'] = $val['h_tx_count'];   //历史提现次数
            $data['all_amount'] = $val['h_xs_amount'] + $val['h_xx_amount'];   // 充值总金额
            $leadeboard++;
            $layui_data['data'][] = $data;
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 每日对帐
    public function dayAccountList() {
        $platform = C('PLATFORM');
        $channel = array();
        $pay = C('PAYMENT_TYPE');

        $channel_list = M('bk_apk')->select();
        foreach ($channel_list as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }

        $channel_list = M('bk_channel')->select();
        foreach ($channel_list as $key => $val) {
            $channel[$val['bk_channelid']] = $val['bk_channel'];
        }

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->assign('platform', $platform);
            $this->assign('apk', $apk);
            $this->assign('channel', $channel);
            $this->show();
            return;
        }

        $where = [];
        $platform = I('get.platform/d');
        if ($platform > 0) {
            $where['bk_PlatformID'] = $platform;
        }

        $channelId = I('get.channel/d');
        if ($channelId > 0) {
            $where['bk_ChannelID'] = $channelId;
        }

        $apk = I('get.apk/d');
        if ($apk > 0) {
            $where['bk_ApkID'] = $apk;
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
            $where_data['log_ID'] = array('between', array($s_time, $e_time));
        }

        $sub1 = M('bk_createorder')->field('SUM(bk_RealAmount)')->where(['bk_IsSuccess' => 2, 'bk_DailyTime=log_ID'] + $where)->buildSql();
        $sub2 = M('bk_createorder')->field('SUM(bk_RealAmount)')->where(['bk_IsSuccess' => 2, '(bk_ResultTime-(bk_ResultTime+8*3600)%86400)=log_ID'] + $where)->buildSql();
        $sub3 = M('bk_dailichargeliushui')->field('SUM(bk_ChangeGold)')->where(['bk_DailyTime=log_ID'])->buildSql();
        $sub4 = M('bk_tixianorder')->field('SUM(bk_TixianRMB-bk_nShouXuFei/10000)')->where(['bk_OrderState' => 5, 'bk_DailyTime=log_ID'] + $where)->buildSql();
        $sub5 = M('bk_tixianorder')->field('SUM(bk_TixianRMB-bk_nShouXuFei/10000)')->where(['bk_OrderState' => 5, 'bk_DakuanTime<>0', '(bk_DakuanTime-(bk_DakuanTime+8*3600)%86400)=log_ID'] + $where)->buildSql();

        $field = "log_ID, $sub1 AS sub1, $sub2 AS sub2, $sub3 AS sub3, $sub4 AS sub4, $sub5 AS sub5";
        $Query = M('log_jingjigaikuang')->where($where_data)->field($field)->group('log_ID')->order('log_ID desc');
        if (0 == I('get.isExecl/d')) {
            $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        }
        $rows = $Query->select();

        $data['count'] = M('log_jingjigaikuang')->where($where_data)->count();
        foreach ($rows as $key => $row) {
            $row_data['datetime'] = date('Y-m-d', $row['log_id']);
            $row_data['chongZhiCreateTime'] = $row['sub1'] / 1;  // 创建时间充值
            $row_data['chongZhiSuccessTime'] = $row['sub2'] / 1;  // 成功时间充值
            $row_data['sendGoldNum'] = $row['sub3'] / 10000;  // 发送数量
            $row_data['tiXianCreateTime'] = $row['sub4'] / 1;  // 创建时间提现
            $row_data['tiXianSuccessTime'] = $row['sub5'] / 1;  // 成功时间提现
            $row_data['recieveGoldNum'] = $row_data['sendGoldNum'];  // 代理充值 接受数量
            $row_data['chaZhiCreateTime'] = sprintf('%.2f', $row_data['chongZhiCreateTime'] - $row_data['tiXianCreateTime']);  // 冲值差值 创建时间
            $row_data['chaZhiSuccessTime'] = sprintf('%.2f', $row_data['chongZhiSuccessTime'] - $row_data['tiXianSuccessTime']);  // 提现差值 成功时间
            $data['data'][] = $row_data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.recharge_dayaccountlist'), $data['data'], '每日对账');
        }

        $data['code'] = 0;
        $this->ajaxReturn($data);
    }
}