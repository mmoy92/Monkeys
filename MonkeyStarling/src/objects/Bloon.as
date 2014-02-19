package objects {
	import com.greensock.easing.Back;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import starling.display.Image;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.utils.deg2rad;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class Bloon extends TagItem {
		public var canPop:Boolean = false;
		public var confirmedPop:Boolean = false;
		private var popFunc:Function;
		
		public function Bloon(_x:int, _y:int, _tag:uint, _popFunc:Function) {
			img = new Image(Assets.getAtlas().getTexture("bloon"));
			super(img, _x, _y, _tag);
			
			var pX:Vector.<int> = Vector.<int>([0, -16, -28, -32, -29, -22, -2, 16, 22, 32, 30, 20, 5, -15, -16, 0]);
			var pY:Vector.<int> = Vector.<int>([0, -46, -40, -25, -11, -3, -2, -13, -7, -15, -30, -28, -42, -46, -46, 0]);
			setPoly(pX, pY);
			
			popFunc = _popFunc;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			var clrFilter:ColorMatrixFilter = new ColorMatrixFilter();
			clrFilter.adjustHue(-1 + Math.random() * 2);
			img.filter = clrFilter;
			
			var w:Number = img.width;
			var h:Number = img.height;
			
			//img.x = -w / 2;
			img.y = -700;
			img.pivotY = h;
			img.pivotX = w / 2;
			TweenMax.to(img, 3.0, {y: 0, rotation: deg2rad(360).toString()});
		}
		
		public function hitGround():void {
			canPop = true;
			TweenMax.to(img, 0.1, {scaleY: 0.8, ease: Strong.easeOut});
			TweenMax.to(img, 0.3, {delay: 0.1, scaleY: 1.0, ease: Strong.easeInOut});
		}
		
		public function readyPop():void {
			canPop = false;
			TweenMax.to(img, 0.23, {scaleY: 1.2, scaleX: 0.8, ease: Strong.easeOut, onComplete:tryPop});
		}
		
		private function tryPop():void {
			if (confirmedPop) {
				popFunc(this);
			} else {
				canPop = true;
				img.scaleX = 1.5;
				img.scaleY = 0.8;
				TweenMax.to(img, 0.4, {scaleY: 1.0, scaleX: 1.0, ease: Strong.easeOut});
			}
		}
	}

}