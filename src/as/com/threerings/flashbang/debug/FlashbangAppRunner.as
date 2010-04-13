package com.threerings.flashbang.debug
{

import com.threerings.util.F;

import com.threerings.flashbang.AppMode;
import com.threerings.flashbang.FlashbangApp;
import com.threerings.ui.SimpleTextButton;
import com.threerings.util.DelayUtil;
import com.threerings.util.DisplayUtils;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

[SWF(width="500", height="500", frameRate="30")]
public class FlashbangAppRunner extends Sprite
{
    public function FlashbangAppRunner (mode :AppMode = null)
    {
        addChild(_bottomLayer);
        addChild(_topLayer);
        if (mode != null) {
            queueAppMode(mode);
        }
    }

    public function queueAppMode (mode :AppMode) :void
    {
        _queuedModes.push(mode);
        if (_currentMode == null) {
            runNextMode();
        }
    }

    protected function runNextMode () :void
    {
        if (_queuedModes.length == 0) {
            return;
        }
        var mode :AppMode = _queuedModes.pop() as AppMode;
        _currentMode = mode;

        var framerate :FramerateView = new FramerateView();
        framerate.x = 100;
        mode.addSceneObject(framerate);
        var game :FlashbangApp = new FlashbangApp();
        game.ctx.mainLoop.pushMode(mode);
        game.run(_bottomLayer);

        var closeButton :SimpleButton = createButton();
		_topLayer.addChild(closeButton);
        
        closeButton.addEventListener(MouseEvent.CLICK, F.justOnce(function() :void {
                game.shutdown();
                DisplayUtils.detach(closeButton);
                _currentMode = null;
				DelayUtil.delayFrame(runNextMode);
            }));
    }
	
	protected function createButton () :SimpleButton
	{
		var closeButton :SimpleTextButton = new SimpleTextButton("Close/Next");
//		closeButton.x = this.stage.stageWidth - closeButton.width;
		return closeButton;
	}

    protected var _currentMode :AppMode;
    protected var _queuedModes :Array = [];
    protected var _topLayer :Sprite = new Sprite();
    protected var _bottomLayer :Sprite = new Sprite();

}
}
