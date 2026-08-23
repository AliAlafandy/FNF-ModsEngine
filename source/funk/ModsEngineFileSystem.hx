package funk;

import openfl.Assets;
import mobile.backend.StorageUtil;
#if sys
import sys.FileSystem;
import sys.FileStat;
#end

using StringTools;

/**
 * Unified file system class that works with both native file access and OpenFL assets.
 * @see https://github.com/Psych-Slice/P-Slice/blob/master/source/mikolka/funkin/custom/NativeFileSystem.hx
 */
class ModsEngineFileSystem {
	inline static function cwd(path:String):String {
		/*#if android
		return StorageUtil.getExternalStorageDirectory();
		#else*/
		if (path.startsWith(Sys.getCwd()) /*|| path.startsWith(Paths.mods())*/)
			return path;
		else
			return Sys.getCwd() + path;
        //#end
	}

	static function openflcwd(path:String):String {
		@:privateAccess
		for (library in lime.utils.Assets.libraries.keys())
		{
			if (Assets.exists('$library:$path') && !path.startsWith('$library:'))
				return '$library:$path';
		}

		return path;
	}

	public static function exists(path:String):Bool {
		#if sys
		if (FileSystem.exists(cwd(path)))
			return true;
		#end
		return Assets.exists(openflcwd(path));
	}

	public static function rename(path:String, newPath:String):Void {
		#if sys
		if (FileSystem.exists(cwd(path)))
			FileSystem.rename(cwd(path), cwd(newPath));
		#end
	}

	public static function stat(path:String):Null<FileStat> {
		#if sys
		return FileSystem.stat(cwd(path));
		#else
		return null;
		#end
	}

	public static function getBitmapData(path:String):openfl.display.BitmapData {
    #if sys
    if (FileSystem.exists(cwd(path)))
        return openfl.display.BitmapData.fromFile(cwd(path));
    #end

    var openflPath = openflcwd(path);
    if (Assets.exists(openflPath, IMAGE)) {
        return Assets.getBitmapData(openflPath);
    }
    
    return null;
	}

	public static function fullPath(path:String):String {
		#if sys
		return FileSystem.fullPath(path);
		#else
		return path;
		#end
	}

	public static function absolutePath(path:String):String {
		#if sys
		return FileSystem.absolutePath(path);
		#else
		return path;
		#end
	}

	public static function isDirectory(path:String):Bool {
		#if sys
		if (FileSystem.exists(cwd(path)) && FileSystem.isDirectory(cwd(path)))
			return true;
		#end
		return false;
		//return Assets.list().exists(f -> f.startsWith(path) && f != path);
	}

	public static function createDirectory(path:String):Void {
		#if sys
		if (!FileSystem.exists(cwd(path)))
			FileSystem.createDirectory(cwd(path));
		#end
	}

	public static function deleteFile(path:String):Void {
		#if sys
		if (FileSystem.exists(cwd(path)) && !FileSystem.isDirectory(cwd(path)))
			FileSystem.deleteFile(cwd(path));
		#end
	}

	public static function deleteDirectory(path:String):Void {
		#if sys
		if (FileSystem.exists(cwd(path)) && FileSystem.isDirectory(cwd(path)))
			FileSystem.deleteDirectory(cwd(path));
		#end
	}

	public static function readDirectory(path:String):Array<String> {
		#if sys
		if (FileSystem.exists(path) && FileSystem.isDirectory(path))
			return FileSystem.readDirectory(path);
		#end

        var filteredList:Array<String> = Assets.list().filter(f -> f.startsWith(path));
		var results:Array<String> = [];
		for (i in filteredList.copy()) {
			var slashsCount:Int = path.split('/').length;
			if (path.endsWith('/'))
				slashsCount -= 1;

			if (i.split('/').length - 1 != slashsCount) {
				filteredList.remove(i);
			}
		}
		for (item in filteredList) {
			@:privateAccess
			for (library in lime.utils.Assets.libraries.keys()) {
				var libPath:String = '$library:$item';
				if (library != 'default' && Assets.exists(libPath) && !results.contains(libPath))
					results.push(libPath);
				else if (Assets.exists(item) && !results.contains(item))
					results.push(item);
			}
		}
		return results.map(f -> f.substr(f.lastIndexOf("/") + 1));
	}
}