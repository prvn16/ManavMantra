function A = adjacencyMatrix(B,N) %#codegen
% For internal use only.

% Copyright 2015 The MathWorks, Inc.

numObjs = coder.internal.indexInt(N);

% Total number of boundaries
numBoundaries = length(B);

% sparse is not supported for code generation; return a full matrix
A = false(numBoundaries);

[numLevels,groupedIndices,numElemsPerGroup] = ...
    groupBoundariesByTreeLevelCodegen(B,numObjs);

% scan through all the level pairs
totalNumElems = coder.internal.indexInt(0);
for p = 1:numLevels-1
    % outside boundaries
    numElems = numElemsPerGroup(p);
    parentsIdx = groupedIndices(totalNumElems+1:totalNumElems+numElems);
    
    totalNumElems = coder.internal.indexPlus(totalNumElems,numElems);
    
    % inside boundaries
    numElems = numElemsPerGroup(p+1);
    childrenIdx = groupedIndices(totalNumElems+1:totalNumElems+numElems);
    
    % Get one sample point on each child boundary
    sampChildren = getSamplePointsFromBoundariesCodegen(B,childrenIdx);
    
    % For each parent boundary
    for m = 1:length(parentsIdx)
        % Index of one of the parents into B
        parentIdx = parentsIdx(m);
        
        % Parent boundary as row-column coordinates
        parent = B{parentIdx};
        
        % Are the children in the current parent?
        isInside = images.internal.coder.inpolygon( ...
            sampChildren(:,2), sampChildren(:,1), ...
            parent(:,2), parent(:,1));
        
        % use a loop for C code generation
        for k = 1:length(isInside)
            childIdx = childrenIdx(k);
            % Set A(i,j)=1 if i is a child of j
            A(childIdx,parentIdx) = isInside(k);
        end
    end
end

%--------------------------------------------------------------------------
% Group object and hole boundaries by level.
%   @in : B - the cell array of boundaries
%         numObjs - the number of objects in B
%   @out: numLevels - the total number of levels (layers of an onion)
%         groupedIndices - a vector of indices grouped by level
%         numElemsPerGroup - a companion vector indicating how many indices
%         there are in each group/layer/level
% The first group contains boundaries which are the outermost (first layer
% of an onion), the second holds the second layer, and so on.
% Variable sized cell arrays do not work very well in code generation yet,
% so here the indices are implicitly grouped. numElemsPerGroup and
% numLevels help us extract the groups from groupedIndices.
function [numLevels,groupedIndices,numElemsPerGroup] = ...
    groupBoundariesByTreeLevelCodegen(B,numObjs)

% Total number of boundaries
P = coder.internal.indexInt(length(B));

% Initialize output
groupedIndices   = coder.internal.indexInt(zeros(P,1));
numElemsPerGroup = coder.internal.indexInt(zeros(P,1));
numLevels = coder.internal.indexInt(0);

% Return empty outputs if the input is empty
if (P < 1)
    return
end

numHoles = P - numObjs;

% Process holes if there are any
processHoles = (numHoles > 0);

% B contains both object and hole boundaries.
% Define the bounds for objects and holes.
startObjectIdx = 1;
endObjectIdx = numObjs;
objectIdx = startObjectIdx:endObjectIdx;

startHoleIdx = numObjs+1;
endHoleIdx = P;
holeIdx = startHoleIdx:endHoleIdx;

% Initialize loop control variables
skipHoleBoundary   = false(numHoles,1);
skipObjectBoundary = false(numObjs,1);
done     = false;
findHole = false; % start with an object boundary and then alternate

currentGroupIdx = coder.internal.indexInt(1);
totalNumElems   = coder.internal.indexInt(0);

while ~done
    if (findHole)
        isOutermostHole = findOutermostBoundariesCodegen( ...
            B,startHoleIdx,endHoleIdx,skipHoleBoundary);
        
        % Once skipHoleBoundary is all 1's we are done processing holes
        skipHoleBoundary = skipHoleBoundary | isOutermostHole;
        
        % Indices (into B) of hole boundaries at the same level
        holesAtThatLevel = holeIdx(isOutermostHole);
        
        % Save the grouped boundaries
        numElems = coder.internal.indexInt(numel(holesAtThatLevel));
        numElemsPerGroup(currentGroupIdx) = numElems;
        groupedIndices(totalNumElems+1:totalNumElems+numElems) = holesAtThatLevel;
    else
        isOutermostObject = findOutermostBoundariesCodegen( ...
            B,startObjectIdx,endObjectIdx,skipObjectBoundary);
        
        % Once skipObjectBoundary is all 1's we are done processing objects
        skipObjectBoundary = skipObjectBoundary | isOutermostObject;
        
        % Indices (into B) of object boundaries at the same level
        objectsAtThatLevel = objectIdx(isOutermostObject);
        
        % Save the grouped boundaries
        numElems = coder.internal.indexInt(numel(objectsAtThatLevel));
        numElemsPerGroup(currentGroupIdx) = numElems;
        groupedIndices(totalNumElems+1:totalNumElems+numElems) = objectsAtThatLevel;
    end
    
    totalNumElems = coder.internal.indexPlus(totalNumElems,numElems);
    currentGroupIdx = coder.internal.indexPlus(currentGroupIdx,1);
    
    if processHoles
        findHole = ~findHole;
    end
    
    if all(skipHoleBoundary) && all(skipObjectBoundary)
        done = true;
    end
end

% numElemsPerGroup is larger than necessary (P is an upper bound) to avoid
% having to resize the array at runtime (allocation on the stack is
% faster), so numLevels tells us what the actual length of numElemsPerGroup
% is.
numLevels = currentGroupIdx-1;

%--------------------------------------------------------------------------
% Returns a logical vector showing the locations of outermost boundaries
% in the input vector (ie 1 for the boundaries that are outermost and
% 0 for all other boundaries)
% startIdx and endIdx bound the section of B that we want to look at (e.g.,
% objects or holes).
% skipBoundary is a logical vector that indicates which boundary we have
% already processed and need to be skipped.
function isOutermost = findOutermostBoundariesCodegen(B,startIdx,endIdx,skipBoundary)

coder.internal.prefer_const(B,startIdx,endIdx,skipBoundary);

% Look for parent boundaries
isOutermost = false(size(skipBoundary));

for m = startIdx:endIdx
    % Skip the boundaries we have already processed
    if ~skipBoundary(m-startIdx+1)
        boundary = B{m};
        x = boundary(1,2); % grab a sample point for testing
        y = boundary(1,1);
        
        surrounded = false;
        for n = startIdx:endIdx % exclude boundary under test
            if ~skipBoundary(n-startIdx+1) && (n ~= m)
                boundary = B{n};
                if images.internal.coder.inpolygon(x,y,boundary(:,2),boundary(:,1))
                    surrounded = true;
                    break;
                end
            end
        end
        isOutermost(m-startIdx+1) = ~surrounded;
    end
end

%--------------------------------------------------------------------------
%   @in:  B - the entire cell array containing object and hole boundaries 
%         as Q-by-2 matrices of row-column coordinates.
%         indexList - vector of indices into B that indicates which
%         boundaries to sample.
%   @out: points - length(indexList)-by-2 matrix of row-column coordinates.
function points = getSamplePointsFromBoundariesCodegen(B,indexList)

coder.internal.prefer_const(B,indexList);

numChildren = coder.internal.indexInt(length(indexList));
points = coder.nullcopy(zeros(numChildren,2));

for m = 1:numChildren
    idx = indexList(m);
    boundary = B{idx};
    % Just pick the first point on the boundary
    points(m,:) = boundary(1,:);
end
