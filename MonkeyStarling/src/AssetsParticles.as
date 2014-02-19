package {
	
	/**
	 * ...
	 * @author Michael M
	 */
	public class AssetsParticles {
		[Embed(source="../assets/graphics/particles/particleBurn.pex",mimeType="application/octet-stream")]
		public static var BurnicleXML:Class;
		
		[Embed(source="../assets/graphics/particles/particleSplode.pex",mimeType="application/octet-stream")]
		public static var SplodicleXML:Class;
		
		[Embed(source="../assets/graphics/particles/partycle.pex",mimeType="application/octet-stream")]
		public static var PartycleXML:Class;
		
		public function AssetsParticles() {
		
		}
	
	}

}