package com.threerings.ui
{
import aduros.util.F;

import com.whirled.contrib.EventHandlerManager;

import flash.events.MouseEvent;

public class SimpleButtonPanel extends ArrayView
{
    public function SimpleButtonPanel (type :OrientationType)
    {
        super(type);
    }

    public function createAndAddButton (name :String, onClick :Function) :SimpleTextButton
    {
        var b :SimpleTextButton = new SimpleTextButton(name);
        _events.registerListener(b, MouseEvent.CLICK, F.adapt(onClick));
        super.add(b);
        return b;
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
        _elements = null;
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();

}
}