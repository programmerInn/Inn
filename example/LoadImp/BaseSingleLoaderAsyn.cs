using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class BaseSingleLoaderAsyn<T> : ISingleLoaderAsyn<T> where T : UnityEngine.Object
{
    public LoadCallBack<T> CallBack { get; set; }

    public BaseSingleLoaderAsyn(LoadCallBack<T> callback)
    {
        this.CallBack = callback;
    }

    public void Notify(T value)
    {
        if (this.CallBack != null)
        {
            this.CallBack(value);
        }
    }
    public void Load()
    {
        CoroutineModule.GetInstance().DoCoroutine(LoadProcess());
    }
    protected abstract IEnumerator LoadProcess();

}
