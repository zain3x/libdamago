package com.threerings.flashbang.pushbutton.scene {
import flash.display.DisplayObject;
import flash.geom.Point;

import com.threerings.util.Map;
import com.threerings.util.Maps;

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

        if (_sceneComponents.length <= 1) {
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

    override public function clear () :void
    {
        super.clear();
        _locationCache.clear();
    }

    //Subclasses override
    override protected function objectAdded (obj :SceneEntityComponent) :void
    {
        super.objectAdded(obj);
        var disp :DisplayObject = obj.displayObject;
        //We add one to the x to force sorting of this new child.
        var loc :Point = new Point(disp.x + 1, disp.y);
        _locationCache.put(obj, loc);
        dirty = true;
    }

    //Subclasses override
    override protected function objectRemoved (obj :SceneEntityComponent) :void
    {
        super.objectRemoved(obj);
        _locationCache.remove(obj);
    }

    protected function checkSceneComponentForLocationChange (obj :SceneEntityComponent,
                                                             previousLoc :Point) :Boolean
    {
        if (previousLoc.y != obj.y) {
            dirty = true;
            previousLoc.y = obj.y;
        }
        return dirty;
    }

    protected function updateZOrdering () :void
    {
        //Bubble sort
        var idx :int = 1;
        while (idx < numChildren) {
            if (getChildAt(idx).y < getChildAt(idx - 1).y) {
                swapChildrenAt(idx, idx - 1);
                if (idx > 1) {
                    idx--;
                }
            } else {
                idx++
            }
        }
    }

    /** Object -> Point for updating Y ordering only when positions area changed.*/
    protected var _locationCache :Map = Maps.newMapOf(Object);
}
}