function tb = countcats(ta,dim)
%COUNTCATS Count occurrences of categories in a tall categorical array's elements.
%   C = COUNTCATS(A)
%   C = COUNTCATS(A,DIM)
%
%   See also CATEGORICAL/COUNTCATS.

%   Copyright 2016-2017 The MathWorks, Inc.

% First argument must be categorical
ta = tall.validateType(ta, mfilename, {'categorical'}, 1);

if nargin < 2
    aggregateFcn = @(chunk, dim) chunkCountcats(chunk, dim);
    reduceFcn = @(chunk, dim) updateCountcats(chunk, dim);
    tmpCell = tall(reduceInDefaultDim({aggregateFcn, reduceFcn}, ta));
    tb = clientfun(@(c) c{1}, tmpCell);
else
    tall.checkNotTall(upper(mfilename), 1, dim);
    if isequal(dim, 1)
       aggregateFcn = @(chunk) chunkCountcats(chunk, dim);
       reduceFcn = @(chunk) updateCountcats(chunk, dim);
       tmpCell = aggregatefun(aggregateFcn,reduceFcn,ta);
       tb = clientfun(@(c) c{1}, tmpCell);
    else
       tb = slicefun(@(x)countcats(x,dim),ta);
    end
end
tb = setKnownType(tb, 'double');
end

function outCell = chunkCountcats(X, dim)
% Put result in cell to allow different way to combine results.
outCell = {countcats(X,dim)};
end

function outCell = updateCountcats(inCell, ~)
% Note: Second input dim is not used.
if size(inCell,1) == 1
    outCell = inCell;
else
    if isequal(size(inCell{1}), size(inCell{2}))
       % When dim is equal to the tall dimension, countcats for each
       % partition will return arrays of the same size. Adding the two
       % arrays together to get the overall counts.
       outCell = {inCell{1} + inCell{2}};
    else
       % When dim is not the tall dimension, only one partition would
       % have the correct answer. All other partition would returns empty
       % array. Combine the results using concatenation.
       outCell = {cat(1, inCell{:})};
    end
end
end

