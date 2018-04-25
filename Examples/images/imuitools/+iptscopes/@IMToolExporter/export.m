function varargout = export(this)
%EXPORT Export to Image Tool (IMTool)

%   Copyright 2007-2015 The MathWorks, Inc.

hScope = this.Application;
hSrc   = hScope.DataSource;
hVideo = getExtension(this, 'Visuals', 'Video');

cMap = hVideo.ColorMap.Map; %#ok<NASGU>
dRange = get(hVideo.Axes,'CLim'); %#ok<NASGU>

% Invoke IMTool such that the title bar of IMTool indicates the frame
% number being exported.  To do this, we first create a variable with the
% desired name, then launch IMTool on that variable.  Hence, the title must
% conform to a legal MATLAB variable name and it must not conflict with
% any other local variables in this context
if isa(hSrc,'Simulink.scopes.source.WiredSource')
    % For wired source, we need to get info from the source itself instead of data handler
    varName = sprintf('%s_%.3f', hSrc.NameShort, getTimeOfDisplayData(hSrc));
    varName = uiservices.generateVariableName(varName);
else
    varName = getExportFrameName(hSrc.DataHandler);
end

% Create variable with this name:
eval([varName ' = get(hVideo.Image, ''CData'');']);

% If IMTOOL is already open, close it
% What we really want is to "reload" the copy of IMTOOL
% with new data, if we launched previously launched
% it ourselves.

if ~getValue(this.Config.PropertyDb, 'NewIMTool') && ishghandle(this.IMTool)
    % The closest we can come to "reusing" the latest IMTool window
    % is to close the latest and open a new one.  The position will
    % shift to the default position, and it will be slow to do
    % this.
    close(this.IMTool);
    this.IMTool = -1;
end

% Launch IMTool on this variable
try

    % Only retain the "most recently opened" IMTool handle
    imtoolCommand = ['imtool(' varName ','...
        '''ColorMap'',cMap,'...
        '''DisplayRange'',dRange);'];
    this.IMTool = eval(imtoolCommand);

catch ME
    error(message('images:imtool:imtoolCallFailed', ME.message));
end

if nargout
    varargout = {this.IMTool};
end

% [EOF]
