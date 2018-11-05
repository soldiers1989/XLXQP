<?php
/*
  ━━━━━━神兽出没━━━━━━
 　　 ┏┓     ┏┓
 　　┏┛┻━━━━━┛┻┓
 　　┃　　　　　 ┃
 　　┃　　━　　　┃
 　　┃　┳┛　┗┳  ┃
 　　┃　　　　　 ┃
 　　┃　　┻　　　┃
 　　┃　　　　　 ┃
 　　┗━┓　　　┏━┛　Code is far away from bug with the animal protecting
 　　　 ┃　　　┃    神兽保佑,代码无bug
 　　　　┃　　　┃
 　　　　┃　　　┗━━━┓
 　　　　┃　　　　　　┣┓
 　　　　┃　　　　　　┏┛
 　　　　┗┓┓┏━┳┓┏┛
 　　　　 ┃┫┫ ┃┫┫
 　　　　 ┗┻┛ ┗┻┛
 ━━━━━━感觉萌萌哒━━━━━━

          佛祖镇楼                  BUG辟易
          佛曰:
          写字楼里写字间，写字间里程序员；
          程序人员写程序，又拿程序换酒钱。
          酒醒只在网上坐，酒醉还来网下眠；
          酒醉酒醒日复日，网上网下年复年。
          但愿老死电脑间，不愿鞠躬老板前；
          奔驰宝马贵者趣，公交自行程序员。
          别人笑我忒疯癫，我笑自己命太贱；
          不见满街漂亮妹，哪个归得程序员？
*/

namespace Home\Controller;
class FreezeManagementController extends BaseController
{

    public function index()
    {
        $this->show();
    }

    //冻结管理-ip列表
    public function ipList()
    {

        $where_data = array();
        $data = array();
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        if (I('get.freeze_ip') != "") {
            $where_data['bk_IP'] = I('get.freeze_ip');
        }

        if (I('get.state/d') != 0) {
            $where_data['bk_State'] = I('get.state/d');
        }

        $layui_data['count'] = M('bk_freezingip')->where($where_data)->count();
        $order = "bk_Time desc";
        $data_list = M('bk_freezingip')->where($where_data)->order($order)->page(I('page/d'))->limit(I('limit/d'))->select();

        $order = 1;
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_id'];
            $data['number'] = $order++;
            $data['freeze_ip'] = $val['bk_ip'];
            $data['state'] = $val['bk_state'] == 2 ? "已冻结" : '已解冻';
            $data['bk_state'] = $val['bk_state'];
            $data['freezeReason'] = $val['bk_freezereason'];
            $data['unfreezeReason'] = $val['bk_unfreezereason'];
            $data['operator'] = $val['bk_operator'];
            $data['freeze_time'] = date('Y-m-d H:m:s', $val['bk_time']);
            $layui_data['data'][] = $data;
        }
        $layui_data['page'] = I('get.page/d');
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //解冻ip
    public function doIP()
    {

        if (I('post.id/d') <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        $id = I('post.id/d');
        //通信数据
        $nuLock = 1;
        $ip = M('bk_freezingip')->where(array('bk_ID' => $id))->getField('bk_IP');
        $result = M('bk_freezingip')->where(array('bk_ID' => $id))->delete();
        $this->sendGameMessage($nuLock, 1, $ip);
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    public function deviceCodeList()
    {
        $where_data = array();
        $data = array();

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        if (I('get.freeze_deviceCode') != "") {
            $where_data['bk_DeviceCode'] = I('get.freeze_deviceCode');
        }
        if (I('get.state/d') != 0) {
            $where_data['bk_State'] = I('get.state/d');
        }

        $layui_data['count'] = M('bk_freezingdevicecode')->where($where_data)->count();
        $data_list = M('bk_freezingdevicecode')->where($where_data)->page(I('page/d'))->limit(I('limit/d'))->select();

        $order = 1;
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_id'];
            $data['number'] = $order++;
            $data['freeze_deviceCode'] = $val['bk_devicecode'];
            $data['state'] = $val['bk_state'] == 2 ? "已冻结" : '已解冻';
            $data['bk_state'] = $val['bk_state'];
            $data['freezeReason'] = $val['bk_freezereason'];
            $data['unfreezeReason'] = $val['bk_unfreezereason'];
            $data['operator'] = $val['bk_operator'];
            $data['freeze_time'] = date('Y-m-d H:m:s', $val['bk_time']);
            $layui_data['data'][] = $data;
        }
        $layui_data['page'] = I('get.page/d');
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //解冻设备码
    public function doDeviceCode()
    {

        if (I('post.id/d') <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        $id = I('post.id');
        //通信数据
        $nuLock = 1;
        $deviceCode = M('bk_freezingdevicecode')->where(array('bk_ID' => $id))->getField('bk_DeviceCode');
        $result = M('bk_freezingdevicecode')->where(array('bk_ID' => $id))->delete();
        $this->sendGameMessage($nuLock, 1, $deviceCode);
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    //帐号冻结
    public function userlockList()
    {

        if (!IS_AJAX) {
            $this->show();
            return;
        }
        if (I('get.AccountID/d') > 0) {
            $where['bk_AccountID'] = I('get.AccountID/d');
        }

        if (I('get.state/d') != 0) {
            $where['bk_State'] = I('get.state/d');
        }

        $rows = M('bk_freezingaccountid')->where($where)->page(I('get.page/d'))->limit(I('get.limit/d'))->order('bk_ID desc')->select();
        foreach ($rows as $row) {
            $row_data['id'] = $row['bk_id'];
            $row_data['AccountID'] = $row['bk_accountid'];
            $row_data['name'] = M('bk_accountv')->where(['bk_AccountID' => $row['bk_accountid']])->getField('gd_name');
            $row_data['historyChongZhi'] = M('bk_payorder')->where(['bk_AccountID' => $row['bk_accountid']])->sum("bk_GetGold") / 10000;  // 历史充值
            $row_data['historyTiXian'] = M('bk_games_gold')->where(['log_AccountID' => $row['bk_accountid'], 'log_SceneType' => 53])->sum("log_ChangeValue") / 10000;  // 历史提现
            $row_data['FreezeReason'] = $row['bk_freezereason'];
            $row_data['UnfreezeReason'] = $row['bk_unfreezereason'];
            $row_data['state'] = $row['bk_state'] == 2 ? "已冻结" : '已解冻';
            $row_data['bk_state'] = $row['bk_state'];
            $row_data['Operator'] = $row['bk_operator'];
            $row_data['Time'] = date('Y-m-d H:i:s', $row['bk_time']);
            $data['data'][] = $row_data;
        }
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //玩家信息
    public function userInfo()
    {

        $data = array();
        $where = array();
        $userStatus = C('userStatus');
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }

        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk[$val['bk_apkid']] = $val['bk_apk'];
        }

        if (!IS_AJAX && 0 == I('get.isExecl/d')) {
            $this->assign('uid', I('get.uid/d'));
            $this->show();
            return;
        }

        if (I('get.uid') !== "") {
            $uids = explode(',', I('get.uid'));
            if (count($uids) > 0) {
                $where['gd_AccountID'] = (count($uids) == 1) ? $uids[0] : array("in", $uids);
            }
        }

        if (I('get.name') != '') {
            $where['gd_Name'] = array('like', '%' . I('get.name') . '%');
        }

        if (I('get.bindAccount') != '') {
            $where['gd_BindAccount'] = I('get.bindAccount');
        }

        if (I('get.ip') != '') {
            $ip = I('get.ip');
            $where['_query'] = "gd_LoginIP={$ip}&gd_RegisterIP={$ip}&_logic=or";
        }

        if (I('get.devicecode') != '') {
            $where['gd_DeviceCode'] = I('get.devicecode');
        }

        if (count($where) == 0) {
            $where['gd_AccountID'] = 0;
        }

        $Query = M('bk_accountv')->where($where)->order("gd_RegisterTime desc");
        if (0 == I('get.isExecl/d')) $Query->page(I('get.page/d'))->limit(I('get.limit/d'));
        $rows = $Query->select();
        $data['count'] = M('bk_accountv')->where($where)->count();
        foreach ($rows as $row) {
            $row_data['accountid'] = $row['gd_accountid'];
            $row_data['name'] = $row['gd_name'];
            $row_data['bindAccount'] = empty($row['gd_bindaccount']) ? "未绑定" : "已绑定";
            $row_data['activeTime'] = $row['gd_activetime'];
            $row_data['apk'] = $apk[$row['gd_apkid']];
            $row_data['channel'] = $channel_list[$row['gd_channelid']];
            $row_data['registerip'] = M('bk_freezingip')->where(['bk_IP' => $row['gd_registerip'], 'bk_State' => 2])->count() ? '(冻结)' . $row['gd_registerip'] : $row['gd_registerip']; //注册IP
            if (0 == I('get.isExecl/d')) $row_data['d_registerip'] = $row['gd_registerip'];
            $row_data['devicecode'] = M('bk_freezingdevicecode')->where(['bk_DeviceCode' => $row['gd_devicecode'], 'bk_State' => 2])->count() ? '(冻结)' . $row['gd_devicecode'] : $row['gd_devicecode'];
            if (0 == I('get.isExecl/d')) $row_data['d_devicecode'] = $row['gd_devicecode'];
            $row_data['logintime'] = date("Y-m-d H:i", $row['gd_last_logintime']);
            $row_data['loginIP'] = M('bk_freezingip')->where(['bk_IP' => $row['gd_loginip'], 'bk_State' => 2])->count() ? '(冻结)' . $row['gd_loginip'] : $row['gd_loginip'];
            $row_data['Last_LoginArea'] = $row['gd_last_loginarea'];
            if (0 == I('get.isExecl/d')) $row_data['d_loginIP'] = $row['gd_loginip'];
            $chongzhiTotal = M('bk_payorder')->where(array("bk_AccountID" => $row['gd_accountid']))->sum("bk_GetGold") / 10000;
            $dailiChongzhi = M('bk_dailichargeliushui')->where(['bk_PlayerID' => $row['gd_accountid']])->sum('bk_ChangeGold') / 10000;
            $row_data['chongzhiTotal'] = $chongzhiTotal + $dailiChongzhi . ' = ' . $chongzhiTotal . ' + ' . $dailiChongzhi;
            $row_data['VIPLv'] = $row['gd_viplv'];
            $row_data['gold'] = $row['gd_gold'] / 10000;
            $row_data['totalonlinetime'] = secsToStr(intval($row['gd_totalonlinetime']));
            $row_data['datShuYin'] = M("bk_games_gold")->where(array(
                'log_AccountID' => $row['gd_accountid'],
                'log_IsGameChange' => 1,
                'log_Time' => array("between", array(strtotime(date("Y-m-d"), time()), time()))
            ))->sum("log_ChangeValue");
            $row_data['datShuYin'] = intval($row_data['datShuYin']) / 10000;

            $row_data['LiShiYaZhu'] = abs(M('bk_games_gold')->where([
                    'log_AccountID' => $row['gd_accountid'],
                    'log_IsGameChange' => 1,
                    'log_ChangeValue' => array('lt', 0)
                ])->sum("log_ChangeValue") / 10000); //历史总押注

            $row_data['LiShiFaJiang'] = M('bk_games_gold')->where([
                    'log_AccountID' => $row['gd_accountid'],
                    'log_IsGameChange' => 1,
                    'log_ChangeValue' => array('gt', 0)
                ])->sum("log_ChangeValue") / 10000; //历史总发奖

            $row_data['lishiShuYin'] = M("bk_games_gold")->where(array(
                'log_AccountID' => $row['gd_accountid'],
                'log_IsGameChange' => 1,
            ))->sum("log_ChangeValue");

            $row_data['lishiShuYin'] = intval($row_data['lishiShuYin'] / 10000);
            $row_data['userState'] = M('bk_freezingaccountid')->where(['bk_AccountID' => $row['gd_accountid'], 'bk_State' => 2])->count() ? '锁定' : '正常';
            $row_data['LiShiTiXian'] = M("bk_tixianorder")->where(array(
                'bk_AccountID' => $row['gd_accountid'],
                'bk_OrderState' => 5
            ))->sum("bk_TixianRMB");
            $row_data['LiShiTiXian'] = $row_data['LiShiTiXian'] ? abs($row_data['LiShiTiXian']) : 0;

            $proxy = M('bk_proxy')->field("(gd_DirectMember+gd_OtherMember) as userTotal, gd_AllCommission, gd_CanTakeCommission")->where(array('gd_AccountID' => $row['gd_accountid']))->find();
            $row_data['userTotal'] = intval($proxy['userTotal']);
            $row_data['onlinestate'] = $userStatus[$row['gd_onlinestate']];
            $row_data['allcommission'] = intval($proxy['gd_allcommission']) / 10000;
            $row_data['cantakecommission'] = intval($proxy['gd_cantakecommission']) / 10000;
            $player_data = M('bk_playerdata')->where(['bk_AccountID' => $row['gd_accountid']])->find();
            if (0 == I('get.isExecl/d')) $row_data['BankName'] = $player_data['bk_bankname'];
            if (0 == I('get.isExecl/d')) $row_data['CardNum'] = $player_data['bk_bankcard'];
            if (0 == I('get.isExecl/d')) $row_data['RealName'] = $player_data['bk_name'];
            if (0 == I('get.isExecl/d')) $row_data['alipay'] = $player_data['bk_alipay'];
            if (0 == I('get.isExecl/d')) $row_data['alipayName'] = $player_data['bk_alipayname'];
            if (0 == I('get.isExecl/d')) $row_data['isIpLock'] = M("bk_freezingip")->where(array("bk_IP" => $row['gd_registerip']))->count();
            if (0 == I('get.isExecl/d')) $row_data['userGoldList'] = U('FreezeManagement/userGoldList', array('accountid' => $row['gd_accountid']));
            if (0 == I('get.isExecl/d')) $row_data['userTixianList'] = U('FreezeManagement/userTixianList', array('accountid' => $row['gd_accountid']));
            $data['data'][] = $row_data;
        }

        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        if (1 == I('get.isExecl/d')) ($this->setExeclData(C('cellName.freezeManagement_userInfo'), $data['data'], '玩家查询'));
        $this->ajaxReturn($data);
    }

    //机器人管理
    public function robotList()
    {

        $userStatus = C('userStatus');
        $where = array();
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $name = I('get.name');
        if (!empty($name)) {
            $where['bk_Name'] = array('like', '%' . $name . '%');
        }

        $uid = I('get.uid/d');
        if (0 != $uid) {
            $where['bk_RobotID'] = $uid;
        }

        $bindAccount = I('get.bindAccount');
        if (!empty($bindAccount)) {
            $where['bk_Robot'] = $bindAccount;
        }

        if (count($where) == 0) {
            //$where['bk_Robot'] = 0;
        }

        $rows = M('bk_robot_gold')->page(I('get.page/d'))->limit(I('get.limit/d'))->where($where)->select();
        $data['count'] = M('bk_robot_gold')->where($where)->count();
        foreach ($rows as $key => $row) {
            $data_row['robot'] = $row['bk_robot'];  //账号
            $data_row['robotid'] = $row['bk_robotid']; //机器人ID
            $data_row['name'] = $row['bk_name']; //机器人昵称
            $data_row['registertime'] = $row['bk_registertime']; //注册时间
            $data_row['Last_LoginTime'] = date('Y-m-d  H:i', $row['bk_last_logintime']);  //最后一次登录时间
            $data_row['Last_LoginArea'] = $row['bk_last_loginArea']; //最后一次登录地域
            $data_row['Last_LoginIP'] = $row['bk_last_loginip']; //机器人最后一次登陆IP
            $data_row['Charge'] = M('bk_robotgoldchange')->where([
                    'log_GoldChangeReason' => 1,
                    'log_AccountID' => $row['bk_robotid']
                ])->sum('log_ChangeGold') / 10000;  //历史充值金额
            $data_row['VIPLv'] = $row['bk_viplv']; //VIP
            $data_row['gold'] = $row['bk_gold'] / 10000; //金币
            $data_row['TotalOnlineTime'] = $row['bk_totalonlinetime']; //在线时长
            $data_row['dayShuYin'] = ($row[strtolower('log_BRJH_TodayZongShuYing')] + $row[strtolower('log_LHD_TodayZongShuYing')] + $row[strtolower('log_BJL_TodayZongShuYing')] + $row[strtolower('log_BCBM_TodayZongShuYing')] + $row[strtolower('log_XXZP_TodayZongShuYing')] + $row[strtolower('log_ZJH_TodayZongShuYing')] + $row[strtolower('log_NN_TodayZongShuYing')] + $row[strtolower('log_HBJL_TodayZongShuYing')] + $row[strtolower('log_TTZ_TodayZongShuYing')] + $row[strtolower('log_PDK_TodayZongShuYing')]) / 10000;
            $data_row['lishiShuYin'] = ($row[strtolower('log_BRJH_HistoryZongShuYing')] + $row[strtolower('log_LHD_HistoryZongShuYing')] + $row[strtolower('log_BJL_HistoryZongShuYing')] + $row[strtolower('log_BCBM_HistoryZongShuYing')] + $row[strtolower('log_XXZP_HistoryZongShuYing')] + $row[strtolower('log_ZJH_HistoryZongShuYing')] + $row[strtolower('log_NN_HistoryZongShuYing')] + $row[strtolower('log_HBJL_HistoryZongShuYing')] + $row[strtolower('log_TTZ_HistoryZongShuYing')] + $row[strtolower('log_PDK_HistoryZongShuYing')]) / 10000; //历史输赢

            $data_row['RobotState'] = $row['bk_robotstate'] == 0 ? '正常' : '冻结';   //账号状态 RobotState
            $data_row['robot_state'] = $row['bk_robotstate'];
            $data_row['OnlineState'] = $userStatus[$row['bk_onlinestate']];  //是否在线

            $RobotType = function () use ($row) {
                if (in_array(intval($row['bk_robottype']), [1, 2, 3])) {
                    return "S";
                } elseif (in_array(intval($row['bk_robottype']), [4, 5, 6])) {
                    return "M";
                } elseif (in_array(intval($row['bk_robottype']), [7, 8, 9])) {
                    return "L";
                } else {
                    return "未知";
                }
            };
            $data_row['RobotType'] = $RobotType();//账号类型
            $data_row['robotGoldUrl'] = U('FreezeManagement/robotGoldList', ['robotid' => $row['bk_robotid']]);
            $data['data'][] = $data_row;
        }
        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        $this->ajaxReturn($data);
    }

    //取某机器人历史输赢
    public function getRobotGamesShuYing()
    {

        $games = C("games");
        $filed = "sum(log_ChangeValue) as ChangeValue, log_SceneType";
        $start_time = strtotime(date('Y-m-d'));
        if (I('post.event') == 'allShuYing') {
            $start_time = 0;
        }

        $data['data'] = M('bk_robot_gold')->field($filed)->where(array(
            "bk_RobotID" => I('post.uid/d'),
            "log_SceneType" => array("gt", 0),
            "log_IsGameChange" => 1,
            "log_Time" => array("between", array($start_time, time()))
        ))->group("log_SceneType")->select();

        foreach ($data['data'] as $key => $row) {
            $data['data'][$key]['gameName'] = $games[$row['log_scenetype']];
        }
        $this->ajaxReturn($data);
    }

    //某个机器人金币变化情况
    public function robotGoldList()
    {

        $operate = C('operate');
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $rows = M("bk_robot_gold")->where(array("bk_RobotID" => I('get.robotid/d')))->page(I('get.page/d'))->limit(I('get.limit/d'))->order("log_Time desc")->select();
        $data['count'] = M("bk_robot_gold")->where(array("bk_RobotID" => I('get.robotid/d')))->count();

        foreach ($rows as $key => $row) {
            $row_data['robotid'] = $row['bk_robotid'];
            $row_data['name'] = $row['bk_name'];
            $row_data['beginValue'] = $row['log_beginvalue']; //变更前数量
            $row_data['ChangeValue'] = $row['log_changevalue']; //变更数量
            $row_data['value'] = $row['log_value']; //变更后数量
            $row_data['daojuname'] = '金币'; //道具名称
            $row_data['text'] = $operate[$row['log_operate']];
            '描述';//描述
            $row_data['time'] = date("Y-m-d H:i:s", $row['log_time']);//时间
            $data['data'][] = $row_data;
        }
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //更新机器人锁定状态
    public function updateRobotStatus()
    {

        $robotid = I('post.robotid/d');
        $isStop = I('post.nuLock/d');
        // $id = M('bk_robot')->where([ 'gd_AccountID' => $robotid ])->data([ 'gd_RobotState' => abs($isStop-1)])->save();
        $isStop = pack('C', abs($isStop - 1));
        $robotid = pack('L', $robotid);
        $body = $isStop . $robotid;
        $socket_result = SendToGame(C('SOCKET_IP'), 30000, 1315, $body);
        $this->ajaxReturn(['code' => 0]);
    }

    //查看IP状态
    public function getIpStatus()
    {

        $ip = I('post.ip');
        if (empty($ip)) {
            $data['code'] = 1;
        }
        $data['isIpLock'] = M("bk_freezingip")->where(array("bk_IP" => $ip, 'bk_State' => 2))->count();
        $this->ajaxReturn($data);
    }

    //IP锁定解锁
    public function lockIp()
    {

        $ip = I('post.ip');
        $nuLock = I('post.nuLock/d');
        if (empty($ip)) {
            $data['code'] = 1;
        }

        if ($nuLock == 0) {
            M('bk_freezingip')->add(array(
                'bk_IP' => $ip,
                'bk_FreezeReason' => I('post.cause'),
                'bk_State' => 2,
                'bk_Operator' => $this->login_admin_info['bk_name'],
                'bk_Time' => time()
            ));
        } else {
            M('bk_freezingip')->data(array(
                'bk_UnfreezeReason' => I('post.cause'),
                'bk_State' => 1,
                'bk_Operator' => $this->login_admin_info['bk_name'],
                'bk_Time' => time()
            ))->where(['bk_IP' => $ip])->save();
        }
        $this->sendGameMessage($nuLock, 1, $ip);
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //查看设备码是否锁定
    public function getkDeviceCodeStatus()
    {

        $deviceCode = I('post.deviceCode');
        $data['isDeviceCodeLock'] = M('bk_freezingdevicecode')->where(['bk_DeviceCode' => $deviceCode, 'bk_State' => 2])->count();
        $this->ajaxReturn($data);
    }

    //锁定或解锁设备码
    public function lockDeviceCode()
    {

        $deviceCode = I('post.deviceCode');
        $nuLock = I('post.nuLock/d');
        if (empty($deviceCode)) {
            $data['code'] = 1;
        }
        if ($nuLock == 0) {
            M('bk_freezingdevicecode')->add(array(
                'bk_DeviceCode' => $deviceCode,
                'bk_FreezeReason' => I('post.cause'),
                'bk_State' => 2,
                'bk_Operator' => $this->login_admin_info['bk_name'],
                'bk_Time' => time()
            ));
        } else {
            M('bk_freezingdevicecode')->data(array(
                'bk_DeviceCode' => $deviceCode,
                'bk_UnfreezeReason' => I('post.cause'),
                'bk_State' => 1,
                'bk_Operator' => $this->login_admin_info['bk_name'],
                'bk_Time' => time()
            ))->where(['bk_DeviceCode' => $deviceCode])->save();;
        }
        $this->sendGameMessage($nuLock, 2, $deviceCode);
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //取某会员是否锁定
    public function getUserStatus()
    {
        $accountid = I('post.accountid/d');
        $data['isUserLock'] = M('bk_freezingaccountid')->where(array('bk_AccountID' => $accountid, 'bk_State' => 2))->count() / 1;
        $this->ajaxReturn($data);
    }

    //是否机器人锁定
    public function getRobotStatus()
    {
        $robotid = I('post.robotid');
        $data['isUserLock'] = M('bk_robot')->where(array('gd_AccountID' => $robotid))->getField('gd_RobotState');
        $this->ajaxReturn($data);
    }

    //锁定或解锁会员
    public function lockUser()
    {
        $accountid = I('post.accountid');
        $nuLock = I('post.nuLock/d');
        if (empty($accountid)) {
            $data['code'] = 1;
        }

        if ($nuLock == 0) {
            M('bk_freezingaccountid')->add(array(
                'bk_AccountID' => $accountid,
                'bk_FreezeReason' => I('post.cause'),
                'bk_State' => 2,
                'bk_Operator' => $this->login_admin_info['bk_name'],
                'bk_Time' => time()
            ));
        } else {
            M('bk_freezingaccountid')->data(array(
                'bk_UnfreezeReason' => I('post.cause'),
                'bk_State' => 1,
                'bk_Operator' => $this->login_admin_info['bk_name'],
                'bk_Time' => time()
            ))->where(['bk_AccountID' => $accountid])->save();
        }
        $this->sendGameMessage($nuLock, 3, $accountid);
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //取某个人的所有游戏令日输赢
    public function getUserGamesShuYing()
    {
        $games = C("games");
        $filed = "sum(log_ChangeValue) as ChangeValue, log_SceneType";
        $start_time = strtotime(date('Y-m-d'));
        if (I('post.event') == 'allShuYing') {
            $start_time = 0;
        }

        $data['data'] = M('bk_games_gold')->field($filed)->where(array(
            "log_AccountID" => I('post.uid/d'),
//            "log_SceneType" => array( "gt" , 0),
            "log_IsGameChange" => 1,
            "log_Time" => array("between", array($start_time, time()))
        ))->group("log_SceneType")->select();
        foreach ($data['data'] as $key => $row) {
            $data['data'][$key]['changevalue'] = $row['changevalue'] / 10000;
            $data['data'][$key]['gameName'] = $games[$row['log_scenetype']];
        }
        $this->ajaxReturn($data);
    }

    //批量帐号冻结
    public function batchUserLock()
    {
        $uids = I('post.uids');
        $isLock = I('post.isLock/d');
        if (count($uids) == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '']);
        }
        foreach ($uids as $row) {
            if ($isLock == 0) {
                M('bk_freezingaccountid')->data([
                    'bk_AccountID' => $row,
                    'bk_Operator' => $this->login_admin_info['bk_name'],
                    'bk_Time' => time()
                ])->add();
                // $this->sendGameMessage( 0 ,3, $row );
            }

            if ($isLock == 1) {
                M('bk_freezingaccountid')->where(['bk_AccountID' => $row])->delete();
                //$this->sendGameMessage( 1 ,3, $row );
            }
        }
        $uids_str = implode(",", $uids);
        if ($isLock == 0) {
            $this->sendGameMessage(0, 3, $uids_str);
        } else {
            $this->sendGameMessage(1, 3, $uids_str);
        }
        $this->ajaxReturn(['code' => 0]);
    }

    //取会员VIP等级
    public function getUserVipClass()
    {
        $accountid = I('post.accountid/d');
        $vipClass = M("bk_accountv")->where(array("gd_AccountID" => $accountid))->getField("gd_VIPLv");
        $data['vipClass'] = intval($vipClass);
        $this->ajaxReturn(array('data' => $data));
    }

    //更新VIP等级
    public function updateVipClass()
    {
        $uid = I('post.uid/d');
        $vipClass = I('post.vipClass/d');
        if ($vipClass < 0 || $vipClass > 9) {
            $this->ajaxReturn(array('code' => 1));
        }
        // M('bk_accountv')->where( array( "gd_AccountID" => $uid ) )->save(array( "gd_VIPLv" => $vipClass ));
        $this->sendGameMessageVip($uid, $vipClass);
        $this->ajaxReturn(array('code' => 0));
    }

    //某个会员金币变化情况
    public function userGoldList()
    {
        $operate = C('operate');
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $where_data = array("gd_AccountID" => I('get.accountid/d'));
        if (I('get.start_time') != "" || I('get.end_time') != "") {
            $s_time = strtotime(I('get.start_time'));
            $e_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == "") {
                $s_time = 1;
            }
            if (I('get.end_time') == "") {
                $e_time = time();
            }
            $where_data['log_Time'] = array('between', array($s_time, $e_time));
        }

        if (I('get.reason/d') != 0) {
            if (I('get.reason/d') == 1) {
                $where_data['log_Operate'] = ['in', [0, 1]];
            }
            if (I('get.reason/d') == 2) {
                $where_data['log_Operate'] = 66;
            }
            if (I('get.reason/d') == 3) {
                $where_data['log_Operate'] = 53;
            }
        }
        $rows = M("bk_games_gold")->where($where_data)->page(I('get.page/d'))->limit(I('get.limit/d'))->order("log_ID desc")->select();
        $data['count'] = M("bk_games_gold")->where($where_data)->count();
        foreach ($rows as $key => $row) {
            $row_data['accountid'] = $row['gd_accountid'];
            $row_data['name'] = $row['gd_name'];
            $row_data['beginValue'] = ($row['log_beginvalue'] / 10000); //变更前数量
            $row_data['ChangeValue'] = ($row['log_changevalue'] / 10000); //变更数量
            $row_data['value'] = ($row['log_value'] / 10000); //变更后数量
            $row_data['daojuname'] = '金币'; //道具名称
            $row_data['text'] = $operate[$row['log_operate']];
            '描述';//描述
            $row_data['time'] = date("Y-m-d H:i:s", $row['log_time']);//时间
            $data['data'][] = $row_data;
        }
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //某个会员所有提现记录
    public function userTixianList()
    {
        $operate = C('operate');
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $rows = M("bk_tixianorder")->where(array("bk_OrderState" => '5', "bk_AccountID" => I('get.accountid/d')))->page(I('get.page/d'))->limit(I('get.limit/d'))->order("bk_DakuanTime desc")->select();
        $data['count'] = M("bk_tixianorder")->where(array("bk_OrderState" => '5', "bk_AccountID" => I('get.accountid/d')))->count();
        $name = M('bk_accountv')->where(['gd_AccountID' => I('get.accountid/d')])->getField('gd_Name');
        foreach ($rows as $key => $row) {
            $row_data['accountid'] = $row['bk_accountid'];
            $row_data['name'] = $name;
            $row_data['OrderNum'] = $row['bk_ordernum'];

            //  $row_data['beginValue'] = $row['log_beginvalue'] / 10000; //变更前数量
            $row_data['ChangeValue'] = $row['bk_tixianrmb']; //变更数量
            //$row_data['value'] = $row['log_value'] / 10000; //变更后数量
            $row_data['daojuname'] = '金币'; //道具名称
            $row_data['text'] = '提现扣除';
            '描述';//描述
            $row_data['time'] = date("Y-m-d H:i:s", $row['bk_dakuantime']);//时间
            $data['data'][] = $row_data;
        }
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //公告配置
    public function gongGao()
    {

        $gameNoticeType = C('gameNoticeType');  // 游戏公告子类型
        $label = C('label');    // 公告角标
        $color_ = C('color_');    // 内容文字颜色(中文)
        $isPop = [0 => '不弹出', 1 => '弹出'];   // 是否弹出

        $where = array();
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $data['page'] = I('get.page/d');
        $data['count'] = M('bk_gonggao')->where($where)->count();
        $order = "bk_Time desc";
        $rows = M('bk_gonggao')->where($where)->page(I('get.page/d'))->limit(I('get.limit/d'))->order($order)->select();
        $number = 1;
        foreach ($rows as $key => $row) {
            $rows[$key]['id'] = $row['bk_id'];  // 公告id
            $rows[$key]['number'] = $number++;  // 编号
            $rows[$key]['Type'] = ($row['bk_type'] == 1) ? '登录公告' : '游戏公告';    // 公告类型
            $rows[$key]['gameType'] = $gameNoticeType[$row['bk_gametype']];    // 游戏公告子类型
            $rows[$key]['OnlineTime'] = date('Y-m-d H:i:s', $row['bk_onlinetime']); // 上架时间
            $rows[$key]['OfflineTime'] = date('Y-m-d H:i:s', $row['bk_offlinetime']);   // 下架时间
            $status = function () use ($row, $key) {
                if ($row["bk_isstop"] == 0) {
                    return "暂停";
                }
                if ($row['bk_onlinetime'] > time()) {
                    return "未上架";
                } elseif ($row['bk_offlinetime'] > time() && $row['bk_onlinetime'] < time()) {
                    return "上架中";
                } else {
                    return "已下架";
                }
            };
            $rows[$key]['isPop'] = $isPop[$row['bk_ispop']];    // 是否弹出
            $rows[$key]['label'] = $label[$row['bk_label']];    // 公告角标
            $rows[$key]['webPage'] = $row['bk_webpage'];    // 指定页面
            $rows[$key]['color'] = $color_[$row['bk_color']];    // 内容颜色
            $rows[$key]['size'] = $row['bk_size'] . 'px';    // 文字大小
            $apk = function () use ($row) {
                $apk_rows = M('bk_apk')->select();
                foreach ($apk_rows as $key => $val) {
                    $apk_list[$val['bk_apkid']] = $val['bk_apk'];
                }
                if ($row['bk_apkid'] == "all") {
                    return implode(',', $apk_list);
                } elseif ($row['bk_apkid'] != "") {
                    $carr = explode(',', $row['bk_apkid']);
                    foreach ($carr as $key => $val) {
                        isset($apk_list[$val]) && ($carr[$key] = $apk_list[$val]);
                    }
                    return $carr;
                }
            };
            $rows[$key]['apk'] = $apk();    // apk包
            $channel = function () use ($row) {
                $channel_rows = M('bk_channel')->select();
                foreach ($channel_rows as $key => $val) {
                    $channel_list[$val['bk_channelid']] = $val['bk_channel'];
                }
                if ($row['bk_channelid'] == "all") {
                    return implode(',', $channel_list);
                } elseif ($row['bk_channelid'] != "") {
                    $carr = explode(',', $row['bk_channelid']);
                    foreach ($carr as $key => $val) {
                        isset($channel_list[$val]) && ($carr[$key] = $channel_list[$val]);
                    }
                    return $carr;
                }
            };
            $rows[$key]['channel'] = $channel();    // 渠道
            $rows[$key]['status'] = $status();  // 公告状态
            $rows[$key]['time'] = date('Y-m-d H:i:s', $row['bk_time']); // 操作时间
            $rows[$key]['operator'] = $row['bk_operator'];  // 操作人
            $rows[$key]['isStop'] = $row["bk_isstop"];  // 是否暂停 0暂定 1继续
            $rows[$key]['editUrl'] = U('FreezeManagement/editGongGao', array('id' => $row['bk_id'])); // 编辑url
            $data['data'] = $rows;
        }
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    // 添加公告
    public function addGongGao()
    {

        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk_list[$val['bk_apkid']] = $val['bk_apk'];
        }
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }
        $this->assign("apk_list", $apk_list);   // apk包
        $this->assign("channel_list", $channel_list);   // 渠道
        $this->show();
    }

    // 图片上传
    public function uploadImages()
    {

        $upload = new \Think\Upload();  // 实例化上传类
        $upload->maxSize = 3145728; // 设置附件上传大小 3mb
        $upload->exts = array('jpg'); // 设置附件上传类型
        $upload->rootPath = './Public/upload/'; // 设置附件上传根目录
        $upload->savePath = 'images/'; // 上传子目录
        $upload->autoSub = false;   // 不生成时间目录
        $upload->saveName = ''; // 保持上传文件名不变
        $info = $upload->upload();  // 上传文件
        if (!$info) {
            $res['code'] = 1;
            $res['message'] = $upload->getError();  // 上传错误提示错误信息
        } else {
            $res['code'] = 0;
            $res['message'] = '上传成功';
            foreach ($info as $file) {
                $res['imgName'] = $file['savename'];  // 图片上传名
            }
        }
        $this->ajaxReturn($res);
    }

    // 添加公告
    public function doAddGongGao()
    {

        $contentColor = C('color'); // 内容颜色

        $type = I('post.type/d');  // 公告类型
        if (!in_array($type, array(1, 2))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '公告类型参数不对'));
        }

        $gameType = I('post.gameType/d');   // 游戏公告子类型
        if ($type == 2 && !in_array($gameType, array(1, 2, 3, 4))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '游戏公告子类型未选择'));
        }

        $priority = I('post.priority/d');  // 优先级
        if (!($priority > 0 && $priority < 100)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '优先级设置范围 1－99 '));
        }

        // 验证时间
        $onlineTime = strtotime(I('post.onlineTime'));
        if ($onlineTime < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 开始时间不正确 '));
        }
        $offlineTime = strtotime(I('post.offlineTime'));
        if ($offlineTime < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 结束时间不正确 '));
        }
        if ($onlineTime >= $offlineTime) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 上架时间必须小于下架时间 '));
        }

        $title = I('post.title'); // 标题
        if ($type == 1 && empty($title)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '标题不能为空'));
        }
        if (in_array($gameType, array(1, 2, 3)) && empty($title)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '标题不能为空'));
        }

        $isPop = I('post.isPop');   // 是否弹出
        if ($type == 2 && !in_array($isPop, array(0, 1))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '是否弹出未选择'));
        }

        $label = I('post.label');   // 公告角标
        if ($type == 2 && !in_array($label, array(0, 1, 2))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '公告角标未选择'));
        }

        $webPage = I('post.webPage') == '' ? '0' : I('post.webPage');   // 指定页面

        $color = I('post.color/d');  // 内容颜色
        if ($color != 0 && !in_array($color, array(1, 2, 3, 4, 5, 6))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '内容颜色参数不对'));
        }

        $size = I('post.size/d');  // 文字大小
        if (!in_array($size, array(40, 41, 42, 43, 44, 45))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '文字大小参数不对'));
        }

        $content = I('post.content');  // 内容
        if ($type == 1 && empty($content)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '内容不能为空'));
        }
        $finalContent = $color == 0 ? "<size=" . $size . ">" . $content . "</size>" : "<color=" . $contentColor[$color] . "><size=" . $size . ">" . $content . "</size></color>"; // 组装公告内容
        if ($type == 2 && empty($content)) $finalContent = '';

        // apk
        $apkAll = I('post.apkAll');
        if ($apkAll == "all") {
            $apkID = "all";
        } else {
            $apk = I('post.apk');
            if (count($apk) == 0 || !is_array($apk)) {
                $this->ajaxReturn(array('code' => 1, 'message' => 'apk包未选择'));
            }
            $apkID = implode(',', $apk);
        }

        // 渠道
        $channelAll = I('post.channelAll');
        if ($channelAll == "all") {
            $channelID = "all";
        } else {
            $channel = I('post.channel');
            if (count($channel) == 0 || !is_array($channel)) {
                $this->ajaxReturn(array('code' => 1, 'message' => '渠道未选择'));
            }
            $channelID = implode(',', $channel);
        }

        $bannerName = I('post.bannerName');   // banner图名
        $contentName = I('post.contentName'); // 内容图名
        $pictureID = $bannerID = $contentID = 0;    // 图片ID
        if (empty($bannerName) && empty($contentName)) {
            $pictureID = 0;
        } elseif (!empty($bannerName) && empty($contentName)) {
            $bannerID = substr($bannerName, 6, -4);
            $pictureID = $bannerID;
        } elseif (!empty($contentName) && empty($bannerName)) {
            $contentID = substr($contentName, 7, -4);
            $pictureID = $contentID;
        } else {
            $bannerID = substr($bannerName, 6, -4);
            $contentID = substr($contentName, 7, -4);
            if ($bannerID != $contentID) {
                $this->ajaxReturn(array('code' => 1, 'message' => 'banner图与内容图xxx数字不一致'));
            } else {
                $pictureID = $bannerID;
            }
        }
        $bannerPath = $bannerName == '' ? '' : (C('UPLOAD_IP') . '/Public/upload/images/' . $bannerName);   // banner图路径
        $contentPath = $contentName == '' ? '' : (C('UPLOAD_IP') . '/Public/upload/images/' . $contentName); // 内容图路径

        $id = M('bk_gonggao')->add(array(
            'bk_Type' => $type, // 公告类型
            'bk_GameType' => $gameType, // 游戏公告子类型
            'bk_YouXianJi' => $priority,   // 公告优先级
            'bk_OnlineTime' => $onlineTime, // 上架时间
            'bk_OfflineTime' => $offlineTime,   // 下架时间
            'bk_Title' => $title,   // 公告标题
            'bk_IsPop' => $isPop,   // 是否弹出 0不弹出 1弹出
            'bk_Label' => $label, // 公告角标
            'bk_WebPage' => $webPage, // 指定页面
            'bk_Color' => $color,   // 内容文字颜色
            'bk_Size' => $size, // 内容文字大小
            'bk_APKID' => $apkID,   // apk
            'bk_ChannelID' => $channelID, // 渠道
            'bk_Content' => $finalContent,   // 公告内容
            'bk_ContentAll' => $content,    // 公告内容(纯文字)
            'bk_BannerPath' => $bannerPath, // banner图路径
            'bk_ContentPath' => $contentPath, // 内容图路径
            'bk_PictureID' => $pictureID,   // 图片ID
            'bk_OperateType' => 0,  // 操作类型 0未修改 1修改
            'bk_Time' => time(),    //操作时间
            'bk_IsStop' => 1,   // 暂停 0暂停 1继续
            'bk_Operator' => $this->login_admin_info['bk_name'] // 操作人
        ));

        if ($id > 0) {
            $sendMessageData['id'] = $id;  // 公告ID
            $sendMessageData['priority'] = $priority; // 优先级
            $sendMessageData['title'] = $title; // 标题
            $sendMessageData['onlineTime'] = $onlineTime;   // 上架时间
            $sendMessageData['offlineTime'] = $offlineTime; // 下架时间
            $sendMessageData['channelID'] = $channelID;   // 渠道
            $sendMessageData['content'] = $finalContent;    // 内容
            $sendMessageData['type'] = $type;   // 公告类型
            $sendMessageData['gameType'] = $gameType;   // 游戏公告子类型
            $sendMessageData['isPop'] = $isPop;   // 是否弹出
            $sendMessageData['label'] = $label;   // 公告角标
            $sendMessageData['pictureID'] = $pictureID;   // 图片ID
            $sendMessageData['webPage'] = $webPage;   // 指定页面
            $sendMessageData['isStop'] = 1;   // 开关(暂停)
            $this->sendGameMessageAddGongGao($sendMessageData);
            $this->ajaxReturn(array('code' => 0));
        }
        $this->ajaxReturn(array('code' => 1, 'message' => '添加失败'));
    }

    // 编辑公告
    public function editGongGao()
    {

        $id = I('get.id/d');

        $apk_rows = M('bk_apk')->select();    // apk包
        foreach ($apk_rows as $key => $val) {
            $apk_list[$val['bk_apkid']] = $val['bk_apk'];
            $apk_ids[] = $val['bk_apkid'];
        }
        $this->assign("apk_list", $apk_list);

        $channel_rows = M('bk_channel')->select(); // 渠道
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
            $channel_ids[] = $val['bk_channelid'];
        }
        $this->assign("channel_list", $channel_list);

        $row = M("bk_gonggao")->where(array('bk_ID' => $id))->find();
        $data['id'] = $row['bk_id'];    // 公告id
        $data['type'] = $row["bk_type"];    // 公告类型
        $data['gameType'] = $row["bk_gametype"];    // 游戏公告子类型
        $data['priority'] = $row["bk_youxianji"];   // 优先级
        $data['onlineTime'] = date("Y-m-d H:i:s", $row['bk_onlinetime']);   // 上架时间
        $data['offlineTime'] = date("Y-m-d H:i:s", $row['bk_offlinetime']); // 下架时间
        $data['title'] = $row["bk_title"];  // 标题
        $data['isPop'] = $row["bk_ispop"];  // 是否弹出
        $data['label'] = $row["bk_label"];  // 公告角标
        $data['webPage'] = $row["bk_webpage"];  // 指定页面
        $data['color'] = $row["bk_color"];  // 内容文字颜色
        $data['size'] = $row["bk_size"];    // 内容文字大小
        $data['content'] = $row["bk_contentall"];  // 内容(纯文字)
        $data['bannerName'] = end(explode('/', $row["bk_bannerpath"]));  // banner图名称
        $data['bannerPath'] = $row["bk_bannerpath"];  // banner图路径
        $data['contentName'] = end(explode('/', $row["bk_contentpath"]));  // 内容图名称
        $data['contentPath'] = $row["bk_contentpath"];  // 内容图路径
        $data['apkAll'] = (trim($row["bk_apkid"]) == "all") ? 1 : 0;
        $data['apkID'] = ($row["bk_apkid"] == "all") ? $apk_ids : explode(',', $row["bk_apkid"]);
        $data['channelAll'] = (trim($row["bk_channelid"]) == "all") ? 1 : 0;
        $data['channelID'] = ($row["bk_channelid"] == "all") ? $channel_ids : explode(',', $row["bk_channelid"]);
        $data['isStop'] = $row['bk_isstop'];   // 是否暂停
        $this->assign("notice", $data);
        $this->show();
    }

    // 编辑公告
    public function doEditGongGao()
    {

        $contentColor = C('color'); // 内容颜色

        $id = I('post.id/d');   // 公告ID

        $type = I('post.type/d');   // 公告类型
        if (!in_array($type, array(1, 2))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }
        $gameType = I('post.gameType/d');   // 公告子类型
        if ($type == 1 && in_array($gameType, array(1, 2, 3, 4))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '登录公告无子类型'));
        }

        $priority = I('post.priority/d');   // 优先级
        if (!($priority > 0 && $priority < 100)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '优先级设置范围 1－99 '));
        }

        // 验证时间
        $onlineTime = strtotime(I("post.onlineTime"));
        if ($onlineTime < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 开始时间不正确 '));
        }
        $offlineTime = strtotime(I("post.offlineTime"));
        if ($offlineTime < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 结束时间不正确 '));
        }
        if ($onlineTime > $offlineTime) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 上架时间必须小于下架时间 '));
        }

        $title = I('post.title');   // 标题
        if ($type == 1 && empty($title)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '标题不能为空'));
        }
        if (in_array($gameType, array(1, 2, 3)) && empty($title)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '标题不能为空'));
        }

        $isPop = I('post.isPop');   // 是否弹出
        if ($type == 1 && in_array($isPop, array(0, 1))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '登录公告无是否弹出'));
        }

        $label = I('post.label');   // 公告角标
        if ($type == 1 && in_array($label, array(0, 1, 2))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '登录公告无公告角标'));
        }

        $webPage = I('post.webPage') == '' ? '0' : I('post.webPage');   // 指定页面

        $color = I('post.color/d');   // 内容颜色
        if ($color != 0 && !in_array($color, array(1, 2, 3, 4, 5, 6))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '内容颜色参数不对'));
        }

        $size = I('post.size/d');   // 内容文字大小
        if (!in_array($size, array(40, 41, 42, 43, 44, 45))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '文字大小未选择'));
        }

        $content = I('post.content');   // 公告内容(纯文字)
        if ($type == 1 && empty($content)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '内容不能为空'));
        }
        $finalContent = $color == 0 ? "<size=" . $size . ">" . $content . "</size>" : "<color=" . $contentColor[$color] . "><size=" . $size . ">" . $content . "</size></color>"; // 组装公告内容
        if ($type == 2 && empty($content)) $finalContent = '';

        $bannerName = I('post.bannerName');   // banner图名
        $contentName = I('post.contentName'); // 内容图名
        $pictureID = $bannerID = $contentID = 0;    // 图片ID
        if (empty($bannerName) && empty($contentName)) {
            $pictureID = 0;
        } elseif (!empty($bannerName) && empty($contentName)) {
            $bannerID = substr($bannerName, 6, -4);
            $pictureID = $bannerID;
        } elseif (!empty($contentName) && empty($bannerName)) {
            $contentID = substr($contentName, 7, -4);
            $pictureID = $contentID;
        } else {
            $bannerID = substr($bannerName, 6, -4);
            $contentID = substr($contentName, 7, -4);
            if ($bannerID != $contentID) {
                $this->ajaxReturn(array('code' => 1, 'message' => 'banner图与内容图xxx数字不一致'));
            } else {
                $pictureID = $bannerID;
            }
        }
        $bannerPath = $bannerName == '' ? '' : (C('UPLOAD_IP') . '/Public/upload/images/' . $bannerName);   // banner图路径
        $contentPath = $contentName == '' ? '' : (C('UPLOAD_IP') . '/Public/upload/images/' . $contentName); // 内容图路径

        $apkAll = I('post.apkAll');
        if ($apkAll == "all") {
            $apkID = "all";
        } else {
            $apk = I('post.apk');
            if (count($apk) == 0 || !is_array($apk)) {
                $this->ajaxReturn(array('code' => 1, 'message' => 'APK包未选择'));
            }
            $apkID = implode(',', $apk);
        }
        $channelAll = I('post.channelAll');
        if ($channelAll == "all") {
            $channelID = "all";
        } else {
            $channel = I('post.channel');
            if (count($channel) == 0 || !is_array($channel)) {
                $this->ajaxReturn(array('code' => 1, 'message' => '渠道未选择'));
            }
            $channelID = implode(',', $channel);
        }

        $isStop = I('post.isStop');  // 是否暂停

        $yid = M('bk_gonggao')->where(array("bk_ID" => $id))->data(array(
            'bk_Type' => $type, // 公告类型
            'bk_GameType' => $gameType, // 游戏公告子类型
            'bk_YouXianJi' => $priority,    // 优先级
            'bk_OnlineTime' => $onlineTime, // 上架时间
            'bk_OfflineTime' => $offlineTime,   // 下架时间
            'bk_Title' => $title,   // 标题
            'bk_IsPop' => $isPop,   // 是否弹出
            'bk_Label' => $label,   // 角标
            'bk_WebPage' => $webPage,   // 指定页面
            'bk_Color' => $color,   // 内容颜色
            'bk_Size' => $size,   // 内容字体大小
            'bk_Content' => $finalContent,   // 内容
            'bk_ContentAll' => $content,   // 内容(纯文字)
            'bk_BannerPath' => $bannerPath,   // banner图路径
            'bk_ContentPath' => $contentPath,   // 内容图路径
            'bk_PictureID' => $pictureID,   // 图片ID
            'bk_APKID' => $apkID,   // apk包
            'bk_ChannelID' => $channelID,   // 渠道
            'bk_OperateType' => 1,  // 是否被修改(操作类型)
            'bk_IsStop' => $isStop, // 是否暂停
            'bk_AmendTime' => time(),   // 更改时间
            'bk_AmendOperator' => $this->login_admin_info['bk_name']    // 更改人
        ))->save();

        if ($yid > 0) {
            $sendGameMessage['id'] = $id;  // 公告ID
            $sendGameMessage['priority'] = $priority; // 优先级
            $sendGameMessage['title'] = $title; // 标题
            $sendGameMessage['onlineTime'] = $onlineTime;   // 上架时间
            $sendGameMessage['offlineTime'] = $offlineTime; // 下架时间
            $sendGameMessage['channelID'] = $channelID;   // 渠道
            $sendGameMessage['content'] = $finalContent;    // 内容
            $sendGameMessage['type'] = $type;   // 公告类型
            $sendGameMessage['gameType'] = $gameType;   // 游戏公告子类型
            $sendGameMessage['isPop'] = $isPop;   // 是否弹出
            $sendGameMessage['label'] = $label;   // 公告角标
            $sendGameMessage['pictureID'] = $pictureID;   // 图片ID
            $sendGameMessage['webPage'] = $webPage;   // 指定页面
            $sendGameMessage['isStop'] = $isStop;   // 开关(暂停)

            $this->sendGameMessageAddGongGao($sendGameMessage);
            $this->ajaxReturn(array('code' => 0, 'data' => $sendGameMessage));
        }
        $this->ajaxReturn(array('code' => 1, 'message' => '更新失败'));
    }

    // 删除公告
    public function delGongGao()
    {
        $id = I('post.id/d');
        $type = I('post.type/d');
        M('bk_gonggao')->where(array("bk_ID" => $id))->delete();
        $this->sendGameMessageDelGongGao(['id' => $id, 'type' => $type]);
        $this->ajaxReturn(array("code" => 0));
    }

    // 暂停开关
    public function stopGongGao()
    {

        $id = I('post.id/d');
        $isStop = I('post.isStop/d');

        if ($id == 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }
        if (!in_array($isStop, array(0, 1))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        $up_count = M("bk_gonggao")->where(array("bk_ID" => $id))->save(['bk_IsStop' => $isStop]);
        if ($up_count > 0) {
            sleep(1);
            $send_data = M('bk_gonggao')->where(['bk_ID' => $id])->find();
            $sendGameMessage['id'] = $send_data['bk_id'];  // 公告ID
            $sendGameMessage['priority'] = $send_data['bk_youxianji']; // 优先级
            $sendGameMessage['title'] = $send_data['bk_title']; // 标题
            $sendGameMessage['onlineTime'] = $send_data['bk_onlinetime'];   // 上架时间
            $sendGameMessage['offlineTime'] = $send_data['bk_offlinetime']; // 下架时间
            $sendGameMessage['channelID'] = $send_data['bk_channelid'];   // 渠道
            $sendGameMessage['content'] = $send_data['bk_content'];    // 内容
            $sendGameMessage['type'] = $send_data['bk_type'];   // 公告类型
            $sendGameMessage['gameType'] = $send_data['bk_gametype'];   // 游戏公告子类型
            $sendGameMessage['isPop'] = $send_data['bk_ispop'];   // 是否弹出
            $sendGameMessage['label'] = $send_data['bk_label'];   // 公告角标
            $sendGameMessage['pictureID'] = $send_data['bk_pictureid'];   // 图片ID
            $sendGameMessage['webPage'] = $send_data['bk_webpage'];   // 指定页面
            $sendGameMessage['isStop'] = $isStop;   // 开关(暂停)
            $this->sendGameMessageAddGongGao($sendGameMessage);
            $row = M("bk_gonggao")->where(array("bk_ID" => $id))->find();

            $status = function () use ($row) {
                if ($row["bk_isstop"] == 0) {
                    return "暂停";
                }
                if ($row['bk_onlinetime'] > time()) {
                    return "未上架";
                } elseif ($row['bk_offlinetime'] > time() && $row['bk_onlinetime'] < time()) {
                    return "上架中";
                } else {
                    return "已下架";
                }
            };
            $this->ajaxReturn(array('code' => 0, 'message' => $status()));
        }
        $this->ajaxReturn(array('code' => 1, 'message' => '更新失败'));
    }

    //跑马灯列表
    public function systemPaoMaDeng()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }

        $rows = M('bk_systempaomadeng')->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        $data['count'] = M('bk_systempaomadeng')->count();
        foreach ($rows as $key => $row) {
            $row_data['id'] = $row['bk_id'];
            $row_data['youxianji'] = $row['bk_youxianji'];
            $bobaoType = function () use ($row) {
                if ($row['bk_bobaotype'] == 1) {
                    return "后台发放";
                } elseif ($row['bk_bobaotype'] == 2) {
                    return "提现发放";
                } elseif ($row['bk_bobaotype'] == 3) {
                    return "中奖发放";
                }
            };
            $row_data['bobaotype'] = $bobaoType();
            $row_data['title'] = $row['bk_title'];

            $row_data['boBaoJianGe'] = $row['bk_bobaojiange'];
            $channe = function () use ($row) {
                $channel_rows = M('bk_channel')->select();
                foreach ($channel_rows as $key => $val) {
                    $channel_list[$val['bk_channelid']] = $val['bk_channel'];
                }
                if ($row['bk_channelid'] == "all") {
                    return implode(',', $channel_list);
                } elseif ($row['bk_channelid'] != "") {
                    $carr = explode(',', $row['bk_channelid']);
                    foreach ($carr as $key => $val) {
                        isset($channel_list[$val]) && ($carr[$key] = $channel_list[$val]);
                    }
                    return $carr;
                }
            };

            $apk = function () use ($row) {
                $apk_rows = M('bk_apk')->select();
                foreach ($apk_rows as $key => $val) {
                    $apk_list[$val['bk_apkid']] = $val['bk_apk'];
                }
                if ($row['bk_apkid'] == "all") {
                    return implode(',', $apk_list);
                } elseif ($row['bk_apkid'] != "") {
                    $carr = explode(',', $row['bk_apkid']);
                    foreach ($carr as $key => $val) {
                        isset($apk_list[$val]) && ($carr[$key] = $apk_list[$val]);
                    }
                    return $carr;
                }
            };
            $row_data['apk'] = $apk();
            $status = function () use ($row, $key) {
                if ($row['bk_onlinetime'] > time()) {
                    return "未上架";
                } elseif ($row['bk_offlinetime'] > time() && $row['bk_onlinetime'] < time()) {
                    return "上架中";
                } else {
                    return "已下架";
                }
            };

            $row_data['onlineTime'] = date("Y-m-d H:i:s", $row['bk_onlinetime']);
            $row_data['offlinetime'] = date("Y-m-d H:i:s", $row['bk_offlinetime']);
            $row_data['status'] = $status();
            $row_data['channe'] = $channe();
            $row_data['content'] = $row['bk_content'];
            $row_data['time'] = date("Y-m-d H:i:s", $row['bk_time']);
            $row_data['Operator'] = $row['bk_operator'];
            $row_data['IsStop'] = $row["bk_isstop"];
            $row_data['editUrl'] = U('FreezeManagement/editSystemPaoMaDeng', array('id' => $row['bk_id']));

            $data['data'][] = $row_data;
        }
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //跑马灯添加
    public function addSystemPaoMaDeng()
    {
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }
        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $row) {
            $apk_list[$row['bk_apkid']] = $row['bk_apk'];
        }
        $this->assign("apk_list", $apk_list);
        $this->assign("channel_list", $channel_list);
        $this->show();
    }

    //跑马灯添加
    public function doAddSystemPaoMaDeng()
    {
        $onlineTime = strtotime(I("post.onlineTime"));
        if ($onlineTime < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 开始时间不正确 '));
        }

        $offlineTime = strtotime(I("post.offlineTime"));
        if ($offlineTime < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 结束时间不正确 '));
        }

        if ($onlineTime > $offlineTime) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 上架时间必须小于下架时间 '));
        }

        $type = I("post.type/d");
        if (!in_array($type, array(1, 2))) {
            $this->ajaxReturn(array('code' => 1));
        }
        $YouXianJi = I('post.YouXianJi/d');
        if (!($YouXianJi > 100 && $YouXianJi < 255)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '优先级设置范围 101－255 '));
        }

        $title = I('post.title');
        if (empty($title)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '标题不能为空'));
        }
        $content = I('post.content');
        if (empty($content)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '内容不能为空'));
        }

        $channelAll = I('post.channelall');
        if ($channelAll == "all") {
            $channel = "all";
        } else {
            $channel = I('post.channel');
            if (count($channel) == 0 || !is_array($channel)) {
                $this->ajaxReturn(array('code' => 1, 'message' => '渠道没有选择'));
            }
            $channel = implode(',', $channel);
        }

        $apkAll = I('post.apkall');
        if ($apkAll == "all") {
            $apkId = "all";
        } else {
            $apk = I('post.apk');
            if (count($apk) == 0 || !is_array($apk)) {
                $this->ajaxReturn(array('code' => 1, 'message' => 'APK包没有选择'));
            }
            $apkId = implode(',', $apk);
        }

        $boBaoJianGe = I('post.boBaoJianGe/d');
        if (!($boBaoJianGe > 0 && $boBaoJianGe < 9999)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '间隔秒数：1 - 9999'));
        }

        $id = M('bk_systempaomadeng')->add(array(
            'bk_YouXianJi' => $YouXianJi,
            'bk_Title' => $title,
            'bk_OnlineTime' => $onlineTime,
            'bk_OfflineTime' => $offlineTime,
            'bk_BoBaoType' => $type,
            'bk_ChannelID' => $channel,
            'bk_ChannelID' => $channel,
            'bk_APKID' => $apkId,
            'bk_Content' => $content,
            'bk_OperateType' => 0,
            'bk_Time' => time(),
            'bk_Operator' => $this->login_admin_info['bk_name'],
            'bk_BoBaoJianGe' => $boBaoJianGe
        ));

        if ($id > 0) {
            sleep(5);
            $data = M('bk_systempaomadeng')->where(['bk_ID' => $id])->find();
            $sendGameMessage['id'] = $data['bk_id'];  //小喇叭ID
            $sendGameMessage['YouXianJi'] = $data['bk_youxianji']; //权重
            $sendGameMessage['OnlineTime'] = $data['bk_onlinetime']; //开始时间
            $sendGameMessage['OfflineTime'] = $data['bk_offlinetime']; //结束时间
            $sendGameMessage['BoBaoJianGe'] = $data['bk_bobaojiange']; //间隔时间  bk_ChannelID
            $sendGameMessage['ChannelID'] = $data['bk_channelid']; //渠道
            $sendGameMessage['Content'] = $data['bk_content'];  //内容
            $this->sendGameMessageAddTrumpet($sendGameMessage);
            $this->ajaxReturn(array('code' => 0));
        }
        $this->ajaxReturn(array('code' => 1, 'message' => '添加失败'));
    }

    //跑马灯编辑
    public function editSystemPaoMaDeng()
    {
        $id = I('get.id/d');
        $channel_rows = M('bk_channel')->select();
        $channel_ids = array();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
            $channel_ids[] = $val['bk_channelid'];
        }
        $this->assign("channel_list", $channel_list);
        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk_list[$val['bk_apkid']] = $val['bk_apk'];
            $apk_ids[] = $val['bk_apkid'];
        }
        $this->assign("apk_list", $apk_list);

        $row = M("bk_systempaomadeng")->where(array('bk_ID' => $id))->find();
        $data['id'] = $row['bk_id'];
        $data['OnlineTime'] = date("Y-m-d H:i:s", $row['bk_onlinetime']);
        $data['OfflineTime'] = date("Y-m-d H:i:s", $row['bk_offlinetime']);
        $data['time'] = strtotime("Y-m-d H:i:s", $row['bk_time']);
        $data['operator'] = $row['bk_operator'];
        $data['title'] = $row["bk_title"];
        $data['youxianji'] = $row["bk_youxianji"];
        $data['Type'] = $row["bk_bobaotype"];
        $data['BoBaoJianGe'] = $row["bk_bobaojiange"];
        $data['content'] = $row["bk_content"];
        $data['operatetype'] = $row["bk_operatetype"];
        $data['channelid'] = ($row["bk_channelid"] == "all") ? $channel_ids : explode(',', $row["bk_channelid"]);
        $data['channelAll'] = (trim($row["bk_channelid"]) == "all") ? 1 : 0;
        $data['apkid'] = ($row["bk_apkid"] == "all") ? $apk_ids : explode(',', $row["bk_apkid"]);
        $data['apkAll'] = (trim($row["bk_apkid"]) == "all") ? 1 : 0;
        $this->assign("row", $data);
        $this->show();
    }

    //跑马灯更新
    public function updateSystemPaoMaDeng()
    {
        $id = I('post.id/d');
        $onlineTime = strtotime(I("post.onlineTime"));
        if ($onlineTime < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 开始时间不正确 '));
        }

        $offlineTime = strtotime(I("post.offlineTime"));
        if ($offlineTime < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 结束时间不正确 '));
        }

        if ($onlineTime > $offlineTime) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 上架时间必须小于下架时间 '));
        }

        $type = I("post.type/d");
        if (!in_array($type, array(1, 2, 3))) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 参数错误 '));
        }

        $YouXianJi = I('post.YouXianJi/d');
        if (!($YouXianJi > 100 && $YouXianJi < 255)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '优先级设置范围 101－255 '));
        }

        $title = I('post.title');
        if (empty($title)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '标题不能为空'));
        }

        $content = I('post.content');
        if (empty($content)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '内容不能为空'));
        }
        $channelAll = I('post.channelall');
        if ($channelAll == "all") {
            $channel = "all";
        } else {
            $channel = I('post.channel');
            if (count($channel) == 0 || !is_array($channel)) {
                $this->ajaxReturn(array('code' => 1, 'message' => '渠道没有选择'));
            }
            $channel = implode(',', $channel);
        }

        $apkAll = I('post.apkall');
        if ($apkAll == "all") {
            $apkId = "all";
        } else {
            $apk = I('post.apk');
            if (count($apk) == 0 || !is_array($apk)) {
                $this->ajaxReturn(array('code' => 1, 'message' => 'APK包没有选择'));
            }
            $apkId = implode(',', $apk);
        }

        $boBaoJianGe = I('post.boBaoJianGe/d');
        if (!($boBaoJianGe > 0 && $boBaoJianGe < 10000)) {
            $this->ajaxReturn(array('code' => 1, 'message' => '间隔秒数：1 - 9999'));
        }

        $yid = M('bk_systempaomadeng')->where(array("bk_ID" => $id))->data(array(
            'bk_YouXianJi' => $YouXianJi,
            'bk_Title' => $title,
            'bk_OnlineTime' => $onlineTime,
            'bk_OfflineTime' => $offlineTime,
            'bk_BoBaoType' => $type,
            'bk_ChannelID' => $channel,
            'bk_APKID' => $apkId,
            'bk_Content' => $content,
            'bk_OperateType' => 0,
            'bk_Time' => time(),
            'bk_BoBaoJianGe' => $boBaoJianGe,
            'bk_Operator' => $this->login_admin_info['bk_name']
        ))->save();

        if ($yid > 0) {
            $data = M('bk_systempaomadeng')->where(['bk_ID' => $id])->find();
            $sendGameMessage['id'] = $data['bk_id'];  //小喇叭ID
            $sendGameMessage['YouXianJi'] = $data['bk_youxianji']; //权重
            $sendGameMessage['OnlineTime'] = $data['bk_onlinetime']; //开始时间
            $sendGameMessage['OfflineTime'] = $data['bk_offlinetime']; //结束时间
            $sendGameMessage['BoBaoJianGe'] = $data['bk_bobaojiange']; //间隔时间  bk_ChannelID
            $sendGameMessage['ChannelID'] = $data['bk_channelid']; //渠道
            $sendGameMessage['Content'] = $data['bk_content'];
            $this->sendGameMessageUpdateTrumpet($sendGameMessage);
            $this->ajaxReturn(array('code' => 0));
        }
        $this->ajaxReturn(array('code' => 1, 'message' => '更新失败'));
    }

    //删除跑马灯
    public function delSystemPaoMaDeng()
    {
        $id = I('post.id/d');
        M('bk_systempaomadeng')->where(array("bk_ID" => $id))->delete();
        $sendGameMessage['id'] = $id;
        $this->sendGameMessageDelTrumpet($sendGameMessage);
        $this->ajaxReturn(array("code" => 0));
    }

    //跑马灯暂停
    public function stopSystemPaoMaDeng()
    {
        $id = I('post.id/d');
        $isStop = I('post.isStop/d');

        if ($id == 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        if (!in_array($isStop, array(0, 1))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        $id = M("bk_systempaomadeng")->where(array("bk_ID" => $id))->data(array('bk_IsStop' => $isStop))->save();
        if ($id > 0) {
            $this->ajaxReturn(array('code' => 0));
        }
        $this->ajaxReturn(array('code' => 1, 'message' => '更新失败'));
    }

    // 邮件配置列表
    public function emailList()
    {

        $emailType = C("emailType");
        $props = C("props");

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $data['page'] = I('get.page/d');
        $data['count'] = M("bk_email")->count();

        $order = "bk_id desc";
        $rows = M("bk_email")->page(I('get.page/d'))->limit(I('get.limit/d'))->order($order)->select();
        $number = 1;    // 编号
        foreach ($rows as $key => $row) {
            $row_data['number'] = $number++;
            $row_data['id'] = $row['bk_id'];
            $row_data['type'] = $row['bk_type'];
            $channel = function () use ($row) {
                $channel_rows = M('bk_channel')->select();
                foreach ($channel_rows as $key => $val) {
                    $channel_list[$val['bk_channelid']] = $val['bk_channel'];
                }
                if ($row['bk_channelid'] == "all") {
                    return implode(',', $channel_list);
                } elseif ($row['bk_channelid'] != "") {
                    $carr = explode(',', $row['bk_channelid']);
                    foreach ($carr as $key => $val) {
                        isset($channel_list[$val]) && ($carr[$key] = $channel_list[$val]);
                    }
                    return $carr;
                }
            };
            $row_data['channel'] = $channel();
            $row_data['accountID'] = $row['bk_accountid'];
            $row_data['type'] = $emailType[$row['bk_type']];
            $row_data['title'] = $row['bk_title'];
            $row_data['content'] = $row['bk_content'];
            $row_data['sendGold'] = intval($row['bk_sendgold']) == 0 ? '无' : intval($row['bk_sendgold']);
            $row_data['propsType'] = $props[$row['bk_propstype']];
            $row_data['sendTime'] = date('Y-m-d H:i:s', $row['bk_sendtime']);
            $row_data['effectiveTime'] = date('Y-m-d H:i:s', $row['bk_effectivetime']);
            $row_data['operateTime'] = date("Y-m-d H:i:s", $row['bk_operatetime']);
            $row_data['operator'] = $row['bk_operator'];
            $row_data['editUrl'] = U('FreezeManagement/editEmail', array('id' => $row_data['id']));
            $data['data'][] = $row_data;
        }
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    // 邮件添加
    public function addEmail()
    {
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
        }
        $this->assign("channel_list", $channel_list);
        $this->show();
    }

    // 邮件添加
    public function doAddEmail()
    {
        $data['bk_Type'] = I('post.type/d');
        if ($data['bk_Type'] != 1) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        $channelAll = I('post.channelall');
        if ($channelAll == "all") {
            $data['bk_ChannelID'] = "all";
        } else {
            $channel = I('post.channel');
            if (count($channel) == 0 || !is_array($channel)) {
                $this->ajaxReturn(array('code' => 1, 'message' => '渠道没有选择'));
            }
            $data['bk_ChannelID'] = implode(',', $channel);
        }

        $accountids = I('post.accountids');
        if (trim($accountids) == '') {
            $data['bk_AccountID'] = "all";
        } else {
            $accountids = explode(",", $accountids);
            $data['bk_AccountID'] = implode(",", $accountids);
        }

        $data['bk_Title'] = I('post.title');
        if (empty($data['bk_Title'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '标题不能为空'));
        }

        $data['bk_Content'] = I('post.content');
        if (empty($data['bk_Content'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '内容不能为空'));
        }
        $data['bk_SendTime'] = strtotime(I('post.sendTime'));
        if ($data['bk_SendTime'] < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 开始时间不正确 '));
        }

        $data['bk_EffectiveTime'] = strtotime(I('post.effectiveTime'));
        if ($data['bk_EffectiveTime'] < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 开始时间不正确 '));
        }
        $data['bk_PropsType'] = I('post.propsType/d');
        if ($data['bk_PropsType'] != 1) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 参数错误 '));
        }

        if (I('post.sendGold') < 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '道具不能为负数 '));
        }

        $data['bk_SendGold'] = I('post.sendGold/d');

        $data['bk_Operator'] = $this->login_admin_info['bk_name'];
        $data['bk_OperateTime'] = time();
        $id = M('bk_email')->data($data)->add();
        if ($id > 0) {
            $sendData['type'] = $data['bk_Type'];    // 邮件类型
            $sendData['channelID'] = $data['bk_ChannelID'];  // 渠道ID
            $sendData['accountID'] = $data['bk_AccountID'];   // 收件人ID
            $sendData['title'] = $data['bk_Title'];  // 标题
            $sendData['content'] = $data['bk_Content'];  // 内容
            $sendData['sendTime'] = $data['bk_SendTime'];    // 发送时间
            $sendData['effectiveTime'] = $data['bk_EffectiveTime'];  // 失效时间
            $sendData['sendGold'] = $data['bk_SendGold']; // 发送金币
            $this->sendGameMessageAddEmail($sendData);
            $this->ajaxReturn(array('code' => 0));
        }
        $this->ajaxReturn(array('code' => 1, 'message' => '添加失败'));
    }

    // 邮件编辑
    public function editEmail()
    {

        $id = I('get.id/d');
        $channel_rows = M('bk_channel')->select();
        foreach ($channel_rows as $key => $val) {
            $channel_list[$val['bk_channelid']] = $val['bk_channel'];
            $channel_ids[] = $val['bk_channelid'];
        }
        $this->assign("channel_list", $channel_list);
        $row = M('bk_email')->where(array("bk_ID" => $id))->find();
        $row['channelid'] = ($row["bk_channelid"] == "all") ? $channel_ids : explode(',', $row["bk_channelid"]);
        $row['channelAll'] = (trim($row["bk_channelid"]) == "all") ? 1 : 0;
        $row['bk_SendTime'] = date('Y-m-d H:i:s', $row['bk_sendtime']);
        $row['bk_EffectiveTime'] = date('Y-m-d H:i:s', $row['bk_effectivetime']);
        $this->assign("row", $row);
        $this->show();
    }

    // 邮件更新
    public function doEditEmail()
    {

        $where['bk_ID'] = I('post.id/d');
        $data['bk_Type'] = I('post.type/d');
        if ($data['bk_Type'] != 1) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        $channelAll = I('post.channelall');
        if ($channelAll == "all") {
            $data['bk_ChannelID'] = "all";
        } else {
            $channel = I('post.channel');
            if (count($channel) == 0 || !is_array($channel)) {
                $this->ajaxReturn(array('code' => 1, 'message' => '渠道没有选择'));
            }
            $data['bk_ChannelID'] = implode(',', $channel);
        }
        $accountids = I('post.accountids');
        if (empty($accountids)) {
            $data['bk_AccountID'] == "all";
        } else {
            $accountids = explode(",", $accountids);
            $data['bk_AccountID'] = implode(",", $accountids);
        }
        $data['bk_Title'] = I('post.title');
        if (empty($data['bk_Title'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '标题不能为空'));
        }
        $data['bk_Content'] = I('post.content');
        if (empty($data['bk_Content'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '内容不能为空'));
        }
        $data['bk_SendTime'] = strtotime(I('post.sendTime'));
        if ($data['bk_SendTime'] < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 开始时间不正确 '));
        }
        $data['bk_EffectiveTime'] = strtotime(I('post.effectiveTime'));
        if ($data['bk_EffectiveTime'] < 1000000) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 开始时间不正确 '));
        }
        $data['bk_PropsType'] = I('post.propsType/d');
        if ($data['bk_PropsType'] != 1) {
            $this->ajaxReturn(array('code' => 1, 'message' => ' 参数错误 '));
        }
        $data['bk_SendGold'] = I('post.sendGold/d');
        $id = M('bk_email')->where($where)->data($data)->save();
        if (intval($id) > 0) {
            $this->ajaxReturn(array('code' => 0));
        }
        $this->ajaxReturn(array('code' => 1, 'message' => '更新失败'));
    }

    // 邮件删除
    public function delEmail()
    {
        $id = I('post.id/d');
        M('bk_email')->where(array("bk_ID" => $id))->delete();
        $this->ajaxReturn(array("code" => 0));
    }

    //客服聊天
    public function kehuChat()
    {
        $consultation = C('consultation');
        $where = array();
        if (!IS_AJAX) {
            $this->assign('adminid', $this->login_admin_info['bk_name']);
            $this->assign('consultation', $consultation);
            $this->show();
            return;
        }

        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $row) {
            $apk_list[$row['bk_apkid']] = $row['bk_apk'];
        }

        $accountid = I('get.accountid/d');
        if ($accountid > 0) {
            $where['bk_AccountID'] = $accountid;
        }

        $consult_type = I('get.consultation/d');
        if ($consult_type > 0) {
            $where['bk_ConsultType'] = $consult_type;
        }

        $vip = I('get.vip/d');
        if ($vip > 0) {
            $where['gd_VIPLv'] = $vip;
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
            $where['bk_Time'] = array('between', array($start_time, $end_time));
        }
        if (in_array(I('get.state'), ['0', '1'])) {
            $where['bk_State'] = I('get.state');
        }

        $rows = M('bk_kefu')->field('a.*, b.gd_VIPLv,b.gd_HeadID ')->alias('a')->join('LEFT JOIN  __ACCOUNTV__ b on a.bk_accountid = b.gd_AccountID')->where($where)->group("bk_AccountID")->page(I('get.page/d'))->limit(I('get.limit/d'))->order('bk_State desc, bk_time desc')->select();
        $subquery = M('bk_kefu')->where($where)->group("bk_AccountID")->buildSql();
        $data['count'] = M('bk_kefu')->table($subquery . ' a')->count();
        foreach ($rows as $key => $row) {
            $row_data['id'] = $row['bk_id'];
            $row_data['accountid'] = $row['bk_accountid'];
            $row_data['name'] = $row['bk_name'];
            $row_data['consultType'] = $consultation[$row['bk_consulttype']];  //咨询类型
            $row_data['content'] = M('bk_kefu')->where(['bk_AccountID' => $row['bk_accountid']])->order('bk_State asc')->limit(1)->getField("bk_content");  //咨询内容
            $row_data['apk'] = $apk_list[$row['bk_apkid']];
            $state = function () use ($row) {
                if ($row['bk_state'] == 0) {
                    return '已回复';
                } elseif ($row['bk_state'] == 1) {
                    return '未回复';
                } elseif ($row['bk_state'] == 2) {
                    return '已关闭';
                } else {
                    return '未知';
                }
            };
            $row_data['bk_State'] = $state();  //状态
            $row_data['bk_ParentID'] = 0;
            $row_data['VIP'] = $row['gd_viplv'];
            $row_data['time'] = date('Y-m-d H:i:s', $row['bk_time']);
            $row_data['closetime'] = date('Y-m-d H:i:s', $row['bk_closetime']);
            $row_data['Operator'] = M('bk_kefu')->where(['bk_AccountID' => $row['bk_accountid']])->order('bk_ID desc')->limit(1)->getField('bk_kefuaccount');
            $row_data['State'] = ($row_data['Operator'] == '0') ? "未回复" : '已回复';
            M('bk_kefu')->where(['bk_AccountID' => $row['bk_accountid']])->save(['bk_State' => $row_data['Operator'] == '0' ? 1 : 0]);
            $row_data['Operator'] = ($row_data['Operator'] == '0') ? "未回复" : $row_data['Operator'];
            $row_data['chatUrl'] = U('FreezeManagement/chat', ["mid" => $row['bk_id']]);
            $row_data['faceid'] = $row['gd_headid'];
            $row_data['vipLv'] = $row['bk_viplv'];
            $row_data['chatConsultTypeUrl'] = U("FreezeManagement/chatConsultType", ['id' => $row['bk_id']]);
            $data['data'][] = $row_data;
        }

        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        $this->ajaxReturn($data);
    }

    //对话聊天
    public function chat()
    {
        $id = I('get.id/d');
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $where['bk_AccountID'] = $id;

        $data['count'] = M("bk_kefu")->where($where)->count();
        if (I('get.last/d') == 1) {
            $data['page'] = ($data['count'] % 10) ? ($data['count'] / 10) + 1 : ($data['count'] / 10);
            $this->ajaxReturn($data);
        }

        $rows = M("bk_kefu")->where($where)->order("bk_Time asc")->page(I('get.page/d'))->limit(I('get.limit/d'))->select();

        $data['page'] = I('get.page/d');
        foreach ($rows as $key => $row) {
            $row_data['username'] = $row['bk_name'];
            $row_data['id'] = $row['bk_accountid'];
            $face = function () use ($row) {
                return M('bk_accountv')->where(array("gd_AccountID" => $row['bk_accountid']))->getField('gd_HeadID');
            };
            $row_data['avatar'] = "/Public/static/face/sprite_RoleIcon_{$face()}.png";
            $row_data['timestamp'] = $row['bk_time'] * 1000;
            $row_data['content'] = $row['bk_content'];
            $row_data['mine'] = intval($row['bk_sender']) == 2 ? true : false;
            $data['data'][] = $row_data;
        }
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //发送消息
    public function sendChatMessage()
    {
        $toid = I("post.toid/d");
        $bk_ID = M('bk_kefu')->where(['bk_AccountID' => $toid])->order('bk_ID desc')->limit(1)->getField('bk_ID');
        M('bk_kefu')->where(['bk_ID' => $bk_ID])->save(['bk_State' => 0]);
        $content = I('post.content');
        $send_admin = $this->login_admin_info['bk_name'];
        $toid = pack("L", $toid);
        $send_admin_len = pack("S", strlen($send_admin));
        $content_len = pack("S", strlen($content));
        $body = $toid . $send_admin_len . $send_admin . $content_len . $content;
        $socket_result = SendToGame(C('SOCKET_IP'), 30000, 1009, $body);
        $this->ajaxReturn($_POST);
    }

    //游戏咨询更新
    public function chatConsultType()
    {
        $consultation = C('consultation');
        $this->assign('consultation', $consultation);
        $this->show();
    }

    //游戏咨询更新
    public function doChatConsultType()
    {
        $id = I('post.id/d');
        $consultation = I('post.consultation/d');
        M('bk_kefu')->where(['bk_ID' => $id])->save(['bk_ConsultType' => $consultation]);
        $this->ajaxReturn(['code' => 0]);
    }

    // 更新消息为已读
    public function updateMessageRead()
    {
        $id = I('post.id/d');
        M('bk_kefu')->where(array('bk_ID' => $id))->save(array("bk_IsRead" => 0));
        $this->ajaxReturn(['code' => 0]);
    }

    //取新消息
    public function getChatMessage()
    {
        $where['bk_IsRead'] = 1;
        $data = array();
        $data['data'] = array();
        $rows = M('bk_kefu')->where($where)->order("bk_Time desc")->select();
        foreach ($rows as $key => $row) {
            $row_data['did'] = $row['bk_id'];
            $row_data['username'] = $row['bk_name'];
            $face = function () use ($row) {
                return M('bk_accountv')->where(array("gd_AccountID" => $row['bk_accountid']))->getField('gd_HeadID');
            };

            $row_data['id'] = $row['bk_accountid'];
            $row_data['fromid'] = $row['fromid'];
            $row_data['avatar'] = "/Public/static/face/sprite_RoleIcon_{$face()}.png";
            $row_data['type'] = 'friend';
            $row_data['content'] = $row['bk_content'];
            $row_data['mine'] = intval($row['bk_sender']) == 2 ? true : false;
            $row_data['timestamp'] = $row['bk_time'] * 1000;
            $data['data'][] = $row_data;
        }
        $this->ajaxReturn($data);
    }

    //用户资料
    public function userData()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX) {
            $this->assign('account', I('get.account/d'));
            $this->show();
            return;
        }

        if (I('get.account/d') <= 0 && I('get.nickname') == "" && I('get.name') == ""
            && I('get.phone') == "" && I('get.bankcard') == "" && I('get.alipay') == "") {
            $this->ajaxReturn(['code' => 0]);
        }

        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['bk_Nickname'] = array('like', '%' . I('get.nickname') . '%');
        }

        if (I('get.name') != "") {
            $where_data['bk_Name'] = I('get.name');
        }

        if (I('get.phone') != "") {
            $where_data['bk_phone'] = I('get.phone');
        }

        if (I('get.bankcard') != "") {
            $where_data['bk_Bankcard'] = I('get.bankcard');
        }

        if (I('get.alipay') != "") {
            $where_data['bk_Alipay'] = I('get.alipay');
        }

        $layui_data['count'] = M('bk_playerdata')->where($where_data)->count();
        $order = "bk_AccountID desc";
        $data_list = M('bk_playerdata')->where($where_data)->order($order)->page(I('page/d'))->limit(I('limit/d'))->select();
        $layui_data['sql'] = M('bk_playerdata')->getLastSql();

        foreach ($data_list as $key => $val) {
            $data['account'] = $val['bk_accountid'];
            $data['nickname'] = $val['bk_nickname'];
            $data['phone'] = ($val['bk_phone'] == 0 ? '未绑定' : $val['bk_phone']);
            $data['bankname'] = ($val['bk_bankname'] == '0' ? '' : $val['bk_bankname']);
            $data['bankcard'] = ($val['bk_bankcard'] == 0 ? '' : $val['bk_bankcard']);
            $data['name'] = ($val['bk_name'] == '0' ? '' : $val['bk_name']);
            $data['province'] = ($val['bk_bankprovince'] == '0' ? '' : $val['bk_bankprovince']);
            $data['city'] = ($val['bk_bankcity'] == '0' ? '' : $val['bk_bankcity']);
            $data['subbranch'] = ($val['bk_banksubbranch'] == '0' ? '' : $val['bk_banksubbranch']);
            $data['alipay'] = ($val['bk_alipay'] == '0' ? '' : $val['bk_alipay']);
            $data['alipayName'] = ($val['bk_alipayname'] == '0' ? '' : $val['bk_alipayname']);
            $data['record'] = $val['bk_record'];
            $data['pasteUrl'] = U("freezeManagement/pasteUserData", array('id' => $val['bk_id']));
            $layui_data['data'][] = $data;
        }
        $layui_data['page'] = I('get.page/d');
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //用户数据粘贴板功能
    public function pasteUserData()
    {

        $id = I("get.id/d");
        $row = M('bk_playerdata')->where(array('bk_ID' => $id))->find();
        $row['bk_phone'] = $row['bk_phone'] == 0 ? '' : $row['bk_phone'];
        $row['bk_bankname'] = $row['bk_bankname'] == '0' ? '' : $row['bk_bankname'];
        $row['bk_bankcard'] = $row['bk_bankcard'] == '0' ? '' : $row['bk_bankcard'];
        $row['bk_name'] = $row['bk_name'] == '0' ? '' : $row['bk_name'];
        $row['bk_bankprovince'] = $row['bk_bankprovince'] == '0' ? '' : $row['bk_bankprovince'];
        $row['bk_bankcity'] = $row['bk_bankcity'] == '0' ? '' : $row['bk_bankcity'];
        $row['bk_banksubbranch'] = $row['bk_banksubbranch'] == '0' ? '' : $row['bk_banksubbranch'];
        $row['bk_alipayname'] = $row['bk_alipayname'] == '0' ? '' : $row['bk_alipayname'];
        $row['bk_alipay'] = $row['bk_alipay'] == '0' ? '' : $row['bk_alipay'];

        $this->assign('row', $row);
        $this->show();
    }

    //玩家电话号码解绑
    public function doUntiedPhone()
    {

        if (I('post.id/d') <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        $data['bk_phone'] = 0;
        $phone = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_phone');
        if ($phone == 0) {
            $this->ajaxReturn(array('code' => 1));
        }
        $record = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Record');
        $new_record = "电话号码解绑:" . $phone . "--->" . "解绑," . $this->login_admin_info['bk_name'] . "," . date('Y-m-d H:i:s', time());
        $data['bk_Record'] = ($record == NULL ? $new_record : $record . "; " . $new_record);
        $result = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->save($data);
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    //玩家电话号码更改
    public function doChangePhone()
    {

        if (I('post.id/d') <= 0 || I('post.editPhone/d') <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        $data['bk_phone'] = I('post.editPhone/d');
        $phone = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_phone');
        $record = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Record');
        $new_record = "电话号码更改:" . ($phone == 0 ? '未绑定' : $phone) . "--->" . $data['bk_phone'] . "," . $this->login_admin_info['bk_name'] . "," . date('Y-m-d H:i:s', time());
        $data['bk_Record'] = ($record == NULL ? $new_record : ($record . "; " . $new_record));
        $result = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->save($data);

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        //与服务器通信
        $cid = I('post.id/d');
        $tid = 1;
        $ttext = I('post.editPhone/d');

        $this->sendUserData($cid, $tid, $ttext);
        $this->ajaxReturn(array('code' => 0));
    }

    //更改银行名称
    public function doEditBankName()
    {

        if (I('post.id/d') <= 0 || I('post.editBankName') == "") {
            $this->ajaxReturn(array('code' => 1));
        }

        $data['bk_BankName'] = I('post.editBankName');
        $bankName = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_BankName');
        if ($bankName == '0' && $data['bk_BankName'] == '0') {
            $this->ajaxReturn(array('code' => 1));
        }
        $record = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Record');
        $new_record = "银行名称更改:" . ($bankName == '0' ? '未绑定' : $bankName) . "--->" . ($data['bk_BankName'] == '0' ? '未绑定' : $data['bk_BankName']) . "," . $this->login_admin_info['bk_name'] . "," . date('Y-m-d H:i:s', time());
        $data['bk_Record'] = ($record == NULL ? $new_record : ($record . "; " . $new_record));
        $result = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->save($data);

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        //与服务器通信
        $cid = I('post.id/d');
        $tid = 3;
        $ttext = I('post.editBankName');

        $this->sendUserData($cid, $tid, $ttext);
        $this->ajaxReturn(array('code' => 0));
    }

    //更改银行卡号
    public function doEditBankcard()
    {

        if (I('post.id/d') <= 0 || I('post.editBankcard') == '') {
            $this->ajaxReturn(array('code' => 1));
        }

        $data['bk_Bankcard'] = I('post.editBankcard');
        $bankCard = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Bankcard');
        if ($bankCard == '0' && $data['bk_Bankcard'] == '0') {
            $this->ajaxReturn(array('code' => 1));
        }
        $record = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Record');
        $new_record = "银行卡号更改:" . ($bankCard == 0 ? '未绑定' : $bankCard) . "--->" . ($data['bk_Bankcard'] == '0' ? '未绑定' : $data['bk_Bankcard']) . "," . $this->login_admin_info['bk_name'] . "," . date('Y-m-d H:i:s', time());
        $data['bk_Record'] = ($record == NULL ? $new_record : ($record . "; " . $new_record));
        $result = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->save($data);

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        //与服务器通信
        $cid = I('post.id/d');
        $tid = 4;
        $ttext = I('post.editBankcard');

        $this->sendUserData($cid, $tid, $ttext);
        $this->ajaxReturn(array('code' => 0));
    }

    //更改持卡人姓名
    public function doEditName()
    {

        if (I('post.id/d') <= 0 || I('post.editName') == "") {
            $this->ajaxReturn(array('code' => 1));
        }

        $data['bk_Name'] = I('post.editName');
        $name = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Name');
        if ($name == '0' && $data['bk_Name'] == '0') {
            $this->ajaxReturn(array('code' => 1));
        }
        $record = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Record');
        $new_record = "持卡人姓名更改:" . ($name == '0' ? '未绑定' : $name) . "--->" . ($data['bk_Name'] == '0' ? '未绑定' : $data['bk_Name']) . "," . $this->login_admin_info['bk_name'] . "," . date('Y-m-d H:i:s', time());
        $data['bk_Record'] = ($record == NULL ? $new_record : ($record . "; " . $new_record));
        $result = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->save($data);

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        //与服务器通信
        $cid = I('post.id/d');
        $tid = 2;
        $ttext = I('post.editName');

        $this->sendUserData($cid, $tid, $ttext);
        $this->ajaxReturn(array('code' => 0));
    }

    //更改开户省份
    public function doEditProvince()
    {

        if (I('post.id/d') <= 0 || I('post.editProvince') == "") {
            $this->ajaxReturn(array('code' => 1));
        }

        $data['bk_BankProvince'] = I('post.editProvince');
        $province = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_BankProvince');
        if ($province == '0' && $data['bk_BankProvince'] == '0') {
            $this->ajaxReturn(array('code' => 1));
        }
        $record = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Record');
        $new_record = "开户省份更改:" . ($province == '0' ? '未绑定' : $province) . "--->" . ($data['bk_BankProvince'] == '0' ? '未绑定' : $data['bk_BankProvince']) . "," . $this->login_admin_info['bk_name'] . "," . date('Y-m-d H:i:s', time());
        $data['bk_Record'] = ($record == NULL ? $new_record : ($record . "; " . $new_record));
        $result = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->save($data);

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        //与服务器通信
        $cid = I('post.id/d');
        $tid = 5;
        $ttext = I('post.editProvince');

        $this->sendUserData($cid, $tid, $ttext);
        $this->ajaxReturn(array('code' => 0));
    }

    //更改开户城市
    public function doEditCity()
    {

        if (I('post.id/d') <= 0 || I('post.editCity') == "") {
            $this->ajaxReturn(array('code' => 1));
        }

        $data['bk_BankCity'] = I('post.editCity');
        $city = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_BankCity');
        if ($city == '0' && $data['bk_BankCity'] == '0') {
            $this->ajaxReturn(array('code' => 1));
        }
        $record = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Record');
        $new_record = "开户城市更改:" . ($city == '0' ? '未绑定' : $city) . "--->" . ($data['bk_BankCity'] == '0' ? '未绑定' : $data['bk_BankCity']) . "," . $this->login_admin_info['bk_name'] . "," . date('Y-m-d H:i:s', time());
        $data['bk_Record'] = ($record == NULL ? $new_record : ($record . "; " . $new_record));
        $result = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->save($data);

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        //与服务器通信
        $cid = I('post.id/d');
        $tid = 6;
        $ttext = I('post.editCity');

        $this->sendUserData($cid, $tid, $ttext);
        $this->ajaxReturn(array('code' => 0));
    }

    //更改开户支行
    public function doEditSubbranch()
    {

        if (I('post.id/d') <= 0 || I('post.editSubbranch') == "") {
            $this->ajaxReturn(array('code' => 1));
        }

        $data['bk_BankSubbranch'] = I('post.editSubbranch');
        $subbranch = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_BankSubbranch');
        if ($subbranch == '0' && $data['bk_BankSubbranch'] == '0') {
            $this->ajaxReturn(array('code' => 1));
        }
        $record = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Record');
        $new_record = "开户支行更改:" . ($subbranch == '0' ? '未绑定' : $subbranch) . "--->" . ($data['bk_BankSubbranch'] == '0' ? '未绑定' : $data['bk_BankSubbranch']) . "," . $this->login_admin_info['bk_name'] . "," . date('Y-m-d H:i:s', time());
        $data['bk_Record'] = ($record == NULL ? $new_record : ($record . "; " . $new_record));
        $result = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->save($data);

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        //与服务器通信
        $cid = I('post.id/d');
        $tid = 7;
        $ttext = I('post.editSubbranch');

        $this->sendUserData($cid, $tid, $ttext);
        $this->ajaxReturn(array('code' => 0));
    }

    //更改支付宝账号
    public function doEditAlipay()
    {

        if (I('post.id/d') <= 0 || I('post.editAlipay') == "") {
            $this->ajaxReturn(array('code' => 1));
        }

        $data['bk_Alipay'] = I('post.editAlipay');
        $alipay = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Alipay');
        if ($alipay == '0' && $data['bk_Alipay'] == '0') {
            $this->ajaxReturn(array('code' => 1));
        }
        $record = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Record');
        $new_record = "支付宝账号更改:" . ($alipay == '0' ? '未绑定' : $alipay) . "--->" . ($data['bk_Alipay'] == '0' ? '未绑定' : $data['bk_Alipay']) . "," . $this->login_admin_info['bk_name'] . "," . date('Y-m-d H:i:s', time());
        $data['bk_Record'] = ($record == NULL ? $new_record : ($record . "; " . $new_record));
        $result = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->save($data);

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1));

        }

        //与服务器通信
        $cid = I('post.id/d');
        $tid = 9;
        $ttext = I('post.editAlipay');

        $this->sendUserData($cid, $tid, $ttext);
        $this->ajaxReturn(array('code' => 0));
    }

    //更改支付宝姓名
    public function doEditAlipayName()
    {

        if (I('post.id/d') <= 0 || I('post.editAlipayName') == "") {
            $this->ajaxReturn(array('code' => 1));
        }

        $data['bk_AlipayName'] = I('post.editAlipayName');
        $alipayName = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_AlipayName');
        if ($alipayName == '0' && $data['bk_AlipayName'] == '0') {
            $this->ajaxReturn(array('code' => 1));
        }
        $record = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->getField('bk_Record');
        $new_record = "支付宝姓名更改:" . ($alipayName == '0' ? '未绑定' : $alipayName) . "--->" . ($data['bk_AlipayName'] == '0' ? '未绑定' : $data['bk_AlipayName']) . "," . $this->login_admin_info['bk_name'] . "," . date('Y-m-d H:i:s', time());
        $data['bk_Record'] = ($record == NULL ? $new_record : ($record . "; " . $new_record));
        $result = M('bk_playerdata')->where(array('bk_AccountID' => I('post.id/d')))->save($data);

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }
        //与服务器通信
        $cid = I('post.id/d');
        $tid = 8;
        $ttext = I('post.editAlipayName');

        $this->sendUserData($cid, $tid, $ttext);
        $this->ajaxReturn(array('code' => 0));
    }

    //冻结手机号列表
    public function lockMobile()
    {


        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $where = [];
        if (I('get.Bankcard') != '') {
            $where['bk_Bankcard'] = I('get.Bankcard');
        }

        if (I('get.state/d') != 0) {
            $where['bk_State'] = I('get.state');
        }

        $rows = M('bk_freezingphone')->where($where)->page(I('get.page/d'))->limit(I('get.limit/d'))->order('bk_id desc')->select();
        $data['count'] = M('bk_freezingphone')->where($where)->count();
        foreach ($rows as $row) {
            $row_data['State_str'] = $row['bk_state'] == 1 ? '解冻' : '冻结';
            $row_data['State'] = $row['bk_state'];
            $row_data['Bankcard'] = $row['bk_bankcard'];
            $row_data['number'] = $row['bk_id'];
            $row_data['FreezeReason'] = $row['bk_freezereason'];
            $row_data['UnfreezeReason'] = $row['bk_unfreezereason'];
            $row_data['Operator'] = $row['bk_operator'];
            $row_data['Time'] = date('Y-m-d H:i:s', $row['bk_time']);
            $data['data'][] = $row_data;
        }
        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        $this->ajaxReturn($data);
    }

    //添加冻结手机号
    public function lockMobileAdd()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $data['bk_FreezeReason'] = I('post.FreezeReason');
        $data['bk_Operator'] = $this->login_admin_info['bk_name'];
        $data['bk_Time'] = time();
        $data['bk_State'] = 2;

        if (I('post.Bankcard') == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '手机号不能为空']);
        }
        $Bankcard = I('post.Bankcard');
        $Bankcard = explode(',', $Bankcard);
        $sendMessageData = [];
        foreach ($Bankcard as $row) {
            $data['bk_Bankcard'] = $row;
            if (M('bk_freezingphone')->where(['bk_Bankcard' => $row, 'bk_State' => 2])->count() == 0) {
                M('bk_freezingphone')->add($data);
                $sendMessageData[] = $data['bk_Bankcard'];
            }
        }

        $this->sendGameMessageLockMobileOrBankNumberOrAlipay([
            'type' => 1,
            'lockNum' => 2,
            'text' => implode(',', $sendMessageData)
        ]);
        $data['code'] = 0;

        $this->ajaxReturn(['code' => 0]);
    }

    //解冻手机号
    public function unLockMobile()
    {
        $Bankcard = I('post.Bankcard');
        $nuLock = I('post.nuLock/d');
        if (empty($Bankcard)) {
            $data['code'] = 1;
        }

        M('bk_freezingphone')->data(array(
            'bk_Bankcard' => $Bankcard,
            'bk_UnfreezeReason' => I('post.cause'),
            'bk_State' => 1,
            'bk_Operator' => $this->login_admin_info['bk_name'],
            'bk_Time' => time()
        ))->where(['bk_Bankcard' => $Bankcard])->save();
        $this->sendGameMessageLockMobileOrBankNumberOrAlipay([
            'type' => 1,
            'lockNum' => 1,
            'text' => $Bankcard
        ]);

        $this->ajaxReturn(['code' => 0]);
    }

    //冻结银行卡号
    public function lockBankNumber()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $where = [];
        if (I('get.Bankcard') != '') {
            $where['bk_Bankcard'] = I('get.Bankcard');
        }
        if (I('get.state/d') != 0) {
            $where['bk_State'] = I('get.state');
        }
        $rows = M('bk_freezingbankcard')->where($where)->page(I('get.page/d'))->limit(I('get.limit/d'))->order('bk_id desc')->select();
        $data['count'] = M('bk_freezingbankcard')->where($where)->count();
        foreach ($rows as $row) {
            $row_data['State_str'] = $row['bk_state'] == 1 ? '解冻' : '冻结';
            $row_data['state'] = $row['bk_state'];
            $row_data['Bankcard'] = $row['bk_bankcard'];
            $row_data['number'] = $row['bk_id'];
            $row_data['FreezeReason'] = $row['bk_freezereason'];
            $row_data['UnfreezeReason'] = $row['bk_unfreezereason'];
            $row_data['Operator'] = $row['bk_operator'];
            $row_data['Time'] = date('Y-m-d H:i:s', $row['bk_time']);

            $data['data'][] = $row_data;
        }
        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        $this->ajaxReturn($data);
    }

    //添加冻结的银行卡号
    public function lockBankNumberAdd()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $data['bk_FreezeReason'] = I('post.FreezeReason');
        $data['bk_Operator'] = $this->login_admin_info['bk_name'];
        $data['bk_Time'] = time();
        $data['bk_State'] = 2;

        if (I('post.Bankcard') == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '手机号不能为空']);
        }
        $Bankcard = I('post.Bankcard');
        $Bankcard = explode(',', $Bankcard);
        $sendMessageData = [];
        foreach ($Bankcard as $row) {
            $data['bk_Bankcard'] = $row;
            if (M('bk_freezingbankcard')->where(['bk_Bankcard' => $row, 'bk_State' => 2])->count() == 0) {
                M('bk_freezingbankcard')->add($data);
                $sendMessageData[] = $data['bk_Bankcard'];
            }
        }

        $this->sendGameMessageLockMobileOrBankNumberOrAlipay([
            'type' => 2,
            'lockNum' => 2,
            'text' => implode(',', $Bankcard)
        ]);

        $this->ajaxReturn(['code' => 0]);
    }

    //解冻冻结的银行卡号
    public function unBankNumber()
    {
        $Bankcard = I('post.Bankcard');
        $nuLock = I('post.nuLock/d');
        if (empty($Bankcard)) {
            $data['code'] = 1;
        }

        M('bk_freezingbankcard')->data(array(
            'bk_Bankcard' => $Bankcard,
            'bk_UnfreezeReason' => I('post.cause'),
            'bk_State' => 1,
            'bk_Operator' => $this->login_admin_info['bk_name'],
            'bk_Time' => time()
        ))->where(['bk_Bankcard' => $Bankcard])->save();

        //$this->sendGameMessage( $nuLock ,2, $deviceCode );
        $data['code'] = 0;
        $this->sendGameMessageLockMobileOrBankNumberOrAlipay([
            'type' => 2,
            'lockNum' => 1,
            'text' => $Bankcard
        ]);
        $this->ajaxReturn($data);
    }

    //冻结支付宝账号
    public function lockAlipay()
    {

        $where = array();

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        if (I('get.alipay') != '') {
            $where['bk_Alipay'] = I('get.alipay');
        }

        if (I('get.state/d') > 0) {
            $where['bk_State'] = I('get.state');
        }

        $data['count'] = M('bk_freezingalipay')->where($where)->count();
        $order = 'bk_Time desc';
        $rows = M('bk_freezingalipay')->where($where)->page(I('get.page/d'))->limit(I('get.limit/d'))->order($order)->select();

        $number = 1;
        foreach ($rows as $row) {
            $row_data['State_str'] = $row['bk_state'] == 1 ? '解冻' : '冻结';
            $row_data['state'] = $row['bk_state'];
            $row_data['alipay'] = $row['bk_alipay'];
            $row_data['number'] = $number;
            $row_data['FreezeReason'] = $row['bk_freezereason'];
            $row_data['UnfreezeReason'] = $row['bk_unfreezereason'] == '0' ? '' : $row['bk_unfreezereason'];
            $row_data['Operator'] = $row['bk_operator'];
            $row_data['Time'] = date('Y-m-d H:i:s', $row['bk_time']);
            $data['data'][] = $row_data;

            $number++;
        }
        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        $this->ajaxReturn($data);
    }

    //添加冻结的支付宝账号
    public function lockAlipayAdd()
    {

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $data['bk_FreezeReason'] = I('post.FreezeReason');
        $data['bk_Operator'] = $this->login_admin_info['bk_name'];
        $data['bk_Time'] = time();
        $data['bk_State'] = 2;

        if (I('post.alipay') == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '支付宝账号不能为空']);
        }
        $alipay = I('post.alipay');
        $alipay = explode(',', $alipay);
        $sendMessageData = [];
        foreach ($alipay as $row) {
            $data['bk_Alipay'] = $row;
            if (M('bk_freezingalipay')->where(['bk_Alipay' => $row, 'bk_State' => 2])->count() == 0) {
                M('bk_freezingalipay')->add($data);
                $sendMessageData[] = $data['bk_Alipay'];
            }
        }

        //服务器通信
        $this->sendGameMessageLockMobileOrBankNumberOrAlipay([
            'type' => 3,
            'lockNum' => 2,
            'text' => implode(',', $alipay)
        ]);

        $this->ajaxReturn(['code' => 0]);
    }

    //解冻被冻结的支付宝账号
    public function unAlipay()
    {

        $alipay = I('post.alipay');
        $nuLock = I('post.nuLock/d');
        if (empty($alipay)) {
            $data['code'] = 1;
        }

        M('bk_freezingalipay')->data(array(
            'bk_Alipay' => $alipay,
            'bk_UnfreezeReason' => I('post.cause'),
            'bk_State' => 1,
            'bk_Operator' => $this->login_admin_info['bk_name'],
            'bk_Time' => time()
        ))->where(['bk_Alipay' => $alipay])->save();

        //$this->sendGameMessage( $nuLock ,2, $deviceCode );
        $data['code'] = 0;

        //服务器通信
        $this->sendGameMessageLockMobileOrBankNumberOrAlipay([
            'type' => 3,
            'lockNum' => 1,
            'text' => $alipay
        ]);
        $this->ajaxReturn($data);
    }

    // 取会员信息
    public function getSendMessageAccount()
    {
        $Account = $this->getAccountUser(I('post.Accountid/d'));
        $data['name'] = $Account['gd_name'];
        $data['accountid'] = $Account['gd_accountid'];
        $data['headid'] = $Account['gd_headid'];
        $this->ajaxReturn(['code' => 0, 'data' => $data]);
    }

    //官网扫码申请
    public function qrOrderApply()
    {
        $qrPayList = C('qrPayList');
        if (!IS_AJAX) {
            $this->assign('qrPayList', $qrPayList);
            $this->show();
            return;
        }

        if (I('get.AccountID/d') > 0) {
            $where['bk_AccountID'] = I('get.AccountID/d');
        }

        if (I('get.PayAmount') != '') {
            $PayAmount = I('get.PayAmount');
            $PayAmount = explode(',', $PayAmount);
            $where['bk_PayAmount'] = ['between', [$PayAmount[0], $PayAmount[1]]];
        }

        if (I('get.Name') != '') {
            $where['bk_Name'] = ['LIKE', '%' . I('get.Name') . '%'];
        }

        if (I('get.Type/d') != 0) {
            $where['bk_Type'] = I('get.Type/d');
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
            $where['bk_CreateTime'] = array('between', array($start_time, $end_time));
        }
        $where['bk_ReceiveAccount'] = 0;
        $rows = M('bk_qrcode_channel')->where(['bk_Pay_Status' => 1])->select();
        foreach ($rows as $row) {
            $payTypeRow[$row['bk_id']] = $row;
        }

        $rows = M('bk_gfsmorder')->where($where)->order('bk_CreateTime desc')->select();
        $data['count'] = M('bk_gfsmorder')->where($where)->count();
        $data['page'] = I('get.page/d');

        foreach ($rows as $row) {
            $d['ReceiveAccount'] = $row['bk_receiveaccount'];  //时间
            $d['CreateTime'] = date('Y-m-d H:i:s', $row['bk_createtime']);  //时间
            $d['MerchantOrder'] = $row['bk_merchantorder'];  //订单号
            $d['AccountID'] = $row['bk_accountid'];  //玩家ID
            $d['Name'] = $row['bk_name'];  //玩家昵称
            $d['PayAmount'] = $row['bk_payamount'];  //充值金额
            //$d[''] = $row[''];  //活动优惠
            $d['RealAmount'] = $row['bk_realamount'];  //实际发放金额
            $d['Type'] = $qrPayList[$row['bk_type']];  //充值方式
            $d['Number'] = $payTypeRow[$row['bk_urlid']]['bk_number'];  //收款账号
            $d['Bank_Name'] = $payTypeRow[$row['bk_urlid']]['bk_bank_name'];  //收款开户行
            $d['User_Name'] = $payTypeRow[$row['bk_urlid']]['bk_user_name'];  //持卡人姓名
            $data['data'][] = $d;
        }

        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //领取扫码订单
    public function getQrOrder()
    {
        $where['bk_MerchantOrder'] = I('post.MerchantOrder');
        if ($where['bk_MerchantOrder'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '参数非法']);
        }
        if (M('bk_gfsmorder')->where($where + ['bk_ReceiveAccount' => ['gt', 0]])->count() > 0) {
            $this->ajaxReturn(['code' => 2, 'message' => '此订单已被领取']);
        }
        M('bk_gfsmorder')->where($where)->save(['bk_ReceiveAccount' => $this->login_admin_info['bk_accountid']]);
        $this->ajaxReturn(['code' => 0]);
    }

    //扫码订单审核
    public function setQrOrderStatus()
    {

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $where['bk_MerchantOrder'] = I('post.MerchantOrder');
        if ($where['bk_MerchantOrder'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '参数非法']);
        }
        $data['bk_IsSuccess'] = I('post.IsSuccess/d');
        if (!in_array($data['bk_IsSuccess'], [1, 0])) {
            $this->ajaxReturn(['code' => 1, 'message' => '参数非法']);
        }

        if ($data['bk_IsSuccess'] == 1) {
            $RealAmount = I('post.RealAmount/d');
            if ($RealAmount > 200000) {
                $this->ajaxReturn(['code' => 1, 'message' => '最大冲值200000']);
            }
            $d['bk_MerchantOrder'] = $where['bk_MerchantOrder'];
            $d['bk_AccountID'] = I('post.AccountID/d');
            $d['bk_RealAmount'] = $RealAmount;
            $this->sendGameMessageQrRealAmount($d);
        } else {
            $data['bk_OperateTime'] = time();
        }
        M('bk_gfsmorder')->where($where)->save($data);
        $this->ajaxReturn(['code' => 0]);
    }

    //扫码订单审核
    public function qrOrderVerify()
    {
        $qrPayList = C('qrPayList');
        if (!IS_AJAX) {
            $this->assign('qrPayList', $qrPayList);
            $this->show();
            return;
        }

        if (I('get.AccountID/d') > 0) {
            $where['bk_AccountID'] = I('get.AccountID/d');
        }

        if (I('get.PayAmount') != '') {
            $PayAmount = I('get.PayAmount');
            $PayAmount = explode(',', $PayAmount);
            if (count($PayAmount) == 1) {
                $where['bk_PayAmount'] = $PayAmount[0];
            } else {
                $where['bk_PayAmount'] = ['between', [$PayAmount[0], $PayAmount[1]]];
            }
        }

        if (I('get.Name') != '') {
            $where['bk_Name'] = ['LIKE', '%' . I('get.Name') . '%'];
        }

        if (I('get.Type/d') != 0) {
            $where['bk_Type'] = I('get.Type/d');
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
            $where['bk_CreateTime'] = array('between', array($start_time, $end_time));
        }
        // $where['bk_ReceiveAccount'] = $this->login_admin_info['bk_accountid'];
        $where['bk_IsSuccess'] = 2;

        $rows = M('bk_qrcode_channel')->where(['bk_Pay_Status' => 1])->select();
        foreach ($rows as $row) {
            $payTypeRow[$row['bk_id']] = $row;
        }

        $rows = M('bk_gfsmorder')->where($where)->order('bk_CreateTime desc')->select();
        $data['sql'] = M('bk_gfsmorder')->getLastSql();
        $data['count'] = M('bk_gfsmorder')->where($where)->count();
        $data['page'] = I('get.page/d');

        foreach ($rows as $row) {
            $d['ReceiveAccount'] = $row['bk_receiveaccount'];  //时间
            $d['CreateTime'] = date('Y-m-d H:i:s', $row['bk_createtime']);  //时间
            $d['MerchantOrder'] = $row['bk_merchantorder'];  //订单号
            $d['AccountID'] = $row['bk_accountid'];  //玩家ID
            $d['Name'] = $row['bk_name'];  //玩家昵称
            $d['PayAmount'] = $row['bk_payamount'];  //充值金额
            //$d[''] = $row[''];  //活动优惠
            $d['RealAmount'] = $row['bk_realamount'];  //实际发放金额
            $d['Type'] = $qrPayList[$row['bk_type']];  //充值方式
            $Detail = explode(",", $payTypeRow[$row['bk_urlid']]['bk_detail']);
            if ($payTypeRow[$row['bk_urlid']]['bk_pay_id'] != 4) {
                $d['Bank_Name'] = $Detail[0]; //收款开户行
                $d['User_Name'] = $Detail[1]; //持卡人姓名
                $d['Number'] = $Detail[2];//收款账号
            } else {
                $d['Bank_Name'] = $Detail[0]; //收款开户行
                $d['User_Name'] = $Detail[2]; //持卡人姓名
                $d['Number'] = $Detail[3]; //收款账号
            }
//            $d['Number'] = $payTypeRow[$row['bk_urlid']]['bk_number'];  //收款账号
//            $d['Bank_Name'] = $payTypeRow[$row['bk_urlid']]['bk_bank_name'];  //收款开户行
//            $d['User_Name'] = $payTypeRow[$row['bk_urlid']]['bk_user_name'];  //持卡人姓名
            $d['Pay_name'] = $payTypeRow[$row['bk_urlid']]['bk_pay_name'];  //通道名称
            $d['IsFirst'] = ($row['bk_isfirst'] == 1) ? "是" : "否"; //是否首冲
            $d['IsSuccess'] = $row['bk_issuccess'];
            if ($row['bk_issuccess'] == 2) {
                $d['IsSuccessStr'] = '新订单';
            } elseif ($row['bk_issuccess'] == 0) {
                $d['IsSuccessStr'] = '失败';
            } elseif ($row['bk_issuccess'] == 1) {
                $d['IsSuccessStr'] = '发货成功';
            }
            $data['data'][] = $d;
        }
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //扫码订单查询
    public function qrOrderList()
    {
        $qrPayList = C('qrPayList');
        if (!IS_AJAX) {
            $this->assign('qrPayList', $qrPayList);
            $this->show();
            return;
        }

        if (in_array(I('get.IsSuccess/d'), [0, 1])) {
            $where['a.bk_IsSuccess'] = I('get.IsSuccess/d');
        }

        if (I('get.ReceiveAccount') != '') {
            $bk_AccountID = M('bk_account')->where(['bk_Name' => I('get.ReceiveAccount')])->getField('bk_AccountID');
            $where['a.bk_ReceiveAccount'] = intval($bk_AccountID);
        }

        if (I('get.AccountID/d') > 0) {
            $where['a.bk_AccountID'] = I('get.AccountID/d');
        }

        if (I('get.PayAmount') != '') {
            $PayAmount = I('get.PayAmount');
            $PayAmount = explode(',', $PayAmount);
            if (count($PayAmount) == 1) {
                $where['bk_PayAmount'] = $PayAmount[0];
            } else {
                $where['bk_PayAmount'] = ['between', [$PayAmount[0], $PayAmount[1]]];
            }
        }

        if (I('get.Name') != '') {
            $where['a.bk_Name'] = ['LIKE', '%' . I('get.Name') . '%'];
        }

        if (I('get.Type/d') != 0) {
            $where['a.bk_Type'] = I('get.Type/d');
        }
        $where['bk_IsSuccess'] = ['in', [0, 1]];
        $_where = $where;
        if (I('get.start_time') != '' || I('get.end_time') != '') {
            $start_time = strtotime(I('get.start_time'));
            $end_time = strtotime(I('get.end_time'));
            if (I('get.start_time') == '') {
                $start_time = 1;
            }
            if (I('get.end_time') == '') {
                $end_time = time();
            }
            $where['bk_CreateTime'] = $_where['bk_IsSuccess'] = array('between', array($start_time, $end_time));

        } else {
            $_where['bk_CreateTime'] = array('between', array(strtotime(date("Y-m-d")), time()));
        }


        $rows = M('bk_qrcode_channel')->where(['bk_Pay_Status' => 1])->select();
        foreach ($rows as $row) {
            $payTypeRow[$row['bk_id']] = $row;
        }

        $rows = M('bk_channel')->select();
        foreach ($rows as $row) {
            $channelList[$row['bk_channelid']] = $row['bk_channel'];
        }

        $rows = M('bk_gfsmorder')->field("a.*, b.bk_Name as aname")->alias('a')->join('LEFT JOIN __ACCOUNT__ b ON a.bk_ReceiveAccount = b.bk_AccountID')->where($where)->page(I('get.page/d'))->limit(I('get.limit/d'))->order('bk_CreateTime desc')->select();
        $data['RealAmount'] = M('bk_gfsmorder')->alias('a')->join('LEFT JOIN __ACCOUNT__ b ON a.bk_ReceiveAccount = b.bk_AccountID')->where($_where)->sum('bk_RealAmount') / 1;
        $data['count'] = M('bk_gfsmorder')->alias('a')->join('LEFT JOIN __ACCOUNT__ b ON a.bk_ReceiveAccount = b.bk_AccountID')->where($where)->count();
        $data['page'] = I('get.page/d');
        foreach ($rows as $row) {
            $d['ReceiveAccount'] = $row['bk_receiveaccount'];  //时间
            $d['CreateTime'] = date('Y-m-d H:i:s', $row['bk_createtime']);  //时间
            $d['MerchantOrder'] = $row['bk_merchantorder'];  //订单号
            $d['AccountID'] = $row['bk_accountid'];  //玩家ID
            $d['Name'] = $row['bk_name'];  //玩家昵称
            $d['PayAmount'] = $row['bk_payamount'];  //充值金额
            //$d[''] = $row[''];  //活动优惠
            $d['RealAmount'] = $row['bk_realamount'];  //实际发放金额
            $d['Type'] = $qrPayList[$row['bk_type']];  //充值方式
            $d['Number'] = $payTypeRow[$row['bk_urlid']]['bk_number'];  //收款账号
            $d['Bank_Name'] = $payTypeRow[$row['bk_urlid']]['bk_bank_name'];  //收款开户行
            $d['User_Name'] = $payTypeRow[$row['bk_urlid']]['bk_user_name'];  //持卡人姓名
            $d['IsSuccess'] = $row['bk_issuccess'];
            if ($row['bk_issuccess'] == 2) {
                $d['IsSuccessStr'] = '新订单';
            } elseif ($row['bk_issuccess'] == 0) {
                $d['IsSuccessStr'] = '已拒绝';
            } elseif ($row['bk_issuccess'] == 1) {
                $d['IsSuccessStr'] = '发货成功';
            }

            $d['IsFirst'] = $row['bk_isfirst'] ? '是' : '否';
            $d['OperateTime'] = date('Y-m-d H:i:s', $row['bk_operatetime']);
            $d['ReceiveAccount'] = $row['aname'];
            $d['ChannelID'] = $channelList[$row['bk_channelid']];
            $data['data'][] = $d;
        }
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //根据会员ID 取会员信息
    public function getAccountUser($uid)
    {
        $accountv = M('bk_accountv')->where([
            'gd_AccountID' => $uid
        ])->find();
        return $accountv;
    }

    //常见问题管理
    public function questionAnswer()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $rows = M('bk_question_answer')->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        $data['count'] = M('bk_question_answer')->count();
        foreach ($rows as $row) {
            $row_data['id'] = $row['bk_id'];
            $row_data['question'] = $row['question'];
            $row_data['answer'] = $row['answer'];
            $row_data['editUrl'] = U('FreezeManagement/questionAnswerEdit', ['id' => $row['bk_id']]);
            $data['data'][] = $row_data;
        }
        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        $this->ajaxReturn($data);
    }

    //添加问答
    public function questionAnswerAdd()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $data['question'] = I('post.question');
        if ($data['question'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '问题不能为空']);
        }

        if (strlen($data['question']) > 60) {
            $this->ajaxReturn(['code' => 1, 'message' => '问题最多20个汉字']);
        }

        $data['answer'] = I('post.answer');
        if ($data['answer'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '回答不能为空']);
        }

        if (strlen($data['answer']) > 150) {
            $this->ajaxReturn(['code' => 1, 'message' => '回答最多50个汉字']);
        }
        $id = M('bk_question_answer')->add($data);
        $data['bk_id'] = $id;
        $this->sendGameMessageQuestionAnswerAdd($data, 1040);
        $this->ajaxReturn(['code' => 0]);
    }

    //编辑问答
    public function questionAnswerEdit()
    {
        if (!IS_AJAX) {
            $question_answer = M('bk_question_answer')->where(['bk_id' => I('get.id/d')])->find();
            $this->assign('data', $question_answer);
            $this->show();
            return;
        }
        $data['question'] = I('post.question');
        if ($data['question'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '问题不能为空']);
        }

        if (strlen($data['question']) > 60) {
            $this->ajaxReturn(['code' => 1, 'message' => '问题最多20个汉字']);
        }

        $data['answer'] = I('post.answer');
        if ($data['answer'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '回答不能为空']);
        }

        if (strlen($data['answer']) > 150) {
            $this->ajaxReturn(['code' => 1, 'message' => '回答最多50个汉字']);
        }

        $where['bk_id'] = I('post.id');
        M('bk_question_answer')->where($where)->save($data);
        $data['bk_id'] = I('post.id');
        $this->sendGameMessageQuestionAnswerAdd($data, 1040);
        $this->ajaxReturn(['code' => 0]);
    }

    //删除问答
    public function questionAnswerDel()
    {
        $where['bk_id'] = I('post.id');
        M('bk_question_answer')->where($where)->delete();
        $this->sendGameMessageQuestionAnswerDel($where, 1041);
        $this->ajaxReturn(['code' => 0]);
    }

    //发送客户问答
    public function sendGameMessageQuestionAnswerAdd($data, $num)
    {
        $d['id'] = pack("L", $data['bk_id']);
        $d['question'] = pack("S", strlen($data['question']));
        $d['answer'] = pack("S", strlen($data['answer']));
        $body = $d['id'] . $d['question'] . $data['question'] . $d['answer'] . $data['answer'];
        $socket_result = SendToGame(C('SOCKET_IP'), 30000, $num, $body);
    }

    //删除客户问答
    public function sendGameMessageQuestionAnswerDel($data, $num)
    {
        $d['id'] = pack("L", $data['bk_id']);
        $body = $d['id'];
        $socket_result = SendToGame(C('SOCKET_IP'), 30000, $num, $body);
    }

    //发送扫码订单实际金额
    public function sendGameMessageQrRealAmount($data)
    {
        $d['bk_MerchantOrder_Len'] = pack("S", strlen($data['bk_MerchantOrder']));
        $d['bk_AccountID'] = pack("L", $data['bk_AccountID']);
        $d['bk_RealAmount'] = pack("L", $data['bk_RealAmount']);
        $body = $d['bk_MerchantOrder_Len'] . $data['bk_MerchantOrder'] . $d['bk_AccountID'] . $d['bk_RealAmount'];
        $socket_result = SendToGame(C('SOCKET_IP'), 30000, 1039, $body);
    }

    //构建向游戏服务端发送数据-用户资料
    public function sendUserData($cid, $tid, $ttext)
    {
        $cid = pack("L", $cid);
        $tid = pack("C", $tid);
        $ttext_len = pack("S", strlen($ttext));
        $body = $cid . $tid . $ttext_len . $ttext;
        $socket_result = SendToGame(C('SOCKET_IP'), 30000, 1031, $body);
    }

    //构建向游戏服务端发送数据
    public function sendGameMessage($cid, $tid, $ttext)
    {
        $cid = pack("C", $cid);
        $tid = pack("C", $tid);
        $ttext_len = pack("S", strlen($ttext));
        $body = $cid . $tid . $ttext_len . $ttext;
        $socket_result = SendToGame(C('SOCKET_IP'), 30000, 1002, $body);
    }

    //构建向游戏服务端发送数据（设置等级）
    public function sendGameMessageVip($uid, $vipClass)
    {
        $uid = pack("L", $uid);
        $vipClass = pack("C", $vipClass);
        $body = $uid . $vipClass;
        $socket_result = SendToGame(C('SOCKET_IP'), 30000, 1003, $body);
    }

    //向游戏服务端发送数据(广告添加)
    public function sendGameMessageAddGongGao($data)
    {
        $send_data['id'] = pack('L', $data['id']);   // 公告ID
        $send_data['priority'] = pack('C', $data['priority']); // 优先级
        $send_data['title'] = pack('S', strlen($data['title'])); // 标题
        $send_data['onlineTime'] = pack('L', $data['onlineTime']);   //上 架时间
        $send_data['offlineTime'] = pack('L', $data['offlineTime']); // 下架时间
        $send_data['channelID'] = pack('S', strlen($data['channelID'])); // 渠道
        $send_data['gameType'] = pack('C', $data['gameType']);  // 游戏公告子类型
        $send_data['content'] = pack('S', strlen($data['content'])); // 公告内容
        $send_data['label'] = pack('C', $data['label']);  // 公告角标
        $send_data['pictureID'] = pack('L', $data['pictureID']);  // 图片ID
        $send_data['webPage'] = pack('S', strlen($data['webPage']));  // 指定页面
        $send_data['isPop'] = pack('C', $data['isPop']);  // 是否弹出
        $send_data['isStop'] = pack('C', $data['isStop']);  // 是否开启
        // 登录公告发送的内容
        $body = $send_data['id'] . $send_data['priority'] . $send_data['title'] . $data['title'] . $send_data['onlineTime'] . $send_data['offlineTime'] .
            $send_data['channelID'] . $data['channelID'] . $send_data['content'] . $data['content'] . $send_data['isStop'];
        // 游戏公告
        if ($data['type'] == 2) {
            $body = $send_data['id'] . $send_data['priority'] . $send_data['title'] . $data['title'] . $send_data['onlineTime'] . $send_data['offlineTime'] .
                $send_data['channelID'] . $data['channelID'] . $send_data['gameType'] . $send_data['content'] . $data['content'] . $send_data['label'] .
                $send_data['pictureID'] . $send_data['webPage'] . $data['webPage'] . $send_data['isPop'] . $send_data['isStop'];
        }
        $port = ($data['type'] == 1) ? 20000 : 30000;
        $ip = ($data['type'] == 1) ? C('SOCKET_IP_LOGIN') : C('SOCKET_IP');
        SendToGame($ip, $port, 1020, $body);
    }

    //向游戏服务端发送数据(解冻或冻结手机号或银行卡)
    public function sendGameMessageLockMobileOrBankNumberOrAlipay($data)
    {
        $data['type'] = pack('C', $data['type']); //类型 1手机号码 2银行卡 3支付宝
        $data['lockNum'] = pack('C', $data['lockNum']); //1解禁 2冻结
        $data['text_str'] = pack('S', strlen($data['text']));
        $body = $data['type'] . $data['lockNum'] . $data['text_str'] . $data['text'];
        SendToGame(C('SOCKET_IP'), 30000, 1035, $body);
    }

    //向游戏服务端发送数据(广告删除)
    public function sendGameMessageDelGongGao($data)
    {
        $data['id'] = pack("L", $data['id']);
        $body = $data['id'];
        $port = ($data['type'] == 1) ? 20000 : 30000;
        $ip = ($data['type'] == 1) ? C('SOCKET_IP_LOGIN') : C('SOCKET_IP');
        SendToGame($ip, $port, 1021, $body);
    }
//
//    //向游戏服务端发送数据(修改公告)
//    public function sendGameMessageUpdateGongGao( $data ) {
//
//        $data['id'] = pack('L', $data['id']); //公告ID\
//        $data['YouXianJi'] = pack('C', $data['YouXianJi']); //优先级
//        $data['title_len'] = pack('S', strlen($data['title'])); //标题
//        $data['onlineTime'] = pack('L', $data['onlineTime']); //上架时间
//        $data['offlineTime'] = pack('L', $data['offlineTime']); //下架时间
//        $data['qudao_len'] = pack('S', strlen($data['qudao'])); //渠道
//        $data['content_len'] = pack('S', strlen($data['content'])); //公告内容
//        $data['isStop'] = pack('C', $data['isStop']); //公告是否停止
//        $body =  $data['id'].$data['YouXianJi'].$data['title_len'].$data['title'].$data['onlineTime'].$data['offlineTime'].$data['qudao_len'].$data['qudao'].$data['content_len'].$data['content'].$data['isStop'];
//        $port = ( $data['type'] == 1  ) ? 20000 : 30000;
//        $ip = ( $data['type'] == 1  ) ? C('SOCKET_IP_LOGIN') : C('SOCKET_IP');
//        SendToGame( $ip, $port, 1022, $body );
//    }

    //向游戏服务端发送数据(发送邮件信息)
    public function sendGameMessageAddEmail($data)
    {
        $send_data['type'] = pack('C', $data['type']); //邮件类型
        $send_data['channelID'] = pack('S', strlen($data['channelID'])); //渠道ID
        $send_data['accountID'] = pack('S', strlen($data['accountID'])); //收件人ID
        $send_data['title'] = pack('S', strlen($data['title'])); //标题
        $send_data['content'] = pack('S', strlen($data['content'])); //内容
        $send_data['sendTime'] = pack('L', $data['sendTime']); // 发送时间
        $send_data['effectiveTime'] = pack('L', $data['effectiveTime']); // 失效时间
        $send_data['sendGold'] = pack('L', $data['sendGold']); // 发送金币
        $body = $send_data['type'] . $send_data['channelID'] . $data['channelID'] . $send_data['accountID'] . $data['accountID'] .
            $send_data['title'] . $data['title'] . $send_data['content'] . $data['content'] . $send_data['sendTime'] . $send_data['effectiveTime'] . $send_data['sendGold'];
        SendToGame(C('SOCKET_IP'), 30000, 1001, $body);
    }

    //向游戏服务端发送数据(添加小喇叭)
    public function sendGameMessageAddTrumpet($data)
    {
        $data['id'] = pack('L', $data['id']);  //小喇叭ID
        $data['YouXianJi'] = pack('C', $data['YouXianJi']); //权重
        $data['OnlineTime'] = pack('L', $data['OnlineTime']); //开始时间
        $data['OfflineTime'] = pack('L', $data['OfflineTime']); //结束时间
        $data['BoBaoJianGe'] = pack('L', $data['BoBaoJianGe']); //间隔时间
        $data['ChannelID_len'] = pack('S', strlen($data['ChannelID'])); //渠道
        $data['Content_len'] = pack('S', strlen($data['Content'])); //渠道
        $body = $data['id'] . $data['YouXianJi'] . $data['OnlineTime'] . $data['OfflineTime'] . $data['BoBaoJianGe'] . $data['ChannelID_len'] . $data['ChannelID'] . $data['Content_len'] . $data['Content'];
        SendToGame(C('SOCKET_IP'), 30000, 1013, $body);
    }

    //向游戏服务端发送数据(删除小喇叭)
    public function sendGameMessageDelTrumpet($data)
    {
        $data['id'] = pack('L', $data['id']);  //小喇叭ID
        $body = $data['id'];
        SendToGame(C('SOCKET_IP'), 30000, 1014, $body);
    }


    //向游戏服务端发送数据(修改小喇叭)
    public function sendGameMessageUpdateTrumpet($data)
    {
        $data['id'] = pack('L', $data['id']);  //小喇叭ID
        $data['YouXianJi'] = pack('C', $data['YouXianJi']); //权重
        $data['OnlineTime'] = pack('L', $data['OnlineTime']); //开始时间
        $data['OfflineTime'] = pack('L', $data['OfflineTime']); //结束时间
        $data['BoBaoJianGe'] = pack('L', $data['BoBaoJianGe']); //间隔时间
        $data['ChannelID_len'] = pack('S', strlen($data['ChannelID'])); //渠道
        $data['Content_len'] = pack('S', strlen($data['Content'])); //内容
        $body = $data['id'] . $data['YouXianJi'] . $data['OnlineTime'] . $data['OfflineTime'] . $data['BoBaoJianGe'] . $data['ChannelID_len'] . $data['ChannelID'] . $data['Content_len'] . $data['Content'];
        SendToGame(C('SOCKET_IP'), 30000, 1015, $body);
    }

}