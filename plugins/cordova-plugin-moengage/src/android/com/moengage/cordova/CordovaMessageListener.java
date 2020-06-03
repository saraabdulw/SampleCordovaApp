package com.moengage.cordova;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import com.moe.pushlibrary.utils.MoEHelperConstants;
import com.moengage.core.Logger;
import com.moengage.cordova.MoECordova;
import com.moengage.pushbase.push.PushMessageListener;

/**
 * @author Umang Chamaria
 * Date: 2019-08-26
 */
public class CordovaMessageListener extends PushMessageListener {

	private static final String TAG = "CordovaMessageListener";

  @Override public void onHandleRedirection(Activity activity, Bundle payload) {
  	Logger.v(TAG + " onHandleRedirection() : Will try to pass callback to javascript.");
    Context context = activity.getApplicationContext();
    payload.putString("type", "pushClick");
    String notificationType = payload.getString(MoEHelperConstants.GCM_EXTRA_NOTIFICATION_TYPE);
    if (MoEHelperConstants.GCM_EXTRA_WEB_NOTIFICATION.equals(notificationType)) {
      Uri uri = getRedirectionUri(payload);
      if (uri != null) {
        payload.putString("uri", uri.toString());
      }
    }else {
      String activityName = payload.getString(MoEHelperConstants.GCM_EXTRA_ACTIVITY_NAME, "");
      if (!TextUtils.isEmpty(activityName)){
        payload.putString("screenName", activityName);
      }
    }
    MoECordova.sendExtras(payload);

    PackageManager pm = context.getPackageManager();
    Intent launchIntent = pm.getLaunchIntentForPackage(context.getPackageName());

    launchIntent.putExtras(payload);
    launchIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
    launchIntent.addFlags(Intent.FLAG_FROM_BACKGROUND);

    context.startActivity(launchIntent);
  }
}