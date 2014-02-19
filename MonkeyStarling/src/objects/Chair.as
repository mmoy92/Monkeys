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
	public class Chair extends TagItem {
		public var canPop:Boolean = false;
		
		public function Chair(_x:int, _y:int, _tag:uint) {
			img = new Image(Assets.getAtlas().getTexture("chair"));
			super(img, _x, _y, _tag);
			
			var pX:Vector.<int> = Vector.<int>([0, -34, -40, -33, -46, -14, 44, 39, 48, 29, 22, 26, 24, -34, 0, -28, 22, 26, 20, -32, -28, 0]);
			var pY:Vector.<int> = Vector.<int>([0, -90, -74, -49, -3, 18, 14, -13, -19, -45, -69, -72, -92, -90, 0, -42, -41, -46, -68, -67, -42, 0]);
			setPoly(pX, pY);
			
			recenter();
			img.y += 19;
		}
	
	}

}