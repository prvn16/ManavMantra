function enableAddon (Identifier)

% enableAddon Enable an add-on
%
%   matlab.addons.enableAddon(IDENTIFIER) enables
%   the add-on with the specified IDENTIFIER.
%
%   IDENTIFIER is the unique identifier of the add-on to be enabled, 
%   specified as a string or character vector. To determine the 
%   unique identifier of an add-on, use the 
%   matlab.addons.installedAddons function.
%
%   Example: Get list of installed add-ons and enable the 
%   first add-on in list
%
%   addons = matlab.addons.installedAddons;
%
%   matlab.addons.enableAddon(addons.Identifier(1))
%
%   See also: matlab.addons.disableAddon,
%   matlab.addons.installedAddons,
%   matlab.addons.isAddonEnabled

% Copyright 2017 The MathWorks Inc.

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
    
    for matlabPathIndex = 1:length(matlabPathEntries)
        matlabPathEntry = char(matlabPathEntries(matlabPathIndex));
        addpath(matlabPathEntry, '-end');
    end
    
    installedAddon.setEnabled(true);
    installedAddonsCache.updateAddonState(installedAddon, true);
    
    javaClassPathEntries = retrieveCustomMetadataWithName(installedAddon, 'javaClassPathEntries');
    
    for javaClassPathIndex = 1:length(javaClassPathEntries)
        javaClassPathEntry = char(javaClassPathEntries(javaClassPathIndex));
        javaaddpath(javaClassPathEntry, '-end');
    end
    
    AddonServiceManager.register(installedAddon);
    
    relatedAddOnIdentifiers = installedAddon.getRelatedAddOnIdentifiers();
    for relatedIdentifierIndex = 1: length(relatedAddOnIdentifiers)
        relatedAddonIdentifier = relatedAddOnIdentifiers(relatedIdentifierIndex);
        relatedAddon = installedAddonsCache.retrieveAddOnWithIdentifier(relatedAddonIdentifier);
        AddonServiceManager.register(relatedAddon);
        relatedAddon.setEnabled(true);
        installedAddonsCache.updateAddonState(relatedAddon, true);
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