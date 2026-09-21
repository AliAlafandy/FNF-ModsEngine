package funkin.data.scripts;

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0")
import hxcodec.flixel.FlxVideoSprite as VideoSprite;
#elseif (hxCodec >= "2.6.1")
import hxCodec.VideoSprite as VideoSprite;
#elseif (hxCodec == "2.6.0")
import VideoSprite; // as VideoSprite
#else
import vlc.MP4Sprite as VideoSprite;
#end

class ModchartVideo extends VideoSprite
{
	public function new(?x:Float = 0, ?y:Float = 0)
	{
		super(x, y);
	}
}
#end
