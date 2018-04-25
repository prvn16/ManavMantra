function J = regionfill(I,varargin)
%REGIONFILL Fill in specified regions in image using inward interpolation
%   J = regionfill(I,MASK) fills the regions in image I specified by MASK. 
%   I must be a grayscale image of size 3-by-3 or larger. MASK is a binary 
%   image the same size as I. Non-zero pixels in MASK designate the pixels 
%   of image I to fill.
%
%   J = regionfill(I,X,Y) fills the region in image I corresponding to the
%   polygon whose vertices are specified by X and Y. X and Y are
%   equal-length vectors containing the X and Y coordinates, respectively,
%   of the vertices of the polygon.
%
%   Class Support
%   -------------
%   The input image I must be a 2-D numeric array of one of the following
%   classes: single, double, int8, int16, int32, uint8, uint16, uint32. It 
%   must be nonsparse and real. The output image J has the same class as I.
%   MASK must be a logical and nonsparse array. X and Y are numeric
%   vectors of class single, double, int8, int16, int32, uint8, uint16, or
%   uint32.
%
%   Note
%   ----
%   REGIONFILL smoothly interpolates inward from the pixel values on the
%   outer boundary of the regions. It computes the discrete Laplacian over
%   the regions and solves the Dirichlet boundary value problem. REGIONFILL
%   can be used, for example, to remove objects in an image or to replace 
%   invalid pixel values using their neighbors.
%
%   Example 1
%   ---------
%   Fill a polygon to remove an object from the background
%   
%       % Read a grayscale image
%       I = imread('eight.tif');
%       
%       % Specify the (x,y)-coordinates (column and row) 
%       % of the polygon vertices
%       x = [222 272 300 270 221 194];
%       y = [21 21 75 121 121 75];
%       
%       % Fill the polygon
%       J = regionfill(I,x,y);
%       
%       % Display the results
%       figure
%       subplot(1,2,1)
%       imshow(I)
%       title('Original image')
%       subplot(1,2,2)
%       imshow(J)
%       title('Image with one less coin')
%
%   Example 2
%   ---------
%   Fill regions to remove objects from the background
%
%       % Read a grayscale image
%       I = imread('eight.tif');
%       
%       % Create a mask over the coins
%       mask = I < 200;
%       % Fill holes
%       mask = imfill(mask,'holes');
%       % Remove noise
%       mask = imerode(mask,strel('disk',10));
%       mask = imdilate(mask,strel('disk',20));
%       
%       % Fill the regions in I
%       J = regionfill(I,mask);
%       
%       % Display the results
%       figure
%       subplot(1,3,1)
%       imshow(I)
%       title('Original image')
%       subplot(1,3,2)
%       imshow(mask)
%       title('Mask of pixels to fill')
%       subplot(1,3,3)
%       imshow(J)
%       title('Resulting image')
%
%   See also IMFILL, IMPOLY, POLY2MASK, ROIFILT2, ROIPOLY.

% Copyright 2014 The MathWorks, Inc.

% Check that the number of inputs is either 2 or 3
% Syntax is either regionfill(I,mask) or regionfill(I,x,y)
narginchk(2,3);

% Error checking
[I,mask] = parseInputs(I,varargin{:});

% Find the outer mask boundary pixels
maskPerimeter = findBoundaryPixels(mask);

% Fill the region in I specified by mask using maskPerimeter as boundary
% condition for Laplace's equation
J = regionfillLaplace(I,mask,maskPerimeter);
end

%--------------------------------------------------------------------------
% Check for errors in the inputs
function [I,mask] = parseInputs(I,varargin)
% Validate type of I
validInputTypes = {'single','double','int8','int16','int32','uint8','uint16','uint32'};
validateattributes(I,validInputTypes,{'nonsparse','real'}, ...
    mfilename,'I',1);
% Validate size of I
[nRow,nCol] = size(I);
% If it is a vector or a n-d matrix, n>2, throw an error
if isvector(I) || ~ismatrix(I)
    error(message('images:regionfill:mustBe2D','I'))
end
% Cannot work on images strictly smaller than 3-by-3
if nRow<3 || nCol<3
    error(message('images:regionfill:mustBeLargerThan2by2','I'))
end

switch(nargin)
    case 2
        % regionfill(I,mask)
        mask = varargin{1};
        % Validate type of mask
        validMaskTypes = {'logical','numeric'};
        validateattributes(mask,validMaskTypes,{'2d','real','nonnan', ...
            'nonsparse'}, mfilename,'MASK',2);
        % Validate size of mask
        if ~isequal(size(mask),[nRow,nCol])
            error(message('images:regionfill:mustBeSameSizeAsI', 'I'))
        end
        % Convert to logical
        mask = logical(mask); % cannot convert complex values and NaNs
    case 3
        % regionfill(I,x,y)
        x = varargin{1};
        y = varargin{2};
        % Forbid empty x or y
        if isempty(x) || isempty(y)
            error(message('images:regionfill:cannotBeEmpty','X','Y'))
        end
        % Validate type of x and y
        validateattributes(x,validInputTypes,{'real','vector','finite'},mfilename,'X',2);
        validateattributes(y,validInputTypes,{'real','vector','finite'},mfilename,'Y',3);
        % Validate size of x and y
        if length(x) ~= length(y)
            error(message('images:regionfill:vectorSizeMismatch','X','Y'))
        end
        % Warning if polygon has 2 vertices or fewer
        if length(x) < 3
            warning(message('images:regionfill:notEnoughVertices'))
        end
        % poly2mask only accepts double
        x = double(x);
        y = double(y);
        % Convert to logical mask
        mask = poly2mask(x,y,nRow,nCol);
end

end

%--------------------------------------------------------------------------
% Find the mask outer boundary pixels
% Return a logical matrix the same size as mask indicating the positions of
% the pixels to be used as boundary condition.
function maskPerimeter = findBoundaryPixels(mask)
% Create a look-up table to dilate with a cross (five-point stencil)
% Return 1 if the current pixel or at least one of its four neighbors is 1
% f = @(x) sum([x(2),x(4:6),x(8)]) > 0;
% lut = makelut(f,3);
lut = [0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;...
    1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;1;1;0;0;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;1;1;0;0;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;...
    1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1];

% Filter the input mask to generate a mask dilated by 1 pixel N,S,W,E
maskDilated = bwlookup(mask,lut);

% Find the perimeter pixels of the specified region; these will
% be used to form the boundary conditions for the soap film PDE.
maskPerimeter = maskDilated & ~mask;
end

%--------------------------------------------------------------------------
% Fill the region in I specified by mask using maskPerimeter as boundary
% condition for Laplace's equation
function J = regionfillLaplace(I,mask,maskPerimeter)
% If mask==ones(size(I))
if all(all(mask))
    % Warn the user that there are no boundary pixels
    % The returned image will be all black because the right side of the
    % equation is all zeros
    warning(message('images:regionfill:maskIsAllWhite'))
end

% Initialize output
J = I;

% Image size
[nRow,nCol] = size(I);

% Form the right side of the equation
rightSide = formRightSide(I,maskPerimeter);

% Location of mask pixels
maskIdx = find(mask);

% Only keep values for pixels that are in the mask
rightSide = rightSide(maskIdx);

% Number the mask pixels in a grid matrix
grid = zeros(nRow,nCol);
grid(maskIdx) = 1:numel(maskIdx);
% Pad with zeros to avoid "index out of bounds" errors in the for loop
grid = padMatrix(grid);
gridIdx = find(grid);

% Form the connectivity matrix D=sparse(i,j,s)
% Connect each mask pixel to itself
i = (1:numel(maskIdx))';
j = (1:numel(maskIdx))';
% The coefficient is the number of neighbors over which we average
numNeighbors = computeNumberOfNeighbors(nRow,nCol);
s = numNeighbors(maskIdx);

% Now connect the N,E,S,W neighbors if they exist
m = nRow+2; % number of rows in grid
for direction = [-1 m 1 -m]
    % Possible neighbors in the current direction
    neighbors = grid(gridIdx+direction);
    % Connect mask points to neighbors with -1's
    i = [i; grid(gridIdx(neighbors~=0))]; %#ok<*AGROW>
    j = [j; nonzeros(neighbors)];
    s = [s; -ones(nnz(neighbors),1)];
end

D = sparse(i,j,s);

% Solve the linear system
sol = D \ rightSide;

% Output
J(maskIdx) = sol;
end

%--------------------------------------------------------------------------
% Form the right side of the linear equation to solve
% The right side is made of the known neighboring pixel values.
% In the general case the equation associated with a mask pixel (pixel to
% be filled) looks like:
%
%         4 x - x_n - x_s - x_e - x_w = 0
%
% where x is the unknown value of the current pixel and x_n, x_s, x_e, x_w
% are the values of the North, South, East, and West pixels.
% If the current pixel is on the edge of the mask, then at least one of
% these neighbor is known. This is what goes in "rightSide":
%
%         4 x - x_n - x_s - x_w = val_e
%
% The right side of the equation is made of the sum of the known neighbor
% values.
function rightSide = formRightSide(I, maskPerimeter)
% Image size
[nRow,nCol] = size(I);

% Get the values of the pixels on the mask perimeter
perimeterValues = zeros(nRow,nCol);
perimeterValues(maskPerimeter) = I(maskPerimeter);

% Initialize
rightSide = zeros(nRow,nCol);
% For pixels that are interior to the image, neighbors are N,S,W,E
rightSide(2:nRow-1,2:nCol-1) = perimeterValues(1:nRow-2,2:nCol-1) ... % N
    + perimeterValues(3:nRow  ,2:nCol-1) ...                          % S
    + perimeterValues(2:nRow-1,1:nCol-2) ...                          % W
    + perimeterValues(2:nRow-1,3:nCol);                               % E
% Pixels on the left border of the image have only 3 neighbors: N,S,E
rightSide(2:nRow-1,1) = perimeterValues(1:nRow-2,1) ... % N
    + perimeterValues(3:nRow  ,1) ...                   % S
    + perimeterValues(2:nRow-1,2);                      % E
% Pixels on the right border have only 3 neighbors: N,S,W
rightSide(2:nRow-1,nCol) = perimeterValues(1:nRow-2,nCol) ... % N
    + perimeterValues(3:nRow  ,nCol) ...                      % S
    + perimeterValues(2:nRow-1,nCol-1);                       % W
% Top border: S,W,E
rightSide(1,2:nCol-1) = perimeterValues(2,2:nCol-1) ... % S
    + perimeterValues(1,1:nCol-2) ...                   % W
    + perimeterValues(1,3:nCol);                        % E
% Bottom border: N,W,E
rightSide(nRow,2:nCol-1) = perimeterValues(nRow-1,2:nCol-1) ... % N
    + perimeterValues(nRow,1:nCol-2) ...                        % W
    + perimeterValues(nRow,3:nCol);                             % E
% Corners have 2 neighbors only
rightSide(1,1) = perimeterValues(1,2) + perimeterValues(2,1); % E+S
rightSide(1,nCol) = perimeterValues(1,nCol-1) + perimeterValues(2,nCol); % W+S
rightSide(nRow,1) = perimeterValues(nRow-1,1) + perimeterValues(nRow,2); % N+E
rightSide(nRow,nCol) = perimeterValues(nRow-1,nCol) + perimeterValues(nRow,nCol-1); % N+W
end

%--------------------------------------------------------------------------
% Return a matrix of size (nRow,nCol) that contains the number of neighbors
% for each pixel. Interior pixels have 4 neighbors. Border pixels have 3.
% Corner pixels have 2.
% This is used when forming the linear equations to be solved.
function numNeighbors = computeNumberOfNeighbors(nRow,nCol)
% Initialize
numNeighbors = zeros(nRow,nCol);
% Interior pixels have 4 neighbors
numNeighbors(2:nRow-1,2:nCol-1) = 4;
% Border pixels have 3 neighbors
numNeighbors(2:nRow-1,[1 nCol]) = 3;
numNeighbors([1 nRow],2:nCol-1) = 3;
% Corner pixels have 2 neighbors
numNeighbors([1 1 nRow nRow],[1 nCol 1 nCol]) = 2;
end

%--------------------------------------------------------------------------
% Pad the input matrix
% When the mask touches the border of the image, we must pad the grid to
% avoid index out of bounds errors.
function gridPadded = padMatrix(grid)
[nRow,nCol] = size(grid);
gridPadded = zeros(nRow+2,nCol+2);
gridPadded(2:nRow+1,2:nCol+1) = grid;
gridPadded = cast(gridPadded,'like',grid);
end