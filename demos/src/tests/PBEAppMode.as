package tests {
import com.pblabs.engine.PBE;
import com.pblabs.engine.core.TemplateManager;
import com.pblabs.engine.resource.ResourceManager;
import com.pblabs.engine.resource.XMLResource;
import com.pblabs.rendering2D.SimpleSpatialComponent;
import com.pblabs.rendering2D.ui.IUITarget;
import com.pblabs.rendering2D.ui.SceneView;
import com.threerings.flashbang.AppMode;

import flash.display.Sprite;
import flash.utils.ByteArray;

import net.amago.pathfinding.navmesh.pbe.PolygonRenderer;

public class PBEAppMode extends AppMode
{
    public function PBEAppMode ()
    {
        super(); 
		PolygonRenderer
		SimpleSpatialComponent
    }

    override protected function destroy () :void
    {
        super.destroy();
		
    }

    override protected function setup () :void
    {
        super.setup();
		PBE.startup(modeSprite);
		var view :IUITarget = new SceneView();
		modeSprite.addChild(view as Sprite);
		PBE.initializeScene(view);

		ResourceManager.instance.onlyLoadEmbeddedResources = true;
		ResourceManager.instance.registerEmbeddedResource("../../rsrc/gamedata.xml", XMLResource, new DATA() as ByteArray);
		
		registerOneShotCallback(TemplateManager.instance, TemplateManager.LOADED_EVENT, 
			function (...ignored) :void {
				TemplateManager.instance.instantiateGroup("Everything");
			});
		TemplateManager.instance.loadFile("../../rsrc/gamedata.xml"); 
	}
	
	[Embed(source="../../assets/gamedata.xml", mimeType='application/octet-stream')]
	public static const DATA :Class;
}
}
