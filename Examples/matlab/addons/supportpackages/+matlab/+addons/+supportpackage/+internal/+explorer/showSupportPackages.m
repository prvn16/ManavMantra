% Copyright 2016 The MathWorks, Inc.
function showSupportPackages(supportPackageBaseCodes, entryPointIdentifier)
    try
        narginchk(2,2);
        if ischar(supportPackageBaseCodes)
            com.mathworks.addons.AddonsLauncher.showDetailPageInExplorerFor(supportPackageBaseCodes, entryPointIdentifier);
        elseif iscellstr(supportPackageBaseCodes)
            com.mathworks.addons.AddonsLauncher.showSupportPackagesInExplorerForSupportPackageBaseCodes(supportPackageBaseCodes, entryPointIdentifier);
        end
    catch exception
        showError(exception);
    end
end