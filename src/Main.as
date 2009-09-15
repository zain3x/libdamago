package
{
import com.threerings.ui.snapping.debug.TestSnapping;

import flash.display.Sprite;

[SWF(width="800", height="800", frameRate="30")]
public class Main extends Sprite
{
    public function Main()
    {
//        addChild(new TestFacebookDesktopSession());
        addChild(new TestSnapping());
    }
}
}

