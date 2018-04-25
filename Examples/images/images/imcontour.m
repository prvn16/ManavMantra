function [c,h] = imcontour(varargin)
%IMCONTOUR Create contour plot of image data.
%   IMCONTOUR(I) draws a contour plot of the intensity image I,
%   automatically setting up the axes so their orientation and aspect ratio
%   match the image.
%
%   IMCONTOUR(I,N) draws a contour plot of the intensity image I,
%   automatically setting up the axes so their orientation and aspect ratio
%   match the image. N is the number of equally spaced contour levels in
%   the plot; if you omit the argument, the number of levels and the values
%   of the levels are chosen automatically.
%
%   IMCONTOUR(I,V) draws a contour plot of I with contour lines at the data
%   values specified in vector V. The number of contour levels is equal to
%   length(V).
%
%   IMCONTOUR(X,Y,...) uses the vectors X and Y to specify the x- and
%   y-axis limits.
%
%   IMCONTOUR(...,LINESPEC) draws the contours using the line type and
%   color specified by LINESPEC. Marker symbols are ignored.
%
%   [C,H] = IMCONTOUR(...) returns the contour matrix C and a handle H to the
%   hggroup object containing the patch objects in the plot. You can use the
%   CLABEL function with C and H to add contour labels to the plot.
%
%   Class Support
%   -------------
%   The input image can be uint8, uint16, int16, double, single, or logical.
%
%   Example
%   -------
%       I = imread('circuit.tif');
%       imcontour(I,3)
%
%   See also CLABEL, CONTOUR.

%   Copyright 1992-2017 The MathWorks, Inc.

[x,y,a,extra_args] = ParseInputs(varargin{:});

extra_args = matlab.images.internal.stringToChar(extra_args);
if (nargout == 0)
    contour(x,y,a,extra_args{:});
else
    [c,h] = contour(x,y,a,extra_args{:});
end

if ~ishold
    axis ij
    axis image
end

%%%
%%% ParseInputs
%%%
function [x,y,a,extra_args] = ParseInputs(varargin)

narginchk(1,Inf);

extra_args = {};

switch nargin
    case 1
        % IMCONTOUR(A)
        a = varargin{1};
        positionA = 1;
        x = 1:size(a,2); y = 1:size(a,1);
        
    case 2
        % IMCONTOUR(A,LINESPEC)
        % IMCONTOUR(A,N)
        % IMCONTOUR(A,V)
        a = varargin{1};
        positionA = 1;
        x = 1:size(a,2); y = 1:size(a,1);
        extra_args{1} = varargin{2};
        
    case 3
        if (ischar(varargin{3}) || ...
                isstring(varargin{3}) && isscalar(varargin{3}))
            % IMCONTOUR(A,N,LINESPEC)
            % IMCONTOUR(A,V,LINESPEC)
            a = varargin{1};
            positionA = 1;
            x = 1:size(a,2); y = 1:size(a,1);
            extra_args = varargin(2:3);
            
        else
            % IMCONTOUR(X,Y,A)
            x = varargin{1};
            y = varargin{2};
            a = varargin{3};
            positionA = 3;
        end
        
    otherwise
        % IMCONTOUR(X,Y,I,N)
        % IMCONTOUR(X,Y,I,V)
        % IMCONTOUR(X,Y,I,LINESPEC)
        % IMCONTOUR(X,Y,I,N,LINESPEC)
        % IMCONTOUR(X,Y,I,V,LINESPEC)
        x = varargin{1};
        y = varargin{2};
        a = varargin{3};
        positionA = 3;
        extra_args = varargin(4:end);
end

validateattributes(a,{'uint8','int16','uint16','double','logical','single'}, ...
              {'real','2d','nonsparse'},...
              mfilename, 'I', positionA);

% Make sure x,y are vectors.
if all(size(x)==size(a)), x = x(1,:); end
if all(size(y)==size(a)), y = y(:,1); end

% If x and y are two-element vectors, make them be the
% same size as a.
x = x(:);
y = y(:);
if (length(x) ~= size(a,2))
    if (length(x) ~= 2)
        error(message('images:imcontour:invalidSize', 'X'))
    end
    x = linspace(x(1), x(end), size(a,2));
end
if (length(y) ~= size(a,1))
    if (length(y) ~= 2)
        error(message('images:imcontour:invalidSize', 'Y'))
    end
    y = linspace(y(1), y(end), size(a,1));
end

if ~isa(a, 'double')
   a = single(a);
end
