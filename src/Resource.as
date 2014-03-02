package  {
	import flash.display.Bitmap;
    import flash.utils.ByteArray;
	import flash.media.Sound;
	public class Resource {
		
		[Embed( source = "../resc/sky.png" )] public static var IMPORT_SKY:Class;
		[Embed( source = "../resc/city_bg.png" )] public static var IMPORT_CITY_BG:Class;
		[Embed( source = "../resc/city_fg.png" )] public static var IMPORT_CITY_FG:Class;
		[Embed( source = "../resc/cleaner_guy.png" )] public static var IMPORT_CLEANER_GUY:Class;
		
//floor1
		[Embed( source = "../resc/floor1/mainbldg_back.png" )] public static var IMPORT_FLOOR1_MAINBLDG_BACK:Class;
		[Embed( source = "../resc/floor1/mainbldg_glasscover.png" )] public static var IMPORT_FLOOR1_MAINBLDG_GLASSCOVER:Class;
		[Embed( source = "../resc/floor1/mainbldg_internal.png" )] public static var IMPORT_FLOOR1_MAINBLDG_INTERNAL:Class;
		[Embed( source = "../resc/floor1/mainbldg_window.png" )] public static var IMPORT_FLOOR1_MAINBLDG_WINDOW:Class;
		
	}
}