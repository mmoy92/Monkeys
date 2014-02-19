package ui {
	import com.greensock.easing.Back;
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class TestInstr extends Sprite {
		protected var title:TextField;
		protected var instr:TextField;
		
		private var titleStr:String;
		private var instrStr:String;
		
		public function TestInstr(_title:String, _instr:String) {
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			titleStr = _title;
			instrStr = _instr;
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			title = new TextField(530, 90, titleStr, Assets.getFont().name, 38);
			title.vAlign = "top";
			title.x = stage.stageWidth / 2 - title.width / 2;
			title.y = 50;
			addChild(title);
			
			instr = new TextField(530, 90, instrStr, Assets.getFont().name, 25);
			instr.vAlign = "top";
			instr.x = stage.stageWidth / 2 - instr.width / 2;
			instr.y = 50;
			addChild(instr);
			
			title.visible = instr.visible = false;
		}
		
		public function animate():void {
			title.visible = true;
			
			var tl:TimelineMax = new TimelineMax();
			tl.add(TweenMax.to(title, 0.5, {y: 100, ease: Back.easeInOut}));
			tl.add([TweenMax.to(title, 0.1, {visible: false}), TweenMax.to(instr, 0.1, {visible: true})], "+=3.0");
			
			tl.add(TweenMax.to(instr, 0.5, {y: 100, ease: Back.easeInOut}));
			tl.add(TweenMax.to(instr, 0.1, { visible: false } ), "+=3.0");
			
		
		}
	}

}