
package net.amago.math.geometry
{
    import com.threerings.geom.Vector2;


    /**
     * A few functions for transforming Vectors
     * @author Colby Cheeze
     *
     */
    public class Transformations
    {
        /**
         * Function is currently incomplete!
         * @param points
         * @param pos
         * @param foward
         * @param side
         * @param scale
         * @return
         *
         */
        public static function worldTransformPoints(points:Array, pos:Vector2, foward:Vector2, side:Vector2, scale:Vector2):Array{
            throw new Error("This function is incomplete!");
        }

        /**
         * Converts a point from local space to world space.
         * @param point The point to convert
         * @param heading The Heading of the local object
         * @param side The perpendicular vector of the heading
         * @param pos The position of the local object
         * @return The new point in it's world space coords.
         *
         */
        public static function pointToWorldSpace(point:Vector2, heading:Vector2, side:Vector2, pos:Vector2):Vector2{
            var transPoint:Vector2 = point.clone();
            m_mat.Set();

            m_mat.vectorRotate(heading, side);
            m_mat.translate(pos.x, pos.y);
            m_mat.transformVector(transPoint);

            return transPoint;
        }

        /**
         * Converts a Vector from local to world space
         * @param vector The Vector to convert
         * @param heading Heading of the local object
         * @param side The perpendicular vector of the heading
         * @return The new Vector in it's world space coords.
         *
         */
        public static function vectorToWorldSpace(vector:Vector2, heading:Vector2, side:Vector2):Vector2{
            var transVec:Vector2 = vector.clone();
            m_mat.Set();

            m_mat.vectorRotate(heading,side);
            m_mat.transformVector(transVec);

            return transVec;
        }

        /**
         * Converts a point from world space to local space.
         * @param point The point to convert
         * @param heading The Heading of the local object
         * @param side The perpendicular vector of the heading
         * @param pos The position of the local object
         * @return The new point in it's local space coords.
         *
         */
        public static function pointToLocalSpace(point:Vector2, heading:Vector2, side:Vector2, pos:Vector2):Vector2{
            var transPoint:Vector2 = point.clone();

            var tx:Number = -pos.dot(heading);
            var ty:Number = -pos.dot(side);

            m_mat.Set(heading.x, side.x,0,heading.y,side.y,0,tx,ty);

            m_mat.transformVector(transPoint);

            return transPoint;

        }

        /**
         * Converts a Vector from world to local space
         * @param vector The Vector to convert
         * @param heading Heading of the local object
         * @param side The perpendicular vector of the heading
         * @return The new Vector in it's local space coords.
         *
         */
        public static function vectorToLocalSpace(vector:Vector2, heading:Vector2, side:Vector2):Vector2{
            var transPoint:Vector2 = vector.clone();

            m_mat.Set(heading.x, side.x, 0, heading.y, side.y);

            m_mat.transformVector(transPoint);

            return transPoint;
        }

        /**
         * Rotates a Vector around (0,0) at a specified angle.
         * @param vector the vector to transform.
         * @param angle the angle to rotate at.
         *
         */
        public static function rotateAroundOrigin(vector:Vector2, angle:Number):void{
            var mat:Matrix2D = new Matrix2D();

            mat.rotate(angle);

            mat.transformVector(vector);
        }

        /**
         * NOTE: Has not yet been tested!
         * Use this to create an array of "whiskers" for use in wall avoidance algorithms
         * @param numWhiskers the number of whiskers to create.
         * @param length the length of the whiskers
         * @param fov FOV of the object
         * @param facing the heading vector of the oject
         * @param origin the origin of the whiskers
         * @return An array of "whiskers" (a list of Vectors)
         *
         */
        public static function createWhiskers(numWhiskers:int, length:Number, fov:Number, facing:Vector2, origin:Vector2):Array{
            //magnitude of the angle seperating each whisker
            var sectorSize:Number = fov/(numWhiskers-1);

            var whiskers:Array = [];
            var temp:Vector2;
            var angle:Number = -fov*0.5;

            var i:int = numWhiskers;
            while(--i>=0){
                temp = facing
                Transformations.rotateAroundOrigin(temp, angle);
                whiskers.push(origin.add(temp.scale(length)));

                angle+=sectorSize;
            }

            return whiskers;
        }

        private static var m_mat:Matrix2D = new Matrix2D();
    }
}
