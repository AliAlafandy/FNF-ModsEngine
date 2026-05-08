package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public var grid:FlxBackdrop;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		if (ClientPrefs.data.lowQuality == false)
		{
			switch (ClientPrefs.data.themes) {
				case 'Mods Engine':
					grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x330000FF, 0x0));
					grid.velocity.set(40, 40);
					grid.alpha = 0;
					FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
					add(grid);
			
				case 'Vanilla (Normal)':
					grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
					grid.velocity.set(40, 40);
					grid.alpha = 0;
					FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
					add(grid);
			}
		}

		var guh:String;

		if (controls.mobileC)
		{
			guh = "Yoo, looks like you're running an   \n
			outdated version of Mods Engine (" + MainMenuState.modsEngineVersion + "),\n
			please update to " + TitleState.updateVersion + "!\n
			Press B to proceed anyway.\n
			\n
			Thank you for using the Port!";
		} else {
			guh = "Yoo, looks like you're running an   \n
			outdated version of Mods Engine (" + MainMenuState.modsEngineVersion + "),\n
			please update to " + TitleState.updateVersion + "!\n
			Press ESCAPE to proceed anyway.\n
			\n
			Thank you for using the Port!";
		}

		warnText = new FlxText(0, 0, FlxG.width, guh, 32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		#if mobile
		addTouchPad("NONE", "A_B");
		#end
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT)
			{
				leftState = true;
				CoolUtil.browserLoad("https://github.com/AliAlafandy/FNF-ModsEngine/releases");
			}
			else if(controls.BACK)
			{
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
