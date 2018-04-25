function varargout = bwdist_old(varargin)
%BWDIST_OLD Distance transform of binary image.
%   This function provides the BWDIST function as computed by versions
%   6.3 (R2009a) and earlier of the Image Processing Toolbox.
%
%   D = BWDIST_OLD(BW) computes the Euclidean distance transform of the
%   binary image BW. For each pixel in BW, the distance transform assigns
%   a number that is the distance between that pixel and the nearest
%   nonzero pixel of BW. BWDIST_OLD uses the Euclidean distance metric by
%   default.  BW can have any dimension.  D is the same size as BW.
%
%   [D,L] = BWDIST_OLD(BW) also computes the nearest-neighbor transform and
%   returns it as a label matrix, L.  L has the same size as BW and D.
%   Each element of L contains the linear index of the nearest nonzero
%   pixel of BW.
%
%   [D,L] = BWDIST_OLD(BW,METHOD) lets you compute an alternate distance
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
%   Note
%   ----
%   BWDIST_OLD uses fast algorithms to compute the true Euclidean distance
%   transform, especially in the 2-D case.  The other methods are
%   provided primarily for pedagogical reasons.  However, the alternative
%   distance transforms are sometimes significantly faster for
%   multidimensional input images, particularly those that have many
%   nonzero elements.
%
%   Class support
%   -------------
%   BW can be numeric or logical, and it must be nonsparse.  D and L are
%   double matrices with the same size as BW.
%
%   Examples
%   --------
%   Here is a simple example of the Euclidean distance transform:
%
%       bw = zeros(5,5); bw(2,2) = 1; bw(4,4) = 1;
%       [D,L] = bwdist_old(bw)
%
%   This example compares 2-D distance transforms for the four methods:
%
%       bw = zeros(200,200); bw(50,50) = 1; bw(50,150) = 1;
%       bw(150,100) = 1;
%       D1 = bwdist_old(bw,'euclidean');
%       D2 = bwdist_old(bw,'cityblock');
%       D3 = bwdist_old(bw,'chessboard');
%       D4 = bwdist_old(bw,'quasi-euclidean');
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
%       D1 = bwdist_old(bw);
%       D2 = bwdist_old(bw,'cityblock');
%       D3 = bwdist_old(bw,'chessboard');
%       D4 = bwdist_old(bw,'quasi-euclidean');
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
%   See also BWDIST, BWULTERODE, WATERSHED.

%   Copyright 1993-2017 The MathWorks, Inc.

[BW,method] = parse_inputs(varargin{:});

% Computing the nearest-neighbor transform is expensive in memory, so we
% only want to call the lower-level functions eucdist2, eucdistn, and
% ddist_old with two output arguments if we have been called with two output
% arguments.
if nargout <= 1
    varargout = cell(1,1);
else
    varargout = cell(1,2);
end

validateattributes(BW,{'logical'},{'nonsparse'},mfilename,'BW',1);

if strcmp(method,'euclidean')
    % Use a really fast method for 2-D Euclidean distance transforms, or
    % a reasonably fast kd-tree based method for multidimensional
    % Euclidean distance transforms.
    if ndims(BW) == 2
      [varargout{:}] = eucdist2(BW);
    else
      [varargout{:}] = eucdistn(BW);
    end
else
    % All methods other that Euclidean use the same algorithm,
    % implemented in private/ddist_old.  The only difference is in the
    % connectivity and weights used.
    switch method
      case 'cityblock'
        conn = conndef(ndims(BW),'minimal');
        weights = ones(size(conn));
        
      case 'chessboard'
        conn = conndef(ndims(BW),'maximal');
        weights = ones(size(conn));
        
      case 'quasi-euclidean'
        conn = conndef(ndims(BW),'maximal');
        
        % For quasi-Euclidean, form a weights array whose values are the
        % distances between the corresponding elements and the center
        % element.
        kk = cell(1,ndims(BW));
        [kk{:}] = ndgrid(-1:1);
        weights = zeros(size(conn));
        for p = 1:ndims(BW)
            % Although the Euclidean distance formula certainly involves
            % squaring each term, all terms here are either 0, 1, or -1,
            % so that's why the abs() term isn't squared below.
            weights = weights + abs(kk{p});
        end
        weights = sqrt(weights);
        
      otherwise
        error(message('images:bwdist_old:unrecognizedMethodString', method));
    end
    
    % check if conn is valid
    try
      iptcheckconn(conn,mfilename,'conn',5);  %bogus argument position
    catch %#ok<CTCH>
      displayInternalError('conn');
    end
    
    % Postprocess the weights to make sure the center weight is
    % zero, and to keep only values corresponding to nonzero
    % connectivity values.
    weights = weights(:);
    weights((end+1)/2) = 0.0;
    weights(~conn) = [];
    if ( ~isa(weights,'double') || ~isreal(weights) || issparse(weights) || ...
          any(isnan(weights(:))) )
      displayInternalError('weights');
    end
    
    % Call the dual-scan neighborhood based algorithm.
    conn = images.internal.getBinaryConnectivityMatrix(conn);
    [varargout{:}] = ddist_old(BW,conn,weights);
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

%----------------------------------------------------
function displayInternalError(string)

error(message('images:bwdist_old:internalError', string));

