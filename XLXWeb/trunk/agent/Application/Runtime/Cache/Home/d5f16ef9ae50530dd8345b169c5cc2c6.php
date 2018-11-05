<?php if (!defined('THINK_PATH')) exit();?><!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>登入 - layuiAdmin</title>
	<meta name="renderer" content="webkit">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0">
	<link rel="stylesheet" href="/Public/static/admin/layui/css/layui.css" media="all">
	<link rel="stylesheet" href="/Public/static/admin/style/admin.css" media="all">
	<link rel="stylesheet" href="/Public/static/admin/style/login.css" media="all">
</head>
<body>

<div class="layadmin-user-login layadmin-user-display-show" id="LAY-user-login" style="display: none;">

	<div class="layadmin-user-login-main">
		<div class="layadmin-user-login-box layadmin-user-login-header">
			<h2></h2>
		</div>
		<div class="layadmin-user-login-box layadmin-user-login-body layui-form">
			<div class="layui-form-item">
				<label class="layadmin-user-login-icon layui-icon layui-icon-username" for="LAY-user-login-username"></label>
				<input type="text" name="username" id="LAY-user-login-username" lay-verify="required" placeholder="用户名" class="layui-input">
			</div>
			<div class="layui-form-item">
				<label class="layadmin-user-login-icon layui-icon layui-icon-password" for="LAY-user-login-password"></label>
				<input type="password" name="password" id="LAY-user-login-password" lay-verify="required" placeholder="密码" class="layui-input">
			</div>
			<div class="layui-form-item">
				<div class="layui-row">
					<div class="layui-col-xs7">
						<label class="layadmin-user-login-icon layui-icon layui-icon-vercode" for="LAY-user-login-vercode"></label>
						<input type="text" name="vercode" id="LAY-user-login-vercode" lay-verify="required" placeholder="图形验证码" class="layui-input">
					</div>
					<div class="layui-col-xs5">
						<div style="margin-left: 10px;">
							<img src="<?php echo U('Index/getVerify');?>" class="layadmin-user-login-codeimg" id="LAY-user-get-vercode">
						</div>
					</div>
				</div>
			</div>
			<div class="layui-form-item">
				<button class="layui-btn layui-btn-fluid" lay-submit lay-filter="LAY-user-login-submit">登 入</button>
			</div>
		</div>
	</div>
</div>

<script src="/Public/static/admin/layui/layui.js"></script>
<script>
    layui.config({
        base: '/Public/static/admin/' //静态资源所在路径
    }).extend({
        index: 'lib/index' //主入口模块
    }).use(['index', 'user'], function(){
        var $ = layui.$
            ,setter = layui.setter
            ,admin = layui.admin
            ,form = layui.form
            ,router = layui.router()
            ,search = router.search;

        form.render();

        $(".layadmin-user-login-codeimg").bind({
            click: function () {
                $(this).attr("src",$(this).attr("src"))
            }
        })

        form.on('submit(LAY-user-login-submit)',function(data){
            const postData = {
                vercode: $("#LAY-user-login-vercode").val(),
                password: $("#LAY-user-login-password").val(),
                username: $("#LAY-user-login-username").val(),
            }

            const postUrl = "<?php echo U('index/doLogin');?>"
            const url = "<?php echo U('index/index');?>"
            $.post(postUrl, postData, (reponse) => {
                console.log(reponse)
                reponse.code == 1 && layer.msg(reponse.message)
                reponse.code == 1 && $(".layadmin-user-login-codeimg").attr("src",$(".layadmin-user-login-codeimg").attr("src"))
                if ( reponse.code == 0 ) {
                    location.href = url
                }
            })
            return false;
        });
    });
</script>
</body>
</html>