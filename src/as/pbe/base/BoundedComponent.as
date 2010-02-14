package net.amago.pbe.base {
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
	
	public function clone () :Object
	{
		return new BoundedComponent(_bounds.clone() as Bounds);
	}
    protected var _bounds :Bounds;
}
}