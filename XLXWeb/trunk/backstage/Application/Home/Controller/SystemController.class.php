<?php
namespace Home\Controller;
class SystemController extends BaseController {
    public function index() {
        $this->show();
    }

    // 菜单添加
    public function menuAdd() {
        $this->show();
    }

    // 菜单添加
    public function doMenuAdd() {
        $insert_data['bk_ParentID'] = I('post.menuParentID/d');
        $insert_data['bk_Name'] = trim(I('post.menuName'));  // 菜单名必填
        $insert_data['bk_URL'] = I('post.menuURL');
        $insert_data['bk_IsDisplay'] = I('post.menuIsDisplay/d');
        $insert_data['bk_LeftOrRight'] = I('post.menuLeftOrRight/d');
        $insert_data['bk_Sort'] = I('post.menuSort/d');
        $insert_data['bk_OperationTime'] = time();
        $insert_data['bk_Subset'] = 0;
        $insert_data['bk_Operator'] = $this->login_admin_info['bk_name'];
        if (empty($insert_data['bk_Name'])) $this->ajaxReturn(['code' => 1, 'message' => '菜单名不能为空']);
        if (!in_array($insert_data['bk_IsDisplay'], [0, 1])) $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        if (!in_array($insert_data['bk_LeftOrRight'], [0, 1])) $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        if ($insert_data['bk_Sort'] > 9999) $this->ajaxReturn(['code' => 1, 'message' => '排序最大最9999']);

        // 计算该菜单是否有子菜单
        M('bk_menu')->where(['bk_MenuID' => $insert_data['bk_ParentID']])->save(['bk_Subset' => 1]);
        $result = M('bk_menu')->add($insert_data);
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1]);
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 3;   // 添加
        $insert_data_log['bk_Log'] = '添加菜单-' . $insert_data['bk_Name'];
        M('bk_log')->add($insert_data_log);
        $this->ajaxReturn(['code' => 0]);
    }

    // 菜单查看
    public function menuCheck() {
        if (!IS_AJAX ){
            $this->show();
            return;
        }

        $layui_data['count'] = M('bk_menu')->count();
        $data_list = M('bk_menu')->order('bk_OperationTime desc')->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        foreach ($data_list as $key => $val) {
            $data['id'] = $val['bk_menuid'];
            $data['name'] = $val['bk_name'];
            $data['parentID'] = $val['bk_parentid'] == 0 ? '' : M('bk_menu')->where(['bk_MenuID' => $val['bk_parentid']])->getField('bk_name');
            $data['isDisplay'] = $val['bk_isdisplay'];
            $data['leftOrRight'] = $val['bk_leftorright'] == 0 ? '左显示' : '右显示';
            $data['sort'] = $val['bk_sort'];
            $data['subset'] = $val['bk_subset'] == 0 ? '无子菜单' : '有子菜单';
            $data['operator'] = $val['bk_operator'];
            $data['time'] = date('Y-m-d H:i:s', $val['bk_operationtime']);
            $data['editURL'] = U('system/editMenu', ['urlID' => $val['bk_menuid']]);
            $layui_data['data'][] = $data;
        }
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 菜单是否显示
    public function doMenuIsDisplay() {
        $id = I('post.id/d');
        $isDisplay = I('post.isDisplay/d');
        if (!in_array($isDisplay, [0, 1])) $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        $update_data['bk_IsDisplay'] = $isDisplay;
        $result = M('bk_menu')->where(['bk_MenuID' => $id])->save($update_data);
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1]);
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 2;   // 修改
        $log = M('bk_menu')->where(['bk_MenuID' => $id])->getField('bk_Name') . '):' . ($isDisplay == 1 ? '隐藏->显示' : '显示->隐藏');
        $insert_data_log['bk_Log'] = $log;
        M('bk_log')->add($insert_data_log);
        $this->ajaxReturn(['code' => 0]);
    }

    // 菜单编辑
    public function editMenu() {
        $id = I('get.urlID/d');
        $result = M('bk_menu')->where(['bk_MenuID' => $id])->find();
        $this->assign('menuInfo', $result);
        $this->show();
    }

    // 菜单编辑
    public function doEditMenu() {
        $id = I('post.id/d');
        $update_data['bk_URL'] = I('post.menuURL');
        $update_data['bk_Name'] = trim(I('post.menuName'));
        $update_data['bk_ParentID'] = I('post.menuParentID/d');
        $update_data['bk_IsDisplay'] = I('post.menuIsDisplay/d');
        $update_data['bk_LeftOrRight'] = I('post.menuLeftOrRight/d');
        $update_data['bk_Subset'] = 0;
        $update_data['bk_Sort'] = I('post.menuSort/d');
        $update_data['bk_Operator'] = $this->login_admin_info['bk_name'];
        if (empty($update_data['bk_Name'])) $this->ajaxReturn(['code' => 1, 'message' => '菜单名不能为空']);
        if ($update_data['bk_Sort'] > 9999) $this->ajaxReturn(['code' => 1, 'message' => '排序最大最9999']);
        if (!in_array($update_data['bk_IsDisplay'], [0, 1])) $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        if (!in_array($update_data['bk_LeftOrRight'], [0, 1])) $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        // 计算该菜单是否有子菜单
        M('bk_menu')->where(['bk_MenuID' => $update_data['bk_ParentID']])->save(['bk_Subset' => 1]);
        $result = M('bk_menu')->where(['bk_MenuID' => $id])->save($update_data);
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1]);
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 2;   // 修改
        $insert_data_log['bk_Log'] = '菜单编辑(' . M('bk_menu')->where(['bk_MenuID' => $id])->getField('bk_Name') . ')';
        M('bk_log')->add($insert_data_log);
        $this->ajaxReturn(['code' => 0]);
    }

    // 菜单删除
    public function doDeleteMenu() {
        $id = I('post.id/d');
        $menuName = M('bk_menu')->where(['bk_MenuID' => $id])->getField('bk_Name');
        $result = M('bk_menu')->where(['bk_MenuID' => $id])->delete();  // 删除菜单
        $Model_Delete1 = M(bk_accountpurview);
        $Model_Delete1->startTrans();
        $count1 = $Model_Delete1->where(['bk_MenuID' => $id])->count();
        $result1 = $Model_Delete1->where(['bk_MenuID' => $id])->delete();   // 删除管理员权限表
        if ($count1 != $result1) {
            $Model_Delete1->rollback();
            $this->ajaxReturn(['code' => 1]);
        }
        $Model_Delete2 = M(bk_rolepurview);
        $Model_Delete2->startTrans();
        $count2 = $Model_Delete2->where(['bk_MenuID' => $id])->count();
        $result2 = $Model_Delete2->where(['bk_MenuID' => $id])->delete();   // 删除角色权限
        if ($count2 != $result2) {
            $Model_Delete2->rollback();
            $this->ajaxReturn(['code' => 1]);
        }
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 4;   // 删除
        $insert_data_log['bk_Log'] = '菜单删除(' . $menuName . ')';
        M('bk_log')->add($insert_data_log);
        $Model_Delete1->commit() && $Model_Delete2->commit() && intval($result) > 0 && $this->ajaxReturn(['code' => 0]);
        $this->ajaxReturn(['code' => 1]);
    }

    // 角色管理
    public function roleManage() {
        if (!IS_AJAX) {
            $this->show();
            return;
        }

        $layui_data['count'] = M('bk_role')->count();
        $data_list = M('bk_role')->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        foreach ($data_list as $key => $val){
            $data['id'] = $val['bk_id'];
            $data['name'] = $val['bk_name'];
            $data['privilegeEditURL'] = U('system/rolePrivilegeEdit', ['roleID' => $val['bk_id']]);
            $data['nameEditURL'] = U('system/roleNameEdit', ['roleID' => $val['bk_id'] ]);
            $layui_data['data'][] = $data;
        }
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 角色添加
    public function roleAdd() {
        $this->show();
    }

    // 角色添加
    public function doRoleAdd() {
        $insert_data['bk_Name'] = trim(I('post.name'));
        if(empty($insert_data['bk_Name'])) $this->ajaxReturn(['code' => 1, 'message' => '角色名称不能为空']);
        $result = M('bk_role')->data($insert_data)->add();
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1]);
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 3;   // 添加
        $insert_data_log['bk_Log'] = '角色添加(' . trim(I('post.name')) . ')';
        M('bk_log')->add($insert_data_log);
        $this->ajaxReturn(['code' => 0]);
    }

    // 角色名称编辑
    public function roleNameEdit() {
        $roleID = I('get.roleID/d');
        $result = M('bk_role')->where(['bk_ID' => $roleID])->find();
        $this->assign('roleInfo', $result);
        $this->show();
    }

    // 角色名称编辑
    public function doRoleNameEdit() {
        $id = I('post.id/d');
        $update_data['bk_Name'] = trim(I('post.name'));
        if (empty($update_data['bk_Name'])) $this->ajaxReturn(['code' => 1, 'message' => '角色名称不能为空']);
        $result = M('bk_role')->where(['bk_ID' => $id])->save($update_data);
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1, 'message' => '更新失败']);
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 2;   // 修改
        $insert_data_log['bk_Log'] = '角色添加(' . trim(I('post.name')) . ')';
        M('bk_log')->add($insert_data_log);
        $this->ajaxReturn(['code' => 0]);
    }

    // 身份验证(Google验证)
    public function getQRCodeGoogleUrl() {
        $id = I('post.id/d');
        Vendor('GoogleAuthenticator.GoogleAuthenticator');
        $ga = new \GoogleAuthenticator();
        $GoogleVCode = M('bk_role')->where(['bk_ID' => $id])->getField('bk_GoogleVCode');
        if(strlen($GoogleVCode) == 0) {
            $secret = $ga->createSecret();
            M('bk_role')->where(['bk_ID' => $id])->save(['bk_GoogleVCode' => $secret]);
        }
        $secret = $GoogleVCode;
        $qrCodeUrl = $ga->getQRCodeGoogleUrl('Manage', $secret);
        $this->ajaxReturn(['code' => 0, 'path' => $qrCodeUrl]);
    }

    // 角色权限编辑
    public function rolePrivilegeEdit() {
        $this->show();
    }

    // 获取角色权限(菜单列表)
    public function getPrivilege() {
        $rolePurview = array();
        $roleID = I('get.roleID/d');
        $menuList = M('bk_menu')->order('bk_Sort asc')->select();
        $rolePurview_row = M('bk_rolepurview')->where(['bk_RoleID' => $roleID])->select();
        foreach ($rolePurview_row as $val)  $rolePurview[] = intval($val['bk_menuid']);
        foreach ($menuList as $key => $val) {
            if (in_array($val['bk_menuid'], $rolePurview)){
                $menuList[$key]['checked'] = true;
            }
        }
        $this->ajaxReturn($menuList);
    }

    // 角色权限编辑
    public function doRolePrivilegeEdit() {
        $roleID = I('post.roleID/d');
        $menuIDS = I('post.menuIDS');

        // 删除角色权限
        $Model_Delete = M('bk_rolepurview');
        $Model_Delete->startTrans();
        $count = $Model_Delete->where(['bk_RoleID' => $roleID])->count();
        $result_delete = 0;
        if ($count > 0) {
            $result_delete = $Model_Delete->where(['bk_RoleID' => $roleID])->delete();
        }
        if ($result_delete != $count) {
            $Model_Delete->rollback();
            $this->ajaxReturn(['code' => 1]);
        }
        $Model_Delete->commit();

        // 写入角色权限
        $Model_Add = M('bk_rolepurview');
        $Model_Add->startTrans();
        $count1 = $count2 = 0;
        foreach ($menuIDS as $val) {
            if (intval($val) > 0) {
                $count1++;  // 判断菜单总数
                $insert_data['bk_RoleID'] = $roleID;
                $insert_data['bk_MenuID'] = intval($val);
                $result = $Model_Add->add($insert_data);
                if (intval($result) > 0) $count2++; // 判断写入记录数
            }
        }
        if ($count1 != $count2) {
            $Model_Add->rollback();
            $this->ajaxReturn(['code' => 1]);
        }
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 2;   // 修改
        $insert_data_log['bk_Log'] = '权限编辑(' . M('bk_role')->where(['bk_ID' => $roleID])->getField('bk_Name') . ')';
        M('bk_log')->add($insert_data_log);
        $Model_Add->commit() && $this->ajaxReturn(['code' => 0]);
    }

    // 角色删除
    public function doRoleDelete() {
        $id = I('post.id/d');
        $roleName = M('bk_role')->where(['bk_ID' => $id])->getField('bk_Name');
        $result = M('bk_role')->where(['bk_ID' => $id])->delete();
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1]);
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 4;   // 删除
        $insert_data_log['bk_Log'] = '角色删除(' . $roleName . ')';
        M('bk_log')->add($insert_data_log);
        $this->ajaxReturn(['code' => 0]);
    }

    // 管理员查看
    public function adminCheck() {
        if (!IS_AJAX ){
            $this->show();
            return;
        }

        $roleList_row = M('bk_role')->select();
        foreach ($roleList_row as $val ){
            $roleList[$val['bk_id']] = $val['bk_name'];
        }

        $layui_data['count'] = M('bk_account')->count();
        $fields = ['bk_AccountID', 'bk_Name', 'bk_QQ', 'bk_WeChat', 'bk_Phone', 'bk_Type', 'bk_Forbidden'];
        $data_row = M('bk_account')->field($fields)->order('bk_AccountID asc')->page(I('get.page/d'))->limit(I('get.limit/d'))->select();
        foreach ($data_row as $key => $val) {
            $data['id'] = $val['bk_accountid'];
            $data['name'] = $val['bk_name'];
            $data['qq'] = $val['bk_qq'];
            $data['weChat'] = $val['bk_wechat'];
            $data['phone'] = $val['bk_phone'];
            $data['type'] = $roleList[$val['bk_type']];
            $data['isForbidden'] = $val['bk_forbidden'];
            $data['infoEditUrl'] = U('system/adminInfoEdit', ['id'=>  $val['bk_accountid']]);
            $data['privilegeEditURL'] = U('system/adminPrivilegeEdit', ['id'=>  $val['bk_accountid']]);
            $data['passwordEditURL'] = U('system/adminPasswordEdit', ['id'=>  $val['bk_accountid']]);
            $layui_data['data'][] = $data;
        }
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }

    // 管理员是否禁用
    public function doAdminIsForbidden() {
        $id = I('post.id/d');
        $update_data['bk_Forbidden'] = I('post.isForbidden/d');
        if (!in_array($update_data['bk_Forbidden'], [0, 1])) $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        $result = M('bk_account')->where(['bk_AccountID' => $id])->save($update_data);
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1]);
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 2;   // 修改
        $log = '管理员状态编辑(' . M('bk_account')->where(['bk_AccountID' => $id])->getField('bk_Name') . ')' . ':' . ($update_data['bk_Forbidden'] == 1 ? '禁用->正常' : '正常->禁用');
        $insert_data_log['bk_Log'] = $log;
        M('bk_log')->add($insert_data_log);
        $this->ajaxReturn(['code' => 0]);
    }

    // 管理员信息编辑
    public function adminInfoEdit() {
        $id = I('get.id/d');
        $adminInfo = M('bk_account')->where(['bk_AccountID'=> $id])->find();
        $this->assign('adminInfo', $adminInfo);
        $roleList_row = M('bk_role')->select();
        $this->assign('roleList', $roleList_row);
        $this->show();
    }

    // 管理员信息编辑
    public function doAdminInfoEdit() {
        $id = I('post.id/d');
        $roleType = M('bk_account')->where(['bk_AccountID' => $id])->getField('bk_Type');
        $update_data['bk_Name'] = trim(I('post.name'));
        $update_data['bk_Type'] = I('post.type/d');
        $update_data['bk_QQ'] = I('post.qq');   // 可为空
        $update_data['bk_WeChat'] = I('post.weChat');   // 可为空
        $update_data['bk_Phone'] = I('post.phone'); // 可为空
        if (empty($update_data['bk_Name'])) $this->ajaxReturn(['code' => 1, 'message' => '管理员账号不能为空']);
        if ($update_data['bk_Type'] <= 0) $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        $accountID = M('bk_account')->where(['bk_AccountID' => $id])->save($update_data);
        if (intval($accountID) <= 0) $this->ajaxReturn(['code' => 1]);  // 无任何更新时返回(失败)
        if ($roleType == I('post.type/d')) $this->ajaxReturn(['code' => 0]);    // 角色类型无变化时候返回(成功)

        // 删除管理员权限
        $Model_Delete = M('bk_accountpurview');
        $Model_Delete->startTrans();
        $count = $Model_Delete->where(['bk_AccountID' => $id])->count();
        $result_delete = 0;
        if ($count > 0) {
            $result_delete = $Model_Delete->where(['bk_AccountID' => $id])->delete();
        }
        if ($result_delete != $count) {
            $Model_Delete->rollback();
            $this->ajaxReturn(['code' => 1]);
        }
        $Model_Delete->commit();

        // 写入管理员权限
        $Model_Add = M('bk_accountpurview');
        $Model_Add->startTrans();
        $count1 = M('bk_rolepurview')->where(['bk_RoleID' => $update_data['bk_Type']])->count();
        $rolePrivilege_row = M('bk_rolepurview')->where(['bk_RoleID' => $update_data['bk_Type']])->select();
        $count2 = 0;
        foreach ($rolePrivilege_row as $key => $val) {
            $insert_data['bk_AccountID'] = $accountID; // 管理员账号ID
            $insert_data['bk_MenuID'] = $val['bk_menuid'];
            $result = $Model_Add->add($insert_data);
            intval($result) > 0 && $count2++;
        }
        if ($count1 != $count2) {
            $Model_Add->rollback();
            $this->ajaxReturn(['code' => 1]);
        }
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 2;   // 修改
        $insert_data_log['bk_Log'] = '管理员信息编辑(' . M('bk_account')->where(['bk_AccountID' => $id])->getField('bk_Name') . ')';
        M('bk_log')->add($insert_data_log);
        $Model_Add->commit() && $this->ajaxReturn(['code' => 0]);   // 管理员所有权限写入返回(成功)
    }

    // 管理员权限编辑
    public function adminPrivilegeEdit() {
        $this->show();
    }

    // 获取管理员权限(菜单列表)
    public function getAdminPrivilege() {
        $adminPurview = array();
        $adminID = I('get.adminID/d');
        $menuList = M('bk_menu')->order('bk_Sort asc')->select();
        $adminPurview_row = M('bk_accountpurview')->where(['bk_AccountID' => $adminID])->select();
        foreach ($adminPurview_row as $val)  $adminPurview[] = intval($val['bk_menuid']);
        foreach ($menuList as $key => $val) {
            if (in_array($val['bk_menuid'], $adminPurview)){
                $menuList[$key]['checked'] = true;
            }
        }
        $this->ajaxReturn($menuList);
    }

    // 管理员权限编辑
    public function doAdminPrivilegeEdit() {
        $adminID = I('post.adminID/d');
        $menuIDS = I('post.menuIDS');

        // 删除管理员权限
        $Model_Delete = M('bk_accountpurview');
        $Model_Delete->startTrans();
        $count = $Model_Delete->where(['bk_AccountID' => $adminID])->count();
        $result_delete = 0;
        if ($count > 0) $result_delete = $Model_Delete->where(['bk_AccountID' => $adminID])->delete();
        if ($result_delete != $count) {
            $Model_Delete->rollback();
            $this->ajaxReturn(['code' => 1]);
        }
        $Model_Delete->commit();

        // 写入管理员权限
        $Model_Add = M('bk_accountpurview');
        $Model_Add->startTrans();
        $count1 = $count2 = 0;
        foreach ($menuIDS as $val) {
            if (intval($val) > 0) {
                $count1++;  // 判断菜单总数
                $insert_data['bk_AccountID'] = $adminID;
                $insert_data['bk_MenuID'] = intval($val);
                $result = $Model_Add->add($insert_data);
                if (intval($result) > 0) $count2++; // 判断写入记录数
            }
        }
        if ($count1 != $count2) {
            $Model_Add->rollback();
            $this->ajaxReturn(['code' => 1]);
        }
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 2;   // 修改
        $insert_data_log['bk_Log'] = '管理员权限编辑(' . M('bk_account')->where(['bk_AccountID' => $adminID])->getField('bk_Name') . ')';
        M('bk_log')->add($insert_data_log);
        $Model_Add->commit() && $this->ajaxReturn(['code' => 0]);
    }

    // 管理员密码修改
    public function adminPasswordEdit() {
        $id = I('get.id/d');
        $result = M('bk_account')->where(['bk_AccountID'=> $id])->find();
        $this->assign('adminInfo', $result);
        $this->show();
    }

    // 管理员密码修改
    public function doAdminPasswordEdit() {
        $id = I('post.id/d');
        $update_data['bk_Password'] = trim(I('post.password'));
        if (empty($update_data['bk_Password'])) $this->ajaxReturn(['code' => 1, 'message' => '管理员密码不能为空']);
        $update_data['bk_Password'] = md5($update_data['bk_Password']);
        $result = M('bk_account')->where(['bk_AccountID' => $id])->save($update_data);
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1]);
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 2;   // 修改
        $insert_data_log['bk_Log'] = '管理员权限编辑(' . M('bk_account')->where(['bk_AccountID' => $id])->getField('bk_Name') . ')';
        M('bk_log')->add($insert_data_log);
        $this->ajaxReturn(['code' => 0]);
    }

    // 管理员删除
    public function doAdminDelete() {
        $id = I('post.id/d');
        $adminName = M('bk_account')->where(['bk_AccountID' => $id])->getField('bk_Name');
        $result = M('bk_account')->where(['bk_AccountID' => $id])->delete();
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1]);
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 4;   // 删除
        $insert_data_log['bk_Log'] = '管理员删除(' . $adminName . ')';
        M('bk_log')->add($insert_data_log);
        $this->ajaxReturn(['code' => 0]);
    }

    // 管理员添加
    public function adminAdd() {
        $roleList = M('bk_role')->select();
        $this->assign('roleList', $roleList );
        $this->show();
    }

    // 管理员添加
    public function doAdminAdd() {
        $insert_data['bk_Name'] = trim(I('post.name'));
        $insert_data['bk_Type'] = I('post.type/d');
        $insert_data['bk_QQ'] = I('post.qq');
        $insert_data['bk_WeChat'] = I('post.weChat');
        $insert_data['bk_Phone'] = I('post.phone');
        $insert_data['bk_Password'] = trim(I('post.password'));
        $insert_data['bk_GoogleVCode'] = M('bk_role')->where(['bk_ID' => I('post.type/d')])->getField('bk_GoogleVCode');
        if (empty($insert_data['bk_Name'])) $this->ajaxReturn(['code' => 1, 'message' => '管理员账号不能为空']);
        if(!preg_match('/^[0-9a-zA-Z]{2,16}$/', $insert_data['bk_Name'])) $this->ajaxReturn(['code' => 1, 'message' => '管理员账号格式错误']);
        if ($insert_data['bk_Type'] <=0) $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        if (empty($insert_data['bk_GoogleVCode'])) $this->ajaxReturn(['code' => 1, 'message' => '非法数据']);
        if (empty($insert_data['bk_Password'])) $this->ajaxReturn(['code' => 1, 'message' => '管理员密码不能为空']);
        $insert_data['bk_Password'] = md5($insert_data['bk_Password']);
        $count = M('bk_account')->where(['bk_Name' => $insert_data['bk_Name']])->count();
        if ($count > 0) $this->ajaxReturn(['code' => 1, 'message' => '管理员账号已经存在']);
        $result = M('bk_account')->add($insert_data);   // 返回管理员ID
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1]);
        // 管理员继承对应角色权限
        $Model = M('bk_accountpurview');
        $Model->startTrans();
        $rolePrivilege = M('bk_rolepurview')->where(['bk_RoleID' => I('post.type/d')])->select();
        $countPrivileg = M('bk_rolepurview')->where(['bk_RoleID' => I('post.type/d')])->count();
        $countAdd = 0;
        foreach ($rolePrivilege as $key => $val) {
            $resultAdd = $Model->data(['bk_AccountID' => $result, 'bk_MenuID' => $val['bk_menuid']])->add();
            if ($resultAdd > 0) $countAdd++;
        }
        if ($countPrivileg != $countAdd) {
            $Model->rollback();
            $this->ajaxReturn(['code' => 1, 'message' => '权限继承失败']);
        }
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 3;   // 添加
        $insert_data_log['bk_Log'] = '管理员添加(' . $insert_data['bk_Name'] . ')';
        M('bk_log')->add($insert_data_log);
        $Model->commit() && $this->ajaxReturn(['code' => 0]);
        $this->ajaxReturn(['code' => 0]);
    }

    // IP白名单配置
    public function ipApproveConf() {
        if(!IS_AJAX) {
            $ipList = M('bk_ip')->where(['bk_ID' => 1])->find();
            $ipList = $ipList['bk_ip'];
            $this->assign("ipList", implode("\n" ,unserialize($ipList)));
            $this->show();
            return;
        }
        $ipList = trim(I('post.ipList'));
        if (empty($ipList)) $this->ajaxReturn(['code' => 1, 'message' => 'IP地址不能为空']);
        $ipList = explode("\n", $ipList);
        if(count($ipList) == 0) $this->ajaxReturn(['code' => 1, 'message' => '参数错误']);
        foreach ($ipList as $key => $val) {
            $pattern = '/^(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$/';
            if (!preg_match($pattern, $val)) $this->ajaxReturn(['code' => 1, 'message' => '第' . ($key + 1) .'个IP地址格式错误']);
        }
        $ipList = serialize($ipList);
        $count = M('bk_ip')->where(['bk_ID' => 1])->count();
        if ($count == 0) {
            $insert_data['bk_IP'] = $ipList;
            $result = M('bk_ip')->add($insert_data);
        }else {
            $update_data['bk_IP'] = $ipList;
            $result = M('bk_ip')->where(['bk_ID' => 1])->save($update_data);
        }
        if (intval($result) <= 0) $this->ajaxReturn(['code' => 1]);
        // 日志记录
        $insert_data_log['bk_Time'] = time();
        $insert_data_log['bk_Account'] = $this->login_admin_info['bk_name'];
        $insert_data_log['bk_IP'] = $_SERVER['REMOTE_ADDR'];
        $insert_data_log['bk_Type'] = 3;   // 添加
        $insert_data_log['bk_Log'] = 'IP白名单添加';
        M('bk_log')->add($insert_data_log);
        $this->ajaxReturn(['code' => 0]);
    }

    // 管理员日志
    public function adminLog() {
        $adminLogType = C('ADMIN_LOG_TYPE');

        if(!IS_AJAX) {
            $this->show();
            return;
        }
        $layui_data['count'] = M('bk_log')->count();
        $data_row = M('bk_log')->page(I('get.page/d'))->limit(I('get.limit/d'))->order('bk_ID desc')->select();
        foreach ($data_row as $key => $val) {
            $data['name'] = $val['bk_account'];
            $data['ip'] = $val['bk_ip'];
            $data['type'] = $adminLogType[$val['bk_type']];
            $data['log'] = $val['bk_log'];
            $data['time'] = date("Y-m-d H:i:s", $val['bk_time']);
            $layui_data['data'][] = $data;
        }
        $layui_data['code'] = 0;
        $this->ajaxReturn($layui_data);
    }
}
?>