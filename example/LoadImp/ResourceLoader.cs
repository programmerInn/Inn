using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
public class ResourceLoader : ILoader
{
    public void Init()
    {

    }

    public T Load<T>(string name) where T : UnityEngine.Object
    {
        //return Resources.Load<T>(Path.Combine(path, name));
        return Resources.Load<T>(name);
    }

    //暂时未实现异步方法。
    public void LoadAsyn<T>(string name, LoadCallBack<T> callBack) where T : UnityEngine.Object
    {
        callBack(Load<T>(name));
    }

    public string GetAbsolutePath(string fileName)
    {
        return FileModule.StandardPath(Path.Combine(Application.dataPath, fileName));
    }
}
