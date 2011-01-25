package net.amago.pathfinding.navmesh.pbe.debug {
import aduros.util.F;

import com.pblabs.engine.entity.PropertyReference;
import com.pblabs.rendering2D.DisplayObjectRenderer;
import com.threerings.display.GraphicsUtil;
import com.threerings.geom.Vector2;
import com.threerings.ui.TextBits;
import com.threerings.util.ClassUtil;
import com.threerings.util.DisplayUtils;
import com.threerings.util.EventHandlerManager;
import com.threerings.util.Set;
import com.threerings.util.Sets;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.text.TextField;

import net.amago.pathfinding.navmesh.NavMesh;
import net.amago.pathfinding.navmesh.NavMeshNode;
import net.amago.pathfinding.navmesh.NavMeshPolygonExclusion;
import net.amago.pathfinding.navmesh.NavmeshUtil;
import net.amago.pathfinding.navmesh.pbe.NavMeshManager;

public class NavMeshDebugComponent extends DisplayObjectRenderer
{
	public var managerProperty :PropertyReference;
	
    public function NavMeshDebugComponent ()
    {
        super();
        _displayObject = new Sprite();
    }
	
	protected function get manager () :NavMeshManager
	{
		return owner.getProperty(managerProperty) as NavMeshManager;
	}

    override public function set displayObject (value :DisplayObject) :void
    {
        throw new Error("Cannot set displayObject in " + ClassUtil.tinyClassName(this) +
            "; it is always a Sprite");
    }

    override protected function onAdd () :void
    {
        super.onAdd();
        _events.registerListener(owner.eventDispatcher, NavMeshManager.CHANGED, F.callback(redraw));
    }

    override protected function onRemove () :void
    {
        super.onRemove();
        _events.freeAllHandlers();
    }

    override protected function onReset () :void
    {
        super.onReset();
        redraw();
    }

    protected function redraw () :void
    {
        var g :Graphics = Sprite(_displayObject).graphics;
        g.clear();
		
		if (manager.pathFinder != null) {
			drawNavigationMesh(Sprite(_displayObject), manager.pathFinder.navMesh);
		}
    }

    protected static function drawNavigationMesh (sprite :Sprite, mesh :NavMesh, path :Array =
        null) :void
    {
//		trace("drawing navmesh " + mesh);
			
		DisplayUtils.removeAllChildren(sprite);
        var drawnNodePairs :Set = Sets.newSetOf(Object);
        var k :int;

        for each (var poly :NavMeshPolygonExclusion in mesh._polygonsAll) {
            drawPolygon(poly, sprite);
        }
		
        for each (var node :NavMeshNode in mesh.nodes) {
            drawNode(node, sprite);
        }

        sprite.graphics.lineStyle(2, 0xffcccc);
        if (path != null) {
            for (k = 0; k < path.length - 1; k++) {
                sprite.graphics.moveTo(path[k].x, path[k].y);
                sprite.graphics.lineTo(path[k + 1].x, path[k + 1].y);
            }
        }

        //Draw path if given
        if (path != null && path.length > 1) {

            var start :Vector2 = path[0];
            var target :Vector2 = path[path.length - 1];
            sprite.graphics.moveTo(start.x, start.y);
            sprite.graphics.beginFill(0xff0033);
            sprite.graphics.drawCircle(start.x, start.y, 4);

            sprite.graphics.beginFill(0x009900);
            sprite.graphics.drawCircle(target.x, target.y, 4);

            NavmeshUtil.drawGrid(sprite.graphics, 100, 0xff9999);

            sprite.graphics.lineStyle(2, 0xcc00cc);

            for (k = 0; k < path.length - 1; k++) {
                sprite.graphics.moveTo(path[k].x, path[k].y);
                sprite.graphics.lineTo(path[k + 1].x, path[k + 1].y);
            }
        }

        function drawPolygon (poly :NavMeshPolygonExclusion, sprite :Sprite, buffer :int = 0) :void {
            if (buffer != 0) {
                poly.pad(buffer);
            }
            sprite.graphics.lineStyle(1, 0);
            for (var i :int = 0; i < poly.vertices.length - 1; i++) {
                var vertex1 :Vector2 = poly.vertices[i] as Vector2;
                var vertex2 :Vector2 = poly.vertices[i + 1] as Vector2;

//                if (buffer == 0) {
//                    sprite.graphics.moveTo(vertex1.x, vertex1.y);
//                    sprite.graphics.lineTo(vertex2.x, vertex2.y);
//                } else {
                    GraphicsUtil.dashTo(sprite.graphics, vertex1.x, vertex1.y, vertex2.x,
                        vertex2.y);
//                }

                sprite.graphics.drawCircle(vertex1.x, vertex1.y, 3);
            }
            var vertexFirst :Vector2 = poly.vertices[0] as Vector2;
            var vertexLast :Vector2 = poly.vertices[poly.vertices.length - 1] as Vector2;

//            if (buffer == 0) {
//                sprite.graphics.moveTo(vertexLast.x, vertexLast.y);
//                sprite.graphics.lineTo(vertexFirst.x, vertexFirst.y);
//            } else {
                GraphicsUtil.dashTo(sprite.graphics, vertexLast.x, vertexLast.y, vertexFirst.x,
                    vertexFirst.y);
//            }

            sprite.graphics.drawCircle(vertexLast.x, vertexLast.y, 3);
            sprite.graphics.endFill();
            if (buffer != 0) {
                poly.pad(-buffer);
            }
        }

        function drawNode (node :NavMeshNode, sprite :Sprite) :void {
            sprite.graphics.lineStyle(1, 0x00cc33, 1);
            for each (var neighbour :NavMeshNode in node.getNeighbors()) {
                var nodePairKey :int = NavmeshUtil.hashForIdPair(node.hashCode(),
                    neighbour.hashCode());
                if (!drawnNodePairs.contains(nodePairKey)) {
                    GraphicsUtil.dashTo(sprite.graphics, node.vector.x, node.vector.y,
                        neighbour.vector.x, neighbour.vector.y);
					var labelTxt :String = "";
                    if (!mesh._distances.containsKey(NavmeshUtil.hashForIdPair(node._id,
                        neighbour._id))) {
						labelTxt = "        X";
                    } else {
						labelTxt =
                            "" + int(mesh._distances.get(NavmeshUtil.hashForIdPair(node._id,
                            neighbour._id)));
                    }
                    var distanceLabel :TextField = TextBits.createText(labelTxt);
                    distanceLabel.selectable = false;
                    var labelPos :Vector2 = Vector2.interpolate(node, neighbour, 0.5);
                    distanceLabel.x = labelPos.x;
                    distanceLabel.y = labelPos.y;
                    sprite.addChild(distanceLabel);

                    drawnNodePairs.add(nodePairKey);

                }
            }
            sprite.graphics.drawCircle(node.x, node.y, 3);

            var label :TextField = TextBits.createText(" " + node.getNodeId(), 0.8, 0, 0x999999);
            label.selectable = false;
            label.x = node.vector.x;
            label.y = node.vector.y;

            sprite.addChild(label);

        }

    }
	
    protected var _color :uint = 0xcc00cc;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _thickness :Number = 2;
}
}