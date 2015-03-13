package;
import openfl.display.Loader;
import openfl.display.Sprite;

enum AdsType {
	Preroll;
	Banner;
}

/**
 * ...
 * @author Loutchansky Oleg
 */
class Ads
{
	static inline var adsFlashUrl:String = "http://api.vk.com/swf/vk_ads.swf";
	
	var adsOverlay : Sprite;
	var adsLoader : Loader;

	public function new(type : AdsType = AdsType.Banner)
	{
		adsOverlay = new Sprite();
		adsLoader = new Loader();
		
	}
	
}