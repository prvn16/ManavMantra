function outstats = regionprops(varargin)
%REGIONPROPS Measure properties of image regions.
%   STATS = REGIONPROPS(BW,PROPERTIES) measures a set of properties for
%   each connected component (object) in the 2D binary image BW, which must
%   be a logical gpuArray.
%
%   STATS = REGIONPROPS(L,PROPERTIES) measures a set of properties for each
%   labeled region in the gpuArray label matrix L. Positive integer
%   elements of L correspond to different regions. For example, the set of
%   elements of L equal to 1 corresponds to region 1; the set of elements
%   of L equal to 2 corresponds to region 2; and so on.
%
%   STATS = REGIONPROPS(...,I,PROPERTIES) measures a set of properties for
%   each labeled region in the gpuArray image I. The first input to
%   REGIONPROPS (BW, or L) identifies the regions in I.  The sizes must
%   match: SIZE(I) must equal SIZE(BW), or SIZE(L).
%
%   STATS is an array of structures with length equal to the number of
%   objects in BW, or max(L(:)). The fields of the structure array
%   denote different properties for each region, as specified by
%   PROPERTIES.
%
%   PROPERTIES can be a comma-separated list of strings or character 
%   vectors, a cell array containing strings or character vectors, 
%   'all', or 'basic'. The set of valid measurement strings or character 
%   vectors includes:
%
%   Shape Measurements
%
%     'Area'                'Extent'             'Orientation'
%     'BoundingBox'         'Extrema'            'PixelIdxList'
%     'Centroid'            'Image'              'PixelList'
%     'Eccentricity'        'MajorAxisLength'    'SubarrayIdx'
%     'EquivDiameter'       'MinorAxisLength'
%
%   Pixel Value Measurements (requires grayscale image as an input)
%
%     'MaxIntensity'
%     'MeanIntensity'
%     'MinIntensity'
%     'PixelValues'
%     'WeightedCentroid'
%
%   Property strings or character vectors are case insensitive and cannot 
%   be abbreviated.
%
%   If PROPERTIES is set to 'all', REGIONPROPS returns all of the Shape
%   measurements. If called with a grayscale image, REGIONPROPS also
%   returns Pixel value measurements. If PROPERTIES is not specified or if
%   it is set to 'basic', these measurements are computed: 'Area',
%   'Centroid', and 'BoundingBox'.
%
%   Note that negative-valued pixels are treated as background and pixels
%   that are not integer-valued are rounded down.
%
%   Note on Terminology
%   -------------------
%   REGIONPROPS can be used on contiguous regions and discontiguous
%   regions.
%
%   Contiguous regions are also called "objects", "connected components",
%   and "blobs". A label matrix containing contiguous regions might look
%   like this:
%
%       1 1 0 2 2 0 3 3
%       1 1 0 2 2 0 3 3
%
%   Elements of L equal to 1 belong to the first contiguous region or
%   connected component, elements of L equal to 2 belong to the second
%   connected component, etc.
%
%   Discontiguous regions are regions that may contain multiple connected
%   components.  A label matrix containing discontiguous regions might look
%   like this:
%
%       1 1 0 1 1 0 2 2
%       1 1 0 1 1 0 2 2
%
%   Elements of L equal to 1 belong to the first region, which is
%   discontiguous and contains two connected components. Elements of L
%   equal to 2 belong to the second region, which is a single connected
%   component.
%
%   Example
%   -------
%   % Label the connected pixel components in the text.png image, compute
%   % their centroids, and superimpose the centroid locations on the
%   % image.
%
%       BW = gpuArray(imread('text.png'));
%       s  = regionprops(BW, 'centroid');
%       centroids = cat(1, s.Centroid);
%       imshow(BW)
%       hold on
%       plot(centroids(:,1), centroids(:,2), 'b*')
%       hold off
%
%   Remarks
%   -------
%   The GPU implementation of this function does not support the following
%   properties: 'ConvexArea', 'ConvexHull', 'ConvexImage', 'EulerNumber',
%   'FilledArea', 'FilledImage' and 'Solidity'.
%
%   Class Support 
%   ------------- 
%   If the first input is BW, BW must be a 2D logical gpuArray. If the
%   first input is L, L must be a 2D real gpuArray that contain integers. L
%   can have any underlying numeric class. 
%
%   See also gpuArray/bwlabel.

%   Copyright 2014-2017 The MathWorks, Inc.

narginchk(1, inf);

argin = matlab.images.internal.stringToChar(varargin);

% dispatch to CPU.
if ~isa(argin{1},'gpuArray')
    args = gatherIfNecessary(argin{:});
    outstats = regionprops(args{:});
    return;
end

L = argin{1};
hValidateAttributes(L,...
    {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {'real','2D','nonsparse'},mfilename,'L',1);

if islogical(L)
    %REGIONPROPS(BW,...)
    [L,numObjs] = bwlabel(L);
else
    numObjs = max( 0, floor(double(gather(max(reshape(L,numel(L),1))))) );
end

imageSize = size(L);

[I,requestedStats,officialStats] = ParseInputs(imageSize, argin{:});

[stats, statsAlreadyComputed] = InitializeStatStructures(...
    numObjs, requestedStats, officialStats);

% Compute PixelIdxList
[stats, statsAlreadyComputed] = ...
    ComputePixelIdxList(L, numObjs, stats, statsAlreadyComputed);

% Compute other statistics.
numRequestedStats = length(requestedStats);
for k = 1 : numRequestedStats
    switch requestedStats{k}

        case 'Area'
            [stats, statsAlreadyComputed] = ...
                ComputeArea(stats, statsAlreadyComputed);

        case 'Centroid'
            [stats, statsAlreadyComputed] = ...
                ComputeCentroid(stats, statsAlreadyComputed);

        case 'EquivDiameter'
            [stats, statsAlreadyComputed] = ...
                ComputeEquivDiameter(stats, statsAlreadyComputed);

        case 'Extrema'
            [stats, statsAlreadyComputed] = ...
                ComputeExtrema(stats,statsAlreadyComputed);

        case 'BoundingBox'
            [stats, statsAlreadyComputed] = ...
                ComputeBoundingBox(stats,statsAlreadyComputed);

        case 'SubarrayIdx'
            [stats, statsAlreadyComputed] = ...
                ComputeSubarrayIdx(stats,statsAlreadyComputed);

        case {'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Eccentricity'}
            [stats, statsAlreadyComputed] = ...
                ComputeEllipseParams(stats,statsAlreadyComputed);

        case 'Extent'
            [stats, statsAlreadyComputed] = ...
                ComputeExtent(stats,statsAlreadyComputed);

        case 'Image'
            [stats, statsAlreadyComputed] = ...
                ComputeImage(stats,statsAlreadyComputed);

        case 'PixelValues'
            [stats, statsAlreadyComputed] = ...
                ComputePixelValues(I,stats,statsAlreadyComputed);

        case 'WeightedCentroid'
            [stats, statsAlreadyComputed] = ...
                ComputeWeightedCentroid(I,stats,statsAlreadyComputed);

        case 'MeanIntensity'
            [stats, statsAlreadyComputed] = ...
                ComputeMeanIntensity(I,stats,statsAlreadyComputed);

        case 'MinIntensity'
            [stats, statsAlreadyComputed] = ...
                ComputeMinIntensity(I,stats,statsAlreadyComputed);

        case 'MaxIntensity'
            [stats, statsAlreadyComputed] = ...
                ComputeMaxIntensity(I,stats,statsAlreadyComputed);
    end
end

% Create the output stats structure array.
outstats = createOutputStatsStructure(requestedStats, stats);

%%%
%%% ComputePixelIdxList
%%%
function [stats, statsAlreadyComputed] = ...
    ComputePixelIdxList(L,numObjs,stats,statsAlreadyComputed)
%   A P-by-1 matrix, where P is the number of pixels belonging to
%   the region.  Each element contains the linear index of the
%   corresponding pixel.

statsAlreadyComputed.PixelIdxList = 1;
statsAlreadyComputed.PixelList = 1;

if numObjs ~= 0
    [idx1, idx2]= images.internal.gpu.regionprops(L, numObjs);
    [stats.PixelIdxList] = deal(idx1{:});  % 1D indices
    [stats.PixelList]    = deal(idx2{:});  % 2D indices
end

%%%
%%% ComputeArea
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeArea(stats, statsAlreadyComputed)
%   The area is defined to be the number of pixels belonging to
%   the region.

if ~statsAlreadyComputed.Area
    statsAlreadyComputed.Area = 1;

    for k = 1:length(stats)
        stats(k).Area = size(stats(k).PixelIdxList, 1);
    end
end

%%%
%%% ComputeEquivDiameter
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeEquivDiameter(stats, statsAlreadyComputed)
%   Computes the diameter of the circle that has the same area as
%   the region.
%   Ref: Russ, The Image Processing Handbook, 2nd ed, 1994, page
%   511.

if ~statsAlreadyComputed.EquivDiameter
    statsAlreadyComputed.EquivDiameter = 1;

    [stats, statsAlreadyComputed] = ...
        ComputeArea(stats,statsAlreadyComputed);

    factor = 2/sqrt(pi);
    for k = 1:length(stats)
        stats(k).EquivDiameter = factor * sqrt(stats(k).Area);
    end
end


%%%
%%% ComputeCentroid
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeCentroid(stats, statsAlreadyComputed)
%   [mean(r) mean(c)]

if ~statsAlreadyComputed.Centroid
    statsAlreadyComputed.Centroid = 1;

    for k = 1:length(stats)
        stats(k).Centroid = gather(mean(stats(k).PixelList,1));
    end

end


%%%
%%% ComputeExtrema
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeExtrema(stats, statsAlreadyComputed)
%   A 8-by-2 array; each row contains the x and y spatial
%   coordinates for these extrema:  leftmost-top, rightmost-top,
%   topmost-right, bottommost-right, rightmost-bottom, leftmost-bottom,
%   bottommost-left, topmost-left.
%   reference: Haralick and Shapiro, Computer and Robot Vision
%   vol I, Addison-Wesley 1992, pp. 62-64.

if ~statsAlreadyComputed.Extrema
    statsAlreadyComputed.Extrema = 1;
    
    firstCol  = substruct('()',{':',1});
    secondCol = substruct('()',{':',2});

    for k = 1:length(stats)
        pixelList = stats(k).PixelList;
        if isempty(pixelList)
            stats(k).Extrema = zeros(8,2) + 0.5;
        else
            r = subsref(pixelList,secondCol);%pixelList(:,2);
            c = subsref(pixelList,firstCol);%pixelList(:,1);

            minR = gather(min(r));
            maxR = gather(max(r));
            minC = gather(min(c));
            maxC = gather(max(c));

            minRSet = r == minR;
            maxRSet = r == maxR;
            minCSet = c == minC;
            maxCSet = c == maxC;

            % Points 1 and 2 are on the top row.
            r1 = minR;
            r2 = minR;
            % Find the minimum and maximum column coordinates for
            % top-row pixels.
            tmp = subsref(c,substruct('()',{minRSet}));%c(minRSet);
            c1 = gather(min(tmp));
            c2 = gather(max(tmp));

            % Points 3 and 4 are on the right column.
            % Find the minimum and maximum row coordinates for
            % right-column pixels.
            tmp = subsref(r,substruct('()',{maxCSet}));%r(maxCSet);
            r3 = gather(min(tmp));
            r4 = gather(max(tmp));
            c3 = maxC;
            c4 = maxC;

            % Points 5 and 6 are on the bottom row.
            r5 = maxR;
            r6 = maxR;
            % Find the minimum and maximum column coordinates for
            % bottom-row pixels.
            tmp = subsref(c,substruct('()',{maxRSet}));%c(maxRSet);
            c5 = gather(max(tmp));
            c6 = gather(min(tmp));

            % Points 7 and 8 are on the left column.
            % Find the minimum and maximum row coordinates for
            % left-column pixels.
            tmp = subsref(r,substruct('()',{minCSet}));%r(minCSet);
            r7 = gather(max(tmp));
            r8 = gather(min(tmp));
            c7 = minC;
            c8 = minC;

            stats(k).Extrema = [
                c1-0.5 r1-0.5
                c2+0.5 r2-0.5
                c3+0.5 r3-0.5
                c4+0.5 r4+0.5
                c5+0.5 r5+0.5
                c6-0.5 r6+0.5
                c7-0.5 r7+0.5
                c8-0.5 r8-0.5
                               ];
        end
    end

end

%%%
%%% ComputeBoundingBox
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeBoundingBox(stats,statsAlreadyComputed)
%   [minC minR width height]; minC and minR end in .5.

if ~statsAlreadyComputed.BoundingBox
    statsAlreadyComputed.BoundingBox = 1;

    for k = 1:length(stats)
        list = stats(k).PixelList;
        if isempty(list)
            stats(k).BoundingBox = [0.5*ones(1,2) zeros(1,2)];
        else
            min_corner = gather(min(list,[],1)) - 0.5;
            max_corner = gather(max(list,[],1)) + 0.5;
            stats(k).BoundingBox = [min_corner (max_corner - min_corner)];
        end
    end
end

%%%
%%% ComputeSubarrayIdx
%%%

function [stats, statsAlreadyComputed] = ...
    ComputeSubarrayIdx(stats,statsAlreadyComputed)
%   Find a cell-array containing indices so that L(idx{:}) extracts the
%   elements of L inside the bounding box.

if ~statsAlreadyComputed.SubarrayIdx
    statsAlreadyComputed.SubarrayIdx = 1;

    [stats, statsAlreadyComputed] = ...
        ComputeBoundingBox(stats,statsAlreadyComputed);
    num_dims = 2; % only supported 2D
    idx = cell(1,num_dims);
    for k = 1:length(stats)
        boundingBox = stats(k).BoundingBox;
        left = boundingBox(1:(end/2));
        right = boundingBox((1+end/2):end);
        left = left(1,[2 1 3:end]);
        right = right(1,[2 1 3:end]);
        for p = 1:num_dims
            first = left(p) + 0.5;
            last = first + right(p) - 1;
            idx{p} = gpuArray.colon(first,last);
        end
        stats(k).SubarrayIdx = idx;
    end
end

%%%
%%% ComputeEllipseParams
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeEllipseParams(stats,statsAlreadyComputed)
%   Find the ellipse that has the same normalized second central moments as the
%   region.  Compute the axes lengths, orientation, and eccentricity of the
%   ellipse.  Ref: Haralick and Shapiro, Computer and Robot Vision vol I,
%   Addison-Wesley 1992, Appendix A.


if ~(statsAlreadyComputed.MajorAxisLength && ...
        statsAlreadyComputed.MinorAxisLength && ...
        statsAlreadyComputed.Orientation && ...
        statsAlreadyComputed.Eccentricity)
    statsAlreadyComputed.MajorAxisLength = 1;
    statsAlreadyComputed.MinorAxisLength = 1;
    statsAlreadyComputed.Eccentricity = 1;
    statsAlreadyComputed.Orientation = 1;

    [stats, statsAlreadyComputed] = ...
        ComputeCentroid(stats,statsAlreadyComputed);

    firstCol  = substruct('()',{':',1});
    secondCol = substruct('()',{':',2});
    for k = 1:length(stats)
        list = stats(k).PixelList;
        if isempty(list)
            stats(k).MajorAxisLength = 0;
            stats(k).MinorAxisLength = 0;
            stats(k).Eccentricity = 0;
            stats(k).Orientation = 0;

        else
            % Assign X and Y variables so that we're measuring orientation
            % counterclockwise from the horizontal axis.

            xbar = stats(k).Centroid(1);
            ybar = stats(k).Centroid(2);

            x = subsref(list,firstCol) - xbar;
            y = -(subsref(list,secondCol) - ybar);  % This is negative for the
                                                    % orientation calculation (measured in the
                                                    % counter-clockwise direction).

            N = length(x);

            % Calculate normalized second central moments for the region. 1/12 is
            % the normalized second central moment of a pixel with unit length.
            uxx = gather(sum(x.^2))/N + 1/12;
            uyy = gather(sum(y.^2))/N + 1/12;
            uxy = gather(sum(x.*y))/N;

            % Calculate major axis length, minor axis length, and eccentricity.
            common = sqrt((uxx - uyy)^2 + 4*uxy^2);
            stats(k).MajorAxisLength = 2*sqrt(2)*sqrt(uxx + uyy + common);
            stats(k).MinorAxisLength = 2*sqrt(2)*sqrt(uxx + uyy - common);
            stats(k).Eccentricity = 2*sqrt((stats(k).MajorAxisLength/2)^2 - ...
                (stats(k).MinorAxisLength/2)^2) / ...
                stats(k).MajorAxisLength;

            % Calculate orientation.
            if (uyy > uxx)
                num = uyy - uxx + sqrt((uyy - uxx)^2 + 4*uxy^2);
                den = 2*uxy;
            else
                num = 2*uxy;
                den = uxx - uyy + sqrt((uxx - uyy)^2 + 4*uxy^2);
            end
            if (num == 0) && (den == 0)
                stats(k).Orientation = 0;
            else
                stats(k).Orientation = (180/pi) * atan(num/den);
            end
        end
    end

end


%%%
%%% ComputeExtent
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeExtent(stats,statsAlreadyComputed)
%   Area / (BoundingBox(3) * BoundingBox(4))

if ~statsAlreadyComputed.Extent
    statsAlreadyComputed.Extent = 1;

    [stats, statsAlreadyComputed] = ...
        ComputeArea(stats,statsAlreadyComputed);
    [stats, statsAlreadyComputed] = ...
        ComputeBoundingBox(stats,statsAlreadyComputed);

    for k = 1:length(stats)
        if (stats(k).Area == 0)
            stats(k).Extent = NaN;
        else
            stats(k).Extent = stats(k).Area / prod(stats(k).BoundingBox(3:4));
        end
    end
end

%%%
%%% ComputeImage
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeImage(stats,statsAlreadyComputed)
%   Binary image containing "on" pixels corresponding to pixels
%   belonging to the region.  The size of the image corresponds
%   to the size of the bounding box for each region.

if ~statsAlreadyComputed.Image
    statsAlreadyComputed.Image = 1;

    [stats, statsAlreadyComputed] = ...
        ComputeSubarrayIdx(stats,statsAlreadyComputed);

    firstCol  = substruct('()',{':',1});
    secondCol = substruct('()',{':',2});
    for k = 1:length(stats)
        subarrayIdx = stats(k).SubarrayIdx;
        if any(cellfun(@isempty,subarrayIdx))
            stats(k).Image = gpuArray(logical([]));
        else
            maxBound = zeros(size(subarrayIdx));
            minBound = zeros(size(subarrayIdx));
            for i = 1:numel(subarrayIdx)
              maxBound(i) = gather(max(subarrayIdx{i}));
              minBound(i) = gather(min(subarrayIdx{i}));
            end
            % cellfun not supported on gpuArray so use for-loop above

            sizeOfSubImage = maxBound - minBound + 1;

            % Shift the pixelList subscripts so that they are relative to
            % sizeOfSubImage.
            if min(sizeOfSubImage) == 0
                stats(k).Image = logical(sizeOfSubImage);
            else
                subtractby = maxBound-sizeOfSubImage;

                cc = subsref(stats(k).PixelList,firstCol);%stats(k).PixelList(:,1);
                rr = subsref(stats(k).PixelList,secondCol);%stats(k).PixelList(:,2);

                sub_cc = cc - subtractby(2); % note reversed order
                sub_rr = rr - subtractby(1);

                idx = (sub_cc - 1) * sizeOfSubImage(1) + sub_rr;
                I = gpuArray.false(sizeOfSubImage);
                I = subsasgn(I,substruct('()',{idx}),gpuArray.true);%I(idx) = true;
                stats(k).Image = I;
            end
        end
    end
end

%%%
%%% ComputePixelValues
%%%
function [stats, statsAlreadyComputed] = ...
                ComputePixelValues(I,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.PixelValues
    statsAlreadyComputed.PixelValues = 1;

    sub.type = '()';
    for k = 1:length(stats)
        sub.subs = {stats(k).PixelIdxList};
        % reshape: force column vector if row vector image
         stats(k).PixelValues = reshape(subsref(I,sub), [], 1);%stats(k).PixelValues = reshape(I(stats(k).PixelIdxList), [], 1);
    end
end

%%%
%%% ComputeWeightedCentroid
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeWeightedCentroid(I,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.WeightedCentroid
    statsAlreadyComputed.WeightedCentroid = 1;

    [stats, statsAlreadyComputed] = ...
        ComputePixelValues(I,stats,statsAlreadyComputed);

    wc = zeros(1,2);
    sub.type = '()';
    for k = 1:length(stats)
        sumIntensity = gather(sum(stats(k).PixelValues));
        for n = 1:2
            sub.subs = {':',n};
            M = gather(sum(subsref(stats(k).PixelList,sub) .* double(stats(k).PixelValues)));
            wc(n) = M ./ sumIntensity;
        end
        stats(k).WeightedCentroid = wc;
    end
end

%%%
%%% ComputeMeanIntensity
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeMeanIntensity(I,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.MeanIntensity
    statsAlreadyComputed.MeanIntensity = 1;

    [stats, statsAlreadyComputed] = ...
        ComputePixelValues(I,stats,statsAlreadyComputed);

    for k = 1:length(stats)
        stats(k).MeanIntensity = gather(mean(stats(k).PixelValues));
    end
end

%%%
%%% ComputeMinIntensity
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeMinIntensity(I,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.MinIntensity
    statsAlreadyComputed.MinIntensity = 1;

    [stats, statsAlreadyComputed] = ...
        ComputePixelValues(I,stats,statsAlreadyComputed);

    for k = 1:length(stats)
        stats(k).MinIntensity = gather(min(stats(k).PixelValues));
    end
end

%%%
%%% ComputeMaxIntensity
%%%
function [stats, statsAlreadyComputed] = ...
    ComputeMaxIntensity(I,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.MaxIntensity
    statsAlreadyComputed.MaxIntensity = 1;

    [stats, statsAlreadyComputed] = ...
        ComputePixelValues(I,stats,statsAlreadyComputed);

    for k = 1:length(stats)
        stats(k).MaxIntensity = gather(max(stats(k).PixelValues));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I, reqStats, officialStats] = ParseInputs(sizeImage, varargin)

shapeStats = {
    'Area'
    'Centroid'
    'BoundingBox'
    'SubarrayIdx'
    'MajorAxisLength'
    'MinorAxisLength'
    'Eccentricity'
    'Orientation'
    'Image'
    'Extrema'
    'EquivDiameter'
    'Extent'
    'PixelIdxList'
    'PixelList'};

pixelValueStats = {
    'PixelValues'
    'WeightedCentroid'
    'MeanIntensity'
    'MinIntensity'
    'MaxIntensity'};

basicStats = {
    'Area'
    'Centroid'
    'BoundingBox'};

I = [];
officialStats = shapeStats;

numOrigInputArgs = numel(varargin);

if numOrigInputArgs == 1
    %REGIONPROPS(BW) or REGIONPROPS(L)

    reqStats = basicStats;
    return;

elseif isnumeric(varargin{2}) || islogical(varargin{2})
    %REGIONPROPS(...,I) or REGIONPROPS(...,I,PROPERTIES)

    I = varargin{2};
    
    % Move image to GPU if needed.
    if ~isa(I,'gpuArray')
        I = gpuArray(I);
    end
        
    hValidateAttributes(I, ...
        {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
    {}, mfilename, 'I', 2);

    assert(isequal(sizeImage, size(I)), ...
        message('images:regionprops:sizeMismatch'));

    officialStats = [shapeStats;pixelValueStats];
    if numOrigInputArgs == 2
        %REGIONPROPS(BW) or REGIONPROPS(L,I)
        reqStats = basicStats;
        return;
    else
        %REGIONPROPS(BW,I,PROPERTIES) or REGIONPROPS(L,I,PROPERTIES)
        startIdxForProp = 3;
        reqStats = getPropsFromInput(startIdxForProp, ...
            officialStats, pixelValueStats, basicStats, varargin{:});
    end

else
    %REGIONPROPS(BW,PROPERTIES) or REGIONPROPS(L,PROPERTIES)
    startIdxForProp = 2;
    reqStats = getPropsFromInput(startIdxForProp, ...
        officialStats, pixelValueStats, basicStats, varargin{:});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [reqStats,officialStats] = getPropsFromInput(startIdx, ...
    officialStats, pixelValueStats, basicStats, varargin)

if iscell(varargin{startIdx})
    %REGIONPROPS(...,PROPERTIES)
    propList = varargin{startIdx};
elseif strcmpi(varargin{startIdx}, 'all')
    %REGIONPROPS(...,'all')
    reqStats = officialStats;
    return;
elseif strcmpi(varargin{startIdx}, 'basic')
    %REGIONPROPS(...,'basic')
    reqStats = basicStats;
    return;
else
    %REGIONPROPS(...,PROP1,PROP2,..)
    propList = varargin(startIdx:end);
end

numProps = length(propList);
reqStats = cell(1, numProps);
for k = 1 : numProps
    if ischar(propList{k})
        noGrayscaleImageAsInput = startIdx == 2;
        if noGrayscaleImageAsInput
            % This code block exists so that regionprops can throw a more
            % meaningful error message if the user want a pixel value based
            % measurement but only specifies a label matrix as an input.
            tempStats = [officialStats; pixelValueStats];
            prop = validatestring(propList{k}, tempStats, mfilename, ...
                'PROPERTIES', k);
            if any(strcmp(prop,pixelValueStats))
                error(message('images:regionprops:needsGrayscaleImage', prop));
            end
        else
            prop = validatestring(propList{k}, officialStats, mfilename, ...
                'PROPERTIES', k);
        end
        reqStats{k} = prop;
    else
        error(message('images:regionprops:invalidType'));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [stats, statsAlreadyComputed] = InitializeStatStructures(...
    numObjs, requestedStats, allStats)

if isempty(requestedStats)
    error(message('images:regionprops:noPropertiesWereSelected'));
end

% Initialize the stats structure array.
numStats = length(allStats);
empties = cell(numStats, numObjs);
stats = cell2struct(empties, allStats, 1);
% Initialize the statsAlreadyComputed structure array. Need to avoid
% multiple calculations of the same property for performance reasons.
zz = cell(numStats, 1);
for k = 1:numStats
    zz{k} = 0;
end
statsAlreadyComputed = cell2struct(zz, allStats, 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outstats = createOutputStatsStructure(requestedStats, stats)

% This is an optimized version of what happens in rmfield. In our case, we
% know the fieldnames in advance and what their indices are.  Rmfield is
% much slower than this function because it calls strmatch(...n'exact').

% Figure out what fields to keep and what fields to remove.
fnames = fieldnames(stats);
idxRemove = ~ismember(fnames, requestedStats);
idxKeep = ~idxRemove;

% Convert to cell array
c = struct2cell(stats);
sizeOfc = size(c);

% Determine size of new cell array that will contain only the requested
% fields.

newSizeOfc = sizeOfc;
newSizeOfc(1) = sizeOfc(1) - numel(find(idxRemove));
newFnames = fnames(idxKeep);

% Create the output structure.
outstats = cell2struct(reshape(c(idxKeep,:), newSizeOfc), newFnames);
