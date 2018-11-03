/*
 * Tencent is pleased to support the open source community by making xLua available.
 * Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using XLua;
using System;

/// <summary>
/// 参数体
/// </summary>
[System.Serializable]
public class Injection
{
    public string name;
    public GameObject value;
}

[LuaCallCSharp]
public class LuaBehaviour : MonoBehaviour
{
    public string ScriptName = "";
    public Injection[] injections;

    private Action luaStart;
    private Action luaUpdate;
    private Action luaOnDestroy;

    private bool isStarted = false;
    private LuaTable scriptEnv;
    bool isLoadedLuaScript = false;

    public LuaTable LuaScript
    {
        get
        {
            if (scriptEnv == null)
            {
                LoadLuaScript();
            }
            return scriptEnv;
        }
    }

    /// <summary>
    /// 回调luastart
    /// </summary>
    void CallLuaStart()
    {
        if (luaStart != null)
        {
            luaStart();
        }
    }

    /// <summary>
    /// 加载lua脚本
    /// </summary>
    void LoadLuaScript()
    {
        if (!isLoadedLuaScript)
        {
            if (string.IsNullOrEmpty(ScriptName))
                return;
            byte[] luaContent = LuaManager.Instance.LoadCustomLuaFile(ScriptName);
            LuaEnv luaEnv = LuaManager.LuaEnv;
            scriptEnv = luaEnv.NewTable();
            LuaTable meta = luaEnv.NewTable();
            meta.Set("__index", luaEnv.Global);
            scriptEnv.SetMetaTable(meta);
            meta.Dispose();

            scriptEnv.Set("this", this);
            foreach (var injection in injections)
            {
                scriptEnv.Set(injection.name, injection.value);
            }

            luaEnv.DoString(Utility.BytesToUTF8String(luaContent), ScriptName, scriptEnv);
            isLoadedLuaScript = true;
        }
    }

    /// <summary>
    /// 绑定lua方法
    /// </summary>
    void BindingLuaScript()
    {
        LoadLuaScript();

        Action luaAwake = scriptEnv.Get<Action>("Awake");
        scriptEnv.Get("Start", out luaStart);
        scriptEnv.Get("Update", out luaUpdate);
        scriptEnv.Get("OnDestroy", out luaOnDestroy);

        if (luaAwake != null)
        {
            luaAwake();
        }

        if (isStarted)
        {
            CallLuaStart();
        }
    }

    void Awake()
    {
        BindingLuaScript();
    }

    void Start()
    {
        isStarted = true;
        CallLuaStart();
    }

    // Update is called once per frame
    void Update()
    {
        if (luaUpdate != null)
        {
            luaUpdate();
        }
    }

    void OnDestroy()
    {
        if (luaOnDestroy != null)
        {
            luaOnDestroy();
        }
        luaOnDestroy = null;
        luaUpdate = null;
        luaStart = null;
        if (scriptEnv != null)
        {
            scriptEnv.Dispose();
        }
        injections = null;
        scriptEnv = null;
    }

    #region DelayInvoke

    public virtual void DelayInvoke(float delayTime, Action callBack)
    {
        if (delayTime > 0)
        {
            int delayID = GetCoroutineID();
            Coroutine cor = StartCoroutine(DelayCoroutine(delayID, delayTime, callBack));
            coroutineDict.Add(delayID, cor);
        }
        else
        {
            if (callBack != null)
                callBack();
        }
    }

    private int mCoroutineID = 0;
    private int GetCoroutineID()
    {
        mCoroutineID++;
        if (mCoroutineID == 100000)
            mCoroutineID = 1;
        return mCoroutineID;
    }

    Dictionary<int, Coroutine> coroutineDict = new Dictionary<int, Coroutine>();

    public void StopAllDelayInvoke()
    {
        foreach (var item in coroutineDict)
        {
            if (item.Value != null)
            {
                StopCoroutine(item.Value);
            }
        }
        coroutineDict.Clear();
    }

    protected IEnumerator DelayCoroutine(int delayID, float delayTime, Action callBack)
    {
        if (delayTime > 0)
            yield return new WaitForSeconds(delayTime);
        if (coroutineDict.ContainsKey(delayID))
        {
            if (callBack != null)
                callBack();
            coroutineDict[delayID] = null;
            coroutineDict.Remove(delayID);
        }
    }
    
    #endregion

}
