classdef simpleMCOSConstructor < matlab.internal.language.introspective.classInformation.fileConstructor
    methods
        function ci = simpleMCOSConstructor(className, whichTopic, justChecking)
            noAtDir = isempty(regexp(whichTopic, ['[\\/]@' className '$'], 'once'));
            ci@matlab.internal.language.introspective.classInformation.fileConstructor('', className, fileparts(whichTopic), whichTopic, noAtDir, justChecking);
        end

        function b = isClass(~)
            b = true;
        end
        
        function b = isMCOSClassOrConstructor(~)
            b = true;
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
