using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 其实那C#对象并不为null，是UnityEngine.Object重载的==操作符，
/// 当一个对象被Destroy，未初始化等情况，obj == null返回true，
/// 但这C#对象并不为null，可以通过System.Object.ReferenceEquals(null, obj)来验证下。
/// </summary>
[XLua.LuaCallCSharp]
[XLua.ReflectionUse]
public static class UnityEngineObjectExtention
{
    public static bool IsNull(this UnityEngine.Object o) // 或者名字叫IsDestroyed等等
    {
        return o == null;
    }
}
