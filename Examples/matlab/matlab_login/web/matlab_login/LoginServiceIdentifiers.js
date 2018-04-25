define(["dojo/_base/kernel"], function(kernel) {
    kernel.global.logoutServiceId = 'LoginService.logout';
    kernel.global.shouldLogoutServiceId = 'LoginService.shouldLogout';
    kernel.global.isUserLoggedInServiceId = 'LoginService.isUserLoggedIn';
    kernel.global.saveCacheLoginInfoServiceId = 'LoginService.saveCacheLoginInfo';
    kernel.global.getInfoToCallEmbeddedLoginServiceId = 'LoginService.getInfoToCallEmbeddedLogin';
});
