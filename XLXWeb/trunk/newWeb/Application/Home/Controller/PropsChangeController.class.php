<?php

namespace Home\Controller;
class PropsChangeController extends BaseController
{
    public function index()
    {
        $this->show();
    }

    //道具增减
    public function propsList()
    {

        $data = array();

        $props = C('props');

        if (!IS_AJAX) {
            $this->assign('props_type', $props);
            $this->show();
            return;
        }

        //道具增减
        if (I('post.props_type/d') <= 0 || I('post.add_reduce/d') <= 0 || I('post.reason') == "") {
            $this->ajaxReturn(array('code' => 1, 'message' => '数据获取失败'));
        }

        if (I('post.reason') == "show" && I('post.reason_text') == '') {
            $this->ajaxReturn(array('code' => 1, 'message' => '数据获取失败'));
        }

        //存入数据库中的数据
        $data['bk_Reason'] = I('post.reason');
        if (I('post.reason') == "show") {
            $data['bk_Reason'] = I('post.reason_text');
        }
        $data['bk_PropsType'] = I('post.props_type/d');
        $data['bk_PropsAmount'] = I('post.add_reduce/d') == 1 ? I('post.props_amount/d') : -I('post.props_amount/d');   //确定是增加金币还是减少金币
        $data['bk_Time'] = time();
        $data['bk_Operator'] = $this->login_admin_info['bk_name'];

        //构建socket数据
        $propsType_send = I('post.props_type/d');
        $amount_send = $data['bk_PropsAmount'];

        //对所有玩家操作
        if (I('post.account') == "") {
            //查询所有玩家id
            $account_list = M('bk_accountv')->field('gd_AccountID')->select();
            $count = 0;
            //数据库事务开启
            $Model = M('bk_props');
            $Model->startTrans();
            //对所有玩家加金币
            foreach ($account_list as $key => $val) {
                $data['bk_AccountID'] = $val['gd_accountid'];
                $result = $Model->data($data)->add();
                if (intval($result) < 0) {
                    $count++;
                }
            }
            //数据库事务回滚
            if ($count > 0) {
                $Model->rollback();
                $this->ajaxReturn(array('code' => 1, 'message' => '数据存储失败'));
            }
            //数据库事务提交
            $Model->commit();
            //构建socket数据-发送所有
            $account_send = "all";
            $str = pack("S", strlen($account_send)) . $account_send . pack("C", $propsType_send) . pack("L", $amount_send);
            SendToGame(C('socket_ip'), 30000, 1005, $str);
            $this->ajaxReturn(array('code' => 0));
        }

        //对指定的玩家进行道具增减,并开启验证
        $pattern = "/^\d{7}$/";
        $account = I('post.account');
        $account = str_replace(' ', '', $account);

        //用户输入的字符串长度小于7
        if (strlen($account) < 7) {
            $this->ajaxReturn(array('code' => 1, 'message' => '请输入正确的玩家ID'));
        } //用户只输入单个玩家ID

        //单个玩家道具增减
        if (strlen($account) == 7) {

            //判断玩家ID格式是否正确(7位非负整数)
            if (!preg_match($pattern, $account)) {
                $this->ajaxReturn(array('code' => 1, 'message' => '请输入正确的玩家ID'));
            }
            //判断该玩家ID是否存在
            if ((M('bk_accountv')->where(array('gd_AccountID' => $account))->find()) == NULL) {
                $this->ajaxReturn(array('code' => 1, 'message' => '该玩家ID不存在'));
            }

            $data['bk_AccountID'] = $account;
            $result = M('bk_props')->data($data)->add();
            if (intval($result) <= 0) {
                $this->ajaxReturn(array('code' => 1, 'message' => '存储失败'));
            }
            //构建socket数据-发送单个玩家
            $account_send = $account;
            $str = pack("S", strlen($account_send)) . $account_send . pack("C", $propsType_send) . pack("L", $amount_send);
            SendToGame(C('socket_ip'), 30000, 1005, $str);
            $this->ajaxReturn(array('code' => 0));
        }

        //用户输入多个玩家ID,并且用逗号分割(英文逗号)
        $count = 0;
        foreach (explode(",", $account) as $val) {

            //判断玩家ID格式是否正确(7位非负整数)
            if (!preg_match($pattern, $val)) {
                $this->ajaxReturn(array('code' => 1, 'message' => ('添加失败,输入的第' . ($count + 1) . '个玩家ID格式不正确,或者该玩家后面输入了中文逗号')));
            }

            //判断该玩家ID是否存在
            if ((M('bk_accountv')->where(array('gd_AccountID' => $val))->find()) == NULL) {
                $this->ajaxReturn(array('code' => 1, 'message' => ('添加失败,输入的第' . ($count + 1) . '个玩家ID不存在')));
            }
            $count++;
        }
        //输入的所有玩家ID格式都正确且玩家表中都存在
        $count_ = 0;
        //数据库事务开启
        $Model = M('bk_props');
        $Model->startTrans();
        foreach (explode(",", $account) as $val) {
            $data['bk_AccountID'] = $val;
            $result = $Model->data($data)->add();
            if (intval($result) <= 0) {
                $count_++;
            }
        }
        //数据库事务回滚
        if ($count_ > 0) {
            $Model->rollback();
            $this->ajaxReturn(array('code' => 1, 'message' => '数据存储失败'));
        }
        //数据库事务提交
        $Model->commit();
        //构建socket数据-发送多个玩家ID
        $account_send = $account;
        $str = pack("S", strlen($account_send)) . $account_send . pack("C", $propsType_send) . pack("L", $amount_send);
        SendToGame(C('socket_ip'), 30000, 1005, $str);
        $this->ajaxReturn(array('code' => 0));
    }

    //道具查看
    public function propsCheck()
    {

        $where_data = array();
        $data = array();

        $props = C('props');
        $props_reason = C('props_reason');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->assign("props_type", $props);
            $this->assign("props_reason", $props_reason);
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account') != "") {
            $where_data['bk_AccountID'] = array('in', explode(",", I('get.account')));
        }

        if (I('get.props_type/d') > 0) {
            $where_data['bk_PropsType'] = I('get.props_type/d');
        }

        if (I('get.amount/d') > 0) {
            $where_data['bk_PropsAmount'] = I('get.amount/d');
        }

        if (I('get.props_reason/d') > 0) {
            $where_data['bk_Reason'] = $props_reason[I('get.props_reason/d')];
        }

        if (I('get.reason_text') != "") {
            $where_data['bk_Reason'] = array('like', '%' . I('get.reason_text') . '%');
        }

        if (I('get.operator') != "") {
            $where_data['bk_operator'] = I('get.operator');
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
            $where_data['bk_time'] = array('between', array($s_time, $e_time));
        }

        $order = "bk_Time desc";
        $fileds = array('p.bk_AccountID as accountid', 'gd_Name as name', 'bk_PropsType as type', 'bk_PropsAmount as amount', 'bk_Reason', 'bk_time', 'bk_operator');
        $layui_data['count'] = M('bk_props')->field($fileds)->alias('p')->join("  __ACCOUNTV__  ON p.bk_AccountID = __ACCOUNTV__.gd_AccountID ")->where($where_data)->count();
        $Query = M('bk_props')->field($fileds)->alias('p')->join("  __ACCOUNTV__  ON p.bk_AccountID = __ACCOUNTV__.gd_AccountID ")->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        foreach ($data_list as $key => $val) {
            $data['account'] = $val['accountid'];
            $data['name'] = $val['name'];
            $data['props_type'] = $props[$val['type']];
            $data['props_amount'] = $val['amount'];
            $data['reason'] = $val['bk_reason'];
            $data['operator'] = $val['bk_operator'];
            $data['time'] = date('Y:m:d H:i:s', $val['bk_time']);
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.props_check'), $layui_data['data'], '道具查看');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }
}