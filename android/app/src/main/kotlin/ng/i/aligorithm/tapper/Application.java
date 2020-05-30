package ng.i.aligorithm.tapper;

import android.content.Context;

import androidx.multidex.MultiDex;

import io.flutter.app.FlutterApplication;

public class Application extends FlutterApplication {
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }

}
