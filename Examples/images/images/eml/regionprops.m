function [outstats] = regionprops(varargin) %#codegen
% REGIONPROPS Measure properties of image regions.

%   Copyright 2014-2017 The MathWorks, Inc.

narginchk(1, inf);
coder.internal.prefer_const(varargin);

if ischar(varargin{1})
    coder.internal.errorIf(~eml_is_const(varargin{1}),...
        'MATLAB:images:validate:codegenInputNotConst','OUTPUT');
    
    outputString = validatestring(lower(varargin{1}), {'struct','table'}, ...
        mfilename, 'Output',1);
    
    coder.internal.errorIf(strcmp(outputString,'table'),...
        'images:regionprops:codegenTableUnsupported');
    argOffset = 1;
else
    argOffset = 0;
end

startIdx = coder.internal.indexPlus(1,argOffset);

if islogical(varargin{startIdx}) || isstruct(varargin{startIdx})
    %REGIONPROPS(BW,...) or REGIONPROPS(CC,...)
    
    if islogical(varargin{startIdx})
        %REGIONPROPS(BW,...)
        coder.internal.errorIf(numel(size(varargin{startIdx})) > 2, 'images:validate:tooManyDimensions','BW','2');

        CC = bwconncomp(varargin{startIdx},8);
        
    else
        %REGIONPROPS(CC,...)
        CC = varargin{startIdx};
        validateCC(CC);
    
    end
    
    imageSize = CC.ImageSize;
    numObjs = CC.NumObjects;
    
    L = [];
    
else
    %REGIONPROPS(L,...)
    
    coder.internal.errorIf(numel(size(varargin{startIdx})) > 2, 'images:validate:tooManyDimensions','L','2');
    
    L = varargin{startIdx};
    
    supportedTypes = {'uint8','uint16','uint32','int8','int16','int32','single','double'};
    supportedAttributes = {'real','nonsparse'};
    validateattributes(L, supportedTypes, supportedAttributes, ...
        mfilename, 'L', startIdx);
    
    imageSize = size(L);
    
    if isempty(L)
        numObjs = 0;
    else
        if coder.isColumnMajor
            numObjs = max( 0, floor(double(max(L(:)))));
        else
            numObjs = max( 0, floor(double(max(max(L,[],2),[],1))));
        end
    end
    
    CC = [];
end

[I, requestedStats, outstats] = parseInputsAndInitializeOutStruct(imageSize, argOffset, numObjs, varargin{startIdx:end});

[stats, statsAlreadyComputed] = initializeStatsStruct(I, numObjs, TEMPSTATS_ALL);

% Compute PixelIdxList.
[stats, statsAlreadyComputed] = ...
    ComputePixelIdxList(L, CC, numObjs, stats, statsAlreadyComputed);

% Compute other statistics.
numRequestedStats = length(requestedStats);
for k = coder.unroll(1 : numRequestedStats)
    switch requestedStats(k)
        
        case AREA
            [stats, statsAlreadyComputed] = ...
                ComputeArea(stats, statsAlreadyComputed);
            
        case FILLEDIMAGE
            [stats, statsAlreadyComputed] = ...
                ComputeFilledImage(imageSize,stats,statsAlreadyComputed);
            
        case FILLEDAREA
            [stats, statsAlreadyComputed] = ...
                ComputeFilledArea(imageSize,stats,statsAlreadyComputed);

        case CENTROID
            [stats, statsAlreadyComputed] = ...
                ComputeCentroid(imageSize,stats, statsAlreadyComputed);
            
        case EULERNUMBER
            [stats, statsAlreadyComputed] = ...
                ComputeEulerNumber(imageSize,stats,statsAlreadyComputed);
            
        case EQUIVDIAMETER
            [stats, statsAlreadyComputed] = ...
                ComputeEquivDiameter(stats, statsAlreadyComputed);
            
        case EXTREMA
            [stats, statsAlreadyComputed] = ...
                ComputeExtrema(imageSize,stats,statsAlreadyComputed);
            
        case BOUNDINGBOX
            [stats, statsAlreadyComputed] = ...
                ComputeBoundingBox(imageSize,stats,statsAlreadyComputed);
            
        case SUBARRAYIDX
            [stats, statsAlreadyComputed] = ...
                ComputeSubarrayIdx(imageSize,stats,statsAlreadyComputed);
            
        case MAJORAXISLENGTH
            [stats, statsAlreadyComputed] = ...
                ComputeEllipseParams(imageSize,stats,statsAlreadyComputed);
            
        case MINORAXISLENGTH 
            [stats, statsAlreadyComputed] = ...
                ComputeEllipseParams(imageSize,stats,statsAlreadyComputed);
            
        case ORIENTATION 
            [stats, statsAlreadyComputed] = ...
                ComputeEllipseParams(imageSize,stats,statsAlreadyComputed);
            
        case ECCENTRICITY
            [stats, statsAlreadyComputed] = ...
                ComputeEllipseParams(imageSize,stats,statsAlreadyComputed);
        
        case EXTENT
            [stats, statsAlreadyComputed] = ...
                ComputeExtent(imageSize,stats,statsAlreadyComputed);
        
        case IMAGE
            [stats, statsAlreadyComputed] = ...
                ComputeImage(imageSize,stats,statsAlreadyComputed);
            
        case PIXELLIST
            [stats, statsAlreadyComputed] = ...
                ComputePixelList(imageSize,stats,statsAlreadyComputed);
        
        case PERIMETER
            % Computing perimeter using the label matrix is faster than
            % computing the perimeter from the PixelIdxList.
            if ~isempty(L)
                [stats, statsAlreadyComputed] = ...
                    ComputePerimeterWithLabelMatrix(L,numObjs,stats, ...
                    statsAlreadyComputed);
            else
                [stats, statsAlreadyComputed] = ...
                    ComputePerimeterWithPixelIdxList(imageSize,stats, ...
                    statsAlreadyComputed);
            end
            
        case PIXELVALUES
            [stats, statsAlreadyComputed] = ...
                ComputePixelValues(I,stats,statsAlreadyComputed);
            
        case WEIGHTEDCENTROID
            [stats, statsAlreadyComputed] = ...
                ComputeWeightedCentroid(imageSize,I,stats,statsAlreadyComputed);
            
        case MEANINTENSITY
            [stats, statsAlreadyComputed] = ...
                ComputeMeanIntensity(I,stats,statsAlreadyComputed);
            
        case MININTENSITY
            [stats, statsAlreadyComputed] = ...
                ComputeMinIntensity(I,stats,statsAlreadyComputed);
            
        case MAXINTENSITY
            [stats, statsAlreadyComputed] = ...
                ComputeMaxIntensity(I,stats,statsAlreadyComputed);
        
        case PIXELIDXLIST
                % Do nothing. Already done.
            
        otherwise
            assert(false, 'Invalid value');
            
    end
end

% Create the output stats structure array.
[outstats, stats] = populateOutputStatsStructure(outstats, stats); %#ok<ASGLU>

end


%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputePixelIdxList(L, CC, numObjs,stats,statsAlreadyComputed)
% Compute PixelIdxList from label matrix, L or Connected Component
% structure, CC.
% PixelIdxList
%   A P-by-1 matrix, where P is the number of pixels belonging to
%   the region.  Each element contains the linear index of the
%   corresponding pixel.

statsAlreadyComputed.PixelIdxList = true;

if numObjs ~= 0
    if isempty(CC)
        % Calculate regionLengths and regionIndices from label, L
        
        % Don't use coder.nullcopy as regionLengths is used to create the
        % pixelIdxList buffer.
        regionLengths = (zeros(numObjs,1));
        if coder.isColumnMajor
            for j = 1:size(L,2)
                for i = 1:size(L,1)
                    % Floor label value by casting.
                    idx = coder.internal.indexInt(L(i,j));
                    % Zero and negative label values represent the background.
                    if idx > coder.internal.indexInt(0)
                        regionLengths(idx,1) = regionLengths(idx,1) + 1;
                    end
                end
            end
            
            regionIndices = coder.nullcopy(zeros(sum(regionLengths,1),1));
            idxCount = coder.internal.indexInt([0;cumsum(regionLengths)]);
            j = coder.internal.indexInt(1);
            for q = 1:size(L,2)
                for p = 1:size(L,1)
                    % Floor label value by casting.
                    idx = coder.internal.indexInt(L(p,q));
                    % Zero and negative label values represent the background.
                    if idx > coder.internal.indexInt(0)
                        idxCount(idx) = coder.internal.indexPlus(idxCount(idx),1);
                        regionIndices(idxCount(idx),1) = j;
                    end
                    j = coder.internal.indexPlus(j,1);
                end
            end
        else % coder.isRowMajor
            
            for i = 1:size(L,1)
                for j = 1:size(L,2)
                    % Floor label value by casting.
                    idx = coder.internal.indexInt(L(i,j));
                    % Zero and negative label values represent the background.
                    if idx > coder.internal.indexInt(0)
                        regionLengths(idx,1) = regionLengths(idx,1) + 1;
                    end
                end
            end
            
            regionIndices = coder.nullcopy(zeros(sum(regionLengths,1),1));
            idxCount = coder.internal.indexInt([0;cumsum(regionLengths)]);
            % jRow and j are both linear indices of L traversed along
            % columns. The difference is that they are incremented
            % differently.
            j = coder.internal.indexInt(1);
            jRow = coder.internal.indexInt(1);
            for p = 1:size(L,1)
                for q = 1:size(L,2)
                    % Floor label value by casting.
                    idx = coder.internal.indexInt(L(p,q));
                    % Zero and negative label values represent the background.
                    if idx > coder.internal.indexInt(0)
                        idxCount(idx) = coder.internal.indexPlus(idxCount(idx),1);
                        regionIndices(idxCount(idx),1) = jRow;
                    end
                    % jRow is the linear index of elements in L. It is
                    % incremented by the number of rows in the label matrix
                    % because we are traversing along rows.
                    jRow = coder.internal.indexPlus(jRow,size(L,1));
                end
                % j is the linear index of elements in L traversed along
                % columns. It is incremented after each row is fully
                % traversed. jRow is reset to j after each row traversal.
                j = coder.internal.indexPlus(j,1);
                jRow = j;
            end
        end
    else
        % Calculate regionLengths and regionIndices from CC struct
        regionIndices = CC.RegionIndices;
        regionLengths = CC.RegionLengths;
    end
    
    idxCount = coder.internal.indexInt([0;cumsum(regionLengths)]);
    for k = 1:numel(stats)
        if coder.isColumnMajor
            stats(k).PixelIdxList = regionIndices(idxCount(k)+1:idxCount(k+1),1);
        else
            % Sort the indices to match column-major output
            stats(k).PixelIdxList = sort(regionIndices(idxCount(k)+1:idxCount(k+1),1));
        end
    end
    
end
end

%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeArea(stats, statsAlreadyComputed)
%   The area is defined to be the number of pixels belonging to
%   the region.

if ~statsAlreadyComputed.Area
    statsAlreadyComputed.Area = true;
    
    for k = 1:length(stats)
        stats(k).Area = size(stats(k).PixelIdxList, 1);
    end
end

end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeEquivDiameter(stats, statsAlreadyComputed)
%   Computes the diameter of the circle that has the same area as
%   the region.
%   Ref: Russ, The Image Processing Handbook, 2nd ed, 1994, page
%   511.

if ~statsAlreadyComputed.EquivDiameter
    statsAlreadyComputed.EquivDiameter = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputeArea(stats,statsAlreadyComputed);
    
    factor = 2/sqrt(pi);
    for k = 1:length(stats)
        stats(k).EquivDiameter = factor * sqrt(stats(k).Area);
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeFilledImage(imageSize, stats,statsAlreadyComputed)
%   Uses imfill to fill holes in the region.

if ~statsAlreadyComputed.FilledImage
    statsAlreadyComputed.FilledImage = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputeImage(imageSize,stats,statsAlreadyComputed);
    
    conn = conndef(numel(imageSize),'minimal');
    
    for k = 1:length(stats)
        stats(k).FilledImage = imfill(stats(k).Image,conn,'holes');
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeFilledArea(imageSize,stats,statsAlreadyComputed)
%   Computes the number of "on" pixels in FilledImage.

if ~statsAlreadyComputed.FilledArea
    statsAlreadyComputed.FilledArea = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputeFilledImage(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        if numel(size(stats(k).FilledImage == 2))
            stats(k).FilledArea = sum(sum(stats(k).FilledImage,1),2);
        else
            stats(k).FilledArea = sum(stats(k).FilledImage(:));
        end
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeCentroid(imageSize,stats, statsAlreadyComputed)
%   [mean(r) mean(c)]

if ~statsAlreadyComputed.Centroid
    statsAlreadyComputed.Centroid = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputePixelList(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        stats(k).Centroid = mean(stats(k).PixelList,1);
    end
    
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeEulerNumber(imageSize,stats,statsAlreadyComputed)
%   Calls BWEULER on 'Image' using 8-connectivity

if ~statsAlreadyComputed.EulerNumber
    statsAlreadyComputed.EulerNumber = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputeImage(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        stats(k).EulerNumber = bweuler(stats(k).Image,8);
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeExtrema(imageSize,stats, statsAlreadyComputed)
%   A 8-by-2 array; each row contains the x and y spatial
%   coordinates for these extrema:  leftmost-top, rightmost-top,
%   topmost-right, bottommost-right, rightmost-bottom, leftmost-bottom,
%   bottommost-left, topmost-left.
%   reference: Haralick and Shapiro, Computer and Robot Vision
%   vol I, Addison-Wesley 1992, pp. 62-64.

if ~statsAlreadyComputed.Extrema
    statsAlreadyComputed.Extrema = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputePixelList(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        pixelList = stats(k).PixelList;
        if (isempty(pixelList))
            stats(k).Extrema = zeros(8,2) + 0.5;
        else
            r = pixelList(:,2);
            c = pixelList(:,1);
            
            minR = min(r);
            maxR = max(r);
            minC = min(c);
            maxC = max(c);
            
            minRSet = r == minR;
            maxRSet = r == maxR;
            minCSet = c == minC;
            maxCSet = c == maxC;
            
            % Points 1 and 2 are on the top row.
            r1 = minR;
            r2 = minR;
            % Find the minimum and maximum column coordinates for
            % top-row pixels.
            tmp = c(minRSet);
            c1 = min(tmp);
            c2 = max(tmp);
            
            % Points 3 and 4 are on the right column.
            % Find the minimum and maximum row coordinates for
            % right-column pixels.
            tmp = r(maxCSet);
            r3 = min(tmp);
            r4 = max(tmp);
            c3 = maxC;
            c4 = maxC;
            
            % Points 5 and 6 are on the bottom row.
            r5 = maxR;
            r6 = maxR;
            % Find the minimum and maximum column coordinates for
            % bottom-row pixels.
            tmp = c(maxRSet);
            c5 = max(tmp);
            c6 = min(tmp);
            
            % Points 7 and 8 are on the left column.
            % Find the minimum and maximum row coordinates for
            % left-column pixels.
            tmp = r(minCSet);
            r7 = max(tmp);
            r8 = min(tmp);
            c7 = minC;
            c8 = minC;
            
            stats(k).Extrema = [c1-0.5 r1-0.5
                c2+0.5 r2-0.5
                c3+0.5 r3-0.5
                c4+0.5 r4+0.5
                c5+0.5 r5+0.5
                c6-0.5 r6+0.5
                c7-0.5 r7+0.5
                c8-0.5 r8-0.5];
        end
    end
    
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeBoundingBox(imageSize,stats,statsAlreadyComputed)
%   [minC minR width height]; minC and minR end in .5.

if ~statsAlreadyComputed.BoundingBox
    statsAlreadyComputed.BoundingBox = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputePixelList(imageSize,stats,statsAlreadyComputed);
    
    num_dims = numel(imageSize);
    
    for k = 1:length(stats)
        list = stats(k).PixelList;
        if (isempty(list))
            stats(k).BoundingBox = [0.5*ones(1,num_dims) zeros(1,num_dims)];
        else
            min_corner = min(list,[],1) - 0.5;
            max_corner = max(list,[],1) + 0.5;
            stats(k).BoundingBox = [min_corner (max_corner - min_corner)];
        end
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeSubarrayIdx(imageSize,stats,statsAlreadyComputed)
%   For internal purposes only. Find an array containing indices so that 
%   L(idx(1:idxLength(1)),idx(idxLength(1)+1:idxLength(2)) extracts the 
%   elements of L inside the bounding box. This routine adds a new field to 
%   the stats structure, SubarrayIdxLengths to store the lengths of the
%   indices.

if ~statsAlreadyComputed.SubarrayIdx
    statsAlreadyComputed.SubarrayIdx = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputeBoundingBox(imageSize,stats,statsAlreadyComputed);
    num_dims = numel(imageSize);
    for k = 1:length(stats)
        boundingBox = stats(k).BoundingBox;
        left = boundingBox(1:(end/2));
        right = boundingBox((1+end/2):end);
        left = left(1,[2 1]);
        right = right(1,[2 1]);
        
        idx = zeros(1,0);
        coder.varsize('idx',[],[0 1]);
        idxLengths = zeros(1,2);
        for p = 1:num_dims
            first = left(p) + 0.5;
            last = first + right(p) - 1;
            idx = [idx first:last]; %#ok<AGROW>
            idxLengths(p) = last-first+1;
        end
        stats(k).SubarrayIdx = idx;
        stats(k).SubarrayIdxLengths = idxLengths;
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeEllipseParams(imageSize,stats,statsAlreadyComputed)
%   Find the ellipse that has the same normalized second central moments as the
%   region.  Compute the axes lengths, orientation, and eccentricity of the
%   ellipse.  Ref: Haralick and Shapiro, Computer and Robot Vision vol I,
%   Addison-Wesley 1992, Appendix A.

if ~(statsAlreadyComputed.MajorAxisLength && ...
        statsAlreadyComputed.MinorAxisLength && ...
        statsAlreadyComputed.Orientation && ...
        statsAlreadyComputed.Eccentricity)
    statsAlreadyComputed.MajorAxisLength = true;
    statsAlreadyComputed.MinorAxisLength = true;
    statsAlreadyComputed.Eccentricity = true;
    statsAlreadyComputed.Orientation = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputePixelList(imageSize,stats,statsAlreadyComputed);
    [stats, statsAlreadyComputed] = ...
        ComputeCentroid(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        list = stats(k).PixelList;
        if (isempty(list))
            stats(k).MajorAxisLength = 0;
            stats(k).MinorAxisLength = 0;
            stats(k).Eccentricity = 0;
            stats(k).Orientation = 0;
            
        else
            % Assign X and Y variables so that we're measuring orientation
            % counterclockwise from the horizontal axis.
            
            xbar = stats(k).Centroid(1);
            ybar = stats(k).Centroid(2);
            
            x = list(:,1) - xbar;
            y = -(list(:,2) - ybar); % This is negative for the
            % orientation calculation (measured in the
            % counter-clockwise direction).
            
            N = length(x);
            
            % Calculate normalized second central moments for the region. 1/12 is
            % the normalized second central moment of a pixel with unit length.
            uxx = sum(x.^2)/N + 1/12;
            uyy = sum(y.^2)/N + 1/12;
            uxy = sum(x.*y)/N;
            
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
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeExtent(imageSize,stats,statsAlreadyComputed)
%   Area / (BoundingBox(3) * BoundingBox(4))

if ~statsAlreadyComputed.Extent
    statsAlreadyComputed.Extent = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputeArea(stats,statsAlreadyComputed);
    [stats, statsAlreadyComputed] = ...
        ComputeBoundingBox(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        if (stats(k).Area == 0)
             % Guarded NaN
            stats(k).Extent = coder.internal.nan(1);
        else
            stats(k).Extent = stats(k).Area / prod(stats(k).BoundingBox(3:4));
        end
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeImage(imageSize,stats,statsAlreadyComputed)
%   Binary image containing "on" pixels corresponding to pixels
%   belonging to the region.  The size of the image corresponds
%   to the size of the bounding box for each region.

if ~statsAlreadyComputed.Image
    statsAlreadyComputed.Image = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputeSubarrayIdx(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        subarrayIdx = stats(k).SubarrayIdx;
        idxCount = cumsum([0 stats(k).SubarrayIdxLengths])+1;
        
        if isempty(subarrayIdx(idxCount(1):idxCount(2)-1)) || ...
                isempty(subarrayIdx(idxCount(2):idxCount(3)-1))
            stats(k).Image = logical([]);
        else
            maxBound = zeros(1,2);
            minBound = zeros(1,2);
            
            maxBound(1) = max(subarrayIdx(idxCount(1):(idxCount(2)-1)));
            maxBound(2) = max(subarrayIdx(idxCount(2):(idxCount(3)-1)));
            
            minBound(1) = min(subarrayIdx(idxCount(1):(idxCount(2)-1)));
            minBound(2) = min(subarrayIdx(idxCount(2):(idxCount(3)-1)));
            
            sizeOfSubImage = maxBound - minBound + 1;
            
            % Shift the pixelList subscripts so that they is relative to
            % sizeOfSubImage.
            if min(sizeOfSubImage) == 0
                stats(k).Image = logical(sizeOfSubImage);
            else
                subtractby = maxBound-sizeOfSubImage;
                
                % swap subtractby so that it is in the same order as
                % PixelList, i.e., c r ....
                subtractby = subtractby(:, [2 1]);
                
                % Pseudo code:
                % ndimsL = numel(imageSize);
                % for m = 1 : ndimsL
                %    subscript(m) = stats(k).PixelList(:,m) - subtractby(m);
                % end
                %
                % subscript = subscript(:,[2 1]);
                % idx = sub2ind(sizeOfSubImage,subscript{:});
                
                % swap subscript back into the order sub2ind expects, i.e.
                % r c ...
                I = false(sizeOfSubImage);
                r = stats(k).PixelList(:,2) - subtractby(2);
                c = stats(k).PixelList(:,1) - subtractby(1);
                for p = 1:numel(r)
                    I(r(p),c(p)) = true;
                end
                stats(k).Image = I;
            end
        end
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputePixelList(imageSize,stats,statsAlreadyComputed)
%   A P-by-2 matrix, where P is the number of pixels belonging to
%   the region.  Each row contains the row and column
%   coordinates of a pixel.

if ~statsAlreadyComputed.PixelList
    statsAlreadyComputed.PixelList = true;
    
    ndimsL = numel(imageSize);
    % Convert the linear indices to subscripts and store
    % the results in the pixel list.  Reverse the order of the first
    % two subscripts to form x-y order.
    for k = 1:length(stats)
        if ~isempty(stats(k).PixelIdxList)
            [i, j] = ind2sub(imageSize, stats(k).PixelIdxList);
            % swap subscripts returned from ind2sub i.e. c r ...
            stats(k).PixelList = [j, i];
        else
            stats(k).PixelList = zeros(0,ndimsL);
        end
    end
end
end

%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputePerimeterWithLabelMatrix(L, numObjs, stats, statsAlreadyComputed)

if ~statsAlreadyComputed.Perimeter
    statsAlreadyComputed.Perimeter = true;
    
    % Find perimeter of all regions in the label matrix
    stats = computePerimeter(stats, double(L), numObjs, 8);
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputePerimeterWithPixelIdxList(imageSize, stats, statsAlreadyComputed)

if ~statsAlreadyComputed.Perimeter
    statsAlreadyComputed.Perimeter = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputeImage(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        % Find perimeter of the k-th region.
        stats(k) = computePerimeter(stats(k), double(stats(k).Image), 1, 8);
    end
end
end
%--------------------------------------------------------------------------
function stats = computePerimeter(stats, L, numObjs, conn)
% Calculate perimeter of numObjs regions in L and store in the
% corresponding 'Perimeter' field of the stats structure array using 
% label value as the index.

if numObjs > 0
    L_pad = padarray(L,[1 1],0,'both');
    
    numPadRows = size(L_pad,1);
    numPadCols = size(L_pad,2);
    
    visitedLabels = false(numObjs,1);
    
    % Set trace direction
    direc = CLOCKWISE;
    
    % Create search direction LUTs
    [fOffsets, fNextDirectionLut, fNextSearchDirectionLut,...
        fStartMarker, fBoundaryMarker] = calculateLUTs(L_pad, conn, direc);
    
    fNextSearchDir = setNextSearchDirection(direc, conn);
    
    % Index into unpadded label image, L
    idxOrig = coder.internal.indexInt(1);        
    currentLabel = coder.internal.indexInt(-1);
    
    for c = 2:numPadCols-1
        for r = 2:numPadRows-1
            % idx = numPadRows*(c-1) + r;
            idx = coder.internal.indexPlus(coder.internal.indexTimes(coder.internal.indexMinus(c,1),numPadRows),r);
            
            % Find the label of the current pixel. Floor label value by 
            % casting. Note: label can be negative in which case pixelLabel
            % will be negative.
            [labelR,labelC] = ind2sub(size(L),idxOrig);
            pixelLabel = coder.internal.indexInt(L(labelR,labelC));
            
            % You are at a pixel of another boundary if it is not 0 or 
            % negative and if it doesn't have the same label as the current
            % label.
            if (L(labelR,labelC) > 0 && ...
                    L(labelR,labelC) ~= currentLabel && visitedLabels(pixelLabel) == false)
                
                % Set the current label to the unvisited label of the first
                %  boundary pixel.
                currentLabel = pixelLabel;
                %We've found the start of the next boundary.
                [boundary, L_pad] = traceRegionBoundary(L, L_pad, idx, ...
                    currentLabel, conn, fOffsets, fStartMarker, fBoundaryMarker,...
                    fNextSearchDir, fNextDirectionLut, fNextSearchDirectionLut);
                
                stats(currentLabel).Perimeter = computePerimeterFromBoundary(boundary);
                
                visitedLabels(pixelLabel) = true;
            end
            idxOrig = idxOrig + 1;
        end
    end
end
end
%--------------------------------------------------------------------------
function [fOffsets, fNextDirectionLut, fNextSearchDirectionLut,...
    fStartMarker, fBoundaryMarker] = calculateLUTs(bwPadImage, conn, direc)
% Create lookup tables for region boundary tracing.

coder.inline('always');
coder.internal.prefer_const(bwPadImage, conn, direc);

fStartMarker = START_DOUBLE;
fBoundaryMarker = BOUNDARY_DOUBLE;

numPadRows = size(bwPadImage,1);

% Compute the linear indexing offsets to take us from a pixel to its
% neighbors.
M = numPadRows;

fOffsets = coder.nullcopy(zeros(conn,1,coder.internal.indexIntClass));
if(conn == 8)
    % Order is: [N, NE, E, SE, S, SW, W, NW];
    fOffsets(1)=-1;fOffsets(2)= M-1;fOffsets(3)=  M;fOffsets(4)= M+1;
    fOffsets(5)= 1;fOffsets(6)=-M+1;fOffsets(7)= -M;fOffsets(8)=-M-1;
else
    % Order is [N, E, S, W]
    fOffsets(1)=-1;fOffsets(2)=M;fOffsets(3)=1;fOffsets(4)=-M;
end

ndl8c = coder.internal.indexInt([2,3,4,5,6,7,8,1]);
nsdl8c = coder.internal.indexInt([8,8,2,2,4,4,6,6]);

ndl4c = coder.internal.indexInt([2,3,4,1]);
nsdl4c = coder.internal.indexInt([4,1,2,3]);

ndl8cc = coder.internal.indexInt([8,1,2,3,4,5,6,7]);
nsdl8cc = coder.internal.indexInt([2,4,4,6,6,8,8,2]);

ndl4cc = coder.internal.indexInt([4,1,2,3]);
nsdl4cc = coder.internal.indexInt([2,3,4,1]);

% fNextDirectionLut is a lookup table.  Given that we just looked at
% neighbor in a given direction, which neighbor do we look at next?

% fNextSearchDirectionLut is another lookup table.
% Given the direction from pixel k to pixel k+1, what is the direction
% to start with when examining the neighborhood of pixel k+1?

if(direc == CLOCKWISE)
    if (conn == 8)
        fNextDirectionLut =  ndl8c;
    else
        fNextDirectionLut = ndl4c;
    end
    if (conn == 8)
        fNextSearchDirectionLut = nsdl8c;
    else
        fNextSearchDirectionLut = nsdl4c;
    end
else % counterclockwise
    if (conn == 8)
        fNextDirectionLut = ndl8cc;
    else
        fNextDirectionLut = ndl4cc;
    end
    if (conn == 8)
        fNextSearchDirectionLut = nsdl8cc;
    else
        fNextSearchDirectionLut = nsdl4cc;
    end
end
end
%--------------------------------------------------------------------------
function [boundary, L_pad] = traceRegionBoundary(L, L_pad, idx, ...
    currentLabel, conn, fOffsets, fStartMarker, fBoundaryMarker,...
    fNextSearchDir, fNextDirectionLut, fNextSearchDirectionLut)
% This function traces a single contour of a region based on its label. It
% takes the original label matrix, the padded label matrix, a linear index
% to the initial border pixel belonging to the object that's going to be
% traced, and the current pixel label. This method needs to be
% pre-configured by invoking initializeTracer routine. It returns an array
% containing the X-Y coordinates of border pixels.

coder.varsize('fScratch',[],[1 0]);
fScratch  = zeros(0,1,coder.internal.indexIntClass());

% Initialize loop variables
fScratch = [fScratch;idx];
[currentR,currentC] = ind2sub(size(L_pad),idx);
L_pad(currentR,currentC) = fStartMarker;
done = false;
numPixels = 1;
currentPixel = idx;
nextSearchDir = fNextSearchDir;
initDepartureDir = coder.internal.indexInt(-1);
numPadRows = size(L_pad,1);

while(~done)
    
    % Find the next boundary pixel.
    direction      = nextSearchDir;
    foundNextPixel = false;
    
    for k = 1:conn
        
        %Try to locate the next pixel in the chain
        neighbor = currentPixel + fOffsets(direction);
        [neighborR,neighborC] = ind2sub(size(L_pad),neighbor);
            
        if(isRegionBoundaryPixel(L,L_pad, ...
                neighbor, neighborR,neighborC,currentLabel))
            
            % Found the next boundary pixel.
            [currentR,currentC] = ind2sub(size(L_pad),currentPixel);
            if(L_pad(currentR,currentC) == fStartMarker && ...
                    initDepartureDir == -1)
                
                % We are making the initial departure from the
                % starting pixel.
                initDepartureDir = direction;
                
            elseif(L_pad(currentR,currentC) == fStartMarker && ...
                    initDepartureDir == direction)
                
                % We are about to retrace our path.
                % That means we're done.
                done = true;
                foundNextPixel = true;
                break;
            end
            
            % Take the next step along the boundary.
            nextSearchDir = ...
                fNextSearchDirectionLut(direction);
            foundNextPixel = true;
            
            % First use numPixels as an index into scratch array,
            % then increment it
            % First increment it and then use numPixels as an index into
            % scratch array,
            numPixels = numPixels + 1;
            fScratch = [fScratch; neighbor]; %#ok<AGROW>
            
            if(L_pad(neighborR,neighborC) ~= fStartMarker)
                L_pad(neighborR,neighborC) = fBoundaryMarker;
            end
            
            currentPixel = neighbor;
            break;
        end
        direction = fNextDirectionLut(direction);
    end
    
    if (~foundNextPixel)
        
        % If there is no next neighbor, the region must
        % just have a single pixel.
        numPixels = 2;
        fScratch = [fScratch;fScratch]; %#ok<AGROW>
        done = true;
    end
end

% Create boundary array and stuff it with proper data
boundary = coder.nullcopy(zeros(numPixels,2));

for idx = 1:numPixels
    boundary(idx,1) = mod(fScratch(idx)-1,numPadRows);
    boundary(idx,2) = floor(double(fScratch(idx)-1)/numPadRows);
end

end
%--------------------------------------------------------------------------
function isBoundaryPix = isRegionBoundaryPixel(L, L_pad, ...
    idx, idxR, idxC, currentLabel)

isBoundaryPix = false;
numRows = size(L,1);
numPadRows = size(L_pad,1);

% First, make sure that it's not a background pixel, otherwise it's
% an automatic failure.
if(L_pad(idxR, idxC))
    
    % Make sure that pixel has the same label as the currentLabel,
    % otherwise it's an automatic failure.
    idxIntoOrig = calculateIdxIntoOrig(numRows,numPadRows,idx-1);
    [labelR, labelC] = ind2sub(size(L),idxIntoOrig+1);
    if (L(labelR, labelC) == currentLabel)
        isBoundaryPix = true;
    end
end
end

%--------------------------------------------------------------------------
function ndx = calculateIdxIntoOrig(numRows, numPadRows, idx)
% Calculate index into original label matrix given an index into the padded
% label matrix.

r = mod(idx,numPadRows);
c = floor(double(idx) / numPadRows);
% ndx = (r + (c-1) * numRows) - 1;
ndx = coder.internal.indexMinus(coder.internal.indexPlus(r, coder.internal.indexTimes(coder.internal.indexMinus(c,1),numRows)),1);
end

%--------------------------------------------------------------------------
% Values used for marking the starting and boundary pixels.

function out = START_DOUBLE()

out = int8(-2);
end

function out = BOUNDARY_DOUBLE()

out = int8(-3);

end

function out = CLOCKWISE()

out = 1;

end
%--------------------------------------------------------------------------
function fNextSearchDir = setNextSearchDirection(direc, conn)
% Given an initial boundary pixel and an initial 'best guess' search
% direction, this method verifies that the best guess is valid and if it
% is not, then it finds the proper direction.
%
% NOTE: setNextSearchDirection method assumes that idx points to a valid
%       boundary pixel. It's the user's responsibility to make sure that
%       this is the case

% Next search direction depends on trace direction and connectivity
if (direc == CLOCKWISE)
    fNextSearchDir = coder.internal.indexInt(1);
else
    if (conn == 8)
        fNextSearchDir = coder.internal.indexInt(7);
    else
        fNextSearchDir = coder.internal.indexInt(3);
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputePixelValues(I,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.PixelValues
    statsAlreadyComputed.PixelValues = true;
    
    for k = 1:length(stats)
        stats(k).PixelValues = coder.nullcopy(ones(size(stats(k).PixelIdxList),'like',I));
        [r,c] = ind2sub(size(I),stats(k).PixelIdxList);
        for idx = 1:numel(stats(k).PixelValues)
            stats(k).PixelValues(idx,1) = I(r(idx),c(idx));
        end
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeWeightedCentroid(imageSize,I,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.WeightedCentroid
    statsAlreadyComputed.WeightedCentroid = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputePixelList(imageSize,stats,statsAlreadyComputed);
    
    [stats, statsAlreadyComputed] = ...
        ComputePixelValues(I,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        Intensity = stats(k).PixelValues;
        sumIntensity = sum(Intensity);
        numDims = size(stats(k).PixelList,2);
        
        if isreal(I)
            wc = zeros(1,numDims);
        else
            wc = complex(zeros(1,numDims));
        end
        for n = 1 : numDims
            M = sum(stats(k).PixelList(:,n) .* ...
                double( Intensity(:) ));
            wc(n) = M / sumIntensity;
        end
        stats(k).WeightedCentroid = wc;
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeMeanIntensity(I,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.MeanIntensity
    statsAlreadyComputed.MeanIntensity = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputePixelValues(I,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        stats(k).MeanIntensity = mean(stats(k).PixelValues);
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeMinIntensity(I,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.MinIntensity
    statsAlreadyComputed.MinIntensity = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputePixelValues(I,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        if ~isempty(stats(k).PixelValues)
            stats(k).MinIntensity = min(stats(k).PixelValues,[],1);
        end
    end
end
end
%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = ...
    ComputeMaxIntensity(I,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.MaxIntensity
    statsAlreadyComputed.MaxIntensity = true;
    
    [stats, statsAlreadyComputed] = ...
        ComputePixelValues(I,stats,statsAlreadyComputed);
    
    for k = 1:length(stats)
        if ~isempty(stats(k).PixelValues)
            stats(k).MaxIntensity = max(stats(k).PixelValues,[],1);
        end
    end
end
end

%--------------------------------------------------------------------------
function [I, reqStats, outstats] = parseInputsAndInitializeOutStruct(imageSize, argOffset, numObjs, varargin)
% Parse input property strings and create output stats struct array, 
% requested stats property enumeration and grayscale image, if specified.

coder.inline('always');
coder.internal.prefer_const(varargin);

% List of enumerated property strings is used to create the temporary stats 
% structure to store computed statistics. This list is different from 
% the list of property strings used to create the output structure
% subsequently.  
shapeStats = [...
    AREA
    CENTROID
    BOUNDINGBOX
    SUBARRAYIDX
    MAJORAXISLENGTH
    MINORAXISLENGTH
    ECCENTRICITY
    ORIENTATION
    IMAGE
    FILLEDIMAGE
    FILLEDAREA
    EULERNUMBER
    EXTREMA
    EQUIVDIAMETER
    EXTENT
    PIXELIDXLIST
    PIXELLIST
    PERIMETER
    ];

pixelValueStats = [...
    PIXELVALUES
    WEIGHTEDCENTROID
    MEANINTENSITY
    MININTENSITY
    MAXINTENSITY];

basicStats = [...
    AREA
    CENTROID
    BOUNDINGBOX];

numOrigInputArgs = numel(varargin);

if numOrigInputArgs == 1
    %REGIONPROPS(BW) or REGIONPROPS(L)
    I = [];
    reqStats = basicStats;
    [outstats, ~] = initializeStatsStruct([], numObjs, OUTPUTSTATS_BASIC);
    return;
    
elseif isnumeric(varargin{2}) || islogical(varargin{2})
    %REGIONPROPS(...,I) or REGIONPROPS(...,I,PROPERTIES)
    
    I = varargin{2};
    validateattributes(I, {'numeric','logical'},{}, mfilename, 'I', 2+argOffset);

    coder.internal.errorIf(~isequal(imageSize,size(I)), ...
        'images:regionprops:sizeMismatch');
    
    if numOrigInputArgs == 2
        %REGIONPROPS(BW,I) or REGIONPROPS(L,I)
        reqStats = basicStats;
        [outstats, ~] = initializeStatsStruct([], numObjs, OUTPUTSTATS_BASIC);
        return;
    else
        %REGIONPROPS(BW,I,PROPERTIES) or REGIONPROPS(L,I,PROPERTIES)
        officialStats = [shapeStats;pixelValueStats];
        startIdxForProp = 3;
        [reqStats, outstats] = getPropsFromInputAndInitializeOutStruct(...
            startIdxForProp, officialStats, basicStats, argOffset, ...
            I, numObjs, varargin{:});
    end
    
else
    %REGIONPROPS(BW,PROPERTIES) or REGIONPROPS(L,PROPERTIES)
    I = [];
    officialStats = shapeStats;
    startIdxForProp = 2;
    [reqStats, outstats] = getPropsFromInputAndInitializeOutStruct(...
        startIdxForProp, officialStats, basicStats, argOffset, ...
        I, numObjs, varargin{:});
end
end

%--------------------------------------------------------------------------
function [reqStats, outstats] = getPropsFromInputAndInitializeOutStruct(...
    startIdx, officialStats, basicStats, argOffset, I, numObjs, varargin)

% Parse property strings and initialize the output stats structure array.

coder.inline('always');
coder.internal.prefer_const(varargin,officialStats, basicStats, argOffset);

if strcmpi(varargin{startIdx}, 'all')
    %REGIONPROPS(...,'all')
    reqStats = officialStats;
    if startIdx == 3 
        % Grayscale image was specified
        [outstats, ~] = initializeStatsStruct(I, numObjs, OUTPUTSTATS_ALL_PIXELVALUESTATS);
    else
        % No Grayscale image was specified
        [outstats, ~] = initializeStatsStruct([], numObjs, OUTPUTSTATS_ALL_SHAPESTATS);
    end    
    return;
elseif strcmpi(varargin{startIdx}, 'basic')
    %REGIONPROPS(...,'basic')
    reqStats = basicStats;
    [outstats, ~] = initializeStatsStruct([], numObjs, OUTPUTSTATS_BASIC);
    return;
else
    %REGIONPROPS(...,PROP1,PROP2,..)
    % Do nothing here and continue parsing individual properties.
end

numProps = numel(varargin)-startIdx+1;
reqStats = zeros(numProps,1);
 
% List of valid property strings used to create the output stats structure
% array. Note: 'all' and 'basic' are not included in this list.
pixelValueStatsStrs = { ...
    'MaxIntensity', 'MeanIntensity', 'MinIntensity', ...
    'PixelValues', 'WeightedCentroid'};

shapeMeasurementProperties = { ...
    'Area', 'BoundingBox', 'Centroid', 'Eccentricity', ...
    'EquivDiameter', 'EulerNumber', 'Extent', ...
    'Extrema', 'FilledArea', 'FilledImage', 'Image', ...
    'MajorAxisLength', 'MinorAxisLength', 'Orientation', ...
    'Perimeter', 'PixelIdxList', 'PixelList'};

unsupportedProperties = { ...
    'ConvexArea', 'ConvexHull', 'ConvexImage', 'Solidity', 'SubarrayIdx'};

% Concatenate official and pixel value statistics.
officialAndPixelValueStatsStrs = { ...
    pixelValueStatsStrs{:} shapeMeasurementProperties{:} unsupportedProperties{:}}; %#ok<CCAT>

p = 1;
for k = coder.unroll(startIdx:numel(varargin))
    coder.internal.errorIf(~ischar(varargin{k}),'images:regionprops:invalidType');
    
    % Verify that the property is legal
    prop = validatestring(varargin{k}, officialAndPixelValueStatsStrs, ...
        mfilename, 'PROPERTIES', k);
    % Exclude properties that are not supported
    % for codegen with a meaningful error message
    for idx = coder.unroll(1:numel(unsupportedProperties))
        coder.internal.errorIf(strcmp(prop, unsupportedProperties{idx}),...
            'images:regionprops:codegenUnsupportedProperty', prop);
    end
    
    noGrayscaleImageAsInput = (startIdx == 2);
    if noGrayscaleImageAsInput
        % This code block exists so that regionprops can throw a more
        % meaningful error message if the user want a pixel value based
        % measurement but only specifies a label matrix as an input.
        for idx = coder.unroll(1:numel(pixelValueStatsStrs))
            coder.internal.errorIf(strcmp(prop, pixelValueStatsStrs{idx}),...
                'images:regionprops:needsGrayscaleImage', prop);
        end
    end
    
    % Initialize output stats one property at a time (excluding 'basic'
    % and 'all').
    if strcmpi(prop,'Area')
        statsOneObj.Area = 0;
    elseif strcmp(prop,'FilledImage')
        statsOneObj.FilledImage = false(0,0);
        coder.varsize('statsOneObj.FilledImage',[],[1 1]);
    elseif strcmp(prop,'FilledArea')
        statsOneObj.FilledArea = 0;
    elseif strcmp(prop,'Centroid')
        statsOneObj.Centroid = zeros(1,2);
    elseif strcmp(prop,'EulerNumber')
        statsOneObj.EulerNumber = 0;
    elseif strcmp(prop,'EquivDiameter')
        statsOneObj.EquivDiameter = 0;
    elseif strcmp(prop,'Extrema')
        statsOneObj.Extrema = zeros(8,2);
    elseif strcmp(prop,'BoundingBox')
        statsOneObj.BoundingBox = zeros(1,4);
    elseif strcmp(prop,'MajorAxisLength')
        statsOneObj.MajorAxisLength = 0;
    elseif strcmp(prop,'MinorAxisLength')
        statsOneObj.MinorAxisLength = 0;
    elseif strcmp(prop,'Orientation')
        statsOneObj.Orientation = 0;
    elseif strcmp(prop,'Eccentricity')
        statsOneObj.Eccentricity = 0;
    elseif strcmp(prop,'Solidity')
        statsOneObj.Solidity = 0;
    elseif strcmp(prop,'Extent')
        statsOneObj.Extent = 0;
    elseif strcmp(prop,'Image')
        statsOneObj.Image = false(0,0);
        coder.varsize('statsOneObj.Image',[],[1 1]);
    elseif strcmp(prop,'PixelList')
        statsOneObj.PixelList = zeros(0,2);
        coder.varsize('statsOneObj.PixelList',[Inf 2],[1 0]);
    elseif strcmp(prop,'PixelIdxList')
        statsOneObj.PixelIdxList = zeros(0,1);
        coder.varsize('statsOneObj.PixelIdxList',[Inf 1],[1 0]);
    elseif strcmp(prop,'Perimeter')
        statsOneObj.Perimeter = 0;
    elseif strcmp(prop,'PixelValues')
        if islogical(I)
            statsOneObj.PixelValues = false(0,1);
        else
            statsOneObj.PixelValues = zeros(0,1,'like',I);
        end
        coder.varsize('statsOneObj.PixelValues',[Inf 1],[1 0]);
    elseif strcmp(prop,'WeightedCentroid')
        if isreal(I)
            statsOneObj.WeightedCentroid = zeros(1,2);
        else
            statsOneObj.WeightedCentroid = complex(zeros(1,2));
        end
    elseif strcmp(prop,'MeanIntensity')
        if isreal(I)
            statsOneObj.MeanIntensity = 0;
        else
            statsOneObj.MeanIntensity = complex(0);
        end
    elseif strcmp(prop,'MinIntensity')
        if islogical(I)
            statsOneObj.MinIntensity = false(1,1);
        else
            statsOneObj.MinIntensity = zeros(1,1,'like',I);
        end
    elseif strcmp(prop,'MaxIntensity')
        if islogical(I)
            statsOneObj.MaxIntensity = false(1,1);
        else
            statsOneObj.MaxIntensity = zeros(1,1,'like',I);
        end
    else
        assert(false, 'Invalid property value');
    end
    
    % Convert requested property string to enum
    propEnum = convertPropStrToEnum(prop);
    reqStats(p) = coder.const(propEnum);
    p = p + 1;
end

outstats = repmat(statsOneObj, numObjs, 1);

end

%--------------------------------------------------------------------------
function propEnum = convertPropStrToEnum(prop)
% Convert property string to an enumeration

switch prop
    case 'Area'
        propEnum = AREA;
    case 'FilledImage'
        propEnum = FILLEDIMAGE;
    case 'FilledArea'
        propEnum = FILLEDAREA;
    case 'Centroid'
        propEnum = CENTROID;
    case 'EulerNumber'
        propEnum = EULERNUMBER;
    case 'EquivDiameter'
        propEnum = EQUIVDIAMETER;
    case 'Extrema'
        propEnum = EXTREMA;
    case 'BoundingBox'
        propEnum = BOUNDINGBOX;
    case 'SubarrayIdx'
        propEnum = SUBARRAYIDX;
    case 'MajorAxisLength'
        propEnum = MAJORAXISLENGTH;
    case 'MinorAxisLength'
        propEnum = MINORAXISLENGTH;
    case 'Orientation'
        propEnum = ORIENTATION;
    case 'Eccentricity'
        propEnum = ECCENTRICITY;
    case 'Solidity'
        propEnum = SOLIDITY;
    case 'Extent'
        propEnum = EXTENT;
    case 'ConvexArea'
        propEnum = CONVEXAREA;
    case 'ConvexImage'
        propEnum = CONVEXIMAGE;
    case 'ConvexHull'
        propEnum = CONVEXHULL;
    case 'Image'
        propEnum = IMAGE;
    case 'PixelList'
        propEnum = PIXELLIST;
    case 'PixelIdxList'
        propEnum = PIXELIDXLIST;
    case 'PerimeterOld'
        propEnum = PERIMETEROLD;
    case 'Perimeter'
        propEnum = PERIMETER;
    case 'PixelValues'
        propEnum = PIXELVALUES;
    case 'WeightedCentroid'
        propEnum = WEIGHTEDCENTROID;
    case 'MeanIntensity'
        propEnum = MEANINTENSITY;
    case 'MinIntensity'
        propEnum = MININTENSITY;
    case 'MaxIntensity'
        propEnum = MAXINTENSITY;
    otherwise
        error('Invalid property string');
end
end
%--------------------------------------------------------------------------

function propEnum = AREA()
coder.inline('always');
propEnum = int8(1);
end

function propEnum = CENTROID()
coder.inline('always');
propEnum = int8(2);
end

function propEnum = BOUNDINGBOX()
coder.inline('always');
propEnum = int8(3);
end

function propEnum = SUBARRAYIDX()
coder.inline('always');
propEnum = int8(4);
end

function propEnum = MAJORAXISLENGTH()
coder.inline('always');
propEnum = int8(5);
end

function propEnum = MINORAXISLENGTH()
coder.inline('always');
propEnum = int8(6);
end

function propEnum = ECCENTRICITY()
coder.inline('always');
propEnum = int8(7);
end

function propEnum = ORIENTATION()
coder.inline('always');
propEnum = int8(8);
end

function propEnum = CONVEXHULL()
coder.inline('always');
propEnum = int8(9);
end

function propEnum = CONVEXIMAGE()
coder.inline('always');
propEnum = int8(10);
end

function propEnum = CONVEXAREA()
coder.inline('always');
propEnum = int8(11);
end

function propEnum = IMAGE()
coder.inline('always');
propEnum = int8(12);
end

function propEnum = FILLEDIMAGE()
coder.inline('always');
propEnum = int8(13);
end

function propEnum = FILLEDAREA()
coder.inline('always');
propEnum = int8(14);
end

function propEnum = EULERNUMBER()
coder.inline('always');
propEnum = int8(15);
end

function propEnum = EXTREMA()
coder.inline('always');
propEnum = int8(16);
end

function propEnum = EQUIVDIAMETER()
coder.inline('always');
propEnum = int8(17);
end

function propEnum = SOLIDITY()
coder.inline('always');
propEnum = int8(18);
end

function propEnum = EXTENT()
coder.inline('always');
propEnum = int8(19);
end

function propEnum = PIXELIDXLIST()
coder.inline('always');
propEnum = int8(20);
end

function propEnum = PIXELLIST()
coder.inline('always');
propEnum = int8(21);
end

function propEnum = PERIMETER()
coder.inline('always');
propEnum = int8(22);
end

function propEnum = PERIMETEROLD()
coder.inline('always');
propEnum = int8(23);
end

function propEnum = PIXELVALUES()
coder.inline('always');
propEnum = int8(24);
end

function propEnum = WEIGHTEDCENTROID()
coder.inline('always');
propEnum = int8(25);
end

function propEnum = MEANINTENSITY()
coder.inline('always');
propEnum = int8(26);
end

function propEnum = MININTENSITY()
coder.inline('always');
propEnum = int8(27);
end

function propEnum = MAXINTENSITY()
coder.inline('always');
propEnum = int8(28);
end

function statsTypeEnum = TEMPSTATS_ALL()
coder.inline('always');
statsTypeEnum = int8(29);
end

function statsTypeEnum = OUTPUTSTATS_BASIC()
coder.inline('always');
statsTypeEnum = int8(30);
end

function statsTypeEnum = OUTPUTSTATS_ALL_SHAPESTATS()
coder.inline('always');
statsTypeEnum = int8(31);
end

function statsTypeEnum = OUTPUTSTATS_ALL_PIXELVALUESTATS()
coder.inline('always');
statsTypeEnum = int8(32);
end

%--------------------------------------------------------------------------
function [stats, statsAlreadyComputed] = initializeStatsStruct(I, numObjs, statsType)
% Use property enumeration to create and intialize fields of regionprops 
% structure

% Initialize the statsAlreadyComputed structure array. Need to avoid
% multiple calculations of the same property for performance reasons.
if isequal(statsType, TEMPSTATS_ALL) || ...
        isequal(statsType, OUTPUTSTATS_ALL_PIXELVALUESTATS) || ...
        isequal(statsType, OUTPUTSTATS_ALL_SHAPESTATS)
    
    statsAlreadyComputed.Area = false;
    statsOneObj.Area = 0;
    
    statsAlreadyComputed.Centroid = false;
    statsOneObj.Centroid = zeros(1,2);
    
    statsAlreadyComputed.BoundingBox = false;
    statsOneObj.BoundingBox = zeros(1,4);
    
    statsAlreadyComputed.MajorAxisLength = false;
    statsOneObj.MajorAxisLength = 0;
    
    statsAlreadyComputed.MinorAxisLength = false;
    statsOneObj.MinorAxisLength = 0;
    
    statsAlreadyComputed.Eccentricity = false;
    statsOneObj.Eccentricity = 0;
    
    statsAlreadyComputed.Orientation = false;
    statsOneObj.Orientation = 0;
    
    statsAlreadyComputed.Image = false;
    statsOneObj.Image = false(0,0);
    coder.varsize('statsOneObj.Image',[],[1 1]);
        
    statsAlreadyComputed.FilledImage = false;
    statsOneObj.FilledImage = false(0,0);
    coder.varsize('statsOneObj.FilledImage',[],[1 1]);
    
    statsAlreadyComputed.FilledArea = false;
    statsOneObj.FilledArea = 0;
    
    statsAlreadyComputed.EulerNumber = false;
    statsOneObj.EulerNumber = 0;
        
    statsAlreadyComputed.Extrema = false;
    statsOneObj.Extrema = zeros(8,2);
    
    statsAlreadyComputed.EquivDiameter = false;
    statsOneObj.EquivDiameter = 0;
    
    statsAlreadyComputed.Extent = false;
    statsOneObj.Extent = 0;
    
    statsAlreadyComputed.PixelIdxList = false;
    statsOneObj.PixelIdxList = zeros(0,1);
    coder.varsize('statsOneObj.PixelIdxList',[Inf 1],[1 0]);
    
    statsAlreadyComputed.PixelList = false;
    statsOneObj.PixelList = zeros(0,2);
    coder.varsize('statsOneObj.PixelList',[Inf 2],[1 0]);
    
    statsAlreadyComputed.Perimeter = false;
    statsOneObj.Perimeter = 0;
    
    % Create pixel value statistics for a valid grayscale image
    if isequal(statsType, TEMPSTATS_ALL) || ...
            isequal(statsType, OUTPUTSTATS_ALL_PIXELVALUESTATS)
        
        statsAlreadyComputed.PixelValues = false;
        if islogical(I)
            statsOneObj.PixelValues = false(0,1);
        else
            statsOneObj.PixelValues = zeros(0,1,'like',I);
        end
        coder.varsize('statsOneObj.PixelValues',[Inf 1],[1 0]);
        
        statsAlreadyComputed.WeightedCentroid = false;
        if isreal(I)
            statsOneObj.WeightedCentroid = zeros(1,2);
        else
            statsOneObj.WeightedCentroid = complex(zeros(1,2));
        end
        
        statsAlreadyComputed.MeanIntensity = false;
        if isreal(I)
            statsOneObj.MeanIntensity = 0;
        else
            statsOneObj.MeanIntensity = complex(0);
        end
        
        statsAlreadyComputed.MinIntensity = false;
        if islogical(I)
            statsOneObj.MinIntensity = false(1,1);
        else
            statsOneObj.MinIntensity = zeros(1,1,'like',I);
        end
        
        statsAlreadyComputed.MaxIntensity = false;
        if islogical(I)
            statsOneObj.MaxIntensity = false(1,1);
        else
            statsOneObj.MaxIntensity = zeros(1,1,'like',I);
        end
        
    end
    
elseif isequal(statsType, OUTPUTSTATS_BASIC)
    statsAlreadyComputed = struct('Area', false, 'Centroid', false, ...
        'BoundingBox', false);
    statsOneObj = struct('Area', 0, 'Centroid', zeros(1,2), 'BoundingBox', zeros(1,4));
end

% 'SubarrayIdx' property is required to store values to calculate other
% properties such as 'FilledArea'. Add this field only to the temporary
% stats struct.
if isequal(statsType, TEMPSTATS_ALL)
    statsAlreadyComputed.SubarrayIdx = false;
    statsOneObj.SubarrayIdx = zeros(1,0);
    coder.varsize('statsOneObj.SubarrayIdx',[],[0 1]);
    statsOneObj.SubarrayIdxLengths = zeros(1,2);
end

stats = repmat(statsOneObj, numObjs, 1);

end

%--------------------------------------------------------------------------
function perimeter = computePerimeterFromBoundary(B)

% Vectorized code:
%
% delta = diff(B,1).^2;
% if(size(delta,1) > 1)
%     isCorner  = any(diff([delta;delta(1,:)],1),2); % Count corners.
%     isEven    = any(~delta,2);
%     perimeter = sum(isEven,1)*0.980 + sum(~isEven,1)*1.406 - sum(isCorner,1)*0.091;
% else
%     perimeter = 0; % if the number of pixels is 1 or less.
% end

delta = coder.nullcopy(zeros(size(B,1)-1,size(B,2)));
for idx = 1:size(delta,1)
    delta(idx,1) = (B(idx+1,1)-B(idx,1)).^2;
    delta(idx,2) = (B(idx+1,2)-B(idx,2)).^2;
end

% Initialize perimeter. Perimeter is zero if the number of pixels is 1 or 
% less.
perimeter = 0;  
if(size(delta,1) > 1)
    temp = coder.nullcopy(zeros(size(delta)));
    isCorner = coder.nullcopy(false(size(delta,1),1));
    isEven = coder.nullcopy(false(size(delta,1),1));
    for idx = 1:size(delta,1)-1
        temp(idx,1) = delta(idx+1,1)-delta(idx,1);
        temp(idx,2) = delta(idx+1,2)-delta(idx,2);
        isCorner(idx) = temp(idx,1) || temp(idx,2);
        isEven(idx) = (~delta(idx,1)) || (~delta(idx,2));
        perimeter = perimeter + double(isEven(idx))*0.980 + double(~isEven(idx))*1.406 - double(isCorner(idx))*0.091; 
    end
    temp(end,1) = delta(end,1)-delta(1,1);
    temp(end,2) = delta(end,2)-delta(1,2);
    isCorner(end) = temp(end,1) || temp(end,2);
    isEven(end) = (~delta(end,1)) || (~delta(end,2));
    
    perimeter = perimeter + double(isEven(end))*0.980 + double(~isEven(end))*1.406 - double(isCorner(end))*0.091;

end
end

%--------------------------------------------------------------------------
function [outstats, stats] = populateOutputStatsStructure(outstats, stats)
% Copy requested properties from the temporary stats struct array to the
% output stats struct array.

for k = 1:length(stats)
    for fIdx = coder.unroll(0:eml_numfields(outstats(k))-1)
        fieldName = eml_getfieldname(outstats(k),fIdx);
        outstats(k).(fieldName) = coder.nullcopy(stats(k).(fieldName));
        if coder.isColumnMajor
            for vIdx = 1:numel(outstats(k).(fieldName))
                outstats(k).(fieldName)(vIdx) = stats(k).(fieldName)(vIdx);
            end
        else
            for vIdx = 1:size(outstats(k).(fieldName),2)
                for uIdx = 1:size(outstats(k).(fieldName),1)
                    outstats(k).(fieldName)(uIdx,vIdx) = stats(k).(fieldName)(uIdx,vIdx);
                end
            end
        end
    end
end

end

%--------------------------------------------------------------------------
function validateCC(CC)
%VALIDATECC Validates CC struct returned by bwconncomp

coder.internal.errorIf(~isstruct(CC), 'images:checkCC:expectedStruct');

tf = true;
for fIdx = coder.unroll(0:eml_numfields(CC)-1)
    fieldName = eml_getfieldname(CC,fIdx);
    tf = tf && any(strcmp(fieldName,{'Connectivity','ImageSize','NumObjects','RegionLengths','RegionIndices'}));
end

coder.internal.errorIf(~tf, 'images:checkCC:codegenMissingField');

end
