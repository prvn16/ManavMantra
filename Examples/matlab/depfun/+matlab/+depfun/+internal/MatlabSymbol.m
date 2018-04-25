classdef MatlabSymbol < handle
    
    properties(Access = protected)
        OriginalSymbol
    end
    
    properties
        Type = matlab.depfun.internal.MatlabType.NotYetKnown;
        Symbol
        WhichResult
    end
    
    properties (Dependent = true, SetAccess = private)
        QSymbol
    end
    
    properties(Constant)
        classList = matlab.depfun.internal.ClassSet;
        metaCache = containers.Map;
        
        % Symbols we don't have to record dependencies on, because they are
        % always available.
        immortalBuiltinSymbols = containers.Map( ...
            matlab.depfun.internal.requirementsConstants.matlabBuiltinClasses, ...
            true(1,numel(matlab.depfun.internal.requirementsConstants.matlabBuiltinClasses)));
        
        % Extensions
        executableExtensions = initExecutableExtensions();
        dataExtensions = initDataExtensions();  
        
        % Known built-in classes that don't follow the usual rules
        ruleBreakingBuiltinClass = { 'opaque' };
    end
    
    properties(Hidden=true)
        DotQualified        
        PartialPath
        FileName
        Ext
        ClassName
        ClassFile
        FullPathProvidedByUser = false;
    end
    
    methods (Static)
        
        function pth = classDir(qName)
            import matlab.depfun.internal.MatlabSymbol;
            pth = MatlabSymbol.classList.classDir(qName);
        end
        
        function type = classType(qName)
            import matlab.depfun.internal.MatlabSymbol
            type = MatlabSymbol.classList.classType(qName);
        end
        
        function addProxyClass(className, classType, whichResult)
            sym = matlab.depfun.internal.MatlabSymbol(className, ...
                                             classType, whichResult);
            add(sym.classList, sym);
        end
        
    end
    
    methods(Static) 
        
        function initClasses
            import matlab.depfun.internal.MatlabSymbol;
            import matlab.depfun.internal.MatlabType;
            
            % Get the names of the Matlab built-in classes.
            clsList = matlab.depfun.internal.requirementsConstants.matlabBuiltinClasses;
            
            % Remove the non-builtin classes from the class set.
            kList = knownClasses(MatlabSymbol.classList);
            rList = setdiff(kList,clsList);
            remove(MatlabSymbol.classList, rList);
          
            % Pre-load the exist cache to avoid excessive harassment of the
            % file system. Only pre-load the cache for those classes that
            % are not already in the class set. Why is this an advantage?
            % Because here we can batch the calls to cacheExist -- we can
            % ask about all the @-dirs in each folder in a single call,
            % instead of crossing the MEX/MATLAB boundary once per @-dir.
            
            unkClasses = setdiff(clsList, kList);
            if ~isempty(unkClasses)
                p = strsplit(path,pathsep);
                fs = [filesep '@'];
                % Extra crazy optimization allowing loop to consume two
                % path items on each iteration. If the path has an odd
                % number of items on it, process the first path item
                % outside the loop so that an even number of items remain.
                % This further halves the number of times we cross the
                % MEX/MATLAB boundary. (All that passport checking is so
                % tedious, the waiting in line so boring.)
                s = 1;
                if mod(numel(p),2) ~= 0
                    atDir = strcat([p{s} fs], unkClasses);
                    matlab.depfun.internal.cacheExist(atDir,'dir');
                    s = 2;
                end
                for k=s:2:numel(p)
                    ad0 = strcat([p{k} fs], unkClasses); 
                    ad1 = strcat([p{k+1} fs], unkClasses); 
                    matlab.depfun.internal.cacheExist([ad0 ad1],'dir');
                end
            end
           
            % Add the known builtin classes to the class set, but only the
            % ones that aren't on the list yet.
            for n=1:numel(unkClasses)
                whichResult = matlab.depfun.internal.cacheWhich(unkClasses{n});
                if isempty(whichResult)
                    whichResult = unkClasses{n};
                end
                MatlabSymbol.addProxyClass(...
                    unkClasses{n}, MatlabType.BuiltinClass, whichResult);
            end            
        end
        
        function clearClasses
            import matlab.depfun.internal.MatlabSymbol;
            
            MatlabSymbol.classList.clear();
            remove(MatlabSymbol.metaCache, keys(MatlabSymbol.metaCache));
        end
        
        function n = basename(f)
            [~,n,~] = fileparts(f);
        end
        
        function s = makeFcnSymbol(f, type, pth)
            s = matlab.depfun.internal.MatlabSymbol(f, type, pth);           
        end
        
        function s = makeCodeOrDataSymbol(f, type)
            [~,name,ext] = fileparts(f);
            if isKey(o.dataExtensions, ext)
                type = matlab.depfun.internal.MatlabType.Data;
            end
            s = matlab.depfun.internal.MatlabSymbol(name, type, f);
        end
                
        
        function s = makeFileSymbol(f, type)
            [~,n,~] = fileparts(f);
            s = matlab.depfun.internal.MatlabSymbol(n, type, f);
        end

        function [pathName, varargout] = trimFullPath(fullFileName)
        % trimFullPath  Strip off last piece from full path name    
        % p = trimFullPath(fullpath) returns a modified path
        % name minus the last substring of fullpath as delineated by filesep 
        % characters. 
        % [p substr] = trimFullPath(...) also returns the last 
        % substring.  
            pathName = '';
            if nargout == 2
                varargout{1} = '';
            end
            
            fs = filesep;
            % Nothing to do? Do nothing!
            if isempty(fullFileName), return; end

            if fullFileName(end) == fs
                fullFileName = fullFileName(1:end-1);
            end
            fileSepIdx = strfind(fullFileName, fs);
            if ~isempty(fileSepIdx)
                pathName = fullFileName(1:fileSepIdx(end));
                if nargout == 2
                    varargout{1} = fullFileName((fileSepIdx(end)+1):end); 
                end
            end
        end
        
        function tf = isKnownClass(name)
            import matlab.depfun.internal.MatlabSymbol
            tf = MatlabSymbol.classList.isKnownClass(name);
        end
        
        function pth = getBuiltinPath(str)
        % getBuiltinPath Get a builtin's path from the which result
        %
        %  Pattern:
        %    built-in (/path/to/builtin) % Other junk
        %   
            import matlab.depfun.internal.requirementsConstants;
            
            pth = str;
            re = [requirementsConstants.BuiltInStr '.*[(]([^)]+)[)]'];
            match = regexp(str,re,'tokens');
            if iscell(match)
                match = match{1};
                pth = match{1};
            end
        end
        
        function classifyNames(names, paths, fsCache)
        % classifyNames Add named classes to the list of known classes.
        % Determine if each name in the list could possibly reference a
        % MATLAB class.
        % TODO: does this handle UDD and OOPs classes correctly?
            import matlab.depfun.internal.MatlabSymbol;
            import matlab.depfun.internal.MatlabType;
            import matlab.depfun.internal.ClassSet;
            
            if ischar(names)
                names = {names};
            end
            if ischar(paths)
                paths = {paths};
            end

            len = numel(names);
            for n = 1:len
                sym = MatlabSymbol(names{n}, MatlabType.NotYetKnown, ...
                                   paths{n});
                sym.Type = fsCache.Type([paths{n} ' : ' names{n}]);
                if isempty(sym.Type)
                    sym.Type = MatlabType.NotYetKnown;
                    determineClassType(sym);
                    if isClass(sym.Type)
                        add(sym.classList, sym);
                    end
                end
            end
        end
    end
    
    methods
        
        %--------------------------------------------------------------
        function s = MatlabSymbol(symStr, varargin)
        % MatlabSymbol Construct a representation of a MATLAB file symbol
        %
        % s = MatlabSymbol(NAME, TYPE, PATH) creates a symbol with the
        % given MatlabType and path to the file defining the symbol.
        %
        % TYPE and PATH are optional. TYPE defaults to
        % MatlabType.NotYetKnown, and PATH to the result of running WHICH
        % on the input string.
        %
        % s = MatlabSymbol(SYM) takes a string symbol name and
        % constructs a MATLAB object representing the symbol.  SYM is a
        % single symbol from the set of symbols returned by the
        % getSymbolNames function for a given MATLAB file.
        %
        % s = MatlabSymbol(SYM, TYPE) constructs a symbol object when the
        % type of the symbol is already known. TYPE must be MatlabType
        % instance.
        %
        % s = MatlabSymbol(NAME, TYPE, PATH, CLASSNAME, CLASSFILE) creates 
        % a symbol with the given MatlabType, path to the file, and 
        % pre-computed class name and path to the class contructor file.
        
            import matlab.depfun.internal.MatlabType;
            
            % Zero-input case, to support pre-allocation of object arrays.
            if nargin == 0
                s.Symbol = '';
                s.DotQualified = false;
                s.OriginalSymbol = '';
                s.WhichResult = '';
                return;
            end

            % If we have any inputs, the first one must be a string.
            if ~isa(symStr,'char')
                error(message('MATLAB:depfun:req:InvalidInputType',...
                              1, class(symStr), 'char'))
            end
            s.OriginalSymbol = symStr;
            s.Symbol = symStr;
            s.DotQualified = ~isempty(strfind(symStr,'.'));
            
            % Call WHICH if caller hasn't supplied a path. (Expensive?)
            if nargin < 3 
                s.WhichResult = matlab.depfun.internal.cacheWhich(symStr);  
            else
                s.WhichResult = varargin{2};
            end
            
            % save the results of FILEPARTS for performance
            if ~isempty(s.WhichResult) && isfullpath(s.WhichResult)
                [s.PartialPath, s.FileName, s.Ext] = fileparts(s.WhichResult);
            else
                s.PartialPath = '';
                s.FileName = '';
                s.Ext = '';
            end
            
            % When the object is created, its ClassName and ClassFile are
            % unset. They will be set by determineClassType().
            if nargin < 4
                s.ClassName = '?';
            else
                s.ClassName = varargin{3};
            end
            
            if nargin < 5
                s.ClassFile = '?';
            else
                s.ClassFile = varargin{4};
            end
            
            % Symbols may be specified with an argument list of types, e.g.,
            % 'my_method(my_class)' -- remove the argument list from the
            % symbol specification now, since WHICH has already identified
            % class.
            argStart = strfind(s.Symbol,'(');
            if ~isempty(argStart)
                s.Symbol = s.Symbol(1:argStart-1);
            end

            % Validate type, if caller supplied one.
            if nargin > 1
                if ~isa(varargin{1}, 'matlab.depfun.internal.MatlabType')
                    error(message('MATLAB:depfun:req:InvalidInputType',...
                                  2, class(varargin{1}), 'MatlabType'))
                end
                s.Type = varargin{1};
            end   
        end
        
        %--------------------------------------------------------------
        function pth = proxyLocation(sym)
        % proxyLocation Return the location of the proxy file, without a
        % terminating extension. In the case of a built-in, return a
        % virtual path constructed from the first matching @-directory on
        % the path and the base name of the built-in symbol.
            import matlab.depfun.internal.MatlabSymbol;
            import matlab.depfun.internal.requirementsConstants;
            
            fs = filesep;
            pth = '';
            cDir = '';
            if isProxy(sym)
                if isBuiltin(sym)  % Should catch MATLAB built-in classes
                    if strncmp( ...
               [requirementsConstants.BuiltInStrAndATrailingSpace '('], ...
                               sym.WhichResult, 10)
                        pth = sym.WhichResult(11:end-1);
                        return;
                    end
                    cDir = MatlabSymbol.classDir(sym.Symbol);
                    if isempty(cDir)
                        cDir = MatlabSymbol.classDir(sym.QSymbol);
                    end
                else
                    % Regular file
                    if isempty(strfind(sym.WhichResult,...
                                       requirementsConstants.BuiltInStr))
                        pth = sym.WhichResult;
                        chopIdx = strfind(pth,sym.Ext);
                        if ~isempty(chopIdx)
                            pth = pth(1:chopIdx(end)-1);
                        end
                    else
                        % Built-in appears in the WHICH result. This should be
                        % a toolbox-built-in proxy. Three possibilities:
                        %
                        %  * Known class directory in the class set
                        %  * @-dir on the path.
                        %  * The symbol name.
                        %
                        % Look for @-directory, fall back to symbol name.
                        
                        cDir = MatlabSymbol.classDir(sym.Symbol);
                        if isempty(cDir)
                            atDir = findAtDirOnPath(sym.Symbol);
                            if isempty(atDir)
                                % Maybe UDD style built-in
                                dotIdx = strfind(sym.Symbol,'.');
                                if ~isempty(dotIdx)
                                    s = sym.Symbol(1:dotIdx(1)-1);
                                    atDir = findAtDirOnPath(s);
                                    if ~isempty(atDir)
                                        cDir = [atDir{1} fs '@' ...
                                             sym.Symbol(dotIdx(1)+1:end)];
                                    end
                                end
                            else
                                cDir = atDir{1};
                            end
                        end
                    end
                end
                if isempty(pth)
                    if ~isempty(cDir)
                        name = sym.Symbol;
                        chopIdx = strfind(name,'.');
                        % Extract base part of dot-qualified name
                        if ~isempty(chopIdx)
                            name = name(chopIdx(end)+1:end);
                        end
                        pth = [cDir fs name];  
                    else
                        pth = sym.Symbol;
                    end
                end
            else
                pth = sym.WhichResult;
            end
        end
        
        %--------------------------------------------------------------
        function p = proxy(sym)
        % PROXY Retrieve the proxy dependency for the input symbol.
        % For example, given a class method, retrieve the constructor.
            import matlab.depfun.internal.MatlabType;
        
            p = sym;
            if isPrincipal(p)
                [name, type, pth] = classInfo(sym.classList, p);
                
                % If the class isn't registered, looking it up works badly.
                % But we might be able to use the file's path to determine
                % its class, type and proxy location.
                if isempty(pth)
                    name = p.ClassName;
                    pth = p.ClassFile;
                    type = classType(name, pth);
                    
                    % All is lost.
                    if isempty(pth) || type == MatlabType.NotYetKnown
             error(message('MATLAB:depfun:req:NoClassForMethod', ...
                           sym.WhichResult, sym.classList.NumEntries))
                    end
                end
                p = matlab.depfun.internal.MatlabSymbol(name, type, pth, ...
                                                        name, pth);
            end
        end

        %--------------------------------------------------------------
        function ps = principals(sym)
        % PRINCIPALS Retrieve the principals of a proxy dependency.
        % Return an array of MatlabSymbol objects.
        % Return an empty MatlabSymbol array if the symbol is not a proxy.
            import matlab.depfun.internal.MatlabType;
            
            fs = filesep;
            ps = matlab.depfun.internal.MatlabSymbol.empty(1,0);
            
            % Class methods ARE principals. They don't HAVE principals.
            % So are class private functions and class schemas (but not
            % package schemas) and maybe other types of files. Only allow
            % proxy files past this point -- otherwise file pattern 
            % matching may incorrectly map certain file names to proxy
            % names, creating a proxy/principal relationship where none was
            % intended. 
            if ~isProxy(sym), return; end
            
            % Directed dispatch (using dot-notation) to disambiguate
            % against private/classFiles.m
            [pfiles, ftype, ctype] = sym.classList.classFiles(sym);
            
            % Recuse yourself from further proceedings.
            keep = ~strcmp(pfiles, sym.WhichResult);
            pfiles = pfiles(keep);
            ftype = ftype(keep);
            
            % Make symbols from the paths returned by classFiles.
            if ~isempty(pfiles)
                % A proxy symbol should not appear in its list of 
                % principals.
                %
                % Remove any functions that match the extensionless
                % name of the input symbol from the list of principals.
                % This handles, for example, classes with .p and .m
                % contructors. Signal, I'm looking at you again.
                
                fcn = proxyLocation(sym);
                pat = [ regexptranslate('escape',fcn) ...
                        '(($)|([.][^.]*$))' ];
                keep = cellfun('isempty',regexp(pfiles, pat, 'once'));
                pfiles = pfiles(keep);
                
                % Adjust types too, or they'll be wrong...
                ftype = ftype(keep);

                sz = numel(pfiles);
                ps = repmat(matlab.depfun.internal.MatlabSymbol(), 1, sz);
                
                for k = 1:sz
                    file = pfiles{k};
                    type = ftype(k);
                    % Extract the symbol name from the full path to the
                    % file. The symbol name is everything between the last
                    % filesep and the last '.' -- the 'base' part of the
                    % full path. Written this way to avoid known slow
                    % performance of fileparts.
                    endSymbol = strfind(file,'.');
                    if isempty(endSymbol)
                        endSymbol = numel(file);
                    else
                        endSymbol = endSymbol(end)-1;
                    end
                    beginSymbol = strfind(file, fs);
                    if isempty(beginSymbol)
                        beginSymbol = 1;
                    else
                        beginSymbol = beginSymbol(end)+1;
                    end
                    symbol = file(beginSymbol:endSymbol);
                    % TODO: Make type more accurate -- discriminate between
                    % class and method, for example.
                    if isClass(type)
                        mType = type.methodType;
                        if mType == MatlabType.NotYetKnown
                            mType = type;
                        end
                    else
                        mType = type;
                    end
                    
                    ps(k) = matlab.depfun.internal.MatlabSymbol(...
                        symbol, mType, file);
                end
            end
        end

        %--------------------------------------------------------------
        function obj = CopyMatlabSymbol(sym)
        % Serves like a copy constructor of MatlabSymbol class
            obj = matlab.depfun.internal.MatlabSymbol(sym.OriginalSymbol, ...
                  sym.Type, sym.WhichResult, sym.ClassName, sym.ClassFile);
        end

        %--------------------------------------------------------------
        function value = get.QSymbol(obj)
            import matlab.depfun.internal.MatlabType;
            value = '';
            if obj.Type ~= MatlabType.Data && ...
                   obj.Type ~= MatlabType.Extrinsic && ...
                   obj.Type ~= MatlabType.Ignorable && ...
                   obj.Type ~= MatlabType.NotYetKnown
                value = qualifiedName(obj.WhichResult);
            end
        end
        
        %--------------------------------------------------------------
        function clsName = get.ClassName(obj)
        % Compute the class name when it is unset. Otherwise, return the
        % result without computing it again for performance.
            if '?' == obj.ClassName
                obj.determineClassType();
            end
            
            clsName = obj.ClassName;
        end
        
        %--------------------------------------------------------------
        function clsFile = get.ClassFile(obj)
        % Compute the class name when it is unset. Otherwise, return the
        % result without computing it again for performance.
            if '?' == obj.ClassFile
                obj.determineClassType();
            end
            
            clsFile = obj.ClassFile;
        end
        
        %--------------------------------------------------------------
        function s = clone(symObj, pth)
        % CLONE Make a copy of the MatlabSymbol; optionally modify WhichResult
            import matlab.depfun.internal.MatlabSymbol;

            s = MatlabSymbol(symObj.Symbol, symObj.Type, pth, ...
                             symObj.ClassName, symObj.ClassFile);
            s.Type = symObj.Type;
            s.DotQualified = symObj.DotQualified;
        end
       
        %--------------------------------------------------------------
        % Only call as absolutely necessary -- WHICH is very expensive.
        function updateSymbol(symObj, newSym)
            import matlab.depfun.internal.MatlabType;
            import matlab.depfun.internal.cacheWhich;
            
            symObj.Symbol = newSym;
            symObj.WhichResult = cacheWhich(newSym);
            if ~isempty(symObj.WhichResult)
                [symObj.PartialPath, symObj.FileName, symObj.Ext] = fileparts(symObj.WhichResult);
            end
            if symObj.Type ~= matlab.depfun.internal.MatlabType.Data
                symObj.DotQualified = ~isempty(strfind(newSym,'.'));
            end
        end
        
        %--------------------------------------------------------------
        function symList = makeSymbolList(symObj)
            symList = {};
            if iscell(symObj.WhichResult)
                len = numel(symObj.WhichResult);
                for k=1:len
                    sym = clone(symObj, symObj.WhichResult{k});
                    symList = [ symList sym ]; 
                end
            else
                symList = symObj ;
            end
        end

        %--------------------------------------------------------------
        function determineMatlabType(symObj)
        %getMatlabType Determine type of this symbol.
        %    symType = getSymbol(SYM) evaluates the type of this symbol 
        %    and returns an instance of the MatlabType enumeration class.
            import matlab.depfun.internal.requirementsConstants;
            import matlab.depfun.internal.MatlabType;
     
            % First of all: distinguish between code and data, based on
            % file extension. This ensures that data files are not
            % processed by getTypeUsingEnvironment.
            if isData(symObj)
                symObj.Type = MatlabType.Data;
                % Data files never count as 'dot-qualified'.
                symObj.DotQualified = false;
            % Not a known data extension
            elseif ~isempty(symObj.WhichResult)
                % If there's no extension (but the path is known), then
                % this is an extrinsic file (all MATLAB file types have
                % extensions). (Unless WHICH calls it a built-in.)
                %
                % The file is also Extrinsic if its extension is unknown.
                if isempty(symObj.Ext) 
                    if ~isempty(strfind(symObj.WhichResult, ' is a Java '))
                        symObj.Type = matlab.depfun.internal.MatlabType.JavaAPI;
                    elseif isempty(strfind(symObj.WhichResult,...
                                           requirementsConstants.BuiltInStr))
                        symObj.Type = matlab.depfun.internal.MatlabType.Extrinsic;
                        symObj.DotQualified = false;
                    end
                else
                    if ~matlab.depfun.internal.MatlabInspector.knownExtension(symObj.Ext)
                        symObj.Type = matlab.depfun.internal.MatlabType.Extrinsic;
                        symObj.DotQualified = false;
                    end
                end
            end

            %Order of checking symbols to determine their type:
            %  1.  Check for class using whole name
            %  2.  If whole name not a class, try whole name as a function.
            %      if no match, try lopping off dot-parts, checking for
            %      class then function.
            symString = symObj.OriginalSymbol;
            while symObj.Type == MatlabType.NotYetKnown
                getTypeUsingEnvironment(symObj);
                %If symbol type comes back as NotYetKnown, it is a
                %dot-qualified name the type of which can't yet be
                %determined.  Lop off the right-most substring and try
                %again.
                if symObj.Type == MatlabType.NotYetKnown
                    if isempty(strfind(symString,'.'))
                        %No (more) dots in the name - ignore it
                        symObj.Type = MatlabType.Ignorable;
                    else
                        %lop off right-most substring and keep trying
                        symString = removeRightmostSubstring(symString);
                        updateSymbol(symObj, symString);
                        
                        % At this point, we have nothing to lose. If the
                        % symbol is something else, it must have been
                        % identified. .NET and Python symbols may reach
                        % here when .NET or Python is not installed.
                        switch symString
                            case { 'java' 'javax' 'com' }
                                symObj.Type = MatlabType.JavaAPI;
                            case { 'NET' 'System' }
                                symObj.Type = MatlabType.DotNetAPI;
                            case 'py'
                                symObj.Type = MatlabType.PythonAPI;
                        end
                    end
                end
            end
        end
        
        %--------------------------------------------------------------
        function getTypeUsingEnvironment(symObj)
        %getTypeInfoUsingEnvironment  Use meta-class and WHICH to determine symbol type
        %    getTypeUsingEnvironment(SYM_OBJ) attempts to identify the type 
        %    of symbol represented by SYM_OBJ using the MATLAB environment.   
        %
        %    If SYM_OBJ is a dot-qualified name, it could represent a
        %    package-scoped function or a static member of a class.  If the
        %    latter, the construct of interest is the class itself, but in
        %    order to find that class the right-most substring needs to be
        %    removed from the dot-qualified name and another pass through
        %    this method made.
        %
        %    Preconditions: 
        %    * The symbol is not a local symbol in the current file
        %    * The symbol does not represent something in the current file's
        %      private directory.
        %
        %    The sequence of checking is important in order to identify the
        %    type correctly:
        %    * Determine whether the symbol represents a class.
        %    * If not a class, look at the WHICH results.  
        %    * If WHICH results are empty:
        %      ** If the symbol is dot-qualified, the type isn't known yet
        %      ** If not dot-qualified, the symbol is ignorable
        %    * If WHICH answer is not empty, use the answer to figure out
        %       what this thing is.
            import matlab.depfun.internal.MatlabType;
            
            % determineClassType() knows a lot about methods too. Only keep
            % going if the symbol's type hasn't been resolved.
            determineClassType(symObj);
            if symObj.Type == MatlabType.NotYetKnown   % ~isClass(symObj)
                if isempty(symObj.WhichResult)
                    %The symbol isn't a class and WHICH doesn't find it.
                    %If the symbol contains no dots it is ignorable, but if
                    %it is dot-qualified some portion of the name might
                    %still resolve to something.
                    if ~symObj.DotQualified
                        symObj.Type = MatlabType.Ignorable;
                    end
                else
                    % Not a class and WHICH found something
                    useWhichToEvaluateSymbol(symObj);
                end  
            end
        end
        
        %-------------------------------------------------------------
        function determineClassType(symObj)
        % determineClassType If the symbol is associated with a class, 
        %  figure out which one.
        %
        %    Use UDD & MCOS meta-class information to determine whether the
        %    input symbol represents a class.  

            import matlab.depfun.internal.MatlabSymbol;
            import matlab.depfun.internal.MatlabType;
            import matlab.depfun.internal.ClassSet;
            import matlab.depfun.internal.cacheExist;
            import matlab.depfun.internal.cacheWhich;
            import matlab.depfun.internal.requirementsConstants;
            
            % Qualified class name is empty, because Type is NotYetKnown.
            % Attempt to deduce qualified class name from the WHICH result.
            % If the symbol name matches the base part of the qualified class 
            % name, use the class name.
            [name, clsFile] = className(symObj.WhichResult);
            % Save the class name for future reference, since
            % a lot of effort is spent on finding the class name.
            symObj.ClassName = name;
            symObj.ClassFile = clsFile;
            
            if ~isempty(name)
                dotIdx = strfind(name,'.');
                baseName = name;
                if ~isempty(dotIdx)
                    baseName = name(dotIdx(end)+1:end);
                end

                % If the symbol name is not equal to the base part of the 
                % class name, or if the symbol name itself is empty, then 
                % the symbol is not a class constructor. However, it could 
                % still be a class method.
                %
                % Note that the symbol name may appear multiple times in the
                % class name, particularly if it is a constructor, as in: 
                % toolbox.component.component. 
                %
                % Be careful about method names that form a proper suffix of
                % the class name, i.e., @fittype/type.m. The method name must
                % have the same length as the class name for the method to be
                % the constructor.
                if ~strcmp(name,symObj.Symbol) && ...
                        ~strcmp(baseName, symObj.Symbol)
                    % Name is associated with a class, but symObj.Symbol 
                    % doesn't match the base part of the name. 
                    % symObj.Symbol should be a method.
                    if (isfullpath(clsFile) && matlabFileExists(clsFile)) || ...
                            cacheExist(name,'class')
                        type = classType(name, clsFile);
                        if type ~= MatlabType.NotYetKnown
                            symObj.Type = methodType(type);
                            if isStaticMethod(symObj) || symObj.FullPathProvidedByUser
                                clsSym = MatlabSymbol(name, type, clsFile, ...
                                                      name, clsFile);
                                add(symObj.classList, clsSym);
                            end
                        end
                    end
                else
                    symObj.Type = classType(name, clsFile);
                    % A UDD class using the built-in constructor. Give it a
                    % virtual WhichResult that points to where the
                    % constructor should be.
                    if symObj.Type == MatlabType.UDDClass && ...
                       ~isempty(strfind(symObj.WhichResult, ...
            [requirementsConstants.BuiltInStrAndATrailingSpace ...
             requirementsConstants.MethodStr]))
                       symObj.WhichResult = clsFile;
                    end

                    if symObj.Type ~= MatlabType.NotYetKnown
                        if isBuiltin(symObj) && isClass(symObj) && ...
                                ~isempty(clsFile)
                            symObj.WhichResult = clsFile;
                            cacheWhich(symObj.Symbol,clsFile);
                        end
                        
                        if isClass(symObj)
                            add(symObj.classList, symObj);
                        end
                    end
                end
            else
                % If we didn'f figure out the class name yet, try one more
                % thing.
                
                % TO DO: Stopping hard-coding 'empty' and 'newarray' 
                % when G1145053 is fixed.
                rightmostDotIdx = regexp(symObj.Symbol,'\.(empty|newarray)$','ONCE');
                if ~isempty(rightmostDotIdx)
                    cname = symObj.Symbol(1:rightmostDotIdx-1);
                    if cacheExist(cname, 'class')
                        symObj.updateSymbol(cname);
                        symObj.Type = MatlabType.MCOSClass;
                        symObj.ClassName = cname;
                        symObj.ClassFile = symObj.WhichResult;
                        
                        add(symObj.classList, symObj);
                    end
                end
            end
        end
        
        %------------------------------------------------------------
        function determineSymbolType(symbol, fsCache, addExc)
            try
                determineMatlabType(symbol);        
            catch exception
                % only catch the error thrown by meta.class.fromName()
                if strcmp(exception.identifier, 'MATLAB:class:InvalidSuperClass')
                    % add the file to the exclusion file, because its super class
                    % cannot be found on the path.
                    reason = struct('identifier', exception.identifier, ...
                                    'message', exception.message, ...
                                    'rule', '');
                    addExc(symbol.WhichResult, reason);
                    symbol.Type = matlab.depfun.internal.MatlabType.Ignorable;
                else
                    rethrow(exception);
                end
            end

            % Only cache the type if the symbol is the entry point or class name.
            %
            % TODO: Add MCOSMethod to MatlabType, and make this code faster by
            % checking the type.
            if ~isempty(symbol.Symbol)
                dotIdx = strfind(symbol.Symbol,'.');
                baseSym = symbol.Symbol;
                if ~isempty(dotIdx)
                    baseSym = baseSym(dotIdx(end)+1:end);
                end
                if ~isempty(symbol.WhichResult)
                    % Remove extension, if any
                    noExt = symbol.WhichResult(1:end-numel(symbol.Ext));
                    loc = strfind(noExt, baseSym);
                    % Is the baseSym the last part of the baseFile?
                    if ~isempty(loc)
                        loc = loc(end);
                        if loc == numel(noExt) - numel(baseSym) + 1
                            cacheType(fsCache, [symbol.WhichResult ' : ' baseSym], symbol.Type);
                        end
                    end
                end
            end
        end

        %--------------------------------------------------------------
        function overload(symObj, clsList)
        % OVERLOAD Add paths to overloaded methods this symbol represents
            import matlab.depfun.internal.ClassSet;

            function pth = symbolPath(symbolName, whichResult)
                import matlab.depfun.internal.cacheExist;
                import matlab.depfun.internal.requirementsConstants;
                
                [clsDir,~,~] = fileparts(whichResult);

                if isempty(clsDir) && ...
                  ~isempty(strfind(whichResult, ...
                                  requirementsConstants.BuiltInStr)) && ...
                  ~isempty(strfind(whichResult, requirementsConstants.MethodStr))
                    pth = '';
                else
                    pth = fullfile(clsDir, [ symbolName '.m'] );
                    if cacheExist(pth, 'file') ~= 2
                        pth = whichResult;
                    end
                end
            end

            len = numel(clsList);            
            if len == 1                
                symObj.WhichResult = symbolPath(symObj.Symbol, ...
                                                clsList.WhichResult);
            else
                symObj.WhichResult = cell(1,len);
                for k = 1:len
                    symObj.WhichResult{k} = ...
                        symbolPath(symObj.Symbol, clsList(k).WhichResult);
                end
            end                
        end
        
        %-------------------------------------------------------------
        function useWhichToEvaluateSymbol(symObj)
        % useWhichToEvaluateSymbol Use WHICH to determine symbol type 
        %    Built-in functions have the string 'built-in' in the WHICH
        %    answer.  Things like Java methods are not reported as built-in,
        %    but have no path location (and hence no fileseps in the WHICH 
        %    answer).  If not a built-in or a Java-like thing, evaluate the
        %    answer returned by WHICH to try and figure out whether it's a
        %    function we are interested in, whether it's ignorable, or
        %    whether it's a dot-qualified name that we can't yet evaluate.
        %
        %    Preconditions:
        %    *  The symbol is not a class 
        %    *  WHICH found something for this symbol name
        %
        %  To evalute the answer returned by WHICH, check the following:
        %      * Is the symbol a built-in (record in built-in list)
        %      * Is the symbol a Java function (ignore)
        %      * Is the symbol a method in a @builtinType directory
        %      * Is the symbol dot-qualified?
        %      ** If yes, it could be a package-scoped function, a static 
        %         method, or a constant property.  We want package-scoped
        %         functions but defer on the other things.
        %      ** If no, it could be an ordinary function, a method of a
        %         built-in type that is not an overload of an ordinary
        %         function (e.g., @opaque/toChar), or a class method.  We
        %         want ordinary functions and methods of built-in types,
        %         but not class methods.
        
            import matlab.depfun.internal.MatlabSymbol;
            import matlab.depfun.internal.MatlabType;
            import matlab.depfun.internal.ClassSet;
            import matlab.depfun.internal.cacheExist;
            import matlab.depfun.internal.requirementsConstants;
            
            fs = filesep;
            if ~isempty(strfind(symObj.WhichResult, ...
                                requirementsConstants.BuiltInStr))
                %"built-in" appears in the WHICH answer
                symObj.Type = MatlabType.BuiltinFunction;
                
                % Be precise for dynamic built-ins
                % For performance, check whether the symbol is dot
                % qualified first.
                if  symObj.DotQualified
                    if strncmp(symObj.Symbol, 'NET.', 4) ...
                         || strncmp(symObj.Symbol, 'System.', 7)
                        symObj.Type = MatlabType.DotNetAPI;
                    elseif strncmp(symObj.Symbol, 'py.', 3)                    
                        symObj.Type = MatlabType.PythonAPI;
                    end
                end
            else
                %Not a builtin.  Is it a Java-like thing?  
                fileSepIdx = strfind(symObj.WhichResult, fs);
                if isempty(fileSepIdx)
                    if symObj.DotQualified && ...
                            (strncmp(symObj.Symbol, 'java.', 5) || ...
                             strncmp(symObj.Symbol, 'javax.', 6)) || ...
                             ~isempty(strfind(symObj.WhichResult, 'Java'))
                        symObj.Type = MatlabType.JavaAPI;
                    else
                        symObj.Type = MatlabType.Ignorable;
                    end
                else
                    fileName = symObj.WhichResult((fileSepIdx(end)+1):end);

                    %Count number of '@' and '+' in WHICH result
                    numAts = length(strfind(symObj.WhichResult,[fs '@']));
                    numPlus = length(strfind(symObj.WhichResult,[fs '+']));
                    
                    if ~symObj.DotQualified
                    %Name isn't dot-qualified.  
                        if numAts == 0
                            if strncmp(symObj.Symbol,fileName, length(symObj.Symbol))
                                % If numAts is zero and the name of the file matches
                                % the symbol name, it's a top-level function.
                                symObj.Type = MatlabType.Function;
                            else
                                symObj.Type = MatlabType.Ignorable;
                            end
                        else
                            % If numAts is greater than zero, it's a method.
                            if isFileInBuiltinTypeDir(symObj.WhichResult)
                                %It's a method of a built-in type that
                                %isn't an overload of an ordinary function
                                symObj.Type = ...
                                    MatlabType.Function; 
                            else
                                partialPath = symObj.PartialPath;
                                
                                % G1211213 - Remove the trailing 'private' directory
                                isPrivateFile = isprivate(symObj.WhichResult);
                                if isPrivateFile
                                    partialPath = MatlabSymbol.trimFullPath(partialPath);                                    
                                end                               
                                
                                [~, atDirName] = MatlabSymbol.trimFullPath(partialPath);
                                if atDirName(1) == '@'
                                    atDirName = atDirName(2:end);
                                end
                                
                                % deal with UDD here
                                % Some UDD classes don't have the class
                                % constructor. The constraint is loosen a
                                % bit here.
                                if matlabFileExists(fullfile(partialPath,'schema')) 
                                    if numAts == 1
                                        % UDD package function: One @ in
                                        % the path, directory contains
                                        % schema.m.
                                        
                                        % If the symbol is a real UDD function, 
                                        % its Symbol must be the same as its QSymbol 
                                        % or it must be a function private to package 
                                        % functions.                                         
                                        % If it is not a private function, 
                                        % getSymbolNames will concatenate 
                                        % the UDD package name to the symbol name.
                                        
                                        % symObj.QSymbol fails for NotYetKnown symbols.
                                        if strcmp(symObj.Symbol, ...
                                                  qualifiedName(symObj.WhichResult)) ...
                                                 || isPrivateFile
                                            symObj.Type = ...
                                                MatlabType.UDDPackageFunction;
                                        end
                                    end    

                                    if numAts == 2
                                        if strcmp(symObj.Symbol,atDirName)
                                            symObj.Type = MatlabType.UDDClass;
                                        else % UDD class method
                                            symObj.Type = MatlabType.UDDMethod;
                                        end
                                        % Add the UDD class to the list of 
                                        % known classes.
                                        cS = MatlabSymbol(symObj.ClassName, MatlabType.UDDClass, symObj.ClassFile);
                                        add(symObj.classList, cS);                                     
                                    end
                                else                                
                                    if isPrivateFile
                                        % files in the private folder will be
                                        % taken care of in evaluateSymbols() in 
                                        % MatlabInspector.m. Thus, they should be
                                        % ignored at this point to prevent from 
                                        % introducing unnecessary classes which 
                                        % contain methods with the same name.
                                        symObj.Type = MatlabType.Ignorable;                                
                                    else
                                        if symObj.Type == MatlabType.NotYetKnown
                                            
                                            % Not much hope for this
                                            % symbol. It's a method, or
                                            % nothing.
                                            symObj.Type = ...
                                                MatlabType.ClassMethod;
                                        end
                                    end
                                end
                            end 
                        end
                    else
                        %Name is dot-qualified
                        
                        dotIdx = strfind(symObj.Symbol,'.');
                        symSimpleName = symObj.Symbol((dotIdx(end)+1):end);

                        if ~strncmp(symSimpleName, fileName, ...
                                    length(symSimpleName))
                           %The symbol's simple name does not match the
                           %file name returned by WHICH, so it must be 
                           %either a static method defined in a classdef 
                           %file or a constant property.   Return this as
                           %an unknown symbol; keep looking for the class.
                           symObj.Type = MatlabType.NotYetKnown;
                        else
                            %File name matches simple symbol name.  The 
                            %symbol could represent any one of:
                            % 1.  a package function in an MCOS package 
                            %     (no @, one or more +)
                            % 2.  a UDD static method (2 @, no +)
                            % 3.  a package function in a UDD package 
                            %     (1 @, no +,
                            %     @-dir contains a schema.m file).
                            % 4.  an MCOS static method (1 @, zero or more +)

                            if numAts == 0 && numPlus > 0   %Case 1
                                symObj.Type = MatlabType.Function; 
                            elseif numAts == 2 && numPlus == 0  %Case 2
                                % UDD static method
                                symObj.Type = MatlabType.UDDMethod;
                                % Add the UDD class to the list of 
                                % known classes.
                                add(symObj.classList, symObj);                             
                            elseif numAts == 1 && numPlus == 0  %Case 3 or 4
                                %Either a UDD package schema function or an MCOS
                                %static method.  Look for a schema.m file  
                                symPathName = ...
                                    symObj.WhichResult(1:fileSepIdx(end));
                                 d = dir(symPathName);
                                 cel = struct2cell(d);
                                 if ~isempty(strfind(cel(1,:),'schema.m')) || ...
                                    ~isempty(strfind(cel(1,:),'schema.p'))
                                     %Symbol is a UDD package schema function
                                     symObj.Type = MatlabType.UDDPackageFunction;
                                 else
                                     % No schema.m: symbol is an 
                                     % static method.
                                     symObj.Type = MatlabType.NotYetKnown;
                                 end
                            elseif numAts == 1 && numPlus > 0  %Case 4
                                symObj.Type = MatlabType.NotYetKnown;
                            end
                        end %  ~strncmp(symSimpleName, fileName, length(symSimpleName))
                    end % ~isDotQualified
                end
            end
        end
        
        %-------------------------------------------------------------        
        function found = findCorrespondentMCode(symObj, mExt)
            import matlab.depfun.internal.cacheExist;
            
            found = false;
            if nargin == 1
                mExt = '.m';
            end
            
            mWhichResult = fullfile(symObj.PartialPath,[symObj.FileName mExt]);
            if cacheExist(mWhichResult,'file')
                found = true;
                mt = matlab.depfun.internal.cacheMtree(mWhichResult);
                Comment = subtree(mtfind(mt,'Kind','COMMENT'));
                nonComment = mt - Comment;
                if ~isempty(nonComment)
                    symObj.WhichResult = mWhichResult;
                    symObj.Ext = mExt;
                else
                    warning(message('MATLAB:depfun:req:CorrespondingMCodeIsEmpty', ...
                        symObj.WhichResult))
                end
            end
        end
        
        %-------------------------------------------------------------
        function registerClass(symObj)
            if ~isempty(symObj.ClassName)
                type = classType(symObj.ClassName, symObj.ClassFile);
                sym = matlab.depfun.internal.MatlabSymbol( ...
                            symObj.ClassName, type, symObj.ClassFile, ...
                            symObj.ClassName, symObj.ClassFile);
                add(sym.classList,sym);
            end
        end
        
        %--------------------------------------------------------------
        function tf = isData(o)
        % isData Does the symbol represent a data file?
            tf = isKey(o.dataExtensions, lower(o.Ext));
        end
 
        %--------------------------------------------------------------       
        function tf = isCode(o)
        % isCode Does the symbol represent executable code?        
            tf = isKey(o.executableExtensions, o.Ext);
        end
        
        %-------------------------------------------------------------- 
        function tf = isStaticMethod(sym)
            tf = false;
            
            if isMethod(sym) && ~isBuiltin(sym) && isDotQualified(sym) && isPrincipal(sym)
                sym_proxy = proxy(sym);
                if isProxy(sym_proxy)
                    % A static class method must be referenced in the caller
                    % as a fully qualified symbol, which contains the class
                    % name. 
                    % WHICH('class.method') returns nothing unless 'method'
                    % is a static method of 'class'.
                    chopIdx = strfind(sym.Symbol, '.');
                    if ~isempty(chopIdx)
                        tf = strcmp(sym_proxy.Symbol, sym.Symbol(1:chopIdx(end)-1));
                        if ~tf
                            % G1331041 - Is the symbol an inherited static 
                            % method referenced as derivedClass.staticMethod?
                            % The proxy of derivedClass.staticMethod is baseClass,
                            % so the test above fails because baseClass does not match
                            % derivedClass.
                            new_sym = matlab.depfun.internal.MatlabSymbol( ...
                                sym.Symbol(1:chopIdx(end)-1), ...
                                matlab.depfun.internal.MatlabType.NotYetKnown);
                            determineClassType(new_sym);
                            tf = isClass(new_sym);
                            if tf
                                % Replace the base class path with the
                                % derived class path so that both classes
                                % can be included in the dependency graph.
                                sym.WhichResult = new_sym.WhichResult;
                                sym.ClassName = new_sym.ClassName;
                                sym.ClassFile = new_sym.ClassFile;
                            end
                        end
                    end
                end
            end
        end
        
        %--------------------------------------------------------------
        function tf = isProxy(p)
        % isProxy Can the symbol represent other symbols?
            tf = isClass(p) && ~isSliceable(p);
        end
        
        %--------------------------------------------------------------
        function tf = isPrincipal(p)    
        % isPrincipal Can the symbol p be represented by a proxy?
            tf = (isMethod(p) || isClassPrivate(p) || ...
                  isClassSchema(p)) && ~isSliceable(p) && ...
                  ~isPackageSchema(p) && ~isPackageFunction(p) && ...
                  ~isRuleBreakingMatlabBuiltin(p);
        end
        
        %--------------------------------------------------------------
        function tf = isRuleBreakingMatlabBuiltin(p)
            tf = any(strcmp(p.ClassName, p.ruleBreakingBuiltinClass));
        end
        
        %--------------------------------------------------------------
        function tf = isPackageFunction(o)
        % isPackageFcn Is the symbol a package function?
            fs = filesep;
            tf = isUDDPackageFunction(o.Type) || ...
                (isFunction(o.Type) && ...
                 (isempty(strfind(o.WhichResult, [fs '@'])) && ...
                  ~isempty(strfind(o.WhichResult, [fs '+']))));
        end

        %--------------------------------------------------------------
        function tf = isPackageSchema(o) 
        % isClassSchema Does the symbol represent a package schema file?
        % Path must contain one at-sign and end in schema.m.
            tf = false;
            fs = filesep;
            schema = [fs 'schema.m'];
            schemaIdx = strfind(o.WhichResult, schema);
            if isempty(schemaIdx)
                schema = [fs 'schema.p'];
                schemaIdx = strfind(o.WhichResult, schema);  
            end
            if ~isempty(schemaIdx)
                schemaIdx = schemaIdx(end); 
                atIdx = strfind(o.WhichResult, [fs '@']);
                tf = ~isempty(atIdx) && numel(atIdx) == 1 && ...
                     schemaIdx == numel(o.WhichResult) - numel(schema) + 1;
            end
        end 
        
        %--------------------------------------------------------------
        function tf = isClassSchema(o) 
        % isClassSchema Does the symbol represent a class schema file?
        % Path must contain two at-signs and end in schema.m.
            tf = false;
            fs = filesep;
            schema = [fs 'schema.m'];
            schemaIdx = strfind(o.WhichResult, schema);
            if isempty(schemaIdx)
                schema = [fs 'schema.p'];
                schemaIdx = strfind(o.WhichResult, schema);  
            end            
            if ~isempty(schemaIdx)
                schemaIdx = schemaIdx(end); 
                atIdx = strfind(o.WhichResult, [fs '@']);
                tf = ~isempty(atIdx) && numel(atIdx) == 2 && ...
                     schemaIdx == numel(o.WhichResult) - numel(schema) + 1;
            end
        end
        
        %--------------------------------------------------------------
        function tf = isScopedPrivate(o)
        % isScopedPrivate Does the symbol represent a private file
        % scoped to a class or package?
            fs = filesep;
            scoped = [ '[@+].*\' fs 'private' '\' fs ];
            tf = ~isempty(regexp(o.WhichResult, scoped, 'once'));
        end

        %--------------------------------------------------------------
        function tf = isClassPrivate(o)
        % isClassPrivate Does the symbol represent a private file
        % scoped to a class?
            fs = filesep;
            scoped = [ '@.*\' fs 'private' '\' fs ];
            tf = ~isempty(regexp(o.WhichResult, scoped, 'once'));
        end

        %--------------------------------------------------------------
        function tf = isClass(o)
        % isClass Is the symbol a class? (Ask the symbol type.)
            tf = isClass(o.Type);
        end
        
        %--------------------------------------------------------------
        function tf = isMethod(o)
        % isMethod Is the symbol a class method? (Ask the symbol type.)
            tf =  isMethod(o.Type);
        end      
        
        %--------------------------------------------------------------
        function tf = isExtensionMethod(o)
        % isExtensionMethod Is the symbol an extension method? By definition: a
        % class method outside the directory that holds the class
        % constructor.
            tf = false;
            if isMethod(o)
                ctorDir = fileparts(o.ClassFile);
                mthDir = fileparts(o.WhichResult);
                tf = ~isempty(ctorDir) && ~strcmp(ctorDir, mthDir);
            end
        end

        %--------------------------------------------------------------
        function tf = isExtrinsic(o)
        % isExtrinsic Is the symbol an extrincis file? (Ask the symbol type.)
            tf =  isExtrinsic(o.Type);
        end

        %--------------------------------------------------------------
        function tf = isUDDMethod(o)
        % isMethod Is the symbol a UDD class method? (Ask the symbol type.)
            tf =  isUDDMethod(o.Type);
        end

        %--------------------------------------------------------------
        function tf = isUDDPackageFunction(o)
        % isMethod Is the symbol a UDD class method? (Ask the symbol type.)
            tf =  isUDDPackageFunction(o.Type);
        end
        
        %--------------------------------------------------------------
        function tf = isFunction(o)
        % isFunction Is the symbol a function? (Ask the symbol type.)
            tf =  isFunction(o.Type);
        end
        
        %--------------------------------------------------------------
        function tf = isBuiltin(o)
        % isBuiltin Is the symobl a builtin function? (Ask the symbol type.)
            tf = isBuiltin(o.Type);
        end
        
        %--------------------------------------------------------------
        function tf = isSliceable(o)
        % isSliceable Is the symbol a member of a sliceable class?
        % All MATLAB builtin classes -- e.g., @cell, @char, and the like --
        % are sliceable, because their methods are not interdependent.
        %
        % Sliceable symbols never proxy any other files. The "methods" of
        % sliceable are not methods in the regular sense --
        % they don't depend on each other. Thus, using one of these
        % "methods" shouldn't trigger the inclusion of all of them into the
        % parts list. This matters most when considering extension 
        % directories. For example, calling @char/strfind does not imply
        % that all the files in all @char directories should be placed on
        % the parts list. 
        %
        % Methods of non-sliceable classes may have the same name as
        % sliceable classes -- several classes (curse them!) are known to
        % have methods named "double", for example. Don't be fooled. These
        % methods are NOT sliceable. Methods, in fact, are never sliceable.
        % But the class they belong to may be...

            if isMethod(o)
                tf = isKey(o.immortalBuiltinSymbols, o.ClassName);
            else
                tf = isKey(o.immortalBuiltinSymbols, o.Symbol);
            end
        
        end
        
        %--------------------------------------------------------------
        function tf = isDotQualified(o)
        % isDotQualified Does the symbol name contain dots? (Packages).
            tf = false;
            if o.Type ~= matlab.depfun.internal.MatlabType.Data
                dotIdx= strfind(o.Symbol,'.');
                tf = ~isempty(dotIdx);
            end
        end
        
        %--------------------------------------------------------------
        function tf = isDotNetAPI(o)
            tf = isDotNetAPI(o.Type);
        end
        
        %--------------------------------------------------------------
        function tf = isJavaAPI(o)
            tf = isJavaAPI(o.Type);
        end
        
        %--------------------------------------------------------------
        function tf = isPythonAPI(o)
            tf = isPythonAPI(o.Type);
        end
    end %methods block
end  %class


% =================     Local functions     =========================

%-------------------------------------------------------------
function sym = removeRightmostSubstring(sym)
%removeRightmostSubstring  Trim off right-most dot and trailing substring
%    The string is unaltered if it contains no dots.
    dotIdx = strfind(sym,'.');
    if ~isempty(dotIdx)
        sym = sym(1:(dotIdx(end)-1));
    end
end

%----------------------------------------------------------------
function tf = isFileInBuiltinTypeDir(fullPath)
    import matlab.depfun.internal.MatlabSymbol;
    import matlab.depfun.internal.MatlabInspector;
    dirPath = MatlabSymbol.trimFullPath(fullPath);
    [~,  immediateDirectory] = MatlabSymbol.trimFullPath(dirPath);
    if ~isempty(immediateDirectory) && immediateDirectory(1) == '@'
        tf = any(ismember(MatlabInspector.BuiltinClasses,immediateDirectory(2:end)));
    else
        tf = false;
    end

end

function extMap = initExecutableExtensions()
% Create a containers.Map with executable (code) extensions as keys, 
% for fast lookup.
    mext = mexext('all');
    extList = cellfun(@(e)['.' e], { mext.ext }, 'UniformOutput', false );
    extList = unique([ extList ...
       matlab.depfun.internal.requirementsConstants.executableMatlabFileExt ]);
    extMap = containers.Map(extList, true(size(extList)));
end

function extMap = initDataExtensions()
% Create a containers.Map with data extensions as keys, for fast lookup.
    extList = matlab.depfun.internal.requirementsConstants.dataFileExt;
    extMap = containers.Map(extList, true(size(extList)));
end


