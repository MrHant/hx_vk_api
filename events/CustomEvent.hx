package vk.events;
import flash.events.Event;

/**
 * @author Artyom Silivonchik
 */
class CustomEvent extends Event
{
	public var params(default, null): Dynamic;
	
	public function new(type: String, params: Dynamic = null, bubbles: Bool = false, cancelable: Bool = false)
	{
		this.params = params;
		super(type, bubbles, cancelable);
	}
}