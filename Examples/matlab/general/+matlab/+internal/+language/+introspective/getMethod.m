function classMethod = getMethod(metaClass, methodName, isCaseSensitive)
    classMethods = metaClass.Methods;
    classMethod = [];
    
    if nargin < 3
       isCaseSensitive = false; 
    end

    if ~isempty(classMethods)
        % remove methods that do not match methodName
        classMethods(cellfun(@(c)~matlab.internal.language.introspective.casedStrCmp(isCaseSensitive, c.Name, methodName), classMethods)) = [];
        if ~isempty(classMethods)
            % remove methods that are constructors
            classMethods(cellfun(@(c)strcmp(c.Name, c.DefiningClass.Name), classMethods)) = [];
                        
            if ~isempty(classMethods)
                
                staticMethods = classMethods(cellfun(@(c)eq(c.Static, true), classMethods));
            
                % select the first method if more than one method is remaning
                if ~isempty(staticMethods)
                    classMethod = staticMethods{1};
                else                
                    classMethod = classMethods{1};
                end
            end
        end
    end
end
        
%   Copyright 2014 The MathWorks, Inc.
