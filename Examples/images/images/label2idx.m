function pixelIdxList = label2idx(L) %#codegen
% Convert label matrix to cell array of linear indices
%   pixelIndexList = label2idx(L) converts the regions described by the
%   label matrix L into a 1xN cell array, pixelIndexList. Each element of the
%   output, pixelIndexList{N}, is a vector that contains all the linear
%   indices in L where L == N.
%
%   Examples
%   --------
%   L = [1 2; 2 3]
%   pixelIndexList = label2idx(L)
%
%   See also bwconncomp, labelmatrix, superpixels.

% Copyright 2015-2017 The MathWorks, Inc.

validateattributes(L,images.internal.iptnumerictypes,...
    {'nonsparse','real','nonempty'},mfilename,'L',1)

if coder.isColumnMajor || (coder.isRowMajor && numel(size(L)>2))
    N = max(L(:));
else % coder.isRowMajor and L is 2-D    
    N = max(max(L,[],2),[],1);
end

% Do a minimum amount of validation on the max(L(:)). We can do this
% cheaply without an O(N) scan of L and we can provide a helpful error
% message.
coder.internal.errorIf(~isfinite(N) || (round(N)~=N) || (N < 0),...
    'images:label2idx:invalidLabelMatrix');

if coder.target('MATLAB')
    pixelIdxList = label2idxmex(L,double(N));
else
    pixelIdxList = label2idxTwoPass(L,N);
end


function pixelIdxList = label2idxTwoPass(L,N)

pixelIdxList = coder.nullcopy(cell(1,N));

% Pass 1, compute counts of each label value in label matrix
counts = zeros(1,N);
if coder.isColumnMajor || (coder.isRowMajor && numel(size(L)>2))
    for idx = 1:numel(L)
        lbl = L(idx);
        if (lbl >= 1)
            lbl = coder.internal.indexInt(lbl);
            counts(lbl) = counts(lbl)+1;
        end
    end    
else % coder.isRowMajor and L is 2-D
    for p = 1:size(L,1)
        for q = 1:size(L,2)
            lbl = L(p,q);
            if (lbl >= 1)
                lbl = coder.internal.indexInt(lbl);
                counts(lbl) = counts(lbl)+1;
            end
        end
    end
end

% Pre-allocate each cell of cell array to the correct length
for label = 1:N
    pixelIdxList{label} = coder.nullcopy(zeros(counts(label),1));
end

% Pass 2, populate each cell of cell array with linear indices
currentCounts = zeros(1,N);
if coder.isColumnMajor || (coder.isRowMajor && numel(size(L)>2))
    for idx = 1:numel(L)
        label = L(idx);
        if label >= 1
            label = coder.internal.indexInt(label);
            pixelIdxList{label}(currentCounts(label)+1) = idx;
            currentCounts(label) = currentCounts(label)+1;
        end
    end
else % coder.isRowMajor and L is 2-D
    % idxRow and idx are both linear indices of L traversed along columns.
    % The difference is that they are incremented differently.
    idxRow = coder.internal.indexInt(1);
    idx = coder.internal.indexInt(1);
    for p = 1:size(L,1)
        for q = 1:size(L,2)
            label = L(p,q);
            if label >= 1
                label = coder.internal.indexInt(label);
                pixelIdxList{label}(currentCounts(label)+1) = idxRow;
                currentCounts(label) = currentCounts(label)+1;
            end
            % idxRow is the linear index of elements in L. It is
            % incremented by number of rows in the label matrix because we
            % are traversing along rows.
            idxRow = coder.internal.indexPlus(idxRow,size(L,1));
        end
        % idx is the linear index of elements in L traversed along columns.
        % It is incremented after each row is fully traversed. idxRow is
        % reset to idx after each row traversal.
        idx = coder.internal.indexPlus(idx,1);
        idxRow = idx;
    end
    
    % Sort the indices to match column-major output
    for label = 1:N
        pixelIdxList{label} = sort(pixelIdxList{label});
    end
end


