function installedSupportPackages = getInstalledSupportPackagesInfo()
% matlab.supportpackagemanagement.internal.getInstalledSupportPackagesInfo
% - An internal function that returns the metadata for installed support
% packages.
%
% This function is called by Add-Ons in product layer to respond to the
% 'getInstalledAddOns' request from the Add-Ons gallery

% Copyright 2015-2016 The MathWorks, Inc.

% Call internal utility function to get installed support package data
packages = matlab.supportpackagemanagement.internal.util.getInstalledSpPkgProducts();

if isempty(packages)
    installedSupportPackages = repmat( ...
        javaArray('com.mathworks.hwsmanagement.InstalledSupportPackage', 1), ... % javaArray cannot utilize Java imports
        0, 0);
    return
end

numPackages = length(packages);
installedSupportPackages = ...
    javaArray('com.mathworks.hwsmanagement.InstalledSupportPackage', ... % javaArray cannot utilize Java imports
    numPackages);

import com.mathworks.hwsmanagement.InstalledSupportPackage
for i = 1:numPackages
    % Determine whether the support package should be labeled "Hardware
    % Support Package" or "Feature"
    resourceBundle = java.util.ResourceBundle.getBundle('com.mathworks.hwsmanagement.resources.RES_AddOns_SupportPackage');
    if (strcmp(packages(i).SupportCategory, 'hardware') == 1)
        displayType = resourceBundle.getString('displayType.HardwareSupportPackage');
    else
        displayType = resourceBundle.getString('displayType.Feature');
    end
    % The isHwSetupAvailable will indicate whether this support package
    % should have the "Setup" button to launch hardware setup
    isHwSetupAvailalable = ~isempty(matlabshared.supportpkg.internal.ssi.getBaseCodesHavingHwSetup({packages(i).BaseCode}));
    % Construct the installed support package bean object via the Builder
    installedSupportPackages(i) = ...
        InstalledSupportPackage.getBuilder() ...
        .baseCode(packages(i).BaseCode) ...
        .version(packages(i).Version) ...
        .fullName(packages(i).FullName) ...
        .installedDate(java.util.Date(double(packages(i).InstalledDate))) ...
        .isVisible(packages(i).Visible) ...
        .displayType(displayType) ...
        .hasHwSetup(isHwSetupAvailalable) ...
        .createInstalledSupportPackage();
end

end

