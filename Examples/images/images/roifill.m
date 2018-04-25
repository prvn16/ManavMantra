function varargout = roifill(varargin)
%ROIFILL Fill in specified polygon in grayscale image.
%
%   ROIFILL is not recommended. Use REGIONFILL instead.
%
%   Use ROIFILL to fill in a specified polygon in a grayscale
%   image. ROIFILL smoothly interpolates inward from the pixel values on the
%   boundary of the polygon by solving Laplace's equation. ROIFILL can be
%   used, for example, to erase objects in an image.
%
%   J = ROIFILL creates an interactive polygon tool, associated with the
%   image displayed in the current figure, called the target image. You
%   place the tool interactively, using the mouse to specify the vertices of
%   the polygon. Double-click to add a final vertex to the polygon and close
%   the polygon. Right-click to close the polygon without adding a
%   vertex. You can adjust the position of the polygon and individual
%   vertices in the polygon by clicking and dragging.
%
%   To add new vertices, position the pointer along an edge of the polygon
%   and press the "A" key. The pointer changes shape. Left-click to add a
%   vertex at the specified position.
%
%   After positioning and sizing the polygon, fill the region by
%   either double-clicking over the polygon or choosing Fill Area from
%   the tool's context menu. ROIFILL returns J, a version of the image
%   with the region filled.
%
%   To delete the polygon, press Backspace, Escape or Delete, or choose the
%   Cancel option from the context menu.  If the polygon is deleted, all
%   return values are set to empty.
%
%   J = ROIFILL(I) displays the image I and creates an interactive polygon
%   tool associated with that image.
%
%   J = ROIFILL(I,C,R) fills the polygon specified by C and R, which are
%   equal-length vectors containing the row-column coordinates of the pixels
%   on vertices of the polygon. The k-th vertex is the pixel (R(k),C(k)).
%
%   J = ROIFILL(I,BW) uses BW (a binary image the same size as I) as a
%   mask. ROIFILL fills in the regions in I corresponding to the nonzero
%   pixels in BW.  It does this by interpolating inward from the pixel
%   values corresponding to the boundary of the nonzero region in BW. The
%   boundary pixel values are not modified. If there are multiple regions,
%   ROIFILL performs the interpolation on each region independently.
%
%   [J,BW] = ROIFILL(...) returns the binary mask used to determine which
%   pixels in I get filled. BW is a binary image the same size as I with 1's
%   for pixels corresponding to the interpolated region of I and 0's
%   elsewhere.
%
%   J = ROIFILL(x,y,I,xi,yi) uses the vectors x and y to establish a
%   nondefault spatial coordinate system. xi and yi are equal-length vectors
%   that specify polygon vertices as locations in this coordinate system.
%
%   [x,y,J,BW,xi,yi] = ROIFILL(...) returns the XData and YData in x and y;
%   the output image in J; the mask image in BW; and the polygon coordinates
%   in xi and yi. xi and yi are empty if the ROIFILL(I,BW) form is used.
%
%   If ROIFILL is called with no output arguments, the resulting image is
%   displayed in a new figure.
%
%   Class Support
%   -------------
%   The input image I can be uint8, uint16, int16, single, or double.  The
%   input binary mask BW can be numeric or logical. The output binary mask BW
%   is always logical. The output image J has the same class as I. All other
%   inputs and outputs are double.
%
%   Example
%   -------
%       I = imread('eight.tif');
%       c = [222 272 300 270 221 194];
%       r = [21 21 75 121 121 75];
%       J = roifill(I,c,r);
%       figure, imshow(I), figure, imshow(J)
%
%   See also IMPOLY, REGIONFILL, ROIFILT2, ROIPOLY.

%   Copyright 1993-2014 The MathWorks, Inc.

[xdata,ydata,I,xi,yi,mask,newFig,placement_cancelled] = ParseInputs(varargin{:});

% return empty if user cancels operation
if placement_cancelled
    varargout = repmat({[]},nargout,1);
    return;
end

% initialize result
result = I;

% Find the perimeter pixels of the specified region; these will
% be used to form the boundary conditions for the soap film PDE.
perimeter = bwperim(mask);

% Find the interior pixels; these are the pixels that will be
% replaced in the output image.
interior = mask & ~perimeter;

% Number the interior pixels in a grid matrix.
idx = find(interior);

if ~isempty(idx)
    grid = zeros(size(mask));
    grid(idx) = 1:length(idx);

    % Use the boundary pixels to form the right side of the linear system.
    [M,N] = size(grid);

    % Get the perimeter values.
    perimValues = zeros(M,N);
    perimIdx = find(perimeter);
    perimValues(perimIdx) = I(perimIdx);

    rightside = zeros(M,N);
    rightside(2:(M-1),2:(N-1)) = perimValues(1:(M-2),2:(N-1)) + ...
        perimValues(3:M,2:(N-1)) + perimValues(2:(M-1),1:(N-2)) + ...
        perimValues(2:(M-1),3:N);
    rightside = rightside(idx);

    % Form the sparse D matrix from the numbered nodes of the grid matrix.
    % This part is borrowed from toolbox/matlab/demos/delsq.m.
    % Connect interior points to themselves with 4's.
    i = grid(idx);
    j = grid(idx);
    s = 4*ones(size(idx));

    % for k = north, east, south, west
    for k = [-1 M 1 -M]
        % Possible neighbors in the k-th direction
        Q = grid(idx+k);
        % Index of points with interior neighbors
        q = find(Q);
        % Connect interior points to neighbors with -1's.
        i = [i; grid(idx(q))]; %#ok<AGROW>
        j = [j; Q(q)]; %#ok<AGROW>
        s = [s; -ones(length(q),1)]; %#ok<AGROW>
    end
    D = sparse(i,j,s);

    % Solve the linear system.
    x = D \ rightside;
    result(idx) = x;
end

switch nargout
    case 0
        % ROIFILL(...)

        if (newFig)
            figure;
        end
        if (~isequal(xdata, [1 size(result,2)]) || ...
                ~isequal(ydata, [1 size(result,1)]))
            imshow(result,'XData',xdata,'YData',ydata);
        else
            imshow(result);
        end

    case 1
        % J = ROIFILL(...)

        varargout{1} = result;

    case 2
        % [J,MASK] = ROIFILL(...)

        varargout{1} = result;
        varargout{2} = mask;

    otherwise
        % [X,Y,J,...] = ROIFILL(...)

        varargout{1} = xdata;
        varargout{2} = ydata;
        varargout{3} = result;

        if (nargout >= 4)
            % [X,Y,J,MASK,...] = ROIFILL(...)
            varargout{4} = mask;
        end

        if (nargout >= 5)
            % [X,Y,J,MASK,Xi,...] = ROIFILL(...)
            varargout{5} = xi;
        end

        if (nargout >= 6)
            % [X,Y,J,MASK,Xi,Yi] = ROIFILL(...)
            varargout{6} = yi;
        end

        if (nargout >= 7)
            error(message('images:roifill:tooManyOutputArgs'));
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xdata,ydata,I,xi,yi,mask,newFig,placement_cancelled] = ParseInputs(varargin)

xi = [];
yi = [];
newFig = 0;
placement_cancelled = false;

cmenu_text = getString(message('images:roiContextMenuUIString:fillAreaContextMenuLabel'));

narginchk(0, 5);

%We check the validity of I in each case because ROIFILL should error if I
%is invalid before calling roipoly.
switch nargin
    case 0
        % ROIFILL
        [xdata, ydata, I, flag] = getimage;
        validateattributes(I, {'uint8', 'uint16', 'int16', 'single', 'double'}, ...
            {'2d', 'nonsparse'}, mfilename, 'I', 1);
        if (flag == 0)
            error(message('images:roifill:currentAxesMissingImage'));
        end
        if (flag == 1)
            error(message('images:roifill:indexedNotSupported'));
        end
        [xi,yi,placement_cancelled] = createWaitModePolygon(gca,cmenu_text);
        mask = poly2mask(xi,yi,size(I,1),size(I,2));
        newFig = 1;

    case 1
        % ROIFILL(I)

        I = varargin{1};
        validateattributes(I, {'uint8', 'uint16', 'int16', 'single', 'double'}, ...
            {'2d', 'nonsparse'}, mfilename, 'I', 1);
        xdata = [1 size(I,2)];
        ydata = [1 size(I,1)];
        imshow(I);
        [xi,yi,placement_cancelled] = createWaitModePolygon(gca,cmenu_text);
        mask = poly2mask(xi,yi,size(I,1),size(I,2));
        newFig = 1;

    case 2
        % ROIFILL(I, MASK)

        I = varargin{1};
        validateattributes(I, {'uint8', 'uint16', 'int16', 'single', 'double'}, ...
            {'2d', 'nonsparse'}, mfilename, 'I', 1);
        xdata = [1 size(I,2)];
        ydata = [1 size(I,1)];
        mask = varargin{2};
        if ~isequal(size(mask),size(I))
            error(message('images:roifill:maskMustBeSameSizeAsI'));
        end
        if ~islogical(mask) %convert to logical
            mask = mask~=0;
        end

    case 3
        % ROIFILL(I, Xi, Yi)

        I = varargin{1};
        validateattributes(I, {'uint8', 'uint16', 'int16', 'single', 'double'}, ...
            {'2d', 'nonsparse'}, mfilename, 'I', 1);
        xdata = [1 size(I,2)];
        ydata = [1 size(I,1)];
        xi = varargin{2};
        yi = varargin{3};
        checkSizeOfXiYi(xi,yi);
        [r,c] = size(I);
        mask = roipoly(r, c, xi, yi);

    case 5
        % ROIFILL(x, y, I, Xi, Yi)

        xdata = varargin{1};
        ydata = varargin{2};
        I = varargin{3};
        validateattributes(I, {'uint8', 'uint16', 'int16', 'single', 'double'}, ...
            {'2d', 'nonsparse'}, mfilename, 'I', 3);
        xi = varargin{4};
        yi = varargin{5};
        checkSizeOfXiYi(xi,yi);
        [r,c] = size(I);
        mask = roipoly(xdata, ydata, r, c, xi, yi);
end

if (min(size(I)) < 3)
    error(message('images:roifill:invalidSize'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkSizeOfXiYi(xi,yi)

XiYiAreVectors = isvector(xi) && isvector(yi);
XiYiUnequalLengths = length(xi) ~= length(yi);
if ~XiYiAreVectors || XiYiUnequalLengths
    error(message('images:roifill:xAndYNotSameSize'));
end

