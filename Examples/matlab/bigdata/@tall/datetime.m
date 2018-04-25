function d = datetime(arg1, varargin)
%DATETIME create tall array of datetime from tall arrays
%   D = DATETIME(DS,'InputFormat',INFMT)
%   D = DATETIME(DS,'InputFormat',INFMT,'Locale',LOCALE)
%   D = DATETIME(DS,'InputFormat',INFMT,'PivotYear',PIVOT,...)
%   D = DATETIME(DV)
%   D = DATETIME(Y,MO,D,H,MI,S)
%   D = DATETIME(Y,MO,D)
%   D = DATETIME(Y,MO,D,H,MI,S,MS)
%   D = DATETIME(X,'ConvertFrom',TYPE)
%   D = DATETIME(X,'ConvertFrom','epochtime','Epoch',EPOCH)
%   D = DATETIME(...,'Format',FMT)
%   D = DATETIME(...,'TimeZone',TZ,...)
%
%   Limitations:
%   1. When creating DATETIME from the strings in the cell array DS,
%      always specify the input format INFMT, for correctness.
%   2. Specifying FMT as 'preserveinput' may require the tall array to be
%      evaluated to determine the format.
%
%   See also DATETIME.
        
%   Copyright 2015-2017 The MathWorks, Inc.

% At least validate the first argument
arg1 = tall.validateType(arg1, mfilename, {'numeric', 'cellstr', 'string'}, 1);
outAdap = iGetAdaptor(arg1, varargin{:});

% The workers may be in a different country than the client, so we must
% impose the client TimeZone and Format from.

d = slicefun(@(varargin) iMakeDatetime(outAdap.TimeZone, outAdap.Format, varargin{:}), ...
    arg1, varargin{:});

% The output adaptor should be the same as the prototype but with size from
% the slicefun.
d.Adaptor = copySizeInformation(outAdap, d.Adaptor);

end

function d = iMakeDatetime(timezone, format, varargin)
% Helper to create a datetime array and impose the client timezone and
% format
try
    d = datetime(varargin{:});
catch err
    if isnumeric(varargin{1})
        rethrow(err)
    end
    
    % This deals with cases where an entire chunk is made up of strings
    % that cannot be parsed by the input format. Adding a string(missing)
    % to the input will allow such cases to pass, albeit with a NaT for the
    % output of those strings. This is the correct behavior if at least one
    % chunk has at least one good date or string(missing).
    ds = varargin{1};
    sz = size(ds);
    % We have to make ds into a column vector to avoid having to add more
    % than one NaT. Otherwise we would have to add an entire row or slice
    % of NaTs.
    ds = [string(ds(:)); string(missing)];
    d = datetime(ds, varargin{2:end});
    d = reshape(d(1:end-1), sz);
end
d.TimeZone = timezone;
d.Format = format;
end


function adap = iGetAdaptor(arg1, varargin)
% Determine the correct adaptor for the output. This includes determining
% the FORMAT and TIMEZONE properties.

idx = find(cellfun(@isNonTallScalarString, varargin), 1, 'first');
trailingArgs = varargin(idx:end);

% For simplicity, just use the in-memory constructor to parse
% everything from the first param-value pair to the end. This has the added
% advantage that any parse errors are reported immediately.
try
    proto = datetime([2000 1 1 0 0 0], trailingArgs{:});
catch err
    % We need to take care if the format needs to be determined from the
    % input values
    if strcmp(err.identifier, 'MATLAB:datetime:InvalidPreserveInput')
        % We have no choice but to get an element of the input. If the
        % preview is available this will be very cheap, if not then we'll
        % read one chunk.
        data = gather(matlab.bigdata.internal.lazyeval.extractHead(hGetValueImpl(arg1),1));
        try
            proto = datetime(data, trailingArgs{:});
        catch err
            throwAsCaller(err);
        end
    else
        throwAsCaller(err);
    end
end

adap = matlab.bigdata.internal.adaptors.getAdaptor(proto);
end
