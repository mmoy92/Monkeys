package objects {
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.deg2rad;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class ConnectSprite extends Sprite {
		private var failImage:Image;
		private var tryImage:Image;
		private var successImage:Image;
		public function ConnectSprite() {
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			initFail();
			initTrying();
			initSuccess();
		}
		
		private function initSuccess():void {
			successImage = new Image(Assets.getAtlas().getTexture("connectionSuccess"));
			successImage.visible = false;
			successImage.x -= successImage.width / 2;
			successImage.pivotY = successImage.width / 2;
			this.addChild(successImage);
		}
		
		private function initTrying():void {
			tryImage = new Image(Assets.getAtlas().getTexture("connectionArrows"));
			tryImage.visible = false;
			this.addChild(tryImage);
			tryImage.pivotX = tryImage.width / 2;
			tryImage.pivotY = tryImage.height / 2;
			
		}
		
		private function initFail():void {
			failImage = new Image(Assets.getAtlas().getTexture("connectionFail"));
			failImage.visible = false;
			//failImage.x -= failImage.width / 2;
			failImage.y -= failImage.height / 2 + 20;
			failImage.pivotX = failImage.width / 2;
			this.addChild(failImage);
		}
		public function successAnimation():void {
			failImage.visible = tryImage.visible = false;
			successImage.visible = true;
			successImage.scaleY = 3.0;
			
			TweenMax.to(successImage, 0.5, { scaleY:1.0 } );
			
		}
		public function tryAnimation():void {
			failImage.visible = successImage.visible = false;
			tryImage.visible = true;
			tryImage.scaleX = 1.5
			tryImage.scaleY = 1.5
			var rot:Number = deg2rad( -360);
			TweenMax.to(tryImage, 1, { scaleX: 1.0, scaleY:1.0,  rotation: rot.toString(), repeat: -1 } );
		}
		
		public function failAnimation():void 
		{
			tryImage.visible = successImage.visible = false;
			failImage.visible = true;
			failImage.scaleX = 3.0;
			TweenMax.to(failImage, 0.5, { scaleX:1.0 } );
		}
	
	}

}