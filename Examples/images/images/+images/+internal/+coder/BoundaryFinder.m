classdef BoundaryFinder < handle %#codegen
    
    % This is an implementation of the boundaries class used by
    % bwboundariesmex in M for C code generation
    
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Access = protected)
        % Basic members
        conn
        numRows
        numCols
        paddedLabelMatrix
        
        % Lookup tables and other variables used by the tracing algorithm
        neighborOffsets        % array of obj.conn indices
        validationOffsets      % array of obj.conn indices
        nextDirectionLut       % array of int
        nextSearchDirectionLut % array of int
        nextSearchDir  % int
        startMarker    % int
        boundaryMarker % int
    end
    
    methods
        function obj = BoundaryFinder(labelMatrix,conn)
            
            % Pad with zeros to avoid going out of bounds
            obj.paddedLabelMatrix = padarray(labelMatrix,[1,1]);
            
            [numRows,numCols] = size(labelMatrix);
            
            % Taking padding into consideration
            obj.numRows = coder.internal.indexInt(numRows+2);
            obj.numCols = coder.internal.indexInt(numCols+2);
            
            % Validate conn
            validateattributes(conn,{'double'},{},mfilename,'CONN')
            % conn must be 4 or 8
            assert(conn==4 || conn==8, ...
                eml_message('images:bwboundaries:badScalarConn'))
            
            obj.conn = conn;
        end
        
        function B = findBoundaries(obj)
            % Find boundaries in a label image.
            
            M = obj.numRows;
            N = obj.numCols;
            
            % Create output cell array
            numRegions = obj.calculateNumRegions();
            % If there is connected component in the image,
            % B will be a 0-by-1 empty cell array.
            % Note that bwboundariesmex returns a 0-by-0 empty cell array.
            B = coder.nullcopy(cell(numRegions,1));
            
            regionHasBeenTraced = false(numRegions,1);
            if (numRegions > 0)
                % Prepare lookup tables used for tracing boundaries
                obj.initTraceLUTs('double','clockwise')
                obj.setNextSearchDirection([],0,0,'clockwise')
                
                for c = 2:N-1
                    for r = 2:M-1
                        linearIdx = M*(c-1) + r;
                        label     = coder.internal.indexInt(obj.paddedLabelMatrix(linearIdx));
                        previousLabel = obj.paddedLabelMatrix(linearIdx-1);
                        
                        if label > 0 && ...               % if we are in a region
                              previousLabel == 0 && ...   % if this is the first pixel of the region
                              ~regionHasBeenTraced(label) % we haven't traced that region before
                          
                            % We have found the start of a new boundary
                            boundary = obj.traceBoundary(linearIdx);
                            B{label} = boundary;
                            regionHasBeenTraced(label) = true;
                        end
                    end
                end
            end
        end
    end
    
    methods (Access = protected)
        function numRegions = calculateNumRegions(obj)
            % Calculate the number of regions in the label matrix.
            
            M = obj.numRows;
            N = obj.numCols;
            
            % Return the maximum label
            numRegions = 0;
            numElements = M*N;
            for k = 1:numElements
                label = obj.paddedLabelMatrix(k);
                if (label > numRegions)
                    numRegions = label;
                end
            end
        end
        
        function boundary = traceBoundary(obj,idx)
            % Trace the boundary of a single region from a label matrix and
            % the linear index of the initial border pixel. The output is a
            % Q-by-2 array of Q row-column coordinate pairs for the pixels
            % belonging to the boundary.
            
            % Initialize loop variables
            coder.varsize('scratch');
            scratch = coder.nullcopy(coder.internal.indexInt(zeros(INITIAL_SCRATCH_LENGTH,1)));
            scratchLength    = INITIAL_SCRATCH_LENGTH;
            scratch(1)       = idx;
            obj.paddedLabelMatrix(idx) = obj.startMarker;
            isDone           = false;
            numPixels        = coder.internal.indexInt(1);
            currentPixel     = idx;
            nextSearchDir    = obj.nextSearchDir; %#ok<PROPLC>
            initDepartureDir = coder.internal.indexInt(-1);
            
            while ~isDone
                % Find the next boundary pixel
                direction = nextSearchDir; %#ok<PROPLC>
                foundNextPixel = false;
                
                for k = 1:obj.conn
                    % Try to locate the next pixel in the chain
                    neighbor = coder.internal.indexPlus(currentPixel, obj.neighborOffsets(direction+1));
                    
                    if obj.paddedLabelMatrix(neighbor)
                        % Found the next boundary pixel
                        if obj.paddedLabelMatrix(currentPixel) == obj.startMarker && ...
                              initDepartureDir == coder.internal.indexInt(-1)
                            % We are making the initial departure from the
                            % starting pixel
                            initDepartureDir = direction;
                        elseif obj.paddedLabelMatrix(currentPixel) == obj.startMarker && ...
                                initDepartureDir == direction
                            % We are about to retrace our path: we're done
                            isDone = true;
                            foundNextPixel = true;
                            break
                        end
                        
                        % Take the next step along the boundary
                        nextSearchDir = obj.nextSearchDirectionLut(direction+1); %#ok<PROPLC>
                        foundNextPixel = true;
                        
                        if (scratchLength <= numPixels+1)
                            [scratch,scratchLength] = expandScratchSpace(scratch,scratchLength);
                        end
                        
                        % Use numPixels as an index into scratch array
                        scratch(numPixels+1) = neighbor;
                        numPixels = numPixels + 1;
                        
                        if (numPixels == MAX_NUM_PIXELS)
                            isDone = true;
                            break
                        end
                        
                        if (obj.paddedLabelMatrix(neighbor) ~= obj.startMarker)
                            obj.paddedLabelMatrix(neighbor) = obj.boundaryMarker;
                        end
                        
                        currentPixel = neighbor;
                        break
                    end
                    direction = obj.nextDirectionLut(direction+1);
                end
                
                if ~foundNextPixel
                    % If there is no next neighbor, the region must have a
                    % single pixel
                    numPixels = coder.internal.indexInt(2);
                    scratch(2) = scratch(1);
                    isDone = true;
                end
            end
            
            % Copy coordinates to output matrix
            boundary = obj.copyCoordsToBuf(numPixels,scratch);
        end
        
        function boundary = copyCoordsToBuf(obj,numPixels,linearIndices)
            % Convert linear indices to row-column coordinates
            % Remove the effect of zero padding
            % Save the RC coordinates to boundary
            
            boundary = coder.nullcopy(zeros(numPixels,2));            
            for k = 1:numPixels
                col = coder.internal.indexDivide(linearIndices(k),obj.numRows);
                row = linearIndices(k) - col*obj.numRows - 1;
                boundary(k,1) = row;
                boundary(k,2) = col;
            end
        end
        
        function initTraceLUTs(obj,class,direction)
            % Initialize the lookup tables and other initial values used by
            % the boundary tracing methods. direction is either 'clockwise'
            % or 'counterclockwise'.
            
            if strcmp(class,'logical')
                obj.startMarker    = START_UINT8;
                obj.boundaryMarker = BOUNDARY_UINT8;
            else
                % double
                obj.startMarker    = START_DOUBLE;
                obj.boundaryMarker = BOUNDARY_DOUBLE;
            end
            
            % Store the linear indexing offsets to go from a pixel to one
            % of its neighbors in neighborOffsets.
            % Store the linear indexing offsets used to validate whether a 
            % pixel is on the boundary of an object in validationOffsets.
            M = obj.numRows;
            if (obj.conn == 8)
                % N, NE, E, SE, S, SW, W, NW
                obj.neighborOffsets = coder.internal.indexInt([-1,M-1,M,M+1,1,-M+1,-M,-M-1]);
                obj.validationOffsets = coder.internal.indexInt([-1,M,1,-M, 0,0,0,0]);
                % We're adding 0's to make it length 8 in all cases because
                % Coder doesn't support varsize for class members.
            else
                % N, E, S, W
                obj.neighborOffsets = coder.internal.indexInt([-1,M,1,-M, 0,0,0,0]);
                obj.validationOffsets = coder.internal.indexInt([-1,M-1,M,M+1,1,-M+1,-M,-M-1]);
            end
            
            ndl8c  = coder.internal.indexInt([1,2,3,4,5,6,7,0]);
            nsdl8c = coder.internal.indexInt([7,7,1,1,3,3,5,5]);
            
            ndl4c  = coder.internal.indexInt([1,2,3,0, 0,0,0,0]);
            nsdl4c = coder.internal.indexInt([3,0,1,2, 0,0,0,0]);
            
            ndl8cc  = coder.internal.indexInt([7,0,1,2,3,4,5,6]);
            nsdl8cc = coder.internal.indexInt([1,3,3,5,5,7,7,1]);
            
            ndl4cc  = coder.internal.indexInt([3,0,1,2, 0,0,0,0]);
            nsdl4cc = coder.internal.indexInt([1,2,3,0, 0,0,0,0]);
            
            % nextDirectionLut defines which neighbor we should look at
            % after having looked at a previous neighbor in a given
            % direction.
            
            % nextSearchDirectionLut defines the direction we should start
            % looking in when examining the neighborhood of pixel k+1 given
            % the direction pixel k to pixel k+1.
            
            if strcmp(direction,'clockwise')
                if (obj.conn == 8)
                    obj.nextDirectionLut = ndl8c;
                    obj.nextSearchDirectionLut = nsdl8c;
                else
                    obj.nextDirectionLut = ndl4c;
                    obj.nextSearchDirectionLut = nsdl4c;
                end
            else
                if (obj.conn == 8)
                    obj.nextDirectionLut = ndl8cc;
                    obj.nextSearchDirectionLut = nsdl8cc;
                else
                    obj.nextDirectionLut = ndl4cc;
                    obj.nextSearchDirectionLut = nsdl4cc;
                end
            end
        end
        
        function setNextSearchDirection(obj,bwImage,idx,firstStep,direction)
            % Given an initial boundary pixel and an initial guess for the
            % next search direction, verify that the guess is valid and set
            % the correct next search direction.
            
            if isempty(bwImage)
                % Used by findBoundaries: next search direction depends on
                % trace direction and connectivity
                if strcmp(direction,'clockwise')
                    obj.nextSearchDir = coder.internal.indexInt(1);
                else
                    obj.nextSearchDir = coder.internal.indexInt(obj.conn-1);
                end
            else
                % Check whether direction is valid
                validSearchDirFound = false;
                for clockIdx = firstStep:firstStep+obj.conn
                    % Convert clockwise index to counterclockwise index
                    tmp = 2*firstStep - clockIdx; % linear index, might be <0
                    counterIdx = tmp + (tmp<=0)*obj.conn; % make it >0
                    
                    % Set current index depending on the tracing direction
                    if strcmp(direction,'clockwise')
                        currentCircIdx = clockIdx;
                    else
                        currentCircIdx = counterIdx;
                    end
                    
                    % Convert linear index to circular index
                    currentCircIdx = rem(currentCircIdx,obj.conn);
                    
                    % Search for a background neighbor according to the
                    % proposed search direction
                    
                    if strcmp(direction,'clockwise')
                        delta = -1;
                    else
                        delta = 1;
                    end
                    if (obj.conn == 8)
                        checkDir = currentCircIdx + delta;
                        checkDir = checkDir + (checkDir<0)*8;
                        checkDir = rem(checkDir,8);
                        
                        % For 8-connected traces, neighborOffsets has all 8
                        % neighbors
                        offset = idx + obj.neighborOffsets(checkDir);
                        if (bwImage(offset) == 0)
                            validSearchDirFound = true;
                            obj.nextSearchDir = currentCircIdx;
                            break
                        end
                    else
                        checkDir1 = 2*currentCircIdx + 2*delta;
                        checkDir1 = checkDir1 + (checkDir1<0)*8;
                        checkDir1 = rem(checkDir1,8);
                        
                        checkDir2 = checkDir1 - delta;
                        checkDir2 = checkDir2 + (checkDir2<0)*8;
                        checkDir2 = rem(checkDir2,8);
                        
                        % For 4-connected traces, validationOffsets has all
                        % 8 neighbors
                        offset1 = idx + obj.validationOffsets(checkDir1);
                        offset2 = idx + obj.validationOffsets(checkDir2);
                        if ~(bwImage(offset1) && bwImage(offset2))
                            validSearchDirFound = true;
                            obj.nextSearchDir = currentCircIdx;
                            break
                        end
                    end
                end
                assert(validSearchDirFound, ...
                    'Unable to determine valid search direction');
            end
        end
    end
end

%--------------------------------------------------------------------------
% Constants
function out = INITIAL_SCRATCH_LENGTH
    out = coder.internal.indexInt(200);
end

function out = START_DOUBLE
    out = -2;
end

function out = BOUNDARY_DOUBLE
    out = -3;
end

function out = START_UINT8
    out = 2;
end

function out = BOUNDARY_UINT8
    out = 3;
end

function out = MAX_NUM_PIXELS
    out = intmax('int32'); % arbitrary
end

%--------------------------------------------------------------------------
% Utils
function [scratch,scratchLength] = expandScratchSpace(scratchIn,scratchLengthIn)
    % Expand scratch space for holding region boundaries
    scratchLength = 2*scratchLengthIn;
    scratch = coder.nullcopy(coder.internal.indexInt(zeros(scratchLength,1)));
    for k = 1:scratchLengthIn
        scratch(k) = scratchIn(k);
    end
end
