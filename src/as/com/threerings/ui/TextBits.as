//
// $Id$

package com.threerings.ui{

import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

public class TextBits
{
    public static function createText (text :String, textScale :Number = 1, maxWidth :int = 0,
        textColor :uint = 0, align :String = "center", htmlText :Boolean = false) :TextField
    {
        var tf :TextField = new TextField();
        initTextField(tf, text, textScale, maxWidth, textColor, align, htmlText);

        return tf;
    }

    public static function createInputText (width :int, height :int, textScale :Number = 1,
        textColor :uint = 0, initialText :String = "") :TextField
    {
        var tf :TextField = new TextField();
        tf.type = TextFieldType.INPUT;
        tf.mouseEnabled = true;
        tf.selectable = true;
        tf.multiline = true;
        tf.wordWrap = false;
        tf.border = true;
        tf.width = width / textScale;
        tf.height = height / textScale;
        tf.scaleX = tf.scaleY = textScale;

        var format :TextFormat = tf.defaultTextFormat;
        if (textColor > 0) {
            format.color = textColor;
        }
        tf.setTextFormat(format);

        tf.text = initialText;

        return tf;
    }

    public static function initTextField (tf :TextField, text :String, textScale :Number = 1,
        maxWidth :int = 0, textColor :uint = 0, align :String = "center",
        htmlText :Boolean = false) :void
    {
        var wordWrap :Boolean = (maxWidth > 0);

        tf.mouseEnabled = false;
        tf.selectable = false;
        tf.multiline = true;
        tf.wordWrap = wordWrap;
        tf.scaleX = textScale;
        tf.scaleY = textScale;
        // If this is not set to true, modifying the TextField's alpha won't work
        // But it cannot be set to true if we're using the built-in fonts
//        tf.embedFonts = true;
        tf.antiAliasType = AntiAliasType.ADVANCED;

        if (wordWrap) {
            tf.width = maxWidth / textScale;
        } else {
            tf.autoSize = TextFieldAutoSize.LEFT;
        }

        var format :TextFormat = tf.defaultTextFormat;
        format.font = "Arial";
        format.align = align;
        if (textColor > 0) {
            format.color = textColor;
        }

        if (htmlText) {
            tf.defaultTextFormat = format;
            tf.htmlText = text;
        } else {
            tf.text = text;
            tf.setTextFormat(format);
        }

        if (wordWrap) {
            // if the text isn't as wide as maxWidth, shrink the TextField
            tf.width = tf.textWidth + TEXT_WIDTH_PAD;
            tf.height = tf.textHeight + TEXT_HEIGHT_PAD;
        }
    }

    protected static const TEXT_WIDTH_PAD :int = 5;
    protected static const TEXT_HEIGHT_PAD :int = 4;
}

}
