
package 
{
	import flare.animate.Transitioner;
	import flare.data.DataSet;
	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.filter.GraphDistanceFilter;
	import flare.vis.operator.layout.RadialTreeLayout;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	/**
	 * Demo reading the graph from a graphml file
	 *
	 * 
	 * @author <a href="http://goosebumps4all.net">martin dudek</a>
	 */
	
	[SWF(width="300", height="300", backgroundColor="#ffffff", frameRate="30")]
	public class Main extends Sprite
	{
		
		private var vis:Visualization;
		
		private var maxLabelWidth:Number;
		private var maxLabelHeight:Number;
		
		private var _gdf:GraphDistanceFilter;
		
		private var _maxDistance:int = 2;
		
		private var _transitionDuration:Number = 2;
		
		public function Main() {
			var gmr:GraphMLReader = new GraphMLReader(onLoaded);
			var flashVars:Object=this.loaderInfo.parameters;
			gmr.read(flashVars.pm_url);
		}
			
		
		private function onLoaded(data:Data):void {
			
			

			vis = new Visualization(data);
			
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			
			vis.bounds = new Rectangle(25, 25, w-50, h-50);
			
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = 0xffffffff;
			var i:int = 0;
			vis.data.nodes.visit(function(ns:NodeSprite):void { 
				var ts:TextSprite = new TextSprite(ns.data.name,textFormat);	
				ns.addChild(ts);	
			});
			
			vis.data.nodes.setProperty("x",w/2);
			vis.data.nodes.setProperty("y",h/2);
			
			maxLabelWidth = getMaxTextLabelWidth();
			maxLabelHeight = getMaxTextLabelHeight();
			
			vis.data.nodes.visit(function(ns:NodeSprite):void { 
				var rs:RectSprite = new RectSprite( -maxLabelWidth/2-1,-maxLabelHeight/2 - 1, maxLabelWidth + 2, maxLabelHeight + 2);
				if (ns.data.node_class == "person") {
					rs.fillColor = 0xff000044; 
					rs.lineColor = 0xff000044; 
				} else {
					rs.fillColor = 0xffaa0000; 
					rs.lineColor = 0xffaa0000; 
				}
				rs.lineWidth = 2;
				
				ns.addChildAt(rs, 0); // at postion 0 so that the text label is drawn above the rectangular box
				
				ns.size = 0;
				adjustLabel(ns,maxLabelWidth,maxLabelHeight);
				
				ns.mouseChildren = false; 
				
				ns.addEventListener(MouseEvent.CLICK, update);
				
				ns.buttonMode = true;
			});
			
			
			var lay:RadialTreeLayout =  new RadialTreeLayout();
			lay.useNodeSize = false;
			
			var root:NodeSprite = vis.data.nodes[0];
			
			_gdf = new GraphDistanceFilter([root], _maxDistance,NodeSprite.GRAPH_LINKS); 
			
			vis.operators.add(_gdf); //distance filter has to be added before the layout
			vis.operators.add(lay);
			
			addChild(vis);
			
			updateRoot(root);
			
		}
		
		
		
		private function update(event:MouseEvent):void {
			
			var n:NodeSprite = event.target as NodeSprite;
			if (n == null) return; 
			updateRoot(n);
			
		}
		
		private function updateRoot(n:NodeSprite):void {
			
			vis.data.root = n; 
			
			_gdf.focusNodes = [n];
			
			var t1:Transitioner = new Transitioner(_transitionDuration);
			
			vis.update(t1).play();
			
			
		}
		
		
				
		private function getMaxTextLabelWidth() : Number {
			var maxLabelWidth:Number = 0;
			vis.data.nodes.visit(function(n:NodeSprite):void {
				var w:Number = getTextLabelWidth(n);
				if (w > maxLabelWidth) {
					maxLabelWidth = w;
				}
				
			});
			return maxLabelWidth;
		}
		
		private function getMaxTextLabelHeight() : Number {
			var maxLabelHeight:Number = 0;
			vis.data.nodes.visit(function(n:NodeSprite):void {
				var h:Number = getTextLabelHeight(n);
				if (h > maxLabelHeight) {
					maxLabelHeight = h;
				}
				
			});
			return maxLabelHeight;
		}
			
		private function getTextLabelWidth(s:NodeSprite) : Number {
			var s2:TextSprite = s.getChildAt(s.numChildren-1) as TextSprite; // get the text sprite belonging to this node sprite
			var b:Rectangle = s2.getBounds(s);
			return s2.width;
		}
		
		private function getTextLabelHeight(s:NodeSprite) : Number {
			var s2:TextSprite = s.getChildAt(s.numChildren-1) as TextSprite; // get the text sprite belonging to this node sprite
			var b:Rectangle = s2.getBounds(s);
			return s2.height;
		}
		
		private function adjustLabel(s:NodeSprite, w:Number, h:Number) : void {
			
			var s2:TextSprite = s.getChildAt(s.numChildren-1) as TextSprite; // get the text sprite belonging to this node sprite
			
			s2.horizontalAnchor = TextSprite.CENTER;
			s2.verticalAnchor = TextSprite.CENTER;
						
		}
		
	}
		
}	
	/** 
	 * simple graphml reader utility
	 * 
	 */ 

	import flare.data.converters.GraphMLConverter;
	import flare.data.DataSet;
	import flash.events.*;
	import flash.net.*;
	import flare.vis.data.Data;

	class GraphMLReader {
		public var onComplete:Function;
	
        public function GraphMLReader(onComplete:Function=null,file:String = null) {
            this.onComplete = onComplete;

			if(file != null) {
				read(file);
			}
        }
		
		public function read(file:String):void {
			if ( file != null) {
				var loader:URLLoader = new URLLoader();
				configureListeners(loader);
				var request:URLRequest = new URLRequest(file);
				try {
					loader.load(request);
				} catch (error:Error) {
					trace("Unable to load requested document.");
				
				}
			}
		}

        private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }

        private function completeHandler(event:Event):void {
          
			if (onComplete != null) {
				var loader:URLLoader = event.target as URLLoader;
				var dataSet:DataSet = new GraphMLConverter().parse(new XML(loader.data));
				onComplete(Data.fromDataSet(dataSet));
			} else {
				trace("No onComplete function specified.");
			}
        }

       

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
        }

       
        private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event);
        }
    }

