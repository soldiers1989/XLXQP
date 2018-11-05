<?php
/**
 * Created by PhpStorm.
 * User: a
 * Date: 2018/7/12
 * Time: 17:42
 */
namespace Home\Controller;
use Think\Controller;

class BaseController extends Controller {
    public $login_admin_info;
    function __construct(){
        parent::__construct();
        $this->checkLogin();
        $this->meunList();
        $this->login_admin_info = self::getAdminInfo( session('userid') );
    }

    //检查登录
    private function checkLogin() {
        $no_redirect = ["login", "getVerify", "doLogin"];
        if ( intval(session("userid")) == 0 && !in_array(ACTION_NAME, $no_redirect) )   {
            $this->redirect('index/login', [], 0 );
        }
    }

    //菜单列表
    private  function meunList(){
        $admin_power_row = M('admin_power')->where( array( 'aid' => session('userid') ) )->select();
        foreach ( $admin_power_row as $val )  $admin_power_id[] = intval($val['mid']);
        $cateRow = M('menu')->where( array( 'isdisplay' => 1 ) )->order("sort asc")->select();

        foreach ( $cateRow as $key => $val ){
            if ( !in_array($val['id'], $admin_power_id) ) {
                continue;
            }
            $data[$key]['id'] = $val['id'];
            $data[$key]['parentid'] = $val['parentid'];
            $data[$key]['name'] = $val['name'];
            $data[$key]['url'] = $val['url'];
            $data[$key]['subset'] = $val['subset'];
        }

        $row = self::getTree($data, $pid = 0, $col_id = 'id', $col_pid = 'parentid'); //$col_id,$col_pid,$col_cid对应分类表category中的字段
        $this->assign("menu_list", $row);
    }

    static public function getTree(&$data, $pid = 0, $col_id = 'id', $col_pid = 'parentid') {
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


    static public function findChild(&$data, $pid = 0, $col_pid = 'parentid') {
        $rootList = array();
        foreach ($data as $key => $val) {
            if ($val[$col_pid] == $pid) {
                $rootList[]   = $val;
                unset($data[$key]);
            }
        }
        return $rootList;
    }

    static private function getAdminInfo( $id = 0 ){
        return M('admin')->where(array(
            'id' => $id
        ))->find();
    }

}