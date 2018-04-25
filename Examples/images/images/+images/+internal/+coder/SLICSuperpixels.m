classdef SLICSuperpixels < handle %#codegen
    %SLICSuperpixels Implementation of the Simple Linear Iterative
    %                Clustering (SLIC) algorithm for C code generation.
    
    % Note
    % ----
    %
    % This class can be run as regular MATLAB code. (Useful when playing
    % around with the algorithm!) Simply replace instances of 
    % coder.internal.inf with the regular Inf.
    %
    % Reference
    % ---------
    %
    % Radhakrishna Achanta, Appu Shaji, Kevin Smith, Aurelien Lucchi, 
    % Pascal Fua, and Sabine Susstrunk, "SLIC Superpixels Compared to 
    % State-of-the-art Superpixel Methods," IEEE Transactions on Pattern 
    % Analysis and Machine Intelligence, vol. 34, num. 11, p. 2274 - 2282, 
    % May 2012.
    %
    % Radhakrishna Achanta, Appu Shaji, Kevin Smith, Aurelien Lucchi, 
    % Pascal Fua, and Sabine Susstrunk, "SLIC Superpixels," EPFL Technical 
    % Report no. 149300, June 2010.
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties
        % Input image stuff
        labImage                % input image; either float or double
        %numPixels               % numRows*numCols
        %numRows                 % y dimension of labImage
        %numCols                 % x dimension of labImage
        
        % Cluster center stuff
        numClusters             % initial number of superpixels
        clusterCenters_L        % [l,a,b] for each cluster center
        clusterCenters_a        % not used if grayscale
        clusterCenters_b        % not used if grayscale
        clusterCenters_x        % column position in floating point
        clusterCenters_y        % row position in floating point
        clusterCenters_numPix   % number of pixels in cluster
        nhoodSize               % search space around a cluster center
        
        % Distance metric stuff
        isCompactnessDynamic    % true if m is dynamically adjusted for each cluster
        compactnessFactor2      % fixed color distance m^2, in case compacness is not dynamic
        maxColorDistance2       % array of max observed color distance for each cluster, for dynamic compactness
        maxSpatialDistanceInv2  % constant 1/S^2
        distances               % array of distance from pixel (y,x) to its cluster
        colorDistances          % color part of distances; used to keep track of the max
        
        % Output image stuff
        labels                  % array of intermediary labels (connectivity not enforced)
    end
    
    properties (Access = protected)
        % offsets to visit neighbors when enforcing connectivity
        dx4
        dy4
        
        % offsets to visit neighbors when moving centers to lowest energy
        dx8
        dy8
        
        hasBeenInitialized      % whether it is safe to run the algorithm
    end
    
    methods (Access = public)
        %------------------------------------------------------------------
        % Class constructor. Sets and initialize class members.
        %   @in:  I - image to run SLIC on; must be in L*a*b* color space
        %             or grayscale; must be float or double
        %         k - number of desired superpixels
        %         m - compactness paramter; if m<0 then compactness is
        %             dynamically adjusted for each superpixel
        %         useSLIC0 - flag whether to refine the compactness
        %                    adaptively (SLIC0) or keep it fixed (SLIC)
        function obj = SLICSuperpixels(I,varargin)
            coder.internal.prefer_const(I,varargin{:});
            
            assert(nargin == 1 || nargin == 4, ...
                'instantiate with image or with image AND parameters');
            
            % Validate I
            validateattributes(I,{'single','double'},{'real','nonsparse'}, ...
                mfilename,'I',1)
            assert(size(I,3) == 1 || size(I,3) == 3, ...
                'I must be grayscale or L*a*b*')
            
            % Input image stuff
            obj.labImage = I;
            
            %obj.numRows = coder.internal.indexInt(size(I,1));
            %obj.numCols = coder.internal.indexInt(size(I,2));
            %obj.numPixels = coder.internal.indexInt(size(I,1)*size(I,2));
            
            % NW, W, SW, N, S, NE, E, SE
            obj.dx8 = coder.const(coder.internal.indexInt([-1,-1,-1, 0,0, 1,1,1]));
            obj.dy8 = coder.const(coder.internal.indexInt([-1, 0, 1,-1,1,-1,0,1]));
            
            % W, N, S, E
            obj.dx4 = coder.const(coder.internal.indexInt([-1, 0,0,1]));
            obj.dy4 = coder.const(coder.internal.indexInt([ 0,-1,1,0]));
            
            obj.hasBeenInitialized = false;
            
            if (nargin > 1)
                % Initialization
                obj.init(varargin{:});
            end
        end
        
        %------------------------------------------------------------------
        % Initialize class members.
        %   @in:  k - number of desired superpixels
        %         m - compactness parameter
        %         useSLIC0 - flag whether to refine the compactness
        %                    adaptively (SLIC0) or keep it fixed (SLIC)
        function init(obj,k,m,useSLIC0)
            coder.internal.prefer_const(k,m,useSLIC0);
            
            % Initialize cluster center stuff
            obj.initializeClusterCenters(k);
            
            % Set compactness and initialize distances
            obj.setCompactness(m,useSLIC0);
            
            % Initialize intermediary labels to 0
            obj.labels = coder.internal.indexInt(zeros(size(obj.labImage,1),size(obj.labImage,2)));
            
            obj.hasBeenInitialized = true;
        end
        
        %------------------------------------------------------------------
        % Set compactness and initialize distances arrays.
        %   @in:  m - compactness parameter
        %         useSLIC0 - flag whether to refine the compactness
        %                    adaptively (SLIC0) or keep it fixed (SLIC)
        function setCompactness(obj,m,useSLIC0)
            coder.internal.prefer_const(m,useSLIC0);
            
            % Validate compactness
            validateattributes(m,{'numeric'}, ...
                {'scalar','positive','finite','nonempty','nonsparse'}, ...
                mfilename,'m',1)
            validateattributes(useSLIC0,{'logical'}, ...
                {'finite','nonempty'},mfilename,'useSLIC0',2)
            
            % In case we're using SLIC
            obj.compactnessFactor2 = cast(m*m,'like',obj.labImage);
            
            % Initialize array of distances stored
            % from one iteration to the next
            if useSLIC0
                % For SLIC0
                obj.isCompactnessDynamic = coder.const(true);
                obj.maxColorDistance2 = ...
                    cast(m*m,'like',obj.labImage) ...
                    * ones(obj.numClusters,1,'like',obj.labImage);
                obj.colorDistances = coder.nullcopy( ...
                    zeros(size(obj.labImage,1),size(obj.labImage,2),'like',obj.labImage));
            else
                % For SLIC
                obj.isCompactnessDynamic = coder.const(false);
                obj.maxColorDistance2 = cast(0,'like',obj.labImage);
                obj.colorDistances    = cast(0,'like',obj.labImage);
            end

            % Initialize distance array to infinity
            obj.resetDistances();
        end
        
        %------------------------------------------------------------------
        % Initialize the [l,a,b,x,y] vector of each cluster center and the
        % search space around cluster centers (defined by nhoodSize^2).
        % This method tries to initialize a number of centers close to the
        % user-specified desired number of superpixels. Centers are
        % regularly spaced in x and y with a spacing of S and are kept from
        % the image borders at a distance of S/2. Each cluster is made
        % approximately square by tying the number of clusters along the
        % rows and the columns to the aspect ratio of the image. For
        % example, if the image is 3:2 then the number of cluster centers
        % along the columns will be approximately 1.5 the number of centers
        % along the rows.
        % Note that the actual number of clusters will most likely differ
        % from the desired number of superpixels. This is because not every
        % integer can be factored into the product of two integers M and N
        % such that N/M = WIDTH/HEIGHT. The actual number might be greater
        % or less than desiredNumSuperpixels, depending on which direction
        % (up or down) numbers are rounded.
        %   @in:  desiredNumSuperpixels - user-provided desired number of
        %                                 cluster centers to initialize
        function initializeClusterCenters(obj,desiredNumSuperpixels)
            coder.internal.prefer_const(desiredNumSuperpixels);
            
            % K must be in |N*\{inf}
            validateattributes(desiredNumSuperpixels,{'numeric'}, ...
                {'integer','real','positive','scalar'}, ...
                mfilename,'desiredNumSuperpixels',1);
            
            K = cast(desiredNumSuperpixels,'like',obj.labImage);
            
            % ASPECT_RATIO = WIDTH/HEIGHT
            aspectRatio = cast(size(obj.labImage,2),'like',obj.labImage)/cast(size(obj.labImage,1),'like',obj.labImage);
            
            if (K <= aspectRatio)
                % If the aspect ratio is greater than or equal to the desired
                % number of superpixels, then we'll run into problems with the
                % number of cluster centers along the rows. In this case, set
                % the number of centers along the rows to 1 and deduce the
                % number of centers along the columns from the desired number
                % of superpixels.
                numCentersAlongRows = coder.internal.indexInt(1);
                numCentersAlongCols = min(coder.internal.indexInt(desiredNumSuperpixels),size(obj.labImage,2));
            elseif (K*aspectRatio <= 1)
                % This is the other extreme case.
                numCentersAlongCols = coder.internal.indexInt(1);
                numCentersAlongRows = min(coder.internal.indexInt(desiredNumSuperpixels),size(obj.labImage,1));
            else
                % In the normal range, calculate the number of centers along
                % the rows and columns so that they satisfy the aspect ratio:
                %
                %    K_w/K_h = WIDTH/HEIGHT = aspectRatio
                %
                % and
                %
                %    K_w*K_h = K = desiredNumSuperpixels
                %
                % which yields
                %
                %    K_w = sqrt( aspectRatio * K )
                %    K_h = sqrt( K / aspectRatio )
                %
                % and which also gives us
                %
                %    K_w > 1  iff  K > 1/aspectRatio
                %    K_h > 1  iff  K > aspectRatio
                
                % Compute K_h = sqrt( HEIGHT/WIDTH * K )
                temp = sqrt( K / aspectRatio );
                numCentersAlongRows = min(coder.internal.indexInt( round(temp) ), size(obj.labImage,1));

                % Compute K_w = WIDTH/HEIGHT * K_h
                numCentersAlongCols = min(coder.internal.indexInt( round(aspectRatio * temp) ), size(obj.labImage,2));
            end
            
            obj.numClusters = numCentersAlongRows * numCentersAlongCols;
            assert(obj.numClusters > 0, 'number of clusters must be positive');
            
            % Reset to zeros
            obj.resetClusterCenters();

            spacingAlongRows = cast(size(obj.labImage,1),'like',obj.labImage) / cast(numCentersAlongRows,'like',obj.labImage);
            spacingAlongCols = cast(size(obj.labImage,2),'like',obj.labImage) / cast(numCentersAlongCols,'like',obj.labImage);
            
            startOffsetRow = max(1,round(spacingAlongRows/cast(2,'like',obj.labImage)));
            startOffsetCol = max(1,round(spacingAlongCols/cast(2,'like',obj.labImage)));
            
            % Step size for neighborhood search
            obj.nhoodSize = coder.internal.indexInt(ceil( max(spacingAlongCols,spacingAlongRows) ));
            
            % Do not perturb center if area SxS is smaller than 3x3
            doPerturb = (obj.nhoodSize > 2);
            
            % Normalization factor for the spatial distance metric
            obj.maxSpatialDistanceInv2 = 1/cast(obj.nhoodSize^2,'like',obj.labImage);
            
            centerIdx = coder.internal.indexInt(1);
            for n = 1:numCentersAlongCols
                for m = 1:numCentersAlongRows
                    % Coordinates of the cluster center
                    x = coder.internal.indexInt(round( (cast(n,'like',obj.labImage)-1)*spacingAlongCols + startOffsetCol ));
                    y = coder.internal.indexInt(round( (cast(m,'like',obj.labImage)-1)*spacingAlongRows + startOffsetRow ));
                    
                    % (y,x) is a candidate location
                    % Compute gradient over 3x3 neighborhood
                    % and move to lowest gradient pixel
                    
                    grad = obj.computeGradientAtPixel(x,y);
                    newx = x;
                    newy = y;
                    
                    if doPerturb
                        for k = 1:8
                            tmpx = coder.internal.indexInt(x) + obj.dx8(k);
                            tmpy = coder.internal.indexInt(y) + obj.dy8(k);
                            newGrad = obj.computeGradientAtPixel(tmpx,tmpy);
                            if newGrad < grad
                                grad = newGrad;
                                newx = tmpx;
                                newy = tmpy;
                            end
                        end
                    end
                    
                    obj.setClusterCenterLocation(centerIdx,newx,newy);
                    centerIdx = centerIdx + 1;
                end
            end
        end
        
        %------------------------------------------------------------------
        % Return the gradient magnitude (energy) squared at pixel location
        % (y,x). The gradient is computed by central differences by summing
        % the gradient in each color channel. Pixels on the border of the
        % image have an infinite energy in order to avoid moving a cluster
        % center to the border of the image.
        %   @in:  x - column index of the pixel; must be integer-valued
        %         y - row index of the pixel; must be integer-valued
        %   @out: Gmag - energy squared
        function Gmag = computeGradientAtPixel(obj,x,y)
            % Return infinity if (y,x) is not inside the image
            Gmag = cast(coder.internal.inf,'like',obj.labImage);
            %Gmag = cast(Inf,'like',obj.labImage);
            
            if (x > 1) && (x < size(obj.labImage,2)) && (y > 1) && (y < size(obj.labImage,1))
                dx2 = (obj.labImage(y,x+1,1) - obj.labImage(y,x-1,1))*(obj.labImage(y,x+1,1) - obj.labImage(y,x-1,1));
                dy2 = (obj.labImage(y+1,x,1) - obj.labImage(y-1,x,1))*(obj.labImage(y+1,x,1) - obj.labImage(y-1,x,1));
                
                if obj.isColor()
                    % Add a* and b*
                    dx2 = dx2 ...
                        + (obj.labImage(y,x+1,2) - obj.labImage(y,x-1,2))*(obj.labImage(y,x+1,2) - obj.labImage(y,x-1,2)) ...
                        + (obj.labImage(y,x+1,3) - obj.labImage(y,x-1,3))*(obj.labImage(y,x+1,3) - obj.labImage(y,x-1,3));
                    dy2 = dy2 ...
                        + (obj.labImage(y+1,x,2) - obj.labImage(y-1,x,2))*(obj.labImage(y+1,x,2) - obj.labImage(y-1,x,2)) ...
                        + (obj.labImage(y+1,x,3) - obj.labImage(y-1,x,3))*(obj.labImage(y+1,x,3) - obj.labImage(y-1,x,3));
                end
                
                Gmag = dx2 + dy2;
            end
        end
        
        %------------------------------------------------------------------
        % Move the cluster center with index centerIdx to the pixel
        % location (y,x).
        %   @in:  centerIdx - index of the cluster center to move
        %         x - column index of the destination; must be integer-valued
        %         y - row index of the destination; must be integer-valued
        function setClusterCenterLocation(obj,centerIdx,x,y)
            assert(obj.isInBounds(x,y),'out of bounds');
            
            if obj.isColor()
                obj.clusterCenters_x(centerIdx) = cast(x,'like',obj.labImage);
                obj.clusterCenters_y(centerIdx) = cast(y,'like',obj.labImage);
                obj.clusterCenters_L(centerIdx) = obj.labImage(y,x,1); % L
                obj.clusterCenters_a(centerIdx) = obj.labImage(y,x,2); % a
                obj.clusterCenters_b(centerIdx) = obj.labImage(y,x,3); % b
            else
                obj.clusterCenters_x(centerIdx) = cast(x,'like',obj.labImage);
                obj.clusterCenters_y(centerIdx) = cast(y,'like',obj.labImage);
                obj.clusterCenters_L(centerIdx) = obj.labImage(y,x,1); % L
            end
        end
        
        %------------------------------------------------------------------
        % Run the Simple Linear Iterative Clustering (SLIC) algorithm for
        % numIter iterations.
        %   @in:  numIter - number of iterations
        %   @out: labelImage - final image of connected labels
        %         numSuperpixels - final number of superpixels in
        %                          labelImage
        function [labelImage,numSuperpixels] = generateSuperPixels(obj,numIter)
            coder.internal.prefer_const(numIter);
            
            % Initialization is assumed to have been done
            assert(obj.hasBeenInitialized,'must initialize algorithm parameters first')
            validateattributes(numIter,{'numeric'}, ...
                {'real','integer','positive','scalar'},mfilename,'numIter',1)
            
            % k-means
            if obj.isCompactnessDynamic
                obj.SLIC0(numIter);
            else
                obj.SLIC(numIter);
            end
            
            % Post-processing
            [labelImage,numSuperpixels] = obj.enforceConnectivity();
        end
        
        %------------------------------------------------------------------
        % Return the distance metric squared and the color distance squared
        % from the pixel at location (y,x) to the cluster center with index
        % centerIdx. The color distance is normalized by maxColorDistance.
        % All distances are squared. The color distance returned is used to
        % update the maximum observed color distance within a cluster.
        %   @in:  centerIdx - index of the cluster center
        %         x - column index of the pixel
        %         y - row index of the pixel
        %         maxColorDistance2 - factor (also called compactness) used
        %                             to normalize the color distance
        %                             metric; can be fixed if SLIC or
        %                             adaptive if SLIC0
        %   @out: distance2 - sum of the spatial and color distances
        %                     squared; the spatial distance is normalized
        %                     by S^2, the search space of a cluster center
        %         colorDist2 - color distance squared; normalized by
        %                      maxColorDistance2
        function [distance2,colorDist2] = distanceFromClusterCenter(obj,centerIdx,x,y,relativeScaleFactor)
            
            % Spatial proximity
            center_x = obj.clusterCenters_x(centerIdx);
            center_y = obj.clusterCenters_y(centerIdx);
            
            spatialDist2 = ...
                (center_x - cast(x,'like',obj.labImage))^2 + ...
                (center_y - cast(y,'like',obj.labImage))^2;
            
            % Color similarity
            pixel_l  = obj.labImage(y,x,1);
            center_l = obj.clusterCenters_L(centerIdx);
            
            % Also return the color distance
            % to keep track of the max dynamically
            colorDist2 = (center_l - pixel_l)^2;
            
            if obj.isColor()
                pixel_a  = obj.labImage(y,x,2);
                pixel_b  = obj.labImage(y,x,3);
                center_a = obj.clusterCenters_a(centerIdx);
                center_b = obj.clusterCenters_b(centerIdx);
                
                colorDist2 = colorDist2 ...
                    + (center_a - pixel_a)^2 ...
                    + (center_b - pixel_b)^2;
            end
            
            % Distance metric d^2 = dc^2/m^2 + ds^2/S^2
            distance2 = colorDist2 + spatialDist2*relativeScaleFactor;
        end
        
        %------------------------------------------------------------------
        % Update the array of observed max color distance for each cluster.
        % Used only for SLIC0, when the compactness coefficient is
        % adaptively computed for each cluster from one iteration to the
        % next.
        function updateMaxColorDistances(obj)
            % For all pixels
            for x = 1:size(obj.labImage,2)
                for y = 1:size(obj.labImage,1)
                    % Get this pixel's label and distance to center
                    centerIdx = obj.labels(y,x);
                    curDist2  = obj.colorDistances(y,x);
                    % Is the distance from the pixel to its cluster center
                    % larger than the max color distance for that cluster?
                    if obj.maxColorDistance2(centerIdx) < curDist2
                        obj.maxColorDistance2(centerIdx) = curDist2;
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        % Update the [l,a,b,x,y] vector of each cluster center to be the
        % mean taken across all pixels belonging to the cluster.
        % clusterCenters_numPix is used to keep track of how many pixels
        % belong to a cluster.
        function updateClusterCenters(obj)
            % Reset to zeros
            obj.resetClusterCenters();
            
            % Accumulate
            for x = 1:size(obj.labImage,2)
                for y = 1:size(obj.labImage,1)
                    % Assigned label for pixel (y,x)
                    centerIdx = obj.labels(y,x);
                    % column
                    obj.clusterCenters_x(centerIdx) = obj.clusterCenters_x(centerIdx) + cast(x,'like',obj.labImage);
                    % row
                    obj.clusterCenters_y(centerIdx) = obj.clusterCenters_y(centerIdx) + cast(y,'like',obj.labImage);
                    % L*
                    obj.clusterCenters_L(centerIdx) = obj.clusterCenters_L(centerIdx) + obj.labImage(y,x,1);
                    if obj.isColor()
                        % a*
                        obj.clusterCenters_a(centerIdx) = obj.clusterCenters_a(centerIdx) + obj.labImage(y,x,2);
                        % b*
                        obj.clusterCenters_b(centerIdx) = obj.clusterCenters_b(centerIdx) + obj.labImage(y,x,3);
                    end
                    % number of pixels in this cluster
                    obj.clusterCenters_numPix(centerIdx) = coder.internal.indexPlus(obj.clusterCenters_numPix(centerIdx),1);
                end
            end
            
            % Divide by the number of pixels to get the mean
            for k = 1:obj.numClusters
                clusterSize = cast(obj.clusterCenters_numPix(k),'like',obj.labImage);
                if clusterSize > 0
                    obj.clusterCenters_x(k) = obj.clusterCenters_x(k)./clusterSize; % x
                    obj.clusterCenters_y(k) = obj.clusterCenters_y(k)./clusterSize; % y
                    obj.clusterCenters_L(k) = obj.clusterCenters_L(k)./clusterSize; % L
                    if obj.isColor()
                        obj.clusterCenters_a(k) = obj.clusterCenters_a(k)./clusterSize; % a
                        obj.clusterCenters_b(k) = obj.clusterCenters_b(k)./clusterSize; % b
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        % Enforce the connectivity of superpixels in the label image. As
        % SLIC does not enforce connectivity when assigning pixels to
        % clusters, some pixels might get orphaned. This connected
        % component algorithm merges orphaned pixels with the closest
        % superpixel. A pixel is considered orphaned if it belongs to a
        % connected component which is smaller than a quarter the average
        % size of a superpixel. As a result of merging smaller superpixels
        % into larger ones, the total number of superpixels might drop.
        %   @out: labelImage - final label image with no orphaned pixels
        %         numSuperpixels - actual number of superpixels in
        %                          labelImage
        function [labelImage,numSuperpixels] = enforceConnectivity(obj)
            % Initialize the output label image of class double
            %labelImage = zeros(obj.numRows,obj.numCols);
            labelImage = zeros(size(obj.labImage,1),size(obj.labImage,2));
            
            minSuperpixelSize = coder.internal.indexInt(size(obj.labImage,1)*size(obj.labImage,2)) / (4*obj.numClusters);
            
            currentLabel  = cast(1,'like',labelImage);
            adjacentLabel = cast(1,'like',labelImage);
            
            % Scratch space
            scratch = coder.nullcopy(coder.internal.indexInt(zeros(size(obj.labImage,1)*size(obj.labImage,2),1)));
            
            % For each pixel in the image
            for x = 1:coder.internal.indexInt(size(obj.labImage,2))
                for y = 1:coder.internal.indexInt(size(obj.labImage,1))
                    % If we haven't treated that pixel yet
                    if labelImage(y,x) < 1
                        % Label this pixel
                        labelImage(y,x) = currentLabel;
                        
                        % Store the pixels belonging to
                        % that connected component
                        scratch(1) = coder.internal.indexInt(size(obj.labImage,1))*(x-1) + y;
                        count = coder.internal.indexInt(1);
                        
                        % Get a neighboring label in case
                        % we need to relabel the current pixel
                        for k = 1:4
                            newx = x + obj.dx4(k);
                            newy = y + obj.dy4(k);
                            
                            if obj.isInBounds(newx,newy)
                                temp = labelImage(newy,newx);
                                if temp > 0
                                    adjacentLabel = temp;
                                    break;
                                end
                            end
                        end
                        
                        idx = coder.internal.indexInt(0);
                        while idx < count
                            idx = idx+1;
                            [newy_d,newx_d] = ind2sub([size(obj.labImage,1),size(obj.labImage,2)],scratch(idx));
                            
                            for k = 1:4
                                newx = coder.internal.indexInt(newx_d) + obj.dx4(k);
                                newy = coder.internal.indexInt(newy_d) + obj.dy4(k);
                                
                                if obj.isInBounds(newx,newy)
                                    % If this connected pixel hasn't been
                                    % treated yet and has the same label
                                    if (labelImage(newy,newx) < 1) && (obj.labels(newy,newx) == obj.labels(y,x))
                                        % Add neighbor to connected component
                                        count = count+1;
                                        scratch(count) = coder.internal.indexInt(size(obj.labImage,1))*(newx-1) + newy;
                                        labelImage(newy,newx) = currentLabel;
                                    end
                                end
                            end
                        end
                        
                        % If connected component is small, label it with
                        % the label of one of the neighbors found earlier
                        if count <= minSuperpixelSize
                            for k = 1:count
                                idx = scratch(k);
                                labelImage(idx) = adjacentLabel;
                            end
                            currentLabel = currentLabel-1;
                        end
                        currentLabel = currentLabel+1;
                    end
                end
            end
            numSuperpixels = double(currentLabel-1);
        end
    end
    
    methods (Access = protected)
        %------------------------------------------------------------------
        % Reset the distances matrix, which stores the distance from each
        % pixel to its nearest cluster, to infinity.
        % Used at the beginning of each clustering iteration.
        function resetDistances(obj)
            obj.distances = coder.internal.inf*ones(size(obj.labImage,1),size(obj.labImage,2),'like',obj.labImage);
            %obj.distances = Inf*ones(obj.numRows,obj.numCols,'like',obj.labImage);
        end
        
        %------------------------------------------------------------------
        % Re-initialize the [l,a,b,x,y] vector of each cluster center to
        % zeros. Also set the number of pixels in each cluster to 0.
        % This is done during initialization to create the member variables
        % and before updating the cluster centers at the end of each
        % iteration of SLIC.
        function resetClusterCenters(obj)
            %coder.internal.prefer_const(obj.numClusters);
            
            % Everything needs to be re-initialized to 0
            % as we compute the mean later
            
            if obj.isColor()
                % [x,y,L,a,b]
                obj.clusterCenters_x = zeros(obj.numClusters,1,'like',obj.labImage);
                obj.clusterCenters_y = zeros(obj.numClusters,1,'like',obj.labImage);
                obj.clusterCenters_L = zeros(obj.numClusters,1,'like',obj.labImage);
                obj.clusterCenters_a = zeros(obj.numClusters,1,'like',obj.labImage);
                obj.clusterCenters_b = zeros(obj.numClusters,1,'like',obj.labImage);
            else
                % [x,y,L]
                obj.clusterCenters_x = zeros(obj.numClusters,1,'like',obj.labImage);
                obj.clusterCenters_y = zeros(obj.numClusters,1,'like',obj.labImage);
                obj.clusterCenters_L = zeros(obj.numClusters,1,'like',obj.labImage);
                obj.clusterCenters_a = cast(0,'like',obj.labImage);
                obj.clusterCenters_b = cast(0,'like',obj.labImage);
            end
            
            obj.clusterCenters_numPix = coder.internal.indexInt(zeros(obj.numClusters,1));
        end
        
        %------------------------------------------------------------------
        % The name of this method is pretty self-explanatory...
        function TF = isInBounds(obj,x,y)
            coder.inline('always')
            TF = (x > 0) && (x <= size(obj.labImage,2)) &&...
                 (y > 0) && (y <= size(obj.labImage,1));
        end
        
        %------------------------------------------------------------------
        % This is a method and not a property because MATLAB Coder doesn't
        % want to fold the expression into a constant boolean at 
        % instantiation.
        function TF = isColor(obj)
            coder.inline('always')
            % true if L*a*b*, false if grayscale
            TF = ~ismatrix(obj.labImage);
        end
        
        %------------------------------------------------------------------
        % Run SLIC with an adaptive compactness factor. Each cluster center
        % maintains its own maximum color distance, which is used to
        % normalize the color distance computation. The spatial distance is
        % normalized by S, the approximate maximum spatial distance within
        % a cluster.
        %   @in:  numIter - number of iterations of the algorithm
        function SLIC0(obj,numIter)
            coder.internal.prefer_const(numIter);
            
            for iter = 1:numIter
                % 1. Assignment step
                
                % Reset the distances to infinity
                obj.resetDistances();
                
                % For each cluster center
                for clusterIdx = 1:obj.numClusters
                    % Current cluster center
                    center_x = obj.clusterCenters_x(clusterIdx);
                    center_y = obj.clusterCenters_y(clusterIdx);
                    
                    % Define the 2S-by-2S region around the cluster center
                    xmin = coder.internal.indexInt(max(center_x - cast(obj.nhoodSize,'like',obj.labImage),cast(1,'like',obj.labImage)));
                    xmax = coder.internal.indexInt(min(center_x + cast(obj.nhoodSize,'like',obj.labImage),cast(size(obj.labImage,2),'like',obj.labImage)));
                    
                    ymin = coder.internal.indexInt(max(center_y - cast(obj.nhoodSize,'like',obj.labImage),cast(1,'like',obj.labImage)));
                    ymax = coder.internal.indexInt(min(center_y + cast(obj.nhoodSize,'like',obj.labImage),cast(size(obj.labImage,1),'like',obj.labImage)));
                    
                    % Factor m^2/S^2 used to weigh space vs. color similarity
                    % in the computation of the distance metric
                    relativeScaleFactor = obj.maxColorDistance2(clusterIdx) * obj.maxSpatialDistanceInv2;
                    
                    % For each pixel in a 2S-by-2S neighborhood
                    for x = xmin:xmax
                        for y = ymin:ymax
                            [distance,colorDistance] = obj.distanceFromClusterCenter(clusterIdx,x,y,relativeScaleFactor);
                            if distance < obj.distances(y,x)
                                % Set cluster center k as the
                                % closest center to pixel (y,x)
                                obj.distances(y,x)      = distance;
                                obj.labels(y,x)         = clusterIdx;
                                obj.colorDistances(y,x) = colorDistance;
                            end
                        end
                    end
                end
                
                % 2. Update step
                obj.updateMaxColorDistances();
                obj.updateClusterCenters();
            end
        end
        
        %------------------------------------------------------------------
        % Run SLIC with a fixed, user-defined compactness factor for all
        % clusters, which is used to normalize the color distance. The
        % spatial distance is normalized by S, the approximate maximum
        % spatial distance within a cluster.
        %   @in:  numIter - number of iterations of the algorithm
        function SLIC(obj,numIter)
            coder.internal.prefer_const(numIter);
            
            % Factor m^2/S^2 used to weigh space vs. color similarity
            % in the computation of the distance metric
            relativeScaleFactor = obj.compactnessFactor2 * obj.maxSpatialDistanceInv2;
            
            for iter = 1:numIter
                % 1. Assignment step
                
                % Reset the distances to infinity
                obj.resetDistances();
                
                % For each cluster center
                for clusterIdx = 1:obj.numClusters
                    % Current cluster center
                    center_x = obj.clusterCenters_x(clusterIdx);
                    center_y = obj.clusterCenters_y(clusterIdx);
                    
                    % Define the 2S-by-2S region around the cluster center
                    xmin = coder.internal.indexInt(max(center_x - cast(obj.nhoodSize,'like',obj.labImage),cast(1,'like',obj.labImage)));
                    xmax = coder.internal.indexInt(min(center_x + cast(obj.nhoodSize,'like',obj.labImage),cast(size(obj.labImage,2),'like',obj.labImage)));
                    
                    ymin = coder.internal.indexInt(max(center_y - cast(obj.nhoodSize,'like',obj.labImage),cast(1,'like',obj.labImage)));
                    ymax = coder.internal.indexInt(min(center_y + cast(obj.nhoodSize,'like',obj.labImage),cast(size(obj.labImage,1),'like',obj.labImage)));
                    
                    % For each pixel in a 2S-by-2S neighborhood
                    for x = xmin:xmax
                        for y = ymin:ymax
                            distance = obj.distanceFromClusterCenter(clusterIdx,x,y,relativeScaleFactor);
                            if distance < obj.distances(y,x)
                                % Set pixel (y,x) as the closest
                                % to cluster center k
                                obj.distances(y,x) = distance;
                                obj.labels(y,x)    = clusterIdx;
                            end
                        end
                    end
                end
                
                % 2. Update step
                obj.updateClusterCenters();
            end
        end
    end
end
