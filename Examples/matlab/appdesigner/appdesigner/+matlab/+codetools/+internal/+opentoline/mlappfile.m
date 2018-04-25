function mlappfile(file, linenumber, column, ~) 
% This function is internal and may change in future releases.

% Plug-in for the opentoline function for MATLAB app files.

% Copyright 2014 - 2015, The MathWorks, Inc.

% The column input argument is optional (g1268749)
if nargin == 2
    column = 1;
end

% Get AppCodeTool instance 
appCodeTool = appdesigner.internal.application.getAppCodeTool();

% Process GoToLineColumn request to open app in App Designer
appCodeTool.processGoToLineColumn(file, linenumber, column);

end