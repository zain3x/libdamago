package com.threerings.flashbang.pushbutton {
import com.pblabs.engine.core.ITickedObject;
import com.threerings.util.Preconditions;

public class UpdaterComponent extends EntityComponent 
    implements ITickedObject
{

    public function UpdaterComponent (callback :Function)
    {
        Preconditions.checkNotNull(callback);
        _callback = callback;
    }

    public function onTick (dt :Number) :void
    {
        _callback(dt);
    }

    protected var _callback :Function;
}
}