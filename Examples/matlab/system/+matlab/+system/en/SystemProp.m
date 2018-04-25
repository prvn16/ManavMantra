classdef SystemProp< handle
%  FOR INTERNAL USE ONLY -- This class is intentionally undocumented. Its
%  behavior may change, or the class itself may be removed in a future
%  release.

   
  %   Copyright 1995-2014 The MathWorks, Inc.

    methods
        function out=SystemProp
            % Property management base class for System objects
        end

        function getInputNamesImpl(in) %#ok<MANU>
        end

        function getOutputNamesImpl(in) %#ok<MANU>
        end

        function isInactivePropertyImpl(in) %#ok<MANU>
            %flag = isInactivePropertyImpl(obj, prop) Whether prop is currently 'on'
            %   Return a flag indicating if input prop is 'turned off' or irrelevant
            %   based on the current property values.
        end

    end
    methods (Abstract)
    end
end
