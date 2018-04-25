function tf = anyHandleValue(values)
%ANYHANDLEVALUE Checks if any of the values is a handle object.
%   TF = ANYHANDLEVALUE(values) checks if any of the value in
%   VALUES is a handle. This is used by BUFFER Objects (KeyValueVector
%   and ValueBuffer), in mapreduce and tall write.
%
%   See also datastore, mapreduce, tall.

%   Copyright 2016 The MathWorks, Inc.
    tf = false;
    if ~iscell(values)
        if isa(values, 'handle')
            tf = true;
            return;
        end
    else
        for i = 1 : numel(values)
            if isa(values{i}, 'handle')
                tf = true;
                return;
            end
        end
    end
end
