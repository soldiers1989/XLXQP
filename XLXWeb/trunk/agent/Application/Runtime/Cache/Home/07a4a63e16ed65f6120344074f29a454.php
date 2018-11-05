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
                    <label class="layui-form-label">我的余额</label>
                    <div class="layui-input-block">
                        <div class="layui-input-inline">
                            <input type="number" value="<?php echo ($gold); ?>" disabled lay-verify="user_id" autocomplete="off" class="layui-input">
                        </div>
                    </div>
                </div>
                <div class="layui-form-item">
                    <label class="layui-form-label">玩家ID</label>
                    <div class="layui-input-block">
                        <div class="layui-input-inline">
                            <input type="number" name="user_id" lay-verify="user_id" autocomplete="off" placeholder="玩家ID" class="layui-input">
                        </div>
                    </div>
                </div>
                <div class="layui-form-item">
                    <label class="layui-form-label"> 确认ID</label>
                    <div class="layui-input-block">
                        <div class="layui-input-inline">
                            <input type="number" name="confirm_user_id" lay-verify="confirm_user_id" autocomplete="off" placeholder="确认ID" class="layui-input">
                        </div>
                    </div>
                </div>
                <div class="layui-form-item">
                    <label class="layui-form-label"> 冲值金额</label>
                    <div class="layui-input-block">
                        <div class="layui-input-inline">
                            <input type="number" name="price" lay-verify="price" autocomplete="off" placeholder="冲值金额" class="layui-input">
                        </div>
                        <div class="layui-form-mid layui-word-aux">请输正整数，如有小数，系统会为你自动舍去小数部分</div>
                    </div>
                </div>
                <div class="layui-form-item">
                    <div class="layui-input-block">
                        <button  class="layui-btn" lay-submit lay-filter="LAY-menu-add-submit">确认冲值</button>
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
                $(document).keydown(function(e){
                    if(!e) var e = window.event;
                    if(e.keyCode==32){
                        console.log('125')
                        return;//在这里写要改变的东西
                    }
                });
                $('.layui-btn').addClass("layui-hide");
                let postData = {
                    user_id: $("input[name='user_id']").val(),
                    confirm_user_id: $("input[name='confirm_user_id']").val(),
                    price: $("input[name='price']").val()
                }

                var ix = layer.load(1, {
                    shade: [0.9,'#fff'] //0.1透明度的白色背景
                });

                //询问框
                $.post("<?php echo U('index/doRechargeAdd');?>", postData , (response) => {
                    if ( response.code == 0 ) {
                        layer.alert('添加成功', function(index, layero){
                            location.reload()
                            //按钮【按钮一】的回调
                        })
                    }else{
                        layer.alert( response.message )
                        layer.close(ix)
                        $('.layui-btn').removeClass("layui-hide");
                    }
                })
                return false
            })
        });
    </script>

</body>
</html>