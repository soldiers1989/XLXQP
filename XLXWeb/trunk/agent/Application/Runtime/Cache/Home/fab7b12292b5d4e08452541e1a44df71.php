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
    
	<style>
	</style>

</head>
<body>
<div class="layui-fluid" id="LAY-app-message">

        
	<div style="text-align: center; width: 100%; ">
		<img alt="" src="/Public/static/images/welcome.png" style="margin: 100px 0 0 0;" />
	</div>


</div>
<script src="/Public/static/admin/layui/layui.js"></script>

	<script>
        layui.use(['jquery', 'table', 'form'], function(){
            var table = layui.table
                ,$ = layui.jquery
                ,form = layui.form;
        });
	</script>

</body>
</html>