package com.threerings.flashbang.debug {
import flash.display.Sprite;

public class StandAlone extends Sprite
{
    /**
     *
     */
    public function StandAlone ()
    {
        var game :FlashbangApp = new FlashbangApp();
        game.run(this);
        game.ctx.mainLoop.pushMode(createAppMode());
    }

    /**
     *
     * @return
     * @throws Error
     */
    protected function createAppMode () :AppMode
    {
        throw new Error("Abstract method");
    }
}
}
