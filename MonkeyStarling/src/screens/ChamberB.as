package screens {
	import com.greensock.easing.RoughEase;
	import com.greensock.easing.Strong;
	import com.greensock.TimelineMax;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import objects.Bloon;
	import objects.Chair;
	import objects.HitSprite;
	import objects.Monkey;
	import objects.TagItem;
	import playerio.Connection;
	import playerio.Message;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	import ui.HUD;
	import ui.TestInstr;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class ChamberB extends Zone {
		private var balloons:Array = new Array();
		private var chairs:Array = new Array();
		
		public var phase:String = "Waiting";
		public const minPlayers:int = 2;
		
		private var partycleSystem:PDParticleSystem;
		
		public function ChamberB(_game:Game, _connection:Connection) {
			hud = new HUD(new TestInstr("Test 2\nMusical Chairs", "Don't be the last one on stage."));
			bgImage = new Image(Assets.getAtlas().getTexture("bg_ChamberB"));
			bgImage.scaleX = bgImage.scaleY = 1.78;
			
			roomBounds = new Rectangle(0, 0, 2319, 480);
			
			roomPolyX = Vector.<int>([0, -179, 2437, 2437, -179, -179, 0, 183, 492, 366, 0, 183, 0, 596, 2137, 2322, 470, 596, 0]);
			roomPolyY = Vector.<int>([0, 122, 122, 600, 600, 122, 0, 240, 240, 479, 479, 240, 0, 240, 240, 479, 479, 240, 0]);
			
			partycleSystem = new PDParticleSystem(XML(new AssetsParticles.PartycleXML()), Assets.getAtlas().getTexture("circleTexture"));
			partycleSystem.touchable = false;
			//partycleSystem.scaleX = partycleSystem.scaleY = 0.5;
			Starling.juggler.add(partycleSystem);
			
			super(_game, _connection);
		
		}
		
		// =======================================================================// 
		// Level setup
		// =======================================================================//
		override public function addChildren():void {
			super.addChildren();
			objContainer.addChild(partycleSystem);
		
		}
		
		override public function removeChildren():void {
			super.removeChildren();
			partycleSystem = null;
			chairs = null;
			balloons = null;
		
		}
		
		override public function addHandlers():void {
			super.addHandlers();
			
			connection.addMessageHandler("RoomStart", handleRoomStart);
			connection.addMessageHandler("RichStart", handleRichStart);
			connection.addMessageHandler("TestStart", handleTestStart);
			connection.addMessageHandler("SpawnBalloon", handleSpawnBalloon);
			connection.addMessageHandler("BalloonReady", handleBalloonReady);
			
			connection.addMessageHandler("UpdatePop", handleUpdatePop);
			connection.addMessageHandler("PopAction", handlePopAction);
			
			connection.addMessageHandler("MonkeySat", handleNewSit);
			connection.addMessageHandler("RemoveChair", handleRemoveChair);
			connection.addMessageHandler("Results", handleResults);
			connection.addMessageHandler("AdvanceB", handleAdvanceRoom);
		}
		
		override public function removeHandlers():void {
			super.removeHandlers();
			
			connection.removeMessageHandler("RoomStart", handleRoomStart);
			connection.removeMessageHandler("RichStart", handleRichStart);
			connection.removeMessageHandler("TestStart", handleTestStart);
			connection.removeMessageHandler("SpawnBalloon", handleSpawnBalloon);
			connection.removeMessageHandler("BalloonReady", handleBalloonReady);
			
			connection.removeMessageHandler("UpdatePop", handleUpdatePop);
			connection.removeMessageHandler("PopAction", handlePopAction);
			
			connection.removeMessageHandler("MonkeySat", handleNewSit);
			connection.removeMessageHandler("RemoveChair", handleRemoveChair);
			connection.removeMessageHandler("Results", handleResults);
			connection.removeMessageHandler("AdvanceB", handleAdvanceRoom);
		}
		
		// =======================================================================// 
		// Init Methods    
		// =======================================================================//  
		private function handleRoomStart(info:Message):void {
			if (myMonkey.inGame) {
				camMode = FIXED;
				
				hud.statusTxt.text = "";
				
				phase = "RoomStart";
				cam.zoomFocus(1.0);
				var tl:TimelineMax = new TimelineMax();
				tl.call(hud.instrSprite.animate);
				tl.add(TweenLite.to(camPoint, 1.0, {y: 240, x: 610, ease: Strong.easeInOut}));
				
				//Init chairs
				var wVars:int = 0;
				var pVars:int = 3;
				for (var i:int = 0; i < (info.length - wVars) / pVars; i++) {
					var varBase:int = (i * pVars) + wVars;
					var cx:int = info.getInt(varBase);
					var cy:int = info.getInt(varBase + 1);
					var ctag:uint = info.getInt(varBase + 2);
					
					var newChair:Chair = new Chair(cx, cy, ctag);
					
					newChair.monkey = null;
					
					chairs.push(newChair);
					addObj(newChair);
				}
				doSort = true;
			}
		}
		
		private function handleRichStart(info:Message):void {
			if (myMonkey.inGame) {
				phase = "RichTesting";
				
				//background.partyStage.play();
				//hud.instrMC.gotoAndStop("richFirst");
				hud.statusTxt.text = "Rich monkeys get first pick.";
				var isRich:Boolean = false;
				for (var pID:String in players) {
					var curPlayer:Monkey = getMonkey(int(pID));
					if (curPlayer.bananas >= 10) {
						isRich = true;
						freeMonkey(curPlayer);
					}
				}
				if (isRich) {
					if (myMonkey.bananas >= 10) {
						camMode = MY_MONKEY;
						cam.zoomFocus(1.25);
					} else {
						cam.zoomFocus(1.0);
					}
				}
			}
		}
		
		private function handleTestStart(info:Message):void {
			if (myMonkey.inGame) {
				phase = "Testing";
				camMode = MY_MONKEY;
				//hud.instrMC.gotoAndStop("open");
				cam.zoomFocus(1.25);
				hud.statusTxt.text = "The stage is open."
				roomPolyX = Vector.<int>([0, -179, 2437, 2437, -179, -179, 0, 183, 2137, 2322, 0, 183, 0]);
				roomPolyY = Vector.<int>([0, 122, 122, 600, 600, 122, 0, 240, 240, 479, 479, 240, 0]);
			}
		}
		
		override public function handleInit(info:Message):void {
			var wVars:int = 2;
			var pVars:int = 10;
			//Get your ID and phase
			phase = info.getString(0);
			game.id = info.getInt(1);
			//Load every existing player's data
			for (var i:int = 0; i < (info.length - wVars) / pVars; i++) {
				var varBase:int = (i * pVars) + wVars;
				var pID:int = info.getInt(varBase);
				var newMonkey:Monkey = new Monkey();
				
				//Retrieve from message
				newMonkey.id = pID;
				newMonkey.x = newMonkey.trueX = info.getInt(varBase + 1);
				newMonkey.y = newMonkey.trueY = info.getInt(varBase + 2);
				newMonkey.keyUp = info.getBoolean(varBase + 3);
				newMonkey.keyDown = info.getBoolean(varBase + 4);
				newMonkey.keyRight = info.getBoolean(varBase + 5);
				newMonkey.keyLeft = info.getBoolean(varBase + 6);
				newMonkey.bananas = info.getInt(varBase + 7);
				newMonkey.inGame = info.getBoolean(varBase + 8);
				newMonkey.username = info.getString(varBase + 9);
				
				if (phase == "Testing" || phase == "Results") {
					//roomHitBox.gotoAndStop(2);
				}
				
				if (newMonkey.inGame) {
					players[pID] = newMonkey;
				} else {
					spectators[pID] = newMonkey;
					newMonkey.alpha = 0.5;
				}
				
				addObj(newMonkey);
				
				numPlayers++;
			}
			doSort = true;
		}
		
		// =======================================================================// 
		// Join Method 
		// =======================================================================//  
		override public function handleNewJoin(info:Message):void {
			
			//Get new player's id
			var pID:int = info.getInt(0);
			var newMonkey:Monkey = new Monkey();
			//Set him at the given x and y with all default properties
			if (pID == game.id) {
				myMonkey = newMonkey;
			}
			
			newMonkey.id = pID;
			newMonkey.x = newMonkey.trueX = info.getInt(1);
			newMonkey.y = newMonkey.trueY = info.getInt(2);
			newMonkey.bananas = info.getInt(3);
			
			newMonkey.inGame = info.getBoolean(4);
			newMonkey.username = info.getString(5);
			
			addObj(newMonkey);
			//newMonkey.sprite.gotoAndPlay("spawn");
			
			if (newMonkey.inGame) {
				players[pID] = newMonkey;
			} else {
				spectators[pID] = newMonkey;
				newMonkey.alpha = 0.4;
				
				if (newMonkey == myMonkey) {
					hud.statusTxt.text = "Test in progress. Wait until the next round starts.";
				}
			}
			numPlayers++;
		
		}
		
		// =======================================================================// 
		// Handle user left
		// =======================================================================//
		override public function userLeft(curMonkey:Monkey):void {
			for each (var chair:TagItem in chairs) {
				if (chair.monkey == curMonkey) {
					removeObj(chair);
					chairs.splice(chairs.indexOf(chair), 1);
					break;
				}
			}
		}
		
		// =======================================================================// 
		// Mouse Handler
		// =======================================================================//
		
		override public function handleTouch(e:TouchEvent):void {
			super.handleTouch(e);
			var touch:Touch = e.getTouch(stage, TouchPhase.BEGAN);
			if (touch) {
				var hit:Point = touch.getLocation(game);
				for (var i:uint = objContainer.numChildren - 1; i > 0; i--) {
					if (objContainer.getChildAt(i) is HitSprite) {
						var obj:HitSprite = objContainer.getChildAt(i) as HitSprite;
						if (obj.hitPoint(hit)) {
							if (obj is Bloon) {
								onClickBloon(obj as Bloon);
							} else if (obj is Chair) {
								onClickChair(obj as Chair);
							}
							break;
						}
					}
				}
			}
		}
		
		// =======================================================================// 
		// Balloon Handlers  
		// =======================================================================//
		private function handleSpawnBalloon(info:Message, bx:int, by:int, tag:int):void {
			if (myMonkey.inGame) {
				
				var newBalloon:Bloon = new Bloon(bx, by, tag, partyclePop);
				addObj(newBalloon);
				balloons.push(newBalloon);
			}
		}
		
		private function onClickBloon(bloon:Bloon):void {
			if (inRange(myMonkey, bloon, 75, 40) && bloon.canPop && myMonkey.stance != Monkey.PUNCH) {
				//freezeMonkey(myMonkey);
				bloon.readyPop();
				myMonkey.punch();
				connection.send("TryPop", bloon.tag);
			}
		}
		
		private function handleBalloonReady(info:Message, tag:int):void {
			if (myMonkey.inGame) {
				getBloon(tag).hitGround();
			}
		}
		
		private function handleUpdatePop(info:Message, tag:int,  isPop:Boolean):void {
			if (myMonkey.inGame) {
				getBloon(tag).confirmedPop = isPop;
			}
		}
		
		private function handlePopAction(info:Message, monkeyID:int, tag:int):void {
			if (myMonkey.inGame) {
				var popper:Monkey = getMonkey(monkeyID);
				var bloon:Bloon = getBloon(tag);
				popper.punch();
				bloon.readyPop();
				bloon.confirmedPop = true;
			}
		}
		
		private function getBloon(tag:int):Bloon {
			for each (var bloon:Bloon in balloons) {
				if (tag == bloon.tag) {
					return bloon;
					break;
				}
			}
			trace("Bloon not found!");
			return null;
		}
		
		private function partyclePop(bloon:Bloon):void {
			partycleSystem.x = bloon.x;
			partycleSystem.y = bloon.y;
			partycleSystem.start(0.3);
			
			balloons.splice(balloons.indexOf(bloon), 1);
			removeObj(bloon);
		}
		
		// =======================================================================// 
		// Chair handlers/methods
		// =======================================================================//
		
		private function onClickChair(chair:Chair):void {
			if (myMonkey.inGame) {
				if (inRange(myMonkey, chair, 75, 40)) {
					connection.send("ConfirmSit", chair.tag);
				}
			}
		}
		
		private function handleRemoveChair(info:Message, tag:int):void {
			if (myMonkey.inGame) {
				for each (var chair:Chair in chairs) {
					if (tag == chair.tag) {
						removeObj(chair);
						chairs.splice(chairs.indexOf(chair), 1);
						break;
					}
				}
			}
		}
		
		private function handleNewSit(info:Message, id:int, tag:int):void {
			if (myMonkey.inGame) {
				var curMonkey:Monkey = getMonkey(id);
				for each (var chair:Chair in chairs) {
					if (tag == chair.tag) {
						chair.monkey = curMonkey;
						curMonkey.x = curMonkey.trueX = chair.x;
						curMonkey.y = curMonkey.trueY = chair.y + 1;
						freezeMonkey(curMonkey);
						curMonkey.changeStance(Monkey.SIT);
						//curMonkey.getMC().y -= 30;
						curMonkey.bcSprite.visible = false;
						curMonkey.nameTxt.visible = false;
						
						doSort = true;
						if (curMonkey == myMonkey) {
							camMode = MOUSE;
							cam.zoomFocus(1.0);
						}
						
						break;
					}
				}
			}
		}
		
		// =======================================================================// 
		// Frame Update Methods    
		// =======================================================================//  
		override public function updateZone():void {
			if (hud && phase == "Waiting") {
				hud.pingTxt.text = "Ping " + game.ping + "ms";
				if (numPlayers < minPlayers && phase == "Waiting") {
					hud.statusTxt.text = "The experiment requires " + (minPlayers - numPlayers) + " more test subjects.";
				} else {
					hud.statusTxt.text = "Required test sample reached. Beginning the test.";
				}
			}
		}
		
		override public function updatePlayers(curPlayer:Monkey):void {
			
			updateMovement(curPlayer);
		
		}
		
		// =======================================================================// 
		// State Update Methods    
		// =======================================================================//  
		override public function handleStateUpdate(info:Message):void {
			//The time now
			var messageTime:Number = (new Date()).getTime();
			//The time since the last state update
			var localDiff:Number = messageTime - oldStateTime;
			if (oldStateTime == 0) {
				oldStateTime = (new Date()).getTime();
				return;
			}
			//Server tick (~120ms per update)
			var serverDiff:Number = info.getInt(0);
			
			for (var i:int = 0; i < (info.length - 1) / 3; i++) {
				var pID:int = info.getInt(i * 3 + 1);
				var trueX:int = info.getInt(i * 3 + 2);
				var trueY:int = info.getInt(i * 3 + 3);
				var curMonkey:Monkey = getMonkey(pID);
				
				curMonkey.trueX = trueX;
				curMonkey.trueY = trueY;
				
				interpolate(curMonkey, localDiff, serverDiff);
			}
			oldStateTime = ((oldStateTime + serverDiff) * 3 + (new Date()).getTime()) / 4;
		}
		
		// =======================================================================// 
		// Results Phase Methods      											  //        
		// =======================================================================//  
		private function handleResults(info:Message):void {
			if (myMonkey.inGame) {
				camMode = FIXED;
				freezeEveryone();
				phase = "Results";
				
				var monkeyA:Monkey = getMonkey(info.getInt(0));
				
				var tl:TimelineMax = new TimelineMax();
				cam.zoomFocus(1.0);
				tl.add(TweenLite.to(camPoint, 1.0, {y: 240, x: 1956, ease: Strong.easeOut}));
				tl.call(moveBlocks, [monkeyA]);
				tl.add(TweenLite.to(camPoint, 1.0, {x: 890, ease: Strong.easeInOut}), "+=1.5");
				tl.call(floorSmash, [monkeyA], "+=1.0");
				tl.call(postWait, [], "+=5.0");
				
			}
		}
		
		private function moveBlocks(monkeyA:Monkey):void {
			if (monkeyA.trueX < 650) {
				monkeyA.trueX = 650;
			} else if (monkeyA.trueX > 1150) {
				monkeyA.trueX = 1150;
			}
			TweenLite.to(monkeyA, 1.0, {x: monkeyA.trueX, ease: Strong.easeOut});
		}
		
		private function floorSmash(monkeyA:Monkey):void {
			monkeyA.smashed();
			setFire(monkeyA);
			//background.partyStage.gotoAndPlay("death");
			for each (var bloon:TagItem in balloons) {
				TweenMax.delayedCall(0.2, removeObj, [bloon]);
					//bloon.gotoAndPlay("pop");
			}
			cam.shake(0.1, 15);
			balloons = null;
		}
		
		private function postWait():void {
			hud.timerTxt.text = "";
			phase = "PostWait";
			camMode = MY_MONKEY;
			freeEveryone();
			connection.send("PostWait");
			cam.zoomFocus(1.25);
			for (var pID:String in players) {
				var curPlayer:Monkey = getMonkey(int(pID));
				curPlayer.changeStance(Monkey.STAND);
			}
			//transfer all spectators to game
			for (var pIDb:String in spectators) {
				var curSpectator:Monkey = getMonkey(int(pIDb));
				if (curSpectator != null) {
					curSpectator.inGame = true;
					curSpectator.alpha = 1.0;
					players[pIDb] = curSpectator;
					delete spectators[pIDb];
				}
			}
		}
		
		private function handleAdvanceRoom(info:Message):void {
			removeChildren();
			removeHandlers();
			
			game.curZone = new ChamberC(game, connection);
			game.curZone.addChildren();
		}
	}

}