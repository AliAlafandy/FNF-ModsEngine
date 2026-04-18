package objects;

import flixel.graphics.frames.FlxAtlasFrames;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var isAnimated:Bool = false;
	
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	private var iconOffsets:Array<Float> = [0, 0];

	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function changeIcon(char:String, ?allowGPU:Bool = true)
	{
		if (this.char == char)
			return;

		this.char = char;
		isAnimated = false;

		var baseName:String = 'icons/' + char;
		var iconPath:String = 'images/' + baseName + '.png';
		var xmlPath:String = 'images/' + baseName + '.xml';

		if (!Paths.fileExists(iconPath, IMAGE))
			baseName = 'icons/icon-' + char;
		if (!Paths.fileExists('images/' + baseName + '.png', IMAGE))
			baseName = 'icons/icon-face';

		if (Paths.fileExists('images/' + baseName + '.xml', TEXT))
		{
			isAnimated = true;
			frames = Paths.getSparrowAtlas(baseName, allowGPU);

			if (frames.getByName("idle0000") != null)
				animation.addByPrefix("idle", "idle", 24, true);
			if (frames.getByName("losing0000") != null)
				animation.addByPrefix("losing", "losing", 24, true);
			if (frames.getByName("winning0000") != null)
				animation.addByPrefix("winning", "winning", 24, true);

			if (animation.exists("idle"))
				animation.play("idle");

			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (height - 150) / 2;
		} else {
			var graphic = Paths.image(baseName, allowGPU);

			var frameWidth:Int = Math.floor(graphic.height);
			var frameCount:Int = Math.floor(graphic.width / frameWidth);
			if (frameCount < 2) frameCount = 2;

			loadGraphic(graphic, true, frameWidth, Math.floor(graphic.height));

			var frameArray:Array<Int> = [];
			for (i in 0...frameCount)
				frameArray.push(i);

			animation.add(char, frameArray, 0, false, isPlayer);
			animation.play(char);

			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (height - 150) / 2;
		}

		if (char.endsWith('-pixel'))
			antialiasing = false;
		else
			antialiasing = ClientPrefs.data.antialiasing;
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String
	{
		return char;
	}

	public function playAnimation(name:String)
	{
		if (isAnimated && animation.exists(name))
			animation.play(name);
	}
}
