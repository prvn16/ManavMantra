classdef NeighborhoodProcessor < handle %#codegen
    % MATLAB Coder API to process pixel neighborhood
    %
    %    Create a neighborhood processor. nhconn is a logical variable
    %    indicate the neighborhood connectivity.
    %
    % NeighborhoodProcessor methods:
    %   process        - Perform neighborhood operation.
    %
    % NeighborhoodProcessor properties:
    %   ImageSize      - Size of I
    %   Neighborhood   - Logical neighborhood connectivity
    %   InteriorStart  - Image subscript to first pixel (top-left side) of
    %   image to have a full neighborhood
    %   InteriorEnd    - Image subscript to last pixel (bottom-right side)
    %   of image to have a full neighborhood
    %   ProcessBorder  - Flag to indicate if border pixels need to processed.
    
    %   Copyright 2014-2015 The MathWorks, Inc.
    
    % Variable naming:
    % ind  - linear index. eg im(12)
    % sub  - subscripted index. eg im(2,3)
    % im   - image
    % nh   - neighborhood
    % imnh - image neighborhood (for a particular pixel in the context)
    
    properties (GetAccess = public, SetAccess = private)
        
        % Neighborhood - The neighborhood connectivity specification.
        %  An N-D matrix of logicals denoting the neighbors of a pixel.
        %
        Neighborhood
        
        % ImageSize - Vector containing the dimensions of the image.
        %
        ImageSize;
        
        
        % Number of Dimensions x 1.
        % Start of interior pixel subscripts. Interior pixels have
        % full valid neighborhood (i.e no padding required).
        %
        InteriorStart;
        
        % Number of Dimensions x 1.
        % End of interior pixel subscripts. Interior pixels have
        % full valid neighborhood (i.e no padding required).
        %
        InteriorEnd;
        
        %Number of neighbors x 1
        ImageNeighborLinearOffsets;
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        
        % Type of padding for out-of-bound pixels
        %
        Padding;
        
        % Pad value to use when Padding is of type CONSTANT
        %
        PadValue;
        
        % Flag to indicate if border pixels need to processed. Turning
        % this off will process only the interior pixels which have full
        % neighborhood (and hence will be faster).
        ProcessBorder;
        
        % Method to choose neighborhood center when a neighborhood
        % dimension is even valued.
        %
        NeighborhoodCenter;
                
    end
    
    properties (GetAccess = public, Constant = true)
        % Enumerations to help set various properties
        
        % Rounding to pick center pixels for even sized neighborhood.
        NEIGHBORHOODCENTER = struct(...
            'DEFAULT', 1,...      % defaults to bottom right
            'TOPLEFT', 2,...
            'BOTTOMRIGHT',3);
                
        % Padding options for out of bound pixels
        PADDING = struct(...
            'NONE', 1,...
            'CONSTANT', 2,...
            'REPLICATE', 3,...
            'SYMMETRIC',4);
        
        % Process pixels along the border?
        PROCESSBORDER = struct(...
            'YES', true,...  % PADDING comes into play
            'NO', false);
    end
    
    properties (Access = private)
        
        % Number of neighbors x1
        NeighborLinearIndices
        
        % Number of neighbors x Number of Dimensions
        NeighborSubscriptOffsets;
        
        PixelsPerPage;
    end
    
    
    
    %% Constructor and setup
    methods
        function nhoodObj = NeighborhoodProcessor(imSize, nhConnectivity, varargin)
            coder.inline('always');
            coder.internal.prefer_const(imSize);
            coder.internal.prefer_const(nhConnectivity);
            
            % Validation
            coder.internal.assert(islogical(nhConnectivity), ...
                'images:validate:connNotLogical', ...
                'IfNotConst', 'Fail');
            
            % Image size
            imSize = coder.internal.indexInt(imSize);
            nhoodObj.ImageSize = imSize;
            
            % Neighborhood
            if(ndims(nhConnectivity)>numel(imSize))
                % Chop nh dimensions to fit image dimensions
                connSize = size(nhConnectivity);
                nhConn   = zeros(connSize(1:numel(imSize)));
                nhConn(1:end) = nhConnectivity(1:numel(nhConn));
            else
                nhConn = nhConnectivity;
            end
            nhoodObj.Neighborhood = nhConn;
            
            % Defaults
            nhoodObj.Padding            = images.internal.coder.NeighborhoodProcessor.PADDING.NONE;            
            nhoodObj.ProcessBorder      = ...
                images.internal.coder.NeighborhoodProcessor.PROCESSBORDER.YES;
            nhoodObj.NeighborhoodCenter = ...
                images.internal.coder.NeighborhoodProcessor.NEIGHBORHOODCENTER.DEFAULT;

            padValueSpecified = false;
            % Parse optional inputs. Expected to be in Param-Value order.
            for argInd=1:2:numel(varargin)
                
                switch varargin{argInd}
                    case 'NeighborhoodCenter'                        
                        nhoodObj.NeighborhoodCenter  = varargin{argInd+1};
                    case 'ProcessBorder'
                        nhoodObj.ProcessBorder       = varargin{argInd+1};
                    case 'Padding'                        
                        nhoodObj.Padding = varargin{argInd+1};
                    case 'PadValue'
                        % Used only when Padding = CONSTANT
                        padValueSpecified = true;
                        padValue = varargin{argInd+1};
                        assert(isa(padValue,'double'),'Pad values must be doubles (internally casted to image type)');
                    otherwise
                        assert('Invalid syntax');
                end
            end
            
            if(padValueSpecified)
                nhoodObj.PadValue = padValue;
            else
                nhoodObj.PadValue = 0.0;
            end
            
            % Initialize
            numberOfNeighbors  = sum(nhConn(:));
            nhoodObj.ImageNeighborLinearOffsets = coder.nullcopy(...
                zeros(numberOfNeighbors ,1,coder.internal.indexIntClass()));
            nhoodObj.NeighborLinearIndices      = coder.nullcopy(...
                zeros(numberOfNeighbors ,1,coder.internal.indexIntClass()));
            nhoodObj.NeighborSubscriptOffsets   = coder.nullcopy(...
                zeros(numberOfNeighbors , ndims(nhConn),coder.internal.indexIntClass()));
        end
    end
    
    methods (Hidden = true)
        function nhoodObj = updateInternalProperties(nhoodObj)
            % UPDATEINTERNALPROPERTIES
            % Recompute internal derived properties.
            %
            coder.inline('always');
            [nhoodObj.ImageNeighborLinearOffsets, nhoodObj.NeighborLinearIndices, nhoodObj.NeighborSubscriptOffsets,...
                nhoodObj.InteriorStart,...
                nhoodObj.InteriorEnd] = ...
                images.internal.coder.NeighborhoodProcessor.computeParameters(...
                nhoodObj.ImageSize, nhoodObj.Neighborhood, nhoodObj.NeighborhoodCenter,...
                nhoodObj.ImageNeighborLinearOffsets, nhoodObj.NeighborLinearIndices, nhoodObj.NeighborSubscriptOffsets);
        end
    end
    
    %% Random access paradigm
    methods 
        function [imnhInds, nhInds, isInside] = getNeighborIndices(nhoodObj, lind)
            %getNeighborIndices - Obtain neighborhood indices of a pixel
            %
            %  Ensure that updateInternalProperties is called once before
            %  this method.
            %
            %  lind      - Linear index of a pixel in image.
            %
            %  imnhInds  - Linear index to all neighbors of pixel (lind) in image.
            %  nhInds    - Linear index to all neighbors of pixel in the
            %              connectivity matrix. Use this to index to any
            %              weights associated with the neighborhood.
            %              Same size as imnhInds.
            %
            %  Behavior with PADDING:
            %         NONE - imnhInds and nhInds are truncated to contain
            %                within image bounds locations only.
            %     CONSTANT - imnhInds and nhInds are same size as specified
            %                connectivity. Out of bound imnhInds locations
            %                are set to index value 1. Use isInside to
            %                differentiate actual indices and out of bound
            %                locations.
            %         REST - imnhInds is set based on padding option.          
            %
            %  isInside  - Boolean. Same size as imnhInds and nhInds only
            %              when PADDING ~= NONE. Indicates corresponding
            %              locations in imnhInds and nhInds which are
            %              within bounds of the image.
            %              
            
            % Get the linear indices, imInds, of all neighboring pixels for
            % the linear pixel index lind. nhInds is the local neighbor
            % indices for use with weights.
            %
            coder.inline('always');
            
            % linear index of all neighbors
            imnhInds_ = coder.internal.indexPlus(...
                nhoodObj.ImageNeighborLinearOffsets, lind);
            
            % subscript of current pixel
            pixelSub = nhoodObj.getSubscriptArrayFromInd(nhoodObj.ImageSize, lind);
            % Drop fparams dimenions
            pixelSub = pixelSub(1:ndims(nhoodObj.Neighborhood));
            pixelSub = cast(pixelSub, coder.internal.indexIntClass());
            % Subscripts of all neighbors
            imnhSubs = bsxfun(@plus, nhoodObj.NeighborSubscriptOffsets, pixelSub);
            
            nhInds_ = nhoodObj.NeighborLinearIndices;
            
            isInside = true(numel(imnhInds_),1);            
            
            switch(nhoodObj.Padding)
                case images.internal.coder.NeighborhoodProcessor.PADDING.NONE
                    for ind = 1:size(imnhSubs,1)
                        % Remove out of bound neighbors
                        pixelSub = imnhSubs(ind,:);
                        for dimInd = 1:ndims(nhoodObj.Neighborhood)
                            % Check bounds for each dimension
                            if(pixelSub(dimInd)<1 || pixelSub(dimInd)>nhoodObj.ImageSize(dimInd))
                                % neighbor is not inside image bounds
                                isInside(ind) = false;
                                break;
                            end
                        end
                    end
                    % Remove out of bound indices
                    imnhInds = imnhInds_(isInside);
                    nhInds = nhInds_(isInside);
                    
                case images.internal.coder.NeighborhoodProcessor.PADDING.CONSTANT
                    imnhInds = imnhInds_;
                    nhInds = nhInds_;
                    for ind = 1:size(imnhSubs,1)
                        pixelSub = imnhSubs(ind,:);
                        for dimInd = 1:ndims(nhoodObj.Neighborhood)
                            % Check bounds for each dimension
                            if(pixelSub(dimInd)<1 || pixelSub(dimInd)>nhoodObj.ImageSize(dimInd))
                                % neighbor is not inside image bounds
                                isInside(ind) = false;
                                % Set out of bound loctions to 1
                                imnhInds(ind) = coder.internal.indexInt(1);
                                break;
                            end
                        end
                    end

                case images.internal.coder.NeighborhoodProcessor.PADDING.REPLICATE
                    imnhInds = imnhInds_;
                    nhInds = nhInds_;
                    for ind = 1:size(imnhSubs,1)
                        pixelSub = imnhSubs(ind,:);
                        for dimInd = 1:ndims(nhoodObj.Neighborhood)
                            % Check bounds for each dimension, clamp out of
                            % bound subscripts
                            if(pixelSub(dimInd)<1)
                                % neighbor is not inside image bounds
                                isInside(ind) = false;
                                pixelSub(dimInd) = 1;
                            end
                            if(pixelSub(dimInd)>nhoodObj.ImageSize(dimInd))
                                % neighbor is not inside image bounds
                                isInside(ind) = false;
                                pixelSub(dimInd) = nhoodObj.ImageSize(dimInd);
                            end
                        end
                        if(isInside(ind)==false)
                            imnhInds(ind) = nhoodObj.getIndFromSubscriptArray(nhoodObj.ImageSize(1:numel(pixelSub)), pixelSub);
                        end
                    end
                case images.internal.coder.NeighborhoodProcessor.PADDING.SYMMETRIC
                    imnhInds = imnhInds_;
                    nhInds = nhInds_;
                    for ind = 1:size(imnhSubs,1)
                        pixelSub = imnhSubs(ind,:);
                        for dimInd = 1:ndims(nhoodObj.Neighborhood)
                            % Check bounds for each dimension, clamp out of
                            % bound subscripts
                            if(pixelSub(dimInd)<1)
                                % neighbor is not inside image bounds
                                isInside(ind) = false;
                                pixelSub(dimInd) = pixelSub(dimInd)+2*nhoodObj.ImageSize(dimInd);
                            end
                            if(pixelSub(dimInd)>nhoodObj.ImageSize(dimInd))
                                % neighbor is not inside image bounds
                                isInside(ind) = false;
                                pixelSub(dimInd) = 2*nhoodObj.ImageSize(dimInd)-pixelSub(dimInd)+1;
                            end
                        end
                        if(isInside(ind)==false)
                            imnhInds(ind) = nhoodObj.getIndFromSubscriptArray(nhoodObj.ImageSize(1:numel(pixelSub)), pixelSub);
                        end
                    end
                    
                otherwise
                    % Not supported
                    assert(false,'Unsupported padding option');
                    imnhInds = imnhInds_;
                    nhInds = nhInds_;
            end
            
            
            
        end
    end
    
    %% Process API
    methods
        function out = process(nhoodObj, in, fhandle, out, varargin)
            % PROCESS - Perform neighborhood operation
            %  out = process(NHOOD, IN, FHANDLE, OUT, fparams) processes
            %  each pixel of input image IN using function handle FHANDLE.
            %  FHANDLE must take two arguments:
            %      imnh  - a column vector of image pixels from the
            %      neighborhood of the current pixel
            %      fparams - a structure with the following fields:
            %        fparams.pixel  - pixel value of current pixel
            %        fparams.ind    - linear index of current pixel
            %        fparams.nhinds - linear index into current valid
            %        neighbors in the connectivity m
            %
            coder.inline('always');
            
            narginchk(4,5);
            if(nargin<5)
                fparams = [];
            else
                fparams = varargin{1};                
            end
            coder.internal.prefer_const(fparams);
            % Call fhandle on every pixel with two inputs:
            % - image neighborhood (numNeighborsx1)
            % - fparams. Structure
            
            % Compute internal properties after all the settable properties
            % have been updated.
            nhoodObj.updateInternalProperties();
            
            % Compile time dispatch intended
            switch numel(nhoodObj.ImageSize)
                case 2
                    out = nhoodObj.process2D(in, fhandle, out, fparams);
                case 3
                    out = nhoodObj.process3D(in, fhandle, out, fparams);
                otherwise
                    out = nhoodObj.processND(in, fhandle, out, fparams);
            end
        end
    end
    
    %% Process API helpers
    methods (Access = private)
        % 2D Specialization
        function out = process2D(nhoodObj, in, fhandle, out, fparams)
            coder.inline('always');
            coder.internal.prefer_const(fparams);
            
            % Interior pixels----------------------------------------------
            % all neighbors are within bounds
            nhInds = nhoodObj.NeighborLinearIndices;
            secondIndRange = [nhoodObj.InteriorStart(2),nhoodObj.InteriorEnd(2)];
            firstIndRange  = [nhoodObj.InteriorStart(1),nhoodObj.InteriorEnd(1)];
            imageNeighborLinearOffsets = nhoodObj.ImageNeighborLinearOffsets;
            imageSize1 = nhoodObj.ImageSize(1);

            parfor secondInd = secondIndRange(1):secondIndRange(2)
                out_= coder.nullcopy(out(:, secondInd));
                for firstInd = firstIndRange(1):firstIndRange(2) %#ok<PFBNS>
                    %> Process pixels with full neighborhood
                    % Obtain linear index to pixel
                    pind = (secondInd-1)*imageSize1+firstInd;
                    
                    % All neighbors are within bounds, directly index
                    % offsets.
                    imnhInds = coder.internal.indexPlus(...
                        imageNeighborLinearOffsets, pind);
                    
                    if(isrow(in))
                        % Handle edge case indexing when 'in' degenerates
                        % down from a 2D image during run-time.
                        imnh      = in(imnhInds');
                    else
                        imnh      = in(imnhInds);
                    end
                                        
                    % Augment the fparams data with pixel info
                    fparamsAugmented = images.internal.coder.NeighborhoodProcessor.augmentFunctionParameters(fparams,...
                        in(pind), pind, nhInds, imnhInds);
                    
                    % Call client pixel function
                    out_(firstInd) = fhandle(imnh, fparamsAugmented); %#ok<PFBNS>
                end
                out(:, secondInd) = out_;
            end
            
            % Border pixels -----------------------------------------------
            if(nhoodObj.ProcessBorder)
                
                % Left
                firstDimExtents  = [1, nhoodObj.ImageSize(1)];
                secondDimExtents = [1, nhoodObj.InteriorStart(2)-1];
                out = nhoodObj.process2DExteriorOnly(in, fhandle, out, ...
                    fparams,...
                    firstDimExtents, secondDimExtents);
                
                % Right
                firstDimExtents  = [1,                    nhoodObj.ImageSize(1)];
                secondDimExtents = [nhoodObj.InteriorEnd(2)+1, nhoodObj.ImageSize(2)];
                out = nhoodObj.process2DExteriorOnly(in, fhandle, out,...
                    fparams,...
                    firstDimExtents, secondDimExtents);
                
                % Top segment
                firstDimExtents  = [1, nhoodObj.InteriorStart(1)-1];
                secondDimExtents = [1, nhoodObj.ImageSize(2)];
                out = nhoodObj.process2DExteriorOnly(in, fhandle, out,...
                    fparams,...
                    firstDimExtents, secondDimExtents);
                
                % Bottom segment
                firstDimExtents  = [nhoodObj.InteriorEnd(1)+1, nhoodObj.ImageSize(1)];
                secondDimExtents = [1,                    nhoodObj.ImageSize(2)];
                out = nhoodObj.process2DExteriorOnly(in, fhandle, out,...
                    fparams,...
                    firstDimExtents, secondDimExtents);
            end
        end
        function out = process2DExteriorOnly(nhoodObj, in, fhandle, out, fparams,...
                firstDimExtents, secondDimExtents)
            coder.internal.prefer_const(fparams);
            coder.inline('always');
            
            padValue = cast(nhoodObj.PadValue,'like',in);
            
            % Guard against imagesize < nhood size
            firstDimExtents(1) = max(firstDimExtents(1), 1);
            firstDimExtents(2) = min(firstDimExtents(2), nhoodObj.ImageSize(1));
            secondDimExtents(1) = max(secondDimExtents(1), 1);
            secondDimExtents(2) = min(secondDimExtents(2), nhoodObj.ImageSize(2));
            
            for secondInd = secondDimExtents(1):secondDimExtents(2)
                for firstInd = firstDimExtents(1):firstDimExtents(2)
                    %> Process pixels with partial neighborhood
                    % Obtain linear index to pixel
                    
                    %pind = (secondInd-1)*nhoodObj.ImageSize(1)+firstInd;
                    pind = coder.internal.indexPlus(...
                        coder.internal.indexTimes(...
                        coder.internal.indexMinus(secondInd,1),...
                        nhoodObj.ImageSize(1)) ,...
                        firstInd);
                    
                    [imnhInds, nhInds, isInside]  = nhoodObj.getNeighborIndices(pind);
                    
                    if(isrow(in))
                        % Handle edge case indexing when 'in' degenerates
                        % down from a 2D image during run-time.
                        imnh      = in(imnhInds');
                    else
                        imnh      = in(imnhInds);                        
                    end
                    
                    if(nhoodObj.Padding == images.internal.coder.NeighborhoodProcessor.PADDING.CONSTANT)
                        imnh(~isInside) = padValue;
                    end
                    
                    % Augment the fparams data with pixel info
                    fparamsAugmented = images.internal.coder.NeighborhoodProcessor.augmentFunctionParameters(fparams,...
                        in(pind), pind, nhInds, imnhInds);
                    
                    % Call client pixel function
                    out(pind) = fhandle(imnh, fparamsAugmented);
                end
            end
        end
        
        % 3D Specialization
        function out = process3D(nhoodObj, in, fhandle, out, fparams)
            coder.inline('always');
            coder.internal.prefer_const(fparams);
            
            % Interior pixels ---------------------------------------------
            nhInds = nhoodObj.NeighborLinearIndices;
            for thirdInd = nhoodObj.InteriorStart(3):nhoodObj.InteriorEnd(3)
                for secondInd = nhoodObj.InteriorStart(2):nhoodObj.InteriorEnd(2)
                    for firstInd = nhoodObj.InteriorStart(1):nhoodObj.InteriorEnd(1)
                        %> Process pixels with full neighborhood
                        % Obtain linear index to pixel
                        pind = (thirdInd-1)* nhoodObj.ImageSize(2)*nhoodObj.ImageSize(1) ...
                            + (secondInd-1)*nhoodObj.ImageSize(1)...
                            + firstInd;
                        
                        % All neighbors are within bounds, directly index
                        % offsets.
                        imnhInds = coder.internal.indexPlus(...
                            nhoodObj.ImageNeighborLinearOffsets, pind);
                       
                        if(isrow(in))
                            % Handle edge case indexing when 'in' degenerates
                            % down from a 2D image during run-time.
                            imnh      = in(imnhInds');
                        else
                            imnh      = in(imnhInds);
                        end
                        
                        % Augment the fparams data with pixel info
                        fparamsAugmented = images.internal.coder.NeighborhoodProcessor.augmentFunctionParameters(fparams,...
                            in(pind), pind, nhInds, imnhInds);
                        
                        % Call client pixel function
                        out(pind) = fhandle(imnh, fparamsAugmented);
                    end
                end
            end
            
            % Border pixels -----------------------------------------------
            if(nhoodObj.ProcessBorder)
                
                % Sweep full 2D planes in the front and back of the third
                % axis
                firstDimExtents  = [1, nhoodObj.ImageSize(1)];
                secondDimExtents = [1, nhoodObj.ImageSize(2)];
                thirdDimExtents  = [1, nhoodObj.InteriorStart(3)-1];
                out = nhoodObj.process3DExteriorOnly(in, fhandle, out,...
                    fparams,...
                    firstDimExtents, secondDimExtents,thirdDimExtents);
                
                thirdDimExtents  = [nhoodObj.InteriorEnd(3)+1, nhoodObj.ImageSize(3)];
                out = nhoodObj.process3DExteriorOnly(in, fhandle, out,...
                    fparams,...
                    firstDimExtents, secondDimExtents,thirdDimExtents);
                
                
                % Sweep partial 2D planes along the left and right sides
                firstDimExtents  = [1, nhoodObj.ImageSize(1)];
                secondDimExtents = [1, nhoodObj.InteriorStart(2)-1];
                thirdDimExtents  = [nhoodObj.InteriorStart(3), nhoodObj.InteriorEnd(3)];
                out = nhoodObj.process3DExteriorOnly(in, fhandle, out, ...
                    fparams,...
                    firstDimExtents, secondDimExtents,thirdDimExtents);
                
                secondDimExtents = [nhoodObj.InteriorEnd(2)+1, nhoodObj.ImageSize(2)];
                out = nhoodObj.process3DExteriorOnly(in, fhandle, out,...
                    fparams,...
                    firstDimExtents, secondDimExtents,thirdDimExtents);
                
                
                % Sweep partial 2D planes along the top and bottom
                firstDimExtents  = [1, nhoodObj.InteriorStart(1)-1];
                secondDimExtents = [nhoodObj.InteriorStart(2), nhoodObj.InteriorEnd(2)];
                thirdDimExtents  = [nhoodObj.InteriorStart(3), nhoodObj.InteriorEnd(3)];
                out = nhoodObj.process3DExteriorOnly(in, fhandle, out,...
                    fparams,...
                    firstDimExtents, secondDimExtents,thirdDimExtents);
                
                firstDimExtents = [nhoodObj.InteriorEnd(1)+1, nhoodObj.ImageSize(1)];
                out = nhoodObj.process3DExteriorOnly(in, fhandle, out,...
                    fparams,...
                    firstDimExtents, secondDimExtents,thirdDimExtents);
                
            end
        end
        function out = process3DExteriorOnly(nhoodObj, in, fhandle, out, fparams,...
                firstDimExtents, secondDimExtents, thirdDimExtents)
            coder.internal.prefer_const(fparams);
            coder.inline('always');
            
            padValue = cast(nhoodObj.PadValue,'like',in);
            
            % Guard against imagesize < nhood size
            firstDimExtents(1) = max(firstDimExtents(1), 1);
            firstDimExtents(2) = min(firstDimExtents(2), nhoodObj.ImageSize(1));
            secondDimExtents(1) = max(secondDimExtents(1), 1);
            secondDimExtents(2) = min(secondDimExtents(2), nhoodObj.ImageSize(2));
            thirdDimExtents(1) = max(thirdDimExtents(1), 1);
            thirdDimExtents(2) = min(thirdDimExtents(2), nhoodObj.ImageSize(3));
            
            for thirdInd = thirdDimExtents(1):thirdDimExtents(2)
                for secondInd = secondDimExtents(1):secondDimExtents(2)
                    for firstInd = firstDimExtents(1):firstDimExtents(2)
                        %> Process pixels with partial neighborhood
                        % Obtain linear index to pixel
                        
                        % pind = (thirdInd-1)* nhoodObj.ImageSize(2)*nhoodObj.ImageSize(1) ...
                        %      + (secondInd-1)*nhoodObj.ImageSize(1)...
                        %      + firstInd;
                        pind = firstInd;
                        pind = coder.internal.indexPlus(pind,...
                            coder.internal.indexTimes(nhoodObj.ImageSize(1), ...
                            coder.internal.indexMinus(secondInd,1)));
                        pind = coder.internal.indexPlus(pind,...
                            coder.internal.indexTimes(nhoodObj.ImageSize(2), ...
                            coder.internal.indexTimes(nhoodObj.ImageSize(1),...
                            coder.internal.indexMinus(thirdInd,1))));
                        
                        [imnhInds, nhInds, isInside]  = nhoodObj.getNeighborIndices(pind);
                        
                        if(isrow(in))
                            % Handle edge case indexing when 'in' degenerates
                            % down from a 2D image during run-time.
                            imnh      = in(imnhInds');
                        else
                            imnh      = in(imnhInds);
                        end
                        
                        if(nhoodObj.Padding == images.internal.coder.NeighborhoodProcessor.PADDING.CONSTANT)
                            imnh(~isInside) = padValue;
                        end
                        
                        % Augment the fparams data with pixel info
                        fparamsAugmented = images.internal.coder.NeighborhoodProcessor.augmentFunctionParameters(fparams,...
                            in(pind), pind, nhInds, imnhInds);
                        
                        % Call client pixel function
                        out(pind) = fhandle(imnh, fparamsAugmented);
                    end
                end
            end
        end
        
        % ND Generalization
        function out = processND(nhoodObj, in, fhandle, out, fparams)
            coder.inline('always');
            coder.internal.prefer_const(fparams);
            
            padValue = cast(nhoodObj.PadValue,'like',in);
            
            % Use naive random walker
            for pind = 1:numel(in)
                [imnhInds, nhInds, isInside]  = nhoodObj.getNeighborIndices(pind);
                
                if(isrow(in))
                    % Handle edge case indexing when 'in' degenerates
                    % down from a 2D image during run-time.
                    imnh      = in(imnhInds');
                else
                    imnh      = in(imnhInds);
                end
                
                if(nhoodObj.Padding == images.internal.coder.NeighborhoodProcessor.PADDING.CONSTANT)
                    imnh(~isInside) = padValue;
                end
                
                % Augment the fparams data with pixel info
                fparamsAugmented = images.internal.coder.NeighborhoodProcessor.augmentFunctionParameters(fparams,...
                    in(pind), pind, nhInds, imnhInds);
                
                % Call client pixel function
                out(pind) = fhandle(imnh, fparamsAugmented);
            end
        end
        
    end
    
    %% Static Helpers
    methods (Static = true, Access = private)
        
        function [loffsets, linds, soffsets, interiorStart, interiorEnd]...
                = computeParameters(...
                imSize, nhConn, rounding,...
                loffsets, linds, soffsets)
            
            coder.inline('always');
            coder.internal.prefer_const(imSize);
            coder.internal.prefer_const(nhConn);
            coder.internal.prefer_const(rounding);
            
            %
            % Mental model -
            % Full relative linear offsets from start of image:
            %   inds = reshape(1:prod(imSize),imSize);
            % Relative linear offsets from top left of conn sized nhood:
            %   inds(1:connSize(1), 1:connSize(2),...)
            % Subtract linear offset at location corresponding to center
            % pixel in conn to obtain required final offsets.
            %
            
            connSize            = size(nhConn);
            pixelsPerNhPage     = [1 cumprod(connSize(1:end-1))];
            % Handle ndims(im)>ndims(nhConn);
            pixelsPerImPage     = [1 cumprod(imSize(1:end-1))];
            pixelsPerImPage     = pixelsPerImPage(1:ndims(nhConn));
            
            % Subscripts to center pixel
            switch rounding
                case images.internal.coder.NeighborhoodProcessor.NEIGHBORHOODCENTER.TOPLEFT
                    centerPixelSub = floor((connSize+1)./2);
                otherwise
                    % DEFAULT or BOTTOMRIGHT
                    centerPixelSub = ceil((connSize+1)./2);
            end
            centerPixelSub = coder.internal.indexInt(centerPixelSub);
                        
            % Interior pixels - pixel extents which will have full
            % neighborhoods. Handle ndims(im)>ndims(nhConn);
            interiorStart = ones(1,numel(imSize));
            interiorStart(1:ndims(nhConn)) = centerPixelSub ...
                - ones(1,ndims(nhConn), coder.internal.indexIntClass()) ...
                + coder.internal.indexInt(1);
            
            interiorEnd   = imSize;
            % interiorEnd(1:ndims(nhConn)) =...
            %     imSize(1:ndims(nhConn)) - (connSize - cpixelSub);
            interiorEnd(1:ndims(nhConn)) =...
                coder.internal.indexMinus(...
                imSize(1:ndims(nhConn)),...
                coder.internal.indexMinus(connSize, centerPixelSub)...
                );
            
            if(sum(nhConn(:))==0)
                % No valid neighbors 
                return;
            end
            
            indx = 1;
            for pind = 1:numel(nhConn)
                % For each neighbor location
                if(nhConn(pind))
                    % If its a valid neighbor, compute its subscipt
                    subs = ...
                        images.internal.coder.NeighborhoodProcessor.getSubscriptArrayFromInd(...
                        connSize, pind);
                    if(~isempty(soffsets))
                        % Protect against coder error when there are no
                        % neighbors.
                        soffsets(indx,:) = subs;
                    end
                    % and liner index in the nhood size context
                    weights     = [subs(1) subs(2:end)-1];
                    linds(indx) = sum(coder.internal.indexTimes(weights,pixelsPerNhPage));
                    
                    % Compute location of the neighbor in the context of
                    % the image size
                    weights          = [subs(1) subs(2:end)-1];
                    loffsets(indx)   = sum(coder.internal.indexTimes(weights,pixelsPerImPage));
                    
                    indx = indx+1;
                end
            end
            
            % Move offsets to center pixel (in the image size space)
            weights  = [centerPixelSub(1) centerPixelSub(2:end)-1];
            centerLocationInImage = sum(coder.internal.indexTimes(weights,pixelsPerImPage));
            loffsets = coder.internal.indexMinus(loffsets,centerLocationInImage);
            
            soffsets = bsxfun(@minus, soffsets, centerPixelSub);
            
        end
        
        function fparamsAugmented = augmentFunctionParameters(fparams,...
                pixel, pind, nhInds, imnhInds)
            % Augment the parameters sent as the second input to the per
            % pixel processing function handle with pixel specific
            % information.
            coder.inline('always');
            if(~isempty(fparams))
                fparamsAugmented = fparams;
            end
            fparamsAugmented.pixel    = pixel;
            fparamsAugmented.ind      = pind;
            fparamsAugmented.nhInds   = nhInds;
            fparamsAugmented.imnhInds = imnhInds;
        end
        
        
        function sub = getSubscriptArrayFromInd(siz, ndx)
            % ind2sub implementation
            % Modified to return subs as a single row vector
            
            coder.inline('always');
            
            sub = zeros(1, numel(siz));
            
            if numel(siz) == 2
                vi     = rem(ndx-1, siz(1)) + 1;
                sub(2) = double((coder.internal.indexMinus(ndx,vi))/siz(1) + 1);
                sub(1) = double(vi);
            else
                % 3+ D
                siz = double(siz);
                ndx = double(ndx);
                k = [1 cumprod(siz(1:end-1))];
                for i = numel(siz):-1:1,
                    vi = rem(ndx-1, k(i)) + 1;
                    vj = (ndx - vi)/k(i) + 1;
                    sub(i) = double(vj);
                    ndx = vi;
                end
            end
            
        end
        
        function ind = getIndFromSubscriptArray(siz, sub)
            % sub2ind implementation
            % Modified to accept an array of subscripts
            k   = [1 cumprod(siz(1:end-1))];
            ind = coder.internal.indexInt(1);          
            for i = 1:numel(siz)
                v = sub(i);
                ind = ind + coder.internal.indexInt(v-1)*k(i);
            end
            
        end
        
    end
    
end