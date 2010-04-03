/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 *
 * This is an copy of Machine.as from PushButton Labs, adapted for Three Rings Flashbang.
 *
 ******************************************************************************/
package com.threerings.flashbang.pushbutton.stateMachine {
import com.pblabs.components.stateMachine.IMachine;
import com.pblabs.components.stateMachine.IState;
import com.pblabs.components.stateMachine.TransitionEvent;
import com.pblabs.engine.entity.IPropertyBag;
import com.threerings.util.DebugUtil;
import com.threerings.util.Log;

import flash.utils.Dictionary;

/**
 * Implementation of IMachine; probably any custom FSM would be based on this.
 *
 * @see IMachine for API docs.
 */
public class Machine implements IMachine
{

    /**
     * What state will we start out in?
     */
    public var defaultState :String = null;
    /**
     * Set of states, indexed by name.
     */
    public var states :Dictionary = new Dictionary();

    public function get currentState () :IState
    {
        return getCurrentState();
    }

    public function get currentStateName () :String
    {
        return getStateName(getCurrentState());
    }

    public function set currentStateName (value :String) :void
    {
        if (!setCurrentState(value)) {
            log.warning(this, "set currentStateName",
                "Could not transition to state '" + value + "'");
        }
    }

    /**
     * Virtual time at which we entered the state.
     */
    public function get enteredStateTime () :Number
    {
        return _enteredStateTime;
    }

    public function get propertyBag () :IPropertyBag
    {
        return _propertyBag;
    }

    public function set propertyBag (value :IPropertyBag) :void
    {
        _propertyBag = value;
    }

    public function addState (name :String, state :IState) :void
    {
        states[name] = state;
    }

    public function getCurrentState () :IState
    {
        // DefaultState - we get it if no state is set.
        if (_currentState == null) {
            setCurrentState(defaultState);
        }

        return _currentState;
    }

    public function getPreviousState () :IState
    {
        return _previousState;
    }

    public function getState (name :String) :IState
    {
        return states[name] as IState;
    }

    public function getStateName (state :IState) :String
    {
        for (var name :String in states) {
            if (states[name] == state) {
                return name;
            }
        }

        return null;
    }

    public function setCurrentState (name :String) :Boolean
    {
        var newState :IState = getState(name);
        if (newState == null) {
            return false;
        }

        var oldState :IState = _currentState;
        _setNewState = true;

        _previousState = _currentState;
        _currentState = newState;

        // Old state gets notified it is changing out.
        if (oldState != null) {
            oldState.exit(this);
        }

        // New state finds out it is coming in.
        newState.enter(this);

        // Fire a transition event, if we have a dispatcher.
        if (_propertyBag != null) {
            var te :TransitionEvent = new TransitionEvent(TransitionEvent.TRANSITION);
            te.oldState = oldState;
            te.oldStateName = getStateName(oldState);
            te.newState = newState;
            te.newStateName = getStateName(newState);

            _propertyBag.eventDispatcher.dispatchEvent(te);
        }

        return true;
    }

    public function tick () :void
    {
        _setNewState = false;

        // DefaultState - we get it if no state is set.
        if (_currentState == null) {
            setCurrentState(defaultState);
        }

        if (_currentState != null) {
            _currentState.tick(this);
        }

        // If didn't set a new state, it counts as transitioning to the
        // current state. This updates prev/current state so we can tell
        // if we just transitioned into our current state.
        if (_setNewState == false && _currentState != null) {
            _previousState = _currentState;
        }
    }

    protected var _currentState :IState = null;
    protected var _enteredStateTime :Number = 0;
    protected var _previousState :IState = null;

    protected var _propertyBag :IPropertyBag = null;
    protected var _setNewState :Boolean = false;

    protected static const log :Log = Log.getLog(Machine);
}
}