package objects;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

enum Alignment
{
	LEFT;
	CENTERED;
	RIGHT;
}

class Alphabet extends FlxSpriteGroup
{
	public var text(default, set):String;

	public var bold:Bool = false;
	public var letters:Array<AlphaCharacter> = [];

	// menu system (from 0.4.2)
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Int = 0;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var isMenuItem:Bool = false;

	public var changeX:Bool = true;
	public var changeY:Bool = true;

	public var alignment(default, set):Alignment = LEFT;
	public var scaleX(default, set):Float = 1;
	public var scaleY(default, set):Float = 1;

	public var rows:Int = 0;

	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0);

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = true)
	{
		super(x, y);

		startPosition.set(x, y);
		this.bold = bold;
		this.text = text;
	}

	// alignment
	public function setAlignmentFromString(align:String)
	{
		switch(align.toLowerCase().trim())
		{
			case "right":
				alignment = RIGHT;
			case "center" | "centered":
				alignment = CENTERED;
			default:
				alignment = LEFT;
		}
	}

	private function set_alignment(v:Alignment)
	{
		alignment = v;
		updateAlignment();
		return v;
	}

	private function updateAlignment()
	{
		for(letter in letters)
		{
			var offset:Float = 0;

			switch(alignment)
			{
				case CENTERED:
					offset = letter.rowWidth / 2;
				case RIGHT:
					offset = letter.rowWidth;
				default:
					offset = 0;
			}

			letter.offset.x -= letter.alignOffset;
			letter.alignOffset = offset * scale.x;
			letter.offset.x += letter.alignOffset;
		}
	}

	// text setter
	private function set_text(v:String)
	{
		v = v.replace("\\n", "\n");
		clearLetters();
		createLetters(v);
		updateAlignment();
		text = v;
		return v;
	}

	public function clearLetters()
	{
		for(letter in letters)
		{
			if(letter != null)
			{
				letter.kill();
				remove(letter);
			}
		}
		letters = [];
		rows = 0;
	}

	// scale system (0.7.3)
	public function setScale(newX:Float, newY:Null<Float> = null)
	{
		if(newY == null) newY = newX;

		scaleX = newX;
		scaleY = newY;

		scale.set(newX, newY);
		softReloadLetters();
	}

	public function softReloadLetters(ratioX:Float = 1, ratioY:Null<Float> = null)
	{
		if(ratioY == null) ratioY = ratioX;

		for(letter in letters)
		{
			letter.setupAlphaCharacter(
				(letter.x - x) * ratioX + x,
				(letter.y - y) * ratioY + y
			);
		}
	}

	// menu movement (mixed system)
	override function update(elapsed:Float)
	{
		if(isMenuItem)
		{
			var lerpVal:Float = Math.exp(-elapsed * 9.6);

			if(changeX)
			{
				var targetX:Float = (targetY * distancePerItem.x) + startPosition.x + xAdd;
				if(forceX != Math.NEGATIVE_INFINITY) targetX = forceX;
				x = FlxMath.lerp(targetX, x, lerpVal);
			}

			if(changeY)
			{
				var targetYPos:Float = (targetY * yMult) + startPosition.y + yAdd;
				y = FlxMath.lerp(targetYPos, y, lerpVal);
			}
		}

		super.update(elapsed);
	}

	public function snapToPosition()
	{
		if(isMenuItem)
		{
			if(changeX)
			{
				var targetX:Float = (targetY * distancePerItem.x) + startPosition.x + xAdd;
				if(forceX != Math.NEGATIVE_INFINITY) targetX = forceX;
				x = targetX;
			}

			if(changeY)
				y = (targetY * yMult) + startPosition.y + yAdd;
		}
	}

	// letter creation (from 0.7.3)
	private static var Y_PER_ROW:Float = 85;

	private function createLetters(newText:String)
	{
		var xPos:Float = 0;
		var rowData:Array<Float> = [];
		rows = 0;

		for(character in newText.split(""))
		{
			if(character == "\n")
			{
				xPos = 0;
				rows++;
				continue;
			}

			if(AlphaCharacter.allLetters.exists(character.toLowerCase()))
			{
				var letter:AlphaCharacter = new AlphaCharacter();
				letter.scale.set(scaleX, scaleY);

				letter.setupAlphaCharacter(
					xPos,
					rows * Y_PER_ROW * scale.y,
					character,
					bold
				);

				letter.row = rows;

				xPos += letter.width * scaleX;

				add(letter);
				letters.push(letter);

				rowData[rows] = xPos;
			}
		}

		for(letter in letters)
			letter.rowWidth = rowData[letter.row];

		if(letters.length > 0) rows++;
	}
}
