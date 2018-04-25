classdef Completion < handle
% The Completion of a set of functions is a set consisting of the origninal
% functions and all the resources that the original set requires in order to 
% run. 
% 
% A Completion consists of:
% 
%    * A root set, which consists of the original functions.
%
%    * A list of parts, which consists of the original functions and the
%      functions and files the root set requires.
%
%    * A Schema, the set of rules that governs the generation of the parts
%      list from the root set.
%
%    * A dependency graph, which describes the function call and file
%      usage dependencies between the files in the part list.
%
%    * A target environment, which identifies the resources and licenses
%      the Completion may presume to be available.
%
% Copyright 2012-2016, The MathWorks, Inc.

    properties (SetAccess = protected)
        Schema
        Platforms
        Target = matlab.depfun.internal.Target.MATLAB;
    end

    properties (Access=private)
        % Don't initialize any of these properties here, or the value will
        % stick across multiple instances. This is really only an issue for
        % handle objects, but still, good practice to avoid it.
        
        % The call (or use) tree of dependencies.
        DependencyGraph

        % Excluded files
        ExclusionList

        % Files expected in the target environment.
        ExpectedList

        % Initial inputs -- roots of the call tree (which is really a 
        % forest, if you want to be technical about it).
        RootSet

        % Inspectors extract symbols from files and assign classifications
        % to symbols.
        Inspectors

        % A list of symbols that need analysis. Consider symbols equal if
        % their 'WhichResults' fields match.
        ScanList

        % Maximum depth of the dependency forest -- currently, the only
        % useful values are 1 (immediate dependencies only) and inf (all
        % possible dependencies). So why not a boolean? Judgement call.
        CompletionLevel
        
        % Map file names to vertex IDs for fast lookup. 
        File2Vertex

        % Names and root directories of installed toolboxes
        CachedTbxData
        
        % Slice classes, or not
        sliceClass
        
        % The name of the symbol class
        symCls
        
        % Cache of file system data -- WHICH and EXIST
        FsCache
        
        % Cache the list of files which has been analyzed
        isAnalyzed
        
        % use database for MATLAB files?
        % true, read dependencies for MATLAB files from existing database
        % false, compute dependencies for MATLAB files without using
        % existing database
        useDB
        
        % use the exclusion list from database?
        useExclusionListFromDB
        
        % list of MATLAB files        
        matlabFiles
        
        % Construct from requirementsConstants in Completion constructor.
        dfdb_path
        % DepedencyDepot
        DepDepot
        
        % navigator of the PCM database
        pcm_navigator
        
        % Cache, so we don't have to ask frequently
        isWin32
        
        % The map of built-in symbols and owning components (1-to-1)
        builtinSymbolToComponent
        
        % The map of symbols files built-inList
        builtinList

% Due to several component boundary violations in the current code base, 
% this property is disabled for 16a.
%         % The map of MATLAB modules and owning components (1-to-1)
%         matlabModuleToComponent
        
        % The map of source entries and owning components
        sourceToComponent

        % The map of given files and required components (1-to-many)
        fileToComponents
        
        % List of uncompilable toolbox
        uncompilabeTbx

        % problematic files
        problematicFiles

        % true or false, indicates whether this is a special run for libMATLAB dependency analysis
        isLibMATLABDeps
        
        % Store PathUtility object for re-use
        PathUtility
    end

    properties(Constant)
        PlatformExt = initPlatformExt();
    end
    
    methods (Static)
        function obj = loadobj(S)
            if isstruct(S)
                obj = matlab.depfun.internal.Completion();
                
                obj.Schema = S.Schema;
                obj.Platforms = S.Platforms;
                obj.Target = S.Target;
                obj.DependencyGraph = S.DependencyGraph;
                obj.ExclusionList = S.ExclusionList;
                obj.ExpectedList = S.ExpectedList;
                obj.RootSet = S.RootSet;
                
                obj.ScanList = S.ScanList;
                obj.CompletionLevel = S.CompletionLevel;
                obj.File2Vertex = S.File2Vertex;
                obj.CachedTbxData = S.CachedTbxData;
                obj.sliceClass = S.sliceClass;
                obj.FsCache = S.FsCache;
                obj.isAnalyzed = S.isAnalyzed;
                obj.useDB = S.useDB;
                obj.matlabFiles = S.matlabFiles;
                obj.dfdb_path = S.dfdb_path;
                obj.isWin32 = S.isWin32;
                obj.symCls = S.symCls;
                obj.PathUtility = S.PathUtility;
                
                obj.builtinSymbolToComponent = S.builtinSymbolToComponent;
% Due to several component boundary violations in the current code base, 
% this property is disabled for 16a.
%                 obj.matlabModuleToComponent = S.matlabModuleToComponent;
                obj.sourceToComponent = S.sourceToComponent;
                obj.fileToComponents = S.fileToComponents;
                obj.problematicFiles = S.problematicFiles;
                
                % since the MatlabInspector constructor requires those function
                % handles, which relies on the current completion object.
                buildInspector(obj);
            end
        end
    end

    methods (Access = private)
        
        function principals = builtinPrincipals(obj) 
        % Get built-ins from Inspectors
            principals = {};
            inspectorName = keys(obj.Inspectors);
            proxy = matlab.depfun.internal.flatten(values(obj.Inspectors(inspectorName{1}).BuiltinListMap));
            for i = 2:numel(inspectorName)
                % proxy is a cell array of MatlabSymbol
                proxy = [proxy  ...
                     matlab.depfun.internal.flatten(values(obj.Inspectors(inspectorName{i}).BuiltinListMap))]; %#ok
            end
            if ~isempty(proxy)
                proxy = [proxy{:}];
                [~,uniq] = unique({proxy.WhichResult});
                proxy = proxy(uniq);
            end
            
            % Keep only those that are proxies
            keep = arrayfun(@(s)isProxy(s),proxy);
            proxy = proxy(keep);
            
            % For each, retrieve principals, building up an array of
            % MatlabSymbol objects.
            for j = 1:numel(proxy)
                principals = [ principals proxy(j).principals() ]; %#ok
            end
            if ~isempty(principals)
                principals = unique({principals.WhichResult});
            else
                principals = {};  % Don't return empty MatlabSymbol
            end
        end
        
        function recordFile2VertexID(obj, file, vid)
        % recordFile2Vertex Remember a file to vertex id mapping.
            if isKey(obj.File2Vertex, file)
                error(message(...
                    'MATLAB:depfun:req:InternalDupFileVertex', file));
            else
                obj.File2Vertex(file) = vid;
            end
        end
        
        function vid = findVertexID(obj, sym)
        % findVertexID Lookup a vertex in the file name -> vertex map
            vid = [];
            file = sym.WhichResult;
            
            if isKey(obj.File2Vertex, file)
                vid = obj.File2Vertex(file);
            end
        end        
        
        function removeSymbol(obj, sym)
            for k=1:numel(sym)
                vid = findVertexID(obj, sym(k));
                removeVertex(obj.DependencyGraph, vid);
            end
            if ~isempty(sym)
                remove(obj.File2Vertex, {sym.WhichResult});
            end
        end
        
        function computeDependencies(obj)
        % Compute dependencies if there's anything on the scan list.
        % If the dependency graph is non-empty, it must be left over from
        % a previous computation, so create a new one for this new completion.
      
            if ~isempty(obj.ScanList)
                % Create new graph if we don't have one, or the one we
                % have is non-empty.
                if isempty(obj.DependencyGraph)                
                    % Make a new graph object, directed, of course.
                    obj.DependencyGraph = ...
                        matlab.internal.container.graph.Graph(...
                                                        'Directed', true);
                    
                    % Also reset the platform list
                    obj.Platforms = matlab.depfun.internal.StringSet;
                    
                end
                
                while ~isempty(obj.ScanList)
                    findDependentFiles(obj);
                    sym = knownSymbols(obj);
                    
                    % Do not apply additional set rules to extrinsic files.
                    if ~isempty(sym)
                        extrinsic = [sym.Type] == ...
                                matlab.depfun.internal.MatlabType.Extrinsic;
                        sym = sym(~extrinsic);
                    end
                    
                    files = {};
                    if ~isempty(sym)
                        files = { sym.WhichResult };
                    end
                    
                    % Apply the set rules
                    [addedFiles, keep, rMap] = ...
                            ruleActions(obj, 'COMPLETION', files);
                    
                    % Files removed from the Completion set must be removed
                    % from the graph. And all their dependencies too.
                    removeSymbol(obj, sym(~keep));
                    
                    while ~isempty(addedFiles)
                    % Files added to the Completion must be added to the
                    % scan list for regular processing. Of course, as the
                    % ScanList holds symbols, the files must be made into 
                    % symbols.
                    [sym, uType] = resolveRootSet(obj, addedFiles);
            
                    % Add the discoverable (apparently real) files of 
                    % unclaimed type (those for which there are no 
                    % inspectors) to the list of new symbols.
                    [resolved, u] = resolveUnknownType(obj, uType);
                    
                    sym = [sym resolved];
                    addedFiles = {};
                    
                    % TODO? Error if there are unknown unknowns? Which
                    % there are if ~isempty(u).
                    
                    % Add the new symbols to the scan list.
                    for k=1:numel(sym)
                        obj.ScanList.enqueue(sym(k));
                        if strcmp(sym(k).Ext,'.p')
                            pSym = CopyMatlabSymbol(sym(k));
                            if findCorrespondentMCode(pSym,'.m')
                                addedFiles = [addedFiles pSym.WhichResult]; %#ok
                            end
                        end
                    end
                    
                    end
                end
            end
        end
        
        function compList = requiredComponents(obj, files)
        % Return a list of required components for given files
        
            compList = cell(1,0); % For UNION
            if ~isempty(files)
                % Find the owning component of each required file
% This section uses the Component-MATLAB Module data. Due to several
% component boundary violations in the current code base, this section is
% disabled for 16a.
%                 matlabModule = filename2path(files);
%                 keep = isKey(obj.matlabModuleToComponent, matlabModule);
%                 if any(keep)
%                     owningComp = values(obj.matlabModuleToComponent, ...
%                                        matlabModule(keep));
%                     if ~isempty(owningComp)
%                         compList = union(compList, owningComp);
%                     end
%                 end

                % This section uses the Component-Source data as a compensation
                % for the component boundary violations for 16a.
                owningComp = findComponentBasedOnScmData(obj, files);
                if ~isempty(owningComp)
                    compList = union(compList, owningComp);
                end

                if obj.useDB % DFDB
                    % WHICH errors if input contains 'built-in ('.
                    isWhichResult = true;
                    userfiles = obj.PickOutUserFiles(files, isWhichResult);
                else
                    userfiles = files;
                end

                % Find component dependencies of each newly analyzed
                % user file.
                if ~isempty(userfiles)
                    keep = isKey(obj.fileToComponents, userfiles);
                    depComp = values(obj.fileToComponents, userfiles(keep));
                    depComp = [depComp{:}];
                    if ~isempty(depComp)
                        compList = union(compList, depComp);
                    end
                end

                % Find component dependencies of each pre-analyzed
                % file.
                if obj.Target == matlab.depfun.internal.Target.MCR ...
                        && ~isempty(obj.matlabFiles)
                    % If the user files already depend on all MCR products,
                    % unnecessary to query the database for 
                    % pre-analyzed files for performance.
                    cList = obj.pcm_navigator.componentShippedByMCRProducts;
                    intersectComp = ...
                        cellfun(@(l)intersect(compList, l), cList, ...
                        'UniformOutput', false);
                    coveredMCRProductIdx = ~cellfun('isempty', intersectComp);
                    if ~all(coveredMCRProductIdx)
                        precomputedDepComp = obj.DepDepot.requiredComponents(obj.matlabFiles);
                        if ~isempty(precomputedDepComp)
                            compList = union(compList, precomputedDepComp);
                        end
                    end
                end
            end
        end
        
        function pid = productsShippingComponent(obj, components)
        % Return a list of products which ship the given components
            pid = cell(size(components));
            
            if ~isempty(components)
                pinfo = cellfun( ...
                    @(c)obj.pcm_navigator.productShippingComponent(c,obj.Target), ...
                    components, 'UniformOutput', false);
                for k = 1:numel(components)
                    if ~isempty(pinfo{k})
                        pid{k} = [pinfo{k}.extPID];
                    end
                end
            end
        end
        
        function products = getProductInfo(obj, product_ids)
        % Input:
        %   product_ids - A cell array, whose length is the same as 
        %                 the number of required components. 
        %                 Each element is a cell array of 
        %                 external ids of products required by the
        %                 correspondent component.
        % Output:
        %   products - A struct array that contains a list of unique
        %              required products. Each element has four fileds:
        %              Name - External name of the required product;
        %              Version - version of the required product;
        %              ProductNumber - External product identifier;
        %              Certain - A bool value that indicates the listed 
        %                        product is certainly or may be required, 
        %                        because more than one products may ship 
        %                        the same required component.        
            
            products = struct.empty;
            
            import matlab.depfun.internal.requirementsConstants
            
            if obj.Target == matlab.depfun.internal.Target.MCR
                product_ids{end+1} = ...
                    requirementsConstants.required_min_product_mcr;
            else
                product_ids{end+1} = ...
                    requirementsConstants.required_min_product_other;
            end
            
            % How many products may ship each required component?
            count_list = cellfun(@(l)numel(l), product_ids);            
            
            % A list of unique products, which are certainly required.
            certain_idx = (count_list == 1);
            unique_list = unique([product_ids{certain_idx}]);
            
            % Found more than one products may ship the same 
            % required component. Uncertain which one is really
            % required at this point, so hold the decision 
            % to the end.
            pending_idx = (count_list > 1);
            pending_list = product_ids(pending_idx);
                          
            for k = 1:numel(unique_list)
                pinfo = obj.pcm_navigator.productInfo(unique_list(k));
                if ~isempty(pinfo)
                    products(end+1).Name = pinfo.extPName; %#ok
                    products(end).Version = pinfo.version;
                    products(end).ProductNumber = pinfo.extPID;
                    products(end).Certain = true;
                end
            end
            
            if ~isempty(pending_list)
                for i = 1:numel(pending_list)
                    certainIdx = ismember(pending_list{i}, unique_list);
                    if ~any(certainIdx)
                        % If the pending component has not been shipped 
                        % by any product. It is uncertain which one is
                        % truely required or optimal.
                        % Honestly list uncertion options and 
                        % leave the decision to the customer.
                        for j = 1:numel(pending_list{i})
                            pinfo = obj.pcm_navigator.productInfo(pending_list{i}(j));
                            if ~isempty(pinfo)
                                products(end+1).Name = pinfo.extPName; %#ok
                                products(end).Version = pinfo.version;
                                products(end).ProductNumber = pinfo.extPID;
                                products(end).Certain = false;
                            end
                            unique_list(end+1) = pending_list{i}(j); %#ok
                        end
                    end
                end
            end
        end
        
        function products = requiredProducts(obj, files)
        % requiredProducts What products do these files require?
        % The result is a struct array.
        % Each element contains three fields: Name, Version and
        % ProductNumber, Certain.
        
            product_external_ids = {};
            if ~isempty(files)
                reqComp = obj.requiredComponents(files);
                
                if ~isempty(reqComp)
                    product_external_ids = ...
                        obj.productsShippingComponent(reqComp);
                end
                
                % Work-around for user authored .jar and .class files 
                % which are included with -a. 
                % MEX files also require mcr_core. (G1318387)
                % Their presence indicates that mcr_core is required.
                if obj.Target == matlab.depfun.internal.Target.MCR ...
                    && any(~cellfun('isempty',regexp(files,'.+\.(jar|class|mex\w+)$')))
                    product_external_ids{end+1} = ...
                        matlab.depfun.internal.requirementsConstants.mcr_core_pid; 
                end
            end
            
            products = obj.getProductInfo(product_external_ids);
        end
        
        function symbols = knownSymbols(obj, filter)
        % knownPaths Return all the symbols with paths that match a filter
            if nargin == 1
                filter = '';
            end
            % Retrieve the data objects stored in the graph's vertices.
            symbols = [];
            if obj.DependencyGraph.VertexCount > 0
                symbolList = partProperty(obj.DependencyGraph, 'Data', 'Vertex');
                symbols = [ symbolList.symbol ];

                % Apply the filter, if any, to the paths.
                if ~isempty(filter) && ~isempty(symbols)
                    match = regexp({symbols.WhichResults}, ...
                                       filter, 'once');
                    % Keep the symbols with matching paths
                    keepIdx = ~cellfun('isempty', match);
                    symbols = symbols(keepIdx);
                end
            end
        end
       
        function traceList = buildTraceList(obj, canonicalPath)
            % Don't canonicalize file paths by default.
            if nargin == 1
                canonicalPath = false;
            end
            traceList = struct([]);

            % Don't do any work if there's nothing to do
            if isempty(obj.DependencyGraph) || ...
                   obj.DependencyGraph.VertexCount == 0, return; end

            % An array of the 'Data' objects at every vertex. They'd better
            % be homogenous. Extract the 'symbol' field from the vertex
            % data.
            symbolList = partProperty(obj.DependencyGraph, 'Data', 'Vertex');
            symbolList = [symbolList.symbol];

            % Use while-loop because for k=1:length(symbolList) doesn't
            % re-evaluate length(symbolList) at the beginning of the loop.
            k = 1;
            while k <= length(symbolList)
                % Don't return any dot-qualified symbols, because they
                % might originate from the same file as a non-dot-qualified
                % symbol. The bare form is the canonical form. 

                % Note: since any symbol might be a proxy and even 
                % MathWorks symbols might have extension directories
                % outside of MathWorks directories, expand every
                % symbol to its (potential) list of principals.

                symbol = symbolList(k);
                pList = principals(symbol);
                
                if ~isempty(pList)
                    
                    % Exclude principals according to the per-target
                    % rules. For example, a user class with the same
                    % name as a MathWorks class may list MathWorks
                    % files as principals. But MathWorks files are
                    % supposed to be excluded by certain targets
                    % (MATLAB, for example).
                 
                    filePath = {pList.WhichResult};
                    [exclude, expect] = notShipping(obj,filePath,'COMPLETION');
                    keep = ~(exclude | expect);
                    pList = pList(keep);
                    
                    % Add the principals to the end of the symboList
                    % that we're currently looping through. I know,
                    % modifying the list you're iterating over is "bad
                    % form", but here I am telling you about it -- don't
                    % ignore me -- and it is so very convenient.
                    if ~isempty(pList)
                        symbolList = [symbolList pList];
                    end
                end

                if matlab.depfun.internal.cacheExist(symbol.WhichResult,'file')
                    traceList(end+1).name = symbol.Symbol;
                    traceList(end).type = char(symbol.Type);
                    traceList(end).path = symbol.WhichResult;
                    traceList(end).language = 'MATLAB';
                end

                k = k + 1;
            end
            
            if matlab.internal.alias.isAliasOn % feature('mcosalias')
                user_alias_files = findUserAliasFiles(traceList);
                for k = 1:length(user_alias_files)
                    traceList(end+1).name = 'alias';
                    traceList(end).type = char(matlab.depfun.internal.MatlabType.Data);
                    traceList(end).path = user_alias_files{k};
                    traceList(end).language = 'MATLAB';
                end
            end

            if canonicalPath % Only by request
                for k=1:length(traceList)
                    traceList(k).path = strrep(traceList(k).path,'\','/');
                end
            end

            % Never return duplicates. 
            if ~isempty(traceList)
                [~,i,~] = unique({traceList.path});
                traceList = traceList(i);
            end

        end

        function known = isInDependencyGraph(obj, d)
        % isInDependencyGraph Determine if the rootSet depends on symbol d.
        % Search the dependency graph for a vertex with the same symbol data.
        % This needs to be very fast since it forms part of the core dynamic
        % discovery algorithm. findIf requires a callback to MATLAB from
        % C++. This may or may not be fast enough.
            
        % @todo: Possible performance enhancements:
        % * Augment the Completion object with a file name -> vertex ID map, 
        %   for hyperspeed lookup. (At the expense of effectively duplicating 
        %   much of the graph data.)

           % Find all the parts with a symbol data matching d.
            vid = findVertexID(obj, d);
            known = ~isempty(vid);
        end

        function id = findOrCreateVertex(obj, referant, create)
            id = [];
            if isstruct(referant)
                % Find the first vertex with symbol data matching 
                % the referant's symbol
                id = findVertexID(obj, referant.symbol);
                if isempty(id) && create
                    id = addVertex(obj.DependencyGraph, referant);
                    recordFile2VertexID(obj, referant.symbol.WhichResult, id);
                end
            elseif isnumeric(referant)
                
            end
        end

        function recordExclusion(obj, file, reason)
            obj.ExclusionList(end+1).file = file;
            obj.ExclusionList(end).why = reason;
        end

        function recordExpected(obj, file, reason)
            canonicalized = strrep(file, '/', filesep);            
            if isempty(obj.ExpectedList) 
                rq.file = canonicalized;
                rq.why = reason;
                obj.ExpectedList = rq;
            elseif ~ismember(canonicalized, {obj.ExpectedList.file})
                rq.file = canonicalized;
                rq.why = reason;
                obj.ExpectedList(end+1) = rq;
            end
        end

        function recordPlatformExt(obj, ext)
            % MATLAB extensions are case sensitive.
            % Platform independent file extensions are not keys 
            % in obj.PlatformExt.

            % TODO: Refine test for .dll and .so to check for platform
            % specific directory name in path string?
            % TODO: Another suggestion: .dll and .so only imply current
            % platform? E.g. .dll implies win32 on a win32 machine.

            if isKey(obj.PlatformExt, ext)
                p = obj.PlatformExt(ext);
                add(obj.Platforms, p{:});
            end
        end
        
        function recordPlatform(obj, service)
        % recordPlatform 
            e = service.Ext;
            recordPlatformExt(obj, e);
        end

        function recordClassDependency(obj, client, symbol)
        % recordClassDependency Record dependencies on class files.
        % TODO: Eliminate? Anything special to do here? Most responsibilities
        % moved to ClassSymbol.

            % Make client depend on symbol's proxy.
            recordDependency(obj, client, symbol);

        end
        
        function enqueueUnanalyzedSymbol(obj, sym)
            if ~obj.useDB ...
                   || ~isempty(obj.PickOutUserFiles(sym.WhichResult,true))
                %  Enqueue the symbol to the scan list only if the file 
                % exists and has not been analyzed.      
                if matlab.depfun.internal.cacheExist(sym.WhichResult,'file') ...
                    && ~isKey(obj.isAnalyzed, sym.WhichResult)
                    obj.ScanList.enqueue(sym);
                end
            end
        end
        
        function addClassToScanList(obj, proxy)
        % Add the given class (proxy and principals) to the scan list.
        
            pList = principals(proxy);
            arrayfun(@(s)enqueueUnanalyzedSymbol(obj, s), pList);
            
            % Add the proxy -- proxy symbol does not appear
            % in its list of principals.
            enqueueUnanalyzedSymbol(obj, proxy);
        end

        function symList = recordDependency(obj, client, service)
        % recordDependency Client depends on service. Write it down.
            import matlab.depfun.internal.MatlabType;
            import matlab.depfun.internal.MatlabSymbol;
        
            symList = [];
            
            % ----------------------------
            % Deal with the client symbol
            % ----------------------------
            
            % Retrieve the proxy symbol for the client. This allows us to
            % capture the dependencies of a principal but represent the 
            % principal by the proxy in the dependency graph.
            client = proxy(client);

            % Since the initial RootSet may be different from the
            % initial ScanList, some symbols in that ScanList may
            % not be in the RootSet. They have not yet
            % been inserted into the DependencyGraph before
            % reaching this point. Thus, we need to check the
            % existence of the client too.
            src.symbol = client;
            if ~obj.isInDependencyGraph(client)
                source = findOrCreateVertex(obj, src, true);
            else
                source = findOrCreateVertex(obj, src, false);
            end
            
            % -----------------------------
            % Deal with the service symbol
            % -----------------------------
            
            if ~isa(service,obj.symCls)
                error(message('MATLAB:depfun:req:InvalidInputType',...
                              3,class(service), obj.symCls));
            end
            
            if isExcluded(obj, service.WhichResult)
                return;
            end
             
            % Never record a dependency on a principal. You'll likely get it
            % wrong; all the principals required by the input file set
            % should be pulled in by dependencies on their proxies.
            %
            % However, we must record dependencies on static methods of a
            % class, as programs can use static methods without ever
            % creating class instances -- and if no instances are created,
            % no proxy will ever be added to the dependency set.
            if isPrincipal(service) && ~isProxy(service) && ...
                    ~isStaticMethod(service)
                return;
            end
            
            % Check if a file isExpected after isPrincipal so that
            % principals don't show up in the expected file list.
            if isExpected(obj, service.WhichResult) && ...
                 ~isAllowed(obj, 'COMPLETION', service.WhichResult)
                return;
            end

            % Retrieve the proxy symbol for the service. The client
            % already exists in the graph.
            %
            % Proxies protect the graph from having too many redundant
            % edges. 
            service = proxy(service);

            % Last chance check for exclusion and requirement
            if ~isExcluded(obj, service.WhichResult) && ...
               (~isExpected(obj, service.WhichResult) || ...
                 isAllowed(obj, 'COMPLETION', service.WhichResult))

                tgt.symbol = service;

                % G934738: if the dependent file is a P-file, add it
                % to the completion but don't add it to the ScanList
                if strcmp(service.Ext,'.p')
                    tmpPSym = CopyMatlabSymbol(service);
                    tmpPtgt.symbol = tmpPSym;
                    if ~obj.isInDependencyGraph(tmpPSym)
                        target = findOrCreateVertex(obj, tmpPtgt, true);
                        addEdge(obj.DependencyGraph, source, target);
                        matlab.depfun.internal.cacheEdge(source, ...
                                                         target, true);
                    else
                        target = findOrCreateVertex(obj, tmpPtgt, false);
                        if ~matlab.depfun.internal.cacheEdge(source, ...
                                                             target, false)
                            addEdge(obj.DependencyGraph, source, target);
                            matlab.depfun.internal.cacheEdge(source, ...
                                                             target, true);
                        end
                    end

                    % add the correspondent MATLAB file to the completion
                    % and ScanList.
                    findCorrespondentMCode(service,'.m');
                end
                
                % Only enqueue services that we haven't analyzed already
                % G1235327
                % The existence of a node in the graph used to be necessary and
                % sufficient to say the file represented by the node has
                % been analyzed. However, this is no longer sufficient,
                % because analyzed class methods can be represented by the
                % same proxy node in the graph, and the proxy itself may
                % have not been analyzed.
                enqueueService = ~isKey(obj.isAnalyzed, service.WhichResult) ...
                                 && (obj.CompletionLevel > 0);

                % G886754: if the dependent file is a MEX-file, also add its
                % MATLAB file to the completion but don't add it to the ScanList
                DoesShadowedMFileExist = false;
                if strcmp(service.Ext(2:end), mexext) || ...
                        (obj.isWin32 && strcmp(service.Ext, '.dll'))
                    Mfile = strrep(service.WhichResult, service.Ext, '.m');
                    if matlab.depfun.internal.cacheExist(Mfile,'file')
                        tmpMSym = CopyMatlabSymbol(service);
                        tmpMSym.WhichResult = Mfile;
                        tmpMSym.Ext = '.m';

                        tmpMtgt.symbol = tmpMSym;
                        DoesShadowedMFileExist = true;
                    end
                end

                % Must analyze the class schema file of UDD classes 
                % (that's how we find their parent classes).
                if service.Type == MatlabType.UDDClass
                    clsSchema = getUDDClassSchema(service.WhichResult);
                    if ~isempty(clsSchema)
                        obj.ScanList.enqueue(MatlabSymbol(...
                              MatlabSymbol.basename(clsSchema), ...
                              MatlabType.UDDMethod, clsSchema));
                    end  
                end
                
                % If the service is a UDD package function or a UDD class, look 
                % for a package schema file. The service depends on the package 
                % schema file if there is one. Recursively record this dependency.
                if (service.Type == MatlabType.UDDPackageFunction && ...
                    strcmp(service.Symbol,'schema') == false) || ...
                        service.Type == MatlabType.UDDClass

                    % The format of the WhichResult differs, so we must use
                    % different methods (these techniques don't rise to the
                    % level of "algorithm") to find the class directory; also,
                    % we can't rely on the class being registered yet.
                    clsDir = MatlabSymbol.classDir(service.Symbol);
                    if isempty(clsDir)
                        clsDir = service.WhichResult;
                    end
                    if service.Type == MatlabType.UDDPackageFunction
                        pkgSchema = getUDDPackageFunctionSchema(clsDir);
                    else
                        pkgSchema = getUDDPackageSchema(clsDir);
                    end
                    % If we found one, remember it. If the service is a p-file,
                    % copy it before recording a dependency on it, since 
                    % findCorrespondentMcode will morph it into an MATLAB file --
                    % and since MatlabSymbols are handle objects, we'll end up
                    % with two files of the same name at different vertices in
                    % the graph. And that's a fatal error.
                    if ~isempty(pkgSchema)
                        pkgSchemaClient = service;
                        if strcmp(service.Ext, '.p')
                            pkgSchemaClient = CopyMatlabSymbol(service);
                        end
                        cellfun( ...
                            @(ps)recordDependency(obj, pkgSchemaClient, ...
                            MatlabSymbol(MatlabSymbol.basename(ps), ...
                            MatlabType.UDDPackageFunction, ps)), ...
                            pkgSchema, 'UniformOutput', false);
                    end
                end

                if ~obj.isInDependencyGraph(service)
                    target = findOrCreateVertex(obj, tgt, true);
                    addEdge(obj.DependencyGraph, source, target);
                    matlab.depfun.internal.cacheEdge(source, target, true);

                    % Remember any platform dependencies created by
                    % this file.
                    recordPlatform(obj, service);

                    % Return array of newly added symbols
                    symList = [ symList service ];
                    
                    % G886754: if the dependent file is an MEX-file, also add its
                    % MATLAB file to the completion but don't add them to the
                    % ScanList
                    if DoesShadowedMFileExist
                        target = findOrCreateVertex(obj, tmpMtgt, true);
                        addEdge(obj.DependencyGraph, source, target);
                        matlab.depfun.internal.cacheEdge(source, target, true);
                    end
                else
                    target = findOrCreateVertex(obj, tgt, false);
                    if ~matlab.depfun.internal.cacheEdge(source, target, false)
                        addEdge(obj.DependencyGraph, source, target);
                        matlab.depfun.internal.cacheEdge(source, target, true);
                    end

                    if DoesShadowedMFileExist
                        target = findOrCreateVertex(obj, tmpMtgt, false);
                        if ~matlab.depfun.internal.cacheEdge(source, target, false)
                            addEdge(obj.DependencyGraph, source, target);
                            matlab.depfun.internal.cacheEdge(source, target, true);
                        end
                    end
                end

                % If the dependency is permitted, and we're computing
                % a full completion, add the required file to the
                % list of files that require further analysis. Also
                % enqueue any principals that service may represent.
                if enqueueService
                    if isClass(service)
                        addClassToScanList(obj, service);
                    else
                        if ~obj.useDB ...
                               || ~isempty(obj.PickOutUserFiles(service.WhichResult,true))
                           obj.ScanList.enqueue(service);
                        end
                    end
                end
            end
        end
        
        function recordComponentDependency(obj, client, serviceList)
        % This function records the client's component dependencies.
        % serviceList is a struct that consists of two fields, 'builtin'
        % and 'file', which are cell arrays storing built-in and non-built-in 
        % symbols used by the client, respectively. 
            
            compList = cell(1,0);
            if ~isempty(serviceList.builtin)
                keep = isKey(obj.builtinSymbolToComponent, serviceList.builtin);
                if any(keep)
                    component = values(obj.builtinSymbolToComponent, ...
                                       serviceList.builtin(keep));
                    compList = union(compList, component);
                end
            end
            
            if ~isempty(serviceList.file)
                remove = obj.isExcluded(serviceList.file);
                fileList = serviceList.file(~remove);
                
% This section uses the Component-MATLAB Module data. Due to several
% component boundary violations in the current code base, this section is
% disabled for 16a.
%                 if ~isempty(fileList)                    
%                     matlabModule = filename2path(fileList);
% 
%                     keep = isKey(obj.matlabModuleToComponent, matlabModule);
%                     if any(keep)
%                         component = values(obj.matlabModuleToComponent, ...
%                                            matlabModule(keep));
%                         compList = union(compList, component);
%                     end
%                 end

                % This section uses the Component-Source data as a compensation
                % for the component boundary violations for 16a.
                if ~isempty(fileList)
                    component = findComponentBasedOnScmData(obj, fileList);
                    if ~isempty(component)
                        compList = union(compList, component);
                    end
                end
            end
            
            if ~isempty(serviceList.component)
                compList = union(compList, serviceList.component);
            end
            
            % Remember what components are required for each file.
            if ~isempty(compList)
                obj.fileToComponents(client.WhichResult) = compList;
            end
        end
        
        function compList = findComponentBasedOnScmData(obj, files)
            import matlab.depfun.internal.requirementsConstants;
            
            compList = cell(1,0);
            
            keep = strncmpi(files, requirementsConstants.MatlabRoot, ...
                            length(requirementsConstants.MatlabRoot));
            items = files(keep);
            % Remove matlab root
            len = length(requirementsConstants.MatlabRoot)+2;
            items = cellfun(@(p)p(len:end), items, 'UniformOutput', false);
            
            while ~isempty(items) && ~all(cellfun('isempty', items))
                found = isKey(obj.sourceToComponent, items);
                if any(found)
                    component = values(obj.sourceToComponent, ...
                                       items(found));
                    compList = union(compList, component);
                end
                items = items(~found);
                % Trim off the last part. FILEPARTS is expensive.
                items = cellfun(@(p)fileparts(p), items, ...
                                'UniformOutput', false);
                items = unique(items,'stable');
            end
        end

        function [resolved, unresolved] = resolveUnknownType(obj, unknownType)
        % resolveUnknownType Add Extrinsic symbol to root set if file exists
            import matlab.depfun.internal.MatlabSymbol;
            import matlab.depfun.internal.MatlabType;
            import matlab.depfun.internal.cacheWhich;
            import matlab.depfun.internal.cacheExist;
            
            unresolved = {};
            resolved = {};
            for u = 1:numel(unknownType)
                % Full path to file, or file on the MATLAB path. (Check
                % here for MATLAB file types too, in case they were missed
                % by earlier classifications.)
                if ~isempty(unknownType{u})
                    e = cacheExist(unknownType{u}, 'file');
                    if e == 2 || e == 3 || e == 4 || e == 6
                        [~,name,~]=fileparts(unknownType{u});
                        % Do we have a full path, or do we need to look for 
                        % the file with WHICH?
                        if isfullpath(unknownType{u})
                            pth = unknownType{u};
                        else
                            pth = cacheWhich(unknownType{u});
                        end
                        % Three-argument MatlabSymbol: specify name, type and
                        % full path.                    
                        uSym = MatlabSymbol(name, MatlabType.Extrinsic, pth);
                        resolved = [ resolved, uSym ];
                    else
                        unresolved = [ unresolved, unknownType(u) ];
                    end
                end
            end
        end
        
        function [symbols, undeterminedType] = resolveRootSet(obj, nameList)
        % resolveRootSet Create symbols from the files in the input list.
        % Defer to the expertise of the Inspectors to determine the actual
        % symbol type. Some input names may be unclassifiable; return a 
        % list of these names without prejudice.
            import matlab.depfun.internal.MatlabInspector;
            import matlab.depfun.internal.MatlabSymbol;
            import matlab.depfun.internal.cacheWhich;
            import matlab.depfun.internal.cacheExist;
            
            % retrieve dependencies for MATLAB files directly from
            % existing database
            if obj.useDB
                userFiles = PickOutUserFiles(obj, nameList);
                nameList = userFiles;               
            end
            
            undeterminedType = {};
            symbols = [];
            
            % For every input name
            for k = 1:numel(nameList)
                % Get the next name on the list.
                name = nameList{k};

                % If the name is a directory, recursively add all the files
                % -- but don't process expected or excluded directories.
                % Make sure that filesep is always /, because that's what
                % the expected and excluded patterns use.
                maybeDir = strrep(fullpath(name,pwd),'\','/');
                if exist(maybeDir,'dir') == 7
                    if ~isExpected(obj, maybeDir) && ...
                        ~isExcluded(obj, maybeDir)
                        aDir=maybeDir;

                        contents = dir(aDir);
                        % Remove '.' and '..'. Use a while loop on the theory
                        % that it will be faster on average than find followed
                        % by indexed delete -- the entries we wish to discard
                        % will almost always be the the first two in the
                        % structure.
                        n = 1; len = numel(contents);
                        chopped = 0;
                        while n <= len && chopped < 2
                            if strcmp(contents(n).name,'..') || ...
                               strcmp(contents(n).name, '.')
                                contents(n) = [];
                                len = len - 1;
                                chopped = chopped + 1;
                                continue; % Don't increment N after deletion.
                            end
                            n = n + 1;
                        end
                        % Make a list of full paths to the files in the 
                        % subdirectory.
                        dirFiles = cellfun(@(f)fullfile(aDir,f), ...
                                  {contents.name}, 'UniformOutput', false);
                        % Recursively resolve the files in the subdirectory.
                        [s uT] = resolveRootSet(obj, dirFiles);
                        symbols = [symbols s];
                        undeterminedType = [undeterminedType uT];
                    else
                        s = matlab.depfun.internal.MatlabSymbol('', ...
                            matlab.depfun.internal.MatlabType.Ignorable,...
                            maybeDir);
                        symbols = [ symbols s ]; %#ok
                    end
                    
                    % GOTO the next entry 
                    continue;
                end
                
                % Look for an inspector for the name's file type.
                [~,~,ext] = fileparts(name);

                % Try to find an inspector that knows about name's type of 
                % file.
                if ~isempty(ext) && isKey(obj.Inspectors, ext)
                    % If the file has an extension, look for an
                    % inspector specialized for that file type. 
                    inspector = obj.Inspectors(ext);
                else
                    % No matching inspector -- let MATLAB have the last
                    % crack at the name. Note that MatlabInspector will
                    % attempt to identify names with no extension.
                    inspector = obj.Inspectors('.m');
                end

                [newSymbol, unknownType] = ...
                        determineType(inspector, name);
                % Add the non-excluded resolved symbols to the
                % root set.
                symbols = [ symbols newSymbol ];
                    
                % Add the unknownType symbols to the
                % undeterminedType list
                undeterminedType = { undeterminedType{:} unknownType };
            end
        end

       % Excluded: The file should never be part of the completion.
       %
       % Expected: The file forms part of the target environment, and
       %   generally should not be part of the completion. This is both an
       %   optimization (ship fewer files) and an enforcement of business
       %   rules -- our license specifies that expected files should not be
       %   transferred from one machine to another.
       % 
       % Allowed: If the file would be removed from the completion because it
       %   is expected, allow it to be present. A file that is both excluded
       %   and allowed is excluded.

        function allowed = isAllowed(obj, fileSet, file)
        % isAllowed Is the file allowed to be part of the given file set?
            allowed = false;
            if ~isempty(obj.Schema)
                allowed = isAllowed(obj.Schema, fileSet, obj.Target, file);
            end
        end

        function [expeto, why] = isExpected(obj, files)
        % isExpected Is the file part of the target's expected feature set?
            if ischar(files)
                files = {files};
            end
            
            [expeto, why] = matlab.depfun.internal.cacheIsExpected(...
                                            obj.Schema, obj.Target, files);
            
            idx = find(expeto);
            for i = idx
                recordExpected(obj, files{i}, why(i));
            end
        end

        function [verboten, why] = isExcluded(obj, files)
        % isExcluded Determine if the Schema excludes a given file
        % Optionally record exclusions.
            if ischar(files)
                files = {files};
            end
            
            [verboten, why] = matlab.depfun.internal.cacheIsExcluded( ...
                obj.Schema, obj.Target, files, obj.useExclusionListFromDB);
            
            idx = find(verboten);
            for i = idx
                recordExclusion(obj, files{i}, why(i));
            end
        end

        function findDependentFiles(obj)
        % findDependentFiles Determine the files required by the root set.
        % findDependentFiles computes the completion of the root set. This
        % is the driver function that orchestrates the entire process.
        % 
        % 1. Get a file from the list of files to analyze.
        % 2. Examine the file to discover the symbols it uses
        % 3. Determine which of those symbols correspond to functions
        %    or methods.
        % 4. Filter the resulting dependencies against the exclusion list
        %    in the schema.
        % 5. Record the surviving dependencies in the call tree graph.
        % 6. Add the corresponding files to the list of files to analyze.
        % 7. Check the Schema to for dependencies mandated by the newly
        %    discovered files, methods or classes. Add them to the graph and
        %    file list, as appropriate.
        % 8. If there are files left in the list, go back to step 1.
        %
        % The accuracy of steps 2 and 3 is both the most difficult and 
        % most important part of the computation. Statically determining the
        % fully-qualified symbol names in a dynamically dispatched language
        % is a difficult problem, especially in the absense of runtime type
        % data. 
        
            

            % Implements the steps of the driver process
            while ~isempty(obj.ScanList)
                % Get the next file to analyze
                symbol = obj.ScanList.dequeue;
                fileName = symbol.WhichResult;
                
                % Don't analyze a same file
                if isKey(obj.isAnalyzed,fileName)
                    continue; 
                end

                % Don't do any work if the file should be excluded
                if isExcluded(obj, fileName), continue; end

                % Stop processing if the file is part of the required
                % target environment, but remember that we need it.
                if isExpected(obj, fileName) && ...
                  ~isAllowed(obj, 'COMPLETION', fileName), continue; end
                
                % Code inspectors examine a file to determine what symbols
                % it uses. Look up a code inspector for this file, based
                % on file extension.
                % Note, we cannot use proxySym's Ext because the Ext of 
                % a built-in class constructor is empty.
                ext = symbol.Ext;
                                
                % If there's no Inspector for this extension, add the 
                % file to the graph as an unconnected vertex. This creates
                % a weakly justified dependency (we know we depend on 
                % this file, but we don't know why).
                %
                % Empty extensions fall into this category too, until
                % it becomes necessary to be more sophisticated. (Note that
                % empty filenames have empty extensions, so symbols with
                % no associated file become weakly justified dependencies
                % as well.)                
                if ~isKey(obj.Inspectors, ext) || symbol.Type == ...
                                matlab.depfun.internal.MatlabType.Extrinsic
                    dep.symbol = symbol;
                    findOrCreateVertex(obj, dep, true);
                    recordPlatform(obj, symbol);
                    
                    if strcmp(ext(2:end), mexext) || (obj.isWin32 && strcmp(ext, '.dll'))
                        Mfile = strrep(symbol.WhichResult,ext,'.m');                        
                        if matlab.depfun.internal.cacheExist(Mfile,'file')
                            tmpSym = CopyMatlabSymbol(symbol);
                            tmpSym.WhichResult = Mfile;
                            tmpSym.Ext = '.m';
                            
                            tmp.symbol = tmpSym;
                            findOrCreateVertex(obj, tmp, true);
                        end
                    end
                    
                    continue;
                end
                
                % for libMATLAB dependency analysis, we want the exception to be handled
                % here and save the problematic file into problematicFiles so that the program
                % can continue  
                % for all other analysis, we want the program to stop on any error condition

                if obj.isLibMATLABDeps  
                    try
                        % If symbol doesn't have a proxy, it is its own proxy.
                        proxySym = proxy(symbol);
                    catch ME
                        obj.problematicFiles(symbol.WhichResult) = ME.message();
                    end
                else
                    % If symbol doesn't have a proxy, it is its own proxy.
                    proxySym = proxy(symbol);
                end
                
                
                if isClass(symbol)
                    recordClassDependency(obj,symbol,symbol);
                else
                    src.symbol = proxySym;    
                    findOrCreateVertex(obj, src, true);
                    % Remember any platform dependencies created by
                    % this file.
                    recordPlatform(obj, symbol); 
                end
                
                % Fetch the appropriate code Inspector
                inspector = obj.Inspectors(ext);
                
                % Analyze the symbols used by the file. The inspector may
                % call back to recordDependency and recordClassDependency,
                % so it is likely that our internal data will change as a 
                % result of this call.
                %
                % for libMATLAB dependency analysis, we want the exception to be handled
                % here and save the problematic file into problematicFiles so that the program
                % can continue  
                % for all other analysis, we want the program to stop on any error condition

                if obj.isLibMATLABDeps  
                    try
                        analyzeSymbol(inspector, symbol);
                    catch ME
                        obj.problematicFiles(symbol.WhichResult) = ME.message();
                    end
                else
                    analyzeSymbol(inspector, symbol);
                end

                % record files that have been analyzed
                obj.isAnalyzed(fileName) = 1;

                % Add any toolbox-specific includes to the dependency graph.
                % Make sure to pass the full path, or the machinery to identify
                % the owning toolbox may fail.
                reqList = statutoryIncludes(obj.Schema, obj.Target, fileName);
                % TODO: For performance, lookup symbol's VertexID here, and
                % use it in addEdge below.
                for k=1:length(reqList)
                    if strcmp(reqList{k}.language, 'data')
                        type = matlab.depfun.internal.MatlabType.Ignorable;
                    else
                        type = matlab.depfun.internal.MatlabType.Function;
                    end
                    reqSymbol = ...
                        matlab.depfun.internal.MatlabSymbol.makeFileSymbol(...
                            reqList{k}.path, type);
                    addEdge(obj.DependencyGraph, proxySym, reqSymbol);
                end
            end   
        end
        
        function fileSet = applySetRules(obj, fileSet, setName)
        % Apply the rules for a named set to the contents of the set.
            [addedFiles, keep, rMap] = ruleActions(obj, setName, fileSet);
            fileSet = fileSet(keep);
            fileSet = [fileSet addedFiles];
            [exc, exp] = notShipping(obj, fileSet, setName);
            gone = exc | exp;
            fileSet = fileSet(~gone);
        end
        
        function traceList = filterTraceList(obj, traceList, ruleSetName)
            fileSet = {traceList.path};
            [~, keep] = ruleActions(obj, ruleSetName, fileSet);
            traceList = traceList(keep);
            fileSet = {traceList.path};
            [exc, exp] = notShipping(obj, fileSet, ruleSetName);
            gone = exc | exp;
            traceList = traceList(~gone);
        end
        
        function [addedFiles, rmFilter, rMap] = ruleActions(obj, fileSet, files)
            % Apply the rule sets to determine if they add or remove any
            % additional files.
            [modifiedList, rMap] = ...
                applySetRules(obj.Schema, obj.Target, fileSet, ...
                                       files);
            % Don't add duplicate files to the list. Filter out (from the
            % list of added files) any files we already have in the list 
            % of input files.
            addedFiles = setdiff(modifiedList, files, 'legacy');
            
            % Should any files be removed from the list of files? Make a
            % logical index to actually remove them.
            [~,rmIdx] = setdiff(files, modifiedList, 'legacy');
            rmFilter = true(1,numel(files));
            rmFilter(rmIdx) = false;
        end
        
        function [excluded, expected] = notShipping(obj, files, setName)
        % notShipping Compute logical index of excluded and expected files.
            fcount = numel(files);
            expected = false(1,fcount);
            excluded = false(1,fcount);
            for k=1:numel(files)
                f = files{k};
                excluded(k) = isExcluded(obj, f);
                expected(k) = isExpected(obj, f) && ...
                             ~isAllowed(obj, setName, f);
            end
        end
        
        function rootSymbols = initializeRootSet(obj, files)
        % initializeRootSet Process the files that will form the roots of
        % the dependency forest (there may be multiple roots if there is 
        % more than one entry point).
        %
        % Called by the constructor and no other function. Factored out
        % to reduce code complexity (the constructor may be called with
        % no files.)
        
            % Must create Inspector map before processing arguments, because
            % function classification uses Inspectors.
            [rootSymbols, unknownType] = resolveRootSet(obj, files);
            
            % Add the discoverable (apparently real) files of unclaimed
            % type (those for which there are no inspectors) to the root
            % set.
            [resolved, unresolved] = resolveUnknownType(obj, unknownType);
            rootSymbols = [rootSymbols resolved];
            
            % It's an error if there's nothing in the root set. That means
            % we couldn't locate any of the input files.
            if isempty(rootSymbols)
                if obj.useDB
                    return;
                else
                    % input may be more than one empty folders
                    if ischar(files)
                        tmpStr = files;
                    else
                        tmpStr = sprintf('%s, ', files{:});
                        tmpStr = tmpStr(1:end-2);
                    end
                    error(message('MATLAB:depfun:req:NameIsAnEmptyDirectory', tmpStr));
                end
            end
            
            % Some symbol may have multiple WhichResult's. In other words, a
            % cell in the cell array 'files' may be also a cell array. 
            % This causes problem in the following steps. Thus, we need 
            % to reformat the cell array 'files' to make sure each cell 
            % only contain one string.   
            org_num_rootSymbols = numel(rootSymbols);
            actual_num_rootSymbols = 0;
            for i = 1:org_num_rootSymbols
                if iscell(rootSymbols(i).WhichResult)
                    actual_num_rootSymbols = actual_num_rootSymbols + length(rootSymbols(i).WhichResult);
                else
                    actual_num_rootSymbols = actual_num_rootSymbols + 1;
                end
            end
            
            if actual_num_rootSymbols ~= org_num_rootSymbols
                tmp_list = [];
                for i = 1:org_num_rootSymbols
                    if ~iscell(rootSymbols(i).WhichResult)
                        tmp_list = [tmp_list rootSymbols(i)];
                    else
                        SymbolList = makeSymbolList(rootSymbols(i));
                        for j = 1:length(SymbolList)     
                            tmp_list = [tmp_list SymbolList(j)];
                        end
                    end
                end
                rootSymbols = tmp_list;  
            end
            
            rootSymbols = unique(rootSymbols);
                        
            % Extrinsic symbols should be separated from rootSymbols.
            % They will be firstly added to the scanlist then be added to 
            % dependency graph later without analysis.
            % For performance we will not add another rule in the rdl file.
            extrinsic = [rootSymbols.Type] == ...
                            matlab.depfun.internal.MatlabType.Extrinsic;
            extrinsicSymbols = rootSymbols(extrinsic);
            rootSymbols = rootSymbols(~extrinsic);
            for k=1:numel(extrinsicSymbols)                
                obj.ScanList.enqueue(extrinsicSymbols(k));
            end
            
            [addedFiles, ruleFilter, notes] = ...
                ruleActions(obj, 'ROOTSET', {rootSymbols.WhichResult});
            
            % Filter out the files removed by the rules. ruleFilter is a
            % logical index (a mask). FALSE means remove the file at that
            % position.
            removed = rootSymbols(~ruleFilter);
            rootSymbols = rootSymbols(ruleFilter);
            
            % The rules may have shifted some files from the ROOTSET into
            % the COMPLETION. Add those files to the scan list. Note:
            % symbols for these moved files are already on the removed
            % list.
            if isKey(notes, 'COMPLETION') && ~isempty(notes('COMPLETION'))
                % Get the list of files moved to the COMPLETION
                movedFiles = notes('COMPLETION');
                % Prepare a logical index to extract the moved files from
                % the removed files list.
                movedIdx = zeros(size(removed));
                % For efficiency, create the cell array of removed files
                % outside the loop.
                removedFiles = { removed.WhichResult };
                % For each moved file, find the index of the corresponding
                % symbol in the removed list.
                for k=1:numel(movedFiles)
                    movedIdx = movedIdx | strcmp(movedFiles{k}, removedFiles);
                end
                % Extract the symbols for the moved files from the removed
                % file list.
                sym = removed(movedIdx);
                % The moved files weren't really removed, so we don't want
                % to record them on the exclusion list. So, take the
                % moved files off the removed files list. (Moved / removed,
                % the terminology is a bit confusing, for which I
                % apologize.)
                removed = removed(~movedIdx);
                % Filter the moved files against the exclusion and expected
                % lists, just in case some of the moved files actually need
                % to be excluded.
                [exc, exp] = notShipping(obj, {sym.WhichResult}, 'COMPLETION');
                % Put the moved (yet excluded) files back on the removed
                % list.
                removed = [removed sym(exc)];
                % Take the moved, yet excluded or expected files off of the
                % moved files list. Remember the expected files.
                expected = sym(exp);
                sym = sym(~(exc | exp));
                
                % Add the expected files to the list of expected files.
                for k=1:numel(expected)
                    file = expected(k).WhichResult;
                    recordExpected(obj, file, notes(file));
                end
                
                % Finally, place the brave survivors on the ScanList,
                % whence they will eventually enter the COMPLETION.
                for k=1:numel(sym)
                    % enqueue the original symbol
                    obj.ScanList.enqueue(sym(k));
                    
                    % (1) If the file is p-code, link it to 
                    %     its correspondent m-code. If the corresponding 
                    %     m-code doesn't exist or is empty/nothing but
                    %     comments, throw a warning.
                    % (2) If the file is m-code, then do nothing.
                    if strcmp(sym(k).Ext,'.p')
                        % Since MatlabSymbol is a handle object, we have to
                        % create a new object to contain new information.
                        pSym = CopyMatlabSymbol(sym(k));
                        if findCorrespondentMCode(pSym,'.m')
                            addedFiles = [addedFiles pSym.WhichResult]; %#ok
                        end
                    end
                    
                    % (1) If the file is fig-file, link it to its 
                    %     correspondent .m and .mlx file. If the  
                    %     m-code doesn't exist or is empty/nothing but
                    %     comments, throw a warning.
                    % (2) If the file is m-code, then do nothing.
                    if strcmpi(sym(k).Ext,'.fig')
                        figSym1 = CopyMatlabSymbol(sym(k));
                        if findCorrespondentMCode(figSym1,'.mlx')
                            addedFiles = [addedFiles figSym1.WhichResult]; %#ok
                        end
                        
                        figSym2 = CopyMatlabSymbol(sym(k));
                        if findCorrespondentMCode(figSym2,'.m')
                            addedFiles = [addedFiles figSym2.WhichResult]; %#ok
                        end
                    end
                end
            end
            
            % Add the files that were truly removed (not those that just
            % got moved to the COMPLETION) to the exclusion list.
            for k=1:numel(removed)
                file = removed(k).WhichResult;
                recordExclusion(obj, file, notes(file));
            end       
            
            % Resolve the new files into symbols (and add them to the root
            % set); a Completion is a handle object, so methods can have
            % side-effects.
            rootSymbols = [ rootSymbols resolveRootSet(obj, addedFiles) ];
            
            % Test root set files for exclusion.
            [exc, exp] = notShipping(obj, {rootSymbols.WhichResult}, 'ROOTSET');
            gone = exc | exp;
          
            % Remove excluded files from the root set. (Or, more precisely,
            % retain all non-excluded files in the root set.)
            rootSymbols = rootSymbols(~gone);
            
            % If there are no symbols in the root set, warn the user that
            % the Completion contains no entry points.
            %             if isempty(rootSymbols)
            %                 warning(message('MATLAB:depfun:req:NoEntryPoints', ...
            %                                  char(obj.Target)));
            %             end

        end   
        
        function buildInspector(obj)
            % Create functions that allow inspectors to add dependencies
            % and exclusions to the completion.            
            fcnHandles.addDep = @(client, symbol)recordDependency(obj, client, symbol);
            fcnHandles.addClassDep = @(client, symbol)recordClassDependency(obj, client, symbol);
            fcnHandles.addComponentDep = @(client, service)recordComponentDependency(obj, client, service);
            fcnHandles.addExclusion = @(file, why)recordExclusion(obj, file, why);
            fcnHandles.addExpected =  @(file, why)recordExpected(obj, file, why);
            fcnHandles.pickUserFiles = @(files)PickOutUserFiles(obj, files);            
        
            m = matlab.depfun.internal.MatlabInspector(obj.Schema, ...
                               obj.Target, obj.FsCache, obj.useDB, ...
                               fcnHandles);
                           
            % MTREE-friendly files (.m, .mlx, and .mlapp) share the same inspector.
            % .p files are not analyzed.
            import matlab.depfun.internal.requirementsConstants;
            for k = 1:requirementsConstants.analyzableMatlabFileExtSize
                obj.Inspectors(requirementsConstants.analyzableMatlabFileExt{k}) = m;
            end
            
            mat = matlab.depfun.internal.MatFileInspector(obj.Schema, ...
                               obj.Target, obj.FsCache, obj.useDB, ...
                               fcnHandles);
            obj.Inspectors('.mat') = mat;
        end
        
        function userFiles = PickOutUserFiles(obj, inputs, varargin)
        % Differentiate MATLAB files and user files. Note that inputs may
        % be symbols as well -- all inputs are passed to WHICH. If WHICH
        % finds a file, this function copies that file -- name unchanged,
        % even if the name was partial or relative -- to the output
        % userFiles. The test for case-sensitive function name matching
        % relies on this behavior (that the names are unchanged).
            import matlab.depfun.internal.cacheWhich;
            import matlab.depfun.internal.cacheExist;
            import matlab.depfun.internal.requirementsConstants;
            
            if ischar(inputs)
                inputs = { inputs };
            end
            
            if numel(varargin) == 0
                isWhichResult = false;
            else
                isWhichResult = varargin{1};
            end

            fs = filesep;
            MatlabFiles = {};
            userFiles = {};
            for i = 1:numel(inputs)
                % If the input is already a result returned by WHICH, don't
                % call WHICH again.
                if isWhichResult
                    w = inputs{i};
                else
                    w = cacheWhich(inputs{i});
                end

                % 16b work-around for g1329309
                % Ignore files from uncompilable toolboxes.
                % Files under $(MATLABROOT)/toolbox but not on the
                % MATLAB search path.
                % No exclude reason is needed because they are not supposed
                % to be found at all.
                fpath = '';
                if ~isempty(w)
                    fpath = w;
                elseif cacheExist(inputs{i},'file')
                    fpath = inputs{i};
                end

                if obj.PathUtility.isFromUncompilableToolbox(string(fpath),obj.uncompilabeTbx)
                    continue;
                end

                % Ignore class methods except static methods,
                % because which('symbol') is an inappropriate question
                % for class methods.
                if isWhichResult || (~isWhichResult && isempty(strfind(inputs{i},'.')))
                    if obj.DepDepot.isPrincipal(w)
                        continue;
                    end
                end
                    
                % G954614: Put built-in's in userFiles so that they can be 
                % removed with an explicit reason in a later step 
                % in initializeRootSet().
                if ~isempty(w) && ~strncmp(w, ...
                     requirementsConstants.BuiltInStrAndATrailingSpace,...
                     requirementsConstants.lBuiltInStrAndATrailingSpace)
                    if (~isExpected(obj, w) || isAllowed(obj, 'COMPLETION', w)) && ~isExcluded(obj, w)
                        w = regexprep(w,'[\/\\]',fs);
                        if obj.PathUtility.isaMathWorksFile({w})
                            MatlabFiles{end+1} = w;
                            % look up corresponding m-code for p-code
                            if hasext(w,'.p')
                                MatlabFiles{end+1} = regexprep(w,'\.p$','.m');
                            end                            
                        else
                            userFiles{end+1} = inputs{i};
                        end
                    end
                else
                    userFiles{end+1} = inputs{i};
                end
            end
            
            obj.matlabFiles = [obj.matlabFiles MatlabFiles];
        end
        
        function builtinList = retrieveBuiltinList(obj) 
        % retrieve used built-ins from inspectors
            builtinList = cell(1,0);
            inspectorName = keys(obj.Inspectors);
            for i = 1:numel(inspectorName)
                % tmpLis is a cell array of MatlabSymbol
                tmpList = matlab.depfun.internal.flatten(values(obj.Inspectors(inspectorName{i}).BuiltinListMap));
                
                builtinSymbol = cell(1, numel(tmpList));
                for j = 1:numel(tmpList)
                    builtinSymbol{j} = tmpList{j}.Symbol;                
                end
                builtinList = union(builtinList, builtinSymbol);
                
            end
        end
        
        function componentID = checkBuiltinComponentMembership(obj, bltins)
        % Find the owning components and modules for given built-in symbols
        
            if ischar(bltins)
                bltins = {bltins};
            end
            num_bltins = numel(bltins);
            
            componentID = cell(num_bltins, 1);
            for k = 1:num_bltins
                mname = obj.pcm_navigator.moduleOwningBuiltin(bltins{k});
                componentID{k} = obj.DepDepot.componentOwningModule(mname);
            end
        end
        
        function fileList = retrieveDependencyFromDatabase(obj)
            fileList = {};
            
            % retrieve the list of used built-ins
            bltinList = obj.retrieveBuiltinList();
            
            % A helper function
            function files = queryMcodeForPcode(files)
                % G971667: Dependencies of p-code are recorded under the
                % corresponding m-code. Files listed in the INCLUDE section in
                % mcc.ixf don't go through PickOutUserFiles().
                pFileIdx = ~cellfun('isempty', regexp(files, '.+\.p$'));
                mFile = regexprep(files(pFileIdx), '\.p$', '.m');
                files = [files; mFile];
            end
            
            % Initialize the recentFoundFiles in the beginning.
            recentFoundFiles = obj.matlabFiles;
            
            % Find the owning components for used built-ins, and retrieve
            % INCLUDE lists of those components
            if ~isempty(bltinList)
                componentID = obj.checkBuiltinComponentMembership(bltinList);                
                componentID = unique(cell2mat(componentID));
                knownComponentIDs = componentID;
                
                for k = 1:length(componentID)
                    inclusionFiles = obj.DepDepot.getInclusion(obj.Target, componentID(k));
                    inclusionFiles = fullfile(matlabroot,inclusionFiles);
                    inclusionFiles = queryMcodeForPcode(inclusionFiles);
                    recentFoundFiles = [recentFoundFiles inclusionFiles'];
                end
            end
            
            % If any built-ins are proxies, retrieve their principals.
            builtinP = obj.builtinPrincipals();
            
            % Apply the set rules to the built-ins before adding them to
            % the list of MATLAB files.
            builtinP = obj.applySetRules(builtinP, 'COMPLETION');

            recentFoundFiles = unique([recentFoundFiles builtinP]);

            if ~isempty(recentFoundFiles)
                % recursively retrieve the inclusion list from the database
                % Don't ship any unlicensed files.
                keep = licensed(recentFoundFiles, obj.Schema);
                recentFoundFiles = recentFoundFiles(keep);
                knownComponentIDs = [];             
                knownComponentNames = {};

                % g1207598 ssegench
                % Need to keep track of which time through the loop this is
                %  on the first time through the loop dependencies need to be retrieved 
                %  for all recentFoundFiles. This list will be the files initially passed
                %  into retrieveDependencyFromDatabase as well as any statuatory includes 
                %  for the components those file belong to.
                % At the end of the first loop recentFoundFiles is the list of dependencies that
                %  that were returned from the database. There is no need to try to retrieve 
                %  those files dependencies from the database since it will not (it better not) 
                %  provide any additional file. We do however need to check the components of 
                %  these files to see if there are any new components and therefore 
                %  new statuatory includes. If there are, retrieve the dependencies for only 
                %  the new statutory includes. Repeat this loop until there are no new files found.
                isFirstRun  = true;
                while ~isempty(recentFoundFiles)

                    % Determine the components that own the MATLAB files.
                    [componentID, NotFoundList] = ...
                         obj.DepDepot.checkComponentMembership(recentFoundFiles);
                    componentID = unique(componentID);
                    % remove non-existent component 0
                    componentID(logical(~componentID)) = [];

                    % only interested in new findings
                    recentFoundComponentIDs = setdiff(componentID, ...
                        knownComponentIDs);

                    % Find the tokens in '<matlabroot>/toolbox/<tokens>/',
                    % regardless of which way the separators lean.
                    tok = {};
                    for k = 1:numel(NotFoundList)
                        tmp = obj.PathUtility.componentBaseDir(NotFoundList{k});
                        
                        if ~isempty(tmp)
                            tok = [tok; tmp{1}]; %#ok
                        end
                    end
                    tok = unique(tok);

                    % only interested in new findings
                    recentFoundComponentNames = ...
                        setdiff(tok, knownComponentNames);
                    
                    % exit this loop if there is no new finding
                    recentFoundComponents = ...
                        [num2cell(recentFoundComponentIDs); ...
                         recentFoundComponentNames];

                    if isempty(recentFoundComponents) && ~isempty(fileList)
                        break;
                    end
                    
                    statuatoryInclusionFiles = {};
                    % retrieve statutory inclusion files for each component
                    for k = 1:numel(recentFoundComponents)
                        inclusionFiles = obj.DepDepot.getInclusion(obj.Target, ...
                                                    recentFoundComponents{k});
                        inclusionFiles = fullfile(matlabroot,inclusionFiles);
                        
                        inclusionFiles = queryMcodeForPcode(inclusionFiles);

                        % append the inclusion list to the mandatory File List
                        statuatoryInclusionFiles = ...
                            [statuatoryInclusionFiles inclusionFiles']; %#ok
                    end

                    % there could be overlap in the inclusion lists for
                    % components. Make this unique
                    statuatoryInclusionFiles = unique(statuatoryInclusionFiles);
                    
                    % append the mandatory list to the recent files List
                    recentFoundFiles = ...
                            unique([recentFoundFiles statuatoryInclusionFiles]);
                    
                    % remember components that have been already found
                    % isempty check prevents [] warning when non-empty
                    % array dimensions don't match.
                    if ~isempty(recentFoundComponents)
                        knownComponentIDs = [knownComponentIDs; ...
                            recentFoundComponentIDs]; %#ok
                    end
                    if ~isempty(recentFoundComponentNames)
                        knownComponentNames = [knownComponentNames; ...
                            recentFoundComponentNames]; %#ok
                    end
                    
                    % Retrieve dependent files from the database.
                    % This retrieves principals as well.
                    % On the first pass through this loop do it for all files
                    if isFirstRun
                        tmpList = obj.DepDepot.requirements(recentFoundFiles);
                        isFirstRun = false;
                    else
                        % subsequent passes only look up the addition inclusion files
                        % plus recently found p-files if there are any.
                        
                        % G1225955: Another p-file related work-around
                        pfildIdx = ~cellfun('isempty',regexp(recentFoundFiles,'\.p$'));
                        if any(pfildIdx)
                            pfileList = recentFoundFiles(pfildIdx);
                            tmpList = obj.DepDepot.requirements([statuatoryInclusionFiles pfileList]);
                        else
                            tmpList = obj.DepDepot.requirements(statuatoryInclusionFiles);
                        end
                    end
                    
                    if ~isempty(tmpList)
                        keep = licensed({tmpList.path}, obj.Schema);
                        tmpList = tmpList(keep);

                        % remember files that have been already found
                        if isempty(fileList)
                            recentFoundFiles = {tmpList.path};
                            fileList = tmpList;
                        else
                            [recentFoundFiles, recentFoundFilesIdx] = ...
                                setdiff({tmpList.path}, {fileList.path});

                            fileList = [fileList ...
                                        tmpList(recentFoundFilesIdx)]; %#ok
                        end
                    else
                        recentFoundFiles = {};
                    end
                end % for loop

                % a fix for G920466
                % prioritize files that are currently on the path by putting
                % files that are not currently on the path to the end of the 
                % list.

                if ~isempty(fileList)
                    % store the current path in a cell array
                    crt_path = getCurrentPath();                    
                    % convert file names to path items
                    pth_items = filename2path({fileList.path});
                    
                    offPathIdx = ~cell2mat(cellfun(@(f)any(strcmp(crt_path, f)),pth_items,'UniformOutput',false));
                    offPathList = fileList(offPathIdx);
                    fileList(offPathIdx) = [];
                    
                    % fixedpoint/numerictype.m should shadow
                    % fixedpoint/+embedded/@fi/numerictype.m.
                    % To achieve this, put items that contain '@','+', or
                    % 'private' behind items that don't contain those patterns.
                    shadowed_fileList = {};
                    if ~isempty(fileList)
                        shadowedIdx = ~cellfun('isempty',regexp({fileList.path},'/([@+]|private/)','ONCE'));
                        shadowed_fileList = fileList(shadowedIdx);
                        fileList(shadowedIdx) = [];
                    end
                    
                    fileList = [fileList shadowed_fileList offPathList];                    
                end
            end
        end
        
        function list = computePartsList(obj, canonicalPath)
        % Do the work to determine the parts list -- compute and filter the
        % dependencies.
        %
        % This list may be empty if all the entry-point files in the
        % application are non-deployable. Use the ISDEPLOYABLE function to
        % determine if a file may be shipped to the target environment. 
            fs = filesep;
        
            % Don't canonicalize file paths by default.
            if nargin == 1
                canonicalPath = false;
            end
            
            computeDependencies(obj);
            list = buildTraceList(obj, canonicalPath);
            
            if obj.useDB
                fileList = retrieveDependencyFromDatabase(obj);
                % files retrieved from the database are canonical.
                if ~canonicalPath
                    for k=1:length(fileList)
                        fileList(k).path = strrep(fileList(k).path, '/', fs);
                    end
                end
                
                % g1717645 - work around until g1723012 is fixed
                if ~isempty(fileList)
                    filePath = {fileList.path};
                    expectedIdx = isExpected(obj,filePath);
                    allowedIdx = isAllowed(obj,'COMPLETION',filePath);
                    filterIdx = (expectedIdx & ~allowedIdx);
                    fileList(filterIdx) = [];
                end
                
                if isempty(list)
                    list = fileList;
                elseif ~isempty(fileList)
                    list = [list fileList];
                end
            end
            
            % verify the existence of each part -- remove parts that
            % don't exist from the list of returned parts.
            if ~isempty(list)
                nonExistIdx = logical(...
                    cellfun(...
                    @(f)matlab.depfun.internal.cacheExist(f,'file'),...
                    {list.path})==0);
                if any(nonExistIdx)
                    nonExistFiles = list(nonExistIdx);
                    list(nonExistIdx) = [];
                    
                    % A work-around for the racing condition (G982509).
                    % Ask one more question before removing non-existent
                    % files. If a m-file does not exist, does its p-file
                    % exist?
                    nonExistMFilesIdx = ~cellfun('isempty', ...
                        regexp({nonExistFiles.path},'\.m$'));
                    if any(nonExistMFilesIdx)
                        nonExistMFiles = nonExistFiles(nonExistMFilesIdx);
                        % checkPFiles is a cell array
                        checkPFiles = regexprep({nonExistMFiles.path}, '\.m$', '.p');
                        existPFilesIdx = logical(...
                            cellfun(...
                            @(f)matlab.depfun.internal.cacheExist(f,'file'),...
                            checkPFiles)==6);
                        lostAndFound = nonExistMFiles(existPFilesIdx);
                        % replace non-existent m-file with its
                        % corresponding existent p-file
                        for k = 1:numel(lostAndFound)
                            lostAndFound(k).path = regexprep(lostAndFound(k).path,'\.m$','.p');
                        end
                        
                        if ~isempty(lostAndFound)
                            list = [list lostAndFound];
                        end
                    end
                end
            end
            
            if ~isempty(list)
                [~,idx] = unique({list.path},'legacy');
                list = list(idx);
            end
            
            % Add a boolen field to indicate if a file is 
            % directly called by user file(s)  
            if obj.Target == matlab.depfun.internal.Target.MCR ...
                    && ~isempty(list)
                isDirectlyCalledByUserFile = ...
                               ismember({list.path}, obj.matlabFiles);
                % Dear MATLAB, why can't I just do 
                % list(isDirectlyCalledByUserFile).userCalled = true; ?
                for k=1:length(list)                    
                    list(k).userCalled = isDirectlyCalledByUserFile(k);
                end
            end
        end
    end   % End private methods

    methods

        function obj = Completion(varargin)
        % Completion Create a DEPFUN Completion object.
        % A Completion is similar to a transitive closure -- it represents
        % the complete set of files that an input "root set" of files 
        % requires in order to execute in a given context.
        %
        % Signature:
        %   c = Completion( { files } [, target ] [, level0] [, 'useDatabase'])
        %
        % Inputs:
        %   files  : full paths or resolvable against the MATLAB path.
        %   target : The context or environment in which the Completion
        %            must execute.
        %   level0 : true - level 0 dependency only
        %            false (by default) - level inf
        %   'useDatabase': an indicator that shows whether depfun database
        %                  is used (set) or not used (unset).
        %
        % Outputs:
        %        c : A Completion object. 
        %
        % Methods:
        %
        % * parts(c) retrieves the list of required parts.
        %
        % * products(c) retrieves the list of MathWorks products which are 
        %   assumed to be present on the target.
        %
        % * platforms(c) retrieves the list of platforms that the parts
        %   list supports.
        %
        % Example:
        %   c = Completion( { 'fcn1.m', 'fcn2.m', 'data.txt' }, ...
        %                  matlab.depfun.internal.Target.MCR )
            import matlab.depfun.internal.requirementsConstants
            % Initialize constructible properties
            env = matlab.depfun.internal.reqenv;
            obj.dfdb_path = env.DependencyDatabasePath;
            
            % Initialize instance properties
            obj.ExclusionList = struct.empty;
            obj.ExpectedList = struct.empty;
            obj.RootSet = {};
            obj.Inspectors = containers.Map;
            obj.matlabFiles = {};            
            obj.useExclusionListFromDB = false;
            obj.useDB = false;
            obj.CompletionLevel = inf;         
            obj.sliceClass = false;
            obj.symCls = 'matlab.depfun.internal.MatlabSymbol';
            
            obj.PathUtility = matlab.depfun.internal.PathUtility;
            obj.pcm_navigator = ...
                matlab.depfun.internal.ProductComponentModuleNavigator(env.PcmPath);

            % if no input, it is used by loadobj to only 
            % create a new empty Completion object
            if nargin == 0
                return;
            end

            % Empty / null values for possible inputs.
            files = {};
            obj.Target = matlab.depfun.internal.Target.Unknown;
            obj.CachedTbxData = [];

            obj.Platforms = matlab.depfun.internal.StringSet;
            obj.File2Vertex = containers.Map('KeyType', 'char', ...
                                             'ValueType', 'any');
            obj.isAnalyzed = containers.Map('KeyType', 'char', ...
                                             'ValueType', 'logical');
            obj.problematicFiles = containers.Map('KeyType', 'char', ...
                                             'ValueType', 'any');

            obj.isLibMATLABDeps = strcmp(getenv('LIBMATLABDEPS'), 'TRUE');                           

            obj.isWin32 = strcmp(requirementsConstants.arch, 'win32');

            % Check for too many or too few inputs
            if nargin > 6 || nargin == 0
                error(message('MATLAB:depfun:req:BadInputCount', ...
                              '1, 2, 3, 4, 5 or 6', nargin, ...
                              'matlab.depfun.internal.Completion.Completion'));
            end

            % Process the arguments by data type.
            %   * The file list must be a cell array.
            %   * The target must be a matlab.depfun.internal.Target
            %   * The level-0 must be a logical value, which indicates the
            %     depth of dependency.
            %   * The 'useDatabase' is a string flag showing whether 
            %     the depfun database is used.
            %
            % No other types are allowed. At least one of file list or
            % target must be specified. The rules argument is entirely
            % optional.
            k = 1;            

            while k <=numel(varargin)
                switch class(varargin{k})
                    case 'cell'
                        if ~isempty(files)
                            error(message('MATLAB:depfun:req:DuplicateArgType',...
                                'cell',k,filesK,'cell'));
                        end
                        files = varargin{k};
                        filesK = k;
                    case 'matlab.depfun.internal.Target'
                        if obj.Target ~= matlab.depfun.internal.Target.Unknown
                            error(message('MATLAB:depfun:req:DuplicateArgType',...
                                'matlab.depfun.internal.Target',k,targetK,...
                                'matlab.depfun.internal.Target'));
                        end
                        obj.Target = varargin{k};
                        targetK = k;
                    case 'logical'
                        % Allow user to restrict completion analysis to 
                        % immediate requirements only. If isLevel0 is true,
                        % set CompletionLevel to 0. Otherwise, keep its 
                        % default value, inf.
                        if obj.CompletionLevel == 0
                            error(...
                               message('MATLAB:depfun:req:DuplicateArgType',...
                                       'logical',k,levelK, 'logical'));
                        end
                        if varargin{k} == true
                            obj.CompletionLevel = 0;
                        end
                        levelK = k;
                    case 'char'
                        % If making use of existing database for MATLAB files
                        % is specified by the user, set the flag true; 
                        % otherwise keep its default value, false. 
                        if strcmpi(varargin{k},'useDatabase')
                            if exist(obj.dfdb_path,'file')
                                obj.useDB = true;
                                obj.useExclusionListFromDB = true;
                            end
                        elseif strncmpi(varargin{k},'createDatabase ',15)
                            obj.useDB = false;
                            obj.dfdb_path = varargin{k}(16:end);                            
                            if exist(obj.dfdb_path,'file')
                                obj.useExclusionListFromDB = true;
                            end
                        else
                            error(message('MATLAB:depfun:req:BadStringFlag', ...
                                          varargin{k}, ...
                                          'matlab.depfun.internal.Completion'));
                        end
                    case 'matlab.internal.container.graph.Graph'
                         if ~isempty(obj.DependencyGraph)
                            error(message('MATLAB:depfun:req:DuplicateArgType',...
                                'matlab.internal.container.graph.Graph',...
                                k,graphK,'matlab.internal.container.graph.Graph'));
                         end
                        obj.DependencyGraph = varargin{k};
                        graphK = k;
                    case 'containers.Map'
                        if ~isempty(obj.File2Vertex)
                            error(message('MATLAB:depfun:req:DuplicateArgType',...
                                'containers.Map',k,file2vertexK,'containers.Map'));
                        end
                        obj.File2Vertex = varargin{k};
                        file2vertexK = k;
                    otherwise
                        error(message('MATLAB:depfun:req:InvalidInputType',...
                                  k,class(varargin{k}), ...
                                  'cell, Target, logical, or char'));
                end
                k = k + 1;
            end

            % At least one of files and target must be specified.
            if isempty(files) && ...
                    obj.Target == matlab.depfun.internal.Target.Unknown
                error(message('MATLAB:depfun:req:NeedFilesOrTargetToCreate'));
            end
            
            % Create file system cache object
            obj.FsCache = matlab.depfun.internal.FileSystemCache;
        
            % reset caches -- must happen before building the inspectors,
            % since some of them use the caches.
            matlab.depfun.internal.initCaches();
            
            % Get the schema map for this target.
            obj.Schema = schemaMap(obj.Target);

            % Add CodeInspectors to the Map -- one per file extension we
            % know how to analyze.
            buildInspector(obj);
            
            % Notify the class set it should use exclude, expect and 
            % allow filters.
            
            excludeFilter = @(files)isExcluded(obj, files);
            expectFilter = @(files)isExpected(obj, files);
            allowFilter = @(files)isAllowed(obj, 'COMPLETION', files);
            matlab.depfun.internal.ClassSet.registerClassFilters(...
                excludeFilter, expectFilter, allowFilter);
                        
            if obj.Target == matlab.depfun.internal.Target.MCR
                % Avoid analyzing functions from these locations when the
                % target is the MCR. TODO: Rework into mcr.rdl.
                matlab.depfun.internal.ClassSymbol.declareToxic(...
                    { '$MATLAB/toolbox/symbolic' } );
            end
            
            % Initialize the file to required compnents map.
            obj.fileToComponents = containers.Map('KeyType','char',...
                                                  'ValueType','any');
            
            % If the PCM database exists, preload builtins into the WHICH cache. 
            if obj.useDB && obj.PathUtility.pcmexist
                matlab.depfun.internal.preloadWhichCache(obj.pcm_navigator);
            end
            
            % If the database exists, and notify the Schema that 
            % a valid REQUIREMENTS database exists.
            if obj.useDB && exist(obj.dfdb_path, 'file') == 2
                obj.DepDepot = matlab.depfun.internal.DependencyDepot(obj.dfdb_path, true); %readonly
                obj.Schema.depDepot = obj.dfdb_path;
            else
                % The Schema object is stored in a persistent map in the
                % local function schemaMap(). Here its property 'depDepot' 
                % needs to be cleared when useDB is set to false. 
                obj.DepDepot = [];
                obj.Schema.depDepot = [];
            end

            % reset the cache of exclusion list
            if obj.useExclusionListFromDB
                matlab.depfun.internal.cacheIsExcluded(obj.dfdb_path, obj.Target);
            end

            % If there are inputs to process, determine which inputs will
            % form the roots of the dependency forest.
            if ~isempty(files)
                
                % Correct obvious errors in the file names. For example,
                % remove doubled file separators: /my/path//to/a/file can
                % be corrected to /my/path/to/a/file.
                files = realpath(files);
                
                % Create the scan list first, since initializeRootSet may
                % need to put some files on the scan list.
                obj.ScanList = matlab.depfun.internal.SymbolQueue;
                
                % Create symbols for the input files -- and filter them
                % against the active rules and exclusions. After this
                % operation on those files allowed as entry points remain
                % in the root set.
                obj.RootSet = initializeRootSet(obj, files);
                
                % Add the symbols to the scan list -- enqueue the root set
                % files. Since the scan list is a handle object, the
                % modifications performed during cellfun will persist.
                arrayfun(@(f) obj.ScanList.enqueue(f), obj.RootSet);
            end
        end

        function gph = calltree(obj, parts, n, direction)
            % If the dependency graph is empty, compute it.
            computeDependencies(obj);
            gph = obj.DependencyGraph;
        end
        
        function exc = excludedFiles(obj)
            % remove duplicated records
            if ~isempty(obj.ExclusionList)
                [~,idx] = unique({obj.ExclusionList.file},'legacy');
                exc = obj.ExclusionList(idx);
            else
                exc = obj.ExclusionList;
            end
        end
        
        function  exp = expectedFiles(obj)
        % Expected directories are also recorded in
        % obj.ExpectedList. It was OK in the past.
        % But now, we want to know the explicit list of expected
        % files to identify required components for those files.    
            
            list = { obj.ExpectedList.file };
            dir_idx = matlab.depfun.internal.cacheExist(list, 'dir') == 7;
            non_dir_idx = ~dir_idx;
            
            subDir = cellfun(@(b)getSubDirRecursively(b), list(dir_idx), ...
                             'UniformOutput', false);
            subDir = [subDir{:}];            
            exp = union(list(non_dir_idx), subDir);
            
            % Everything under toolbox/matlab is expected except codetools,
            % because it is excluded for MCR target.
            if ~isempty(exp)
                remove = obj.isExcluded(exp);
                exp(remove) = [];
            end
            
            function subDir = getSubDirRecursively(baseDir)
                subDir = {};                
                
                if ispc
                    cmd = ['dir /s /A:D /B "' baseDir '"\*'];
                elseif isunix
                    cmd = ['ls -r -d -A "' baseDir '"/*'];
                else
                    return;
                end
                
                [failed, msg] = system(cmd);
                if ~failed && ~isempty(msg)                    
                    garbage_can = textscan(msg, '%s', 'Delimiter', '\n');
                    if ~isempty(garbage_can)
                        garbage_can = garbage_can{1};
                        idx = strncmp(garbage_can, baseDir, ...
                                    length(baseDir));
                        subDir = garbage_can(idx)';
                    end
                end
            end
        end

        function [parts, products, platforms] = requirements(obj)
        % REQUIREMENTS Determine required parts, products and platforms.
        % Much more efficient than calling parts, products and platforms
        % individually.        
        
            parts = computePartsList(obj, false);
            
            list = {};
            if ~isempty(parts)
                list = { parts.path };
                
                % Additional files can be pulled out of the database. 
                % Need to update obj.Platforms after querying the DB.                                 
                ext = cell(numel(list),1);
                % CELLFUN is slower than FOR loop in this case.
                for i = 1:numel(list)
                    [~,~,ext{i}] = fileparts(list{i});
                end
                cellfun(@(e)recordPlatformExt(obj,e), unique(ext));                
            end
            if ~isempty(obj.ExpectedList)
                % Expected directories are also recorded in
                % obj.ExpectedList. It was OK in the past.
                % But now, we want to know the explicit list of expected
                % files to identify required components for those files.
                expectedFiles = obj.expectedFiles();                
                list = union(list, expectedFiles);
            end            
            
            products = requiredProducts(obj, list);
            platforms = members(obj.Platforms);            
        end
        
        function p = platforms(obj)
        % PLATFORMS List platforms on which Completion will run. 
        % If the Completion contains platform-specific functions or files,
        % the application represented by the Completion can only run on
        % those platforms. 
        %
        % If the returned list is empty, the Completion contains no
        % platform-specific code.
        
            function ext = fileExtension(f)
                [~,~,ext] = fileparts(f);
            end
            
            if obj.useDB
                fileList = retrieveDependencyFromDatabase(obj);
                if ~isempty(fileList)
                    files = {fileList.path};
                    ext = cellfun(@fileExtension, files, 'UniformOutput', false);
                    cellfun(@(e)recordPlatformExt(obj,e), unique(ext));
                end
            end
            p = members(obj.Platforms);
        end

        function builtinListMap = retrieveBuiltinListMap(obj) 
        % retrieve used built-ins from inspectors
            builtinListMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            inspectorName = keys(obj.Inspectors);
            for i = 1:numel(inspectorName)
                % tmpLis is a map of files and a cell array of MatlabSymbol
                tmpMap = obj.Inspectors(inspectorName{i}).BuiltinListMap;
                builtinListMap = [builtinListMap; tmpMap];
            end
        end

        function p = products(obj)
        % PRODUCTS What products does this Completion require?
        % This list of products must be present in the target environment
        % in order for the application represented by the Completion to
        % run.

            p = struct([]);
            list = {};   
            % This call to computePartsList typically does not recompute
            % dependencies, because the scan list is empty.
            plist = computePartsList(obj);
            if ~isempty(plist)
                list = { plist.path };
            end
            if ~isempty(obj.ExpectedList)
                list = [ list, { obj.ExpectedList.file } ];
            end
            
            p = requiredProducts(obj, list);            
        end

        function list = parts(obj, canonicalPath)
        % PARTS List the parts (files) in the Completion.
        % Ship these files to the target environment to run the application
        % represented by the Completion.  
        
            if nargin == 1, canonicalPath = false; end
            
            list = computePartsList(obj, canonicalPath);                        
        end
        
        function [deployable, reason] = isdeployable(obj, files, entryPoint)
        % ISDEPLOYABLE Can the files be shipped to the target environment?
        % Files that are not deployable may still be useable by
        % applications because the files may be present in the target
        % environment.
        %
        % Return values:
        %    deployable: Logical mask the same size as files.
        %
        %    reason    : Structure explaining each file's deployability. The
        %                same size as deployable.
        %
        % A file is deployable if (and only if) it is:
        %
        %  * Not excluded.
        %  * Not removed from the ROOTSET or COMPLETION by a set
        %    manipulation rule.
        %  * Not expected, or expected and allowed.
        %
        % All three of these conditions must be true for a file to be
        % deployable.
        %
        % isdeployable very specifically determines ONLY if the file may be
        % placed in a package to be shipped from the source machine to the
        % target environment. It does not determine whether or not a
        % deployed application may use the file in question, as that
        % knowledge is not available.
            import matlab.depfun.internal.Target;
        
            % By default, test for the broadest notion of deployablity: can
            % the file be part of the package at all? (Test for inclusion
            % in the COMPLETION.) The ROOTSET is the set of entry points,
            % or the main file in the case of an App. (The name ROOTSET is
            % meant to suggest the ROOTS from which the forest of
            % requirements grows.)
            fileSet = 'COMPLETION';
            if entryPoint
                fileSet = 'ROOTSET';
            end
            
            % This message used to explain why a file is deployable. By
            % default, let all files be deployable.
            deployableWhy = ...
                msg2why(message('MATLAB:depfun:req:DeployableFile', ...
                        Target.str(obj.Target)));
            reason = repmat(deployableWhy,1,numel(files));

            % Turn the input files into symbols.
            [symbols, uType] = resolveRootSet(obj, files);
            
            % Determine if the set operations remove or add the files in
            % question to the indicated file set.
            paths = {};
            if ~isempty(symbols)
                paths = { symbols.WhichResult };
            else
                paths = uType;
            end
            [~, keep, rMap] = ruleActions(obj, fileSet, paths);
                        
            % keep is a logical index the same length as the file list. 
            % Where keep is false, the rule set mandates file removal.
            % Removed files are not deployable.
            deployable = keep;

            % Add the reasons for removal to the list of reasons. 
            % Map is poorly vectorizable, so must use a manual loop
            removed = paths(~keep);
            for k=1:numel(removed)
                reason(k) = rMap(removed{k});
            end 
            
            % Determine which files are excluded, expected and allowed,
            % or replaced.
            %
            % If a file has been removed by the set rules, don't overwrite
            % the set rule-related explanation.
            replacedFiles = {};
            if isKey(rMap,'#REPLACED')
                replacedFiles = rMap('#REPLACED');
            end
            
            [excluded, whyExcluded] = isExcluded(obj, paths);
            if ~all(excluded)
                
                replaced = zeros(1,numel(paths));
                if numel(replacedFiles) > 0
                    for k=1:numel(paths)
                        replaced(k) = ismember(paths{k}, replacedFiles);
                        reason(k) = deployableWhy;
                    end
                    paths(replaced) = rMap('#REPLACEMENT');
                    keep = keep | replaced;
                end
                
                [expected, whyExpected] = isExpected(obj, paths);
                allowed = isAllowed(obj, fileSet, paths);
                
                expected = expected & ~allowed;
                explain = expected & keep;  % Kept by rules, but expected
                if ~isempty(whyExpected)
                    reason(explain) = whyExpected(explain);
                end
            else
                expected = false(1,numel(paths));
            end
            
            % Merge the results -- excluded trumps expected and allowed, and 
            % allowed trumps expected.
            deployable = keep & ~excluded & ~expected;
            explain = excluded & keep;  % Kept by rules, but excluded
            if ~isempty(whyExcluded)
                reason(explain) = whyExcluded(explain);
            end
        end

        function S = saveobj(obj)
            S.Schema = obj.Schema;
            S.PathUtility = obj.PathUtility;
            S.Platforms = obj.Platforms;
            S.Target = obj.Target;
            S.DependencyGraph = obj.DependencyGraph;
            S.ExclusionList = obj.ExclusionList;
            S.ExpectedList = obj.ExpectedList;
            S.RootSet = obj.RootSet;
            S.Inspectors = obj.Inspectors;
            S.ScanList = obj.ScanList;
            S.CompletionLevel = obj.CompletionLevel;
            S.File2Vertex = obj.File2Vertex;
            S.CachedTbxData = obj.CachedTbxData;
            S.PlatformExt = obj.PlatformExt;
            S.sliceClass = obj.sliceClass;
            S.FsCache = obj.FsCache;
            S.isAnalyzed = obj.isAnalyzed;
            S.useDB = obj.useDB;
            S.matlabFiles = obj.matlabFiles;
            S.dfdb_path = obj.dfdb_path;
            S.isWin32 = obj.isWin32;
            S.symCls = obj.symCls;
            S.builtinSymbolToComponent = obj.builtinSymbolToComponent;
%             S.matlabModuleToComponent = obj.matlabModuleToComponent;
            S.sourceToComponent = obj.sourceToComponent;
            S.fileToComponents = obj.fileToComponents;
            S.problematicFiles = obj.problematicFiles;
        end

        function [g, insertedFiles] = getDependencyGraph(obj,varargin)
        % If there is no insertAsIs list, 
        %   [g, insertedFiles] = getDependencyGraph(obj)  
        % If there is an insertAsIs list,
        %   [g, insertedFiles] = getDependencyGraph(obj,tbxDir,insertList)
            
            insertedFiles = {};
            
            % compute level-0 dependencies
            obj.computeDependencies();
            
            if numel(varargin) > 0
                if numel(varargin) ~= 2
                   error(message('MATLAB:depfun:req:BadInputCount', ...
                          '0 or 2', numel(varargin), ...
                          'matlab.depfun.internal.Completion.getDependencyGraph')); 
                end
                
                if ischar(varargin{1})
                    tbxDir = varargin{1};
                else
                    error(message('MATLAB:depfun:req:InvalidInputType', ...
                                  1, class(varargin{1}), 'char'));
                end                
                if ischar(varargin{2})
                    insertList = varargin{2};
                else
                    error(message('MATLAB:depfun:req:InvalidInputType', ...
                                  2, class(varargin{2}), 'char'));
                end
                
                % add files on the InsertAsIs list to the level-0 dependency graph
                insertedFiles = ...
                    obj.addFilesOnInsertAsIsListToGraph(tbxDir,insertList);
            end
            
            % return the graph
            g = obj.DependencyGraph;
        end
        
        function insertedFiles = addFilesOnInsertAsIsListToGraph(obj,tbxDir,insertList) 
        % create vertices and edges for files on the InsertAsIs list in the level-0
        % dependency graph
            import matlab.depfun.internal.MatlabSymbol;
            import matlab.depfun.internal.MatlabType;
            
            insertedFiles = {};

            fs = filesep;
            datafiles = extractDataDependencyFromInsertAsIsList(insertList);
            if ~isempty(datafiles)
                for i = 1:length(datafiles)
                    % reformat the file name
                    cltName = datafiles(i).file;
                    cltName = obj.PathUtility.rp2fp(tbxDir,cltName);
                    cltName = strrep(cltName,'/',fs);
                    % create a temp symbol, name and type are not important
                    clt.symbol = MatlabSymbol(cltName, MatlabType.NotYetKnown, cltName);
                    % find the vertex ID of the client file in the graph
                    cltVid = findOrCreateVertex(obj, clt, false);           
                    if ~isempty(cltVid)
                        for j = 1:length(datafiles(i).data)
                            % reformat the file name
                            svcPath = datafiles(i).data{j};
                            svcPath = obj.PathUtility.rp2fp(tbxDir, svcPath);
                            svcPath = strrep(svcPath,'/',fs);
                            % G952064: The symbol name of data file should
                            % not contain the MATLAB root.
                            svcSymbol = strrep(svcPath, [matlabroot fs], '');
                            svcSymbol = strrep(svcSymbol, fs, '/');
                            % create a data symbol
                            svc.symbol = MatlabSymbol(svcSymbol, MatlabType.Data, svcPath);
                            % create a new vertex
                            svcVid = findOrCreateVertex(obj, svc, true);
                            % add a new edge    
                            addEdge(obj.DependencyGraph, cltVid, svcVid);
                            
                            % save the inserted data file
                            insertedFiles = [insertedFiles; svcPath]; %#ok
                        end
                    end
                end
                insertedFiles = unique(insertedFiles);
            end
        end
        
        function b2c = get.builtinSymbolToComponent(obj)
        % Extract the mapping of built-in symbols to owning components. 
            if isempty(obj.builtinSymbolToComponent)
                obj.builtinSymbolToComponent = obj.pcm_navigator.builtinToComponentMap;
            end
            
            b2c = obj.builtinSymbolToComponent;
        end

% Due to several component boundary violations in the current code base,
% this property is disabled for 16a.
%         function m2c = get.matlabModuleToComponent(obj)
%         % Extract the mapping of MATLAB modules to owning components.
%             if isempty(obj.matlabModuleToComponent)
%                 obj.matlabModuleToComponent = obj.pcm_navigator.MatlabModuleToComponentMap;
%             end
%
%             m2c = obj.matlabModuleToComponent;
%         end

        function s2c = get.sourceToComponent(obj)
        % Extract the mapping of MATLAB modules and sub-directories to owning components.
            if isempty(obj.sourceToComponent)
                obj.sourceToComponent = obj.pcm_navigator.sourceToComponentMap;
            end

            s2c = obj.sourceToComponent;
        end
        
        function result = get.uncompilabeTbx(obj)
            if isempty(obj.uncompilabeTbx)
                obj.uncompilabeTbx = ...
                    string(strcat(obj.pcm_navigator.getUncompilableTbxRoot, filesep));
            end

            result = obj.uncompilabeTbx;
        end

        function f2c = fileToComponentMap(obj)
            % Return the map of files and required components.
            f2c = obj.fileToComponents;
        end

        function failedFiles = problematicfilesEncountered(obj)
             % Return the list of files that depfun has trouble to analyze.
             failedFiles = obj.problematicFiles;
        end
    end
end

function m = schemaMap(target, clobber)
% schemaMap Return the Target to Schema map for the current MCR
% Create maps as necessary. 
    persistent mcrMap
    
    % Retrieve corresponding enum integer
    tgt = matlab.depfun.internal.Target.int(target);

    m = [];

    if nargin > 1 && clobber
        mcrMap = [];
        return;
    end

    % If there are no rules at all yet, create the MCR index map    
    if isempty(mcrMap)
        mcrMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    end
    
    % If there's no schema map for the current MCR, create one. If there is,
    % set rulesMap to refer to it.
    if ~isKey(mcrMap, get_current_mcr_id)
        rulesMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
        mcrMap(get_current_mcr_id) = rulesMap;
    else
        rulesMap = mcrMap(get_current_mcr_id);
    end

    % If the current rules map contains no Schema for the current target,
    % create one.
    if ~isKey(rulesMap, tgt)
        rulesMap(tgt) = targetSchema(target);
    end
    m = rulesMap(tgt);
end

function s = targetSchema(target)
    import matlab.depfun.internal.Target;

    % Use target to determine rules file
    rulesFile = '';
    switch target
      case Target.PCTWorker
        rulesFile = 'pctworker.rdl';
      case Target.MATLAB
        rulesFile = 'matlab.rdl';
      case Target.MCR
        rulesFile = 'mcr.rdl';
      case Target.Deploytool
        rulesFile = 'deploytool.rdl';
      case { Target.None, Target.All }
        % Empty rules file for these targets
        rulesFile = 'empty.rdl';
      otherwise
        error(message('MATLAB:depfun:req:BadTarget', Target.str(target)));
    end

    if isempty(rulesFile)
        error(message('MATLAB:depfun:req:InternalNoRules'));
    end

    [deproot, ~, ~] = fileparts(mfilename('fullpath'));
    rulesFile = fullfile(deproot,rulesFile);

    if exist(rulesFile, 'file') ~= 2
        error(message('MATLAB:depfun:req:RulesFileMustExist', rulesFile));
    end

    s = matlab.depfun.internal.Schema();
    s.addRules(rulesFile);
    
end

% ---------------------------------------------------------------------------
% Local functions

function pth = fullpath(file, rootDir)
% Return the fullpath to a file. Why is this tricky? Because the file
% string may be a full path already.
pth = '';
if isfullpath(file)
    pth = file;
elseif ~isempty(file)
    pth = fullfile(rootDir,file);
end
end

%---------------------------------------------------------------------------
function pext = initPlatformExt()
% Create the platform extension map: extension -> list of architectures
% Each value in the map is a cell array of strings, even singletons.
    import matlab.depfun.internal.StringSet;

    mexall = mexext('all');
    pext = containers.Map(...
         strcat('.', { mexall.ext } ), ...
         cellfun(@(e){e},{mexall.arch},'UniformOutput',false));
    pext('.dll') = { 'win32', 'win64' };
    pext('.so') = { 'glnxa64', 'glnx86' };
    pext('.dylib') = { 'maci64' };
    
end

%---------------------------------------------------------------------------
function uddPkgSchema = getUDDPackageSchema(uddClsDir)
%getUDDPackageSchema Get package schema.m and/or schema.p for UDD class 
    import matlab.depfun.internal.cacheExist;
    
    uddPkgSchema ={};
    atIdx = strfind(uddClsDir, [filesep '@']);
    uddPkgPath = uddClsDir(1:atIdx(end)); % Package name ends at the 2nd @
    uddPkgSchemaM = [uddPkgPath 'schema.m'];
    if cacheExist(uddPkgSchemaM,'file')
        uddPkgSchema = [ uddPkgSchema uddPkgSchemaM ];
    end
    
    uddPkgSchemaP = [uddPkgPath 'schema.p'];
    if cacheExist(uddPkgSchemaP,'file')
        uddPkgSchema = [ uddPkgSchema uddPkgSchemaP ];
    end
end

%---------------------------------------------------------------------------
function uddClsSchema = getUDDClassSchema(uddClsDir)
%getUDDClassSchema  Get class schema.m for UDD class 
    import matlab.depfun.internal.cacheExist;
    fs = filesep;
    % Class name ends at the first filesep after the last @ 
    atIdx = strfind(uddClsDir, [fs '@']) + 1;
    sepIdx = strfind(uddClsDir, fs);
    n = numel(uddClsDir);
    if ~isempty(atIdx) && ~isempty(sepIdx)
        n = find(sepIdx > atIdx(end));
        if ~isempty(n), n = sepIdx(n); end
    end
   
    uddPkgPath = uddClsDir(1:n);  
    uddClsSchema = [uddPkgPath 'schema.m'];
    if ~cacheExist(uddClsSchema,'file')
        uddClsSchema = '';
    end
end

%---------------------------------------------------------------------------
function uddPkgSchema = getUDDPackageFunctionSchema(w)
% getUDDPackageFunctionSchema
% Get package schema.m and/or schema.p for UDD package function 
    import matlab.depfun.internal.cacheExist;
    fs = filesep;
    uddPkgSchema = {};
    atIdx = strfind(w, [fs '@']) + 1;
    if numel(atIdx) == 1 && atIdx > 1
        % Find the file separators
        fsIdx = strfind(w, fs);
        % The file separator that ends the package directory path is the
        % first one after the @.
        pkgIdx = find(fsIdx > atIdx);
        if ~isempty(pkgIdx)
            uddPkgPath = w(1:(fsIdx(pkgIdx(1))-1));
            uddPkgSchemaM = fullfile(uddPkgPath,'schema.m');            
            if cacheExist(uddPkgSchemaM,'file')
                uddPkgSchema = [ uddPkgSchema uddPkgSchemaM ];
            end
            
            uddPkgSchemaP = fullfile(uddPkgPath,'schema.p');
            if cacheExist(uddPkgSchemaP,'file')
                uddPkgSchema = [ uddPkgSchema uddPkgSchemaP ];
            end
        end
    end
end

%---------------------------------------------------------------------------
function xFiles = extractDataDependencyFromInsertAsIsList(insertasisList)
    % check if the insert_as_is list is empty
    fp = fopen(insertasisList,'r');
    if fp < 0
        error(['Cannot find insert as is list: ' insertasisList]);
    end
    if fseek(fp, 1, 'bof') == -1
        % empty file
        fclose(fp);
        xFiles = [];
        return;
    else
        fclose(fp);
    end
    
    xDoc = xmlread(insertasisList);

    % Recurse over child nodes. This could run into problems 
    % with very deeply nested trees.
    xTree = parseChildNodes(xDoc);

    xFiles = findFileElement(xTree);
end

% ----- Local function PARSECHILDNODES -----
function children = parseChildNodes(theNode)
% Recurse over node children.
    children = [];
    if theNode.hasChildNodes
       childNodes = theNode.getChildNodes;
       numChildNodes = childNodes.getLength;
       allocCell = cell(1, numChildNodes);

       children = struct(             ...
          'Name', allocCell, 'Attributes', allocCell,    ...
          'Data', allocCell, 'Children', allocCell);

        for count = 1:numChildNodes
            theChild = childNodes.item(count-1);
            children(count) = makeStructFromNode(theChild);
        end
    end
end

% ----- Local function MAKESTRUCTFROMNODE -----
function nodeStruct = makeStructFromNode(theNode)
% Create structure of node info.
    nodeStruct = struct(                        ...
       'Name', char(theNode.getNodeName),       ...
       'Attributes', parseAttributes(theNode),  ...
       'Data', '',                              ...
       'Children', parseChildNodes(theNode));

    if any(strcmp(methods(theNode), 'getData'))
       nodeStruct.Data = char(theNode.getData); 
    else
       nodeStruct.Data = '';
    end
end

% ----- Local function PARSEATTRIBUTES -----
function attributes = parseAttributes(theNode)
% Create attributes structure.
    attributes = [];
    if theNode.hasAttributes
       theAttributes = theNode.getAttributes;
       numAttributes = theAttributes.getLength;
       allocCell = cell(1, numAttributes);
       attributes = struct('Name', allocCell, 'Value', ...
                           allocCell);

       for count = 1:numAttributes
          attrib = theAttributes.item(count-1);
          attributes(count).Name = char(attrib.getName);
          attributes(count).Value = char(attrib.getValue);
       end
    end
end

%--------------------------------------------------------------
function files = findFileElement(theTree)
    if strcmp(theTree.Name,'dependency')
        files = [];
        for i = 1:length(theTree.Children)
            if strcmp(theTree.Children(i).Name,'file')
                filenode.file= theTree.Children(i).Attributes.Value;
                filenode.data = {}; 
                filenode.fid = [];
                for j = 1:length(theTree.Children(i).Children)
                    if strcmp(theTree.Children(i).Children(j).Name,'data')
                        filenode.data = [filenode.data theTree.Children(i).Children(j).Attributes.Value];
                    end
                end
                files = [files filenode];
            end
        end
    else
        error(message('MATLAB:depfun:req:InvalidInsertAsIsList'));
    end
end

%-------------------------------------------------------------        
function crt_pth = getCurrentPath()
    % get the path string in which entries are separated by ';'.
    pth_str = path;
    % get the cannonical path
    pth_str = strrep(pth_str, filesep, '/');
    % convert string to cell array
    crt_pth = strsplit(pth_str, pathsep);
end

%-------------------------------------------------------------
function user_alias = findUserAliasFiles(traceList)
    import matlab.depfun.internal.requirementsConstants
    
    user_alias = {};
    if ~isempty(traceList)
        w = {traceList.path};
        user_files = w(~contains(w, requirementsConstants.MatlabRoot));    
        if ~isempty(user_files)
            user_paths = unique(filename2path(user_files));
            possible_user_alias = strcat(user_paths, requirementsConstants.FileSep, 'alias');
            exist_idx = cellfun(@(f)matlab.depfun.internal.cacheExist(f,'file')==2, possible_user_alias);
            user_alias = possible_user_alias(exist_idx);
        end						      
    end
end
