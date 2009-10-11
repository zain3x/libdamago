package com.threerings.pathfinding.debug
{
import com.threerings.flashbang.Config;
import com.threerings.flashbang.FlashbangApp;
import com.threerings.util.Log;

import flash.display.Sprite;
import flash.events.Event;

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
        _game = new FlashbangApp(gameConfig);

        _game.ctx.mainLoop.setup();
        _game.ctx.mainLoop.run(this);


        _game.ctx.mainLoop.pushMode( new QuitAppMode() );
        _game.ctx.mainLoop.pushMode( new TestNavigationMeshPathfinding());

    }

    protected function unload (..._) :void
    {
        _game.shutdown();
    }

    protected var _game :FlashbangApp;
}
}

import flash.system.fscommand;
import com.threerings.flashbang.AppMode;

class QuitAppMode extends AppMode
{
    override protected function enter() :void
    {
        fscommand("quit");
    }

}
