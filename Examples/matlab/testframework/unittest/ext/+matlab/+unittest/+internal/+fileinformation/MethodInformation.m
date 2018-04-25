classdef MethodInformation < matlab.unittest.internal.fileinformation.CodeSegmentInformation
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        ExecutableLines
        Name
        Signature
    end
    
    properties (Access = private)
        ClassExecutableLines
    end
    
    methods
        function info = MethodInformation(methodNode, classExecutableLines)
            info.ElementTreeNode = methodNode;
            info.Name = cell2mat(strings(info.ElementTreeNode.Fname));
            info.ClassExecutableLines = classExecutableLines;
        end
        
        function lines = get.ExecutableLines(info)
            executableLinesRaw = intersect(unique(lineno(info.ElementTreeNode.Body.Full)),...
                info.ClassExecutableLines);
            lines = reshape(executableLinesRaw,1, []);
        end
        
        function signature = get.Signature(info)
            % Use Ins and Outs mtree nodes to extract arguments
             outputsNode = info.ElementTreeNode.Outs;
             inputsNode = info.ElementTreeNode.Ins;
             
             outArgs = strings(outputsNode.List);
             inArgs = strings(inputsNode.List);
             
             % Add '~' string for ignored inputs
             inArgs(strcmp('',inArgs)) = {'~'};
             
             % Special case when no output argument or a scalar output
             % argument is present.
             outputSignature = '';
             if isscalar(outArgs)
                 outputSignature = sprintf('%s = ',outArgs{1});
             elseif numel(outArgs) > 1
                 outputSignature = sprintf('[%s] = ',strjoin(outArgs,', '));
             end
             
             inputSignature = sprintf('%s(%s)', info.Name, ...
                 strjoin(inArgs,', '));
             signature = [outputSignature,inputSignature];
        end
    end
end


