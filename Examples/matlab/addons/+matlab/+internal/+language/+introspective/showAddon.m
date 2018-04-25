%  Copyright 2014-2016 The MathWorks, Inc.
function showAddon(baseCode, funcName)
    idForUsageDataAnalytics = 'tripwire';  % required for Omniture tracking(g1476851)
    if nargin == 2
        com.mathworks.addons.AddonsLauncher.showDetailPageInExplorerForProductWithFunctionFocused(baseCode, funcName, idForUsageDataAnalytics);
    elseif nargin == 1
        com.mathworks.addons.AddonsLauncher.showDetailPageInExplorerFor(baseCode, idForUsageDataAnalytics);
    end
end
