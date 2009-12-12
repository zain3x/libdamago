package com.threerings.flashbang.pushbutton.scene.tests {
import com.threerings.flashbang.components.LocationComponent;
import com.threerings.flashbang.pushbutton.EntityAppmode;
import com.threerings.flashbang.pushbutton.GameObjectEntity;
import com.threerings.flashbang.pushbutton.PropertyReference;
import com.threerings.flashbang.pushbutton.scene.Scene2DComponent;
import com.threerings.flashbang.pushbutton.scene.SceneEntityComponent;
import com.threerings.flashbang.pushbutton.scene.SceneLayerYOrdering;
import com.threerings.flashbang.pushbutton.scene.SceneView;
import com.threerings.flashbang.pushbutton.scene.components.LocationComponentBasic;
import com.threerings.flashbang.pushbutton.tasks.LocationTaskComponent;
import com.threerings.util.DebugUtil;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
public class TestSceneBounds extends EntityAppmode
{
    public function TestSceneBounds ()
    {
        DebugUtil.fillRect(modeSprite, 1000, 1000, 0, 0);

        var view :SceneView = new SceneView(200, 200);
        view.debug = true;

        _scene = new Scene2DComponent();
//        _scene.zoom = 0.5;
        _scene.sceneBounds = new Rectangle(-50, 0, 450, 400);
        _scene.debug = true;
        _scene.sceneView = view;
        _scene.panView(0, 0);
        _sortingLayer= new SceneLayerYOrdering();
//        modeSprite.addChild(_sortingLayer);
//        registerListener(_sortingLayer, Event.ENTER_FRAME, _sortingLayer.render);
        _scene.addLayer(_sortingLayer, _layerName);
        this.addSingletonComponent(_scene);
//        addComponentViaSameNamedEntity(_scene, _sceneName);
        modeSprite.addChild(view);

        createRectObject(new Rectangle(2, 2, 20, 40));
        createRectObject(new Rectangle(2, 200, 20, 40));
        createRectObject(new Rectangle(200, 200, 20, 40));
        createRectObject(new Rectangle(200, 2, 20, 140));

        var moving :GameObjectEntity = createRectObject(new Rectangle(40, 40, 20, 50), 0xff0000);
        registerListener(modeSprite, MouseEvent.CLICK, function (...ignored) :void {
            moving.removeAllTasks();
            moving.addTask(LocationTaskComponent.CreateLinear(view.mouseX, view.mouseY, 3,
                moving.lookupComponentByType(LocationComponent) as LocationComponent));
        });

        //Slowly pan left
        modeSprite.addEventListener(Event.ENTER_FRAME, function (...ignored) :void {
             _scene.panView(3.0, 0);
        });
    }

    protected function createRectObject (rect :Rectangle, color :uint = 0) :GameObjectEntity
    {
        //The display component
        var sprite :Sprite = new Sprite();
        var g :Graphics = sprite.graphics;
        g.beginFill(color);
        g.drawRect(-rect.width / 2, -rect.height, rect.width, rect.height)
        g.endFill();
        g.lineStyle(1, 0xff0000);
        g.drawRect(-rect.width / 2, -rect.height, rect.width, rect.height)
        sprite.x = rect.x;
        sprite.y = rect.y;
        return createObjectFromSprite(sprite);
    }

    protected function createObjectFromSprite (sprite :Sprite, name :String = null) :GameObjectEntity
    {
        var obj :GameObjectEntity = new GameObjectEntity(name);

        //The location component
        var location :LocationComponentBasic = new LocationComponentBasic();
        location.x = sprite.x;
        location.y = sprite.y;
        obj.addComponent(location);


        var sceneComponent :SceneEntityComponent = new SceneEntityComponent(sprite);
        sceneComponent.sceneLayerName = _layerName;
        obj.addComponent(sceneComponent);

        //Link the display to the location component
        sceneComponent.xProperty = new PropertyReference("@location.x");
        sceneComponent.yProperty = new PropertyReference("@location.y");

        //Add to the db
        this.addObject(obj);

        //Add to the scene
//        _scene.addSceneComponent(sceneComponent);
        _sortingLayer.addObject(sceneComponent, sceneComponent.displayObject);
        return obj;
    }



    protected var _sceneName :String = "scene";
    protected var _layerName :String = "someLayer";
    protected var _scene :Scene2DComponent;
    protected var _sortingLayer :SceneLayerYOrdering;
}
}