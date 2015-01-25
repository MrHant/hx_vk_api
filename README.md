hx-vk-api
=========

Haxe VK API throw OpenFL <b>(Flash)</b>
Example to use:
```Haxe

package;

import openfl.display.sprite;
import vk.Vk;

class Main extend Sprite
{
	public function new() 
	{
		var flashVars = this.stage.loaderInfo.parameters;
		var vk = new Vk(flashVars);
		
		// https://vk.com/dev/clientapi
		var paramsWindow = new Array();
		paramsWindow.push("setTitle");
		paramsWindow.push("My Title");
		
		vk.callMethod(paramsWindow);
		
		vk.api("users.get", [], userGetComplete, userGetError);
		
	}
	
	private function userGetComplete(params:Dynamic):Void {
		
		var tField = new TextField();
		tField.x = 25;
		tField.y = 25;
		tField.width = 750;
		tField.height = 500;
		tField.wordWrap = true;
		tField.text = Std.string(params);
		
		addChild(a);
	}
	
	private function userGetError(params:Dynamic):Void {
		
		var tField = new TextField();
		tField.x = 25;
		tField.y = 25;
		tField.width = 750;
		tField.height = 500;
		tField.wordWrap = true;
		tField.text = Std.string(params);
		
		addChild(a);
		
	}

}
```
