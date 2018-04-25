function y = castLike(prototype, value)
% castLike  Cast value to prototype's class and attributes.
%
%   castLike(PROTOTYPE, VALUE) casts VALUE to PROTOTYPE's class and
%   attributes.  castLike is a helper function for the builtin CAST.
%
%   The type of the output will be identical to the type of
%   PROTOTYPE, regardless of data type override.
%
%   See also CAST.

%   Copyright 2017 The MathWorks, Inc.

    % This check can't be ordinarily hit (due to first-arg dispatch), but
    % keeping it here as a precaution.
    if ~isnumerictype(prototype)
        error(message('fixed:numerictype:inputMustBeNumerictype'));
    end
    if ~isnumeric(value) && ~islogical(value)
        error(message('fixed:coder:inputMustBeNumeric'));
    end
    switch prototype.DataType
        case {'Fixed', 'ScaledDouble'}
            % Use fi's castLike
            y = castLike(fi([], prototype), value);
        case 'boolean'
            % Convert directly to a logical
            y = logical(value);
        case 'double'
            % Convert directly to a double
            y = double(value);
        otherwise
            % Assert that it's a single and then convert directly
            assert(strcmp(prototype.DataType, 'single'))
            y = single(value);
    end
end