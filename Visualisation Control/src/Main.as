package 
{
	import flare.animate.Transitioner;
	import flare.data.DataSet;
	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.vis.Visualization;
	import flare.vis.controls.DragControl;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.filter.GraphDistanceFilter;
	import flare.vis.operator.layout.RadialTreeLayout;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	
	[SWF(width="600", height="600", backgroundColor="#001F3E", frameRate="30")]
	public class Main extends Sprite
	{
		
		private var vis:Visualization;
		
		private var _gdf:GraphDistanceFilter;
		
		private var _maxDistance:int = 3;
		
		private var _transitionDuration:Number = 1;
		
		public function Main() {
			var gmr:GraphMLReader = new GraphMLReader(onLoaded);
			var flashVars:Object=this.loaderInfo.parameters;
			gmr.read(flashVars.pm_url);
//			gmr.read("http://localhost:3001/people/graphml/2"); // for debugging in the Flash player
		}
		
		private function onLoaded(data:Data):void {
		
			vis = new Visualization(data);
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			vis.bounds = new Rectangle(40,0,w-60,h-100);
						
			var headingTF:TextFormat = new TextFormat();
			headingTF.color = 0xffffffff;
			headingTF.font = "Arial";
			headingTF.size = 12;
			
			var chartHeading:TextSprite = new TextSprite("Network Visualisation", headingTF);
			chartHeading.x = 0;
			chartHeading.y = 0;
			vis.addChild(chartHeading);
			
			var nodeTF:TextFormat = new TextFormat();
			nodeTF.color = 0xffffffff;
			nodeTF.bold = true;
			nodeTF.font = "Arial";
			nodeTF.size = 10;
			nodeTF.align = "center";
			
			var dc:DragControl = new DragControl(NodeSprite);
			vis.controls.add(dc);
			
			vis.data.nodes.visit(function(ns:NodeSprite):void { 
				var ts:TextSprite = new TextSprite(ns.data.name,nodeTF);	
				ns.addChild(ts);	
				ns.width = ts.width;
				
				var rs:Sprite = new Sprite;
				
				if (ns.data.node_class == "person") {
					if (ns.data.sex == "Female") {
						rs.addChild(new female);
					} else {
						rs.addChild(new male);
					}
				} else if (ns.data.node_class == "organisation") {
					rs.addChild(new organisation);
				} else if (ns.data.node_class == "location") {
					rs.addChild(new location);
				} else if (ns.data.node_class == "reference") {
					switch(ns.data.reference_type) {
						case "email":
							rs.addChild(new email);
							break;
						default:
							rs.addChild(new reference);
					}
				} else if (ns.data.node_class == "event") {
					rs.addChild(new event);
				} else { // shouldn't happen
					rs.addChild(new reference);
				}
				
				rs.x = -20;
				rs.y = -20;
				
				// center below circle
				ts.x = rs.x - ts.width / 2 + 15;
				ts.y = rs.y + 40;

				ns.addChildAt(rs, 0); // at position 0 so that the text label is drawn above the rectangular box
				ns.size = 0;
				ns.mouseChildren = false; 
				ns.addEventListener(MouseEvent.DOUBLE_CLICK, update);
				ns.buttonMode = true;
			});
			
			var layout:RadialTreeLayout =  new RadialTreeLayout();
			layout.useNodeSize = false;
			
			var root:NodeSprite = vis.data.nodes[0];
			
			_gdf = new GraphDistanceFilter([root], _maxDistance,NodeSprite.GRAPH_LINKS); 
			
			vis.operators.add(_gdf); //distance filter has to be added before the layout
			vis.operators.add(layout);
			
			addChild(vis);
			
			// text formatting for edge labels
			var edgeTF:TextFormat = new TextFormat();
			edgeTF.color = 0xffcdcdee;
			edgeTF.font = "Arial";
			edgeTF.size = 9;
			edgeTF.align = "center";
			
			// draw labels on edges
			var i:int = 0;
			vis.data.edges.visit(function(es:EdgeSprite):void {
				es.data.label = es.data.link_type,edgeTF
			});
			var lae:Labeler = new Labeler("data.label",Data.EDGES,edgeTF,EdgeSprite,Labeler.LAYER); 
			vis.data.edges.visit(function(es:EdgeSprite):void {
				es.addEventListener(Event.RENDER,updateEdgeLabelPosition);
			});
			vis.operators.add(lae);

			vis.update();
			updateRoot(root);
			
		}
		
		private function updateEdgeLabelPosition(evt:Event):void {
			var es:EdgeSprite = evt.target as EdgeSprite;
			es.props.label.x = (es.source.x + es.target.x) / 2;
			es.props.label.y = (es.source.y + es.target.y) / 2 + 15;	
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

