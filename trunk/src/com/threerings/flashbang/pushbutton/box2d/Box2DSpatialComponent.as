/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.threerings.flashbang.pushbutton.box2d {
import Box2D.Collision.Shapes.b2CircleShape;
import Box2D.Collision.Shapes.b2MassData;
import Box2D.Common.Math.b2Vec2;
import Box2D.Dynamics.b2Body;
import Box2D.Dynamics.b2BodyDef;
import Box2D.Dynamics.b2FixtureDef;

import com.pblabs.engine.core.ObjectType;
import com.pblabs.engine.entity.EntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.util.Log;
import com.threerings.util.MathUtil;

import flash.geom.Point;

import physicsSim.box2d.B2Util;

public class Box2DSpatialComponent extends EntityComponent
{
    public function get manager () :Box2DManagerComponent
    {
        return _manager;
    }

    public function set manager (value :Box2DManagerComponent) :void
    {
        log.debug("set manager=" + value);
        if (_body) {
            log.warning(this, "set Manager",
                "The manager can only be set before the component is registered.");
            return;
        }

        _manager = value;

        _bodyDef.position.Multiply(_manager.inverseScale);
        _manager.add(_bodyDef, this, function (body :b2Body) :void {
                _body = body;
                _body.SetUserData(this);
                _bodyDef.position.Multiply(_manager.scale);

                linearVelocity = _linearVelocity;
                angularVelocity = _angularVelocity;

//                buildCollisionShapes();
            });
    }

    public function get body () :b2Body
    {
        return _body;
    }

    public function get collisionType () :ObjectType
    {
        return _collisionType;
    }

    public function set collisionType (value :ObjectType) :void
    {
        _collisionType = value;

//        if (_body)
//            buildCollisionShapes();
    }

    public function get collidesWithTypes () :ObjectType
    {
        return _collidesWithTypes;
    }

    public function set collidesWithTypes (value :ObjectType) :void
    {
        _collidesWithTypes = value;

//        if (_body)
//            buildCollisionShapes();
    }

    public function get position () :Point
    {
        if (_body) {
            var pos :b2Vec2 = _body.GetPosition();
            return new Point(pos.x * _manager.scale, pos.y * _manager.scale);
        }

        return new Point(_bodyDef.position.x, _bodyDef.position.y);
    }

    public function set position (value :Point) :void
    {
        _body.SetPosition(B2Util.pointToB2Vec(value));
        var position :b2Vec2 = new b2Vec2(value.x, value.y);
        _bodyDef.position = position;

        if (_body) {
            position.Multiply(_manager.inverseScale);
            _body.SetPosition(position);
        }
    }

    public function get rotation () :Number
    {
        var rotation :Number = _bodyDef.angle;

        if (_body) {
            rotation = _body.GetAngle();
        }

        return MathUtil.toDegrees(rotation);
    }

    public function set rotation (value :Number) :void
    {
        var rotation :Number = MathUtil.toRadians(value);
        _bodyDef.angle = rotation;

        if (_body) {
            _body.SetAngle(rotation);
        }
    }

    [EditorData(defaultValue="100|100")]
    public function get size () :Point
    {
        return _size;
    }

    public function set size (value :Point) :void
    {
        _size = value;

//        if (_body) {
//            buildCollisionShapes();
//        }
    }

    public function get linearVelocity () :Point
    {
        if (_body) {
            var velocity :b2Vec2 = _body.GetLinearVelocity();
            _linearVelocity.x = velocity.x * _manager.scale;
            _linearVelocity.y = velocity.y * _manager.scale;
        }

        return _linearVelocity;
    }

    public function set linearVelocity (value :Point) :void
    {
        _linearVelocity = value;

        if (_body) {
            var velocity :b2Vec2 = new b2Vec2(value.x * _manager.inverseScale,
                value.y * _manager.inverseScale);
            _body.SetLinearVelocity(velocity);
        }
    }

    public function get angularVelocity () :Number
    {
        if (_body) {
            var velocity :Number = _body.GetAngularVelocity();
            _angularVelocity = MathUtil.toDegrees(velocity);
        }

        return _angularVelocity;
    }

    public function set angularVelocity (value :Number) :void
    {
        _angularVelocity = value;

        if (_body) {
            var velocity :Number = MathUtil.toRadians(value);
            _body.SetAngularVelocity(velocity);
        }
    }

    [EditorData(defaultValue="true")]
    public function get canMove () :Boolean
    {
        return _canMove;
    }

    public function set canMove (value :Boolean) :void
    {
        _canMove = value;

        if (_body) {
            updateMass();
        }
    }

    [EditorData(defaultValue="true")]
    public function get canRotate () :Boolean
    {
        return _canRotate;
    }

    public function set canRotate (value :Boolean) :void
    {
        _canRotate = value;

        if (_body) {
            updateMass();
        }
    }

    [EditorData(defaultValue="true")]
    public function get canSleep () :Boolean
    {
        return _canSleep;
    }

    public function set canSleep (value :Boolean) :void
    {
        _canSleep = value;
        _bodyDef.allowSleep = value;
        if (_body) {
            _body.AllowSleeping(value);
        }
    }

    public function get collidesContinuously () :Boolean
    {
        if (_body) {
            return _body.IsBullet();
        }

        return _bodyDef.isBullet
    }

    public function set collidesContinuously (value :Boolean) :void
    {
        _bodyDef.isBullet = value;
        if (_body) {
            _body.SetBullet(value);
        }
    }

    [TypeHint(type="com.pblabs.box2D.CollisionShape")]
    public function get collisionShapes () :Array
    {
        return _collisionShapes;
    }

    public function set collisionShapes (value :Array) :void
    {
        _collisionShapes = value;
        if (_body) {
            buildCollisionShapes();
        }
    }

    public function buildCollisionShapes () :void
    {
//        if (!_body) {
//            log.warning(this, "buildCollisionShapes",
//                "Cannot build collision shapes prior to registration.");
//            return;
//        }
//
//        var shape :b2Shape = _body.GetShapeList();
//        while (shape) {
//            var nextShape :b2Shape = shape.m_next;
//            _body.DestroyShape(shape);
//            shape = nextShape;
//        }
//
//        if (_collisionShapes) {
//            for each (var newShape :CollisionShape in _collisionShapes)
//                _body.CreateShape(newShape.createShape(this));
//        }

        updateMass();
    }

    public function updateMass () :void
    {
        var massData :b2MassData = new b2MassData();
        massData.mass = 10;
        _body.SetMassData(massData);
//        _body.SetMassFromShapes();
//        if (!_canMove || !_canRotate) {
//            var mass :b2MassData = new b2MassData();
//            mass.center = _body.GetLocalCenter();
//            if (_canMove)
//                mass.mass = _body.GetMass();
//            else
//                mass.mass = 0;
//
//            if (_canRotate)
//                mass.I = _body.GetInertia();
//            else
//                mass.I = 0;
//
//            _body.SetMass(mass);
//        }
    }

    override protected function onAdd () :void
    {
        super.onAdd();

        var circDef :b2CircleShape = new b2CircleShape(10);
        var fd :b2FixtureDef = new b2FixtureDef();
        fd.shape = circDef;
        fd.density = 1.0;
        // Override the default friction.
        fd.friction = 0.9;
        fd.restitution = 0.1;

        //When we're added, look for the Box2D manager

        var managerComponent :Box2DManagerComponent = owner.getProperty(managerReference)
            as Box2DManagerComponent;
//            owner.getProperty(new PropertyReference("#" + managerEntityName + "." +
//            managerComponentName)) as Box2DManagerComponent;
        if (null != managerComponent) {
            trace("adding myself to the Box2DManagerComponent");
            manager = managerComponent;
            _body.CreateFixture(fd);
        }
        if (!_manager) {
            log.warning(this, "onAdd",
                "A Box2DSpatialComponent cannot be registered without a manager.");
            return;
        }

    }

//    protected function setManager (manager :Box2DManagerComponent) :void
//    {
//        _manager = manager;
//        _bodyDef.position.Multiply(_manager.inverseScale);
//        _manager.add(_bodyDef, this, function (body :b2Body) :void {
//                _body = body;
//                _body.SetUserData(this);
//                _bodyDef.position.Multiply(_manager.scale);
//
//                linearVelocity = _linearVelocity;
//                angularVelocity = _angularVelocity;
//
//                buildCollisionShapes();
//            });
//    }

//    protected function handleEntityAdded (e :ValueEvent) :void
//    {
//        if (e.value is Box2DManagerComponent) {
//            GameObjectEntity(owner).db.removeEventListener(EntityAppmode.OBJECT_ADDED,
//                handleEntityAdded);
//            manager = e.value as Box2DManagerComponent;
//        }
//    }

    override protected function onRemove () :void
    {
        super.onRemove();
        _manager.remove(_body);
        _body = null;
    }

    private var _manager :Box2DManagerComponent = null;

    public var managerReference :PropertyReference;
    private var _collisionType :ObjectType = null;
    private var _collidesWithTypes :ObjectType = null;

    private var _size :Point = new Point(10, 10);

    private var _canMove :Boolean = true;
    private var _canRotate :Boolean = true;

    private var _linearVelocity :Point = new Point(0, 0);
    private var _angularVelocity :Number = 0.0;
    private var _canSleep :Boolean = true;

    private var _collisionShapes :Array = null;
    private var _collidesContinuously :Boolean = false;

    private var _body :b2Body = null;
    private var _bodyDef :b2BodyDef = new b2BodyDef();

    protected static const log :Log = Log.getLog(Box2DSpatialComponent);
}
}