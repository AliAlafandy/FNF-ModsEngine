package objects;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import backend.Paths;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	private var isAnimated:Bool = false;

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

		// Try fallback paths
		if (!Paths.fileExists(iconPath, IMAGE))
			baseName = 'icons/icon-' + char;
		if (!Paths.fileExists('images/' + baseName + '.png', IMAGE))
			baseName = 'icons/icon-face';

		// --- Check if XML exists (animated icon support) ---
		if (Paths.fileExists('images/' + baseName + '.xml', TEXT))
		{
			// Animated icon
			isAnimated = true;
			frames = Paths.getSparrowAtlas(baseName, allowGPU);

			// 🔹 Add flexible animation prefix matching
			var hasIdle = false;
			var hasLosing = false;
			var hasWinning = false;

			// Try all common name styles automatically
			for (anim in ['idle', 'icon idle'])
			{
				if (frames.getByName(anim + '0000') != null || frames.getByName(anim) != null)
				{
					animation.addByPrefix('idle', anim, 24, true);
					hasIdle = true;
					break;
				}
			}
			for (anim in ['losing', 'icon lose'])
			{
				if (frames.getByName(anim + '0000') != null || frames.getByName(anim) != null)
				{
					animation.addByPrefix('losing', anim, 24, true);
					hasLosing = true;
					break;
				}
			}
			for (anim in ['winning', 'icon win'])
			{
				if (frames.getByName(anim + '0000') != null || frames.getByName(anim) != null)
				{
					animation.addByPrefix('winning', anim, 24, true);
					hasWinning = true;
					break;
				}
			}

			// Play idle by default
			if (hasIdle)
				animation.play('idle');
			else if (hasWinning)
				animation.play('winning');
			else if (hasLosing)
				animation.play('losing');

			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (height - 150) / 2;
		}
		else
		{
			// Static icon (2 or 3 frames)
			var graphic = Paths.image(baseName, allowGPU);

			var frameWidth:Int = Math.floor(graphic.height); // Square frame
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

		// Antialias settings
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
