function data = unpackValueImpls(data)
%unpackValueImpls Unpack ValueImpl fields from tall instances

%   Copyright 2015-2017 The MathWorks, Inc.

for idx = 1:numel(data)
    if istall(data{idx})
        data{idx} = iGetValueImplWithAssertion(data{idx});
    elseif isa(data{idx}, 'matlab.bigdata.internal.LocalArray') ...
            || isa(data{idx}, 'matlab.bigdata.internal.BroadcastArray')
        % Do nothing as these are already internal types.
    else
        % Put non-tall arrays into a wrapper so that they don't affect
        % method dispatch.
        data{idx} = matlab.bigdata.internal.LocalArray(data{idx});
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the underlying partitioned array, along with a lazy assertion
function pa = iGetValueImplWithAssertion(data)

pa = data.ValueImpl;
adaptor = data.Adaptor;

pa = elementfun(@(x) iAssertAdaptorInfoCorrect(x, adaptor), pa);
% Copy across the metadata
hSetMetadata(pa, hGetMetadata(data.ValueImpl));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lazy assertion that the adaptor information is correct
function x = iAssertAdaptorInfoCorrect(x, adaptor)

assertionFmtPrefix = 'An internal consistency error occurred. Details:\n';

if ~isnan(adaptor.NDims)
    assert(ndims(x) == adaptor.NDims, ...
           [assertionFmtPrefix, ...
            '  NDIMS of output incorrect. Expected: %d, actual: %d.'], ...
           adaptor.NDims, ndims(x));
end

% Compare known elements of size, ignoring tall size.
chunkSz = size(x);
expSz   = adaptor.Size;
if ~isempty(expSz)
    chunkSz(isnan(expSz)) = NaN;
    if ~isequaln(chunkSz(2:end), expSz(2:end))
        assert(false, ...
            [assertionFmtPrefix, ...
            '  SIZE of output incorrect. Expected: [%s], actual: [%s].'], ...
            num2str(expSz), num2str(chunkSz));
    end
end

expectedClass = adaptor.Class;
actualClass   = class(x);
if isempty(expectedClass)
    assert(~ismember(actualClass, matlab.bigdata.internal.adaptors.getStrongTypes()), ...
           'MATLAB:bigdata:array:AssertStrongType', ...
           [assertionFmtPrefix, ...
            '  Class of output unexpectedly not known. Actual class: %s'], ...
           actualClass);
else
    assert(isequal(expectedClass, actualClass), ...
           'MATLAB:bigdata:array:AssertStrongType', ...
           [assertionFmtPrefix, ...
            '  Class of output incorrect. Expected: %s, actual: %s.'], ...
           expectedClass, actualClass);
end
end
