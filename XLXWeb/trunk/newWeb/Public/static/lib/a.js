layui.define(["layer","m","form"],function(exports){var l=layui.layer,q=layui.$,f=layui.form,m=layui.m,c={h:"layui-hide"},h=function(a,b){return a==1?"submit("+b+")":a==2?"select("+b+")":false},o={p:function(b,c,d){q(document).keydown(function(e){if(!e){var e=window.event}return false});q.post(b,c,function(e){l.alert(e.code?e.message:m.a,function(i){e.code?l.close(i):location.reload();e.code&&q(d).removeClass("layui-hide")})})},s:function(b,d,u){f.on(h(1,b),function(c){q(c.elem).addClass("layui-hide");o.p(u,d(),c.elem)});return false},ss:function(b,v,d){var t=function(a){(a.value==v)?q(d).removeClass(c.h):q(d).addClass(c.h)};f.on(h(2,b),t)}};exports("a",o)});