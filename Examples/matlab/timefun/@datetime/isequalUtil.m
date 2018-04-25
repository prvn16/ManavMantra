function [args,prototype] = isequalUtil(args)

%   Copyright 2014-2016 The MathWorks, Inc.

try
    
    arg = args{1};
    if isa(arg,'datetime')
        % Strings will be converted to be "like" the first datetime.
        prototype = arg;
    else
        % Find the first "real" datetime as a prototype for converting strings.
        prototype = args{find(cellfun(@(x)isa(x,'datetime'),args),1,'first')};
    end
    unzoned = isempty(prototype.tz);
    leapSecs = strcmp(prototype.tz,datetime.UTCLeapSecsZoneID);

    for i = 1:length(args)
        arg = args{i};
        if isa(arg,'datetime')
            if isempty(arg.tz) ~= unzoned
                error(message('MATLAB:datetime:IncompatibleTZ'));
            elseif ~unzoned
                if strcmp(arg.tz,datetime.UTCLeapSecsZoneID) ~= leapSecs
                    error(message('MATLAB:datetime:IncompatibleTZLeapSeconds'));
                end
            end
        elseif (isstring(arg) && isscalar(arg)) || matlab.internal.datatypes.isCharStrings(arg)
            arg = autoConvertStrings(arg,prototype); % use first datetime array as a prototype
        elseif isa(arg, 'missing')
            arg = struct('data', nan(size(arg)));
        elseif isequal(arg,[])
            continue % leave the data as just []
        else
            error(message('MATLAB:datetime:InvalidComparison',class(arg),'datetime'));
        end
        args{i} = arg.data;
    end

catch ME
    throwAsCaller(ME);
end
