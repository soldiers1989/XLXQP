<?php

namespace Home\Controller;
class RechargeLeaderBoardController extends BaseController
{
    public function index()
    {
        $this->show();
    }

    //充值排行榜
    public function leaderBoard()
    {

        $where_data = $where_data_daili = $where_data_tixian = array();
        $data = array();

        G('begin');
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
            $where_data_daili['bk_RecieveTime'] = array('between', array($start_time, $end_time)); //代理充值(线下)
            $where_data_tixian['bk_DakuanTime'] = array('between', array($start_time, $end_time));  //提现
            $where_data['bk_ResultTime'] = array('between', array($start_time, $end_time));   //充值(线上)
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
        $order = "(h_xs_amount+h_xx_amount) desc";
        $data_list = M('bk_createorder')->field($filed)->alias('a')->where($where_data)->group('bk_AccountID')->order($order)->limit(200)->select();

        $layui_data['sql'] = M('bk_createorder')->getLastSql();
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
        G('end');

        $layui_data['code'] = 0;
        $layui_data['time'] = G('begin', 'end') . 's';
        $this->ajaxReturn($layui_data);
    }
}