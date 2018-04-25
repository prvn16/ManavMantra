function addons = installedAddons

% installedAddons Return list of installed add-ons
%
%   ADDONS = matlab.addons.installedAddons returns a list of 
%   currently installed add-ons, specified as a table of strings 
%   with these fields:
% 
%           Name - Name of the add-on
%        Version - Version of the add-on
%           Guid - Unique identifier of the add-on
% 
%   Example:  Get list installed add-ons
% 
%   addons = matlab.addons.installedAddons
%
%   addons =
%
%   1x3 table
%
%                      Name                           Version                   Identifier
%   _____________________________________________    _________    ______________________________________
%
%   "Simulink"                                       "R2017b"     "SL"
%
%   See also: matlab.addons.disableAddon,
%   matlab.addons.enableAddon,   
%   matlab.addons.isAddonEnabled

% Copyright 2017 The MathWorks Inc.

import com.mathworks.addons_common.notificationframework.InstalledAddOnsCache;

addons = table;

addonsStruct = struct([]);

try
    
    installedAddonsCache = InstalledAddOnsCache.getInstance;
    installedAddonsAsArray = installedAddonsCache.getInstalledAddonsAsArray();
    
    for addonIndex = 1:length(installedAddonsAsArray)
        installedAddon = installedAddonsAsArray(addonIndex);
        addonsStruct(addonIndex).Name = string(installedAddon.getName());
        addonsStruct(addonIndex).Version = string(installedAddon.getVersion());
        addonsStruct(addonIndex).Identifier = string(installedAddon.getIdentifier());
    end
    
    if size(addonsStruct) > 0
        addons = struct2table(addonsStruct);
    end
    
catch ex
    error(ex.identifier, ex.message);
end

end