function doEnablePlotBrowserListeners(fig,state)
% This undocumented function may be removed in a future release.

%   Copyright 2013 The MathWorks, Inc.

if ~isscalar(fig) || ~isprop(fig,'PlotBrowserListener') || isempty(fig.PlotBrowserListener) || ...
        ~isfield(fig.PlotBrowserListener,'Listener')
    return
end

% Handle udd vs MCOS listeners
if isobject(fig.PlotBrowserListener.Listener)
    fig.PlotBrowserListener.Listener.Enabled = state;
    if isfield(fig.PlotBrowserListener,'ObjectProps') && ~isempty(fig.PlotBrowserListener.ObjectProps)
        for k=1:length(fig.PlotBrowserListener.ObjectProps)
            fig.PlotBrowserListener.ObjectProps(k).DisplayNameListener.Enabled = state;
        end
    end
else
    set(fig.PlotBrowserListener.Listener,'Enabled',state);
end
