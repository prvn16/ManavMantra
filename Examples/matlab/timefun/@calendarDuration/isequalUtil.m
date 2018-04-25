function args = isequalUtil(args)

%   Copyright 2014 The MathWorks, Inc.

try

    for i = 1:length(args)
        arg = args{i};
        if isa(arg, 'missing')
            arg = calendarDuration(arg);
        elseif ~isa(arg,'calendarDuration')
            error(message('MATLAB:calendarDuration:InvalidComparison',class(arg),'calendarDuration'));
        end
        % Expand out scalar zero placeholders to simplify comparison of all three
        % fields. May also have to put appropriate nonfinites into elements of
        % fields that were expanded.
        components = calendarDuration.expandScalarZeroPlaceholders(arg.components);
        args{i} = calendarDuration.reconcileNonfinites(components);
    end

catch ME
    throwAsCaller(ME);
end
