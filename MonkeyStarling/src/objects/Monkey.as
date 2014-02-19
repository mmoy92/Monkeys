package objects {
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.geom.Rectangle;
	import screens.Zone;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.PDParticleSystem;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Color;
	import starling.utils.deg2rad;
	import starling.utils.getNextPowerOfTwo;
	import ui.BananaCount;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class Monkey extends HitSprite {
		public var id:int;
		public var username:String = "";
		public var inGame:Boolean = false;
		public var bananas:int = 0;
		
		public var sprite:Sprite;
		private var standMC:MovieClip;
		private var walkMC:MovieClip;
		private var punchMC:MovieClip;
		private var sitIMG:Image;
		private var flyDeadIMG:Image;
		private var floorDeadIMG:Image;
		
		private var objVector:Vector.<Quad>;
		public static const STAND:uint = 0;
		public static const WALK:uint = 1;
		public static const PUNCH:uint = 2;
		public static const SIT:uint = 3;
		public static const FLYDEAD:uint = 4;
		public static const FLOORDEAD:uint = 5;
		public const scale:Number = 1.0;
		
		public var bcSprite:BananaCount;
		public var nameTxt:TextField;
		
		public var keyUp:Boolean = false;
		public var keyDown:Boolean = false;
		public var keyLeft:Boolean = false;
		public var keyRight:Boolean = false;
		
		public var messageTimeout:int = 0;
		public var trueX:int = 0;
		public var trueY:int = 0;
		
		//The ammount they are off position
		public var offX:Number = 0;
		public var offY:Number = 0;
		//The ammount to correct the player by each time step
		public var offStepX:Number = 0;
		public var offStepY:Number = 0;
		
		public var freeMovement:Boolean = true;
		public var canMoveRight:Boolean = true;
		public var canMoveLeft:Boolean = true;
		public var canMoveUp:Boolean = true;
		public var canMoveDown:Boolean = true;
		
		public var weapon:String = "None";
		public var stance:uint = STAND;
		public var team:int = 0;
		public var zone:Zone;
		
		private var vely:Number = 0;
		
		private var punchTween:TweenMax;
		public var myPS:PDParticleSystem;
		public var confirmedDie:Boolean;
		public var deathFunc:Function;
		
		public function Monkey() {
			var pX:Vector.<int> = Vector.<int>([0, -43, -54, -27, -18, -8, -2, 10, 9, 32, 44, 41, 25, 1, -16, -44, -43, 0]);
			var pY:Vector.<int> = Vector.<int>([0, -24, -7, -6, -12, -4, -10, -6, -36, -44, -61, -70, -80, -78, -57, -46, -24, 0]);
			setPoly(pX, pY);
			addEventListener(Event.ADDED_TO_STAGE, init);
		
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			sprite = new Sprite();
			sprite.scaleX = sprite.scaleY = scale;
			addChild(sprite);
			
			initAnimations();
			
			sprite.pivotX = sprite.width / 2;
			sprite.y = -sprite.height;
			
			bcSprite = new BananaCount();
			bcSprite.x = bcSprite.width / 2;
			bcSprite.y = -110;
			addChild(bcSprite);
			
			nameTxt = new TextField(104, 21, "", Assets.getFont().name, 15, Color.BLACK);
			nameTxt.x = -52;
			nameTxt.y = -110;
			addChild(nameTxt);
		}
		
		private function initAnimations():void {
			var standFrames:Vector.<Texture> = Assets.getAtlas().getTextures("player_still_");
			standMC = new MovieClip(standFrames, 7);
			sprite.addChild(standMC);
			
			var walkFrames:Vector.<Texture> = Assets.getAtlas().getTextures("player_walk_");
			walkMC = new MovieClip(walkFrames, 20);
			walkMC.addFrameAt(2, Assets.getAtlas().getTexture("player_walk_0002"));
			walkMC.addFrameAt(7, Assets.getAtlas().getTexture("player_walk_0006"));
			
			var punchFrames:Vector.<Texture> = Assets.getAtlas().getTextures("player_punch_");
			punchMC = new MovieClip(punchFrames, 30);
			punchMC.addFrameAt(3, Assets.getAtlas().getTexture("player_punch_0003"));
			punchMC.addFrameAt(5, Assets.getAtlas().getTexture("player_punch_0004"));
			punchMC.addFrameAt(9, Assets.getAtlas().getTexture("player_punch_0007"), null, 0.3);
			punchMC.addFrameAt(13, Assets.getAtlas().getTexture("player_punch_0008"), null, 0.3);
			punchMC.addFrameAt(15, Assets.getAtlas().getTexture("player_punch_0009"), null, 0.3);
			punchMC.addFrameAt(16, Assets.getAtlas().getTexture("player_punch_0010"), null, 0.3);
			punchMC.loop = false;
			
			var sitImage:Image = new Image(Assets.getAtlas().getTexture("player_sit_"));
			//sitImage.x = -sitImage.width / 2;
			sitImage.y = -10;
			
			var flyDieImage:Image = new Image(Assets.getAtlas().getTexture("player_flydie_"));
			flyDieImage.x = 75;
			flyDieImage.y = -25;
			flyDieImage.pivotX = flyDieImage.width / 2;
			flyDieImage.pivotY = flyDieImage.height / 2;
			var floorDieImage:Image = new Image(Assets.getAtlas().getTexture("player_floordie_"));
			floorDieImage.x = floorDieImage.width / 2;
			floorDieImage.y = -25;
			floorDieImage.pivotX = floorDieImage.width / 2;
			floorDieImage.pivotY = floorDieImage.height / 2;
			
			objVector = new Vector.<Quad>();
			objVector[STAND] = standMC;
			objVector[WALK] = walkMC;
			objVector[PUNCH] = punchMC;
			objVector[SIT] = sitImage;
			objVector[FLYDEAD] = flyDieImage;
			objVector[FLOORDEAD] = floorDieImage;
		}
		
		public function enterFrame():void {
			if (nameTxt && bcSprite) {
				nameTxt.text = username;
				bcSprite.txt.text = "" + bananas;
			}
			var keyBool:Boolean = (keyLeft && (keyDown || keyUp)) || (keyRight && (keyDown || keyUp)) || ((keyLeft && keyRight) && (keyUp || keyDown)) || ((keyUp && keyDown) && (keyLeft || keyRight));
			if (((canMoveDown && keyDown && !keyUp) || (canMoveUp && keyUp && !keyDown) || (canMoveLeft && keyLeft && !keyRight) || (canMoveRight && keyRight && !keyLeft)) || (keyBool && !(keyLeft && keyRight && keyUp && keyLeft))) {
				if (stance == STAND && freeMovement) {
					walkMC.stop();
					walkMC.play();
					changeStance(WALK);
				}
			} else if (stance == WALK) {
				changeStance(STAND);
			}
			if (stance == FLYDEAD) {
				vely += 0.7;
				sprite.y += vely;
				if (sprite.y > 0) {
					vely = -vely / 1.8;
					var absVel:Number = Math.abs(vely);
					if (absVel < 1) {
						vely = 0;
						sprite.y = 0;
						changeStance(FLOORDEAD);
						squash();
					} else if (absVel > 3) {
						squash();
					}
					sprite.y = 0;
				}
				if (y + sprite.y < 0) {
					sprite.y = -y;
					vely = 0;
				}
			}
			if (myPS) {
				myPS.emitterX = sprite.x;
				myPS.emitterY = sprite.y-10;
			}
		}
		
		private function squash():void {
			getMC().scaleX = 1.3;
			getMC().scaleY = 0.8;
			TweenMax.to(getMC(), 0.5, {scaleX: 1.0, scaleY: 1.0, ease: Strong.easeOut});
		}
		
		public function smashed():void {
			vely = -60;
			changeStance(FLYDEAD);
			var newX:Number =  - 100 + Math.random() * 200;
			TweenMax.to(sprite, 2, {x: newX, ease: Strong.easeOut});
			TweenMax.to(getMC(), 2, {rotation: deg2rad(720), ease: Strong.easeOut});
		}
		
		public function getMC(i:int = -1):Quad {
			if (i == -1) {
				i = stance;
			}
			return objVector[i];
		}
		
		public function changeStance(newStance:uint):void {
			if (newStance != stance) {
				var curObject:DisplayObject = objVector[stance];
				if (curObject) {
					sprite.removeChild(curObject);
					if (curObject is MovieClip) {
						Starling.juggler.remove(curObject as MovieClip);
					}
				}
				stance = newStance;
				curObject = objVector[stance];
				if (curObject) {
					sprite.addChild(curObject);
					if (curObject is MovieClip) {
						Starling.juggler.add(curObject as MovieClip);
					}
				}
			}
		}
		
		public function punch():void {
			if (stance != PUNCH) {
				if (punchTween) {
					punchTween.kill();
				}
				freeMovement = false;
				changeStance(PUNCH);
				punchMC.stop();
				punchMC.play();
				TweenMax.delayedCall(0.7, changeStance, [STAND]);
			}
		}
		public function readyDie():void {
			//canPop = false;
			TweenMax.delayedCall(0.23,tryDie);
			//TweenMax.to(img, 0.23, {scaleY: 1.2, scaleX: 0.8, ease: Strong.easeOut, onComplete: tryPop});
		}
		
		private function tryDie():void {
			if (confirmedDie) {
				deathFunc(this);
			} else {
				//canPop = true;
				//img.scaleX = 1.5;
				//img.scaleY = 0.8;
				//TweenMax.to(img, 0.4, {scaleY: 1.0, scaleX: 1.0, ease: Strong.easeOut});
			}
		}
		public function setDir(i:int):void {
			sprite.scaleX = i * scale;
			reversed = i < 0;
		}
	}

}