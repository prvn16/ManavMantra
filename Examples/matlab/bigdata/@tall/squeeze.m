function b = squeeze(a)
%SQUEEZE Remove singleton dimensions.
%   B = SQUEEZE(A) returns an array B with the same elements as
%   A but with all the singleton dimensions removed.
%
%   See also tall/cat.

% Copyright 2015-2017 The MathWorks, Inc.

if ~isnan(a.Adaptor.NDims) && a.Adaptor.NDims<=2
    % Nothing to squeeze as already 2-d
    b = a;
    return;
end

% Check for known sizes
if isTallSizeGuaranteedNonUnity(a.Adaptor)
    % First dimension not 1 so can be done slice-wise
    b = slicefun(@iSqueezeSmallDims, a);
    
elseif isSizeKnown(a.Adaptor,1) && getSizeInDim(a.Adaptor,1)==1
    % First dimension is known to be 1. We know this should fit in
    % memory, so just execute on the client.
    b = clientfun(@squeeze, a);
    
else
    % TODO (g1475231): switch to ternaryfun once it can handle clientfun
    % We don't know if the tall dimension needs squeezing. Use
    % ternaryfun to decide at execution time.
    %     b = ternaryfun( size(a, 1) == 1, ...
    %         clientfun(@squeeze, a), ...
    %         slicefun(@iSqueezeSmallDims, a) );

    % For now use a chunkfun to work out which case we have
    tf = (size(a, 1) == 1);
    b = chunkfun(@iPickWhich, a, tf);
    
end

% In each of these cases the output has the same type as the input, so make
% the output adaptor the same as the input but with updated size.
b.Adaptor = copySizeInformation(a.Adaptor, b.Adaptor);

end


function b = iPickWhich(a, globalTallSizeIsUnity)
if globalTallSizeIsUnity
    % Overall array is size one in tall dimension, but we need to be
    % careful if this chunk is empty since squeezing the chunk won't work.
    if size(a,1)==0
        % Need to work out the small dimensions. Use a fake array.
        b = reshape(a, iGetSqueezedEmptySize(size(a)));
    else
        b = squeeze(a);
    end
else
    b = iSqueezeSmallDims(a);
end
end


function sz = iGetSqueezedEmptySize(sz)
% Work out the squeezed dimensions for an empty chunk where the overall
% tall dimension is 1.
sz(1) = 1;
dummy = squeeze(zeros(sz));
sz = size(dummy);
sz(1) = 0;
end

function a = iSqueezeSmallDims(a)
if iscolumn(a)
    return;
end
siz = size(a);
siz([false (siz(2:end) == 1)]) = []; % Remove singleton dimensions.
a = reshape(a,siz);
end

