package
{
import com.threerings.ui.SimpleButtonPanel;
import com.threerings.ui.snapping.debug.TestSnapping;

import flash.display.Sprite;

[SWF(width="800", height="800", frameRate="30")]
public class Tests extends Sprite
{
    public function Tests()
    {
        //addChild(new TestFacebookDesktopSession());
        addChild(new TestSnapping());
        SimpleButtonPanel
    }
}
}

