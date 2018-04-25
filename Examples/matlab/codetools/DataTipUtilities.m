 classdef DataTipUtilities
    %DATATIPUTILITIES Utilities for datatips.
    
    %   Copyright 2016-2017 The MathWorks, Inc.

    methods (Static)
        function structOrClassName = getStructOrClassName(variableName)
            endOfVariableName = find(variableName == '.', 1);
            structOrClassName = variableName(1:endOfVariableName - 1);
        end

        function [object, methodOrProperty] = getVariableNameParts(variableName)
            startOfMethodOrProperty = find(variableName == '.', 1, 'last');
            methodOrProperty = variableName(startOfMethodOrProperty + 1:end);

            object = variableName(1:startOfMethodOrProperty - 1);
        end
    end
 end