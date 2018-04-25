classdef ContentWrapper < handle
    %This class is undocumented and may change in a future release.
    
    %This handle class is used to wrap around large content that might be
    %reused in multiple places in order to avoid using a lot of storage.
    
    % Instances of this class are stored inside of function handles that
    % live inside of ScriptTestCaseProvider which might be saved as of
    % R2016b. Therefore, altering this function may affect R2016b (or
    % later) saved test suites.
    
    % Copyright 2016 The MathWorks, Inc.
    properties(SetAccess=immutable)
        Content
    end
    
    methods
        function wrapper = ContentWrapper(content)
            wrapper.Content = content;
        end
    end
end