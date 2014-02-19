package screens {
	import feathers.controls.Button;
	import feathers.controls.text.StageTextTextEditor;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	import feathers.core.ITextEditor;
	import feathers.display.Scale9Image;
	import feathers.text.BitmapFontTextFormat;
	import feathers.textures.Scale9Textures;
	import feathers.themes.AeonDesktopTheme;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import objects.ConnectSprite;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class Login extends Sprite {
		public var inputTxt:TextInput;
		public var numPlayersTxt:TextArea;
		private var button:Button;
		
		private var connectSprite:ConnectSprite;
		
		private var isJoining:Boolean = false;
		private var state:String;
		private var callBack:Function;
		private var joinFunc:Function;
		
		private const BASE_Y:int = 150;
		
		public function Login(callBack:Function) {
			super();
			this.callBack = callBack;
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			new AeonDesktopTheme();
			
			state = "Connect";
			
			
			addInputTxt();
			addNumPlayersTxt();
			addButton();
			addConnectSprite();
		
		}
		// =======================================================================// 
		// Handlers
		// =======================================================================//
		
		public function success(func:Function, roomStats:String):void {
			state = "Join";
			button.label = "Join";
			joinFunc = func;
			numPlayersTxt.text = roomStats;
			connectSprite.successAnimation();
		}
		public function fail():void {
			state = "Retry";
			button.label = "Retry";
			numPlayersTxt.text = "Connection failure."
			connectSprite.failAnimation();
		}
		public function setName(newName:String):void {
			inputTxt.text = newName;
		}
		// =======================================================================// 
		// Connect Sprite
		// =======================================================================//
		private function addConnectSprite():void {
			connectSprite = new ConnectSprite();
			connectSprite.x = stage.stageWidth / 2 - connectSprite.width / 2;
			connectSprite.y = stage.stageHeight / 2 + 25;
			addChild(connectSprite);
		}
		
		// =======================================================================// 
		// Num Players Text
		// =======================================================================//
		private function addNumPlayersTxt():void {
			numPlayersTxt = new TextArea();
			numPlayersTxt.text = "";
			numPlayersTxt.isEditable = false;
			numPlayersTxt.isEnabled = false;
			numPlayersTxt.width = 200;
			numPlayersTxt.height = 75;
			numPlayersTxt.x = stage.stageWidth / 2 - numPlayersTxt.width/2;
			numPlayersTxt.y = BASE_Y + 150;
			
			addChild(numPlayersTxt);
		}
		
		// =======================================================================// 
		// Button
		// =======================================================================//
		private function addButton():void {
			button = new Button();
			button.label = "Connect";
			
			button.width = 200;
			button.height = 25;
			button.x = stage.stageWidth / 2 - button.width / 2;
			button.y = BASE_Y + button.height + 1;
			
			button.defaultLabelProperties.textFormat = new BitmapFontTextFormat(Assets.getFont().name, 15);
			button.addEventListener(Event.TRIGGERED, onClick);
			this.addChild(button);
		}
		
		private function onClick(e:Event):void {
			
			switch (state) {
				case "Connect": 
					if (inputTxt.text != "") {
						connectSprite.tryAnimation();
						callBack(inputTxt.text);
					}
					break;
				case "Join":
					if (inputTxt.text != "") {
						connectSprite.tryAnimation();
						state = "Joining";
						joinFunc();
					}
					break;
				case "Retry":
					if (inputTxt.text != "") {
						connectSprite.tryAnimation();
						state = "Joining";
						callBack(inputTxt.text);
					}
					break;
				
			}
		}
		
		// =======================================================================// 
		// Input
		// =======================================================================//
		private function addInputTxt():void {
			inputTxt = new TextInput();
			inputTxt.text = "Subject";
			inputTxt.width = 200;
			inputTxt.height = 25;
			inputTxt.x = stage.stageWidth / 2 - inputTxt.width / 2;
			inputTxt.y = BASE_Y;
			inputTxt.textEditorFactory = function():ITextEditor {
				var editor:StageTextTextEditor = new StageTextTextEditor();
				editor.fontFamily = "Arial";
				editor.fontSize = 15;
				//editor.color = 0xFFFFFF;
				editor.textAlign = "center";
				return editor;
			}
			
			this.addChild(inputTxt);
		}
	
	}

}