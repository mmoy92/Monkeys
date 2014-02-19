package {
	import com.greensock.TweenMax;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import playerio.BigDB;
	import playerio.Client;
	import playerio.Connection;
	import playerio.DatabaseObject;
	import playerio.Message;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	import playerio.RoomInfo;
	import screens.ChamberA;
	import screens.ChamberB;
	import screens.ChamberC;
	import screens.Login;
	import screens.Zone;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	import ui.HUD;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class Game extends Sprite {
		public var curZone:Zone;
		public static var connection:Connection;
		
		//Your userID
		public var myId:int = -1;
		//If the up key is pressed
		public var keyUp:Boolean = false;
		//If the down key is pressed
		public var keyDown:Boolean = false;
		//If the Right key is pressed
		public var keyRight:Boolean = false;
		//If the Left key is pressed
		public var keyLeft:Boolean = false;
		
		public var pingTimer:Timer;
		public var ping:int = 0;
		public var maxVel:Point = new Point(0.20, 0.20);
		
		private var screenLogin:Login;
		public var client:Client;
		
		public var id:int;
		public var username:String;
		
		public const version:String = "0.2.5";
		
		public function Game() {
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init():void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//this.addEventListener(NavigationEvent.CHANGE_SCREEN, onChangeScreen);
			
			//screenInGame = new InGame();
			//screenInGame.disposeTemporarily();
			//this.addChild(screenInGame);
			screenLogin = new Login(function(name:String):void {
					username = name;
					PlayerIO.connect(Starling.current.nativeStage, //Referance to stage
						"monkey-experiment-8xnxqylgceowk0bhpvwjg", //Game id (Get your own at playerio.com)
						"public", //Connection id, default is public
						"Guest", //Username
						"", //User auth. Can be left blank if authentication is disabled on connection
						null, //Current PartnerPay partner.
						handleConnect, //Function executed on successful connect
						handleError //Function executed if we recive an error
						);
				});
			this.addChild(screenLogin);
			screenLogin.numPlayersTxt.text = "v" + version;
			screenLogin.setName("Subject");
			//screenWelcome.initialize();
		}
		
		private function handleConnect(client:Client):void {
			this.client = client;
			
			BigDB(client.bigDB).load("World", "Stats", function(obj:DatabaseObject):void {
					if (obj != null) {
						if (username == "Subject") {
							screenLogin.setName("Subject " + obj.NumCreated);
						}
					}
				});
			
			//Set developmentsever (Comment out to connect to your server online)
			//client.multiplayer.developmentServer = "localhost:8184";
			
			client.multiplayer.listRooms("GameRoom", {}, 50, 0, loadRooms);
		
		}
		
		private function loadRooms(rooms:Array):void {
			var numPlayers:int = 0;
			for (var a:int = 0; a < rooms.length; a++) {
				var curRoom:RoomInfo = RoomInfo(rooms[a]);
				numPlayers += curRoom.onlineUsers;
			}
			if (numPlayers == 0) {
				client.multiplayer.createRoom("TestRoomA", //Room id. If set to null a random roomid is used
					"GameRoom", //The game type started on the server
					true, //Should the room be visible in the lobby?
					{} //Room data. This data is returned to lobby list. Variabels can be modifed on the server
					);
					//Create pr join the room test
			}
			var populationMsg:String = "Connected to server!\n" + rooms.length + " Experiments" + "\n" + numPlayers + " Test Subjects";
			
			screenLogin.success(function():void {
					client.multiplayer.joinRoom("TestRoomA", {}, handleJoin, //Function executed on successful joining of the room
						handleError //Function executed if we got a join error 
						);
				}, populationMsg);
		}
		
		private function handleError(error:PlayerIOError):void {
			screenLogin.fail();
		}
		
		private function handleJoin(connection:Connection):void {
			username = screenLogin.inputTxt.text;
			removeChild(screenLogin, true);
			
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			Starling.current.nativeStage.addEventListener(flash.events.Event.ACTIVATE, handleActivate);
			Starling.current.nativeStage.addEventListener(flash.events.Event.DEACTIVATE, handleDeactivate);
			
			connection.send("NameUpdate", username);
			
			curZone = new ChamberA(this, connection);
			curZone.addChildren();
			
			pingTimer = new Timer(5000);
			pingTimer.addEventListener(TimerEvent.TIMER, sendPing);
			pingTimer.start();
			
			Game.connection = connection;
			
			connection.addDisconnectHandler(handleDisconnect);
			//connection.addMessageHandler("ChatMessage", function(m:Message, msg:String):void {});
			connection.addMessageHandler("Pong", handlePong);
			connection.addMessageHandler("NameUpdate", handleNewName);
			connection.addMessageHandler("*", handleMessages);
		}
		
		private function handleNewName(m:Message, id:int, name:String):void {
			curZone.getMonkey(id).username = name;
		}
		
		private function sendPing(e:TimerEvent):void {
			connection.send("Ping", (new Date()).getTime());
		}
		
		private function handlePong(m:Message, timeStamp:int):void {
			ping = (new Date()).getTime() - timeStamp;
			connection.send("PingUpdate", ping);
		}
		
		private function handleRightClick(e:MouseEvent):void {
		}
		
		private function handleActivate(e:flash.events.Event):void {
		}
		
		private function handleDeactivate(e:flash.events.Event):void {
			if (curZone) {
				curZone.handleDeactivate();
			}
		}
		
		private function handleKeyUp(e:KeyboardEvent):void {
			if (curZone.myMonkey) {
				if (e.keyCode == 87 || e.keyCode == 38 && keyUp) {
					connection.send("uUp");
					keyUp = false;
				}
				if (e.keyCode == 83 || e.keyCode == 40 && keyDown) {
					connection.send("dUp");
					keyDown = false;
				}
				if (e.keyCode == 68 || e.keyCode == 39 && keyRight) {
					connection.send("rUp");
					keyRight = false;
				}
				if (e.keyCode == 65 || e.keyCode == 37 && keyLeft) {
					connection.send("lUp");
					keyLeft = false;
				}
				if (e.keyCode == 32) {
					curZone.ghostMonkey.alpha = curZone.ghostMonkey.alpha == 0.5 ? 0.0 : 0.5;
				}
			}
		}
		
		private function handleKeyDown(e:KeyboardEvent):void {
			if (curZone.myMonkey) {
				if (e.keyCode == 87 || e.keyCode == 38 && !keyUp) {
					connection.send("uDown");
					keyUp = true;
				}
				if (e.keyCode == 83 || e.keyCode == 40 && !keyDown) {
					connection.send("dDown");
					keyDown = true;
				}
				if (e.keyCode == 68 || e.keyCode == 39 && !keyRight) {
					connection.send("rDown");
					keyRight = true;
				}
				if (e.keyCode == 65 || e.keyCode == 37 && !keyLeft) {
					connection.send("lDown");
					keyLeft = true;
				}
			}
		}
		
		public function handleEnterFrame(e:Event):void {
			curZone.update();
		}
		
		private function handleMessages(m:Message):void {
			//trace("Received ", m);
			//trace(m.type);
		}
		
		private function handleDisconnect():void {
			trace("Disconnected from server");
			if (curZone) {
				curZone.cam.destroy();
				curZone.removeChildren();
				curZone.removeHandlers();
				TweenMax.killAll();
				curZone = null;
			}
			removeHandlers();
			init();
		}
		
		private function removeHandlers():void {
			//nStage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			stage.removeEventListener(flash.events.Event.ACTIVATE, handleActivate);
			stage.removeEventListener(flash.events.Event.DEACTIVATE, handleDeactivate);
			
			connection.removeDisconnectHandler(handleDisconnect);
			//connection.addMessageHandler("ChatMessage", function(m:Message, msg:String):void {});
			connection.removeMessageHandler("Pong", handlePong);
			connection.removeMessageHandler("NameUpdate", handleNewName);
			connection.removeMessageHandler("*", handleMessages);
		}
		//private function onChangeScreen(e:NavigationEvent):void {
		//switch (e.params.id) {
		//case "play":
		//screenWelcome.disposeTemporarily();
		//screenInGame.initialize();
		//break;
		//}
		//}
	
	}

}