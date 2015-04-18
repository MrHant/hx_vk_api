package vk.api;
import flash.events.EventDispatcher;
import vk.events.CustomEvent;

/**
 * @author Artyom Silivonchik
 */
class Client extends EventDispatcher implements IClient
{
	private var apiCallId: Int = 0;
	private var apiCalls: Array< String -> Void >;
	
	public function new() 
	{
		super();
		apiCalls = new Array();
	}

	public function registerApiCall(onComplete: Dynamic -> Void = null, onError: Dynamic -> Void = null): Int 
	{
		var callId: Int = apiCallId++;
		apiCalls[callId] = function(data: Dynamic) 
		{
			if (data.error != null) 
			{
				if (onError != null) {
					onError(data.error);
				}
				else {
					trace("VKAPI Error: " + data.error);
				}
			} else if (onComplete != null) {
				onComplete(data.response);
			}
		}
		return callId;
	}
	
	private function defaultHandler(method: String, params: Dynamic = null)
	{
		dispatchEvent(new CustomEvent(method, params));
	}

	/*
	 * Handlers
	 */
	public function apiCallback(callId:Int, data:Dynamic)
	{
		apiCalls[callId](data);
		apiCalls[callId] = null;
	}
	 
	public function onSettingsChanged(params: Dynamic = null)
	{
		defaultHandler("onSettingsChanged", params);
	}
	
	public function onBalanceChanged(params: Dynamic = null)
	{
		defaultHandler("onBalanceChanged", params);
	}
	
	public function onLocationChanged(params: Dynamic = null)
	{
		defaultHandler("onLocationChanged", params);
	}
	
	public function onWindowResized(params: Dynamic = null)
	{
		defaultHandler("onWindowResized", params);
	}
	
	public function onApplicationAdded(params: Dynamic = null)
	{
		defaultHandler("onApplicationAdded", params);
	}
	
	public function onWindowBlur(params: Dynamic = null)
	{
		defaultHandler("onWindowBlur", params);
	}
	
	public function onWindowFocus(params: Dynamic = null)
	{
		defaultHandler("onWindowFocus", params);
	}
	
	public function onWallPostSave(params: Dynamic = null)
	{
		defaultHandler("onWallPostSave", params);
	}
	
	public function onWallPostCancel(params: Dynamic = null)
	{
		defaultHandler("onWallPostCancel", params);
	}
	
	public function onProfilePhotoSave(params: Dynamic = null)
	{
		defaultHandler("onProfilePhotoSave", params);
	}
	
	public function onProfilePhotoCancel(params: Dynamic = null)
	{
		defaultHandler("onProfilePhotoCancel", params);
	}
	
	public function onMerchantPaymentSuccess(params: Dynamic = null)
	{
		defaultHandler("onMerchantPaymentSuccess", params);
	}
	
	public function onMerchantPaymentCancel(params: Dynamic = null)
	{
		defaultHandler("onMerchantPaymentCancel", params);
	}
	
	public function onMerchantPaymentFail(params: Dynamic = null)
	{
		defaultHandler("onMerchantPaymentFail", params);
	}
}