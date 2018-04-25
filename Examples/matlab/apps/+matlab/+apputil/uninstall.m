function uninstall(appid)
% matlab.apputil.uninstall Uninstall an app.
% 
%   matlab.apputil.uninstall(APPID) uninstalls the specified app.  The app
%   is removed from the app gallery and all files associated with the app
%   are deleted.  The APPID argument is a character vector or string
%   containing the ID of the app that was returned by
%   matlab.apputil.install when the app was installed.  The id can also be
%   determined by using the matlab.apputil.getInstalledAppInfo function.
%
%   Note that if the uninstall is successful, there is no output from the
%   function.  If the uninstall fails, an error will be generated.
% 
%   Example: Remove a previous installed app
% 
%     matlab.apputil.uninstall('DataVisualizationAPP');
%
%   See also: matlab.apputil.install, matlab.apputil.getInstalledAppInfo.

% Copyright 2012-2016 The MathWorks, Inc.

narginchk(1,1);

validateattributes(appid,{'char','string'},{'scalartext'}, ...
    'matlab.apputil.uninstall','APPID',1)
appid = char(appid);

appview = com.mathworks.appmanagement.AppManagementViewSilent;
appAPI = com.mathworks.appmanagement.AppManagementApiBuilder.getAppManagementApiCustomView(appview);
infos = matlab.internal.apputil.getAllAppInfo(char(appAPI.getMyAppsLocation));

if isempty(infos)
    error(message('MATLAB:apputil:uninstall:notinstalled'));
end

appIndex = matlab.internal.apputil.AppUtil.findAppIDs({infos.id}, appid, true);

if ~any((appIndex))
    error(message('MATLAB:apputil:uninstall:notinstalled'));
end

appAPI.uninstall(infos(appIndex).GUID);

status = appview.getError;

if ~isempty(status)
    error(message('MATLAB:apputil:uninstall:uninstallfailed', ...
        char(status.getLocalizedMessage())));
end

end

