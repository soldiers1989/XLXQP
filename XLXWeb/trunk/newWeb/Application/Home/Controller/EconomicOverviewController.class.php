<?php

namespace Home\Controller;
class EconomicOverviewController extends BaseController
{

    public function index()
    {
        $this->show();
    }

    // 游戏经济
    public function gameEconomic()
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

        $layui_data['count'] = M('log_jingjigaikuang')->where($where_data)->count();
        $order = "log_Time desc";
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
            $this->setExeclData(C('cellName.game_economic'), $layui_data['data'], '游戏经济');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //金币排行榜
    public function goldLeaderBoard()
    {
        $data = array();

        G('begin');
        $channel = array();
        $channel_list = M('bk_channel')->select();
        foreach ($channel_list as $key => $val) {
            $channel[$val['bk_channelid']] = $val['bk_channel'];
        }

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $order = "gd_Gold desc";
        $fields = array('gd_AccountID', 'gd_Name', 'gd_ChannelID', 'gd_Last_LoginTime', 'gd_Gold');
        $data_list = M('gd_account')->field($fields)->order($order)->limit(300)->select();
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

        G('end');
        $layui_data['time'] = G('begin', 'end') . 's';
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }
}