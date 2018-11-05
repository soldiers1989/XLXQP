!function () {
    function size() {
        var h=window.innerHeight/2;
        var a=document.getElementById("another");
        a.style.height=h+"px";
        a.style.top=h+"px";
        var b=document.getElementById("model");
        b.style.top=(h*2-330)/2+"px";
    }
    size();
    window.addEventListener("resize",size);


    var timer=null,loadIndex=null;
    var button=document.getElementById("sendCode");

    layui.use(['layer', 'form','jquery'], function() {
        var layer = layui.layer,
            $ = layui.jquery,
            form = layui.form;

        $(".layadmin-user-login-codeimg").bind({
            click: function () {
                $(this).attr("src",$(this).attr("src"))
            }
        })

        form.verify({
            pass: [
                /^[\S]{4,12}$/
                ,'璇疯緭鍏�6鍒�12浣嶅瓧绗︼紝涓斾笉鑳藉嚭鐜扮┖鏍�'
            ]
        });

        form.on('submit(login)',function(data){
            let postData = {
                vercode: $("#LAY-user-login-vercode").val(),
                password: $("#LAY-user-login-password").val(),
                username: $("#LAY-user-login-username").val(),
            }

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
}()