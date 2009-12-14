package
{
import com.threerings.flashbang.debug.FlashbangAppRunner;
import com.threerings.flashbang.pushbutton.EntityComponent;
import com.threerings.flashbang.pushbutton.GameObjectEntity;
import com.threerings.flashbang.pushbutton.scene.tests.TestSceneBounds;
import com.threerings.flashbang.pushbutton.scene.tests.TestYOrderingLayer;

[SWF(width="600", height="600", frameRate="30")]
public class Tests extends FlashbangAppRunner
{
    public function Tests ()
    {
//        IEntityExtended
//        IEntityComponentEx
        EntityComponent
        GameObjectEntity
//        queueAppMode(new TestYOrderingLayer());
        queueAppMode(new TestSceneBounds());

//        addChild(new TestFacebookDesktopSession());
//        addChild(new TestFacebookDesktopSession());
//        addChild(new TestSnapping());
//        SimpleButtonPanel
//        new Bou
//        addChild(new Tester());
//        new FlashbangAppRunner();
    }
}
}

