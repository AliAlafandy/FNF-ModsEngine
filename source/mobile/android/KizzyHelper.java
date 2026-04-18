package arkoselabs.utils;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.media.MediaMetadata;
import android.media.session.MediaSession;
import android.media.session.PlaybackState;
import android.os.Build;
import android.util.Log;
import org.haxe.extension.Extension;
import java.io.File;
import java.io.InputStream;
import java.io.IOException;

public class KizzyHelper extends Extension {
    private static MediaSession mediaSession;
    private static NotificationManager notificationManager;

    private static final String CHANNEL_ID = "psych_silent_mode_v1"; 
    private static final int NOTIFICATION_ID = 111;
    private static final String TAG = "KizzyHelper";

    public static void initialize() {
        if (Extension.mainActivity == null) return;

        Extension.mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    Context context = Extension.mainContext;
                    if (mediaSession == null) {
                        mediaSession = new MediaSession(context, "PsychSession");
                        mediaSession.setCallback(new MediaSession.Callback() {});
                        mediaSession.setFlags(MediaSession.FLAG_HANDLES_TRANSPORT_CONTROLS | MediaSession.FLAG_HANDLES_MEDIA_BUTTONS);
                        mediaSession.setActive(true);

                        notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
                        createNotificationChannel();
                        
                        Log.d(TAG, "Session started in the background.");
                    }

                    if (Build.VERSION.SDK_INT >= 33) {
                        Extension.mainActivity.requestPermissions(new String[]{"android.permission.POST_NOTIFICATIONS"}, 101);
                    }
                } catch (Exception e) {
                    Log.e(TAG, "INIT ERROR: " + e.getMessage());
                }
            }
        });
    }

    public static void updateStatus(final String title, final String artist, final String imagePath) {
        if (Extension.mainActivity == null) return;

        Extension.mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    if (mediaSession == null) { initialize(); return; }
                    Context context = Extension.mainContext;
                    Bitmap albumArt = null;

                    if (imagePath != null && !imagePath.isEmpty()) {
                        try {
                            File imgFile = new File(imagePath);
                            if (imgFile.exists()) {
                                albumArt = BitmapFactory.decodeFile(imgFile.getAbsolutePath());
                            }
                            else {
                                AssetManager am = context.getAssets();
                                InputStream istr = null;
                                try {
                                    istr = am.open(imagePath);
                                } catch (IOException e1) {
                                    try {
                                        istr = am.open("assets/" + imagePath);
                                    } catch (IOException e2) {
                                        if (imagePath.startsWith("assets/")) {
                                            istr = am.open(imagePath.substring(7));
                                        }
                                    }
                                }
                                if (istr != null) {
                                    albumArt = BitmapFactory.decodeStream(istr);
                                    istr.close();
                                }
                            }
                        } catch (Exception e) {
                            Log.e(TAG, "Image could not be loaded: " + imagePath);
                        }
                    }

                    if (albumArt == null) {
                        albumArt = getAppIconAsBitmap(context);
                    }

                    MediaMetadata metadata = new MediaMetadata.Builder()
                            .putString(MediaMetadata.METADATA_KEY_TITLE, title)
                            .putString(MediaMetadata.METADATA_KEY_ARTIST, artist)
                            .putBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART, albumArt)
                            .build();
                    mediaSession.setMetadata(metadata);

                    PlaybackState state = new PlaybackState.Builder()
                            .setActions(PlaybackState.ACTION_PLAY | PlaybackState.ACTION_PAUSE | PlaybackState.ACTION_SKIP_TO_NEXT)
                            .setState(PlaybackState.STATE_PLAYING, 0, 1.0f)
                            .build();
                    mediaSession.setPlaybackState(state);

                    showNotification(title, artist, albumArt);

                } catch (Exception e) {
                    Log.e(TAG, "UPDATE ERROR: " + e.getMessage());
                }
            }
        });
    }

    private static void showNotification(String title, String artist, Bitmap art) {
        Context context = Extension.mainContext;
        Notification.Builder builder;

        if (Build.VERSION.SDK_INT >= 26) {
            builder = new Notification.Builder(context, CHANNEL_ID);
        } else {
            builder = new Notification.Builder(context);
        }
        builder.setPriority(Notification.PRIORITY_MIN);

        Notification.MediaStyle style = new Notification.MediaStyle();
        style.setMediaSession(mediaSession.getSessionToken());
        style.setShowActionsInCompactView(0);

        builder.setVisibility(Notification.VISIBILITY_SECRET)
                .setSmallIcon(null)
                .setLargeIcon(art)
                .setContentTitle(title)
                .setContentText(artist)
                .setStyle(style)
                .setOngoing(true);

        notificationManager.notify(NOTIFICATION_ID, builder.build());
    }

    private static void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= 26) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID, "Background Service", NotificationManager.IMPORTANCE_MIN);
            
            channel.setDescription("Running silently");
            channel.setShowBadge(false);
            channel.setLockscreenVisibility(Notification.VISIBILITY_SECRET);
            
            if (notificationManager != null) {
                notificationManager.createNotificationChannel(channel);
            }
        }
    }

    public static void shutdown() {
        if (Extension.mainActivity == null) return;
        
        Extension.mainActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    if (mediaSession != null) {
                        mediaSession.setActive(false);
                        mediaSession.release();
                        mediaSession = null;
                    }
                    if (notificationManager != null) {
                        notificationManager.cancel(NOTIFICATION_ID);
                    }
                    Log.d(TAG, "MediaSession closed and cleared.");
                } catch (Exception e) {
                    Log.e(TAG, "SHUTDOWN ERROR: " + e.getMessage());
                }
            }
        });
    }

    private static Bitmap getAppIconAsBitmap(Context context) {
        try {
            Drawable drawable = context.getPackageManager().getApplicationIcon(context.getPackageName());
            if (drawable instanceof BitmapDrawable) {
                return ((BitmapDrawable) drawable).getBitmap();
            }
            Bitmap bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(bitmap);
            drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
            drawable.draw(canvas);
            return bitmap;
        } catch (Exception e) {
            return null;
        }
    }
}
