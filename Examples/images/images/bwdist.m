function varargout = bwdist(varargin)
%BWDIST Distance transform of binary image.
%   D = BWDIST(BW) computes the Euclidean distance transform of the
%   binary image BW. For each pixel in BW, the distance transform assigns
%   a number that is the distance between that pixel and the nearest
%   nonzero pixel of BW. BWDIST uses the Euclidean distance metric by
%   default.  BW can have any dimension.  D is the same size as BW.
%
%   [D,IDX] = BWDIST(BW) also computes the closest-pixel map in the form of
%   an index array, IDX. (The closest-pixel map is also called the feature
%   map, feature transform, or nearest-neighbor transform.) IDX has the
%   same size as BW and D. Each element of IDX contains the linear index of
%   the nearest nonzero pixel of BW.
%
%   [D,IDX] = BWDIST(BW,METHOD) lets you compute an alternate distance
%   transform, depending on the value of METHOD.  METHOD can be
%   'cityblock', 'chessboard', 'quasi-euclidean', or 'euclidean'.  METHOD
%   defaults to 'euclidean' if not specified.  METHOD may be
%   abbreviated.
%
%   The different methods correspond to different distance metrics.  In
%   2-D, the cityblock distance between (x1,y1) and (x2,y2) is abs(x1-x2)
%   + abs(y1-y2).  The chessboard distance is max(abs(x1-x2),
%   abs(y1-y2)).  The quasi-Euclidean distance is:
%
%       abs(x1-x2) + (sqrt(2)-1)*abs(y1-y2),  if abs(x1-x2) > abs(y1-y2)
%       (sqrt(2)-1)*abs(x1-x2) + abs(y1-y2),  otherwise
%
%   The Euclidean distance is sqrt((x1-x2)^2 + (y1-y2)^2).
%
%   Notes
%   -----
%   BWDIST uses a fast algorithm to compute the true Euclidean distance
%   transform.  The other methods are provided primarily for pedagogical
%   reasons.
%
%   The function BWDIST changed in version 6.4 (R2009b). Previous versions
%   of the Image Processing Toolbox used different algorithms for
%   computing the Euclidean distance transform and the associated
%   closest-pixel map matrix. If you need the same results produced by 
%   the previous implementation, use the function BWDIST_OLD.  
%
%   Class support
%   -------------
%   BW can be numeric or logical, and it must be nonsparse.  D is a
%   single matrix with the same size as BW.
%   The class of IDX depends on number of elements in the input image, 
%   and is determined using the following table.
%
%       Class         Range
%       --------      --------------------------------
%       'uint32'      numel(BW) <= 2^32-1
%       'uint64'      numel(BW) >= 2^32
%
%   Examples
%   --------
%   Here is a simple example of the Euclidean distance transform:
%
%       bw = zeros(5,5); bw(2,2) = 1; bw(4,4) = 1;
%       [D,IDX] = bwdist(bw)
%
%   This example compares 2-D distance transforms for the four methods:
%
%       bw = zeros(200,200); bw(50,50) = 1; bw(50,150) = 1;
%       bw(150,100) = 1;
%       D1 = bwdist(bw,'euclidean');
%       D2 = bwdist(bw,'cityblock');
%       D3 = bwdist(bw,'chessboard');
%       D4 = bwdist(bw,'quasi-euclidean');
%       RGB1 = repmat(rescale(D1), [1 1 3]);
%       RGB2 = repmat(rescale(D2), [1 1 3]);
%       RGB3 = repmat(rescale(D3), [1 1 3]);
%       RGB4 = repmat(rescale(D4), [1 1 3]);
%       figure
%       subplot(2,2,1), imshow(RGB1), title('Euclidean')
%       hold on, imcontour(D1)
%       subplot(2,2,2), imshow(RGB2), title('City block')
%       hold on, imcontour(D2)
%       subplot(2,2,3), imshow(RGB3), title('Chessboard')
%       hold on, imcontour(D3)
%       subplot(2,2,4), imshow(RGB4), title('Quasi-Euclidean')
%       hold on, imcontour(D4)
%
%   This example compares isosurface plots for the distance transforms of
%   a 3-D image containing a single nonzero pixel in the center:
%
%       bw = zeros(50,50,50); bw(25,25,25) = 1;
%       D1 = bwdist(bw);
%       D2 = bwdist(bw,'cityblock');
%       D3 = bwdist(bw,'chessboard');
%       D4 = bwdist(bw,'quasi-euclidean');
%       figure
%       subplot(2,2,1), isosurface(D1,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Euclidean')
%       subplot(2,2,2), isosurface(D2,15), axis equal, view(3)
%       camlight, lighting gouraud, title('City block')
%       subplot(2,2,3), isosurface(D3,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Chessboard')
%       subplot(2,2,4), isosurface(D4,15), axis equal, view(3)
%       camlight, lighting gouraud, title('Quasi-Euclidean')
%
%   See also BWDIST_OLD, BWULTERODE, WATERSHED.

%   Copyright 1993-2017 The MathWorks, Inc.


[BW,method] = parse_inputs(varargin{:});

% Computing the nearest-neighbor transform is expensive in memory, so we
% only want to call the lower-level function ddist with two output
% arguments if we have been called with two output arguments. Also, for the
% Euclidean case, bwdistComputeEDTFT will be called instead of
% bwdistComputeEDT, when there are two output arguments.
if nargout <= 1
    varargout = cell(1,1);
else
    varargout = cell(1,2);
end

if strcmp(method,'euclidean')
    % Use fast methods for multidimensional Euclidean distance
    % transforms and Euclidean closest feature transforms.
    if (nargout == 2)
        numOfElements = numel(BW);
        if(numOfElements <= intmax('uint32'))
            outType = uint32(1);
        else
            outType = uint64(1);
        end
        [D, IDX] = bwdistComputeEDTFT(BW, outType);
        varargout{1} = sqrt(D);
        varargout{2} = IDX;                  
    else
        D = bwdistComputeEDT(BW);
        varargout{1} = sqrt(D);      
    end    
else
    % All methods other than Euclidean use the same algorithm,
    % implemented in private/ddist.  The only difference is in the
    % connectivity and weights used.
    [weights,conn] = images.internal.computeChamferMask(ndims(BW),method);
    
    % Postprocess the weights to make sure the center weight is
    % zero.
    weights((end+1)/2) = 0.0;
    
    % Call the dual-scan neighborhood based algorithm.
    [varargout{:}] = ddist(BW,conn,weights);
end

%--------------------------------------------------

function [BW,method] = parse_inputs(varargin)

narginchk(1,2);
validateattributes(varargin{1}, {'logical','numeric'}, {'nonsparse', 'real'}, ...
              mfilename, 'BW', 1);

BW = varargin{1} ~= 0;

if nargin < 2
    method = 'euclidean';
else
    valid_methods = {'euclidean','cityblock','chessboard','quasi-euclidean'};
    method = validatestring(varargin{2}, valid_methods, ...
                          mfilename, 'METHOD', 2);
end
