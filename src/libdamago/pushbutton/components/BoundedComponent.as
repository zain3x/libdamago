package libdamago.pushbutton.components {
import com.pblabs.engine.entity.EntityComponent;
import com.threerings.ui.bounds.Bounds;
import com.threerings.util.ClassUtil;

public class BoundedComponent extends EntityComponent
{
    public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(BoundedComponent);

    public function BoundedComponent (bounds :Bounds = null)
    {
        _bounds = bounds;
    }

    public function get bounds () :Bounds
    {
        return _bounds;
    }
	
	public function set bounds (val :Bounds) :void
	{
		_bounds = val;
	}
	
    protected var _bounds :Bounds;
}
}