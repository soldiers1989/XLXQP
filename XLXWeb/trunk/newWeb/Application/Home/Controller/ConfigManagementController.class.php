<?php

namespace Home\Controller;
class ConfigManagementController extends BaseController
{
    public function index()
    {
        $this->show();
    }

    //主页文字编辑（游戏内）
    public function homepageEdit()
    {

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        if (I('post.homepage') == "" || I('post.area/d') <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        $data['bk_Area'] = I('post.area/d');
        $data['bk_Content'] = I('post.homepage');
        $data['bk_Time'] = time();
        $result = M('bk_homepageedit')->add($data);
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    //代理配置(查看)
    public function proxyConfig()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');
        }

        if (I('get.nickname') != "") {
            $where_data['bk_Nickname'] = I('get.nickname');
        }

        if (I('get.phone/d') > 0) {
            $where_data['bk_Phone'] = I('get.phone/d');
        }

        if (I('get.qq/d') > 0) {
            $where_data['bk_QQ'] = I('get.qq/d');
        }

        if (I('get.wechat') != "") {
            $where_data['bk_WeChat'] = I('get.wechat');
        }

        if (I('get.number/d') > 0) {
            $where_data['bk_Number'] = I('get.number/d');
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
            $where_data['bk_TJ_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('bk_daili')->where($where_data)->count();
        $order = "bk_Weights desc";
        $Query = M('bk_daili')->field()->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        $number = 1;
        foreach ($data_list as $key => $val) {
            if (0 == I('get.isExecl/d')) $data['id'] = $val['bk_id'];
            $data['id_'] = $number;
            $data['weights'] = $val['bk_weights'];
            $data['recommend'] = $val['bk_recommend'] == 0 ? "无" : "HOT";
            $data['number'] = $val['bk_number'];
            $apk_str = "";
            if ($val['bk_apkid'] == "all") {
                $apk_list = M('bk_apk')->select();
                foreach ($apk_list as $key => $value) {
                    $apk_str .= $value['bk_apk'] . " ";
                }
            } else {
                foreach (explode(',', $val['bk_apkid']) as $apl_val) {
                    $apk_str .= (M('bk_apk')->where(array('bk_ApkID' => $apl_val))->getField('bk_Apk') . " ");
                }
            }
            $data['apk'] = $apk_str;
            $data['account'] = $val['bk_accountid'];
            $data['gameNickname'] = $val['bk_gamenickname'];
            $data['nickname'] = $val['bk_nickname'];
            $data['qq'] = $val['bk_qq'];
            $data['wechat'] = $val['bk_wechat'];
            $data['phone'] = $val['bk_phone'];
            $data['name'] = $val['bk_name'];
            $data['state'] = $val['bk_state'] == 0 ? "已下架" : "上架中";
            $data['bk_account'] = $val['bk_bk_accound'];
            $data['tj_time'] = date('Y-m-d H:i:s', $val['bk_tj_time']);
            $data['tj_operator'] = $val['bk_tj_operator'];
            $data['time'] = $val['bk_time'] == 0 ? "" : date('Y-m-d H:i:s', $val['bk_time']);
            $data['operator'] = $val['bk_operator'] == '0' ? "" : $val['bk_operator'];
            if (0 == I('get.isExecl/d')) $data['editUrl'] = U("configManagement/editProxy", array('id' => $val['bk_id']));
            $layui_data['data'][] = $data;

            $number++;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.proxy_config'), $layui_data['data'], '代理配置');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //删除代理
    public function doProxyDel()
    {

        if (I('post.id/d') <= 0 || I('post.account/d') <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        $result = M('bk_daili')->where(array('bk_ID' => I('post.id/d')))->delete();
        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }
        //构建socket数据
        $str = pack("L", I('post.account/d'));
        SendToGame(C('socket_ip'), 30000, 1025, $str);
        $this->ajaxReturn(array('code' => 0));
    }

    //代理编辑
    public function editProxy()
    {

        $apk_rows = M('bk_apk')->select();
        foreach ($apk_rows as $key => $val) {
            $apk_list[$val['bk_apkid']] = $val['bk_apk'];
            $apk_ids[] = $val['bk_apkid'];
        }
        $this->assign("apk_list", $apk_list);

        $id = I("get.id/d");
        $row = M('bk_daili')->where(array('bk_ID' => $id))->find();
        $data['id'] = $row['bk_id'];
        $data['accountid'] = $row['bk_accountid'];
        $data['nickname'] = $row['bk_nickname'];
        $data['qq'] = $row['bk_qq'];
        $data['wechat'] = $row['bk_wechat'];
        $data['phone'] = $row['bk_phone'];
        $data['weights'] = $row['bk_weights'];
        $data['recommend'] = $row['bk_recommend'];
        $data['state'] = $row['bk_state'];
        $data['number'] = $row['bk_number'];
        $data['apkid'] = ($row["bk_apkid"] == "all") ? $apk_ids : explode(',', $row["bk_apkid"]);
        $data['apkAll'] = (trim($row["bk_apkid"]) == "all") ? 1 : 0;
        $data['name'] = $row['bk_name'];
        $this->assign('row', $data);
        $this->show();
    }

    //添加代理
    public function addProxy()
    {

        $apk_list = array();
        $apk = M('bk_apk')->select();

        foreach ($apk as $key => $val) {
            $apk_list[$val['bk_apkid']] = $val['bk_apk'];
        }

        if (!IS_AJAX) {
            $this->assign('apk_list', $apk_list);
            $this->show();
            return;
        }

        if (I('post.account') == "" || I('post.nickname') == "" || I('post.phone') == "" || I('post.weights') == "" ||
            I('post.recommend_label') == "" || I('post.state') == "" || I('post.number') == "" || I('post.name') == "" ||
            I('post.Accound') == "" || I('post.Psd') == "") {

            $this->ajaxReturn(array('code' => 1));
        }

        //apk包id
        $apkAll = I('post.apkall');
        if ($apkAll == "all") {
            $apkId = "all";
        } else {
            $apk = I('post.apk');
            if (count($apk) == 0 || !is_array($apk)) {
                $this->ajaxReturn(array('code' => 1));
            }
            $apkId = implode(',', $apk);
        }

        $data['bk_AccountID'] = I('post.account');
        $data['bk_GameNickname'] = I('post.GameNickname');
        $data['bk_Nickname'] = I('post.nickname');
        $data['bk_QQ'] = I('post.qq');
        $data['bk_WeChat'] = I('post.wechat');
        $data['bk_Phone'] = I('post.phone');
        $data['bk_Weights'] = I('post.weights');
        $data['bk_Recommend'] = I('post.recommend_label');
        $data['bk_Number'] = I('post.number');
        $data['bk_state'] = I('post.state');
        $data['bk_APKID'] = $apkId;
        $data['bk_Name'] = I('post.name');
        //代理后台-账号-密码-账号状态
        $data['bk_BK_Accound'] = I('post.Accound');
        $data['bk_BK_Psd'] = md5(I('post.Psd'));
        $data['bk_BK_State'] = 1;

        $data['bk_TJ_Time'] = time();
        $data['bk_TJ_Operator'] = $this->login_admin_info['bk_name'];

        $result = M("bk_daili")->add($data);
        if (intval($result)) {

            //构建socket数据
            $str = pack("L", $data['bk_AccountID']) . pack("L", $data['bk_Number']) .
                pack("S", strlen($data['bk_Nickname'])) . $data['bk_Nickname'] . pack("S", strlen($data['bk_QQ'])) . $data['bk_QQ'] .
                pack("S", strlen($data['bk_WeChat'])) . $data['bk_WeChat'] . pack("S", strlen($data['bk_Phone'])) . $data['bk_Phone'] .
                pack("L", $data['bk_Weights']) . pack("C", $data['bk_Recommend']) . pack("C", $data['bk_state']) .
                pack("S", strlen($data['bk_APKID'])) . $data['bk_APKID'];
            SendToGame(C('socket_ip'), 30000, 1023, $str);

            $this->ajaxReturn(array('code' => 0));
        }
    }

    //更新代理
    public function doProxyUpdate()
    {

        if (I('post.id/d') <= 0 || I('post.account/d') <= 0 || I('post.weights/d') <= 0 ||
            I('post.recommend_label') == "" || I('post.nickname') == "" || I('post.phone') == "" ||
            I('post.number/d') <= 0 || I('post.name') == "") {

            $this->ajaxReturn(array('code' => 1, 'message' => '更新失败'));
        }

        //apk包id
        $apkAll = I('post.apkall');
        if ($apkAll == "all") {
            $apkId = "all";
        } else {
            $apk = I('post.apk');
            if (count($apk) == 0 || !is_array($apk)) {
                $this->ajaxReturn(array('code' => 1));
            }
            $apkId = implode(',', $apk);
        }

        $up_data['bk_Weights'] = I('post.weights/d');
        $up_data['bk_Recommend'] = I('post.recommend_label');
        $up_data['bk_Nickname'] = I('post.nickname');
        $up_data['bk_QQ'] = I('post.qq');
        $up_data['bk_WeChat'] = I('post.wechat');
        $up_data['bk_Phone'] = I('post.phone');
        $up_data['bk_Number'] = I('post.number/d');
        $up_data['bk_APKID'] = $apkId;
        $up_data['bk_Name'] = I('post.name');
        $up_data['bk_state'] = I('post.state');
        if (strlen(I('post.psd')) < 6 && strlen(I('post.psd')) > 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '用户密码不能小于6位'));
        }
        if (strlen(I('post.psd')) >= 6) {
            $up_data['bk_BK_Psd'] = md5(I('post.psd'));
        }
        $up_data['bk_Time'] = time();
        $up_data['bk_Operator'] = $this->login_admin_info['bk_name'];

        $result = M('bk_daili')->where(array('bk_ID' => I('post.id/d')))->save($up_data);

        if (intval($result)) {
            //构建socket数据
            $str = pack("L", I('post.account/d')) . pack("L", $up_data['bk_Number']) .
                pack("S", strlen($up_data['bk_Nickname'])) . $up_data['bk_Nickname'] . pack("S", strlen($up_data['bk_QQ'])) . $up_data['bk_QQ'] .
                pack("S", strlen($up_data['bk_WeChat'])) . $up_data['bk_WeChat'] . pack("S", strlen($up_data['bk_Phone'])) . $up_data['bk_Phone'] .
                pack("L", $up_data['bk_Weights']) . pack("C", $up_data['bk_Recommend']) . pack("C", $up_data['bk_state']) .
                pack("S", strlen($up_data['bk_APKID'])) . $up_data['bk_APKID'];
            $socket_result = SendToGame(C('socket_ip'), 30000, 1024, $str);

            $this->ajaxReturn(array('code' => 0));
        }
    }

    //投诉管理
    public function complaintsManagement()
    {

        $where_data = array();
        $data = array();

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        if (I('get.account/d') > 0) {
            $where_data['bk_AccountID'] = I('get.account/d');
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
            $where_data['bk_Time'] = array('between', array($s_time, $e_time));
        }

        $layui_data['count'] = M('bk_toushumanagement')->where($where_data)->count();
        $order = "bk_Time desc";
        $Query = M('bk_toushumanagement')->where($where_data)->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        $layui_data['sql'] = M('bk_toushumanagement')->getLastSql();

        $number = 1;
        foreach ($data_list as $key => $val) {
            if (0 == I('get.isExecl/d')) $data['id'] = $val['bk_id'];
            $data['number'] = $number;
            $data['account'] = $val['bk_accountid'];
            $data['nickname'] = $val['bk_nickname'];
            $data['time'] = date('Y-m-d H:i:s', $val['bk_time']);
            $data['content'] = $val['bk_content'];
            $data['state'] = $val['bk_state'] == 0 ? "未处理" : "已处理";
            $data['result'] = $val['bk_operate_result'] == '0' ? "" : $val['bk_operate_result'];
            $data['operator'] = $val['bk_operator'] == '0' ? "" : $val['bk_operator'];
            $data['operate_time'] = $val['bk_operate_time'] == 0 ? "" : date('Y-m-d H:i:s', $val['bk_operate_time']);
            if (0 == I('get.isExecl/d')) $data['editUrl'] = U("configManagement/editComplaintsManagement", array('id' => $val['bk_id']));
            $layui_data['data'][] = $data;
            $number++;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.complaints_management'), $layui_data['data'], '投诉管理');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //投诉管理编辑
    public function editComplaintsManagement()
    {

        $id = I("get.id/d");
        $row = M('bk_toushumanagement')->where(array('bk_ID' => $id))->find();
        $this->assign('row', $row);
        $this->show();
    }

    //更新投诉管理
    public function doComplaintsManagementUpdate()
    {

        $up_data['bk_Operate_Result'] = I('post.content');
        $up_data['bk_State'] = 1;
        $up_data['bk_Operate_Time'] = time();
        $up_data['bk_Operator'] = $this->login_admin_info['bk_name'];

        $result = M('bk_toushumanagement')->where(array('bk_ID' => I('post.id/d')))->save($up_data);
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    //游戏状态
    public function gameState()
    {

        $apk_list = array();
        $channel_list = array();
        $apk_channel_list = array();
        $apk = M('bk_apk')->select();
        $channel = M('bk_channel')->select();
        $apk_channel = M('bk_apkchannel')->field(array('bk_ID', 'bk_True_ApkID', 'bk_True_ChannelID'))->where(array('bk_ChannelState' => 1))->select();

        foreach ($apk as $key => $val) {
            $apk_list[$val['bk_id']] = $val['bk_apk'];
        }

        foreach ($channel as $key => $val) {
            $channel_list[$val['bk_id']] = $val['bk_channel'];
        }

        foreach ($apk_channel as $key => $val) {
            $apk_channel_list[$val['bk_id']] = $apk_list[$val['bk_true_apkid']] . '-' . $channel_list[$val['bk_true_channelid']];
        }

        if (!IS_AJAX) {
            $this->assign('apk_channel', $apk_channel_list);
            $this->show();
            return;
        }

        if (I('post.weights') == "" || I('post.game') == "" || I('post.apkChannel') == "" || I('post.state') == "" || I('post.label') == "" ||
            I('post.room_primary') == "" || I('post.room_middle') == "" || I('post.room_high') == "" || I('post.room_rich') == "" ||
            I('post.label_primary') == "" || I('post.label_middle') == "" || I('post.label_high') == "" || I('post.label_rich') == "") {

            $this->ajaxReturn(array('code' => 1, 'message' => '添加失败，请填写完整信息'));
        }

        $pattern = "/^[1-9][0-9]{0,1}$/";
        if (!preg_match($pattern, I('post.weights/d'))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '添加失败，请填写正确的权重'));
        }

        $game = I('post.game');
        $apkChannel = I('post.apkChannel');
        $count = 0;

        //构建Socket数据
        $weights_str = "";  //权重
        $gameName_str = ""; //游戏名称
        $apkID_str = "";    //apk包名
        $channelID_str = "";    //渠道
        $state_str = "";    //状态
        $label_str = "";    //标签
        $room1_str = "";    //房间1
        $label1_str = "";   //房间1标签
        $room2_str = "";    //房间2
        $label2_str = "";   //房间2标签
        $room3_str = "";    //房间3
        $label3_str = "";   //房间3标签
        $room4_str = "";    //房间4
        $label4_str = "";   //房间4标签

        //数据库事务开始
        $Model = M('bk_gamestate');
        $Model->startTrans();

        foreach ($game as $val_game) {
            foreach ($apkChannel as $val_ac) {

                $roomType = 0;
                //判断游戏房间类型
                switch ($val_game) {
                    //奔驰宝马
                    case 6:
                        $roomType = 3;
                        break;
                    //时时彩
                    case 5:
                        $roomType = 2;
                        break;
                    //炸金花 牛牛 红包接龙 推筒子 跑得快
                    case 8:
                    case 9:
                    case 10:
                    case 11:
                    case 13:
                        $roomType = 1;
                        break;
                }

                $data['bk_GameName'] = $val_game;
                //获取apk和channel信息
                $data['bk_APK'] = $apk_list[M('bk_apkchannel')->where(array('bk_ID' => $val_ac))->getField('bk_True_ApkID')];  //apk包名
                $data['bk_APKID'] = M('bk_apkchannel')->where(array('bk_ID' => $val_ac))->getField('bk_ApkID');    //apk包id   真实id 非自增id
                $data['bk_Channel'] = $channel_list[M('bk_apkchannel')->where(array('bk_ID' => $val_ac))->getField('bk_True_ChannelID')];  //渠道名
                $data['bk_ChannelID'] = M('bk_apkchannel')->where(array('bk_ID' => $val_ac))->getField('bk_ChannelID');    //渠道id   真实id 非自增id

                //判断用户添加的数据是否重复
                if ($Model->where($data)->find() != NULL) {
                    $this->ajaxReturn(array('code' => 1, 'message' => '添加失败，请不要重复添加数据'));
                }

                $data['bk_Weights'] = I('post.weights/d');
                $data['bk_ChannelState'] = M('bk_apkchannel')->where(array('bk_ID' => $val_ac))->getField('bk_ChannelState');  //渠道状态
                $data['bk_State'] = I('post.state');
                $data['bk_Label'] = I('post.label');
                $data['bk_Room1'] = I('post.room_primary');
                $data['bk_Label1'] = I('post.label_primary');
                $data['bk_Room2'] = ($roomType != 2 ? I('post.room_middle') : 4);
                $data['bk_Label2'] = $roomType != 2 ? I('post.label_middle') : 4;
                $data['bk_Room3'] = ($roomType == 0 || $roomType == 1 ? I('post.room_high') : 4);
                $data['bk_Label3'] = ($roomType == 0 || $roomType == 1 ? I('post.label_high') : 4);
                $data['bk_Room4'] = ($roomType == 1 ? I('post.room_rich') : 4);
                $data['bk_Label4'] = ($roomType == 1 ? I('post.label_rich') : 4);
                $data['bk_RoomType'] = $roomType;
                $data['bk_Time'] = time();
                $data['bk_Operator'] = $this->login_admin_info['bk_name'];

                //socket通信的字符串
                $weights_str .= $data['bk_Weights'] . ',';  //权重
                $gameName_str .= $data['bk_GameName'] . ',';    //游戏名称
                $apkID_str .= $data['bk_APKID'] . ',';  //apk包
                $channelID_str .= $data['bk_ChannelID'] . ',';  //渠道
                $state_str .= $data['bk_State'] . ',';  //状态
                $label_str .= $data['bk_Label'] . ',';  //标签
                $room1_str .= $data['bk_Room1'] . ',';  //房间1
                $label1_str .= $data['bk_Label1'] . ',';    //房间1标签
                $room2_str .= $data['bk_Room2'] . ',';  //房间2
                $label2_str .= $data['bk_Label2'] . ',';    //房间2标签
                $room3_str .= $data['bk_Room3'] . ',';  //房间3
                $label3_str .= $data['bk_Label3'] . ',';    //房间3标签
                $room4_str .= $data['bk_Room4'] . ',';  //房间4
                $label4_str .= $data['bk_Label4'] . ',';    //房间4

                $result = $Model->add($data);
                intval($result) < 0 && $count++;
            }
        }

        //数据库事务回滚
        if ($count != 0) {
            $Model->rollback();
            $this->ajaxReturn(array('code' => 1, 'message' => '添加失败'));
        }

        //数据库事务提交
        $Model->commit();
        //数据传输给服务器
        $weights_str = substr($weights_str, 0, strlen($weights_str) - 1);   //权重
        $gameName_str = substr($gameName_str, 0, strlen($gameName_str) - 1);    //游戏名称
        $apkID_str = substr($apkID_str, 0, strlen($apkID_str) - 1); //apk包
        $channelID_str = substr($channelID_str, 0, strlen($channelID_str) - 1); //渠道
        $state_str = substr($state_str, 0, strlen($state_str) - 1); //状态
        $label_str = substr($label_str, 0, strlen($label_str) - 1); //标签
        $room1_str = substr($room1_str, 0, strlen($room1_str) - 1); //房间1
        $label1_str = substr($label1_str, 0, strlen($label1_str) - 1);  //房间1标签
        $room2_str = substr($room2_str, 0, strlen($room2_str) - 1); //房间2
        $label2_str = substr($label2_str, 0, strlen($label2_str) - 1);  //房间2标签
        $room3_str = substr($room3_str, 0, strlen($room3_str) - 1); //房间3
        $label3_str = substr($label3_str, 0, strlen($label3_str) - 1);  //房间3标签
        $room4_str = substr($room4_str, 0, strlen($room4_str) - 1); //房间4
        $label4_str = substr($label4_str, 0, strlen($label4_str) - 1);  //房间4标签

        $str = pack("S", strlen($weights_str)) . $weights_str . pack("S", strlen($gameName_str)) . $gameName_str .
            pack("S", strlen($apkID_str)) . $apkID_str . pack("S", strlen($channelID_str)) . $channelID_str .
            pack("S", strlen($state_str)) . $state_str . pack("S", strlen($label_str)) . $label_str .
            pack("S", strlen($room1_str)) . $room1_str . pack("S", strlen($label1_str)) . $label1_str .
            pack("S", strlen($room2_str)) . $room2_str . pack("S", strlen($label2_str)) . $label2_str .
            pack("S", strlen($room3_str)) . $room3_str . pack("S", strlen($label3_str)) . $label3_str .
            pack("S", strlen($room4_str)) . $room4_str . pack("S", strlen($label4_str)) . $label4_str;

        SendToGame(C('socket_ip'), 30000, 1000, $str);
        $this->ajaxReturn(array('code' => 0));
    }

    //游戏状态查看
    public function gameStateList()
    {
        $data = array();

        $gameName = C('games');

        //游戏标签
        $lable = C('label');
        //房间标签
        $_lable = C('_label');
        //房间档次标签
        $lable_ = C('label_');

        if (!IS_AJAX && I('get.isExecl/d') == 0) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');

        $layui_data['count'] = M('bk_gamestate')->count();
        $order = "bk_Weights desc";
        $Query = M('bk_gamestate')->order($order);

        if (0 == I('get.isExecl/d')) {
            $Query->page($layui_data['page'])->limit(I('get.limit/d'));
        }

        $data_list = $Query->select();

        $number = 1;
        foreach ($data_list as $key => $val) {
            if (0 == I('get.isExecl/d')) $data['id'] = $val['bk_id'];
            $data['number'] = $number;
            $data['weights'] = $val['bk_weights'];
            $data['name'] = $gameName[$val['bk_gamename']];
            $data['apk'] = $val['bk_apk'];
            $data['channel'] = $val['bk_channel'];
            $data['channel_state'] = $val['bk_channelstate'] == 1 ? '开启' : '关闭';
            $data['state'] = $val['bk_state'] == 1 ? '上架' : '下架';
            $data['label'] = $lable[$val['bk_label']];
            $data['room1'] = $val['bk_roomtype'] == 0 ? '初级-' . $_lable[$val['bk_room1']] : '平民-' . $_lable[$val['bk_room1']];
            $data['label1'] = $lable_[$val['bk_label1']];
            $data['room2'] = $val['bk_room2'] == 4 || $val['bk_roomtype'] == 2 ? $_lable[$val['bk_room2']] : ($val['bk_roomtype'] == 0 ? '中级-' . $_lable[$val['bk_room2']] : '小资-' . $_lable[$val['bk_room2']]);
            $data['label2'] = $lable_[$val['bk_label2']];
            $data['room3'] = $val['bk_room3'] == 4 || $val['bk_roomtype'] == 2 ? $_lable[$val['bk_room3']] : ($val['bk_roomtype'] == 0 ? '高级-' . $_lable[$val['bk_room3']] : '老板-' . $_lable[$val['bk_room3']]);
            $data['label3'] = $lable_[$val['bk_label3']];
            $data['room4'] = $val['bk_room4'] == 4 ? $_lable[$val['bk_room4']] : '土豪-' . $_lable[$val['bk_room4']];
            $data['label4'] = $lable_[$val['bk_label4']];
            $data['operator'] = $val['bk_operator'];
            $data['time'] = date('Y-m-d H:i:s', $val['bk_time']);
            if (0 == I('get.isExecl/d')) $data['editUrl'] = U("configManagement/editGameState", array('id' => $val['bk_id']));
            $layui_data['data'][] = $data;

            $number++;
        }

        if (1 == I('get.isExecl/d')) {
            $this->setExeclData(C('cellName.game_state'), $layui_data['data'], '游戏状态');
        }

        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //游戏状态编辑
    public function editGameState()
    {
        $id = I("get.id/d");
        $row = M('bk_gamestate')->where(array('bk_ID' => $id))->find();
        $this->assign('row', $row);
        $this->show();
    }

    //更新游戏状态
    public function doGameStateUpdate()
    {

        if (I('post.id/d') <= 0 || I('post.roomType/d') < 0 || I('post.weights/d') <= 0 ||
            I('post.state') == "" || I('post.label') == "" ||
            I('post.room_primary') == "" || I('post.label_primary') == "" ||
            I('post.room_middle') == "" || I('post.label_middle') == "" ||
            I('post.room_high') == "" || I('post.label_high') == "" ||
            I('post.room_rich') == "" || I('post.label_rich') == "") {

            $this->ajaxReturn(array('code' => 1, 'message' => '更新失败'));
        }

        if (I('post.weights/d') < 1 || I('post.weights/d') > 99) {
            $this->ajaxReturn(array('code' => 1, 'message' => '权重配置错误'));
        }

        $up_data['bk_Weights'] = I('post.weights/d');   //权重
        $up_data['bk_State'] = I('post.state/d');   //状态
        $up_data['bk_Label'] = I('post.label/d');   //标签
        $up_data['bk_Room1'] = I('post.room_primary/d');    //房间1
        $up_data['bk_Label1'] = I('post.label_primary/d');  //房间1标签
        $up_data['bk_Room2'] = I('post.roomType/d') != 2 ? I('post.room_middle/d') : 4; //房间2
        $up_data['bk_Label2'] = I('post.roomType/d') != 2 ? I('post.label_middle/d') : 4;   //房间2标签
        $up_data['bk_Room3'] = (I('post.roomType/d') == 0 || I('post.roomType/d') == 1 ? I('post.room_high/d') : 4);    //房间3
        $up_data['bk_Label3'] = (I('post.roomType/d') == 0 || I('post.roomType/d') == 1 ? I('post.label_high/d') : 4);  //房间3标签
        $up_data['bk_Room4'] = I('post.roomType/d') == 1 ? I('post.room_rich/d') : 4;   //房间4
        $up_data['bk_Label4'] = I('post.roomType/d') == 1 ? I('post.label_rich/d') : 4; //房间4标签

        $result = M('bk_gamestate')->where(array('bk_ID' => I('post.id/d')))->save($up_data);

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '更新失败'));
        }

        $result_list = M('bk_gamestate') - where(array('bk_ID' => I('post.id/d')))->find();
        //socket通信数据
        $str = pack("S", strlen($up_data['bk_Weights'])) . $up_data['bk_Weights'] . pack("S", strlen($result_list['bk_gamename'])) . $result_list['bk_gamename'] .
            pack("S", strlen($result_list['bk_apkid'])) . $result_list['bk_apkid'] . pack("S", strlen($result_list['bk_channelid'])) . $result_list['bk_channelid'] .
            pack("S", strlen($up_data['bk_State'])) . $up_data['bk_State'] . pack("S", strlen($up_data['bk_Label'])) . $up_data['bk_Label'] .
            pack("S", strlen($up_data['bk_Room1'])) . $up_data['bk_Room1'] . pack("S", strlen($up_data['bk_Label1'])) . $up_data['bk_Label1'] .
            pack("S", strlen($up_data['bk_Room2'])) . $up_data['bk_Room2'] . pack("S", strlen($up_data['bk_Label2'])) . $up_data['bk_Label2'] .
            pack("S", strlen($up_data['bk_Room3'])) . $up_data['bk_Room3'] . pack("S", strlen($up_data['bk_Label3'])) . $up_data['bk_Label3'] .
            pack("S", strlen($up_data['bk_Room4'])) . $up_data['bk_Room4'] . pack("S", strlen($up_data['bk_Label4'])) . $up_data['bk_Label4'];

        SendToGame(C('socket_ip'), 30000, 1000, $str);
        $this->ajaxReturn(array('code' => 0));
    }

    //删除游戏状态
    public function doGameStateDel()
    {

        if (I('post.id/d') <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        $id = I('post.id/d');
        $delete_list = M('bk_gamestate')->where(array('bk_ID' => $id))->find();

        //socket通信
        $str = pack("C", $delete_list['bk_gamename']) . pack("L", $delete_list['bk_apkid']) . pack("L", $delete_list['bk_channelid']);
        SendToGame(C('socket_ip'), 30000, 1006, $str);
        $result = M('bk_gamestate')->where(array('bk_ID' => $id))->delete();
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    //apk包渠道配置
    public function gameStateConf()
    {

        $apk_list = array();
        $channel_list = array();
        $apk = M('bk_apk')->where(array('bk_ApkState' => 1))->select();
        $channel = M('bk_channel')->where(array('bk_ChannelState' => 1))->select();

        foreach ($apk as $key => $val) {
            $apk_list[$val['bk_id']] = $val['bk_apk'];
        }

        foreach ($channel as $key => $val) {
            $channel_list[$val['bk_id']] = $val['bk_channel'];
        }

        if (!IS_AJAX) {
            $this->assign('apk', $apk_list);
            $this->assign('channel', $channel_list);
            $this->show();
            return;
        }

        if (I('post.apk/d') <= 0 || I('post.channel/d') <= 0) {
            $this->ajaxReturn(array('code' => 1));
        }

        //获取apk和channel的id     非自增id
        $data['bk_ApkID'] = M('bk_apk')->where(array('bk_ID' => I('post.apk/d')))->getField('bk_ApkID');
        $data['bk_ChannelID'] = M('bk_channel')->where(array('bk_ID' => I('post.channel/d')))->getField('bk_ChannelID');

        if ($data['bk_ApkID'] != "" && $data['bk_ChannelID'] != "") {

            $data['bk_True_ApkID'] = I('post.apk/d');
            $data['bk_True_ChannelID'] = I('post.channel/d');
            $data['bk_Operator'] = $this->login_admin_info['bk_name'];
            $data['bk_Time'] = time();

            $result = M('bk_apkchannel')->add($data);
            intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
        }
    }

    //新建apk包名
    public function addApk()
    {

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        if (I('post.apk') == "" || I('post.apk_id/d') <= 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '添加失败'));
        }

        if (((M('bk_apk')->where(array('bk_ApkID' => I('post.apk_id/d')))->find()) != NULL) ||
            ((M('bk_apk')->where(array('bk_Apk' => I('post.apk')))->find()) != NULL)) {

            $this->ajaxReturn(array('code' => 1, 'message' => '不能重复配置相同的apk包或者apk包id'));
        }

        $data['bk_Apk'] = I('post.apk');
        $data['bk_ApkID'] = I('post.apk_id/d');
        $data['bk_Operator'] = $this->login_admin_info['bk_name'];
        $data['bk_Time'] = time();
        $result = M('bk_apk')->add($data);
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    //apk包编辑
    public function apkList()
    {

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');
        $layui_data['count'] = M('bk_apk')->count();
        $order = "bk_Time desc";
        $data_list = M('bk_apk')->order($order)->page($layui_data['page'])->limit(I('get.limit/d'))->select();

        $number = 1;
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_id'];
            $data['number'] = $number;
            $data['apk'] = $val['bk_apk'];
            $data['apk_id'] = $val['bk_apkid'];
            $data['state'] = $val['bk_apkstate'];
            $data['operator'] = $val['bk_operator'];
            $data['time'] = date('Y-m-d H:i:s', $val['bk_time']);
            $data['amend'] = $val['bk_amendoperator'] == '0' ? '' : $val['bk_amendoperator'];
            $data['amend_time'] = $val['bk_amendtime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_amendtime']);
            $layui_data['data'][] = $data;

            $number++;
        }
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //apk包编辑-开启/关闭
    public function doApkState()
    {

        $id = I('post.id/d');
        $state = I('post.state/d');

        if ($id == 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        if (!in_array($state, array(0, 1))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        $result = M("bk_apk")->where(array("bk_ID" => $id))->data(array('bk_ApkState' => $state, 'bk_AmendOperator' => $this->login_admin_info['bk_name'], 'bk_AmendTime' => time()))->save();
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    //新建渠道
    public function addChannel()
    {

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        if (I('post.channel') == "" || I('post.channel_id/d') <= 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '添加失败'));
        }

        if (((M('bk_channel')->where(array('bk_ChannelID' => I('post.channel_id/d')))->find()) != NULL) || (M('bk_channel')->where(array('bk_Channel' => I('post.channel')))->find()) != NULL) {
            $this->ajaxReturn(array('code' => 1, 'message' => '不能重复配置相同的渠道或者渠道id'));
        }

        $data['bk_Channel'] = I('post.channel');
        $data['bk_ChannelID'] = I('post.channel_id/d');
        $data['bk_Operator'] = $this->login_admin_info['bk_name'];
        $data['bk_Time'] = time();
        $result = M('bk_channel')->add($data);
        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    //渠道编辑
    public function channelList()
    {

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');
        $layui_data['count'] = M('bk_channel')->count();
        $order = "bk_Time desc";
        $data_list = M('bk_channel')->order($order)->page($layui_data['page'])->limit(I('get.limit/d'))->select();

        $number = 1;
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_id'];
            $data['number'] = $number;
            $data['channel'] = $val['bk_channel'];
            $data['channel_id'] = $val['bk_channelid'];
            $data['state'] = $val['bk_channelstate'];
            $data['operator'] = $val['bk_operator'];
            $data['time'] = date('Y-m-d H:i:s', $val['bk_time']);
            $data['amend'] = $val['bk_amendoperator'] == '0' ? '' : $val['bk_amendoperator'];
            $data['amend_time'] = $val['bk_amendtime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_amendtime']);
            $layui_data['data'][] = $data;

            $number++;
        }
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //渠道编辑-开启/关闭
    public function doChannelStateAlone()
    {

        $id = I('post.id/d');
        $state = I('post.state/d');

        if ($id == 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        if (!in_array($state, array(0, 1))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        $result = M("bk_channel")->where(array("bk_ID" => $id))->data(array('bk_ChannelState' => $state, 'bk_AmendOperator' => $this->login_admin_info['bk_name'], 'bk_AmendTime' => time()))->save();

        intval($result) > 0 && $this->ajaxReturn(array('code' => 0));
    }

    //apk包渠道查看
    public function apkChannelList()
    {

        $apk_list = array();
        $channel_list = array();
        $apk = M('bk_apk')->select();
        $channel = M('bk_channel')->select();

        foreach ($apk as $key => $val) {
            $apk_list[$val['bk_id']] = $val['bk_apk'];
        }

        foreach ($channel as $key => $val) {
            $channel_list[$val['bk_id']] = $val['bk_channel'];
        }

        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $layui_data['page'] = I('get.page/d');
        $layui_data['count'] = M('bk_apkchannel')->count();
        $order = "bk_Time desc";
        $data_list = M('bk_apkchannel')->order($order)->page($layui_data['page'])->limit(I('get.limit/d'))->select();

        $number = 0;
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_id'];
            $data['number'] = ++$number;
            $data['apk'] = $apk_list[$val['bk_true_apkid']];
            $data['channel'] = $channel_list[$val['bk_true_channelid']];
            $data['state'] = $val['bk_channelstate'];
            $data['operator'] = $val['bk_operator'];
            $data['time'] = date('Y-m-d H:i:s', $val['bk_time']);
            $data['amend'] = $val['bk_amendoperator'] == '0' ? '' : $val['bk_amendoperator'];
            $data['amend_time'] = $val['bk_amendtime'] == 0 ? '' : date('Y-m-d H:i:s', $val['bk_amendtime']);
            $layui_data['data'][] = $data;
        }
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //apk包名渠道查看-渠道状态
    public function doChannelState()
    {

        $id = I('post.id/d');
        $state = I('post.state/d');

        if ($id == 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        if (!in_array($state, array(0, 1))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        $result = M("bk_apkchannel")->where(array("bk_ID" => $id))->data(array('bk_ChannelState' => $state, 'bk_AmendOperator' => $this->login_admin_info['bk_name'], 'bk_AmendTime' => time()))->save();

        if (intval($result) <= 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '参数错误'));
        }

        $apk = M("bk_apkchannel")->where(array("bk_ID" => $id))->getField('bk_ApkID');
        $channel = M("bk_apkchannel")->where(array("bk_ID" => $id))->getField('bk_ChannelID');

        $str = pack("S", strlen($apk)) . $apk . pack("S", strlen($channel)) . $channel . pack("S", strlen($state)) . $state;
        $socket_result = SendToGame(C('socket_ip'), 30000, 1004, $str);

        $this->ajaxReturn(array('code' => 0));
    }

    //推广员链接
    public function promoterDomain()
    {

        if (!IS_AJAX) {
            $this->show();
            return false;
        }

        $rows = M('bk_tuiguangyuanurl')->order('bk_ID')->select();
        $type = [0 => '未知', 1 => '推广员链接', 2 => '非推广员链接'];
        foreach ($rows as $row) {
            $row_data['id'] = $row['bk_id'];
            $row_data['url'] = $row['bk_url'];
            $row_data['type'] = $type[$row['bk_type']];
            $row_data['operator'] = $row['bk_operator'];
            $row_data['time'] = date('Y-m-d', $row['bk_time']);
            $row_data['dataUrl'] = U('configManagement/promoterDomainEdit', ['id' => $row_data['id']]);
            $data['data'][] = $row_data;
        }
        $data['code'] = 0;
        $data['page'] = I('get.page/d');
        $this->ajaxReturn($data);
    }

    //推广员添加
    public function promoterDomainAdd()
    {
        if (!IS_AJAX) {
            $this->show();
            return false;
        }
        $data['bk_URL'] = I('post.url');
        $data['bk_Type'] = I('post.type/d');
        if (!in_array($data['bk_Type'], [1, 2])) {
            $this->ajaxReturn(['code' => 1, '类型数据非法']);
        }
        $data['bk_Operator'] = $this->login_admin_info['bk_name'];
        $data['bk_Time'] = time();
        M('bk_tuiguangyuanurl')->add($data);
        $this->sendGameMessagePromoterDomain($data);
        $this->ajaxReturn(['code' => 0]);
    }

    //推广员编辑
    public function promoterDomainEdit()
    {
        if (!IS_AJAX) {
            $row = M('bk_tuiguangyuanurl')->where(['bk_ID' => I('get.id/d')])->find();
            $this->assign('row', $row);
            $this->show();
            return false;
        }
        $data['bk_URL'] = I('post.url');
        $data['bk_Type'] = I('post.type/d');
        if (!in_array($data['bk_Type'], [1, 2])) {
            $this->ajaxReturn(['code' => 1, '类型数据非法']);
        }
        $data['bk_Operator'] = $this->login_admin_info['bk_name'];
        $data['bk_Time'] = time();
        $where['bk_ID'] = I('post.id/d');
        M('bk_tuiguangyuanurl')->where($where)->save($data);
        $this->sendGameMessagePromoterDomain($data);
        $this->ajaxReturn(['code' => 0]);
    }

    //删除域名
    public function promoterDomainDel()
    {
        $where['bk_ID'] = I('post.id/d');
        M('bk_tuiguangyuanurl')->where($where)->delete();
        $this->ajaxReturn(['code' => 0]);
    }

    //向游戏服务端发送数据(推广员添加)
    public function sendGameMessagePromoterDomain($data)
    {
        $data['bk_Type'] = pack('C', $data['bk_Type']); //权重
        $data['bk_URL_len'] = pack('S', strlen($data['bk_URL']));
        $body = $data['bk_Type'] . $data['bk_URL_len'] . $data['bk_URL'];
        SendToGame(C('SOCKET_IP'), 30000, 1034, $body);
    }

}