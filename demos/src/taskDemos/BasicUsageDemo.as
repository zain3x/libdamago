package taskDemos {
import aduros.util.F;

import com.pblabs.engine.PBE;
import com.pblabs.engine.core.TemplateManager;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.resource.ResourceManager;
import com.pblabs.engine.resource.XMLResource;
import com.pblabs.rendering2D.DisplayObjectScene;
import com.pblabs.rendering2D.SceneAlignment;
import com.pblabs.rendering2D.SimpleSpatialComponent;
import com.pblabs.rendering2D.ui.IUITarget;
import com.pblabs.rendering2D.ui.SceneView;
import com.threerings.geom.Vector2;
import com.threerings.util.MathUtil;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.ByteArray;

import net.amago.pathfinding.navmesh.NavMeshPolygonExclusion;
import net.amago.pathfinding.navmesh.PathToFollow;
import net.amago.pathfinding.navmesh.pbe.ExclusionComponent;
import net.amago.pathfinding.navmesh.pbe.NavMeshManager;
import net.amago.pathfinding.navmesh.pbe.PathFindingComponent;
import net.amago.pathfinding.navmesh.pbe.PolygonRenderer;
import net.amago.pathfinding.navmesh.pbe.debug.NavMeshDebugComponent;
import net.amago.pathfinding.navmesh.pbe.debug.PathDisplayComponent;
import net.amago.pbe.debug.SpriteBlobComponent;

public class BasicUsageDemo extends Sprite
{
    public function BasicUsageDemo ()
    {
		//Import referenced classes
		PolygonRenderer
		Vector2
		SimpleSpatialComponent
		NavMeshManager
		SpriteBlobComponent
		PathFindingComponent
		PathDisplayComponent
		NavMeshDebugComponent	
		ExclusionComponent
		
		addChild(_mouseLayer = new Sprite());
		
		//Initialize a basic scene
		PBE.startup(this);
		var view :IUITarget = new SceneView();
		addChild(view as Sprite);
		var sceneEntity :IEntity = PBE.initializeScene(view);
		var scene :DisplayObjectScene = sceneEntity.lookupComponentByType(DisplayObjectScene) as DisplayObjectScene;
		scene.sceneAlignment = SceneAlignment.TOP_LEFT;
		
		ResourceManager.instance.onlyLoadEmbeddedResources = true;
		ResourceManager.instance.registerEmbeddedResource("../../assets/demo01.pbelevel", XMLResource, new DATA() as ByteArray);
		
		TemplateManager.instance.addEventListener(TemplateManager.LOADED_EVENT, F.justOnce(
			function (...ignored) :void {
				TemplateManager.instance.instantiateGroup("Everything");
			}));
		TemplateManager.instance.loadFile("../../assets/demo01.pbelevel");
		
		//Add mouse listeners for interactivity
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, function (...ignored) :void {
			_startDrag.x = stage.mouseX;
			_startDrag.y = stage.mouseY;
			_mouseDown = true;
		});
		
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, function (...ignored) :void {
			_mouseLayer.graphics.clear();
			if (_mouseDown) {
				var g :Graphics = _mouseLayer.graphics;
				g.lineStyle(1, 1);
				var left :Number = Math.min(_startDrag.x, stage.mouseX);
				var top :Number = Math.min(_startDrag.y, stage.mouseY);
				var width :Number = Math.abs(_startDrag.x - stage.mouseX);
				var height :Number = Math.abs(_startDrag.y - stage.mouseY);
				g.drawRect(left, top, width, height);
			}
		});
		
		this.stage.addEventListener(MouseEvent.MOUSE_UP, function (...ignored) :void {
			if (MathUtil.distance(stage.mouseX, stage.mouseY, _startDrag.x, _startDrag.y) > 10) {
				var points :Array = [
					new Vector2(_startDrag.x, _startDrag.y),
					new Vector2(stage.mouseX, _startDrag.y),
					new Vector2(stage.mouseX, stage.mouseY),
					new Vector2(_startDrag.x, stage.mouseY),
					];
				var polygon :NavMeshPolygonExclusion = new NavMeshPolygonExclusion(points);
				var obs :IEntity = TemplateManager.instance.instantiateEntity("obstacle");
				if (obs == null) {
					trace("Failed to create obstacle from template");
				} else {
					ExclusionComponent(obs.lookupComponentByType(ExclusionComponent)).vertices = points;
				}
			} else {
				var path :PathToFollow = 
				PathFindingComponent(PBE.nameManager.lookup("Traveller").lookupComponentByType(PathFindingComponent)).findPathToPoint(new Point(stage.mouseX, stage.mouseY));
			}
			_mouseDown = false;
		});
    }
	
	protected var _mouseDown :Boolean;
	protected var _startDrag :Point = new Point();
	protected var _mouseLayer :Sprite;
	
	[Embed(source="../../assets/demo01.pbelevel", mimeType='application/octet-stream')]
	public static const DATA :Class;
}
}