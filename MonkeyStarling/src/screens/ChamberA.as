package screens {
	import com.greensock.easing.Strong;
	import com.greensock.TimelineMax;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import flash.geom.Rectangle;
	import objects.Monkey;
	import playerio.Connection;
	import playerio.Message;
	import starling.display.Image;
	import starling.text.TextField;
	import ui.HUD;
	import ui.TestInstr;
	import starling.utils.Color;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class ChamberA extends Zone {
		public var phase:String;
		public const minPlayers:int = 2;
		
		public const testDuration:int = 15000;
		public const redColor:int = 0x8A0000;
		public const blueColor:int = 0x17499B;
		public const whiteColor:int = 0xDFE2EE;
		
		public var blockA:Image = new Image(Assets.getAtlas().getTexture("movingBlock"));
		public var blockB:Image = new Image(Assets.getAtlas().getTexture("movingBlock"));
		
		public var leftSideX:Vector.<int> = Vector.<int>([-47, 412, 310, -47]);
		public var leftSideY:Vector.<int> = Vector.<int>([230, 230, 495, 495]);
		public var rightSideX:Vector.<int> = Vector.<int>([978, 1436, 1436, 1080]);
		public var rightSideY:Vector.<int> = Vector.<int>([230, 230, 495, 495]);
		
		public var serverCount:Number = 0;
		
		public function ChamberA(_game:Game, _connection:Connection) {
			
			hud = new HUD(new TestInstr("Test 1\nMinority Rule", "Be on the side with fewer monkeys."));
			bgImage = new Image(Assets.getAtlas().getTexture("bg_ChamberA"));
			bgImage.scaleX = bgImage.scaleY = 1.78;
			
			roomBounds = new Rectangle(0, 0, 1390, 480);
			
			roomPolyX = Vector.<int>([0, -182, 1512, 1512, -182, -182, 0, 178, 1212, 1396, 0, 178, 0]);
			roomPolyY = Vector.<int>([0, 124, 124, 600, 600, 124, 0, 240, 240, 480, 480, 240, 0]);
			
			super(_game, _connection);
		}
		
		override public function addChildren():void {
			super.addChildren();
			
			blockA.x = (roomBounds.width / 2) - (stage.stageWidth * 1.5);
			blockB.x = (roomBounds.width / 2) + (stage.stageWidth * 1.5);
			blockA.pivotX = blockB.pivotX = blockB.width;
			blockA.scaleX = blockA.scaleY = blockB.scaleX = blockB.scaleY = 2.0
			blockB.scaleX *= -1;
			
			blockB.y = blockA.y = 120;
			
			background.addChild(blockA);
			background.addChild(blockB);
		}
		
		override public function removeChildren():void {
			background.removeChild(blockA, true);
			background.removeChild(blockB, true);
			
			blockA = blockB = null;
			
			super.removeChildren();
		}
		override public function addHandlers():void {
			super.addHandlers();
			connection.addMessageHandler("RoomStart", handleRoomStart);
			connection.addMessageHandler("TestStart", handleTestStart);
			connection.addMessageHandler("Advance", handleAdvanceRoom);
		}
		override public function removeHandlers():void {
			super.removeHandlers();
			
			connection.removeMessageHandler("RoomStart", handleRoomStart);
			connection.removeMessageHandler("TestStart", handleTestStart);
			connection.removeMessageHandler("Advance", handleAdvanceRoom);
		}
		
		// =======================================================================// 
		// Init Methods    
		// =======================================================================//  
		private function handleRoomStart(info:Message):void {
			if (myMonkey.inGame) {
				var mid:int = roomBounds.width / 2;
				camMode = FIXED;
				freezeEveryone();
				
				hud.statusTxt.text = "";
				blockA.visible = true;
				blockB.visible = true;
				
				phase = "RoomStart";
				cam.zoomFocus(1.0);
				var tl:TimelineMax = new TimelineMax();
				tl.call(hud.instrSprite.animate);
				tl.add(TweenLite.to(camPoint, 1.0, {y: 240, x: mid, ease: Strong.easeInOut}));
				tl.add([TweenLite.to(blockA, 1.0, {delay: 0.5, visible: true, x: mid - 200, ease: Strong.easeOut}), TweenLite.to(blockB, 1.0, {delay: 0.5, visible: true, x: mid + 200, ease: Strong.easeOut})]);
				tl.add([TweenLite.to(blockA, 1.0, {x: "-500", ease: Strong.easeIn, visible: false}), TweenLite.to(blockB, 1.0, {x: "500", ease: Strong.easeIn, visible: false})]);
				
			}
		}
		
		private function handleTestStart(info:Message):void {
			if (myMonkey.inGame) {
				phase = "Testing";
				camMode = MY_MONKEY;
				freeEveryone();
				serverCount = testDuration;
				cam.zoomFocus(1.25);
			}
		}
		
		override public function handleInit(info:Message):void {
			var wVars:int = 2;
			var pVars:int = 10;
			//Get your ID and phase
			phase = info.getString(0);
			game.id = info.getInt(1);
			//myMonkey = players[info.getInt(1)];
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
				
				trace("name is: "+ newMonkey.username);
				
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
			if (phase == "Testing") {
				if (hitTest(leftSideX, leftSideY, curPlayer.trueX, curPlayer.trueY)) {
					if (curPlayer.team == 0) {
						curPlayer.team = 1;
						TweenMax.fromTo(curPlayer.getMC(), 1.5, {hexColors: {color: redColor}, ease: Strong.easeOut}, {hexColors: {color: 0xffffff}});
					}
				} else if (curPlayer.team == 1) {
					curPlayer.team = 0;
					TweenMax.fromTo(curPlayer.getMC(), 1.5, {hexColors: {color: whiteColor}, ease: Strong.easeOut}, {hexColors: {color: 0xffffff}});
				}
				
				if (hitTest(rightSideX, rightSideY, curPlayer.trueX, curPlayer.trueY)) {
					if (curPlayer.team == 0) {
						curPlayer.team = 2;
						
						TweenMax.fromTo(curPlayer.getMC(), 1.5, {hexColors: {color: blueColor}, ease: Strong.easeOut}, {hexColors: {color: 0xffffff}});
					}
				} else if (curPlayer.team == 2) {
					curPlayer.team = 0;
					TweenMax.fromTo(curPlayer.getMC(), 1.5, {hexColors: {color: whiteColor}, ease: Strong.easeOut}, {hexColors: {color: 0xffffff}});
				}
				
			}
			
			if (phase == "RoomStart") {
				if (blockA.x > curPlayer.x) {
					curPlayer.x = curPlayer.trueX = blockA.x;
				}
				if (blockB.x < curPlayer.x) {
					curPlayer.x = curPlayer.trueX = blockB.x;
				}
			}
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
			//Take the weighted average of the expected message time and actual message time to get the old time
			//This average is useful for adapting to systematic variations to latency
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
					
					//TweenLite.from(hud.timerTxt, 1.0, {scaleY: 1.2, tint: 0x8A0000, ease: Strong.easeOut});
					results();
				}
			}
		}
		
		// =======================================================================// 
		// Results Phase Methods      											  //        
		// =======================================================================//  
		private function results():void {
			if (myMonkey.inGame) {
				var mid:int = roomBounds.width / 2;
				
				camMode = FIXED;
				freezeEveryone();
				phase = "Results";
				
				cam.zoomFocus(1.0);
				
				var numMid:int = 0;
				var numRed:int = 0;
				var numBlue:int = 0;
				for (var pID:String in players) {
					var curMonkey:Monkey = Monkey(players[pID]);
					numMid += curMonkey.team == 0 ? 1 : 0;
					numRed += curMonkey.team == 1 ? 1 : 0;
					numBlue += curMonkey.team == 2 ? 1 : 0;
				}
				
				var tl:TimelineMax = new TimelineMax();
				tl.add(TweenLite.to(camPoint, 1.0, {y: 240, x: roomBounds.left + 360, ease: Strong.easeInOut, onComplete: showCount, onCompleteParams: [1, numRed, redColor]}));
				tl.call(rewardSide, [1], "+=0.5");
				tl.add(TweenLite.to(camPoint, 2.0, {x: roomBounds.right - 360, ease: Strong.easeInOut, onComplete: showCount, onCompleteParams: [2, numBlue, blueColor]}), "+=0.5");
				tl.call(rewardSide, [2], "+=0.5");
				tl.call(postWait, [], "+=0.5");
				
			}
		}
		
		private function showCount(side:int, count:int, clr:int):void {
			var countTxt:TextField = new TextField(100, 75, String(count), Assets.getFont().name, 50, clr);
			hud.addChild(countTxt);
			var mid:int = stage.stageWidth / 2;
			countTxt.x = mid + (side == 1 ? 100 : -100);
			countTxt.scaleX = 3.0
			countTxt.scaleY = 5.0;
			countTxt.x -= countTxt.width / 2;
			countTxt.y = stage.stageHeight / 2 - countTxt.height / 2;
			
			for (var pID:String in players) {
				var curMonkey:Monkey = Monkey(players[pID]);
				if (curMonkey.team == side) {
					TweenMax.fromTo(curMonkey.getMC(), 1.0, {hexColors: {color: clr}, ease: Strong.easeOut}, {hexColors: {color: 0xffffff}});
				}
			}
			
			TweenMax.to(countTxt, 1.0, {scaleY: 3.0, ease: Strong.easeOut});
			TweenMax.to(countTxt, 1.0, {delay: 1.5, alpha: 0, onComplete: hud.removeChild, onCompleteParams: [countTxt, true]});
		}
		
		private function rewardSide(side:int):void {
			if (myMonkey.team == side) {
				connection.send("RequestReward");
			}
		}
		
		private function postWait():void {
			hud.timerTxt.text = "";
			phase = "PostWait";
			camMode = MY_MONKEY;
			freeEveryone();
			connection.send("PostWait");
			cam.zoomFocus(1.25);
			//transfer all spectators to game
			for (var pID:String in spectators) {
				var curSpectator:Monkey = getMonkey(int(pID));
				if (curSpectator != null) {
					curSpectator.inGame = true;
					curSpectator.alpha = 1.0;
					players[pID] = curSpectator;
					delete spectators[pID];
				}
			}
		}
		
		private function handleAdvanceRoom(info:Message):void {
			removeChildren();
			removeHandlers();
			
			game.curZone = new ChamberB(game, connection);
			game.curZone.addChildren();
		}
	}

}