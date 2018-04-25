function varargout = uifigure(varargin)
%UIFIGURE Create UI figure window
%    UIFIGURE creates a UI figure using default property values configured
%    for building apps in App Designer.
%
%    UIFIGURE(Name, Value) specifies properties using one or more Name,
%    Value pair arguments.
%
%    fig = UIFIGURE(___) returns the figure object, fig. Use this
%    option with any of the input argument combinations in the previous
%    syntaxes.
%
%    Example 1: Create Default UI figure
%       uifigure;
%
%    Example 2: Create a UI figure with a specific title.
%       fig = uifigure('Name', 'Plotted Results');
%
%    See also UIPANEL, UITAB, UITABGROUP, UIBUTTONGROUP
%
%    Copyright 2017 The MathWorks, Inc.

nargoutchk(0,1);

% disable shadow warnings
warningState = warning('off', 'MATLAB:dispatcher:nameConflict');

% store path, then add the current directory
originalPath = addpath(pwd);

% store pwd, then cd to native uifigure
originalDir = cd(fullfile(matlabroot, 'toolbox', 'matlab', 'uitools', 'uicomponents', 'components'));

% Remove the 'defaultfigurecolor' set by MATLAB Online
% As MATLAB Online has use case of figures to come in white background
% as setting the 'defaultfigurecolor' set value to the root and all figures
% inlcusing the 'uifigures' show up in white as backgroundcolor
if(isfield(get(0, 'default'), 'defaultFigureColor'))
    originalColor = get(0, 'DefaultFigureColor');
    %remove the default color only if it is white
    if(isequal(originalColor, [1 1 1]))
        set(0, 'DefaultFigureColor', 'remove');
        % save the original color to reset it as we removed it
        resetColor = onCleanup(@()colorCleanup(originalColor));
    end
end

% on function exit, run cleanup
c = onCleanup(@()cleanup(originalPath, originalDir, warningState));

% validate the browser for mlapp
% we make the varibale valid as persistent as in MO the jave code
% for verification 'getClientTypeProperties' throws error on subsequent
% runs
persistent valid;
if(isempty(valid))
    % validate browser
    valid = validateBrowser();
end

% call native uifigure on valid browser else throw error msg
if(valid)
   window = uifigure(varargin{:});
else
  throwAsCaller(MException(message('MATLAB:ui:uifigure:UnsupportedBrowserUIFigure')));
end

if (nargout > 0)
    varargout{1} = window;
end

end

function out = validateBrowser()
% validate the browser in which MATLAB Online is launched

import com.mathworks.matlabserver.workercommon.client.*;
clientServiceRegistryFacade = ClientServiceRegistryFactory.getClientServiceRegistryFacade();
userManager = clientServiceRegistryFacade.getUserManager();

prop = userManager.getClientTypeProperties();

browser = prop.get('BROWSER');

browserVer = prop.get('BROWSER_VER');
% add special check for Browser verison as for IE11 and Edge the api returns same browser name
if (strcmp(browser, 'Google Chrome') || (strcmp(browser, 'Microsoft Internet Explorer')) && ~contains(browserVer, 'Edge'))
    out = true;
else
    out = false;
end

end

function cleanup(originalPath, originalDir, warningState)
%restore the path for MATLAB Online

% restore the original path
path(originalPath);

% cd back, reinstate warning state
cd (originalDir);
warning(warningState);

end

function colorCleanup(originalColor)
%reset the 'defaultFigureColor'

set(0, 'DefaultFigureColor', originalColor);

end

