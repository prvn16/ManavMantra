function n=countvars(outer)
% helper function: count the "visible" variables in fplot/fsurf/... input

% Copyright 2015 The MathWorks, Inc.
    n = numel(symvarMulti(outer));
end

function vars = symvarMulti(c)
    if iscell(c)
        vars = cellfun(@symvarMulti, c, 'UniformOutput', false);
        vars = reshape(unique([vars{:}]),1,[]);
    elseif isa(c,'function_handle')
        vars = {};
    elseif ischar(c) && isvarname(c) && (exist(c,'builtin') || exist(c,'file'))
        vars = {};
    else
        vars = reshape(symvar(c),1,[]);
    end
end
