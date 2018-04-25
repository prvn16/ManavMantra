classdef ClassFileInformation < matlab.unittest.internal.fileinformation.FileInformation
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        MethodList  matlab.unittest.internal.fileinformation.CodeSegmentInformation = matlab.unittest.internal.fileinformation.MethodInformation.empty(1,0)
    end
    
    properties (Access = private)
        SetMethodList = false;
        SetExecutableLines = false;
    end
    
    properties (SetAccess = private)
        ExecutableLines
    end
    
    methods(Access = ?matlab.unittest.internal.fileinformation.FileInformation)
        function info = ClassFileInformation(fullName,parseTree)
            info = info@matlab.unittest.internal.fileinformation.FileInformation(fullName,parseTree);
        end
    end
    
    methods
        function lines = get.ExecutableLines(info)
            if ~info.SetExecutableLines
                rawLines = info.getExecutableLines;
                info.ExecutableLines = setdiff(rawLines, info.getNonExecutableClassLines);
                info.SetExecutableLines = true;
            end
            lines = info.ExecutableLines;
        end
        function methodInformation = get.MethodList(info)
            import matlab.unittest.internal.fileinformation.MethodInformation
            if ~info.SetMethodList
                classExecutableLines = info.ExecutableLines;
                methodFcnNodes = getMethodFunctionNodes(info);
                nodeIndices = indices(methodFcnNodes);
                numMethods = numel(nodeIndices);
                methodInfoArray = cell(1,numMethods);
                for idx = 1:numMethods
                    currentNode = methodFcnNodes.select(nodeIndices(idx));
                    methodInfoArray{idx} = MethodInformation(currentNode,classExecutableLines);
                end
                info.MethodList = [MethodInformation.empty(1,0) methodInfoArray{:}];
                info.SetMethodList = true;
            end
            methodInformation = info.MethodList;
        end
    end
    
    methods (Access = private)
        function lines = getNonExecutableClassLines(info)
            % If the file contains no code, handle this special case and return.
            if count(info.FileTree) == 0
                % Early return if the file is not a valid class.
                lines = zeros(1,0);
                return;
            end
            
            % Find the lines that contain Class definitions and Method
            % block declaration
            classdefAndMethodLines = lineno(mtfind(info.FileTree, ...
                'Kind', {'CLASSDEF', 'METHODS'}));
            
            % Find lines that contain all the attributes for the class
            % definition. This includes -
            % 1. Class attributes
            % 2. lines specifying super classes
            classdefNodes = (mtfind(info.FileTree, ...
                'Kind', 'CLASSDEF'));
            classAttributeLines = [lineno(classdefNodes.Cexpr.Full); lineno(classdefNodes.Cattr.Full)];
            
            % Find all lines that contain method attributes
            MethodNodes = mtfind(info.FileTree, ...
                'Kind', 'METHODS');
            methodAttributeLines =  lineno(MethodNodes.Attr.Full);
            
            allClassdefAndMethodLines = unique([classdefAndMethodLines; classAttributeLines; methodAttributeLines]);
            
            propertyEnumEventLines = unique(lineno(subtree(mtfind(info.FileTree, ...
                'Kind', {'PROPERTIES', 'ENUMERATION', 'EVENTS'}))));
            
            lines = [allClassdefAndMethodLines; propertyEnumEventLines].';
        end
        
        function methodFcnNodes = getMethodFunctionNodes(info)
            methodNodes = mtfind(info.FileTree,'Kind','METHODS');
            methodFcnNodes = mtfind(methodNodes.Body.List,'Kind',{'FUNCTION','PROTO'});
        end
    end
end