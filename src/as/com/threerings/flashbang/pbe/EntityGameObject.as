package com.threerings.flashbang.pbe {
    

public class EntityGameObject extends EntityObject
{
    public function EntityGameObject (name :String = null)
    {
        super(name);
        addComponent(new UpdaterComponent(updateInternal), "updater");
    }
    
    protected function update (dt :Number) :void
    {
        //Override 
    }
    
    private function updateInternal (dt :Number) :void
    {
        update(dt);
    }
    
    
}
}