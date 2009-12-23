package libdamago.pushbutton.components {
import com.threerings.flashbang.pushbutton.EntityComponent;
import com.threerings.util.ClassUtil;

import flash.display.DisplayObject;

public class SceneComponent extends EntityComponent
{
	public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(SceneComponent);
	
	public function SceneComponent (disp :DisplayObject)
	{
		super(COMPONENT_NAME);
		_displayObject = disp;
	}
	
	public function get displayObject () :DisplayObject
	{
		return _displayObject;
	}
	
	protected var _displayObject :DisplayObject;
}
}