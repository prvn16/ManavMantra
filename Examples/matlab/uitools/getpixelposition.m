function position = getpixelposition(h,recursive)
% GETPIXELPOSITION Get the position of an HG object in pixel units.
%   GETPIXELPOSITION(HANDLE) gets the position of the object specified by
%   HANDLE in pixel units.
%
%   GETPIXELPOSITION(HANDLE, RECURSIVE) gets the position as above. If
%   RECURSIVE is true, the returned position is relative to the parent
%   figure of HANDLE.
%
%   POSITION = GETPIXELPOSITION(...) returns the pixel position in POSITION.
%
%   Example:
%       f = figure;
%       p = uipanel('Position', [.2 .2 .6 .6]);
%       h1 = uicontrol(p, 'Units', 'normalized', 'Position', [.1 .1 .5 .2]);
%       % Get pixel position w.r.t the parent uipanel
%       pos1 = getpixelposition(h1)
%       % Get pixel position w.r.t the parent figure using the recursive flag
%       pos2 = getpixelposition(h1, true)
%
%   See also SETPIXELPOSITION, UICONTROL, UIPANEL

% Copyright 1984-2013 The MathWorks, Inc.

% Verify that getpixelposition is given between 1 and 2 arguments
narginchk(1, 2);

% Verify that "h" is a handle
if ~ishghandle(h)
    error(message('MATLAB:getpixelposition:InvalidHandle'))
end

if nargin < 2
    recursive = false;
end

position = getPixelPositionHelper(h,recursive);


