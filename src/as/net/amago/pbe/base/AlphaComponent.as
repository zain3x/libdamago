package net.amago.pbe.base {
import com.threerings.util.ClassUtil;

public class AlphaComponent extends NotifyingValueComponent
{
    public static const CHANGED :String = ClassUtil.tinyClassName(AlphaComponent) + "Changed";
    public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(AlphaComponent);

    public function get alpha () :Number
    {
        return _value;
    }

    public function set alpha (val :Number) :void
    {
        setValue(val);
    }

    override protected function get eventName () :String
    {
        return CHANGED;
    }
}
}