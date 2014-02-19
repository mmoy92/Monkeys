package objects {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.Color;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class HitSprite extends Sprite {
		public var hitPolyX:Vector.<int>;
		public var hitPolyY:Vector.<int>;
		protected var reversed:Boolean = false;
		public function HitSprite() {
			super();
			var shadow:Image = new Image(Assets.getAtlas().getTexture("moteTexture"));
			shadow.color = Color.BLACK;
			shadow.height /= 2;
			shadow.width *= 3;
			shadow.alpha = 0.5;
			shadow.blendMode = BlendMode.MULTIPLY;
			shadow.x -= shadow.width/2;
			shadow.y -= shadow.height / 2;
			addChild(shadow);
			
			//var orig:Image =  new Image(Assets.getAtlas().getTexture("orig"));
			//addChild(orig);
		}
		public function setPoly(pX:Vector.<int>, pY:Vector.<int>):void {
			hitPolyX = pX;
			hitPolyY = pY;
		}
		public function hitPoint(_p:Point):Boolean {
			var p:Point = _p.clone();
			if (!touchable || !bounds.containsPoint(p) || hitPolyX == null || hitPolyY == null) {
				
				return false;
			}
			p.x -= x;
			p.y -= y;
			
			var i:int = 0;
			var j:int = 0;
			
			var c:Boolean = false;
			var s:int = reversed ? -1: 1;
			for (i = 0, j = hitPolyX.length - 1; i < hitPolyX.length; j = i++) {
				if (((hitPolyY[i] > p.y) != (hitPolyY[j] > p.y)) && (p.x < (hitPolyX[j]*s - hitPolyX[i]*s) * (p.y - hitPolyY[i]) / (hitPolyY[j] - hitPolyY[i]) + hitPolyX[i]*s))
					c = !c;
			}
			return c;
		}
	}

}