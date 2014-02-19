package objects {
	import starling.display.Image;
	import starling.display.Sprite;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class DepositBin extends Sprite {
		public var img:Image;
		
		public function DepositBin() {
			img = new Image(Assets.getAtlas().getTexture("depositBin"));
			img.scaleX *= 2;
			img.scaleY *= 2;
			img.x -= img.width/2;
			img.y = -img.height;
			
			addChild(img);
			
			
		}
	
	}

}