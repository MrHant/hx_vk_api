package vk.api;

/**
 * @author Artyom Silivonchik
 */
interface IClient
{
	private var apiCallId: Int;
	private var apiCalls: Array< String -> Void >;
	
	function onBalanceChanged(params: Dynamic = null): Void;
	function onSettingsChanged(params: Dynamic = null): Void;
	function onLocationChanged(params: Dynamic = null): Void;
	function onWindowResized(params: Dynamic = null): Void;
	function onApplicationAdded(params: Dynamic = null): Void;
	function onWindowBlur(params: Dynamic = null): Void;
	function onWindowFocus(params: Dynamic = null): Void;
	function onWallPostSave(params: Dynamic = null): Void;
	function onWallPostCancel(params: Dynamic = null): Void;
	function onProfilePhotoSave(params: Dynamic = null): Void;
	function onProfilePhotoCancel(params: Dynamic = null): Void;
	function onMerchantPaymentSuccess(params: Dynamic = null): Void;
	function onMerchantPaymentCancel(params: Dynamic = null): Void;
	function onMerchantPaymentFail(params: Dynamic = null): Void;
	function apiCallback(callId: Int, data: Dynamic): Void;
}