classdef MatlabInspector < matlab.depfun.internal.MwFileInspector
% MatlabInspector Determine what files and classes a MATLAB function requires.
% Analyze the symbols used in a MATLAB function to determine which correspond
% to functions or class methods. 

% Copyright 2012-2016 The MathWorks, Inc.

    properties (Constant)
        KnownExtensions = initKnownExtensions();
    end
    
    properties (Access = private)
        OptionalKeywordDeps
    end

    methods
        
        function obj = MatlabInspector(r, t, fsCache, useDB, fcns)
            % Pass on the input arguments to the superclass constructor
            obj@matlab.depfun.internal.MwFileInspector(r, t, fsCache, useDB, fcns);
            
            obj.OptionalKeywordDeps = initOptionalKeywordDependencies();
        end
        
        function [symbolList, unknownType] = determineType(obj, name)
        % determineType Divide names into known and unknown lists. 
        
            symbolList = {};
            unknownType = {};
            
            % validate the file name before a further investigation
            if isValidMatlabFileName(name)
                symbol = ...
                    matlab.depfun.internal.MatlabInspector.resolveType( ...
                                      name, obj.fsCache, obj.addExclusion);
                if symbol.Type ~= ...
                              matlab.depfun.internal.MatlabType.NotYetKnown
                    symbolList = symbol;
                else
                    unknownType = symbol;
                end
            else
                % WHICH returns '' for files like .foo.m, though they 
                % may be on the path. As a result, if .foo.m is passed in
                % as a relative path, WHICH cannot find its full path.
                if isfullpath(name)
                    if matlab.depfun.internal.cacheExist(name, 'file')
                        fullpath = name;
                    end
                else
                    fullpath = fullfile(pwd, name);
                    if ~matlab.depfun.internal.cacheExist(fullpath, 'file')
                        error(message('MATLAB:depfun:req:NameNotFound',name))
                    end
                end
                
                [~,symName,~] = fileparts(name);
                symbol = matlab.depfun.internal.MatlabSymbol(symName, ...
                         matlab.depfun.internal.MatlabType.Extrinsic, fullpath);
                symbolList = symbol;
            end
        end
        
    end % Public methods
    
    methods (Static)
        
        function tf = knownExtension(ext)
        % knownExtension Is the extension "owned" by MATLAB? 
            tf = isKey(matlab.depfun.internal.MatlabInspector.KnownExtensions, lower(ext));
        end
        
        %------------------------------------------------------------
        function symbol = resolveType(name, fsCache, addExc)
        % resolveType Examine a name to determine its type
        % 
        % Defer to MatlabSymbol's more perfect knowledge about symbols to
        % determine the fully qualified name of each input identifier. An
        % identifier may refer to a file on the MATLAB path or may be the
        % package-qualified name of a method or a class.
          
            if ~ischar(name)
                error(message('MATLAB:depfun:req:NameMustBeChar', ...
                              1, class(name)))
            end
            
            % TODO: Check for dot-qualified names here, maybe. The
            % names may be file names, though, which might have dots 
            % in them.
                       
            % Determine if we've been passed a file name rather than a 
            % function name.
            % G886754: If it is M-code, look for its corresponding 
            % MEX file first.
            fullpath = '';
            mExtIdx = regexp(name,'\.m$','ONCE');
            if ~isempty(mExtIdx)
                MEXname = [name(1:mExtIdx) mexext];
                [fullpath, symName, fileType] = resolveFileName(MEXname);
				% G968392: A DLL file can be a valid MEX file on win32.
				% If a DLL file coexists with a MEXW32 file, pick the MEXW32 file.
				if isempty(fullpath) && strcmp(computer('arch'), 'win32')
					MEXname = [name(1:mExtIdx) 'dll'];
					[fullpath, symName, fileType] = resolveFileName(MEXname);
				end
            end
            
            if isempty(fullpath)
                [fullpath, symName, fileType] = resolveFileName(name);
            end
            
            % If we still haven't found it, look for the name on
            % the path, if possible, and determine the file name that
            % contains it.
            if isempty(fullpath)
                [fullpath, symName] = resolveSymbolName(name);
            end
            
            % Remove the m-file extension from symbol names, if present.
            % If we don't, it may confuse the analysis, leading us to
            % believe this is dot-qualified name. We know it isn't because
            % the name corresponds to a file name, which can't be
            % dot-qualified.
            symName = regexprep(symName, ...
                matlab.depfun.internal.requirementsConstants.analyzableMatlabFileExtPat, '');
           
            % Make a symbol corresponding to the input name; don't 
            % presume to know the type.
            symbol = matlab.depfun.internal.MatlabSymbol(symName, ...
                             fileType, fullpath);
            
            % G1401459: Trust the full path provided by the caller of REQUIREMENTS. 
            % In general, the WHICH result of a symbol is questionable.
            % That's why we have to ignore class methods (g1405818).
            if strcmp(fullpath, name)
                symbol.FullPathProvidedByUser = true;
            end
            
            % Ask the MatlabSymbol object to figure out its own type. This
            % operation is expensive, which is why it is not part of the 
            % constructor.
            if fileType == matlab.depfun.internal.MatlabType.NotYetKnown
                determineSymbolType(symbol, fsCache, addExc);
            end
        end
        
    end % Public static methods

    methods (Access = protected)
        
        function symlist = getSymbols(obj, w)
            % Sub-optimal work-around/trade-off for g1360911.
            %
            % getSymbolNames has 600+ lines, so it is better to remain as a
            % separate file. If getSymbolNames.m is added as a new private
            % method of MatlabInspector, both $DIR/MatlabInspector.m and
            % $DIR/getSymbolNames.m must be moved into $DIR/@MatlabInspector. 
            % That will make MatlabInspector.m loose accessibilty to files
            % in $DIR/private.
            [F, S] = getSymbolNames(w);
            
            local_fcn_idx = ismember(S, F);
            symlist = S(~local_fcn_idx);
            
            if ~isempty(obj.OptionalKeywordDeps)
                K = getOptionalKeywordDeps(obj, w);
                if ~isempty(K)
                    symlist = [symlist; K];
                end
            end
        end
        
        function S = getOptionalKeywordDeps(obj, w)
            S = {};
            mt = matlab.depfun.internal.cacheMtree(w);
            
            if ~isempty(mt)
                keywordsWithOptionalDeps = keys(obj.OptionalKeywordDeps);
                % cellfun('isempty') returns wrong results in this case (g1429346)
                detected_idx = ~cellfun(@isempty, ...
                                        cellfun(@(k)mtfind(mt, 'Kind', k), ...
                                                keywordsWithOptionalDeps, ...
                                                'UniformOutput', false));
                detectedKeywords = keywordsWithOptionalDeps(detected_idx);
                tmp = values(obj.OptionalKeywordDeps, detectedKeywords);
                S = [tmp{:}]';
            end
        end

    end % Protected methods
end

% ================= Local functions =========================

%------------------------------------------------------------
function [fullpath, fcnName, fileType] = resolveFileName(name)
% resolveFileName If the name is a file, return file and function
    import matlab.depfun.internal.cacheWhich;
    import matlab.depfun.internal.cacheExist;

    fullpath = '';
    fcnName = '';
    fileType = matlab.depfun.internal.MatlabType.NotYetKnown;
    ex = cacheExist(name, 'file');
    if ex == 2 || ex == 3 || ex == 6
        [~,origFile,origExt] = fileparts(name);
        % When readme and readme.m coexist in a folder,
        % if 'readme' is given, we return <full path to the
        % folder>/readme.m;
        % if '<full path to the
        % folder>/readme' is given, we return <full path to the
        % folder>/readme;
        if isempty(origExt) && isfullpath(name)
            % Windows is case insensitive, the input 'name' may contain 
            % mis-spelled cases. For example, the drive letter may be 
            % lower case or upper case. WHICH can correct the wrong case, 
            % based on test points in treqArguments.
            pth = cacheWhich([name '.']);
        else
            % If the input 'name' is a symobl, a relative path, 
            % or a full path of a file with extension, call WHICH without 
            % appending a '.'.
            pth = cacheWhich(name);
        end
        
        % Test for matching case by looking for the filename part of
        % the input name in the full path reported by which. If the cases
        % of the filename parts don't match, MATLAB won't call the
        % function, so we shouldn't include it in the Completion.        
        [~,foundFile,] = fileparts(pth);
        if strcmp(origFile, foundFile) == 1   % Case sensitive
            fullpath = pth;
            fcnName = foundFile;
        end
        
        if isempty(fullpath)
            % WHICH will annoyingly ignore non-MATLAB files without an
            % extension, unless explicitly told the file has no extension.
            % Extension or not, we know the file exists, because exists says it
            % does -- so add the empty extension if necessary.
            wname = name;
            if isempty(origExt)
                wname = [name '.'];
            end
            pth = cacheWhich(wname);
            [~,foundFile,] = fileparts(pth);
            if strcmp(origFile, foundFile) == 1   % Case sensitive
                fullpath = pth;
                fcnName = foundFile;
            end
        end
        
        % Check the extension -- if it is unknown, then this is an
        % Extrinsic file. Note: must use original extension here, because
        % WHICH returns empty for Extrinsic files.
        if ~isempty(origExt) && ...
           ~matlab.depfun.internal.MatlabInspector.knownExtension(origExt)
            fileType = matlab.depfun.internal.MatlabType.Extrinsic;
        end
    elseif ex == 7
        fullpath = name;
    end
end

%------------------------------------------------------------
function [fullpath, symName] = resolveSymbolName(symName)
% resolveSymbolName Given a full or partial symbol name, fully expand it.
% At this point, full expansion means locating the file that contains
% the symbol and canonicalizing the full path of that file according
% to the current platform. File / function name mapping is case 
% sensitive.
%
% Look for the symbol on the path and under MATLAB root. Make sure the
% returned file is not a directory.

    import matlab.depfun.internal.MatlabSymbol;
    import matlab.depfun.internal.cacheWhich;
    import matlab.depfun.internal.cacheExist;
    import matlab.depfun.internal.requirementsConstants;
    
    fullpath = '';
    partialPath = false;
    dotQualified = false;
            
    % Does the file name point to an existing file?
    if ~cacheExist(symName,'file')
        % No. Try to find the name with which.
        pth = cacheWhich(symName);
        
        % Three possible cases:
        %   * symName contains the trailing part of a partial file name.
        %   * symName contains a dot-qualified name of a function or class.
        %   * symName is garbage -- unresolvable.        

        dots = strfind(symName, '.');
        start = length(pth) - length(symName);
        % If the WHICH-result contains the symName, symName was a partial
        % path.
        if start > 0 && strncmpi(pth(start:end),symName,length(symName))
            % Check case -- which inexplicably ignores case when looking for 
            % file names, but strfind performs a case-sensitive check. 
            if ~isempty(strfind(pth, symName))
                partialPath = true;
            end
        elseif ~isempty(dots)
            dotQualified = true;
        end
        
        % If the symbol name is a partial path or a dot-qualified name, it
        % is valid and we can accept the WHICH-result as the path to the
        % defining file.
        if partialPath || dotQualified
            fullpath = pth;
        end
        % Didn't work. Look for the file under MATLAB root.
        if isempty(fullpath)
            pth = fullfile(matlabroot,symName);
            % Ensure file / function name case match.
            ex = cacheExist(pth, 'file');
            if (ex == 2 || ex == 6) && strfind(pth, symName)
                fullpath = pth;
            else
                fullpath = '';
            end
        end
        
        % G883993: manage undocumented built-in
        if isempty(fullpath) && exist(symName,'builtin') == 5
            fullpath = cacheWhich(symName);
        end
    else             
        % Make sure file is specified with platform-conformant
        % path separators. (If not, WHICH and EXIST will perform
        % inconsistently.
        if ispc
            fullpath = strrep(symName,'/', filesep);
        else
            fullpath = strrep(symName,'\',filesep);
        end
        
        % Try to discover full path to file using which. If which
        % can't find the file, then just use what we were given.
        where = cacheWhich(fullpath);
        if ~isempty(where) 
            fullpath = where;
        end
        % If the full path does not contain a case sensitive match to
        % the function name, we didn't resolve the function, despite what 
        % WHICH and EXIST might think.
        match = ~isempty(strfind(fullpath, symName));
        if ~match
            fullpath = '';
        end
    end

    % Check for invalid results -- we must find some file, and that
    % file must not be a directory.
    if isempty(fullpath)
        error(message('MATLAB:depfun:req:NameNotFound',symName))
    elseif exist(fullpath, 'dir') == 7
        error(message('MATLAB:depfun:req:NameIsADirectory',symName))
    end
    
    builtinStr = requirementsConstants.BuiltInStrAndATrailingSpace;
    if strncmp(fullpath,builtinStr,length(builtinStr))
        [~,symName,~] = fileparts(MatlabSymbol.getBuiltinPath(fullpath));
    else
        % Dot qualified names are their own symbols.
        if ~dotQualified
            [~,symName,~] = fileparts(fullpath);
        end
    end
end

%-------------------------------------------------------------
function extMap = initKnownExtensions()
% Create a containers.Map with file extensions as keys, for fast lookup.
    import matlab.depfun.internal.requirementsConstants
    
    mext = mexext('all');
    extList = cellfun(@(e)['.' e], { mext.ext }, 'UniformOutput', false );
    extList = unique([ extList ...
                       requirementsConstants.dataFileExt ...
                       requirementsConstants.executableMatlabFileExt ]);
    extMap = containers.Map(extList, true(size(extList)));
end

%--------------------------------------------------------------
function tf = isValidMatlabFileName(w)
% This function only judges a file with a MATLAB file extension.
    import matlab.depfun.internal.requirementsConstants
    tf = true;
    [~,fname,ext] = fileparts(w);
    if ismember(ext, ...
                requirementsConstants.executableMatlabFileExt_reverseOrder)
        % The rules for naming variable/function/file are almost the same.
        %     tf = ~isempty(regexp(fname,'^[a-z|A-Z]\w*$','ONCE'));
        % The only difference is that a variable cannot be a key word.
        % For example, end.m is a valid MATLAB file name, though 'end' is not 
        % a valid variable name because it is a key word.
        % 
        % ISVARNAME is implemented as 
        % "mxIsValidMatNamePart(str, n) && !inIsKeyword(str)"
        % Therefore, isValidMatlabFileName is equivalent to 
        % "isvarname(fname) || iskeyword(fname)".
        %
        % This part can be replaced when mxIsValidMatNamePart 
        % gets wrapped as a built-in. (G1103186)        
        tf = isvarname(fname) || iskeyword(fname);
    end
end
