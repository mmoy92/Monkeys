package screens{
	import objects.Monkey;
	import playerio.Message;
	
	/**
	 * ...
	 * @author Michael M
	 */
	public interface ZoneBase {
		function addChildren():void;
		function removeChildren():void;
		function removeHandlers():void;
		
		function handleInit(info:Message):void;
		function handleNewJoin(info:Message):void;
		function handleUserLeft(info:Message):void;
		
		function update():void;
		function updateZone():void;
		function updateSpectators(curSpectator:Monkey):void;
		function updatePlayers(curPlayer:Monkey):void;
		function handleStateUpdate(info:Message):void;
	}
}