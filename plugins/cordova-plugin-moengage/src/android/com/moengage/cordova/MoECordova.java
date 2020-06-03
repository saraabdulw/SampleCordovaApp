package com.moengage.cordova;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import com.moe.pushlibrary.MoEHelper;
import com.moe.pushlibrary.models.GeoLocation;
import com.moengage.push.PushManager;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.moengage.push.PushManager;
import com.moengage.inapp.InAppManager;

/**
 * This class echoes a string called from JavaScript.
 */
public class MoECordova extends CordovaPlugin {

  private static final String ACTION_PASS_TOKEN = "pass_token";
  private static final String ACTION_PASS_PAYLOAD = "pass_payload";
  private static final String ACTION_SET_EXISTING_USER = "existing_user";
  private static final String ACTION_SET_USER_ATTRIBUTE = "set_user_attribute";
  private static final String ACTION_TRACK_EVENT = "track_event";
  private static final String ACTION_SET_UNIQUE_ID = "unique_id";
  private static final String ACTION_USER_LOGOUT = "logout";
  private static final String ACTION_USER_LOCATION = "set_user_attribute_location";
  private static final String ACTION_SET_LOG_LEVEL = "setLogLevel";
  private static final String ACTION_ENABLE_DATA_REDIRECTION = "enableDataRedirection";
  private static final String ACTION_SET_USER_ATTRIBUTE_TIMESTAMP = "set_user_attribute_timestamp";
  private static final String ACTION_INIT = "init";
  private static final String ACTION_SET_ALIAS = "setAlias";

  private static CallbackContext nativeCallbackContext;
  private static CordovaWebView cordovaWebView;
  private static boolean isForeground = false;
  private static List<Bundle> cachedExtras = Collections.synchronizedList(new ArrayList<Bundle>());

  @Override public boolean execute(String action, JSONArray args, CallbackContext callbackContext)
      throws JSONException {
    cordovaWebView = this.webView;
    Log.d("MoECordova", "inside native code : " + action);
    Context context = getApplicationContext();
    MoEHelper moeHelper = MoEHelper.getInstance(context);
    JSONObject jsonObject = args.getJSONObject(0);
    Log.d("MoECordova", "payload : " + jsonObject.toString());
    switch (action) {
      case ACTION_PASS_TOKEN:
        String token = jsonObject.getString("gcm_token");
        PushManager.getInstance().refreshToken(context, token);
        callbackContext.success("success");
        break;
      case ACTION_PASS_PAYLOAD:
        JSONObject payload = jsonObject.getJSONObject("gcm_payload");
        Bundle data = jsonToBundle(payload);
        PushManager.getInstance().getPushHandler().handlePushPayload(context, data);
        callbackContext.success("success");
        break;
      case ACTION_SET_EXISTING_USER:
        boolean isExisting = jsonObject.getBoolean("existing_user");
        moeHelper.setExistingUser(isExisting);
        callbackContext.success("success");
        break;
      case ACTION_SET_USER_ATTRIBUTE:
        String dataType = jsonObject.getString("attribute_type");
        String attributeName = jsonObject.getString("attribute_name");
        switch (dataType) {
          case "boolean":
            moeHelper.setUserAttribute(attributeName, jsonObject.getBoolean("attribute_value"));
            break;
          case "String":
            moeHelper.setUserAttribute(attributeName, jsonObject.getString("attribute_value"));
            break;
          case "integer":
            moeHelper.setUserAttribute(attributeName, jsonObject.getInt("attribute_value"));
            break;
          case "double":
            moeHelper.setUserAttribute(attributeName, jsonObject.getDouble("attribute_value"));
            break;
        }
        callbackContext.success("success");
        break;
      case ACTION_TRACK_EVENT:
        String eventName = jsonObject.getString("event_name");
        JSONObject eventAttributes = jsonObject.getJSONObject("event_attributes");
        moeHelper.trackEvent(eventName, eventAttributes);
        callbackContext.success("success");
        break;
      case ACTION_USER_LOGOUT:
        moeHelper.logoutUser();
        callbackContext.success("success");
        break;
      case ACTION_USER_LOCATION:
        String locationAttributeName = jsonObject.getString("attribute_name");
        double latitude = jsonObject.getDouble("attribute_lat_value");
        double longitude = jsonObject.getDouble("attribute_lon_value");
        GeoLocation geoLocation = new GeoLocation(latitude, longitude);
        if (!TextUtils.isEmpty(locationAttributeName)) {
          moeHelper.setUserAttribute(locationAttributeName, geoLocation);
        } else {
          moeHelper.setUserLocation(latitude, longitude);
        }
        callbackContext.success("success");
        break;
      case ACTION_SET_LOG_LEVEL:
        int loglevel = jsonObject.getInt("log_level");
        moeHelper.setLogLevel(loglevel);
        callbackContext.success("success");
        break;
      case ACTION_ENABLE_DATA_REDIRECTION:
        boolean shouldRedirectData = jsonObject.getBoolean("set_redirect");
        // moeHelper.setDataRedirection(shouldRedirectData);
        callbackContext.success("success");
        break;
      case ACTION_SET_USER_ATTRIBUTE_TIMESTAMP:
        String attrName = jsonObject.getString("attribute_name");
        moeHelper.setUserAttributeEpochTime(attrName, jsonObject.getLong("attribute_value"));
        callbackContext.success("success");
        break;
      case ACTION_INIT:
        nativeCallbackContext = callbackContext;
        if (!cachedExtras.isEmpty()) {
          synchronized(cachedExtras) {
            Iterator<Bundle> gCachedExtrasIterator = cachedExtras.iterator();
            while (gCachedExtrasIterator.hasNext()) {
              sendExtras(gCachedExtrasIterator.next());
            }
          }
          cachedExtras.clear();
        }
        break;
      case ACTION_SET_ALIAS:
        moeHelper.setAlias(jsonObject.getString("set_alias"));
        break;
      default:
        callbackContext.error("fail");
    }
    return true;
  }

  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
    isForeground = true;
  }

  @Override
  public void onPause(boolean multitasking) {
    super.onPause(multitasking);
    isForeground = false;
  }

  @Override
  public void onResume(boolean multitasking) {
    super.onResume(multitasking);
    isForeground = true;
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    isForeground = false;
    cordovaWebView = null;
  }

  private Context getApplicationContext() {
    return this.cordova.getActivity().getApplicationContext();
  }

  public static void sendExtras(Bundle extras) {
    if (extras != null) {
      String noCache = extras.getString("no-cache");
      if (cordovaWebView != null) {
        sendEvent(bundleToJson(extras));
      } else if(!"1".equals(noCache)){
        cachedExtras.add(extras);
      }
    }
  }

  private Bundle jsonToBundle(JSONObject json) {
    try {
      Bundle bundle = new Bundle();
      Iterator iter = json.keys();
      while (iter.hasNext()) {
        String key = (String) iter.next();
        String value = json.getString(key);
        bundle.putString(key, value);
      }
      return bundle;
    } catch (JSONException e) {

    }
    return null;
  }

  public static void sendEvent(Bundle extras) {
    JSONObject extrasJSON = bundleToJson(extras);
    if (extrasJSON == null) return;
    sendEvent(extrasJSON);
  }

  public static void sendEvent(JSONObject _json) {
    Log.d("MoECordova", "sendEvent : " + _json.toString());
    PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, _json);
    pluginResult.setKeepCallback(true);
    if (nativeCallbackContext != null) {
      Log.d("MoECordova", "sendingEvent : " + _json.toString());
      nativeCallbackContext.sendPluginResult(pluginResult);
    }
  }

  private static JSONObject bundleToJson(Bundle bundle) {
    Set<String> keys = bundle.keySet();
    JSONObject jsonObject = new JSONObject();
    for (String key : keys) {
      try {
        jsonObject.put(key, bundle.get(key));
      } catch (Exception e) {
        Log.e("MoECordova", "MoEUtils:convertBundletoJSONString", e);
      }
    }
    return jsonObject;
  }

  public static boolean isInForeground() {
    return isForeground;
  }

  public static boolean isActive() {
    return cordovaWebView != null;
  }

  public static void registerNativeCallbacks(){
    PushManager.getInstance().setMessageListener(new CordovaMessageListener());
    InAppManager.getInstance().setInAppListener(new CordovaInAppListener());
  }
}
