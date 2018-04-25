function [loadOutcome, compatibilityData, componentAndGroupData, appNameData, codeData, appMetadata] = loadApp(filepath)
% LOADAPP Facade API for App Designer client side getting app data to load
%
% Retrieve the data of the App of file - "filepath".  This
% is called by the client when the user chooses an App to open.

% Copyright 2017 The MathWorks, Inc.

% Assume load will be successful
loadOutcome.Status = 'success';

compatibilityData = [];
componentAndGroupData = [];
appNameData = [];
codeData = [];
appMetadata = [];

try    
    % create a deserializer and get the app Data
    deserializer = appdesigner.internal.serialization.MLAPPDeserializer(filepath);
    appData = deserializer.getAppData();
    
    % extract the code Data
    codeData = appData.code;
    % the client expects the 'startupCallback' field to be called 'StartupFcn'.
    % Changing the key name here because the client has many occurences
    % of 'StartupFcn' and don't want to make that change in the initial
    % checkin
    if ( isfield(codeData,'StartupCallback'))
        codeData.StartupFcn = codeData.StartupCallback;
        codeData = rmfield(codeData,'StartupCallback');
    end
    
    % convert the component and their properties to structs
    componentConverter = appdesigner.internal.serialization.util.ComponentObjectToStructConverter(appData.components.UIFigure);
    componentData = componentConverter.getConvertedData();
    
    % create the component and group data structure
    componentAndGroupData.ComponentData = componentData;
    
    if isfield(appData.components,'Groups')
        componentAndGroupData.GroupData = appData.components.Groups;
    else
        componentAndGroupData.GroupData = [];
    end
    
    % get the metadata of the app
    appMetadata  = deserializer.getAppMetadata();
    
    % get the compatibility type of the app (SAME, BACKWARD, FORWARD)
    versionOfLoadedApp = appMetadata.MATLABRelease;
    compatibilityType = appdesigner.internal.serialization.util.ReleaseUtil.getCompatibilityType(versionOfLoadedApp);
    
    % create a structure for the client to handle the compatbility
    % type
    compatibilityData.CompatibilityType = char(compatibilityType);
    compatibilityData.LoadedVersion = versionOfLoadedApp;
    compatibilityData.CurrentVersion = appdesigner.internal.serialization.util.ReleaseUtil.getCurrentRelease();
    compatibilityData.MLAPPVersion = appMetadata.MLAPPVersion;
    
    % get the serialized AppName
    serializedAppName = codeData.ClassName;
    
    [~, appName] =  fileparts(filepath);
    appNameData = struct('AppName', appName, 'SerializedAppName', serializedAppName);
    
catch me
    % Error Message
    loadOutcome.Message = me.message;
    loadOutcome.Status = 'error';
end

end
