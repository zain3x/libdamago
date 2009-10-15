package
{
import com.threerings.flashbang.debug.FlashbangAppRunner;
import com.threerings.pathfinding.debug.Tester;

import flash.display.Sprite;

[SWF(width="800", height="800", frameRate="30")]
public class Tests extends Sprite
{
    public function Tests ()
    {
//        addChild(new TestFacebookDesktopSession());
//        addChild(new TestSnapping());
//        SimpleButtonPanel
//        new Bou
        addChild(new Tester());
        new FlashbangAppRunner();
    }
}
}

