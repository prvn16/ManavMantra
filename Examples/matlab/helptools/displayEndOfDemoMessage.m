function displayEndOfDemoMessage(filename)
%displayEndOfDemoMessage Explain how to get more information about a demo.
%   displayEndOfDemoMessage(mfilename) shows a link to the published HTML
%   version of a MATLAB code file written using cells.  Enable Cell Mode
%   using the Cell menu in the MATLAB Editor.
%
%   The message only displays when the file is run top-to-bottom.  When
%   publishing or evaluating as cells, this function does nothing.

% Copyright 2005-2015 The MathWorks, Inc.

% Check nargin explicitly, so we throw an error even in -nodesktop mode.
narginchk(1,1)

filename = char(filename);

% Do nothing unless:
if matlab.internal.display.isHot && ... the caller wants links (PUBLISH doesn't)
        ~isempty(filename) && ... we're not in Cell Mode in the Editor
        ~strcmp(filename,'echodemo') % we're in playback with ECHODEMO
        cmd = ['matlab:showdemo ' filename];
        msg = getString(message('MATLAB:displayEndOfDemoMessage:Message',cmd,filename));
    fprintf('\n');
    fprintf('\n');
    fprintf('-------------------------------------------------------------------------\n');
    fprintf('\n');
    fprintf(' %s\n',msg);
    fprintf('\n');
    fprintf('-------------------------------------------------------------------------\n');
    fprintf('\n');
end
