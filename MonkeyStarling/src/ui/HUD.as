package ui {
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class HUD extends Sprite {
		public var pingTxt:TextField;
		public var statusTxt:TextField;
		public var timerTxt:TextField;
		public var instrSprite:TestInstr;
		public function HUD(_instrSprite:TestInstr) {
			super();
			
			instrSprite = _instrSprite;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addChild(instrSprite);
			
			pingTxt = new TextField(150, 50, "Ping: ");
			pingTxt.hAlign = "left";
			pingTxt.vAlign = "top";
			addChild(pingTxt);
			
			statusTxt = new TextField(380, 50, "");
			statusTxt.vAlign = "top";
			statusTxt.x = stage.stageWidth / 2 - statusTxt.width/2;
			addChild(statusTxt);
			
			timerTxt = new TextField(380, 90, "", Assets.getFont().name, 75);
			timerTxt.vAlign = "top";
			timerTxt.x = stage.stageWidth / 2 - timerTxt.width / 2;
			addChild(timerTxt);
			
			
		
		}
	
	}

}