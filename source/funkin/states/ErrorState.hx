package funkin.states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class ErrorState extends MusicBeatState
{
	public var acceptCallback:Void->Void;
	public var backCallback:Void->Void;
	public var errorMsg:String;

	public function new(error:String, accept:Void->Void = null, back:Void->Void = null)
	{
		this.errorMsg = error;
		this.acceptCallback = accept;
		this.backCallback = back;

		super();
	}

	public var errorSine:Float = 0;
	public var errorText:FlxText;
	override function create()
	{
		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));

		switch (ClientPrefs.data.themes) {
			case "Mods Engine":
				bg.color = 0xFF000080;

			case "Vanilla (Normal)":
				bg.color = FlxColor.GRAY;
		}
		
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		if (ClientPrefs.data.lowQuality == false)
		{
			var grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
			grid.velocity.set(40, 40);
			grid.alpha = 0;
			FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
			add(grid);
		}

		errorText = new FlxText(0, 0, FlxG.width - 300, errorMsg, 32);
		errorText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		errorText.scrollFactor.set();
		errorText.borderSize = 2;
		errorText.screenCenter();
		add(errorText);
		super.create();

		#if mobile
		addTouchPad('NONE', 'A_B');
		addTouchPadCamera();
		#end
	}

	override function update(elapsed:Float)
	{
		errorSine += 180 * elapsed;
		errorText.alpha = 1 - Math.sin((Math.PI * errorSine) / 180);

		if(controls.ACCEPT && acceptCallback != null)
			acceptCallback();
		else if(controls.BACK && backCallback != null)
			backCallback();

		super.update(elapsed);
	}
}
