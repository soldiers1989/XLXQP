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
        <div class="layui-card-body">
        <div style="padding-bottom: 10px;" class="searchTable">
            <div class="layui-form-item">
                <div class="layui-inline">
                    <label class="layui-form-label">开始日期</label>
                    <div class="layui-input-inline">
                        <input type="text" name="s_date" id="s_date" lay-verify="date" placeholder="yyyy-MM-dd" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <div class="layui-inline">
                    <label class="layui-form-label">截止日期</label>
                    <div class="layui-input-inline">
                        <input type="text" name="e_date" id="e_date" lay-verify="date" placeholder="yyyy-MM-dd" autocomplete="off" class="layui-input">
                    </div>
                </div>
                <button class="layui-btn" data-type="reload">搜索</button>
            </div>
        </div>
    <table class="layui-table" lay-data="{loading:true,height:'full',page:true, id:'datalist'}" lay-filter="datalist">
        <thead>
            <tr>
                <th lay-data="{field:'date'}">日期</th>
                <th lay-data="{field:'receiveName'}">充值帐户</th>
                <th lay-data="{field:'PlayerID'}">充值ID</th>
                <th lay-data="{field:'ChangeGold'}">充值金额</th>
                <th lay-data="{field:'DailiBefore'}">充值前帐户余额</th>
                <th lay-data="{field:'DailiEnd'}">充值后帐户余额</th>
                <th lay-data="{field:'lastToal'}">总充值</th>
                <th lay-data="{field:'moonToal'}">本月充值金额</th>
            </tr>
        </thead>
    </table>

    <script type="text/html" id="bar">
        <a class="layui-btn layui-btn-primary layui-btn-xs"  lay-event="powerEdit">权限</a>
        <a class="layui-btn layui-btn-primary layui-btn-xs"  lay-event="edit">改密</a>
    </script>

    <script type="text/html" id="switchTpl">
        <input type="checkbox" name="sex" value="{{d.id}}" lay-skin="switch" lay-text="启用|禁用" lay-filter="forbidden" {{ d.lock == 1 ? 'checked' : '' }}>
    </script>

    </div>
    </div>


</div>
<script src="/Public/static/admin/layui/layui.js"></script>

    <script>
        layui.use(['jquery', 'table', 'laydate'], function(){
            var table = layui.table
                ,$ = layui.jquery
                ,form = layui.form
                ,laydate = layui.laydate;

            //日期
            laydate.render({
                elem: '#s_date'
            });
            laydate.render({
                elem: '#e_date'
            });

            var active = {
                reload: function(){
                    table.reload('datalist', {
                        page: {
                            curr: 1,
                        },
                        where: {
                            start_time: $('input[name="s_date"]').val(),
                            end_time: $('input[name="e_date"]').val(),
                        },
                        url: '<?php echo U("index/record");?>',
                        limits: [20,50,100],
                        done: function (data) {
                          //  console.log(data)
                        }
                    })
                },
                init:function () {
                    this.reload()
                }
            }
            active.init();
            $('.searchTable .layui-btn').bind({
                click: function () {
                    var type = $(this).data('type')
                    active[type] ? active[type].call(this) : ""
                }
            })



        });
    </script>

</body>
</html>