/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.threerings.flashbang.pushbutton.box2d {
import com.pblabs.engine.entity.EntityComponent;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.threerings.flashbang.Updatable;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import Box2D.Collision.b2AABB;
import Box2D.Common.Math.b2Vec2;
import Box2D.Dynamics.b2Body;
import Box2D.Dynamics.b2BodyDef;
import Box2D.Dynamics.b2DebugDraw;
import Box2D.Dynamics.b2World;
public class Box2DManagerComponent extends EntityComponent
    implements Updatable//, ISpatialManager2D
{
    [EditorData(defaultValue="true")]
    public function get allowSleep () :Boolean
    {
        return _allowSleep;
    }

    public function set allowSleep (value :Boolean) :void
    {
        if (_world) {
            log.warning(this, "AllowSleep",
                "This property cannot be changed once the world has been created!");
            return;
        }

        _allowSleep = value;
    }

    [EditorData(defaultValue="9.81")]
    public function get gravity () :Point
    {
        return _gravity;
    }

    public function set gravity (value :Point) :void
    {
        _gravity = value;

        if (_world)
            _world.SetGravity(new b2Vec2(value.x, value.y));
    }

    public function get inverseScale () :Number
    {
        return 1 / _scale;
    }

    [EditorData(defaultValue="30")]
    public function get scale () :Number
    {
        return _scale;
    }

    public function set scale (value :Number) :void
    {
        _scale = value;
    }

    [EditorData(defaultValue="-10000|-10000|20000|20000")]
    public function get worldBounds () :Rectangle
    {
        return _worldBounds;
    }

    public function set worldBounds (value :Rectangle) :void
    {
        if (_world) {
            log.warning(this, "WorldBounds",
                "This property cannot be changed once the world has been created!");
            return;
        }

        _worldBounds = value;
    }

    public function add (bodyDef :b2BodyDef, thisArg :* = null, completedCallback :Function =
        null) :void
    {
        if (!_world) {
            throw new Error("World not initialized.");
        }

        var body :b2Body = _world.CreateBody(bodyDef);
        if (completedCallback != null)
            completedCallback.apply(thisArg, [ body ]);
    }

//    public function addSpatialObject (object :ISpatialObject2D) :void
//    {
//        _otherItems.addSpatialObject(object);
//    }
//
//    public function castRay (start :Point, end :Point, mask :ObjectType,
//        result :RayHitInfo) :Boolean
//    {
//        return _otherItems.castRay(start, end, mask, result);
//    }

//    /**
//     * @inheritDoc
//     */
//    public function objectsUnderPoint (point :Point, mask :ObjectType, results :Array,
//        scene :IScene2D) :Boolean
//    {
//        var tmpResults :Array = new Array();
//
//        // First use the normal spatial query...
//        if (!queryCircle(point, 0.01, mask, tmpResults))
//            return false;
//
//        // Ok, now pass control to the objects and see what they think.
//        var hitAny :Boolean = false;
//        for each (var tmp :ISpatialObject2D in tmpResults) {
//            if (!tmp.pointOccupied(point, scene))
//                continue;
//
//            results.push(tmp);
//            hitAny = true;
//        }
//
//        return hitAny;
//    }

//    public function onInterpolateTick (factor :Number) :void
//    {
//    }

//    public function queryRectangle (box :Rectangle, mask :ObjectType, results :Array) :Boolean
//    {
//        // Query Box2D.
//        var aabb :b2AABB = new b2AABB();
//        aabb.lowerBound = b2Vec2.Make(box.topLeft.x / scale, box.topLeft.y / scale);
//        aabb.upperBound = b2Vec2.Make(box.bottomRight.x / scale, box.bottomRight.y / scale);
//
//        var resultShapes :Array = new Array(1024);
//        if (_world.Query(aabb, resultShapes, 1024) == 0)
//            return false;
//
//        // Now get the owning components back from the results and give to user.
//        for (var i :int = 0; i < 1024; i++) {
//            if (!resultShapes[i])
//                break;
//
//            var curShape :b2Shape = resultShapes[i] as b2Shape;
//            var curComponent :Box2DSpatialComponent =
//                curShape.GetBody().GetUserData() as Box2DSpatialComponent;
//            if (ObjectTypeManager.instance.doTypesOverlap(curComponent.collisionType, mask))
//                results.push(curComponent);
//        }
//
//        // Let the other items have a turn.
//        i += _otherItems.queryRectangle(box, mask, results) ? 1 : 0;
//
//        // If we made it anywhere with i, then we got a result.
//        return (i != 0);
//    }
//
//    public function queryCircle (center :Point, radius :Number, mask :ObjectType,
//        results :Array) :Boolean
//    {
//        return _otherItems.queryCircle(center, radius, mask, results);
//    }

    public function remove (body :b2Body) :void
    {
        if (_world != null) {
            _world.DestroyBody(body);
        }
    }

//    public function removeSpatialObject (object :ISpatialObject2D) :void
//    {
//        _otherItems.removeSpatialObject(object);
//    }

    public function setDebugDrawer (drawer :b2DebugDraw) :void
    {
        drawer.SetDrawScale(_scale);
        _world.SetDebugDraw(drawer);
    }

    public function traceWorld () :void
    {
        var body :b2Body = _world.GetBodyList();
        var ii :int = 1;
        while (body) {
            trace((ii++) + " " +  body.GetPosition().x, body.GetPosition().y);
            var next :b2Body = body.GetNext();
            body = next;
        }
    }

    public function update (dt :Number) :void
    {
        _world.Step(dt, 10, 10);
//        traceWorld();
    }

    override protected function onAdd () :void
    {
        super.onAdd();
        createWorld();

        //Get all the existing components and add them to us.
//        for each (var comp :Box2DSpatialComponent in
//            db.getComponentsOfType(Box2DSpatialComponent)) {
//
//            if (comp.managerEntityName == name && comp.manager == null) {
//                comp.manager = this;
//            }
//        }
    }

    override protected function onRemove () :void
    {
        super.onRemove();
        var body :b2Body = _world.GetBodyList();
        while (body) {
            var next :b2Body = body.GetNext();
            _world.DestroyBody(body);
            body = next;
        }

        _world = null;
//        _events.freeAllHandlers();
    }
    protected var _allowSleep :Boolean = true;
//    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _gravity :Point = new Point(0, 9.81);

    // Used to store other world objects that aren't implemented by Box2D.
//    protected var _otherItems :BasicSpatialManager2D = new BasicSpatialManager2D();
    protected var _scale :Number = 30;
    protected var _world :b2World = null;
    protected var _worldBounds :Rectangle = new Rectangle(-5000, -5000, 10000, 10000);

    protected static const log :Log = Log.getLog(Box2DManagerComponent);

    private function createWorld () :void
    {
        var bounds :b2AABB = new b2AABB();
        bounds.lowerBound.Set(_worldBounds.x / _scale, _worldBounds.y / _scale);
        bounds.upperBound.Set((_worldBounds.x + _worldBounds.width) / _scale,
            (_worldBounds.y + _worldBounds.height) / _scale);
        _world = new b2World(new b2Vec2(_gravity.x, _gravity.y), _allowSleep);
        _world.SetContactFilter(new ContactFilter());
        _world.SetContactListener(new ContactListener());
    }
}
}
