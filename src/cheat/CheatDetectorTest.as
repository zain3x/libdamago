package cheat
{
import com.threerings.ui.SimpleTextButton;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

public class CheatDetectorTest extends Sprite
{
    public function CheatDetectorTest()
    {
        function cheater (key :String, trueValue :int, hackedValue :int) :void {
            trace("Cheat on " + key + ", true value=" + trueValue+ ", hacked value=" + hackedValue);
            _ch.set(key, _ch.get(key));
        }

        _ch = new CheatDetector(cheater);

        addEventListener(Event.ENTER_FRAME, enterFrame);

        _text = new TextField();
        addChild(_text);
        _text.x = 10;
        _text.y = 10;

        _button = new SimpleTextButton("increment");
        addChild(_button);
        _button.x = 10;
        _button.y = 30;
        function addScore (...ignored) :void {
            _ch.set("score", _ch.get("score") + 10);
        }
        _button.addEventListener(MouseEvent.CLICK, addScore);
        _ch.set("score", 20);
    }

    protected function enterFrame (...ignored) :void
    {
        _ch.update(1);
        _text.text = "" + _ch.get("score");
    }

    protected var _text :TextField;
    protected var _button :SimpleTextButton;
    protected var _ch :CheatDetector;
    protected var _scoreKey :String = "score";

}
}
