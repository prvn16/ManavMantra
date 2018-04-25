function isEnabled = isAddonEnabled(Identifier)

% isAddonEnabled Return the enabled state of an add-on
%
%   ISENABLED = matlab.addons.isAddonEnabled(IDENTIFIER) returns true 
%   if the specified add-on is enabled and false otherwise.
%
%   IDENTIFIER is the unique identifier of the add-on to be enabled, 
%   specified as a string or character vector. To determine the 
%   unique identifier of an add-on, use the 
%   matlab.addons.installedAddons function.
%
%   ISENABLED is a logical value indicating the 
%   enabled state of the add-on.
%
%   Example: Get list of installed add-ons and get the state 
%   for the first add-on
%
%   addons = matlab.addons.installedAddons;
%
%   isEnabled = matlab.addons.isAddonEnabled(addons.Identifier(1))
%
%   isEnabled =
%
%       logical
%
%       0
%
%   See also: matlab.addons.disableAddon,
%   matlab.addons.enableAddon,
%   matlab.addons.installedAddons

% Copyright 2017 The MathWorks Inc.

import com.mathworks.addons_common.notificationframework.InstalledAddOnsCache;

narginchk(1,1);

try
    
    isEnabled = true;
    
    installedAddonsCache = InstalledAddOnsCache.getInstance;
    
    installedAddon = installedAddonsCache.retrieveAddOnWithIdentifier(Identifier);
    
    if installedAddon.isEnableDisableSupported()
        isEnabled = installedAddonsCache.isAddonEnabled(Identifier);
    end
    
catch ex
    if isprop(ex, 'ExceptionObject') && ...
            ~isempty(strfind(ex.ExceptionObject.getClass, 'IdentifierNotFoundException'))
        error(message('matlab_addons:enableDisableManagement:invalidIdentifier'));
    else
        error(ex.identifier, ex.message);
    end
end

end