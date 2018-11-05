<?php
namespace Home\Controller;
use Think\Controller;
class BaseController extends Controller {
    public $login_admin_info;
    static private $admin_info;

    function __construct() {
        parent::__construct();
        //self::ipCheck();
        $this->checkLogin();
        self::menuList();
        $this->menuList();
        $this->login_admin_info = self::getAdminInfo(session('userID'));
        self::$admin_info = $this->login_admin_info;
        if ($this->login_admin_info['bk_forbidden'] == 0) session('userID', null);
        self::powerCheck();
    }

    // IP白名单检查
    static private function ipCheck() {
        $login_IP = getClientIp();
        $ipList = M('bk_ip')->where(['bk_ID' => 1])->find();
        $ipList = $ipList['bk_ip'];
        $ipList = unserialize($ipList);
        if(!in_array($login_IP, $ipList)) {
            http_response_code(404);
            die();
        }
    }

    // 登录检测
    private function checkLogin() {
        $no_redirect = ['login', 'doLogin'];
        if (intval(session('userID')) == 0 && !in_array(ACTION_NAME, $no_redirect)) {
            $this->redirect('index/login', [], 0);
        }
    }

    // 获取菜单列表
    private function menuList() {
        $menuList_row = M('bk_accountpurview')->field('bk_MenuID')->where(['bk_AccountID' => session('userID')])->select();
        foreach ($menuList_row as $val) {
            $menuList[] = intval($val['bk_menuid']);
        }
        $fields = ['bk_MenuID', 'bk_ParentID', 'bk_Name', 'bk_URL', 'bk_LeftOrRight', 'bk_Subset'];
        $allMenuList = M('bk_menu')->field($fields)->where(['bk_IsDisplay' => 1])->order('bk_Sort asc')->select();
        foreach ($allMenuList as $key => $val) {
            if (!in_array($val['bk_menuid'], $menuList)) {
                continue;
            }
            $data[$key]['menuID'] = $val['bk_menuid'];
            $data[$key]['menuParentID'] = $val['bk_parentid'];
            $data[$key]['menuName'] = $val['bk_name'];
            $data[$key]['menuURL'] = $val['bk_url'];
            $data[$key]['menuLeftOrRight'] = $val['bk_leftorright'];
            $data[$key]['menuSubset'] = $val['bk_subset'];
        }
        $result = self::getTree($data, $pid = 0, $col_id = 'menuID', $col_pid = 'menuParentID');
        $this->assign('menuList', $result);
    }

    //  获取父级菜单
    static public function getTree(&$data, $pid = 0, $col_id = 'menuID', $col_pid = 'menuParentID') {
        $child = self::findChild($data, $pid, $col_pid);
        if (empty($child)) {
            return null;
        }
        foreach ($child as $key => $val) {
            $treeList = self::getTree($data, $val[$col_id], $col_id, $col_pid);
            if ($treeList !== null) {
                $child[$key]['child'] = $treeList;
            }
        }
        return $child;
    }

    // 获取子菜单
    static public function findChild(&$data, $pid = 0, $col_pid = 'menuParentID') {
        $rootList = array();
        foreach ($data as $key => $val) {
            if ($val[$col_pid] == $pid) {
                $rootList[] = $val;
                unset($data[$key]);
            }
        }
        return $rootList;
    }

    // 管理员信息
    public function adminInfo($id = 0) {
        return self::getAdminInfo($id);
    }

    // 获取管理员信息
    static private function getAdminInfo($id = 0) {
        return M('bk_account')->where(['bk_AccountID' => $id])->find();
    }

    // 权限检查(模块)
    static private function powerCheck() {
        $menuID = M('bk_menu')->where(['bk_URL' => __SELF__])->getField('bk_MenuID');
        if (intval($menuID) == 0) return;
        $isPurview = M('bk_accountpurview')->where(['bk_AccountID' => session('userID'), 'bk_MenuID' => $menuID])->count();
        if (intval($isPurview) == 0) die('非法操作');
    }

    // Excel导出
    public function phpExcel() {
        // 引入核心文件
        vendor('PHPExcel.PHPExcel');
        $objPHPExcel = new \PHPExcel();
        return $objPHPExcel;
    }

    // Excel导出
    public function doExcelData($cellName, $data, $title) {
        vendor('PHPExcel.PHPExcel.PHPExcel');
        vendor('PHPExcel.PHPExcel.Writer.IWriter');
        vendor('PHPExcel.PHPExcel.Writer.Abstract');
        vendor('PHPExcel.PHPExcel.Writer.Excel5');
        vendor('PHPExcel.PHPExcel.Writer.Excel2007');
        vendor('PHPExcel.PHPExcel.IOFactory');
        $phpExcel = $this->phpExcel();

        // 处理表头
        $topNumber = 1; // 表头有几行占用
        $fileTitle = iconv('utf-8', 'gb2312', $title);   // 文件名称
        $fileName = $fileTitle.date('_YmdHis');  // 文件名称
        $cellKey = [
            'A','B','C','D','E','F','G','H','I','J','K','L','M',
            'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
            'AA','AB','AC','AD','AE','AF','AG','AH','AI','AJ','AK','AL','AM',
            'AN','AO','AP','AQ','AR','AS','AT','AU','AV','AW','AX','AY','AZ'];
        foreach ($cellName as $key => $val) {
            $phpExcel->setActiveSheetIndex(0)->setCellValue($cellKey[$key].$topNumber, $val);   // 设置表头数据
            //$phpExcel->getActiveSheet()->freezePane($cellKey[$key].($topNumber+1));   // 冻结窗口
            $phpExcel->getActiveSheet()->getStyle($cellKey[$key].$topNumber)->getFont()->setBold(true); // 设置是否加粗
            // 大于0表示需要设置宽度
            if($val[3] > 0) {
                $phpExcel->getActiveSheet()->getColumnDimension($cellKey[$key])->setWidth($val[3]); //设置列宽度
            }
        }

        //  处理数据
        foreach ($data as $key => $val) {
            $i = 0;
            foreach ($val as $k => $v) {
                $phpExcel->setActiveSheetIndex(0)->setCellValue($cellKey[$i].($key + 2),$v);
                $i++;
            }
        }

        // 导出Excel
        header('pragma:public');
        header('Content-type:application/vnd.ms-excel;charset=utf-8;name="'.$fileTitle.'.xls"');
        header("Content-Disposition:attachment;filename=$fileName.xls");    // attachment新窗口打印inline本窗口打印
        vendor('PHPExcel.PHPExcel.IOFactory');
        $objWriter = \PHPExcel_IOFactory::createWriter($phpExcel, 'Excel5');
        $objWriter->save('php://output');
        exit;
    }
}
?>