function packages = getInstalledSpPkgProducts()
%PACKAGES = getInstalledSpPkgProducts - An internal utility function to
%return a list of installed support package data from support package root.
% This function is used by AddOn Manager to retrieve installed support
% package data for display. This function is called on MATLAB startup and
% when the installed support package information has changed.
% 
% PACKAGES is a struct array with the following fileds:
% * BaseCode 
% * Version
% * FullName
% * InstalledDate
% * Visible
% * SupportCategory

% Copyright 2016 MathWorks Inc.

% We don't want to propagate any errors since this would bubble up to the
% user as a MATLAB desktop java exception
try
    spRoot = matlabshared.supportpkg.internal.getSupportPackageRootNoCreate();
catch
    spRoot = '';
end
installedPackages = com.mathworks.install.InstalledProductFactory.getInstalledProducts(spRoot);


packages = repmat(struct('BaseCode', '', ...
                  'Version', '', ...
                  'FullName', '', ...
                  'InstalledDate', '', ...
                  'Visible', '', ...
                  'SupportCategory', ''), 1, installedPackages.size());
for i = 1:installedPackages.size()
   installedSp = installedPackages.get(i-1);
   packages(i).BaseCode = char(installedSp.getBaseCode());
   packages(i).Version = char(installedSp.getVersion());
   packages(i).FullName = char(installedSp.getName());
   packages(i).InstalledDate = installedSp.getInstalledDate();
   packages(i).SupportCategory = matlab.supportpackagemanagement.internal.util.getSupportCategoryForBaseCode(packages(i).BaseCode);
   packages(i).Visible = matlab.supportpackagemanagement.internal.util.isSupportPackageVisible(packages(i).BaseCode);
end
end