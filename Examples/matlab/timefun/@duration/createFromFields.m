function ms = createFromFields(fields)

%   Copyright 2014 The MathWorks, Inc.

try

    sz = [1 1];
    for i = 1:length(fields)
        f = fields{i};
        if ~isreal(f)
            error(message('MATLAB:duration:InputMustBeReal'));
        elseif isscalar(f)
            % OK
        elseif isequal(sz,[1 1])
            sz = size(f);
        elseif ~isequal(size(f),sz)
            error(message('MATLAB:duration:InputSizeMismatch'));
        end
    end

    h = double(fields{1});
    m = double(fields{2});
    s = double(fields{3});
    
    % Any field can be positive or negative, with any range, have a fractional
    % part, or be Inf or NaN.
    ms = full(h*3600000 + m*60000 + s*1000); % s -> ms
    
    if length(fields) == 4
        ms = ms + double(fields{4});
    end

catch ME
    throwAsCaller(ME);
end
