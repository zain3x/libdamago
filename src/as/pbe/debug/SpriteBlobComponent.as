package net.amago.pbe.debug {
import com.pblabs.rendering2D.DisplayObjectRenderer;
import com.threerings.ui.TextBits;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.text.TextField;

public class SpriteBlobComponent extends DisplayObjectRenderer
{
    public function SpriteBlobComponent ()
    {
        super();
        _displayObject = new Sprite();
		_textField = TextBits.createText("", 1.5);
		_textField.y = -10;
		_textField.x = -30;
		Sprite(_displayObject).addChild(_textField);
		_color = 0x0000ff;
        redraw();
    }

    public function set color (val :uint) :void
    {
        _color = val;
        redraw();
    }
	
	public function set label (val :String) :void
	{
		_textField.text = val;
	}

    override public function set displayObject (value :DisplayObject) :void
    {
        throw new Error("Cannot set displayObject in SpriteBlobComponent; it is always a Sprite");
    }

    public function set radius (val :Number) :void
    {
        _radius = val;
        redraw();
    }

    protected function redraw () :void
    {
        var g :Graphics = Sprite(_displayObject).graphics;
        g.clear();
        g.beginFill(_color);
        g.drawCircle(0, 0, _radius);
        g.endFill();
    }
	
    protected var _color :uint = 0x000000;
    protected var _radius :Number = 10;
	protected var _textField :TextField;
}
}