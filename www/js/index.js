/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
        this.receivedEvent('deviceready');
        console.log('on device ready called');
        var moe = new MoECordova.init();
        
        //Setting log level for iOS platform
        moe.setLogLevelForiOS(1);
        
        //Tracking event with attributes
        moe.trackEvent("customEvent", {"customAttr" : 100});
        
        //Registering for push notification
        moe.registerForPushNotification()

        //Tracking event with different attributes of various datatypes
        var eventDict1 = {
            "attributeString" : "abcde"
        }
        moe.trackEvent("EventWithString",eventDict1)

        var eventDict2 = {
            "attributeBool" : false
        }
        moe.trackEvent("EventWithBool",eventDict2)
        
        var eventDict3 = {
            "attributeNumber" : 1234
        }
        moe.trackEvent("EventWithNumber",eventDict3)
        
        var eventDict4 = {
            "attributeDecimal" : 1.234
        }
        moe.trackEvent("EventWithFloat",eventDict4)

        moe.setExistingUser(true)
        //this value is just for reference as a sample value,Please don't hard-code this value. Use actual values.
        
        moe.setUserAttribute("USER_ATTRIBUTE_UNIQUE_ID", "uniqueId1")
        //this value is just for reference as a sample value,Please don't hard-code this value. Use actual values.
        
        moe.setUserAttribute("userAttributeInteger", 1234)
        //this value is just for reference as a sample value,Please don't hard-code this value. Use actual values.
        
        moe.setUserAttribute("userAttributeBool", false)
        //this value is just for reference as a sample value,Please don't hard-code this value. Use actual values.
        
        moe.setUserAttribute("userAttributeString", "HELLO MOENGAGE")
        //this value is just for reference as a sample value,Please don't hard-code this value. Use actual values.
        
        moe.setUserAttributeTimestamp("userAttributeTimeStamp",1470288682)
        //this value is just for reference as a sample value,Please don't hard-code this value. Use actual values.
        
        moe.setAlias("uniqueId2")
        //this value is just for reference as a sample value,Please don't hard-code this value. Use actual values.
        
        moe.setUserAttributeLocation("SampleLocation",72.0089,54.0009)

        moe.showInApp()

        moe.on('onPushClick', function(data) {
            console.log('Received data: ' + data);
        });

        moe.on('onPushRegistration', function(data) {
            console.log('Received data: ' + data);
        });

        moe.on('onInAppShown', function(data) {
            console.log('Received data: ' + data);
        });

        moe.on('onInAppClick', function(data) {
            console.log('Received data: ' + data);
        });
    },

    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

app.initialize();
