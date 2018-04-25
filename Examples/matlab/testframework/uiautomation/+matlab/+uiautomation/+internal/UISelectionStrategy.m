classdef (Abstract) UISelectionStrategy
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        Validator
        Options
    end
    
    methods
        
        function strategy = UISelectionStrategy(validator, options)
            strategy.Validator = validator;
            strategy.Options = options;
        end
        
        function index = validate(strategy, option)
            
            if strategy.isIndex(option)
                index = strategy.validateIndex(option);
                return;
            end
            
            [text, ~] = convertCharsToStrings(option, 1);
            if strategy.Validator.isValidTextInput(strategy, text)
                index = strategy.validateText(text);
                return;
            end
            
            strategy.Validator.handleInvalidInput(strategy);
        end
    end
    
    methods (Access = protected)
        function index = validateIndex(strategy, index)
            
            % Guaranteed to be numeric at this point, do further validation
            
            f = find(~isint(index) | index < 1, 1);
            if ~isempty(f)
                % show the first "bad" index
                error( message('MATLAB:uiautomation:Driver:BadIndex', num2str(index(f))) );
            end
            
            % all positive ints - check for overflow
            N = numel(strategy.Options);
            f = find(index > N, 1);
            if ~isempty(f)
                % show the first "bad" index
                error( message('MATLAB:uiautomation:Driver:IndexOutOfBounds', index(f)) );
            end
            
        end
    end
    
    methods (Abstract, Access = protected)
        bool = isIndex(strategy,A)
        index = validateText(strategy, text)
    end
    
    methods (Abstract, Hidden)
        bool = isValidTextShape(strategy, text)
        handleInvalidInputsForSingleLineText(strategy)
        handleInvalidInputsForMultiLineText(strategy)
    end
    
end

function mask = isint(A)
% soft check for numerics - "isinteger" function requires type match
mask = A == floor(A);
end