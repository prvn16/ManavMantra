function components = createFromFields(fields)

%   Copyright 2014 The MathWorks, Inc.

try
    nfields = length(fields);
    sz = [1 1];
    for i = 1:nfields
        f = fields{i};
        if ~isscalar(f)
            sz = size(f);
            break
        end
    end

    for i = 1:nfields
        f = fields{i};
        if ~isreal(f)
            error(message('MATLAB:calendarDuration:InputMustBeReal'));
        elseif isscalar(f)
            if f == 0
                % OK, leave it as a placeholder
            else
                f = repmat(f,sz);
                fields{i} = f;
            end
        elseif ~isequal(size(f),sz)
            error(message('MATLAB:calendarDuration:InputSizeMismatch'));
        end
        % The seconds or time field can have a fractional part, others must be
        % integer values. Any field can be Inf or NaN.
        if i < nfields || nfields == 3
            nonintVals = (round(f(:)) ~= f(:));
            if any(nonintVals)
                if any(isfinite(f(nonintVals)))
                    error(message('MATLAB:calendarDuration:MustBeInteger'));
                end
            end
        end
    end

catch ME
    throwAsCaller(ME);
end

% Allow positive or negative, any range. Fractional years/months/days/hours/minutes already caught.

mo = full(double(fields{1})*12 + double(fields{2}));
d = full(double(fields{3}));

if nfields == 3 % y,mo,d
    ms = 0;
elseif nfields == 4 % y,mo,d,ms
    ms = full(double(fields{4}));
else % y,mo,d,h,mi,s
    ms = full(double(fields{4})*3600 + double(fields{5})*60 + double(fields{6})) * 1000; % s -> ms
end

components.months = mo;
components.days = d;
components.millis = ms;

% Put the same nonfinite in all three fields, but don't replace a scalar zero placeholder.
components = calendarDuration.reconcileNonfinites(components);
