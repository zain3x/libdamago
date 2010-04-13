package net.amago.pathfinding.navmesh.pbe {
import com.pblabs.engine.entity.PropertyReference;
import com.pblabs.rendering2D.DisplayObjectRenderer;
import flash.display.DisplayObject;
import flash.display.Sprite;
import com.threerings.util.DebugUtil;
import com.threerings.util.EventHandlerManager;
import com.threerings.util.F;
import net.amago.math.geometry.Polygon;
public class PolygonRenderer extends DisplayObjectRenderer
{
	public var polygonProperty :PropertyReference;
	
    public function PolygonRenderer ()
    {
        super();
		_displayObject = new Sprite();
    }
	
	override public function set displayObject(value:DisplayObject):void
	{
		throw new Error("Cannot set displayObject in BitmapRenderer; it is always a Sprite containing a Bitmap.");
	}
	
	override protected function onAdd() : void
	{
		super.onAdd();
		_events.registerListener(owner.eventDispatcher, ExclusionComponent.CHANGED, 
			F.callback(redraw));
	}
	
	override protected function onRemove () :void
	{
		super.onRemove();
		_events.freeAllHandlers();
	}
	
	override protected function onReset() : void
	{
		redraw();
	}
	
	protected function redraw () :void
	{
		Sprite(_displayObject).graphics.clear();
		var polygon :Polygon = owner.getProperty(polygonProperty) as Polygon;
		if (polygon != null) {
			polygon.draw(Sprite(_displayObject).graphics, 0);
		}
	}
	
	protected var _events :EventHandlerManager = new EventHandlerManager();
}
}