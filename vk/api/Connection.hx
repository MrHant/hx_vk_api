package vk.api;
import flash.errors.ArgumentError;
import flash.errors.Error;
import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.net.LocalConnection;
import lime.utils.ByteArray;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLRequestHeader;
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
	var connectionName 	: String;
	var sendingLC		: LocalConnection;
	var receivingLC		: LocalConnection;
	
	var pendingRequests	: Array<Array<Dynamic>>;
	var loaded			: Bool = false;
	
	var completeF 		: Dynamic -> Void;
	var errorF 			: Dynamic -> Void;
	var isTestMode 		: Bool = false;
	
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
		
	function initConnection() 
	{		
		if (loaded) 
		{
			return;
		}
		loaded = true;
		sendPendingRequests();
	}
	
	/**
	 * Add param: test_mode: 1
	 */
	public function setTestModeOn()
	{
		isTestMode = true;
	}

	public function callMethod(params: Array<Dynamic>)
	{
		params.unshift("callMethod");
		sendData(params);
	}
	
	public function api(method: String, params: Dynamic, onComplete: Dynamic -> Void = null, onError: Dynamic -> Void = null)
	{
		if (isTestMode)
		{	
			Reflect.setProperty(params, "test_mode", "1");			
		}
		
		var callId:Int = receivingLC.client.registerApiCall(onComplete, onError);
		sendData(["api", callId, method, params]);
	}

	function sendPendingRequests()
	{
		while (pendingRequests.length > 0)
		{
			sendData(pendingRequests.shift());
		}
	}
	
	function sendData(params: Array<Dynamic>)
	{
		if (loaded) 
		{
			params.unshift("_in_" + connectionName);
			Reflect.callMethod(null, sendingLC.send, params);
		} else {
			pendingRequests.push(params);
		}
	}
	
	function onInitStatus(e:StatusEvent)
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
	
	 var tempPhoto : ByteArray;
	
	public function uploadWallPhoto(img : ByteArray, options : Dynamic, complete : Dynamic -> Void, error : Dynamic -> Void) : Void 
	{
		completeF = complete;
		errorF = error;
		
		this.tempPhoto = img;
		
		this.api("photos.getWallUploadServer", { }, uploadWallPhotoStep2, error);
	}
	
	var urlLoader : URLLoader;
	function uploadWallPhotoStep2(params: Dynamic)
	{
		//trace(params);
		/*var sender:URLRequest = new URLRequest(params.upload_url);
		var vars:URLVariables = new URLVariables();
		vars.photo = tempPhoto;		
		sender.data = "photo:" + tempPhoto;
		sender.method = URLRequestMethod.POST;
		urlLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;		
		urlLoader.addEventListener(Event.COMPLETE, uploadFinish);
		
		try 
		{
			urlLoader.load(sender);
		} 
		catch (e:Error) 
		{
			trace(e);
		}*/
		
		var imageStream = tempPhoto;
 
		var stream:ByteArray = new ByteArray();
		var boundary:String = "----------Ij5ae0ae0KM7GI3KM7";
		var imageName:String	= "image" + ".png";
		stream.writeUTFBytes("--" + boundary + '\r\nContent-Disposition: form-data; name="file1"; filename="' + imageName + '"\r\nContent-Type: image/png\r\n\r\n');
		stream.writeBytes(imageStream);
		stream.writeUTFBytes("\r\n--" + boundary + '--\r\n');
		var header:URLRequestHeader = new URLRequestHeader ("Content-type", "multipart/form-data; boundary=" + boundary);
		var urlRequest:URLRequest = new URLRequest(params.upload_url);
		urlRequest.requestHeaders.push(header);
		urlRequest.method = URLRequestMethod.POST;
		urlRequest.data = stream;
		urlLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
		urlLoader.addEventListener( Event.COMPLETE, uploadFinish );
		urlLoader.addEventListener( IOErrorEvent.IO_ERROR, errorF );
		try 
		{
			urlLoader.load( urlRequest );
		}
		catch (e:Error) 
		{
			errorF(e);
		}


	}
	
	function uploadFinish(e:Event):Void 
	{
		completeF(urlLoader.data);
	}

}