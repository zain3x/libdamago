//
// $Id: AVRGameControlFake.as 2466 2009-06-10 18:19:11Z nathan $
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.threerings.whirled.contrib.avrg.debug.fakeavrg {

import com.whirled.ServerObject;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AgentSubControl;
import com.whirled.avrg.GameSubControlClient;
import com.whirled.avrg.LocalSubControl;
import com.whirled.avrg.PlayerSubControlClient;
import com.whirled.avrg.RoomSubControlClient;

import flash.display.DisplayObject;

public class AVRGameControlFake extends AVRGameControl
{
    public function AVRGameControlFake (disp :DisplayObject)
    {
        super(disp);

        if (disp is ServerObject) {
            throw new Error("AVRGameControl should not be instantiated with a ServerObject");
        }

        // set up the default hitPointTester
        _local.setHitPointTester(disp.root.hitTestPoint);

        FakeAVRGContext.server.addPlayer(this);
    }

    /**
    * We are always connected when fake.
    */
    override public function isConnected() :Boolean
    {
        return true;
    }

    override public function get game () :GameSubControlClient
    {
        return _game;
    }

    /**
     * Accesses the client's room sub control for the player's current room.
     */
    override public function get room () :RoomSubControlClient
    {
        return _room;
    }

    /**
     * Accesses the client's local player sub control.
     */
    override public function get player () :PlayerSubControlClient
    {
        return _player;
    }

    /**
     * Accesses the client's local sub control.
     */
    override public function get local () :LocalSubControl
    {
        return _local;
    }

    /**
     * Accesses the client's agent sub control.
     */
    override public function get agent () :AgentSubControl
    {
        return _agent;
    }

    override protected function createSubControls () :Array
    {
        return [
            _game = new GameSubControlClientFake(this),
            _room = new RoomSubControlClientFake(this),
            _player = new PlayerSubControlClientFake(this),
            _local = new LocalSubControlFake(this),
            _agent = new AgentSubControlFake(this),
        ];
    }

    override protected function requestMobSprite_v1 (id :String) :DisplayObject
    {
        return null;
    }

    internal function leftRoom_v1 (scene :int) :void
    {
    }

    internal function enteredRoom_v1 (scene :int) :void
    {
    }
}
}

import flash.display.DisplayObject;

import com.whirled.avrg.MobSubControlClient;

class MobEntry
{
    public var control :MobSubControlClient;

    public function MobEntry (control :MobSubControlClient, sprite :DisplayObject)
    {
        this.control = control;
    }
}
