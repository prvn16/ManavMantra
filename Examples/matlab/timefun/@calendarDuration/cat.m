function result = cat(dim,varargin)

%   Copyright 2014 The MathWorks, Inc.

import matlab.internal.datetime.datenumToMillis
import matlab.internal.datatypes.throwInstead

nargs = length(varargin);
m = cell(1,nargs);
d = cell(1,nargs);
ms = cell(1,nargs);
fmts = cell(1,nargs);
sz = cell(1,nargs);
template = [];
for i = 1:nargs
    arg = varargin{i};
    if isa(arg,'calendarDuration')
        if isequal(template,[])
            template = varargin{i}; % base result on first calendarDuration
        end
        components = arg.components;
        m{i} = components.months;
        d{i} = components.days;
        ms{i} = components.millis;
        fmts{i} = arg.fmt;
        sz{i} = calendarDuration.getFieldSize(components);
    elseif isa(arg,'duration')
        m{i} = 0;
        d{i} = 0;
        ms{i} = milliseconds(arg);
        fmts{i} = 'mdt';
        sz{i} = size(arg);
    elseif isa(arg,'missing')
        m{i} = 0;
        d{i} = 0;
        ms{i} = double(arg);
        fmts{i} = 'mdt';
        sz{i} = size(arg);        
    else
        % Numeric input treated as a multiple of 24 hours.
        m{i} = 0;
        d{i} = 0;
        try
            ms{i} = datenumToMillis(arg);
        catch ME
            throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:calendarDuration:cat:InvalidConcatenation'));
        end
        fmts{i} = 'mdt';
        sz{i} = size(arg);
    end
end

result = template;
result.components.months = catField(dim,m,sz);
result.components.days   = catField(dim,d,sz);
result.components.millis = catField(dim,ms,sz);
result.fmt = calendarDuration.combineFormats(fmts{:});


function field = catField(dim,field,sz)
if any(cellfun(@(c)isequal(c,0),field))
    for i = 1:length(field)
        f = field{i};
        if isscalar(f), field{i} = repmat(f,sz{i}); end
    end
end

field = cat(dim,field{:});
