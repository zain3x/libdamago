package net.amago.pbe.base {
import com.threerings.util.ClassUtil;

public class RotationComponent extends NotifyingValueComponent
{
	public static const EVENT_NAME :String = "angleChanged";
	public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(RotationComponent); 
	
    public function RotationComponent ()
    {
        super();
    }
	
	public function get angle () :Number
	{
		return _value;
	}
	
	public function set angle (val :Number) :void
	{
		setValue(val);
	}
	
	override protected function get eventName () :String
	{
		return EVENT_NAME;
	}
}
}