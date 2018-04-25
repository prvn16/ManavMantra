function outAdap = computeReducedSize(outAdap, origAdap, reductionDim, canLeaveEmpty)
% Update size information for the output of a reduction given the input
% adaptor and reduction dimension.
%
% canLeaveEmpty specifies whether a zero dimension should be left empty
% (true) or set to 1 (false). For example, MIN, MAX, set this true, SUM,
% PROD set it false.

% Copyright 2016 The MathWorks, Inc.

% For safety, assume the output size is unknown until we can prove otherwise
outAdap = resetSizeInformation(outAdap);

if isempty(reductionDim)
    % Can't do much if we don't know what was reduced!
    return
end

if ~isnumeric(reductionDim) || ~isscalar(reductionDim) || ~isreal(reductionDim) ...
        || ~isfinite(reductionDim) || reductionDim<1 || reductionDim~=round(reductionDim)
    % If the dimension is invalid, just ignore it so that the lazy
    % operation can throw the correct error.
    return
end


% Work out the size in dimUsed after reduction.
reducedSize = 1;
if canLeaveEmpty 
    % If canLeaveEmpty is true, we need to know the original size in the reduction
    % dimension - if it's definitely non-empty, then we can proceed, otherwise
    % we must abort.
    if reductionDim == 1
        if ~origAdap.isTallSizeGuaranteedNonZero()
            % Can't guarantee tall size is non-empty, return
            return
        else
            % Non-empty in tall dimension, OK to leave reducedSize as 1.
        end
    else
        if ~origAdap.isSizeKnown(reductionDim)
            return
        end
        if origAdap.getSizeInDim(reductionDim) == 0
            reducedSize = 0;
        end
    end
end

% If we've got this far then we know the dimension used and its final size.
% Copy the input size and reset the reduction dimension.
outAdap = copySizeInformation(outAdap, origAdap);
outAdap = outAdap.setSizeInDim(reductionDim, reducedSize);

end
