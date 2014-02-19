package {
	import flash.display.Sprite;
	import net.hires.debug.Stats;
	import screens.Login;
	import starling.core.Starling;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class Main extends Sprite {
		private var myStarling:Starling;
		
		public function Main():void {
			init();
			//addChild( new Stats() );
			
			
			
		
		}
		public function init():void {
			
			myStarling = new Starling(Game, stage);
			//myStarling.antiAliasing = 1;
			Starling.current.showStats = true;
			Starling.current.showStatsAt("left", "bottom", 2);
			myStarling.antiAliasing = 1;
			myStarling.start();
			
			
		}
	}

}