package com.threerings.flashbang.pushbutton.scene {
import com.threerings.util.ArrayUtil;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import flash.display.DisplayObject;
import flash.geom.Point;
/**
 * Sorts DisplayObjects by the y coordinate.  Caches values so only changed objects
 * are resorted.
 * @author dion
 */
public class SceneLayerYOrdering extends SceneLayer
{
    /**
     * Order the child components according to their y values.
     */
    override public function render (... ignored) :void
    {
        super.render();

        if (_sceneComponents.size() <= 1) {
            //Don't order if there's nothing to order.
            return;
        }

        if (!dirty) { //Check if any child location is changed
            _locationCache.forEach(checkSceneComponentForLocationChange);
        }

        if (dirty) {
            updateZOrdering();
        }
    }

    //Subclasses override
    override protected function objectAdded (obj :*) :void
    {
        super.objectAdded(obj);
        var disp :DisplayObject = _sceneComponents.get(obj) as DisplayObject;
        //We add one to the x to force sorting of this new child.
        var loc :Point = new Point(disp.x + 1, disp.y);
        _locationCache.put(obj, loc);
        _componentsToReorder.push(obj);
        dirty = true;

    }

    //Subclasses override
    override protected function objectRemoved (obj :*) :void
    {
        super.objectRemoved(obj);
        _locationCache.remove(obj);
        ArrayUtil.removeFirst(_componentsToReorder, obj);
    }

    protected function checkSceneComponentForLocationChange (obj :*, previousLoc :Point) :void
    {
        var disp :DisplayObject = _sceneComponents.get(obj) as DisplayObject;
        if (previousLoc.x != disp.x || previousLoc.y != disp.y) {
            dirty = true;
            previousLoc.x = disp.x;
            previousLoc.y = disp.y;
            _componentsToReorder.push(obj);
        }
    }

    protected function updateZOrdering () :void
    {
        if (_sceneComponents.size() <= 1) {
            _componentsToReorder.splice(0);
            dirty = false;
            return;
        }
        //Only reorder the changed components.
        var sortedComponents :Array = _sceneComponents.values();
        ArrayUtil.sortOn(sortedComponents, SORT_ARGS);
        for each (var dirtyObj :*in _componentsToReorder) {
            var disp :DisplayObject = _sceneComponents.get(dirtyObj) as DisplayObject;
            var idx :int = ArrayUtil.indexOf(sortedComponents, disp);
            setChildIndex(disp, idx);
        }

        dirty = false;
        _componentsToReorder.splice(0);
    }

    protected var _componentsToReorder :Array = [];

    /** Object -> Point for updating Y ordering only when positions area changed.*/
    protected var _locationCache :Map = Maps.newMapOf(Object);
    protected static const SORT_ARGS :Array = [ "y" ];
}
}