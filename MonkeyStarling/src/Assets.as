package  
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Michael M
	 */
	public class Assets 
	{
		[Embed(source = "../assets/fonts/ChemReac_0.png")]
		public static const FontTexture:Class;
		[Embed(source = "../assets/fonts/ChemReac.fnt", mimeType = "application/octet-stream")]
		public static const FontXML:Class;
		
		[Embed(source="../assets/graphics/spriteSheet.png")]
		public static const AtlasTextureGame:Class;
		
		[Embed(source="../assets/graphics/spriteSheet.xml",mimeType="application/octet-stream")]
		public static const AtlasXmlGame:Class;
		
		
		public static const BUTTON_SCALE9_GRID:Rectangle = new Rectangle(5, 5, 50, 50);
		
		
		private static var gameTextures:Dictionary = new Dictionary();
		private static var gameTextureAtlas:TextureAtlas;
		
		public static function getFont():BitmapFont
		{
			var fontTexture:Texture = Texture.fromBitmap(new FontTexture());
			var fontXML:XML = XML(new FontXML());
			
			var font:BitmapFont = new BitmapFont(fontTexture, fontXML);
			TextField.registerBitmapFont(font);
			
			return font;
		}
		
		public static function getAtlas():TextureAtlas {
			if (gameTextureAtlas == null) {
				var texture:Texture = getTexture("AtlasTextureGame");
				var xml:XML = XML(new AtlasXmlGame());
				gameTextureAtlas = new TextureAtlas(texture, xml);
			}
			return gameTextureAtlas;
		}
		
		public static function getTexture(name:String):Texture {
			if (gameTextures[name] == undefined) {
				var bitmap:Bitmap = new Assets[name]();
				gameTextures[name] = Texture.fromBitmap(bitmap);
			}
			return gameTextures[name];
		}
		
	}

}