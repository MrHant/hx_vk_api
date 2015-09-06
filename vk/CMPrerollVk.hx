package com.vk;
 
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.system.SecurityDomain;
 
/**
 * ...
 * @author kazemir
 */
class CMPrerollVk 
{
	public var cmFlashUrl:String = "http://img.creara-media.ru/lembrd/cm_1.0.swf";
	/**
	 * Подложка рекламного блока
	 */
	private var cmOverlay:Sprite = new Sprite();
	/**
	 * Загрузчик рекламного блока
	 */
	private var cmPrerollLoader:Loader;
 
	/**
	 * визуальный контейнер рекламного блока
	 */
	private var cmPreroll:Dynamic;
	//private var flashVars:Dynamic;
 
	private var pid:Float = 0;
 
	public var ext:Dynamic = {};
 
	private var rootContainer:DisplayObjectContainer;
 
	private var params:Dynamic = {};
 
	public function new(pid:Float, rootContainer:DisplayObjectContainer) 
	{
		cmOverlay.visible = false;
		Security.allowDomain( "*" );
		Security.allowInsecureDomain( "*" );
		
		this.pid = pid;
		this.rootContainer = rootContainer;
		
		//this.flashVars = rootContainer.loaderInfo.parameters;
		
		this.cmPrerollLoader = new Loader();
		
		this.cmPrerollLoader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onError );
		this.cmPrerollLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoaded );
		this.cmPrerollLoader.contentLoaderInfo.addEventListener( IOErrorEvent.NETWORK_ERROR, onError );
		this.cmPrerollLoader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
	}
 
	private function cmRedrawOverlay():Void 
	{
		cmOverlay.graphics.clear();
		if ( stage == null )
			return;
		
		cmOverlay.graphics.beginFill( 0xF7F7F7 );
		cmOverlay.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
		cmOverlay.graphics.endFill();
	}
 
	private var stage (get, null):Stage;
	
	function get_stage ():Stage 
	{
		return rootContainer.stage;
	}
 
	private function onLoaded(event:Event):Void 
	{
		try 
		{
			cmPreroll = cmPrerollLoader.content;
			
			cmPrerollLoader.contentLoaderInfo.sharedEvents.addEventListener( "cmShowBanner", onShowBanner );
			cmPrerollLoader.contentLoaderInfo.sharedEvents.addEventListener( "cmHideBanner", onHideBanner );
			
			cmPreroll.initialize( 0, rootContainer, {} );
		} 
		catch ( e:Dynamic)
		{
			trace( "Init failed : " + Std.string(e));
		}
	}
 
	private function onHideBanner(event:Event):Void 
	{
		trace( "[CM] HIDE banner" );
		cmOverlay.visible = false;
		stage.removeEventListener( "resize", onStageResize );
		stage.removeEventListener( "added", onChildAdded );
		
		rootContainer.removeEventListener( Event.ADDED_TO_STAGE, cmOnAddedToStage );
		
		if ( rootContainer.contains( cmOverlay ) )
			rootContainer.removeChild( cmOverlay );
		
		if ( this.cmPrerollLoader != null ) 
		{
			cmPreroll.removeEventListener( "cmShowBanner", onShowBanner );
			cmPreroll.removeEventListener( "cmHideBanner", onHideBanner );
			
			if ( rootContainer.contains( cmPrerollLoader ) )
				rootContainer.removeChild( cmPrerollLoader );
			
			if ( cmPreroll != null )
				cmPreroll.dispose();
			
			cmPrerollLoader.unload();
			cmPrerollLoader = null;
		}
	}
 
	private function onError(event:Dynamic):Void 
	{
		trace( "[CM] Error : " + event );
	}
 
	public function initCreara(fv:Dynamic):CMPrerollVk 
	{
		this.params = fv;
		
		if ( stage == null )
			rootContainer.addEventListener( Event.ADDED_TO_STAGE, cmOnAddedToStage );
		else
			cmOnAddedToStage( null );
		
		return this;
	}
 
	private function cmOnAddedToStage(event:Dynamic):Void 
	{
		try 
		{
			if ( event != null )
				rootContainer.removeEventListener( Event.ADDED_TO_STAGE, cmOnAddedToStage );
			
			cmRedrawOverlay();
			rootContainer.addChild( cmOverlay );
			
			stage.addEventListener( "resize", onStageResize );
			stage.addEventListener( "added", onChildAdded );
			
			/// load
			var req:URLRequest = new URLRequest( cmFlashUrl );
			var reqParams:URLVariables = new URLVariables();
			//setup( params, reqParams, {"viewer_id", "api_id", "secret", "sid"} );
			//setup( ext, reqParams, ext );
			
			//reqParams['pid'] = pid + "";
			
			reqParams.viewer_id = params.viewer_id;
			reqParams.api_id = params.api_id;
			reqParams.secret = params.secret;
			reqParams.sid = params.sid;
			reqParams.pid = Std.string(pid);
			
			req.data = reqParams;
			//Security.loadPolicyFile("http://img.creara-media.ru/crossdomain.xml");
			var lc:LoaderContext = new LoaderContext( true );// ,
					//ApplicationDomain.currentDomain,
					//SecurityDomain.currentDomain );
			
			cmPrerollLoader.load( req, lc );
			
			rootContainer.addChild(cmPrerollLoader);
			cmPrerollLoader.visible = false;
		} 
		catch ( e:Dynamic) 
		{
			trace( "[CM] Failed : " + Std.string(e));
		}
	}
 
	private function onChildAdded(event:Event):Void 
	{
		if ( cmOverlay != null && rootContainer.contains( cmOverlay ) ) 
			rootContainer.setChildIndex( cmOverlay, rootContainer.numChildren - 1 );
		
		if ( cmPrerollLoader != null && rootContainer.contains( cmPrerollLoader ) )
			rootContainer.setChildIndex( cmPrerollLoader, rootContainer.numChildren - 1 );
	}
 
	private function onStageResize(event:Event):Void 
	{
		setupAndShowBanner();
	}
 
	private function onShowBanner(event:Event):Void 
	{
		cmOverlay.visible = true;
		setupAndShowBanner();
	}
 
	private function setupAndShowBanner():Void 
	{
		cmRedrawOverlay();
		if ( stage != null && cmPreroll != null ) 
		{
			var w:Int = stage.stageWidth;
			var h:Int = stage.stageHeight;
			
			if ( w == 0 || h == 0 )
				return;
			
			cmPrerollLoader.visible = true;
			center( cmPreroll, w, h );
		}
	}
 
	public function center(preroll:Dynamic, w:Int, h:Int):Void 
	{
		preroll.x = (w - 500) / 2;
		preroll.y = 50;
	}
 
	/*private function setup(o:Dynamic, t:Dynamic, args:Dynamic):Void 
	{
		if ( Std.is(args, Array) ) 
		{
			for( a in args ) 
				if ( a in o && o[a] != null ) 
					t[a] = o[a];
		} 
		else 
		{
			for (  b in args ) 
				if ( b in o && o[b] != null ) 
					t[b] = o[b];
		}
	}*/
}