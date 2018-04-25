classdef UIMultiSelectionStrategy < matlab.uiautomation.internal.UISelectionStrategy
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function strategy = UIMultiSelectionStrategy(varargin)
            strategy = strategy@matlab.uiautomation.internal.UISelectionStrategy(varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        function bool = isIndex(~,A)
            bool = isnumeric(A);
        end
        
        function indices = validateText(strategy, text)
            import matlab.uiautomation.internal.UISingleSelectionStrategy;
            
            delegate = UISingleSelectionStrategy(strategy.Validator, strategy.Options);
            indices = zeros(1, numel(text));
            for i = 1:numel(text)
                indices(i) = delegate.validateText(text(i));
            end
        end
        
    end
    
    methods (Hidden)
        
        function bool = isValidTextShape(~, ~)
            bool = true;
        end
        
        function handleInvalidInputsForSingleLineText(~)
            error( message('MATLAB:uiautomation:Driver:MustBeTextOrIndices') );
        end
        
        handleInvalidInputsForMultiLineText(strategy); % unused
        
    end
    
end
