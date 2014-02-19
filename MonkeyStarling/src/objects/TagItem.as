package objects {
	import flash.geom.Point;
	import objects.Monkey;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	
	
	
	public class TagItem extends HitSprite {
		
		public var tag:uint;
		public var monkey:Monkey;
		public var img:Image;
		public function TagItem(_img:Image,_x:int, _y:int, _tag:uint) {
			img = _img;
			x = _x;
			y = _y;
			tag = _tag;
			addChild(img);
		}
		public function recenter():void {
			img.x = -img.width / 2;
			img.y = -img.height;
		}
	}
	
}
