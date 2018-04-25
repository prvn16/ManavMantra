function disableAddon (Identifier)

% disableAddon Disable an add-on
%
%   matlab.addons.disableAddon(IDENTIFIER) disables
%   the add-on with the specified IDENTIFIER.
%
%   IDENTIFIER is the unique identifier of the add-on to be disabled, 
%   specified as a string or character vector. To determine the 
%   unique identifier of an add-on, use the 
%   matlab.addons.installedAddons function.
%
%   Example: Get list of installed add-ons and disable the 
%   first add-on in list
%
%   addons = matlab.addons.installedAddons;
%
%   matlab.addons.disableAddon(addons.Identifier(1))
%
%   See also: matlab.addons.enableAddon,
%   matlab.addons.installedAddons,
%   matlab.addons.isAddonEnabled

% Copyright 2017-2018 The MathWorks Inc.

import com.mathworks.addons_common.notificationframework.InstalledAddOnsCache;
import com.mathworks.addon_service_management_api.AddonServiceManager;

narginchk(1, 1);

try
    installedAddonsCache = InstalledAddOnsCache.getInstance;
    installedAddon = installedAddonsCache.retrieveAddOnWithIdentifier(Identifier);
    
    if ~installedAddon.isEnableDisableSupported()
        error(message('matlab_addons:enableDisableManagement:notSupported'));
    end
    
    matlabPathEntries = retrieveCustomMetadataWithName(installedAddon, 'matlabPathEntries');
    matlab.internal.addons.removeFromMatlabPath(matlabPathEntries);
   
    installedAddon.setEnabled(false);
    installedAddonsCache.updateAddonState(installedAddon, false);
    
    javaClassPathEntries = retrieveCustomMetadataWithName(installedAddon, 'javaClassPathEntries');
    matlab.internal.addons.removeFromJavaClasspath(javaClassPathEntries);
    
    AddonServiceManager.unregister(installedAddon);
    
    relatedAddOnIdentifiers = installedAddon.getRelatedAddOnIdentifiers();
    for relatedIdentifierIndex = 1: length(relatedAddOnIdentifiers)
        relatedAddonIdentifier = relatedAddOnIdentifiers(relatedIdentifierIndex);
        relatedAddon = installedAddonsCache.retrieveAddOnWithIdentifier(relatedAddonIdentifier);
        AddonServiceManager.unregister(relatedAddon);
        relatedAddon.setEnabled(false);
        installedAddonsCache.updateAddonState(relatedAddon, false);
    end
    
catch ex
    if isprop(ex, 'ExceptionObject') && ...
            ~isempty(strfind(ex.ExceptionObject.getClass, 'IdentifierNotFoundException'))
        error(message('matlab_addons:enableDisableManagement:invalidIdentifier'));
    else
        error(ex.identifier, ex.message);
    end
end

    function contains = cellContains (cellEntries, entryToCheck)
        if ispc  % Windows is not case-sensitive
            contains = any(strcmpi(entryToCheck, cellEntries));
        else
            contains = any(strcmp(entryToCheck, cellEntries));
        end
    end
end