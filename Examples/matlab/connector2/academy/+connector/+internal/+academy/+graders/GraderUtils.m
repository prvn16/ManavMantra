classdef GraderUtils
    %GRADERUTILS is a collection of static utility functions that are
    %useful in multiple grading contexts, such as comparing code or
    %workspace variables
    
    properties (Constant)
        baseFolder = fullfile(tempdir, '.training');
        testFolder = fullfile(tempdir,'.training','tests');
        gradingFolder = fullfile(tempdir,'.training','grading');
    end
    
    methods(Static)
        
        function createFoldersAndAddToPath
            import connector.internal.academy.graders.*;
            for c = {GraderUtils.testFolder, GraderUtils.gradingFolder}
                f = c{1};
                try
                    rmdir(f,'s')
                end
                mkdir(f);
                addpath(f,'-end');
            end
        end

        function removeFoldersFromPath
            import connector.internal.academy.graders.*;
            for c = {GraderUtils.testFolder, GraderUtils.gradingFolder}
                f = c{1};
                rmpath(f);
            end
            try
                rmdir(GraderUtils.baseFolder,'s')
            end
        end
        
        function yesNo = isVariableInWorkspace(ws,v)
            yesNo = false;
            if ~isstruct(ws)
                warning('GraderUtils:InvalidInput','ws not a valid workspace variable');
            end
            for varname = fields(ws)'
                if isequal(v,ws.(varname{1}))
                    yesNo = true;
                    return;
                end
            end
        end
        
        function fcnNames = getNamesOfDefinedFunctions(codeSnippet)
            fcnNames = {};
            if ischar(codeSnippet)
                codeSnippet = mtree(codeSnippet);
            end
            if ~isa(codeSnippet,'mtree')
                warning('GraderUtils:InvalidInput','codeSnippet must be either a character array or mtree');
                return;
            end
            fcnNodes = mtfind(codeSnippet,'Kind','FUNCTION');
            for j = find(fcnNodes.getIX)
                fcnNames{end+1} = tree2str(fcnNodes.select(j).Fname); %#ok<AGROW>
            end
        end
        
        function [yesNo,numCalls] = codeCalls(codeSnippet,fcnName)
            yesNo = false;
            numCalls = 0;
            if ischar(codeSnippet)
                codeSnippet = mtree(codeSnippet);
            end
            if ~isa(codeSnippet,'mtree')
                warning('GraderUtils:InvalidInput','codeSnippet must be either a character array or mtree');
                return;
            end
            if ~ischar(fcnName)
                warning('GraderUtils:InvalidInput','fcnName should be a character array');
            end
            matches = mtfind(codeSnippet,'Kind','ID',...
                'String',fcnName);
            numCalls = nnz(matches.getIX);
            if ~(matches.isnull)
                yesNo = true;
            end
        end
        
        function yesNo = containsSyntaxError(codeSnippet)
            if ischar(codeSnippet)
                codeSnippet = mtree(codeSnippet);
            end
            if ~isa(codeSnippet,'mtree')
                warning('GraderUtils:InvalidInput','codeSnippet must be either a character array or mtree');
                return;
            end
            yesNo = ~isnull(mtfind(codeSnippet,'Kind','ERR'));
        end
        
        function bringBaseWorkspaceIntoCallingScope
            baseWorkspaceVars_ = evalin('base','whos');
            for i_ = 1:numel(baseWorkspaceVars_)
                name_ = baseWorkspaceVars_(i_).name;
                value_ = evalin('base',baseWorkspaceVars_(i_).name);
                assignin('caller',name_,value_);
            end
        end
        
        function runLiveScript(editorId, fileName, fullFileText)
            uuid = char(java.util.UUID.randomUUID);            
            regionDataFuture = com.mathworks.mde.embeddedoutputs.RegionsDataUtil.getRegionDataFuture(editorId);
            regionDataList = regionDataFuture.get();
            
            %fullFileText = char(com.mathworks.services.mlx.MlxFileUtils.getCode(java.io.File(fileName)));
            
            %Use existing mtree API to find the first function line
            tree = com.mathworks.widgets.text.mcode.MTree.parse(fullFileText);
            node = com.mathworks.widgets.text.mcode.MDocumentUtils.getFirstFunctionNode(tree);
            
            if ~isempty(node)
                firstFunctionLineNumber = double(node.getStartLine());
            else
                firstFunctionLineNumber = -1;
            end
            
            matlab.internal.editor.EvaluationOutputsService.evalRegions(editorId, uuid, regionDataList, fullFileText, firstFunctionLineNumber, false, false, fileName, -1);
        end

        function moveMlxFileContentsToEditor(filename, editorId)
            file = java.io.File(filename);

            isMLX = com.mathworks.services.mlx.MlxFileUtils.isMlxFile(file.getAbsolutePath());

            % Load the content
            if isMLX
                opcPackage = com.mathworks.services.mlx.MlxFileUtils.read(file);
            else
                opcPackage = com.mathworks.publishparser.PublishParser.convertMToRichScript(file);
            end

            opcMap = com.mathworks.services.mlx.OpcUtils.convertOpcPackageToMap(opcPackage);
            opcMap.put("status", true);
            converter = com.mathworks.connector.message_service.impl.JSONConverterImpl;
            jsonMsg = char(converter.convertToJson(opcMap));

            service = com.mathworks.messageservice.MessageServiceFactory.getMessageServiceOpaque;

            messageJSON = java.lang.String(unicode2native(jsonMsg, 'UTF-8'), 'UTF-8');
            service.publish(['/mlx/service/readResponse/' editorId], messageJSON.getBytes('UTF-8')); %convert to byte array%
        end
        
        function emptyFolder(f)
            files = dir(f);
            for i = 1:numel(files)
                if files(i).isdir
                    if ~any(strcmp(files(i).name,{'.','..'}))
                        rmdir(fullfile(f,files(i).name),'s');
                    end
                else
                    delete(fullfile(f,files(i).name));
                end
            end
        end
        
        function [V,v] = editDistance(string1,string2)
            % Edit Distance is a standard Dynamic Programming problem. Given two strings s1 and s2, the edit distance between s1 and s2 is the minimum number of operations required to convert string s1 to s2. The following operations are typically used:
            % Replacing one character of string by another character.
            % Deleting a character from string
            % Adding a character to string
            % Example:
            % s1='article'
            % s2='ardipo'
            % EditDistance(s1,s2)
            % > 4
            % you need to do 4 actions to convert s1 to s2
            % replace(t,d) , replace(c,p) , replace(l,o) , delete(e)
            % using the other output, you can see the matrix solution to this problem
            %
            %
            % by : Reza Ahmadzadeh (seyedreza_ahmadzadeh@yahoo.com - reza.ahmadzadeh@iit.it)
            % 14-11-2012
            
            m=length(string1);
            n=length(string2);
            v=zeros(m+1,n+1);
            for i=1:1:m
                v(i+1,1)=i;
            end
            for j=1:1:n
                v(1,j+1)=j;
            end
            for i=1:m
                for j=1:n
                    if (string1(i) == string2(j))
                        v(i+1,j+1)=v(i,j);
                    else
                        v(i+1,j+1)=1+min(min(v(i+1,j),v(i,j+1)),v(i,j));
                    end
                end
            end
            V=v(m+1,n+1);
        end
        
        function possibleMatch = didYouMean(stringToMatch, allStrings)
            import connector.internal.academy.graders.*;
            % This function tries to find a closest match between a given
            % string and
            possibleMatch = '';
            if (length(stringToMatch) > 2) && ~isempty(allStrings)
                % Convert all the strings to lower case
                l_stringToMatch = lower(stringToMatch);
                l_allStrings = lower(allStrings);
                
                % Find the edit distance
                ed = cellfun(@(x) GraderUtils.editDistance(x,l_stringToMatch),l_allStrings);
                
                % Find the variable with lowest edit distance. If there are
                % multiple, or if the edit distance is too large, don't return anything.
                min_ed_idx = ed == min(ed);
                if min(ed) <= 1 && nnz(min_ed_idx) == 1
                    possibleMatch = allStrings{min_ed_idx};
                end
            end
        end
        
        function jsonStr = encodeToJson(o)
            %Encodes o to a JSON string. Limited support:
            %  - Scalar struct becomes JSON object - {  }
            %  - Struct array becomes JSON array - [  ]
            %  - Cell array becomes JSON array - [  ]
            %  - Single number becomes JSON numeric
            %  - Single logical becomes JSON boolean
            %  - Character array becomes JSON string (escaped)
            %  - Numeric array or logical array first converted to cell
            %    array (num2cell), and then becomes JSON array
            %  - Anything else is returned as an empty object
            import connector.internal.academy.graders.*;
            
            %Preprocess
            if ((~isscalar(o)) && (isnumeric(o) || islogical(o)))
                o = num2cell(o);
            end
            
            %Default
            jsonStr = '{}';
            matchFound = false;
            
            %Struct array
            if isstruct(o) && ~isscalar(o)
                jsonStr = '[';
                vals = arrayfun(@(x) GraderUtils.encodeToJson(x), o, 'UniformOutput',false);
                jsonStr = [jsonStr strjoin(vals,',')];
                jsonStr = [jsonStr ']'];
                matchFound = true;
            end
            
            %Scalar structure
            if isstruct(o) && isscalar(o)
                jsonStr = '{';
                names = fields(o);
                vals = {};
                for i = 1:numel(names)
                    vals{i} = ['"' names{i} '":' GraderUtils.encodeToJson(o.(names{i}))];
                end
                jsonStr = [jsonStr strjoin(vals,',')];
                jsonStr = [jsonStr '}'];
                matchFound = true;
            end
            
            %Cell array
            if iscell(o)
                jsonStr = '[';
                vals = cellfun(@(x) GraderUtils.encodeToJson(x), o, 'UniformOutput',false);
                jsonStr = [jsonStr strjoin(vals,',')];
                jsonStr = [jsonStr ']'];
                matchFound = true;
            end
            
            %Scalar logical
            if islogical(o) && isscalar(o)
                if o
                    jsonStr = 'true';
                else
                    jsonStr = 'false';
                end
                matchFound = true;
            end
            
            %Scalar numeric
            if isnumeric(o) && isscalar(o)
                jsonStr = num2str(o);
                matchFound = true;
            end
            
            %Character array
            if ischar(o)
                jsonStr = ['"' GraderUtils.escapeStringForJson(o) '"'];
                matchFound = true;
            end
            
            %Other objects - see if they have public properties, and if so,
            %use those
            try
                hasProperties = ~isempty(properties(o));
            catch
                hasProperties = false;
            end
            if (hasProperties && ~isempty(o) && ~matchFound && ~istable(o))
                if ~isscalar(o)
                    jsonStr = '[';
                    vals = arrayfun(@(x) GraderUtils.encodeToJson(x), o, 'UniformOutput',false);
                    jsonStr = [jsonStr strjoin(vals,',')];
                    jsonStr = [jsonStr ']'];
                else
                    jsonStr = '{';
                    names = properties(o);
                    vals = {};
                    for i = 1:numel(names)
                        vals{i} = ['"' names{i} '":' GraderUtils.encodeToJson(eval(['o.' names{i}]))];
                    end
                    jsonStr = [jsonStr strjoin(vals,',')];
                    jsonStr = [jsonStr '}'];
                end
            end
            
        end
        
    end
    
    methods (Static=true,Access=private)
        
        function jsonEscapedStr = escapeStringForJson(str)
            str = strrep(str,'\','\\');
            str = strrep(str,char(8),'');
            str = strrep(str,char(9),'\t');
            str = strrep(str,char(10),'\n');
            str = strrep(str,char(13),'\r');
            str = strrep(str,'"','\"');
            jsonEscapedStr = str;
        end
        
    end
    
end

