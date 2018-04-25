% Copyright 2016 The MathWorks, Inc.
function showAllHardwareSupportPackages(entryPointIdentifier)
    try
        narginchk(1,1);
        com.mathworks.addons.AddonsLauncher.showExplorerViewForHardwareSupportPackages(entryPointIdentifier);
    catch exception
        showError(exception);
    end
end