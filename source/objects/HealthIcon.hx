package objects;

class HealthIcon extends FlxSprite
{
    public var sprTracker:FlxSprite;
    private var isOldIcon:Bool = false;
    private var isPlayer:Bool = false;
    private var char:String = '';

    private var iconOffsets:Array<Float> = [0, 0];

    public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
    {
        super();
        this.isOldIcon = (char == 'bf-old');
        this.isPlayer = isPlayer;
        this.changeIcon(char, allowGPU);
        scrollFactor.set();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        // Follow tracker if assigned
        if (sprTracker != null)
            setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
    }

    public function changeIcon(char:String, ?allowGPU:Bool = true)
    {
        if (this.char != char)
        {
            var name:String = 'icons/' + char;
            if (!Paths.fileExists('images/' + name + '.png', IMAGE))
                name = 'icons/icon-' + char;
            if (!Paths.fileExists('images/' + name + '.png', IMAGE))
                name = 'icons/icon-face'; // fallback

            var graphic:FlxGraphic = Paths.image(name, allowGPU);

            // --- Detect frame count dynamically ---
            var frameWidth:Int = Math.floor(graphic.height); // each frame is a square
            var frameCount:Int = Math.floor(graphic.width / frameWidth);
            if (frameCount < 2) frameCount = 2;

            // Load graphic
            loadGraphic(graphic, true, frameWidth, frameWidth);

            // Update offsets
            iconOffsets[0] = (width - 150) / 2;
            iconOffsets[1] = (height - 150) / 2;
            updateHitbox();

            // Add animation for all frames
            var frameArray:Array<Int> = [];
            for (i in 0...frameCount)
                frameArray.push(i);

            animation.add(char, frameArray, 0, false, isPlayer);
            animation.play(char);

            this.char = char;

            antialiasing = char.endsWith('-pixel') ? false : ClientPrefs.data.antialiasing;
        }
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

    // --- New method: update icon frame based on health ---
    public function updateIcon(healthPercent:Float):Void
    {
        if (animation.curAnim == null) return;

        var maxFrame:Int = animation.curAnim.frames.length - 1;
        var winning:Bool = healthPercent > 80;
        var losing:Bool = healthPercent < 20;

        if (isPlayer)
        {
            if (winning)
                animation.curAnim.curFrame = Std.int(Math.min(maxFrame, 2)); // Winning
            else if (losing)
                animation.curAnim.curFrame = 1; // Losing
            else
                animation.curAnim.curFrame = Std.int(Math.min(maxFrame, 0)); // Neutral
        }
        else
        {
            // Opponent frame is inverse of player
            if (winning)
                animation.curAnim.curFrame = 1; // Losing
            else if (losing)
                animation.curAnim.curFrame = Std.int(Math.min(maxFrame, 2)); // Winning
            else
                animation.curAnim.curFrame = Std.int(Math.min(maxFrame, 0)); // Neutral
        }
    }
}
