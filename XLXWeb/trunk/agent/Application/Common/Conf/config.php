<?php
return array(
	//'配置项'=>'配置值'
    /* 数据库设置 */
    'DB_TYPE'               =>  'mysql',     // 数据库类型
    'DB_HOST'               =>  '47.75.211.63,47.75.169.181', // 服务器地址
    'DB_NAME'               =>  'backstage',          // 数据库名
    'DB_USER'               =>  'backstage,backstageR',      // 用户名
    'DB_PWD'                =>  'mysqladmin,Xiaolongxia518@',          // 密码
    'DB_PORT'               =>  '',        // 端口
    'DB_PREFIX'             =>  'bk_',    // 数据库表前缀
    'DB_PARAMS'          	=>  array(), // 数据库连接参数
    'DB_DEBUG'  			=>  TRUE, // 数据库调试模式 开启后可以记录SQL日志
    'DB_FIELDS_CACHE'       =>  true,        // 启用字段缓存
    'DB_CHARSET'            =>  'utf8',      // 数据库编码默认采用utf8
    'DB_DEPLOY_TYPE'        =>  1, // 数据库部署方式:0 集中式(单一服务器),1 分布式(主从服务器)
    'DB_RW_SEPARATE'        =>  true, // 数据库读写是否分离 主从式有效
    'DB_MASTER_NUM'         =>  1, // 读写分离后 主服务器数量
    //'DB_SLAVE_NO'           => '', // 读写分离后 主服务器数量

    /* 模板引擎设置 */
    'DEFAULT_THEME'         =>  'default',
    'TMPL_PARSE_STRING'     => array(
        '__PUBLIC__'        => SCRIPT_DIR . '/Public',
        '__STATIC__'        => SCRIPT_DIR . '/Public/static',
    ),
    'URL_CASE_INSENSITIVE' => true,

    //自定义
    'IMAGE_CHECK_KEY'               => 'rew85chs', //图片验证KEY
    'UPLOAD_URL'                    => '/Public/upload',  //上传目录的访问地址
    'UPLOAD_PATH'                   => $_SERVER['DOCUMENT_ROOT'].'/Public/upload',  //上传的写入目
);
