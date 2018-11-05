<?php
namespace Home\Controller;
class IndexController extends BaseController {
    public function index() {
        $this->show();
    }

    public function welcome() {
        $this->show();
    }

    // 管理员登录
    public function login() {
        $this->show();
    }

    // 管理员登录验证
    public function doLogin() {
        Vendor('GoogleAuthenticator.GoogleAuthenticator');
        $googleVerify = new \GoogleAuthenticator();
        $username = I('post.username'); // 用户名
        $password = I('post.password'); // 密码
        $vercode = I('post.vercode');   // 谷歌验证码
        $userInfo = M('bk_account')->where(['bk_Name' => $username, 'bk_Password' => md5($password)])->find();
        $this->loginLogWrite(['username' => $username]); // 登录日志
        intval($userInfo['bk_accountid']) == 0 && $this->ajaxReturn(['code' => 1, 'message' => '用户名或密码错误']);
//        $checkResult = $googleVerify->verifyCode($userInfo['bk_googlevcode'], $vercode, 0); // 谷歌验证
//        if (!$checkResult) {
//            $this->ajaxReturn(['code' => 1, 'message' => '验证码错误']);
//        }
        if ($userInfo['bk_forbidden'] == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '账号被禁用']);
        }
        session('userID', $userInfo['bk_accountid']);
        $this->ajaxReturn(['code' => 0, 'message' => '']);
    }

    // 管理员退出登录
    public function logout() {
        session('userID', null);
        $this->redirect('index/login', [], 0);
    }

    // 管理员修改密码
    public function editPassword() {
        $this->login_admin_info;
        $this->assign('userInfo', $this->login_admin_info);
        $this->show();
    }

    // 管理员修改密码
    public function doEditPassword() {
        $update_data['bk_Password'] = trim(I('post.password'));
        if (empty($update_data['bk_Password'])) $this->ajaxReturn(['code' => 1, 'message' => '管理员密码不能为空']);
        $update_data['bk_Password'] = md5($update_data['bk_Password']);
        $result = M('bk_account')->where(['bk_AccountID' => $this->login_admin_info['bk_accountid']])->save($update_data);
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1, 'message' => '修改失败']);
        // 日记记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 2;   // 修改
        $insert_data_log['bk_Log'] = '修改密码';
        M('bk_log')->add($insert_data_log);
        $this->ajaxReturn(['code' => 0]);
    }

    // 管理员登录日志
    private function loginLogWrite($username) {
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $username['username'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 1;   // 登录
        $insert_data_log['bk_Log'] = '登录系统';
        M('bk_log')->add($insert_data_log);
    }

    // 获取子菜单
    public function getMenuChild() {
        $mid = I('get.mid');
        $menuList = M('bk_menu')->where(['bk_ParentID'=> $mid, 'bk_IsDisplay' => 1])->order('bk_Sort asc')->select();
        $this->ajaxReturn($menuList);
    }
}
?>