<?php
namespace Home\Controller;
class IndexController extends BaseController {
    public function index(){
        $this->assign('agent',  $this->login_admin_info);
        $this->assign('gold', $this->getUserGold());
        $this->show();
    }

    public function welcome(){
        $this->show();
    }

    //登录
    public function login(){
        $this->show();
    }

    //用记登录验证
    public function doLogin(){
        $vercode  = I("post.vercode");
        $verify = new \Think\Verify();
        !$verify->check($vercode) && $this->ajaxReturn( ["code"=>1, "message"=>"验证码错误"] );
        $userName = I("post.username");
        $passWd   = I("post.password");
        $userInfo = M("daili")->where( ["bk_BK_Accound"=>$userName, "bk_BK_Psd"=> md5($passWd)] )->find();

        //$this->loginLogWrite(array('account' => $userName)); //登录日志
        intval($userInfo['bk_id']) == 0 && $this->ajaxReturn(["code"=>1, "message"=>"用户名或密码错误"]);
        if ( $userInfo['bk_bk_state'] == 0  ) {
            $this->ajaxReturn(["code"=>1, "message"=>"帐号被禁用！"]);
        }
        session("userid", $userInfo['bk_id']);
        $this->ajaxReturn(["code"=>0]);
    }

    //取得验证码
    public function getVerify(){
        $Verify =  new \Think\Verify();
        $Verify->useNoise = false;
        $Verify->imageW = 110;
        $Verify->imageH = 38;
        $Verify->fontSize = 13;
        $Verify->entry();
    }

    //游戏冲值
    public function recharge(){
        $this->assign('gold', $this->getUserGold());
        $this->show();
    }

    //添加冲值
    public function doRechargeAdd() {
        $user_id = I('post.user_id/d');
        $confirm_user_id = I('post.confirm_user_id/d');
        if( $user_id != $confirm_user_id || $user_id == 0 ) {
            $this->ajaxReturn(['code' => 1, 'message' => '两次输入“玩家ID”不正确或为空'] );
        }

        if( $user_id == $this->login_admin_info['bk_accountid'] ) {
            $this->ajaxReturn(['code' => 1, 'message' => '自己不能给自己冲值'] );
        }

        if ( M('accountv')->where(['gd_AccountID' =>$user_id ])->count() == false ){
            $this->ajaxReturn(['code' => 1, 'message' => '玩家不存在，请检查“玩家ID”是否输入正确!'] );
        }

        $price = I('post.price/d');
        if( $price == 0 || $price < 0 ){
            $this->ajaxReturn(['code' => 1, 'message' => '请输入正确“冲值金额”'] );
        }

        if( $this->getUserGold() < $price ) {
            $this->ajaxReturn(['code' => 1, 'message' => "你的金币余额：".$this->getUserGold().", 不足：{$price} ."] );
        }

        //代理ID
        $did = pack("L", $this->login_admin_info['bk_accountid'] );
        //玩家ID
        $uid = pack("L", $user_id );
        //金币
        $price = pack("L", $price );
        $body = $did . $uid . $price ;
        $socket_result = SendToGame( C('socket_ip'), 30000, 1027, $body );
        $this->ajaxReturn(['code' => 0]);
    }

    //冲值记录
    public function record(){
        if( !IS_AJAX ){
            $this->show();
            return false;
        }

        if ( I('get.start_time') != '' ||  I('get.end_time') != '' ) {
            $start_time =  strtotime(I('get.start_time'));
            $end_time = strtotime(I('get.end_time'))+24*60*60;
            if (  I('get.start_time') == '' ) {
                $start_time =  1;
            }
            if ( I('get.end_time') == '' ) {
                $end_time = time();
            }
            $where_data['bk_ChargeTime'] =  array('between', array( $start_time, $end_time  ));
        }

        $where_data['bk_DailiID'] =  $this->login_admin_info['bk_accountid'];
        $rows = M('dailichargeliushui')->where( $where_data )->order('bk_ChargeTime desc')->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        $data['sql'] = M('dailichargeliushui')->getLastSql();
        $data['count'] = M('dailichargeliushui')->where( $where_data )->count();
        foreach ( $rows as $row ) {
            $row_data['date'] = date('Y-m-d H:i:s', $row['bk_chargetime']);
            $row_data['receiveName'] = $row['bk_playername'];
            $row_data['PlayerID'] = $row['bk_playerid'];
            $row_data['ChangeGold'] = $row['bk_changegold'] / 10000;
            $row_data['DailiBefore'] = $row['bk_dailibefore'] / 10000;
            $row_data['DailiEnd'] = $row['bk_dailiend'] / 10000;
            $row_data['lastToal'] = M('dailichargeliushui')->where([
                'bk_ChargeTime' => array( 'ELT', $row['bk_chargetime'] ),
                 'bk_DailiID' => $this->login_admin_info['bk_accountid']
            ])->sum("bk_changegold") / 10000;

            $moon_send_time = strtotime(date('Y-m', $row['bk_chargetime']));
            $moon_end_time = $row['bk_chargetime'];

            $row_data['moonToal'] = M('dailichargeliushui')->where([
                'bk_ChargeTime' => array( 'between' , array( $moon_send_time, $moon_end_time ) ),
                 'bk_DailiID' => $this->login_admin_info['bk_accountid']
            ])->sum("bk_changegold")/10000;
//            $row_data['sql'] = M('dailichargeliushui')->getLastSql();
//            $data['s'][$row_data['moonToal']] = date('Y-m-d', $row['bk_chargetime']);
            $data['data'][] = $row_data;
        }
        print_r( $data['s']);
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //取用户当前余额
    public function getUserGold( $IS_AJAX = false ){
        $gold = M('accountv')->where(['gd_AccountID' => $this->login_admin_info['bk_accountid']])->getField('gd_gold');
        if( I('post.is_ajax/d') == 1 ) {
            $IS_AJAX = true;
        }

        if( $IS_AJAX ) {
            $this->ajaxReturn(['gold' => $gold/10000]);
            return;
        }
        return $gold / 10000;
    }

    //修改密码
    public function editPasswd(){
        $row = M('daili')->where(['bk_ID' => session("userid") ])->find();
        $this->assign('daili', $row);
        $this->show();
    }

    //修改密码
    public function doEditPasswd() {
        $where['bk_ID'] = I('post.id/d');
        if(  $where['bk_ID'] !=  session("userid") ) $this->ajaxReturn(['code' => 1, 'message' => '非法操作']);
        if(  $where['bk_ID'] == 0 ) $this->ajaxReturn(['code' => 1, 'message' => '非法参数']);
        if( I('post.password') == '' ) $this->ajaxReturn(['code' => 1, 'message' => '密码不能为空']);
        $data['bk_BK_Psd'] =  md5(I('post.password'));
        $up_count = M('daili')->where($where)->save($data);
        if( $up_count == 0 ) {
            $this->ajaxReturn(['code' => 1, 'message' => '修改失败'] );
        }
        session("userid", null);
        $this->ajaxReturn(['code' => 0]);
    }

    //退出登录
    public function quit(){
        session("userid", null);
        $this->redirect('index/login', [], 0 );
    }
}
