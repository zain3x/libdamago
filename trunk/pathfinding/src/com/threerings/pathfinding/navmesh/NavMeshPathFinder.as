package com.threerings.pathfinding.navmesh
{
    import com.threerings.geom.Vector2;
    import com.threerings.util.Util;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.Point;

    import com.threerings.pathfinding.PathToFollow;
    import com.threerings.pathfinding.astar.Astar;
    import com.threerings.pathfinding.astar.SearchResults;

    /**
    * Adapter for the NavMesh pathfinding system.
    *
    */
    public class NavMeshPathFinder extends EventDispatcher
    {
        public static const DRAW_MESH :String = "Draw Mesh";

        protected var _navMesh :NavMesh;
        protected var _currentPath :Array;
        protected var _border :Number;
        protected var _boardSize :Point;

        public function NavMeshPathFinder(boundsX :Number = 500, boundsY :Number = 500, border :int = 0)
        {
            _navMesh = new NavMesh();
            _navMesh.setBounds(border, border, boundsX - border * 2, boundsY - border * 2);
            _border = border;
            _boardSize = new Point(boundsX, boundsY);
        }

        public function addNavMeshPolygon (poly :NavMeshPolygon) :void
        {
            _navMesh.addPolygon(poly);
        }


        /**
        * @poly : an array of Vector2 objects, assumed to be a convex polygon.
        */
        public function addPolygon (poly :Array) :void
        {
            _navMesh.addPolygon(new NavMeshPolygon(poly));
        }
//
//        public function setTerrain(terrain :Array) :void
//        {
//            for each(var tr :TerrainPiece in terrain) {
////                trace("adding to navmesh: terrain " + tr);
//                _navMesh.addRect(tr._centerX, tr._centerY, tr._width, tr._height, tr._movementPenalty, tr._padOuter);
//            }
//
////            _navMesh.checkAndRemoveIntersectingEdges();
////            _navMesh.checkForMissingEdges();
//        }
        public function getPath(from :Vector2, target :Vector2, padding :Number = 1,
            keepNodesInsideBounds :Boolean = false) :PathToFollow
        {
            _navMesh.removeAllNodes();

            _navMesh._paddedPolygon2Polygon.clear();
            _navMesh._polygon2PaddedPolygon.clear();



            var paddedPolygons :Array = _navMesh._polygonsAll.map(
                function (element:NavMeshPolygon, ...ignored) :NavMeshPolygon {
                    var paddedPoly :NavMeshPolygon = element.clone();

//                    var width :Number = Geometry2.boundingBoxOfVerticesWidth(element.vertices);
//                    var height :Number = Geometry2.boundingBoxOfVerticesHeight(element.vertices);

//                    var minPenalty :Number = (width + height) / (Math.sqrt(Math.pow(width, 2) + Math.pow(height, 2)));
//                    var minPenalty :Number = 2*(width + height);
//
//                    minPenalty *= 1.2;
//                    paddedPoly.movementCost = minPenalty;//Math.max(1, element.movementCost/(1*padding));//Reduce the movement cost of the buffer so that it's prefereable to move around the obstacle
                    paddedPoly.movementCost = element.movementCost;//Math.max(1, element.movementCost/(1*padding));//Reduce the movement cost of the buffer so that it's prefereable to move around the obstacle
                    _navMesh._paddedPolygon2Polygon.put(paddedPoly, element);
                    _navMesh._polygon2PaddedPolygon.put(element, paddedPoly);
                    return paddedPoly;
                });
//            paddedPolygons.forEach(padPolygons);



            //This logic is confusing
            var originalPolygons :Array = _navMesh._polygonsAll;
            var allPolygons :Array = originalPolygons.concat(paddedPolygons) ;
            _navMesh._polygonsAll = paddedPolygons;


            _navMesh.padPolygons(padding);
//            var verticesBuffer :Number = 20;
//            trace("shinkng polygons");
            _navMesh.shrinkPolygons();
            if (keepNodesInsideBounds) {
                _navMesh.allPolygonPointsInsideBounds(_border, _boardSize.x - _border, _border, _boardSize.y - _border, padding);
            }
//            trace("allPolygonPointsInsideBounds");
//            trace("reAddPolygonNodesAndEdges");
            _navMesh.reAddPolygonNodesAndEdges();
//            trace("total nodes=" + _navMesh._nodes.length);
//            _navMesh.copyPolygonNodesAndEdges();
            var fromNode :NavMeshNode = _navMesh.addNode(_navMesh.createNode(from.x, from.y));
            var toNode :NavMeshNode = _navMesh.addNode(_navMesh.createNode(target.x, target.y));
            _navMesh._start = fromNode;
            _navMesh._target = toNode;

//            trace("checking the from node for edges:" + fromNode.getNeighbors());


            _navMesh._polygonsAll = allPolygons;
            _navMesh.checkAndRemoveIntersectingEdges();
            _navMesh.ifNodeIsEnclosedByAPolygonAddNodeAtTheClosestPointOnThePolygonAndCreateAnEdge(fromNode);
            _navMesh.ifNodeIsEnclosedByAPolygonAddNodeAtTheClosestPointOnThePolygonAndCreateAnEdge(toNode);
            _navMesh.removeEdgesOutOfBounds();
            _navMesh.checkForMissingEdges();
            _navMesh.removeEdgesOfPaddedIntersectingParentTerrain();

//            _navMesh.addEdge(fromNode, toNode);
//            _navMesh.removeEdgesOutIntersectingOriginalPolygons();

            var shortestEdgeLength :Number = padding;//Number.MAX_VALUE;
//            _navMesh._paddedPolygon2Polygon.keys().forEach(Util.adapt(function (p :NavMeshPolygon) :void {
//                shortestEdgeLength = Math.min(shortestEdgeLength, p.shortestEdgeLength);
//            }));

//            trace("fromNode=" +fromNode);
//            trace("after padding navmesh=" + _navMesh);
//            _navMesh._polygonsAll = originalPolygons;

//                _navMesh.padPolygons(-padding, false);
//            _navMesh.padPolygons(-padding, false);
//            trace("start getNeighbors()=" + fromNode.getNeighbors());
            var pathToFollow :PathToFollow = new PathToFollow();

            var astar :Astar = new Astar(_navMesh);

            //Extra safetey
//            _navMesh.padPolygons(5);
            var searchResults :SearchResults = astar.search(fromNode, toNode);
//            _navMesh.padPolygons(-5);//Remove extra safety

//            _navMesh._polygonsAll = _navMesh._polygonsAll.concat(originalPolygons);
            _navMesh._polygonsAll = originalPolygons;
//            trace("searchResults.getIsSuccess()=" + searchResults.getIsSuccess());
            if(! searchResults.getIsSuccess()) {
                //Panic
//                _navMesh.removeAllNodes();
//                if(padding != 0) {
//                    _navMesh.padPolygons(-padding , false);
//                }
                _navMesh._polygonsAll = originalPolygons;
                return pathToFollow;
            }
            var path :Array = searchResults.getPath().getNodes();

//            trace("pathToFollow=" + path);
//            _navMesh._polygons = originalPolygons;
//            _navMesh._polygonsAll = originalPolygons;
//            _navMesh.padPolygons(10);
//            _navMesh._polygonsAll = allPolygons;
//            path = _navMesh.postProcessPath(path, padding);
//            _navMesh._polygonsAll = originalPolygons;
//            _navMesh.padPolygons(-10);
//            _navMesh.padPolygons(-padding);


            for each(var v :Vector2 in path) {
                pathToFollow.addPathPoint(v.x, v.y);
            }


            pathToFollow = pathToFollow.addBezierCurvature(2, shortestEdgeLength);

            _currentPath = path;

//            trace("returning path, polygons=" + _navMesh._polygons.length);

//            _navMesh.padPolygons(-padding, false);
            dispatchEvent(new Event(NavMeshPathFinder.DRAW_MESH));

//            _navMesh.removeNode(fromNode);
//            _navMesh.removeNode(toNode);

//            _navMesh.removeAllNodes();

//            trace("restoring padding");
//            if(padding != 0) {
//                _navMesh.padPolygons(-padding, false);
//
//            }
//            trace("getPath, afetr removing units and restoring padding, pathToFollow=" + pathToFollow);



            _navMesh._polygonsAll = originalPolygons;

            return pathToFollow;


            function padPolygons(element:NavMeshPolygon, index:int, arr:Array):void {
                element.pad(padding);
            }
            function unPadPolygons(element:NavMeshPolygon, index:int, arr:Array):void {
                element.pad(-padding);
            }
        }





        public function getPath2(from :Vector2, target :Vector2, padding :Number = 0) :PathToFollow
        {
//            trace("getPath from=" + from + ", to=" + target);
//            trace("navmesh=" + _navMesh);
//

//            trace("navmesh=" + _navMesh);

//            trace("adding units");
            var fromNode :NavMeshNode = _navMesh.addNode(_navMesh.createNode(from.x, from.y));
            var toNode :NavMeshNode = _navMesh.addNode(_navMesh.createNode(target.x, target.y));

//            trace("adding padding=" + padding);
            if(padding != 0) {
                _navMesh.padPolygons(padding, true);
            }
//            trace("after padding navmesh=" + _navMesh);
//            trace("start getNeighbors()=" + fromNode.getNeighbors());
            var pathToFollow :PathToFollow = new PathToFollow();

            var astar :Astar = new Astar(_navMesh);
            var searchResults :SearchResults = astar.search(fromNode, toNode);


//            trace("searchResults.getIsSuccess()=" + searchResults.getIsSuccess());
            if(! searchResults.getIsSuccess()) {
                //Panic
                _navMesh.removeNode(fromNode);
                _navMesh.removeNode(toNode);
                if(padding != 0) {
                    _navMesh.padPolygons(-padding , false);
                }
                _navMesh.checkAndRemoveIntersectingEdges();
                _navMesh.checkForMissingEdges();
                return pathToFollow;
            }
            var path :Array = searchResults.getPath().getNodes();
//            trace("path=" + path);
//            path = _navMesh.postProcessPath(path);
//            trace("after processing path=" + path);

            for each(var v :Vector2 in path) {
                pathToFollow.addPathPoint(v.x, v.y);
            }

            _currentPath = pathToFollow.path;

            dispatchEvent(new Event(NavMeshPathFinder.DRAW_MESH));

            _navMesh.removeNode(fromNode);
            _navMesh.removeNode(toNode);

//            trace("restoring padding");
            if(padding != 0) {
                _navMesh.padPolygons(-padding, false);

            }
//            trace("getPath, afetr removing units and restoring padding, navmesh=" + _navMesh);
//            trace("pathToFollow=" + pathToFollow);
            return pathToFollow;

        }

        public function get navMesh () :NavMesh
        {
            return _navMesh;
        }

    }
}
