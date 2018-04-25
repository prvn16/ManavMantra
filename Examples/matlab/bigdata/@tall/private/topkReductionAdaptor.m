function outAdap = topkReductionAdaptor(tx, k, dim)
% topkReductionAdaptor  Determine the output adaptor for topkrows, mink,
% and maxk reductions, where:
%
%    TX is the tall input that the k-reduction is operating on
%    K is the number of elements to reduce to
%    DIM is the reduction dimension
%
% For example, when reducing in the tall dimension:
%
% If we know that the input has at least k rows, we know the output has k.
% Equally if we know that the input has fewer than k rows the size is
% unmodified. If we can't deduce either we set it to unknown.

% Copyright 2017 The MathWorks, Inc.

% Start by copying the entire adaptor from input to output.  This is done
% to preserve type and any non-reduced sizes that may be known.
outAdap = tx.Adaptor;

if dim == 1
    % Default to unknown tall size when reducing in the tall dimension
    outAdap = resetTallSize(outAdap);
end

k = double(k); % Adaptors can't cope with non-double size

sizeInDim = getSizeInDim(tx.Adaptor, dim);
if ~isnan(sizeInDim)
    % We know the size in the reduced dimension which makes it simple
    % to derive the output size.
    sizeInDim = min(sizeInDim,k);
    outAdap = setSizeInDim(outAdap, dim, sizeInDim);
    return;
end

% Might be able to work out from preview
arrayInfo = matlab.bigdata.internal.util.getArrayInfo(tx);
if arrayInfo.IsPreviewAvailable
    previewSz = size(arrayInfo.PreviewData);
    
    if dim == 1
        if previewSz(dim)>=k
            % Tall size reduced to k
            outAdap = setSizeInDim(outAdap, dim, k);
        else
            % Preview doesn't have enough rows. Need to work out if that is
            % because the array is too small or the preview just doesn't
            % have the data.
            if ~arrayInfo.IsPreviewTruncated
                % Data is small
                outAdap = setTallSize(outAdap, previewSz(1));
            end
        end
    elseif dim <= numel(previewSz)
        % Small-dim reduction size can always be determined
        outAdap = setSizeInDim(outAdap, dim, min(previewSz(dim), k));
    end
end
end