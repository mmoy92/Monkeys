package ui {
	import com.greensock.easing.Back;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.Color;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class BananaCount extends Sprite {
		private var nana:Image;
		public var txt:TextField;
		
		public function BananaCount() {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			txt = new TextField(90, 30, "", Assets.getFont().name, 25, 0x544406);
			txt.x = -txt.width/2;
			txt.y = -txt.height-5;
			
			nana = new Image(Assets.getAtlas().getTexture("banana"));
			nana.scaleX = 0.5;
			nana.scaleY = 0.5;
			nana.y = -nana.height;
			
			addChild(txt);
			addChild(nana);
		}
		
		public function changed():void {
			TweenMax.fromTo(this, 1.0, {scaleX: 2.0, ease: Strong.easeOut}, {scaleX: 1.0});
		}
		
		public function reward(amt:int):void {
			txt.text = "+" + amt;
			txt.color = Color.GREEN;
			TweenMax.to(this, 0.5, {y: "-50", ease: Strong.easeOut});
			TweenMax.delayedCall(1.0, removeFromParent, [true]);
		}
		
		public function deduct(amt:int):void {
			txt.text = "-" + amt;
			txt.color = Color.RED;
			TweenMax.to(this, 0.5, {y: "-50", ease: Strong.easeOut});
			TweenMax.delayedCall(1.0, removeFromParent, [true]);
		}
	}

}