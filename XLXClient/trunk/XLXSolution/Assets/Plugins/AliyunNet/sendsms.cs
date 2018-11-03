using System;
using System.Collections.Generic;
using System.Text;
using Aliyun.Acs.Core;
using Aliyun.Acs.Core.Exceptions;
using Aliyun.Acs.Core.Profile;
using Aliyun.Acs.Dysmsapi.Model.V20170525;
using System.Threading;


public	static class Program
	{
		//产品名称:云�?�信短信API产品,�?发�?�无�?替换
		const String product = "Dysmsapi";
		//产品域名,�?发�?�无�?替换
		const String domain = "dysmsapi.aliyuncs.com";

		// TODO 此处�?要替换成�?发�?�自己的AK(在阿里云访问控制台寻�?)
		const String accessKeyId = "LTAIyvUxwrsW0tE1";
		const String accessKeySecret = "JjWCuLjlJ3fdxfnnMxAQrcRBxIGYCW";
		public static SendSmsResponse sendSms()
		{
			IClientProfile profile = DefaultProfile.GetProfile("cn-hangzhou", accessKeyId, accessKeySecret);
			DefaultProfile.AddEndpoint("cn-hangzhou", "cn-hangzhou", product, domain);
			IAcsClient acsClient = new DefaultAcsClient(profile);
			SendSmsRequest request = new SendSmsRequest();
			SendSmsResponse response = null;
			try
			{

				//必填:待发送手机号。支持以逗号分隔的形式进行批量调用，批量上限�?1000个手机号�?,批量调用相对于单条调用及时�?�稍有延�?,验证码类型的短信推荐使用单条调用的方�?
				request.PhoneNumbers = "19940867612";
				//必填:短信签名-可在短信控制台中找到
				request.SignName = "小龙�?123";
				//必填:短信模板-可在短信控制台中找到
				request.TemplateCode = "SMS_135027712";
				//可�??:模板中的变量替换JSON�?,如模板内容为"亲爱�?${name},您的验证码为${code}"�?,此处的�?�为
				request.TemplateParam = "{\"code\":\"123456\"}";
				//可�??:outId为提供给业务方扩展字�?,�?终在短信回执消息中将此�?�带回给调用�?
				request.OutId = "yourOutId";
				//请求失败这里会抛ClientException异常
				response = acsClient.GetAcsResponse(request);

			}
			catch (ServerException e)
			{
				Console.WriteLine(e.ErrorCode);
			}
			catch (ClientException e)
			{
				Console.WriteLine(e.ErrorCode);
			}
			return response;

		}

		public static SendBatchSmsResponse sendSms22()
		{
			IClientProfile profile = DefaultProfile.GetProfile("cn-hangzhou", accessKeyId, accessKeySecret);
			DefaultProfile.AddEndpoint("cn-hangzhou", "cn-hangzhou", product, domain);

			IAcsClient acsClient = new DefaultAcsClient(profile);
			SendBatchSmsRequest request = new SendBatchSmsRequest();
			//request.Protocol = ProtocolType.HTTPS;
			//request.TimeoutInMilliSeconds = 1;

			SendBatchSmsResponse response = null;
			try
			{

				//必填:待发送手机号。支持JSON格式的批量调用，批量上限�?100个手机号�?,批量调用相对于单条调用及时�?�稍有延�?,验证码类型的短信推荐使用单条调用的方�?
				request.PhoneNumberJson = "[\"1500000000\",\"1500000001\"]";
				//必填:短信签名-支持不同的号码发送不同的短信签名
				request.SignNameJson = "[\"云�?�信\",\"云�?�信\"]";
				//必填:短信模板-可在短信控制台中找到
				request.TemplateCode = "SMS_1000000";
				//必填:模板中的变量替换JSON�?,如模板内容为"亲爱�?${name},您的验证码为${code}"�?,此处的�?�为
				//友情提示:如果JSON中需要带换行�?,请参照标准的JSON协议对换行符的要�?,比如短信内容中包含\r\n的情况在JSON中需要表示成\\r\\n,否则会导致JSON在服务端解析失败
				request.TemplateParamJson = "[{\"name\":\"Tom\", \"code\":\"123\"},{\"name\":\"Jack\", \"code\":\"456\"}]";
				//可�??-上行短信扩展�?(扩展码字段控制在7位或以下，无特殊�?求用户请忽略此字�?)
				//request.SmsUpExtendCodeJson = "[\"90997\",\"90998\"]";

				//请求失败这里会抛ClientException异常
				response = acsClient.GetAcsResponse(request);

			}
			catch (ServerException e)
			{
				Console.Write(e.ErrorCode);
			}
			catch (ClientException e)
			{
				Console.Write(e.ErrorCode);
				Console.Write(e.Message);
			}
			return response;

		}

		public static QuerySendDetailsResponse querySendDetails(String bizId)
		{
			//初始化acsClient,暂不支持region�?
			IClientProfile profile = DefaultProfile.GetProfile("cn-hangzhou", accessKeyId, accessKeySecret);
			DefaultProfile.AddEndpoint("cn-hangzhou", "cn-hangzhou", product, domain);
			IAcsClient acsClient = new DefaultAcsClient(profile);
			//组装请求对象
			QuerySendDetailsRequest request = new QuerySendDetailsRequest();
			//必填-号码
			request.PhoneNumber = "15000000000";
			//可�??-流水�?
			request.BizId = bizId;
			//必填-发�?�日�? 支持30天内记录查询，格式yyyyMMdd       
			request.SendDate = DateTime.Now.ToString("yyyyMMdd");
			//必填-页大�?
			request.PageSize = 10;
			//必填-当前页码�?1�?始计�?
			request.CurrentPage = 1;

			QuerySendDetailsResponse querySendDetailsResponse = null;
			try
			{
				querySendDetailsResponse = acsClient.GetAcsResponse(request);
			}
			catch (ServerException e)
			{
				Console.WriteLine(e.ErrorCode);
			}
			catch (ClientException e)
			{
				Console.WriteLine(e.ErrorCode);
			}
			return querySendDetailsResponse;
		}

		static void Main(string[] args)
		{
			SendSmsResponse reponse = sendSms();
			Console.Write("短信发�?�接口返回的结果----------------");
			Console.WriteLine("Code=" + reponse.Code);
			Console.WriteLine("Message=" + reponse.Message);
			Console.WriteLine("RequestId=" + reponse.RequestId);
			Console.WriteLine("BizId=" + reponse.BizId);
			Console.WriteLine();
			Thread.Sleep(3000);

			if (reponse.Code != null && reponse.Code == "OK")
			{
				QuerySendDetailsResponse queryReponse = querySendDetails(reponse.BizId);

				Console.WriteLine("短信明细查询接口返回数据----------------");
				Console.WriteLine("Code=" + queryReponse.Code);
				Console.WriteLine("Message=" + queryReponse.Message);
				foreach (QuerySendDetailsResponse.QuerySendDetails_SmsSendDetailDTO smsSendDetailDTO in queryReponse.SmsSendDetailDTOs)
				{
				//	Console.WriteLine("Content=" + smsSendDetailDTO.Content);
				//	Console.WriteLine("ErrCode=" + smsSendDetailDTO.ErrCode);
				//	Console.WriteLine("OutId=" + smsSendDetailDTO.OutId);
				//	Console.WriteLine("PhoneNum=" + smsSendDetailDTO.PhoneNum);
				//	Console.WriteLine("ReceiveDate=" + smsSendDetailDTO.ReceiveDate);
				//	Console.WriteLine("SendDate=" + smsSendDetailDTO.SendDate);
				//	Console.WriteLine("SendStatus=" + smsSendDetailDTO.SendStatus);
				//	Console.WriteLine("Template=" + smsSendDetailDTO.TemplateCode);
				}
			}

		}
	}
