using System;
using UnityEngine;
using UnityEngine.Events;

[XLua.LuaCallCSharp]
[Serializable]
public class ColorChangedEvent : UnityEvent<Color>
{

}