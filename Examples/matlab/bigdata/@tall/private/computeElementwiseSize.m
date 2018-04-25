function out = computeElementwiseSize(out, in)
% Try to set the sizes of the outputs given a set of inputs. IN must be a
% cell array, OUT can be one array or a cell array of arrays.

% Copyright 2016-2017 The MathWorks, Inc.

cellOut = iscell(out);
if ~cellOut
    out = {out};
end


if numel(in)==1
    % Unary, so the first input must be tall and we can copy the size to all outputs.
    for idx = 1:numel(out)
        out{idx}.Adaptor = copySizeInformation(out{idx}.Adaptor, in{1}.Adaptor);
    end
    if ~cellOut
        out = out{1};
    end
    return;
end

% For all other cases, we need to combine results from multiple input
% adaptors. Ignore broadcast inputs since these do not contribute to the size
% computation.
isInputBroadcast = cellfun(@(x) isa(x, 'matlab.bigdata.internal.BroadcastArray'), in);
inAdaptors = cellfun(@matlab.bigdata.internal.adaptors.getAdaptor, ...
    in(~isInputBroadcast), 'UniformOutput', false);

% Tall dimension is special. Even if unknown, we would like to propagate
% whether it is preserved so that if we later discover the size it will
% become known.
tallSize = cellfun(@(x) x.getSizeInDim(1), inAdaptors);
unknownTallSizes = isnan(tallSize);
if any(unknownTallSizes)
    % At least one is unknown. We can only propagate if the unknown ones
    % are all the same unknown size and the rest are unit.
    inIdx = find(unknownTallSizes,1,'first');
    tallSizeIds = cellfun( @(x) x.TallSize.Id, inAdaptors );
    if all(tallSize(~unknownTallSizes))==1 ...
            && all(tallSizeIds(unknownTallSizes) == tallSizeIds(inIdx))
        % Propagate tall size
        for outIdx = 1:numel(out)
            out{outIdx}.Adaptor = copyTallSize(out{outIdx}.Adaptor, inAdaptors{inIdx});
        end
    end
    
else
    % All sizes known. Check they are compatible and if so, propagate the
    % non-unit one.
    [~,inIdx] = iCheckOneDim(tallSize);
    if inIdx>0 % Will be zero if incompatible
        for outIdx = 1:numel(out)
            out{outIdx}.Adaptor = copyTallSize(out{outIdx}.Adaptor, inAdaptors{inIdx});
        end
    end
    
end

% Now deal with the small sizes

% If any input has an unknown number of dimensions, the best we can do is
% try to determine the tall size, since the small sizes will be unknown.
ndims = cellfun(@(x) x.NDims, inAdaptors);
if any(isnan(ndims))
    % Unknown dimensionality, nothing more we can do.
    
else
    ndims = max(ndims);
    % We allow unity dimension expansion, so can build up dimensions
    % one-by-one.
    localSz = nan(1,ndims-1);
    for dim=2:ndims
        thisDim = cellfun(@(x) getSizeInDim(x,dim), inAdaptors);
        localSz(dim-1) = iCheckOneDim(thisDim);
    end
    % If any dimension was incompatible, we get a NaN. In that case, leave the
    % dimensions unknown. If all OK, set the small sizes of the output.
    if ~any(isnan(localSz))
        for outIdx = 1:numel(out)
            out{outIdx}.Adaptor = setSmallSizes(out{outIdx}.Adaptor, localSz);
        end
    end
    
end

if ~cellOut
    out = out{1};
end

end

function [dim,idx] = iCheckOneDim(dims)
% Determine the output size given a set of input sizes in one dimension. To
% be compatible, all sizes must be known and must match or be 1.
dim = nan; % Default to "unknown"
idx = 0;
if any(isnan(dims))
    return;
end

% Find the first non-zero value
idx = find(dims~=1, 1, 'first');
if isempty(idx)
    % All one
    idx = 1;
    dim = 1;
    return
end

% Compare values. Only set the output if they are all compatible.
allowedVals = [1, dims(idx)];
if all(ismember(dims, allowedVals))
    dim = dims(idx);
end
end
