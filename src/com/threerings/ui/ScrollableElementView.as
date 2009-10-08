package com.threerings.ui {
    import aduros.util.F;

    import com.threerings.ui.DisplayUtils;
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.Predicates;

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;


public class ScrollableElementView
{
    public function ScrollableElementView (elementContainers :Array)
    {
        _elementContainers = elementContainers;
    }

    public function addElement (d :DisplayObject) :void
    {
        _elements.push(d);
        redrawElements();
    }

    public function removeElement (d :DisplayObject) :void
    {
        ArrayUtil.removeAll(_elements, d);
        redrawElements()
    }

    public function scrollRightDown1Page (...ignored) :void
    {
        if (_topLeftIdx + _elementContainers.length >= _elements.length) {
            _topLeftIdx += _elementContainers.length;
            redrawElements();
        }
    }

    public function scrollLeftUp1Page (...ignored) :void
    {
        _topLeftIdx -= _elementContainers.length;
        _topLeftIdx = Math.max(_topLeftIdx, 0);
        redrawElements();
    }

    public function removeGaps () :void
    {
        ArrayUtil.removeAllIf(_elements, Predicates.createEquals(null));
        redrawElements();
    }

    public function redrawElements () :void
    {
        _elementContainers.forEach(F.adapt(DisplayUtils.removeAllChildren));

        for (var elementIdx :int = _topLeftIdx, var containerIdx :int = 0;
            elementIdx < _elements.length && containerIdx < _elementContainers.length;
            ++ii, ++containerIdx) {

            if (_elements[elementIdx] != null) {
                DisplayObjectContainer(_elementContainers[containerIdx]).addChild(
                    _elements[elementIdx]);
            }

        }
    }

    public function shutdown () :void
    {
        _elementContainers = null;
        _elements = null;
    }

    protected var _topLeftIdx :int = 0;
    protected var _elementContainers :Array;
    protected var _elements :Array = [];
}
}