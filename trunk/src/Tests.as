package
{
import com.plabs.components.tasks.After;
import com.plabs.components.tasks.AnimateValueTask;
import com.plabs.components.tasks.ColorMatrixBlendTask;
import com.plabs.components.tasks.FunctionTask;
import com.plabs.components.tasks.GoToFrameTask;
import com.plabs.components.tasks.InterpolatingTask;
import com.plabs.components.tasks.LocationTask;
import com.plabs.components.tasks.ParallelTask;
import com.plabs.components.tasks.PlayFramesTask;
import com.plabs.components.tasks.RepeatingTask;
import com.plabs.components.tasks.ScaleTask;
import com.plabs.components.tasks.SelfDestructTask;
import com.plabs.components.tasks.SerialTask;
import com.plabs.components.tasks.TaskComponent;
import com.plabs.components.tasks.TaskContainer;
import com.plabs.components.tasks.TimedTask;
import com.plabs.components.tasks.VisibleTask;
import com.plabs.components.tasks.WaitForFrameTask;
import com.plabs.components.tasks.WaitOnPredicateTask;
import com.plabs.components.tasks.When;
import com.threerings.flashbang.debug.FlashbangAppRunner;
import com.threerings.flashbang.pushbutton.EntityComponentEventManager;
import com.threerings.flashbang.pushbutton.GameObjectEntity;
import com.threerings.flashbang.pushbutton.scene.tests.TestSceneBounds;
import com.threerings.flashbang.pushbutton.scene.tests.TestYOrderingLayer;

[SWF(width="600", height="600", frameRate="30")]
public class Tests extends FlashbangAppRunner
{
    public function Tests ()
    {
        AnimateValueTask
        FunctionTask
        GoToFrameTask
        TaskContainer
        LocationTask
        InterpolatingTask
        PlayFramesTask
        RepeatingTask
        ScaleTask
        TaskComponent
//        When(
        WaitOnPredicateTask
        WaitForFrameTask
        VisibleTask
        TimedTask
        SerialTask
        SelfDestructTask
        ScaleTask
        ParallelTask
        LocationTask
        ColorMatrixBlendTask
//        After()

//        IEntityExtended
//        IEntityComponentEx
        EntityComponentEventManager
        GameObjectEntity
        queueAppMode(new TestYOrderingLayer());
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

