function out = computeSlicewiseSize(out, args)
%computeSlicewiseSize Compute the size of the result of a slicewise operation
%   OUT = computeSlicewiseSize(OUT, ARGS) updates the adaptors for tall array or
%   cell of tall arrays OUT based on tall (or non-tall) ARGS (must be cell).

% Copyright 2016 The MathWorks, Inc.

outIsCell = iscell(out);
if ~outIsCell
    out = {out};
end

% In a slicewise operation, the only thing we can possibly preserve is the tall
% size, and we can do this only when all args are tall with the same tall
% size.

% Start by disregarding non-tall elements of args if they are size 1 in
% the tall dimension.
isNonTallSz1InTallDim = cellfun(@(x) ~istall(x) && size(x, 1) == 1, args);
args(isNonTallSz1InTallDim) = [];

% We can only continue if we have only tall arrays remaining.
if all(cellfun(@istall, args))
    argAdaptors = cellfun(@hGetAdaptor, args, 'UniformOutput', false);
    tallSizes   = cellfun(@(x) getSizeInDim(x, 1), argAdaptors);
    tallSizeIds = cellfun(@(x) x.TallSizeId, argAdaptors);

    % If the tall sizes are all the same and non-NaN, then we can simply use
    % that. Otherwise, if the tallSizeIds are all the same, we can propagate
    % that. Else, do nothing.
    if ~any(isnan(tallSizes)) && isscalar(unique(tallSizes))
        for idx = 1:numel(out)
            out{idx}.Adaptor = setSizeInDim(out{idx}.Adaptor, 1, tallSizes(1));
        end
    elseif isscalar(unique(tallSizeIds))
        for idx = 1:numel(out)
            out{idx}.Adaptor = copyTallSize(out{idx}.Adaptor, argAdaptors{1});
        end
    end
end

if ~outIsCell
    out = out{1};
end
end
