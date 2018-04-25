classdef SingleLineTextValidator < matlab.uiautomation.internal.TextValidator
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        
        function bool = isValidTextInput(~, strategy, text)
            bool = isstring(text) && strategy.isValidTextShape(text);
        end
        
        function index = validateText(~, text, options)
            index = find(text == options);
        end
        
        function handleInvalidInput(~, strategy)
            strategy.handleInvalidInputsForSingleLineText();
        end
        
    end
end
