classdef FileInformation < handle & matlab.mixin.Heterogeneous
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        FullName
    end
    
    properties (SetAccess = private)
        FileIdentifier
    end
        
    properties(Access = private)
        SetFileIdentifier = false;
    end
    
    properties (Abstract,SetAccess =  private)
        MethodList matlab.unittest.internal.fileinformation.CodeSegmentInformation
    end
    
    properties (Abstract,SetAccess =  private)
        ExecutableLines
    end
    
    properties (SetAccess = private, GetAccess = protected)
        FileTree
    end
    
    properties (Hidden, Dependent)
        PackageName
    end
    
    methods (Static)
        function info =  forFile(filename)
            import matlab.unittest.internal.fileResolver;
            fullName = fileResolver(filename);
            parseTree = mtree(filename, '-file');
            
            if (parseTree.FileType == mtree.Type.ClassDefinitionFile)
                info = matlab.unittest.internal.fileinformation.ClassFileInformation(fullName,parseTree);
            else
                info = matlab.unittest.internal.fileinformation.ProceduralFileInformation(fullName,parseTree);
            end
        end
    end
    
    methods
        function packageName = get.PackageName(info)
            identifier = matlab.unittest.internal.getParentNameFromFilename(info.FullName);
            packageName = getPackageName(identifier);
        end
        
        function identifier = get.FileIdentifier(info)
            import matlab.unittest.internal.getParentNameFromFilename
            if ~info.SetFileIdentifier
                [folder,shortName] = fileparts(info.FullName);
                
                folderParts = split(string(folder),filesep);
                containingFolder = folderParts(end);
                if containingFolder == "private"
                    info.FileIdentifier = shortName;
                elseif startsWith(containingFolder,'@') && containingFolder ~= "@"+shortName
                    parentName = getParentNameFromFilename(info.FullName);
                    info.FileIdentifier = fullfile(parentName,shortName);
                else
                    info.FileIdentifier = getParentNameFromFilename(info.FullName);
                end
                info.SetFileIdentifier = true;
            end
            identifier = info.FileIdentifier;
        end
    end
    
    methods (Access = protected)
        function info = FileInformation(fullName,parseTree)
            info.FullName = fullName;
            info.FileTree = parseTree;
        end
        
        function lines = getExecutableLines(info)
            fileLines = info.getAllCodeLines;
            
            % If unable to parse the file, mark all lines as executable
            if iskind(info.FileTree, 'ERR')                
                lines = 1:numel(fileLines);
                return
            end
            nonExecutableLineContinuations = getNonExecutableLineContinuations(fileLines, info.FileTree);
            executableAndFunctionLines = setdiff(info.getAllLinesWithExecutableContent,...
                nonExecutableLineContinuations);
            executableLines = setdiff(executableAndFunctionLines, info.getFunctionLines);
            
            % Be sure to always return a row vector.
            lines = reshape(setdiff(executableLines, ...
                info.getNonExecutableImportLines), 1, []);
        end
    end
    
    methods (Access = private)
        function lines = getNonExecutableImportLines(info)
            % Any non-executable command like import is a DCALL node in
            % mtree. Get all dual calls and check the Left String to
            % find the import command
            importDualCallNodes = mtfind(info.FileTree, 'Kind', 'DCALL','Left.String','import');
            lines = lineno(importDualCallNodes).';
        end
        
        function lines = getFunctionLines(info)
            % Find all (non-anonymous) function declarations. Ensure line
            % continuations are handled correctly.
            fcnHeaderNodes = mtfind(info.FileTree, 'Kind', {'FUNCTION','PROTO'});
            fcnHeaderLines = lineno(fcnHeaderNodes).';
            fileLines = info.getAllCodeLines;
            continueLines = findLineContinuations(fileLines);
            lines = findLineContinuationsInFunctionHeader(fcnHeaderLines,continueLines);
        end
        
        function lines = getAllLinesWithExecutableContent(info)
            % Find all meaningful lines in the code that mtree lists. These
            % include -
            % 1. Class definition
            % 2. Properties Block headers
            % 3. Events Block headers
            % 4. Methods Block headers
            % 5. Function definitions
            % 6. Properties
            % 7. Events
            % 8. Executable lines of code in functions/methods, scripts
            % 9. Line continuations (multiple lines counted)
            % 10. All import commands
            lines = unique(info.FileTree.lineno).';
        end
        
        function fileLines = getAllCodeLines(info)
            % Get all lines in M-file in chars, separated by newline
            % read code from .m or .mlx files
            fileLines = splitlines(matlab.internal.getCode(info.FullName));
        end
    end
    
end
function packageName = getPackageName(parentName)
ind = find(parentName == '.',1,'last');
 if isempty(ind)
     packageName = '';
 else
     packageName = parentName(1:ind-1);
 end
end
function nonExecutabaleContinuelines = getNonExecutableLineContinuations(fullCodeCell, fileTree)
% get line numbers for code with line continutatios
continueLines = findLineContinuations(fullCodeCell);

% find all lines with executable code and the coresponding line numbers
linesWithExecutableCode = lineno(fileTree.mtfind('Kind','ID'));

% get the non-executable continue line numbers. 
nonExecutabaleContinuelines = setdiff(continueLines,linesWithExecutableCode);
end

function continueLines = findLineContinuations(codeLinesCell)
allLinesWithTokens = xmtok(codeLinesCell)';
continueLines = setdiff(find(1:numel(codeLinesCell) > allLinesWithTokens), ...
                    find(allLinesWithTokens == 0));
end

function allFcnLines = findLineContinuationsInFunctionHeader(fcnLines,continueLines)
while true
    mask = ismember(continueLines, fcnLines+1);
    if ~any(mask)
        break;
    end
    fcnLines = [fcnLines, continueLines(mask)];
    continueLines(mask) = [];
end
allFcnLines = fcnLines;
end