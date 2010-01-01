package net.amago.pbe.debug {
import com.pblabs.engine.PBE;
import com.pblabs.engine.core.TemplateManager;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.rendering2D.ui.IUITarget;
import com.pblabs.rendering2D.ui.SceneView;
import com.threerings.flashbang.AppMode;
import com.threerings.flashbang.resource.XmlResource;
import com.threerings.util.Util;
import com.threerings.util.XmlUtil;

import flash.display.Sprite;

/**
 * Level/Screen/Mode transition management in Pushbutton is currently either primitive or overly
 * complex or broken.  If you want to use this class stand alone, just supply a parent sprite
 * (likely your main stage sprite) to the constructor.
 */
public class PBEAppmode extends AppMode
{
    public function PBEAppmode (xmlClasses :Object)
    {
        super();
        _xmlClazzes = xmlClasses;
    }

    /**
     * As much as possible, destroy all the static PBE stuff.
     */
    override protected function destroy () :void
    {
        super.destroy();
        for each (var entityName :String in Util.keys(PBE.nameManager.entityList)) {
			var entity :IEntity = PBE.nameManager.lookup(entityName);
			if (entity != null) {
            	entity.destroy();
			}
        }

    }

    override protected function setup () :void
    {
        super.setup();
		for (var name :String in _xmlClazzes) {
			var clazz :Class = _xmlClazzes[name] as Class;
			ctx.rsrcs.queueResourceLoad("xml", name, {embeddedClass:clazz});
		}
		
		ctx.rsrcs.loadQueuedResources(onLoaded);
    }
	
	protected function onLoaded () :void
	{
		_view = new SceneView();
		modeSprite.addChild(_view as Sprite);
		PBE.initializeScene(_view);
		
		for (var name :String in _xmlClazzes) {
			addToTemplateManater(XmlResource(ctx.rsrcs.getResource(name)).xml);
		}
		
		for (name in _xmlClazzes) {
			loadLevel(XmlResource(ctx.rsrcs.getResource(name)).xml);
		}
		
	}
	
	protected function addToTemplateManater (xml :XML) :void
	{
		//Make sure all the types are registered
		for each (var xmlChild :XML in xml.children()) {
			trace("adding " + XmlUtil.getAttr(xmlChild, "name", null));
			TemplateManager.instance.addXML(xmlChild, "", 0);
		}	
	}

    protected function loadLevel (xml :XML) :void
    {
        //Instantiate all the entities
        for each (var xmlChild :XML in xml.child("entity")) {
			trace("instantiating " + XmlUtil.getAttr(xmlChild, "name", null));
            TemplateManager.instance.instantiateEntity(XmlUtil.getAttr(xmlChild, "name", null));
        }

    }

    protected var _xmlClazzes :Object;
    protected var _view :IUITarget;
}
}