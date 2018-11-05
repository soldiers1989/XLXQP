layui.use(['layer', 'form', 'element', 'jquery'], function() {
    var element = layui.element;
	var $ = layui.$;
	var hideBtn = $('#hideBtn');
	var mainLayout = $('#main-layout');
	var mainMask = $('.main-mask');


    element.on('tab(tab)', function(data){
        $("iframe[data-id='"+$(this).attr('lay-id')+"']").attr("src",  $("iframe[data-id='"+$(this).attr('lay-id')+"']").attr("src"))
    });

    //监听导航点击
    element.on('nav(leftNav)', function(elem) {
		var id = elem.attr('data-id');
		var url = elem.attr('data-url');
		var text = elem.attr('data-text');
		var status = elem.attr('data-status');

        var isActive = $('.main-layout-tab .layui-tab-title').find("li[lay-id=" + id + "]");
		if(isActive.length > 0) {
			//切换到选项卡
			element.tabChange('tab', id);
		} else {
            $('.layui-tab-title li').each(function (index, val) {
            	if( index != 0 ) {
                    element.tabDelete('tab', $(val).attr('lay-id'));
				}
            })

			if ( status == 0  ) {
				element.tabAdd('tab', {
					title: text,
					content: '<iframe src="' + url + '" name="iframe' + id + '" class="iframe" framborder="0" data-id="' + id + '" scrolling="auto" width="100%"  height="100%"></iframe>',
					id: id
				});
				element.tabChange('tab', id);
            }else{
				$.get(getMenuChildsUrl, {mid: id}, (response) => {
                    response.forEach(function (value, i) {
                        var isActive = $('.main-layout-tab .layui-tab-title').find("li[lay-id=" + value.bk_menuid + "]");
                        if(isActive.length > 0) {
                            //切换到选项卡
                            element.tabChange('tab', value.bk_menuid);
						}else {
							element.tabAdd('tab', {
								title: value.bk_name,
								content: '<iframe src="' + value.bk_url + '" name="iframe' + value.bk_menuid + '" class="iframe" framborder="0" data-id="' + value.bk_menuid + '" scrolling="auto" width="100%"  height="100%"></iframe>',
								id: value.bk_menuid
							});
							element.tabChange('tab', value.bk_menuid);
                        }
                    })
					if( response.length > 0 )element.tabChange('tab', response[0].bk_menuid);
				})
			}
		}
		mainLayout.removeClass('hide-side');
    });

	//监听导航点击
	element.on('nav(rightNav)', function(elem) {
		var navA = $(elem).find('a');
		var id = navA.attr('data-id');
		var url = navA.attr('data-url');
		var text = navA.attr('data-text');

        if(!url){
			return;
		}
		var isActive = $('.main-layout-tab .layui-tab-title').find("li[lay-id=" + id + "]");
        if(isActive.length > 0) {
			//切换到选项卡
			element.tabChange('tab', id);
		} else {
			element.tabAdd('tab', {
				title: text,
				content: '<iframe src="' + url + '" name="iframe' + id + '" class="iframe" framborder="0" data-id="' + id + '" scrolling="auto" width="100%"  height="100%"></iframe>',
				id: id
			});
			element.tabChange('tab', id);
		}
		mainLayout.removeClass('hide-side');
	});



	//菜单隐藏显示
	hideBtn.on('click', function() {
		if(!mainLayout.hasClass('hide-side')) {
			mainLayout.addClass('hide-side');
		} else {
			mainLayout.removeClass('hide-side');
		}
	});

	//遮罩点击隐藏
	mainMask.on('click', function() {
		mainLayout.removeClass('hide-side');
	})
});