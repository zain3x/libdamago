package com.threerings.geometry.path.debug
{
import com.threerings.display.GraphicsUtil;
import com.threerings.flashbang.AppMode;
import com.threerings.geom.Vector2;
import com.threerings.text.TextFieldUtil;
import com.threerings.ui.SimpleTextButton;
import com.threerings.util.Set;
import com.threerings.util.Sets;
import com.threerings.util.Util;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

import com.threerings.geometry.path.PathToFollow;
import com.threerings.geometry.path.navmesh.NavMesh;
import com.threerings.geometry.path.navmesh.NavMeshNode;
import com.threerings.geometry.path.navmesh.NavMeshPathFinder;
import com.threerings.geometry.path.navmesh.NavMeshPolygon;

import com.threerings.util.GameUtil;
import com.threerings.util.GraphicsUtils;

public class TestNavigationMeshPathfinding extends AppMode
{

    protected var _navTestSprite :Sprite;
    protected var _currentNavTest :int = 0;

    protected var _text :TextField;

    protected var _nextNavMeshTestButton :SimpleTextButton;

    protected function nextNavTest (...ignored) :void
    {

        while(_navTestSprite.numChildren > 0) { _navTestSprite.removeChildAt(0); }
        _navTestSprite.graphics.clear();


        try
        {
            var tempFunction :Function = TESTS[_currentNavTest] as Function;//this["navTest" + _currentNavTest];
            var meshSprite :Sprite = new Sprite();
            _navTestSprite.addChild(meshSprite);
            tempFunction(meshSprite);

            TextFieldUtil.updateText(_text,  " Test: " + (_currentNavTest + 1));

        }
        catch (err :ReferenceError)
        {
            _currentNavTest = 0;
            nextNavTest();
        }
        _currentNavTest++;
        if (_currentNavTest >= TESTS.length) {
            _currentNavTest = 0;
        }


    }





    protected static function drawNavMesh(meshSprite :Sprite, navmesh :NavMesh, path :PathToFollow, start :Vector2, target :Vector2) :void
    {
        //Draw everything
        drawNavigationMesh(meshSprite, navmesh, path.path);

        meshSprite.graphics.beginFill(0xff0033);
        meshSprite.graphics.drawCircle(start.x, start.y, 4);

        meshSprite.graphics.beginFill(0x009900);
        meshSprite.graphics.drawCircle(target.x, target.y, 4);

        GraphicsUtils.drawGrid(meshSprite.graphics, 100, 0xff9999);

        meshSprite.graphics.lineStyle(2, 0xcc00cc);

        var pathNodes :Array = path.path;
        for(var k :int = 0; k < pathNodes.length - 1; k++) {
            meshSprite.graphics.moveTo(pathNodes[k].x, pathNodes[k].y);
            meshSprite.graphics.lineTo(pathNodes[k + 1].x, pathNodes[k + 1].y);
        }
    }

    override protected function enter() :void
    {
        super.enter();

        modeSprite.graphics.clear();
        modeSprite.graphics.beginFill(0xffffff);
        modeSprite.graphics.drawRect(0, 0, 1600, 1600);
        modeSprite.graphics.endFill();

        _navTestSprite = new Sprite();
        _navTestSprite.x = 100;
        _navTestSprite.y = 100;
        _navTestSprite.scaleX = 0.7;
        _navTestSprite.scaleY = _navTestSprite.scaleX;
        modeSprite.addChild(_navTestSprite);

        _nextNavMeshTestButton = new SimpleTextButton("Next NavMesh Test");
        _nextNavMeshTestButton.addEventListener(MouseEvent.CLICK, nextNavTest);
        _nextNavMeshTestButton.x = 100;
        _nextNavMeshTestButton.y = 60;
        modeSprite.addChild(_nextNavMeshTestButton);

        _text = TextFieldUtil.createField("Test " + _currentNavTest, {x:250, y:_nextNavMeshTestButton.y, scaleX:2, scaleY:2});
        modeSprite.addChild(_text);
        nextNavTest();

    }

    public static function drawNavigationMesh(sprite :Sprite, mesh :NavMesh, path :Array = null) :void
    {
        var drawnNodePairs :Set = Sets.newSetOf(Object);
        var k :int;

        //Draw bounds
        if(mesh.getBounds() != null) {
            var rect :Rectangle = mesh.getBounds();
            sprite.graphics.lineStyle(3, 0xff3333);
            sprite.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);

            sprite.graphics.lineStyle(1, 0xff3333);
            sprite.graphics.drawRect(0, 0, BOARD_SIZE.x, BOARD_SIZE.y);
        }

        for each (var poly :NavMeshPolygon in mesh._polygonsAll) {
            drawPolygon(poly, sprite);
        }

        for each (var node :NavMeshNode in mesh.nodes) {
            drawNode(node, sprite);
        }


        sprite.graphics.lineStyle(2, 0xffcccc);
        if(path != null) {
            for(k = 0; k < path.length - 1; k++) {
                sprite.graphics.moveTo(path[k].x, path[k].y);
                sprite.graphics.lineTo(path[k + 1].x, path[k + 1].y);
            }
        }



        //Draw path if given
        if(path != null && path.length > 1) {

            var start :Vector2 = path[0];
            var target :Vector2 = path[path.length - 1];
            sprite.graphics.moveTo(start.x, start.y);
            sprite.graphics.beginFill(0xff0033);
            sprite.graphics.drawCircle(start.x, start.y, 4);

            sprite.graphics.beginFill(0x009900);
            sprite.graphics.drawCircle(target.x, target.y, 4);

            GraphicsUtils.drawGrid(sprite.graphics, 100, 0xff9999);

            sprite.graphics.lineStyle(2, 0xcc00cc);

            for(k = 0; k < path.length - 1; k++) {
                sprite.graphics.moveTo(path[k].x, path[k].y);
                sprite.graphics.lineTo(path[k + 1].x, path[k + 1].y);
            }
        }

        function drawPolygon(poly :NavMeshPolygon, sprite :Sprite, buffer :int = 0) :void
        {
            if(buffer != 0) {
               poly.pad(buffer);
            }
            sprite.graphics.lineStyle(3, 0);
            for(var i :int = 0; i < poly.vertices.length - 1; i++) {
                var vertex1 :Vector2 = poly.vertices[ i ] as Vector2;
                var vertex2 :Vector2 = poly.vertices[ i + 1 ] as Vector2;

                if(buffer == 0) {
                    sprite.graphics.moveTo(vertex1.x, vertex1.y);
                    sprite.graphics.lineTo(vertex2.x, vertex2.y);
                }
                else {
                    GraphicsUtil.dashTo(sprite.graphics, vertex1.x, vertex1.y, vertex2.x, vertex2.y);
                }

                sprite.graphics.drawCircle(vertex1.x, vertex1.y, 3);
            }
            var vertexFirst :Vector2 = poly.vertices[ 0 ] as Vector2;
            var vertexLast :Vector2 = poly.vertices[ poly.vertices.length - 1 ] as Vector2;

            if(buffer == 0) {
                sprite.graphics.moveTo(vertexLast.x, vertexLast.y);
                sprite.graphics.lineTo(vertexFirst.x, vertexFirst.y);
            }
            else {
                GraphicsUtil.dashTo(sprite.graphics, vertexLast.x, vertexLast.y, vertexFirst.x, vertexFirst.y);
            }

            sprite.graphics.drawCircle(vertexLast.x, vertexLast.y, 3);
            sprite.graphics.endFill();
            if(buffer != 0) {
               poly.pad(-buffer);
            }
        }

        function drawNode(node :NavMeshNode, sprite :Sprite) :void
        {
            sprite.graphics.lineStyle(1, 0x00cc33, 1);
            for each(var neighbour :NavMeshNode in node.getNeighbors()) {
                var nodePairKey :int = GameUtil.hashForIdPair(node.hashCode(), neighbour.hashCode());
                if(!drawnNodePairs.contains(nodePairKey)) {
                    GraphicsUtil.dashTo(sprite.graphics, node.vector.x, node.vector.y, neighbour.vector.x, neighbour.vector.y);
                    var distanceLabel:TextField= new TextField();
                    if(!mesh._distances.containsKey(GameUtil.hashForIdPair(node._id, neighbour._id))) {
                        distanceLabel.text = "        X";
                    }
                    else {
                        distanceLabel.text = "" + int(mesh._distances.get(GameUtil.hashForIdPair(node._id, neighbour._id)));
                    }
                    distanceLabel.selectable = false;
                    var labelPos :Vector2 = Vector2.interpolate(node, neighbour, 0.5);
                    distanceLabel.x = labelPos.x;
                    distanceLabel.y = labelPos.y;
                    sprite.addChild(distanceLabel);

                    drawnNodePairs.add(nodePairKey);


                }
            }
            sprite.graphics.drawCircle(node.x, node.y, 3);

            var label:TextField= new TextField();
            label.text = " " + node.getNodeId();
            label.selectable = false;
            label.x = node.vector.x;
            label.y = node.vector.y;

            sprite.addChild(label);

        }

    }


    protected function navTest12 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(110, 300);
        var start :Vector2 = new Vector2(195.95343588531367, 244.8525571403164);
        var buffer :int = 168;

        var terrain :Array = new Array();

        terrain.push(NavMeshPolygon.fromRect(350, 420, 100, 350));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);
        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest5 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(40, 40);
        var start :Vector2 = new Vector2(320, 120);
        var buffer :int = 200;
        var terrain :Array = scenario(4);
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));
        var path :PathToFollow = pathfinder.getPath(start, target, buffer);

        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }



    protected function navTest6 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(40, 40);
        var start :Vector2 = new Vector2(40, 240);
        var buffer :int = 30;

        var terrain :Array = new Array();

        terrain.push(NavMeshPolygon.fromRect(-10, 200, 600, 20));
        terrain.push(NavMeshPolygon.fromRect(390, 380, 80, 10));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);

        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest7 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(50, 40);
        var start :Vector2 = new Vector2(60, 240);
        var buffer :int = 100;
        var terrain :Array = scenario(4);
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));
        var path :PathToFollow = pathfinder.getPath(start, target, buffer);
        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest16 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(40, 40);
        var start :Vector2 = new Vector2(40, 240);
        var buffer :int = 100;

        var terrain :Array = new Array();

        terrain.push(NavMeshPolygon.fromRect(-10, 200, 600, 20));
        terrain.push(NavMeshPolygon.fromRect(400, 385, 80, 10));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);

        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest15 (meshSprite :Sprite) :void
    {
        var size :Vector2 = new Vector2(BOARD_SIZE.x, BOARD_SIZE.y);
        BOARD_SIZE.x = 400;
        BOARD_SIZE.y = 400;
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(370, 40);
        var start :Vector2 = new Vector2(40, 370);
        var buffer :int = 100;

        var terrain :Array = new Array();

    //            terrain.push(NavMeshPolygon.fromRect(400, 200, 500, 20));
        terrain.push(NavMeshPolygon.fromRect(0, 300, 500, 20));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);

        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);

        BOARD_SIZE.x = size.x;
        BOARD_SIZE.y = size.y;
    }

    protected function navTest8 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(600, 500);
        var start :Vector2 = new Vector2(600, 250);
        var buffer :int = 100;

        var terrain :Array = new Array();
        terrain.push(NavMeshPolygon.fromRect(850, 350, 800, 50));
        terrain.push(NavMeshPolygon.fromRect(500, 350, 40, 350));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);

        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);

    }

    protected function navTest14 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

//        var target :Vector2 = new Vector2(300, 100);
        var target :Vector2 = new Vector2(450, 250);
        var start :Vector2 = new Vector2(420, 700);
        var buffer :int = 40;

        var terrain :Array = new Array();

        terrain.push(NavMeshPolygon.fromRect(300, 450, 300, 60));
        terrain.push(NavMeshPolygon.fromRect(300, 250, 100, 30));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);

        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest1(meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(310, 120);
        var start :Vector2 = new Vector2(400, 600);
        var buffer :int = 201;

        var terrain :Array = new Array();
//        terrain.push(NavMeshPolygon.fromRect(200, BOARD_SIZE.y - 100, 200, 60));
//        terrain.push(NavMeshPolygon.fromRect(200, BOARD_SIZE.x - 200, BOARD_SIZE.y - 100, 200, 60));
//        terrain.push(NavMeshPolygon.fromRect(200, BOARD_SIZE.x - 200, 100, 200, 60));
//        terrain.push(NavMeshPolygon.fromRect(200, 200, 100, 200, 60));
        terrain.push(new NavMeshPolygon([
//                                        new Vector2(200, 200),
//                                        new Vector2(400, 200),
//                                        new Vector2(400, 400),
//                                        new Vector2(200, 400),


                                        new Vector2(200, 200),
                                        new Vector2(400, 200),
                                        new Vector2(500, 300),
                                        new Vector2(400, 400),
                                        new Vector2(300, 400),
                                        ]).translateLocal(200, 200));

        var isOverlapping :Boolean = true;
//        do {
//            //Check for overlapping.  If we find it, change the terrain, and break.
//
//            isOverlapping = false;
//
//            bothLoops: for each (var p1 :NavMeshPolygon in terrain) {
//                for each (var p2 :NavMeshPolygon in terrain) {
//                    if (p1 == p2) {
//                        continue;
//                    }
//                    if (Geometry.isPolygonsIntersecting(p1.vertices, p1.vertices)) {
//                        ArrayUtil.removeAll(terrain, p1);
//                        ArrayUtil.removeAll(terrain, p2);
//                        trace("Creating union of polygons");
//                        var union :Array = Geometry.unionPolygons(p1.vertices, p2.vertices);
//                        trace("union=" + union);
//                        var navpoly :NavMeshPolygon =
//                            new NavMeshPolygon(union);
//
//                        trace("Removing");
//                        trace(p1.toStringLong());
//                        trace(p2.toStringLong());
//                        trace("Adding");
//                        trace(navpoly.toStringLong());
//                        terrain.push(navpoly);
//                        isOverlapping = true;
//                        break bothLoops;
//                    }
//                }
//            }
//        } while (isOverlapping)
//        trace(terrain);


        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);

        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest9 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(100, 10);
        var start :Vector2 = new Vector2(280, 750);
        var buffer :int = 75;

        var terrain :Array = new Array();
        var width :int = 300;

        terrain.push(NavMeshPolygon.fromRect(BOARD_SIZE.x - 200, BOARD_SIZE.y - 100, width, 60));
        terrain.push(NavMeshPolygon.fromRect(200, BOARD_SIZE.y - 100, width, 60));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));


        var path :PathToFollow = pathfinder.getPath(start, target, buffer);

        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest10 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(40, 40);
        var start :Vector2 = new Vector2(40, 350);
        var buffer :int = 200;

        var terrain :Array = new Array();
        var riverMouthWidth :Number = 200;
        var riverHalfLength :Number = (BOARD_SIZE.x / 2) - (riverMouthWidth / 2);

        terrain.push(NavMeshPolygon.fromRect(riverHalfLength/2, BOARD_SIZE.y/3, riverHalfLength, 50));
        terrain.push(NavMeshPolygon.fromRect(BOARD_SIZE.x - riverHalfLength / 2, BOARD_SIZE.y/3, riverHalfLength, 50));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);
        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest4 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(40, 40);
        var start :Vector2 = new Vector2(340, 460);
        var buffer :int = 500;

        var terrain :Array = new Array();
        terrain.push(NavMeshPolygon.fromRect(300, 300, 300, 300));
        terrain.push(NavMeshPolygon.fromRect(300, 300, 100, 100));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);
        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest13 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(40, 40);
        var start :Vector2 = new Vector2(340, 460);
        var buffer :int = 500;

        var terrain :Array = new Array();

        terrain.push(NavMeshPolygon.fromRect(300, 300, 300, 300));
        terrain.push(NavMeshPolygon.fromRect(500, 500, 100, 100));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);
        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest3 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(40, 170);
        var start :Vector2 = new Vector2(40, 750);
        var buffer :int = 50;

        var terrain :Array = scenario(5);
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));
        var path :PathToFollow = pathfinder.getPath(start, target, buffer);

        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }


    protected function navTest2 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(40, 180);
        var start :Vector2 = new Vector2(40, 750);
        var buffer :int = 50;
        var terrain :Array = new Array();

        terrain.push(NavMeshPolygon.fromRect(-10, 200, 500, 20));
        terrain.push(NavMeshPolygon.fromRect(600, 400, 600, 20));
        terrain.push(NavMeshPolygon.fromRect(-10, 600, 600, 20));
        terrain.push(NavMeshPolygon.fromRect(800, 800, 1000, 20));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);

        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest11 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(130, 180);
        var start :Vector2 = new Vector2(130, 750);
        var buffer :int = 350;
        var terrain :Array = new Array();

        terrain.push(NavMeshPolygon.fromRect(-10, 200, 600, 20));
        terrain.push(NavMeshPolygon.fromRect(800, 400, 1000, 20));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));

        var path :PathToFollow = pathfinder.getPath(start, target, buffer);

        drawNavMesh(meshSprite, pathfinder.navMesh, path, start, target);
    }

    protected function navTest17 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(110, 300);
        var start :Vector2 = new Vector2(222.901133137304, 221.9154921433647);
        var buffer :int = 168;

        var terrain :Array = new Array();
        terrain.push(NavMeshPolygon.fromRect(350, 420, 100, 350));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));


        var path :PathToFollow = pathfinder.getPath(start, target, buffer);
        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }

    protected function navTest18 (meshSprite :Sprite) :void
    {
        var pathfinder :NavMeshPathFinder = new NavMeshPathFinder(BOARD_SIZE.x, BOARD_SIZE.y);

        var target :Vector2 = new Vector2(110, 300);
        var start :Vector2 = new Vector2(343.1099633926767, 146.57854798993506);
        var buffer :int = 168;

        var terrain :Array = new Array();
        terrain.push(NavMeshPolygon.fromRect(350, 420, 100, 350));
        terrain.forEach(Util.adapt(pathfinder.addNavMeshPolygon));
        var path :PathToFollow = pathfinder.getPath(start, target, buffer);
        drawNavMesh(meshSprite, pathfinder.navMesh, path, start , target);
    }


    protected static function scenario (scenarioCode :int) :Array
    {
        if( scenarioCode >= 1 && scenarioCode <= TERRAIN_SCENARIOS) {
            return TestNavigationMeshPathfinding["scenario" + scenarioCode]();
        }
        return [];
    }

    protected static function scenario1 () :Array//Bridge over river
    {
        var terrain :Array = new Array();

        var riverMouthWidth :Number = 150;
        var riverHalfLength :Number = (BOARD_SIZE.x / 2) - (riverMouthWidth / 2);
        terrain.push(NavMeshPolygon.fromRect(riverHalfLength/2, BOARD_SIZE.y/2, riverHalfLength, 50));
        terrain.push(NavMeshPolygon.fromRect(BOARD_SIZE.x - riverHalfLength / 2, BOARD_SIZE.y/2, riverHalfLength, 50));
        return terrain;
    }

    protected static function scenario2() :Array
    {
        var terrain :Array = new Array();
        terrain.push(NavMeshPolygon.fromRect(BOARD_SIZE.x / 2, BOARD_SIZE.y / 2, 250, 150));
        return terrain;
    }

    protected static function scenario3 () :Array//Castle
    {

        var terrain :Array = new Array();
        var riverMouthWidth :Number = 200;
        var riverHalfLength :Number = (BOARD_SIZE.x / 2) - (riverMouthWidth / 2);

        terrain.push(NavMeshPolygon.fromRect(riverHalfLength/2, BOARD_SIZE.y/3, riverHalfLength, 50));
        terrain.push(NavMeshPolygon.fromRect(BOARD_SIZE.x - riverHalfLength / 2, BOARD_SIZE.y/3, riverHalfLength, 50));

        return terrain;
    }

    protected static function scenario4 () :Array
    {
        var terrain :Array = new Array();
        terrain.push(NavMeshPolygon.fromRect(-10, 200, 600, 20));
        terrain.push(NavMeshPolygon.fromRect(390, 380, 80, 10));
        return terrain;
    }

    protected static function scenario5 () :Array//Maze
    {
        var terrain :Array = new Array();

        terrain.push(NavMeshPolygon.fromRect(-10, 200, 600, 20));
        terrain.push(NavMeshPolygon.fromRect(800, 400, 1000, 20));
        terrain.push(NavMeshPolygon.fromRect(-10, 600, 600, 20));
        terrain.push(NavMeshPolygon.fromRect(800, 800, 1000, 20));

        return terrain;
    }

    protected var TESTS :Array = [
                                            navTest1,
                                            navTest2,
                                            navTest3,
                                            navTest4,
                                            navTest5,
                                            navTest6,
                                            navTest7,
                                            navTest8,
                                            navTest9,
                                            navTest10,
                                            navTest11,
                                            navTest12,
                                            navTest13,
                                            navTest14,
                                            navTest15,
                                            navTest16,
                                            navTest17,
                                            navTest18,
                                            ];

    protected static const BOARD_SIZE :Point = new Point(1000, 1000);
    public static const TERRAIN_SCENARIOS :int = 5;


}
}
