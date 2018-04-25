function [linkedVertices, linkedStripData] = linkLineStrips(vertices, stripData)
%linkLineStrips Link together line strips having common end points
%
%   [linkedVertices, linkedStripData] = linkLineStrips(vertices, stripData)
%   identifies cases where the last vertex in the input data for one line
%   strip equals the first vertex in another strip, and links such strips
%   together. In some cases the result is a closed loop. In others it's an
%   open curve. In general, the number of columns in the vertex array is
%   reduced slightly, as duplicate vertices are removed, and the number of
%   elements in stripData may be reduced substantially, as sets of shorter
%   strips are combined into a single longer strip.

% Copyright 2014-2015 The MathWorks, Inc.

% For each input part, determing the indices of the previous and next
% parts, and the indices of the first and last vertices.
[prev, next, first, last] = sequenceStripParts(vertices, stripData);

% Logical vector for tracking which input parts have been copied already.
traced = false(size(first));

% Pre-allocate outputs to match the inputs in size. This will always be
% sufficient, and unused columns are removed at the end.
linkedVertices  = zeros(size(vertices), 'like',vertices);
linkedStripData = zeros(size(stripData),'like',stripData);

% Trace each open curve, merging its parts. The k-th curve is open if
% prev(k) == 0.  We complete a new part when we've reached an old part
% for which the corresponding element of next is 0.

n = 1;  % Track which column we've reached in the output.
p = 1;  % Track which new part we're assembling.
linkedStripData(p) = n;
for k = find(prev == 0)
    j = k;
    while j > 0 && ~traced(j)
        % Copy the j-th part into the output.
        s = first(j);
        e = last(j);
        m = n + e - s;
        linkedVertices(:,n:m) = vertices(:,s:e);
        n = m;
        traced(j) = true;
        j = next(j);
    end
    % No more parts to add: Advance n by to start a new output part, and
    % augment the output line strip data to indicate the termination of the
    % new part.
    n = n + 1;
    p = p + 1;
    linkedStripData(p) = n;
end

% Trace the remaining curves, which we expect to be closed. We're complete
% a new part when we reach an old part whose index equals the starting
% index.

for k = find(prev > 0 & ~traced)
    if ~traced(k)
        j = k;
        while j > 0 && ~traced(j)
            % Copy the j-th part into the output.
            s = first(j);
            e = last(j);
            m = n + e - s;
            linkedVertices(:,n:m) = vertices(:,s:e);
            n = m;
            traced(j) = true;
            j = next(j);
        end
        % No more parts to add: Advance n by to start a new output part, and
        % augment the output line strip data to indicate the termination of the
        % new part.
        n = n + 1;
        p = p + 1;
        linkedStripData(p) = n;
    end
end

% Remove unused columns left over from the pre-allocation step.
linkedVertices(:,n:end) = [];
linkedStripData(p+1:end) = [];

%--------------------------------------------------------------------------

function [prev, next, first, last] = sequenceStripParts(vertices, stripData)
% Determine the numbers of the parts preceding (prev) and following (next)
% a given part. prev(k) is the number of the part preceding the k-th part,
% or zero is there is no preceding part. Likewise, next(k) is the number of
% the part following the k-th part, or zero is there is no following part.
%
% When prev(k) == 0, the k-th part is the first part of an open curve.
% When next(k) == 0, the k-th part is the last part of an open curve.
% When prev(k) > 0 && next(k) > 0, the k-th part is either (a) an interior
% part of an open curve or (b) part of a closed curve.
%
% first(k) is the column number of the first vertex of the k-th part in the
% vertices array. Likewise, last(k) is the column number of the last vertex
% of the k-th part in the vertices array.
%
% All four output have size 1-by-m where m is the number of parts.
% Note that m == stripData(end) - 1.

first = stripData(1:end-1);
last  = stripData(2:end) - 1;

xFirst = vertices(1,first);
xLast  = vertices(1,last);

yFirst = vertices(2,first);
yLast  = vertices(2,last);

[yFirst, iFirst] = sort(yFirst);
[yLast,  iLast]  = sort(yLast);

xFirst = xFirst(iFirst);
xLast = xLast(iLast);

m = length(first);

% Find subsequences of yLast (sorted) in which the Y-coordinates are the same
indx = find(diff(yLast) > 0);
syLast = [1, 1 + indx];
eyLast = [indx, m];
vyLast = yLast(syLast);

% Find subsequences of yFirst (sorted) in which the Y-coordinates are the same
indx = find(diff(yFirst) > 0);
syFirst = [1, 1 + indx];
eyFirst = [indx, m];
vyFirst = yFirst(syFirst);

next = zeros(1,m,'uint32');
prev = next;

% Use a sweep line approach: Pass through each unique value of Y among the
% first and last points of each strip part. On each pass, sort in X and
% identify first-last vertex pairings.
kyLast = 1;
kyFirst = 1;
while kyLast <= length(syLast) && kyFirst <= length(syFirst)
    if vyLast(kyLast) < vyFirst(kyFirst)
        % There's a last Y for which there is no first Y.
        kyLast = kyLast + 1;
    elseif vyFirst(kyFirst) < vyLast(kyLast)
        % There's a first Y for which there is no last Y.
        kyFirst = kyFirst + 1;
    else
        % The first and last Y-coordinates match; now match them in X.
        jLast  = syLast(kyLast)  :  eyLast(kyLast);
        jFirst = syFirst(kyFirst) : eyFirst(kyFirst);
        
        [jLast, jFirst] = matchFirstAndLastX(jLast, jFirst, xLast, xFirst);

        % Augment lists of accumulated previous-next pairs.
        p = iLast(jLast);
        n = iFirst(jFirst);
        
        next(p) = n;
        prev(n) = p;
        
        % Advance to the next unique y-value in both
        % of the sorted lists of first and last Y.
        kyLast = kyLast + 1;
        kyFirst = kyFirst + 1;
    end
end

%--------------------------------------------------------------------------

function [jLast, jFirst] = matchFirstAndLastX(jLast, jFirst, xLast, xFirst)
% Order the elements of jLast and jFirst for which the X-coordinate is the
% same, returning them as paired lists. Elements for which a given xLast is
% not matched by a corresponding xFirst are removed.

xLast = xLast(jLast);
xFirst = xFirst(jFirst);

[xLast, iLast] = sort(xLast);
[xFirst, iFirst] = sort(xFirst);

if ~isequal(xLast,xFirst)
    [iLast, iFirst] = removeUniqueElements(iLast, iFirst, xLast, xFirst);
end

jLast = jLast(iLast);
jFirst = jFirst(iFirst);

%--------------------------------------------------------------------------

function [iLast, iFirst] = removeUniqueElements(iLast, iFirst, xLast, xFirst)
% Remove elements in xLast that do not have a match in xFirst and vice versa.

[qLast, locFirst] = ismember(xLast, xFirst);
locFirst(locFirst == 0) = [];

iLast(~qLast) = [];
iFirst = iFirst(locFirst);
