package funkin.data.scripts;

#if VIDEOS_ALLOWED
import hxvlc.flixel.FlxVideoSprite as VideoSprite;

class ModchartVideo extends VideoSprite
{
	public function new(?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);
	}
}
#end
