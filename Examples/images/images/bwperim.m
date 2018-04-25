function pout = bwperim(varargin)
%BWPERIM Find perimeter of objects in binary image.
%   BW2 = BWPERIM(BW1) returns a binary image containing only the perimeter
%   pixels of objects in the input image BW1. A pixel is part of the
%   perimeter if it nonzero and it is connected to at least one zero-valued
%   pixel.  The default connectivity is 4 for two dimensions, 6 for three
%   dimensions, and CONNDEF(NDIMS(BW),'minimal') for higher dimensions.
%
%   BW2 = BWPERIM(BW1,CONN) specifies the desired connectivity.  CONN may
%   have the following scalar values:  
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%       6     three-dimensional six-connected neighborhood
%       18    three-dimensional 18-connected neighborhood
%       26    three-dimensional 26-connected neighborhood
%
%   Connectivity may be defined in a more general way for any dimension by
%   using for CONN a 3-by-3-by- ... -by-3 matrix of 0s and 1s.  The 1-valued
%   elements define neighborhood locations relative to the center element of
%   CONN.  CONN must be symmetric about its center element.
%
%   Class Support
%   -------------
%   BW1 must be logical or numeric, and it must be nonsparse.  BW2 is
%   logical.
%
%   Example
%   -------
%       BW1 = imread('circbw.tif');
%       BW2 = bwperim(BW1,8);
%       figure, imshow(BW1)
%       figure, imshow(BW2)
%
%   See also BWAREA, BWBOUNDARIES, BWEULER, BWTRACEBOUNDARY, CONNDEF, IMFILL.

%   Copyright 1992-2010 The MathWorks, Inc.

narginchk(1,2);
b = varargin{1};

validateattributes(b, {'logical' 'numeric'}, {'nonsparse'}, ...
              mfilename, 'BW', 1);
if ~islogical(b)
    b = b ~= 0;
end

num_dims = ndims(b);

if nargout == 0 && num_dims > 2
    error(message('images:bwperim:invalidSyntax'))
end

if nargin < 2
    conn = conndef(num_dims,'minimal');
else
    conn = varargin{2};
    iptcheckconn(conn,mfilename,'CONN',2);
end

conn = ScalarToArray(conn);

% If it's a 2-D problem with 4- or 8-connectivity, use
% bwmorph --- it works without padding the input.
if (num_dims == 2) && isequal(conn, [0 1 0; 1 1 1; 0 1 0])
    p = bwmorph(b,'perim4');
    
elseif (num_dims == 2) && isequal(conn, ones(3,3))
    p = bwmorph(b,'perim8');
    
else
    % Use a general technique that works for any dimensionality
    % and any connectivity.
    num_dims = max(num_dims, ndims(conn));
    b = padarray(b,ones(1,num_dims),0,'both');
    b_eroded = imerode(b,conn);
    p = b & ~b_eroded;
    idx = cell(1,num_dims);
    for k = 1 : num_dims
        idx{k} = 2:(size(p,k) - 1);
    end
    p = p(idx{:});
end

if nargout == 0
    imshow(p)
else
    pout = p;
end

% ================ ScalarToArray ========================
function conn_out = ScalarToArray(conn)

if numel(conn) == 1
    switch conn
      case 1
        conn_out = 1;
        
      case 4
        conn_out = [0 1 0; 1 1 1; 0 1 0];
        
      case 8
        conn_out = ones(3,3);
        
      case 6
        conn_out = conndef(3,'minimal');
        
      case 18
        conn_out = cat(3,[0 1 0; 1 1 1; 0 1 0], ...
                       ones(3,3), [0 1 0; 1 1 1; 0 1 0]);
        
      case 26
        conn_out = conndef(3,'maximal');
        
      otherwise
        error(message('images:bwperim:unexpectedConnValue'));
    end
else
    conn_out = conn;
end
