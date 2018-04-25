function [L,numComponents] = bwlabel(BW,mode)
%BWLABEL Label connected components in 2-D binary image.
%   L = BWLABEL(BW,N) returns a matrix L, of the same size as BW,
%   containing labels for the connected components in BW. N can have a
%   value of either 4 or 8, where 4 specifies 4-connected objects and 8
%   specifies 8-connected objects; if the argument is omitted, it defaults
%   to 8.
%
%   The elements of L are integer values greater than or equal to 0.  The
%   pixels labeled 0 are the background.  The pixels labeled 1 make up one
%   object, the pixels labeled 2 make up a second object, and so on.
%
%   [L,NUM] = BWLABEL(BW,N) returns in NUM the number of connected objects
%   found in BW.
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
%   of BWCONNCOMP. See the documentation for each function for more information.
%
%   Class Support
%   -------------
%   BW can be logical or numeric, and it must be real, 2-D, and nonsparse.
%   L is of class double.
%
%   Example
%   -------
%       BW = logical([1 1 1 0 0 0 0 0
%                     1 1 1 0 1 1 0 0
%                     1 1 1 0 1 1 0 0
%                     1 1 1 0 0 0 1 0
%                     1 1 1 0 0 0 1 0
%                     1 1 1 0 0 0 1 0
%                     1 1 1 0 0 1 1 0
%                     1 1 1 0 0 0 0 0]);
%       L = bwlabel(BW,4)
%       [r,c] = find(L == 2)
%
%   See also BWCONNCOMP,BWLABELN,BWSELECT,LABELMATRIX,LABEL2RGB,REGIONPROPS.

%   Copyright 1993-2015 The MathWorks, Inc.

validateattributes(BW, {'logical' 'numeric'}, {'real', '2d', 'nonsparse'}, ...
              mfilename, 'BW', 1);

if (nargin < 2)
    mode = 8;
else
    validateattributes(mode, {'double'}, {'scalar'}, mfilename, 'N', 2);
end

if ~islogical(BW)
    BW = BW ~= 0;
end

[startRow,endRow,startCol,labelForEachRun,numComponents] = ...
    labelBinaryRuns(BW,mode);

% Given label information, create output matrix.
L = bwlabel2(startRow,endRow,startCol,labelForEachRun,size(BW,1), ...
    size(BW,2));
