package com.threerings.flashbang.pushbutton.scene {
import com.pblabs.engine.core.IAnimatedObject;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.flashbang.components.SceneComponent;
import com.threerings.util.ClassUtil;
import com.threerings.util.F;
import com.threerings.util.Log;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

import net.amago.pbe.base.EntityComponentListener;

//For displaying IEntitys in Scenes
public class SceneEntityComponent extends EntityComponentListener
    implements SceneComponent, IAnimatedObject
{
    public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(SceneEntityComponent);

    public static function getFrom (e :IEntity) :SceneEntityComponent
    {
        return e.lookupComponentByName(COMPONENT_NAME) as SceneEntityComponent;
    }

    /**
     * If set, alpha is gotten from this property every frame.
     */
    public var alphaProperty :PropertyReference;

    public var autoAttach :Boolean = true;

    public var displayObjectRef :PropertyReference;


    /**
     * If set, the layer index is gotten from this property every frame.
     */
//    public var layerNameProperty :PropertyReference;

    /**
     * If set, position is gotten from this property every frame.
     */
    public var positionProperty :PropertyReference;

    /**
     * If set, rotation is gotten from this property every frame.
     */
    public var rotationProperty :PropertyReference;
    public var scaleXRef :PropertyReference;
    public var scaleYRef :PropertyReference;

    protected var _sceneLayerName :String;
    public var sceneRef :PropertyReference;

    public var updateOnEvents :Array = [];

    public var xProperty :PropertyReference;
    public var yProperty :PropertyReference;


    /**
     * If set, scale is gotten from this property every frame.
     */
    //    public var scaleProperty :PropertyReference;

    /**
     * If set, our z-index is gotten from this property every frame.
     */
    public var zIndexProperty :PropertyReference;

    public function SceneEntityComponent (displayObject :DisplayObject = null)
    {
        super();
        _displayObject = displayObject;
    }



    public function get alpha () :Number
    {
        return _alpha;
    }

    /**
     * Transparency, 0 being completely transparent and 1 being opaque.
     */
    public function set alpha (value :Number) :void
    {
//		displayObject.alpha = value;
        if (value == _alpha)
            return;

        _alpha = value;
        _transformDirty = true;
    }

    public function get displayObject () :DisplayObject
    {
        return _displayObject;
    }

//    /**
//     * The displayObject which this DisplayObjectRenderer will draw.
//     */
//    public function set displayObject (value :DisplayObject) :void
//    {
//        var previousDisp :DisplayObject = _displayObject;
//        _displayObject = value;
//
//        // Remove old object from scene.
//        if (_scene && _displayObject != previousDisp) {
//            _scene.removeSceneComponent(this);
//            _scene.addSceneComponent(this);
//            _lastLayerIndex = _layerIndex;
//            _layerIndexDirty = _zIndexDirty = false;
//        }
//    }

    public function get isDirty () :Boolean
    {
        return _isDirty;
    }

    override public function get name () :String
    {
        return COMPONENT_NAME;
    }

    //    public function get layerIndex () :int
    //    {
    //        return _layerIndex;
    //    }

    //    /**
    //     * In what layer of the scene is this renderer drawn?
    //     */
    //    public function set layerIndex (value :int) :void
    //    {
    //        if (_layerIndex == value)
    //            return;
    //
    //        _layerIndex = value;
    //        _layerIndexDirty = true;
    //    }

    //    /**
    //     * @return Bounds in object space, relative to its local origin.
    //     */
    //    public function get localBounds () :Rectangle
    //    {
    //        if (!displayObject)
    //            return null;
    //
    //        return displayObject.getBounds(displayObject);
    //    }

    //    public function get position () :Point
    //    {
    //        return _position.clone();
    //    }

    /**
     * Position of the renderer in scene space.
     *
     * @see worldPosition
     */
    public function set position (value :Point) :void
    {
        x = value.x;
        y = value.y;

        //        var posX :Number;
        //        var posY :Number;
        //
        //        if (snapToNearestPixels) {
        //            posX = int(value.x);
        //            posY = int(value.y);
        //        } else {
        //            posX = value.x;
        //            posY = value.y;
        //        }
        //
        //        if (posX == _position.x && posY == _position.y)
        //            return;
        //
        //        _position.x = posX;
        //        _position.y = posY;
        //        _transformDirty = true;
    }

    public function get scaleX():Number
    {
        return _scaleX;
    }

    /**
     * You can scale things on the X and Y axes.
     */
    public function set scaleX (value:Number):void
    {
        if (value == _scaleX)
            return;

        _scaleX = value;
        _transformDirty = true;
    }

    public function get scaleY():Number
    {
        return _scaleY;
    }

    /**
     * You can scale things on the X and Y axes.
     */
    public function set scaleY (value:Number):void
    {
        if (value == _scaleY)
            return;

        _scaleY = value;
        _transformDirty = true;
    }

    //
    //    public function get registrationPoint () :Point
    //    {
    //        return _registrationPoint.clone();
    //    }

    //    /**
    //     * The registration point can be used to offset the sprite
    //     * so that rotation and scaling work properly.
    //     *
    //     * @param value Position of the "center" of the sprite.
    //     */
    //    public function set registrationPoint (value :Point) :void
    //    {
    //        var intX :int = int(value.x);
    //        var intY :int = int(value.y);
    //
    //        if (intX == _registrationPoint.x && intY == _registrationPoint.y)
    //            return;
    //
    //        _registrationPoint.x = intX;
    //        _registrationPoint.y = intY;
    //        _transformDirty = true;
    //    }
    //
    //    /**
    //     * Where in the scene will this object be rendered?
    //     */
    //    public function get renderPosition () :Point
    //    {
    //        return new Point(displayObject.x, displayObject.y);
    //    }
    //
    //    public function get rotation () :Number
    //    {
    //        return _rotation;
    //    }
    //
    //    /**
    //     * Rotation in degrees, with 0 being Y+.
    //     */
    //    public function set rotation (value :Number) :void
    //    {
    //        if (value == _rotation)
    //            return;
    //
    //        _rotation = value;
    //        _transformDirty = true;
    //    }
    //
    //    /**
    //     * Rotation offset applied to the child DisplayObject. Used if, for instance,
    //     * your art is rotated 90deg off from where you want it.
    //     *
    //     * @return Number Offset Rotation angle in degrees
    //     */
    //    public function get rotationOffset () :Number
    //    {
    //        return PBUtil.getDegreesFromRadians(_rotationOffset);
    //    }
    //
    //    /**
    //     * Rotation offset applied to the child DisplayObject.
    //     *
    //     * @param value Offset Rotation angle in degrees
    //     */
    //    public function set rotationOffset (value :Number) :void
    //    {
    //        _rotationOffset = PBUtil.unwrapRadian(PBUtil.getRadiansFromDegrees(value));
    //    }
    //
    //    public function get scale () :Point
    //    {
    //        return _scale.clone();
    //    }
    //
    //    /**
    //     * You can scale things on the X and Y axes.
    //     */
    //    public function set scale (value :Point) :void
    //    {
    //        if (value.x == _scale.x && value.y == _scale.y)
    //            return;
    //
    //        _scale.x = value.x;
    //        _scale.y = value.y;
    //        _transformDirty = true;
    //    }

    public function get scene () :Scene2DComponent
    {
        return _scene;
    }

    public function set layer (val :String) :void
    {
        if (_sceneLayerName != val) {
            _sceneLayerName = val;
            if (isAttached) {
                detach();
                attach();
            }
        }
    }

    public function get layer () :String
    {
        return _sceneLayerName;
    }

    //    /**
    //     * The scene which is responsible for drawing this renderer. Note that
    //     * you can use the renderer outside of a scene, to control some
    //     * DisplayObject, by setting displayObject to point to what you want
    //     * to control, and setting scene to null.
    //     */
    //    public function set scene (value :Scene) :void
    //    {
    //        // Remove from old scene if appropriate.
    //        if (_scene && _displayObject)
    //            _scene.remove(this);
    //
    //        _scene = value;
    //
    //        // And add to new scene (clearing dirty state).
    //        if (_scene && _displayObject) {
    //            _scene.add(this);
    //            _lastLayerIndex = _layerIndex;
    //            _layerIndexDirty = _zIndexDirty = false;
    //        }
    //    }

    /**
     * Our bounds in scene coordinates.
     */
    public function get sceneBounds () :Rectangle
    {
        // NOP if no DO.
        if (!displayObject)
            return null;

        var bounds :Rectangle = displayObject.getBounds(displayObject);

        // Just translation for now.
        bounds.x += displayObject.x;
        bounds.y += displayObject.y;

        // And hand it back.
        return bounds;
    }

    public function get x () :Number
    {
        return _x;
    }

    public function set x (value :Number) :void
    {
        if (value == _x)
            return;

        _x = value;
        _transformDirty = true;
    }

    public function get y () :Number
    {
        return _y;
    }

    public function set y (value :Number) :void
    {
        if (value == _y)
            return;

        _y = value;
        _transformDirty = true;
    }

    //    public function get worldPosition () :Point
    //    {
    //        return scene.transformSceneToWorld(position);
    //    }

    //    /**
    //     * Convenience method to allow placing the renderer in world coordinates.
    //     */
    //    public function set worldPosition (value :Point) :void
    //    {
    //        scene.remove(this);
    //
    //        position = scene.transformWorldToScene(value);
    //        updateTransform();
    //
    //        scene.add(this);
    //    }

    //    /**
    //     * The x value of our scene space position.
    //     */
    //    public function get x () :Number
    //    {
    //        return _position.x;
    //    }
    //
    //    public function set x (value :Number) :void
    //    {
    //        var posX :Number;
    //
    //        if (snapToNearestPixels) {
    //            posX = int(value);
    //        } else {
    //            posX = value;
    //        }
    //
    //        if (posX == _position.x)
    //            return;
    //
    //        _position.x = posX;
    //        _transformDirty = true;
    //    }

    //    /**
    //     * The y component of our scene space position. Used for sorting.
    //     */
    //    public function get y () :Number
    //    {
    //        return _position.y;
    //    }
    //
    //    public function set y (value :Number) :void
    //    {
    //        var posY :Number;
    //
    //        if (snapToNearestPixels) {
    //            posY = int(value);
    //        } else {
    //            posY = value;
    //        }
    //
    //        if (posY == _position.y)
    //            return;
    //
    //        _position.y = posY;
    //        _transformDirty = true;
    //    }

    public function get zIndex () :int
    {
        return _zIndex;
    }

    /**
     * By default, layers are sorted based on the z-index, from small
     * to large.
     * @param value Z-index to set.
     */
    public function set zIndex (value :int) :void
    {
        if (_zIndex == value)
            return;

        _zIndex = value;
        _zIndexDirty = true;
    }

    public function attach () :void
    {
        if (_displayObject == null && displayObjectRef != null) {
            _displayObject = owner.getProperty(displayObjectRef) as DisplayObject;
        }

        updateFromEvent();
        var scene2D :Scene2DComponent = owner.getProperty(sceneRef) as Scene2DComponent;
        if (_scene == scene2D) {
            log.info("attach, already attached", "_scene", _scene, "scene2D", scene2D);
            return;
        }
        //Add ourselves to the scene
        if (scene2D != null) {
            scene2D.addSceneComponent(this);
        } else {
            log.warning("attach", "scene2D", scene2D);
        }
    }

    protected function get actualLayer () :SceneLayer
    {
        var scene2D :Scene2DComponent = owner.getProperty(sceneRef) as Scene2DComponent;
        if (_scene == null) {
            return null;
        }
        return scene2D.getLayerContaining(this);
    }

    public function detach () :void
    {
        if (_scene != null) {
            _scene.removeSceneComponent(this);
        }
    }

    public function get isAttached () :Boolean
    {
        if (owner == null) {
            return false;
        }
        var scene2D :Scene2DComponent = owner.getProperty(sceneRef) as Scene2DComponent;
        if (_scene == null) {
            return false;
        }
        return scene2D.containsComponent(this);
    }

    public function onFrame (dt :Number) :void
    {
        // Lookup and apply properties. This only makes adjustments to the
        // underlying DisplayObject if necessary.
        if (displayObject == null || displayObject.parent == null) {
            return;
        }


//		displayObject.scaleX = owner.getProperty(scaleXRefy, 1) as Number;
//		displayObject.scaleY = owner.getProperty(scaleYRef, 1) as Number;
//		displayObject.alpha = owner.getProperty(alphaProperty, 1) as Number;
//		displayObject.visible = (displayObject.alpha > 0);
//		displayObject.x = owner.getProperty(xProperty, 0) as Number;
//		displayObject.y = owner.getProperty(yProperty, 0) as Number;
//        trace("updating", x, y);

        if (_isDirty) {
            updateProperties();
        }

        // Now that we've read all our properties, apply them to our transform.
        if (_transformDirty) {
            updateTransform();
        }
    }

    //    /**
    //     * Is the rendered object opaque at the request position in screen space?
    //     * @param pos Location in world space we are curious about.
    //     * @return True if object is opaque there.
    //     */
    //    public function pointOccupied (worldPosition :Point) :Boolean
    //    {
    //        if (!displayObject || !scene)
    //            return false;
    //
    //        // Sanity check.
    //        if (displayObject.stage == null)
    //            Logger.warn(this, "pointOccupied",
    //                "DisplayObject is not on stage, so hitTestPoint will probably not work right.");
    //
    //        // This is the generic version, which uses hitTestPoint. hitTestPoint
    //        // takes a coordinate in screen space, so do that.
    //        worldPosition = scene.transformWorldToScreen(worldPosition);
    //        return displayObject.hitTestPoint(worldPosition.x, worldPosition.y, true);
    //    }

    //    /**
    //     * Transform a point from object space to world space.
    //     */
    //    public function transformObjectToWorld (p :Point) :Point
    //    {
    //        return _transformMatrix.transformPoint(p);
    //    }
    //
    //    /**
    //     * Transform a point from world space to object space.
    //     */
    //    public function transformWorldToObject (p :Point) :Point
    //    {
    //        // Oh goodness.
    //        var tmp :Matrix = _transformMatrix.clone();
    //        tmp.invert();
    //
    //        return tmp.transformPoint(p);
    //    }

    /**
     * Update the object's transform based on its current state. Normally
     * called automatically, but in some cases you might have to force it
     * to update immediately.
     * @param updateProps Read fresh values from any mapped properties.
     */
    public function updateTransform (updateProps :Boolean = false) :void
    {
//		trace("updateTransform");
        if (!displayObject) {
            return;
        }


        if (updateProps) {
            updateProperties();
        }

        if (_scene == null) {
            return;
        }
        //        _transformMatrix.identity();
        //        _transformMatrix.scale(_scale.x, _scale.y);
        //        _transformMatrix.translate(-_registrationPoint.x * _scale.x,
        //            -_registrationPoint.y * _scale.y);
        //        _transformMatrix.rotate(PBUtil.getRadiansFromDegrees(_rotation) + _rotationOffset);
        //        _transformMatrix.translate(_position.x, _position.y);

        //        displayObject.transform.matrix = _transformMatrix;
        displayObject.scaleX = _scaleX;
        displayObject.scaleY = _scaleY;
        displayObject.alpha = _alpha;
        displayObject.visible = (alpha > 0);
        displayObject.x = x;
        displayObject.y = y;

//		if (SceneItemComponent(owner.lookupComponentByType(SceneItemComponent)).desc.type == SceneComponentType.STOREY) {
//			trace(x, y);
//		}

        _transformDirty = false;
    }

    override protected function onAdd () :void
    {
        super.onAdd();
        for each (var eventName :String in updateOnEvents) {
            registerListener(owner.eventDispatcher, eventName, F.callback(updateFromEvent, eventName));
        }


        _alpha = 1;
        _hitTestDirty = true;

        _isDirty = true;
        _lastLayerIndex = -1;

        _layerIndex = 0;
        _layerIndexDirty = true;
        _scaleX = 1
        _scaleY = 1;
        _transformDirty = true;

        _x = 0;
        _y = 0;

        _zIndex = 0;
        _zIndexDirty = true;

        _scene = null;
    }

    override protected function onRemove () :void
    {
        super.onRemove();
        // Remove ourselves from the scene when we are removed
        detach();
        _displayObject = null;
    }

    override protected function onReset() : void
    {
        super.onReset();

        //detach();

        if (autoAttach && !isAttached) {
            attach();
        }
    }

    protected function updateFromEvent (... _) :void
    {
        _isDirty = true;
    }

    protected function updateProperties () :void
    {
        _transformDirty = true;
        _isDirty = false;
        // Sync our zIndex.
//        if (zIndexProperty) {
//            zIndex = owner.getProperty(zIndexProperty, zIndex);
//        }

        // Sync our layerIndex.
        //        if (layerNameProperty)
        //            layerIndex = owner.getProperty(layerNameProperty, layerIndex);

        // Maybe we were in the right layer, but have the wrong zIndex.
        //        if (_zIndexDirty && _scene) {
        //            _scene.getLayer(_layerIndex).markDirty();
        //            _zIndexDirty = false;
        //        }

        // Position.
        if (null != xProperty) {
            x = owner.getProperty(xProperty) as Number;
        }

        if (null != yProperty) {
            y = owner.getProperty(yProperty) as Number;
        }

//        var pos :Point = owner.getProperty(positionProperty) as Point;
//        if (pos) {
//            if (scene) {
//                position = scene.transformWorldToScene(pos);
//            } else {
//                position = pos;
//            }
//        }

        //        // Scale.
        //        var scale :Point = owner.getProperty(scaleProperty) as Point;
        //        if (scale) {
        //            this.scale = scale;
        //        }

        //        // Rotation.
        //        if (rotationProperty) {
        //            var rot :Number = owner.getProperty(rotationProperty) as Number;
        //            this.rotation = rot;
        //        }

        // Alpha.
        if (null != alphaProperty) {
            alpha = owner.getProperty(alphaProperty) as Number;
        }

        //        // Registration Point.
        //        var reg :Point = owner.getProperty(registrationPointProperty) as Point;
        //        if (reg) {
        //            registrationPoint = reg;
        //        }

        // Make sure we're in the right layer and at the right zIndex in the scene.
        // Do this last to be more caching-layer-friendly. If we change position and
        // layer we can just do this at end and it works.
//        if (_layerIndexDirty && _scene) {
//            var tmp :int = _layerIndex;
//            _layerIndex = _lastLayerIndex;
//
//            if (_lastLayerIndex != -1) {
//                _scene.removeSceneComponent(this);
//            }
//
//            _layerIndex = tmp;
//
//            _scene.addSceneComponent(this);
//
//            _lastLayerIndex = _layerIndex;
//            _layerIndexDirty = false;
//        }
    }

    protected var _alpha :Number = 1;

    protected var _displayObject :DisplayObject;
    protected var _hitTestDirty :Boolean = true;

    protected var _isDirty :Boolean;
    protected var _lastLayerIndex :int = -1;

    protected var _layerIndex :int = 0;
    protected var _layerIndexDirty :Boolean = true;
    //    protected var _position :Point = new Point();
    //    protected var _registrationPoint :Point = new Point();
    //    protected var _rotation :Number = 0;

    //    protected var _rotationOffset :Number = 0;
    protected var _scaleX :Number = 1
    protected var _scaleY :Number = 1;

    protected var _transformDirty :Boolean = true;

    protected var _x :Number = 0;
    protected var _y :Number = 0;

    protected var _zIndex :int = 0;
    protected var _zIndexDirty :Boolean = true;

    internal var _scene :Scene2DComponent;

    protected static const log :Log = Log.getLog(SceneEntityComponent);
}
}