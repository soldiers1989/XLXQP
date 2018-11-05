<?php

namespace Home\Controller;
class WithdrawController extends BaseController
{
    public function index() {
        $this->show();
    }

    // 提现申请
    public function withdrawalApplication() {
        $where_data = $data = $export = array();

        $TX_CLASS = C('TX_CLASS');    // 提现分类
        $TX_TYPE = C('TX_TYPE');    // 提现类型

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }
        G('begin');
        $layui_data['page'] = I('get.page/d');
        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');   // 玩家ID
        }
        if (I('get.nickname') != "") {
            $where_data['bk_AccountName'] = I('get.nickname');  // 玩家昵称
        }
        if (I('get.order') != "") {
            $where_data['bk_OrderNum'] = I('get.order');    // 订单号
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
            $where_data['bk_CreateTime'] = array('between', array($s_time, $e_time));   // 起始时间
        }
        $where_data['bk_OrderState'] = 1;   // 审核中的订单
        $layui_data['count'] = M('bk_tixianorder')->where($where_data)->count();

        $order = 'bk_CreateTime desc';
        $fields = 'bk_ID, bk_OrderNum, bk_AccountID, bk_AccountName, bk_TiXianName, bk_CreateTime, bk_TiXian, 
        bk_ReceiveAccount, bk_TixianRMB, bk_Overage, bk_TixianType, bk_nShouXuFei, bk_Type, bk_EarlyWarning, bk_ChargeDesc';
        $Query = M('bk_tixianorder')->field($fields)->where($where_data)->order($order);
        if (I('get.isExecl/d') == 0) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        $sql = M('bk_tixianorder')->getLastSql();
        $number = 1;
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_id'];
            $data['number'] = $number;
            $data['order'] = $val['bk_ordernum'];   // 订单号
            $data['account'] = $val['bk_accountid'];    // 玩家ID
            $data['nickname'] = $val['bk_accountname']; // 玩家昵称
            $data['time'] = date('Y-m-d H:i:s', $val['bk_createtime']);    // 提现申请时间
            $data['charge_sum'] = $val['bk_chargedesc'];   // 充值总额
            $data['ytx_sum'] = $val['bk_tixian'] / 10000;   // 已提现金额
            $data['overage'] = ($val['bk_overage'] / 10000);    // 余额
            $data['TX_TYPE'] = $TX_TYPE[$val['bk_tixiantype']]; // 提现类型
            $admin = $this->adminInfo($val['bk_receiveaccount']);
            $data['receiveaccount'] = $val['bk_receiveaccount'] == 0 ? '未领取' : $admin['bk_name']; // 领取人
            $data['receive_flag'] = $val['bk_receiveaccount'] == 0 ? true : false;
            $data['tx_amount'] = $val['bk_tixianrmb'];  // 提现金额
            $flag = $val['bk_earlywarning'];   // 预警内容
            $data['flag'] = $flag == '' ? 0 : 1;    // 预警标志;
            $data['warning'] = $flag;
            $data['tx_rate'] = ($val['bk_nshouxufei'] / 10000);   // 提现手续费
            $data['tx_real_amount'] = ($data['tx_amount'] - $data['tx_rate']);    // 实际提现金额
            $data['TX_CLASS'] = $TX_CLASS[$val['bk_type']]; // 提现分类
            $data['player_info'] = U('freezeManagement/userInfo', array('uid' => $val['bk_accountid']));    // 玩家信息url
            $data['order_info'] = U('Withdraw/orderInfo', array('id' => $val['bk_id']));    // 订单信息
            $data['not_allow'] = U('Withdraw/orderNotAllow', array('id' => $val['bk_id'])); // 订单不通过
            $layui_data['data'][] = $data;

            // 数据导出
            $export['number'] = $data['number'];
            $export['account'] = $data['account'];
            $export['nickname'] = $data['nickname'];
            $export['charge_sum'] = $data['charge_sum'];
            $export['ytx_sum'] = $data['ytx_sum'];
            $export['overage'] = $data['overage'];
            $export['TX_TYPE'] = $data['TX_TYPE'];
            $export['tx_amount'] = $data['tx_amount'];
            $export['warning'] = $data['warning'];
            $export['tx_rate'] = $data['tx_rate'];
            $export['tx_real_amount'] = $data['tx_real_amount'];
            $export['time'] = $data['time'];
            $export['TX_CLASS'] = $data['TX_CLASS'];
            $export['order'] = $data['order'];
            $export['data'][] = $export;
            $number++;
        }
        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.withdraw_application'), $export['data'], '提现申请');
        }
        G('end');
        if (G('begin', 'end') > 2) {
            \Think\Log::write(G('begin', 'end') . 's', 'Time', C('LOG_TYPE'), C('LOG_PATH') . date('y_m_d') . '_my1.log');
        } else {
            \Think\Log::write(G('begin', 'end') . 's', 'Time', C('LOG_TYPE'), C('LOG_PATH') . date('y_m_d') . '_my.log');
        }

        $layui_data['code'] = 0;
        $layui_data['sql'] = $sql;
        $layui_data['time'] = G('begin', 'end') . 's';
        $this->ajaxReturn($layui_data);
    }

    // 领取提现订单
    public function getTixianOrder() {
        $id = I('post.id/d');
        $t_count = M('bk_tixianorder')->where(['bk_ID' => $id, 'bk_ReceiveAccount' => 0])->count();
        if ($t_count == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '领取失败,此订单已被别人领取!']);
        }
        M('bk_tixianorder')->where(['bk_ID' => $id])->save(['bk_ReceiveAccount' => intval(session('userid'))]);

        $this->ajaxReturn(['code' => 0, 'name' => $this->login_admin_info['bk_name']]);
    }


    // 提现订单信息
    public function orderInfo() {
        $data = array();

        $TX_TYPE = C('TX_TYPE');    // 提现类型
        $TX_CLASS = C('TX_CLASS');  // 提现分类
        $HTSH_RES = C('HTSH_RES');  // 后台审核结果
        $TDTX_RES = C('TDTX_RES');  // 提现通道结果
        $RGCL_RES = C('RGCL_RES');  // 人工处理结果
        $DD_STATE = C('DD_STATE');  // 订单状态

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $layui_data['count'] = M('bk_tixianorder')->where(['bk_ID' => I('get.id/d')])->count();
        $data_list = M('bk_tixianorder')->where(['bk_ID' => I('get.id/d')])->page(I('page/d'))->limit(I('limit/d'))->select();
        foreach ($data_list as $key => $val) {
            $data['order'] = $val['bk_ordernum'];   // 订单号
            $data['create_time'] = date('Y-m-d H:i:s', $val['bk_createtime']);  // 订单生成时间
            $data['request_ip'] = $val['bk_requestip']; // 来自IP
            $data['device_code'] = $val['bk_devicecode'];   // 设备码
            $data['account'] = $val['bk_accountid'];    // 玩家ID
            $data['nickname'] = $val['bk_accountname']; // 玩家昵称
            $data['amount'] = $val['bk_tixianrmb']; // 提现金额
            $data['tx_rate'] = ($val['bk_nshouxufei'] / 10000); // 提现手续费
            $data['tx_real_amount'] = ($data['amount'] - $data['tx_rate']); // 实际提现金额
            $data['type'] = $TX_TYPE[$val['bk_tixiantype']];    // 提现类型
            $data['class'] = $TX_CLASS[$val['bk_type']];    // 提现分类
            $data['tx_account'] = $val['bk_tixianaccount']; // 目标账号
            $data['sh_result'] = $HTSH_RES[$val['bk_verifyres']];   // 后台审核结果
            $data['sh_operator'] = $val['bk_verifyaccount'] == '0' ? '' : $val['bk_verifyaccount']; // 后台审核账号
            $data['sh_detail'] = $val['bk_verifydetail'] == '0' ? '' : $val['bk_verifydetail']; // 审核结果详细
            $data['sh_time'] = ($val['bk_verifytime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_verifytime']));  // 审核时间
            $data['tx_pass'] = ($val['bk_passname'] == 0 ? '' : $val['bk_passname']);   // 提现通道
            $data['tx_pass_result'] = $TDTX_RES[$val['bk_passres']];    // 通道提现结果
            $data['tx_process_time'] = ($val['bk_passprocesstime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_passprocesstime']));    // 通道提现处理时间
            $data['rg_result'] = $RGCL_RES[$val['bk_peopleres']];   // 人工处理结果
            $data['RGCL_RES_detail'] = ($val['bk_peopleresdetail'] == '0' ? '' : $val['bk_peopleresdetail']);   // 人工处理详细结果
            $data['rg_operator'] = ($val['bk_peopleaccount'] == 0 ? '' : $val['bk_peopleaccount']); // 人工处理账号
            $data['rg_time'] = ($val['bk_peopletime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_peopletime']));  // 人工处理时间
            $data['dk_time'] = ($val['bk_dakuantime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_dakuantime']));  // 打款时间
            $data['state'] = $DD_STATE[$val['bk_orderstate']];  // 订单状态
            $layui_data['data'][] = $data;
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 提现申请-允许通过-第三方打款
    public function doAllowThirdPartyPayment() {
        $send_data = array(); //curl发送的数据

        if (I('post.id/d') <= 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '数据获取失败']);
        }

        $t_count = M('bk_tixianorder')->where(['bk_ID' => I('post.id/d'), 'bk_ReceiveAccount' => session('userid')])->count();
        if ($t_count == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '操作失败,请先领取订单,或订单已被领取']);
        }

        // 第三方支付-数据
        $row = M('bk_tixianorder')->where(['bk_ID' => I('post.id/d')])->find();
        $send_data['id'] = $row['bk_accountid'];  // 玩家ID
        $send_data['pay_type'] = $row['bk_tixiantype'];  // 支付类型 1银行卡 2支付宝
        $send_data['amount'] = $row['bk_tixianrmb'];  // 金额
        $send_data['apkid'] = $row['bk_apkid'];  // 包id
        $send_data['bankid'] = $row['bk_tixiantype'] == 1 ? M('bk_bindcardinfo')->where(['gd_AccountID' => $row['bk_accountid']])->getField('gd_BankID') : '';  // 账号 支付宝传空值
        $send_data['merchant_order_no'] = $row['bk_ordernum'];  // 订单号
        $res = $this->http_request(C('HTTP_POST_ADD'), $send_data);  // 发送post请求

        // 订单数据更新
        $up_data['bk_VerifyRes'] = 1;   // 后台审核结果
        $up_data['bk_VerifyAccount'] = $this->login_admin_info['bk_name'];  // 后台审核账号
        $up_data['bk_VerifyDetail'] = $res; // 后台审核详细结果(第三方返回)
        $up_data['bk_VerifyTime'] = time(); // 后台审核时间
        $result = M('bk_tixianorder')->where(array('bk_ID' => I('post.id/d')))->save($up_data);

        intval($result) > 0 && $this->ajaxReturn(array('code' => 0, 'message' => $res));
    }

    // 提现申请-允许通过-人工打款
    public function doAllowManualPayment() {
        if (I('post.id/d') <= 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '数据获取失败']);
        }

        $t_count = M('bk_tixianorder')->where(['bk_ID' => I('post.id/d'), 'bk_ReceiveAccount' => session('userid')])->count();
        if ($t_count == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '操作失败,请先领取订单,或订单已被领取']);
        }
        $up_data['bk_VerifyRes'] = 1;   // 人工审核结果
        $up_data['bk_VerifyAccount'] = $this->login_admin_info['bk_name'];  // 人工审核账号
        $up_data['bk_VerifyDetail'] = '通过,并选择人工打款方式为玩家打款';  // 人工审核详细结果
        $up_data['bk_VerifyTime'] = time();  // 人工审核时间
        $up_data['bk_OrderState'] = 4;  // 订单状态
        $result = M('bk_tixianorder')->where(array('bk_ID' => I('post.id/d')))->save($up_data);
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    // 提现申请-不通过-退币
    public function doNotAllowRefund() {
        if (I('post.id/d') <= 0 || I('post.reason') == '' || I('post.amount/d') <= 0 || I('post.account/d') <= 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '数据获取不完整']);
        }

        $t_count = M('bk_tixianorder')->where(['bk_ID' => I('post.id/d'), 'bk_ReceiveAccount' => session('userid')])->count();
        if ($t_count == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '操作失败,请先领取订单,或订单已被领取']);
        }
        $id = I('post.id/d');
        $account = I('post.account/d'); // 玩家ID
        $amount = I('post.amount/d');   // 提现金额
        $up_data['bk_VerifyRes'] = 2;   // 人工审核结果
        $up_data['bk_VerifyAccount'] = $this->login_admin_info['bk_name'];  // 人工审核账号
        $up_data['bk_VerifyDetail'] = I('post.reason'); // 人工审核详细结果
        $up_data['bk_VerifyTime'] = time(); // 人工审核时间
        $up_data['bk_OrderState'] = 2;  // 订单状态
        $result = M('bk_tixianorder')->where(array('bk_ID' => $id))->save($up_data);
        if (intval($result) > 0) {
            // 与服务器通信
            $str = pack('L', $account) . pack('L', $amount);
            sendToGame(C('socket_ip'), 30000, 1032, $str);
            $this->ajaxReturn(array('code' => 0));
        }
    }

    // 提现申请-不通过-不退币
    public function doNotAllowNotRefund() {
        if (I('post.id/d') <= 0 || I('post.reason') == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '数据获取不完整']);
        }

        $t_count = M('bk_tixianorder')->where(['bk_ID' => I('post.id/d'), 'bk_ReceiveAccount' => session('userid')])->count();
        if ($t_count == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '操作失败,请先领取订单,或订单已被领取']);
        }
        $id = I('post.id/d');
        $up_data['bk_VerifyRes'] = 2;   // 人工审核结果
        $up_data['bk_VerifyAccount'] = $this->login_admin_info['bk_name'];  // 人工审核账号
        $up_data['bk_VerifyDetail'] = I('post.reason'); // 人工审核详细结果
        $up_data['bk_VerifyTime'] = time(); // 人工审核时间
        $up_data['bk_OrderState'] = 2;  // 订单状态

        $result = M('bk_tixianorder')->where(array('bk_ID' => $id))->save($up_data);
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    // 特殊订单处理
    public function specialOrderProcess() {
        $where_data = $data = array();

        $TDTX_RES = C('TDTX_RES');  // 通道提现结果
        $TX_TYPE = C('TX_TYPE');    // 提现类型

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');
        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');   // 玩家ID
        }
        if (I('get.nickname') != '') {
            $where_data['bk_AccountName'] = I('get.nickname');  // 玩家昵称
        }
        if (I('get.order') != '') {
            $where_data['bk_OrderNum'] = I('get.order');    // 订单号
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
            $where_data['bk_CreateTime'] = array('between', array($s_time, $e_time));   // 起始时间
        }
        $where_data['bk_OrderState'] = 4;   // 订单状态
        $where_data['bk_ReceiveAccount'] = session('userid');   // 接收人

        $layui_data['count'] = M('bk_tixianorder')->where($where_data)->count();
        $fields = array('bk_ID', 'bk_OrderNum', 'bk_PassRes', 'bk_AccountID', 'bk_AccountName', 'bk_TixianType',
            'bk_TixianAccount', 'bk_TixianRMB', 'bk_CreateTime', 'bk_Overage', 'bk_VerifyAccount', 'bk_nShouXuFei',
            'bk_TiXianName', 'bk_EarlyWarning', 'bk_ChargeDesc');
        $order = 'bk_CreateTime desc';
        $Query = M('bk_tixianorder')->field($fields)->where($where_data)->order($order);
        if (I('get.isExecl/d') == 0) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        $number = 1;
        foreach ($data_list as $key => $val) {
            if (I('get.isExecl/d') == 0) $data['id'] = $val['bk_id'];
            $data['number'] = $number;  // 序号
            $data['account'] = $val['bk_accountid'];    // 玩家ID
            $data['nickname'] = $val['bk_accountname']; // 玩家昵称
            $data['TX_TYPE'] = $TX_TYPE[$val['bk_tixiantype']]; // 提现类型
            $data['target_account_'] = $val['bk_tixianaccount'];    // 目标账号
            $data['name'] = $val['bk_tixianname'];    // 提现姓名
            $data['tx_real_amount'] = $val['bk_tixianrmb'] - ($val['bk_nshouxufei'] / 10000);  // 实际提现金额
            $flag = $val['bk_earlywarning'];   // 预警内容
            if (I('get.isExecl/d') == 0) $data['flag'] = $flag == '' ? 0 : 1;    // 预警标志;
            $data['warning'] = $flag;
            $data['tx_rate'] = ($val['bk_nshouxufei'] / 10000); // 提现手续费
            $data['tx_amount'] = $val['bk_tixianrmb'];  // 提现金额
            $data['time'] = date('Y-m-d H:i:s', $val['bk_createtime']); // 提现申请时间
            $data['ht_operator'] = $val['bk_verifyaccount'];    // 后台审核人
            $data['order'] = $val['bk_ordernum'];   // 订单号
            $data['txtd_result'] = $TDTX_RES[$val['bk_passres']];   // 通道提现结果
            if (I('get.isExecl/d') == 0) $data['order_info'] = U('Withdraw/orderInfo', array('id' => $val['bk_id']));   // 订单信息
            if (I('get.isExecl/d') == 0) {
                if ($val['bk_tixiantype'] == 1) {
                    $data['target_account'] = U('Withdraw/userDataBankCardInfo', array('account' => $val['bk_accountid'], 'id' => $data['id']));    // 银行卡信息
                } else {
                    $data['target_account'] = U('Withdraw/userDataAlipayInfo', array('account' => $val['bk_accountid'], 'id' => $data['id']));    // 支付宝信息
                }
            }
            $layui_data['data'][] = $data;
            $number++;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.special_order'), $layui_data['data'], '特殊订单处理');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 用户资料-银行卡信息  特殊订单处理
    public function userDataBankCardInfo() {
        $where_data = array();
        $txType = C('TX_TYPE'); // 提现类型

        $where_data['bk_AccountID'] = I('get.account/d');   // 玩家ID
        $where_data['bk_ID'] = I('get.id/d');

        $row = M('bk_tixianorder')->where($where_data)->find();
        $data['account'] = $where_data['bk_AccountID']; // 玩家ID
        $data['type'] = $txType[$row['bk_tixiantype']]; // 提现类型
        $data['tixianrmb'] = $row['bk_tixianrmb'] - $row['bk_nshouxufei'] / 10000;  // 实际提现金额
        $row = M('bk_playerdata')->where(['bk_AccountID' => I('get.account/d')])->find();
        $data['name'] = $row['bk_name'] == '0' ? '' : $row['bk_name'];  // 持卡人姓名
        $data['bankcard'] = $row['bk_bankcard'] == '0' ? '' : $row['bk_bankcard'];  // 银行卡号
        $data['bankName'] = $row['bk_bankname'] == '0' ? '' : $row['bk_bankname'];  // 银行名称
        $this->assign('data', $data);
        $this->show();
    }

    // 用户资料-支付宝信息  特殊订单处理
    public function userDataAlipayInfo() {
        $where_data = array();
        $txType = C('TX_TYPE'); // 提现类型

        $where_data['bk_AccountID'] = I('get.account/d');   // 玩家ID
        $where_data['bk_ID'] = I('get.id/d');

        $row = M('bk_tixianorder')->where($where_data)->find();
        $data['account'] = $where_data['bk_AccountID']; // 玩家ID
        $data['type'] = $txType[$row['bk_tixiantype']]; // 提现类型
        $data['tixianrmb'] = $row['bk_tixianrmb'] - $row['bk_nshouxufei'] / 10000;  // 实际提现金额
        $row = M('bk_playerdata')->where(['bk_AccountID' => I('get.account/d')])->find();
        $data['name'] = $row['bk_alipayname'] == '0' ? '' : $row['bk_alipayname'];  // 支付宝姓名
        $data['alipay'] = $row['bk_alipay'] == '0' ? '' : $row['bk_alipay'];    // 支付宝账号
        $this->assign('data', $data);
        $this->show();
    }

    // 特殊订单处理-人工打款
    public function doManualPayment() {
        if (I('post.id/d') <= 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '数据获取失败']);
        }

        $up_data['bk_PeopleRes'] = 1;   // 人工处理结果
        $up_data['bk_PeopleResDetail'] = '打款成功';    // 人工审核详细结果
        $up_data['bk_PeopleAccount'] = $this->login_admin_info['bk_name'];  // 人工审核账号
        $up_data['bk_PeopleTime'] = time(); // 人工审核时间
        $up_data['bk_OrderState'] = 5;  // 订单状态
        $up_data['bk_DakuanTime'] = $up_data['bk_PeopleTime'];  // 打款时间

        $result = M('bk_tixianorder')->where(array('bk_ID' => I('post.id/d')))->save($up_data);
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    // 特殊订单处理-退币
    public function doRefund() {
        if (I('post.id/d') <= 0 || I('post.amount/d') <= 0 || I('post.account/d') <= 0 || I('post.reason') == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '数据获取失败']);
        }

        $id = I('post.id/d');
        $account = I('post.account/d'); // 玩家ID
        $amount = I('post.amount/d');   // 提现金额
        $reason = I('post.reason'); // 原因
        $up_data['bk_PeopleRes'] = 2;   // 订单状态
        $up_data['bk_PeopleResDetail'] = $reason;   // 人工处理详细结果
        $up_data['bk_PeopleAccount'] = $this->login_admin_info['bk_name'];  // 人工处理账号
        $up_data['bk_PeopleTime'] = time(); // 人工处理时间
        $up_data['bk_OrderState'] = 6;  // 订单状态
        $result = M('bk_tixianorder')->where(array('bk_ID' => $id))->save($up_data);
        if (intval($result) > 0) {
            //与服务器通信
            $str = pack("L", $account) . pack("L", $amount);
            sendToGame(C('socket_ip'), 30000, 1032, $str);
            $this->ajaxReturn(array('code' => 0));
        }
    }

    // 提现记录
    public function withdrawalsRecord() {
        $where_data = $data = $export = array();

        $TXDD_STATE = C('TXDD_STATE');  // 订单状态
        $TX_CLASS = C('TX_CLASS');    // 提现分类

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->assign('TXDD_STATE', $TXDD_STATE);
            $this->assign('txdd_class', $TX_CLASS);
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');
        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');   // 玩家ID
        }
        if (I('get.nickname') != '') {
            $where_data['bk_AccountName'] = I('get.nickname');  // 玩家昵称
        }
        if (I('get.order') != '') {
            $where_data['bk_OrderNum'] = I('get.order');    // 订单号
        }
        if (I('get.txdd_class/d') > 0) {
            $where_data['bk_Type'] = I('get.txdd_class/d'); // 提现类型
        }
        if (I('get.TXDD_STATE/d') > 0) {
            $where_data['bk_OrderState'] = I('get.TXDD_STATE/d');
        } else {
            $where_data['_string'] = 'bk_OrderState=2 OR bk_OrderState=5 OR bk_OrderState=6';   // 订单状态
        }
        if (I('get.sren') != '') {
            $where_data['bk_ReceiveAccount'] = intval(M('bk_account')->where(['bk_Name' => I('get.sren')])->getField('bk_AccountID')); // 接收人
            if ($where_data['bk_ReceiveAccount'] == 0) {
                $where_data['bk_ReceiveAccount'] = 10000000;
            }
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
            $where_data['bk_CreateTime'] = array('between', array($s_time, $e_time));   // 起始时间
        }

        $layui_data['count'] = M('bk_tixianorder')->where($where_data)->count();
        $order = 'bk_CreateTime desc';
        $fields = 'bk_ID, bk_Type, bk_OrderNum, bk_AccountID, bk_TiXianName, bk_AccountName, bk_CreateTime, bk_TiXian, 
        bk_Overage, bk_TixianRMB, bk_nShouXuFei, bk_EarlyWarning, bk_ChargeDesc, bk_VerifyAccount, bk_VerifyTime, bk_PassProcessTime, bk_PeopleAccount, 
        bk_PeopleResDetail, bk_PeopleTime, bk_DakuanTime, bk_OrderState';
        $Query = M('bk_tixianorder')->field($fields)->where($where_data)->order($order);
        if (I('get.isExecl/d') == 0) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        $layui_data['tixianTotal'] = sprintf('%.2f', M('bk_tixianorder')->where($where_data)->sum('bk_tixianrmb-bk_nshouxufei / 10000'));
        $number = 1;
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_id'];
            $data['number'] = $number;  // 序号
            $data['TX_CLASS'] = $TX_CLASS[$val['bk_type']]; // 提现类型
            $data['order'] = $val['bk_ordernum'];   // 提现订单
            $data['account'] = $val['bk_accountid'];    // 玩家ID
            $data['name'] = $val['bk_tixianname'] == '0' ? '' : $val['bk_tixianname'];  // 玩家名字
            $data['nickname'] = $val['bk_accountname']; // 玩家昵称
            $data['time'] = date('Y-m-d H:i:s', $val['bk_createtime']);   // 提现申请时间
            $data['charge_sum'] = $val['bk_chargedesc'];   // 充值内容
            $data['ytx_sum'] = $val['bk_tixian'] / 10000;   // 已提现金额
            $data['overage'] = ($val['bk_overage'] / 10000);   // 余额
            $data['tx_amount'] = $val['bk_tixianrmb'];  // 提现金额
            $flag = $val['bk_earlywarning'];    // 预警内容
            $data['flag'] = $flag == '' ? 0 : 1;    // 预警标志;
            $data['warning'] = $flag;
            $data['tx_rate'] = ($val['bk_nshouxufei']) / 10000;   // 提现手续费
            $data['tx_real_amount'] = ($data['tx_amount'] - $data['tx_rate']);    // 实际提现金额
            $data['sh_operator'] = $val['bk_verifyaccount'];    // 审核人
            $data['sh_time'] = ($val['bk_verifytime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_verifytime']));  // 审核时间
            $data['tdtx_time'] = ($val['bk_passprocesstime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_passprocesstime']));  // 通道处理时间
            $data['rg_operator'] = ($val['bk_peopleaccount'] == '0' ? '' : $val['bk_peopleaccount']); // 人工处理账号
            $data['RGCL_RES_detail'] = ($val['bk_peopleresdetail'] == '0' ? '' : $val['bk_peopleresdetail']); // 人工处理结果
            $data['rgcl_time'] = ($val['bk_peopletime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_peopletime']));    // 人工处理时间
            $data['dk_time'] = ($val['bk_dakuantime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_dakuantime']));  // 打款时间
            $data['result'] = $TXDD_STATE[$val['bk_orderstate']];   // 订单状态
            $data['result_'] = $val['bk_orderstate'];
            $layui_data['data'][] = $data;

            //数据导出
            $export['number'] = $data['number'];
            $export['TX_CLASS'] = $data['TX_CLASS'];
            $export['order'] = $data['order'];
            $export['account'] = $data['account'];
            $export['name'] = $data['name'];
            $export['nickname'] = $data['nickname'];
            $export['charge_sum'] = $data['charge_sum'];
            $export['ytx_sum'] = $data['ytx_sum'];
            $export['overage'] = $data['overage'];
            $export['tx_amount'] = $data['tx_amount'];
            $export['warning'] = $data['warning'];
            $export['tx_rate'] = $data['tx_rate'];
            $export['tx_real_amount'] = $data['tx_real_amount'];
            $export['time'] = $data['time'];
            $export['sh_operator'] = $data['sh_operator'];
            $export['sh_time'] = $data['sh_time'];
            $export['tdtx_time'] = $data['tdtx_time'];
            $export['rg_operator'] = $data['rg_operator'];
            $export['RGCL_RES_detail'] = $data['RGCL_RES_detail'];
            $export['rgcl_time'] = $data['rgcl_time'];
            $export['dk_time'] = $data['dk_time'];
            $export['result'] = $data['result'];
            $export['data'][] = $export;
            $number++;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.withdraw_record'), $export['data'], '提现记录');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 订单查询
    public function orderInquiry() {
        $where_data = $data = array();

        $TX_TYPE = C('TX_TYPE');    // 提现类型
        $HTSH_RES = C('HTSH_RES');  // 后台审核结果
        $TDTX_RES = C('TDTX_RES');  // 提现通道结果
        $RGCL_RES = C('RGCL_RES');  // 人工处理结果
        $DD_STATE = C('DD_STATE');  // 订单状态
        $TX_CLASS = C('TX_CLASS');  // 提现分类

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->assign('txdd_class', $TX_CLASS);
            $this->assign('DD_STATE', $DD_STATE);
            $this->assign('TX_TYPE', $TX_TYPE);
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');
        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');   // 玩家ID
        }
        if (I('get.nickname') != '') {
            $where_data['bk_AccountName'] = I('get.nickname');  // 玩家昵称
        }
        if (I('get.order') != '') {
            $where_data['bk_OrderNum'] = I('get.order');    // 订单号
        }
        if (I('get.txdd_class/d') > 0) {
            $where_data['bk_Type'] = I('get.txdd_class/d'); // 提现分类
        }
        if (I('get.txType/d') > 0) {
            $where_data['bk_TixianType'] = I('get.txType/d');   // 提现类型
        }
        if (I('get.DD_STATE/d') > 0) {
            $where_data['bk_OrderState'] = I('get.DD_STATE/d'); // 订单状态
        }
        $selectTime = 'bk_CreateTime';
        if (I('get.selectTime') == 'PayTime') {
            $selectTime = 'bk_DakuanTime';  // 打款时间
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
            $where_data[$selectTime] = array('between', array($s_time, $e_time));   // 起始时间
        }
        if (I('get.sren') != '') {
            $where_data['bk_ReceiveAccount'] = intval(M('bk_account')->where(['bk_Name' => I('get.sren')])->getField('bk_AccountID')); // 接收人
            if ($where_data['bk_ReceiveAccount'] == 0) {
                $where_data['bk_ReceiveAccount'] = 10000000;
            }
        }
        $tixianTotal_where_data = $where_data;
        if (I('get.start_time') == '' || I('get.end_time') == '') {
            $tixianTotal_where_data['bk_CreateTime'] = array('between', array(strtotime(date('Y-m-d')), time()));   // 起始时间
        }

        $layui_data['count'] = M('bk_tixianorder')->where($where_data)->count();
        $order = 'bk_CreateTime desc';
        if (I('get.sortTime') == 'PayTime') {
            $order = 'bk_DakuanTime desc';
        }
        $Query = M('bk_tixianorder')->where($where_data)->order($order);
        if (I('get.isExecl/d') == 0) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }
        $data_list = $Query->select();
        $layui_data['tixianTotal'] = sprintf('%.2f', M('bk_tixianorder')->where($tixianTotal_where_data)->sum('bk_tixianrmb - bk_nshouxufei / 10000'));
        $layui_data['sql'] = M('bk_tixianorder')->getLastSql();
        foreach ($data_list as $key => $val) {
            $data['TX_CLASS'] = $TX_CLASS[$val['bk_type']]; // 提现分类
            $data['order'] = $val['bk_ordernum'];   // 订单号
            $data['create_time'] = date('Y-m-d H:i:s', $val['bk_createtime']);  // 提现申请时间
            $data['request_ip'] = $val['bk_requestip']; // 来自IP
            $data['device_code'] = $val['bk_devicecode'];   // 设备码
            $data['account'] = $val['bk_accountid'];    // 玩家ID
            $data['name'] = $val['bk_tixianname'] == '0' ? '' : $val['bk_tixianname'];  // 姓名
            $data['nickname'] = $val['bk_accountname']; // 玩家昵称
            $data['amount'] = $val['bk_tixianrmb']; // 提现金额
            $flag = $val['bk_earlywarning'];   // 预警内容
            if (I('get.isExecl/d') == 0) $data['flag'] = $flag == '' ? 0 : 1;    // 预警标志;
            $data['warning'] = $flag;
            $data['tx_rate'] = ($val['bk_nshouxufei'] / 10000); // 提现手续费
            $data['tx_real_amount'] = ($data['amount'] - $data['tx_rate']); // 实际提现金额
            $data['type'] = $TX_TYPE[$val['bk_tixiantype']];    // 提现类型
            $data['tx_account'] = $val['bk_tixianaccount']; // 目标账号
            $data['sh_result'] = $HTSH_RES[$val['bk_verifyres']];   // 后台审核结果
            if (I('get.isExecl/d') == 0) $data['flag_sh'] = $val['bk_verifyres'];   // 审核结果标记
            $data['sh_operator'] = ($val['bk_verifyaccount'] == '0' ? '' : $val['bk_verifyaccount']);   //  后台审核账号
            $data['sh_detail'] = ($val['bk_verifydetail'] == '0' ? '' : $val['bk_verifydetail']);   // 后台审核结果详细
            $data['sh_time'] = ($val['bk_verifytime'] == 0 ? '' : (date('Y-m-d H:i:s', $val['bk_verifytime'])));    // 后台审核时间
            $data['tx_pass'] = ($val['bk_passname'] == 0 ? '' : $val['bk_passname']);   // 提现通道
            $data['tx_pass_result'] = $TDTX_RES[$val['bk_passres']];    // 通道提现结果
            if (I('get.isExecl/d') == 0) $data['flag_td'] = $val['bk_passres']; // 通道结果标记
            $data['tx_process_time'] = ($val['bk_passprocesstime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_passprocesstime']));    // 通道提现处理时间
            $data['rg_result'] = $RGCL_RES[$val['bk_peopleres']];   // 人工处理结果
            $data['RGCL_RES_detail'] = ($val['bk_peopleresdetail'] == '0' ? '' : $val['bk_peopleresdetail']);   // 人工处理结果详细
            if (I('get.isExecl/d') == 0) $data['flag_rg'] = $val['bk_peopleres'];   // 人工处理结果标记
            $data['rg_operator'] = ($val['bk_peopleaccount'] == '0' ? '' : $val['bk_peopleaccount']);   // 人工处理账号
            $data['rg_time'] = ($val['bk_peopletime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_peopletime']));  // 人工处理时间
            $data['dk_time'] = ($val['bk_dakuantime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_dakuantime']));  // 打款时间
            $data['state'] = $DD_STATE[$val['bk_orderstate']];  // 订单状态
            if (I('get.isExecl/d') == 0) $data['flag_result'] = $val['bk_orderstate'];  // 订单状态标记
            $layui_data['data'][] = $data;
        }

        if (1 == I('get.isExecl/d')) {
            $this->doExcelData(C('cellName.order_inquiry'), $layui_data['data'], '订单查询');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 预警配置
    public function earlyWarningConfig() {
        $data_list = M('bk_earlywarningconfig')->where(array('bk_ID' => 2))->find();   // 默认值
        $default_data['condition1'] = ($data_list['bk_condition1'] == 0 ? '' : ($data_list['bk_condition1']));
        $default_data['condition2'] = ($data_list['bk_condition2'] == 0 ? '' : $data_list['bk_condition2']);
        $default_data['condition3'] = ($data_list['bk_condition3'] == 0 ? '' : ($data_list['bk_condition3']));
        $default_data['condition4'] = ($data_list['bk_condition4'] == 0 ? '' : ($data_list['bk_condition4']));
        $default_data['condition5'] = ($data_list['bk_condition5'] == 0 ? '' : $data_list['bk_condition5']);
        $default_data['condition6'] = ($data_list['bk_condition6'] == 0 ? '' : $data_list['bk_condition6']);

        if (!IS_AJAX) {
            $this->assign('default_data', $default_data);
            $this->show();
            return;
        }

        $data = array();

        // 配置1-4,6只能是正整数和0   配置5只能是正数和0
        $pattern1 = '/^[1-9]\d*|[0]{1,1}$/';    // 正整数   0表示重置
        $pattern2 = '/^\d+(\.{0,1}\d+){0,1}$/'; // 正数   0表示重置

        if (I('post.condition1') != '') {
            if (!preg_match($pattern1, I('post.condition1'))) {
                $this->ajaxReturn(array('code' => 1, 'message' => '配置1参数错误'));
            }
            $data['bk_Condition1'] = I('post.condition1/d');
        }
        if (I('post.condition2') != '') {
            if (!preg_match($pattern1, I('post.condition2'))) {
                $this->ajaxReturn(array('code' => 1, 'message' => '配置2参数错误'));
            }
            $data['bk_Condition2'] = I('post.condition2/d');
        }
        if (I('post.condition3') != '') {
            if (!preg_match($pattern1, I('post.condition3'))) {
                $this->ajaxReturn(array('code' => 1, 'message' => '配置3参数错误'));
            }
            $data['bk_Condition3'] = I('post.condition3/d');
        }
        if (I('post.condition4') != '') {
            if (!preg_match($pattern1, I('post.condition4'))) {
                $this->ajaxReturn(array('code' => 1, 'message' => '配置4参数错误'));
            }
            $data['bk_Condition4'] = I('post.condition4/d');
        }
        if (I('post.condition5') != '') {
            if (!preg_match($pattern2, I('post.condition5'))) {
                $this->ajaxReturn(array('code' => 1, 'message' => '配置5参数错误'));
            }
            $data['bk_Condition5'] = I('post.condition5');
        }
        if (I('post.condition6') != '') {
            if (!preg_match($pattern1, I('post.condition6'))) {
                $this->ajaxReturn(array('code' => 1, 'message' => '配置6参数错误'));
            }
            $data['bk_Condition6'] = I('post.condition6/d');
        }

        $data['bk_Operator'] = $this->login_admin_info['bk_name'];  // 操作人
        $data['bk_Time'] = time();  // 操作时间

        $count = array();
        $count['count'] = M('bk_earlywarningconfig')->count();
        if ($count['count'] > 0) {
            $result = M('bk_earlywarningconfig')->where(array('bk_ID' => 2))->save($data);
        } else {
            $result = M('bk_earlywarningconfig')->add($data);
        }
        if (intval($result) > 0) {
            // 与服务器通信
            $str = pack('L', $data_list['bk_condition1']) . pack('L', $data_list['bk_condition2']) .
                pack('L', $data_list['bk_condition3']) . pack('L', $data_list['bk_condition4']) .
                pack('f', $data_list['bk_condition5']) . pack('L', $data_list['bk_condition6']);
            sendToGame(C('socket_ip'), 30000, 1043, $str);
            $this->ajaxReturn(array('code' => 0));
        }
    }

    // 提现调控-提现类型
    public function withdrawType() {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $layui_data['count'] = M('bk_payorwithdrawchannel')->count();
        $order = 'bk_Time desc';
        $data_list = M('bk_payorwithdrawchannel')->order($order)->page(I('page/d'))->limit(I('limit/d'))->select();
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_id'];
            $data['type_id'] = $val['bk_typeid'];
            $data['name'] = $val['bk_typename'];
            $data['operator'] = $val['bk_operator'];
            $data['time'] = date('Y-m-d H:i:s', $val['bk_time']);
            $data['amendUrl'] = U('withdraw/amendWithdrawType', array('id' => $val['bk_id']));
            $layui_data['data'][] = $data;
        }
        $layui_data['page'] = I('get.page/d');
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 提现调控-提现类型-新建
    public function addWithdrawType() {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        if (I('post.withdrawTypeID') != '' && I('post.withdrawTypeName') != '') {

            $pattern1 = '/^[1-9]\d*$/';
            if (!preg_match($pattern1, I('post.withdrawTypeID'))) {
                $this->ajaxReturn(array('code' => 1, 'message' => '参数错误，正能填写正整数'));
            }

            $count_type = M('bk_payorwithdrawchannel')->where(array('bk_TypeID' => I('post.withdrawTypeID/d')))->count();
            if ($count_type > 0) {
                $this->ajaxReturn(array('code' => 1, 'message' => '参数错误，该提现类型ID已经存在'));
            }

            $count_name = M('bk_payorwithdrawchannel')->where(array('bk_TypeName' => I('post.withdrawTypeName')))->count();
            if ($count_name > 0) {
                $this->ajaxReturn(array('code' => 1, 'message' => '参数错误，该提现类型名称已经存在'));
            }

            $data['bk_TypeID'] = I('post.withdrawTypeID/d');
            $data['bk_TypeName'] = I('post.withdrawTypeName');
            $data['bk_Operator'] = $this->login_admin_info['bk_name'];
            $data['bk_Time'] = time();

            $result = M('bk_payorwithdrawchannel')->add($data);
            intval($result) > 0 ? $this->ajaxReturn(array('code' => 0)) : $this->ajaxReturn(array('code' => 1, 'message' => '数据存储失败'));
        } else {
            $this->ajaxReturn(array('code' => 1, 'message' => '数据丢失'));
        }
    }

    // 提现调控-提现类型-提现类型名称修改
    public function amendWithdrawType() {
        $id = I('get.id/d');
        $row = M('bk_payorwithdrawchannel')->where(array('bk_ID' => $id))->find();
        $this->assign('row', $row);
        $this->show();
    }

    // 提现调控-提现类型-提现类型名称修改
    public function doWithdrawType() {
        if (I('post.withdrawTypeName') != "" && I('post.id/d') > 0) {

            $data['bk_TypeName'] = I('post.withdrawTypeName');
            $result = M('bk_payorwithdrawchannel')->where(array('bk_ID' => I('post.id/d')))->save($data);

            if (intval($result) > 0) {
                $this->ajaxReturn(array('code' => 0));
            }
        }
    }

    // 提现调控-提现厂商
    public function withdrawVendor() {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $layui_data['count'] = M('bk_withdrawvendor')->count();
        $order = 'bk_Time desc';
        $data_list = M('bk_withdrawvendor')->order($order)->page(I('page/d'))->limit(I('limit/d'))->select();
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_id'];
            $data['vendor_id'] = $val['bk_vendorid'];
            $data['name'] = $val['bk_vendorname'];
            $data['operator'] = $val['bk_operator'];
            $data['time'] = date('Y-m-d H:i:s', $val['bk_time']);
            $data['amendUrl'] = U("withdraw/amendWithdrawVendor", array('id' => $val['bk_id']));
            $layui_data['data'][] = $data;
        }
        $layui_data['page'] = I('get.page/d');
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 提现调控-提现厂商-新建
    public function addWithdrawVendor() {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        if (I('post.withdrawVendorID') != '' && I('post.withdrawVendorName') != '') {

            $pattern1 = '/^[1-9]\d*$/';
            if (!preg_match($pattern1, I('post.withdrawVendorID'))) {
                $this->ajaxReturn(array('code' => 1, 'message' => '参数错误，正能填写正整数'));
            }

            $count_type = M('bk_withdrawvendor')->where(array('bk_VendorID' => I('post.withdrawVendorID/d')))->count();
            if ($count_type > 0) {
                $this->ajaxReturn(array('code' => 1, 'message' => '参数错误，该提现类型ID已经存在'));
            }

            $count_name = M('bk_withdrawvendor')->where(array('bk_VendorName' => I('post.withdrawVendorName')))->count();
            if ($count_name > 0) {
                $this->ajaxReturn(array('code' => 1, 'message' => '参数错误，该提现类型名称已经存在'));
            }

            $data['bk_VendorID'] = I('post.withdrawVendorID/d');
            $data['bk_VendorName'] = I('post.withdrawVendorName');
            $data['bk_Operator'] = $this->login_admin_info['bk_name'];
            $data['bk_Time'] = time();

            $result = M('bk_withdrawvendor')->add($data);
            intval($result) > 0 ? $this->ajaxReturn(array('code' => 0)) : $this->ajaxReturn(array('code' => 1, 'message' => '数据存储失败'));
        } else {
            $this->ajaxReturn(array('code' => 1, 'message' => '数据丢失'));
        }
    }

    // 提现调控-提现厂商-提现厂商名称修改
    public function amendWithdrawVendor() {
        $id = I('get.id/d');
        $row = M('bk_withdrawvendor')->where(array('bk_ID' => $id))->find();
        $this->assign('row', $row);
        $this->show();
    }

    // 提现调控-提现厂商-提现厂商名称修改
    public function doWithdrawVendor() {
        if (I('post.withdrawVendorName') != '' && I('post.id/d') > 0) {
            $data['bk_VendorName'] = I('post.withdrawVendorName');
            $result = M('bk_withdrawvendor')->where(array('bk_ID' => I('post.id/d')))->save($data);

            if (intval($result) > 0) {
                $this->ajaxReturn(array('code' => 0));
            }
        }
    }

    // 提现调控-提现通道查看
    public function withdrawChannelCheck() {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $layui_data['count'] = M('bk_tixianpassconf')->count();
        $order = 'bk_OperateTime desc';
        $data_list = M('bk_tixianpassconf')->order($order)->page(I('page/d'))->limit(I('limit/d'))->select();
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_passid'];
            $apk_str = '';
            if ($val['bk_apkid'] == 'all') {
                $apk_list = M('bk_apk')->select();
                foreach ($apk_list as $key => $value) {
                    $apk_str .= $value['bk_apk'] . ' ';
                }
            } else {
                foreach (explode(',', $val['bk_apkid']) as $apl_val) {
                    $apk_str .= (M('bk_apk')->where(array('bk_ApkID' => $apl_val))->getField('bk_Apk') . ' ');
                }
            }
            $data['apk'] = $apk_str;

            $data['pass'] = $val['bk_passname'];
            $data['limit'] = $val['bk_vendorname'];
            $data['overage'] = '[' . $val['bk_pertxmin'] . ',' . $val['bk_pertxmax'];
            $layui_data['data'][] = $data;
        }
        $layui_data['page'] = I('get.page/d');
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 提现调控-提现通道调控
    public function withdrawChannelRegulation() {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $s_time = date('Y-m-d H:i:s', mktime(0, 0, 0, date('m'), date('d'), date('Y')));
        $e_time = date('Y-m-d H:i:s', mktime(0, 0, 0, date('m'), date('d') + 1, date('Y')) - 1);

        $layui_data['count'] = M('bk_tixianpassconf')->count();
        $order = 'bk_OperateTime desc';
        $data_list = M('bk_tixianpassconf')->order($order)->page(I('page/d'))->limit(I('limit/d'))->select();
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_passid'];

            $apk_str = '';
            if ($val['bk_apkid'] == 'all') {
                $apk_list = M('bk_apk')->select();
                foreach ($apk_list as $key => $value) {
                    $apk_str .= $value['bk_apk'] . ' ';
                }
            } else {
                foreach (explode(',', $val['bk_apkid']) as $apl_val) {
                    $apk_str .= (M('bk_apk')->where(array('bk_ApkID' => $apl_val))->getField('bk_Apk') . ' ');
                }
            }

            $data['apk'] = $apk_str;

            $data['pass'] = $val['bk_passname'];
            $data['merchants'] = $val['bk_factname'];

            $tixianorder_all = M('bk_tixianorder')->field(array('COUNT(bk_ID) AS count', 'SUM(bk_TixianRMB) AS sum_all'))
                ->where(array('bk_PassProcessTime' => array('between', array($s_time, $e_time)), 'bk_PassName' => $val['bk_passid']))
                ->select();
            $data['count_all'] = $tixianorder_all['count'];
            $data['sum_all'] = ($tixianorder_all['sum_all'] / 10000);

            $tixianorder_failure = M('bk_tixianorder')->field(array('COUNT(bk_ID) AS count', 'SUM(bk_TixianRMB) AS sum_failure'))
                ->where(array('bk_PassProcessTime' => array('between', array($s_time, $e_time)), 'bk_PassName' => $val['bk_passid'], 'bk_PassRes' => 1))
                ->select();
            $data['count_failure'] = $tixianorder_failure['count'];
            $data['sum_failure'] = ($tixianorder_failure['sum_failure'] / 10000);

            $tixianorder_success = M('bk_tixianorder')->field(array('COUNT(bk_ID) AS count', 'SUM(bk_TixianRMB) AS sum_success'))
                ->where(array('bk_PassProcessTime' => array('between', array($s_time, $e_time)), 'bk_PassName' => $val['bk_passid'], 'bk_PassRes' => array(array('eq', 2), array('eq', 3), 'or')))
                ->select();
            $data['count_success'] = $tixianorder_success['count'];
            $data['sum_success'] = ($tixianorder_success['sum_success'] / 10000);

            $data['rate'] = ($data['count_all'] == 0 ? '100%' : ($data['count_success'] == 0 ? '0%' : (sprintf('%.4f', $data['count_success'] / $data['count_all']) * 100 . '%')));
            $data['flag'] = ($data['count_all'] == 0 ? 100 : ($data['count_success'] == 0 ? 0 : $data['count_success'] / $data['count_all'])) >= 90 ? 'true' : 'false';
            $data['overage'] = $val['bk_balance'];
            $data['state'] = ($val['bk_state'] == 1 ? '开启' : '关闭');
            $data['weights'] = $val['bk_weight'];
            $layui_data['data'][] = $data;
        }
        $layui_data['page'] = I('get.page/d');
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 提现调控-提现通道调控-开启/关闭
    public function doWithdrawChannelRegulation() {
        $id = I('post.id/d');
        $state = I('post.state/d');

        if ($id == 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        if (!in_array($state, array(0, 1))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        $result = M('bk_tixianpassconf')->where(array('bk_PassID' => $id))->data(array('bk_State' => $state, 'bk_Operator' => $this->login_admin_info['bk_name'], 'bk_OperateTime' => time()))->save();

        if (intval($result) > 0) {
            $this->ajaxReturn(array('code' => 0));
        }
    }

    // 提现调控-提现通道调控-权重修改
    public function doEditWeights() {
        $id = I('post.id/d');
        $editWeights = I('post.editWeights/d');

        if ($id == 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        if (!in_array($editWeights, array(1, 10))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        $result = M('bk_tixianpassconf')->where(array('bk_PassID' => $id))->data(array('bk_Weight' => $editWeights, 'bk_Operator' => $this->login_admin_info['bk_name'], 'bk_OperateTime' => time()))->save();

        if (intval($result) > 0) {
            $this->ajaxReturn(array('code' => 0));
        }
    }
}