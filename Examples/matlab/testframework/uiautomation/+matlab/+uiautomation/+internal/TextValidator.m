classdef TextValidator
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods (Abstract)
        bool = isValidTextInput(validator, strategy, text)
        index = validateText(validator, text, options)
        handleInvalidInput(validator, strategy)
    end
end