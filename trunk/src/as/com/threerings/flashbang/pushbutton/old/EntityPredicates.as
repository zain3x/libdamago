package com.threerings.flashbang.pushbutton.old {
import com.threerings.util.Predicates;

public class EntityPredicates
{
    public static function createHasName (name :String) :Function
    {
        return Predicates.createPropertyEquals("objectName", name);
    }
}
}