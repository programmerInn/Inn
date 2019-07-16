using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public delegate void LoadCallBack<T>(T resource) where T : Object;

public interface ILoader
{
    void Init();
    T Load<T>(string name) where T : Object;//同步返回
    void LoadAsyn<T>(string name, LoadCallBack<T> callBack) where T : Object;
    string GetAbsolutePath(string fileName);
}
