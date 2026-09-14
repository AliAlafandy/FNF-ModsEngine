package funkin.data.objects;

import flixel.FlxSprite;

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0")
import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1")
import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0")
import VideoHandler;
#else
import vlc.MP4Handler as VideoHandler;
#end
#end

class VideoSprite extends FlxSprite
{
	public var video:FlxVideo;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		video = new FlxVideo();
		video.alpha = 0;
	}

	public function play(path:String, loop:Bool = false)
	{
		video.play(Paths.video(path), loop);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(video.bitmapData != null)
			loadGraphic(video.bitmapData);
	}

	override function destroy()
	{
		video.dispose();
		super.destroy();
	}
}