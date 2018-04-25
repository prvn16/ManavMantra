classdef System< matlab.system.SystemInterface & matlab.system.SystemProp
%matlab.System Base class for System objects
%
% In order to create a System object, you must subclass your object from
% matlab.System. Subclassing allows you to use the implementation and
% service methods provided by this base class to build your object. You use
% this syntax as the first line of your class definition file, where
% ObjectName is the name of your object:
% 
% classdef ObjectName < matlab.System
%

 
%   Copyright 1995-2017 The MathWorks, Inc.

    methods
        function out=System
            %matlab.System Base class for System objects
            %
            % In order to create a System object, you must subclass your object from
            % matlab.System. Subclassing allows you to use the implementation and
            % service methods provided by this base class to build your object. You use
            % this syntax as the first line of your class definition file, where
            % ObjectName is the name of your object:
            % 
            % classdef ObjectName < matlab.System
            %
        end

        function cloneImpl(in) %#ok<MANU>
        end

        function inputDimensionConstraint(in) %#ok<MANU>
        end

        function outputDimensionConstraint(in) %#ok<MANU>
        end

    end
    methods (Abstract)
    end
end
