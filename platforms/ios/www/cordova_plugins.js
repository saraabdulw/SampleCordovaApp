cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "cordova-plugin-moengage.MoECordova",
      "file": "plugins/cordova-plugin-moengage/www/MoECordova.js",
      "pluginId": "cordova-plugin-moengage",
      "clobbers": [
        "MoECordova"
      ]
    }
  ];
  module.exports.metadata = {
    "cordova-plugin-whitelist": "1.3.4",
    "cordova-plugin-moengage": "5.0.1"
  };
});