function outstats = regionprops3(varargin)
%REGIONPROPS3 Measure properties of 3-D volumetric image regions.
%   STATS = REGIONPROPS3(BW,PROPERTIES) measures a set of properties for
%   each connected component (object) in the 3-D volumetric binary image
%   BW. The output STATS is a MATLAB table with height (number of rows)
%   equal to the number of objects in BW, CC.NumObjects, or max(L(:)). The
%   variables of the table denote different properties for each region, as
%   specified by PROPERTIES. See help for 'table' in MATLAB for additional
%   methods for the table.
%
%   STATS = REGIONPROPS3(CC,PROPERTIES) measures a set of properties for
%   each connected component (object) in CC, which is a structure returned
%   by BWCONNCOMP. CC must be the connectivity of a 3-D volumetric image i.e.
%   CC.ImageSize must be a 1x3 vector.
%
%   STATS = REGIONPROPS3(L,PROPERTIES) measures a set of properties for each
%   labeled region in the 3-D label matrix L. Positive integer elements of L
%   correspond to different regions. For example, the set of elements of L
%   equal to 1 corresponds to region 1; the set of elements of L equal to 2
%   corresponds to region 2; and so on.
%
%   STATS = REGIONPROPS3(...,V,PROPERTIES) measures a set of properties for
%   each labeled region in the 3-D volumetric grayscale image V. The first
%   input to REGIONPROPS3 (BW, CC, or L) identifies the regions in V.  The
%   sizes must match: SIZE(V) must equal SIZE(BW), CC.ImageSize, or
%   SIZE(L).
%
%   PROPERTIES can be a comma-separated list of strings or character
%   vectors, a cell array containing strings or character vectors,
%   "all", or "basic". The set of valid measurement strings or character
%   vectors includes:
%
%   Shape Measurements
%
%     "Volume"              "PrincipalAxisLength"  "Orientation"               
%     "BoundingBox"         "Extent"               "SurfaceArea"          
%     "Centroid"            "EquivDiameter"        "VoxelIdxList" 
%     "ConvexVolume"        "VoxelList"            "ConvexHull"   
%     "Solidity"            "ConvexImage"          "Image"  
%     "SubarrayIdx"         "EigenVectors"         "EigenValues"
%
%   Voxel Value Measurements (requires 3-D volumetric grayscale image as the second input)
%
%     "MaxIntensity"
%     "MeanIntensity"
%     "MinIntensity"
%     "VoxelValues"
%     "WeightedCentroid"
%
%   Property strings or character vectors are case insensitive and can be
%   abbreviated.
%
%   If PROPERTIES is set to "all", REGIONPROPS3 returns all of the Shape
%   measurements. If called with a 3-D volumetric grayscale image,
%   REGIONPROPS3 also returns Voxel value measurements. If PROPERTIES is
%   not specified or if it is set to "basic", these measurements are
%   computed: "Volume", "Centroid", and "BoundingBox".
%
%   Note that negative-valued voxels are treated as background
%   and voxels that are not integer-valued are rounded down.
%
%   Example 1
%   ---------
%   % Estimate the centers and radii of objects in a 3-D volumetric image
%
%         % Create a binary image with two spheres
%         [x, y, z] = meshgrid(1:50, 1:50, 1:50);
%         bw1 = sqrt((x-10).^2 + (y-15).^2 + (z-35).^2) < 5;
%         bw2 = sqrt((x-20).^2 + (y-30).^2 + (z-15).^2) < 10;
%         bw = bw1 | bw2;
%         s = regionprops3(bw, "Centroid", ...
%                            "PrincipalAxisLength");
%
%         % Get centers and radii of the two spheres
%         centers = s.Centroid;
%         diameters = mean(s.PrincipalAxisLength,2);
%         radii = diameters/2;
%
%
%   Class Support
%   -------------
%   If the first input is BW, BW must be a 3-D logical array. If the first
%   input is CC, CC must be a structure returned by BWCONNCOMP. If the
%   first input is L, L must be real, nonsparse, numeric array containing 3
%   dimensions.
%
%   See also BWCONNCOMP, BWLABELN, ISMEMBER, REGIONPROPS.

%   Copyright 2017 The MathWorks, Inc.

narginchk(1, inf);

args = matlab.images.internal.stringToChar(varargin);

if islogical(args{1}) || isstruct(args{1})
    %REGIONPROPS3(BW,...) or REGIONPROPS3(CC,...)
    
    L = [];
    
    if islogical(args{1})
        %REGIONPROPS3(BW,...)
        if ndims(args{1}) > 3
            error(message('images:regionprops3:invalidSizeBW'));
        end
        CC = bwconncomp(args{1});
    else
        %REGIONPROPS3(CC,...)
        CC = args{1};
        checkCC(CC);
        if numel(CC.ImageSize) > 3
            error(message('images:regionprops3:invalidSizeCC'));
        end
    end
    
    imageSize = CC.ImageSize;
    numObjs = CC.NumObjects;   
    
else
    %REGIONPROPS3(L,...)
    
    CC = [];
    
    L = args{1};
    supportedTypes = {'uint8','uint16','uint32','int8','int16','int32','single','double'};
    supportedAttributes = {'3d','real','nonsparse','finite'};
    validateattributes(L, supportedTypes, supportedAttributes, ...
        mfilename, 'L', 1);
    imageSize = size(L);
    
    if isempty(L)
        numObjs = 0;
    else
        numObjs = max( 0, floor(double(max(L(:)))) );
    end
end

[V,requestedStats,officialStats] = parseInputs(imageSize, args{:});

[stats, statsAlreadyComputed] = initializeStatsTable(...
    numObjs, requestedStats, officialStats);

% Compute VoxelIdxList
[stats, statsAlreadyComputed] = ...
    computeVoxelIdxList(L, CC, numObjs, stats, statsAlreadyComputed);

% Compute other statistics.
numRequestedStats = length(requestedStats);
for k = 1 : numRequestedStats
    switch requestedStats{k}
        
        case 'Volume'
            [stats, statsAlreadyComputed] = ...
                computeVolume(stats, statsAlreadyComputed);
            
        case 'Centroid'
            [stats, statsAlreadyComputed] = ...
                computeCentroid(imageSize,stats, statsAlreadyComputed);
            
        case 'EquivDiameter'
            [stats, statsAlreadyComputed] = ...
                computeEquivDiameter(stats, statsAlreadyComputed);
            
        case 'SurfaceArea'
            [stats, statsAlreadyComputed] = ...
                computeSurfaceArea(imageSize,stats, statsAlreadyComputed);
            
        case 'BoundingBox'
            [stats, statsAlreadyComputed] = ...
                computeBoundingBox(imageSize,stats,statsAlreadyComputed);
            
        case 'SubarrayIdx'
            [stats, statsAlreadyComputed] = ...
                computeSubarrayIdx(imageSize,stats,statsAlreadyComputed);
            
        case {'PrincipalAxisLength', 'Orientation', 'EigenVectors', 'EigenValues'}
            [stats, statsAlreadyComputed] = ...
                computeEllipsoidParams(imageSize,stats,statsAlreadyComputed);
            
        case 'Extent'
            [stats, statsAlreadyComputed] = ...
                computeExtent(imageSize,stats,statsAlreadyComputed);
            
        case 'Image'
            [stats, statsAlreadyComputed] = ...
                computeImage(imageSize,stats,statsAlreadyComputed);
            
        case 'VoxelList'
            [stats, statsAlreadyComputed] = ...
                computeVoxelList(imageSize,stats,statsAlreadyComputed);
            
        case 'VoxelValues'
            [stats, statsAlreadyComputed] = ...
                computeVoxelValues(V,stats,statsAlreadyComputed);
            
        case 'ConvexVolume'
            [stats, statsAlreadyComputed] = ...
                computeConvexVolume(imageSize, stats,statsAlreadyComputed);
    
        case 'ConvexImage'
            [stats, statsAlreadyComputed] = ...
                computeConvexImage(imageSize,stats,statsAlreadyComputed);

        case 'ConvexHull'
            [stats, statsAlreadyComputed] = ...
                computeConvexHull(imageSize,stats,statsAlreadyComputed);
            
        case 'Solidity'
            [stats, statsAlreadyComputed] = ...
                computeSolidity(imageSize,stats,statsAlreadyComputed);
            
        case 'WeightedCentroid'
            [stats, statsAlreadyComputed] = ...
                computeWeightedCentroid(imageSize,V,stats,statsAlreadyComputed);
            
        case 'MeanIntensity'
            [stats, statsAlreadyComputed] = ...
                computeMeanIntensity(V,stats,statsAlreadyComputed);
            
        case 'MinIntensity'
            [stats, statsAlreadyComputed] = ...
                computeMinIntensity(V,stats,statsAlreadyComputed);
            
        case 'MaxIntensity'
            [stats, statsAlreadyComputed] = ...
                computeMaxIntensity(V,stats,statsAlreadyComputed);
    end
end

% Create the output table.
outstats = createOutputTable(requestedStats, stats);

%% computeVoxelIdxList
function [stats, statsAlreadyComputed] = ...
    computeVoxelIdxList(L,CC,numObjs,stats,statsAlreadyComputed)
%   A P-by-1 matrix, where P is the number of voxels belonging to
%   the region.  Each element contains the linear index of the
%   corresponding voxel.

statsAlreadyComputed.VoxelIdxList = 1;

if numObjs ~= 0
    if ~isempty(CC)
        idxList = CC.PixelIdxList;
    else
        idxList = label2idxmex(L, double(numObjs));
    end
    stats.VoxelIdxList = idxList';
end

%% computeVolume
function [stats, statsAlreadyComputed] = ...
    computeVolume(stats, statsAlreadyComputed)
%   The volume is defined to be the number of voxels belonging to
%   the region.

if ~statsAlreadyComputed.Volume
    statsAlreadyComputed.Volume = 1;
    
    for k = 1:height(stats)
        stats.Volume{k} = size(stats.VoxelIdxList{k}, 1);
    end
end

%% computeEquivDiameter
function [stats, statsAlreadyComputed] = ...
    computeEquivDiameter(stats, statsAlreadyComputed)
%   Computes the diameter of the sphere that has the same volume as
%   the region.

if ~statsAlreadyComputed.EquivDiameter
    statsAlreadyComputed.EquivDiameter = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeVolume(stats,statsAlreadyComputed);
    
    factor = 2*(3/(4*pi))^(1/3);
    for k = 1:height(stats)
        stats.EquivDiameter{k} = factor * (stats.Volume{k})^(1/3);
    end
end

%% ComputeCentroid
function [stats, statsAlreadyComputed] = ...
    computeCentroid(imageSize,stats, statsAlreadyComputed)
%   [mean(r) mean(c) mean(p)]

if ~statsAlreadyComputed.Centroid
    statsAlreadyComputed.Centroid = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeVoxelList(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:height(stats)
        stats.Centroid{k} = mean(stats.VoxelList{k},1);
    end
    
end

%% computeSurfaceArea
function [stats, statsAlreadyComputed] = ...
                computeSurfaceArea(imageSize,stats, statsAlreadyComputed)

if ~statsAlreadyComputed.SurfaceArea
    statsAlreadyComputed.SurfaceArea = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeSubarrayIdx(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:height(stats)
        if statsAlreadyComputed.Image == 1
            image3D = stats.Image{k};
        else
            image3D = getImageForEachRegion(imageSize,stats.SubarrayIdx{k},stats.VoxelList{k});
        end
        
        if (isempty(image3D))
            stats.SurfaceArea{k}  = 0;
        else
            % image3D can be a 2-D matrix for some flat regions. Make it a
            % true 3-D matrix
            if ismatrix(image3D)
                % Use plane size of 2 to account for both sides of the flat
                % surface
                im = false([size(image3D) 2]);
                im(:,:,1) = image3D;
                image3D = im;
            end
            stats.SurfaceArea{k} = surfaceareamex(image3D);
        end
    end
end

%% computeBoundingBox
function [stats, statsAlreadyComputed] = ...
    computeBoundingBox(imageSize,stats,statsAlreadyComputed)
%   Note: The output format is [minC minR minP width height depth] and
%   minC, minR, minP end in .5, where minC, minR and minP are the minimum
%   column, minimum row and minimum plane values respectively

if ~statsAlreadyComputed.BoundingBox
    statsAlreadyComputed.BoundingBox = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeVoxelList(imageSize,stats,statsAlreadyComputed);
  
    for k = 1:height(stats)
        list = stats.VoxelList{k};
        if (isempty(list))
            stats.BoundingBox{k} = [0.5*ones(1,3) zeros(1,3)];
        else
            minCorner = min(list,[],1) - 0.5;
            maxCorner = max(list,[],1) + 0.5;
            stats.BoundingBox{k} = [minCorner (maxCorner - minCorner)];
        end
    end
end

%% computeSubarrayIdx
function [stats, statsAlreadyComputed] = ...
    computeSubarrayIdx(imageSize,stats,statsAlreadyComputed)
%   Find a cell-array containing indices so that L(idx{:}) extracts the
%   elements of L inside the bounding box.

if ~statsAlreadyComputed.SubarrayIdx
    statsAlreadyComputed.SubarrayIdx = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeBoundingBox(imageSize,stats,statsAlreadyComputed);
    num_dims = numel(imageSize);
    idx = cell(1,num_dims);
    for k = 1:height(stats)
        boundingBox = stats.BoundingBox{k};
        left = boundingBox(1:(end/2));
        right = boundingBox((1+end/2):end);
        left = left(1,[2 1 3:end]);
        right = right(1,[2 1 3:end]);
        for p = 1:num_dims
            first = left(p) + 0.5;
            last = first + right(p) - 1;
            idx{p} = first:last;
        end
        stats.SubarrayIdx{k} = idx;
    end
end

%% computeEllipseParams
function [stats, statsAlreadyComputed] = ...
    computeEllipsoidParams(imageSize,stats,statsAlreadyComputed)
%   Find the ellipsoid that has the same normalized second central moments
%   as the region.  Compute the principal axes lengths, orientation, and
%   eigenvectors and eigenvalues of the ellipsoid.

if ~(statsAlreadyComputed.PrincipalAxisLength && ...
        statsAlreadyComputed.Orientation && ...
        statsAlreadyComputed.EigenValues && ...        
        statsAlreadyComputed.EigenVectors)
    statsAlreadyComputed.PrincipalAxisLength = 1;
    statsAlreadyComputed.Orientation = 1;
    statsAlreadyComputed.EigenValues = 1;
    statsAlreadyComputed.EigenVectors = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeSubarrayIdx(imageSize,stats,statsAlreadyComputed);
    [stats, statsAlreadyComputed] = ...
        computeCentroid(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:height(stats)
        list = stats.VoxelList{k};
        if (isempty(list))
            stats.PrincipalAxisLength{k} = [0 0 0];
            stats.Orientation{k} = [0 0 0];
            stats.EigenValues{k} = [0 0 0];
            stats.EigenVectors{k} = zeros(3,3);
            
        else
            if statsAlreadyComputed.Image == 1
                image3D = stats.Image{k};
            else
                image3D = getImageForEachRegion(imageSize,stats.SubarrayIdx{k},stats.VoxelList{k});
            end

            centroid = stats.Centroid{k}-stats.BoundingBox{k}(1:3)+0.5;

            mu000 = calculateCentralMoments(image3D, centroid, 0, 0, 0);
            mu200 = calculateCentralMoments(image3D, centroid, 2, 0, 0) / mu000 + 1/12;
            mu020 = calculateCentralMoments(image3D, centroid, 0, 2, 0) / mu000 + 1/12;
            mu002 = calculateCentralMoments(image3D, centroid, 0, 0, 2) / mu000 + 1/12;
            mu110 = calculateCentralMoments(image3D, centroid, 1, 1, 0) / mu000;
            mu011 = calculateCentralMoments(image3D, centroid, 0, 1, 1) / mu000;
            mu101 = calculateCentralMoments(image3D, centroid, 1, 0, 1) / mu000;
            
            numPoints = size(stats.VoxelList{k},1);
            covMat = [mu200 mu110 mu101; ...
                      mu110 mu020 mu011; ...
                      mu101 mu011 mu002]./numPoints;

            [U,S] = svd(covMat);
            [S,ind] = sort(diag(S), 'descend');
            
            U = U(:,ind);
            % Update U so that the first axis points to positive x
            % direction and make sure that the rotation matrix determinant
            % is positive
            if U(1,1) < 0
                U = -U;
                U(:,3) = -U(:,3);
            end
            
            [V,D] = eig(covMat);
            [D,ind] = sort(diag(D), 'descend');
            
            V = V(:,ind);           
            
            stats.PrincipalAxisLength{k} = [4*sqrt(S(1)*numPoints) 4*sqrt(S(2)*numPoints) 4*sqrt(S(3)*numPoints)];
            stats.Orientation{k} = rotm2euler(U);
            stats.EigenValues{k} = D*numPoints;
            stats.EigenVectors{k} = V;
        end
    end
end

function centralMoments = calculateCentralMoments(im,centroid,i,j,k)

[r,c,p] = size(im);
centralMoments = ((1:r)-centroid(2))'.^i * ((1:c)-centroid(1)).^j;
z = reshape(((1:p)-centroid(3)).^k,[1 1 p]);
centralMoments = centralMoments.*z.*im;
centralMoments = sum(centralMoments(:));

function eulerAngles = rotm2euler(rotm)
%ROTM2EULER Convert rotation matrix to Euler angles
%
%   eulerAngles = rotm2euler(rotm) converts 3x3 3D rotation matrix to Euler
%   angles
%
%   Reference:
%   ---------
%   
%   Ken Shoemake, Graphics Gems IV, Edited by Paul S. Heckbert,
%   Morgan Kaufmann, 1994, Pg 222-229.

% Scale factor to convert radians to degrees
k = 180 / pi;

cy = hypot(rotm(1, 1), rotm(2, 1));

if cy > 16*eps(class(rotm))
    psi     = k * atan2( rotm(3, 2), rotm(3, 3));
    theta   = k * atan2(-rotm(3, 1), cy);
    phi     = k * atan2( rotm(2, 1), rotm(1, 1));
else
    psi     = k * atan2(-rotm(2, 3), rotm(2, 2));
    theta   = k * atan2(-rotm(3, 1), cy);
    phi     = 0;                    
end

eulerAngles = [phi, theta, psi];

%% computeExtent
function [stats, statsAlreadyComputed] = ...
    computeExtent(imageSize,stats,statsAlreadyComputed)
%   Volume / (BoundingBoxWidth * BoundingBoxHeight * BoundingBoxDepth)

if ~statsAlreadyComputed.Extent
    statsAlreadyComputed.Extent = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeVolume(stats,statsAlreadyComputed);
    [stats, statsAlreadyComputed] = ...
        computeBoundingBox(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:height(stats)
        if (stats.Volume{k} == 0)
            stats.Extent{k} = NaN;
        else
            stats.Extent{k} = stats.Volume{k} / prod(stats.BoundingBox{k}(4:6));
        end
    end
end

%% computeImage
function [stats, statsAlreadyComputed] = ...
    computeImage(imageSize,stats,statsAlreadyComputed)
%   Binary image containing "on" voxels corresponding to voxels
%   belonging to the region.  The size of the image corresponds
%   to the size of the bounding box for each region.

if ~statsAlreadyComputed.Image
    statsAlreadyComputed.Image = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeSubarrayIdx(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:height(stats)
        stats.Image{k} = getImageForEachRegion(imageSize,stats.SubarrayIdx{k},stats.VoxelList{k});        
    end
end

function imageKthRegion = getImageForEachRegion(imageSize,regionSubarrayIdx,regionVoxelList)

ndimsL = numel(imageSize);
if any(cellfun(@isempty,regionSubarrayIdx))
    imageKthRegion = logical([]);
else
    maxBound = cellfun(@max,regionSubarrayIdx);
    minBound = cellfun(@min,regionSubarrayIdx);
    sizeOfSubImage = maxBound - minBound + 1;
    
    % Shift the VoxelList subscripts so that they is relative to
    % sizeOfSubImage.
    if min(sizeOfSubImage) == 0
        imageKthRegion = logical(sizeOfSubImage);
    else
        subtractby = maxBound-sizeOfSubImage;
        
        % swap subtractby so that it is in the same order as
        % VoxelList, i.e., c r ....
        subtractby = subtractby(:, [2 1 3:end]);
        
        subscript = cell(1,ndimsL);
        for m = 1 : ndimsL
            subscript{m} = regionVoxelList(:,m) - subtractby(m);
        end
        
        % swap subscript back into the order sub2ind expects, i.e.
        % r c ...
        subscript = subscript(:,[2 1 3:end]);
        
        idx = sub2ind(sizeOfSubImage,subscript{:});
        imageKthRegion = false(sizeOfSubImage);
        imageKthRegion(idx) = true;
    end
end

%% computeVoxelList
function [stats, statsAlreadyComputed] = ...
    computeVoxelList(imageSize,stats,statsAlreadyComputed)
%   A P-by-3 matrix, where P is the number of voxels belonging to
%   the region.  Each row contains the row, column and plane
%   coordinates of a voxel.

if ~statsAlreadyComputed.VoxelList
    statsAlreadyComputed.VoxelList = 1;
    
    ndimsL = 3;
    % Convert the linear indices to subscripts and store
    % the results in the voxel list.  Reverse the order of the first
    % two subscripts to form x-y order.
    In = cell(1,ndimsL);
    for k = 1:height(stats)
        if ~isempty(stats.VoxelIdxList{k})
            [In{:}] = ind2sub(imageSize, stats.VoxelIdxList{k});
            stats.VoxelList{k} = [In{:}];
            stats.VoxelList{k} = stats.VoxelList{k}(:,[2 1 3]);
        else
            stats.VoxelList{k} = zeros(0,ndimsL);
        end
    end
end

%%%
%%% ComputeSurfaceVoxelList
%%%
function [stats, statsAlreadyComputed] = ...
    computeSurfaceVoxelList(imageSize,stats,statsAlreadyComputed)
%   Find the pixels on the perimeter/surface of the region; make a list
%   of the coordinates of their corners; sort and remove
%   duplicates.

if ~statsAlreadyComputed.SurfaceVoxelList
    statsAlreadyComputed.SurfaceVoxelList = 1;


    [stats, statsAlreadyComputed] = ...
        computeBoundingBox(imageSize,stats,statsAlreadyComputed);
    [stats, statsAlreadyComputed] = ...
        computeVoxelList(imageSize,stats,statsAlreadyComputed);
    [stats, statsAlreadyComputed] = ...
        computeSubarrayIdx(imageSize,stats,statsAlreadyComputed);

    for k = 1:height(stats)
        
        image_K = getImageForEachRegion(imageSize,stats.SubarrayIdx{k},stats.VoxelList{k});
        
        if(isempty(image_K))
            stats.SurfaceVoxelList{k} = [];
            continue;
        end
        
        if(ndims(image_K) < 3) %#ok<ISMAT>
            perimVolume = bwperim(image_K, 8);
        else
            perimVolume = bwperim(image_K, 26);
        end
        
        firstRow   = stats.BoundingBox{k}(2) + 0.5;
        firstCol   = stats.BoundingBox{k}(1) + 0.5;
        firstPlane = stats.BoundingBox{k}(3) + 0.5;
        
        perimIdx = find(perimVolume);
        
        [r, c, p] = ind2sub(size(image_K), perimIdx);
        % Force rectangular empties.
        r = r(:) + firstRow - 1;
        c = c(:) + firstCol - 1;
        p = p(:) + firstPlane -1;
        
        rr = [r-.5 ; r    ; r+.5 ; r    ; r    ; r   ];
        cc = [c    ; c+.5 ; c    ; c-.5 ; c    ; c   ];
        pp = [p    ; p    ; p    ; p    ; p+.5 ; p-.5];    
        stats.SurfaceVoxelList{k} = unique([cc rr pp],'rows');
    end

end

%% computeConvexHull
function [stats, statsAlreadyComputed] = ...
    computeConvexHull(imageSize,stats,statsAlreadyComputed)
%   A P-by-3 array representing the convex hull of the region.
%   The first column contains row coordinates; the second column
%   contains column coordinates; the third column contains plane
%   coordinates. The resulting polygon goes through voxel corners, 
%   not voxel centers.

if ~statsAlreadyComputed.ConvexHull
    statsAlreadyComputed.ConvexHull = 1;
          
    [stats, statsAlreadyComputed] = ...
        computeSurfaceVoxelList(imageSize,stats,statsAlreadyComputed);
    [stats, statsAlreadyComputed] = ...
        computeBoundingBox(imageSize,stats,statsAlreadyComputed);
 
    for k = 1:height(stats)
        list = stats.SurfaceVoxelList{k};
        if (isempty(list))
            stats.ConvexHull{k} = zeros(0,3);
        else
            % compute the convhull triangulations.
            conHullTriIdx = convhulln(list);
            
            % Flatten the triangle vertices on the hull
            conHullTriIdx = reshape(conHullTriIdx,[numel(conHullTriIdx), 1]);
            % Drop repeated vertices
            % ConvHull will be in X, Y, Z format
            conHullXYZ = list(unique(conHullTriIdx),:);
            stats.ConvexHull{k}   = conHullXYZ;
            
        end
    end
    
end

%% computeConvexImage
function [stats, statsAlreadyComputed] = ...
    computeConvexImage(imageSize, stats,statsAlreadyComputed)
%   Uses delaunauyTriangulation to fill in the convex hull.

if ~statsAlreadyComputed.ConvexImage
    statsAlreadyComputed.ConvexImage = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeConvexHull(imageSize,stats,statsAlreadyComputed);
    [stats, statsAlreadyComputed] = ...
        computeBoundingBox(imageSize,stats,statsAlreadyComputed);

    for k = 1:height(stats)
        M = stats.BoundingBox{k}(5);
        N = stats.BoundingBox{k}(4);
        P = stats.BoundingBox{k}(6); 
        hull = stats.ConvexHull{k};
        if (isempty(hull))
            stats.ConvexImage{k} = false(M,N,P);
        else
            firstRow   = stats.BoundingBox{k}(2) + 0.5;
            firstCol   = stats.BoundingBox{k}(1) + 0.5;
            firstPlane = stats.BoundingBox{k}(3) + 0.5;
            
            [c, r, p] = meshgrid(1:1:M, 1:1:N, 1:1:P);
            p = p(:) + firstPlane -1;
            r = r(:) + firstRow - 1;
            c = c(:) + firstCol - 1;
            
            dt = delaunayTriangulation(hull);
            % Get indices of internal points (non NaN)
            idx = pointLocation(dt, c(:), r(:), p(:));
                
            % non-NaN indices are internal points
            convImage = ~isnan(idx);
             
            image_K = getImageForEachRegion(imageSize,stats.SubarrayIdx{k},stats.VoxelList{k});

            %reshape to the same size as input           
            stats.ConvexImage{k} = reshape(convImage, [size(image_K,2),...
                size(image_K,1), size(image_K,3)]);
        end
    end
end


%% computeConvexVolume
function [stats, statsAlreadyComputed] = ...
    computeConvexVolume(imageSize, stats,statsAlreadyComputed)
%   Computes the number of "on" voxels in ConvexImage.

if ~statsAlreadyComputed.ConvexVolume
    statsAlreadyComputed.ConvexVolume = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeConvexImage(imageSize,stats,statsAlreadyComputed);

    for k = 1:height(stats)
        stats.ConvexVolume{k} = sum(stats.ConvexImage{k}(:));
    end


end

%% computeSolidity
function [stats, statsAlreadyComputed] = ...
    computeSolidity(imageSize,stats,statsAlreadyComputed)
%   Volume / ConvexVolume

if ~statsAlreadyComputed.Solidity
    statsAlreadyComputed.Solidity = 1; 
    
    [stats, statsAlreadyComputed] = ...
        computeVolume(stats,statsAlreadyComputed);
    [stats, statsAlreadyComputed] = ...
        computeConvexVolume(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:height(stats)
        if (stats.ConvexVolume{k} == 0)
            stats.Solidity{k} = NaN;
        else
            stats.Solidity{k} = stats.Volume{k} / stats.ConvexVolume{k};
        end
    end
end

%% computeVoxelValues
function [stats, statsAlreadyComputed] = ...
    computeVoxelValues(V,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.VoxelValues
    statsAlreadyComputed.VoxelValues = 1;
    
    for k = 1:height(stats)
        stats.VoxelValues{k} = V(stats.VoxelIdxList{k});
    end
end

%% computeWeightedCentroid
function [stats, statsAlreadyComputed] = ...
    computeWeightedCentroid(imageSize,V,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.WeightedCentroid
    statsAlreadyComputed.WeightedCentroid = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeVoxelList(imageSize,stats,statsAlreadyComputed);
    
    for k = 1:height(stats)
        Intensity = V(stats.VoxelIdxList{k});
        sumIntensity = sum(Intensity);
        numDims = size(stats.VoxelList{k},2);
        wc = zeros(1,numDims);
        for n = 1 : numDims
            M = sum(stats.VoxelList{k}(:,n) .* ...
                double( Intensity(:) ));
            wc(n) = M / sumIntensity;
        end
        stats.WeightedCentroid{k} = wc;
    end
end

%% computeMeanIntensity
function [stats, statsAlreadyComputed] = ...
    computeMeanIntensity(V,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.MeanIntensity
    statsAlreadyComputed.MeanIntensity = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeVoxelValues(V,stats,statsAlreadyComputed);
    
    for k = 1:height(stats)
        stats.MeanIntensity{k} = mean(stats.VoxelValues{k});
    end
end

%% computeMinIntensity
function [stats, statsAlreadyComputed] = ...
    computeMinIntensity(V,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.MinIntensity
    statsAlreadyComputed.MinIntensity = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeVoxelValues(V,stats,statsAlreadyComputed);
    
    for k = 1:height(stats)
        stats.MinIntensity{k} = min(stats.VoxelValues{k});
    end
end

%% computeMaxIntensity
function [stats, statsAlreadyComputed] = ...
    computeMaxIntensity(V,stats,statsAlreadyComputed)

if ~statsAlreadyComputed.MaxIntensity
    statsAlreadyComputed.MaxIntensity = 1;
    
    [stats, statsAlreadyComputed] = ...
        computeVoxelValues(V,stats,statsAlreadyComputed);
    
    for k = 1:height(stats)
        stats.MaxIntensity{k} = max(stats.VoxelValues{k});
    end
end

function [V, reqStats, officialStats] = parseInputs(sizeImage, varargin)

shapeStats = {
    'Volume'
    'Centroid'
    'BoundingBox'
    'SubarrayIdx'
    'Image'
    'EquivDiameter'
    'Extent'
    'VoxelIdxList'
    'VoxelList'
    'PrincipalAxisLength'
    'Orientation'
    'EigenVectors'
    'EigenValues'
    'ConvexHull'
    'ConvexImage'
    'ConvexVolume'
    'Solidity'
    'SurfaceArea'};

voxelValueStats = {
    'VoxelValues'
    'WeightedCentroid'
    'MeanIntensity'
    'MinIntensity'
    'MaxIntensity'};

basicStats = {
    'Volume'
    'Centroid'
    'BoundingBox'};

V = [];
officialStats = shapeStats;

numOrigInputArgs = numel(varargin);

if numOrigInputArgs == 1
    %REGIONPROPS3(BW) or REGIONPROPS3(CC) or REGIONPROPS3(L)
    
    reqStats = basicStats;
    return;
    
elseif isnumeric(varargin{2}) || islogical(varargin{2})
    %REGIONPROPS3(...,V) or REGIONPROPS3(...,V,PROPERTIES)
    
    V = varargin{2};
    validateattributes(V, {'numeric','logical'},{}, mfilename, 'V', 2);
    
    iptassert(isequal(sizeImage,size(V)), ...
        'images:regionprops3:sizeMismatch')
    
    officialStats = [shapeStats;voxelValueStats];
    if numOrigInputArgs == 2
        %REGIONPROPS3(BW) or REGIONPROPS3(CC,V) or REGIONPROPS3(L,V)
        reqStats = basicStats;
        return;
    else
        %REGIONPROPS3(BW,V,PROPERTIES) of REGIONPROPS3(CC,V,PROPERTIES) or
        %REGIONPROPS3(L,V,PROPERTIES)
        startIdxForProp = 3;
        reqStats = getPropsFromInput(startIdxForProp, ...
            officialStats, voxelValueStats, basicStats, varargin{:});
    end
    
else
    %REGIONPROPS3(BW,PROPERTIES) or REGIONPROPS3(CC,PROPERTIES) or
    %REGIONPROPS3(L,PROPERTIES)
    startIdxForProp = 2;
    reqStats = getPropsFromInput(startIdxForProp, ...
        officialStats, voxelValueStats, basicStats, varargin{:});
end

function [reqStats,officialStats] = getPropsFromInput(startIdx, ...
    officialStats, voxelValueStats, basicStats, varargin)

if iscell(varargin{startIdx})
    %REGIONPROPS3(...,PROPERTIES)
    propList = varargin{startIdx};
elseif strcmpi(varargin{startIdx}, 'all')
    %REGIONPROPS3(...,'all')
    reqStats = officialStats;
    return;
elseif strcmpi(varargin{startIdx}, 'basic')
    %REGIONPROPS3(...,'basic')
    reqStats = basicStats;
    return;
else
    %REGIONPROPS3(...,PROP1,PROP2,..)
    propList = varargin(startIdx:end);
end

numProps = length(propList);
reqStats = cell(1, numProps);
for k = 1 : numProps
    if ischar(propList{k})
        noGrayscaleImageAsInput = startIdx == 2;
        if noGrayscaleImageAsInput
            % This code block exists so that regionprops3 can throw a more
            % meaningful error message if the user want a voxel value based
            % measurement but only specifies a label matrix as an input.
            tempStats = [officialStats; voxelValueStats];
            prop = validatestring(propList{k}, tempStats, mfilename, ...
                'PROPERTIES', k+1);
            if any(strcmp(prop,voxelValueStats))
                error(message('images:regionprops3:needsGrayscaleImage', prop));
            end
        else
            prop = validatestring(propList{k}, officialStats, mfilename, ...
                'PROPERTIES', k+2);
        end
        reqStats{k} = prop;
    else
        error(message('images:regionprops3:invalidType'));
    end
end

function [stats, statsAlreadyComputed] = initializeStatsTable(...
    numObjs, requestedStats, officialStats)

if isempty(requestedStats)
    error(message('images:regionprops3:noPropertiesWereSelected'));
end

% Initialize the stats table.
tempStats = {'SurfaceVoxelList';'DelaunayTriangulation'};
allStats = [officialStats; tempStats];
numStats = length(allStats);
empties = cell(numObjs, numStats);
stats = cell2table(empties,'VariableNames',allStats);
% Initialize the statsAlreadyComputed structure array. Need to avoid
% multiple calculatations of the same property for performance reasons.
zz = cell(numStats, 1);
for k = 1:numStats
    zz{k} = 0;
end
statsAlreadyComputed = cell2struct(zz, allStats, 1);

function outstats = createOutputTable(requestedStats, stats)

% Figure out what fields to keep and what fields to remove.
fnames = stats.Properties.VariableNames;
idxRemove = ~ismember(fnames, requestedStats);
idxKeep = ~idxRemove;

% Convert to cell array
c = table2cell(stats);
sizeOfc = size(c);

% Determine size of new cell array that will contain only the requested
% fields.

newSizeOfc = sizeOfc;
newSizeOfc(2) = sizeOfc(2) - numel(find(idxRemove));
newFnames = fnames(idxKeep);

% Create the output structure.
outstats = cell2table(reshape(c(:,idxKeep), newSizeOfc), 'VariableNames',newFnames);
