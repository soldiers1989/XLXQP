using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using cn.sharesdk.unity3d;

public class ShareSDKManager : Kernel<ShareSDKManager>
{

    private ShareSDK ssdk;


    // Use this for initialization
    void Start () {
        GameObject ShareSdkObject = GameObject.Find("Share");
        if (ShareSdkObject != null)
        {
            ssdk = ShareSdkObject.GetComponent<ShareSDK>();
        }
        else
        {
            Debug.LogErrorFormat("Find Share SDK GameObject failed!");
            return;
        }

        ssdk.shareHandler = ShareResultHandler;
        ssdk.authHandler = OnAuthResultHandler;
        ssdk.showUserHandler = OnGetUserInfoResultHandler;
        ssdk.getFriendsHandler = OnGetFriendsResultHandler;
        ssdk.followFriendHandler = OnFollowFriendResultHandler;
    }
	
	// Update is called once per frame
	void Update () {
		
	}

    public void CustomizeShareParamsInfo(string Title, string Text ,string ImageURL , string URL , int contentType, PlatformType ID)
    {
        Debug.Log("AAAAA Test ShareSDK C#");
        if (ID == PlatformType.WeChat || ID == PlatformType.WeChatMoments)
        {
            TypeIsWeChat(Title, Text, ImageURL, URL, contentType, ID);
        }
        else if (ID == PlatformType.QQ || ID == PlatformType.QZone)
        {
            TypeIsQQ(Title, Text, ImageURL, URL, contentType, ID);
        }
        else if (ID == PlatformType.SinaWeibo)
        {
            TypeIsSina(Title, Text, ImageURL, URL, contentType, ID);
        }
    }

    void TypeIsWeChat(string Title, string Text, string ImageURL, string URL, int contentType, PlatformType ID)
    {
        ShareContent content = new ShareContent();
        content.SetTitle(Title);
        content.SetText(Text);
        content.SetImageUrl(ImageURL);
        content.SetUrl(URL);
        content.SetShareType(contentType);
        ssdk.ShareContent(ID, content);
        Debug.Log("AAAAA Test ShareSDK C# 通过分享菜单分享Wechat" + Title + Text + ImageURL + URL + ID);
    }

    void TypeIsQQ(string Title, string Text, string ImageURL, string URL, int contentType, PlatformType ID)
    {
        ShareContent content = new ShareContent();
        content.SetTitle(Title);
        content.SetText(Text);
        content.SetImageUrl(ImageURL);
        content.SetTitleUrl(URL);
        content.SetShareType(contentType);
        ssdk.ShareContent(ID, content);
        Debug.Log("AAAAA Test C# 通过分享菜单分享QQ"+ Title + Text + ImageURL + URL + ID);
    }
    void TypeIsSina(string Title, string Text, string ImageURL, string URL, int contentType, PlatformType ID)
    {
        ShareContent content = new ShareContent();
        content.SetTitle(Title);
        content.SetText(Text);
        content.SetImageUrl(ImageURL);
        content.SetUrl(URL);
        content.SetShareType(contentType);
        ssdk.ShareContent(ID, content);
        Debug.Log("AAAAA Test C# 通过分享菜单分享Sina" + Title + Text + ImageURL + URL + ID);
    }

    void OnAuthResultHandler(int reqID, ResponseState state, PlatformType type, Hashtable result)
	{
		if (state == ResponseState.Success)
		{
			if (result != null && result.Count > 0) {
                Debug.Log("authorize success !" + "Platform :" + type + "result:");
			} else {
                Debug.Log("authorize success !" + "Platform :" + type);
			}
		}
		else if (state == ResponseState.Fail)
		{
            #if UNITY_ANDROID
            Debug.Log("fail! throwable stack = " + result["stack"] + "; error msg = " + result["msg"]);
            #elif UNITY_IPHONE
			Debug.Log ("fail! error code = " + result["error_code"] + "; error msg = " + result["error_msg"]);
            #endif
        }
        else if (state == ResponseState.Cancel) 
		{
			print ("cancel !");
		}
	}

    void ShareResultHandler (int reqID, ResponseState state, PlatformType type, Hashtable result)
    {
		if (state == ResponseState.Success)
		{
			Debug.Log ("---------------- share successfully - share result :");
            Debug.Log(ShareSDKMiniJSON.jsonEncode(result));
            EventDispatcher.Instance.TriggerEvent("ShareSDKReceiveMessageEvent", state);
        }
		else if (state == ResponseState.Fail)
		{
            #if UNITY_ANDROID
            Debug.Log("fail! throwable stack = " + result["stack"] + "; error msg = " + result["msg"]);
            #elif UNITY_IPHONE
			Debug.Log ("fail! error code = " + result["error_code"] + "; error msg = " + result["error_msg"]);
            #endif
            EventDispatcher.Instance.TriggerEvent("ShareSDKReceiveMessageEvent", state);
        }
        else if (state == ResponseState.Cancel) 
		{
            Debug.Log("cancel !");
            EventDispatcher.Instance.TriggerEvent("ShareSDKReceiveMessageEvent", state);
        }
    }

    void OnGetUserInfoResultHandler (int reqID, ResponseState state, PlatformType type, Hashtable result)
	{
		if (state == ResponseState.Success)
		{
            Debug.Log("get user info result :");
            //print (MiniJSON.jsonEncode(result));
            //print ("AuthInfo:" + MiniJSON.jsonEncode (ssdk.GetAuthInfo (PlatformType.QQ)));
            Debug.Log("Get userInfo success !Platform :" + type );
		}
		else if (state == ResponseState.Fail)
		{
            #if UNITY_ANDROID
            Debug.Log("fail! throwable stack = " + result["stack"] + "; error msg = " + result["msg"]);
            #elif UNITY_IPHONE
			Debug.Log ("fail! error code = " + result["error_code"] + "; error msg = " + result["error_msg"]);
            #endif
        }
        else if (state == ResponseState.Cancel) 
		{
            Debug.Log("cancel !");
		}
	}

    void OnGetFriendsResultHandler (int reqID, ResponseState state, PlatformType type, Hashtable result)
	{
		if (state == ResponseState.Success)
		{
            Debug.Log("get friend list result :");
			//print (MiniJSON.jsonEncode(result));
		}
		else if (state == ResponseState.Fail)
		{
        #if UNITY_ANDROID
            Debug.Log("fail! throwable stack = " + result["stack"] + "; error msg = " + result["msg"]);
        #elif UNITY_IPHONE
			Debug.Log ("fail! error code = " + result["error_code"] + "; error msg = " + result["error_msg"]);
        #endif
        }
        else if (state == ResponseState.Cancel) 
		{
            Debug.Log("cancel !");
		}
	}
    void OnFollowFriendResultHandler (int reqID, ResponseState state, PlatformType type, Hashtable result)
	{
		if (state == ResponseState.Success)
		{
            Debug.Log("Follow friend successfully !");
		}
		else if (state == ResponseState.Fail)
		{
            #if UNITY_ANDROID
            Debug.Log("fail! throwable stack = " + result["stack"] + "; error msg = " + result["msg"]);
            #elif UNITY_IPHONE
			Debug.Log ("fail! error code = " + result["error_code"] + "; error msg = " + result["error_msg"]);
            #endif
        }
        else if (state == ResponseState.Cancel) 
		{
			print ("cancel !");
		}
	}

}
