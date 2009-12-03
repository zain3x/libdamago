package com.threerings.ui {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;
import com.threerings.util.ArrayUtil;
import com.threerings.util.EventHandlerManager;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.MathUtil;
import com.threerings.util.Predicates;
import aduros.util.F;
public class ScrollableElementView
{

    public function ScrollableElementView (elementContainers :Array,
                                         leftUpButton :InteractiveObject = null,
                                         bottomDownButton :InteractiveObject = null,
                                         leftUpScroll1Page :InteractiveObject = null,
                                         rightBottomScroll1Page :InteractiveObject = null,
                                         firstIdxButton :InteractiveObject = null,
                                         lastIdxButton :InteractiveObject = null,
                                         hideButtonsIfNoScrolling :Boolean = true)
    {
        _elementContainers = elementContainers;

        _leftUpButton = leftUpButton;
        _bottomDownButton = bottomDownButton;
        _leftUpScroll1Page = leftUpScroll1Page;
        _rightBottomScroll1Page = rightBottomScroll1Page;
        _firstIdxButton = firstIdxButton;
        _lastIdxButton = lastIdxButton;

        if (leftUpButton != null) {
            _events.registerListener(leftUpButton, MouseEvent.CLICK, scrollLeftUp);
        }

        if (bottomDownButton != null) {
            _events.registerListener(bottomDownButton, MouseEvent.CLICK, scrollDownRight);
        }

        if (leftUpScroll1Page != null) {
            _events.registerListener(leftUpScroll1Page, MouseEvent.CLICK, scrollLeftUp1Page);
        }

        if (rightBottomScroll1Page != null) {
            _events.registerListener(rightBottomScroll1Page, MouseEvent.CLICK, scrollRightDown1Page);
        }

        if (firstIdxButton != null) {
            _events.registerListener(firstIdxButton, MouseEvent.CLICK, scrollMaxLeftUp);
        }

        if (lastIdxButton != null) {
            _events.registerListener(lastIdxButton, MouseEvent.CLICK, scrollMaxRightDown);
        }

        _hideButtonsIfNoScrolling = hideButtonsIfNoScrolling;
    }


    public function get index () :int
    {
        return _topLeftIdx;
    }

    public function set index (val :int) :void
    {
        _topLeftIdx = val;
        redrawElements();
    }

    public function addElement (obj :Object, getDisplay :Function = null) :void
    {
        if (getDisplay == null) {
            if (!(obj is DisplayObject)) {
                throw new Error("addElement: obj is not a DisplayObject and getDisplay == null." +
                    "\n If adding a non-DisplayObject, supply a function getDisplay(obj*) :" +
                    "DisplayObject");
            }
            getDisplay = getObjectAsDisplayObject;
        }
        _elements.push(obj);
        _elementDisplayFunctions.put(obj, getDisplay);
        redrawElements();
    }

    public function clear () :void
    {
        _elementContainers.forEach(F.adapt(DisplayUtils.removeAllChildren));
        _elements = [];
        _elementDisplayFunctions.clear();
        _topLeftIdx = 0;
        redrawElements();
    }

    public function containerSize () :int
    {
        if (null == _elementContainers) {
            return 0;
        }
        return _elementContainers.length;
    }

    public function elementsSize () :int
    {
        if (null == _elements) {
            return 0;
        }
        return _elements.length;
    }

    public function getElementAt (idx :int) :*
    {
        return _elements[idx];
    }

    public function redrawElements () :void
    {
        _elementContainers.forEach(F.adapt(DisplayUtils.removeAllChildren));

        var containerIdx :int = 0;
        _bottomRightIdx = _topLeftIdx;
        for (var elementIdx :int = _topLeftIdx;
            elementIdx < _elements.length && containerIdx < _elementContainers.length;
            ++elementIdx, ++containerIdx) {

            if (_elements[elementIdx] != null) {
                var element :Object = _elements[elementIdx];
                var f :Function = _elementDisplayFunctions.get(element) as Function;
                DisplayObjectContainer(_elementContainers[containerIdx]).addChild(
                    f(element) as DisplayObject);
            }
            _bottomRightIdx = elementIdx;
        }
        checkForHidingButtons();
    }

    public function removeElement (d :Object) :void
    {
        ArrayUtil.removeAll(_elements, d);
        _elementDisplayFunctions.remove(d);
        redrawElements()
    }

    public function removeGaps () :void
    {
        ArrayUtil.removeAllIf(_elements, Predicates.isNull);
        redrawElements();
    }

    public function shutdown () :void
    {
        clear();
        _events.freeAllHandlers();
    }

    protected function checkForHidingButtons () :void
    {
        var button :InteractiveObject;
        for each (button in [_firstIdxButton, _leftUpButton, _leftUpScroll1Page]) {
            if (_topLeftIdx == 0) {
//                trace("Hiding left buttons, _topLeftIdx=" + _topLeftIdx);
                hideAndDisableButton(button);
            } else {
//                trace("showing left buttons, _topLeftIdx=" + _topLeftIdx);
                enableButton(button);
            }
        }

        for each (button in [_lastIdxButton, _bottomDownButton, _rightBottomScroll1Page]) {
            if (_bottomRightIdx == _elements.length - 1) {
                trace("Hiding right buttons, _bottomRightIdx=" + _bottomRightIdx, "_elements.length=" + _elements.length);
                hideAndDisableButton(button);
            } else {
                trace("showing right buttons, _bottomRightIdx=" + _bottomRightIdx, "_elements.length=" + _elements.length);
                enableButton(button);
            }
        }
    }

    protected function enableButton (button :InteractiveObject) :void
    {
        if (null == button) {
            return;
        }

        if (null != _enableButtonFunctions.get(button)) {
            var enable :Function = _enableButtonFunctions.get(button) as Function;
            enable();
            _enableButtonFunctions.remove(button);
        }
    }

    protected function hideAndDisableButton (button :InteractiveObject) :void
    {
        if (null == button) {
            return;
        }

        if (null != _enableButtonFunctions.get(button)) {
            return;
        }

        var buttonParent :DisplayObjectContainer = button.parent;
        var idx :int = buttonParent.getChildIndex(button);
        function enable () :void {
            buttonParent.addChildAt(button, idx);
        }

        _enableButtonFunctions.put(button, enable);
        DisplayUtils.detach(button);
    }

    protected function scrollDownRight (...ignored) :Boolean
    {
        if (_bottomRightIdx == _elements.length - 1) {
            return false;
        }
        _topLeftIdx++;
        _topLeftIdx = MathUtil.clamp(_topLeftIdx, 0, _elements.length - 1);
        redrawElements();
        return true;
    }

    protected function scrollLeftUp (...ignored) :void
    {
        _topLeftIdx--;
        _topLeftIdx = MathUtil.clamp(_topLeftIdx, 0, _elements.length - 1);
        redrawElements();
    }

    protected function scrollLeftUp1Page (...ignored) :void
    {
        var elementSize :int = _bottomRightIdx - _topLeftIdx;
        _topLeftIdx = MathUtil.clamp(_topLeftIdx - elementSize - 1, 0, _elements.length - 1);
        redrawElements();
    }

    protected function scrollMaxLeftUp (...ignored) :void
    {
        _topLeftIdx = 0;
        redrawElements();
    }

    protected function scrollMaxRightDown (...ignored) :void
    {
        while (scrollDownRight()) {}
    }

    protected function scrollRightDown1Page (...ignored) :void
    {
        var elementSize :int = _bottomRightIdx - _topLeftIdx;
        _topLeftIdx = MathUtil.clamp(_topLeftIdx + elementSize + 1, 0, _elements.length - elementSize - 1);
        redrawElements();
    }


//    protected function scrollDownRight (...ignored) :Boolean
//    {
//        if (_bottomRightIdx == _elements.length - 1) {
//            return false;
//        }
//        _topLeftIdx++;
//        _topLeftIdx = MathUtil.clamp(_topLeftIdx, 0, _elements.length - 1);
//        redrawElements();
//        return true;
//    }
//
//    protected function scrollLeftUp (...ignored) :void
//    {
//        _topLeftIdx--;
//        _topLeftIdx = MathUtil.clamp(_topLeftIdx, 0, _elements.length - 1);
//        redrawElements();
//    }
//
//    protected function scrollLeftUp1Page (...ignored) :void
//    {
//        var elementSize :int = _bottomRightIdx - _topLeftIdx;
//        _topLeftIdx = MathUtil.clamp(_topLeftIdx - elementSize - 1, 0, _elements.length - 1);
//        redrawElements();
//    }
//
//    protected function scrollMaxLeftUp (...ignored) :void
//    {
//        _topLeftIdx = 0;
//        redrawElements();
//    }
//
//    protected function scrollMaxRightDown (...ignored) :void
//    {
//        while (scrollDownRight()) {}
//    }
//
//    protected function scrollRightDown1Page (...ignored) :void
//    {
//        var elementSize :int = _bottomRightIdx - _topLeftIdx;
//        _topLeftIdx = MathUtil.clamp(_topLeftIdx + elementSize + 1, 0, _elements.length - elementSize - 1);
//        redrawElements();
//    }

    protected static function getObjectAsDisplayObject (obj :Object) :DisplayObject
    {
        return DisplayObject(obj);
    }
    protected var _bottomDownButton :InteractiveObject;
    protected var _bottomRightIdx :int = 0;

    protected var _elementContainers :Array;
    protected var _elementDisplayFunctions :Map = Maps.newMapOf(Object);
    protected var _elements :Array = [];

    protected var _enableButtonFunctions :Map = Maps.newMapOf(InteractiveObject);

    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _firstIdxButton :InteractiveObject;
    protected var _hideButtonsIfNoScrolling :Boolean;
    protected var _lastIdxButton :InteractiveObject;

    protected var _leftUpButton :InteractiveObject;
    protected var _leftUpScroll1Page :InteractiveObject;
    protected var _rightBottomScroll1Page :InteractiveObject;

    protected var _topLeftIdx :int = 0;
}
}
