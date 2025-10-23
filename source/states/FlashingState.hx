package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	#if mobile
	var warnTextMobile:FlxText;
	#else
	var warnText:FlxText;
	#end
	
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		#if mobile
		var guhMobile:String = "Hey, watch out!\n
		This Mod contains some flashing lights!\n
		Press A to disable them now or go to Options Menu.\n
		Press B to ignore this message.\n
		You've been warned!";
		#else
		var guh:String = "Hey, watch out!\n
		This Mod contains some flashing lights!\n
		Press ENTER to disable them now or go to Options Menu.\n
		Press ESCAPE to ignore this message.\n
		You've been warned!";
		#end
		
		controls.isInSubstate = false; // qhar I hate it

		#if mobile
		warnTextMobile = new FlxText(0, 0, FlxG.width, guhMobile, 32);
		warnTextMobile.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnTextMobile.screenCenter(Y);
		add(warnTextMobile);
		#else
		warnText = new FlxText(0, 0, FlxG.width, guh, 32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
		#end

		#if mobile
		addTouchPad("NONE", "A_B");
		#end
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.data.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					#if mobile
					FlxFlicker.flicker(warnTextMobile, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
					#else
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
					#end
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					
					#if mobile
					FlxTween.tween(warnTextMobile, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
					#else
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
					#end
				}
			}
		}
		super.update(elapsed);
	}
}
