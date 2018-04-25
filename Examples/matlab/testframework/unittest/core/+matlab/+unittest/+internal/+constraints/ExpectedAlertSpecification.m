classdef ExpectedAlertSpecification < matlab.unittest.internal.mixin.UnsortedUniqueMixin & ...
                                      matlab.unittest.internal.mixin.TrimRepeatedElementsMixin
    % ExpectedAlertSpecification - This class is undocumented. It
    % represents how an alert is specified.
    
    % Copyright 2015 The MathWorks, Inc.
    properties(Access = protected)
        Specification;
    end
    
    methods(Static)
        function spec = fromData(data)
            import matlab.unittest.internal.constraints.IDSpecification;
            import matlab.unittest.internal.constraints.MessageObjectSpecification;
            import matlab.unittest.internal.constraints.ClassSpecification;
            
            if isa(data, 'char')
                spec = IDSpecification({data});
            elseif isa(data, 'cell')
                spec = IDSpecification(data);
            elseif isa(data, 'message')
                spec = MessageObjectSpecification(data);
            elseif isa(data, 'meta.class')
                spec = ClassSpecification(data);
            end
        end
    end
    
    methods(Abstract, Static)
        str = formatForDisplay(actualAlert);
    end
    
    methods
        function str = convertToDisplayableList(spec)
            import matlab.unittest.internal.diagnostics.indentWithArrow;
            strs = arrayfun(@(x)indentWithArrow(x.toStringForDisplay), spec, 'UniformOutput',false);
            str = strjoin(strs,'\n');
        end
    end
    
    methods(Abstract)
        tf = accepts(expectedAlertSpecification, actualAlert);
        str = toStringForDisplay(expectedAlertSpecification);
    end
    
    methods(Access=protected)
        function spec = ExpectedAlertSpecification(specification)
            spec = repmat(spec, 1, numel(specification));
            if ~isempty(spec)
                [spec.Specification] = specification{:};
            end
        end
    end
end