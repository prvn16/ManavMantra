classdef Schema < handle
% Set of heuristics influencing REQUIREMENTS' behavior. 
%   * Excluded files (pattern matching)
%   * Required licenses
%   * Explicit dependencies

    properties (Access = private)

        excludeList % Files we hate, and the reasons why.
        expectList  % Files we expect on the target and don't ship 
        allowList   % Expected files we allow to ship anyway
        commonBlock     % Variables available in rules files
        currentLicense  % License associated with current rules file
        currentTbxName  % Toolbox associated with current rules file
        includeBaseline % By toolbox and then by target
        knownLanguages  % Map: file extension -> language name
        setOperations   % Rules that operate on known sets
        fileClassifier  % Simple file classification based on file extension
        
        activeRulesFile % Rules file currently being processed
        activeRulesLine % Currently running commands from this line
        
        Environment % Values that depend on "environment"
        PathUtility % Methods that depend manipulate paths
    end

    properties (Access = public)
        depDepot        % Connected to the valid database, if any
    end
    
    properties (Constant)
        MatlabRoot = strrep(matlabroot,'\','/');
        
        keywords = { ...
            'target', 'include', 'exclude', 'license', 'substitute', ...
            'insert', 'expect', 'allow', 'remove', 'replace', 'move' ...
        };
        varPat = '\$\w+';  % Pattern for variables, i.e., $MATLABROOT
        allTargets = 'all';
    end
    
    methods(Access = public)
        
        function obj = Schema
            initProperties(obj);
            initVariables(obj);
        end
        
        function delete(obj)
            if ~isempty(obj.depDepot)
                obj.depDepot.disconnect;
                obj.depDepot = [];
            end
        end

        function setVariable(obj, var, value)
        % Inject a new variable into the common block.
            obj.commonBlock(...
                    matlab.depfun.internal.Schema.esc(var)) = value;
        end

        % Return an array of structures containing the includes required by
        % any rules that apply to the input file. The structure contains
        % two fields, .path and .language. If a dependency is non-executable, 
        % set .language to 'Data'.
        function files = statutoryIncludes(obj, target, file)
            files = tbxIncludes(obj, target, file);           
        end

        % Return an array of structures containing the includes required by
        % the toolbox containing file. The structure contains two fields,
        % .path and .language. If a dependency is non-executable, set
        % .language to 'Data'.
        function dependencies = tbxIncludes(obj, target, file)
            dependencies = struct([]);
            file = strrep(file,'\','/');  % Canonicalize path sep.
            tbx = obj.whichToolboxOwns(file);
            if ~isempty(tbx) && isKey(obj.includeBaseline, tbx)
                tbxbaseline = obj.includeBaseline(tbx);
                tgt = matlab.depfun.internal.Target.int(target);
                if isKey(tbxbaseline, tgt)
                    % Uniform output, for once!
                    dependencies = ...
                        cellfun((@(d)struct('path', d, 'language', ...
                        whatLanguage(obj, d))), tbxbaseline(tgt));
                end
            end
        end
        
        function allowed = isAllowed(obj, fileSet, target, fcn)
        % isAllowed Is the file allowed in the file set for the target?
        % An "allowed" file may form part of a completion even if it is
        % expected. Files that are not explicitly allowed become part of the
        % completion only if they are not expected.

            vectorize = iscell(fcn);
            if vectorize
                allowed = false(size(fcn));
            else
                allowed = false;
            end
           
            target = matlab.depfun.internal.Target.int(target); 
            fcn = strrep(fcn,'\','/');  % Rules lists uses /

            if isKey(obj.allowList, target)
                tgtMap = obj.allowList(target);
                if isKey(tgtMap, fileSet)
                    rules = tgtMap(fileSet);
                    k=1;
                    while (k <= numel(rules) && ~all(allowed))
                        matched = regexp(fcn, rules{k}, 'once');
                        if vectorize
                            matched = ~cellfun('isempty', matched);
                            % Now mark the fcn as allowed.
                            allowed = allowed | matched;
                        else
                            allowed = allowed | ~isempty(matched);
                        end
                        
                        % Next rule that might allow a file.
                        k = k + 1;
                    end
                end
            end
        end

        function [expected, why] = isExpected(obj, target, fcn)
            [expected, why] = isListed(obj.expectList, target, fcn);
        end

        function [excluded, why] = isExcluded(obj, target, fcn)
            [excluded, why] = isListed(obj.excludeList, target, fcn);
        end

        function [xformedSet, rMap] = ...
                applySetRules(obj, target, setName, origMembers)
        % Apply rules to a given set. Typically, the rules will add or remove
        % members from the set.
            xformedSet = origMembers;
            rMap = containers.Map;
            target = char(target);
            % If there are set operations registered for this target (by
            % INSERT or REMOVE rules in a rules file), then check to see
            % if the rules apply to the input set.
            if isKey(obj.setOperations, target)
                targetOperations = obj.setOperations(target);
                if isKey(targetOperations, setName);
                    operations = targetOperations(setName);
                    % Rules for the set and target exist; apply them all,
                    % in order.
                    for n=1:numel(operations)
                        xformedSet = feval(operations{n}, xformedSet, rMap);
                    end
                end
            end
        end
        
        function addRules(obj, file)
            obj.activeRulesFile = file;
            ruleFcnDir = tempname;
            rds = exist(ruleFcnDir,'dir');
            if rds == 0
                mkdir(ruleFcnDir)
            else
                error(message(...
                    'MATLAB:depfun:req:InternalCreateRulesDirFail',...
                    ruleFcnDir))
            end
            
            [fcn,pth] = codify(obj, ruleFcnDir, file);
            
            % This should never happen (codify creates this file)
            e = exist(pth,'file');
            if e ~= 2
                error(message(...
                    'MATLAB:depfun:req:InternalRulesFileMustExist', ...
                    pth))
            end

            % Put the temp directory on the path, so we can run the
            % rules file.
            addpath(ruleFcnDir);

            % Neither should this (rehash should make sure we find it)
            e = exist(fcn,'file');
            if e ~= 2
                error(message(...
                    'MATLAB:depfun:req:InternalRulesFileMustRun', ...
                    fcn, e))
            end

            % Catch any exception, so we can do cleanup
            rulesFileError = [];
            try
                feval(fcn, obj);
            catch me
                rulesFileError = me;
            end
            
            % Take the temp directory off the path, to avoid polluting the
            % user's environment
            rmpath(ruleFcnDir);

            % There is a known sporadic issue in Windows API.
            % Try three times to remove the directory.
            for tt = 1:3
                if exist(ruleFcnDir, 'dir')
                    try
                        % Delete this temporary file and the directory
                        % that contains it.
                        succeeded = rmdir(ruleFcnDir, 's');
                        if succeeded
                            break;
                        end
                    catch
                    % Do nothing. Just try again.
                    end
                end
            end
            % If succeeded is false or undefined when it reaches this 
            % point, the temp directory has not been removed.
            
            obj.activeRulesFile = '';
            % If there was an exception, rethrow it.
            if ~isempty(rulesFileError)
                rethrow(rulesFileError);
            end
        end
                        
        function why = getExclusionReason(obj, target)
            why = obj.excludeList.getReason(target);
        end
    end
        
    % Static class methods used for implementation only. 
    methods (Static, Access = private)
        
        % Escape regular expression special characters -- all of them!
        % Probably overkill, since many of these characters can't appear in
        % valid filenames.
        function str = esc(str)
             str = regexprep(str, ...
     {'\\', '\$', '\(',  '\)',  '\.',  '\*',  '\|',  '\^',  '\+',  '\?',  '\{',  '\}'}, ...
     {'/', '\\$', '\\(', '\\)', '\\.', '\\*', '\\|', '\\^', '\\+', '\\?', '\\{', '\\}'} ...
                 );
        end
        
        % Expand file name patterns. Be Like UNIX (always good advice, 
        % when it comes to the file system).
        function files = glob(pattern)
            % Find the directory containing the files in the pattern. Three
            % possibilities for it's structure: 
            %   * relative path
            %   * absolute path
            %   * empty
            [root,~,~] = fileparts(pattern);
            if ~isempty(root), root = [root '/']; end
            
            % Get the list of files matching the pattern. The names of
            % these files are relative to the directory specified in the
            % pattern (or pwd, if none).
            files = dir(pattern);
                      
            % Extract list of names, eliminating pesky filesystem 
            % cairns . and .. (Look for a pattern matching either of 
            % these pieces of cruft in the name list, and use cellfun and
            % isempty to build a logical index that extracts only those 
            % names that aren't . or ..).
            files = {files.name};
            files = files(cellfun(@isempty,(regexp(files, '^[.][.]?'))));
            
            % Prefix each file with the directory that contains it.
            % Avoid fullfile here, due to its pernicious path separator
            % canonicalization.
            files = cellfun(@(f)[root,f], files, ...
                            'UniformOutput', false);
        end
        
        % Expand all the filename patterns in the list
        function files = expandPatterns(list, root)
            % Null root means the files on the list are specified by
            % absolute path.
            if nargin == 1
                root = ''; 
            else
                if root(end) ~= '/'
                    root = [root '/'];
                end
            end
            
            % Match patterns on the list against the files in the root.
            % Use [] instead of fullfile, since fullfile also canonicalizes
            % the path separator for the current platform. And on Windows,
            % that means / changes to \. And we all know that / is the ONE
            % TRUE PATH SEPARATOR.
            files = cellfun(...
                @(p)matlab.depfun.internal.Schema.glob([root p]), ...
                            list, 'UniformOutput', false);
            files = [files{:}];     
        end
        
        % Look at a list (cell array) of file names and return the indices
        % of all those that are specified by absolute path. Use a pattern
        % that works on both UN*X and Windows. Return a logical index.
        function idx = absolutePaths(list)
            idx = ~cellfun(@isempty, ...
                 cellfun(@(f)regexp(f, '^(([\[\]A-Za-z]+[:][\\/])|([\\/]))'),...
                         list, 'UniformOutput', false));
        end
    end
    
    % Implementation methods. Property set/get methods must appear in 
    % methods block with no attributes.

    methods
        function set.depDepot(obj, db_path)
            if ~isempty(obj.depDepot)
                obj.depDepot.disconnect;
            end
            if ~isempty(db_path) && numel(db_path) > 0
                obj.depDepot = matlab.depfun.internal.DependencyDepot(...
                    db_path, true);
            else
                obj.depDepot = [];
            end
        end
    end

    methods(Access = private)
        
        function initProperties(obj)

            % Guess my favorite MATLAB data structure.
            % I won't make you guess my favorite function: cellfun!

            obj.excludeList = matlab.depfun.internal.WhyList(...
                'MATLAB:depfun:req:InternalNoExclusions');

            obj.expectList = matlab.depfun.internal.WhyList(...
                'MATLAB:depfun:req:InternalNoExpected');

            obj.commonBlock = containers.Map;
            obj.currentLicense = '';
            obj.includeBaseline = containers.Map;
            obj.setOperations = containers.Map;
            obj.allowList = containers.Map('KeyType', 'int32', ...
                'ValueType', 'any');
            
            obj.fileClassifier = matlab.depfun.internal.FileClassifier();
            
            obj.Environment = matlab.depfun.internal.reqenv;
            obj.PathUtility = matlab.depfun.internal.PathUtility;
        end

        function initVariables(obj)
            % Escape regexp-fooling characters in the full path to the
            % MATLAB root. If there's a drive letter in the path, replace
            % it with [Xx], which will regexp-match a drive letter of any
            % case. 
            mlroot =  matlab.depfun.internal.Schema.esc(matlabroot);
            driveLetter = '^\w[:]';  % Pattern matching a drive letter.
            if ispc && ~isempty(regexp(mlroot, driveLetter, 'once'))
                mlroot = [ '[' upper(mlroot(1)) lower(mlroot(1)) ']:', ...
                          mlroot(3:end) ];
            end
            
            % Set values for standard variables used in dependency files.
            obj.commonBlock(...
                matlab.depfun.internal.Schema.esc('$MATLABROOT')) = ...
                mlroot;
             
            obj.commonBlock(...
                matlab.depfun.internal.Schema.esc('$ARCH')) = ...
                matlab.depfun.internal.Schema.esc(computer('arch'));
            
            obj.commonBlock(...
                matlab.depfun.internal.Schema.esc('$TOOLBOX')) = ...
                [mlroot '/' ...
                strrep(obj.Environment.RelativeToolboxRoot,filesep,'/')];
        end
         
        function list = scopeFilesToToolbox(obj, list)
            % Chop the @!@ list terminator off the end of the list, since
            % it isn't a meaningful file name.
            list = list(1:end-1);
            
            % The list of files is a cell array; always the last
            % argument. Make sure the files use the / path separator.
            list = bindVars(obj, strrep(list,'\','/'));
            
            % Remove patterns specified by absolute path from the
            % list (temporarily) so we can prefix the relative path
            % patterns with the full path to the toolbox root.
            absIdx = matlab.depfun.internal.Schema.absolutePaths(list);
            absPath = list(absIdx);   % Absolute path
            list = list(~absIdx);     % Relative path
            
            % Prefix each relative path in the list with the full path 
            % to the toolbox root. This scopes relative path rules to
            % individual toolboxes.
            %
            % The compiler toolbox is not subject to this restriction.
            % (Incredible cosmic power! Itty bitty living space.)
            if ~strcmp(obj.currentTbxName, 'compiler')
                % Make sure to use / in rules, or pattern match
                % will fail: Aiieeeee...into the abyss. And don't use the
                % fiendish fullfile, which surreptitiously canonicalizes
                % path separators.
                tbxDir = strrep(toolboxdir(obj.currentTbxName),'\','/'); 
                list = cellfun(@(p)[tbxDir '/' p], ...
                               list, 'UniformOutput', false);
            end
            
            % Put the patterns specified by absolute path back into the
            % list.
            list = [list absPath];
        end
        
        % Determine which toolbox owns a given file (it is possible that
        % the file is a free agent, bound to no one).
        function tbx = whichToolboxOwns(obj,file)
            tbx = '';
            % It's only in a toolbox if it lives under 
            % <matlabroot>/toolbox.
            match = obj.PathUtility.componentBaseDir(file);
            if ~isempty(match)
                tbx = match{1}{1};
            end
        end

        % Strip the MATLAB root from a file path
        function relative = stripMLRoot(obj, pth)
            relative = strrep(pth, [obj.MatlabRoot '/'], '');
        end
        
        function [tline,statement] = statement2fcn(obj, tline)  
            % Currently, these statements: 
            %   license, include, exclude, using and if.
            origLine = tline;
                       
            % LICENSE
            %   license Image_Processing_Toolbox, images
            tline = regexprep(tline, 'license\s+(\S*),\s*(\S*)\s*', ...
                          'license(rules, ''$1'', ''$2'', ''start'');'); 
                      
            % ALLOW
            tline = regexprep(tline, 'allow\s+(\w+)\s+(\w+)\s*\[,', ...
                                     'allow(rules, ''$1'', ''$2'', {');

            % INSERT
            tline = regexprep(tline, 'insert\s+(\w+)\s+(\w+)\s*\[,', ...
                                     'insert(rules, ''$1'', ''$2'', {');

            % REMOVE
            tline = regexprep(tline, 'remove\s+(\w+)\s+(\w+)\s*\[,', ...
                                     'remove(rules, ''$1'', ''$2'', {');

            % REPLACE
            tline = regexprep(tline, 'replace\s+(\w+)\s+(\w+)\s*\[,', ...
                                     'replace(rules, ''$1'', ''$2'', {');
                                 
            % SUBSTITUTE
            tline = regexprep(tline, 'substitute\s+(\w+)\s+(\w+)\s+(\w+)\s*\[,', ...
                                     'substitute(rules, ''$1'', ''$2'', ''$3'', {');  
                                 
            % MOVE
            tline = regexprep(tline, 'move\s+(\w+)\s+(\w+)\s+(\w+)\s*\[,', ...
                                     'move(rules, ''$1'', ''$2'', ''$3'', {');                                 
            % INCLUDE
            tline = regexprep(tline, 'include\s+(\w*)\s*\[,', ...
                                     'include(rules, ''$1'', {');
            
            % EXCLUDE
            tline = regexprep(tline, 'exclude\s+(\w*)\s*\[,', ...
                                     'exclude(rules, ''$1'', {');

            % EXPECT
            tline = regexprep(tline, 'expect\s+(\w*)\s*\[,', ...
                                     'expect(rules, ''$1'', {');
                        
            % USING
            tline = regexprep(tline, 'using\s+(\S*)\s', ...
                                     'using(rules, ''$1'') ');
           
            % IF
            % Needs to go last, as it takes advantage of previous changes
            % to the syntax.
            tline = regexprep(tline, ...
                 'if\s+(\w+\([^)]+\))\s+(.*)(({ \.\.\.)|\);)', ...
                 '$2@()$1, $3');
           
            % The line was a statement if this function changed it.
            statement = (strcmp(origLine,tline) == 0);
        end
        
        function [fcn, pth] = codify(obj, ruleFcnDir, file)
            % Transform a depfun rules file into executable MATLAB.
            % Write the MATLAB function to a temporary file.
            % Return the function name and full path to the file.
            %
            % This is a very intolerant and pedantic parser. It does not
            % consider \n as whitespace in statements. 
            
            %TODO: Hack name to help MCC's MCR find it. Name must exist as a
            %MATLAB file on the MATLAB path before MCC starts. What a PIA!
            %pth = 'compiler_rules.m';
            %pth = [tempname(obj.ruleFcnDir) '.m'];
            pth = fullfile(ruleFcnDir, 'compiler_rules.m');
            [~,fcn,~] = fileparts(pth);
            clear(fcn);            
            
            ffp = fopen(pth,'w');
            if ffp < 0
                error(message(...
                    'MATLAB:depfun:req:InternalCreateRulesFileFail',...
                    pth))
            end
            
            fprintf(ffp, 'function %s(rules)\n', fcn);
            
            % Loop over every line in the dependency rules file
            rfp = fopen(file, 'r');
            if rfp < 0
                error(message(...
                    'MATLAB:InternalRDLFileMustExist', file));
            end
            
            listLine = -1;
            lineNumber = 0;
            while 1
                tline = fgetl(rfp);
                lineNumber = lineNumber + 1;
                
                % EOF -- notify rules object that we've processed the
                % license.
                if ~ischar(tline)
                    fprintf(ffp,'license(rules,''end'');');
                    break
                end 
 
                % Blank lines are boring
                if isempty(tline)
                    continue;
                end
                
                % Write out comments unmodified (but discard comments in a
                % list).
                if ~isempty(regexp(tline, '^\s*%', 'once'))
                    if listLine == -1
                        fprintf(ffp, '%s\n', tline);
                    end
                    continue;
                end
                
                % Convert keywords to lower case
                tline = regexprep(tline, obj.keywords, obj.keywords, ...
                                  'ignorecase');
                                            
                if ~isempty(regexp(tline,'\[\s*(%.*)?$','once'))
                    listLine = 0;
                end 
                
                % Add ... line endings to [] lists
                if listLine >= 0
                    if ~isempty(regexp(tline,'\]\s*(%.*)?$','once'))
                        listLine = -1;
                    end
                    if listLine == -1  % Came to the end of the list
                        tline = strrep(tline,']','''@!@''});');
                    else
                        % Quote quotes
                        tline = strrep(tline,'''', '''''');
                        
                        % Trim leading and trailing space
                        tline = regexprep(tline,'^\s*(.*)\s+', '$1');
                        if listLine > 0
                            tline = ['''' tline ''''];
                        end
                        tline = [tline ', ...'];
                        listLine = listLine + 1;
                    end
                end
                
                % Convert statements to functions -- tricky...
                [tline,statement] = statement2fcn(obj, tline);
                
                % In front of every statement line, add a 
                % call to the 'line' function, which allows errors to
                % refer back to the lines in the original file.
                if statement
                    fprintf(ffp, 'rulesLine(rules, %d);\n', lineNumber);
                end
                
                % Write the modified line to the function file. 
                fprintf(ffp, '%s\n', tline);
            end        
            
            % Close the new file (and the old one)
            fclose(ffp);
            fclose(rfp);
        end

        % Use the file extension to determine the language used by the code
        % inside the file. (Or 'Data', if the file extension doesn't match
        % a known language.)
        function lang = whatLanguage(obj, file)
            lang = obj.fileClassifier.classify(file);
        end
        
        % Construct a well-formatted exclude message.
        function msg = formatExcludeMsg(obj, target)
            msg = msg2why(message('MATLAB:depfun:req:ExcludedBy', ...
                                    target, obj.currentLicense));
        end
        
        % Construct a well-formatted exclude message.
        function msg = formatRequireMsg(obj, target)
            msg = msg2why(message('MATLAB:depfun:req:ExpectedBy', ...
                                    target, obj.currentLicense));
        end
        
        function list = bindVars(obj, exprList)
            % Expand variables, in the most delightful way. Wheels within
            % wheels. So much iteration in one little line.
            % 
            % The only \ characters in obj.commonBlock.values serve to
            % escape the following character -- but regexprep seems to eat
            % them, so double them up before calling regexprep.
            list = cellfun(@(p)regexprep(p, obj.commonBlock.keys, ...
                   strrep(obj.commonBlock.values,'\','\\')), exprList, ...
                                   'UniformOutput', false);     
        end 
    
    end
    
    % Methods used by the generated functions -- these methods constitute
    % the actions in the dependency file language.
    methods (Access = public)
        
        % Add a list of files to the exclude list for a given target. If
        % no target is specified, files are excluded from all targets.

        function exclude(obj, varargin)
            target = obj.allTargets;
            % With two arguments, the first is a target name
            if nargin > 2, 
                target = matlab.depfun.internal.Target.int(varargin{1}); 
                targetStr = matlab.depfun.internal.Target.str(target);
            end
            
            % Relative paths lie beneath root of toolbox containing rules file
            list = scopeFilesToToolbox(obj, varargin{nargin-1});
            
            % Add the excluded files and patterns to the exclude list
            append(obj.excludeList, list, target, ...
                   @()formatExcludeMsg(obj, targetStr));

        end

        function rulesLine(obj, n)
            obj.activeRulesLine = n;
        end
        
        function expect(obj, varargin)
            target = obj.allTargets;
            % With two arguments, the first is a target name
            if nargin > 2
                target = matlab.depfun.internal.Target.int(varargin{1}); 
                targetStr = matlab.depfun.internal.Target.str(target);
            end
            
            if varargin{1} == matlab.depfun.internal.Target.MCR
                nv = matlab.depfun.internal.ProductComponentModuleNavigator();
                list = nv.MatlabModulesInMatlabRuntime();
                % Consolidate all directories under toolbox/matlab into one
                % entry, $MATLABROOT/toolbox/matlab/.
                tbx_matlab = fullfile(matlabroot,'toolbox/matlab/');
                list(contains(list, tbx_matlab)) = [];
                list = strcat(list, filesep);
                list = [tbx_matlab; list];
                % Honor the syntax of the .rdl file.
                list = strrep(list, matlabroot, '$MATLABROOT');
                list = strrep(list, filesep, '/');
                list = [list; '@!@'];
                % Use the same function to convert the list to patterns
                list = scopeFilesToToolbox(obj, list);
            else
                % Relative paths lie beneath root of toolbox containing rules file
                list = scopeFilesToToolbox(obj, varargin{nargin-1});
            end
            % Add the required files and patterns to the required files list
            append(obj.expectList, list, target, ...
                   @()formatRequireMsg(obj, targetStr));

        end
        
        function tgtMap = allowMap(obj, target, setName)
            
            % Convert target name to integer
            target = matlab.depfun.internal.Target.int(target); 

            % If there's no allow list for this target, create one
            if ~isKey(obj.allowList, target)
                obj.allowList(target) = containers.Map;
            end

            % Add the file patterns (append them to any existing patterns)
            tgtMap = obj.allowList(target);

            if ~isKey(tgtMap, setName)
                tgtMap(setName) = {};
            end
        end
        
        function allowLiteral(obj, target, setName, literal)
        % allowLiteral Add literal file strings to the allow list. Escape
        % any regexp characters in the literal strings.
            if nargin ~= 4
                error(message(...
                      'MATLAB:depfun:req:RDLAllowBadArgCount', ...
                      obj.activeRulesFile, obj.activeRulesLine, nargin))
            end
            literal = scopeFilesToToolbox(obj, literal);
            literal = matlab.depfun.internal.Schema.esc(literal);
            tgtMap = allowMap(obj, target, setName);

            % g1138216 ssegench
            % only add the difference to the map
            tgtMap(setName) = union(tgtMap(setName), literal);
           
            
        end
        
        function allow(obj, varargin)
        % Allow Add file patterns to the allow list for a given target
            if nargin ~= 4
                error(message(...
                      'MATLAB:depfun:req:RDLAllowBadArgCount', ...
                      obj.activeRulesFile, obj.activeRulesLine, nargin))
            end

            setName = varargin{2};
            tgtMap = allowMap(obj, varargin{1}, setName);
           
            % Relative paths lie beneath root of toolbox containing rules file
            list = scopeFilesToToolbox(obj, varargin{nargin-1});
            
            % g1138216 ssegench
            % only add the difference to the map
            tgtMap(setName) = union(tgtMap(setName), list);

        end
        
         
        function replace(obj, varargin)
        % REMOVE Create rules that replace files in a named set.
            if nargin ~= 4
                error(message(...
                      'MATLAB:depfun:req:RDLReplaceBadArgCount', ...
                      obj.activeRulesFile, obj.activeRulesLine, nargin))
            end
            
            % Chop the @!@ list terminator off the end of the list, since
            % it isn't a meaningful file name.
            list = varargin{nargin-1};
            list = list(1:end-1);
            
            target = varargin{1};
            setName = varargin{2};
            
            if ~isKey(obj.setOperations, target)
                obj.setOperations(target) = containers.Map;
            end
            
            % Transform the input expressions into anonymous functions
            % taking a single input, the set contents.
            fcnList = cell(1,numel(list)-2);
            for n=1:numel(list)
                
                % Rules take the form 'predicate ? reason' where both
                % predicate and reason are MATLAB expressions. predicate
                % takes a single argument (a list of files) and returns a
                % logical array indicating if any files should be removed
                % from the list. reason evaluates to a string that explains
                % why the files are being removed from the list.
                
                m = regexp(list{n},'(?<transform>.*)\s*[?]\s*(?<reason>.*)',...
                           'names');
                       
                if isempty(m)
                    error(message(...
                        'MATLAB:depfun:req:RDLBadlyFormedXFormRule',...
                        'REPLACE', n, obj.activeRulesFile, ...
                        obj.activeRulesLine, target))
                end
                
                % Create MATLAB expression defining an anonymous function.
                % The function replaces the contents of the set with the 
                % result of the operation on the contents of the set. 
                %
                % The name of the set (for example, ROOTSET or COMPLETION)
                % must appear in the expression. It will be prefixed with a
                % #, to distinguish it from valid MATLAB syntax. Replace
                % the #<set name> string with the name of the anonymous
                % function's input variable.
                op = strrep(['@(setMembers)' m.transform ], ...
                            ['#' setName],'setMembers');

                % If the string #SCHEMA appears in the predicate, replace it
                % with a reference to this Schema object.
                op = strrep(op,'#SCHEMA','obj');

                % Evaluate the MATLAB expression to create an anonymous
                % function.
                op = eval(op);
                
                % The reason expression may contain '#FILE', for which the 
                % name of the replaced file must be substituted. Create an
                % anonymous function which will generate a removal reason
                % when given a file's name.
                reason = strrep(['@(file,rule)' m.reason], '#FILE', 'file');
                reason = strrep(reason, '#RULE', 'rule');
                reason = eval(reason);
                
                % Store an anonymous function that invokes the local
                % applyReplaceFcn with the newly created filter function
                % (op) and reason-generator function (reason).
                %
                % Dynamic languages are awesome.
                rule = sprintf('REPLACE %s: %s', setName, m.transform);
                fcnList{n} = ...
                    @(files, notes)...
                    applyReplaceFcn(op, files, notes, reason, rule);
            end
            
            % Retrieve the set of operations for this target.
            ops = obj.setOperations(target);

            % If there are as yet no operations for the input set name,
            % initialize the list of operations to an empty cell arry.
            if ~isKey(ops, setName)
                ops(setName) = {};
            end
                       
            % Append the replace rules for this set to any existing rules
            % for this set.
            ops(setName) = [ ops(setName) fcnList ];  %#ok    
 
        end       

        function remove(obj, varargin)
        % REMOVE Create rules that remove files from a named set.
            if nargin ~= 4
                error(message(...
                      'MATLAB:depfun:req:RDLRemoveBadArgCount', ...
                      obj.activeRulesFile, obj.activeRulesLine, nargin))
            end
            
            % Chop the @!@ list terminator off the end of the list, since
            % it isn't a meaningful file name.
            list = varargin{nargin-1};
            list = list(1:end-1);
            
            target = varargin{1};
            setName = varargin{2};
            
            if ~isKey(obj.setOperations, target)
                obj.setOperations(target) = containers.Map;
            end
            
            % Transform the input expressions into anonymous functions
            % taking a single input, the set contents.
            fcnList = cell(1,numel(list)-2);
            for n=1:numel(list)
                
                % Rules take the form 'predicate ? reason' where both
                % predicate and reason are MATLAB expressions. predicate
                % takes a single argument (a list of files) and returns a
                % logical array indicating if any files should be removed
                % from the list. reason evaluates to a string that explains
                % why the files are being removed from the list.
                
                m = regexp(list{n},'(?<predicate>.*)\s*[?]\s*(?<reason>.*)',...
                           'names');
                       
                if isempty(m)
                    error(message('MATLAB:depfun:req:RDLBadlyFormedXFormRule',...
                                  'REMOVE', n, obj.activeRulesFile, ...
                                  obj.activeRulesLine, target))
                end
                
                % Create MATLAB expression defining an anonymous function.
                % The function subtracts the result of the operation from
                % the existing contents of the set. The operation must
                % return a logical index the same size as the set.
                %
                % The name of the set (for example, ROOTSET or COMPLETION)
                % must appear in the expression. It will be prefixed with a
                % #, to distinguish it from valid MATLAB syntax. Replace
                % the #<set name> string with the name of the anonymous
                % function's input variable.
                op = strrep(['@(setMembers)setMembers(~' m.predicate ')'], ...
                            ['#' setName],'setMembers');

                % If the string #SCHEMA appears in the predicate, replace it
                % with a reference to this Schema object.
                op = strrep(op,'#SCHEMA','obj');

                % Evaluate the MATLAB expression to create an anonymous
                % function.
                op = eval(op);
                
                % The reason expression may contain '#FILE', for which the 
                % name of the removed file must be substituted. Create an
                % anonymous function which will generate a removal reason
                % when given a file's name.
                reason = strrep(['@(file,rule)' m.reason], '#FILE', 'file');
                reason = strrep(reason, '#RULE', 'rule');
                reason = eval(reason);
                
                % Store an anonymous function that invokes the local
                % applyRemoveFcn with the newly created filter function
                % (op) and reason-generator function (reason).
                %
                % Dynamic languages are awesome.
                rule = sprintf('REMOVE %s: %s', setName, m.predicate);
                fcnList{n} = ...
                    @(files, notes)...
                    applyRemoveFcn(op, files, notes, reason, rule);
            end
            
            % Retrieve the set of operations for this target.
            ops = obj.setOperations(target);

            % If there are as yet no operations for the input set name,
            % initialize the list of operations to an empty cell arry.
            if ~isKey(ops, setName)
                ops(setName) = {};
            end
                       
            % Append the remove rules for this set to any existing rules
            % for this set.
            ops(setName) = [ ops(setName) fcnList ];  %#ok    
 
        end       
        
        function move(obj, varargin)
        % MOVE Create rules that move files between named sets
            if nargin ~= 5
                error(message(...
                      'MATLAB:depfun:req:RDLMoveBadArgCount', ...
                      obj.activeRulesFile, obj.activeRulesLine, nargin))
            end
            
            % Chop the @!@ list terminator off the end of the list, since
            % it isn't a meaningful file name.
            list = varargin{nargin-1};
            list = list(1:end-1);
            
            target = varargin{1};
            srcSet = varargin{2};
            destSet = varargin{3};
            
            if ~isKey(obj.setOperations, target)
                obj.setOperations(target) = containers.Map;
            end
            
            % Transform the input expressions into anonymous functions
            % taking a single input, the set contents.
            fcnList = cell(1,numel(list));
            for n=1:numel(list)        

                % Split the input line into predicate and reason, two 
                % MATLAB expressions that must be evaluated.
                m = regexp(list{n},'(?<predicate>.*)\s*[?]\s*(?<reason>.*)',...
                           'names');
                       
                if isempty(m)
                    error(message('MATLAB:depfun:req:RDLBadlyFormedXFormRule',...
                        'MOVE', n, obj.activeRulesFile, obj.activeRulesLine, ...
                        target))
                end
                
                % Create MATLAB expression defining an anonymous function.
                % The function filters the contents of the input set
                % against the MOVE predicate.
                %
                % See the EVAL comment in remove() for an explanation of
                % what's going on with the # here.
                op = strrep(['@(setMembers)setMembers(~' m.predicate ')'], ...
                            ['#' srcSet],'setMembers');
                op = eval(op);
                
                reason = strrep(['@(file,rule)' m.reason], '#FILE', 'file');
                reason = strrep(reason, '#RULE', 'rule');
                reason = eval(reason);                
                
                % Store an anonymous function that invokes the local
                % applyMoveFcn with the newly created filter function
                % (op) and destination information (destMap and destSet).
                
                rule = sprintf('MOVE %s %s: %s', srcSet, destSet, m.predicate);

                fcnList{n} = ...
                    @(files, destMap)applyMoveFcn(op, files, destMap, ...
                                                  destSet, reason, rule);                        
                        
            end
            
            % Add all the move operations to the list of rules for the
            % source set of the indicated target.
            ops = obj.setOperations(target);

            if ~isKey(ops, srcSet)
                ops(srcSet) = {};
            end
            
            % Append the insert rules for this set to any existing rules
            % for this set.
            ops(srcSet) = [ ops(srcSet) fcnList ];  %#ok
        end
        
        function substitute(obj, varargin)
        % SUBSTITUTE Create rules that replace files in one set and move
        % them to another. Substitute is a combination MOVE and REPLACE.
        
            if nargin ~= 5
                error(message(...
                      'MATLAB:depfun:req:RDLSubstituteBadArgCount', ...
                      obj.activeRulesFile, obj.activeRulesLine, nargin))
            end
            
            % Chop the @!@ list terminator off the end of the list, since
            % it isn't a meaningful file name.
            list = varargin{nargin-1};
            list = list(1:end-1);
            
            target = varargin{1};
            srcSet = varargin{2};
            destSet = varargin{3};
            
            if ~isKey(obj.setOperations, target)
                obj.setOperations(target) = containers.Map;
            end
            
            % Transform the input expressions into anonymous functions
            % taking a single input, the set contents.
            fcnList = cell(1,numel(list));
            for n=1:numel(list)        

                % Split the input line into transform and reason, two 
                % MATLAB expressions that must be evaluated.
                m = regexp(list{n},'(?<transform>.*)\s*[?]\s*(?<reason>.*)',...
                           'names');
                       
                if isempty(m)
                    error(message('MATLAB:depfun:req:RDLBadlyFormedXFormRule',...
                        'MOVE', n, obj.activeRulesFile, obj.activeRulesLine, ...
                        target))
                end
                
                % Create MATLAB expression defining an anonymous function.
                % The function modifies the contents of the input set
                % using the SUBSTITUTE transfrom.
                %
                % See the EVAL comment in remove() for an explanation of
                % what's going on with the # here.
                op = strrep(['@(setMembers)' m.transform ], ...
                            ['#' srcSet],'setMembers');
                op = eval(op);
                
                reason = strrep(['@(file,rule)' m.reason], '#FILE', 'file');
                reason = strrep(reason, '#RULE', 'rule');
                reason = eval(reason);                
                
                % Store an anonymous function that invokes the local
                % applyMoveFcn with the newly created filter function
                % (op) and destination information (destMap and destSet).
                
                rule = sprintf('SUBSTITUTE %s %s: %s', srcSet, destSet, m.transform);

                fcnList{n} = ...
                    @(files, destMap)applySubstituteFcn(op, files, destMap, ...
                                                  destSet, reason, rule);                        
                        
            end
            
            % Add all the substitute operations to the list of rules for the
            % source set of the indicated target.
            ops = obj.setOperations(target);

            if ~isKey(ops, srcSet)
                ops(srcSet) = {};
            end
            
            % Append the insert rules for this set to any existing rules
            % for this set.
            ops(srcSet) = [ ops(srcSet) fcnList ];  %#ok
        end
        
        function insert(obj, varargin)
        % INSERT Create rules that add files to a named set.
            if nargin ~= 4
                error(message(...
                      'MATLAB:depfun:req:RDLInsertBadArgCount', ...
                      obj.activeRulesFile, obj.activeRulesLine, nargin))
            end
            
            % Chop the @!@ list terminator off the end of the list, since
            % it isn't a meaningful file name.
            list = varargin{nargin-1};
            list = list(1:end-1);
            
            target = varargin{1};
            setName = varargin{2};
            
            if ~isKey(obj.setOperations, target)
                obj.setOperations(target) = containers.Map;
            end
            
            % Transform the input expressions into anonymous functions
            % taking a single input, the set contents.
            fcnList = cell(numel(list)-2);
            for n=1:numel(list)
                
                % Create MATLAB expression defining an anonymous function.
                % The function concatenates the result of operation with
                % the existing contents of the set.
                %
                % See the EVAL comment in remove() for an explanation of
                % what's going on with the # here.
                op = strrep(['@(setMembers,notes)[setMembers ' list{n} ']'], ...
                            ['#' setName],'setMembers');
                
                % So evil. So awesome. Create a live anonymous
                % function from the input expression.
                fcnList{n} = eval(op); 
                
            end
            
            ops = obj.setOperations(target);

            if ~isKey(ops, setName)
                ops(setName) = {};
            end
            
            % Append the insert rules for this set to any existing rules
            % for this set.
            ops(setName) = [ ops(setName) fcnList ];  %#ok
            
        end
        
        function include(obj, varargin)
        % Add a list of files to the include baseline -- this means that
        % all the files in the given toolbox depend on these files.   
            target = obj.allTargets;
            % With two arguments, the first is a target name
            if nargin > 2, 
                target = matlab.depfun.internal.Target.int(varargin{1}); 
            end
            
            % Chop the @!@ list terminator off the end of the list, since
            % it isn't a meaningful file name.
            list = varargin{nargin-1};
            list = list(1:end-1);
            
            % The list of file include patterns is a cell array; always 
            % the last argument. Make sure the files use the / path 
            % separator. 
            list = bindVars(obj,strrep(list,'\','/')); 
            
            % Filter the list of files specified by absolute path onto
            % their own list. They won't survive the toolbox-relativization
            % process below otherwise.
            absIdx = matlab.depfun.internal.Schema.absolutePaths(list);
            absPath = list(absIdx);   % Absolute path
            list = list(~absIdx);     % Relative path
            
            tbxDir = strrep(toolboxdir(obj.currentTbxName), '\','/');
            absPath = matlab.depfun.internal.Schema.expandPatterns(absPath);
            files = matlab.depfun.internal.Schema.expandPatterns(list, tbxDir);
             
            files = [files absPath];  % Add back absolute file paths
            % Add the list of files to the baseline include list. A file
            % may be included for one or more targets, so maintain a set of
            % targets.
            %
            % Create an include baseline for each toolbox
            if ~isKey(obj.includeBaseline, obj.currentTbxName)
                obj.includeBaseline(obj.currentTbxName) = ...
                    containers.Map('KeyType', 'int32', 'ValueType', 'any');
            end
            % Awesomely, includeList is a handle object, so we can treat
            % it as a reference instead of a value.
            includeList = obj.includeBaseline(obj.currentTbxName);
            if isKey(includeList, target) 
                includeList(target) = ...  
                    [includeList(target) files{:} ];  %#ok -- handle obj
            else
                includeList(target) = files;          %#ok -- handle obj
            end 
        end
        
        function license(obj, varargin)
        % Make a note of the current license. (And maybe do more 
        % interesting things later on.)
            switch nargin
                case 2
                    obj.currentLicense = '';
                case 4
                    obj.currentLicense = varargin{1};
                    obj.currentTbxName = varargin{2};
                otherwise
                  error(message(...
                      'MATLAB:depfun:req:RDLBadLicense', nargin))
            end
        end
        
        function using(obj, varargin)
        end

    end
end

%------- Local Functions -----

function rememberReplacement(reasonMap, replacement, replaced, reason, rule)
    replacedKey = '#REPLACED';
    replacementKey = '#REPLACEMENT';
    if numel(replaced) > 0
        if ~isKey(reasonMap,replacedKey)
            reasonMap(replacedKey) = {};
        end
        if ~isKey(reasonMap,replacementKey)
            reasonMap(replacementKey) = replacement;
        else
            reasonMap(replacementKey) = [ ...
                reasonMap(replacementKey) replacement ];
        end
    end

    for k=1:numel(replaced)
        reasonMap(replaced{k}) = feval(reason, replaced{k}, rule);
        reasonMap(replacedKey) = [ reasonMap(replacedKey) replaced{k} ];
    end
end


function [keptFiles, replacementIdx] = ...
        applyReplaceFcn(fcn, fileList, reasonMap, reason, rule)
% Apply a replacement function to a list of files. Record, in the reasonMap,
% why the files were replaced in the list. reasonMap must be a handle
% object, as it is not returned.

    % Apply the rule and remember the files that survive.
    keptFiles = fcn(fileList);
    
    % Compute the names and locations of the files that were replaced.
    [~, replacedIdx, replacementIdx] = setxor(fileList, keptFiles, 'legacy');
    
    % Replaced files. For example, p-file entry points.
    replacedFiles = fileList(replacedIdx);
    % Replacement files. For example, correspondent m-files for p-file
    % entry points.
    replacementFiles = keptFiles(replacementIdx); 
    
    % Make a note of why the file was replaced in the set, and add the
    % file to the list of replaced files.
    if isempty(replacementIdx)
        rememberReplacement(reasonMap, replacementFiles, replacedFiles, ...
                            reason, rule);
    end
end

function [keptFiles, rmIdx] = ...
    applyRemoveFcn(fcn, fileList, reasonMap, reason, rule)
% Apply a removal function to a list of files. Record, in the reasonMap,
% why the files were removed from the list. reasonMap must be a handle
% object, as it is not returned.

    % Apply the rule and remember the files that survive.
    keptFiles = fcn(fileList);
    % Compute the names and locations of the files that were removed.
    [name, rmIdx] = setdiff(fileList, keptFiles, 'legacy');
    % Make a note of why the file was removed from the set.
    for k=1:numel(name)
        reasonMap(name{k}) = feval(reason, name{k}, rule);
    end
end

function keptFiles = applyMoveFcn(fcn, fileList, destinationMap, ...
                                  destination, reason, rule)
% Apply a move function to a list of files. Remove the files from the list
% and enter them into the destination map.

    % Apply the rule and remember the files that were not moved.
    keptFiles = fcn(fileList);
    % Add the files that were moved to the destination map.
    dSet = {};
    if isKey(destinationMap, destination)
        dSet = destinationMap(destination);
    end
    % destinationMap must be a handle object, because this is a
    % side-effect.
    movedFiles = setdiff(fileList, keptFiles, 'legacy');
    % Don't create a set of moved files if no files moved. The empty set
    % confuses some code in Completion/initializeRootSet.
    if ~isempty(movedFiles) || ~isempty(dSet)
        destinationMap(destination) = [ movedFiles dSet];
    end
    
    % Make a note of why the file was removed from the set.
    for k=1:numel(movedFiles)
        destinationMap(movedFiles{k}) = feval(reason, movedFiles{k}, rule);
    end
end

function keptFiles = applySubstituteFcn(fcn, fileList, destinationMap, ...
                                        destination, reason, rule)
% Apply a substitute function to a list of files. Replace files with their
% substitutions on the source list and move the original files to the
% destination list. (Combination of REPLACE and MOVE.)

    % Apply the rule and remember the files that were not moved.
    keptFiles = fcn(fileList);
    
    % Add the files that were moved to the destination map.
    dSet = {};
    if isKey(destinationMap, destination)
        dSet = destinationMap(destination);
    end
    
    % destinationMap must be a handle object, because this is a
    % side-effect.
    [~, replacedIdx, replacementIdx] = setxor(fileList, keptFiles, 'legacy');
    
    % Replaced files. For example, p-file entry points.
    replacedFiles = fileList(replacedIdx);
    % Replacement files. For example, correspondent m-files for p-file
    % entry points.
    replacementFiles = keptFiles(replacementIdx);    
    
    % Don't create a set of moved files if no files moved. The empty set
    % confuses some code in Completion/initializeRootSet.
    if ~isempty(replacedFiles) || ~isempty(dSet)
        destinationMap(destination) = [ replacedFiles dSet];
    end
    
    % Make a note of why the file was replaced in the set, and add the
    % file to the list of replaced files.
    if ~isempty(replacementIdx)
        rememberReplacement(destinationMap, replacementFiles, ...
                            replacedFiles, reason, rule);
    end
end
