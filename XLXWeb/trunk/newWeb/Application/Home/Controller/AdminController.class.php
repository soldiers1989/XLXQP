<?php

namespace Home\Controller;
class AdminController extends BaseController
{

    //ip白名单配制
    public function ipApproveConf()
    {
        if (!IS_AJAX) {
            $ips = M('bk_ip')->where(['bk_ID' => 1])->find();
            $ips = $ips['bk_ip'];
            $this->assign("ips", implode("\n", unserialize($ips)));
            $this->show();
            return;
        }
        $ips = trim(I('post.ips'));
        $ips = explode("\n", $ips);
        if (count($ips) == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '参数错误']);
        }
        $ips = serialize($ips);
        if (M('bk_ip')->where(['bk_ID' => 1])->count() == 0) {
            M('bk_ip')->add(['bk_IP' => $ips]);
        } else {
            M('bk_ip')->where(['bk_ID' => 1])->save(['bk_IP' => $ips]);
        }
        $this->ajaxReturn(['code' => 0]);
    }

    public function adminList()
    {
        $where_data = array();
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $role_list = M('bk_role')->select();
        foreach ($role_list as $val) {
            $role_list_data[$val['bk_id']] = $val['bk_name'];
        }

        $data_list = M('bk_account')->where($where_data)->order(array("bk_AccountID" => "asc"))->page(I('page/d'))->limit(I('limit/d'))->select();
        $layui_data['count'] = M('bk_account')->where($where_data)->count();
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_accountid'];
            $data['name'] = $val['bk_name'];
            $data['qq'] = $val['bk_qq'];
            $data['wechat'] = $val['bk_wechat'];
            $data['phone'] = $val['bk_phone'];
            $data['type'] = $role_list_data[$val['bk_type']];
            $data['forbidden'] = $val['bk_forbidden'];
            $data['powereditUrl'] = U('admin/powerEdit', array('id' => $data['id']));
            $data['adminPasswdEditUrl'] = U('admin/adminPasswdEdit', array('id' => $data['id']));
            $data['adminEditUrl'] = U('admin/adminEdit', array('id' => $data['id']));
            $layui_data['data'][] = $data;
        }
        $layui_data['page'] = I('get.page/d');
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    //角色列表
    public function roleList()
    {
        if (!IS_AJAX) {
            $this->show();
            return;
        }
        $rows = M('bk_role')->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        $data['count'] = M('bk_role')->count();
        foreach ($rows as $key => $row) {
            $row_data['id'] = $row['bk_id'];
            $row_data['name'] = $row['bk_name'];
            $row_data['powerRoleEditUrl'] = U('admin/powerRoleEdit', ['id' => $row['bk_id']]);
            $row_data['editUrl'] = U('admin/roleEdit', ['id' => $row['bk_id']]);
            $data['data'][] = $row_data;
        }
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //角色添加
    public function addRole()
    {
        $this->show();
    }

    public function doRoleDel()
    {
        $id = I('post.id/d');
        M('bk_role')->where([
            'bk_ID' => $id
        ])->delete();
        $this->ajaxReturn(['code' => 0]);
    }

    //角色添加
    public function doAddRole()
    {
        $data['bk_Name'] = I('post.name');
        if (empty($data['bk_Name'])) {
            $this->ajaxReturn(['code' => 1, 'message' => '参数错误']);
        }
        $id = M('bk_role')->data($data)->add();
        if ($id == 0) {
            $this->ajaxReturn(['code' => 1, 'message' => '添加失败']);
        }
        $this->ajaxReturn(['code' => 0]);
    }

    //角色权限管理
    public function powerRoleEdit()
    {
        $this->show();
    }

    //角色修改
    public function roleEdit()
    {
        $role = M('bk_role')->where(['bk_ID' => I('get.id/d')])->find();
        $this->assign("role", $role);
        $this->show();
    }

    //
    public function doEditRole()
    {
        $where['bk_ID'] = I('post.id/d');
        $data['bk_Name'] = I('post.name');
        $count = M('bk_role')->where($where)->save($data);
        if (0 != $count) {
            $this->ajaxReturn(['code' => 0]);
        }
        $this->ajaxReturn(['code' => 1, 'message' => '更新失败']);
    }

    //添加管理员
    public function adminAdd()
    {
        $role_list = M('bk_role')->select();
        $this->assign('role_list', $role_list);
        $this->show();
    }

    //管理员添加
    public function doAdminAdd()
    {
        $data['bk_Name'] = I('post.a_name');
        $data['bk_Type'] = I('post.a_type/d');
        $data['bk_QQ'] = I('post.a_qq');
        $data['bk_WeChat'] = I('post.a_wechat');
        $data['bk_Phone'] = I('post.a_phone');
        $data['bk_Password'] = I('post.a_password');

        if (trim($data['bk_Name']) == '') {
            $this->ajaxReturn(array('code' => 1, 'message' => '管理员名称不能为空'));
        }

        if (!preg_match("/^[0-9a-zA-Z\s]+$/", $data['bk_Name'])) {
            $this->ajaxReturn(array('code' => 1, 'message' => '管理员名称只能为英文'));
        }

        if (trim($data['bk_Password']) == '') {
            $this->ajaxReturn(array('code' => 1, 'message' => '管理员密码不能为空'));
        }

        $data['bk_Password'] = md5($data['bk_Password']);
        $admin_count = M("bk_account")->where(array(
            'bk_Name' => $data['bk_Name']
        ))->count();

        if ($admin_count > 0) {
            $this->ajaxReturn(array('code' => 1, 'message' => '管理员已经存在'));
        }
        $id = M('bk_account')->add($data);
        if ($id > 0) {
            //将角色 权限 添加到管理权限
            $role_power = M('bk_rolepurview')->where(['bk_RoleID' => $data['bk_Type']])->select();
            foreach ($role_power as $key => $row) {
                M('bk_accountpurview')->data(['menu_ID' => $row['bk_menuid'], 'bk_AccountID' => $id])->add();
            }
            $this->ajaxReturn(['code' => 0]);
        }
    }

    //管理员信息编辑
    public function adminEdit()
    {
        $id = I('get.id/d');
        $row = M('bk_account')->where(['bk_AccountID' => $id])->find();
        $this->assign('admin', $row);
        $role_list = M('bk_role')->select();
        $this->assign('role_list', $role_list);

        $this->show();
    }

    //是否禁用管理
    public function doAdminForbidden()
    {
        $id = I('post.id/d');
        $forbidden = I('post.forbidden/d');
        if (!in_array($forbidden, array(1, 0))) {
            $this->ajaxReturn(array('code' => 1, 'message' => '非法数据'));
        }

        M('bk_account')->where(array('bk_AccountID' => $id))->save(array('bk_Forbidden' => $forbidden));
        $this->ajaxReturn(array('code' => 0));
    }

    //权限管理
    public function powerEdit()
    {
        $this->show();
    }

    //权限更新
    public function doPowerEdit()
    {
        $admin_id = I('post.aid/d');
        $menu_ids = I('post.ids');

        $t_count = function () use ($admin_id) {
            return M('bk_accountpurview')->where(array('bk_AccountID' => $admin_id))->count();
        };
        if ($t_count() > 0) {
            M('bk_accountpurview')->where(array('bk_AccountID' => $admin_id))->delete();
        }
        foreach ($menu_ids as $val) {
            if (intval($val) == 0) {
                continue;
            }
            M('bk_accountpurview')->add(array(
                'bk_AccountID' => $admin_id,
                'menu_ID' => intval($val)
            ));
        }
        $this->ajaxReturn(array('code' => 0));
    }

    //修改管理员密码
    public function adminPasswdEdit()
    {
        $id = I('get.id/d');
        $row = M('bk_account')->where(['bk_AccountID' => $id])->find();
        $this->assign('row', $row);
        $this->show();
    }

    //修改管理员密码
    public function doAdminPasswdEdit()
    {
        $where['bk_AccountID'] = I('post.id/d');
        $data['bk_Password'] = I('post.password');

        if (trim($data['bk_Password']) == '') {
            $this->ajaxReturn(array('code' => 1, 'message' => '管理员密码不能为空'));
        }
        $data['bk_Password'] = md5($data['bk_Password']);

        M('bk_account')->where($where)->save($data);
        $this->ajaxReturn(['code' => 0]);

    }

    public function getMenuList()
    {
        $admin_power_id = array();
        $admin_id = I('get.aid/d');
        $menu_list = M('bk_menu')->select();
        $admin_power_row = M('bk_accountpurview')->where(array('bk_AccountID' => $admin_id))->select();

        foreach ($admin_power_row as $val) $admin_power_id[] = intval($val['menu_id']);
        foreach ($menu_list as $key => $val) {
            //$menu_list[$key]['checked'] = false;
            if (in_array($val['menu_id'], $admin_power_id)) {
                $menu_list[$key]['checked'] = true;
            }
        }
        $this->ajaxReturn($menu_list);
    }

    //权限管理
    public function getRoleMenuList()
    {
        $role_power_id = array();
        $role_id = I('get.aid/d');
        $menu_list = M('bk_menu')->select();
        $role_power_row = M('bk_rolepurview')->where(array('bk_RoleID' => $role_id))->select();

        foreach ($role_power_row as $val) $role_power_id[] = intval($val['bk_menuid']);
        foreach ($menu_list as $key => $val) {
            if (in_array($val['menu_id'], $role_power_id)) {
                $menu_list[$key]['checked'] = true;
            }
        }
        $this->ajaxReturn($menu_list);
    }

    //角色权限管理
    public function doRolePowerEdit()
    {
        $role_id = I('post.aid/d');
        $menu_ids = I('post.ids');

        $t_count = function () use ($role_id) {
            return M('bk_rolepurview')->where(array('bk_RoleID' => $role_id))->count();
        };

        if ($t_count() > 0) {
            M('bk_rolepurview')->where(array('bk_RoleID' => $role_id))->delete();
        }

        foreach ($menu_ids as $val) {
            if (intval($val) == 0) {
                continue;
            }

            M('bk_rolepurview')->add(array(
                'bk_RoleID' => $role_id,
                'bk_MenuID' => intval($val)
            ));
        }
        $this->ajaxReturn(array('code' => 0));
    }

    public function getQRCodeGoogleUrl()
    {
        $id = I('post.id/d');
        Vendor('GoogleAuthenticator.GoogleAuthenticator');
        $ga = new \GoogleAuthenticator();
        $GoogleVCode = M('bk_account')->where(['bk_AccountID' => $id])->getField('bk_GoogleVCode');
        if (strlen($GoogleVCode) == 0) {
            $secret = $ga->createSecret();
            M('bk_account')->where(['bk_AccountID' => $id])->save(['bk_GoogleVCode' => $secret]);
        }
        $secret = $GoogleVCode;
        $name = M('bk_account')->where(['bk_AccountID' => $id])->getField('bk_name');
        $qrCodeUrl = $ga->getQRCodeGoogleUrl($name . ':bk.9527youxi.com', $secret);
        $this->ajaxReturn(['code' => 0, 'path' => $qrCodeUrl]);
    }
}