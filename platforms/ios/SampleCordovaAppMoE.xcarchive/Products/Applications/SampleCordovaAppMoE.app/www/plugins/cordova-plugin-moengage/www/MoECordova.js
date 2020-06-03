cordova.define("cordova-plugin-moengage.MoECordova", function(require, exports, module) {
var exec = require('cordova/exec');

var MoECordova = function() {

    this._handlers = {
        'onInAppClick': [],
        'onPushClick': [],
        'onPushRegistration': [],
        'onInAppShown': []
    };
    var that =  this;
    var success = function(msg) {
        console.log("inside success of Constructor");
        if (msg) {
          console.log(JSON.stringify(msg));
          if (msg.type === 'inAppClick') {
            that.emit('onInAppClick',msg);
        }else if (msg.type === 'pushClick') {
            that.emit('onPushClick',msg);
        }else if (msg.type === 'pushRegister') {
            that.emit('onPushRegistration',msg);
        }else if (msg.type === 'inAppShown') {
            that.emit('onInAppShown',msg);
        }
    }
}
var fail = function () {
    console.log("inside failure of Constructor");
}
exec(success, fail, 'MoEngage', 'init', [{"init":"init"}]);
}

/**
 * Passes Push Token to the MoEngage SDK
 *
 * @param token Push Token
 */
 MoECordova.prototype.passToken = function(token) {
    console.log("inside pass token");
    var success = function(result) {
        console.log("passToken : success");
    };


    var fail = function(msg) {
        console.log("passToken : fail");
    };

    pushToken = {
        "gcm_token": token
    }
    exec(success, fail, 'MoEngage', 'pass_token', [pushToken]);
}

/**
 * Passes Push payload to the MoEngage SDK
 *
 * @param pushPayload JSONObject of the push payload.
 */
 MoECordova.prototype.pushPayload = function(pushPayload) {
    console.log("inside pushPayload");
    var success = function(result) {
        console.log("pushPayload : success");
    };


    var fail = function(msg) {
        console.log("pushPayload : fail");
    };

    pushPayload = {
        "gcm_payload": pushPayload
    }
    exec(success, fail, 'MoEngage', 'pass_payload', [pushPayload]);
}

/**
 * Tells the SDK whether this is a migration or a fresh installation.
 * <b>Not calling this method will STOP execution of INSTALL CAMPAIGNS<b/>.
 * This is solely required for migration to MoEngage Platform
 *
 * @param existingUser true if it is an existing user else set false
 */
 MoECordova.prototype.setExistingUser = function(isExisting) {
    console.log("inside setExistingUser");
    var success = function(result) {
        console.log("setExistingUser : success");
    };


    var fail = function(msg) {
        console.log("setExistingUser : fail");
    };

    existingUser = {
        "existing_user": isExisting
    }
    exec(success, fail, 'MoEngage', 'existing_user', [existingUser]);
}

/**
 * Tracks the specified event
 *
 * @param action The action associated with the Event
 * @param attrs A JSONObject of all the attributes which needs to be
 * logged.
 */
 MoECordova.prototype.trackEvent = function(eventName, eventAttributes) {
    console.log("inside trackEvent");
    var success = function(result) {
        console.log("trackEvent : success");
    };


    var fail = function(msg) {
        console.log("trackEvent : fail");
    };

    event = {
        "event_name": eventName,
        "event_attributes": eventAttributes
    }
    exec(success, fail, 'MoEngage', 'track_event', [event]);
}

/**
 * Set a user attribute for the current user
 *
 * @param attributeName The attribute which needs to be set
 * @param attributeValue The attribute value corresponding to the userAttribute
 */
 MoECordova.prototype.setUserAttribute = function(attributeName, attributeValue) {
    console.log("inside setUserAttribute");
    var success = function(result) {
        console.log("setUserAttribute : success");
    };

    var fail = function(msg) {
        console.log("setUserAttribute : fail");
    };
    var type = null;
    var attributeType = typeof(attributeValue);
    if (attributeType == "number") {
        var index = attributeValue.toString().indexOf('.');
        if (index != 0 && index < 0) {
            type = "integer"
        } else {
            type = "double"
        }
    } else if (attributeType == "string") {
        type = "String";
    } else if (attributeType == "boolean") {
        type = "boolean";
    }
    userAttribute = {
        "attribute_name": attributeName,
        "attribute_value": attributeValue,
        "attribute_type": type
    }

    exec(success, fail, 'MoEngage', 'set_user_attribute', [userAttribute]);
}


/**
 * Set a user attribute location for the current user
 *
 * @param attributeName The attribute which needs to be set
 * @param attributeLatValue Latitude value corresponding to the location userAttribute
 * @param attributeLonValue Longitude value corresponding to the location userAttribute
 */
 MoECordova.prototype.setUserAttributeLocation = function(attributeName, attributeLatValue, attributeLonValue) {
    console.log("inside setUserAttribute Location");
    var success = function(result) {
        console.log("setUserAttributeLocation : success");
    };

    var fail = function(msg) {
        console.log("setUserAttributeLocation : fail");
    };

    userAttribute = {
        "attribute_name": attributeName,
        "attribute_lat_value": attributeLatValue,
        "attribute_lon_value": attributeLonValue
    }

    exec(success, fail, 'MoEngage', 'set_user_attribute_location', [userAttribute]);
}

/**
 * Set a user attribute timestamp for the current user
 * @param attributeName The attribute which needs to be set
 * @param epochTimeStampVal The attribute epoch timestamp value corresponding to the userAttribute
 */
 MoECordova.prototype.setUserAttributeTimestamp = function(attributeName, epochTimeStampVal) {
    console.log("inside setUserAttribute Timestamp");
    var success = function(result) {
        console.log("setUserAttributeTimestamp : success");
    };

    var fail = function(msg) {
        console.log("setUserAttributeTimestamp : fail");
    };

    userAttribute = {
        "attribute_name": attributeName,
        "attribute_value": epochTimeStampVal
    }

    exec(success, fail, 'MoEngage', 'set_user_attribute_timestamp', [userAttribute]);
}

/**
 * Invalidates the existing sessions and user attributes and treats all
 * actions performed by the user as a new user after this method is called<br>
 * If the Application is doing a self registration for gcm token then invalidate the token on
 * logout
 */
 MoECordova.prototype.logout = function() {
    console.log("inside logout");
    var success = function(result) {
        console.log("logout : success");
    };

    var fail = function(msg) {
        console.log("logout : fail");
    };
    exec(success, fail, 'MoEngage', 'logout', [{ "action": "logout" }]);

}

/**
 *  Show inApp view on the window
 *  Note : This method is only required for iOS
 */
 MoECordova.prototype.showInApp = function() {
    console.log("inside showInApp");
    var success = function(result) {
        console.log("showInApp : success");
    };

    var fail = function(msg) {
        console.log("showInApp : fail");
    };
    exec(success, fail, 'MoEngage', 'showInApp', [{"action":"showInApp"}]);

}

/**
 *  Set LogLevel for Android
 *  Note : This method is for setting loglevel in Android
 *  @param loglevel The integer attribute which decides the LogLevel. Values can be from 0 to 5
 */

 MoECordova.prototype.setLogLevelForAndroid = function(loglevel){
    console.log("inside setLogLevel");
    var success = function(result) {
        console.log("setLogLevel : success");
    };

    var fail = function(msg) {
        console.log("setLogLevel : fail");
    };
    exec(success, fail, 'MoEngage', 'setLogLevel', [{"log_level" : loglevel}]);
}

/**
 *  Set LogLevel for iOS
 *  Note : This method is for setting loglevel in iOS
 *  @param loglevel The integer attribute which decides the LogLevel. Values can be from 0 to 2
 */

 MoECordova.prototype.setLogLevelForiOS = function(loglevel){
    console.log("inside setLogLevel");
    var success = function(result) {
        console.log("setLogLevel : success");
    };

    var fail = function(msg) {
        console.log("setLogLevel : fail");
    };
    exec(success, fail, 'MoEngage', 'setLogLevelForiOS', [{"log_level" : loglevel}]);
}

/**
 *  Register For Push Notification for iOS
 *  Note : This method is only for iOS
 */

 MoECordova.prototype.registerForPushNotification = function(){
    console.log("inside registerForPushNotification");
    var success = function(result) {
        console.log("registerForPushNotification : success");
    };

    var fail = function(msg) {
        console.log("registerForPushNotification : fail");
    };
    exec(success, fail, 'MoEngage', 'registerForPushNotification', [{"action" : "registerForPushNotification"}]);
}

/**
 * Use this method to update User Attribute Unique ID of a user
 * @param alias The updated Unique ID for the user 
 */

MoECordova.prototype.setAlias = function (alias) {
  console.log("inside setAlias");
  var success = function(result) {
      console.log("setAlias : success");
  };

  var fail = function(msg) {
      console.log("setAlias : fail");
  };

  exec(success, fail, 'MoEngage', 'setAlias', [{"set_alias" : alias}]);
};


MoECordova.prototype.emit = function() {
    var args = Array.prototype.slice.call(arguments);
    var eventName = args.shift();

    if (!this._handlers.hasOwnProperty(eventName)) {
        return false;
    }

    for (var i = 0, length = this._handlers[eventName].length; i < length; i++) {
        var callback = this._handlers[eventName][i];
        if (typeof callback === 'function') {
            callback.apply(undefined,args);
        } else {
            console.log('event handler: ' + eventName + ' must be a function');
        }
    }

    return true;
};

MoECordova.prototype.on = function(eventName, callback) {
    if (!this._handlers.hasOwnProperty(eventName)) {
        this._handlers[eventName] = [];
    }
    this._handlers[eventName].push(callback);
};

module.exports = {

    init: function() {
        return new MoECordova();
    },

    MoECordova: MoECordova
}

});
