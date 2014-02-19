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
	import objects.Dagger;
	import objects.DepositBin;
	import objects.HitSprite;
	import objects.Monkey;
	import objects.TagItem;
	import playerio.Connection;
	import playerio.Message;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.PDParticleSystem;
	import starling.filters.ColorMatrixFilter;
	import starling.text.TextField;
	import starling.textures.Texture;
	import ui.HUD;
	import ui.TestInstr;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class ChamberC extends Zone {
		public var phase:String = "Waiting";
		public const minPlayers:int = 2;
		private var reds:Vector.<Monkey> = new Vector.<Monkey>();
		private var blues:Vector.<Monkey> = new Vector.<Monkey>();
		public var redSum:int = 0;
		public var blueSum:int = 0;
		private var winner:uint = 0;
		public var redTXT:TextField;
		public var blueTXT:TextField;
		public var donateA:Button;
		public var donateB:Button;
		public var binA:DepositBin;
		public var binB:DepositBin;
		
		public const testDuration:int = 15000;
		public var serverCount:Number = 0;
		
		public var dagger:Dagger;
		
		public function ChamberC(_game:Game, _connection:Connection) {
			hud = new HUD(new TestInstr("Test 3\nFreeriders", "Donate more bananas than the other side."));
			bgImage = new Image(Assets.getAtlas().getTexture("bg_ChamberC"));
			bgImage.y -= 223;
			bgImage.scaleX = bgImage.scaleY = 2.0;
			
			roomBounds = new Rectangle(2, -178, 1657, 655);
			
			roomPolyX = Vector.<int>([0, 1833, 1833, -180, -180, 1833, 0, 1, 762, 763, 695, 695, 592, 590, 132, 1, 0, 900, 1661, 1535, 1068, 1069, 967, 968, 900, 900, 0]);
			roomPolyY = Vector.<int>([0, 602, 126, 126, 602, 602, 0, 476, 478, 245, 244, 270, 270, 245, 244, 476, 0, 479, 478, 245, 244, 270, 271, 244, 244, 479, 0]);
			
			super(_game, _connection);
		
		}
		
		// =======================================================================// 
		// Level setup
		// =======================================================================//
		override public function addChildren():void {
			super.addChildren();
			redTXT = new TextField(178, 200, "?", Assets.getFont().name, 96, 0xFF0000);
			blueTXT = new TextField(178, 200, "?", Assets.getFont().name, 96, 0x0000FF);
			
			redTXT.x = 555;
			blueTXT.x = 930;
			redTXT.y = blueTXT.y = -60;
			
			background.addChild(redTXT);
			background.addChild(blueTXT);
			
			donateA = new Button(Assets.getAtlas().getTexture("donateBtn_up"), "+1", Assets.getAtlas().getTexture("donateBtn_down"));
			donateB = new Button(Assets.getAtlas().getTexture("donateBtn_up"), "+5", Assets.getAtlas().getTexture("donateBtn_down"));
			
			donateA.fontSize = 30;
			donateA.textBounds = new Rectangle(-15, -5, 70, 50);
			donateA.fontName = Assets.getFont().name;
			
			donateB.fontSize = 30;
			donateB.textBounds = new Rectangle(-15, -5, 70, 50);
			donateB.fontName = Assets.getFont().name;
			
			background.addChild(donateA);
			background.addChild(donateB);
			
			binA = new DepositBin();
			binB = new DepositBin();
			
			var clrFilter:ColorMatrixFilter = new ColorMatrixFilter();
			clrFilter.adjustHue(0.5);
			binA.img.filter = clrFilter;
			
			binA.x = 641;
			binB.x = 1019;
			binA.y = binB.y = 265;
			
			background.addChild(binA);
			background.addChild(binB);
		}
		
		override public function removeChildren():void {
			super.removeChildren();
		
		}
		
		override public function addHandlers():void {
			super.addHandlers();
			
			connection.addMessageHandler("RoomStart", handleRoomStart);
			connection.addMessageHandler("TestStart", handleTestStart);
			connection.addMessageHandler("TweenCount", handleTweenCount);
			
			connection.addMessageHandler("Results", handleResults);
			connection.addMessageHandler("JudgeResults", handleJudge);
			connection.addMessageHandler("DaggerReady", handleDaggerReady);
			connection.addMessageHandler("DaggerTaken", handleDaggerTaken);
			connection.addMessageHandler("DaggerFail", handleDaggerFail);
			
			connection.addMessageHandler("PostWait", handlePostWait);
			connection.addMessageHandler("AdvanceC", handleAdvanceRoom);
		}
		
		override public function removeHandlers():void {
			super.removeHandlers();
			
			connection.removeMessageHandler("RoomStart", handleRoomStart);
			connection.removeMessageHandler("TestStart", handleTestStart);
			connection.removeMessageHandler("TweenCount", handleTweenCount);
			
			connection.removeMessageHandler("Results", handleResults);
			connection.removeMessageHandler("JudgeResults", handleJudge);
			connection.removeMessageHandler("DaggerReady", handleDaggerReady);
			connection.removeMessageHandler("DaggerTaken", handleDaggerTaken);
			connection.removeMessageHandler("DaggerFail", handleDaggerFail);
			connection.removeMessageHandler("PostWait", handlePostWait);
			connection.removeMessageHandler("AdvanceC", handleAdvanceRoom);
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
				cam.zoomFocus(0.75);
				
				var tl:TimelineMax = new TimelineMax();
				tl.call(hud.instrSprite.animate);
				tl.add(TweenLite.to(camPoint, 1.5, {y: 148, x: 837, ease: Strong.easeInOut}));
				
			}
		}
		
		private function handleTestStart(info:Message):void {
			if (myMonkey.inGame) {
				phase = "Testing";
				camMode = MY_MONKEY;
				
				serverCount = testDuration;
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
				
				newMonkey.deathFunc = deathFunc;
				if (newMonkey.inGame) {
					players[pID] = newMonkey;
				} else {
					spectators[pID] = newMonkey;
					newMonkey.alpha = 0.5;
				}
				
				addObj(newMonkey);
				newMonkey.bcSprite.visible = false;
				
				numPlayers++;
			}
			doSort = true;
		}
		
		// =======================================================================// 
		// Init donate buttons
		// =======================================================================//
		private function initDonateButtons():void {
			if (myMonkey.team == 1) {
				donateA.x = donateB.x = 500;
			} else {
				donateA.x = donateB.x = 1093;
			}
			donateA.y = 12;
			donateB.y = 76;
			donateA.visible = donateB.visible = false;
			donateA.addEventListener(Event.TRIGGERED, donateOne);
			donateB.addEventListener(Event.TRIGGERED, donateFive);
		}
		
		private function donateOne(e:Event):void {
			connection.send("Donate", 1);
			donateA.y = -4;
			TweenMax.to(donateA, 0.5, {y: 12, ease: Strong.easeOut});
		
		}
		
		private function donateFive(e:Event):void {
			connection.send("Donate", 5);
			donateB.y = 60;
			TweenMax.to(donateB, 0.5, {y: 76, ease: Strong.easeOut});
		}
		
		private function handleTweenCount(info:Message, team:int):void {
			var txt:TextField = team == 1 ? redTXT : blueTXT;
			TweenMax.killTweensOf(txt);
			txt.y = -65;
			TweenMax.to(txt, 0.5, {y: -60, ease: Strong.easeOut});
		}
		
		// =======================================================================// 
		// Join Method 
		// =======================================================================//  
		override public function handleNewJoin(info:Message):void {
			
			//Get new player's id
			var pID:int = info.getInt(0);
			var newMonkey:Monkey = new Monkey();
			//Set him at the given x and y with all default properties
			
			newMonkey.id = pID;
			newMonkey.x = newMonkey.trueX = info.getInt(1);
			newMonkey.y = newMonkey.trueY = info.getInt(2);
			newMonkey.bananas = info.getInt(3);
			newMonkey.inGame = info.getBoolean(4);
			newMonkey.username = info.getString(5);
			
			newMonkey.deathFunc = deathFunc
			addObj(newMonkey);
			newMonkey.bcSprite.visible = false;
			
			if (newMonkey.inGame) {
				players[pID] = newMonkey;
				if (newMonkey.x < 820) {
					newMonkey.team = 1;
					reds.push(newMonkey);
				} else {
					newMonkey.team = 2;
					blues.push(newMonkey);
				}
			} else {
				spectators[pID] = newMonkey;
				newMonkey.alpha = 0.4;
				
				if (newMonkey == myMonkey) {
					hud.statusTxt.text = "Test in progress. Wait until the next round starts.";
				}
			}
			if (pID == game.id) {
				myMonkey = newMonkey;
				myMonkey.bcSprite.visible = true;
				initDonateButtons();
			}
			numPlayers++;
		
		}
		
		// =======================================================================// 
		// Handle user left
		// =======================================================================//
		override public function userLeft(curMonkey:Monkey):void {
			super.userLeft(curMonkey);
			if (curMonkey.team == 1) {
				reds.splice(reds.indexOf(curMonkey), 1);
			} else if (curMonkey.team == 2) {
				reds.splice(blues.indexOf(curMonkey), 1);
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
				for (var i:int = objContainer.numChildren - 1; i >= 0; i--) {
					if (objContainer.getChildAt(i) is HitSprite) {
						var obj:HitSprite = objContainer.getChildAt(i) as HitSprite;
						if (obj.hitPoint(hit)) {
							if (obj is Dagger) {
								onClickDagger();
							} else if (obj is Monkey) {
								trace("got monkey touch")
								onClickMonkey(obj as Monkey);
							}
							break;
						}
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
			if (phase == "Testing") {
				if (myMonkey.team == 1 && inRange(myMonkey, binA, 125, 50)) {
					donateA.visible = myMonkey.bananas >= 1;
					donateB.visible = myMonkey.bananas >= 5;
				} else if (myMonkey.team == 2 && inRange(myMonkey, binB, 125, 50)) {
					donateA.visible = myMonkey.bananas >= 1;
					donateB.visible = myMonkey.bananas >= 5;
				} else {
					donateA.visible = donateB.visible = false;
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
			
			if (phase == "Testing") {
				updateTimer(serverDiff);
			}
			
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
		
		private function updateTimer(serverStep:int):void {
			if (myMonkey.inGame) {
				serverCount -= serverStep;
				var seconds:int = Math.floor(serverCount / 1000);
				var centi:int = serverCount % 100;
				
				hud.timerTxt.text = String(seconds) + ".";
				
				if (centi < 10) {
					hud.timerTxt.text += "0";
				}
				hud.timerTxt.text += String(centi);
				
				if (serverCount <= 0) {
					hud.timerTxt.text = "0.00";
				}
			}
		}
		
		// =======================================================================// 
		// Results Phase Methods      											  //        
		// =======================================================================//  
		private function handleResults(info:Message, _redSum:int, _blueSum:int):void {
			if (myMonkey.inGame) {
				camMode = FIXED;
				freezeEveryone();
				phase = "Results";
				hud.timerTxt.text = "";
				
				redSum = _redSum;
				blueSum = _blueSum;
				donateA.visible = donateB.visible = false;
				
				winner = redSum == blueSum ? 0 : (redSum > blueSum ? 1 : 2);
				
				var tl:TimelineMax = new TimelineMax();
				cam.zoomFocus(0.75);
				tl.add(TweenLite.to(camPoint, 1.5, {y: 148, x: 837, ease: Strong.easeInOut}));
				tl.call(showWinner);
				
			}
		}
		
		private function showWinner():void {
			var txt:TextField;
			if (winner == 0) {
				txt = new TextField(310, 300, "Equal", Assets.getFont().name, 40, 0x620062);
			} else {
				txt = new TextField(310, 300, "Failure", Assets.getFont().name, 40, 0x620062);
			}
			hud.addChild(txt);
			var mid:Number = hud.width / 2 - txt.width / 2;
			txt.x = winner == 0 ? mid : (winner == 2 ? mid - 157 : mid + 157);
			txt.scaleY = 2.0;
			txt.hAlign = "center";
			
			redTXT.text = "" + redSum;
			blueTXT.text = "" + blueSum;
			
			var losers:Vector.<Monkey> = redSum == blueSum ? null : (redSum > blueSum ? blues : reds);
			if (losers) {
				for each (var loser:Monkey in losers) {
					TweenMax.fromTo(loser.getMC(), 1.0, {hexColors: {color: 0x620062}, ease: Strong.easeOut}, {hexColors: {color: 0xffffff}});
				}
			}
			
			var tl:TimelineMax = new TimelineMax();
			tl.add(TweenMax.to(txt, 1.0, {scaleY: 1.0, ease: Strong.easeOut}));
			tl.add(TweenMax.to(txt, 1.0, {delay: 1.5, alpha: 0, onComplete: hud.removeChild, onCompleteParams: [txt, true]}));
		
		}
		
		private function handleJudge(info:Message):void {
			var result:uint = info.getUInt(0);
			if (result == 0) {
				//Kill everyone
				for (var pID:String in players) {
					var curMonkey:Monkey = Monkey(players[pID]);
					curMonkey.smashed();
					setFire(curMonkey);
					
				}
				cam.shake(0.2, 15);
			} else if (result == 1) {
				var _x:int = info.getInt(1);
				var _y:int = info.getInt(2);
				var tag:int = info.getInt(3);
				
				if (myMonkey.team == winner) {
					camMode = MOUSE;
				} else {
					camMode = MY_MONKEY;
					cam.zoomFocus(1.0);
				}
				myMonkey.bcSprite.visible = false;
				
				freeEveryone();
				phase = "Elimination";
				
				dagger = new Dagger(_x, _y, tag);
				
				addObj(dagger);
			} else {
				//Kill noob
				var nub:Monkey = getMonkey(info.getInt(1));
				trace("kill request for " + nub)
				nub.smashed();
				setFire(nub);
				cam.shake(0.1, 15);
			}
		
		}
		
		// =======================================================================// 
		// Dagger methods
		// =======================================================================//
		private function onClickDagger():void {
			if (inRange(myMonkey, dagger, 75, 40) && dagger.canTake) {
				connection.send("ConfirmDagger");
				dagger.tryTake();
			}
		}
		
		private function handleDaggerReady(info:Message):void {
			if (myMonkey.inGame) {
				dagger.readyGround();
			}
		}
		
		private function handleDaggerTaken(info:Message, id:int):void {
			if (myMonkey.inGame) {
				getMonkey(id).weapon = "dagger";
				removeObj(dagger);
				dagger = null;
				
				var dagIcon:Image = new Image(Assets.getAtlas().getTexture("dagger"));
				getMonkey(id).addChild(dagIcon);
				dagIcon.x = -dagIcon.width / 2;
				dagIcon.y = -150;
			}
		}
		
		private function handleDaggerFail(info:Message):void {
			if (myMonkey.inGame) {
				if (dagger) {
					dagger.cancelTake();
				}
			}
		}
		
		private function onClickMonkey(monkey:Monkey):void {
			if (myMonkey.weapon == "dagger" && inRange(myMonkey, monkey, 75, 40) && myMonkey != monkey && myMonkey.stance != Monkey.PUNCH) {
				trace("sent stab to " + monkey.id);
				connection.send("Stab", monkey.id);
				myMonkey.punch();
				monkey.readyDie();
			}
		}
		
		private function deathFunc(monkey:Monkey):void {
			setFire(monkey);
			monkey.smashed();
			cam.shake(0.1, 15);
		}
		
		// =======================================================================// 
		// Post-test methods
		// =======================================================================//
		private function handlePostWait(info:Message):void {
			hud.timerTxt.text = "";
			phase = "PostWait";
			camMode = MY_MONKEY;
			freeEveryone();
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
			
			game.curZone = new ChamberA(game, connection);
			game.curZone.addChildren();
		}
	}

}