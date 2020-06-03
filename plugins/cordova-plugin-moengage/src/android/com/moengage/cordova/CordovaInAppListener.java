package com.moengage.cordova;

import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import com.moengage.cordova.MoECordova;
import com.moengage.core.Logger;
import com.moengage.inapp.InAppManager;
import com.moengage.inapp.InAppMessage;

/**
 * @author Umang Chamaria
 * Date: 2019-08-26
 */
public class CordovaInAppListener implements InAppManager.InAppMessageListener {

  private static final String TAG = "CordovaInAppListener";

  @Override public void onInAppShown(InAppMessage message) {

  }

  @Override public boolean showInAppMessage(InAppMessage message) {
    return false;
  }

  @Override public void onInAppClosed(InAppMessage message) {

  }

  @Override public boolean onInAppClick(@Nullable String screenName, @Nullable Bundle extras,
      @Nullable Uri deepLinkUri) {
    try {
      Logger.v(TAG + " onInAppClick() : Will try to pass callback to javascript.");
      if (extras == null){
        extras = new Bundle();
      }
      if (!TextUtils.isEmpty(screenName)) {
        extras.putString("screenName", screenName);
      }
      if (deepLinkUri != null) {
        extras.putString("uri", deepLinkUri.toString());
      }
      extras.putString("type", "inAppClick");
      MoECordova.sendExtras(extras);
    } catch (Exception e) {
      Logger.e( TAG + " onInAppClick() : ");
    }
    return true;
  }
}
