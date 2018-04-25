classdef UDD < matlab.internal.language.introspective.classWrapper.base
    properties (SetAccess=protected, GetAccess=protected)
        packageName;
        schemaClass;
    end

    methods (Access=protected)
        function classInfo = getSuperElement(cw, elementName)
            classInfo = [];
            cw.loadClass;
            if ~isempty(cw.schemaClass)
                supers = cw.schemaClass.SuperClasses';
                for super = supers
                    wrappedSuper = matlab.internal.language.introspective.classWrapper.superUDD(super, cw.subClassPath, cw.subClassPackageName);
    
                    classInfo = wrappedSuper.getElement(elementName, false);
    
                    if ~isempty(classInfo)
                        if isempty(classInfo.superWrapper)
                            classInfo.superWrapper = wrappedSuper;
                        end
                        return;
                    end
                end
            end
        end
    end
    
    methods (Access=protected)
        function loadClass(~)
        end
        
        function classInfo = getFileMethod(cw, methodName)
            classInfo = getFileMethod@matlab.internal.language.introspective.classWrapper.base(cw, methodName);
            if ~isempty(classInfo)
                cw.loadClass;
                if ~isempty(cw.schemaClass)
                    for classMethod = cw.schemaClass.Methods'
                        if strcmpi(classMethod.Name, methodName)
                            classInfo.setStatic(strcmp(classMethod.Static, 'on'));
                            return;
                        end
                    end
                end
            end
        end
    end
end

%   Copyright 2007-2012 The MathWorks, Inc.
