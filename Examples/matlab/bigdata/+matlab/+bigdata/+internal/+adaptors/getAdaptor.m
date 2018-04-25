function out = getAdaptor(localValue)
%getAdaptor Get appropriate adaptor for a local value.
%   A = getAdaptor(X) returns an adaptor appropriate to the local value X, with
%   the tall size left in the 'unknown' state.
%
%   A = getAdaptor(T) for tall T returns T's Adaptor.

%   Copyright 2016-2017 The MathWorks, Inc.

if istall(localValue)
    out = hGetAdaptor(localValue);
elseif isa(localValue, 'matlab.bigdata.internal.BroadcastArray')
    % Unfortunately, for BroadcastArrays, we have lost all size and type
    % information.
    assert(false, 'Cannot get adaptor for BroadcastArray.');
else
    typeName = class(localValue);
    switch typeName
        case 'table'
            out = matlab.bigdata.internal.adaptors.TableAdaptor(localValue);
        case 'timetable'
            out = matlab.bigdata.internal.adaptors.TimetableAdaptor(localValue);
        case {'datetime','duration','calendarDuration'}
            out = matlab.bigdata.internal.adaptors.DatetimeFamilyAdaptor(localValue);
        case {'categorical'}
            out = matlab.bigdata.internal.adaptors.CategoricalAdaptor(localValue);
        otherwise
            % All other types can be deduced from the typename alone, so
            % don't duplicate the logic here.
            out = matlab.bigdata.internal.adaptors.getAdaptorForType(typeName);
            % Make sure we don't try to make a tall sparse
            if issparse(localValue)
                error(message('MATLAB:bigdata:array:SparseNotAllowed'));
            end
    end
    out = setKnownSize(out, size(localValue));
end
end
