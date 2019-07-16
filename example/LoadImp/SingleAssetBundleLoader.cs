using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SingleAssetBundleLoader:BaseSingleLoaderAsyn<AssetBundle>
{
    public string AssetName { get; set; }
    public string AssetPath { get; set; }


    public SingleAssetBundleLoader(string assetName, string assetPath,LoadCallBack<AssetBundle> callBack):base(callBack)
    {
        this.AssetName = assetName;
        this.AssetPath = assetPath;
    }
    //public void Load()
    //{
    //    CoroutineModule.GetInstance().DoCoroutine(LoadProcess());
    //}
    //public void Notify(AssetBundle asserbundle)
    //{
    //    if (this.CallBack != null)
    //    {
    //        this.CallBack(asserbundle);
    //    }
    //}

    protected override IEnumerator LoadProcess()
    {
        AssetBundleCreateRequest request=AssetBundle.LoadFromFileAsync(AssetPath);
        yield return request;
        Notify(request.assetBundle);
    }

}

