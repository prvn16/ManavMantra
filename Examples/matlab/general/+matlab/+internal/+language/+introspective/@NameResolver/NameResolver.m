classdef NameResolver < handle

    properties 
        classInfo        = [];
        
        topicInput       = '';
        helpPath         = '';  
        nameLocation     = '';       
        whichTopic       = '';
        resolvedTopic    = '';
        elementKeyword   = '';
        
        wsVariables      = struct('name', {});
        foundVar         = false;
        fixTypos         = false;
        
        isCaseSensitive  = false;
        malformed        = false;
        justChecking     = true;
        isUnderqualified = false;
        isInaccessible   = false;
    end
    
    properties (Dependent, SetAccess = private)
       isResolved;
       regexpCaseOption;      
    end
    
    methods        
        function obj = NameResolver(topicInput, helpPath, justChecking, wsVariables, fixTypos)
               
            obj.topicInput = topicInput;
            obj.resolvedTopic = topicInput;
                        
            if nargin >= 2
                obj.helpPath = helpPath;
            end

            if nargin >= 3
                obj.justChecking = justChecking;
            end
            
            if nargin >= 4
                obj.wsVariables = wsVariables;
            end
            
            if nargin >= 5
                obj.fixTypos = fixTypos;
            end
        end       
        
        function location = get.nameLocation(obj)               
            if isempty(obj.nameLocation)
                if ~obj.isResolved
                    obj.nameLocation = matlab.internal.language.introspective.safeWhich(obj.topicInput, obj.isCaseSensitive);
                else
                    obj.nameLocation = obj.whichTopic;
                end
            end
            
            location = obj.nameLocation;            
        end
        
        function result = get.isResolved(obj)
            result = ~isempty(obj.whichTopic); 
        end
        
        function result = get.regexpCaseOption(obj)
            if obj.isCaseSensitive
                result = 'matchcase';
            else
                result = 'ignorecase';
            end 
        end
        
        executeResolve(obj, isCaseSensitive); 
    end
    
    methods (Access=private)    
        
        doResolve(obj, topic, resolveWorkspace);
        innerDoResolve(obj, topic);
        
        underqualifiedResolve(obj, topic);
        resolveWithTypos(obj);

        resolveExplicitPath(obj, topic);        
        resolveImplicitPath(obj, topic);
        
        resolveUnaryClass(obj, className);
        
        UDDClassInformation(obj, UDDParts);
        MCOSClassInformation(obj, topic, MCOSParts);        
        
        resolvePackageInfo(obj, allPackageInfo, isExplicitPackage);  
    end
    
    methods(Static)
        [isDocumented, packageID] = isDocumentedPackage(packageInfo, packageName);
    end
end

%   Copyright 2007-2014 The MathWorks, Inc.
