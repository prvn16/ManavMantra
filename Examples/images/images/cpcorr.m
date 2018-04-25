function xymoving = cpcorr(varargin)
%CPCORR Tune control point locations using cross-correlation. 
%   movingPointsAdjusted = CPCORR(movingPoints,fixedPoints,MOVING,FIXED) uses
%   normalized cross-correlation to adjust each pair of control points
%   specified in movingPoints and fixedPoints.
%
%   movingPoints must be an M-by-2 double matrix containing the
%   coordinates of control points in the moving image.  fixedPoints is
%   an M-by-2 double matrix containing the coordinates of control points
%   in the fixed image.
%
%   CPCORR returns the adjusted control points in movingPointsAdjusted, a
%   double matrix the same size as movingPoints.  If CPCORR cannot
%   correlate a pairs of control points, movingPointsAdjusted will contain
%   the same coordinates as movingPoints for that pair.
%
%   CPCORR will only move the position of a control point by up to 4
%   pixels.  Adjusted coordinates are accurate up to one tenth of a
%   pixel.  CPCORR is designed to get subpixel accuracy from the image
%   content and coarse control point selection.
%
%   Note that the MOVING and FIXED images must have the same scale for
%   CPCORR to be effective.
%
%   CPCORR cannot adjust a point if any of the following occur:
%     - points are too near the edge of either image
%     - regions of images around points contain Inf or NaN
%     - region around a point in moving image has zero standard deviation
%     - regions of images around points are poorly correlated
%
%   Class Support
%   -------------
%   The images can be numeric and must contain finite values. The input
%   control point pairs are double.
%
%   Example
%   --------
%   This example uses CPCORR to fine-tune control points selected in an
%   image.  Note the difference in the values of the movingPoints matrix
%   and the movingPointsAdjusted matrix.
%
%       moving = imread('onion.png');
%       fixed = imread('peppers.png');
%       movingPoints = [127 93; 74 59];
%       fixedPoints = [323 195; 269 161];
%       movingPointsAdjusted = cpcorr(movingPoints,fixedPoints,...
%                                 moving(:,:,1),fixed(:,:,1))
%
%   See also CPSELECT, FITGEOTRANS, NORMXCORR2, IMWARP.

%   Copyright 1993-2013 The MathWorks, Inc.

%   Input-output specs
%   ------------------
%   movingPoints: M-by-2 double matrix 
%              movingPoints(:)>=0.5
%              movingPoints(:,1)<=size(MOVING,2)+0.5
%              movingPoints(:,2)<=size(MOVING,1)+0.5
%
%   fixedPoints: M-by-2 double matrix 
%              fixedPoints(:)>=0.5
%              fixedPoints(:,1)<=size(FIXED,2)+0.5
%              fixedPoints(:,2)<=size(FIXED,1)+0.5
%
%   MOVING:   2-D, real, full matrix
%            logical, uint8, uint16, or double
%            must be finite (no NaNs, no Infs inside regions being correlated)
%
%   FIXED:    2-D, real, full matrix
%            logical, uint8, uint16, or double
%            must be finite (no NaNs, no Infs inside regions being correlated)

[xymoving_in,xyfixed_in,moving,fixed] = ParseInputs(varargin{:});

CORRSIZE = 5;

% get all rectangle coordinates
rects_moving = calc_rects(xymoving_in,CORRSIZE,moving);
rects_fixed = calc_rects(xyfixed_in,2*CORRSIZE,fixed);

ncp = size(xymoving_in,1);

xymoving = xymoving_in; % initialize adjusted control points matrix

for icp = 1:ncp

    if isequal(rects_moving(icp,3:4),[0 0]) || ...
       isequal(rects_fixed(icp,3:4),[0 0]) 
        % near edge, unable to adjust
        continue
    end
    
    sub_moving = imcrop(moving,rects_moving(icp,:));
    sub_fixed = imcrop(fixed,rects_fixed(icp,:));    

    movingsize = size(sub_moving);

    % make sure finite
    if any(~isfinite(sub_moving(:))) || any(~isfinite(sub_fixed(:)))
        % NaN or Inf, unable to adjust
        continue
    end

    % check that template rectangle sub_moving has nonzero std
    if std(sub_moving(:))==0
        % zero standard deviation of template image, unable to adjust
        continue
    end

    norm_cross_corr = normxcorr2(sub_moving,sub_fixed);    

    % get subpixel resolution from cross correlation
    subpixel = true;
    [xpeak, ypeak, amplitude] = findpeak(norm_cross_corr,subpixel);

    % eliminate any poor correlations
    THRESHOLD = 0.5;
    if (amplitude < THRESHOLD) 
        % low correlation, unable to adjust
        continue
    end
    
    % offset found by cross correlation
    corr_offset = [ (xpeak-movingsize(2)-CORRSIZE) (ypeak-movingsize(1)-CORRSIZE) ];

    % eliminate any big changes in control points
    ind = find(abs(corr_offset) > (CORRSIZE-1), 1);
    if ~isempty(ind)
        % peak of norxcorr2 not well constrained, unable to adjust
        continue
    end

    moving_fractional_offset = xymoving(icp,:) - round(xymoving(icp,:));
    fixed_fractional_offset = xyfixed_in(icp,:) - round(xyfixed_in(icp,:));    
    
    % adjust control point
    xymoving(icp,:) = xymoving(icp,:) - moving_fractional_offset - corr_offset + fixed_fractional_offset;

end

%-------------------------------
%
function rect = calc_rects(xy,halfwidth,img)

% Calculate rectangles so imcrop will return image with xy coordinate inside center pixel

default_width = 2*halfwidth;
default_height = default_width;

% xy specifies center of rectangle, need upper left
upperleft = round(xy) - halfwidth;

% need to modify for pixels near edge of images
upper = upperleft(:,2);
left = upperleft(:,1);
lower = upper + default_height;
right = left + default_width;
width = default_width * ones(size(upper));
height = default_height * ones(size(upper));

% check edges for coordinates outside image
[upper,height] = adjust_lo_edge(upper,1,height);
[~,height] = adjust_hi_edge(lower,size(img,1),height);
[left,width] = adjust_lo_edge(left,1,width);
[~,width] = adjust_hi_edge(right,size(img,2),width);

% set width and height to zero when less than default size
iw = find(width<default_width);
ih = find(height<default_height);
idx = unique([iw; ih]);
width(idx) = 0;
height(idx) = 0;

rect = [left upper width height];

%-------------------------------
%
function [coordinates, breadth] = adjust_lo_edge(coordinates,edge,breadth)

indx = find( coordinates<edge );
if ~isempty(indx)
    breadth(indx) = breadth(indx) - abs(coordinates(indx)-edge);
    coordinates(indx) = edge;
end

%-------------------------------
%
function [coordinates, breadth] = adjust_hi_edge(coordinates,edge,breadth)

indx = find( coordinates>edge );
if ~isempty(indx)
    breadth(indx) = breadth(indx) - abs(coordinates(indx)-edge);
    coordinates(indx) = edge;
end

%-------------------------------
%
function [xymoving_in,xyfixed_in,moving,fixed] = ParseInputs(varargin)

narginchk(4,4);

xymoving_in = varargin{1};
xyfixed_in = varargin{2};
if size(xymoving_in,2) ~= 2 || size(xyfixed_in,2) ~= 2
    error(message('images:cpcorr:cpMatrixMustBeMby2'))
end

if size(xymoving_in,1) ~= size(xyfixed_in,1)
    error(message('images:cpcorr:needSameNumOfControlPoints'))
end

moving = varargin{3};
fixed = varargin{4};
if ~ismatrix(moving) || ~ismatrix(fixed)
    error(message('images:cpcorr:intensityImagesReq'))
end

moving = double(moving);
fixed = double(fixed);

if any(xymoving_in(:)<0.5) || any(xymoving_in(:,1)>size(moving,2)+0.5) || ...
   any(xymoving_in(:,2)>size(moving,1)+0.5) || ...
   any(xyfixed_in(:)<0.5) || any(xyfixed_in(:,1)>size(fixed,2)+0.5) || ...
   any(xyfixed_in(:,2)>size(fixed,1)+0.5)
    error(message('images:cpcorr:cpPointsMustBeInPixCoord'))
end
