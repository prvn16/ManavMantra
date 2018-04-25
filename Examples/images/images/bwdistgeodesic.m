function d = bwdistgeodesic(varargin)
%BWDISTGEODESIC Geodesic distance transform of binary image.
%   D = BWDISTGEODESIC(BW,MASK) computes the geodesic distance transform
%   given the binary image BW and the seed locations specified by MASK.
%   Regions where BW is true represent valid regions that can be traversed
%   in the computation of the distance transform. Regions where BW is false
%   represent constrained regions that cannot be traversed in the distance
%   computation. For each true pixel in BW, the geodesic distance transform
%   assigns a number that is the constrained distance between that pixel
%   and the nearest true pixel in MASK. The output matrix D contains
%   geodesic distances.
%
%   D = BWDISTGEODESIC(BW,C,R) computes the geodesic distance transform of
%   the binary image BW. C and R are vectors containing the column and row
%   indices of the seed locations. C and R must contain values which are
%   valid pixel indices in BW.
%
%   D = BWDISTGEODESIC(BW,IND) computes the geodesic distance transform of
%   the binary image BW. IND is a vector of linear indices of seed
%   locations.
%   
%   D = BWDISTGEODESIC(...,METHOD) specifies an alternate distance
%   metric. Method can be 'cityblock','chessboard', or 'quasi-euclidean'.
%   If not specified, METHOD defaults to 'chessboard'.
%
%   The different methods correspond to different distance metrics.  In 
%   2-D, the cityblock distance between (x1,y1) and (x2,y2) is abs(x1-x2)
%   + abs(y1-y2).  The chessboard distance is max(abs(x1-x2),
%   abs(y1-y2)).  The quasi-Euclidean distance is:
%
%       abs(x1-x2) + (sqrt(2)-1)*abs(y1-y2),  if abs(x1-x2) > abs(y1-y2)
%       (sqrt(2)-1)*abs(x1-x2) + abs(y1-y2),  otherwise
%
%   Class Support
%   -------------
%   BW is a logical matrix. C, R, and IND are numeric vectors that contain
%   positive integer values. D is a numeric array of class single that has
%   the same size as the input BW.
%      
%   Examples
%   --------
%   % Compute the geodesic distance transformation of BW based on the seed
%   % locations specified by the vectors C and R. Note that output pixels
%   % for which BW is false have undefined geodesic distance and contain
%   % NaN values. Because there is no connected path from the seed
%   % locations to the element BW(10,5), the output D(10,5) has a value of 
%   % Inf.
%   
%   BW = [1 1 1 1 1 1 1 1 1 1;...
%        1 1 1 1 1 1 0 0 1 1;...
%        1 1 1 1 1 1 0 0 1 1;...
%        1 1 1 1 1 1 0 0 1 1;...
%        0 0 0 0 0 1 0 0 1 0;...
%        0 0 0 0 1 1 0 1 1 0;...
%        0 1 0 0 1 1 0 0 0 0;...
%        0 1 1 1 1 1 1 0 1 0;...
%        0 1 1 0 0 0 1 1 1 0;...
%        0 0 0 0 1 0 0 0 0 0];
%
%   BW = logical(BW);
%   C = [1 2 3 3 3];
%   R = [3 3 3 1 2];
%
%   D = bwdistgeodesic(BW,C,R);
%
%   See also BWDIST, GRAYDIST.

%   Copyright 2011-2016 The MathWorks, Inc.

% Enforce number of required input arguments
narginchk(2, 4)

BW = varargin{1};

validateattributes(BW,{'logical'},{'nonempty',...
    'nonsparse','real'},mfilename,'BW',1);

[A,ind,weights,conn] = parseGeodesicInputs(varargin,mfilename);

% We need to weight off limits false pixels as having Infinite weight
% before passing to graydistmex
A(~BW) = Inf; 

conn = images.internal.getBinaryConnectivityMatrix(conn);
d = graydistmex(A,ind,conn,weights);

d(~BW) = NaN;

