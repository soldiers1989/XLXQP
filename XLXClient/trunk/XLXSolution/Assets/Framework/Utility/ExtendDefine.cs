using Common;
using Common.AssetSystem;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[XLua.LuaCallCSharp]
public static class ExtendDefine
{
    /// <summary>
    /// 扩展 Image 方法，设置Sprite名称 刷新 Sprite
    /// </summary>
    /// <param name="image">扩展的对象</param>
    /// <param name="spriteName">图片资源名称</param>
    /// <param name="isNativeSize"></param>
    public static void ResetSpriteByName(this UnityEngine.UI.Image image, string spriteName, bool isNativeSize = false)
    {
        if (UISpriteManager.Instance != null)
        {
            UISpriteManager.Instance.SetImageSprite(image, spriteName, isNativeSize);
        }
    }

    /// <summary>
    /// 扩展 Image 方法, 设置Sprite名称 刷新 Sprite
    /// </summary>
    /// <param name="image">扩展的对象</param>
    /// <param name="spriteName">图片资源名称</param>
    /// <param name="isNativeSize">是否使用原尺寸</param>
    public static void ResetSpriteByNameAsync(this UnityEngine.UI.Image image, string spriteName, bool isNativeSize = false)
    {
        if (UISpriteManager.Instance != null)
        {
            UISpriteManager.Instance.SetImageSpriteAsync(image, spriteName, isNativeSize);
        }
    }

    /// <summary>
    /// 重置图片的Sprite，通过Url 或者 名称
    /// (先加载默认资源)
    /// </summary>
    /// <param name="image"></param>
    /// <param name="spriteName"></param>
    /// <param name="remoteUrl"></param>
    /// <param name="isNativeSize"></param>
    public static IEnumerator ResetSpriteByRemoteUrlOrLocal(this UnityEngine.UI.Image image, string remoteUrl, string spriteName, bool isNativeSize = false)
    {
        bool isSetedByRemoteSprite = false;
        if (!string.IsNullOrEmpty(remoteUrl))
        {            
            // 判断本地的cache 有没有
            bool isCached = false;
            string localFileName = string.Format("{0}/{1}.face", AppDefine.LOCAL_HEADICON_PATH, Utility.GetMD5Code(remoteUrl));
            string realUrl = remoteUrl;
            if (FileUtility.ExistsFile(localFileName))
            {
                isCached = true;
                realUrl = "file:///" + localFileName;
            }

            using (WWW loader = new WWW(realUrl))
            {
                if (!loader.isDone)
                {
                    yield return loader;
                }

                if (loader.isDone)
                {
                    if (string.IsNullOrEmpty(loader.error))
                    {
                        if (!isCached)
                        {
                            FileUtility.WriteBytesToFile(localFileName, loader.bytes, loader.bytes.Length);
                        }

                        if (image == null)
                        {
                            yield break;
                        }

                        Texture2D tempImage = loader.texture;
                        if (tempImage != null)
                        {
                            Sprite sprite = Sprite.Create(tempImage, new Rect(0, 0, tempImage.width, tempImage.height), new Vector2(0, 0));
                            image.sprite = sprite;
                            isSetedByRemoteSprite = true;
                            if (isNativeSize)
                            {
                                image.SetNativeSize();
                            }
                        }
                    }
                }
                else
                {
                    Debug.LogErrorFormat("load sprite[{0}] error:{1}", remoteUrl, loader.error);
                }
            }
        }

        // 如果设置远程资源失败了，则，设置本地的图片资源
        if (!isSetedByRemoteSprite)
        {
            if (!string.IsNullOrEmpty(spriteName))
            {
                image.ResetSpriteByName(spriteName, isNativeSize);
            }
        }
    }
}

