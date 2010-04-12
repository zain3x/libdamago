package net.amago.util
{
import com.threerings.util.DisplayUtils;
import com.threerings.util.Preconditions;

import flash.display.MovieClip;
import flash.display.Sprite;

public class PoolSprite extends ObjectPool
{
    public function PoolSprite()
    {
        super(Sprite);
    }

    override public function addObject (o :*) :void
    {
        Preconditions.checkArgument(!(o is MovieClip), "Sprites, not MovieClips");
        var s :Sprite = o as Sprite;

        //Clean up the Sprite.
        DisplayUtils.detach(s);
        DisplayUtils.removeAllChildren(s);
        s.graphics.clear();
        s.x = 0;
        s.y = 0;
        s.scaleX = s.scaleY = 1;
        s.alpha = 1;
        trace("adding a sprite, total", size);
        super.addObject(s);
    }

}
}