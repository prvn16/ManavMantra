% Copyright 2016 The MathWorks, Inc.
function showSupportPackagesForBaseProducts(baseProductBaseCodes, entryPointIdentifier)
    try
        narginchk(2,2);
        com.mathworks.addons.AddonsLauncher.showSupportPackagesInExplorerForBaseProductBaseCodes(baseProductBaseCodes, entryPointIdentifier);
    catch exception
        showError(exception);
    end
end