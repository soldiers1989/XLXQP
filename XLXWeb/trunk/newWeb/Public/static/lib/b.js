layui.define(['a', 'form'], function (e) {
    let a = layui.a, f = layui.form, q = layui.$, o = {
        form_button_event: function (b, d, u) {
            f.on('submit('+b+')', function (c) {
                a.p(u,d);
            });
            return false;
        }
    };
    e('b', o);
});