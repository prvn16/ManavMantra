function out = getArrayMetadata(t, fcn)
%getArrayMetadata return array metadata that is the same everywhere
%   OUT = getArrayMetadata(T, FCN) returns in OUT the result of calling FCN on
%   the underlying data of T. FCN must return the same scalar output for
%   each partition.
%

% Copyright 2016-2017 The MathWorks, Inc.

opts = matlab.bigdata.internal.PartitionedArrayOptions();
opts.PassTaggedInputs = true;
[outPerPartition, isUnknown] = partitionfun(opts, @(info, x) iCallPerPartition(info.IsLastChunk, x, fcn), t);
[out, ~]                     = reducefun(@iSelectFirstWithCheck, outPerPartition, isUnknown);
out                          = clientfun(@(c) c{1}, out);
% The framework will assume out is partition dependent because it is
% derived from partitionfun. It is not, so we must correct this.
out = copyPartitionIndependence(out, t);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enforce the fact that the metadata must be identical from each partition.
function [out, isUnknown] = iSelectFirstWithCheck(in, isUnknown)
if isempty(in)
    out = in;
    return;
end
if any(isUnknown) && any(~isUnknown)
    in(isUnknown) = [];
    isUnknown(isUnknown) = [];
end
out = in(1);
isUnknown = isUnknown(1);
assert(all(arrayfun(@(x) isequaln(x, out), in(2:end))));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hasFinished, out, isUnknown] = iCallPerPartition(hasFinished, data, fcn)
% If any chunk is an unknown empty chunk, ignore it if we can. The only
% time we can't do that is the very last chunk, in which case we output
% that this result came from an unknown.
isUnknown = false;
if matlab.bigdata.internal.TaggedArray.isTagged(data)
    isUnknown = matlab.bigdata.internal.UnknownEmptyArray.isUnknown(data);
    if isUnknown && ~hasFinished
        out = cell(0, 1);
        isUnknown = false(0, 1);
        return;
    end
    data = getUnderlying(data);
end
out = {fcn(data)};
hasFinished = true;
end
