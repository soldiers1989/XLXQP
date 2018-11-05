<?php

namespace Home\Controller;
class YuebaoController extends BaseController
{

    public function index()
    {
        $this->show();
    }

    // 余额宝统计-利率调整
    public function yuebaoConfig()
    {
        $up_date = array(); // 数据库更新
        $flag = ''; // 配置标签
        $data = ''; // 配置值

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
        SendToGame(C('socket_ip'), 30000, 1650, $str);

        $this->ajaxReturn(['code' => 0, 'flag' => $flag, 'data' => $data]);
    }

    // 余额宝统计-余额宝明细
    public function yuebaoDetail()
    {

        $platform = C('platform');  // 平台
        $type = C('yuebao_type');   // 余额宝类型
        $vary = C('yuebao_vary');   // 余额宝变化类型
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
        if (I('get.nickname') != "") {
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
        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['bk_Time'] = array('between', array($s_time, $e_time)); // 起始时间
        }

        $layui_data['page'] = I('get.page/d');
        $layui_data['count'] = M('bk_yuebaodetail')->where($where_data)->count();
        $order = "bk_Time desc";
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
            $this->setExeclData(C('cellName.yuebao_detail'), $layui_data['data'], '余额宝明细');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 余额宝统计
    public function yuebaoStatistics()
    {

        // 暂时不涉及到平台 包 渠道
        $where_data = array();
//        $platform = C('platform');  // 平台
//        $apk = array(); // apk
//
//        $apk_list = M('bk_apk')->field(['bk_ApkID', 'bk_Apk'])->select();
//        foreach ($apk_list as $key => $val) {
//            $apk[$val['bk_apkid']] = $val['bk_apk'];
//        }
        if (!IS_AJAX && I('get.isExecl/d') == 0) {
//            $this->assign('platform', $platform);
//            $this->assign('apk', $apk);
            $this->show();
            return;
        }
//        if (I('get.platform/d') > 0) {
//            $where_data['bk_PlatformID'] = I('get.platform/d'); // 平台
//        }
//        if (I('get.apk/d') > 0) {
//            $where_data['bk_ApkID'] = I('get.apk/d');   // apk
//        }
        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time')) + 24 * 60 * 60 - 1;
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['bk_Time'] = array('between', array($s_time, $e_time)); // 起始时间
        }

        $layui_data['page'] = I('get.page/d');
        $layui_data['count'] = M('bk_yuebaostatistics')->where($where_data)->count();
        $order = "bk_Time desc";
        $Query = M('bk_yuebaostatistics')->where($where_data)->order($order);
        if (I('get.isExecl/d') == 0) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        foreach ($data_list as $key => $val) {
            $data['date'] = date('Y-m-d', $val['bk_time']); // 日期
//            $data['platform'] = $platform[$val['bk_platformid']];  // 平台
//            $data['apk'] = $apk[$val['bk_apkid']];  // apk
//            $data['channel'] = '';  // 渠道
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
            $this->setExeclData(C('cellName.yuebao_statistics'), $layui_data['data'], '余额宝统计');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 余额宝排行榜
    public function yuebaoLeaderboard()
    {

        $where_data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');
        }

        $order = "bk_YuebaoTotall desc";
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
            $this->setExeclData(C('cellName.yuebao_leaderboard'), $layui_data['data'], '余额宝排行榜');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }
}