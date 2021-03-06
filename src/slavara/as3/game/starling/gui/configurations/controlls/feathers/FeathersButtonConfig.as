package slavara.as3.game.starling.gui.configurations.controlls.feathers {
	import feathers.text.BitmapFontTextFormat;
	import feathers.textures.Scale3Textures;
	import slavara.as3.core.enums.BaseEnum;
	import slavara.as3.game.starling.gui.configurations.controlls.StarlingButtonConfig;
	
	/**
	 * @author SlavaRa
	 */
	public class FeathersButtonConfig extends StarlingButtonConfig {
		
		public function FeathersButtonConfig() {
			super();
			super.width = 0;
			super.height = 0;
			useHandCursor = true;
			label = "";
		}
		
		public var texDefaultIcon:BaseEnum;
		public var texDefaultSkin:BaseEnum;
		public var texHoverSkin:BaseEnum;
		public var label:String;
		public var textFormat:BitmapFontTextFormat;
		public var scale3texDefaultSkin:Scale3Textures;
		public var scale3texHoverSkin:Scale3Textures;
		
	}
}