<?php

namespace Home\Controller;

use Think\Controller;

class BaseController extends Controller
{
    public $login_admin_info;
    static private $a;

    function __construct()
    {
        parent::__construct();
        //self::ipCheck();
        $this->checkLogin();
        self::meunList();
        $this->meunList();
        $this->login_admin_info = self::getAdminInfo(session('userid'));
        self::$a = $this->login_admin_info;
        if ($this->login_admin_info['bk_forbidden'] == 0) {
            session("userid", null);
        }
        self::powerCheck();
    }

    //IP白名单检测
    static private function ipCheck()
    {
        $login_id = getClientIp();
        $ips = M('bk_ip')->where(['bk_ID' => 1])->find();
        $ips = $ips['bk_ip'];
        $ips = unserialize($ips);
        if (!in_array($login_id, $ips)) {
//            http_response_code(404);
//            die();
        }
    }

    //权限检查
    static private function powerCheck()
    {
        $menu_id = M('bk_menu')->where(['menu_URL' => __SELF__])->getField('menu_ID');
        if (intval($menu_id) == 0) {
            return;
        }
        $t_count = M('bk_accountpurview')->where(['bk_AccountID' => session("userid"), 'menu_ID' => $menu_id])->count();
        if (intval($t_count) == 0) {
            die("非法操作...");
        }
    }

    private function checkLogin()
    {
        $no_redirect = ["login", "getVerify", "doLogin"];
        if (intval(session("userid")) == 0 && !in_array(ACTION_NAME, $no_redirect)) {
            $this->redirect('index/login', [], 0);
        }
    }

    private function meunList()
    {
        $admin_power_row = M('bk_accountpurview')->where(array('bk_AccountID' => session('userid')))->select();
        foreach ($admin_power_row as $val) $admin_power_id[] = intval($val['menu_id']);
        $cateRow = M('bk_menu')->where(array('menu_IsDisplay' => 1))->order('menu_Sort asc')->select();
        foreach ($cateRow as $key => $val) {
            if (!in_array($val['menu_id'], $admin_power_id)) {
                continue;
            }
            $data[$key]['menu_id'] = $val['menu_id'];
            $data[$key]['menu_parentid'] = $val['menu_parentid'];
            $data[$key]['menu_name'] = $val['menu_name'];
            $data[$key]['menu_url'] = $val['menu_url'];
            $data[$key]['menu_leftorright'] = $val['menu_leftorright'];
            $data[$key]['menu_subset'] = $val['menu_subset'];
        }
        $row = self::getTree($data, $pid = 0, $col_id = 'menu_id', $col_pid = 'menu_parentid');//$col_id,$col_pid,$col_cid对应分类表category中的字段
        $this->assign("menu_list", $row);
    }

    static public function getTree(&$data, $pid = 0, $col_id = 'menu_id', $col_pid = 'menu_parentid')
    {
        $childs = self::findChild($data, $pid, $col_pid);
        if (empty($childs)) {
            return null;
        }
        foreach ($childs as $key => $val) {
            $treeList = self::getTree($data, $val[$col_id], $col_id, $col_pid);
            if ($treeList !== null) {
                $childs[$key]['childs'] = $treeList;
            }
        }
        return $childs;
    }

    static public function findChild(&$data, $pid = 0, $col_pid = 'parent')
    {
        $rootList = array();
        foreach ($data as $key => $val) {
            if ($val[$col_pid] == $pid) {
                $rootList[] = $val;
                unset($data[$key]);
            }
        }
        return $rootList;
    }

    public function adminInfo($id = 0)
    {
        return self::getAdminInfo($id);
    }

    static private function getAdminInfo($id = 0)
    {
        return M('bk_account')->where(array(
            'bk_AccountID' => $id
        ))->find();
    }

    public function phpExecl()
    {
        //引入核心文件
        vendor("PHPExcel.PHPExcel");
        $objPHPExcel = new \PHPExcel();
        return $objPHPExcel;
    }

    public function setExeclData($cellName, $data, $title)
    {
        vendor("PHPExcel.PHPExcel.PHPExcel");
        vendor("PHPExcel.PHPExcel.Writer.IWriter");
        vendor("PHPExcel.PHPExcel.Writer.Abstract");
        vendor("PHPExcel.PHPExcel.Writer.Excel5");
        vendor("PHPExcel.PHPExcel.Writer.Excel2007");
        vendor("PHPExcel.PHPExcel.IOFactory");
        $phpExecl = $this->phpExecl();

        //处理表头
        $topNumber = 1;//表头有几行占用
        $xlsTitle = iconv('utf-8', 'gb2312', $title);//文件名称
        $fileName = $xlsTitle . date('_YmdHis');//文件名称
        $cellKey = array(
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
            'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
            'AA', 'AB', 'AC', 'AD', 'AE', 'AF', 'AG', 'AH', 'AI', 'AJ', 'AK', 'AL', 'AM',
            'AN', 'AO', 'AP', 'AQ', 'AR', 'AS', 'AT', 'AU', 'AV', 'AW', 'AX', 'AY', 'AZ'
        );

        foreach ($cellName as $k => $v) {
            $phpExecl->setActiveSheetIndex(0)->setCellValue($cellKey[$k] . $topNumber, $v);//设置表头数据
            //$phpExecl->getActiveSheet()->freezePane($cellKey[$k].($topNumber+1));//冻结窗口
            $phpExecl->getActiveSheet()->getStyle($cellKey[$k] . $topNumber)->getFont()->setBold(true);//设置是否加粗
            if ($v[3] > 0) { //大于0表示需要设置宽度
                $phpExecl->getActiveSheet()->getColumnDimension($cellKey[$k])->setWidth($v[3]); //设置列宽度
            }
        }

        foreach ($data as $key => $val) {
            $i = 0;
            foreach ($val as $k => $v) {
                $phpExecl->setActiveSheetIndex(0)->setCellValue($cellKey[$i] . ($key + 2), $v);
                $i++;
            }
        }
        header('pragma:public');
        header('Content-type:application/vnd.ms-excel;charset=utf-8;name="' . $xlsTitle . '.xls"');
        header("Content-Disposition:attachment;filename=$fileName.xls");//attachment新窗口打印inline本窗口打印
        vendor("PHPExcel.PHPExcel.IOFactory");
        $objWriter = \PHPExcel_IOFactory::createWriter($phpExecl, 'Excel5');
        $objWriter->save('php://output');
        exit;
    }


}