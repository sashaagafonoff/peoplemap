package 
{
	import fl.controls.Button;
	import flare.display.TextSprite;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;

	import flare.animate.FunctionSequence;
	import flare.animate.Transition;
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	

	import flare.util.Shapes;
	
	import flare.vis.Visualization;

	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.DataList;
	import flare.vis.data.render.ArrowType;
	
	import flare.vis.controls.DragControl;
	import flare.vis.controls.PanZoomControl;
	import flare.vis.controls.ExpandControl;
	import flare.vis.controls.HoverControl;
	import flare.vis.controls.IControl;
	
	import flare.vis.events.SelectionEvent;
	
	import flare.vis.operator.OperatorSwitch;
	
	import flare.vis.operator.encoder.PropertyEncoder;
	
	import flare.vis.operator.layout.CircleLayout;
	import flare.vis.operator.layout.ForceDirectedLayout;
	import flare.vis.operator.layout.IndentedTreeLayout;
	import flare.vis.operator.layout.Layout;
	import flare.vis.operator.layout.NodeLinkTreeLayout;
	import flare.vis.operator.layout.RadialTreeLayout;
	
	import flare.vis.operator.filter.GraphDistanceFilter;
	
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.label.RadialLabeler;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;

	import flash.text.TextFormat;
	
	import peoplemap.GraphMLReader;
	
	[SWF(width="600", height="600", backgroundColor="#001F3E", frameRate="30")]
	public class Main extends Sprite
	{
		
		// add UI components (from /lib/peoplemap.swc)
		private var mb:menuBar = new menuBar;
		private var preloaderAnimation:loaderComponent = new loaderComponent;
		private var bmb:baseMenuBar = new baseMenuBar;

		private var vis:Visualization;
		
		private var opt:Array;
		private var idx:int = -1;
		private var cur:Object = new Object;
		private var stgHeight:int = stage.stageHeight;
		
		private var currentActionMenuID:int = -1; // used to store ID of current actionMenu (if present)
		
/*		
 * 		Set up the basic layout and set links for the buttons
*/
	
		public function Main() {
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// get configured options for visualisation types 
			opt = options(stage.width-50,stage.height-50);
			
			// set default visualisation to tree (first in options index)
			idx = 0;

			showPreLoader();
			
			// build menu buttons
			mb.menuBgd.width = stage.stageWidth;
			mb.x = stage.stageWidth - mb.menuBgd.width + 20;
			addChild(mb);
			
			// set the highlight state of the Tree button to up as it is always displayed first
			mb.treeBtn.upState = mb.treeBtn.overState;

			// build base menu
			bmb.baseMenuBgd.width = stage.stageWidth;
			bmb.y = stage.stageHeight - bmb.baseMenuBgd.height;
			addChild(bmb);
			
			bmb.btnFullScreen.addEventListener(MouseEvent.CLICK, toggleFullScreen);
			stage.addEventListener(Event.RESIZE, resize);

			// set up listeners for each of the buttons from the menuBar component (in /lib/peoplemap.swc)
			for (var i:uint=0; i<opt.length; ++i) {
				this.mb.getChildByName(opt[i].button).addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void { 
					downstateMenuBtns();
					event.target.upState = event.target.overState; 
					//setChildIndex(event.target, -1);
					switchTo(event.target.name).play();
				});
			}

			// ADD CODE HERE FOR ZOOM CONTROL	
				
				
			updateGraph();

		}
/*		
//		toggle all menu buttons when switching states
//		
*/
		private function downstateMenuBtns():void {
			mb.treeBtn.upState = mb.treeBtn.downState;
			mb.indentBtn.upState = mb.indentBtn.downState;
			mb.forceBtn.upState = mb.forceBtn.downState;
			mb.radialBtn.upState = mb.radialBtn.downState;
			mb.circleBtn.upState = mb.circleBtn.downState;
		}
		
/*		
 * 		Once the GraphML data has been loaded, build the visualisation
*/
		private function onLoaded(data:Data):void {
			
			// hide preloader
			removeChild(preloaderAnimation);
			
			
			// set up visualisation space
			vis = new Visualization(data);
			vis.x = 0;
			vis.y = 50;
			vis.operators.add(opt[idx].op);
			vis.setOperator("nodes", new PropertyEncoder(opt[idx].nodes, "nodes"));
			vis.setOperator("edges", new PropertyEncoder(opt[idx].edges, "edges"));
						
			var dc:DragControl = new DragControl(NodeSprite);
			vis.controls.add(dc);

			var pzc:PanZoomControl = new PanZoomControl();
			vis.controls.add(pzc);
			
			// set up icons for visualisation
			vis.data.nodes.visit(function(ns:NodeSprite):void { 
				
				// rs is the icon
				var rs:Sprite = new Sprite;
 
				// select icon (from /lib/icons.swc) depending on type
				switch (ns.data.node_class) {
					case "person":
						if (ns.data.sex == "Female") {
							rs.addChild(new female);
						} else {
							rs.addChild(new male);
						}
						break;
					case "organisation":
						rs.addChild(new organisation);
						break;
					case "location":
						rs.addChild(new location);
						break;
					case "reference":
						switch(ns.data.reference_type) {
							case "email":
								rs.addChild(new email);
								break;
							default:
								rs.addChild(new reference);
						}
						break;
					case "event":
						rs.addChild(new event);
						break;
					default:
						rs.addChild(new reference);
				}
 
				// move node to center it against edge lines
				rs.x = -20;
				rs.y = -20;
				
				ns.addEventListener(MouseEvent.CLICK, showActionMenu);
 
				// set up text formatting of node labels
				var nodeTF:TextFormat = new TextFormat();
				nodeTF.color = 0xffffffff;
				nodeTF.bold = true;
				nodeTF.font = "Arial";
				nodeTF.size = 10;
				nodeTF.align = "center";
	 
				// get name of node for label
				var ts:TextSprite = new TextSprite(ns.data.name,nodeTF);	
				ns.addChild(ts);	

				// center below icon
				ts.x = ns.x - ns.width / 2;
				ts.y = ns.y + 20;

				ns.addChildAt(rs, 0); // at position 0 so that the text label is drawn above the icon
				ns.size = 0;
				ns.mouseChildren = false; 
				ns.buttonMode = true;
			});

			// update visualisation and add to Stage
			addChild(vis);

			// make the default layout a Tree
			switchTo("treeBtn").play();
 
 
		}
		
/*		
 * This function sets up an array which will configure each visualisation type based on the size of the bounds
*/		
		private function options(w:Number, h:Number):Array
		{
			var a:Array = [
				{
					name: "Tree",
					button: "treeBtn",
					op: new NodeLinkTreeLayout("topToBottom", 30, 20, 30),
					param: {layoutAnchor: new Point(stage.stageWidth/2, stage.stageHeight/4)}
				},
				{
					name: "Force",
					button: "forceBtn",
					op: new ForceDirectedLayout(true),
					param: {
						"simulation.dragForce.drag": 0.7,
						defaultParticleMass: 1,
						defaultSpringLength: 125,
						defaultSpringTension: 0.1,
						layoutAnchor: new Point(stage.stageWidth/2, stage.stageHeight/3)
					},
					update: true
				},
				{
					name: "Indent",
					button: "indentBtn",
					op: new IndentedTreeLayout(50,10),
					param: { layoutAnchor: new Point(stage.stageWidth/2, 70) }
				},
				{
					name: "Radial",
					button: "radialBtn",
					op: new RadialTreeLayout(50,true,true),
					param: { layoutAnchor: new Point(stage.stageWidth/2, stage.stageHeight/3),
							angleWidth: -2 * Math.PI,
							radiusIncrement: 45,
							useNodeSize: true
							 }
				},
				{
					name: "Circle",
					button: "circleBtn",
					op: new CircleLayout(  null, null, false),
					param: { angleWidth: -2 * Math.PI,
							 layoutAnchor: new Point(stage.stageWidth/2, stage.stageHeight/2.5)}
				}
			];
			
			// default values
			var nodes:Object = {
				shape: Shapes.CIRCLE,
				fillColor: 0x99666699,
				lineColor: 0xffffffff,
				lineWidth: 0,
				size: 1,
				alpha: 1,
				visible: true
			}
			var edges:Object = {
				lineColor: 0xff555588,
				lineWidth: 2,
				alpha: 1,
				visible: true
			}
			var ctrl:IControl = new ExpandControl(NodeSprite,
				function():void { vis.update(1, "nodes","main").play(); });
			
			// apply defaults where needed
			var name:String;
			for each (var o:Object in a) {
				if (!o.nodes)
					o.nodes = nodes;
				else for (name in nodes)
					if (o.nodes[name]==undefined)
						o.nodes[name] = nodes[name];
 
				if (!o.edges)
					o.edges = edges;
				else for (name in edges)
					if (o.edges[name]==undefined)
						o.edges[name] = edges[name];
 				if (o.param) o.op.parameters = o.param;
			}
			return a;
		}
		
		/*		
 * 		This function supports switching between layout types
*/
		private function switchTo(visualisationType:String):Transition {
			
			var old:Object = opt[idx];
			for (idx=0; idx<opt.length; ++idx) {
				if (opt[idx].button == visualisationType) break;
			}
			cur = opt[idx];

			vis.continuousUpdates = false;
			vis.operators.clear();
			vis.operators.add(cur.op);
			vis.setOperator("nodes", new PropertyEncoder(cur.nodes, "nodes"));
			vis.setOperator("edges", new PropertyEncoder(cur.edges, "edges"));
			
			// text formatting for edge labels
			var edgeTF:TextFormat = new TextFormat();
			edgeTF.color = 0xffcdcdee;
			edgeTF.font = "Arial";
			edgeTF.size = 9;
			edgeTF.align = "center";
 
			// draw labels on edges
			vis.data.edges.visit(function(es:EdgeSprite):void {
				es.data.label = es.data.link_type,edgeTF
			});
			vis.data.edges.setProperty("arrowType", ArrowType.TRIANGLE);
			vis.data.edges.setProperty("arrowWidth", 8);
			
			// To handle animated transtions, we use a function sequence
			// this is like a normal animation sequence, except that each
			// animation segment is created lazily by a function when needed,
			// rather than generating the values for all segments up front.
			// This can help simplify the handling of intermediate values.
			var seq:FunctionSequence = new FunctionSequence();
			var nodes:DataList = vis.data.nodes;
			var edges:DataList = vis.data.edges;
			seq.push(vis.updateLater("nodes", "edges", "main"), 2);
			
			if (old.straighten && !(cur.straighten || cur.canStraighten)) {
				seq.add(Layout.straightenEdges(edges, new Transitioner(1)));
			}
			// If performing a force-directed layout, set up
			// continuous updates and ease in the edge tensions.
			if (cur.update) {
				cur.op.defaultSpringTension = 0;
				seq.addEventListener(TransitionEvent.END,
					function(evt:Event):void {
						var t:Transitioner = vis.update(2, "nodes", "edges");
						t.$(cur.op).defaultSpringTension =
							cur.param.defaultSpringTension;
						t.play();
						vis.continuousUpdates = true;
					}
				);
			}
			
			var lae:Labeler = new Labeler("data.label",Data.EDGES,edgeTF,EdgeSprite,Labeler.LAYER); 
			vis.data.edges.visit(function(es:EdgeSprite):void {es.addEventListener(Event.RENDER,updateEdgeLabelPosition);});
			vis.operators.add(lae);

			return seq;
		}

		private function updateEdgeLabelPosition(evt:Event):void {
			var es:EdgeSprite = evt.target as EdgeSprite;
			es.props.label.x = (es.source.x + es.target.x) / 2;
			es.props.label.y = (es.source.y + es.target.y) / 2 + 15;	
		}
		
		private function showActionMenu(evt:MouseEvent):void {
			
			// remove the current actionMenu (if present)
			if (currentActionMenuID != -1) { 
				removeChildAt(currentActionMenuID); 
			} 
			
			var actionMenu:cptNodeActions = new cptNodeActions;
			actionMenu.nodeID = evt.target.data.id;
			actionMenu.nodeType = evt.target.data.node_class;
			actionMenu.x = evt.target.x-97;
			actionMenu.y = evt.target.y-35;
			addChild(actionMenu);
			actionMenu.btnClose.addEventListener(MouseEvent.CLICK, hideActionMenu);
			actionMenu.btnGetTwitterData.addEventListener(MouseEvent.CLICK, getTwitterData);
			actionMenu.btnGetFacebookData.addEventListener(MouseEvent.CLICK, getFacebookData);
			actionMenu.btnGetNearbyNodes.addEventListener(MouseEvent.CLICK, getNearbyNodes);
			actionMenu.btnEditNodeData.addEventListener(MouseEvent.CLICK, editNodeData);
			actionMenu.btnAddComment.addEventListener(MouseEvent.CLICK, addComment);
			actionMenu.btnDeleteNode.addEventListener(MouseEvent.CLICK, deleteNode);
			
			currentActionMenuID = getChildIndex(actionMenu);
		}
		
		private function hideActionMenu(evt:MouseEvent):void {
			removeChild(evt.target.parent);
			currentActionMenuID = -1;
		}
		
		private function getTwitterData(evt:MouseEvent):void {
			evt.target.upState = evt.target.overState;
			// retrieve Twitter data for node
			// ie followers, followed by, tweets by followers/followees, own tweets
		}
		
		private function getFacebookData(evt:MouseEvent):void {
			evt.target.upState = evt.target.overState;
			// retrieve Facebook data for node
			// ie first circle of friends
			// status updates, linked content, etc
		}
		
		private function getNearbyNodes(evt:MouseEvent):void {
			evt.target.upState = evt.target.overState;
			// retrieve immediate network around node
			// add limiter to retrieval to allow setting of number of records retrieved (probably in Rails, with setting of limit from this control)
		}
		
		private function editNodeData(evt:MouseEvent):void {
			evt.target.upState = evt.target.overState;
			// view the appropriate form for the node type
		}
		
		private function addComment(evt:MouseEvent):void {
			evt.target.upState = evt.target.overState;
			// add a comment to the node
		}
		
		private function deleteNode(evt:MouseEvent):void {
			// keep the button state up for this operation
			evt.target.upState = evt.target.overState;
			var nodeClass:String = new String;
			switch(evt.target.parent.nodeType) {
				case "person" :
					nodeClass = "people";
					break;
				case "organisation" :
					nodeClass = "organisations";
					break;
				case "event" :
					nodeClass = "events";
					break;
				case "location" :
					nodeClass = "locations";
					break;
				case "reference" :
					nodeClass = "references";
					break;
				default:
					nodeClass = "error"; // should not happen
			}
			
			// delete the node
			var deleteRequest:URLRequest = new URLRequest("http://localhost:3001/" + nodeClass + "/destroy/" + evt.target.parent.nodeID);
			deleteRequest.method = URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, handleRESTfulRequest);
			loader.load(deleteRequest);
			hideActionMenu(evt);
		}
		
		private function handleRESTfulRequest(evt:Event):void {
			// confirm event type in GUI
			showPreLoader();
			updateGraph();
		}

		private function updateGraph():void {
			if (vis) { removeChild(vis); }
			
			var gmr:GraphMLReader = new GraphMLReader(onLoaded);
			var flashVars:Object=this.loaderInfo.parameters;

			//gmr.read(flashVars.pm_url); // variable loaded from embed code in page
			gmr.read("http://localhost:3001/people/graphml/2"); // for debugging in the Flash player
			
		}
		
		public function play():void
		{
			if (opt[idx].update) vis.continuousUpdates = true;
		}
		
		public function stop():void
		{
			vis.continuousUpdates = false;
		}
		
		private function toggleFullScreen(evt:MouseEvent):void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
				bmb.btnFullScreen.upState = bmb.btnFullScreen.overState;
			} else {
				stage.displayState = StageDisplayState.NORMAL;
				bmb.btnFullScreen.upState = bmb.btnFullScreen.downState;
			}

		}
		
		private function showPreLoader():void {
			// show preloader
			preloaderAnimation.x = 170;
			preloaderAnimation.y = 270;
			addChild(preloaderAnimation);
		}
		
		private function resize(evt:Event):void {
			mb.x = mb.x - (stage.stageWidth - mb.menuBgd.width)/2; // float left
			mb.menuBgd.width = stage.stageWidth;
			mb.y = Math.round((stgHeight - stage.stageHeight)/2); // float top

			bmb.x = bmb.x + (stage.stageWidth - bmb.baseMenuBgd.width)/2;  // float right
			bmb.baseMenuBgd.width = stage.stageWidth;
			bmb.y = Math.round((stgHeight - stage.stageHeight) / 2) + stage.stageHeight - bmb.baseMenuBgd.height; // float bottom
			
			vis.bounds.width = stage.stageWidth - 100;
			vis.bounds.height = stage.stageHeight - 100;
			vis.update();
			
		}
	}
		
}	

