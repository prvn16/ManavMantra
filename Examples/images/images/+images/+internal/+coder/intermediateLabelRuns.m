function [startRow,endRow,startCol,labelForEachRun,numRuns] = intermediateLabelRuns(BW,mode) %#codegen
%intermediateLabelRuns is used by bwlabel and bwconncomp for code generation.  
%   The inputs are a 2D binary image BW and the connectivity MODE. There is no
%   error checking in this code. BW must be a 2D binary image and MODE must
%   be 4 or 8. The variable labelForEachRun is the initial labels for each 
%   run. However, some labels may be equivalent to one another. Also, the 
%   labels are not guaranteed to be consecutive. They need further
%   processing in the clients bwlabel and bwconncomp to make the labels 
%   consecutive and resolve label equivalence. 
%       
%   The outputs are:
%   startRow        - starting Row subscript of the run.
%   endRow          - last Row subscript of the run.
%   startCol        - starting Col of the run.
%   labelForEachRun - initial label associated with each run.
%   numRuns         - number of Connected Components in BW.
%
%   sr, er, c, and labelForEachRun are vectors of the same size.

% Copyright 2015-2017 The MathWorks, Inc.

coder.inline('always');
coder.internal.prefer_const(mode);

validateattributes(BW, {'logical' 'numeric'}, {'2d', 'real', 'nonsparse'}, ...
    mfilename, 'BW', 1);

coder.internal.errorIf(~eml_is_const(mode), ...
    'MATLAB:images:validate:codegenInputNotConst','mode');
coder.internal.errorIf(~((mode(1) == 4) || (mode(1) == 8)), ...
    'images:validate:codegenUnsupportedConn');

numRuns = numberOfRuns(BW);

% Early return when the image contains no connected components.
if numRuns == 0
    startRow = zeros(numRuns,1,coder.internal.indexIntClass());
    endRow = zeros(numRuns,1,coder.internal.indexIntClass());
    startCol  = zeros(numRuns,1,coder.internal.indexIntClass());
    labelForEachRun = zeros(numRuns,1,coder.internal.indexIntClass());
    numRuns = coder.internal.indexInt(0);
    return;
end

% The variables, sr, er and c describe each run in the image. For each run,
% sr contains the starting row of the run, er contains the ending row of 
% the run and c contains the starting column of the run
startRow = coder.nullcopy(zeros(numRuns,1,coder.internal.indexIntClass()));
endRow = coder.nullcopy(zeros(numRuns,1,coder.internal.indexIntClass()));
startCol  = coder.nullcopy(zeros(numRuns,1,coder.internal.indexIntClass()));
[startRow,endRow,startCol] = fillRunVectors(BW,startRow,endRow,startCol);

% Create as many labels as there are runs. Intialize them to zero to 
% indicate unlabeled runs.
labelForEachRun = zeros(numRuns,1,coder.internal.indexIntClass());

% Connectivity
if (mode(1) == 8)
    % The offset value is used in the overlap test below.
    offset = coder.internal.indexInt(1);
else
    offset = coder.internal.indexInt(0);
end

% Initialize variables
k = coder.internal.indexInt(1);
currentColumn = coder.internal.indexInt(k);
nextLabel = coder.internal.indexInt(1);
firstRunOnPreviousColumn = coder.internal.indexInt(-1);
lastRunOnPreviousColumn = coder.internal.indexInt(-1);
firstRunOnThisColumn = coder.internal.indexInt(1);

while (k <= numRuns)
    % Process k-th run
    if (startCol(k) == (currentColumn + 1))
        % We are starting a new column adjacent to previous column
        firstRunOnPreviousColumn = firstRunOnThisColumn;
        firstRunOnThisColumn = k;
        lastRunOnPreviousColumn = k-1;
        currentColumn = startCol(k);
    elseif (startCol(k) > (currentColumn + 1))
        % We are starting a new column not adjacent to previous column
        firstRunOnPreviousColumn = coder.internal.indexInt(-1);
        lastRunOnPreviousColumn = coder.internal.indexInt(-1);
        firstRunOnThisColumn = k;
        currentColumn = startCol(k);
    else
        % Not changing columns; nothing to do here
    end
    
    if (firstRunOnPreviousColumn >= 0)
        % Look for overlaps on previous column
        p = firstRunOnPreviousColumn;
        while ((p <= lastRunOnPreviousColumn))
            if ((endRow(k) >= (startRow(p)-offset)) && (startRow(k) <= (endRow(p)+offset)))
                % We've got an overlap; it's 4-connected or 8-connected
                % depending on the value of offset.
                
                if (labelForEachRun(k) == 0)
                    % This run hasn't yet been labeled;
                    % copy over the label of the overlapping run from the 
                    % previous column.                    
                    labelForEachRun(k) = labelForEachRun(p);
                    % Increment label number so that it matches the index
                    % of this run.
                    nextLabel = nextLabel + 1;
                else
                    if (labelForEachRun(k) ~= labelForEachRun(p))
                        % This run and the overlapping run
                        % have been labeled with different
                        % labels. Resolve the label collison and record 
                        % the equivalence.
                        
                        labelForEachRun = uf_new_pair(labelForEachRun, k, p);
                        
                    else
                        % This run and the overlapping run
                        % have been labeled with the same label;
                        % nothing to do here.
                    end
                    
                end
            else
                % No overlaps on previous column. Do nothing.
            end
            p = p + 1;
        end
    end
    
    if (labelForEachRun(k) == 0)
        % This run hasn't yet been labeled because we
        % didn't find any overlapping runs.  Label it
        % with a new label.
        labelForEachRun(k) = nextLabel;
        nextLabel = nextLabel + 1;
    end
    
    k = k + 1;
end


function labels = uf_new_pair(labels, k, p)
% Resolve label collision between the current run, k and overlapping run 
% from previous column, p 

coder.inline('always');
coder.internal.prefer_const(labels, k, p);

[labels, root_k] = uf_find_root(labels, k);
[labels, root_p] = uf_find_root(labels, p);
if (root_k ~= root_p)
    % k and p belong to two disjoint sets
    labels = uf_union(labels, root_k, root_p, k, p);
end

function labels = uf_union(labels, root_k, root_p, k, p)
% Compute union of labels of the current run, k and overlapping run from 
% previous column, p. Assign the label with the lower value to the run and 
% its parent i.e. make the run with the lower label value the parent of the
% other run and its parent.

coder.inline('always');
coder.internal.prefer_const(labels, root_k, root_p, k, p);

% Assign the lower label
if root_p < root_k
    labels(root_k) = root_p;
    labels(k) = root_p;
else
    labels(root_p) = root_k;
    labels(p) = root_k;
end

function [labels, node] = uf_find_root(labels, node)
% Return the root of the set that node belongs to
% Compress the tree as we go along

coder.inline('always');
coder.internal.prefer_const(labels, node);

while (node ~= labels(node)) % while node is not the root
    labels(node) = labels(labels(node)); % move node up in the tree
    node = labels(node);
end

function result = numberOfRuns(im)
%Scan the input array, counting the number of runs present.

coder.inline('always');
coder.internal.prefer_const(im);

result = coder.internal.indexInt(0);

[M, N] = size(im);

if ((M ~= 0) && (N ~= 0) )
    for col = 1:N
        if (im(1,col) ~= 0)
            result = result + 1;
        end
        
        % Columnwise count of all 0 to 1 transitions 
        for k = 2:M
            if ((im(k,col) ~= 0) && (im(k-1,col) == 0))
                result = result + 1;
            end
        end
    end
end

function [sr,er,c] = fillRunVectors(im,sr,er,c)
% Scan the array, recording start row, end row, and column information
% about each run.  The calling function must allocate sufficient space
% for sr, er, and c.

coder.inline('always');
coder.internal.prefer_const(im,sr,er,c);

[M,N] = size(im);


runCounter = coder.internal.indexInt(1);

for col = 1:N
    row = coder.internal.indexInt(1);
    while (row <= M)
        % Look for the next run.
        while ((row <= M) && (im(row,col) == 0))
            row = row + 1;
        end
        
        if ((row <= M) && (im(row,col) ~= 0))
            c(runCounter) = col;
            sr(runCounter) = row;
            while ((row <= M) && (im(row,col) ~= 0))
                row = row + 1;
            end
            er(runCounter) = row-1;
            runCounter = runCounter + 1;
        end
    end
end
