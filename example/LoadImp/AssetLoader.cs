using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
public class AssetLoader : ILoader
{
    private string manifestName;
    public string ManifestName
    {
        get
        {
            return manifestName;
        }

        set
        {
            manifestName = value;
        }
    }

    private string abListFile;
    private AssetBundleManifest mainfest;
    private Dictionary<string, string> abDic = new Dictionary<string, string>();
    private Dictionary<string, AssetBundle> abLoadDic = new Dictionary<string, AssetBundle>();

    public AssetLoader(string mainfestName,string abListFile)
    {
        this.manifestName = mainfestName;
        this.abListFile = abListFile;
    }
    public void Init()
    {
        LoadMainfest();
        InitListDic();
    }

    private bool LoadMainfest()
    {
        string manifest = this.GetAbsolutePath(manifestName);
        Debug.LogError(manifest);
        AssetBundle mainfestAb = AssetBundle.LoadFromFile(manifest);
        mainfest = mainfestAb.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        mainfestAb.Unload(false);
        //string[] absName = mainAssetBundleManiFest.GetAllAssetBundles();

        //foreach (string abName in absName)
        //{
        //    Debug.LogError("ABNAME____" + abName);
        //}
        return true;
    }

    private bool InitListDic()
    {
        string abListPath = this.GetAbsolutePath(abListFile);
        string[] files = File.ReadAllLines(abListPath);
        foreach (var file in files)
        {

            string[] fs = file.Split('|');
            //字体处理。名字一样。。
            if(abDic.ContainsKey(fs[0])&&fs[0].StartsWith("font"))
            {
                continue;
            }
            abDic.Add(fs[0], fs[1]);
        }
        return true;
    }

    public string GetAbName(string file)
    {
        string abName = null;
        if (abDic.TryGetValue(file, out abName))
        {
            return abName;
        }
        return null;
    }

    /**通过assetbundle名字取到assetbundle
     *name assetbund中指定的名字 
     *abpath.文件路径
     **/

    public AssetBundle GetAssetBundle(string name)
    {
        string abPath = this.GetAbsolutePath(name);
        string[] dependencies = mainfest.GetAllDependencies(name);
        foreach (string dependent in dependencies)
        {
            GetAssetBundle(dependent);
        }
        AssetBundle bundle = null;
        if (abLoadDic.TryGetValue(abPath, out bundle))
        {
            return bundle;
        }
        else
        {
            bundle = AssetBundle.LoadFromFile(abPath);
            abLoadDic.Add(abPath, bundle);
        }
        return bundle;
    }


    /**
     * 通过assetbundle名字取到assetbundle
     * 异步加载assetbundle
     * */
    public void GetAssetBundleAsyn(string name, LoadCallBack<AssetBundle> callBack)
    {

        string abPath = this.GetAbsolutePath(name);
        AssetBundle bundle = null;
        if (abLoadDic.TryGetValue(abPath, out bundle))
        {
            if (callBack != null) callBack(bundle);
            return;
        }
        LoadCallBack<AssetBundle> addMapCallBack =
            (assetBundle => { abLoadDic.Add(abPath, assetBundle); if (callBack != null) callBack(assetBundle); });

        SingleAssetBundleLoader loaderData = new SingleAssetBundleLoader(name, abPath, addMapCallBack);
        string[] dependencies = mainfest.GetAllDependencies(name);
        int number = 0;

        LoadCallBack<AssetBundle> loadEndCallback= 
            (assetbundle => { number += 1;if (number == dependencies.Length) loaderData.Load();});
        if (dependencies.Length > 0)
        {
            foreach (string dependency in dependencies)
            {
                GetAssetBundleAsyn(dependency, loadEndCallback);
            }
        }
        else
        {
            loaderData.Load();
        }
    }



    public T Load<T>(string name) where T : UnityEngine.Object
    {
        string abName = GetAbName(name);
        AssetBundle ab = GetAssetBundle(abName);
        T value = ab.LoadAsset<T>(Path.GetFileName(name));
        //T value = ab.LoadAsset<T>(name);
        return value;

    }

    public void LoadAsyn<T>(string name, LoadCallBack<T> callBack) where T : UnityEngine.Object
    {
       

        string abName = GetAbName(name);
        GetAssetBundleAsyn(abName,
            assetBundle =>
            {
                SingleAssetLoader<T> assetLoader = new SingleAssetLoader<T>(assetBundle,name, callBack);
                assetLoader.Load();
            });
    }



    public string GetAbsolutePath(string fileName)
    {
        //return FileModule.StandardPath(Path.Combine(FileModule.DataPath, fileName));
        return FileModule.StandardPath(Path.Combine(GameConst.streamAssetResFullPath, fileName));
    }
}
