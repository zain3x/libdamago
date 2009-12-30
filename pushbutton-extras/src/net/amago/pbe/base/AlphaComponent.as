package libdamago.pushbutton.components {
import com.threerings.util.ClassUtil;

public class AlphaComponent extends NotifyingValueComponent
{
	public static const EVENT_NAME :String = "alphaChanged";
	public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(AlphaComponent); 
	
	public function AlphaComponent ()
	{
		super();
	}
	
	public function get alpha () :Number
	{
		return _value;
	}
	
	public function set alpha (val :Number) :void
	{
		setValue(val);
	}
	
	override protected function get eventName () :String
	{
		return EVENT_NAME;
	}
}
}