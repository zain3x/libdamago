//
// $Id$

package com.threerings.util {
import flash.utils.describeType;
import com.threerings.util.ClassUtil;
public class ReflectionUtil
{

    public static function getAccessorNames (clazz :Class) :Array
    {
        var variableList :Array = [];
        var xml :XML = getClassDescription(clazz);
        for each (var child :XML in xml.factory.accessor) {
            variableList.push(child.@name.toString());
        }
        return variableList;
    }

    public static function getFieldType (clazz :Class, fieldName :String) :*
    {
        var xml :XML = getClassDescription(clazz);
        for each (var varXml :XML in xml.factory.variable) {
            if (varXml.@name.toString() == fieldName) {
                return ClassUtil.getClassByName(varXml.@type.toString());
            }
        }
        for each (varXml in xml.factory.accessor) {
            if (varXml.@name.toString() == fieldName) {
                return ClassUtil.getClassByName(varXml.@type.toString());
            }
        }
        return null;
    }

    public static function getStaticFieldType (clazz :Class, fieldName :String) :*
    {
        var xml :XML = getClassDescription(clazz);
        for each (var varXml :XML in xml.variable) {
            if (varXml.@name.toString() == fieldName) {
                return ClassUtil.getClassByName(varXml.@type.toString());
            }
        }
        for each (varXml in xml.accessor) {
            if (varXml.@name.toString() == fieldName) {
                return ClassUtil.getClassByName(varXml.@type.toString());
            }
        }

        return null;
    }

    public static function getStaticVariableNames (clazz :Class) :Array
    {
        var variableList :Array = [];
        var xml :XML = getClassDescription(clazz);
        for each (var child :XML in xml.variable) {
            variableList.push(child.@name.toString());
        }
        return variableList;
    }

    public static function getVariableNames (clazz :Class) :Array
    {
        var variableList :Array = [];
        var xml :XML = getClassDescription(clazz);
        for each (var child :XML in xml.factory.variable) {
            variableList.push(child.@name.toString());
        }
        return variableList;
    }

    protected static function getClassDescription (clazz :Class) :XML
    {
        var clazzXML :XML = _classCache.get(clazz) as XML;
        if (clazzXML == null) {
            clazzXML = describeType(clazz);
            _classCache.put(clazz, clazzXML);
        }
        return clazzXML;
    }

    /**
     * Cache the class xml description.
     */
    protected static var _classCache :Map = Maps.newMapOf(Class);
}
}
