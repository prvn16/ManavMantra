function h = DiffPlot(methodSelection)

h = fxptui.DiffPlot;
if strcmpi(methodSelection,'comparesignals') || strcmpi(methodSelection,'compareruns') ...
        || strcmpi(methodSelection,'selectchannel') || strcmpi(methodSelection,'selectchannelforcomparesignals') ...
        || strcmpi(methodSelection,'selectchannelforcompareruns')
    h.methodSelection = methodSelection;
end

