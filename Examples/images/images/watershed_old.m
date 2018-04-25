function L = watershed_old(varargin)
%WATERSHED_OLD Watershed transform (old version).
%   This function provides the watershed transform as computed by versions
%   5.3 (R2006b) and earlier of the Image Processing Toolbox.
%
%   L = WATERSHED_OLD(A) computes a label matrix identifying the watershed
%   regions of the input matrix A.  A can have any dimension.  The elements
%   of L are integer values greater than or equal to 0.  The elements
%   labeled 0 do not belong to a unique watershed region.  These are called
%   "watershed pixels."  The elements labeled 1 belong to the first
%   watershed region, the elements labeled 2 belong to the second watershed
%   region, and so on.
%
%   By default, WATERSHED_OLD uses 8-connected neighborhoods for 2-D inputs
%   and 26-connected neighborhoods for 3-D inputs.  For higher
%   dimensions, WATERSHED_OLD uses the connectivity given by
%   CONNDEF(NDIMS(A),'maximal').
%
%   L = WATERSHED_OLD(A,CONN) computes the watershed transform using the
%   specified connectivity.  CONN may have the following scalar values:
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
%   CONN.  If specified this way, CONN must be symmetric about its center.
%
%   Class Support
%   -------------
%   A can be a numeric or logical array of any dimension, and it must be
%   nonsparse.  The output array L is double. 
%
%   See also WATERSHED.

%   Copyright 1993-2015 The MathWorks, Inc.

% Input-output specs
% ==================
% A    - full, real, numeric, logical
%        +/- Inf OK, but NaNs not allowed
%        empty OK
%        required
%
% CONN - connectivity; see connectivity spec
%        optional; if not specified = ones(repmat(3,1,ndims(A)))
%
% L      full, double array, same size as A

[A,conn] = parse_inputs(varargin{:});
try
    [~, idx] = sort(A(:));
catch
    % If there's no sort method, convert to double.
    [~, idx] = sort(double(A(:)));
end

% check idx
if ~isa(idx,'double') || ~isreal(idx) || issparse(idx)
  error(message('images:watershed_old:internalError'))
end
  
conn = images.internal.getBinaryConnectivityMatrix(conn);
L = watershed_vs(A,conn,idx-1);

% Post-process result to remove gaps in watershed lines.  Change any
% labeled pixel with a higher labeled neighbor to a watershed pixel.
conn = conn2array(conn);
L(imdilate(L,conn) > L) = 0;

function [A,conn] = parse_inputs(varargin)
  
narginchk(1,2);

A = varargin{1};
validateattributes(A,{'numeric' 'logical'}, {'real' 'nonsparse'}, ...
              mfilename, 'A', 1);

if nargin < 2
    conn = conndef(ndims(A), 'maximal');
else
    conn = varargin{2};
    if isa(conn,'strel')
        conn = getnhood(conn);
    else
        iptcheckconn(conn, mfilename, 'CONN', 2);
    end
end

