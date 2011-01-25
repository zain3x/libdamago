package taskDemos {
import com.lorentz.SVG.SVGColor;
import com.lorentz.SVG.SVGParser;
import com.lorentz.SVG.StringUtil;

import flash.display.CapsStyle;
import flash.display.GradientType;
import flash.display.JointStyle;
import flash.display.Sprite;
import flash.geom.Matrix;

import org.svgweb.SVGViewerFlash;

public class SVGPolygonParserDemo extends Sprite
{

    [Embed(source="../../assets/demo02.pbelevel", mimeType='application/octet-stream')]
    public static const DATA :Class;
	protected var currentFontSize:Number;
	protected var currentViewBox:Object;
	
	protected var svg_object:Object;
	
	protected const WIDTH:String = "width";
	protected const HEIGHT:String = "height";
	protected const WIDTH_HEIGHT:String = "width_height";
	
    public function SVGPolygonParserDemo ()
    {
        var svgParser :SVGParser = new SVGParser(svg);
        var parsed :Object = svgParser.parse();
		visit(parsed);
    }

    protected function visit (elt :Object) :Sprite
    {
        var obj :Sprite;

//        inheritStyles(elt);


        //Save current fontSize and viewBoxSize, and set the new one
//        var oldFontSize :Number = currentFontSize;
//        var oldViewBox :* = currentViewBox;
//        if (elt.finalStyle["font-size"] != null) {
//            currentFontSize = getUserUnit(elt.finalStyle["font-size"], HEIGHT);
//        }
        if (elt.viewBox != null) {
            currentViewBox = elt.viewBox;
        }
        //
		trace("elt.type=" + elt.type);
        switch (elt.type) {
            case 'svg':
                obj = visitSvg(elt);
                break;

            case 'rect':
                obj = visitRect(elt);
                break;

            case 'path':
                obj = visitPath(elt);
                break;

            case 'polygon':
                obj = visitPolygon(elt);
                break;

            case 'polyline':
                obj = visitPolyline(elt);
                break;

            case 'line':
                obj = visitLine(elt);
                break;

            case 'circle':
				trace("not implemented");
//                obj = visitCircle(elt);
                break;

            case 'ellipse':
				trace("not implemented");
//                obj = visitEllipse(elt);
                break;

            case 'g':
//                obj = 
				visitG(elt);
                break;

            case 'text':
				trace("not implemented");
//                obj = visitText(elt);
                break;

            default:
                throw new Error("Unknown tag type " + elt.localName());
        }

        if (obj != null) {
            if (elt.transform)
                obj.transform.matrix = elt.transform;

//            if (elt.finalStyle["display"] == "none" || elt.finalStyle["visibility"] == "hidden") {
//                obj.visible = false;
//			}

            //Testing
//            if (elt.clipPath != null) {
//                var id :String = StringUtil.rtrim(String(elt.clipPath).split("(")[1], ")");
//                id = StringUtil.ltrim(id, "#");
//
//                var mask :* = visitClipPath(svg_object.defs[id]);
//
//                var newGroup :Sprite = new Sprite();
//                newGroup.addChild(obj);
//                newGroup.addChild(mask);
//                obj.mask = mask;
//
//                obj = newGroup;
//            }

            //Restore the old fontSize and viewBoxSize
//            currentFontSize = oldFontSize;
//            currentViewBox = oldViewBox;
                //
        }

        return obj;
    }
	
	private function visitG(elt:Object):void {
//		var s:Sprite = new Sprite();
//		s.name = elt.id != null ? elt.id : "g";
		
//		if( elt.x != null )
//			s.x = getUserUnit(elt.x, WIDTH);
//		if( elt.y != null )
//			s.y =  getUserUnit(elt.y, HEIGHT);
		
//		if(elt.transform)
//			s.transform.matrix = elt.transform;
		
		for each(var childElt:Object in elt.children) {
//			s.addChild(
				visit(childElt);//);
		}
//		return s;
	}

    protected function visitLine (elt :Object) :Sprite
    {
        var s :Sprite = new Sprite();
        s.name = elt.id != null ? elt.id : "line";

        var x1 :Number = getUserUnit(elt.x1, WIDTH);
        var y1 :Number = getUserUnit(elt.y1, HEIGHT);
        var x2 :Number = getUserUnit(elt.x2, WIDTH);
        var y2 :Number = getUserUnit(elt.y2, HEIGHT);

        lineStyle(s, elt);
        s.graphics.moveTo(x1, y1);
        s.graphics.lineTo(x2, y2);
        s.graphics.lineStyle();
        return s;
    }
	
	private function lineStyle(s:Sprite, elt:Object):void {
		return;
//		var color:uint = 0x000000;//SVGColor.parseToInt(elt.finalStyle.stroke);
//		var noStroke:Boolean = true;//elt.finalStyle.stroke==null || elt.finalStyle.stroke == '' || elt.finalStyle.stroke=="none";
//		
//		var stroke_opacity:Number = Number(elt.finalStyle["opacity"]?elt.finalStyle["opacity"]: (elt.finalStyle["stroke-opacity"]? elt.finalStyle["stroke-opacity"] : 1));
//		
//		var w:Number = 1;
//		if(elt.finalStyle["stroke-width"])
//			w = getUserUnit(elt.finalStyle["stroke-width"], WIDTH_HEIGHT);
//		
//		var stroke_linecap:String = CapsStyle.NONE;
//		
//		if(elt.finalStyle["stroke-linecap"]){
//			var linecap:String = StringUtil.trim(elt.finalStyle["stroke-linecap"]).toLowerCase(); 
//			if(linecap=="round")
//				stroke_linecap = CapsStyle.ROUND;
//			else if(linecap=="square")
//				stroke_linecap = CapsStyle.SQUARE;
//		}
//		
//		var stroke_linejoin:String = JointStyle.MITER;
//		
//		if(elt.finalStyle["stroke-linejoin"]){
//			var linejoin:String = StringUtil.trim(elt.finalStyle["stroke-linejoin"]).toLowerCase(); 
//			if(linejoin=="round")
//				stroke_linejoin = JointStyle.ROUND;
//			else if(linejoin=="bevel")
//				stroke_linejoin = JointStyle.BEVEL;
//		}
//		
//		if(!noStroke && elt.finalStyle.stroke.indexOf("url")>-1){
//			var id:String = StringUtil.rtrim(String(elt.finalStyle.stroke).split("(")[1], ")");
//			id = StringUtil.ltrim(id, "#");
//			
//			var grad:Object = svg_object.gradients[id];
//			
//			if(grad!=null){
//				switch(grad.type){
//					case GradientType.LINEAR: {
//						calculateLinearGradient(grad);
//						
//						s.graphics.lineGradientStyle(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb");
//						break;
//					}
//					case GradientType.RADIAL: {
//						calculateRadialGradient(grad);
//						
//						if(grad.r==0)
//							s.graphics.lineStyle(w, grad.colors[grad.colors.length-1], grad.alphas[grad.alphas.length-1], true, "normal", stroke_linecap, stroke_linejoin);
//						else
//							s.graphics.lineGradientStyle(grad.type, grad.colors, grad.alphas, grad.ratios, grad.mat, grad.spreadMethod, "rgb", grad.focalRatio);
//						
//						break;
//					}
//				}
//			}
//			return;
//		} else if(noStroke)
//			s.graphics.lineStyle();
//		else
//			s.graphics.lineStyle(w, color, stroke_opacity, true, "normal", stroke_linecap, stroke_linejoin);
	}
	
	private function calculateLinearGradient(grad:Object):void {
		var x1:Number = getUserUnit(grad.x1, WIDTH);
		var y1:Number = getUserUnit(grad.y1, HEIGHT);
		var x2:Number = getUserUnit(grad.x2, WIDTH);
		var y2:Number = getUserUnit(grad.y2, HEIGHT);
		
		grad.mat = flashLinearGradientMatrix(x1, y1, x2, y2);
	}
	
	private function flashLinearGradientMatrix( x1:Number, y1:Number, x2:Number, y2:Number ):Matrix { 
		var w:Number = x2-x1;
		var h:Number = y2-y1; 
		var a:Number = Math.atan2(h,w); 
		var vl:Number = Math.sqrt( Math.pow(w,2) + Math.pow(h,2) ); 
		
		var matr:Matrix = new flash.geom.Matrix(); 
		matr.createGradientBox( 1, 1, 0, 0., 0. ); 
		
		matr.rotate( a ); 
		matr.scale( vl, vl ); 
		matr.translate( x1, y1 ); 
		
		return matr; 
	} 
	
	private function calculateRadialGradient(grad:Object):void {
		var cx:Number = getUserUnit(grad.cx, WIDTH);
		var cy:Number = getUserUnit(grad.cy, HEIGHT);
		var r:Number = getUserUnit(grad.r, WIDTH);
		var fx:Number = getUserUnit(grad.fx, WIDTH);
		var fy:Number = getUserUnit(grad.fy, HEIGHT);
		
		grad.mat = flashRadialGradientMatrix(cx, cy, r, fx, fy);  
		
		var f:* = { x:fx-cx, y:fy-cy };
		grad.focalRatio = Math.sqrt( (f.x*f.x)+(f.y*f.y) )/r;
	}
	
	private function flashRadialGradientMatrix( cx:Number, cy:Number, r:Number, fx:Number, fy:Number ):Matrix { 
		var d:Number = r*2; 
		var mat:Matrix = new flash.geom.Matrix(); 
		mat.createGradientBox( d, d, 0, 0., 0. ); 
		
		var a:Number = Math.atan2(fy-cy,fx-cx); 
		mat.translate( -cx, -cy ); 
		mat.rotate( -a );
		mat.translate( cx, cy ); 
		
		mat.translate( cx-r, cy-r ); 
		
		return mat; 
	}
	
	public function getUserUnit(s:String, viewBoxReference:String):Number {
		var value:Number;
		
		if(s.indexOf("pt")!=-1){
			value = Number(StringUtil.remove(s, "pt"));
			return value*1.25;
		} else if(s.indexOf("pc")!=-1){
			value = Number(StringUtil.remove(s, "pc"));
			return value*15;
		} else if(s.indexOf("mm")!=-1){
			value = Number(StringUtil.remove(s, "mm"));
			return value*3.543307;
		} else if(s.indexOf("cm")!=-1){
			value = Number(StringUtil.remove(s, "cm"));
			return value*35.43307;
		} else if(s.indexOf("in")!=-1){
			value = Number(StringUtil.remove(s, "in"));
			return value*90;
		} else if(s.indexOf("px")!=-1){
			value = Number(StringUtil.remove(s, "px"));
			return value;
			
			//Relative
		} else if(s.indexOf("em")!=-1){
			value = Number(StringUtil.remove(s, "em"));
			return value*currentFontSize;
			
			//Percentage
		} else if(s.indexOf("%")!=-1){
			value = Number(StringUtil.remove(s, "%"));
			
			switch(viewBoxReference){
				case WIDTH : return value/100 * currentViewBox.width;
					break;
				case HEIGHT : return value/100 * currentViewBox.height;
					break;
				default : return value/100 * Math.sqrt(Math.pow(currentViewBox.width,2)+Math.pow(currentViewBox.height,2))/Math.sqrt(2)
					break;
			}
		} else {
			return Number(s);
		}
	}

    protected function visitPath (elt :Object) :Sprite
    {
        var s :Sprite = new Sprite();
        s.name = elt.id != null ? elt.id : "path";
		
		

//        var winding :String =
//            elt.finalStyle["fill-rule"] == null ? "nonzero" : elt.finalStyle["fill-rule"];

//        var renderer :PathRenderer = new PathRenderer(elt.d);
//
//        beginFill(s, elt);
//        lineStyle(s, elt);
//        renderer.render(s, winding);
//        s.graphics.endFill();

        return s;
    }

    protected function visitPolygon (elt :Object) :Sprite
    {
		trace("visitPolygon");
        return visitPolywhatever(elt, true);
    }

    protected function visitPolyline (elt :Object) :Sprite
    {
		trace("visitPolyline");
        return visitPolywhatever(elt, false);
    }

    protected function visitPolywhatever (elt :Object, isPolygon :Boolean) :Sprite
    {
        var s :Sprite = new Sprite();
        if (elt.id != null)
            s.name = elt.id;
        else
            s.name = isPolygon ? "polygon" : "polyline";

        var args :Array = elt.points;

//        if (isPolygon) {
//            beginFill(s, elt);
//        }

        lineStyle(s, elt);

        if (args.length > 2) {
            s.graphics.moveTo(Number(args[0]), Number(args[1]));

            var index :int = 2;
            while (index < args.length) {
                s.graphics.lineTo(Number(args[index]), Number(args[index + 1]));
                index += 2;
            }

            if (isPolygon) {
                s.graphics.lineTo(Number(args[0]), Number(args[1]));
                s.graphics.endFill();
            }
        }

        s.graphics.lineStyle();

        return s;
    }

    protected function visitRect (elt :Object) :Sprite
    {
        var s :Sprite = new Sprite();
        s.name = elt.id != null ? elt.id : "rectangle";

        var x :Number = getUserUnit(elt.x, WIDTH);
        var y :Number = getUserUnit(elt.y, HEIGHT);
        var width :Number = getUserUnit(elt.width, WIDTH);
        var height :Number = getUserUnit(elt.height, HEIGHT);

//        beginFill(s, elt);
        lineStyle(s, elt);

        if (elt.isRound) {
            var rx :Number = getUserUnit(elt.rx, WIDTH);
            var ry :Number = getUserUnit(elt.ry, HEIGHT);
            s.graphics.drawRoundRect(x, y, width, height, rx, ry);
        } else {
            s.graphics.drawRect(x, y, width, height);
        }

        s.graphics.endFill();

        return s;
    }

    protected function visitSvg (elt :Object) :Sprite
    {
        // the view box
        var viewBox :Sprite = new Sprite();
        viewBox.name = "viewBox";
        //viewBox.graphics.drawRect(0,0,elt.viewBox.width, elt.viewBox.height);

        var activeArea :Sprite = new Sprite();
        activeArea.name = "activeArea";
        viewBox.addChild(activeArea);

        // iterate through the children of the svg node
        for each (var childElt :Object in elt.children) {
//            activeArea.addChild(
				visit(childElt);
        }

        /*
           // find the minimum point in the active area.
           var min:Point = new Point(Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY);
           var r:Rectangle;

           var i:int = 0;
           var c:DisplayObject;
           for (i = 0; i < activeArea.numChildren; i++) {
           c = activeArea.getChildAt(i);
           r = c.getBounds(activeArea);
           min.x = Math.min(min.x, r.x);
           min.y = Math.min(min.y, r.y);
           }

           // move the transform into the activeArea layer
           activeArea.x = min.x;
           activeArea.y = min.y;
           for (i = 0; i < activeArea.numChildren; i++) {
           c = activeArea.getChildAt(i);
           c.x -= min.x;
           c.y -= min.y;
           }
         */

        //Testing
        if (elt.width != null && elt.height != null) {
            var activeAreaWidth :int = elt.viewBox.width || activeArea.width;
            var activeAreaHeight :int = elt.viewBox.height || activeArea.height;

            activeArea.scaleX = getUserUnit(elt.width, WIDTH) / activeAreaWidth;
            activeArea.scaleY = getUserUnit(elt.height, HEIGHT) / activeAreaHeight;

            activeArea.scaleX = Math.min(activeArea.scaleX, activeArea.scaleY);
            activeArea.scaleY = Math.min(activeArea.scaleX, activeArea.scaleY);
        }
        //

        return viewBox;
    }

    private var svgImage :SVGViewerFlash;

    protected static const svg :XML = <svg
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:cc="http://creativecommons.org/ns#"
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:svg="http://www.w3.org/2000/svg"
            xmlns="http://www.w3.org/2000/svg"
            xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
            xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
            width="744.09448819"
            height="1052.3622047"
            id="svg2"
            version="1.1"
            inkscape:version="0.47 r22583"
            sodipodi:docname="New document 1">
            <defs
                id="defs4">
                <inkscape:perspective
                    sodipodi:type="inkscape:persp3d"
                    inkscape:vp_x="0 : 526.18109 : 1"
                    inkscape:vp_y="0 : 1000 : 0"
                    inkscape:vp_z="744.09448 : 526.18109 : 1"
                    inkscape:persp3d-origin="372.04724 : 350.78739 : 1"
                    id="perspective10" />
            </defs>
            <sodipodi:namedview
                id="base"
                pagecolor="#ffffff"
                bordercolor="#666666"
                borderopacity="1.0"
                inkscape:pageopacity="0.0"
                inkscape:pageshadow="2"
                inkscape:zoom="0.49497475"
                inkscape:cx="397.38541"
                inkscape:cy="479.83179"
                inkscape:document-units="px"
                inkscape:current-layer="layer1"
                showgrid="false"
                inkscape:snap-midpoints="false"
                inkscape:snap-bbox="true"
                inkscape:window-width="1312"
                inkscape:window-height="1046"
                inkscape:window-x="0"
                inkscape:window-y="0"
                inkscape:window-maximized="0" />
            <metadata
                id="metadata7">
                <rdf:RDF>
                    <cc:Work
                        rdf:about="">
                        <dc:format>image/svg+xml</dc:format>
                        <dc:type
                            rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
                        <dc:title></dc:title>
                    </cc:Work>
                </rdf:RDF>
            </metadata>
            <g
                inkscape:label="Layer 1"
                inkscape:groupmode="layer"
                id="layer1">
                <rect
                    style="fill:#0000ff;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
                    id="rect2816"
                    width="155.87529"
                    height="291.91876"
                    x="172.26543"
                    y="108.40568" />
                <path
                    style="fill:#0000ff;fill-rule:evenodd;stroke:#000000;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1"
                    d="m 267.24437,775.56595 -92.46844,13.93909 0,-308.57142 105.77375,-10.10153"
                    id="rect2820"
                    sodipodi:nodetypes="cccc" />
            </g>
        </svg>;
}
}