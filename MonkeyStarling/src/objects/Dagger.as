package objects {
	import com.greensock.easing.Strong;
	import com.greensock.TimelineLite;
	import com.greensock.TweenMax;
	import objects.TagItem;
	import starling.display.Image;
	import starling.events.Event;
	import starling.utils.deg2rad;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class Dagger extends TagItem {
		public var canTake:Boolean = false;
		
		public function Dagger(_x:int, _y:int, _tag:uint) {
			img = new Image(Assets.getAtlas().getTexture("dagger"));
			super(img, _x, _y, _tag);
			
			var pX:Vector.<int> = Vector.<int>([0, 6, 6, -28, -39, -27, 6, 6, 10, 10, 32, 38, 29, 10, 10, 6, 0]);
			var pY:Vector.<int> = Vector.<int>([0, -16, -7, -7, -4, 0, 0, 10, 10, -0, 0, -3, -8, -6, -15, -16, 0]);
			setPoly(pX, pY);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var orig:Image = new Image(Assets.getAtlas().getTexture("orig"));
			addChild(orig);
			
			var w:Number = img.width;
			var h:Number = img.height;
			
			//img.x = -w / 2;
			img.y = -500;
			img.pivotY = h;
			img.pivotX = w / 2;
			var tl:TimelineLite = new TimelineLite();
			tl.add(TweenMax.to(img, 0.5, {y: 10, rotation: deg2rad(360).toString(), ease: Strong.easeIn}));
			tl.add(TweenMax.to(img, 0.3, {y: -150, rotation: deg2rad(180).toString(), ease: Strong.easeOut}));
			tl.add(TweenMax.to(img, 0.3, {y: 10, rotation: deg2rad(180).toString(), ease: Strong.easeIn}));
		
		}
		
		public function readyGround():void {
			canTake = true;
			TweenMax.killTweensOf(img);
			img.y = 10;
			img.rotation = deg2rad(0);
			TweenMax.to(img, 0.2, {scaleY: 0.8, ease: Strong.easeOut});
			TweenMax.to(img, 0.4, {delay: 0.1, scaleY: 1.0, ease: Strong.easeInOut});
		}
		
		public function tryTake():void {
			canTake = false;
			TweenMax.to(img, 0.2, {scaleY: 1.2, scaleX: 0.8, ease: Strong.easeOut});
		}
		
		public function cancelTake():void {
			canTake = true;
			img.scaleX = 1.5;
			img.scaleY = 0.8;
			TweenMax.to(img, 0.4, {scaleY: 1.0, scaleX: 1.0, ease: Strong.easeOut});
		}
	}

}