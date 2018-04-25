classdef DecoratorLoader < appdesigner.internal.serialization.loader.interface.Loader
    %DECORATORLOADER A decorator loader that will extend/change the
    %functionality of the loader it wraps
 
         % Copyright 2017 The MathWorks, Inc.
         
    properties
        % The loader class it decorates
        Loader
    end
    
    methods        
        function obj = DecoratorLoader(loader)
            % constructor
            obj.Loader = loader;
        end
    end
end

