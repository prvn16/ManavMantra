function [classElement, elementKeyword] = getSimpleElement(metaClass, elementName, isCaseSensitive)
    if nargin < 3
       isCaseSensitive = false; 
    end

    for elementType = matlab.internal.language.introspective.getSimpleElementTypes
        elementKeyword = elementType.keyword;
        classElement = filterElement(metaClass, elementType.list, elementName, isCaseSensitive);
        if ~isempty(classElement)
            break;
        end
    end
end

function classElement = filterElement(metaClass, elementType, elementName, isCaseSensitive)
    classElement = [];
    elementList = metaClass.(elementType);
    if ~isempty(elementList)
        % remove elements that do not match elementName
        elementList(~matlab.internal.language.introspective.casedStrCmp(isCaseSensitive, {elementList.Name}, elementName)) = [];
        if ~isempty(elementList)
            % just in case this filtered down to more that one
            classElement = elementList(1);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
