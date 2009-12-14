package com.threerings.flashbang.pushbutton.scene {
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.flashbang.Updatable;
import com.threerings.flashbang.components.LocationComponent;
import com.threerings.flashbang.pushbutton.EntityComponent;
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.MathUtil;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.*;
/**
 * Basic Rendering2D scene; it is given a SceneView and some
 * DisplayObjectRenderers, and makes sure that they are drawn. Extensible
 * for more complex rendering scenarios. Enforces sorting order, too.
 */
public class Scene2DComponent extends EntityComponent
    implements Updatable
{
    public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(Scene2DComponent);
    public var dirty :Boolean;

    /**
     * Maximum allowed zoom level.
     *
     * @see zoom
     */
    public var maxZoom :Number = 1;
    /**
     * Minimum allowed zoom level.
     *
     * @see zoom
     */
    public var minZoom :Number = .01;

    /**
     * How the scene is aligned relative to its position property.
     *
     * @see SceneAlignment
     * @see position
     */
    public var sceneAlignment :SceneAlignment = SceneAlignment.DEFAULT_ALIGNMENT;

    /**
     * If set, every frame, trackObject's position is read and assigned
     * to the scene's position, so that the scene follows the trackObject.
     */
    public var trackObject :LocationComponent;

//    public var sceneBoundsRef :RectangleReference;

    public function Scene2DComponent (sceneName :String = null)
    {
        _sceneName = sceneName;
        // Get ticked after all the renderers.
//        updatePriority = -10;
        _rootSprite = new Sprite();//generateRootSprite();
    }

    public function get componentReference () :PropertyReference
    {
        if (null != _selfReference) {
            return _selfReference;
        }
        _selfReference = new PropertyReference("#" + owner.name + "." + name);
        return _selfReference;
    }

    public function get layerCount () :int
    {
        return _layers.length;
    }

    override public function get name () :String
    {
        return _sceneName == null ? COMPONENT_NAME : _sceneName;
    }

    public function get position () :Point
    {
        return _rootPosition.clone();
    }

    public function set position (value :Point) :void
    {
        if (!value) {
            return;
        }

        var newX :Number = value.x;
        var newY :Number = value.y;

        if (_rootPosition.x == newX && _rootPosition.y == newY)
            return;
//        trace("Setting _rootPosition.x=" + newX);
        _rootPosition.x = newX;
        _rootPosition.y = newY;
        _transformDirty = true;
    }

    public function get rootSprite () :Sprite
    {
        return _rootSprite;
    }

    public function get sceneView () :SceneView
    {
        return _sceneView;
    }

    public function set sceneView (value :SceneView) :void
    {
        if (_sceneView) {
            _sceneView.removeDisplayObject(_rootSprite);
        }

        _sceneView = value;

        if (_sceneView) {
            _sceneView.addDisplayObject(_rootSprite);
        }
    }

//    public function get sceneViewBounds () :Rectangle
//    {
//        if (!sceneView) {
//            return null;
//        }
//
//        // Make sure we are up to date with latest track.
//        if (trackObject) {
//            position = new Point(-(trackObject.x), -(trackObject.y));
//        }
//
//        if (viewBounds != null) {
//            var centeredLimitBounds :Rectangle =
//                new Rectangle(viewBounds.x + sceneView.width * 0.5,
//                viewBounds.y + sceneView.height * 0.5,
//                viewBounds.width - sceneView.width,
//                viewBounds.height - sceneView.height);
//
//            position = new Point(PBUtil.clamp(position.x, -centeredLimitBounds.right,
//                -centeredLimitBounds.left), PBUtil.clamp(position.y, -centeredLimitBounds.bottom,
//                -centeredLimitBounds.top));
//        }
//
//        updateTransform();
//
//        // What region of the scene are we currently viewing?
//        SceneAlignment.calculate(_tempPoint, sceneAlignment, sceneView.width / zoom,
//            sceneView.height / zoom);
//
//        _sceneViewBoundsCache.x = -position.x - _tempPoint.x;
//        _sceneViewBoundsCache.y = -position.y - _tempPoint.y;
//        _sceneViewBoundsCache.width = sceneView.width / zoom;
//        _sceneViewBoundsCache.height = sceneView.height / zoom;
//
//        return _sceneViewBoundsCache;
//    }

//    public function set sceneViewName (value :String) :void
//    {
//        _sceneViewName = value;
//    }

    /**
     * @inheritDoc
     */
    public function get sceneBounds () :Rectangle
    {
//        if (_sceneBounds != null) {
            return _sceneBounds;
//        }
//        if (sceneBoundsRef != null && sceneBoundsRef.value != null) {
//            return sceneBoundsRef.value;
//        }
//        return null;
    }

    public function set debug (val :Boolean) : void
    {
        var g :Graphics = rootSprite.graphics;
        g.clear();
        if (val && sceneBounds != null) {
            g.lineStyle(1, 0xff0000);
//            g.drawRect(
//            DebugUtil.drawRect(this, _width, _height, 0);
        }
    }

    public function set sceneBounds (value :Rectangle) :void
    {
        _sceneBounds = value;
    }



    public function get zoom () :Number
    {
        return _zoom;
    }

    public function set zoom (value :Number) :void
    {
        // Make sure our zoom level stays within the desired bounds
        value = MathUtil.clamp(value, minZoom, maxZoom);

        if (_zoom == value)
            return;

        _zoom = value;
        _transformDirty = true;
    }

    public function addLayer (layer :SceneLayer, name :String = null, idx :int = -1) :void
    {
        if (null == layer) {
            throw new Error ("null layer");
        }

        if (null != layer._parentScene) {
            throw new Error ("layer already attached to a scene");
        }

        if (null != _layers[idx]) {
            throw new Error ("setLayer at " + idx + ", index occupied");
        }

        if (idx == -1) {
            idx = _layers.length;
        }

        _layers[idx] = layer;
        _rootSprite.addChildAt(layer, idx);
        if (null != name) {
            layer.name = name;
        }
        layer.attachedInternal();
    }

    public function addSceneComponent (obj :SceneEntityComponent) :void
    {
        if (_sceneComponents.containsKey(obj)) {
            throw new Error("Already contains obj " + obj);
        }

        if (null == obj) {
            throw new Error("obj is null");
        }

        if (null == obj.displayObject) {
            throw new Error("obj.displayObject is null");
        }

        var layerName :String = obj.sceneLayerName;
        if (null == layerName) {
            log.warning("obj.sceneLayerName is null, using the default layer");
            layerName = DEFAULT_LAYER_NAME;
        }

        var layer :SceneLayer = getLayer(layerName);

        if (null == layer) {
            throw new Error("No layer named " + layerName);
        }

        _sceneComponents.put(obj, layer);
        layer.addObjectInternal(obj, obj.displayObject);
        obj._scene = this;
        dirty = true;
    }

    public function getDefaultLayer () :SceneLayer
    {
        if (null == _layers[0]) {
            var layer :SceneLayer = new SceneLayer();
            addLayer(layer, DEFAULT_LAYER_NAME, 0);
            return layer;
        }
        return _layers[0] as SceneLayer;
    }

    public function getLayer (layerName :String) :SceneLayer
    {
        for each (var layer :SceneLayer in _layers) {
            if (null != layer && layer.name == layerName) {
                return layer;
            }
        }
        return null;
    }

    public function getLayerAt (idx :uint) :SceneLayer
    {
        return _layers[idx] as SceneLayer;
    }

    public function removeSceneComponent (obj :SceneEntityComponent) :void
    {
        if (!_sceneComponents.containsKey(obj)) {
            log.warning("Doesn't contain " + obj);
            return;
        }
        var layer :SceneLayer = _sceneComponents.get(obj) as SceneLayer;

        if (null == layer) {
            throw new Error("No associated layer for " + obj);
        }

        layer.removeObjectInternal(obj);
        _sceneComponents.remove(obj);
    }

//    public function add (dor :DisplayObjectRenderer) :void
//    {
//        // Add to the appropriate layer.
//        var layer :SceneLayer = getLayer(dor.layerIndex, true);
//        layer.add(dor);
//        if (dor.displayObject)
//            _renderers[dor.displayObject] = dor;
//    }
//
//    public function getLayer (index :int, allocateIfAbsent :Boolean =
//        false) :SceneLayer
//    {
//        // Maybe it already exists.
//        if (_layers[index])
//            return _layers[index];
//
//        if (allocateIfAbsent == false)
//            return null;
//
//        // Allocate the layer.
//        _layers[index] = generateLayer(index);
//
//        // Order the layers. This is suboptimal but we are probably not going
//        // to be adding a lot of layers all the time.
//        while (_rootSprite.numChildren)
//            _rootSprite.removeChildAt(_rootSprite.numChildren - 1);
//        for (var i :int = 0; i < layerCount; i++) {
//            if (_layers[i])
//                _rootSprite.addChild(_layers[i]);
//        }
//
//        // Return new layer.
//        return _layers[index];
//    }

//    public function getRenderersUnderPoint (screenPosition :Point, mask :ObjectType = null) :Array
//    {
//        // Query normal DO hierarchy.
//        var unfilteredResults :Array = _rootSprite.getObjectsUnderPoint(screenPosition);
//        var worldPosition :Point = transformScreenToWorld(screenPosition);
//
//        // TODO: rewrite to splice from unfilteredResults to avoid alloc?
//        var results :Array = new Array();
//
//        for each (var o :*in unfilteredResults) {
//            var renderer :DisplayObjectRenderer = getRendererForDisplayObject(o);
//
//            if (!renderer)
//                continue;
//
//            if (!renderer.owner)
//                continue;
//
//            if (mask && !ObjectTypeManager.instance.doTypesOverlap(mask, renderer.objectMask))
//                continue;
//
//            if (!renderer.pointOccupied(worldPosition))
//                continue;
//
//            results.push(renderer);
//        }
//
//        // Also give layers opportunity to return renderers.
//        var scenePosition :Point = transformScreenToScene(screenPosition);
//        for each (var l :SceneLayer in _layers) {
//            // Skip them if they don't use the interface.
//            if (!(l is ILayerMouseHandler))
//                continue;
//
//            (l as ILayerMouseHandler).getRenderersUnderPoint(scenePosition, mask, results);
//        }
//
//        return results;
//    }

//    public function invalidate (dirtyRenderer :DisplayObjectRenderer) :void
//    {
//        var layerToDirty :SceneLayer = getLayer(dirtyRenderer.layerIndex);
//        if (!layerToDirty)
//            return;
//
//        if (layerToDirty is ICachingLayer)
//            ICachingLayer(layerToDirty).invalidate(dirtyRenderer);
//    }
//
//    public function invalidateRectangle (dirty :Rectangle) :void
//    {
//        for each (var l :SceneLayer in _layers) {
//            if (l is ICachingLayer)
//                (l as ICachingLayer).invalidateRectangle(dirty);
//        }
//    }
//
//    public function remove (dor :DisplayObjectRenderer) :void
//    {
//        var layer :SceneLayer = getLayer(dor.layerIndex, false);
//        if (!layer)
//            return;
//
//        layer.remove(dor);
//        if (dor.displayObject)
//            delete _renderers[dor.displayObject];
//    }

    public function panView (deltaX :Number, deltaY :Number) :void
    {
        if (deltaX == 0 && deltaY == 0) {
            return;
        }


        // TODO: Take into account rotation so it's correct even when
        //       rotating.
        var before :Number = _rootPosition.x;
        _rootPosition.x -= deltaX / _zoom;
//        trace("deltaX=", before, _rootPosition.x);
//        trace("Before/after=", before, _rootPosition.x);
        _rootPosition.y -= deltaY / _zoom;



        _transformDirty = true;
    }

    public function setWorldCenter (pos :Point) :void
    {
        if (!sceneView)
            throw new Error("sceneView not yet set. can't center the world.");

        position = transformWorldToScreen(pos);
    }

//    public function sortSpatials (array :Array) :void
//    {
//        // Subclasses can set how things are sorted.
//    }

    public function transformSceneToScreen (inPos :Point) :Point
    {
        return _rootSprite.localToGlobal(inPos);
    }

    public function transformSceneToWorld (inPos :Point) :Point
    {
        return inPos;
    }

    public function transformScreenToScene (inPos :Point) :Point
    {
        return _rootSprite.globalToLocal(inPos);
    }

    public function transformScreenToWorld (inPos :Point) :Point
    {
        return _rootSprite.globalToLocal(inPos);
    }

    public function transformWorldToScene (inPos :Point) :Point
    {
        return inPos;
    }

    public function transformWorldToScreen (inPos :Point) :Point
    {
        return _rootSprite.localToGlobal(inPos);
    }

    public function update (dt :Number) :void
    {
//        trace("updating scene");
        if (!sceneView) {
            log.warning(this + " sceneView is null, so we aren't rendering.");
            return;
        }

        if (trackObject) {
            position = new Point(-(trackObject.x), -(trackObject.y));
        }

//        if (sceneBounds != null) {
//            var centeredLimitBounds :Rectangle =
//                new Rectangle(sceneBounds.x + sceneView.width * 0.5,
//                sceneBounds.y + sceneView.height * 0.5,
//                sceneBounds.width - sceneView.width,
//                sceneBounds.height - sceneView.height);
//
//            position = new Point(MathUtil.clamp(position.x, -centeredLimitBounds.right,
//                -centeredLimitBounds.left), MathUtil.clamp(position.y, -centeredLimitBounds.bottom,
//                -centeredLimitBounds.top));
//        }

        updateTransform();

        // Give layers a chance to sort and update.
        for each (var l :SceneLayer in _layers) {
            l.renderInternal();
        }
    }

//    protected function get sceneBounds () :Rectangle
//    {
//
//    }

    public function updateTransform () :void
    {
        if (_transformDirty == false) {
            return;
        }
        _transformDirty = false;


        if (_sceneBounds != null) {
//            trace("panning");
            //TODO: doesn't take into account zooming yet
            //Check that we're inside the scene bounds
            //Check x, starting with the right.
            var minViewX :Number = -(_sceneBounds.right - _sceneView.width * _zoom);
//            trace("minViewX=" + minViewX);
//            trace("_sceneBounds.right=" + _sceneBounds.right);
            var maxViewX :Number = -_sceneBounds.left;
//            trace("minmaxX=", minViewX, maxViewX);
            var minViewY :Number = -(_sceneBounds.bottom - _sceneView.height * _zoom);
            var maxViewY :Number = -_sceneBounds.top;
//            trace("clampedX=" + MathUtil.clamp(_rootPosition.x, minViewX, maxViewX));
            _rootPosition.x = MathUtil.clamp(_rootPosition.x, minViewX, maxViewX);

//            trace("After clamping=" + _rootPosition.x);
            _rootPosition.y = MathUtil.clamp(_rootPosition.y, minViewY, maxViewY);

//            _rootSprite.x = _rootPosition.x;
//            _rootSprite.y = _rootPosition.y;
        }

//        return;
//        trace("updating scene transform");
//        _transformDirty = false;

        // Update our transform, if required
        _rootTransform.identity();
        _rootTransform.translate(_rootPosition.x, _rootPosition.y);
        _rootTransform.scale(zoom, zoom);

        // Center it appropriately.
//        SceneAlignment.calculate(_tempPoint, SceneAlignment.TOP_LEFT, sceneView.width,
//            sceneView.height);
//        _rootTransform.translate(_tempPoint.x, _tempPoint.y);

        _rootSprite.transform.matrix = _rootTransform;


//        trace("updating scene transform, scale=" + _rootSprite.scaleX);
    }

    internal function removeLayer (layer :SceneLayer) :void
    {
        if (!ArrayUtil.contains(_layers, layer)) {
            throw new Error("No layer: " + layer);
        }

        _layers[ArrayUtil.indexOf(_layers, layer)] = null;
        layer.detachedInternal();
        layer._parentScene = null;
        _rootSprite.removeChild(layer);
    }

    override protected function onRemove () :void
    {
        super.onRemove();
        // Make sure we don't leave any lingering content.
        if (_sceneView) {
//            _sceneView.clearDisplayObjects();
        }
    }

//    /**
//     * Convenience funtion for subclasses to control what class of layer
//     * they are using.
//     */
//    protected function generateLayer (layerIndex :int) :SceneLayer
//    {
//        var l :SceneLayer = new SceneLayer();
//
//        //TODO: set any properties we want for our layer.
//
//        return l;
//    }

//    /**
//     * Convenience function for subclasses to create a custom root sprite.
//     */
//    protected function generateRootSprite () :Sprite
//    {
//        var s :Sprite = new Sprite();
//
//        //TODO: set any properties we want for our root host sprite
//
//        return s;
//    }

//    protected function getRendererForDisplayObject (displayObject :DisplayObject) :DisplayObjectRenderer
//    {
//        var current :DisplayObject = displayObject;
//
//        // Walk up the display tree looking for a DO we know about.
//        while (current) {
//            // See if it's a DOR.
//            var renderer :DisplayObjectRenderer = _renderers[current] as DisplayObjectRenderer;
//            if (renderer)
//                return renderer;
//
//            // If we get to a layer, we know we're done.
//            if (renderer is SceneLayer)
//                return null;
//
//            // Go up the tree..
//            current = current.parent;
//        }
//
//        // No match!
//        return null;
//    }

    protected function sceneViewResized (event :Event) :void
    {
        _transformDirty = true;
    }

    protected var _currentWorldCenter :Point = new Point();
    protected var _layers :Array = [];


//    protected var _renderers :Dictionary = new Dictionary(true);
    protected var _rootPosition :Point = new Point();
//    protected var _rootRotation :Number = 0;
    protected var _rootSprite :Sprite;
    protected var _rootTransform :Matrix = new Matrix();

    /** Objects mapped to layers*/
    protected var _sceneComponents :Map = Maps.newMapOf(Object);

    protected var _sceneView :SceneView;

//    protected var _sceneViewBoundsCache :Rectangle = new Rectangle();
//    protected var _sceneViewName :String = null;
    protected var _sceneName :String = null;

    protected var _selfReference :PropertyReference;
    protected var _tempPoint :Point = new Point();
    protected var _transformDirty :Boolean = true;

    protected var _sceneBounds :Rectangle = null;

    protected var _zoom :Number = 1;
    protected static const DEFAULT_LAYER_NAME :String = "defaultLayer";

    protected static const log :Log = Log.getLog(Scene2DComponent);
}
}