package com.threerings.flashbang.pushbutton.scene.tests {
import com.pblabs.engine.entity.PropertyReference;
import com.plabs.components.tasks.AnimateValueTask;
import com.plabs.components.tasks.LocationTask;
import com.plabs.components.tasks.TaskComponent;
import com.threerings.flashbang.pushbutton.EntityAppmode;
import com.threerings.flashbang.pushbutton.GameObjectEntity;
import com.threerings.flashbang.pushbutton.scene.Scene2DComponent;
import com.threerings.flashbang.pushbutton.scene.SceneEntityComponent;
import com.threerings.flashbang.pushbutton.scene.SceneLayerYOrdering;
import com.threerings.flashbang.pushbutton.scene.SceneView;
import com.threerings.flashbang.pushbutton.scene.components.LocationComponentBasic;
import com.threerings.flashbang.util.Rand;
import com.threerings.util.DebugUtil;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
public class TestYOrderingLayer extends EntityAppmode
{
    public function TestYOrderingLayer ()
    {
        DebugUtil.fillRect(modeSprite, 1000, 1000, 0, 0);

        var view :SceneView = new SceneView(500, 500);

        _scene = new Scene2DComponent();
        _scene.sceneView = view;
        _sortingLayer= new SceneLayerYOrdering();
        modeSprite.addChild(_sortingLayer);
        registerListener(_sortingLayer, Event.ENTER_FRAME, _sortingLayer.render);
//        _scene.addLayer(_sortingLayer, _layerName);
//        addComponentViaSameNamedEntity(_scene, _sceneName);
//        modeSprite.addChild(view);

        for (var ii :int = 0; ii < 10; ++ii) {
            var rect :Rectangle = new Rectangle(Rand.nextIntInRange(0, 200),
                                                Rand.nextIntInRange(100, 300),
                                                Rand.nextIntInRange(20, 50),
                                                Rand.nextIntInRange(50, 100));
            createRectObject(rect);
        }

        var moving :GameObjectEntity = createRectObject(new Rectangle(40, 40, 20, 50), 0xff0000);
        registerListener(modeSprite, MouseEvent.CLICK, function (...ignored) :void {
            var tasks :TaskComponent = moving.lookupComponentByType(TaskComponent) as TaskComponent;
            tasks.removeAllTasks();
            moving.setProperty(new PropertyReference("@sceneComponent.displayObject.alpha"), 1);
            tasks.addTask(AnimateValueTask.CreateLinear(new PropertyReference("@sceneComponent.displayObject.alpha"), 0, 3));
            var xRef :PropertyReference = new PropertyReference("@location.x");
            var yRef :PropertyReference = new PropertyReference("@location.y");
            tasks.addTask(LocationTask.CreateSmooth(xRef, yRef, view.mouseX, view.mouseY, 3));
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

    protected function createObjectFromSprite (sprite :Sprite) :GameObjectEntity
    {
        var obj :GameObjectEntity = new GameObjectEntity();

        //The location component
        var location :LocationComponentBasic = new LocationComponentBasic();
        location.x = sprite.x;
        location.y = sprite.y;
        var locationName :String = "location";
        obj.addComponent(location, locationName);


        var sceneComponent :SceneEntityComponent = new SceneEntityComponent(sprite);
        var sceneComponentName :String = "sceneComponent";
        sceneComponent.sceneLayerName = _layerName;
        obj.addComponent(sceneComponent, sceneComponentName);

        //Link the display to the location component
        sceneComponent.xProperty = new PropertyReference("@location.x");
        sceneComponent.yProperty = new PropertyReference("@location.y");

        //Tasks
        obj.addComponent(new TaskComponent(), TaskComponent.COMPONENT_NAME);

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