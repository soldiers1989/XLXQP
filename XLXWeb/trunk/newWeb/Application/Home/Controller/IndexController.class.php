<?php

namespace Home\Controller;
class IndexController extends BaseController
{
    public function index()
    {
        $this->show();
    }

    public function test()
    {
        $this->show();
    }

    public function welcome()
    {
        $this->show();
    }

    //用户登录
    public function login()
    {
        $this->show();
    }

    //用记登录验证
    public function doLogin()
    {
        Vendor('GoogleAuthenticator.GoogleAuthenticator');
        $ga = new \GoogleAuthenticator();
        $vercode = I("post.vercode");
        $userName = I("post.username");
        $passWd = I("post.password");
        $userInfo = M("bk_account")->where(["bk_Name" => $userName, "bk_Password" => md5($passWd)])->find();
        $this->loginLogWrite(array('account' => $userName)); //登录日志
        intval($userInfo['bk_accountid']) == 0 && $this->ajaxReturn(["code" => 1, "message" => "用户名或密码错误"]);
        $checkResult = $ga->verifyCode($userInfo['bk_googlevcode'], $vercode, 0);
        /*if( !$checkResult ) {
            $this->ajaxReturn(["code"=>1, "message"=>"验证码错误！"]);
        }*/

        if ($userInfo['bk_forbidden'] == 0) {
            $this->ajaxReturn(["code" => 1, "message" => "帐号被禁用！"]);
        }
        session("userid", $userInfo['bk_accountid']);
        $this->ajaxReturn(["code" => 0, "message" => ""]);
    }

    //用户退出登录
    public function outLogin()
    {
        session('userid', null);
        $this->redirect('index/login', [], 0);
    }

    //管理员修改密码
    public function editAdminPasswd()
    {
        $this->login_admin_info;
        $this->assign('row', $this->login_admin_info);
        $this->show();
    }

    //管理员修改密码
    public function doEditAdminPasswd()
    {
        $data['bk_Password'] = I('post.password');

        if (trim($data['bk_Password']) == '') {
            $this->ajaxReturn(array('code' => 1, 'message' => '管理员密码不能为空'));
        }
        $data['bk_Password'] = md5($data['bk_Password']);

        M('bk_account')->where(['bk_AccountID' => $this->login_admin_info['bk_accountid']])->save($data);
        session('userid', null);
        $this->ajaxReturn(['code' => 0]);
    }

    private function loginLogWrite($d)
    {
        $data['bk_Time'] = time();
        $data['bk_Account'] = $d['account'];
        $data['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $data['bk_Type'] = 1;
        $data['bk_Log'] = "登录";
        $data['bk_TableName'] = "bk_account";
        M("bk_log")->add($data);
    }

    //取得子菜单
    public function getMenuChilds()
    {
        $mid = I("get.mid");
        $menu_list = M("bk_menu")->where(["menu_ParentID" => $mid, 'menu_IsDisplay' => 1])->select();
        $this->ajaxReturn($menu_list);
    }

    //取得验证码
    public function getVerify()
    {
        $Verify = new \Think\Verify();
        $Verify->useNoise = false;
        $Verify->entry();
    }
}