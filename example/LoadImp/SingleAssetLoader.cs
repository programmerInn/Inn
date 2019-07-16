using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
public class SingleAssetLoader<T> : BaseSingleLoaderAsyn<T> where T : UnityEngine.Object
{
    public AssetBundle AssetBundle { get; set; }
    public string AssetName { get; set; }
    public SingleAssetLoader(AssetBundle assetBundle, string assetName,LoadCallBack<T> callback) : base(callback)
    {
        this.AssetBundle = assetBundle;
        this.AssetName = assetName;
    }

    protected override IEnumerator LoadProcess()
    {
        AssetBundleRequest request=AssetBundle.LoadAssetAsync<T>(Path.GetFileName(AssetName));
        yield return request;
        Notify(request.asset as T);
    }
}
