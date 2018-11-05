<?php if (!defined('THINK_PATH')) exit();?><!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>消息中心</title>
    <meta name="renderer" content="webkit">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <link rel="stylesheet" href="/Public/static/admin/layui/css/layui.css" media="all">
    <link rel="stylesheet" href="/Public/static/admin/css/admin.css" media="all">
    
</head>
<body>
<div class="layui-fluid" id="LAY-app-message">

        
    <div class="layui-card">
    <div class="layui-form" lay-filter="layuiadmin-app-form-list" id="layuiadmin-app-form-list" style="padding: 20px 30px ">
        <form class="layui-form" action="" lay-filter="example">
        <div class="layui-form-item">
            <label class="layui-form-label">管理员名称</label>
            <div class="layui-input-block">
                <div class="layui-input-inline">
                    <input type="text" name="name" lay-verify="name" disabled value="<?php echo ($daili["bk_bk_accound"]); ?>" autocomplete="off" placeholder="管理员名称" class="layui-input">
                </div>
            </div>
        </div>

        <div class="layui-form-item">
            <label class="layui-form-label"> 设置密码</label>
            <div class="layui-input-block">
                <div class="layui-input-inline">
                    <input type="text" name="password"  lay-verify="password" autocomplete="off" placeholder="设置密码" class="layui-input">
                </div>
            </div>
        </div>

        <div class="layui-form-item">
            <div class="layui-input-block">
                <button class="layui-btn " lay-submit lay-filter="LAY-menu-add-submit">修改密码</button>
                <input value="<?php echo ($daili["bk_id"]); ?>" type="hidden" name="id">
            </div>
        </div>
    </form>

    </div>
    </div>


</div>
<script src="/Public/static/admin/layui/layui.js"></script>

    <script>
        layui.use(['jquery', 'table', 'form'], function(){
            var table = layui.table
                ,$ = layui.jquery
                ,form = layui.form;
            form.on('submit(LAY-menu-add-submit)', function(obj){
                let postData = {
                    id: $("input[name='id']").val(),
                    password: $("input[name='password']").val()
                }

                $.post("<?php echo U('index/doEditPasswd');?>", postData , (response) => {
                    if ( response.code == 0 ) {
                        layer.alert('修改成功', function(index, layero){
                            parent.location.href = '/'
                            //按钮【按钮一】的回调
                        })
                    }else{
                        layer.alert( response.message )
                    }
                })
                return false
            })
        });
    </script>

</body>
</html>