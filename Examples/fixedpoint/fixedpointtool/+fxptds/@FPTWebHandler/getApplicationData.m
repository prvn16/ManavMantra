function appData = getApplicationData(~)
%% GETAPPLICATIONDATA function returns the application data of the top model 
% in context of fixed point tool

% Copyright 2016 The MathWorks, Inc.
    
    appData = [];   
    % Initialize appData to empty
    model = fxptui.getTopModelFromFPT;
    
    if ~isempty(model)
        % query for application data of the model
        appData = SimulinkFixedPoint.getApplicationData(model);
    end
end