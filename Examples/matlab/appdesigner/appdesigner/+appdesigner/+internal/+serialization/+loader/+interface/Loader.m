classdef Loader < handle
    %LOADER A base class of all loaders
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods (Abstract)
        % and abstract method to load the data
        appData = load(obj);
    end
end

