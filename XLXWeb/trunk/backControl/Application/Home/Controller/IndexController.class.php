<?php
namespace Home\Controller;
class IndexController extends BaseController {
    public function index(){
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
        $userInfo = M("admin")->where( ["name"=>$userName, "passwd"=> md5($passWd)] )->find();
        //$this->loginLogWrite(array('account' => $userName)); //登录日志
        intval($userInfo['id']) == 0 && $this->ajaxReturn(["code"=>1, "message"=>"用户名或密码错误"]);
        if ( $userInfo['lock'] == 1  ) {
            $this->ajaxReturn(["code"=>1, "message"=>"帐号被禁用！"]);
        }
        session("userid", $userInfo['id']);
        $this->ajaxReturn(["code"=>0, "message"=>""]);
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

    //菜单添加
    public function menuAdd() {
        $this->show();
    }

    //菜单添加
    public function doMenuAdd() {
        $insert_data['url'] = I('post.m_url');
        $insert_data['name'] =  I('post.m_name');
        $insert_data['parentid'] =  I('post.m_parentid/d');
        $insert_data['isdisplay'] =  I('post.m_isdisplay/d');
        $insert_data['sort'] =  I('post.m_sort/d');
        $insert_data['addtime'] = time();
        $insert_data['subset'] = 0;
        $insert_data['operator'] = $this->login_admin_info['name'];

        trim($insert_data['name']) == "" && $this->ajaxReturn(array( 'code' => 1, 'message' => '菜单名不能为空' ));
        $insert_data['sort'] > 9999 && $this->ajaxReturn(array( 'code' => 1, 'message' => '排序最大最9999' ));
        !in_array($insert_data['isdisplay'], array( 0, 1)) && $this->ajaxReturn(array( 'code' => 1, 'message' => '非法数据' ));

        //计算是会有子项
        M('menu')->where( array(
            'id' => $insert_data['parentid']
        ))->save(array(
            'subset' => 1
        ));
        $info = M('menu')->add($insert_data);
        if ( intval($info) > 0  ){
            $this->ajaxReturn( array(
                'code' => 0
            ));
        }
    }

    //菜单管理
    public function menuSeting(){
        if ( !IS_AJAX  ){
            $this->show();
            return;
        }
        $data['count'] =  M("menu")->count();
        $data_list = M("menu")->order(["sort" => "asc"])->page(I('page/d'))->limit(I('limit/d'))->select();
        foreach ( $data_list as $key => $val ) {
            $parentMenu = $this->getOneMenu($val["parentid"]);
            $data['data'][$key]['id'] = $val['id'];
            $data['data'][$key]['name'] = $val['name'];
            $data['data'][$key]['parent'] = $parentMenu['name'];
            $data['data'][$key]['operator'] = $val['operator'];
            $data['data'][$key]['sort'] = $val['sort'];
            $data['data'][$key]['subset'] = ($val['subset'] == 0) ? "无" : "有";
            $data['data'][$key]['isdisplay'] = $val['isdisplay'] ;
            $data['data'][$key]['addtime'] = date('Y-m-d H:i', $val['addtime']) ;
            $data['data'][$key]['editUrl'] = U('index/editMenu', array(
                'id' => $val['id']
            ));
        }
        $data['page'] = I('get.page/d');
        $data['code'] = 0;
        $this->ajaxReturn( $data);
    }

    //菜单编辑
    public function editMenu(){
        $id = I('get.id/d');
        $row = M('menu')->where( array(
            'id' => $id
        ))->find();
        $this->assign('row', $row );
        $this->show();
    }

    //更新是否显示
    public function doMenuIsDisplay() {
        $id = I('post.id/d');
        $isDisplay = I('post.isdisplay/d');
        if ( !in_array($isDisplay, [0, 1]) ){
            $this->ajaxReturn( ['code' => 1, 'message' => '非法数据'] );
        }
        M('menu')->where( [ 'id' => $id ] )->save( [ 'isdisplay' => $isDisplay ] );
        $this->ajaxReturn( ['code' => 0] );
    }

    //菜单修改
    public function doMenuUpdate() {
        $up_data['url'] = I('post.url');
        $up_data['name'] =  I('post.name');
        $up_data['parentid'] =  I('post.parentid/d');
        $up_data['isdisplay'] =  I('post.isdisplay/d');
        $up_data['sort'] =  I('post.sort/d');
        $up_data['addtime'] = time();
        $up_data['subset'] = 0;
        $up_data['operator'] = $this->login_admin_info['name'];
        trim($up_data['name']) == "" && $this->ajaxReturn(array( 'code' => 1, 'message' => '菜单名不能为空' ));
        $up_data['sort'] > 9999 && $this->ajaxReturn(array( 'code' => 1, 'message' => '排序最大最9999' ));
        !in_array($up_data['isdisplay'], array( 0, 1)) && $this->ajaxReturn(array( 'code' => 1, 'message' => '非法数据' ));

        //计算是会有子项
        M('menu')->where( array(
            'id' => $up_data['parentid']
        ))->save(array(
            'subset' => 1
        ));

        $info = M('menu')->where( array(
            'id' => I('post.id/d')
        ))->save($up_data);

        intval($info) > 0 &&  $this->ajaxReturn( array(
            'code' => 0
        ));
    }

    //删除菜单
    public function doMenuDel(){
        M("menu")->where( ['id' => I('post.id/d') ])->delete();
        $this->ajaxReturn([ 'code' => 0 ]);
    }

    public function getOneMenu($id){
        return M("menu")->where(["menu_ID" =>intval($id)])->find();
    }

    //管理管理
    public function adminList(){
        $where_data = array();
        if ( !IS_AJAX  ){
            $this->show();
            return;
        }

        $data_list =  M('admin')->where( $where_data )->order(array("id" => "asc"))->page(I('page/d'))->limit(I('limit/d'))->select();
        $data['count'] =  M('admin')->where( $where_data )->count();
        foreach ( $data_list as $key => $val ){
            $data['id']           = $val['id'];
            $data['name']         = $val['name'];
            $data['addtime']      = date('Y-m-d H:i:s', $val['addtime']);
            $data['lock']         = $val['lock'];
            $data['power_edit_url'] = U('index/adminPowerEdit', array( 'id'=>  $data['id'] ));
            $data['edit_url']      = U('index/adminEdit', ['id' => $val['id']]);
            $layui_data['data'][] = $data;
        }

        $layui_data['page'] = I('get.page/d');
        $layui_data['code'] = 0;
        $this->ajaxReturn( $layui_data );
    }

    //管理员添加
    public function adminAdd(){
        $this->show();
    }

    //管理员添加
    public function doAdminAdd(){
        $data['name'] = I('post.name');
        $data['passwd'] = I('post.password');

        if ( trim($data['name']) == '' ) {
            $this->ajaxReturn(array( 'code' => 1, 'message' => '管理员名称不能为空' ));
        }

        if( !preg_match("/^[0-9a-zA-Z\s]+$/", $data['name']) ) {
            $this->ajaxReturn(array( 'code' => 1, 'message' => '管理员名称只能为英文' ));
        }

        if ( trim($data['passwd']) == '' ) {
            $this->ajaxReturn(array( 'code' => 1, 'message' => '管理员密码不能为空' ));
        }

        $data['passwd'] = md5($data['passwd']);
        $admin_count = M("admin")->where(array(
            'name' => $data['name']
        ))->count();

        if ( $admin_count > 0 ) {
            $this->ajaxReturn(array( 'code' => 1, 'message' => '管理员已经存在' ));
        }

        $info = M('admin')->add($data);
        intval($info) > 0 && $this->ajaxReturn( array(
            'code' => 0
        ));
        $this->ajaxReturn(['code' => 1 , 'message' => '添加失败']);
    }

    //是否禁用管理
    public function doAdminForbidden(){
        $id = I('post.id/d');
        $lock = I('post.lock/d');
        if ( !in_array($lock, array(1, 0)) ){
            $this->ajaxReturn( array('code' => 1, 'message' => '非法数据') );
        }

        M('admin')->where( array( 'id' => $id ) )->save( array( 'lock' => $lock ) );
        $this->ajaxReturn( ['code' => 0] );
    }

    //管理员修改
    public function adminEdit(){
        $id = I('get.id/d');
        $row = M('admin')->where(['id'=> $id])->find();
        $this->assign('row', $row);
        $this->show();
    }

    //修改密码
    public function doAdminEdit(){
        $id = I('post.id/d');
        $data['passwd'] = I('post.password');

        if ( trim($data['passwd']) == '' ) {
            $this->ajaxReturn(array( 'code' => 1, 'message' => '管理员密码不能为空' ));
        }
        $data['passwd'] = md5($data['passwd']);

        M('admin')->where( ['id' => $id] )->save($data);
        $this->ajaxReturn(['code' => 0]);
    }

    //修改权限
    public function adminPowerEdit(){
        $this->show();
    }

    //取菜单列表
    public function getMenuList() {
        $admin_power_id = array();
        $admin_id = I('get.aid/d');
        $menu_list = M('menu')->where(['isdisplay' => 1])->select();
        $admin_power_row = M('admin_power')->where( array( 'aid' => $admin_id ) )->select();

        foreach ( $admin_power_row as $val )  $admin_power_id[] = intval($val['mid']);
        foreach ( $menu_list as $key => $val ) {
            if ( in_array( $val['id'],  $admin_power_id) ){
                $menu_list[$key]['checked'] = true;
            }
        }
        $this->ajaxReturn($menu_list);
    }

    //权限更新
    public function doPowerEdit() {
        $admin_id = I('post.aid/d');
        $menu_ids = I('post.ids');

        $t_count = function() use($admin_id) {
            return  M('admin_power')->where( array( 'aid' => $admin_id ) )->count();
        };
        if(  $t_count() > 0  ) {
            M('admin_power')->where( array( 'aid' => $admin_id ) )->delete();
        }
        foreach ( $menu_ids as $val ){
            if ( intval($val) == 0 ) {
                continue;
            }
            M('admin_power')->add(array(
                'aid' => $admin_id,
                'mid' =>  intval($val)
            ));
        }
        $this->ajaxReturn(array( 'code' => 0) );
    }

    //游戏配制记录
    public function gameConfigList(){
        if( !IS_AJAX ) {
            $this->show();
            return;
        }

        $where['game_id'] = I('get.gid/d');
        $where['class_id'] = I('get.cid/d');

       $rows = M('game_config_list')->where($where)->page(I('get.page/d'))->limit(I('get.limit/d'))->order("id desc")->select();
        $data['count'] =  M('game_config_list')->where($where)->count();
       foreach ($rows as $key => $row ) {
//           $row['run_time'] = time() - $row['start_time'];

//           if(  $row['run_time'] > $row['stime'] ){
//               $row['run_time'] = $row['stime'];
//               $time = $row['stime'];
//           }
//
//           $row['now_amount'] = $row['init_amount'];
//           $c = $time / $row['rate'];
//           for ( $i = 0; $i < $c; $i++ ) {
//               if (  $row['now_amount']+($row['now_amount'] *  $row['ratio'] / 10000 ) < $row['expect_amount']  ) {
//                   $row['now_amount'] += ($row['now_amount'] *  $row['ratio'] / 10000 );
//                   $row['run_time'] = ($i+1)*$row['rate']+1;
//               }
//           }
//
//           if(  $row['run_time'] > $row['stime'] ){
//               $row['run_time'] = $row['stime'];
//           }

           $row['run_time'] = $row['end_time'] - $row['start_time'];
           $row['now_amount'] = $row['now_amount'] - $row['init_amount'];
           $row['start_time'] = date('Y-m-d H:i:s', $row['start_time']);
           $row['end_time'] = date('Y-m-d H:i:s', $row['end_time']);
           if( $row['type'] == 0 ){
               $this->assign('add_row', $row);
           }else{
               $this->assign('reduce_row', $row);
           }
           $row['type'] = $row['type'] == 0 ? '添加': '减少';
           $data['data'][] = $row;
       }
       $data['code'] = 0;
       $data['page'] = I('get.page/d');
       $this->ajaxReturn($data);
    }

    //游戏配制
    public function gameConfig(){
        $where['game_id'] = I('get.gid/d');
        $where['class_id'] = I('get.cid/d');
        $where['is_stop'] = 0;
        $row = M("game_config_list")->where($where)->find();

        if( intval($row['id']) > 0 ) {

//            $row['run_time'] = time() - $row['start_time'];
//            $time = time() - $row['start_time'];
//            if(  $row['run_time'] > $row['stime'] ){
//                $row['run_time'] = $row['stime'];
//                $time = $row['stime'];
//            }
//            $row['now_amount'] = $row['init_amount'];
//            $c = $time / $row['rate'];
//            for ( $i = 0; $i < $c; $i++ ) {
//                if (  $row['now_amount']+($row['now_amount'] *  $row['ratio'] / 10000 ) < $row['expect_amount']  ) {
//                  $row['now_amount'] += ($row['now_amount'] *  $row['ratio'] / 10000 );
//                  $row['run_time'] = ($i+1)*$row['rate']+1;
//                }
//            }
//            if(  $row['run_time'] > $row['stime'] ){
//                $row['run_time'] = $row['stime'];
//            }

            $row['run_time'] = $row['end_time'] - $row['start_time'];
            $row['now_amount'] = $row['now_amount'] - $row['init_amount'];

            if( $row['type'] == 0 ){
                $this->assign('add_row', $row);
            }else{
                $this->assign('reduce_row', $row);
            }
        }
        $this->assign('gameConfigList', U('index/gameConfigList', ['gid' => I('get.gid/d') , 'cid' => I('get.cid/d') ]) );
        $this->show();
    }

    //添加游戏配制
    public function doGameConfigAdd(){
        $data['rate'] = I('post.rate/d');
        if( $data['rate'] < 1 ||  $data['rate'] > 9999 ) $this->ajaxReturn(['code' => 1, 'message' => '频率大小值：1-9999']);
        $data['ratio'] = I('post.ratio/d');
        if( $data['ratio'] < 0.1 ||  $data['ratio'] > 2000 )  $this->ajaxReturn(['code' => 1, 'message' => '万分比大小值：0.1-2000']);
        $data['stime'] = I('post.stime/d');
        if( $data['stime'] < 1 ||  $data['stime'] > 999999 )  $this->ajaxReturn(['code' => 1, 'message' => '时长大小值：1-999999']);
        $data['run_time'] = I('post.run_time/d');
        $data['expect_amount'] = I('post.expect_amount/d');  //
        if( $data['expect_amount'] < 1 ||  $data['expect_amount'] > 99999999 ) $this->ajaxReturn(['code' => 1, 'message' => '期望金额大小值：1-99999999']);
        $data['now_amount'] = I('post.now_amount/d');
        $data['add_text'] = I('post.add_text');
        $data['type'] = I('post.type/d');
        $data['game_id'] = I('post.gid/d');
        $data['class_id'] = I('post.cid/d');
        $data['start_time'] = time();
        $data['end_time'] = 0;
        $data['admin_name'] = $this->login_admin_info['name'];
        $data['init_amount'] = 0;

        $where['game_id'] = I('post.gid/d');
        $where['class_id'] = I('post.cid/d');
        $where['is_stop'] = 0;
        $t_count = M('game_config_list')->where( $where )->count();
        if( $t_count > 0 ) {
            $this->ajaxReturn(['code' => 1, 'message' => '请先停止' ]);
        }

        $id = M('game_config_list')->data($data)->add();

        if( 0 < intval($id) ) {
            //构建Socket数据
            //游戏类型 UINT32
            $gid = pack("L", $data['game_id']);
            //游戏等级 UINT32
            $cid = pack("L", $data['class_id']);
            //增加频率 UINT32
            $rate = pack("L", $data['rate']);
            //增加万分比 UINT32
            $ratio = pack("L", $data['ratio']);
            //增加时长 UINT32
            $stime = pack("L", $data['stime']);
            //期望增加金额 UINT32
            $expect_amount = pack("L", $data['expect_amount']);
            //增加原因 STRING
            $add_text_len = pack("S", strlen($data['add_text']));
            $add_text = $data['add_text'];
            //增加或者减少 1减少   0增加
            $type = pack("L", $data['type']);
            // 数据库语句 UINT32
            $uid = pack("L", $id);
            $body = $gid . $cid . $rate . $ratio . $stime . $expect_amount . $add_text_len. $add_text . $type . $uid ;
            $socket_result = SendToGame( C('socket_ip'), 30000, 1403, $body );
        }
        $this->ajaxReturn(['code' => 0 ]);
    }

    //停止游戏配制
    public function doGameConfigStop(){
        $where['game_id'] = I('post.gid/d');
        $where['class_id'] = I('post.cid/d');
        $where['is_stop'] = 0;
        $up_count = M('game_config_list')->where($where)->save( ['is_stop' => 1] );
        if( $up_count > 0 ) {
            $gid = pack("L", $where['game_id']);
            //游戏等级 UINT32
            $cid = pack("L", $where['class_id']);
            $body = $gid . $cid ;
            $socket_result = SendToGame( C('socket_ip'), 30000, 1406, $body );
        }
        $this->ajaxReturn(['code' => 0 ]);
    }

    //游戏配制
    public function gameConfigRow() {
        $where['game_id'] = I('get.gid/d');
        $where['class_id'] = I('get.cid/d');
        $data['data'][] = M('game_config')->where($where)->find();
        $data['code'] = 0;
        $this->ajaxReturn($data);
    }

    //修改密码
    public function editPasswd(){
        $row = M('admin')->where(['id' => session("userid") ])->find();
        $this->assign('admin', $row);
        $this->show();
    }

    //修改密码
    public function doEditPasswd() {
        $where['id'] = I('post.id/d');
        if(  $where['id'] == 0 ) $this->ajaxReturn(['code' => 1, 'message' => '非法参数']);
        if( I('post.password') == '' ) $this->ajaxReturn(['code' => 1, 'message' => '密码不能为空']);
        $data['passwd'] =  md5(I('post.password'));
        $up_count = M('admin')->where($where)->save($data);
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
