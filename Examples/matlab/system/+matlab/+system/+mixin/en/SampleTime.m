classdef SampleTime< matlab.system.mixin.SampleTimeCore
%matlab.system.mixin.SampleTime Mixin for System objects with sample time
%   The SampleTime mixin is a base class for System objects that allows a 
%   System object execute with a sample time.  This mixin enables the 
%   getSampleTime method, which is only called by the System Block. 
%
%   To use this mixin, subclass your object from this 
%   class in addition to the matlab.System base class. Use the
%   following syntax as the first line of your class definition file, 
%   where ObjectName is the name of your object:
%
%   classdef ObjectName < matlab.System &...
%       matlab.system.mixin.SampleTime

     
%   Copyright 1995-2015 The MathWorks, Inc.

    methods
        function out=SampleTime
            %matlab.system.mixin.SampleTime Mixin for System objects with sample time
            %   The SampleTime mixin is a base class for System objects that allows a 
            %   System object execute with a sample time.  This mixin enables the 
            %   getSampleTime method, which is only called by the System Block. 
            %
            %   To use this mixin, subclass your object from this 
            %   class in addition to the matlab.System base class. Use the
            %   following syntax as the first line of your class definition file, 
            %   where ObjectName is the name of your object:
            %
            %   classdef ObjectName < matlab.System &...
            %       matlab.system.mixin.SampleTime
        end

        function createSampleTime(in) %#ok<MANU>
        end

        function getSampleTimeImpl(in) %#ok<MANU>
        end

    end
    methods (Abstract)
    end
end
