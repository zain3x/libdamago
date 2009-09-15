package com.whirled.contrib.simplegame
{
import flash.display.Sprite;

public class StandAlone extends Sprite
{
    public function StandAlone()
    {
        var game :SimpleGame = new SimpleGame();
        game.run(this);
        game.ctx.mainLoop.pushMode(createAppMode());
    }

    protected function createAppMode () :AppMode
    {
        throw new Error("Abstract method");
    }

}
}