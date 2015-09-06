package vk;
import vk.api.Connection;

/**
 * @author Artyom Silivonchik
 */
class Vk extends Connection
{	
	var isWorkEnviroment : Bool = false;
	
	public function new(flashVars: Dynamic) 
	{
		super(flashVars);
		
		if (flashVars.api_id == null)
		{
			isWorkEnviroment = false;
		}
		else
		{
			isWorkEnviroment = true;
		}
	}
	
	public function isVKEnvironment():Bool
	{
		return isWorkEnviroment;
	}
}