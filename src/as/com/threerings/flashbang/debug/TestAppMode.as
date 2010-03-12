package com.threerings.flashbang.debug
{
    import com.threerings.ui.SimpleTextButton;
    import com.threerings.util.ClassUtil;
    import com.threerings.flashbang.AppMode;
    import com.threerings.flashbang.MainLoop;

    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;

    /**
    * Utility class for testing visual/interactive classes.
    */
    public class TestAppMode extends AppMode
    {
        protected var _nextTestButton :SimpleTextButton;
        protected var _replayButton :SimpleTextButton;
        protected var txt:TextField;

//        protected var _mainLoop :MainLoop;

        public function TestAppMode (description :String)
        {
//            _mainLoop = mainLoop;
             _nextTestButton = new SimpleTextButton("Next test");
             _nextTestButton.addEventListener(MouseEvent.CLICK, popme);

             _replayButton = new SimpleTextButton("Replay");
             _replayButton.addEventListener(MouseEvent.CLICK, replay);
             _replayButton.y = 30;

             txt = new TextField();
             txt.selectable = false;
             txt.mouseEnabled = false;
             txt.width = 200;
             txt.height = 50;
             txt.text = description;
             txt.x = 100;
             txt.y = 10;
             txt.scaleX = 2;
             txt.scaleY = 2;

        }

        override protected function enter() :void
        {
             modeSprite.addChild(_nextTestButton);
//             modeSprite.addChild( _replayButton);
             modeSprite.addChild(txt);
        }

        override protected function exit() :void
        {
             _nextTestButton.removeEventListener(MouseEvent.CLICK, popme);
        }

        protected function popme(... ignored) :void
        {
            TesterContext.game.ctx.mainLoop.popMode();
        }

        protected function replay(... ignored) :void
        {
            var modeClass :Class = ClassUtil.getClass(this);
            trace(ClassUtil.getClassName( this));
            TesterContext.game.ctx.mainLoop.insertMode( new modeClass(), 0);
            TesterContext.game.ctx.mainLoop.popMode();
        }

        public static function createTextButton( txt :String, _x :int, _y :int, callback :Function, parent :Sprite) :SimpleTextButton
        {
             var button :SimpleTextButton = new SimpleTextButton(txt);
             if( callback != null) {
                button.addEventListener(MouseEvent.CLICK, callback);
             }
             parent.addChild( button);
             button.x = _x;
             button.y = _y;
             return button;
        }

//        override public function onKeyDown(keyCode:uint):void
//        {
//            trace("TestAppMode key=" + keyCode);
////            if( keyCode == KeyboardCodes.ENTER || keyCode == KeyboardCodes.SPACE) {
////                popme();
////            }
//        }


    }
}
