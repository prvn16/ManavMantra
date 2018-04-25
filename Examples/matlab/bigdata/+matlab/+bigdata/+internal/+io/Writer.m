%Writer
% The interface used by matlab.bigdata.internal.executor.convertToIndependentTasks
% to write data to a shuffle point.
%

%   Copyright 2016 The MathWorks, Inc.

classdef (Abstract) Writer < handle
    methods (Abstract)
        %ADD Add a collection of<key, value> pairs to the intermediate storage
        %
        % The input keys must either be the same length as values, a scalar
        % or empty. If keys is empty, then implementations of this class
        % can use a default value.
        %
        add(obj, keys, values);
        
        %COMMIT Commit all output to the intermediate storage
        %
        % If the object is destroyed before commit is called, all side
        % effects must be thrown away.
        %
        commit(obj);
    end
end
