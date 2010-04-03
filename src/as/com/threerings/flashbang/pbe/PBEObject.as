package com.threerings.flashbang.pushbutton {
import flash.display.DisplayObjectContainer;
import flash.events.IEventDispatcher;
import com.threerings.util.EventHandlerManager;
public class PBEObject
{

    /**
     * Returns the ObjectDB that this object is contained in.
     */
    public final function get db () :PBEObjectDB
    {
        return _parentDB;
    }

    /**
     * Returns true if the object is in an ObjectDB and is "live"
     * (not pending removal from the database)
     */
    public function get isLiveObject () :Boolean
    {
        return (null != _ref && !_ref.isNull);
    }

    /**
     * Returns the name of this object.
     * Two objects in the same mode cannot have the same name.
     * Objects cannot change their names once added to a mode.
     */
    public function get objectName () :String
    {
        return null;
    }

    /**
     * Returns the unique PBEObjectRef that stores a reference to this PBEObject.
     */
    public final function get ref () :EntityRef
    {
        return _ref;
    }

    /**
     * Causes the lifecycle of the given PBEObject to be managed by this object. Dependent
     * objects will be added to this object's ObjectDB, and will be destroyed when this
     * object is destroyed.
     */
    public function addDependentObject (obj :PBEObject) :void
    {
        if (_parentDB != null) {
            addDependentToDB(obj, false, null, 0);
        } else {
            _pendingDependentObjects.push(new PendingDependentObject(obj, false, null, 0));
        }
    }

    /**
     * Causes the lifecycle of the given PBEObject to be managed by this object. Dependent
     * objects will be added to this object's ObjectDB, and will be destroyed when this
     * object is destroyed.
     */
    public function addDependentSceneObject (obj :PBEObject, displayParent :DisplayObjectContainer =
        null, displayIdx :int = -1) :void
    {
        if (_parentDB != null) {
            addDependentToDB(obj, true, displayParent, displayIdx);
        } else {
            _pendingDependentObjects.push(new PendingDependentObject(obj, true, displayParent,
                displayIdx));
        }
    }

    /** Removes the PBEObject from its parent database. */
    public function destroySelf () :void
    {
        _parentDB.destroyObject(_ref);
    }

    /**
     * Iterates over the groups that this object is a member of.
     * If a subclass overrides this function, it should do something
     * along the lines of:
     *
     * override public function getObjectGroup (groupNum :int) :String
     * {
     *     switch (groupNum) {
     *     case 0: return "Group0";
     *     case 1: return "Group1";
     *     // 2 is the number of groups this class defines
     *     default: return super.getObjectGroup(groupNum - 2);
     *     }
     * }
     */
    public function getObjectGroup (groupNum :int) :String
    {
        return null;
    }

    /**
     * Called immediately after the PBEObject has been added to an ObjectDB.
     * (Subclasses can override this to do something useful.)
     */
    protected function addedToDB () :void
    {
    }

    /**
     * Called after the PBEObject has been removed from the active AppMode, or if the
     * object's containing AppMode is removed from the mode stack.
     *
     * If the PBEObject is removed from the active AppMode, {@link #removedFromDB}
     * will be called before destroyed.
     *
     * destroyed should be used for logic that must be always be run when the PBEObject is
     * destroyed (disconnecting event listeners, releasing resources, etc).
     *
     * (Subclasses can override this to do something useful.)
     */
    protected function destroyed () :void
    {
    }

    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     *
     * Listeners registered in this way will be automatically unregistered when the PBEObject is
     * destroyed.
     */
    protected function registerListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerListener(dispatcher, event, listener, useCapture, priority);
    }

    /**
     * Registers a zero-arg callback function that should be called once when the event fires.
     *
     * Listeners registered in this way will be automatically unregistered when the PBEObject is
     * destroyed.
     */
    protected function registerOneShotCallback (dispatcher :IEventDispatcher, event :String,
        callback :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
    }

    /**
     * Called immediately after the PBEObject has been removed from an AppMode.
     *
     * removedFromDB is not called when the PBEObject's AppMode is removed from the mode stack.
     * For logic that must be run in this instance, see {@link #destroyed}.
     *
     * (Subclasses can override this to do something useful.)
     */
    protected function removedFromDB () :void
    {
    }

    /**
     * Removes the specified listener from the specified dispatcher for the specified event.
     */
    protected function unregisterListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false) :void
    {
        _events.unregisterListener(dispatcher, event, listener, useCapture);
    }

    internal function addDependentToDB (obj :PBEObject, isSceneObject :Boolean,
        displayParent :DisplayObjectContainer, displayIdx :int) :void
    {
        var ref :EntityRef;
        if (isSceneObject) {
            if (!(_parentDB is PBEAppmode)) {
                throw new Error("can't add SceneObject to non-AppMode ObjectDB");
            }
            throw new Error("Not yet implemented");
                //                ref = PBEAppmode(_parentDB).addSceneObject(obj, displayParent, displayIdx);
        } else {
            ref = _parentDB.addObject(obj);
        }
        _dependentObjectRefs.push(ref);
    }

    internal function addedToDBInternal () :void
    {
        for each (var dep :PendingDependentObject in _pendingDependentObjects) {
            addDependentToDB(dep.obj, dep.isSceneObject, dep.displayParent, dep.displayIdx);
        }
        _pendingDependentObjects = null;
        addedToDB();
    }

    internal function destroyedInternal () :void
    {
        destroyed();
        _events.freeAllHandlers();
    }

    internal function removedFromDBInternal () :void
    {
        for each (var ref :EntityRef in _dependentObjectRefs) {
            if (ref.isLive) {
                ref.object.destroySelf();
            }
        }
        removedFromDB();
    }

    protected var _dependentObjectRefs :Array = [];

    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _pendingDependentObjects :Array = [];

    internal var _parentDB :PBEObjectDB;

    // managed by ObjectDB/AppMode
    internal var _ref :EntityRef;
}

}

import flash.display.DisplayObjectContainer;
import com.threerings.flashbang.pushbutton.PBEObject;
class PendingDependentObject
{
    public var displayIdx :int;
    public var displayParent :DisplayObjectContainer;
    public var isSceneObject :Boolean;
    public var obj :PBEObject;

    public function PendingDependentObject (obj :PBEObject, isSceneObject :Boolean,
        displayParent :DisplayObjectContainer, displayIdx :int)
    {
        this.obj = obj;
        this.isSceneObject = isSceneObject;
        this.displayParent = displayParent;
        this.displayIdx = displayIdx;
    }
}
