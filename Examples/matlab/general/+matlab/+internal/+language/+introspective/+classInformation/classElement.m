classdef classElement < matlab.internal.language.introspective.classInformation.classItem
    properties (SetAccess=protected, GetAccess=public)
        element = '';
    end
    
    properties (SetAccess=private, GetAccess=protected)
        separator = '/';
    end
        
    methods
        function ci = classElement(packageName, className, element, definition, minimalPath, whichTopic)
            ci@matlab.internal.language.introspective.classInformation.classItem(packageName, className, definition, minimalPath, whichTopic);
            ci.element = element;
        end
        
        function topic = fullTopic(ci)
            topic = ci.makeTopic(ci.fullClassName);
        end
        
        function docTopic = getDocTopic(ci, justChecking)
            ci.prepareSuperClassName;
            isSuperClassPage = false;
            if usejava('jvm') && ~isempty(ci.fullSuperClassName)
                docTopic = innerGetDocTopic(ci, ci.makeTopic(ci.fullSuperClassName), true);
                if ~isempty(docTopic) && ~justChecking
                    refPages = com.mathworks.mlwidgets.help.HelpInfo.getAllReferencePageUrls(docTopic, true);
                    if ~isempty(refPages)
                        actualURL = char(refPages(1).getFullUrl);
                        isSuperClassPage = ~isempty(regexpi(actualURL, ['\<' ci.superClassName '\.html$'], 'once'));
                    end                    
                end
            else
                docTopic = '';
            end
            if isempty(docTopic) || isSuperClassPage 
                subTopic = innerGetDocTopic(ci, ci.fullTopic, true);
                if ~isempty(subTopic) 
                    docTopic = subTopic;
                end
            end
        end
                
        function setAccessible(~)
        end
        
        function setStatic(ci, b)
            if b
                ci.separator = '.';
            else
                ci.separator = '/';
            end
                
        end
    end
    
    methods (Access=private)
        function topic = makeTopic(ci, className)       
            topic = [className ci.separator ci.element];
        end
    end
end

%   Copyright 2012 The MathWorks, Inc.
