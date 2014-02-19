package screens {
	import com.camerafocus.StarlingCameraFocus;
	import com.greensock.TweenMax;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import objects.Monkey;
	import playerio.Connection;
	import playerio.Message;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	import ui.BananaCount;
	import ui.HUD;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class Zone implements ZoneBase {
		
		public var game:Game;
		public var connection:Connection;
		public var myMonkey:Monkey;
		public var ghostMonkey:Monkey;
		
		public var players:Array = new Array();
		public var spectators:Array = new Array();
		
		public static const FIXED:uint = 0;
		public static const MY_MONKEY:uint = 1;
		public static const MOUSE:uint = 2;
		//public var mousePos:Point = new Point(0, 0);
		public var camMode:uint = MY_MONKEY;
		
		public var cam:StarlingCameraFocus;
		public var camPoint:Point;
		public var hud:HUD;
		public var roomPolyX:Vector.<int>;
		public var roomPolyY:Vector.<int>;
		public var roomBounds:Rectangle;
		public var background:Sprite = new Sprite();
		public var objContainer:Sprite = new Sprite();
		public var bgImage:Image;
		
		protected var doSort:Boolean = false;
		public var numPlayers:int = 0;
		
		//Time at the last state update
		public var oldStateTime:Number = 0;
		//Time at the last frame
		public var oldTime:Number = (new Date()).getTime();
		public var updateDiff:Number;
		public var rewindBuffer:Array;
		private var recordRewind:Boolean = false;
		
		protected var stage:Stage = Starling.current.stage;
		
		public function Zone(_game:Game, _connection:Connection) {
			game = _game;
			connection = _connection;
			
			camPoint = new Point(stage.stageWidth / 2, stage.stageHeight / 2);
			cam = new StarlingCameraFocus(stage, game, camPoint, [], true);
			//cam.zoomFocus(1.25);
			cam.setBoundary(objContainer, roomBounds);
			
			ghostMonkey = new Monkey();
			ghostMonkey.alpha = 0.0;
			
			addHandlers();
		
		}
		
		// =======================================================================// 
		// Level setup
		// =======================================================================//
		public function addChildren():void {
			background.addChild(bgImage);
			game.addChild(background);
			game.addChild(objContainer);
			stage.addChild(hud);
			game.addChild(ghostMonkey);
		}
		
		public function removeChildren():void {
			
			stage.removeChild(hud, true);
			game.removeChild(objContainer, true);
			game.removeChild(background, true);
			game.removeChild(ghostMonkey, true);
			
			ghostMonkey = null;
			players = null;
			spectators = null;
			hud = null;
			cam = null;
			objContainer = null;
			background = null;
			
			game.removeChildren(0, -1, true);
		
		}
		
		public function addHandlers():void {
			//Up
			connection.addMessageHandler("uDown", handleKeyEvent);
			connection.addMessageHandler("uUp", handleKeyEvent);
			//Down
			connection.addMessageHandler("dDown", handleKeyEvent);
			connection.addMessageHandler("dUp", handleKeyEvent);
			//Right
			connection.addMessageHandler("rDown", handleKeyEvent);
			connection.addMessageHandler("rUp", handleKeyEvent);
			//Left
			connection.addMessageHandler("lDown", handleKeyEvent);
			connection.addMessageHandler("lUp", handleKeyEvent);
			
			connection.addMessageHandler("UpdateFM", handleFMUpdate);
			connection.addMessageHandler("KeysFalse", handleKeysFalse);
			
			//Add listener for init request
			connection.addMessageHandler("GetWorldState", handleInit);
			connection.addMessageHandler("State", handleStateUpdate);
			connection.addMessageHandler("Correction", handleCorrection);
			
			//Add message listener for users leaving the room
			connection.addMessageHandler("UserLeft", handleUserLeft);
			//Add message listener for users joining the room
			connection.addMessageHandler("UserJoined", handleNewJoin);
			
			connection.addMessageHandler("RewardBanana", handleRewardBanana);
			connection.addMessageHandler("DeductBanana", handleDeductBanana);
			
			connection.addMessageHandler("UpdateStab", handleUpdateStab);
			connection.addMessageHandler("StabAction", handleStabAction);
			
			stage.addEventListener(TouchEvent.TOUCH, handleTouch);
			stage.addEventListener(EnterFrameEvent.ENTER_FRAME, game.handleEnterFrame);
		}
		
		public function removeHandlers():void {
			connection.removeMessageHandler("uDown", handleKeyEvent);
			connection.removeMessageHandler("uUp", handleKeyEvent);
			connection.removeMessageHandler("dDown", handleKeyEvent);
			connection.removeMessageHandler("dUp", handleKeyEvent);
			connection.removeMessageHandler("rDown", handleKeyEvent);
			connection.removeMessageHandler("rUp", handleKeyEvent);
			connection.removeMessageHandler("lDown", handleKeyEvent);
			connection.removeMessageHandler("lUp", handleKeyEvent);
			connection.removeMessageHandler("UpdateFM", handleFMUpdate);
			connection.removeMessageHandler("KeysFalse", handleKeysFalse);
			connection.removeMessageHandler("GetWorldState", handleInit);
			connection.removeMessageHandler("State", handleStateUpdate);
			connection.removeMessageHandler("Correction", handleCorrection);
			connection.removeMessageHandler("UserLeft", handleUserLeft);
			connection.removeMessageHandler("UserJoined", handleNewJoin);
			connection.removeMessageHandler("RewardBanana", handleRewardBanana);
			connection.removeMessageHandler("DeductBanana", handleDeductBanana);
			connection.removeMessageHandler("UpdateStab", handleUpdateStab);
			connection.removeMessageHandler("StabAction", handleStabAction);
			
			stage.removeEventListener(TouchEvent.TOUCH, handleTouch);
			stage.removeEventListener(EnterFrameEvent.ENTER_FRAME, game.handleEnterFrame);
		}
		
		// =======================================================================// 
		// Init Methods    
		// =======================================================================//  
		
		public function handleInit(info:Message):void {
			//To be overridden
		}
		
		public function handleNewJoin(info:Message):void {
			//To be overridden
		}
		
		public function handleUserLeft(info:Message):void {
			//remove the player when he leaves
			var pID:int = info.getInt(0);
			var curMonkey:Monkey = getMonkey(pID);
			
			userLeft(curMonkey);
			objContainer.removeChild(curMonkey, true);
			
			delete players[pID];
			delete spectators[pID];
			numPlayers--;
		}
		
		public function userLeft(curMonkey:Monkey):void {
			//To be overidden
		}
		
		// =======================================================================// 
		// Frame Update Methods    
		// =======================================================================//  
		
		public function update():void {
			if (cam != null) {
				if (camMode == MY_MONKEY) {
					camPoint.x = myMonkey.x
					camPoint.y = myMonkey.y - 100;
					cam.trackStep = 20;
				} else if (camMode == FIXED) {
					cam.trackStep = 20;
				}
				cam.update();
			}
			//compute the time since last update
			var curTime:Number = (new Date()).getTime();
			updateDiff = curTime - oldTime;
			oldTime = curTime;
			if (myMonkey) {
				myMonkey.keyUp = game.keyUp;
				myMonkey.keyDown = game.keyDown;
				myMonkey.keyRight = game.keyRight;
				myMonkey.keyLeft = game.keyLeft;
				
				ghostMonkey.x = myMonkey.trueX;
				ghostMonkey.y = myMonkey.trueY;
			}
			updateZone();
			//Move all players
			for (var pID:String in players) {
				var curPlayer:Monkey = getMonkey(int(pID));
				if (curPlayer != null) {
					curPlayer.enterFrame();
					
					//Only lets chat messages display for a short time
					//if (curPlayer.messageTimeout > 0) {
					//curPlayer.messageTimeout--;
					//} else {
					//curPlayer.userSays.text = "";
					//}
					
					updatePlayers(curPlayer);
				}
			}
			for (var pIDb:String in spectators) {
				var curSpectator:Monkey = getMonkey(int(pIDb));
				if (curSpectator != null) {
					curSpectator.enterFrame();
					updateSpectators(curSpectator);
				}
			}
			if (doSort) {
				objContainer.sortChildren(sortByY);
				doSort = false;
			}
		
		}
		
		// =======================================================================// 
		// Frame Update Methods  
		// =======================================================================//
		public function updateZone():void {
			//To be overridden
		}
		
		public function updateSpectators(curSpectator:Monkey):void {
			//To be overridden
			updateMovement(curSpectator);
		}
		
		public function updatePlayers(curPlayer:Monkey):void {
			//To be overridden
		
		}
		
		// =======================================================================// 
		// State Update  
		// =======================================================================//
		public function handleStateUpdate(info:Message):void {
			//To be overridden
		}
		
		public function updateMovement(monkey:Monkey):void {
			if (monkey.freeMovement) {
				//Right bounds
				if (monkey.canMoveRight) {
					if (levelHitTest(monkey.x + 25, monkey.y)) {
						monkey.canMoveRight = false;
					}
				} else if (!levelHitTest(monkey.x + 25, monkey.y)) {
					monkey.canMoveRight = true;
				}
				//Left bounds
				if (monkey.canMoveLeft) {
					if (levelHitTest(monkey.x - 25, monkey.y)) {
						monkey.canMoveLeft = false;
					}
				} else if (!levelHitTest(monkey.x - 25, monkey.y)) {
					monkey.canMoveLeft = true;
				}
				//Top bounds
				if (monkey.canMoveUp) {
					if (levelHitTest(monkey.x, monkey.y - 15)) {
						monkey.canMoveUp = false;
					}
				} else if (!levelHitTest(monkey.x, monkey.y - 15)) {
					monkey.canMoveUp = true;
				}
				//Bottom bounds
				if (monkey.canMoveDown) {
					if (levelHitTest(monkey.x, monkey.y + 10)) {
						monkey.canMoveDown = false;
					}
				} else if (!levelHitTest(monkey.x, monkey.y + 10)) {
					monkey.canMoveDown = true;
				}
				if (monkey.canMoveUp && monkey.keyUp) {
					monkey.y -= updateDiff * game.maxVel.y;
					if (!monkey.keyDown) {
						monkey.y += monkey.offStepY * updateDiff;
						monkey.offY -= monkey.offStepY * updateDiff;
						doSort = true;
					}
				}
				if (monkey.canMoveDown && monkey.keyDown) {
					monkey.y += updateDiff * game.maxVel.y;
					if (!monkey.keyUp) {
						monkey.y += monkey.offStepY * updateDiff;
						monkey.offY -= monkey.offStepY * updateDiff;
						doSort = true;
					}
				}
				if (monkey.canMoveRight && monkey.keyRight) {
					monkey.setDir(1);
					monkey.x += updateDiff * game.maxVel.x;
					if (!monkey.keyLeft) {
						monkey.x += monkey.offStepX * updateDiff;
						monkey.offX -= monkey.offStepX * updateDiff;
					}
				}
				if (monkey.canMoveLeft && monkey.keyLeft) {
					monkey.setDir(-1);
					monkey.x -= updateDiff * game.maxVel.x;
					if (!monkey.keyRight) {
						monkey.x += monkey.offStepX * updateDiff;
						monkey.offX -= monkey.offStepX * updateDiff;
					}
				}
				
				if (myMonkey == monkey) {
					//if (recordRewind) {
					//rewindBuffer.push(myMonkey.keyDown, myMonkey.keyUp, myMonkey.keyRight, myMonkey.keyLeft);
					//}
					if (Math.abs(monkey.trueX - monkey.x) > 30 || Math.abs(monkey.trueY - monkey.y) > 30) {
						monkey.x += (monkey.trueX - monkey.x) / 10;
						//monkey.offX = 0;
						monkey.y += (monkey.trueY - monkey.y) / 10;
							//monkey.offY = 0;
							//connection.send("Rewind");
							//recordRewind = true;
							//rewindBuffer = new Array();
					}
				} else {
					if (Math.abs(monkey.trueX - monkey.x) > 30 || Math.abs(monkey.trueY - monkey.y) > 30) {
						monkey.x += (monkey.trueX - monkey.x) / 4;
						monkey.offX = 0;
						monkey.y += (monkey.trueY - monkey.y) / 4;
						monkey.offY = 0;
					}
					
				}
				
			}
		}
		
		public function interpolate(curMonkey:Monkey, localDiff:Number, serverDiff:Number):void {
			
			//First, compute how much the your position is off by
			var latencyDiffX:Number = (localDiff - serverDiff) * game.maxVel.x;
			var latencyDiffY:Number = (localDiff - serverDiff) * game.maxVel.y;
			curMonkey.offX = (curMonkey.trueX + (curMonkey.keyRight ? latencyDiffX : 0) - (curMonkey.keyLeft ? latencyDiffX : 0)) - curMonkey.x;
			curMonkey.offY = (curMonkey.trueY + (curMonkey.keyDown ? latencyDiffY : 0) - (curMonkey.keyUp ? latencyDiffY : 0)) - curMonkey.y;
			
			//Then calculate how much you have to change each ms.
			//Smoothness is more important here then accuracy thus I have it correct slower than next state update.
			//This is not reccommended if position accuracy is important to you.
			if (curMonkey != myMonkey) {
				curMonkey.offStepX = curMonkey.offX / 100;
				curMonkey.offStepY = curMonkey.offY / 100;
			} 
			//We can afford to be much more lax on our own updates because we know our input (and the player doesn't want choppy movement)
			else {
				curMonkey.offStepX = curMonkey.offX / 400;
				curMonkey.offStepY = curMonkey.offY / 400;
			}
		
		}
		
		public function handleCorrection(info:Message, _x:int, _y:int, down:Boolean, up:Boolean, right:Boolean, left:Boolean):void {
			myMonkey.x = _x;
			myMonkey.y = _y;
			myMonkey.canMoveDown = down;
			myMonkey.canMoveUp = up;
			myMonkey.canMoveRight = right;
			myMonkey.canMoveLeft = left;
			//for (var i:int = 0; i < rewindBuffer.length / 4; i++) {
			//myMonkey.keyDown = rewindBuffer[i];
			//myMonkey.keyUp = rewindBuffer[i + 1];
			//myMonkey.keyRight = rewindBuffer[i + 2];
			//myMonkey.keyLeft = rewindBuffer[i + 3];
			//updateMovement(myMonkey);
			//}
		
			//recordRewind = false;
			//rewindBuffer = new Array();
		
		}
		
		// =======================================================================// 
		// Input Methods  
		// =======================================================================//
		private function handleKeyEvent(info:Message):void {
			var pID:int = info.getInt(0);
			var curMonkey:Monkey = getMonkey(pID);
			switch (info.type) {
				case "uDown": 
					curMonkey.keyUp = true;
					break;
				case "uUp": 
					curMonkey.keyUp = false;
					break;
				case "dDown": 
					curMonkey.keyDown = true;
					break;
				case "dUp": 
					curMonkey.keyDown = false;
					break;
				case "rDown": 
					curMonkey.keyRight = true;
					break;
				case "rUp": 
					curMonkey.keyRight = false;
					break;
				case "lDown": 
					curMonkey.keyLeft = true;
					break;
				case "lUp": 
					curMonkey.keyLeft = false;
					break;
			}
		
		}
		
		public function freezeMonkey(curPlayer:Monkey):void {
			curPlayer.freeMovement = false;
			if (curPlayer.stance == Monkey.WALK) {
				curPlayer.changeStance(Monkey.STAND);
			}
		}
		
		public function freezeEveryone():void {
			for (var pID:String in players) {
				var curPlayer:Monkey = players[pID];
				freezeMonkey(curPlayer);
			}
		}
		
		public function freeMonkey(curPlayer:Monkey):void {
			curPlayer.freeMovement = true;
		}
		
		public function freeEveryone():void {
			for (var pID:String in players) {
				var curPlayer:Monkey = players[pID];
				freeMonkey(curPlayer);
			}
		}
		
		public function handleKeysFalse(m:Message, id:int):void {
			var myMonkey:Monkey = getMonkey(id);
			myMonkey.keyRight = false;
			myMonkey.keyLeft = false;
			myMonkey.keyUp = false;
			myMonkey.keyDown = false;
		
		}
		
		public function handleDeactivate():void {
			if (myMonkey) {
				myMonkey.keyRight = game.keyRight = false;
				myMonkey.keyLeft = game.keyLeft = false;
				myMonkey.keyUp = game.keyUp = false;
				myMonkey.keyDown = game.keyDown = false;
				connection.send("KeysFalse");
			}
		}
		
		public function handleFMUpdate(m:Message, id:int, fm:Boolean):void {
			getMonkey(id).freeMovement = fm;
		}
		
		
		private function sendFMUpdate():void {
			connection.send("FM", myMonkey.freeMovement);
		
		}
		
		public function handleUpdateStab(m:Message, id:int, isStab:Boolean):void {
			var other:Monkey = getMonkey(id);
			if (other && isStab) {
				other.confirmedDie = true;
			}
		}
		
		public function handleStabAction(m:Message, killerId:int, victimId:int):void {
			trace("got stabbed");
			var killer:Monkey = getMonkey(killerId);
			killer.punch();
			killer.x = killer.trueX;
			killer.y = killer.trueY;
			if (victimId != -1) {
				var victim:Monkey = getMonkey(victimId);
				if (victim) {
					victim.x = victim.trueX;
					victim.y = victim.trueY;
					victim.confirmedDie = true;
					victim.readyDie();
				}
			}
		}
		
		public function setFire(monkey:Monkey):void {
			var firePS:PDParticleSystem = new PDParticleSystem(XML(new AssetsParticles.BurnicleXML()), Assets.getAtlas().getTexture("blobTexture"));
			firePS.touchable = false;
			Starling.juggler.add(firePS);
			objContainer.addChild(firePS);
			
			firePS.x = monkey.x;
			firePS.y = monkey.y + 1;
			
			monkey.myPS = firePS;
			monkey.getMC().color = 0x8D2121;
			monkey.getMC(Monkey.FLOORDEAD).color = 0x8D2121;
			
			firePS.start();
			
			var splodePS:PDParticleSystem = new PDParticleSystem(XML(new AssetsParticles.SplodicleXML()), Assets.getAtlas().getTexture("moteTexture"));
			splodePS.touchable = false;
			Starling.juggler.add(splodePS);
			objContainer.addChild(splodePS);
			splodePS.x = monkey.x;
			splodePS.y = monkey.y + 2;
			splodePS.populate(50);
			splodePS.start(0.1);
		}
		
		// =======================================================================// 
		// Depth Methods  
		// =======================================================================//
		
		public function sortByY(object1:DisplayObject, object2:DisplayObject):int {
			var y1:Number = object1.y;
			var y2:Number = object2.y;
			if (y1 < y2) {
				return -1;
			}
			if (y1 > y2) {
				return 1;
			}
			return 0;
		}
		
		// =======================================================================// 
		// Auxiliary Methods
		// =======================================================================//
		public function getMonkey(pID:int):Monkey {
			if (players[pID] != undefined && players[pID] != null) {
				return Monkey(players[pID]);
			} else if (spectators[pID] != undefined) {
				return Monkey(spectators[pID]);
			}
			trace("Monkey Id " + pID + " not found!");
			return null;
		
		}
		
		public function handleRewardBanana(info:Message, id:int, amt:int):void {
			
			trace("rewarding banana" + amt);
			var monkey:Monkey = getMonkey(id);
			var popup:BananaCount = new BananaCount();
			popup.y = monkey.bcSprite.y;
			monkey.addChild(popup);
			
			popup.reward(amt - monkey.bananas);
			monkey.bcSprite.changed();
			
			monkey.bananas = amt;
		}
		
		public function handleDeductBanana(info:Message, id:int, amt:int):void {
			var monkey:Monkey = getMonkey(id);
			
			var popup:BananaCount = new BananaCount();
			popup.y = monkey.bcSprite.y;
			monkey.addChild(popup);
			
			popup.deduct(monkey.bananas - amt);
			monkey.bcSprite.changed();
			
			monkey.bananas = amt;
		}
		
		// =======================================================================// 
		// Mouse Handlers
		// =======================================================================//
		public function handleTouch(e:TouchEvent):void {
			if (camMode == MOUSE) {
				var touch:Touch = e.getTouch(stage, TouchPhase.HOVER);
				var station:Touch = e.getTouch(stage, TouchPhase.ENDED);
				if (touch) {
					camPoint.x = (roomBounds.width) * (touch.globalX / stage.stageWidth);
					camPoint.y = roomBounds.height * (touch.globalY / stage.stageHeight);
					cam.trackStep = 100;
				}
			}
		}
		
		// =======================================================================// 
		// Object management
		// =======================================================================//
		public function inRange(mcA:DisplayObject, mcB:DisplayObject, halfRangeX:int, halfRangeY:int):Boolean {
			var ax:int = mcA.x;
			var ay:int = mcA.y;
			
			var bx:int = mcB.x;
			var by:int = mcB.y;
			
			if (mcA is Monkey) {
				ax = Monkey(mcA).trueX;
				ay = Monkey(mcA).trueY;
			}
			
			if (mcB is Monkey) {
				bx = Monkey(mcB).trueX;
				by = Monkey(mcB).trueY;
			}
			
			return (ax >= bx - halfRangeX && ax <= bx + halfRangeX && ay >= by - halfRangeY && ay <= by + halfRangeY);
		}
		
		public function levelHitTest(testx:Number, testy:Number):Boolean {
			
			return hitTest(roomPolyX, roomPolyY, testx, testy);
		}
		
		public function hitTest(listX:Vector.<int>, listY:Vector.<int>, testx:Number, testy:Number):Boolean {
			
			var i:int = 0;
			var j:int = 0;
			
			var c:Boolean = false;
			for (i = 0, j = listX.length - 1; i < listX.length; j = i++) {
				if (((listY[i] > testy) != (listY[j] > testy)) && (testx < (listX[j] - listX[i]) * (testy - listY[i]) / (listY[j] - listY[i]) + listX[i]))
					c = !c;
			}
			return c;
		}
		
		public function addObj(mc:Sprite):void {
			objContainer.addChild(mc);
			doSort = true;
		}
		
		public function removeObj(mc:Sprite):void {
			objContainer.removeChild(mc, true);
			doSort = true;
		}
	
	}

}