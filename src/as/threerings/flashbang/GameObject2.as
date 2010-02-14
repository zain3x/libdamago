package com.threerings.flashbang {
	
import com.threerings.flashbang.tasks.ParallelTask;
import com.threerings.flashbang.tasks.TaskContainer;
import com.threerings.util.EventHandlerManager;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.display.DisplayObjectContainer;
public class GameObject2
{
	/**
	 * Returns the unique GameObjectRef2 that stores a reference to this GameObject.
	 */
	public final function get ref () :GameObjectRef2
	{
		return _ref;
	}
	
	/**
	 * Returns the ObjectDB that this object is contained in.
	 */
	public final function get db () :ObjectDB2
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
	
	/** Removes the GameObject from its parent database. */
	public function destroySelf () :void
	{
		_parentDB.destroyObject(_ref);
	}
	/**
	 * Causes the lifecycle of the given GameObject to be managed by this object. Dependent
	 * objects will be added to this object's ObjectDB, and will be destroyed when this
	 * object is destroyed.
	 */
	public function addDependentObject (obj :GameObject2) :void
	{
		if (_parentDB != null) {
			addDependentToDB(obj, false, null, 0);
		} else {
			_pendingDependentObjects.push(new PendingDependentObject(obj, false, null, 0));
		}
	}
	
	/**
	 * Causes the lifecycle of the given GameObject to be managed by this object. Dependent
	 * objects will be added to this object's ObjectDB, and will be destroyed when this
	 * object is destroyed.
	 */
	public function addDependentSceneObject (obj :GameObject2,
											 displayParent :DisplayObjectContainer = null, displayIdx :int = -1) :void
	{
		if (_parentDB != null) {
			addDependentToDB(obj, true, displayParent, displayIdx);
		} else {
			_pendingDependentObjects.push(
				new PendingDependentObject(obj, true, displayParent, displayIdx));
		}
	}
	
	/**
	 * Adds the specified listener to the specified dispatcher for the specified event.
	 *
	 * Listeners registered in this way will be automatically unregistered when the GameObject is
	 * destroyed.
	 */
	protected function registerListener (dispatcher :IEventDispatcher, event :String,
										 listener :Function, useCapture :Boolean = false, priority :int = 0) :void
	{
		_events.registerListener(dispatcher, event, listener, useCapture, priority);
	}
	
	/**
	 * Removes the specified listener from the specified dispatcher for the specified event.
	 */
	protected function unregisterListener (dispatcher :IEventDispatcher, event :String,
										   listener :Function, useCapture :Boolean = false) :void
	{
		_events.unregisterListener(dispatcher, event, listener, useCapture);
	}
	
	/**
	 * Registers a zero-arg callback function that should be called once when the event fires.
	 *
	 * Listeners registered in this way will be automatically unregistered when the GameObject is
	 * destroyed.
	 */
	protected function registerOneShotCallback (dispatcher :IEventDispatcher, event :String,
												callback :Function, useCapture :Boolean = false, priority :int = 0) :void
	{
		_events.registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
	}
	
	/**
	 * Called immediately after the GameObject has been added to an ObjectDB.
	 * (Subclasses can override this to do something useful.)
	 */
	protected function addedToDB () :void
	{
	}
	
	/**
	 * Called immediately after the GameObject has been removed from an AppMode.
	 *
	 * removedFromDB is not called when the GameObject's AppMode is removed from the mode stack.
	 * For logic that must be run in this instance, see {@link #destroyed}.
	 *
	 * (Subclasses can override this to do something useful.)
	 */
	protected function removedFromDB () :void
	{
	}
	
	/**
	 * Called after the GameObject has been removed from the active AppMode, or if the
	 * object's containing AppMode is removed from the mode stack.
	 *
	 * If the GameObject is removed from the active AppMode, {@link #removedFromDB}
	 * will be called before destroyed.
	 *
	 * destroyed should be used for logic that must be always be run when the GameObject is
	 * destroyed (disconnecting event listeners, releasing resources, etc).
	 *
	 * (Subclasses can override this to do something useful.)
	 */
	protected function destroyed () :void
	{
	}
	
	/**
	 * Called to deliver a message to the object.
	 * (Subclasses can override this to do something useful.)
	 */
	protected function receiveMessage (msg :ObjectMessage) :void
	{
		
	}
	
	internal function addedToDBInternal () :void
	{
		for each (var dep :PendingDependentObject in _pendingDependentObjects) {
			addDependentToDB(dep.obj, dep.isSceneObject, dep.displayParent, dep.displayIdx);
		}
		_pendingDependentObjects = null;
		addedToDB();
	}
	
	internal function addDependentToDB (obj :GameObject2, isSceneObject :Boolean,
										displayParent :DisplayObjectContainer, displayIdx :int) :void
	{
		var ref :GameObjectRef2;
//		if (isSceneObject) {
//			if (!(_parentDB is AppMode)) {
//				throw new Error("can't add SceneObject to non-AppMode ObjectDB");
//			}
//			ref = AppMode(_parentDB).addSceneObject(obj, displayParent, displayIdx);
//		} else {
			ref = _parentDB.addObject(obj);
//		}
		_dependentObjectRefs.push(ref);
	}
	
	internal function removedFromDBInternal () :void
	{
		for each (var ref :GameObjectRef2 in _dependentObjectRefs) {
			if (ref.isLive) {
				ref.object.destroySelf();
			}
		}
		removedFromDB();
	}
	
	internal function destroyedInternal () :void
	{
		destroyed();
		_events.freeAllHandlers();
	}
	
	internal function receiveMessageInternal (msg :ObjectMessage) :void
	{
		receiveMessage(msg);
	}
	
	protected var _events :EventHandlerManager = new EventHandlerManager();
	
	protected var _dependentObjectRefs :Array = [];
	protected var _pendingDependentObjects :Array = [];
	
	// managed by ObjectDB/AppMode
	internal var _ref :GameObjectRef2;
	internal var _parentDB :ObjectDB2;
}

}

import flash.display.DisplayObjectContainer;
import com.threerings.flashbang.GameObject2;

class PendingDependentObject
{
	public var obj :GameObject2;
	public var isSceneObject :Boolean;
	public var displayParent :DisplayObjectContainer;
	public var displayIdx :int;
	
	public function PendingDependentObject (obj :GameObject2, isSceneObject :Boolean,
											displayParent :DisplayObjectContainer, displayIdx :int)
	{
		this.obj = obj;
		this.isSceneObject = isSceneObject;
		this.displayParent = displayParent;
		this.displayIdx = displayIdx;
	}
}
