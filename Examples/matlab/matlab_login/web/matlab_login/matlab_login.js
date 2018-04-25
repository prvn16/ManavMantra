define(["dojo/_base/declare"],
    function (declare) {
        return declare(null, {

            isUserLoggedIn: function (loginLevel, clientString, successCallback, errorCallback) {
                var that = this;
                require(["matlab_login/LoginServiceIdentifiers"],
                function() {
                    var jsonId = isUserLoggedInServiceId;

                    var message = '{"' + jsonId + '":[{';
                    message += '"requestedloginlevel":"' + loginLevel + '",';
                    message += '"clientstring":"' + clientString + '"';
                    message += '}]}';

                    that._callServiceHandler(message,function(result){successCallback(result[jsonId+"Response"][0]);},errorCallback);
                });
            },

            saveCacheLoginInfo: function (firstName, lastName, email, userId, token, profileId, requestedLoginLevel,
                                          rememberMe, cachedUsername, displayName, successCallback, errorCallback) {
                var that = this;
                require(["matlab_login/LoginServiceIdentifiers"],
                function() {
                    var jsonId = saveCacheLoginInfoServiceId;

                    var message = '{"' + jsonId + '":[{';
                    message += '"firstname":"' + firstName + '",';
                    message += '"lastname":"' + lastName + '",';
                    message += '"email":"' + email + '",';
                    message += '"userid":"' + userId + '",';
                    message += '"token":"' + token + '",';
                    message += '"profileid":"' + profileId + '",';
                    message += '"requestedloginlevel":"' + requestedLoginLevel + '",';
                    message += '"cacheusername":"' + cachedUsername + '",';
                    message += '"displayname":"' + displayName + '",';
                    message += '"rememberme":"' + rememberMe + '"';
                    message += '}]}';

                    that._callServiceHandler(message,function(result){successCallback(result[jsonId+"Response"][0]);},errorCallback);
                });
            },

            logout: function (successCallback, errorCallback) {
                var that = this;
                require(["matlab_login/LoginServiceIdentifiers"],
                function() {
                    var jsonId = logoutServiceId;

                    var message = '{"' + jsonId + '":[{';
                    message += '}]}';
                    that._callServiceHandler(message,function(result){successCallback(result[jsonId+"Response"][0]);},errorCallback);
                });
            },

            getInfoToCallEmbeddedLogin: function(successCallback, errorCallback) {
                var that = this;
                require(["matlab_login/LoginServiceIdentifiers"],
                function() {
                    var jsonId = getInfoToCallEmbeddedLoginServiceId;
                    var message = '{"' + jsonId + '":[{';
                    message += '}]}';
                    that._callServiceHandler(message,function(result){successCallback(result[jsonId+"Response"][0]);},errorCallback);
                });
            },

            startGettingLoginStatusUpdates : function(callback) {
                require(["matlab_login/LoginStatusUpdate"], function(LoginStatusUpdate) {
                    var loginStatusUpdate = new LoginStatusUpdate(callback);
                });
            },

            stopGettingLoginStatusUpdates : function() {
                require(["matlab_login/LoginStatusUpdate"], function (LoginStatusUpdate) {
                    var loginStatusUpdate = new LoginStatusUpdate();
                    loginStatusUpdate.stop();
                });
            },

            _callServiceHandler: function(message,successCallback,errorCallback) {
                var that = this;
                require(["InstallServiceHandler/InstallServiceHandler"],
                function(ServiceHandler) {
                    var handler = new ServiceHandler();
                    handler.executeService(message, successCallback,
                        function(errorMessages) {
                            // exception with serviceName;exceptionName;message triple
                            var parts = errorMessages[0].message.split(/;/);
                            var errObj = {name:parts[1], message:parts[2]};
                            throw errObj;
                        }
                    ).then( 
                        function(){},
                        function(error) {
                            that._handleMessage(error,errorCallback);
                        });
                });
            },

            _handleMessage: function(errorObj,errorCallback) {
                if(errorCallback !== undefined) {
                    errorCallback(errorObj);
                }
            }
        });
    });
