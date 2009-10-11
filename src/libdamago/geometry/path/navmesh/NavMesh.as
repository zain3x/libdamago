package libdamago.geometry.path.navmesh
{
    import com.threerings.geom.Vector2;
    import com.threerings.com.threerings.util.ArrayUtil;
    import com.threerings.util.Map;
    import com.threerings.util.Maps;
    import com.threerings.util.MathUtil;

    import flash.geom.Rectangle;

    import libdamago.geometry.LineSegment;
    import libdamago.geometry.Polygon;
    import libdamago.geometry.VectorUtil;
    import libdamago.geometry.path.astar.INode;
    import libdamago.geometry.path.astar.ISearchable;

    import com.threerings.util.GameUtil;

    public class NavMesh implements ISearchable
    {
        protected var _allowOverlappingBuffers :Boolean;

        public var _nodes :Array;
        public var _polygonsAll :Array;
        public var _polygon2PaddedPolygon :Map = Maps.newMapOf(Polygon);
        public var _paddedPolygon2Polygon :Map = Maps.newMapOf(Polygon);

        public var _bounds :Rectangle;
        public var _boundsPolygon :Polygon;

        public var _distances :Map = Maps.newMapOf(Polygon);

        protected var _nextId :int = 0;

        public var _start :NavMeshNode;
        public var _target :NavMeshNode;

        public function NavMesh(allowOverlappingBuffers :Boolean = true)// width :Number, height :Number)
        {
            _allowOverlappingBuffers = allowOverlappingBuffers;
            _nodes = new Array();
            _polygonsAll = new Array();
        }

        public function get nextId() :int
        {
            return _nextId++;
        }

        public function reAddPolygonNodesAndEdges() :void
        {
            for each(var p :NavMeshPolygon in _polygonsAll) {
                addPolygonNodesToNavMesh(p);
                createEdgesForPolygon(p);
            }
        }

        public function setBounds(x :Number, y :Number, w :Number, h :Number) :void
        {
            _bounds = new Rectangle(x, y, w, h);
            _boundsPolygon = Polygon.polygonFromBoundingBox(_bounds);
        }

        public function getBounds() :Rectangle
        {
            return _bounds;
        }

        /**
         * Gets the node for a specific row/column combo.
         * @param   Column that the node is in.
         * @param   Row that the node is in.
         * @return The INode instance.
         */
        public function getNodeUnder (x :Number, y :Number) :INode
        {
            return null;
        }
        /**
         * Gets the terrain transition cost between one node type and another.
         * @param   The first node.
         * @param   The second node.
         * @return The transition cost.
         */
        public function getNodeTransitionCost (n1:INode, n2:INode) :Number
        {
//            return 1;
//            var v1 :Vector2 = NavigationMeshNode(n1).vector;
//            var v2 :Vector2 = NavigationMeshNode(n2).vector;
            var distance :Number = getMovementCost(NavMeshNode(n1), NavMeshNode(n2));
//            _distances.put(GameUtil.getIdForIdPair(n1.getNodeId(), n2.getNodeId()), distance);
            return distance;
//            return MathUtil.distance(n1.getNodeCenter().x, n1.getNodeCenter().y, n2.getNodeCenter().x, n2.getNodeCenter().y);
        }

        public function ifNodeIsEnclosedByAPolygonAddNodeAtTheClosestPointOnThePolygonAndCreateAnEdge(node :NavMeshNode) :void
        {
            var n: NavMeshNode;
            var v :Vector2;
//            trace("ifNodeIsEnclosedByAPolygonAddNodeAtTheClosestPointOnThePolygonAndCreateAnEdge, " + node);
            for each(var polygon :NavMeshPolygon in _polygonsAll) {

//                trace("  Distance=" + Geometry.distToPolygonEdge(node, polygon.vertices) + " from " + node + " to " + polygon);

                if (polygon.isPointInside(node) || polygon.distToPolygonEdge(node) == 0) {
                    trace("    " + node + " is contained by " + polygon);


                    var midpoints :Polygon = polygon.getAllEdgeMidpointsAsPolygon();
                    midpoints.padLocal(2);
                    for each(v in midpoints.vertices) {
                        n = new NavMeshNode(v.x, v.y);
                        addNode(n);
                        addEdge(node, n);
                    }

                    trace("polygon.closestEdge(" + node + ")=" + polygon.closestEdge(node));
                    var closestPoint :Vector2 = polygon.closestEdge(node).closestPointTo(node);
//                    trace("polygon.closestPoint=" + closestPoint);
                    if (closestPoint != null) {
                        var angle :Number = VectorUtil.angleFromVectors(node, closestPoint);
                        v = Vector2.fromAngle(angle, VectorUtil.distance(closestPoint, node) + 0).addLocal(node);
                        n = new NavMeshNode(v.x, v.y);
                        addNode(n);
                        addEdge(node, n);
                    }

//                    for each(n in polygon.vertices) {
//                        addEdge(node, n);
//                    }


//                    var rayLength :Number = 10000;
//                    var pointsToRadiate :Array = [
////                            new Vector2(node.x, node.y + rayLength), //northPoint
////                            new Vector2(node.x, node.y - rayLength), //southPoint
////                            new Vector2(node.x + rayLength, node.y), //eastPoint
////                            new Vector2(node.x - rayLength, node.y), //westPoint
////                            new Vector2(node.x + rayLength, node.y - rayLength), //northeastPoint
////                            new Vector2(node.x - rayLength, node.y - rayLength), //northwestPoint
////                            new Vector2(node.x + rayLength, node.y + rayLength), //southeastPoint
////                            new Vector2(node.x - rayLength, node.y + rayLength) //southwestPoint
//                    ];
//
//                    for each(var rayPoint :Vector2 in pointsToRadiate) {
//                        for(var k :int = 0; k < polygon.vertices.length - 1; k++) {
//                            var intersectionPoint :Vector2 = LineSegment.lineIntersectLine(node, rayPoint, polygon.vertices[k], polygon.vertices[k + 1]);
//                            if (intersectionPoint != null) {
//
//                                var angle :Number = VectorUtil.angleFromVectors(node, intersectionPoint);
//                                var length :Number = VectorUtil.distance(node, intersectionPoint) + 5;
//                                v = Vector2.fromAngle(angle, length);
//                                v = node.add(v);
//                                n = new NavMeshNode(v.x, v.y);
//                                addNode(n);
//                                addEdge(node, n);
//                            }
//                        }
//                    }
//                    continue;
                }
            }
        }


        public function addRect(xCenter :Number, yCenter :Number, w :Number, h :Number, movementPenalty :Number = 1, padOuter :Boolean = true) :NavMeshPolygon
        {
            var rect :NavMeshPolygon = new NavMeshPolygon(
                                                [
                                                    new Vector2(xCenter - w/2, yCenter - h/2),
                                                    new Vector2(xCenter + w/2, yCenter - h/2),
                                                    new Vector2(xCenter + w/2, yCenter + h/2),
                                                    new Vector2(xCenter - w/2, yCenter + h/2),
                                                ],
                                                movementPenalty,
                                                padOuter);
            return addPolygon(rect);
        }
        public function addPolygon (newpoly :NavMeshPolygon) :NavMeshPolygon
        {

//            trace("adding polygon=" + newpoly.toStringLong());
            var node :NavMeshNode;
            var newNode :NavMeshNode;
            var newNodes :Array;
            var poly :NavMeshPolygon;
            var v :Vector2;
            var k :int;
            //The first polygon defines the map
            _polygonsAll.push(newpoly);


            //"Vibrate" polygon, add small random value to the vertices.  This helps
            //avoid vertices lying exactly on edges.
//            function randomiseVertex(v :Vector2, ...ignored) :void
//            {
//                v.x += Rand.nextNumberRange(-0.01, 0.01, 0);
//                v.y += Rand.nextNumberRange(-0.01, 0.01, 0);
//            }
//            newpoly.vertices.forEach(randomiseVertex);


            if (_polygonsAll.length == 1) {
                //Just add the vertices of this polygon to the node list
//                node = new NavigationMeshNode(poly);

                newNodes = createEdgesAndNodesDefiningPolygon(newpoly);
                _nodes = _nodes.concat(newNodes);
            }
            else {
                //First check which edges it breaks, and remove them
                if (newpoly.vertices.length > 1) {

                    checkAndRemoveIntersectingEdges();
//                    for each(var vertex :NavMeshNode in _nodes) {
//
//                        var neighbours :Array = vertex.getNeighbors().slice();
//                        var removed :Array = new Array();
//
//                        for each(var neighbourVertex :NavMeshNode in neighbours) {
//
//                            var isPolygonEdge :Boolean = false;
//                            for each (poly in _polygons) {
//                                if (poly.containsNodes(vertex, neighbourVertex)) {
//                                    isPolygonEdge = true;
//                                    break;
//                                }
//                            }
//                            if (!isPolygonEdge && isLineIntersectingPolygon(vertex, neighbourVertex, newpoly)) {
//                                //Only remove it if it's not a polygon edge
//                                removeEdge(vertex, neighbourVertex);
//                            }
//                        }
//                    }
                }


                newNodes = createEdgesAndNodesDefiningPolygon(newpoly);

                //Then check all vertices for edges with the new vertices in the new polygon
                //Create the new vertices
//                var newVertices :Array = new Array();

                for each(newNode in newNodes) {
                    for each(node in _nodes) {

                        if (newNode == node) {
                            continue;
                        }
                        if (_bounds != null) {
                            if (!_bounds.contains(newNode.x, newNode.y) || !_bounds.contains(node.x, node.y)) {
                                continue;
                            }
                        }

//                        trace("checking " + newNode.vector + " - " + node.vector);
                        if (!isEdgeIntersectingPolygons(newNode, node, _polygonsAll)) {
                            addEdge(newNode, node);
                        }
                    }
                }

                //Add the polygon nodes to the list
                _nodes = _nodes.concat(newNodes);
//                node = new NavigationMeshNode(poly);

//                _nodes.push(node);

                //When no more polygons intersect, add the new polygon inside the containing polygon
                //Create new edges and polygons representing the new Geometry.

            }
//            trace("newNodes.length=" + newNodes.length);
//            trace("_nodes.length=" + _nodes.length);
//            trace("_nodes=" + _nodes);

            return newpoly;
        }

        protected function isEdgeIntersectingPolygons (node1 :NavMeshNode, node2 :NavMeshNode,
            polygons :Array) :Boolean
        {
            var line :LineSegment = new LineSegment(node1, node2);
            for each (var poly :NavMeshPolygon in polygons) {
//                var isConnected :Boolean = LineSegment.isConnected(node1, node2, line.a, line.b);
    //!isConnected &&
                if (poly.isLineIntersecting(line.a, line.b)) {
//                    if (!isConnected) {
//                        trace("not connected ", node1, node2, line.a, line.b);
//                    }
//                    trace("intersecting " + poly);
                    return true;
                }
            }
            return false;
        }



       protected function isEdgeContainedByPolygons (node1 :NavMeshNode, node2 :NavMeshNode) :Boolean
        {
            for each (var poly :NavMeshPolygon in _polygonsAll) {
                if (poly.isPointInside(node1) && poly.isPointInside(node2)) {
                    return true;
                }
            }
            return false;
        }

        protected function isEdgePartOfAPolygon (node1 :NavMeshNode, node2 :NavMeshNode) :Boolean
        {
            for each (var poly :NavMeshPolygon in _polygonsAll) {
                if (poly.isEdge(node1, node2)) {
                    return true;
                }
            }
            return false;
        }

        protected function createEdgesAndNodesDefiningPolygon(shape :NavMeshPolygon) :Array
        {
            //Create the new nodes
            var nodes :Array = new Array();

            for each(var node :NavMeshNode in shape.vertices) {
//                var node :NavigationMeshNode = createNode(vertex);
//                node.setNodeId(nextId);
                nodes.push(node);
            }

            //Make edges of the perimeter of the polygon
            createEdgesForPolygon(shape);
            return nodes;
        }

        protected function createEdgesForPolygon(poly :NavMeshPolygon) :void
        {
            //Make edges of the perimeter of the polygon
            if (nodes.length > 1) {
                for(var k :int = 0; k < poly.vertices.length - 1; k++) {
                    addEdge(poly.vertices[k], poly.vertices[k + 1]);
                }
                addEdge(poly.vertices[0], poly.vertices[poly.vertices.length - 1]);
            }
        }

        protected function addPolygonNodesToNavMesh(poly :NavMeshPolygon) :void
        {
            for(var k :int = 0; k < poly.vertices.length; k++) {
                var node :NavMeshNode = poly.vertices[k] as NavMeshNode;
                if (node._id == 0) {
                    node._id = nextId;
                }
                addNode(node);
            }
        }


        public function addEdge(n1 :NavMeshNode, n2 :NavMeshNode) :void
        {
            if (!ArrayUtil.contains(n1.getNeighbors(), n2)) {
                n1.getNeighbors().push(n2);
            }
            if (!ArrayUtil.contains(n2.getNeighbors(), n1)) {
                n2.getNeighbors().push(n1);
            }
        }

        protected function removeEdge(n1 :NavMeshNode, n2 :NavMeshNode) :void
        {
            if (ArrayUtil.contains(n1.getNeighbors(), n2)) {
                ArrayUtil.removeAll(n1.getNeighbors(),  n2);
            }
            if (ArrayUtil.contains(n2.getNeighbors(), n1)) {
                ArrayUtil.removeAll(n2.getNeighbors(),  n1);
            }
        }

        public function get nodes () :Array
        {
            return _nodes;
        }

//        protected function isLineIntersectingPolygon(A :NavMeshNode, B :NavMeshNode, poly :NavMeshPolygon) :Boolean
//        {
//            return Geometry.isLineIntersectingPolygon(A.vector, B.vector, poly.vertices);
//        }

        public function getNodeClosestTo (x :Number, y :Number, tiebreaker :Vector2 = null)
            :NavMeshNode
        {
            var currentNode :NavMeshNode = _nodes[0] as NavMeshNode;
            var currentDistance :Number = MathUtil.distance(x, y, currentNode.vector.x,
                currentNode.vector.y);
            for each(var node :NavMeshNode in _nodes.slice(1)) {

                var distance :Number = MathUtil.distance(x, y, node.vector.x, node.vector.y);
                if (distance < currentDistance) {
                    currentDistance = distance;
                    currentNode = node;
                }
                else if (distance == currentDistance && tiebreaker != null) {
                    //If distances are equal, use the tiebreaker
                    if (MathUtil.distance(node.vector.x, node.vector.y, tiebreaker.x, tiebreaker.y) <
                        MathUtil.distance(currentNode.vector.x, currentNode.vector.y, tiebreaker.x,
                            tiebreaker.y)) {
                            currentDistance = distance;
                            currentNode = node;
                        }
                }
            }
            return currentNode;
        }

        public function createNode (nodeX :Number, nodeY :Number) :NavMeshNode
        {
            return new NavMeshNode(nodeX, nodeY);
        }

        public function addNode (node :NavMeshNode) :NavMeshNode
        {
            if (!ArrayUtil.contains(_nodes, node)) {
                _nodes.push(node);
            }
            return node;
        }

        public function removeNode (node :NavMeshNode) :void
        {
            if (ArrayUtil.contains(_nodes, node)) {
                ArrayUtil.removeAll(_nodes, node);

                var neighbours :Array = node.getNeighbors().slice();
                for each(var neighbour :NavMeshNode in neighbours) {
                    removeEdge(node, neighbour);
                }
            }
        }

        protected function checkNodeForEdges (node1 :NavMeshNode) :Array
        {
            var newNeighbours :Array = new Array();
//            trace("\n  checkNodeForEdges " + node1);
            for each(var node2 :NavMeshNode in _nodes) {
//                trace("         checking against " + node2);
                if (node1 == node2) {
//                    trace("     node equal " + node2);
                    continue;
                }

                if (ArrayUtil.contains(node1.getNeighbors(), node2)) {
//                    trace("     already neighbours " + node2);
                    continue;
                }

                if (_bounds != null) {
                    if (!_bounds.contains(node1.x, node1.y) || !_bounds.contains(node2.x, node2.y)) {
//                        trace("      not within bounds " + node1 + " or " + node2 + ", bounds=" + _bounds);
                        continue;
                    }
                }

                //!isEdgePartOfAPolygon(node1, node2) &&
                //Check if intersecting any polygons.
                trace("[" + node1 + ", " + node2 + "], isEdgeIntersectingPolygons=" +
                    isEdgeIntersectingPolygons(node1, node2, _polygonsAll) +
                    ", isEdgeContainedByPolygons=" + isEdgeContainedByPolygons(node1, node2));
                if (!isEdgeIntersectingPolygons(node1, node2, _polygonsAll) && !isEdgeContainedByPolygons(node1, node2)) {
//                    trace("     adding edge [" + node1 + ", " + node2 + "]");
                    addEdge(node1, node2);
                    newNeighbours.push(node2);
                }
                else {
                    if (isEdgeIntersectingPolygons(node1, node2, _polygonsAll)) {
                        //Double check

//                        trace("           edge intersecting polygon " + Geometry.isObjectOverlappingSegment(node1, node2, _polygons[0].vertices));
//                        trace("     polygon=" + _polygons[0]);
                    }
                    if (isEdgeContainedByPolygons(node1, node2)) {
//                        trace("           edge contained by polygon");
                    }
                }
            }
            return newNeighbours;
        }

        /**
        * You should call
        * checkForMissingEdges();
        * and
        * checkAndRemoveIntersectingEdges()
        * after this call.
        * I haven't included these methods in the function because sometimes you may
        * want to add or remove many polygons at once.
        *
        */
        public function removePolygon (polyToRemove :NavMeshPolygon) :void
        {
            ArrayUtil.removeAll(_polygonsAll, polyToRemove);
            for each(var polyNode :NavMeshNode in polyToRemove.vertices) {
                for each(var nodeNeighbour :NavMeshNode in polyNode.getNeighbors().slice()) {
                    removeEdge(polyNode, nodeNeighbour);
                }
                ArrayUtil.removeAll(_nodes, polyNode);
            }
        }

        public function checkForMissingEdges () :void
        {
            for each(var node1 :NavMeshNode in _nodes) {
                checkNodeForEdges(node1);
            }
        }

        public function checkAndRemoveIntersectingEdges () :void
        {
            for each(var vertex :NavMeshNode in _nodes) {

                var neighbours :Array = vertex.getNeighbors().slice();

                for each(var neighbourVertex :NavMeshNode in neighbours) {

                    if (isEdgePartOfAPolygon(vertex, neighbourVertex)) {
                        continue;
                    }

                    if (isEdgeIntersectingPolygons(vertex, neighbourVertex, _polygonsAll)) {
                        removeEdge(vertex, neighbourVertex);
                    }
                    else if (isEdgeContainedByPolygons(vertex, neighbourVertex)) {
                        removeEdge(vertex, neighbourVertex);
                    }
                    else
                    //If either point is outside the bounds, make the distance MAX_VALUE;
                    if (_bounds != null) {
                        if (!_bounds.contains(vertex.x, vertex.y) || !_bounds.contains(neighbourVertex.x, neighbourVertex.y)) {
                            removeEdge(vertex, neighbourVertex);
                        }
                    }
                }
            }
        }

        public function removeEdgesOutOfBounds () :void
        {
            if (_bounds == null) {
                return;
            }
            for each(var vertex :NavMeshNode in _nodes) {

                var neighbours :Array = vertex.getNeighbors().slice();
                for each(var neighbourVertex :NavMeshNode in neighbours) {
                    if (!_bounds.contains(vertex.x, vertex.y) || !_bounds.contains(neighbourVertex.x, neighbourVertex.y)) {
                        removeEdge(vertex, neighbourVertex);
                    }
                }
            }
        }
        public function removeEdgesOutIntersectingOriginalPolygons () :void
        {
            for each(var vertex :NavMeshNode in _nodes) {

                var neighbours :Array = vertex.getNeighbors().slice();
                for each(var neighbourVertex :NavMeshNode in neighbours) {
                    if (isEdgeIntersectingPolygons(vertex, neighbourVertex, _polygon2PaddedPolygon.keys())) {
                        removeEdge(vertex, neighbourVertex);
                    }
                }
            }
        }


        /**
        * Pad polygons, whereby all polygons are enlarged by <padding>.  This ensures that
        * a big fat pathfinder will not hit the walls.  This can be a negative number to unpad.
        */
        public function padPolygons(padding :Number, performChecksAnCorrections :Boolean = false) :void
        {
            for each(var poly :NavMeshPolygon in _polygonsAll) {
                poly.padLocal(padding);
            }
            if (performChecksAnCorrections) {
                checkForMissingEdges();
                checkAndRemoveIntersectingEdges();
            }
        }


        public function shrinkPolygons() :void
        {
            var polygonPairsIntersecting :Array = new Array();
            var paddedPolygonsToCheck :Array = _paddedPolygon2Polygon.keys();

            var paddingReductionPerStep :Number = 2;
            var p1 :NavMeshPolygon;
            var p2 :NavMeshPolygon;

            var p1Original :NavMeshPolygon;
            var p2Original :NavMeshPolygon;

            for(var i :int = 0; i < paddedPolygonsToCheck.length - 1; i++) {
                for(var j :int = i + 1; j < paddedPolygonsToCheck.length; j++) {
                    p1 = paddedPolygonsToCheck[i] as NavMeshPolygon;
                    p2 = paddedPolygonsToCheck[j] as NavMeshPolygon;
                    p1Original = _paddedPolygon2Polygon.get(p1) as NavMeshPolygon;
                    p2Original = _paddedPolygon2Polygon.get(p2) as NavMeshPolygon;
                    /* We reduce the overlap between the buffers of polygons.  However, we ignore
                     *  the case where the original polygons overlap because there is no buffer region to shrink.*/
                    if (p1.isIntersection(p2) && !p1Original.isIntersection(p2Original)) {
                        polygonPairsIntersecting.push([p1, p2]);
                    }
                }
            }

            while(polygonPairsIntersecting.length > 0) {

//                trace("\npolygonPairsIntersecting.length=" + polygonPairsIntersecting.length + "\n");
                for each(var polygonPairs :Array in polygonPairsIntersecting) {
//                    var cloneOfP1 :NavMeshPolygon = polygonPairs[0].clone();
                    p1 = polygonPairs[0] as NavMeshPolygon;
                    p2 = polygonPairs[1] as NavMeshPolygon;
                    p1Original = _paddedPolygon2Polygon.get(p1) as NavMeshPolygon;
                    p2Original = _paddedPolygon2Polygon.get(p2) as NavMeshPolygon;

                    var intersectionPolygon :Polygon = p1.getIntersectionPolygon(p2);
//                    trace("intersectionPolygon=" + intersectionPolygon);
                    if (intersectionPolygon == null) {// || Geometry.boundingBoxOfVerticesWidth(intersectionPolygon) <= 2 || Geometry.boundingBoxOfVerticesHeight(intersectionPolygon) <= 2) {
                        continue;
                    }
//                    trace("intersectionPolygon.length=" + intersectionPolygon.length);
                    var middleNode :Vector2 = new Vector2(NavMeshPolygon.horizontalMidPoint(p1Original, p2Original), NavMeshPolygon.verticalMidPoint(p1Original, p2Original));
//                    if (intersectionPolygon.length >= 2) {//!!!!!!!!Changed due to null pointer but haven't checked logic
//                        middleNode = Vector2.interpolate(intersectionPolygon[0], intersectionPolygon[1], 0.5);
//                    }
//                    Geometry.getPolygonCenter(intersectionPolygon);

//                    var isVerticalIntersection : Boolean = Geometry.isVerticalIntersection((_paddedPolygon2Polygon.get(p1) as NavMeshPolygon).vertices, (_paddedPolygon2Polygon.get(p2) as NavMeshPolygon).vertices)
                    var isVerticalIntersection : Boolean = NavMeshPolygon(_paddedPolygon2Polygon.get(p1)).isVerticalIntersection(_paddedPolygon2Polygon.get(p2) as NavMeshPolygon);
                    var isHorizontalIntersection : Boolean = NavMeshPolygon(_paddedPolygon2Polygon.get(p1)).isHorizontalIntersection(_paddedPolygon2Polygon.get(p2) as NavMeshPolygon);
//                    trace("  isVerticalIntersection=" + isVerticalIntersection);
//                    trace("  isHorizontalIntersection=" + isHorizontalIntersection);

//                    trace("Shrinking distance between " + p1Original + " and  " + p2Original);
//                    trace("  middleNode=" + middleNode);

                    var p1center :Vector2 = p1Original.center;//Was padded
                    var p2center :Vector2 = p2Original.center;

                    /*
                    * If the padded polygons overlap we need to shrink them, otherwise the pathfindng will be rubbish.
                    *  But we don't shrink the polygons indiscriminately.
                    */
                    var p1bounds :Rectangle = p1.boundingBox;
                    var p2bounds :Rectangle = p2.boundingBox;
                    if (isVerticalIntersection && isHorizontalIntersection) {


                        if (p1center.y < p2center.y) {//p1 is above p2, show shrink appropriate sides
                            if (p1bounds.bottom >= middleNode.y) {
                                shrinkSouthSide(p1, paddingReductionPerStep);
                            }

                            if (p2bounds.top <= middleNode.y) {
                                shrinkNorthSide(p2, paddingReductionPerStep);
                            }
                        }
                        else {

                            if (p2bounds.bottom >= middleNode.y) {
                                shrinkSouthSide(p2, paddingReductionPerStep);
                            }
                            if (p1bounds.top <= middleNode.y) {
                                shrinkNorthSide(p1, paddingReductionPerStep);
                            }
                        }

                        if (p1center.x < p2center.x) {//p1 is left of p2, show shrink appropriate sides
                            if (p1bounds.right >= middleNode.x) {
                                shrinkEastSide(p1, paddingReductionPerStep);
                            }
                            if (p2bounds.left <= middleNode.x) {
                                shrinkWestSide(p2, paddingReductionPerStep);
                            }
                        }
                        else {
                            if (p2bounds.right >= middleNode.x) {
                                shrinkEastSide(p2, paddingReductionPerStep);
                            }
                            if (p1bounds.left <= middleNode.x) {
                                shrinkWestSide(p1, paddingReductionPerStep);
                            }
                        }
                    }
                    else {
                        if (isVerticalIntersection) {
                            if (p1center.x < p2center.x) {//p1 is left of p2, show shrink appropriate sides
                                if (p1bounds.right >= middleNode.x) {
                                    shrinkEastSide(p1, paddingReductionPerStep);
                                }
                                if (p2bounds.left <= middleNode.x) {
                                    shrinkWestSide(p2, paddingReductionPerStep);
                                }
                            }
                            else {
                                if (p2bounds.right >= middleNode.x) {
                                    shrinkEastSide(p2, paddingReductionPerStep);
                                }
                                if (p1bounds.left <= middleNode.x) {
                                    shrinkWestSide(p1, paddingReductionPerStep);
                                }
                            }
                        }
                        else {//if (!isHorizontalIntersection) {



                            if (p1center.y < p2center.y) {//p1 is above p2, show shrink appropriate sides
                                if (p1bounds.bottom >= middleNode.y) {
                                    shrinkSouthSide(p1, paddingReductionPerStep);
                                }
                                if (p2bounds.top <= middleNode.y) {
                                    shrinkNorthSide(p2, paddingReductionPerStep);
                                }
                            }
                            else {
                                if (p2bounds.bottom >= middleNode.y) {
                                    shrinkSouthSide(p2, paddingReductionPerStep);
                                }
                                if (p1bounds.top <= middleNode.y) {
                                    shrinkNorthSide(p1, paddingReductionPerStep);
                                }
                            }
                        }

                    }
                }

                polygonPairsIntersecting = polygonPairsIntersecting.filter(function isStillIntersecting(element :Array, ...ignored) :Boolean
                                                {
                                                    var paddedPolygon1 :NavMeshPolygon = element[0] as NavMeshPolygon;
                                                    var paddedPolygon2 :NavMeshPolygon = element[1] as NavMeshPolygon;

                                                    var originalPolygon1 :NavMeshPolygon = _paddedPolygon2Polygon.get(element[0]) as NavMeshPolygon;
                                                    var originalPolygon2 :NavMeshPolygon = _paddedPolygon2Polygon.get(element[1]) as NavMeshPolygon;

                                                    if (!paddedPolygon1.isIntersection(paddedPolygon2)) {
                                                        return false;
                                                    }

                                                    var intersectionPolygon :Polygon = paddedPolygon1.getIntersectionPolygon(paddedPolygon2);
                                                    var bounds :Rectangle = intersectionPolygon == null ? new Rectangle() : intersectionPolygon.boundingBox;

                                                    var maxSize :Number = Math.max(bounds.height, bounds.width);
                                                    var maxArea :Number = maxSize * 5;
                                                    var area :Number = bounds.width * bounds.height;
                                                    if (area <= maxArea) {
                                                        return false;
                                                    }
//                                                    trace("\n   paddedPolygon1=" + paddedPolygon1.toStringLong());
//                                                    trace("   paddedPolygon2=" + paddedPolygon2.toStringLong());
//                                                    trace("   intersectionPolygon=" + intersectionPolygon)
//                                                    if (intersectionPolygon != null && intersectionPolygon.length  >= 3){// || Geometry.boundingBoxOfVerticesWidth(intersectionPolygon) <= 2 || Geometry.boundingBoxOfVerticesHeight(intersectionPolygon) <= 2) {
//                                                        return true;
//                                                    }

//                                                    /*We don't count intersections of overlapping original polygons. */
                                                    if (paddedPolygon1.isHorizontalIntersection(paddedPolygon2) && !originalPolygon1.isHorizontallyContained(originalPolygon2)) {
//                                                        trace("isHorizontalIntersection");
                                                        return true;
                                                    }

                                                    //if (Geometry.isVerticalIntersection(paddedPolygon1.vertices, paddedPolygon1.vertices) && !Geometry.isVerticalContained(originalPolygon1.vertices, originalPolygon2.vertices)) {
                                                    if (paddedPolygon1.isVerticalIntersection(paddedPolygon2) && !originalPolygon1.isVerticalContained(originalPolygon2)) {
//                                                        trace("isVerticalIntersection");
                                                        return true;
                                                    }
                                                    return false;
                                                });

            }

            function shrinkEastSide(Vs :NavMeshPolygon, amount :Number) :void
            {
//                trace("     shrinkEastSide");
                Vs.maxX = Vs.maxX - amount;
//                Geometry.makeAllPointsLessThanX(Vs, maxX);
            }
            function shrinkWestSide(Vs :NavMeshPolygon, amount :Number) :void
            {
                Vs.minX = Vs.minX + amount;
//                var minX :Number = Geometry.minX(Vs) + amount;
//                Geometry.makeAllPointsMoreThanX(Vs, minX);
            }
            function shrinkNorthSide(Vs :NavMeshPolygon, amount :Number) :void
            {
                Vs.minY = Vs.minY + amount;
//                var minY :Number = Geometry.minY(Vs) + amount;
//                Geometry.makeAllPointsMoreThanY(Vs, minY);
            }
            function shrinkSouthSide(Vs :NavMeshPolygon, amount :Number) :void
            {
                Vs.maxY = Vs.maxY - amount;
//                var maxY :Number = Geometry.maxY(Vs) - amount;
//                Geometry.makeAllPointsLessThanY(Vs, maxY);
            }
        }


        public function shrinkPolygonSidesSoTheyDoNotTouch(p1 :NavMeshPolygon, p2 :NavMeshPolygon, bufferReduction :Number) :void
        {

            var intersectionPolygon :Polygon = p1.getIntersectionPolygon(p2);
            var middleNode :Vector2 = intersectionPolygon.center;

            //Check intersections of original (unpadded) polygons.
            var isVerticalIntersection : Boolean = NavMeshPolygon(_paddedPolygon2Polygon.get(p1)).isVerticalIntersection(_paddedPolygon2Polygon.get(p2) as NavMeshPolygon);
            var isHorizontalIntersection : Boolean = NavMeshPolygon(_paddedPolygon2Polygon.get(p1)).isHorizontalIntersection(_paddedPolygon2Polygon.get(p2) as NavMeshPolygon);
            //If there is a both a horizontal and vertical intersection, shrink the axis where the reduction is least.
            if (isVerticalIntersection && isHorizontalIntersection) {
                var verticalShrinkageIsLeastP1 :Boolean = getDistanceFromMiddlePointToVerticalShrinkageSide(middleNode, p1) < getDistanceFromMiddlePointToHorizontalShrinkageSide(middleNode, p1);

                if (verticalShrinkageIsLeastP1) {
                    shrinkVertically(middleNode, p1.vertices);
                }
                else {
                    shrinkHorizontally(middleNode, p1.vertices);
                }

                var verticalShrinkageIsLeastP2 :Boolean = getDistanceFromMiddlePointToVerticalShrinkageSide(middleNode, p2) < getDistanceFromMiddlePointToHorizontalShrinkageSide(middleNode, p2);

                if (verticalShrinkageIsLeastP2) {
                    shrinkVertically(middleNode, p2.vertices);
                }
                else {
                    shrinkHorizontally(middleNode, p2.vertices);
                }
            }
            else {
                if (isVerticalIntersection) {
//                    trace("one ply above the other");
                    //Shrink along the y axis
                    trace("EEERR...not finished");
                    shrinkHorizontally(middleNode, p1.vertices);
                    shrinkHorizontally(middleNode, p2.vertices);
//                    shrinkSidesSoPointIsNotInsidePolygon(middleNode, p2.vertices, false);
//                    shrinkSidesSoPointIsNotInsidePolygon(middleNode, p1.vertices, false);
                }
                else {//if (!isHorizontalIntersection) {
//                    trace("one ply NOT above the other");
                    //Shrink along the x axis
                    if (p1.center.y < p2.center.y) {//p1 is above p2
                        shrinkSouthSide(p1.vertices, bufferReduction);
                        shrinkNorthSide(p2.vertices, bufferReduction);
                    }
                    else {
                        shrinkSouthSide(p2.vertices, bufferReduction);
                        shrinkNorthSide(p1.vertices, bufferReduction);
                    }
//                    shrinkVertically(middleNode, p1.vertices);
//                    shrinkVertically(middleNode, p2.vertices);
//                    shrinkSidesSoPointIsNotInsidePolygon(middleNode, p2.vertices, true);
//                    shrinkSidesSoPointIsNotInsidePolygon(middleNode, p1.vertices, true);
                }

            }

            function shrinkVertically(middleNode :Vector2, polygon :Array) :void
            {
                shrinkSidesSoPointIsNotInsidePolygon(middleNode, p2.vertices, false);
                shrinkSidesSoPointIsNotInsidePolygon(middleNode, p1.vertices, false);
            }
            function shrinkHorizontally(middleNode :Vector2, polygon :Array) :void
            {
                shrinkSidesSoPointIsNotInsidePolygon(middleNode, p2.vertices, true);
                shrinkSidesSoPointIsNotInsidePolygon(middleNode, p1.vertices, true);
            }


            function shrinkEastSide(Vs :NavMeshPolygon, amount :Number) :void
            {
                Vs.maxX = Vs.maxX - amount;
            }
            function shrinkWestSide(Vs :NavMeshPolygon, amount :Number) :void
            {
                Vs.minX = Vs.minX + amount;
            }
            function shrinkNorthSide(Vs :NavMeshPolygon, amount :Number) :void
            {
                Vs.minY = Vs.minY + amount;
            }
            function shrinkSouthSide(Vs :NavMeshPolygon, amount :Number) :void
            {
                Vs.maxY = Vs.maxY - amount;
            }

            function shrinkSidesSoPointIsNotInsidePolygon(point :Vector2, p :NavMeshPolygon,
                onlyX :Boolean) :void
            {
                var polycenter :Vector2 = p.center;//Geometry.getPolygonCenter(p);
//                trace("polycenter=" + polycenter);
                p.vertices.forEach(function(v :Vector2, ...ignored) :void {
//                    trace("v=" + v);
                    if (onlyX) {
                        if (polycenter.x < point.x) {
                            if (v.x > point.x) {
                                v.x -= bufferReduction;
                            }
                        }
                        else if (polycenter.x > point.x) {
                            if (v.x < point.x) {
                                v.x += bufferReduction;
                            }
                        }
                    }
                    else {
                        if (polycenter.y < point.y) {
                            if (v.y > point.y) {
                                v.y -= bufferReduction;
                            }
                        }
                        else if (polycenter.y > point.y) {
                            if (v.y < point.y) {
                                v.y += bufferReduction;
                            }
                        }
                    }
                });
            }

            function getDistanceFromMiddlePointToHorizontalShrinkageSide(point :Vector2, p :NavMeshPolygon) :Number
            {
                var polycenter :Vector2 = p.center;
                if (polycenter.x < point.x) {
                    return Math.abs(p.maxX - point.x);
                }
                else {
                    return Math.abs(p.minX - point.x);
                }
            }
            function getDistanceFromMiddlePointToVerticalShrinkageSide(point :Vector2, p :NavMeshPolygon) :Number
            {
                var polycenter :Vector2 = p.center;
                if (polycenter.y < point.y) {
                    return Math.abs(p.maxX - point.x);
                }
                else {
                    return Math.abs(p.minX - point.x);
                }
            }
        }


//        public function shrinkPolygonSidesSoTheyDoNotTouchOLD(p1 :NavMeshPolygon, p2 :NavMeshPolygon, middleNode :Vector2, cloneOfOriginalp1 :NavMeshPolygon, cloneOfOriginalp2 :NavMeshPolygon) :void
//        {
//            trace("shrinkPolygonSidesSoTheyDoNotTouch oringinals:\n   " + _paddedPolygon2Polygon.get(p1) + "\n   "+ _paddedPolygon2Polygon.get(p2));
//
//            _paddedPolygon2Polygon.get(p1)
////            trace("shrinkPolygonSidesSoTheyDoNotTouch:\n   " + p1 + "\n   "+ p2);
////            var intersectionPolygon :Array = Geometry.getIntersectionPolygon(p1.vertices, p2.vertices);
////
////            var middleNode :Vector2 = Geometry.getPolygonCenter(intersectionPolygon);
//
//            trace("middleNode=" + middleNode);
////            trace("containedPoints=" + containedPoints);
//
//            //Check intersections of original (unpadded) polygons.
//            var isVerticalIntersection : Boolean = Geometry.isVerticalIntersection((_paddedPolygon2Polygon.get(p1) as NavMeshPolygon).vertices, (_paddedPolygon2Polygon.get(p2) as NavMeshPolygon).vertices)
//            var isHorizontalIntersection :Boolean = Geometry.isHorizontalIntersection((_paddedPolygon2Polygon.get(p1) as NavMeshPolygon).vertices, (_paddedPolygon2Polygon.get(p2) as NavMeshPolygon).vertices);
//            //If there is a both a horizontal and vertical intersection, shrink the axis where the reduction is least.
//            if (isVerticalIntersection && isHorizontalIntersection) {
//                var verticalShrinkageIsLeastP1 :Boolean = getDistanceFromMiddlePointToVerticalShrinkageSide(middleNode, cloneOfOriginalp1.vertices) < getDistanceFromMiddlePointToHorizontalShrinkageSide(middleNode, cloneOfOriginalp1.vertices);
//
//                if (verticalShrinkageIsLeastP1) {
//                    shrinkVertically(middleNode, p1.vertices);
//                }
//                else {
//                    shrinkHorizontally(middleNode, p1.vertices);
//                }
//
//                var verticalShrinkageIsLeastP2 :Boolean = getDistanceFromMiddlePointToVerticalShrinkageSide(middleNode, cloneOfOriginalp2.vertices) < getDistanceFromMiddlePointToHorizontalShrinkageSide(middleNode, cloneOfOriginalp2.vertices);
//
//                if (verticalShrinkageIsLeastP2) {
//                    shrinkVertically(middleNode, p2.vertices);
//                }
//                else {
//                    shrinkHorizontally(middleNode, p2.vertices);
//                }
//            }
//            else {
//                if (isVerticalIntersection) {
////                    trace("one ply above the other");
//                    //Shrink along the y axis
//                    shrinkHorizontally(middleNode, p1.vertices);
//                    shrinkHorizontally(middleNode, p2.vertices);
////                    shrinkSidesSoPointIsNotInsidePolygon(middleNode, p2.vertices, false);
////                    shrinkSidesSoPointIsNotInsidePolygon(middleNode, p1.vertices, false);
//                }
//                else {//if (!isHorizontalIntersection) {
////                    trace("one ply NOT above the other");
//                    //Shrink along the x axis
//                    shrinkVertically(middleNode, p1.vertices);
//                    shrinkVertically(middleNode, p2.vertices);
////                    shrinkSidesSoPointIsNotInsidePolygon(middleNode, p2.vertices, true);
////                    shrinkSidesSoPointIsNotInsidePolygon(middleNode, p1.vertices, true);
//                }
//
//            }
//
//            function shrinkVertically(middleNode :Vector2, polygon :Array) :void
//            {
//                shrinkSidesSoPointIsNotInsidePolygon(middleNode, p2.vertices, false);
//                shrinkSidesSoPointIsNotInsidePolygon(middleNode, p1.vertices, false);
//            }
//            function shrinkHorizontally(middleNode :Vector2, polygon :Array) :void
//            {
//                shrinkSidesSoPointIsNotInsidePolygon(middleNode, p2.vertices, true);
//                shrinkSidesSoPointIsNotInsidePolygon(middleNode, p1.vertices, true);
//            }
//
//
//
//            function shrinkSidesSoPointIsNotInsidePolygon(point :Vector2, p :Array, onlyX :Boolean) :void
//            {
//                var polycenter :Vector2 = Geometry.getPolygonCenter(p);
////                trace("polycenter=" + polycenter);
//                p.forEach(function(v :Vector2, ...ignored) :void {
////                    trace("v=" + v);
//                    if (onlyX) {
//                        if (polycenter.x < point.x) {
//                            v.x = Math.min(v.x, point.x - 1);
//                        }
//                        else if (polycenter.x > point.x) {
//                            v.x = Math.max(v.x, point.x + 1);
//                        }
//                    }
//                    else {
//                        if (polycenter.y < point.y) {
//                            v.y = Math.min(v.y, point.y - 1);
//                        }
//                        else if (polycenter.y > point.y) {
//                            v.y = Math.max(v.y, point.y + 1);
//                        }
//                    }
//                });
//            }
//
//            function getDistanceFromMiddlePointToHorizontalShrinkageSide(point :Vector2, p :Array) :Number
//            {
//                var polycenter :Vector2 = Geometry.getPolygonCenter(p);
//                if (polycenter.x < point.x) {
//                    return Math.abs(Geometry.maxX(p) - point.x);
//                }
//                else {
//                    return Math.abs(Geometry.minX(p) - point.x);
//                }
//            }
//            function getDistanceFromMiddlePointToVerticalShrinkageSide(point :Vector2, p :Array) :Number
//            {
//                var polycenter :Vector2 = Geometry.getPolygonCenter(p);
//                if (polycenter.y < point.y) {
//                    return Math.abs(Geometry.maxX(p) - point.x);
//                }
//                else {
//                    return Math.abs(Geometry.minX(p) - point.x);
//                }
//            }
//
//
////            trace("   after changes:\n  " + p1 + "\n  " + p2);
//        }

        public function allPolygonPointsInsideBounds(minX :Number, maxX :Number, minY :Number, maxY:Number, buffer :Number) :void
        {
//            for each(var p :NavMeshPolygon in _polygonsAll) {
//                for each(var v :NavMeshNode in p.vertices) {
//                    v.x = MathUtil.clamp(v.x, minX + buffer, maxX - buffer);
//                    v.y = MathUtil.clamp(v.y, minY + buffer, maxY- buffer);
//                }
//            }

            //Also make sure the buffer polygon edges are no more than halfway between the original polygon and the edge
            //If the original polygon edge is also within the bounds
            _paddedPolygon2Polygon.forEach(
                function(paddedPolygon :NavMeshPolygon, originalPolygon :NavMeshPolygon) :void
                {
//                    for each(var v :NavMeshNode in paddedPolygon.vertices) {
//                        v.x = MathUtil.clamp(v.x, minX + buffer, maxX - buffer);
//                        v.y = MathUtil.clamp(v.y, minY + buffer, maxY - buffer);
//                    }
//                    return;
                    var targetValue :Number;
//                    var tempBound :Number;

                    var polygonMinX :Number = originalPolygon.minX;
                    var polygonMaxX :Number = originalPolygon.maxX;
                    var polygonMinY :Number = originalPolygon.minY;
                    var polygonMaxY :Number = originalPolygon.maxY;


//                    var polygonMinX :Number = Geometry.minX(paddedPolygon.vertices);
//                    var polygonMaxX :Number = Geometry.maxX(paddedPolygon.vertices);
//                    var polygonMinY :Number = Geometry.minY(paddedPolygon.vertices);
//                    var polygonMaxY :Number = Geometry.maxY(paddedPolygon.vertices);


//                    trace("polygon minX, maxX, minY, maxY=" + polygonMinX + ", " + polygonMaxX + ", " + polygonMinY + ", " + polygonMaxY);

                    var distanceWesBetweentPaddedAndBounds :Number = paddedPolygon.minX - minX;
                    if (distanceWesBetweentPaddedAndBounds < buffer) {//polygonMinX > minX &&
//                        trace("polygonMinX=" + polygonMinX);
//                        trace("minX=" + minX);
//                        trace(Math.abs(polygonMinX - minX) / 2);
                        targetValue = polygonMinX - Math.abs(polygonMinX - minX) / 2;
                        /* Check for vertices still being outside bounds*/
                        if (targetValue < minX) {
                            targetValue = polygonMaxX - Math.abs(polygonMaxX - minX) / 2;
                        }
//                        trace("west targetvalue=" + targetValue);
                        paddedPolygon.minX = targetValue;
//                        Geometry.makeAllPointsMoreThanX(paddedPolygon.vertices, targetValue);
//                        trace("makeAllPointsMoreThanX=" + targetValue);
                    }
//                    trace("after west bounds check, polygon=" + paddedPolygon);

                    var distanceEastBeyweenPaddedAndBounds :Number = maxX - paddedPolygon.maxX;
//                    trace("distanceEastBeyweenPaddedAndBounds=" + distanceEastBeyweenPaddedAndBounds);
                    if (distanceEastBeyweenPaddedAndBounds < buffer) {// polygonMaxX < maxX &&
                        targetValue = polygonMaxX + Math.abs(polygonMaxX - maxX) / 2;


                        /* Check for vertices still being outside bounds*/
                        if (targetValue > maxX) {
                            targetValue = polygonMinX + Math.abs(polygonMinX - maxX) / 2;
                        }


//                        trace("maxX=" + maxX);
//                        trace("polygonMaxX=" + polygonMaxX);
//                        trace("east targetvalue=" + targetValue);
                        paddedPolygon.maxX = targetValue;
//                        Geometry.makeAllPointsLessThanX(paddedPolygon.vertices, targetValue);
//                        trace("makeAllPointsLessThanX=" + targetValue);
                    }
//                    trace("after east bounds check, polygon=" + paddedPolygon.toStringLong());

                    var distanceNorthBeyweenPaddedAndBounds :Number = Math.abs(minY - paddedPolygon.minY);
                    if (distanceNorthBeyweenPaddedAndBounds < buffer) {//polygonMinY > minY &&
                        targetValue = polygonMinY - Math.abs(polygonMinY - minY) / 2;

                        /* Check for vertices still being outside bounds*/
                        if (targetValue < minY) {
                            targetValue = polygonMaxY - Math.abs(polygonMaxY - minY) / 2;
                        }
                        paddedPolygon.minY = targetValue;
//                        Geometry.makeAllPointsMoreThanY(paddedPolygon.vertices, targetValue);
                    }
//                    trace("after north bounds check, polygon=" + paddedPolygon);

                    var distanceSouthBeyweenPaddedAndBounds :Number = Math.abs(maxY - paddedPolygon.maxY);
                    if (distanceSouthBeyweenPaddedAndBounds < buffer) {//polygonMaxY < maxY &&
                        targetValue = polygonMaxY + Math.abs(polygonMaxY - maxY) / 2;

                        /* Check for vertices still being outside bounds*/
                        if (targetValue > maxY) {
                            targetValue = polygonMinY - Math.abs(polygonMinY - maxY) / 2;
                        }

//                        trace("south targetvalue=" + targetValue);
                        paddedPolygon.maxY = targetValue;
//                        Geometry.makeAllPointsLessThanY(paddedPolygon.vertices, targetValue);
//                        trace("makeAllPointsLessThanY=" + targetValue);
                    }
//                    trace("after south bounds check, polygon=" + paddedPolygon);

                });

        }


        /**ø
        * This step allows variable movement penalties for the polygons, so that is can be possible
        * to move through a given polygon (skip nodes) if the penalty is less than going around.
        */
        public function postProcessPath(path :Array, radius :Number = 0) :Array
        {
//            trace("postProcessPath, path=" + path);
            var index :int;
            var modifiedPath :Array = new Array();//Contains the indices of the original path
            for(index = 0; index < path.length; index++) {
                modifiedPath.push(index);
            }
//            _distances.clear();
//            trace("modifiedPath=" + modifiedPath);
            //Stores distances between nodes, in the form ["" + index1 + "+" + index2]
//            var distanceMap :HashMap = new HashMap();

            function getMovementCostFromMap(nodeIndex1 :int, nodeIndex2 :int, radius :Number = 0) :Number
            {
                var key :int = GameUtil.hashForIdPair(nodeIndex1, nodeIndex2);
                if (!_distances.containsKey(key)) {

                    var movementCost :Number = getMovementCostFromAWithRadiusToB(path[nodeIndex1], radius, path[nodeIndex2], false);
                    if (isNaN(movementCost)) {
                        movementCost = Number.MAX_VALUE;
                    }
                    trace(path[nodeIndex1] + " " + path[nodeIndex2] + " distance=" + movementCost);
                    _distances.put(key, movementCost);
                    return movementCost;

//                    trace("    recomputing " + path[nodeIndex1] + " and " + path[nodeIndex2]);
                    var movementCostMiddle :Number = getMovementCost(path[nodeIndex1], path[nodeIndex2]);
                    movementCostMiddle = Math.max(Vector2.distance(path[nodeIndex1], path[nodeIndex2]), movementCostMiddle);

//                    var movementCost :Number = movementCostMiddle;//Math.max(Math.max(movementCostMiddle, movementCostClockwise), movementCostCClockwise);

                    if (radius != 0) {



                        //When computing the distances for path-shortening, take into account the radius
                        var angle :Number = GameUtil.angleFromVectors(path[nodeIndex1], path[nodeIndex2]);
                        var vectorClockwiseHalfPiV1 :Vector2 = Vector2(path[nodeIndex1]).addPolarVector(angle + Math.PI, radius);
                        var vectorCClockwiseHalfPiV1 :Vector2 = Vector2(path[nodeIndex1]).addPolarVector(angle - Math.PI, radius);

//                        var vectorClockwiseHalfPiV2 :Vector2 = Vector2(path[nodeIndex2]).addPolarVector(angle + Math.PI, radius);
//                        var vectorCClockwiseHalfPiV2 :Vector2 = Vector2(path[nodeIndex2]).addPolarVector(angle - Math.PI, radius);

                        //If the radii (or width or arms)  of the points do not fall within bounds, set them equal to the closest point within the bounds.
                        function makeSecondPointWithinPoints(A :Vector2, B :Vector2) :void //A guranteed to be within bounds, B?
                        {
                            if (!_bounds.contains(B.x, B.y)) {
                                var intersectingPoints :Array = _boundsPolygon.getIntersectionPoints(A, B);
//                                var intersectingPoints :Array = Geometry.getPointsWhereLineIntersectsPolygon(A, B, _boundsPolygon);
                                if (intersectingPoints.length > 0) {
                                    B.x = Vector2(intersectingPoints[0]).x
                                    B.y = Vector2(intersectingPoints[0]).y;
                                }
                                else {
//                                    trace("Error, B should be outside of bounds but no intersection found");
                                    B.x = A.x;
                                    B.y = A.y;
                                }
                            }

                        }
                        makeSecondPointWithinPoints(path[nodeIndex1], vectorClockwiseHalfPiV1);
                        makeSecondPointWithinPoints(path[nodeIndex1], vectorCClockwiseHalfPiV1);
//                        makeSecondPointWithinPoints(path[nodeIndex2], vectorClockwiseHalfPiV2);
//                        makeSecondPointWithinPoints(path[nodeIndex2], vectorCClockwiseHalfPiV2);

                        var movementCostClockwise :Number = getMovementCostForVectors(vectorClockwiseHalfPiV1, path[nodeIndex2]);
//                        var movementCostClockwise :Number = getMovementCostForVectors(vectorClockwiseHalfPiV1, vectorClockwiseHalfPiV2);
                        movementCostClockwise = Math.max(movementCostClockwise, movementCostMiddle);
//                        trace("       movementCostClockwise=" + movementCostClockwise);

//                        var movementCostCClockwise :Number = getMovementCostForVectors(vectorCClockwiseHalfPiV1, vectorCClockwiseHalfPiV2);
                        var movementCostCClockwise :Number = getMovementCostForVectors(vectorCClockwiseHalfPiV1, path[nodeIndex2]);
                        movementCostCClockwise = Math.max(movementCostCClockwise, movementCostMiddle);
//                        trace("       movementCostCClockwise=" + movementCostCClockwise);

                        movementCost = Math.max(movementCostClockwise, movementCostCClockwise, movementCost);


//                        if (movementCostClockwise < movementCostMiddle && movementCostCClockwise < movementCostMiddle) {
//                            movementCost = Math.min(movementCostClockwise, movementCostCClockwise);
//                        }
                    }

//                    var distance :Number = Vector2.distance(path[nodeIndex1], path[nodeIndex2]);
//                    movementCost = Math.max(distance, movementCost);
                    if (isNaN(movementCost)) {
                        movementCost = Number.MAX_VALUE;
                    }
                    _distances.put(key, movementCost);
                }
//                trace("getMovementCost(" + path[nodeIndex1] + ", " + path[nodeIndex2] + ")=" + _distances.get(key));
                return _distances.get(key);
            }

//            function pathIntersectsTerrain(nodeStartIndex :int, nodeEndIndex :int) :Boolean
//            {
//                for(var n :int = nodeStartIndex; n < nodeStartIndex; n++) {
//                    var nodeIndex1 :int = modifiedPath[middleIndex];
//                    var nodeIndex2 :int = modifiedPath[middleIndex + 1];
//
//                    var node1 :Vector2 = path[nodeIndex1] as Vector2;
//                    var node2 :Vector2 = path[nodeIndex2] as Vector2;
//                    for each (var poly :NavMeshPolygon in _polygons) {
//                        if (Geometry.isObjectOverlappingSegment(node1, node2, poly.vertices)) {
//                            return true;
//                        }
//
//                    }
//                }
//                return false;
//            }


            var checkFromTheBeginningAgain :Boolean = true;
            while(checkFromTheBeginningAgain) {
                //Look at every windows of at least three nodes.  If the cost between the first and last is less
                //than with the moddle nodes(s), takining into account costs of moving over polygons (terrain)
                //remove the middle node(s), and start the search again.
                checkFromTheBeginningAgain = false;

                //Starting at the end
                for(var modifiedPathStartIndex :int = 0; modifiedPathStartIndex < modifiedPath.length - 2; modifiedPathStartIndex++) {

                    for(var modifiedPathEndIndex :int = modifiedPathStartIndex + 2; modifiedPathEndIndex < modifiedPath.length; modifiedPathEndIndex++) {

//                        var sb :StringBuilder = new StringBuilder("\n[");
//                        for (var iii :int = modifiedPathStartIndex; iii <= modifiedPathEndIndex; iii++) {
//                            sb.append(path[modifiedPath[iii]] + ", ");
//                        }
//                        sb.append("]");
//                        trace(sb.toString());

//                        trace("path=" + modifiedPath);
//                        trace("modifiedPathStartIndex=" + modifiedPathStartIndex);
//                        trace("modifiedPathEndIndex=" + modifiedPathEndIndex);

                        var movementCostWithoutMiddleNodes :Number = getMovementCostFromMap(modifiedPath[modifiedPathStartIndex] , modifiedPath[modifiedPathEndIndex], radius);
                        var movementCostWithMiddleNodes :Number = 0;

                        for(var middleIndex :int = modifiedPathStartIndex + 1; middleIndex <= modifiedPathEndIndex; middleIndex++) {
//                            trace("   middleIndex=" + middleIndex);
                            movementCostWithMiddleNodes += getMovementCostFromMap(modifiedPath[middleIndex], modifiedPath[middleIndex - 1], radius);
                        }

                        if (movementCostWithoutMiddleNodes < movementCostWithMiddleNodes && movementCostWithoutMiddleNodes < 100000) {// && pathIntersectsTerrain(modifiedPathStartIndex + 1, modifiedPathEndIndex)) {
//                        trace("       splicing node from path");
//                        trace("        movementCostWithMiddleNodes=" + movementCostWithMiddleNodes);
//                        trace("        movementCostWithoutMiddleNodes=" + movementCostWithoutMiddleNodes);
                        //add t distance to see dostances on visualization
                            var indicesToRemove :Array = modifiedPath.slice(modifiedPathStartIndex + 1, modifiedPathEndIndex);
                            indicesToRemove.splice(modifiedPathStartIndex + 1, modifiedPathEndIndex - (modifiedPathStartIndex + 1));
//                            trace("       indicesToRemove=" +indicesToRemove);
                            for each(var indexToRemove :int in indicesToRemove) {

//                                trace("         removing from path=" + path[indexToRemove]);
                                ArrayUtil.removeAll(modifiedPath, indexToRemove);
                            }

//                            trace("after removal, path=" + modifiedPath);
                            if (modifiedPath.length > 2) {
                                checkFromTheBeginningAgain = true;
                            }
                            break;
                        }
                    }
                    if (checkFromTheBeginningAgain) {
                        break;
                    }
                }
            }


            for (var k :int = 0; k < modifiedPath.length - 1; k++) {
                 addEdge(path[k], path[k + 1]);
            }


            var processedPath :Array = new Array();
            for each (var nodeIndex :int in modifiedPath) {
                processedPath.push(path[nodeIndex]);
            }
            return processedPath;
        }



        public static function XXXconvertPathToCurve(path :Array, intervalsBetweenPoints :Number = 50) :Array
        {
            trace("!!!DOESN'T WORK YET!!!convertPathToCurve, path=" + path);
            var curvedPath :Array = new Array();

//            var start :Vector2 = path[0] as Vector2;
//            var end :Vector2 = path[path.length - 1] as Vector2;
//
//            var smoothcurve :SmoothCurve = new SmoothCurve(start.toPoint(), end.toPoint());
//
//            for(var k :int = 1; k < path.length - 1; k++) {
//                smoothcurve.pushControl(Vector2(path[k]).toPoint());
//            }
//
//            for(k = 0; k <= 400; k++) {
//                var p :Point = smoothcurve.getPointByDistance(k);
//
//                curvedPath.push(new Vector2(p.x, p.y));
//            }
            return curvedPath;


//
//            for(var k :int = 0; k < path.length - 2; k++) {
//                var v1 :Vector2 = path[k] as Vector2;
//                var v2 :Vector2 = path[k + 1] as Vector2;
//                var v3 :Vector2 = path[k + 2] as Vector2;
//
////                curvedPath.push(v1);
//
//                var bezier :Bezier = new Bezier(new Point(v1.x, v1.y),
//                                                    new Point(v2.x, v2.y),
//                                                    new Point(v3.x, v3.y), true);
//
//                trace("bezier=" + bezier);
//                //Interpolate between the values
////                var xIncrement :Number = (v3.x - v1.x) / intervalsBetweenPoints;
////                var yIncrement :Number = (v3.y - v1.y) / intervalsBetweenPoints;
//                var p :Point = new Point();
//
////                for(var increment :int = 0; increment < intervalsBetweenPoints; increment++) {
////
//
////[0, 0.1, 0.2, 0.3, 0.4, 0.5]
////[1.0, 0.9, 0.8, 0.7, 0.6, 0.5]
//                for each (var increment :Number in [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]) {
//                    bezier.getPoint(increment, p);
//                    trace("adding=" + p);
////                    bezier.getPoint(1 - (increment/intervalsBetweenPoints) * 0.5, p);
//                    curvedPath.push(new Vector2(p.x, p.y));
//                }
//            }
//            curvedPath.push(path[ path.length - 1]);
//            return curvedPath;
        }


        public function removeAllNodes() :void
        {
//            trace("removeAllNodes");
            for each(var node :NavMeshNode in _nodes) {
                var neighbours :Array = node.getNeighbors().slice();
                for each(var neighbour :NavMeshNode in neighbours) {
                    removeEdge(node, neighbour);
                }
            }
            _nodes.splice(0);
        }

        public function copyPolygonNodesAndEdges() :void
        {
//            trace("copyPolygonNodes");
            for each(var poly :NavMeshPolygon in _polygonsAll) {

                var newNodes :Array = new Array();
                for (var k :int = 0; k < poly.vertices.length - 1; k++) {
                    var node :NavMeshNode = poly.vertices[k] as NavMeshNode;
                    newNodes.push(new NavMeshNode(node.x, node.y));
                }

                for (k = 0; k < newNodes.length - 1; k++) {
                    var node1 :NavMeshNode = newNodes[k] as NavMeshNode;
                    var node2 :NavMeshNode = newNodes[k + 1] as NavMeshNode;
//                    trace("adding edge=" + node1 + ", " + node2);
                    addEdge(node1, node2);
                }
                addEdge(newNodes[0], newNodes[newNodes.length - 1]);

                for each(var n :NavMeshNode in newNodes) {
                    addNode(n);
                }
            }
        }


        protected function getMovementCost(node1 :NavMeshNode, node2 :NavMeshNode, includePaddedPolygons :Boolean = true) :Number
        {
            var key :int = GameUtil.hashForIdPair(node1.hashCode(), node2.hashCode());

            if (_distances.containsKey(key)) {
                return _distances.get(key);
            }

            var distance :Number = getMovementCostForVectors(node1, node2, includePaddedPolygons);
            _distances.put(key, distance);

//            if (withTrace) { trace(" getMovementCost(" + node1._id + ", " + node2._id + ")=" + distance);}
            return distance;
        }

        //Starting from A and going in direction angle, return the vector at most maxLength long that doesn't intersect any polygons.
        //If intersections are found, shorten the ray until they are not.
        protected function getMaxRayNotIntersectingPolygons(start :Vector2, angle :Number, maxLength :Number, includePaddedPolygons :Boolean = true) :Vector2
        {
            var rayEndPoint :Vector2 = VectorUtil.addLocalPolarVector(start, angle, maxLength);

            var checkedAllPolygons :Boolean = false;

            var polygonsToCheck :Array = _polygonsAll.slice();
            polygonsToCheck.push(new NavMeshPolygon(_boundsPolygon.vertices, 1, false));
            while(!checkedAllPolygons) {
                checkedAllPolygons = true;
                for each(var p :NavMeshPolygon in polygonsToCheck) {
                    if (!includePaddedPolygons && _paddedPolygon2Polygon.containsKey(p)) {
                        continue;
                    }
                    if (p.isPointInside(rayEndPoint) && !p.isPointOnEdge(rayEndPoint)) {
//                        var intersectionPoints :Array = Geometry.getPointsWhereLineIntersectsPolygon(start, rayEndPoint, p.vertices);
                        var intersectionPoints :Array = p.getIntersectionPoints(start, rayEndPoint);
                        var closestIntersectionPoint :Vector2 = Polygon.closestPointWithinPoints(start, intersectionPoints);
                        if (closestIntersectionPoint != null && VectorUtil.distanceSq(start, closestIntersectionPoint) < VectorUtil.distanceSq(start, rayEndPoint)) {
                            rayEndPoint = closestIntersectionPoint;
                            checkedAllPolygons = false;
                            break;
                        }
                    }
                }
            }
            return rayEndPoint;
        }

        protected function getMovementCostFromAWithRadiusToB(A :Vector2, radius :Number, B :Vector2, includePaddedPolygons :Boolean = true) :Number
        {
            var angle :Number = VectorUtil.angleFromVectors(A, B);

            //If the width results in the left point intersecting/overlapping with polygon, we mus reduce the
            //width for that side.
            var maxWidthA2Left :Number = radius;
            var maxWidthA2Right :Number = radius;
            var leftV :Vector2 = getMaxRayNotIntersectingPolygons(A, angle + Math.PI / 2, radius, includePaddedPolygons);
            var rightV :Vector2 = getMaxRayNotIntersectingPolygons(A, angle - Math.PI / 2, radius, includePaddedPolygons);

            var dMiddle :Number = getMovementCostForVectors(A, B, includePaddedPolygons);
            var dLeft :Number = getMovementCostForVectors(leftV, B, includePaddedPolygons);
            var dRight :Number = getMovementCostForVectors(rightV, B, includePaddedPolygons);

            var finalDistance :Number = Math.max(dMiddle, dLeft, dRight);
            return finalDistance;
        }
        protected function getMovementCostForVectors(node1 :Vector2, node2 :Vector2, includePaddedPolygons :Boolean = true) :Number
        {
//            trace("getMovementCostForVectors", NavMeshNode(node1).hashCode(), NavMeshNode(node2).hashCode());
            var withTrace :Boolean = false;

            if (withTrace) { trace("     " + node1);}
            if (withTrace) { trace("     " + node2);}
            //If either point is outside the bounds, make the distance MAX_VALUE;
            if (_bounds != null) {
                if (!_bounds.contains(node1.x, node1.y) || !_bounds.contains(node2.x, node2.y)) {
                    if (withTrace) { trace("out of bounds returning MAX");}
                    return Number.MAX_VALUE;
                }
            }

            var distanceBetweenNodes :Number = VectorUtil.distance(node1, node2);
            var intersectionDistance :Number;
            var intersectionPoints :Array;
            var verticesTouchingLine :Array;

            var lengthRemainingNotIntersectingPolygons :Number = distanceBetweenNodes;
            var movementPenalty :Number = 0;

            var finalDistance :Number;

//            var intersectingPolygonsBothPointsOutsidePolygonCleanIntersection :Array = [];
//            var intersectingPolygonsBothPointsOutsidePolygonPassinghroughAtLeastTwoPolygonVertices :Array = [];
//            var intersectingPolygonsOneNodeInOneOutIntersectingOnPolygonVertex :Array = [];
//            var intersectingPolygonsOneNodeInOneOutCleanIntersection :Array = [];

//            var containingPolygons :Array = [];

//            var partOfPolygons :Array = [];


            function addNewPenalty(distance :Number, polygon :NavMeshPolygon) :void
            {
                var movementCost : Number = polygon.movementCost;
//                if (_paddedPolygon2Polygon.containsKey(polygon) && isPolygonPenaltyToMovement(node1, node2, _paddedPolygon2Polygon.get(polygon))) {
//                    /*Fancy algorithm: we use the original polygon penalty if we pass through the padded polygon AND the original
//                     */
//                    /*Correction to algorithm: we must be passing right through both buffer and original polygon for this switching to occur*/
//                    if (!Polygon.isPointInPolygon(node1,  polygon.vertices) && !Polygon.isPointInPolygon(node2,  polygon.vertices)) {
//                        movementCost = NavMeshPolygon(_paddedPolygon2Polygon.get(polygon)).movementCost;
//                        if (withTrace) { trace("    using parents distance=" + movementCost + " instead of padded=" + polygon.movementCost);}
//                        trace("    using parents distance=" + movementCost + " instead of padded=" + polygon.movementCost);
//                    }
//                }

                /* If we ignore padded polygons*/
                if (!includePaddedPolygons && _paddedPolygon2Polygon.containsKey(polygon)) {
                    return;
                }

                /*We don't penalise the start node for getting out of the buffer.*/
//                if (_paddedPolygon2Polygon.containsKey(polygon) && (node1 == _start || node2 == _start)) {
//                    return;
//                }

                if (_paddedPolygon2Polygon.containsKey(polygon) && ((node1 == _start && node2 == _target) || (node2 == _start && node1 == _target))) {
                    return;
                }
//                if (_paddedPolygon2Polygon.containsKey(polygon) && (node1 == _target || node2 == _target)) {
//                    return;
//                }


                movementPenalty += Math.abs(distance) * movementCost;
                lengthRemainingNotIntersectingPolygons -= distance;
                if (withTrace) { trace("            intersection distance=" + distance);}
                if (withTrace) { trace("            polygon.movementCost=" + movementCost);}
                if (withTrace) { trace("            penalty added=" + (distance * movementCost));}

            }



            for each (var poly :NavMeshPolygon in _polygonsAll) {

                /* If we ignore padded polygons*/
                if (!includePaddedPolygons && _paddedPolygon2Polygon.containsKey(poly)) {
                    continue;
                }

                if (withTrace) { trace("        for polygon=" + poly.vertices);}


                /*
                * There are many geometric possibilities for where points lie on, in, or intersecting
                * a polygon.  We must differentiate these possibilities to correctly compute the
                * distance.
                * In summary, if an edge lies on the border of a polygon, the distance is without
                * penalty from the polygon.  Edges within or intersecting are penalized by the
                * movement penalty of the polygon.
                */
                var p1InP :Boolean = poly.isPointInside(node1);
                var p2InP :Boolean = poly.isPointInside(node2);

                if (withTrace) {
                    if (p1InP) {
                        trace("        " + node1 + " lies in the polygon");
                    }
                    if (p2InP) {
                        trace("        " + node2 + " lies in the polygon");
                    }
                }

                var p1IsPVertex :Boolean = poly.isVertex(node1);
                var p2IsPVertex :Boolean = poly.isVertex(node2);

                if (p1InP && p2InP) {/*Both points lie inclusively in or on the polygon.  Must differentiate further */

                    var p1OnBorder :Boolean = poly.isPointOnEdge(node1);
                    var p2OnBorder :Boolean = poly.isPointOnEdge(node2);
                    var p1andp2onSamePolyEdge :Boolean = poly.isLineOnPolygonEdge(node1, node2);

                    if (p1OnBorder && p2OnBorder) {
                        /* Two posibilities here:
                            1) They both lie on the same edge. (no penalty).
                            2) They lie on different edges (penalty for intersection (crossing)). */
                        if (p1andp2onSamePolyEdge) {
                            /* Polygon edge or on polygon edge.  No penalty*/
                            if (withTrace) { trace("        we  think its lying on a polygon edge.  No movement penalty from this polygon");}
                        }
                        else {
                            /* The points lie on different polygon edges, meaning that they cross over the polygon*/
                            if (withTrace) { trace("        we  think its lying on differnet polygon edges. Movement penalty from this polygon");}
                            /* We are no longer charging a penalty for moving through a polygon if we are inside it*/
                            intersectionDistance = VectorUtil.distance(node1, node2);
                            addNewPenalty(intersectionDistance, poly);
                        }
                    }
                    else {
                    /*We have already exlcuded the possibilities where point lie on the polygon edges.
                        The only possibilities now are points within the polygon.  These are to be penalized. */
                        if (withTrace) { trace("        we  think its lying within the polygon. Movement penalty from this polygon");}
                        /* We are no longer charging a penalty for moving through a polygon if we are inside it*/
                        intersectionDistance = VectorUtil.distance(node1, node2);
                        addNewPenalty(intersectionDistance, poly);
                    }

                }
                else if ((p1InP && !p2InP) || (!p1InP && p2InP)) {
                    /*One point is within the polygon, the other is not.  Needs to be differentiated futher
                        The main problem is if the point 'in' the polygon is actually on the border.  In this case
                        we do not count this as an intersection.
                    */

                    var nodeInPolygon :Vector2 = p1InP ? node1 : node2;
                    var nodeOusidePolygon :Vector2 = p1InP ? node2 : node1;

                    if (poly.isPointOnEdge(nodeInPolygon)) {
                        intersectionPoints = poly.getIntersectionPoints(node1, node2);
                        if (withTrace) { trace("        intersectionPoints=" + intersectionPoints)};
                        if (intersectionPoints.length == 2) {
                            if (withTrace) { trace("        we  think its one point lies on the polygon border, the other not.  INTERSECTION.");}
                            intersectionDistance = VectorUtil.distance(intersectionPoints[0], intersectionPoints[1]);
                            addNewPenalty(intersectionDistance, poly);
                        }
                        else if (intersectionPoints.length == 1) {
                            if (withTrace) { trace("        we  think its one point lies on the polygon border, the other not.  NO INTERSECTION.");}
//                            intersectionDistance = VectorUtil.distance(nodeInPolygon, intersectionPoints[0]);
//                            addNewPenalty(intersectionDistance, poly);
                        }
                        else if (intersectionPoints.length == 0){
                            if (withTrace) { trace("        we  think its one point lies on the polygon border, the other not.  But no intersection so no penalty.");}
                        }
                        else {
                            if (withTrace) { trace("        we  think its one point lies on the polygon border, the other not.  But we don't know how to handle three or more intersection points.  But no intersection so no penalty.");}
                        }


                    }
                    else {
                        verticesTouchingLine = poly.getVerticesOfPolygonTouchingLine(nodeInPolygon, nodeOusidePolygon);
                        if (verticesTouchingLine.length == 1) {
//                            trace("    one node in, one out, but line passes through a vertex (INTERSECTION)");

//                            intersectionPoints = Geometry.getVerticesOfPolygonTouchingLine(node1, node2, poly.vertices);
//                            if (verticesTouchingLine.length != 1) {
////                                trace("Problem, we thought it is a clean intersection, but we are getting more than one point of intersection");
//                            }
                            if (verticesTouchingLine.length == 0) {
                                trace("        Polygon problem.  We think one node is in the P, the other out.  The node in is not on the edge, so we assume the line *must* intersect the polygon.  Bt we get no intersection points. node1=" + node1 + ", node2=" + node2 + ", poly.vertices=" + poly.vertices);
                            }
                            else {
                                intersectionDistance = VectorUtil.distance(nodeInPolygon, verticesTouchingLine[0]);
                                addNewPenalty(intersectionDistance, poly);
                            }


//                            intersectingPolygonsOneNodeInOneOutIntersectingOnPolygonVertex.push(poly);
                        }
                        else {
                            if (withTrace) { trace("        one node in, one out, clean INTERSECTION");}
                            intersectionPoints = poly.getIntersectionPoints(node1, node2);
                            if (intersectionPoints.length != 1) {
                                if (withTrace) { trace("        Problem, we thought it is a clean one intersection, but we are getting more than one point of intersection");}
                            }
                            else {
                               intersectionDistance = VectorUtil.distance(nodeInPolygon, intersectionPoints[0]);
                               if (withTrace) { trace("        one intersection point, distance=" + intersectionDistance);}
                               addNewPenalty(intersectionDistance, poly);
                            }
//                            intersectingPolygonsOneNodeInOneOutCleanIntersection.push(poly);
                        }
                    }

                }
                else {
                    /* The two points do not lie within the polygon.  Check for intersections keeping
                     * in mind that intersections that only intersect with the polygon vertices must
                     * be explicitly tested.  Think of a diagonal line passing through the center of
                     * a square.  The given intersection Polygon algorithm cannot detect in as it relies
                     * on testing for two lines intersecting.
                     */
                     if (poly.isLineIntersecting(node1, node2)) {
//                         if (withTrace) { trace("    both points outside, clean polygon INTERSECTION.");}

                         intersectionPoints = poly.getIntersectionPoints(node1, node2);
                         if (intersectionPoints.length != 2) {
//                             trace("Problem, we thought it is a clean intersection, but we are getting more than two points of intersection");
                         }
                         else {
                            intersectionDistance = VectorUtil.distance((intersectionPoints[0] as Vector2), intersectionPoints[1]);
                            addNewPenalty(intersectionDistance, poly);
                         }

//                         intersectingPolygonsBothPointsOutsidePolygonCleanIntersection.push(poly);
                     }
                     else {
                         /*Maybe the line simply passes through the polygon only touching the vertices?*/
                         verticesTouchingLine = poly.getVerticesOfPolygonTouchingLine(node1, node2);
                         if (verticesTouchingLine.length >= 2) {
                             /* At least two polygon vertices are touching this line. */
                             if (withTrace) { trace("         intersection with polygon where line passes through at least two polygon vertices.");}

//                             intersectionPoints = Geometry.getVerticesOfPolygonTouchingLine(node1, node2, poly.vertices);
                             if (verticesTouchingLine.length != 2) {
//                                 trace("Problem, we thought it is a clean intersection, but we are getting more than two points of intersection");
                             }
                             else {
                                intersectionDistance = VectorUtil.distance((verticesTouchingLine[0] as Vector2), verticesTouchingLine[1]);
                                addNewPenalty(intersectionDistance, poly);
                             }


//                             intersectingPolygonsBothPointsOutsidePolygonPassinghroughAtLeastTwoPolygonVertices.push(poly);
                         }
                     }
                }
            }

            lengthRemainingNotIntersectingPolygons = Math.max(lengthRemainingNotIntersectingPolygons, 0);
            finalDistance = lengthRemainingNotIntersectingPolygons + movementPenalty;


            if (isNaN(finalDistance)) {
                trace("!!!!!!WTF, final distance is NAN!");
                return distanceBetweenNodes;
            }

            finalDistance = isFinite(finalDistance) ? finalDistance : Number.MAX_VALUE;
            if (withTrace) { trace("          returning=" + finalDistance);}
            return finalDistance;

                        /*This function sums up the logic below.*/
            function isPolygonPenaltyToMovement(P1 :NavMeshNode, P2 :NavMeshNode, polygon :NavMeshPolygon) :Boolean
            {
                var p1InP :Boolean = polygon.isPointInside(P1);
                var p2InP :Boolean = polygon.isPointInside(P2);

                var p1IsPVertex :Boolean = polygon.isVertex(P1);
                var p2IsPVertex :Boolean = polygon.isVertex(P2);

                if (p1InP && p2InP) {/*Both points lie inclusively in or on the polygon.  Must differentiate further */

                    var p1OnBorder :Boolean = polygon.isPointOnEdge(P1);
                    var p2OnBorder :Boolean = polygon.isPointOnEdge(P2);
                    var p1andp2onSamePolyEdge :Boolean = polygon.isLineOnPolygonEdge(P1, P2);

                    if (p1OnBorder && p2OnBorder) {
                        /* Two posibilities here:
                            1) They both lie on the same edge. (no penalty).
                            2) They lie on different edges (penalty for intersection (crossing)). */
                        if (p1andp2onSamePolyEdge) {
                            /* Polygon edge or on polygon edge.  No penalty*/
                        }
                        else {
                            /* The points lie on different polygon edges, meaning that they cross over the polygon*/
                            return true;
                        }
                    }
                    else {
                    /*We have already exlcuded the possibilities where point lie on the polygon edges.
                        The only possibilities now are points within the polygon.  These are to be penalized. */
                        return true;
                    }

                }
                else if ((p1InP && !p2InP) || (!p1InP && p2InP)) {
                    /*One point is within the polygon, the other is not.  Needs to be differentiated futher
                        The main problem is if the point 'in' the polygon is actually on the border.  In this case
                        we do not count this as an intersection.
                    */

                    var nodeInPolygon :NavMeshNode = p1InP ? P1 : P2;
                    var nodeOusidePolygon :NavMeshNode = p1InP ? P2 : P1;

                    if (polygon.isPointOnEdge(nodeInPolygon)) {
                        intersectionPoints = polygon.getIntersectionPoints(P1, P2);
                        if (intersectionPoints.length == 2) {
                            return true;
                        }
                        else if (intersectionPoints.length == 1) {
                            return true;
                        }
                        else if (intersectionPoints.length == 0){
                        }
                        else {
                        }
                    }
                    else {
                        if (polygon.getVerticesOfPolygonTouchingLine(nodeInPolygon, nodeOusidePolygon).length == 1) {
                            return true;
                        }
                        else {
                            intersectionPoints = polygon.getIntersectionPoints(P1, P2);
                            if (intersectionPoints.length != 1) {
                            }
                            else {
                                return true;
                            }
                        }
                    }

                }
                else {
                    /* The two points do not lie within the polygon.  Check for intersections keeping
                     * in mind that intersections that only intersect with the polygon vertices must
                     * be explicitly tested.  Think of a diagonal line passing through the center of
                     * a square.  The given intersection Polygon algorithm cannot detect in as it relies
                     * on testing for two lines intersecting.
                     */
                     if (polygon.isLineIntersecting(P1, P2)) {

                         intersectionPoints = polygon.getIntersectionPoints(P1, P2);
                         if (intersectionPoints.length != 2) {
                         }
                         else {
                             return true;
                         }
                     }
                     else {
                         /*Maybe the line simply passes through the polygon only touching the vertices?*/
                         var verticesTouchingLine :Array = polygon.getVerticesOfPolygonTouchingLine(P1, P2);
                         if (verticesTouchingLine.length >= 2) {
                             /* At least two polygon vertices are touching this line. */
//                             intersectionPoints = Geometry.getVerticesOfPolygonTouchingLine(P1, P2, polygon.vertices);
                             if (verticesTouchingLine.length != 2) {
                             }
                             else {
                                 return true;
                             }
                         }
                     }
                }
                return false;
            }
        }


        public function removeEdgesOfPaddedIntersectingParentTerrain () :void
        {
            _paddedPolygon2Polygon.forEach(function(padded :NavMeshPolygon, terrainPolygon :NavMeshPolygon) :void {

               for (var i :int = 0; i < padded.vertices.length - 1; i++) {
                   var node1 :NavMeshNode = padded.vertices[i];
                   var node2 :NavMeshNode = padded.vertices[i + 1];

                   if (terrainPolygon.isLineIntersecting(node1, node2)) {
                       removeEdge(node1, node2);
                   }
               }

            });

        }


        public function toString () :String
        {
            var sb :String = new String();

            sb += "Navmesh:";
            sb += "\n   Polygons=" + _polygonsAll.length;
            sb += "\n   Nodes=" + _nodes.length;
            _nodes.map(function (n :NavMeshNode, ...ignored) :String {
                return "\n      " + n + "\n          neighbours=" + n.getNeighbors();
            });
            sb += _nodes.join();


            return sb;
        }

    }
}
