function out = isHardwareGraphics(renderer)
%ISHARDWAREGRAPHICS MATLAB using hardware accelerated OpenGL
% matlab.graphics.internal.isHardwareGraphics() 
% returns true if the OpenGL renderer is hardware accelerated
% returns false if the OpenGL renderer is not hardware accelerated
%
% See also OPENGL

%   Copyright 2013 The MathWorks, Inc.

% matlab.graphics.internal.isHardwareGraphics(S)
% S is a string with the name of the renderer as obtained by 
% temp = opengl('data');
% s = temp.Renderer
% returns false if S is found a list of common software renderers
% returns true if S is not found a list of common software renderers
%
%

narginchk(0,1);

if (nargin==0)
    % If no input was provided
    % get it from opengl data
    temp = opengl('data');
    renderer = temp.Renderer;
else
    %Validate the input
    validateInput(renderer)
end

% It is easier to ask the
% opposite question i.e.
% is it software renderer
% 
% If yes, return false
% If no, return true
out = ~isSoftwareGraphics(renderer);
end


function validateInput(renderer)
% Input must be a single row char array
p = inputParser;
p.addRequired('renderer',...
    @(x) ischar(x) && ( isrow(x) || isempty(x) ) );
p.parse(renderer);
end

% A helper function to determine if MATLAB
% is using software opengl
% Note we do not rely on the Software
% field returned by opengl('data') because
% this only checks if MATLAB was started using 
% the -softwareopengl flag or the command
% opengl software was executed.
% This looks at a list of known software renderers
function out = isSoftwareGraphics(renderer)
out = true;
% I do not think opengl('data')
% returns empty, but just in case.
if isempty(renderer)
    return;
end

% List of software renderers
swRenderers = {'Mesa',...
               'GDI',...
               'Software',...
               'none'};

% Search
result = regexpi(renderer,swRenderers);

% If result is empty, we did not find any
if isempty([result{:}])    
    % Is not software
    out = false;
    return;
end

end








