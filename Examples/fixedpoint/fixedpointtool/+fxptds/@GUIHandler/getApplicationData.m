function appData = getApplicationData(~)
%% GETAPPLICATIONDATA function returns the application data of the top model 
% in context of fixed point tool

% Copyright 2016 The MathWorks, Inc.

    % Initialize appData to empty
    appData  = [];
    
    % get fixed point tool instance
    me = fxptui.getexplorer;
    if ~isempty(me)
        % if FPT is open, query for top node
        model = me.getTopNode.getDAObject.getFullName;
        
        % query for application data of the model
        appData = SimulinkFixedPoint.getApplicationData(model);
    end
end