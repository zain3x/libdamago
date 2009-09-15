package libdamago.geometry.path.debug
{
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.Config;
import com.whirled.contrib.simplegame.SimpleGame;

import flash.display.Sprite;
import flash.events.Event;

import libdamago.geometry.Geometry;

/**
* Tests classes visually.  Each Appmode is a test
*/
[SWF(width="500", height="300", frameRate="30")]
public class Tester extends Sprite
{
    protected static const log :Log = Log.getLog( Tester );

    public function Tester()
    {

        addEventListener(Event.UNLOAD, unload);

        var gameConfig :Config = new Config();
        _game = new SimpleGame(gameConfig);

        _game.ctx.mainLoop.setup();
        _game.ctx.mainLoop.run(this);


        _game.ctx.mainLoop.pushMode( new QuitAppMode() );
        _game.ctx.mainLoop.pushMode( new TestNavigationMeshPathfinding());

    }

    protected function unload (..._) :void
    {
        _game.shutdown();
    }

    protected var _game :SimpleGame;
}
}

import com.whirled.contrib.simplegame.AppMode;

import flash.system.fscommand;

class QuitAppMode extends AppMode
{
    override protected function enter() :void
    {
        fscommand("quit");
    }

}
