package net.amago.pathfinding.navmesh
{
import com.threerings.util.F;

import com.threerings.geom.Vector2;
import com.threerings.util.Hashable;
import com.threerings.util.Util;

import net.amago.math.geometry.LineSegment;
import net.amago.math.geometry.Polygon;
import net.amago.math.geometry.VectorUtil;

public class NavMeshPolygonExclusion extends Polygon
    implements Hashable
{
    private static var _currrentHash :int = 0;
    protected var _hash :int;

    protected var _movementCost :Number;
    protected var _padOuter :Boolean;
    protected var _center :Vector2;
    protected var _padded :Polygon;

    public function NavMeshPolygonExclusion (vertices :Array, movementCost :Number = 1000,
        padOuter :Boolean = true)
    {
        super(vertices.map(F.adapt(function (v :Vector2) :NavMeshNode {
            return NavMeshNode.fromVector2(v);
        })));

        if (vertices == null || vertices.length == 0) {
            throw new Error("vertices=" + vertices);
        }
        _movementCost = movementCost;
        _padOuter = padOuter;
        _padded = this;
		_hash = nextHash;
    }
	
	protected static function get nextHash () :int
	{
		return ++_currrentHash;
	}

    public function get paddedCopy () :Polygon
    {
        return _padded;
    }

    public function padCopy (padding:Number) :Polygon
    {
        if (_padded == this) {
            _padded = super.clone();
        }
        _padded.padLocal(padding);
        return _padded;
    }

    public function revertPaddedCopy () :void
    {
        _padded = super.clone();
    }



    public static function fromRect (x :Number, y :Number, width :Number, height :Number,
        movementCost :Number = 10000, padOuter :Boolean = false) :NavMeshPolygonExclusion
    {
        return new NavMeshPolygonExclusion([
                                    new Vector2(x, y),
                                    new Vector2(x + width, y),
                                    new Vector2(x + width, y + height),
                                    new Vector2(x, y + height),
                                  ],
                                  movementCost, padOuter);
    }


    public function hashCode () :int
    {
        return _hash;
    }
    public function equals (other :Object) :Boolean
    {
        return (other is NavMeshPolygonExclusion) && (_hash === (other as NavMeshPolygonExclusion)._hash);
    }

    override public function clone () :Polygon
    {
        var navPolygon :NavMeshPolygonExclusion =
            new NavMeshPolygonExclusion(_vertices.map(F.adapt(function (v :Vector2) :Vector2 {
                return new NavMeshNode(v.x, v.y);
            })), _movementCost, _padOuter);
        return navPolygon;
    }

    public function get movementCost () :Number
    {
        return _movementCost;
    }

    public function set movementCost (cost :Number) :void
    {
        _movementCost = cost;
    }

    public function isVertex (vertex :Vector2) :Boolean
    {
        for each(var v :NavMeshNode in _vertices) {
            if(v.equals(vertex)) {
                return true;
            }
        }
        return false;
    }

    public function isVertices (node1 :NavMeshNode, node2 :NavMeshNode) :Boolean
    {
        return isVertex(node1.vector) && isVertex(node2.vector);
    }

    public function sharesVertex (polygon :NavMeshPolygonExclusion) :Boolean
    {
        for each(var v1 :Vector2 in _vertices) {
            for each(var v2 :Vector2 in polygon.vertices) {
                if(v1 == v2) {
                    return true;
                }
            }
        }
        return false;
    }

    public function getSharedVertices (polygon :NavMeshPolygonExclusion) :Array
    {
        var sharedVertices :Array = new Array();
        for each(var v1 :Vector2 in _vertices) {
            for each(var v2 :Vector2 in polygon.vertices) {
                if(v1 == v2) {
                    sharedVertices.push(v1);
                }
            }
        }
        return sharedVertices;
    }

//    override public function toString () :String
//    {
//        return "Polygon " + hashCode();
//    }

    public function toStringLong () :String
    {
        return toString() + ": " + _vertices.toString();
    }

    public function compare (navPolygon :NavMeshPolygonExclusion) :Boolean
    {
        for(var k :int = 0; k < vertices.length; k++) {
            if(k >= navPolygon.vertices.length) {
                return false;
            }
            if(!vertices[k].equals(navPolygon.vertices[k])) {
                return false;
            }
        }
        return true;
    }

    public function getAllEdgeMidpointsAsPolygon () :Polygon
    {
        var midPoints :Array = edges.map(Util.adapt(function (e :LineSegment) :NavMeshNode {
            var mid :Vector2 = e.midpoint;
            return new NavMeshNode(mid.x, mid.y);
        }));
//        trace("midPoints=" + midPoints);
        return new NavMeshPolygonExclusion(midPoints);
    }

    public function get maxX () :Number
    {
        var value :Number = Number.MIN_VALUE;
        _vertices.forEach(function(point :Vector2, ...ignored) :void {
              if(point.x > value) {
                  value = point.x;
              }
          });
        return value
    }
    public function get maxY () :Number
    {
        var value :Number = Number.MIN_VALUE;
        _vertices.forEach(function(point :Vector2, ...ignored) :void {
              if(point.y > value) {
                  value = point.y;
              }
          });
        return value
    }

    public function get minY () :Number
    {
        var value :Number = Number.MAX_VALUE;
        _vertices.forEach(function(point :Vector2, ...ignored) :void {
              if(point.y < value) {
                  value = point.y;
              }
          });
        return value
    }
    public function get minX () :Number
    {
        var value :Number = Number.MAX_VALUE;
        _vertices.forEach(function(point :Vector2, ...ignored) :void {
              if(point.x < value) {
                  value = point.x;
              }
          });
        return value
    }

    public function set maxX (value :Number) :void
    {
        _vertices.forEach(function(point :Vector2, ...ignored) :void {
              if(point.x > value) {
                  point.x = value;
              }
          });
    }
    public function set minX (value :Number) :void
    {
        _vertices.forEach(function(point :Vector2, ...ignored) :void {
              if(point.x < value) {
                  point.x = value;
              }
          });
    }
    public function set maxY (value :Number) :void
    {
        _vertices.forEach(function(point :Vector2, ...ignored) :void {
              if(point.y > value) {
                  point.y = value;
              }
          });
    }
    public function set minY (value :Number) :void
    {
        _vertices.forEach(function(point :Vector2, ...ignored) :void {
              if(point.y < value) {
                  point.y = value;
              }
          });
    }

    /**
     * Returns true if any points are an edge of the polygon.
     * @param P1 Array of Vector2 points, with the first point also last in the array.
     */
    public function numberVerticesOfPolygonTouchingLine (P1 :Vector2, P2 :Vector2) :int
    {
        var vertexCount :int = 0;

        for each (var v :Vector2 in _vertices) {
            if (LineSegment.distToLineSegment(P1, P2, v) == 0) {
                vertexCount++;
            }
        }
        return vertexCount;
    }

    /**
     * Returns true if any points are an edge of the polygon.
     * @param P1 Array of Vector2 points, with the first point also last in the array.
     */
    public function getVerticesOfPolygonTouchingLine (P1 :Vector2, P2 :Vector2) :Array
    {
        var verticesTouching :Array = new Array();
        for each (var v :Vector2 in _vertices) {
            if (LineSegment.distToLineSegment(P1, P2, v) == 0) {
                verticesTouching.push(v);
            }
        }

        return verticesTouching;
    }

        /**
    * The horizontal between two polygons.
    *
    * Not defined if the polygons overlap.
    */
    public static function horizontalMidPoint (P1 :NavMeshPolygonExclusion, P2 :NavMeshPolygonExclusion) :Number
    {
        var minXP1 :Number = P1.minX;
        var maxXP1 :Number = P1.maxX;
        var minXP2 :Number = P2.minX;
        var maxXP2 :Number = P2.maxX;

        if(Math.abs(minXP2 - maxXP1) < Math.abs(minXP1 - maxXP2)) {
            return maxXP1 + (minXP2 - maxXP1) / 2;
        }
        else {
            return maxXP2 + (minXP1 - maxXP2) / 2;
        }
    }

    /**
    * The vertical between two polygons.
    *
    * Not defined if the polygons overlap.
    */
    public static function verticalMidPoint (P1 :NavMeshPolygonExclusion, P2 :NavMeshPolygonExclusion) :Number
    {
        var minYP1 :Number = P1.minY;
        var maxYP1 :Number = P1.maxY;
        var minYP2 :Number = P2.minY;
        var maxYP2 :Number = P2.maxY;

        if(Math.abs(minYP2 - maxYP1) < Math.abs(minYP1 - maxYP2)) {
            return maxYP1 + (minYP2 - maxYP1) / 2;
        }
        else {
            return maxYP2 + (minYP1 - maxYP2) / 2;
        }
    }

    public function get longestEdgeLength () :Number
    {
        var longestEdge :LineSegment;
        var currentLongestLengthSq :Number = 0;
        for each (var edge :LineSegment in _edges) {
            if (longestEdge == null) {
                longestEdge = edge;
                continue;
            }
            var lenSq :Number = VectorUtil.distanceSq(edge.a, edge.b);
            if (lenSq > currentLongestLengthSq) {
                currentLongestLengthSq = lenSq;
                longestEdge = edge;
            }
        }
        return longestEdge.length;
    }

    public function get shortestEdgeLength () :Number
    {
        var shortestEdge :LineSegment;
        var currentShortestLengthSq :Number = Number.MAX_VALUE;
        for each (var edge :LineSegment in _edges) {
            if (shortestEdge == null) {
                shortestEdge = edge;
                continue;
            }
            var lenSq :Number = VectorUtil.distanceSq(edge.a, edge.b);
            if (lenSq < currentShortestLengthSq) {
                currentShortestLengthSq = lenSq;
                shortestEdge = edge;
            }
        }
        return shortestEdge.length;
    }

}
}
