classdef localConstructor < matlab.internal.language.introspective.classInformation.constructor
    methods
        function ci = localConstructor(packageName, className, basePath, justChecking)
            definition = fullfile(basePath, [className filemarker className]);
            whichTopic = which(fullfile(basePath, className));
            ci@matlab.internal.language.introspective.classInformation.constructor(packageName, className, definition, whichTopic, justChecking);
        end

        function [helpText, needsHotlinking] = getSecondaryHelp(ci, hotLinkCommand)
            % did not find help for the local constructor, see if there is help for the class
            ci.definition = ci.whichTopic;
            ci.minimalPath = ci.definition;
            ci.minimizePath;
            [helpText, needsHotlinking] = ci.helpfunc(hotLinkCommand);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
