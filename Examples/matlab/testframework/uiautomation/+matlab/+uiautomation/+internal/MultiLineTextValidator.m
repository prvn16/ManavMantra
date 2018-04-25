classdef MultiLineTextValidator < matlab.uiautomation.internal.TextValidator
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        
        function bool = isValidTextInput(~, ~, text)
            bool = isstring(text);
        end
        
        function index = validateText(~, text, options)
            match = cellfun(@(x)isequal(text, convertCharsToStrings(x)), options);
            index = find(match);
        end
        
        function handleInvalidInput(~, strategy)
            strategy.handleInvalidInputsForMultiLineText();
        end
        
    end
end