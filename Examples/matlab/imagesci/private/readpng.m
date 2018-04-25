function [X,map,alpha] = readpng(filename, varargin)
%READPNG Read an image from a PNG file.
%   [X,MAP] = READPNG(FILENAME) reads the image from the
%   specified file.
%
%   [X,MAP] = READPNG(FILENAME,'BackgroundColor',BG) uses the
%   specified background color for compositing transparent
%   pixels.  By default, READPNG uses the background color
%   specified in the file, if present.  If not present, the
%   default is either the first colormap color or black.  If the
%   file contains an indexed image, BG must be an integer in the
%   range [1,P] where P is the colormap length.  If the file
%   contains a grayscale image, BG must be an integer in the
%   range [0,65535].  If the file contains an RGB image, BG must
%   be a 3-element vector whose values are in the range
%   [0,65535].
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2016 The MathWorks, Inc.

bg = parse_args(varargin{:});

if (isempty(bg) && (nargout >= 3))
    % User asked for alpha and didn't specify a background
    % color; in this case we don't perform the compositing.
    bg = 'none';
end

% Specify that the PNG image should be read starting at the beginning of
% the file.
[X, map, alpha] = readpngutil(filename, bg, 0);


%--------------------------------------------------------------------------
function bg = parse_args(param,value)

bg = [];
if nargin < 1
    return
end

% Process param/value pairs.  Only 'backgroundcolor' is recognized.
validateattributes(param,{'char'},{'nonempty'},'','BACKGROUNDCOLOR');
validatestring(param,{'backgroundcolor'});
bg = value;

return

