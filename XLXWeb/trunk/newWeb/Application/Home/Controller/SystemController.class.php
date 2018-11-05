<?php

namespace Home\Controller;
class SystemController extends BaseController
{
    public function index()
    {
        $this->show();
    }

    public function menuAdd()
    {
        $this->show();
    }

    //菜单修改
    public function doMenuUpdate()
    {
        $up_data['menu_URL'] = I('post.m_url');
        $up_data['menu_Name'] = I('post.m_name');
        $up_data['menu_ParentID'] = I('post.m_parentid/d');
        $up_data['menu_IsDisplay'] = I('post.m_isdisplay/d');
        $up_data['menu_LeftOrRight'] = I('post.m_leftorright/d');
        $up_data['menu_Sort'] = I('post.m_sort/d');
        $up_data['menu_OperationTime'] = time();
        $up_data['menu_Subset'] = 0;
        $up_data['menu_Operator'] = $this->login_admin_info['bk_name'];
        trim($up_data['menu_Name']) == "" && $this->ajaxReturn(array('code' => 1, 'message' => '菜单名不能为空'));
        $up_data['menu_Sort'] > 9999 && $this->ajaxReturn(array('code' => 1, 'message' => '排序最大最9999'));
        !in_array($up_data['menu_IsDisplay'], array(0, 1)) && $this->ajaxReturn(array('code' => 1, 'message' => '非法数据'));
        !in_array($up_data['menu_LeftOrRight'], array(0, 1)) && $this->ajaxReturn(array('code' => 1, 'message' => '非法数据'));

        //计算是会有子项
        M('bk_menu')->where(array(
            'menu_ID' => $up_data['menu_ParentID']
        ))->save(array(
            'menu_Subset' => 1
        ));

        $info = M('bk_menu')->where(array(
            'menu_ID' => I('post.id/d')
        ))->save($up_data);

        intval($info) > 0 && $this->ajaxReturn(array(
            'code' => 0
        ));
        $this->ajaxReturn(['code' => 1, ' 更新失败']);
    }

    //菜单添加
    public function doMenuAdd()
    {
        $insert_data['menu_URL'] = I('post.m_url');
        $insert_data['menu_Name'] = I('post.m_name');
        $insert_data['menu_ParentID'] = I('post.m_parentid/d');
        $insert_data['menu_IsDisplay'] = I('post.m_isdisplay/d');
        $insert_data['menu_LeftOrRight'] = I('post.m_leftorright/d');
        $insert_data['menu_Sort'] = I('post.m_sort/d');
        $insert_data['menu_OperationTime'] = time();
        $insert_data['menu_Subset'] = 0;
        $insert_data['menu_Operator'] = $this->login_admin_info['bk_name'];

        trim($insert_data['menu_Name']) == "" && $this->ajaxReturn(array('code' => 1, 'message' => '菜单名不能为空'));
        $insert_data['menu_Sort'] > 9999 && $this->ajaxReturn(array('code' => 1, 'message' => '排序最大最9999'));
        !in_array($insert_data['menu_IsDisplay'], array(0, 1)) && $this->ajaxReturn(array('code' => 1, 'message' => '非法数据'));
        !in_array($insert_data['menu_LeftOrRight'], array(0, 1)) && $this->ajaxReturn(array('code' => 1, 'message' => '非法数据'));

        //计算是会有子项
        M('bk_menu')->where(array(
            'menu_ID' => $insert_data['menu_ParentID']
        ))->save(array(
            'menu_Subset' => 1
        ));
        $info = M('bk_menu')->add($insert_data);
        if (intval($info) > 0) {
            $this->ajaxReturn(array(
                'code' => 0
            ));
        }
    }


    //菜单管理
    public function menuSeting()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $data['count'] = M("bk_menu")->count();
        $data_list = M("bk_menu")->order(["menu_OperationTime" => "desc"])->page(I('page/d'))->limit(I('limit/d'))->select();
        foreach ($data_list as $key => $val) {
            $parentMenu = $this->getOneMenu($val["menu_parentid"]);
            $data['data'][$key]['id'] = $val['menu_id'];
            $data['data'][$key]['name'] = $val['menu_name'];
            $data['data'][$key]['menu_parent'] = $parentMenu['menu_name'];
            $data['data'][$key]['leftorright'] = ($val['menu_leftorright'] == 0) ? "左侧" : "右侧";
            $data['data'][$key]['operator'] = $val['menu_operator'];
            $data['data'][$key]['sort'] = $val['menu_sort'];
            $data['data'][$key]['subset'] = ($val['menu_subset'] == 0) ? "无" : "有";
            $data['data'][$key]['isdisplay'] = $val['menu_isdisplay'];
            $data['data'][$key]['addtime'] = $val['menu_operationtime'];
            $data['data'][$key]['editUrl'] = U('system/editMenu', array(
                'id' => $val['menu_id']
            ));
        }
        $data['data'] = timeToDataTime($data['data'], array('addtime'), 'Y-m-d H:i');
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }


    //更新菜单排序
    public function doMenuSortUpdate()
    {
        $id = I('post.id/d');
        $msort = I('post.msort/d');
        if ($msort > 9999) {
            $this->ajaxReturn(['code' => 1, 'message' => '排序更新失败，不能大于9999']);
        }
        M('bk_menu')->where(['menu_ID' => $id])->save(['menu_Sort' => $msort]);
        $this->ajaxReturn(['code' => 0]);
    }

    //菜单编辑
    public function editMenu()
    {
        $id = I('get.id/d');
        $row = M('bk_menu')->where(array(
            'menu_ID' => $id
        ))->find();
        $this->assign('menu_row', $row);
        $this->show();
    }

    //更新是否显示
    public function doMenuIsDisplay()
    {
        $id = I('post.id/d');
        $isDisplay = I('post.isdisplay/d');
        if (!in_array($isDisplay, [0, 1])) {
            $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        }
        M('bk_menu')->where(['menu_ID' => $id])->save(['menu_IsDisplay' => $isDisplay]);
        $this->ajaxReturn(['code' => 0]);
    }

    //删除数据库
    public function doMenuDel()
    {
        $id = I('post.id/d');
        M('bk_menu')->where(array(
            'menu_ID' => $id
        ))->delete();
        $this->ajaxReturn(array(
            'code' => 0
        ));
    }

    //登录日志列表
    public function loginLog()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $rows = M("bk_log")->where(array("bk_Type" => 1))->page(I('get.page/d'))->limit(I('get.limit/d'))->order('bk_ID desc')->select();
        $data['count'] = M("bk_log")->where(array("bk_Type" => 1))->count();
        $data['page'] = I('get.page/d');
        foreach ($rows as $key => $row) {
            $row_data['account'] = $row['bk_account'];
            $row_data['time'] = date("Y-m-d H:i:s", $row['bk_time']);
            $row_data['ip'] = $row['bk_ip'];
            $row_data['log'] = $row['bk_log'];
            $data['data'][] = $row_data;
        }
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //支付通道列表
    public function payList()
    {
        $PayTypeID = C('pay');
        if (!IS_AJAX) {
            $this->assign('PayType', $PayTypeID);
            $this->show();
            return;
        }

        if (I('get.passame') != '') {
            $where['bk_PassName'] = ['like', '%' . I('get.passame') . '%'];
        }

        if (I('get.PayType/d') != 0) {
            $where['bk_PayTypeID'] = I('get.PayType');
        }

        $rows = M('bk_chargepassconf')->where($where)->page(I('get.page/d'))->limit(I('get.limit/d'))->order('bk_State desc')->select();
        $data['count'] = M('bk_chargepassconf')->where($where)->count();

        $PayTypeID = C('pay');
        foreach ($rows as $key => $row) {
            $row_data['id'] = $row['bk_passid'];
            $row_data['passame'] = $row['bk_passname']; //支付通道名称
            $row_data['PayTypeID'] = $PayTypeID[$row['bk_paytypeid']];  ////支付方式
            $row_data['appid'] = $row['bk_appid']; //appid
            $row_data['MerchantID'] = $row['bk_merchantid']; //商户ID;
            $row_data['AllPayMax'] = $row['bk_allpaymax']; //支付限额
            $row_data['Weight'] = $row['bk_weight']; //优先级权重

            $row_data['OrderNum'] = M('bk_createorder')->where(array("bk_PassID" => $row['bk_passid'], 'bk_CreateTime' => ['between', [strtotime(date('Y-m-d')), time()]]))->count();   //订单生成总数
            $row_data['OrderMoneyTotal'] = M('bk_createorder')->where(array("bk_PassID" => $row['bk_passid'], 'bk_CreateTime' => ['between', [strtotime(date('Y-m-d')), time()]]))->sum("bk_PayAmount") / 100 * 100; //订单总额
            $row_data['failOrderNum'] = M('bk_createorder')->where(array('bk_IsSuccess' => 0, "bk_PassID" => $row['bk_passid'], 'bk_CreateTime' => ['between', [strtotime(date('Y-m-d')), time()]]))->count(); //失败订单数
            $row_data['failOrderMoneyTotal'] = M('bk_createorder')->where(array('bk_IsSuccess' => 0, "bk_PassID" => $row['bk_passid'], 'bk_CreateTime' => ['between', [strtotime(date('Y-m-d')), time()]]))->sum("bk_PayAmount") / 100 * 100;//失败订单总额
            $row_data['okOrderNum'] = M('bk_createorder')->where(array('bk_IsSuccess' => 2, "bk_PassID" => $row['bk_passid'], 'bk_CreateTime' => ['between', [strtotime(date('Y-m-d')), time()]]))->count(); //成功订单数
            $row_data['okOrderMoneyTotal'] = M('bk_createorder')->where(array('bk_IsSuccess' => 2, "bk_PassID" => $row['bk_passid'], 'bk_CreateTime' => ['between', [strtotime(date('Y-m-d')), time()]]))->sum("bk_PayAmount") / 100 * 100;//成功订单总额
            $row_data['okLv'] = sprintf("%.2f %%", $row_data['okOrderNum'] / $row_data['OrderNum'] * 100);//成功率
            $row_data['state'] = $row['bk_state'];
            $row_data['ChargeListClose'] = $row['bk_chargelistclose'];
            $row_data['perPayMin'] = $row['bk_perpaymin'];
            $row_data['perPayMax'] = $row['bk_perpaymax'];
            $row_data['allPayMax'] = $row['bk_allpaymax'];
            $row_data['dataUrl'] = U('system/editPay', array('id' => $row['bk_passid']));
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
            $data['data'][] = $row_data;
        }
        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        $this->ajaxReturn($data);
    }

    //添加支付通道
    public function addPay()
    {
        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $row) {
            $apk_list[$row['bk_apkid']] = $row['bk_apk'];
        }
        $this->assign("apk_list", $apk_list);
        $pay = C('pay');
        $this->assign("pay_list", $pay);
        $this->show();
    }

    //添加支付通道
    public function doAddPay()
    {
        $data['bk_PassName'] = I('post.passName');
        if (empty($data['bk_PassName'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '支付通道名不能为空'));
        }

        $data['bk_PayTypeID'] = I('post.type/d');
        if ($data['bk_PayTypeID'] == 0 || !in_array($data['bk_PayTypeID'], array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '支付类型数据非法'));
        }

        $data['bk_UserIndex'] = I('post.userIndex/d');

        $data['bk_FactName'] = I('post.FactName');
        if (empty($data['bk_FactName'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '商户信息索引数据非法'));
        }

        $data['bk_ReqURL'] = I('post.ReqURL');
        if (empty($data['bk_ReqURL'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '支付URL数据非法'));
        }

//        $data['bk_NotifyURL'] =  I('post.NotifyURL');
//        if( empty($data['bk_NotifyURL']) ) {
//            $this->ajaxReturn(array( 'code' => 1, 'message' => '回调URL数据非法'));
//        }

//        $data['bk_AppID'] =  I('post.AppID');
//        if( empty($data['bk_AppID']) ) {
//            $this->ajaxReturn(array( 'code' => 1, 'message' => 'AppID数据非法'));
//        }
//
//        $data['bk_AppName'] =  I('post.AppName');
//        if( empty($data['bk_AppName']) ) {
//            $this->ajaxReturn(array( 'code' => 1, 'message' => 'App名称数据非法'));
//        }

        $data['bk_PerPayMin'] = I('post.PerPayMin');
        if (empty($data['bk_PerPayMin'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '单笔最小充值数据非法'));
        }

        $data['bk_PerPayMax'] = I('post.PerPayMax');
        if (empty($data['bk_PerPayMax'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '单笔最大充值数据非法'));
        }

        $data['bk_AllPayMax'] = I('post.AllPayMax');
        if (empty($data['bk_AllPayMax'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '支付最大充值数据非法'));
        }

        $data['bk_Weight'] = I('post.Weight/d');
        if (empty($data['bk_Weight'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '优先级权重数据非法'));
        }

        if ($data['bk_Weight'] < 0 || $data['bk_Weight'] > 10000) {
            $this->ajaxReturn(array('code' => 1, 'message' => '优先级权重范围：0-10000'));
        }

        $data['bk_State'] = I('post.State/d');
        $data['bk_State'] = intval($data['bk_State']);
        if (!in_array($data['bk_State'], [0, 1])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '状态数据非法'));
        }

        $data['bk_ChargeListClose'] = I('post.chargeListClose/d');
        $data['bk_ChargeListClose'] = intval($data['bk_ChargeListClose']);
        if (!in_array($data['bk_ChargeListClose'], [0, 1])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '定额通道开关数据非法'));
        }

        $pay = c("pay");
        $data['bk_PayTypeName'] = $pay[$data['bk_PayTypeID']];
        $data['bk_OperateTime'] = time();
        $data['bk_Operator'] = $this->login_admin_info['bk_name'];

        $apkAll = I('post.apkAll');
        if ($apkAll == "all") {
            $apkId = "all";
        } else {
            $apk = I('post.apk');
            if (count($apk) == 0 || !is_array($apk)) {
                $this->ajaxReturn(array('code' => 1, 'message' => 'APK包没有选择'));
            }
            $apkId = implode(',', $apk);
        }

        $data['bk_APKID'] = $apkId;
        $id = M('bk_chargepassconf')->data($data)->add();
        if (intval($id) > 0) {
            $this->ajaxReturn(array('code' => 0));
        }
        $this->ajaxReturn(array('code' => 1, 'message' => '添加失败'));
    }

    //修改支付通道
    public function editPay()
    {
        $id = I('get.id/d');
        $row = M('bk_chargepassconf')->where(array('bk_PassID' => $id))->find();
        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk_list[$val['bk_apkid']] = $val['bk_apk'];
            $apk_ids[] = $val['bk_apkid'];
        }
        $this->assign("apk_list", $apk_list);
        $row['apkid'] = ($row["bk_apkid"] == "all") ? $apk_ids : explode(',', $row["bk_apkid"]);
        $row['apkAll'] = (trim($row["bk_apkid"]) == "all") ? 1 : 0;

        $pay = C('pay');
        $this->assign("pay_list", $pay);

        $this->assign("row", $row);
        $this->show();
    }

    //修改支付通道
    public function doEditPay()
    {
        $data['bk_PassName'] = I('post.passName');
        if (empty($data['bk_PassName'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '支付通道名不能为空'));
        }

        $data['bk_PayTypeID'] = I('post.type/d');
        if ($data['bk_PayTypeID'] == 0 || !in_array($data['bk_PayTypeID'], array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '商户信息索引数据非法'));
        }

//        $data['bk_UserIndex'] =  I('post.userindex/d');
//        if( $data['bk_UserIndex'] == 0 ) {
//            $this->ajaxReturn(array( 'code' => 1, 'message' => '支付厂商ID数据非法'));
//        }


        $data['bk_FactName'] = I('post.FactName');
        if (empty($data['bk_FactName'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '支付厂商名称数据非法'));
        }

//        $data['bk_MerchantID'] =  I('post.MerchantID');
//        if( empty($data['bk_MerchantID']) ) {
//            $this->ajaxReturn(array( 'code' => 1, 'message' => '商户ID数据非法'));
//        }
//
//        $data['bk_MerchantName'] =  I('post.MerchantName');
//        if( empty($data['bk_MerchantName']) ) {
//            $this->ajaxReturn(array( 'code' => 1, 'message' => '商户账号数据非法'));
//        }

        $data['bk_ReqURL'] = I('post.ReqURL');
        if (empty($data['bk_ReqURL'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '支付URL数据非法'));
        }

//        $data['bk_NotifyURL'] =  I('post.NotifyURL');
//        if( empty($data['bk_NotifyURL']) ) {
//            $this->ajaxReturn(array( 'code' => 1, 'message' => '回调URL数据非法'));
//        }

//        $data['bk_AppID'] =  I('post.AppID');
//        if( empty($data['bk_AppID']) ) {
//            $this->ajaxReturn(array( 'code' => 1, 'message' => 'AppID数据非法'));
//        }
//
//        $data['bk_AppName'] =  I('post.AppName');
//        if( empty($data['bk_AppName']) ) {
//            $this->ajaxReturn(array( 'code' => 1, 'message' => 'App名称数据非法'));
//        }

        $data['bk_PerPayMin'] = I('post.PerPayMin');
        if (empty($data['bk_PerPayMin'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '单笔最小充值数据非法'));
        }

        $data['bk_PerPayMax'] = I('post.PerPayMax');
        if (empty($data['bk_PerPayMax'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '单笔最大充值数据非法'));
        }

        $data['bk_AllPayMax'] = I('post.AllPayMax');
        if (empty($data['bk_AllPayMax'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '支付最大充值数据非法'));
        }

        $data['bk_Weight'] = I('post.Weight');
        if (empty($data['bk_Weight'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '优先级权重数据非法'));
        }
        $pay = c("pay");
        $data['bk_PayTypeName'] = $pay[$data['bk_PayTypeID']];
        $data['bk_OperateTime'] = time();
        $data['bk_Operator'] = $this->login_admin_info['bk_name'];

        $apkAll = I('post.apkAll');
        if ($apkAll == "all") {
            $apkId = "all";
        } else {
            $apk = I('post.apk');
            if (count($apk) == 0 || !is_array($apk)) {
                $this->ajaxReturn(array('code' => 1, 'message' => 'APK包没有选择'));
            }
            $apkId = implode(',', $apk);
        }
        $data['bk_APKID'] = $apkId;
        $where['bk_PassID'] = I('post.id/d');
        M('bk_chargepassconf')->where($where)->data($data)->save();
        $this->ajaxReturn(['code' => 0]);
    }

    //状态
    public function doUpdateState()
    {
        $id = I('post.id/d');
        $isDisplay = I('post.isdisplay/d');
        if (!in_array($isDisplay, [0, 1])) {
            $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        }
        M('bk_chargepassconf')->where(['bk_PassID' => $id])->save(['bk_State' => $isDisplay]);
        $this->ajaxReturn(['code' => 0]);
    }

    //修改定额通道开关
    public function doChargeListClose()
    {
        $id = I('post.id/d');
        $isDisplay = I('post.isdisplay/d');
        if (!in_array($isDisplay, [0, 1])) {
            $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        }
        M('bk_chargepassconf')->where(['bk_PassID' => $id])->save(['bk_ChargeListClose' => $isDisplay]);
        $this->ajaxReturn(['code' => 0]);
    }


    //支付入口切换
    public function payControlConf()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $pay = C('pay');
        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk_list[$val['bk_apkid']] = $val['bk_apk'];
        }
        $rows = M('bk_paycontrolconf')->page(I('get.page/d'))->limit(I('get.limit/d'))->order('bk_ID desc')->select();
        $data['count'] = M('bk_paycontrolconf')->count();
        foreach ($rows as $row) {
            $row_data['id'] = $row['bk_id'];
            $row_data['PayTypeID'] = $pay[$row['bk_paytypeid']];
            $PayType = function () use ($row, $pay) {
                if ($row['bk_paytypeid'] == "all") {
                    return implode(',', $pay);
                } elseif ($row['bk_paytypeid'] != "") {
                    $carr = explode(',', $row['bk_paytypeid']);
                    foreach ($carr as $key => $val) {
                        isset($pay[$val]) && ($carr[$key] = $pay[$val]);
                    }
                    return $carr;
                }
            };

            $row_data['PayTypeID'] = $PayType();
            $apkids = explode(',', $row['bk_apkid']);
            foreach ($apkids as $k => $r) {
                $apkids[$k] = $apk_list[$r];
            }
            $row_data['apk'] = implode(',', $apkids);
            $row_data['Charge'] = $row['bk_mincharge'] . ' - ' . $row['bk_maxcharge'];
            $row_data['ChargeList'] = $row['bk_chargelist'];
            $row_data['State'] = $row['bk_state'];
            $row_data['Time'] = date('Y-m-d', $row['bk_time']);
            $row_data['Operator'] = $row['bk_operator'];
            $row_data['dataUrl'] = U('system/editPayControlConf', ['id' => $row['bk_id']]);
            $data['data'][] = $row_data;
        }
        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        $this->ajaxReturn($data);
    }

    //添加支付通道方式
    public function addPayControlConf()
    {
        if (!IS_AJAX) {
            $apk_rows = M('bk_apk')->select();
            foreach ($apk_rows as $key => $val) {
                $apk_list[$val['bk_apkid']] = $val['bk_apk'];
            }
            $pay = C('pay');
            $this->assign("pay_list", $pay);
            $this->assign("apk_list", $apk_list);
            $this->show();
            return;
        }
        // $data['bk_APKID'] = I('post.apk/');

        $APKID = I('post.apk');
        $data['bk_APKID'] = implode(',', $APKID);

//        $PayTypeIDAll = I('post.PayTypeIDAll');
//        if ( $PayTypeIDAll == "all" ){
//            $data['bk_PayTypeID'] = "all";
//        }else {
//            $PayTypeID = I('post.PayTypeID');
//            if( count($PayTypeID) == 0 || !is_array($PayTypeID) ){
//                $this->ajaxReturn(array('code'=>1, 'message'=> 'apk包没有选择'));
//            }
//            $data['bk_PayTypeID'] = implode(',', $PayTypeID);
//        }
        $data['bk_PayTypeID'] = I('post.PayTypeID/d');
        $data['bk_MinCharge'] = I('post.MinCharge/d');
        $data['bk_MaxCharge'] = I('post.MaxCharge/d');
        if ($data['bk_MinCharge'] > $data['bk_MaxCharge']) {
            $this->ajaxReturn(['code' => 1, 'message' => '最大值不能比最小值大']);
        }
        $data['bk_Weight'] = I('post.Weight/d');
        if ($data['bk_Weight'] > 999 || $data['bk_MaxCharge'] < 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '权重值范围为：0-999']);
        }
        $data['bk_State'] = I('post.State/d');
        $data['bk_Time'] = time();
        $data['bk_Operator'] = $this->login_admin_info['bk_name'];
        $price_list_func = function () use ($data) {
            $price_list = I('post.price_list');
            if (empty($price_list) && $data['bk_PayTypeID'] != 11) {
                return ['code' => 1, 'message' => '推荐定额不能为空'];
            }

            $price_list_array = explode(',', $price_list);

            if (count($price_list_array) > 8) {
                return ['code' => 1, 'message' => '推荐定额个数不能大于8个'];
            }
            foreach ($price_list_array as $val) {
                if (intval($val) < $data['bk_MinCharge'] || intval($val) > $data['bk_MaxCharge']) {
                    return ['code' => 1, 'message' => '推荐定额 必须介于充值范围'];
                }
                if (intval($val) == 0 && $data['bk_PayTypeID'] != 11) {
                    return ['code' => 1, 'message' => '推荐定额 数据非法'];
                }
            }
            return ['code' => 0];
        };
        $price_list = $price_list_func();

        if ($price_list['code'] == 1) {
            $this->ajaxReturn($price_list);
        }
        $data['bk_ChargeList'] = trim(I('post.price_list'));
        $data['bk_IsHot'] = I('post.IsHot/d');
        if (!in_array($data['bk_IsHot'], [0, 1])) {
            $this->ajaxReturn(['code' => 1, 'message' => '权重数据非法']);
        }

        $id = M('bk_paycontrolconf')->data($data)->add();
        if (intval($id) > 0) {
            $this->sendGameMessagePayControlConf($data, 1028);
            $this->ajaxReturn(['code' => 0]);
        }
        $this->ajaxReturn(['code' => 1, 'message' => '添加失败']);
    }

    //编辑支付方法
    public function editPayControlConf()
    {
        if (!IS_AJAX) {
            $row = M('bk_paycontrolconf')->where(['bk_ID' => I('get.id/d')])->find();
            $pay_rows = C('pay');
            $row['bk_apkid'] = explode(',', $row['bk_apkid']);
            foreach ($pay_rows as $key => $val) {
                $pay_list[$key] = $val;
                $pay_ids[] = $key;
            }
            $apk_rows = M('bk_apk')->select();
            foreach ($apk_rows as $val) {
                $apk_list[$val['bk_apkid']] = $val['bk_apk'];
            }
            $this->assign("apk_list", $apk_list);
            $this->assign("pay_list", $pay_rows);
            $row['PayTypeID'] = $row["bk_paytypeid"];
            $this->assign("row", $row);
            $this->show();
            return;
        }

        //$data['bk_APKID'] = I('post.apk/d');
        $APKID = I('post.apk');

        $data['bk_APKID'] = implode(',', $APKID);
        $data['bk_PayTypeID'] = I('post.PayTypeID/d');
        $data['bk_MinCharge'] = I('post.MinCharge/d');
        $data['bk_MaxCharge'] = I('post.MaxCharge/d');
        if ($data['bk_MinCharge'] > $data['bk_MaxCharge']) {
            $this->ajaxReturn(['code' => 1, 'message' => '最大值不能比最小值大']);
        }
        $data['bk_State'] = I('post.State/d');
        $data['bk_Weight'] = I('post.Weight/d');
        if ($data['bk_Weight'] > 999 || $data['bk_MaxCharge'] < 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '权重值范围为：0-999']);
        }

        $price_list_func = function () use ($data) {
            $price_list = I('post.price_list');
            if (empty($price_list) && $data['bk_PayTypeID'] != 11) {
                return ['code' => 1, 'message' => '推荐定额不能为空'];
            }

            $price_list_array = explode(',', $price_list);

            if (count($price_list_array) > 8) {
                return ['code' => 1, 'message' => '推荐定额个数不能大于8个'];
            }
            foreach ($price_list_array as $val) {
                if (intval($val) < $data['bk_MinCharge'] || intval($val) > $data['bk_MaxCharge']) {
                    return ['code' => 1, 'message' => '推荐定额 必须介于充值范围'];
                }
                if (intval($val) == 0 && $data['bk_PayTypeID'] != 11) {
                    return ['code' => 1, 'message' => '推荐定额 数据非法'];
                }
            }
            return ['code' => 0];
        };
        $price_list = $price_list_func();

        if ($price_list['code'] == 1) {
            $this->ajaxReturn($price_list);
        }

        $data['bk_ChargeList'] = trim(I('post.price_list'));

        $data['bk_IsHot'] = I('post.IsHot/d');
        if (!in_array($data['bk_IsHot'], [0, 1])) {
            $this->ajaxReturn(['code' => 1, 'message' => '推荐数据非法']);
        }

        $where['bk_ID'] = I('post.id/d');
        $up_num = M('bk_paycontrolconf')->where($where)->save($data);
        if ($up_num == 1) {
            $this->sendGameMessagePayControlConf($data, 1029);
            $this->ajaxReturn(['code' => 0]);
        }
        $this->ajaxReturn(['code' => 1, 'message' => '更新失败']);
    }

    public function doPayControlConfState()
    {
        $where['bk_ID'] = I('post.id/d');
        if (!in_array(I('post.isdisplay/d'), [0, 1])) {
            $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        }
        $up_num = M('bk_paycontrolconf')->where($where)->save(['bk_State' => I('post.isdisplay/d')]);
        sleep(5);
        $row = M('bk_paycontrolconf')->where($where)->find();
        $data['bk_APKID'] = $row['bk_apkid'];
        $data['bk_PayTypeID'] = $row['bk_paytypeid'];
        $data['bk_MinCharge'] = $row['bk_mincharge'];
        $data['bk_MaxCharge'] = $row['bk_maxcharge'];
        $data['bk_State'] = $row['bk_state'];
        $data['bk_Weight'] = $row['bk_weight'];
        $data['bk_IsHot'] = $row['bk_ishot'];
        $data['bk_ChargeList'] = $row['bk_chargelist'];
        $this->sendGameMessagePayControlConf($data, 1029);
        $this->ajaxReturn(['code' => 0]);
    }

    //扫码支付渠道
    public function qrCodePayChannel()
    {
        $qrPayList = C('qrPayList');
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $where = [];
        if (I('get.passame') != '') {
            $where['bk_Pay_Name'] = ['like', '%' . I('get.passame') . '%'];
        }

        $rows = M('bk_qrcode_channel')->where($where)->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        $data['count'] = M('bk_qrcode_channel')->where($where)->count();
        foreach ($rows as $row) {
            $row_data['id'] = $row['bk_id'];
            $row_data['pay_name'] = $row['bk_pay_name'];  //支付通道名
            $row_data['Weight'] = $row['bk_weight'];  //优先级权重
            $row_data['Pay_name'] = $qrPayList[$row['bk_pay_id']];  //支付类型
            $row_data['Pay_Status'] = $row['bk_pay_status'];  //支付开关
            $row_data['ChargeList'] = $row['bk_chargelist'];  //推荐金额
            $row_data['Qr_Url'] = $row['bk_qr_url'];  //支付二维码链接
            $row_data['Bank_Name'] = $row['bk_bank_name'];  //收款开户行
            $row_data['User_Name'] = $row['bk_user_name'];  //银行卡持卡人名称
            $row_data['Number'] = $row['bk_number'];  //银行卡帐号
            $row_data['OrderTotalNum'] = M('bk_gfsmorder')->where(['bk_ChannelID' => $row['bk_id']])->count(); //订单生成总数
            $row_data['OrderTotalAmount'] = M('bk_gfsmorder')->where(['bk_ChannelID' => $row['bk_id']])->sum('bk_PayAmount');//订单总额
            $row_data['failOrderNum'] = M('bk_gfsmorder')->where(['bk_IsSuccess' => 0, 'bk_ChannelID' => $row['bk_id']])->count();//失败订单数
            $row_data['failAmount'] = M('bk_gfsmorder')->where(['bk_IsSuccess' => 0, 'bk_ChannelID' => $row['bk_id']])->sum('bk_PayAmount'); //失败订单总额
            $row_data['successOrderNum'] = M('bk_gfsmorder')->where(['bk_IsSuccess' => 2, 'bk_ChannelID' => $row['bk_id']])->count();//成功订单数
            $row_data['successOrderAmount'] = M('bk_gfsmorder')->where(['bk_IsSuccess' => 2, 'bk_ChannelID' => $row['bk_id']])->sum('bk_PayAmount'); //成功订单总额
            $row_data['successOrderRate'] = sprintf("%0.2f %%", $row_data['failOrderNum'] / $row_data['OrderTotalNum'] * 100); //成功率
            $row_data['MaxCharge'] = $row['bk_maxcharge']; //支付限额
            $row_data['dataUrl'] = U('system/qrCodePayChannelEdit', ['id' => $row['bk_id']]);
            $data['data'][] = $row_data;
        }
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //添加扫码支付通道
    public function qrCodePayChannelAdd()
    {
        $qrPayList = C('qrPayList');
        if (!IS_AJAX) {
            $this->assign('qrPayList', $qrPayList);
            $this->show();
            return;
        }

        $d['bk_Pay_Name'] = I('post.pay_name');
        if ($d['bk_Pay_Name'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '支付通道名不能为空']);
        }

        $d['bk_Weight'] = I('post.Weight/d');
        if ($d['bk_Weight'] == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '优先级权重为1-100']);
        }

        $d['bk_Pay_id'] = I('post.Pay_name/d');
        if ($d['bk_Pay_id'] == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '请选择支付类型']);
        }

        $d['bk_Pay_Status'] = I('post.Pay_Status/d');
        if (!in_array($d['bk_Pay_Status'], [0, 1])) {
            $this->ajaxReturn(['code' => 1, 'message' => '支付开关数据非法']);
        }

        $d['bk_ChargeList'] = I('post.ChargeList');
        if ($d['bk_ChargeList'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '推荐金额不能为空']);
        }

        $d['bk_Qr_Url'] = I('post.Qr_Url');
        if ($d['bk_Qr_Url'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '二维码链接不能为空']);
        }

        $d['bk_Min_Charge'] = I('post.Min_Charge/d');
        $d['bk_Max_Charge'] = I('post.Max_Charge/d');

        if ($d['bk_Min_Charge'] > $d['bk_Max_Charge']) {
            $this->ajaxReturn(['code' => 1, 'message' => '最大金额不能小于最小金额']);
        }

        $d['bk_Bank_Name'] = I('post.Bank_Name');
        if ($d['bk_Bank_Name'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '收款开户行不能为空']);
        }

        $d['bk_User_Name'] = I('post.User_Name');
        if ($d['bk_User_Name'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '持卡姓名不能为空']);
        }

        $d['bk_Number'] = I('post.Number');
        if ($d['bk_Number'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '银行卡帐号不能为空']);
        }

        $d['bk_MaxCharge'] = I('post.AllPayMax/d');
        if ($d['bk_MaxCharge'] == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '支付限额不能为空']);
        }
        $d['bk_Add_Time'] = time();
        $d['bk_Operator'] = $this->login_admin_info['bk_name'];

        $id = M('bk_qrcode_channel')->add($d);
        if ($id) {
            $d['bk_id'] = $id;
            $this->sendGameMessageQrCodePayChannel($d, 1036);
            $this->ajaxReturn(['code' => 0]);
        }
        $this->ajaxReturn(['code' => 1, 'message' => '添加失败']);
    }

    //编辑扫码支付通道
    public function qrCodePayChannelEdit()
    {
        $qrPayList = C('qrPayList');
        if (!IS_AJAX) {
            $code_channel = M('bk_qrcode_channel')->where(['bk_id' => I('get.id/d')])->find();
            $this->assign('channel', $code_channel);
            $this->assign('qrPayList', $qrPayList);
            $this->show();
            return;
        }

        $d['bk_Pay_Name'] = I('post.pay_name');
        if ($d['bk_Pay_Name'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '支付通道名不能为空']);
        }

        $d['bk_Weight'] = I('post.Weight/d');
        if ($d['bk_Weight'] == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '优先级权重为1-100']);
        }

        $d['bk_Pay_id'] = I('post.Pay_name/d');
        if ($d['bk_Pay_id'] == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '请选择支付类型']);
        }

        $d['bk_Min_Charge'] = I('post.Min_Charge/d');
        $d['bk_Max_Charge'] = I('post.Max_Charge/d');

        if ($d['bk_Min_Charge'] > $d['bk_Max_Charge']) {
            $this->ajaxReturn(['code' => 1, 'message' => '最大金额不能小于最小金额']);
        }

        $d['bk_Pay_Status'] = I('post.Pay_Status/d');
        if (!in_array($d['bk_Pay_Status'], [0, 1])) {
            $this->ajaxReturn(['code' => 1, 'message' => '支付开关数据非法']);
        }

        $d['bk_ChargeList'] = I('post.ChargeList');
        if ($d['bk_ChargeList'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '推荐金额不能为空']);
        }

        $d['bk_Qr_Url'] = I('post.Qr_Url');
        if ($d['bk_Qr_Url'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '二维码链接不能为空']);
        }

        $d['bk_Bank_Name'] = I('post.Bank_Name');
        if ($d['bk_Bank_Name'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '收款开户行不能为空']);
        }

        $d['bk_User_Name'] = I('post.User_Name');
        if ($d['bk_User_Name'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '持卡姓名不能为空']);
        }

        $d['bk_Number'] = I('post.Number');
        if ($d['bk_Number'] == '') {
            $this->ajaxReturn(['code' => 1, 'message' => '银行卡帐号不能为空']);
        }

        $d['bk_MaxCharge'] = I('post.AllPayMax/d');
        if ($d['bk_MaxCharge'] == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '支付限额不能为空']);
        }
        $d['bk_Add_Time'] = time();
        $d['bk_Operator'] = $this->login_admin_info['bk_name'];

        $id = M('bk_qrcode_channel')->where(['bk_id' => I('post.id/d')])->save($d);
        if ($id) {
            $d['bk_id'] = I('post.id/d');
            $this->sendGameMessageQrCodePayChannel($d, 1037);
            $this->ajaxReturn(['code' => 0]);
        }
        $this->ajaxReturn(['code' => 1, 'message' => '更新失败']);
    }

    //更改扫码支付状态
    public function qrCodePayChannelStatus()
    {
        $where['bk_id'] = I('post.id/d');
        if (!in_array(I('post.isdisplay/d'), [0, 1])) {
            $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        }
        $up_num = M('bk_qrcode_channel')->where($where)->save(['bk_Pay_Status' => I('post.isdisplay/d')]);
        $data = M('bk_qrcode_channel')->where($where)->find();

        $d['bk_id'] = $data['bk_id'];
        $d['bk_Pay_id'] = $data['bk_pay_id'];
        $d['bk_Min_Charge'] = $data['bk_min_charge'];
        $d['bk_Max_Charge'] = $data['bk_max_charge'];
        $d['bk_Weight'] = $data['bk_weight'];
        $d['bk_Qr_Url'] = $data['bk_qr_url'];
        $d['bk_ChargeList'] = $data['bk_chargelist'];
        $d['bk_Pay_Status'] = $data['bk_pay_status'];
        $this->sendGameMessageQrCodePayChannel($d, 1037);
        $this->ajaxReturn(['code' => 0]);
    }

    //菜单
    public function getOneMenu($id)
    {
        return M("bk_menu")->where(["menu_ID" => intval($id)])->find();
    }

    public function sendGameMessageQrCodePayChannel($data, $num)
    {
        $d['bk_id'] = pack("L", $data['bk_id']);
        $d['bk_Pay_id'] = pack("C", $data['bk_Pay_id']);
        $d['bk_Min_Charge'] = pack("L", $data['bk_Min_Charge']);
        $d['bk_Max_Charge'] = pack("L", $data['bk_Max_Charge']);
        $d['bk_Weight'] = pack("C", $data['bk_Weight']);
        $d['bk_Qr_Url_Len'] = pack("S", strlen($data['bk_Qr_Url']));
        $d['bk_ChargeList_Len'] = pack("S", strlen($data['bk_ChargeList']));
        $d['bk_Pay_Status'] = pack("C", $data['bk_Pay_Status']);
        $body = $d['bk_id'] . $d['bk_Pay_id'] . $d['bk_Min_Charge'] . $d['bk_Max_Charge'] . $d['bk_Weight'] . $d['bk_Qr_Url_Len'] . $data['bk_Qr_Url'] . $d['bk_ChargeList_Len'] . $data['bk_ChargeList'] . $d['bk_Pay_Status'];
        SendToGame(C('SOCKET_IP'), 30000, $num, $body);
    }

    public function sendGameMessagePayControlConf($data, $num)
    {
        $data['id_len'] = pack('S', strlen($data['bk_APKID']));  //包ID
        $data['bk_PayTypeID'] = pack('C', $data['bk_PayTypeID']); //支付ID
        $data['bk_MinCharge'] = pack('L', $data['bk_MinCharge']); //最小值
        $data['bk_MaxCharge'] = pack('L', $data['bk_MaxCharge']); //最大值
        $data['bk_State'] = pack('C', $data['bk_State']); //状态
        $data['bk_Weight'] = pack('C', $data['bk_Weight']); //权重
        $data['bk_IsHot'] = pack('C', $data['bk_IsHot']); //推荐
        $data['bk_ChargeList_len'] = pack('S', strlen($data['bk_ChargeList'])); //定额通道开关
        $body = $data['id_len'] . $data['bk_APKID'] . $data['bk_PayTypeID'] . $data['bk_MinCharge'] . $data['bk_MaxCharge'] . $data['bk_State'] . $data['bk_Weight'] . $data['bk_IsHot'] . $data['bk_ChargeList_len'] . $data['bk_ChargeList'];
        SendToGame(C('SOCKET_IP'), 30000, $num, $body);
    }
}