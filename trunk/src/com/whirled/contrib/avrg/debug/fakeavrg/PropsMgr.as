//
// $Id: PropsMgr.as 4934 2009-09-04 17:47:44Z tim $

package com.whirled.contrib.avrg.debug.fakeavrg{

import com.threerings.com.threerings.util.ArrayUtil;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.whirled.AbstractControl;
import com.whirled.net.PropertySubControl;

public class PropsMgr
{
    public static function gamePropSpace () :String
    {
        return "Game";
    }

    public static function playerPropSpace (playerId :int) :String
    {
        return "Player_" + playerId;
    }

    public static function roomPropSpace (roomId :int) :String
    {
        return "Room_" + roomId;
    }

    public static function createPropCtrl (parent :AbstractControl, propSpaceName :String)
        :PropertySubControl
    {
        var propSpace :Array = getPropSpace(propSpaceName);
        var ctrl :PropSpaceControl = new PropSpaceControl(parent, propSpace);
        if (propSpace.length > 0) {
            ctrl.populateWith(propSpace[0]);
        }
        propSpace.push(ctrl);
        return ctrl;
    }

    public static function destroyPropCtrl (ctrl :PropertySubControl) :void
    {
        var spaceCtrl :PropSpaceControl = PropSpaceControl(ctrl);
        ArrayUtil.removeFirst(spaceCtrl.propSpace, spaceCtrl);
    }

    protected static function getPropSpace (name :String) :Array
    {
        var propSpace :Array = _propSpaces.get(name);
        if (propSpace == null) {
            propSpace = [];
            _propSpaces.put(name, propSpace);
        }

        return propSpace;
    }

    // Map<propSpaceName, Array<PropSpaceControl> >
    protected static var _propSpaces :Map = Maps.newMapOf(String);
}

}

import com.threerings.com.threerings.util.ArrayUtil;
import com.threerings.util.MethodQueue;
import com.whirled.net.PropertySubControl;
import com.threerings.util.Integer;
import com.whirled.game.client.PropertySpaceHelper;
import flash.events.EventDispatcher;
import com.whirled.net.ElementChangedEvent;
import com.whirled.AbstractSubControl;
import flash.display.DisplayObject;
import com.whirled.AbstractControl;
import com.whirled.net.PropertyChangedEvent;
import flash.events.IEventDispatcher;
import flash.events.Event;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.whirled.contrib.avrg.debug.fakeavrg.LocalPropertySubControl;

class PropSpaceControl extends AbstractSubControl
    implements PropertySubControl
{
    public function PropSpaceControl (parent :AbstractControl, propSpace :Array)
    {
        super(parent);
        _propSpace = propSpace;

        _props = new LocalPropertySubControl();
        redispatch(_props, PropertyChangedEvent.PROPERTY_CHANGED);
        redispatch(_props, ElementChangedEvent.ELEMENT_CHANGED);
    }

    protected function redispatch (dispatcher :IEventDispatcher, type :String) :void
    {
        dispatcher.addEventListener(type,
            function (e :Event) :void {
                dispatchEvent(e);
            });
    }

    public function populateWith (ctrl :PropSpaceControl) :void
    {
        var newProps :Map = Maps.newMapOf(Object);
        ctrl._props.rawProps.forEach(
            function (key :Object, value :Object) :void {
                var encoded :Object = PropertySpaceHelper.encodeProperty(value, true);
                var decoded :Object = PropertySpaceHelper.decodeProperty(encoded);
                newProps.put(key, decoded);
            });

        _props.rawProps = newProps;
    }

    public function set (propName :String, value :Object, immediate :Boolean = false) :void
    {
        deliverPropChange(propName, value, null, false, immediate);
    }

    public function setAt (propName :String, index :int, value :Object,
        immediate :Boolean = false) :void
    {
        deliverPropChange(propName, value, index, true, immediate);
    }

    public function setIn (propName :String, key :int, value :Object,
        immediate :Boolean = false) :void
    {
        deliverPropChange(propName, value, key, false, immediate);
    }

    public function get (propName :String) :Object
    {
        return _props.get(propName);
    }

    public function getPropertyNames (prefix :String = "") :Array
    {
        return _props.getPropertyNames(prefix);
    }

    public function getTargetId () :int
    {
        return 0;
    }

    override public function doBatch (fn :Function, ...args) :void
    {
        fn.apply(null, args);
    }

    public function get propSpace () :Array
    {
        return _propSpace;
    }

    protected function deliverPropChange (propName :String, value :Object, key :Object,
        isArray :Boolean, immediate :Boolean) :void
    {
        var encoded :Object = PropertySpaceHelper.encodeProperty(value, (key == null));
        if (immediate) {
            setProperty(propName, encoded, key, isArray);
        }

        var self :PropSpaceControl = this;
        var f :Function = function () :void {
            for each (var ctrl :PropSpaceControl in _propSpace) {
                if (!immediate || ctrl != self) {
                    ctrl.setProperty(propName, encoded, key, isArray);
                }
            }
        };

        MethodQueue.callLater(f);
    }

    protected function setProperty (propName :String, encoded :Object, key :Object,
        isArray :Boolean) :void
    {
        try {
            var decoded :Object = PropertySpaceHelper.decodeProperty(encoded);
            if (key == null) {
                _props.set(propName, decoded, true);
            } else if (isArray) {
                _props.setAt(propName, int(key), decoded, true);
            } else {
                _props.setIn(propName, int(key), decoded, true);
            }

        } catch (re :RangeError) {
            trace("Error setting property: " + re);
        }
    }

    protected var _props :LocalPropertySubControl;
    protected var _propSpace :Array;
}
