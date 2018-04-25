function [L,num] = bwlabeln(varargin)
%BWLABELN Label connected components in binary image.
%   L = BWLABELN(BW) returns a label matrix, L, containing labels for the
%   connected components in BW.  BW can have any dimension; L is the same
%   size as BW.  The elements of L are integer values greater than or equal
%   to 0.  The pixels labeled 0 are the background.  The pixels labeled 1
%   make up one object, the pixels labeled 2 make up a second object, and
%   so on.  The default connectivity is 8 for two dimensions, 26 for three
%   dimensions, and CONNDEF(NDIMS(BW),'maximal') for higher dimensions.
%
%   [L,NUM] = BWLABELN(BW) returns the number of connected objects found in
%   BW.
%
%   [L,NUM] = BWLABELN(BW,CONN) specifies the desired connectivity.  CONN
%   may have the following scalar values:
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%       6     three-dimensional six-connected neighborhood
%       18    three-dimensional 18-connected neighborhood
%       26    three-dimensional 26-connected neighborhood
%
%   Connectivity may be defined in a more general way for any dimension by
%   using a 3-by-3-by- ... -by-3 matrix of 0s and 1s.  The 1-valued
%   elements define neighborhood locations relative to the center element
%   of CONN.  CONN must be symmetric about its center element.
%
%   Note: On the use of BWLABEL, BWLABELN, BWCONNCOMP, and REGIONPROPS
%   ------------------------------------------------------------------
%   The functions BWLABEL, BWLABELN, and BWCONNCOMP all compute connected
%   components for binary images.  BWCONNCOMP is the most recent addition
%   to the Image Processing Toolbox and is intended to replace the use
%   of BWLABEL and BWLABELN.  It uses significantly less memory and is
%   sometimes faster than the older functions.
%  
%                Input  Output            Memory   Connectivity
%                Dim    Form              Use
%                ----------------------------------------------
%   BWLABEL      2-D    Double-precision  High     4 or 8
%                       label matrix           
% 
%   BWLABELN     N-D    Double-precision  High     Any
%                       label matrix       
% 
%   BWCONNCOMP   N-D    CC struct         Low      Any
%
%   To extract features from a binary image using REGIONPROPS using the
%   default connectivity, just pass BW directly into REGIONPROPS, i.e.,
%   REGIONPROPS(BW). 
%
%   To compute a label matrix having a more memory-efficient data type
%   (e.g., uint8 versus double), use the LABELMATRIX function on the output
%   of BWCONNCOMP.
%
%   See the documentation for more information.
%
%   Class Support
%   -------------
%   BW can be numeric or logical, and it must be real and nonsparse.  L
%   is of class double.
%
%   Example
%   -------
%       BW = cat(3,[1 1 0; 0 0 0; 1 0 0],...
%                  [0 1 0; 0 0 0; 0 1 0],...
%                  [0 1 1; 0 0 0; 0 0 1])
%       bwlabeln(BW)
%
%   See also BWCONNCOMP,BWLABEL,LABELMATRIX,LABEL2RGB,REGIONPROPS.

%   Copyright 1993-2015 The MathWorks, Inc.  

[A,conn] = parse_inputs(varargin{:});

[L,num] = bwlabelnmex(A,conn);

%%%
%%% parse_inputs
%%%
function [A,conn] = parse_inputs(varargin)

narginchk(1,2);

validateattributes(varargin{1}, {'numeric', 'logical'}, {'real' 'nonsparse'}, ...
              mfilename, 'BW', 1);

A = varargin{1};
if ~islogical(A)
  A = A ~= 0;
end

if nargin < 2
    conn = conndef(ndims(A), 'maximal');
else
    conn = varargin{2};
    iptcheckconn(conn,mfilename,'CONN',2);    
end

conn = images.internal.getBinaryConnectivityMatrix(conn);
