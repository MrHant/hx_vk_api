package vk.api;
import flash.errors.ArgumentError;
import flash.errors.Error;
import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.net.LocalConnection;
import lime.utils.ByteArray;
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import vk.events.CustomEvent;

/**
 * Performs API Calls and dispatch some VK related events
 * 
 * @author Artyom Silivonchik, Loutchansy Oleg
 * Mostly based on APIConnection by Andrew Rogozov
 */
class Connection
{
	private var connectionName: String;
	private var sendingLC: LocalConnection;
	private var receivingLC: LocalConnection;
	
	private var pendingRequests: Array<Array<Dynamic>>;
	private var loaded: Bool = false;
	
	private var completeF : Dynamic -> Void;
	private var errorF : Dynamic -> Void;
	
	public function new(params:Dynamic)  
	{
		var api_url: String = 'https://api.vk.com/api.php';
		if (params.api_url) api_url = params.api_url;

		connectionName = params.lc_name;
		if (connectionName == null)
		{
			return;
		}
		
		pendingRequests = new Array();
		
		sendingLC = new LocalConnection();
		sendingLC.allowDomain("*");
		
		receivingLC = new LocalConnection();
		receivingLC.allowDomain("*");
		receivingLC.client = new Client();
		
		try 
		{
			receivingLC.connect("_out_" + connectionName);
		}
		catch (error: ArgumentError)
		{
			trace("Can't connect from App. The connection name is already being used by another SWF");
		}
		
		sendingLC.addEventListener(StatusEvent.STATUS, onInitStatus);
		sendingLC.send("_in_" + connectionName, "initConnection");
	}
		
	private function initConnection() 
	{
		if (loaded) 
		{
			return;
		}
		loaded = true;
		sendPendingRequests();
	}

	public function callMethod(params: Array<Dynamic>)
	{
		params.unshift("callMethod");
		sendData(params);
	}
	
	public function api(method: String, params: Dynamic, onComplete: Dynamic -> Void = null, onError: Dynamic -> Void = null)
	{
		var callId:Int = receivingLC.client.registerApiCall(onComplete, onError);
		sendData(["api", callId, method, params]);
	}

	private function sendPendingRequests()
	{
		while (pendingRequests.length > 0)
		{
			sendData(pendingRequests.shift());
		}
	}
	
	private function sendData(params: Array<Dynamic>)
	{
		if (loaded) 
		{
			params.unshift("_in_" + connectionName);
			Reflect.callMethod(null, sendingLC.send, params);
		} else {
			pendingRequests.push(params);
		}
	}
	
	private function onInitStatus(e:StatusEvent)
	{
		e.target.removeEventListener(e.type, onInitStatus);
		if (e.level == "status") 
		{
			initConnection();
		}
	}
	
	// Pass event handling to Client
	public function addEventListener(event: String, _callback: CustomEvent -> Void)
	{
		receivingLC.client.addEventListener(event, _callback);
	}
	
	private var tempPhoto : ByteArray;
	
	public function uploadWallPhoto(img : ByteArray, options : Dynamic, complete : Dynamic -> Void, error : Dynamic -> Void) : Void 
	{
		completeF = complete;
		errorF = error;
		
		this.tempPhoto = img;
		
		this.api("photos.getWallUploadServer", { }, uploadWallPhoto2, error);
	}
	
	private function uploadWallPhotoStep2(params: Dynamic)
	{
		var sender:URLRequest = new URLRequest(url);
		 var vars:URLVariables = new URLVariables();
		 vars.photo = tempPhoto;
		 sender.data = vars;
		 sender.method = URLRequestMethod.POST;
		 urlLoader = new URLLoader();
		 urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		 urlLoader.addEventListener(Event.COMPLETE, completeF);
		 try {
		  urlLoader.load(sender);
		 } catch (e:Error) {
		  trace(e);
		 }

	}

}