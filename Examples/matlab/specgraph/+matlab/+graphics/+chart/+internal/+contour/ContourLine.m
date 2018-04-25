classdef ContourLine
%ContourLine Contour line vertex coordinates and topology
%
%   ContourLine properties:
%      Level - Numerical contour level
%      VertexData - 3-by-N array of vertex coordinates
%      StripData - 1-by-M vector of indices into the VertexData
%
%   ContourLine methods:
%      ContourLine - Construct ContourLine object or array
%      empty - Construct empty ContourLine object
%      splitParts - Split multi-part contour lines into distinct objects
%      mergeParts - Combine contour lines resulting in one per level
%      removeEmpty - Remove elements with no vertices
%      deriveContourMatrix - Convert content to contour matrix form
%      xyzdata - NaN-separated X,Y,Z vectors suitable for use with plot
%
%   Coordinates: This representation is not specific to a certain
%   coordinate system. Vertices can be in the user's data coordinates,
%   local coordinates, or world coordinates.

% Copyright 2014-2017 The MathWorks, Inc.

    properties
        %Level Numerical contour level
        %
        %   A real scalar value equal to the level which the contour
        %   line represents.
        %
        %   Class: double
        Level = [];
        
        % VertexData - 3-by-N array of vertex coordinates
        %
        %   Rows 1, 2, and 3 contain X, Y, and Z coordinates, respectively.
        %   Multiple parts (curves) are indexed by the StripData.
        %
        %   Class: single or double
        VertexData = reshape([],[3 0]);
        
        % StripData - 1-by-M vector of indices into the VertexData
        %
        %   M equals 1 plus the number of distint parts (curves) comprised
        %   by the VertexData. The coordinates of the k-th part start at
        %   column StripData(k) in VertexData and end at column
        %   StripData(k+1) - 1. If only one curve of length L is present,
        %   for example, then StripData equals [1 L+1].
        %
        %   Class: uint32
        StripData  = uint32(1);
    end

    methods (Static)
        function emptyArray = empty()
            %empty Construct empty ContourLine object
            %
            %    matlab.graphics.chart.internal.contour.ContourLine.empy()
            %    returns 0-by-1 ContourLine object.
            emptyArray = matlab.graphics.chart.internal.contour.ContourLine;
            emptyArray(1) = [];
            emptyArray = reshape(emptyArray,[0 1]);
        end
    end
    
    methods
        function contourLine = ContourLine(level, vertexData, stripData)
            %ContourLine Construct ContourLine object or array
            %
            %   matlab.graphics.chart.internal.contour.ContourLine
            %   constructs a default ContourLine object with empty Level
            %   and VertexData values, and StripData set to uint32(1).
            %
            %   matlab.graphics.chart.internal.contour.ContourLine( ...
            %   level, vertexData, stripData) constructs a scalar
            %   ContourLine object with the specified property values.
            %
            %   matlab.graphics.chart.internal.contour.ContourLine( ...
            %   contourMatrix) converts a contourMatrix to a ContourLine
            %   array, with one element for each distinct part. (Typically,
            %   this means more than one element for at least some levels.)
            %
            %   Examples
            %   --------
            %   defaultContourLine = matlab.graphics.chart.internal.contour.ContourLine
            %   
            %   level = 17;
            %
            %   vertexData = [ ...
            %       0.87 0.50 0 -0.50 -0.87 -0.87 -0.50  0  0.50  0.87; ...
            %       0.50 0.87 1  0.87  0.50 -0.50 -0.87 -1 -0.87 -0.50; ...
            %       0    0    0  0     0     0     0     0  0     0];
            %
            %   stripData = uint32([1 6 11]);
            %
            %   contourLines = matlab.graphics.chart.internal.contour.ContourLine( ...
            %       level, vertexData, stripData)
            
            if nargin == 3 && isscalar(level)
                contourLine = matlab.graphics.chart.internal.contour.ContourLine;
                contourLine.Level = level;
                contourLine.VertexData = vertexData;
                contourLine.StripData = uint32(stripData);
            elseif nargin == 1 && (isempty(level) || size(level,1) == 2)
                contourMatrix = level;
                contourLine = convertMatrixToLines(contourMatrix);
            end
        end
        
        function splitContourLines = splitParts(contourLines)
            %splitParts Split multi-part contour lines into distinct objects
            %
            %    splitContourLines = splitParts(contourLines) splits each
            %    distinct contour line part (each connected curve, that
            %    is), into a separate ContourLine element. The input can be
            %    a scalar ContourLine object or a ContourLine array. In
            %    either case, each element of the output array has exactly
            %    one part. (Typically, the output array has more elements
            %    than the input.)
            %
            %   Example
            %   -------
            %   [x,y,z] = peaks;
            %   levels = -6:2:6;
            %   contourLines = matlab.graphics.chart.internal.contour.contourGriddedData(x,y,z,levels)
            %   split = splitParts(contourLines)
            %   [contourLines.Level]
            %   [split.Level]

            switch numel(contourLines)
                case 0
                    splitContourLines = contourLines;

                case 1
                    [startIndices, endIndices] = indexParts(contourLines);
                    if isempty(startIndices)
                        splitContourLines = contourLines;
                    else
                        numParts = numel(startIndices);
                        if numParts == 1
                            splitContourLines = contourLines;
                        else
                            splitContourLines(numParts,1) = matlab.graphics.chart.internal.contour.ContourLine;
                            for k = 1:numParts
                                s = startIndices(k);
                                e = endIndices(k);
                                splitContourLines(k).Level = contourLines.Level;
                                splitContourLines(k).VertexData = contourLines.VertexData(:,s:e);
                                splitContourLines(k).StripData = [1, e - s + 2];
                            end
                        end
                    end

                otherwise
                    splitContourLines = matlab.graphics.chart.internal.contour.ContourLine;
                    splitContourLines(1) = [];
                    for k = 1:numel(contourLines)
                        splitContourLines = [splitContourLines; splitParts(contourLines(k))]; %#ok<AGROW>
                    end
            end
        end

        function mergedContourLines = mergeParts(contourLines)
            %mergeParts Combine contour lines resulting in one per level
            %
            %   mergedContourLines = mergeParts(contourLines) combines
            %   input elements, ensuring only one output element per
            %   contour level. The output is sorted by contour level in
            %   ascending order. Typically, the output has fewer elements
            %   than the input.
            %
            %   Example
            %   -------
            %   [x,y,z] = peaks;
            %   levels = -6:2:6;
            %   contourLines = matlab.graphics.chart.internal.contour.contourGriddedData(x,y,z,levels);
            %
            %   split = splitParts(contourLines)
            %   merged = mergeParts(split)
            %   [split.Level]
            %   [merged.Level]
            
            if numel(contourLines) < 2
                mergedContourLines = contourLines;
            else
                contourLines = contourLines(:);
                uniqueLevels = unique([contourLines.Level]);
                mergedContourLines(numel(uniqueLevels),1) = matlab.graphics.chart.internal.contour.ContourLine;
                for k = 1:numel(contourLines)
                    c = contourLines(k);
                    m = find(c.Level == uniqueLevels);
                    mergedVertexData = mergedContourLines(m).VertexData;
                    mergedContourLines(m).Level = c.Level;
                    mergedContourLines(m).StripData = [mergedContourLines(m).StripData(1,1:end-1) ...
                        size(mergedVertexData,2) + c.StripData];
                    mergedContourLines(m).VertexData = [mergedVertexData c.VertexData];
                end
            end
        end
        
        function [splitContourLines, isLoop] = separateStripsAndLoops(contourLines)
            %separateStripsAndLoops Separate contour loops from strips
            %
            %   [splitContourLines, isLoop] = separateStripsAndLoops(contourLines)
            %   returns to separate lists of contourLines: those which are
            %   strips (first and last vertex are different) vs. those
            %   which are loops (first and last vertex are the same).
            
            % Linearize the list of contour lines.
            contourLines = contourLines(:);
            
            % Initialize some variables.
            numLines = numel(contourLines);
            hasStrips = false(1,numLines);
            hasLoops = false(1,numLines);
            if numLines == 0
                strips = matlab.graphics.chart.internal.contour.ContourLine.empty();
                loops = matlab.graphics.chart.internal.contour.ContourLine.empty();
            else
                strips(1,numLines) = matlab.graphics.chart.internal.contour.ContourLine;
                loops(1,numLines) = matlab.graphics.chart.internal.contour.ContourLine;
            end
            
            % Check each line for loops and strips.
            for n = 1:numLines
                % Initialize the strip and loop contour lines.
                strips(n).Level = contourLines(n).Level;
                loops(n).Level = contourLines(n).Level;
                
                % Initialize some variables.
                stripData = contourLines(n).StripData;
                vertexData = contourLines(n).VertexData;
                partOfLoop = false(1,size(vertexData,2));
                numParts = numel(stripData)-1;
                isLoop = false(1,numParts);
                numVerticesPerStrip = diff(stripData);
                
                % Check each section of the line for loops and strips.
                for p = 1:numParts
                    from = stripData(p);
                    to = stripData(p+1)-1;
                    isLoop(p) = all(vertexData(:,from) == vertexData(:,to));
                    if isLoop(p)
                        hasLoops(n) = true;
                        partOfLoop(from:to) = true;
                    else
                        hasStrips(n) = true;
                    end
                end
                
                % Collect the vertex data for the loops and strips.
                strips(n).VertexData = vertexData(:,~partOfLoop);
                loops(n).VertexData = vertexData(:,partOfLoop);
                
                % Collect the strip data for the loops and strips.
                strips(n).StripData = cumsum([1 numVerticesPerStrip(~isLoop)]);
                loops(n).StripData = cumsum([1 numVerticesPerStrip(isLoop)]);
            end
            
            % Merge the two lists, preserving order.
            splitContourLines = [strips; loops];
            keep = [hasStrips; hasLoops];
            isLoop = [false(1,numLines); true(1,numLines)];
            
            % Remove the contour lines with no strips or no loops.
            splitContourLines = splitContourLines(keep(:));
            isLoop = isLoop(keep(:));
        end

        function contourLines = removeEmpty(contourLines)
            %removeEmpty Remove elements with no vertices
            %
            %   contourLines = removeEmpty(contourLines) returns the subset
            %   of the input input lines which have vertices.
            contourLines = contourLines(:);
            remove = false(size(contourLines));
            for k = 1:numel(contourLines)
                remove(k) = isempty(contourLines(k).VertexData);
            end
            contourLines(remove) = [];
        end
        
        function contourMatrix = deriveContourMatrix(contourLines)
            %deriveContourMatrix Convert content to contour matrix form
            %
            %   contourMatrix = deriveContourMatrix(contourLines) returns a
            %   standard MATLAB 2-by-N contour matrix with the same
            %   information content as in the input ContourLine vector.
            %
            %   Example
            %   -------
            %   [x,y,z] = peaks;
            %   levels = -6:2:6;
            %   contourLines = matlab.graphics.chart.internal.contour.contourGriddedData(x,y,z,levels)
            %   contourMatrix = deriveContourMatrix(contourLines);
            %   size(contourMatrix)
            
            contourMatrix = reshape([],[2 0]);
            for k = 1:numel(contourLines)
                if ~isempty(contourLines(k).Level)
                    contourMatrix = [contourMatrix singleElementContourMatrix(contourLines(k))]; %#ok<AGROW>
                end
            end
        end
        
        function [xdata, ydata, zdata] = xyzdata(contourLine)
            %xyzdata NaN-separated X,Y,Z vectors suitable for use with plot
            %
            %   [xdata, ydata, zdata] = xyzdata(contourLine) converts the
            %   vertices of a scalar ContourLine object into three vectors,
            %   with multiple parts delimited NaN. The output vectors can
            %   be used with graphics functions such as plot.
            %
            %   Example
            %   -------
            %   [x,y,z] = peaks;
            %   levels = -6:2:6;
            %   contourLines = matlab.graphics.chart.internal.contour.contourGriddedData(x,y,z,levels)
            %
            %   figure
            %   numLines = numel(contourLines);
            %   cmap = parula(numLines);
            %   for k = 1:numLines
            %        [xdata,ydata] = xyzdata(contourLines(k));
            %        plot(xdata,ydata,'Color',cmap(k,:),'DisplayName',num2str(contourLines(k).Level))
            %        hold on
            %   end
            %   hLine = findobj('Type','line');
            %   legend(hLine)
            
            [startIndices, endIndices] = indexParts(contourLine);
            numParts = numel(startIndices);
            if numParts == 0
                xdata = reshape([],[1 0]);
                ydata = xdata;
                zdata = xdata;
            else
                numVertices = (1 + endIndices(end) - startIndices(1));
                numDelimiters = (numParts - 1);
                numElements = numVertices + numDelimiters;
                xdata = NaN(1,numElements,'like',contourLine.VertexData);
                ydata = xdata;
                zdata = xdata;
                for k = 1:numParts
                    s = startIndices(k);
                    e = endIndices(k);
                    m = s + k - 1;
                    n = e + k - 1;
                    xdata(m:n) = contourLine.VertexData(1,s:e);
                    ydata(m:n) = contourLine.VertexData(2,s:e);
                    zdata(m:n) = contourLine.VertexData(3,s:e);
                end
            end
        end        
    end
    
    methods (Access = private)
        function [startIndices, endIndices] = indexParts(contourLineObj)
            if isscalar(contourLineObj)
                if numel(contourLineObj.StripData) < 2
                    startIndices = uint32([]);
                    endIndices = uint32([]);
                else
                    startIndices = contourLineObj.StripData(1:end-1);
                    endIndices = contourLineObj.StripData(2:end) - 1;
                end
            else
                validateattributes(contourLineObj, ...
                    {'matlab.graphics.chart.internal.contour.ContourLine'},{'scalar'})
            end
        end
        
        function contourMatrix = singleElementContourMatrix(contourLine)
            % Contour matrix for a single-element contour line object.
            [startIndices, endIndices] = indexParts(contourLine);
            numParts = numel(startIndices);
            if numParts == 0
                contourMatrix = reshape([],[2 0]);
            else
                level = contourLine.Level;
                xyvertices = double(contourLine.VertexData(1:2,:));
                numVertices = size(xyvertices,2);
                numElements = numParts + numVertices;
                contourMatrix = zeros(2,numElements);
                for k = 1:numel(startIndices)
                    s = startIndices(k);
                    e = endIndices(k);
                    m = s + k;
                    n = e + k;
                    numVerticesInPart = 1 + e - s;
                    contourMatrix(1,m-1) = level;
                    contourMatrix(2,m-1) = numVerticesInPart;
                    contourMatrix(:,m:n) = xyvertices(:,s:e);
                end
            end
        end
    end
end

function contourLines = convertMatrixToLines(contourMatrix)
%convertMatrixToLines Convert contour matrix to ContourLine array
%
%   Converts a MATLAB contour matrix to a column vector of
%   matlab.graphics.chart.internal.contour.ContourLine objects.
%   The contours are assumed to fall in the Z == 0 plane.

    if isempty(contourMatrix)
        contourLines = matlab.graphics.chart.internal.contour.ContourLine.empty();
    else
        contourMatrixIndex = indexContourMatrix(contourMatrix);
        contourLines(numel(contourMatrixIndex),1) = matlab.graphics.chart.internal.contour.ContourLine;
        contourLineIsEmpty = false(size(contourLines));
        for k = 1:numel(contourLines)
            i = contourMatrixIndex(k);
            numVertices = i.LastVertex - i.FirstVertex + 1;
            if numVertices > 1
                vertexData = zeros(3,numVertices);
                vertexData(1:2,:) = contourMatrix(:,i.FirstVertex:i.LastVertex);
                stripData = uint32([1 numVertices+1]);
                contourLines(k).Level = i.Level;
                contourLines(k).VertexData = vertexData;
                contourLines(k).StripData = stripData;
            else
                contourLineIsEmpty(k) = true;
            end
        end
        contourLines(contourLineIsEmpty) = [];
    end
end

function contourMatrixIndex = indexContourMatrix(contourMatrix)
% Return a structure with one element per level and fields Level,
% FirstVertex, and LastVertex such that for the k-th contour level:
%
%   contourMatrixIndex(k).Level is the numerical level value.
%
%   contourMatrixIndex(k).FirstVertex is the index of the column containing
%     the first vertex of the contour.
%
%   contourMatrixIndex(k).LastVertex is the index of the column containing
%     the last vertex of the contour.

    contourMatrixIndex = struct( ...
        'Level',[],'FirstVertex',[],'LastVertex',[]);
    contourMatrixIndex(1) = [];
    
    k = 1;
    numColumns = size(contourMatrix,2);
    while k < numColumns
        level = contourMatrix(1,k);
        numVertices = contourMatrix(2,k);
        first = k + 1;
        last  = k + numVertices;
        contourMatrixIndex(1,end+1) = struct('Level',level, ...
            'FirstVertex',first,'LastVertex',last); %#ok<AGROW>
        k = last + 1;        
    end
end
