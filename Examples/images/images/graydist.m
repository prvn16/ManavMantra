function t = graydist(varargin)
%GRAYDIST Gray-weighted distance transform of grayscale image.
%   T = GRAYDIST(A,MASK) computes the gray-weighted distance transform of
%   the grayscale image A. Seed locations are specified by MASK. MASK is a
%   logical image of the same size as A. Locations where MASK is true are
%   seed locations. The output, T, is the same size as A.
%
%   T = GRAYDIST(A,C,R) computes the gray-weighted distance transform of
%   the grayscale image A. C and R are vectors containing the column and
%   row indices of the seed locations. C and R must contain values which
%   are valid pixel indices in A.
%
%   T = GRAYDIST(A,IND) computes the gray-weighted distance transform of
%   the grayscale image A. IND is a vector of linear indices of seed
%   locations.
%
%   T = GRAYDIST(...,METHOD) specifies an alternate distance metric. The
%   METHOD determines the chamfer weights that are assigned to the local
%   neighborhood during outward propagation. Each pixel's contribution to
%   the geodesic time is based on the chamfer weight in a particular
%   direction multiplied by the pixel intensity. METHOD can be 'cityblock',
%   'chessboard', or 'quasi-euclidean'. METHOD defaults to 'chessboard' if
%   not specified. 
%
%   The different methods correspond to different distance metrics.  In
%   2-D, the cityblock distance between (x1,y1) and (x2,y2) is abs(x1-x2)
%   + abs(y1-y2).  The chessboard distance is max(abs(x1-x2),
%   abs(y1-y2)).  The quasi-Euclidean distance is:
%
%       abs(x1-x2) + (sqrt(2)-1)*abs(y1-y2),  if abs(x1-x2) > abs(y1-y2)
%       (sqrt(2)-1)*abs(x1-x2) + abs(y1-y2),  otherwise
%
%   Class support
%   -------------
%   A can be numeric or logical, and it must be nonsparse. MASK is a
%   logical array of the same size as A. C, R, and IND are numeric vectors
%   that contain positive integer values. METHOD can be a string or char
%   vector. The output T is an array of the same size as A. If the input
%   numeric type of A is double, the output T is double. If the input is
%   any other numeric type, the output T is single.
%
%   Examples
%   --------
%   Here is a simple example of the gray-weighted distance transform with a
%   cityblock distance metric.
%
%   A = [1 2 3 4; 2 11 12 2; 3 13 14 3; 4 15 16 4]
%   seed = false(4,4);
%   seed(1,1) = true
%   D = graydist(A,seed,'cityblock')
%     
%   See also BWDIST, BWDISTGEODESIC, WATERSHED.

%   Copyright 2011-2015 The MathWorks, Inc.

% Enforce number of required input arguments
narginchk(2, 4)

validateattributes(varargin{1},{'numeric','logical'},{'nonempty',...
    'nonsparse','real'},mfilename,'A',1);

% parse inputs
[A,ind,weights,conn] = parseGeodesicInputs(varargin,mfilename);

conn = images.internal.getBinaryConnectivityMatrix(conn);
t = graydistmex(A,ind,conn,weights);
