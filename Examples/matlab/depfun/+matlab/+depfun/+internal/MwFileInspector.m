classdef (Abstract) MwFileInspector < handle
% MwFileInspector is the abstreact base-class of concreate file inspector 
% sub-classes, which are used to analyze various types of MathWorks files.
% Copyright 2016 The MathWorks, Inc.

    properties
        BuiltinListMap
        Rules
        Target
    end
    
    properties (Access = protected)
        addDep
        addClassDep
        addComponentDep
        addExclusion
        addExpected
        fsCache
        useDB
        pickUserFiles
        isWin32
        BuiltinMethodInfo
    end

    properties (Constant)
        BuiltinClasses = ...
            matlab.depfun.internal.requirementsConstants.matlabBuiltinClasses;
    end

    methods
        
        function analyzeSymbol(obj, client)
            symlist = getSymbols(obj, client.WhichResult);
            evaluateSymbols(obj, symlist, client);
        end

    end % Public methods    
    
    methods (Abstract)
        %----------------------------------------------------------------
        % Each inspector must implement its own determineType method.
        [symbol, unknown_symbol] = determineType(obj, w);
    end % Abstract public methods
        
    methods (Access = protected)
        
        function obj = MwFileInspector(r, t, fsCache, useDB, fcns)
            obj.BuiltinListMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.Rules = r;
            obj.Target = t;            
            obj.fsCache = fsCache;
            obj.useDB = useDB;
            obj.isWin32 = strcmp(computer('arch'), 'win32');
            % The clients of MatlabInspector are responsible for managing
            % the following passed-in function handles.
            obj.addDep = fcns.addDep;
            obj.addClassDep = fcns.addClassDep;
            obj.addComponentDep = fcns.addComponentDep;
            obj.addExclusion = fcns.addExclusion;
            obj.addExpected = fcns.addExpected;
            obj.pickUserFiles = fcns.pickUserFiles;
            
            % Must construct new maps every time we build a new
            % MatlabInspector, because the maps depend on the MATLAB path, 
            % which could change between constructor calls.
            obj.BuiltinMethodInfo = buildMapOfFunctionsForBuiltinTypes;
        end
        
    end % Protected base class constructor
    
    methods (Access = protected)
        
       %--------------------------------------------------------------
       function methodData = lookupBuiltinClassWithMethod(obj, symObj)
            if isKey(obj.BuiltinMethodInfo, symObj.Symbol)
                methodData = obj.BuiltinMethodInfo(symObj.Symbol);
            else
                methodData = struct('name',{},'location',{},'proxy',{});
            end
        end

        %--------------------------------------------------------------
        function recordExpected(obj, file, reason)
            obj.addExpected(file, reason)
        end

        %--------------------------------------------------------------
        function recordExclusion(obj, file, reason)
            obj.addExclusion(file, reason)
        end
        
        %--------------------------------------------------------------
        function recordPrivateDependency(obj, client, sym)
            import matlab.depfun.internal.MatlabType
            
            cachedType = obj.fsCache.Type([sym.WhichResult ' : ' sym.Symbol]);
            if isempty(cachedType) || cachedType == MatlabType.NotYetKnown
                determineSymbolType(sym, obj.fsCache, obj.addExclusion);
            else
                sym.Type = cachedType;
            end
            
            if ~isempty(sym.ClassName)
                % All these private functions are functions, but in
                % order to properly classify them (to determine their
                % status as proxies or principals) we must register
                % the classes they might or might not belong to.
                registerClass(sym);
            end
            
            recordDependency(obj, client, sym);
        end

        %----------------------------------------------------------------
        function symList = recordDependency(obj, client, symbol)
            symList = obj.addDep(client, symbol);
        end
        
        %----------------------------------------------------------------
        function recordBuiltinDependency(obj, client, symObj)
            import matlab.depfun.internal.MatlabSymbol;
            import matlab.depfun.internal.MatlabType;
            import matlab.depfun.internal.requirementsConstants;
            
            % Is symObj an extension method?
            extMth = isExtensionMethod(symObj);
            
            % Check to see if overloads of the name exist for
            % builtin types -- if so, record dependencies on
            % those overloads. (These classes are already
            % registered, no need to register them again.)
            clsList = lookupBuiltinClassWithMethod(obj, symObj);
            for o=1:numel(clsList)
                % If we're processing an extension method, we must Allow 
                % the class dependency, even if the class is Expected. 
                % The allow function requires lists to be terminated 
                % with @!@.
                if extMth
                    allowLiteral(obj.Rules,obj.Target, 'COMPLETION', ...
                        { clsList(o).proxy, '@!@' });
                end
                
                % Record a dependency on the builtin class.
                bCls = MatlabSymbol(clsList(o).name, ...
                    MatlabType.BuiltinClass, ...
                    clsList(o).proxy);
                
                recordClassDependency(obj, client, bCls);
                
                % If the builtin class is sliceable, record a dependency 
                % on the method as well, since sliceable classes do not
                % proxy their methods.
                
                if isSliceable(bCls)
                    fileNames = cellfun(@(x)fullfile(clsList(o).location,strcat(symObj.Symbol,x)), ...
                        requirementsConstants.executableMatlabFileExt,'UniformOutput',0);
                    fileNamesExistIdx = cellfun(@(f)matlabFileExists(f),fileNames,'UniformOutput',0);
                    fileName = cell2mat(fileNames(find(cell2mat(fileNamesExistIdx),1)));
                    
                    if(~isempty(fileName))
                        bMth = MatlabSymbol(symObj.Symbol, ...
                            MatlabType.ClassMethod, ...
                            fileName);
                        recordDependency(obj, client, bMth);
                    end
                end
            end
        end
        
        %----------------------------------------------------------------        
        function recordClassDependency(obj, client, sym)
            obj.addClassDep(client, sym);
        end
        
        %----------------------------------------------------------------        
        function recordComponentDependency(obj, client, sym)
            obj.addComponentDep(client, sym);
        end
        
        %----------------------------------------------------------------        
        function tf = isMatlabFile(obj, filename)
            userFile = obj.pickUserFiles(filename);
            if isempty(userFile)
                tf = true;
            else
                tf = false;
            end
        end
        
        %--------------------------------------------------------------
        function evaluateSymbols(obj, symlist, client)
        % evaluateSymbols  Evaluate symbols extracted from the client file
        %
        % Iterate over a list of symbols, looking for classes and functions.  A
        % symbol may be dot-qualified.  A class is identified when the symbol is
        % a class name or a dot-qualified static method or constant property
        % reference.  A function or script is identified when a symbol is not a
        % class, can be found on the path (as reported by WHICH), and can be
        % ruled out as a class method.

            import matlab.depfun.internal.MatlabSymbol;
            import matlab.depfun.internal.MatlabType;
            import matlab.depfun.internal.ClassSet;
            import matlab.depfun.internal.cacheWhich;
            import matlab.depfun.internal.cacheExist;
            import matlab.depfun.internal.requirementsConstants;

            file = client.WhichResult;
            parentDir = MatlabSymbol.trimFullPath(file);
            [privateFiles, privateDirName] = getPrivateFiles(parentDir);
            % remove file extension to get symbol names            
            if obj.isWin32
                privateSyms = regexprep(privateFiles, ...
                    ['(' requirementsConstants.executableMatlabFileExtPat ...
                     '|\.dll$)'], '');
            else
                privateSyms = regexprep(privateFiles, ...
                    requirementsConstants.executableMatlabFileExtPat, '');
            end
            
            % Asking about private functions is expensive too.
            pfMap = [];
            if ~isempty(privateSyms)
                pfMap = ...
                    containers.Map(privateSyms, true(size(privateSyms)));
            end
            
            % Let MatlabSymbol know about the new names, so that it can
            % add any that might represent class names to its list of 
            % classes. Calling WHICH here short-circuits the calls to 
            % which in the MatlabSymbol constructors.
            pathlist = cell(size(symlist));
             
            externalAPIComponent = cell(1,0);
            
            %tmpcell for holding builtins called by this symbol
            tmpCell = {};
            % For every symbol
            for k = 1:length(symlist)
                symName = symlist{k};
                pathlist{k} = cacheWhich(symName);

                if  ~isempty(pfMap) && isKey(pfMap, symName)

                    possibleFile = strcat(symName, ...
                        requirementsConstants.executableMatlabFileExt);
                    if obj.isWin32
                        possibleFile{end+1} = [symName '.dll']; %#ok
                    end

                    keep = ismember(possibleFile, privateFiles);
                    possibleFile = possibleFile(keep);
                    possibleFile = fullfile(privateDirName, possibleFile);

                    for f = 1:numel(possibleFile)
                        svc = MatlabSymbol(symName, ...
                            MatlabType.NotYetKnown, possibleFile{f});
                        recordPrivateDependency(obj, client, svc);
                    end
                % Not a private file
                else
                    if obj.useDB
                        % only analyze user files
                        if isempty(strfind(pathlist{k},...
                                requirementsConstants.BuiltInStr)) ...
                                && isMatlabFile(obj, symName)
                            % For the MCR target, the mapping from the
                            % user file to the required components is 
                            % not necessary. Required mcr products will
                            % be identified based on the final required
                            % file list.
                            pathlist{k} = '';
                            continue;
                        end
                    end

                    % Allow MatlabSymbol to make a guess at the symbol type
                    % Then, figure out the real symbol type
                    symObj = MatlabSymbol(symName, MatlabType.NotYetKnown, ...
                                          pathlist{k});
                    % Retrieve cached MatlabType information,
                    % if it has been analyzed before.
                    %
                    % The symbol of a static method and the symobl of 
                    % the class constructor may be correspondent to the
                    % same file, so do not use the cached symbol type
                    % when the symbol is a static method.
                    symObj.Type = obj.fsCache.Type([pathlist{k} ' : ' symName]);
                    if isempty(symObj.Type) || ...
                            symObj.Type == MatlabType.NotYetKnown || ...
                            isStaticMethod(symObj)
                        symObj.Type = MatlabType.NotYetKnown;
                        determineSymbolType(symObj, obj.fsCache, obj.addExclusion);
                    end

                    % The name identifies a builtin function or class.
                    if isBuiltin(symObj)
                        % Might get duplicates, which will be unique-ified 
                        % out later. 
                        tmpCell{end+1} = symObj;  %#ok<AGROW>
                        if isClass(symObj) 
                            recordClassDependency(obj, client, symObj);
                        else
                            % If the symbol overloads the name of a
                            % builtin method, record a dependency on
                            % the appropriate builtin class.
                            recordBuiltinDependency(obj, client, symObj);
                        end
                    elseif isMethod(symObj)
                        if isStaticMethod(symObj)
                            recordDependency(obj, client, symObj);
                        else
                            % ignore non-static class methods
                            pathlist{k} = '';
                        end
                    elseif isUDDPackageFunction(symObj)
                        recordDependency(obj, client, symObj);
                    elseif isClass(symObj) 
                        recordClassDependency(obj, client, symObj);
                    elseif isFunction(symObj)
                        % Symbol is a top-level function or package-based 
                        % function, or a script. Put the file name on the 
                        % list of files this file depends on.
                        recordDependency(obj, client, symObj);
                        % If symObj overloads a method of a built-in
                        % class, record that depenency (on the class and
                        % maybe the method) as well.
                        recordBuiltinDependency(obj, client, symObj);
                    elseif isJavaAPI(symObj)
                        % matlab_toolbox_depfun is a place holder for
                        % the real component jmi, which is shipped by mcr_numerics in 15a.
                        % It should be replaced by jmi in 15b when jmi is taken out of 
                        % mcr_numerices. When g1236179 get fixed, change the following line to
                        % union(externalAPIComponent, 'jmi'); 
                        externalAPIComponent = ...
                            union(externalAPIComponent, 'matlab_toolbox_depfun');  
                    elseif isDotNetAPI(symObj)
                        externalAPIComponent = ...
                            union(externalAPIComponent, 'dotnetcli');
                    elseif isPythonAPI(symObj)
                        externalAPIComponent = ...
                            union(externalAPIComponent, 'pycli');
                    elseif isData(symObj)
                        recordDependency(obj, client, symObj);
                    elseif isExtrinsic(symObj)
                        recordDependency(obj, client, symObj);
                    else
                        % Ignorable
                        pathlist{k} = '';
                    end 
                end % ! private files
            end % for loop
            
            % save the builtin symbols invoked by client into the map
            if ~isempty(tmpCell)
                obj.BuiltinListMap(file) = tmpCell;
            end
            % Recording client's dependency on components that own the 
            % the client's built-in and non-builtin symbols.
            keep = ~cellfun('isempty', pathlist);
            pathlist = pathlist(keep);
            symlist = symlist(keep);

            if ~isempty(pathlist) || ~isempty(externalAPIComponent)
                builtinIdx = ~cellfun('isempty', ...
                                      strfind(pathlist, ...
                                      requirementsConstants.BuiltInStr));
                serviceList.builtin = symlist(builtinIdx)';
                serviceList.file = pathlist(~builtinIdx)';
                serviceList.component = externalAPIComponent;
                recordComponentDependency(obj, client, serviceList);
            end
        end % evaluateSymbols function
        
    end % Protected methods
    
    methods (Abstract, Access = protected)
        
        %----------------------------------------------------------------
        % Each inspector must implement its own getSymbols method.
        result = getSymbols(obj, w);
        
    end  % Abstract protected methods
        
end

% ================= Local functions =========================

%----------------------------------------------------------------
function fcnMap = buildMapOfFunctionsForBuiltinTypes
% buildMapOfFunctionsForBuiltinTypes Record full paths of builtin methods
%
%   map(function.m) -> list of class names and containing directories
%
%     fcnMap(f).name -> class name symbol, suitable for MatlabSymbol
%     fcnMap(f).location -> cell array of class directories, one per class
%         that overloads the function.
    import matlab.depfun.internal.cacheWhich;
    import matlab.depfun.internal.requirementsConstants;

    numTypes = length(matlab.depfun.internal.MatlabInspector.BuiltinClasses);
    fcnMap = containers.Map;
    % For each builtin type
    for k=1:numTypes
        % Get the name of a builtin type (from the static list)
        aType = matlab.depfun.internal.MatlabInspector.BuiltinClasses{k};
		
        % Find all the methods for that type
        whatResults = what(['@' aType]);
        if ~isempty(whatResults)
            % Some fileds in the WHAT result may not always be available, e.g, mlx. 
            wfIdx = cellfun(@(f)isfield(whatResults,f), requirementsConstants.whatFields);
            wf = requirementsConstants.whatFields(wfIdx);
            
            % For each directory containing methods of aType
            % Extended to all executable extensions.
            for n=1:length(whatResults)
                fcn = cellfun(@(f)(whatResults(n).(f))', wf, ...
                                   'UniformOutput', false);
                fcn = [ fcn{:} ]';
                % For each method in the directory
                for j=1:length(fcn)
                    [~,key,~] = fileparts(fcn{j});  % Strip off .m
                    
                    % Add an entry to each map. Each method name maps to
                    % a structure array. 
                    % 
                    % The name field stores the names of the classes that 
                    % overload the function.
                    %
                    % The location field is a cell array of locations where
                    % the overloading function occurs.
                    
                    fcnInfo.name =  aType;
                    fcnInfo.proxy = cacheWhich(aType);
                    fcnInfo.location = whatResults(n).path;
                    if isempty(fcnInfo.proxy)
                        fcnInfo.proxy = [...
                         requirementsConstants.BuiltInStrAndATrailingSpace ...
                         '(' strrep(fcnInfo.location, '@', '') ')'];
                    end 
                    
                    if isKey(fcnMap, key)
                       fcnMap(key) = [ fcnMap(key) fcnInfo ];
                    else
                        fcnMap(key) = fcnInfo;
                    end
                end
            end
        end
    end
end
