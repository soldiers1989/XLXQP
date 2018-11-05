<?php
namespace Home\Controller;
class ConfigManagementController extends BaseController {
    public function index() {
        $this->show();
    }

    // 支付入口切换
    public function paymentEntranceSwitch() {
        $paymentType = C('PAYMENT_TYPE');

        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $apkList_row = M('bk_apk')->select();
        foreach ($apkList_row as $key => $val) {
            $apkList[$val['bk_apkid']] = $val['bk_apk'];
        }
        $layui_data['count'] = M('bk_paycontrolconf')->count();
        $data_row = M('bk_paycontrolconf')->page(I('get.page/d'))->limit(I('get.limit/d'))->order('bk_ID desc')->select();
        $number = 1;
        foreach ($data_row as $key => $val) {
            $data['id'] = $val['bk_id'];
            $data['number'] = $number++;
            $apk_list_func = function () use($val, $apkList) {
                if ($val['bk_apkid'] == 'all') {
                    return implode(',', $apkList);
                } elseif (!empty($val['bk_apkid'])) {
                    $carr = explode(',', $val['bk_apkid']);
                    foreach ($carr as $k => $v) {
                        isset($apkList[$v]) && ($carr[$k] = $apkList[$v]);
                    }
                    return $carr;
                }
            };
            $data['apk'] = $apk_list_func();
            $data['paymentType'] = $paymentType[$val['bk_paytypeid']];
            $data['range'] = $val['bk_mincharge'] . ' - ' . $val['bk_maxcharge'];
            $data['recommendAmount'] = $val['bk_chargelist'];
            $data['weight'] = $val['bk_weight'];
            $data['label'] = $val['bk_ishot'] == 1 ? '推荐' : '无';
            $data['state'] = $val['bk_state'];
            $data['time'] = date('Y-m-d H:i:s', $val['bk_time']);
            $data['operator'] = $val['bk_operator'];
            $data['dataURL'] = U('configManagement/editPaymentEntrance', ['id' => $val['bk_id']]);
            $layui_data['data'][] = $data;
        }
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 添加支付入口
    public function addPaymentEntrance() {
        $paymentType = C('PAYMENT_TYPE');
        $apk_row = M('bk_apk')->select();
        foreach ($apk_row as $key => $val) {
            $apkList[$val['bk_apkid']] = $val['bk_apk'];
        }
        $this->assign('apkList', $apkList);
        $this->assign('paymentList', $paymentType);
        $this->show();
    }

    // 支付入口添加
    public function doAddPaymentEntrance() {
        $apkAll = I('post.apkAll'); // 判断apk
        if ($apkAll == 'all') {
            $apkID = 'all';
        } else {
            $apk = I('post.apk');
            if (count($apk) == 0 || !is_array($apk)) $this->ajaxReturn(['code' => 1, 'message' => '请选择APK包']);
            $apkID = implode(',', $apk);
        }
        $insert_data['bk_APKID'] = $send_data['apk'] = $apkID;
        $insert_data['bk_PayTypeID'] = $send_data['paymentType'] = I('post.paymentType/d');
        $insert_data['bk_MinCharge'] = $send_data['minAmount'] = I('post.minAmount/d');
        $insert_data['bk_MaxCharge'] = $send_data['maxAmount'] = I('post.maxAmount/d');
        $insert_data['bk_Weight'] = $send_data['weight'] = I('post.weight/d');
        $insert_data['bk_ChargeList'] = $send_data['recommendAmount'] = I('post.recommendAmount');
        $insert_data['bk_IsHot'] = $send_data['label'] = I('post.label/d');
        $insert_data['bk_State'] = $send_data['state'] = I('post.state/d');
        $insert_data['bk_Operator'] = $this->login_admin_info['bk_name'];;
        $insert_data['bk_Time'] = time();
        if (M('bk_paycontrolconf')->where(['bk_PayTypeID' => $insert_data['bk_PayTypeID']])->count() > 0) $this->ajaxReturn(['code' => 1, 'message' => '该支付类型已存在,请勿重复添加']);
        if ($insert_data['bk_PayTypeID'] <=0) $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        if ($insert_data['bk_MinCharge'] < 0 || $insert_data['bk_MaxCharge'] < 0) $this->ajaxReturn(['code' => 1, 'message' => '充值范围,不能输入负数']);
        if ($insert_data['bk_MinCharge'] > $insert_data['bk_MaxCharge']) $this->ajaxReturn(['code' => 1, 'message' => '充值范围,最小值不能大于最大值']);
        if ($insert_data['bk_Weight'] > 999 || $insert_data['bk_Weight'] <=0) $this->ajaxReturn(['code' => 1, 'message' => '权重值范围:1-999']);
        // 判定推荐金额
        $price_list_func = function () use ($insert_data) {
            $price_list = $insert_data['bk_ChargeList'];
            if (empty($price_list)) return ['code' => 1, 'message' => '推荐定额不能为空'];
            $price_list_array = explode(',', $price_list);
            if (count($price_list_array) > 8) return ['code' => 1, 'message' => '推荐定额个数不能大于8个'];
            foreach ($price_list_array as $val) {
                if (intval($val) < $insert_data['bk_MinCharge'] || intval($val) > $insert_data['bk_MaxCharge']) return ['code' => 1, 'message' => '推荐定额 必须介于充值范围'];
                if (intval($val) == 0) return ['code' => 1, 'message' => '推荐金额,非法数据'];
            }
            return ['code' => 0];
        };
        $price_list = $price_list_func();
        if ($price_list['code'] == 1) $this->ajaxReturn($price_list);
        if (!in_array($insert_data['bk_IsHot'], [0, 1])) $this->ajaxReturn(['code' => 1, 'message' => '角标,非法数据']);
        if (!in_array($insert_data['bk_State'], [0, 1])) $this->ajaxReturn(['code' => 1, 'message' => '状态,非法数据']);
        $result = M('bk_paycontrolconf')->data($insert_data)->add();
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1, 'message' => '添加失败']);
        $this->sendGameMessagePaymentEntrance($send_data, 1028);
        $this->ajaxReturn(['code' => 0]);
    }

    // 支付入口是否开启
    public function doPaymentEntranceIsNo() {
        $result = M('bk_paycontrolconf')->where(['bk_ID' => I('post.id/d')])->find();
        $send_data['apk'] = $result['bk_apkid'];
        $send_data['paymentType'] = $result['bk_paytypeid'];
        $send_data['minAmount'] = $result['bk_mincharge'];
        $send_data['maxAmount'] = $result['bk_maxcharge'];
        $send_data['weight'] = $result['bk_weight'];
        $send_data['isHot'] = $result['bk_ishot'];
        $send_data['recommendAmount'] = $result['bk_chargelist'];
        if (!in_array(I('post.isNo/d'), [0, 1])) $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        $send_data['state'] = I('post.isNo/d');
        $result1 = M('bk_paycontrolconf')->where(['bk_ID' => I('post.id/d')])->save(['bk_State' => I('post.isNo/d')]);
        if ($result1 <=0) $this->ajaxReturn(['code' => 1]);
        $this->sendGameMessagePaymentEntrance($send_data, 1029);
        $this->ajaxReturn(['code' => 0]);
    }

    // 支付入口编辑
    public function editPaymentEntrance() {
        $paymentType = C('PAYMENT_TYPE');
        $apk_row = M('bk_apk')->select();
        foreach ($apk_row as $key => $val) {
            $apkList[$val['bk_apkid']] = $val['bk_apk'];
            $apkLists[] = $val['bk_apkid'];
        }
        $this->assign('apkList', $apkList);
        $this->assign('paymentList', $paymentType);

        $result = M('bk_paycontrolconf')->where(['bk_ID' => I('post.id/d')])->find();
        $data['apkAll'] = trim($result["bk_apkid"]) == 'all' ? 1 : 0;
        $data['apk'] = $result['bk_apkid'] == 'all' ? $apkLists : explode(',', $result['bk_apkid']);
        $this->assign('paymentEntranceInfo', $data);
        $this->show();
    }






    // 与服务器通信-支付入口
    public function sendGameMessagePaymentEntrance($data, $protocol) {
        $send_data['apk'] = pack('S', strlen($data['apk'])); // apk
        $send_data['paymentType'] = pack('C', $data['paymentType']);    // 支付类型
        $send_data['minAmount'] = pack('L', $data['minAmount']);  // 最小金额
        $send_data['maxAmount'] = pack('L', $data['maxAmount']);  // 最大金额
        $send_data['state'] = pack('C', $data['state']);   // 状态
        $send_data['weight'] = pack('C', $data['weight']); // 权重
        $send_data['isHot'] = pack('C', $data['isHot']);   // 角标
        $send_data['recommendAmount'] = pack('S', strlen($data['recommendAmount'])); // 推荐金额
        $body = $send_data['apk'] . $data['bk_APKID'] . $send_data['paymentType'] . $send_data['minAmount'] . $send_data['maxAmount'] . $send_data['state'] . $send_data['weight'] . $send_data['isHot'] . $send_data['recommendAmount'] . $data['recommendAmount'];
        SendToGame(C('SOCKET_IP'), 30000, $protocol, $body);
    }
}
?>