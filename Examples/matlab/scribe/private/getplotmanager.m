function h = getplotmanager(peekflag)
% This internal helper function may be removed in a future release.

% Copyright 2010-2014 The MathWorks, Inc.

%   H = GETPLOTMANAGER
%   With no arguments, returns the singleton plotmanager. If no plotmanager
%   was previously created, one will be created. 
%
%   H = GETPLOTMANAGER('-peek') 
%   The '-peek' flag by-passes plotmanager creation so that no plotmanager
%   objects is implicitly created. This syntax will return an
%   empty output if no plotmanager object was previously instantiated.
%
%   The following example adds a listener to the plotmanager singleton
%   which is updates in response to selection of a graphic object in any
%   figure
%
%   plotmgr = feval(graph2dhelper('getplotmanager'));
%   li = event.listener(plotmgr,'PlotSelectionChange',@(es,ed) disp(ed));

mlock;
persistent pmCreated;

if nargin==1 && strcmp(peekflag,'-peek') && isempty(pmCreated)
    h = [];
    return
end

pm = matlab.graphics.internal.PlotManager.getInstance;
pmCreated = true;
h = pm;
