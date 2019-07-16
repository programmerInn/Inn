using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface ISingleLoaderAsyn<T> where T : Object
{
    void Load();
    void Notify(T value);
}
