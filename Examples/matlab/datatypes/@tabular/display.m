function display(obj, varargin) %#ok<DISPLAY> Showing extra information.
% DISPLAY table.

% Copyright 2016 The MathWorks, Inc

% Check if the table being displayed is bound to a variable.
if nargin == 1
    name = inputname(1);
else
    name = varargin{1};
end
namedCall = ~isempty(name);

if feature('SuppressCommandLineOutput')
    if ~namedCall
        name = '';
    end
    matlab.internal.language.signalVariableDisplay(obj, name)
else
    compactFormat = strcmp(matlab.internal.display.formatSpacing,'compact');

    if compactFormat
        newline = '\n';
    else
        newline = '\n\n';
    end

    % If display is directly called, no varname is supplied.
    if ~namedCall
        varEquals = '';
    else
        varEquals = [sprintf('%s =', name) newline];
    end

    header = matlab.internal.display.getHeader(obj);
    
    %Ensure consistent formatting for special cases.
    if ~compactFormat && namedCall
        fprintf('\n');
    end
    
    %Build full printed header.
    fprintf([varEquals header newline]);
    disp(obj);
end