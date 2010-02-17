package net.amago.pbe.debug {
import com.pblabs.engine.PBE;
import com.pblabs.engine.core.TemplateManager;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.rendering2D.DisplayObjectScene;
import com.pblabs.rendering2D.SceneAlignment;
import com.pblabs.rendering2D.ui.IUITarget;
import com.pblabs.rendering2D.ui.SceneView;
import com.threerings.flashbang.AppMode;
import com.threerings.flashbang.resource.XmlResource;
import com.threerings.ui.TextBits;
import com.threerings.util.Util;
import com.threerings.util.XmlUtil;

import flash.display.Sprite;
import flash.text.TextField;

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
				trace("destroying " + entityName);
            	entity.destroy();
			}
        }
		if (PBE.nameManager.lookup("SceneDB") != null) {
			PBE.nameManager.lookup("SceneDB").destroy();
		}
		
		TemplateManager.instance.removeXML("appmode");

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
	
	protected function addToTemplateManater (xml :XML) :void
	{
		//Make sure all the types are registered
		for each (var xmlChild :XML in xml.children()) {
			trace("adding " + XmlUtil.getAttr(xmlChild, "name", null));
			TemplateManager.instance.addXML(xmlChild, "appmode", 0);
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
	
	protected function onLoaded () :void
	{
		_view = new SceneView();
		modeSprite.addChild(_view as Sprite);
		var sceneEntity :IEntity = PBE.initializeScene(_view);
		var scene :DisplayObjectScene = sceneEntity.lookupComponentByType(DisplayObjectScene) as DisplayObjectScene;
		scene.sceneAlignment = SceneAlignment.TOP_LEFT;

		for (var name :String in _xmlClazzes) {
			addToTemplateManater(XmlResource(ctx.rsrcs.getResource(name)).xml);
			
			if (name == "level") {
				setLabel(XmlUtil.getStringAttr(XmlResource(ctx.rsrcs.getResource(name)).xml, "demoName", ""));
			}
		}
		
		for (name in _xmlClazzes) {
			loadLevel(XmlResource(ctx.rsrcs.getResource(name)).xml);
		}
		
	}
	
	protected function setLabel (val :String) :void
	{
		if (_title == null) {
			_title = TextBits.createText("", 3);
			modeSprite.addChild(_title);
			_title.x = 100;
			_title.y = 10;
		}
		_title.text = val;
	}
	protected var _title :TextField;
    protected var _view :IUITarget;

    protected var _xmlClazzes :Object;
}
}