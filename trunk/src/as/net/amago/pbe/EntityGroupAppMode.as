package net.amago.pbe {
import com.threerings.flashbang.pushbutton.EntityAppmode;

/**
 * Instatiates a group of entities upon init
 */
public class EntityGroupAppMode extends EntityAppmode
{
    public function EntityGroupAppMode (groupName :String)
    {
        _groupName = groupName;
    }
    
    override protected function setup() : void
    {
        super.setup();
    }
    
    protected var _groupName :String;
}
}