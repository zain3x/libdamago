package com.threerings.geometry.path
{
    import com.threerings.util.MathUtil;
    import com.threerings.geom.Vector2;

    import com.threerings.geometry.Geometry;
    import com.threerings.geometry.LineSegment;
    import com.threerings.geometry.VectorUtil;

    /**
    * After a path is computed, save it, and use it later for following.
    */
    public class PathToFollow
    {

        protected var _path :Array;
        protected var _pathComplete :Boolean;

        public function PathToFollow(points :Array = null)
        {
            _path = new Array();
            _pathComplete = false;

            if(points != null) {
                for each(var o :Object in points) {
                    addPathPoint(o.x, o.y);
                }
            }

        }

        public function get path() :Array
        {
            return _path;
        }

        public function get complete() :Boolean
        {
            return _pathComplete;
        }
        public function addPathPoint(x :Number, y :Number) :void
        {
            var latestVec :Vector2 = new Vector2(x, y);
//            if(_path.length < 2) {
//                _path.push(latestVec);
//            }
//            else {
                circularizeLine(_path , latestVec);
//            }
        }

        /**
        * Using the angle from point 1 and point 2, returns a point in between oint 2 and 3
        * that is half the angle and distance between points 2 and 3.
        */
        protected function circularizeLine(path :Array, point3 :Vector2) :void
        {
//            var point1 :Vector2 = path[ path.length - 2];
//            var point2 :Vector2 = path[ path.length - 1];
//
//            var previousAngle :Number = Util.angleFromVectors(point1, point2);
//            var newAngle :Number = Util.angleFromVectors(point2, point3);
//            var diffAngle :Number = MathUtil.normalizeRadians(newAngle - previousAngle);
//
//            if(diffAngle >= Math.PI/4) {
//
//                var inbetweenAngle :Number = Vector2.smallerAngleBetween(point2, point3);
//
//                var halfWayVec :Vector2 = Vector2.fromAngle(inbetweenAngle, MathUtil.distance(point2.x, point2.y, point3.x, point3.y) / 2);
//                halfWayVec.addLocal(point2);
//                path.push(halfWayVec)
//            }

            path.push(point3);
//            addExtraPointsBetweenLastTwoPoints();
        }

        protected function addExtraPointsBetweenLastTwoPoints() :void
        {
            if(_path.length < 2) {
                return;
            }
            var lastVec :Vector2 = _path.pop();
            var previousVec :Vector2 = _path[ _path.length - 1 ] as Vector2;



            var extraPoints :int = MathUtil.clamp((int(VectorUtil.distance(lastVec, previousVec)) / 30) - 1, 0, 10);

            for(var k :int = 1; k <= extraPoints; k++) {
                _path.push(Vector2.interpolate(previousVec, lastVec, k / (extraPoints + 1.0)));
            }


//            var xIncrement :Number = (lastVec.x - previousVec.x) / (extraPoints + 2);
//            var yIncrement :Number = (lastVec.y - previousVec.y) / (extraPoints + 2);
//            for(var k :int = 1; k <= extraPoints; k++) {
//                _path.push(new Vector2(previousVec.x + k * xIncrement, previousVec.y + k * yIncrement));
//            }
            _path.push(lastVec);
        }


        public function whereShouldIHeadTowardsTest(position :Vector2) :Vector2
        {

            var distance :Number = VectorUtil.distanceSq(position, _path[0]);

            var minDistanceSq :Number = Math.pow(50, 2);
            while(distance < minDistanceSq && _path.length > 1) {
                _path.shift();
                distance = VectorUtil.distanceSq(position, _path[0]);
            }
            return _path[0]

        }


        public function whereShouldIHeadTowards (position :Vector2) :Vector2
        {
            var point :Vector2;

//            point = _path[0] as Vector2;
//            if(point == null) {
//                trace("path has no points, returning your own position");
//                return position;
//            }
//            var distance :Number = MathUtil.distance(position.x, position.y, point.x, point.y);
//
//            if(distance <= 10) {
//                if(_path.length > 1) {
//                    _path.splice(0, 1);
//                }
//            }
//
//            return _path[0];

//            trace("whereShouldIHeadTowards(" + position + ")");
            //Look backwards through the list,
            //get the closest point, then get furthest point following that doesn't change direction
//            var k :int;
//            var closestPointIndex :int = -1;
//            var closestPoint :Vector2;
//            var closestDistance :Number = Number.MAX_VALUE;
//            for (k = 0; k < _path.length; k++) {
//                point = _path[k] as Vector2;
//                var distance :Number = MathUtil.distance(position.x, position.y, point.x, point.y);
//                if(distance < closestDistance) {
//                    closestDistance = distance;
//                    closestPoint = point;
//                    closestPointIndex = k;
//                }
//            }

            //Get the closest edge, and take the point of the edge closest to the target
            var k :int;
            var closestPointIndex :int = -1;
//            var closestPoint :Vector2;
            var closestDistance :Number = Number.MAX_VALUE;
            var point1 :Vector2;
            var point2 :Vector2;
            for (k = 0; k < _path.length - 1; k++) {
                point1 = _path[k] as Vector2;
                point2 = _path[k + 1] as Vector2;
                var distance :Number = LineSegment.distToLineSegment(point1, point2, position);
                if(distance < closestDistance) {
                    closestDistance = distance;
//                    closestPoint = point2;
                    closestPointIndex = k;
                }
            }

            //k is the point of the edge closest to the start.  We want the one closest to the target
            closestPointIndex++;

//            trace("      closest point is=" + _path[closestPointIndex]);

//            if(closestDistance <= 5) {
//                closestPointIndex += 2;
//            }

                if (VectorUtil.distance(position, _path[closestPointIndex]) < 20) {
                    closestPointIndex++
                }


            closestPointIndex = MathUtil.clamp(closestPointIndex, 0, _path.length - 1);
            return _path[closestPointIndex];

//            return (_path[closestPointIndex] != null ? _path[closestPointIndex] : position);

//
//            if(closestPointIndex == 0) {
////                return closestPoint;
//                closestPointIndex = 1;
//                closestPoint = _path[closestPointIndex];
//            }
//            trace("  closest point=" + closestPoint);
//
//            var previousPoint :Vector2 = _path[ closestPointIndex - 1] as Vector2;
//            var pathAngleAtClosestPoint :Number = Util.angleFrom(previousPoint.x, previousPoint.y, closestPoint.x, closestPoint.y);
//
//            trace("  pathAngleAtClosestPoint=" + pathAngleAtClosestPoint);
//
//            for(k = closestPointIndex + 1; k < _path.length; k++) {
//                point = _path[k] as Vector2;
//                if(Util.similar(Util.angleFrom(point.x, point.y, closestPoint.x, closestPoint.y),  pathAngleAtClosestPoint, 0.05)){
//                    closestPointIndex = k;
//                }
//                else {
//                    break;
//                }
//            }
//
//            trace("  but the target point=" + _path[closestPointIndex]);
//
//            return _path[closestPointIndex];

//            trace("whereShouldIHeadTowards, closestPoint=" + closestPoint);
            //Then increment so we aim for the next point in the path
//            closestPointIndex++;
//
//            if(closestPointIndex == _path.length - 1) {
//                _pathComplete = true;
//            }
//
//            if(closestPointIndex < _path.length && closestPointIndex >= 0) {
//                return _path[closestPointIndex];
//            }
//            else {
//                if(_path.length == 0) {
////                    trace("Path length == 0");
//                }
//                return _path[ _path.length - 1];
//            }
        }

        public function getAngleHeading(position :Vector2) :Number
        {
            var vec :Vector2 = whereShouldIHeadTowards(position).clone();
//            trace("I should head towards="+ vec);
            vec.subtractLocal(position);
//            trace("getAngleHeading, position=" + position + "angle=" + vec.angle + ", _path=" + _path);
            return vec.angle;
        }

        public function get length() :int
        {
            return _path.length;
        }

        public function toString() :String
        {
            return "Path: " + _path.toString();
        }

        /**
        * @maxDistanceFromMidPoint: The curves are always the same distance from the midpoint.
        *                           In addition, the max distance between the curve start/stop
        *                           and the mid point can be specified, which may be necessary
        *                           depending on the terrain and buffer.  E.g. set the max
        *                           distance as half the shortest edge length of all obstacle
        *                           polygons.
        */
        public function addBezierCurvature (pointsInbetween :int = 3,
            maxDistanceFromMidPoint :Number = 100) :PathToFollow
        {
            var pathNew :Array = [path[0]];

            var indexOfv1 :int = 0;
            while (indexOfv1 < path.length - 2) {
                //Add the first point in the group of three
                //But we won't add the last point
                var point1 :Vector2 = path[ indexOfv1 ];
                var point2 :Vector2 = path[ indexOfv1 + 1 ];
                var point3 :Vector2 = path[ indexOfv1 + 2 ];

                var mid12  :Vector2 = LineSegment.midPoint(point1, point2);
                var mid23  :Vector2 = LineSegment.midPoint(point2, point3);

                var dis2_mid12 :Number = VectorUtil.distance(point2, mid12);
                var dis2_mid23 :Number = VectorUtil.distance(point2, mid23);

                var distanceFrom2 :Number = Math.min(dis2_mid12, dis2_mid23);
                distanceFrom2 = Math.min(distanceFrom2, maxDistanceFromMidPoint);

                //Recompute the 'mid' points
                mid12 = point2.add(Vector2.fromAngle(VectorUtil.angleFromVectors(point2, point1), distanceFrom2));
                mid23 = point2.add(Vector2.fromAngle(VectorUtil.angleFromVectors(point2, point3), distanceFrom2));

                var inc :Number = 1 / ((pointsInbetween + 2) * 2);
                var t :Number = 0;
                while (t <= 1) {
                    var mid :Vector2 = Geometry.bezier(mid12, point2, mid23, t);
                    pathNew.push(mid);
                    t += inc;
                }
                indexOfv1++;
            }
            pathNew.push(path[ path.length - 1 ]);

            return new PathToFollow(pathNew);
        }


    }
}
