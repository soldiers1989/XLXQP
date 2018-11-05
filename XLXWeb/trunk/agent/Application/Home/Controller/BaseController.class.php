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
        $this->login_admin_info = self::getAdminInfo( session('userid') );
    }

    //检查登录
    private function checkLogin() {
        $no_redirect = ["login", "getVerify", "doLogin"];
        if ( intval(session("userid")) == 0 && !in_array(ACTION_NAME, $no_redirect) )   {
            $this->redirect('index/login', [], 0 );
        }
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
        return M('daili')->where(array(
            'bk_ID' => $id
        ))->find();
    }

}