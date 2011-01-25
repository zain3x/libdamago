package net.amago.pathfinding.navmesh.pbe.debug {
import aduros.util.F;

import com.pblabs.engine.entity.PropertyReference;
import com.pblabs.rendering2D.DisplayObjectRenderer;
import com.threerings.util.ClassUtil;
import com.threerings.util.DisplayUtils;
import com.threerings.util.EventHandlerManager;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;

import net.amago.pathfinding.navmesh.PathToFollow;
import net.amago.pathfinding.navmesh.pbe.PathFindingComponent;

public class PathDisplayComponent extends DisplayObjectRenderer
{
	public var pathProperty :PropertyReference;
	
	public function PathDisplayComponent ()
	{
		super();
		_displayObject = new Sprite();
	}
	
	public function set color (val :uint) :void
	{
		_color = val;
		redraw();
	}
	
	override public function set displayObject (value :DisplayObject) :void
	{
		throw new Error("Cannot set displayObject in " + 
			ClassUtil.tinyClassName(this) + "; it is always a Sprite");
	}
	
	public function set thickness (val :uint) :void
	{
		_thickness = val;
		redraw();
	}
	
	override protected function onReset() : void
	{
		super.onReset();
		redraw();
	}
	
	protected function redraw () :void
	{
		var path :PathToFollow = this.path;
		DisplayUtils.removeAllChildren(_displayObject);
		var g :Graphics = Sprite(_displayObject).graphics;
		g.clear();
		if (path == null) {
			return;
		}
		g.lineStyle(_thickness, _color);
		
		var pathNodes :Array = path.path;
		for(var k :int = 0; k < pathNodes.length - 1; k++) {
			g.moveTo(pathNodes[k].x, pathNodes[k].y);
			g.lineTo(pathNodes[k + 1].x, pathNodes[k + 1].y);
		}
	}
	
	protected function get path () :PathToFollow
	{
		return owner.getProperty(pathProperty) as PathToFollow;
	}
	
	override protected function onAdd() : void
	{
		super.onAdd();
		_events.registerListener(owner.eventDispatcher, PathFindingComponent.CHANGED, 
			F.callback(redraw));
	}
	
	override protected function onRemove () :void
	{
		super.onRemove();
		_events.freeAllHandlers();
	}
	
	protected var _color :uint = 0xcc00cc;
	protected var _thickness :Number = 2;
	protected var _events :EventHandlerManager = new EventHandlerManager();
}
}