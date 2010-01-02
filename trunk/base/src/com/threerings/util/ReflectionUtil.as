//
// $Id: ReflectionUtil.as 4203 2009-08-04 00:43:52Z tim $

package com.threerings.util {

import flash.utils.describeType;

import com.threerings.util.ClassUtil;

public class ReflectionUtil
{
    public static function getFieldType (clazz :Class, fieldName :String) :*
    {
        var xml :XML = describeType(clazz);
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

    public static function getVariableNames (clazz :Class) :Array
    {
        var variableList :Array = [];
        var xml :XML = describeType(clazz);
        for each (var child :XML in xml.factory.variable) {
            variableList.push(child.@name.toString());
        }
        return variableList;
    }

    public static function getAccessorNames (clazz :Class) :Array
    {
        var variableList :Array = [];
        var xml :XML = describeType(clazz);
        for each (var child :XML in xml.factory.accessor) {
            variableList.push(child.@name.toString());
        }
        return variableList;
    }
}
}
