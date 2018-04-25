classdef UISingleSelectionStrategy < matlab.uiautomation.internal.UISelectionStrategy
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        
        function strategy = UISingleSelectionStrategy(varargin)
            strategy = strategy@matlab.uiautomation.internal.UISelectionStrategy(varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        function bool = isIndex(~,A)
            bool = isnumeric(A) && isscalar(A);
        end
        
        function index = validateText(strategy, text)
            index = strategy.Validator.validateText(text, strategy.Options);
            if isempty(index)
                error( message('MATLAB:uiautomation:Driver:NoOptionMatch') )
            end
            if ~isscalar(index)
                error( message('MATLAB:uiautomation:Driver:AmbiguousOptionMatch') )
            end
            
        end
        
    end
    
    methods (Hidden)
        
        function bool = isValidTextShape(~, text)
            bool = isscalar(text);
        end
        function handleInvalidInputsForSingleLineText(~)
            error( message('MATLAB:uiautomation:Driver:MustBeScalarTextOrIndex') );
        end
        
        function handleInvalidInputsForMultiLineText(~)
            error( message('MATLAB:uiautomation:Driver:MustBeTextOrIndex') );
        end
        
    end
    
end
