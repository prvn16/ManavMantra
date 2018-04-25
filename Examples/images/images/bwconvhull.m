function convex_hull = bwconvhull(varargin)
%BWCONVhull Generate convex hull image from binary image.
%   CH = BWCONVHULL(BW) computes the convex hull of all objects in BW and
%   returns CH, binary convex hull image.  BW is a logical 2D image and CH
%   is a logical convex hull image, containing the binary mask of the
%   convex hull of all foreground objects in BW.
%
%   CH = BWCONVHULL(BW,METHOD) specifies the desired method for computing
%   the convex hull image.  METHOD is a string or character vector and may
%   have the following values:
%
%      'union'   : Compute convex hull of all foreground objects, treating
%                  them as a single object.  This is the default method.
%      'objects' : Compute the convex hull of each connected component of
%                  BW individually.  CH will contain the convex hulls of
%                  each connected component.
%
%   CH = BWCONVHULL(BW,'objects',CONN) specifies the desired connectivity
%   used when defining individual foreground objects.  The CONN parameter
%   is only valid when the METHOD is 'objects'.  CONN may have the
%   following scalar values:
%
%      4 : two-dimensional four-connected neighborhood
%      8 : two-dimensional eight-connected neighborhood {default}
%
%   Additionally, CONN may be defined in a more general way, using a 3-by-3
%   matrix of 0s and 1s.  The 1-valued elements define neighborhood
%   locations relative to the center element of CONN.  CONN must be
%   symmetric about its center element.
%
%   Example
%   -------
%   subplot(2,2,1);
%   I = imread('coins.png');
%   imshow(I);
%   title('Original');
%   
%   subplot(2,2,2);
%   BW = I > 100;
%   imshow(BW);
%   title('Binary');
%   
%   subplot(2,2,3);
%   CH = bwconvhull(BW);
%   imshow(CH);
%   title('Union Convex Hull');
%   
%   subplot(2,2,4);
%   CH_objects = bwconvhull(BW,'objects');
%   imshow(CH_objects);
%   title('Objects Convex Hull');
%
%   See also BWCONNCOMP, BWLABEL, LABELMATRIX, REGIONPROPS.

%   Copyright 2010-2016 The MathWorks, Inc.

[BW, method, conn] = parseInputs(varargin{:});

% Label the image
if strcmpi(method,'union')
    % 'union' : label all 'true' pixels as a single region
    labeled_image = uint8(BW);
else
    % 'objects' : label as normal
    labeled_image = bwconncomp(BW,conn);
end

% Call regionprops
blob_props = regionprops(labeled_image,'BoundingBox','ConvexImage');
num_blobs = length(blob_props);
[rows, columns] = size(BW);

% Loop over all blobs getting the CH for each blob one at a time, then add
% it to the cumulative CH image.
convex_hull = false(rows, columns);
for i = 1 : num_blobs
    m = blob_props(i).BoundingBox(4);
    n = blob_props(i).BoundingBox(3);
    r1 = blob_props(i).BoundingBox(2) + 0.5;
    c1 = blob_props(i).BoundingBox(1) + 0.5;
    rows = (1:m) + r1 - 1;
    cols = (1:n) + c1 - 1;
    convex_hull(rows,cols) = convex_hull(rows,cols) | blob_props(i).ConvexImage;
end


%------------------------------------------------
function [BW,method,conn] = parseInputs(varargin)

narginchk(1,3);

BW = varargin{1};
validateattributes(BW, {'logical' 'numeric'}, {'2d', 'real', 'nonsparse'}, ...
    mfilename, 'BW', 1);

if ~islogical(BW)
    BW = BW ~= 0;
end

if nargin == 1
    % BWCONVHULL(BW)
    method = 'union';
    conn = 8;
    
elseif nargin == 2
    % BWCONVHULL(BW,METHOD)
    method = varargin{2};
    conn = 8;
    
else
    % BWCONVHULL(BW,METHOD,CONN)
    method = varargin{2};
    conn = varargin{3};
    
    % special case so that we go through the 2D code path for 4 or 8
    % connectivity
    if isequal(conn, [0 1 0;1 1 1;0 1 0])
        conn = 4;
    end
    if isequal(conn, ones(3))
        conn = 8;
    end
    
end

% validate inputs (accepts partial string matches)
method = validatestring(method,{'union','objects'},mfilename,'METHOD',2);

% validate connectivity
is_valid_scalar = isscalar(conn) && (conn == 4 || conn == 8);
if is_valid_scalar
    return
end

% else, validate 3x3 connectivity matrix

% 3x3 matrix...
is_valid_matrix = isnumeric(conn) && isequal(size(conn),[3 3]);
% with all 1's and 0's...
is_valid_matrix = is_valid_matrix && all((conn(:) == 1) | (conn(:) == 0));
% whos center value is non-zero
is_valid_matrix = is_valid_matrix && conn((end+1)/2) ~= 0;
% and which is symmetrix
is_valid_matrix = is_valid_matrix && isequal(conn(1:end), conn(end:-1:1));

if ~is_valid_matrix
    error(message('images:bwconvhull:invalidConnectivity'))
end



