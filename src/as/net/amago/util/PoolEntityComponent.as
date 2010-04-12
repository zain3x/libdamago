package net.amago.util
{
import com.pblabs.engine.entity.IEntityComponent;
import com.threerings.util.Preconditions;

public class PoolEntityComponent extends ObjectPool
{
    public function PoolEntityComponent()
    {
        super(IEntityComponent);
    }

    override public function addObject (o :*) :void
    {
        var comp :IEntityComponent = o as IEntityComponent;
        Preconditions.checkNotNull(comp);
        Preconditions.checkArgument(!comp.isRegistered, "Trying to add an IEntityComponent" +
            " to the pool that is still registered.");
        super.addObject(o);
    }
}
}