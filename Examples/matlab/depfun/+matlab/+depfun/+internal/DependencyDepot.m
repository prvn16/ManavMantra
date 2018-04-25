classdef DependencyDepot < handle
    properties
        dbName
        Target
        Component
    end
    
    properties (Access = private)
        SqlDBConnObj 
        Language2ID
        ID2Language        
        FileSep = filesep;
        MatlabRoot = matlabroot;
        tableData = init_db_table_data;
        fileClassifier  % Simple file classification based on file extension
        protectedLocations % Cache of protected locations
        isPC
        Environment
        Vertex2FileID;
        Principal2FileID;
    end
    
	methods
        
        function obj = DependencyDepot(DBName, readonly)
            % Input must be a string
            if ~ischar(DBName)
                error(message('MATLAB:depfun:req:InvalidInputType', ...
                    1, class(DBName), 'char'))
            end
            
            % fullpath of the database
            obj.dbName = DBName;

            % Create a database connector object.
            try 
                obj.SqlDBConnObj = matlab.depfun.internal.database.SqlDbConnector;
            catch ME
                error(message(...
                    'MATLAB:depfun:req:InvalidDatabaseConnectionObj',...
                    ME.message))
            end

            % create a new database if it doesn't exist yet.
            created = false;
            if ~exist(obj.dbName,'file')
                created = true;
                obj.SqlDBConnObj.createDatabase(obj.dbName);
            end

            if(nargin > 1 && readonly == true)
                % connect read-only
                obj.SqlDBConnObj.connectReadOnly(obj.dbName);                
            else
                % connect to the database as read/write
                obj.SqlDBConnObj.connect(obj.dbName);
            end
             
            % if we just created the database, initialize the tables.
            if created
                if(ispc)
                    % the default blocksize for NTFS is 4K
                    % if this is a PC set the blocksize of the DB to 4K
                    % this needs to be done before the first table is created. 
                    obj.SqlDBConnObj.doSql('PRAGMA page_size=4096', false);
                end
                obj.createTables();
            end
            
            % we're never going to try to recover the DB if something goes wrong
            % just shut all this stuff off
            obj.SqlDBConnObj.doSql('PRAGMA synchronous=OFF;', false);
            obj.SqlDBConnObj.doSql('PRAGMA journal_mode=OFF;', false);
            obj.SqlDBConnObj.doSql('PRAGMA temp_store=MEMORY;', false); 
            
            obj.fileClassifier = matlab.depfun.internal.FileClassifier;
            obj.isPC = ispc;
            obj.Environment = matlab.depfun.internal.reqenv;
            obj.Vertex2FileID = containers.Map('KeyType', 'uint64', 'ValueType', 'double');
            obj.Principal2FileID = containers.Map('KeyType', 'char', 'ValueType', 'double');
        end
        
        function delete(obj)
            obj.disconnect();
        end

        function disconnect(obj)
            if ~isempty(obj.SqlDBConnObj)
                obj.SqlDBConnObj.disconnect();
            end
        end
        
        function result = fetchNonEmptyRow(obj)
        % Fetch a row that is not expected to be empty.
        % If it is empty, report an error.
            result = obj.SqlDBConnObj.fetchRow();
            if isempty(result)
                error(message('MATLAB:depfun:req:EmptyFetchResult'))
            end
        end
        
        function result = fetchNonEmptyRows(obj)
        % Fetch a set of rows that is not expected to be empty.
        % If it is empty, report an error.
            result = obj.SqlDBConnObj.fetchRows();
            if isempty(result)
                error(message('MATLAB:depfun:req:EmptyFetchResultList'))
            end
        end
        
        function result = fetchRow(obj)
            result = obj.SqlDBConnObj.fetchRow();
        end
        
        function result = fetchRows(obj)
            result = obj.SqlDBConnObj.fetchRows();
        end
        
        function doSql(obj, sqlCmd)
            obj.SqlDBConnObj.doSql(sqlCmd);
        end
        
        function startID = recordFileData(obj, symList, vertexID)
        % Bulk insert the files that the symbols represent, using their
        % vertex info to properly assign file IDs. If no vertexIDs are
        % provided, the files will be labled from obj.maxFileID to obj.maxFileID +
        % length(symlist) - 1. The fileID of the first inserted file is
        % returned as startID.
            
            BuiltinClassID = ...
                int32(matlab.depfun.internal.MatlabType.BuiltinClass);

            BuiltinFunctionID = ...
                int32(matlab.depfun.internal.MatlabType.BuiltinFunction);
            
            MatlabID = obj.Language2ID('MATLAB');
            CppID = obj.Language2ID('CPP');
            
            numSym = length(symList);

            % if vertexIDs were provided, determine which of those vertices 
            % are already in the Vertex2FileID map
            if(nargin == 3)
                inMap = obj.Vertex2FileID.isKey(num2cell(vertexID));
            else
                inMap = false(numSym, 1);
            end
            
            numNew = nnz(~inMap);
            newSymList = symList(~inMap);

            % determine the first available fileID to use. If nothing has
            % been inserted into the file table yet, try to find the last 
            % used fileID in the mapping
            obj.SqlDBConnObj.doSql('SELECT COALESCE(max(ID), 0) FROM File');
            startID = double(obj.SqlDBConnObj.fetchRow());
            if(~isempty(obj.Vertex2FileID))
                allMapped = obj.Vertex2FileID.values;
                allMapped = [allMapped{:}];
                startID = max([allMapped, startID]);
            end

            startID = startID + 1;
            fileID = startID : startID + numNew - 1;
            
            % add any new vertices to the mapping 
            if(nargin == 3 && numNew > 0)
                newMap = containers.Map(vertexID(~inMap), fileID);
                obj.Vertex2FileID = [obj.Vertex2FileID; newMap];
            end
                        
            Type = [newSymList.Type];
            TypeID = int32(Type);
            
            LanguageID = ones(1, numNew) .* MatlabID;
            BuiltinIdx = logical(TypeID==BuiltinClassID | ...
                                 TypeID==BuiltinFunctionID);
            LanguageID(BuiltinIdx) = CppID;

            % for transplantability, only save relative path to the matlabroot 
            WhichResult = strrep({newSymList.WhichResult}, ...
                                 [obj.MatlabRoot obj.FileSep], '');

            % canonical path
            WhichResult = strrep(WhichResult, obj.FileSep, '/');
            Symbol = {newSymList.Symbol};
            
            % Insert the files into the file table; bulk insert for 
            % performance.
            obj.SqlDBConnObj.insert('File', 'ID', fileID, ...
                'Path', WhichResult, 'Language', LanguageID, ...
                'Type', TypeID, 'Symbol', Symbol);
        end

        function recordProxyData(obj, proxySymbols)
        % Fill in the Proxy_Principal table. Each row in the table
        % represents a single proxy -> principal relationship. There are at
        % least as many rows in the table as there are principals. There
        % may be more rows, if multiple proxies represent the same
        % principals.
        %
        % To fill in the table, we create two vectors of the same size,
        % proxyID and principalID. Since we're creating the table here, we
        % can deduce the IDs a priori, which is much faster than querying
        % the database.
        % 

            % stores only the new principals that are not yet in the file table
            principalSymbols = matlab.depfun.internal.MatlabSymbol.empty(1,0);
            proxyID = [];
            principalID = [];
            vertexID = 0;
            expandedProxy = containers.Map('KeyType','char',...
                                           'ValueType','logical');
                                      
            % TODO: Consider moving this loop into a method owned by
            % Completion. buildTraceList may need something like it.
            for symbol = proxySymbols
                pList = principals(symbol);
                if ~isempty(pList)
                    % Store proxy names as full paths without extension, 
                    % so we can detect, for example, when a .p and .m file 
                    % represent the same principals.
                    %
                    % Why does this matter? Because the file list in the
                    % database cannot have duplicate entries. Therefore,
                    % the files in the principal list must be unique.
                    %
                    % In the case of a built-in, try to find the class
                    % directory on the path and use that for a key.
                    proxyName = proxyLocation(symbol);
                    proxyFileID = obj.Vertex2FileID(vertexID);
                    
                    % only new principals that aren't already in the
                    % proxy_principal table need to get added
                    if(~isempty(obj.Principal2FileID))
                        inMap = obj.Principal2FileID.isKey({pList.WhichResult});
                        pList = pList(~inMap);
                    end  
                    
                    if isKey(expandedProxy, proxyName)
                        % Find the IDs of the principals (already
                        % assigned) by finding the locations of the
                        % principals in the principalSymbols list.
                        newPrincipals = zeros(1,numel(pList));
                        principalPaths = {principalSymbols.WhichResult};
                        for n=1:numel(pList)
                            matchP = strcmp(pList(n).WhichResult, ...
                                            principalPaths);
                            id = find(matchP);
                            newPrincipals(n) = id;
                        end
                        newProxy = ones(1,numel(pList)) .* proxyFileID;
                    else
                        % Remember that we've expanded this proxy already.
                        expandedProxy(proxyName) = true;

                        % Remember the IDs of the proxy and its principals.
                        % This code assumes files are inserted into the
                        % database in the same order as they appear in the
                        % array.
                        pCount = numel(principalSymbols);
                        numPList = numel(pList);
                        newPrincipals = (1:numPList) + pCount;
                        newProxy = ones(1,numPList) .* proxyFileID;
   
                        principalSymbols = [principalSymbols pList]; %#ok
                    end
                    proxyID = [proxyID newProxy];  %#ok
                    principalID = [ principalID newPrincipals ]; %#ok
                end
                vertexID = vertexID + 1;
            end
            
            % Add the principals to the file table. By definition, the
            % principal set and the proxy set have an empty intersection.
            if ~isempty(principalSymbols)
                startID = recordFileData(obj, principalSymbols);
                
                % match the principalIDs to those written in the file table
                principalID = principalID + startID - 1;
                
                % Bulk insert
                obj.SqlDBConnObj.insert('Proxy_Principal', ...
                                        'Proxy', proxyID, ...
                                        'Principal', principalID);
            end
        end

        function recordDependency(obj, target, graph, component)
        % Write the level-0 dependency to the database

            obj.Target = target;
            obj.Component = component;
                
            % Insert file information to table File            
            % modifications for performance, g904544
            % (1) cache Language table
            cacheLanguageTable(obj);

            % If the graph is empty, stop. Do nothing else.
            if isempty(graph) || graph.VertexCount == 0
                return;
            end

            % (2) use bulk insert
            % retrieve data from each vertex in the graph
            vertexIDs = graph.VertexIDs()';
            symList = partProperty(graph, 'Data', 'Vertex');
            symList = [symList.symbol];

            % Fill in the file table
            obj.recordFileData(symList, vertexIDs);

            obj.clearTable('Level0_Use_Graph');
            % Insert level-0 dependency to table Level0_Use_Graph
            obj.recordEdges(graph, 'Level0_Use_Graph');

            % Insert principal/proxy data.
            obj.recordProxyData(symList);
        end

        function recordClosure(obj, graph)
            % Insert transitive closure to table Proxy_Closure
            obj.recordEdges(graph, 'Proxy_Closure');            
        end
        
        function recordFileToComponentMap(obj, fileToComponents)
        % Records required components for each file

            if isempty(fileToComponents)
                return;
            end
            
            fileList = keys(fileToComponents);
            % newReqs is a cell array. Each element is a cell
            % array of required components of each file.            
            newReqs = values(fileToComponents, fileList);
            
            obj.SqlDBConnObj.doSql('SELECT Name FROM Required_Components;');
            % if the dfdb is being created from scratch, recordedReqs should be empty
            recordedReqs = obj.SqlDBConnObj.fetchRows();

            toRecord = setdiff([newReqs{:}], [recordedReqs{:}]); 
            obj.SqlDBConnObj.insert('Required_Components', 'Name', toRecord);
            
            obj.SqlDBConnObj.doSql('SELECT ID, Name FROM Required_Components;');
            tmp = obj.SqlDBConnObj.fetchRows();
            ids = cell2mat(cellfun(@(r)r{1},tmp,'UniformOutput',false))';
            componentList = cellfun(@(r)r{2},tmp,'UniformOutput',false)';
                    
            % Replace component name with component ID
            for k = 1:numel(componentList)
                newReqs = cellfun(@(c)regexprep(c, ...
                               ['^' componentList{k} '$'], num2str(ids(k))), ...
                               newReqs, 'UniformOutput', false);
            end                        
            
            fileID = obj.lookupFileIDs(fileList);
            
            % preallocation for performance
            num_rows = sum(cellfun(@(a)numel(a),newReqs));
            fileID_componentID = zeros(num_rows,2);
            count = 0;
            for k = 1:numel(fileList)
                num_component = numel(newReqs{k});
                fileID_componentID(count+1:count+num_component, :) = ...
                    [ ones(num_component,1).*fileID(k) ...
                      str2double(newReqs{k})' ];
                count = count + num_component;
            end
            
            obj.SqlDBConnObj.insert('File_Components', ...
                                    'File', fileID_componentID(:,1), ...
                                    'Component', fileID_componentID(:,2));
                                
            obj.SqlDBConnObj.doSql('PRAGMA index_info(File_Components_Index);');
            if(isempty(obj.SqlDBConnObj.fetchRows()))
                obj.SqlDBConnObj.doSql([...
                    'CREATE INDEX File_Components_Index ON ' ...
                    'File_Components(File)']);
            end
        end
        
        function fileID = lookupFileIDs(obj, fileList)
            % for transplantability, only save the path relative to the matlabroot 
            fileList = matlab.depfun.internal.PathNormalizer.normalizeFiles(fileList, true);
            num_files = numel(fileList);
            fileID = zeros(size(fileList));
            
            % SQLite cannot handle too many terms in compound SELECT.
            % SQLITE_MAX_COMPOUND_SELECT is defined 500 by default.            
            group_size = 256;
            current_group_size = group_size;
            
            count = 0;
            while count < num_files
                start_idx = count + 1;
                end_idx = count + group_size;
                if end_idx > num_files
                    end_idx = num_files;
                    current_group_size = end_idx - start_idx + 1;
                end
                                
                % Get many file IDs with one query
                query = [ 'SELECT ID FROM File WHERE Path = ''%s'' ' ...
                          repmat(['UNION ALL ' ...
                          'SELECT ID FROM File WHERE Path = ''%s'' '], ...
                          1, current_group_size-1) ';'];
                query = sprintf(query, fileList{start_idx:end_idx});
                obj.SqlDBConnObj.doSql(query);
                fileID(start_idx:end_idx) = ...
                    double(cell2mat(decell(obj.SqlDBConnObj.fetchRows())));

                count = count + current_group_size;
            end
        end
        
        function updateComponentDependencyTables(obj, ...
                                      requiredComponents, fileToComponents)
            obj.clearComponentDependencyTables();
            
            obj.SqlDBConnObj.insert('Required_Components', ...
                                    'Name', requiredComponents);
 
            obj.SqlDBConnObj.insert('File_Components', ...
                                    'File', fileToComponents(:,1), ...
                                    'Component', fileToComponents(:,2));
            obj.SqlDBConnObj.doSql([...
                'CREATE INDEX File_Components_Index ON ' ...
                'File_Components(File)']);
        end
        
        function result = getRequiredComponents(obj, varargin)
            if numel(varargin) == 0
                obj.SqlDBConnObj.doSql('SELECT Name From Required_Components ORDER BY ID ASC;');
                result = decell(obj.SqlDBConnObj.fetchRows());
            end
        end
        
        function result = getFileToComponents(obj, request)
            obj.SqlDBConnObj.doSql('SELECT File, Component From File_Components;');
            tmp = obj.SqlDBConnObj.fetchRows();            
            switch request
                case 'file'
                    result = cell2mat(cellfun(@(r)r{1},tmp,'UniformOutput',false))';
                case 'component'
                    result = cell2mat(cellfun(@(r)r{2},tmp,'UniformOutput',false))';
                otherwise
                    result = [];
            end
        end

        function [graph, file2Vertex] = getDependency(obj, component, target) %#ok<INUSD>
        % Return level-0 dependency and FilePath2Vertex mapping
        % graph = getDependency(obj [,component] [,target])

            % make sure the caches required by createGraphAndAddEdges are
            % initialized properly
            matlab.depfun.internal.cacheExist();
            matlab.depfun.internal.cacheWhich();
            matlab.depfun.internal.cacheMtree();
            
            % create a graph based on File and Level0_Use_Graph tables
            [graph, file2Vertex] = obj.createGraphAndAddEdges('Level0_Use_Graph');
        end

        function graph = getClosure(obj, component, target) %#ok<INUSD>
        % Return full closure
        % graph = getClosure(obj [,component] [,target])

            % create a graph based on File and Proxy_Closure tables
            graph = obj.createGraphAndAddEdges('Proxy_Closure');
        end

        function fileList = getFile(obj, component, target) %#ok<INUSD>
        % fileList = getFile(obj [, component] [, target])

            obj.SqlDBConnObj.doSql('SELECT ID, Path from File;');
            % bulk select
            rawList = obj.SqlDBConnObj.fetchRows();
            num_files = numel(rawList);
            % pre-allocation for the struct array
            fileList(num_files).fileID = [];
            fileList(num_files).path = '';
            for i = 1:num_files
                fileList(i).fileID = rawList{i}{1};
                if matlab.depfun.internal.PathNormalizer.isfullpath(rawList{i}{2})
                    fileList(i).path = rawList{i}{2};
                else
                    fileList(i).path = [strrep(obj.MatlabRoot,obj.FileSep,'/') '/' rawList{i}{2}];
                end
            end
        end

        function tf = requires(obj, client, service)
        % Does the client require the service? Client or service may be a 
        % "set" -- the other argument must be a scalar. Data type: numeric
        % IDs or string file names.

            if iscell(client) && iscell(service)
                error(message('MATLAB:depfun:req:DuplicateArgType', ...
                              class(client), 1, 2, class(client)))
            end

            if isnumeric(client)
                clientID = client;
            else
                clientID = lookupPathID(obj, client);
            end
            if isnumeric(service)
                serviceID = service;
            else
                serviceID = lookupPathID(obj, service);
            end

            if numel(serviceID) > 1
                serviceSet = sprintf('%d,', serviceID);
                serviceSet(end) = []; % Chop off trailing comma
                q = sprintf(['SELECT Dependency FROM Proxy_Closure ' ...
                             'WHERE Client = %d AND Dependency IN (%s)'], ...
                            clientID, serviceSet);
                targetID = serviceSet;
            else
                clientSet = sprintf('%d,', clientID);
                clientSet(end) = []; % Chop off trailing comma
                q = sprintf(['SELECT Dependency FROM Proxy_Closure ' ...
                             'WHERE Client IN (%s) AND Dependency = %d'], ...
                            clientSet, serviceID);
                targetID = serviceID;
            end
            obj.SqlDBConnObj.doSql(q);
            inClosure = cellfun(@(r)r{1}, obj.SqlDBConnObj.fetchRows);
            tf = ismember(targetID, inClosure);
        end

        function [list, notFoundList] = requirements(obj, files)
            if ~iscell(files)
                files = { files };
            end
            
            % G1135834: Workaround for the BIBI issue in Bsignal.
            % Clients are always m-files. No dependencies are recorded
            % under p-files. Thus, query m-files corresponding to p-files.
            pfileIdx = ~cellfun('isempty', regexp(files, '\.p$'));
            mFiles = regexprep(files(pfileIdx), '\.p$', '.m');
            files = unique([files mFiles]);
            
            % convert to SQL-friendly canonical path relative to matlabroot
            normalized_path = matlab.depfun.internal.PathNormalizer.normalizeFiles(files, true);
            notFoundList = struct([]);

            % g1207598 ssegench
            % Create a couple temp tables to hold results
            % Table: tempPathList
            %    Holds the initial list of paths. 
            %    This table is used twice.
            %     (1) Populate tempFileList with the file ids for the initial set of files
            %     (2) Identiy which of the initial set of files do not have ids (not in the DB)
            % Table: tempFileList
            %    Holds the list of file ids of dependent files
            %    This table is populated in 4 steps
            %     (1) Add the file ids for the initial set of files passed into 
            %         this function (requirements) 
            %     (2) Add any file ids that are proxies for files already in this table
            %     (3) Add the dependenencies for the files already in in this table
            %     (4) Add the principals for any proxies that are in this table
            %    At this point, the table contains a non-unique list of all the dependent 
            %     files for the initial list of paths, including the file ids (if they exist)
            %     for the initial list. The unique list of attributes for these files can now 
            %     be retrieved from the database with a single select statement.
            % The benefit to this approach is two fold. 
            %   - It eliminates a significant amount of marshaling of data back and forth between 
            %     MATLAB and the database. We don't need to convert a cell array of cell arrays of ints 
            %     into an array, only to iterate over that array, passing those ints back 
            %     into the database.
            %   - It allows the attributes for the files to be retrieved in a single select 
            %     statement. The previous implementation iterated over a list and retrived the 
            %     dependencies (with their attributes) for each file. If there were a lot of 
            %     overlap in the dependencies, the process would retrieve the same file multiple 
            %     times. 
            tempPathTableName = 'tempPathList';
            createTempTable(obj, tempPathTableName, {'path TEXT'});
            tempPathTableDrop = onCleanup(@() obj.SqlDBConnObj.doSql(['DROP TABLE ' tempPathTableName ';']));
            
            tempFileTableName = 'tempFileList';
            createTempTable(obj, tempFileTableName, {'id int'});
            tempFileTableDrop = onCleanup(@() obj.SqlDBConnObj.doSql(['DROP TABLE ' tempFileTableName ';'])); 
            
            obj.SqlDBConnObj.doSql([...
                'CREATE INDEX Temp_File_Index ON ' ...
                 tempFileTableName '(id)']);
            
             
            %put the path list into the temp table
            % sqlite has a limit (500) on the number of terms in the insert
            maxInsertCount = 500;
            if(numel(normalized_path) <=maxInsertCount)
                pathInsertStmt = sprintf( ...
                    ['INSERT INTO ' tempPathTableName ...
                    ' (path)' ...
                    ' VALUES (''%s'');'], strjoin(normalized_path, '''), ('''));
                obj.SqlDBConnObj.doSql(pathInsertStmt);
            else
               % insert in batches of maxInsertCount in size 
               startIndex = 1;
               endIndex = maxInsertCount;
               lastBatch = false; 
               while true
                   if(endIndex < numel(normalized_path))
                        tmpPath = normalized_path(startIndex : endIndex);
                   else 
                        tmpPath = normalized_path(startIndex : end);
                        lastBatch = true;
                   end
                   pathInsertStmt = sprintf( ...
                    ['INSERT INTO ' tempPathTableName ...
                    ' (path)' ...
                    ' VALUES (''%s'');'], strjoin(tmpPath, '''), ('''));
                    obj.SqlDBConnObj.doSql(pathInsertStmt);
                    
                    if(lastBatch)
                        break;
                    end
                    
                    startIndex = startIndex + maxInsertCount;
                    endIndex = endIndex + maxInsertCount;
               end
                
            end
            
            % populate the temp id table with the ids that exist for the paths
            idInsertStmt = ['INSERT INTO ' tempFileTableName ...
                ' (id)' ...
                ' SELECT ID FROM File a, ' tempPathTableName ' b' ...
                ' WHERE a.path = b.path;'];
            obj.SqlDBConnObj.doSql(idInsertStmt);
            
            % add to the id table any proxies
             idInsertStmt = ['INSERT INTO ' tempFileTableName ...
                ' (id)' ...
                ' SELECT Proxy FROM Proxy_Principal a, ' tempFileTableName ' b' ...
                ' WHERE a.Principal = b.id;'];
            obj.SqlDBConnObj.doSql(idInsertStmt);

            % get the list of not Found Files
            
            obj.SqlDBConnObj.doSql(['SELECT path ' ...
                             ' FROM ' tempPathTableName ' a' ...
                             ' WHERE not exists' ...
                                 ' (SELECT 1 FROM File b' ...
                                 '  WHERE a.path = b.Path);']);
            notFoundFiles = obj.SqlDBConnObj.fetchRows();
           
            for i = 1:numel(notFoundFiles)
                % notFoundFiles has the normalized path
                % need to put the original file in the list
                if ~isempty(char(notFoundFiles{i}))
                    notFound = files{strcmp(notFoundFiles{i}, normalized_path)};
                    notFoundList(end+1).name = 'N/A'; %#ok<AGROW>
                    notFoundList(end).type = 'N/A';
                    notFoundList(end).path = strrep(notFound, obj.FileSep, '/');
                    notFoundList(end).language = 'N/A';
                end
            end
            
            % Back to the dependencies.
            % Add all of them to the table.
             idInsertStmt = ['INSERT INTO ' tempFileTableName ...
                ' (id)' ...
                ' SELECT Dependency ' ...
                             'FROM Proxy_Closure '  ...
                             'WHERE exists (select 1 from ' tempFileTableName ' b ' ...
                             'Where Proxy_Closure.Client = b.id);'];
            obj.SqlDBConnObj.doSql(idInsertStmt);
           
            % add the principals
            idInsertStmt = ['INSERT INTO ' tempFileTableName ...
                ' (id)' ...
                ' SELECT Principal ' ...
                             ' FROM Proxy_Principal '  ...
                             ' WHERE exists (select 1 from ' tempFileTableName ' b ' ...
                             ' Where Proxy_Principal.Proxy = b.id);'];
            obj.SqlDBConnObj.doSql(idInsertStmt);            
                 
            % The tempFileTable now contains the list of all the dependent files.
            % One query to select attributes (symbol, type, etc.) for the unique list.
            
            % The below constants represent the order of columns in the select statement below.
            % Update these appropriately if the select statement changes.
            symbolCol = 1;
            typeCol = 2;
            pathCol = 3;
            languageCol = 4;
            
            obj.SqlDBConnObj.doSql(['SELECT Symbol, Type, Path, Language ' ...
                             ' FROM File  WHERE exists (select 1 from ' tempFileTableName ' b ' ...
                             ' Where File.Id = b.id);']);
                
            fileInfo = obj.SqlDBConnObj.fetchRows();
            
            
            % build the trace list below
            total_num_dep = length(fileInfo);

            if ~isempty(fileInfo)
                if isempty(obj.ID2Language)
                    cacheLanguageTable(obj);
                end
            end
            
            % pre-allocation for the dependency list
            if total_num_dep > 0
                list(total_num_dep).name = '';
                list(total_num_dep).type = '';
                list(total_num_dep).path = '';
                list(total_num_dep).language = '';                
            else
                list = struct([]);
            end
            
            for i = 1:total_num_dep
                % convert typeID and langID to string
                type = char(matlab.depfun.internal.MatlabType(fileInfo{i}{typeCol}));                
                lang = obj.ID2Language(fileInfo{i}{languageCol});

                % build trace list
                list(i).name = fileInfo{i}{symbolCol};
                list(i).type = type;
                if matlab.depfun.internal.PathNormalizer.isfullpath(fileInfo{i}{pathCol})
                    list(i).path = fileInfo{i}{pathCol};
                else
                    list(i).path = [strrep(obj.MatlabRoot, ...
                                    obj.FileSep,'/') '/' fileInfo{i}{pathCol}];
                end
                list(i).language = lang;
            end
            
            % combine DepList and NotFoundList
            % Files on the MatlabFile list are valid existing files based on the
            % WHICH result in PickOutUserFiles() in Completion.m, so they
            % should be on the return list, though they might not be in the
            % call closure table. (For example, files on the Inclusion list 
            % are often not found in the call closure table.)
            list = [list notFoundList];
        end
        
        function cList = requiredComponents(obj, files)
        % Returns a list of required components of given files.
        
            if ~iscell(files)
                files = { files };
            end
            
            % convert to canonical path relative to matlabroot
            normalized_path = matlab.depfun.internal.PathNormalizer.normalizeFiles(files, true);
            num_files = numel(normalized_path);
            cList = cell(1,0); % For UNION
            
            % SQLite cannot handle too many terms in compound SELECT.
            % SQLITE_MAX_COMPOUND_SELECT is defined as 500 by default.            
            group_size = 256;
            current_group_size = group_size;
            
            singleQuery = [ ...
                'SELECT Required_Components.Name ' ...
                'FROM File, Required_Components, File_Components ' ... 
                'WHERE File.Path = ''%s'' ' ...
                '  AND File.ID = File_Components.File ' ...
                '  AND File_Components.Component = Required_Components.ID '];
            
            count = 0;
            while count < num_files
                start_idx = count + 1;
                end_idx = count + group_size;
                if end_idx > num_files
                    end_idx = num_files;
                    current_group_size = end_idx - start_idx + 1;
                end
                                
                % Get many file IDs with one query
                query = [ singleQuery ...
                          repmat(['UNION ALL ' singleQuery], ...
                                 1, current_group_size-1) ';'];
                query = sprintf(query, normalized_path{start_idx:end_idx});
                obj.SqlDBConnObj.doSql(query);
                depComp = decell(obj.SqlDBConnObj.fetchRows())';
                if ~isempty(depComp)
                    cList = union(cList, depComp);
                end

                count = count + current_group_size;
            end
        end
        
        function result = getflattenGraph(obj, request)
        % retrieve file list and level-0 call closure from the database
            switch request
                case 'file'
                    obj.SqlDBConnObj.doSql('SELECT ID, Path FROM File ORDER BY ID ASC;');
                    tmp = obj.SqlDBConnObj.fetchRows();
                    ids = cell2mat(cellfun(@(r)r{1},tmp,'UniformOutput',false))';
                    paths = cellfun(@(r)r{2},tmp,'UniformOutput',false)';
                    result = {ids, paths};
                case 'type'
                    obj.SqlDBConnObj.doSql('SELECT Type FROM File ORDER BY ID ASC;');
                    result = cell2mat(decell(obj.SqlDBConnObj.fetchRows()));
                case 'symbol'
                    obj.SqlDBConnObj.doSql('SELECT Symbol FROM File ORDER BY ID ASC;');
                    result = decell(obj.SqlDBConnObj.fetchRows());
                case 'call_closure'            
                    obj.SqlDBConnObj.doSql('SELECT Client, Dependency FROM Level0_Use_Graph;');
                    tmp = obj.SqlDBConnObj.fetchRows();                    
                    client = cell2mat(cellfun(@(r)r{1},tmp,'UniformOutput',false))';
                    dependency = cell2mat(cellfun(@(r)r{2},tmp,'UniformOutput',false))';
                    result = [client dependency];
                otherwise
                    result = [];
            end
        end
        
        function recordFlattenGraph(obj, target, component, FileList, ...
                                    TypeID, Symbol, CallClosure, TClosure)
        % Write the flatten graph to the database
        
            obj.Target = target;
            obj.Component = component;
           
            % Insert file information to table File            
            % modifications for performance, g904544
            % (1) cache Language table
            cacheLanguageTable(obj);
            
            BuiltinClassID = int32(matlab.depfun.internal.MatlabType.BuiltinClass);
            BuiltinFunctionID = int32(matlab.depfun.internal.MatlabType.BuiltinFunction);
            
            MatlabID = obj.Language2ID('MATLAB');
            CppID = obj.Language2ID('CPP');
            
            % (2) use bulk insert
            % retrieve data from each vertex in the graph
            numFile = length(FileList);            
            FileID = 1:numFile;
            
            LanguageID = ones(1, numFile) .* MatlabID;
            BuiltinIdx = logical(TypeID==BuiltinClassID | TypeID==BuiltinFunctionID);
            LanguageID(BuiltinIdx) = CppID;
            
            % write to the database; insert the data at once
            obj.SqlDBConnObj.insert('File', 'ID', FileID, ...
                'Path', FileList, 'Language', LanguageID, ...
                'Type', TypeID, 'Symbol', Symbol);
            
            % insert level-0 call closure to Level0_Use_Graph
            obj.SqlDBConnObj.insert('Level0_Use_Graph', ...
                'Client', CallClosure(:,1), 'Dependency', CallClosure(:,2));
            
            % Insert full closure edges into Proxy_Closure table. Since this 
            % can be a long list, be careful about memory usage. Don't ask the
            % closure object for more memory than MATLAB can provide. Pay
            % attention to both the total amount of memory available and the
            % largest contiguous block.

            % To further increase performance, turn off journaling for this
            % series of SQL commands. Drawback: system failure during this 
            % time will result in a corrupt database. Saving throw:
            % the database isn't complete yet, and is just as unusable as if it
            % were corrupt.

            edgeCount = TClosure.EdgeCount;
            vID = feval(TClosure.VertexIdType,0); %#ok<NASGU>
            vIdData = whos('vID');
            edgeBytes = vIdData.bytes * 2;
            offset = 0;
            
            % Disable automatic transaction for pragma statement
            obj.SqlDBConnObj.doSql('PRAGMA journal_mode = OFF', false);

            % Make something up. Something reasonable. On non-Windows machines,
            % set this value so that we try to allocate enough memory to get
            % all the edges at once. This will likely succeed, but see the 
            % code in the the loop below that reduces this value if we get
            % an out of memory error.
            mem.MaxPossibleArrayBytes = edgeCount * edgeBytes * 4;

            while (offset < edgeCount)
                % How much memory is available? MATLAB is only willing to
                % answer this question on Windows.
                if obj.isPC
                    mem = memory;
                end
                % Take a chunk a little bit less than one-third the size 
                % of the largest available; we'll use the rest expanding 
                % the IDs to int64.
                maxArray = floor(mem.MaxPossibleArrayBytes / 3.14159);
                % How many edges fit into that chunk?
                maxEdges = maxArray / edgeBytes;

                % Get all the edges that will fit.
                try
                    edges = TClosure.EdgeRange(offset, maxEdges);
                    % Convert zero-based graph vertex IDs to one-based database 
                    % vertex IDs. Here's the first copy, and a possible widening.
                    edges = edges + 1;
                    if strcmp(computer('arch'),'win32')
                        edges = int32(edges);  % maxArray is 
                    else
                        edges = int64(edges);  % Database can't handle uint32.
                    end
                    % Write the edges into the database Proxy_Closure table.
                    % Making another copy.
                    obj.SqlDBConnObj.insert('Proxy_Closure', ...
                       'Client', edges(:,1), 'Dependency', edges(:,2));
                    % Hopefully return the memory to MATLAB for reuse in the 
                    % next iteration.
                    clear edges
                catch ex
                    % Was this an out of memory error? Reduce
                    % memory demand and try again.
                    if strcmp(ex.identifier, 'MATLAB:nomem')
                        if ~obj.isPC
                            mem.MaxPossibleArrayBytes = ... 
                                mem.MaxPossibleArrayBytes * .75;
                        end
                        if mem.MaxPossibleArrayBytes < edgeBytes
                            rethrow(ex);
                        end
                        continue;
                    else
                        % Not out of memory -- rethrow it.
                        rethrow(ex);
                    end
                end

                % Increment the starting offset (distance from the first
                % element).
                offset = offset + maxEdges;
            end

            % For performance, create a coverage index for Proxy_Closure.
            % This is expensive (it almost doubles the size of the database),
            % but it makes queries Proxy_Closure queries much faster.
            obj.SqlDBConnObj.doSql([...
                'CREATE INDEX Proxy_Closure_Index ON ' ...
                'Proxy_Closure(Client,Dependency)']);

            % We also spend a lot of time checking component membership, so
            % create a composite index table for the Component_Membership
            % table. In one test, this resulted in a 42x increase in speed.
            obj.SqlDBConnObj.doSql([...
                'CREATE INDEX Component_Membership_Index ON ' ...
                'Component_Membership(File,Component)']);
            
            % g1092063 - ssegench
            % whichNonBuiltin does a lookup on the file table using the
            % symbol column. Over networks (in particular in BaT against
            % the build environment) this query was particularly slow (4+ seconds). 
            % Adding an index to get rid of the full table scan improved
            % performance by a factor of 10.
            obj.SqlDBConnObj.doSql([...
                'CREATE INDEX File_Symbol_Index ON ' ...
                'File(Symbol)']);
            
            % ssegench
            % add index for looking up proxy by principal
             obj.SqlDBConnObj.doSql([...
                'CREATE INDEX Proxy_Principal_Principal_Index ON ' ...
                'Proxy_Principal(Principal)']);
            

            % Disable automatic transaction for pragma statement
            obj.SqlDBConnObj.doSql('PRAGMA journal_mode = ON', false);
        end
        
        function recordExclusion(obj, target, file)
        % save in Exclusion_List based on 'target' for 'file'
            related_tables = {'Exclusion_List', 'Exclude_File'};
            cellfun(@(t)obj.clearTable(t), related_tables);
        
            if ~ischar(target)
                % convert matlab.depfun.internal.Target to string
                target = matlab.depfun.internal.Target.str(target);
            end
            
            obj.SqlDBConnObj.doSql(sprintf('SELECT ID FROM Target WHERE Name = ''%s'';', target));
            targetID = obj.fetchNonEmptyRow();
            
            obj.SqlDBConnObj.insert('Exclude_File', 'Path', file);
            
            file = matlab.depfun.internal.PathNormalizer.normalizeFiles(file, true);
            num_file = numel(file);
            for i = 1:num_file              
                obj.SqlDBConnObj.doSql(sprintf(...
                    'SELECT ID from Exclude_File where Path = ''%s'';', ...
                    file{i}));

                fileID = obj.SqlDBConnObj.fetchRow();                

                % Insert the file into the Exclude_File table if necessary
                if isempty(fileID)
                    obj.SqlDBConnObj.doSql(sprintf(...
                        'INSERT INTO Exclude_File (Path) VALUES (''%s'');',...
                        file{i}));
                    
                    obj.SqlDBConnObj.doSql(sprintf(...
                        'SELECT ID FROM Exclude_File WHERE Path = ''%s'';',...
                        file{i}));

                    fileID = obj.SqlDBConnObj.fetchRow();
                end

                obj.SqlDBConnObj.doSql(sprintf(...
          'INSERT INTO Exclusion_List (Target, File) VALUES (%d, %d);', ...
                    targetID, fileID));
            end
        end
        
        function name = getBuiltinModuleName(obj, cIdx)
        % Retrieve the names of all known builtin modules 
        % defined by the given component.
        
            sql = sprintf(['SELECT Toolbox_Builtin_Module.Name ' ...
                'FROM Toolbox_Builtin_Module, Component_Builtin_Module ' ...
                'WHERE Component_Builtin_Module.Component = %d ' ...
                '  AND Toolbox_Builtin_Module.ID = Component_Builtin_Module.Module;'], ...
                cIdx);
            obj.SqlDBConnObj.doSql(sql);
            name = decell(obj.SqlDBConnObj.fetchRows);
        end
        
        function [componentID, serviceID] = sharedLicenseEntitlements(obj, part)
        % Do any of the given parts enable a shared license?
        % Return the IDs of those components which the parts enable, and
        % the IDs of the services enabled within those components.
            
            componentID = int64([]);
            serviceID = int64([]);
            if isempty(part), return; end
            
            % Must remove root of MathWorks functions or paths won't match.
            % Database stores root-unbound paths.
            part = matlab.depfun.internal.PathNormalizer.normalizeFiles(part, true);

            % SQLite has a 1000-operator limit (well, technically, the
            % expression tree can't be deeper than 1000 levels), so limit
            % query length.
            maxFiles = 200;
            partLen = numel(part);
            if iscell(part)
                startRange = 1; endRange = min(partLen,maxFiles);
                while startRange < partLen
                    subList = part(startRange:endRange);
                    [cList, sList] = querySharedLicenseComponents(subList, ...
                                                         obj.SqlDBConnObj);

                    componentID = [componentID cList];   %#ok can't prealloc
                    serviceID = [serviceID sList]; %#ok<AGROW>

                    % Move the range end points
                    startRange = endRange + 1;
                    endRange = min(endRange + maxFiles, partLen);
                end
            else
                [componentID, serviceID] = querySharedLicenseComponents(...
                                   part, obj.SqlDBConnObj);
            end

            componentID = unique(componentID, 'stable');

            function [componentList, serviceList] = ...
                    querySharedLicenseComponents(partList, db)
                % Construct an OR-list (a disjunction) of part path names.
                if iscell(partList)
                    filePathPredicate = ['File.Path =''' partList{1} ''''];
                    if numel(partList) > 1
                        filePathPredicate = ['(' filePathPredicate ...
                       sprintf(' OR File.Path=''%s''', partList{2:end}) ')' ];
                    end
                else
                    filePathPredicate = ['File.Path = ''' partList '''' ];
                end

                % TODO: Unify these two queries. This is inefficient.

                % SQL query to determine which of the input parts are
                % authorized client functions.
                q = [...
'SELECT File.ID FROM Authorized_Client_Functions,File ' ...
'WHERE ' filePathPredicate ' ' ...
'AND Authorized_Client_Functions.File = File.ID'];
                db.doSql(q);
                result = db.fetchRows;
                serviceList = cellfun(@(r)r{1}, result);
                    
                % SQL query to extract IDs of all components
                % which share functions with any authorized functions in the 
                % input list. (That's a mouthful.)

                q = [...
  'SELECT DISTINCT Component_License.Component ' ...
  'FROM File,Shared_Functions,Shared_License_Client,License,' ...
  '     Shared_License_Provider,Authorized_Client_Functions, ' ...
  '     Component_License ' ...
  'WHERE ' filePathPredicate ' ' ...
  'AND Authorized_Client_Functions.File = File.ID ' ...
  'AND Shared_Functions.Client = Authorized_Client_Functions.Client ' ...
  'AND Shared_License_Provider.ID = Shared_Functions.Provider ' ...
  'AND License.ID = Shared_License_Provider.Feature ' ...
  'AND Component_License.License = License.ID' ...
                ];
                db.doSql(q);
                result = db.fetchRows;
                componentList = cellfun(@(r)r{1}, result);
            end
        end

        function mergeLicenseData(obj, otherDD, target) %#ok<INUSD>
        % Merge the shared license data from otherDD into this one. 

            % Validate inputs
            narginchk(2,3);
            if ~isa(otherDD,class(obj))
                error(message('MATLAB:depfun:req:InvalidInputType', ...
                    2, class(otherDD), class(obj)))
            end
            
           
            function [licenseID, componentID] = mergeLicenseAndComponent(...
                                     db, licenseName, componentName, db_name)
                q = ['SELECT ID FROM License WHERE Name = ''' ...
                     licenseName ''''];
                db.doSql(q);
                licenseID = db.fetchRow; 
                
                % Did not find the license, insert it.
                if isempty(licenseID)
                    q = ['INSERT INTO License (Name) VALUES (''' ...
                         licenseName ''')'];
                    db.doSql(q);
                    db.doSql('SELECT last_insert_rowid()');
                    licenseID = db.fetchRow;
                end
                
                % Get the Component ID -- it must exist already.
                q = ['SELECT ID FROM Component WHERE Name = ''' ...
                     componentName '''' ];
                db.doSql(q);
                componentID = db.fetchRow;
                if isempty(componentID)
                    error(message('MATLAB:depfun:req:MissingComponent', ...
                        componentName, db_name))
                end
            end

            % Insert Protected_Locations that don't exist yet. May need to
            % insert license as well.)
            q = [ ...
            'SELECT License.Name, Protected_Location.Path, Component.Name ' ...
            'FROM License,Component,Protected_Location ' ...
            'WHERE Protected_Location.Feature = License.ID ' ...
            'AND Protected_Location.Component = Component.ID '];

            otherDD.SqlDBConnObj.doSql(q);

            % First protected location
            [licenseName, protectedLoc, componentName] = ...
                otherDD.SqlDBConnObj.fetchRow;

            while ~isempty(protectedLoc)
                % Retrieve / insert license, retrieve component ID
                [licID, protectedCID] = ...
                    mergeLicenseAndComponent(obj.SqlDBConnObj, ...
                                             licenseName, componentName,...
                                             obj.dbName);

                % Does the protected location exist?
                q = ['SELECT Component FROM Protected_Location ' ...
                     'WHERE Feature = ' num2str(licID) ' '...
                     'AND Component = ' num2str(protectedCID) ' '...
                     'AND Path = ''' protectedLoc ''''];
                obj.SqlDBConnObj.doSql(q);
                cID = obj.SqlDBConnObj.fetchRow;
                if isempty(cID)
                    q = ['INSERT INTO Protected_Location ' ...
                         '(Feature, Path, Component) VALUES (' ...
                         num2str(licID), ', ''' protectedLoc ''', ' ...
                         num2str(protectedCID) ')'];
                    obj.SqlDBConnObj.doSql(q);
                end
                
                % Next protected location
                [licenseName, protectedLoc, componentName] = ...
                    otherDD.SqlDBConnObj.fetchRow;
            end

            % Shared_License_Provider -- get ID, license name,
            % provider location and component name.
            q = [...
                'SELECT Shared_License_Provider.ID,License.Name, ' ...
                '       Shared_License_Provider.Path,Component.Name ' ...
                'FROM Shared_License_Provider,License,Component ' ...
                'WHERE License.ID = Shared_License_Provider.Feature ' ...
                'AND Component.ID = Shared_License_Provider.Component'];
            otherDD.SqlDBConnObj.doSql(q);

            % Insert Shared_License_Providers that don't exist yet (may
            % also need to insert Component and License)
            providerMap = containers.Map('KeyType', 'int32', ...
                                         'ValueType', 'int32');
            [providerID, licenseName, providerPth, componentName] = ...
                otherDD.SqlDBConnObj.fetchRow;
            while ~isempty(providerID)
                providerPth = matlab.depfun.internal.PathNormalizer.normalizeFile( ...
                    providerPth, true);
                
                [licID, providerCID] = ...
                    mergeLicenseAndComponent(obj.SqlDBConnObj, ...
                                             licenseName, componentName,...
                                             obj.dbName);

                % Look for the provider
                q = ['SELECT ID FROM Shared_License_Provider ' ...
                     'WHERE Feature = ' num2str(licID) ' '...
                     'AND Component = ' num2str(providerCID) ' ' ...
                     'AND Path = ''' providerPth ''''];
                obj.SqlDBConnObj.doSql(q);
                pID = obj.SqlDBConnObj.fetchRow;
                if isempty(pID)
                    q = ['INSERT INTO Shared_License_Provider ' ...
                         '(Feature, Path, Component) VALUES (' ...
                         num2str(licID), ', ''' providerPth ''', ' ...
                         num2str(providerCID) ')'];
                    obj.SqlDBConnObj.doSql(q);
                    obj.SqlDBConnObj.doSql('SELECT last_insert_rowid()');
                    pID = obj.SqlDBConnObj.fetchRow;                    
                end
                providerMap(providerID) = pID;
                
                % Get the next provider              
                [providerID, licenseName, providerPth, componentName] = ...
                    otherDD.SqlDBConnObj.fetchRow;
            end
            
            clear tDB_close
            
            % Shared_License_Client
            q = [...
                'SELECT Shared_License_Client.ID,'...
                '       Shared_License_Client.Name, ' ...
                '       Shared_License_Client.Path,Component.Name ' ...
                'FROM Shared_License_Client,Component ' ...
                'WHERE Component.ID = Shared_License_Client.Component'];
            otherDD.SqlDBConnObj.doSql(q);
           
            % Insert Shared_License_Clients that don't exist yet 
            clientMap = containers.Map('KeyType', 'int32', ...
                                         'ValueType', 'int32');
            [clientID, clientName, clientPth, componentName] = ...
                otherDD.SqlDBConnObj.fetchRow;
            
            while ~isempty(clientID)
                clientPth = matlab.depfun.internal.PathNormalizer.normalizeFile( ...
                    clientPth, true);
                % Get the Component ID
                q = ['SELECT ID FROM Component WHERE Name = ''' ...
                     componentName '''' ];
                obj.SqlDBConnObj.doSql(q);
                clientCID = obj.SqlDBConnObj.fetchRow;
                if isempty(clientCID)
                    error(message('MATLAB:depfun:req:MissingComponent', ...
                        obj.dbName, componentName))
                end
                
                % Look for the Shared_License_Client
                q = ['SELECT ID FROM Shared_License_Client ' ...
                     'WHERE Name = ''' clientName ''' ' ...
                     'AND Path = ''' clientPth ''' ' ...
                     'AND Component = ' num2str(clientCID) ];
                obj.SqlDBConnObj.doSql(q);
                cID = obj.SqlDBConnObj.fetchRow;
                if isempty(cID)
                    q = ['INSERT INTO Shared_License_Client ' ...
                         '(Name, Path, Component) VALUES (''' ...
                         clientName ''', ''' clientPth ''', ' ...
                         num2str(clientCID) ')'];
                    obj.SqlDBConnObj.doSql(q);                   
                    obj.SqlDBConnObj.doSql('SELECT last_insert_rowid()');
                    cID = obj.SqlDBConnObj.fetchRow;
                end
                clientMap(clientID) = cID;
                [clientID, clientName, clientPth, componentName] = ...
                    otherDD.SqlDBConnObj.fetchRow;                
            end
            
            % Authorized_Client_Functions
            q = ['SELECT File.Path,Authorized_Client_Functions.Client ' ...
                 'FROM File,Authorized_Client_Functions ' ...
                 'WHERE File.ID = Authorized_Client_Functions.File'];
            otherDD.SqlDBConnObj.doSql(q);
            
            [file, client] = otherDD.SqlDBConnObj.fetchRow;
            while ~isempty(file)
                file = matlab.depfun.internal.PathNormalizer.normalizeFile( ...
                    file, true);
                q = ['SELECT ID FROM File WHERE Path = ''' file ''''];
                obj.SqlDBConnObj.doSql(q);
                fileID = obj.SqlDBConnObj.fetchRow;
                
                if isempty(fileID)
                    error(message('MATLAB:depfun:req:MissingFile', ...
                        file, obj.dbName))
                end
                
                if ~isKey(clientMap, client)
                    error(message(...
                        'MATLAB:depfun:req:InternalBadSharedLicenseClientID',...
                         client))
                end
                
                q = ['INSERT INTO Authorized_Client_Functions ' ...
                     '(File, Client) VALUES (' num2str(fileID) ',' ...
                     num2str(clientMap(client)) ')'];
                obj.SqlDBConnObj.doSql(q);
                
                [file, client] = otherDD.SqlDBConnObj.fetchRow;                
            end
            
            % Shared_Functions
            q = ['SELECT File.Path,Shared_Functions.Client,' ...
                 '       Shared_Functions.Provider ' ...
                 'FROM File,Shared_Functions ' ...
                 'WHERE File.ID = Shared_Functions.File'];
            otherDD.SqlDBConnObj.doSql(q);
            
            [file, client, provider] = otherDD.SqlDBConnObj.fetchRow;
            while ~isempty(file)
                q = ['SELECT ID FROM File WHERE Path = ''' file ''''];
                obj.SqlDBConnObj.doSql(q);
                fileID = obj.SqlDBConnObj.fetchRow;
                
                if isempty(fileID)
                    error(message('MATLAB:depfun:req:MissingFile', ...
                        file, obj.dbName))
                end
                
                if ~isKey(clientMap, client)
                    error(message(...
                        'MATLAB:depfun:req:InternalBadSharedLicenseClientID',...
                         client))
                end
                
                if ~isKey(providerMap, provider)
                    error(message(...
                        'MATLAB:depfun:req:InternalBadSharedLicenseProviderID',...
                         client))
                end
                
                q = ['INSERT INTO Shared_Functions (File,Client,Provider) ' ...
                     'VALUES (' num2str(fileID) ',' ...
                     num2str(clientMap(client)) ',' ...
                     num2str(providerMap(provider)) ')'];
                obj.SqlDBConnObj.doSql(q);               
                
                [file, client, provider] = otherDD.SqlDBConnObj.fetchRow;
                
            end
        end

        function mergeComponentBuiltinModuleTable(obj, otherDD)
        % Merge the Component_Builtin_Module tables in obj and otherDD,
        % given the component name of otherDD is cname.
            
            % Find the component ID of the source database
            [~, cIdx] = otherDD.getComponentMembership();
            cIdx = unique(cIdx);

            if ~isempty(cIdx)
                if ~isscalar(cIdx)
                    error(['Detected multiple components. ' ...
                       'All the files in the Component_Membership table ' ...
                       'should belong to the same component in individual ' ...
                       'database.']);
                end
        
                % Find built-ins registered by component cname
                builtinModName = otherDD.getBuiltinModuleName(cIdx);

                if ~isempty(builtinModName)
                    % Find the component location in the source database
                    cptInfo = otherDD.getComponentInfo(cIdx);
                    if length(cptInfo) ~= 1
                        error(['Component ID ' cIdx ' should be mapped to' ...
                               'one and only one component.']);
                    end
                    
                    % Find the new component ID in the consolidated database
                    obj.SqlDBConnObj.doSql(sprintf( ...
                            ['SELECT ID FROM Component ' ...
                             'WHERE Location = ''%s'';'], cptInfo.location));
                    componentID = obj.SqlDBConnObj.fetchRow();
                    if isempty(componentID)
                        error(['Component ' cptInfo.name ' is not on record.']);
                    end

                    for k = 1:numel(builtinModName)
                        % Find the new module ID in the consolidated database
                        obj.SqlDBConnObj.doSql(sprintf( ...
                            ['SELECT ID FROM Toolbox_Builtin_Module ' ...
                             'WHERE Name = ''%s'';'], builtinModName{k}));
                        builtinModuleID = obj.SqlDBConnObj.fetchRow();
                        if isempty(builtinModuleID)
                            obj.SqlDBConnObj.doSql( sprintf( ...
                                ['INSERT INTO Toolbox_Builtin_Module (Name) ' ...
                                 'VALUES (''%s'');'], builtinModName{k}));
                            obj.SqlDBConnObj.doSql(sprintf( ...
                            ['SELECT ID FROM Toolbox_Builtin_Module ' ...
                             'WHERE Name = ''%s'';'], builtinModName{k}));
                            builtinModuleID = obj.SqlDBConnObj.fetchRow();
                        end

                        % Add new component builtin_module pair to 
                        % the consolidated database.
                        obj.SqlDBConnObj.doSql(sprintf( ...
                        ['INSERT INTO Component_Builtin_Module (Component, Module) ' ... 
                         'SELECT %d, %d ' ...
                         'WHERE NOT EXISTS '...
                         '    (SELECT 1 FROM Component_Builtin_Module ' ...
                         '     WHERE Component = %d AND Module = %d);'], ...
                        componentID, builtinModuleID, componentID, builtinModuleID));
                    end
                end
            end
        end
        
        function fileList = getExclusion(obj, target)
        % Read the exclusion_list for Target
        % straight forward read from the exclusion_list matched with the target
            fileList = {};
            obj.SqlDBConnObj.doSql('SELECT name FROM sqlite_master WHERE type=''table'' AND name=''Exclusion_List'';');
            if(strcmp(obj.SqlDBConnObj.fetchRow(),'Exclusion_List'))        
                if ~ischar(target)
                    % convert matlab.depfun.internal.Target to string
                    target = matlab.depfun.internal.Target.str(target);
                end
                obj.SqlDBConnObj.doSql(sprintf(...
                    'SELECT ID FROM Target WHERE Name = ''%s'';', target));
                targetID = obj.fetchNonEmptyRow();
        
                obj.SqlDBConnObj.doSql(sprintf([ ...
                    'SELECT Exclude_File.Path ' ...
                    'FROM Exclusion_List, Exclude_File ' ...
                    'WHERE Exclusion_List.File = Exclude_File.ID ' ...
                    'AND Exclusion_List.Target = %d;'], targetID));
                fileList = decell(obj.SqlDBConnObj.fetchRows());
            end
        end
        
        function recordInclusion(obj, target, component, file)
        % save in exclusion_list based on 'target' for 'file'
            
            related_tables = {'Inclusion_List', 'Include_File'};
            cellfun(@(t)obj.clearTable(t), related_tables);
            
            appendInclusion(obj, target, component, file);
        end
		
        function appendInclusion(obj, target, component, file)
        % save in Inclusion_List based on 'target' for 'file'
            
            if ~ischar(target)
                % convert matlab.depfun.internal.Target to string                
                target = matlab.depfun.internal.Target.str(target);
            end
            
            obj.SqlDBConnObj.doSql(sprintf('SELECT ID FROM Target WHERE Name = ''%s'';', target));
            targetID = obj.fetchNonEmptyRow();
            
            if ischar(component)
                componentID = getComponentID(obj, component);
            elseif isnumeric(component)
                componentID = component;
            end
            
            % Note that some files are required by more than one component                   
            file = matlab.depfun.internal.PathNormalizer.normalizeFiles(file, true);
            num_file = numel(file);
            
       
            
            for i = 1:num_file
                obj.SqlDBConnObj.doSql(sprintf('SELECT ID from Include_File where Path = ''%s'';', file{i}));
                fileID = obj.SqlDBConnObj.fetchRow();
                
                if isempty(fileID)
                    obj.SqlDBConnObj.doSql(sprintf('INSERT INTO Include_File (Path) VALUES (''%s'');', file{i}));
                    
                    obj.SqlDBConnObj.doSql(sprintf('SELECT ID from Include_File where Path = ''%s'';', file{i}));
                    fileID = obj.SqlDBConnObj.fetchRow();
                end
                
                obj.SqlDBConnObj.doSql(sprintf(...
                    'INSERT INTO Inclusion_List (Component, Target, File) VALUES (%d, %d, %d);', ...
                    componentID, targetID, fileID)); 
            end
        end
                
        function fileList = getInclusion(obj, target, component)
        % Read the Inclusion_List for the given component and target
        % straight forward read from the Inclusion_List 
            fileList = {};
            obj.SqlDBConnObj.doSql('SELECT name FROM sqlite_master WHERE type=''table'' AND name=''Inclusion_List'';');
            if(strcmp(obj.SqlDBConnObj.fetchRow(),'Inclusion_List'))        
                if ~ischar(target)
                    % convert matlab.depfun.internal.Target to string
                    target = matlab.depfun.internal.Target.str(target);
                end
                obj.SqlDBConnObj.doSql(sprintf('SELECT ID from Target where Name = ''%s'';', target));
                targetID = obj.SqlDBConnObj.fetchRow();
                
                if ischar(component)
                    componentID = getComponentID(obj, component);
                elseif isnumeric(component)
                    componentID = component;
                end
                
                if ~isempty(componentID) && ~isempty(targetID)
                    obj.SqlDBConnObj.doSql(sprintf([ ...
                        'SELECT Include_File.Path ' ...
                        'FROM Inclusion_List, Include_File ' ...
                        'WHERE Inclusion_List.File = Include_File.ID ' ...
                        'AND Inclusion_List.Target = %d ' ...
                        'AND Inclusion_List.Component = %d;'], targetID, componentID));
                    fileList = decell(obj.SqlDBConnObj.fetchRows());
                end
            end
        end
        
        function componentID = getComponentID(obj, component)
        % If component param is a string, look it up and retrieve corresponding numeric ID; 
        % generate error if not found.
        % If component param is numeric, use it.
        % If component param is some other type, generate error.
            if ischar(component)
                if isempty(component)
                    error(message('MATLAB:depfun:req:EmptyComponentName'))
                elseif strcmp(component, 'xpc')
                    % TODO: find an alternative to hard-coding this exception to the rule
                    % that the component name is equivalent to the name of the directory
                    % immediately under matlab/toolbox.
                    location = ['$MATLAB/toolbox/rtw/targets/xpc/' component];
                else
                    location = ['$MATLAB/' ... 
                        obj.Environment.RelativeToolboxRoot '/' component];
                end
                location = strrep(location, obj.FileSep, '/');
                % Replace single apostrophes with pairs of apostrophes so
                % that the SQL engine won't choke on the query.
                location = matlab.depfun.internal.PathNormalizer.processPathsForSql(location);
                obj.SqlDBConnObj.doSql( ...
                    sprintf('SELECT ID from Component where Location = ''%s'';', ...
                    location));
                % It's okay if the row is empty, so don't call fetchNonEmptyRow().
                componentID = obj.SqlDBConnObj.fetchRow();
            elseif isnumeric(component)
                componentID = component;
            else
                error(message('MATLAB:depfun:req:InvalidComponentNameType', ...
                              component))
            end
        end
        
        function componentID = componentOwningModule(obj, mname)
            obj.SqlDBConnObj.doSql(sprintf([ ...
                'SELECT Component_Builtin_Module.Component ' ...
                'FROM Component_Builtin_Module, Toolbox_Builtin_Module ' ...
                'WHERE Toolbox_Builtin_Module.Name = ''%s'' ' ...
                '  AND Toolbox_Builtin_Module.ID = Component_Builtin_Module.Module;'], ...
                mname));
            componentID = double(obj.SqlDBConnObj.fetchRow());            
        end
        
        function [componentList, indices] = getComponentList(obj)
            obj.SqlDBConnObj.doSql('SELECT ID, Name FROM Component;');
            tmp = obj.SqlDBConnObj.fetchRows();
            componentList = cellfun(@(r)r{2},tmp,'UniformOutput',false)';
            indices = cell2mat(cellfun(@(r)r{1},tmp,'UniformOutput',false))';
        end
        
        function recordComponentMembership(obj, files, component)
            obj.clearTable('Component_Membership');
            
            obj.appendComponentMembership(files, component);            
        end
        
        function appendComponentMembership(obj, files, component)

            if isempty(obj.ID2Language)
                cacheLanguageTable(obj);
            end

            if ischar(component)
                componentID = double(getComponentID(obj, component));
                if isempty(componentID)
                    error(message('MATLAB:depfun:req:EmptyComponentID'))
                end
            elseif isnumeric(component)
                componentID = double(component);
            end
            
            if isnumeric(files)
                files = unique(files);
                fileID = files;
                num_files = length(files);
            else
                files = matlab.depfun.internal.PathNormalizer.normalizeFiles(files, true);
                num_files = numel(files);
                fileID = zeros(num_files, 1);

                for k = 1:num_files
                    fileID(k) = obj.findOrInsertFile(files{k});
                end
                fileID(logical(fileID==0)) = [];
                fileID = unique(fileID);
                num_files = length(fileID);
            end
            
            % write to the database at once
            obj.SqlDBConnObj.insert('Component_Membership', ...
                'File', fileID, 'Component', ones(num_files,1).*componentID);
        end
        
        function [fileID, componentID] = getComponentMembership(obj)
            obj.SqlDBConnObj.doSql('SELECT File, Component FROM Component_Membership;');
            tmp = obj.SqlDBConnObj.fetchRows();
            fileID = cell2mat(cellfun(@(r)r{1},tmp,'UniformOutput',false))';
            componentID = cell2mat(cellfun(@(r)r{2},tmp,'UniformOutput',false))';
        end
        
        function protected = protectedByLicense(obj, parts)
        % Which of the parts are protected by a license? Those in a 
        % protected location!

            % Asking the database is expensive. There aren't that many
            % protected locations, so cache them in a map.
            % Lazy initialization of protected locations cache.
            if isempty(obj.protectedLocations)
                obj.protectedLocations = containers.Map('KeyType', 'char', ...
                                                    'ValueType', 'logical');
                q = 'SELECT Path FROM Protected_Location;';
                obj.SqlDBConnObj.doSql(q);
                ploc = cellfun(@(l)l{1},obj.SqlDBConnObj.fetchRows(), ...
                               'UniformOutput',false);
                for k=1:numel(ploc)
                    obj.protectedLocations(ploc{k}) = true;
                end
            end

            % Expand $MATLAB to the actual MATLABROOT
            ixf = matlab.depfun.internal.IxfVariables('/');
            locations = ixf.bind(keys(obj.protectedLocations));
            partLocations = cellfun(@(p)fileparts(p), parts, ...
                                    'UniformOutput', false);
            partLocations = strrep(partLocations,'\','/');
            numLocations = numel(locations);
            
            protected = false(1,numel(partLocations));
            
            % ssegench
            executableParts = cell2mat(cellfun(@(p)isExecutable(p), parts, ...
                                    'UniformOutput', false));
            for k=1:numel(parts)
                n = 1;
                found = false;
                
                % ssegench
                % only protect executable content
                if executableParts(k)
                    while (n <= numLocations && found == false)
                        found = ~isempty(strfind(partLocations{k}, locations{n}));
                        n = n + 1;
                    end
                end
                protected(k) = found;
            end
            
            
            
        end

        function [knownParts, componentID, fileID] = ...
                componentMembership(obj, parts)

            % convert to canonical path relative to matlabroot
            parts = matlab.depfun.internal.PathNormalizer.normalizeFiles(parts, true);
            num_parts = numel(parts);
            if num_parts == 0
                fileID = [];
                componentID = [];
                knownParts = {};
                return;
            end
            
            % Pre-allocation for performance
            % We are certain about the size because each file strictly 
            % belongs to one or none component.
            % If a file doesn't exist in the database, its query result 
            % consistents of 0 fileID and 0 componentID.
            % If a file exists in the database, its query result
            % consistents of one fileID and one componentID.            
            fileID = zeros(num_parts, 1);
            componentID = zeros(num_parts, 1);
            knownParts = containers.Map();
            
            % Batch queries together, because crossing the MCOS barrier is
            % expensive.
            bucketSize = 64;
            
            % Query structure:
            %
            %  SELECT ifnull(Component_Membership.Component,0)
            %  FROM ( < File Sub-Query > ) AS FID
            %  LEFT JOIN Component_Membership
            %  ON (FID.ID = Component_Membership.File)
            %
            % The File Sub-Query returns a numeric list: File IDs for files 
            % which exist in the database, and zero for those that don't.
            %
            % The LEFT JOIN ensures that the zeros propagate through the 
            % join condition -- files with ID 0 necessarily belong to no
            % component.
            selectFile = ['SELECT ifnull(max(File.ID),0) AS ID FROM File ' ...
                          'WHERE File.Path = ''%s''' ];
            unionFile = [ ' UNION ALL ' selectFile ];

            start = 1;
            while start <= num_parts
                bkt_start = start;
                bkt_end = bkt_start;
                subQuery = sprintf(selectFile, parts{start});
                start = start + 1;
                if start <= num_parts
                    stop = min(start + bucketSize - 2, num_parts);
                    bkt_end = stop;
                    subQuery = [ subQuery ... 
                                 sprintf(unionFile, parts{start:stop}) ]; %#ok
                    start = stop + 1;
                end
                query = [ ...
                    'SELECT FID.ID, ifnull(Component_Membership.Component,0) ' ...
                    'FROM ( ' subQuery ' ) AS FID ' ...
                    'LEFT JOIN Component_Membership ' ...
                    'ON (FID.ID = Component_Membership.File)' ];
                obj.SqlDBConnObj.doSql(query);
                cdata = obj.SqlDBConnObj.fetchRows();
                cdata = reshape(cell2mat([cdata{:}])', 2, [])';
                fileID(bkt_start:bkt_end) = cdata(:,1);
                componentID(bkt_start:bkt_end) = cdata(:,2);
            end
            
            idList = num2str(fileID(1));
            if numel(fileID) > 1
                idList = [idList sprintf(', %d', fileID(2:end))];
            end
            query = ['SELECT ID,Path FROM File WHERE ID IN (' idList ')'];
            obj.SqlDBConnObj.doSql(query);
            files = obj.SqlDBConnObj.fetchRows();            
            
            for n=1:numel(files)
                f = files{n};
                k = matlab.depfun.internal.PathNormalizer.denormalizeFiles(f{2});
                knownParts(k) = f{1};
            end        
        end
        
        function [componentID, orphanFiles] = ...
                                       checkComponentMembership(obj, files)
            % Get two flat lists containing file ID and component ID.
            [~,componentID,~] = componentMembership(obj,files);

            % Files that don't belong to any component 
            % have 0 as component ID.
            orphanFiles = files(~componentID);                        
        end
          
        function licenseInfo = getLicenseInfo(obj, componentID)
        % Map component IDs to license names, using the database.
        % The names appear in the output licenseInfo structure in the same
        % order as the component IDs in the input vector. The structure
        % has two fields: name (a string) and component (an integer ID).
        %
        % The componentID list must be a sorted set (the output, for example,
        % of UNIQUE). Note that componentID zero maps to license name ''.
            
            licenseInfo = struct();
            if numel(componentID) < 1, return; end

            if ~issorted(componentID)
                error(message(...
                    'MATLAB:depfun:req:InternalUnsortedComponentID'))
            end

            cIDStr = num2str(componentID(1));
            if numel(componentID) > 1
                cIDStr = [cIDStr sprintf(', %d', componentID(2:end))];
            end

            % May return more licenses than components, since a component
            % may be enabled by more than one license (all components with
            % shared licenses are enabled by at least two licenses).
            query = [ ...
              'SELECT Component_License.Component,License.name ' ...
              'FROM License,Component_License ' ...
              'WHERE License.ID = Component_License.License ' ...
              'AND Component_License.Component IN (' cIDStr ') ' ...
              'ORDER BY Component_License.Component'];

            obj.SqlDBConnObj.doSql(query);
            info = obj.SqlDBConnObj.fetchRows();

            licenseInfo = cellfun(...
                @(r)struct('name',r{2}, 'component', r{1}), info);

            if componentID(1) == 0
                z.name = '';
                z.component = 0;
                if isempty(licenseInfo) || licenseInfo(1).component ~= 0
                    licenseInfo = [z licenseInfo];
                else
                    licenseInfo(1) = z;
                end
            end
        end

        function componentInfo = getComponentInfo(obj, componentID, fields)
            if nargin < 3
                fields = {'name', 'location'};
            end

            % Retrieve component information from the database, i.e.,
            % name, location
            num_component = length(componentID);
            % pre-allocation
            for k=1:numel(fields)
                componentInfo(num_component).(fields{k}) = '';   %#ok
            end

            fStr = fields{1};
            if numel(fields) > 1
                fStr = [fStr sprintf(', %s', fields{2:end})];
            end

            query = sprintf('SELECT %s FROM Component WHERE ID = %%d', ...
                            fStr);

            for k = 1:num_component
                q = sprintf(query, componentID(k));
                obj.SqlDBConnObj.doSql(q);
                tmp = obj.SqlDBConnObj.fetchRows();
                if ~isempty(tmp)
                    tmp = tmp{1};
                    for n=1:numel(fields)
                        componentInfo(k).(fields{n}) = tmp{n};
                    end
                end
            end
        end

        function reclaimEmptySpace(obj)
        % Minimize the size of the database by rebuilding it. An expensive
        % operation.
            obj.SqlDBConnObj.doSql('VACUUM');   
        end
        
        function tf = isPrincipal(obj, files)
            if ~iscell(files)
                files = { files };
            end
            
            % convert to canonical path relative to matlabroot
            normalized_path = matlab.depfun.internal.PathNormalizer.normalizeFiles(files, true);
            num_files = numel(normalized_path);
            tf = false(num_files, 1);
            
            query = ['SELECT EXISTS ' ... 
                     ' (SELECT 1 ' ...                     
                     '  FROM Proxy_Principal, File ' ...
                     '  WHERE File.Path = ''%s'' ' ...
                     '    AND File.ID = Proxy_Principal.Principal);'];
            
            for k = 1:num_files
                obj.SqlDBConnObj.doSql(sprintf(query, normalized_path{k}));
                tf(k) = obj.SqlDBConnObj.fetchRow();
            end
        end
        
        function recordPrincipals(obj, proxy, principal)
        % Populate the Proxy_Principal table.
        % proxy contains the names or file IDs of proxies.
        % principal contains names or file IDs of principals.
        
            % Find file ID for the proxy
            if isnumeric(proxy)
                proxyID = proxy;
            elseif ischar(proxy)
                proxy_normalized = matlab.depfun.internal.PathNormalizer.normalizeFiles(proxy, true);
                proxyID = cell2mat(cellfun(@(p)obj.findOrInsertFile(p), ...
                          proxy_normalized, 'UniformOutput', false));
            else
                error(message('MATLAB:depfun:req:InvalidInputType', ...
                              1, class(proxy), 'a string or a number'));
            end

            % Find file ID for principals
            if isnumeric(principal)
                principalID = principal;
            elseif ischar(principal)
                principal_normalized = matlab.depfun.internal.PathNormalizer.normalizeFiles(principal, true);
                principalID = cell2mat(cellfun(@(p)obj.findOrInsertFile(p), ...
                              principal_normalized, 'UniformOutput', false));
            else
                error(message('MATLAB:depfun:req:InvalidInputType', ...
                              2, class(principal), 'cell or numeric array'));
            end

            % Record the proxy-principal pairs
            obj.SqlDBConnObj.insert('Proxy_Principal', ...
                             'Proxy', proxyID, 'Principal', principalID);
        end
        
        function result = getProxyPrincipal(obj)
            obj.SqlDBConnObj.doSql('SELECT Proxy, Principal FROM Proxy_Principal;');
            tmp = obj.SqlDBConnObj.fetchRows();
            proxy =  cell2mat(cellfun(@(r)r{1},tmp,'UniformOutput',false))';
            principal =  cell2mat(cellfun(@(r)r{2},tmp,'UniformOutput',false))';            
            result = [proxy principal];
        end
        
        function clearComponentDataTables(obj)
            componentTables = { 'Path_Item', 'Component_Path_Item', ...
                                'License', 'Component_License', ...
                                'Component',  ...
                                'Toolbox_Builtin_Module', ...
                                'Component_Builtin_Module' };        
            cellfun(@(t)obj.clearTable(t), componentTables);
        end
    end

    methods(Access = private)

        function id = lookupPathID(obj, files)
            files = matlab.depfun.internal.PathNormalizer.normalizeFiles(files, true);
            fileSelector = sprintf('Path = ''%s''', files{1});
            if numel(files) > 1
                fileSelector = [fileSelector ' ' ...
                                sprintf(' OR Path = ''%s''', files{:})];
            end

            obj.SqlDBConnObj.doSql(...
                sprintf('SELECT ID FROM File WHERE %s;', fileSelector));
            id = obj.SqlDBConnObj.fetchRow();
        end

        function [lang, type, sym] = getFileData(obj, pth)
            sym = '';
            [lang, type] = obj.fileClassifier.classify(pth);
            if strcmp(lang,'MATLAB')
                [~,sym] = fileparts(pth);
            end
            if isKey(obj.Language2ID, lang)
                lang = obj.Language2ID(lang);
            else
                error(message('MATLAB:depfun:req:InternalBadLanguage', ...
                              lang, obj.dbName))
            end
        end

        function id = findOrInsertFile(obj, pth)
            select = sprintf('SELECT ID from File where Path = ''%s'';', pth);
            obj.SqlDBConnObj.doSql(select);
            id = obj.SqlDBConnObj.fetchRow();
            if isempty(id)
                [lang, type, sym] = getFileData(obj, pth);
                q = sprintf(...
                    ['INSERT INTO File (Path, Language, Type, Symbol) ' ...
                     'VALUES (''%s'', %d, %d, ''%s'')'], pth, lang, ...
                    int32(type), sym);
                obj.SqlDBConnObj.doSql(q);
                obj.SqlDBConnObj.doSql(select);
                id = obj.SqlDBConnObj.fetchRow();
                if isempty(id)
                    op = sprintf('INSERT File: ''%s''', pth);
                    error(message('MATLAB:depfun:req:InternalDBFailure', ...
                                  op, obj.dbName))
                end
            end
        end

        function clearTable(obj, table)
        % Clear an existing table. For performance, drop and recreate
        % the table.
            obj.destroyTable(table);
            obj.createTable(table);
        end
        
        function createTempTable(obj, table, cols)
        % Create a temporary table
        % cols is a cellarray 
        % cols = {'id INT' 'path TEXT'} will yield a 2 column table
            query = ['CREATE TEMP TABLE ' table ' ( ' ...
                      strjoin(cols, ', ') ')'];
            obj.SqlDBConnObj.doSql(query);
          
        end
        
        function createTable(obj, table)
        % Create a table, using the column definitions in the tableData
        % map.
            if isKey(obj.tableData, table)
                cols = obj.tableData(table);
                query = ['CREATE TABLE ' table ' ( ' ...
                         strjoin(cols, ', ') ')'];
                obj.SqlDBConnObj.doSql(query);
            end
        end
        
        function clearSharedLicenseTables(obj)
        % Clear the tables containing shared license data
            tables = {'Protected_Location', ...
                      'Shared_License_Client', ...
                      'Authorized_Client_Functions', ...
                      'Shared_Functions', ...
                      'Shared_License_Provider'};
            cellfun(@(t)obj.clearTable(t), tables);
        end

        function clearFileTables(obj)
        % Clear the file table and all the tables that depend on it.
            fileTables = {'File', 'Proxy_Closure', 'Level0_Use_Graph'};
            cellfun(@(t)obj.clearTable(t), fileTables);
        end
        
        function clearComponentDependencyTables(obj)
        % Clear the file table and all the tables that depend on it.
            fileTables = {'Required_Components', 'File_Components'};
            cellfun(@(t)obj.clearTable(t), fileTables);
        end
        
        function destroyTable(obj, tablename)
        % Destroy an existing table. Don't try to destroy tables that don't
        % exist, since that makes SQLite angry.
            obj.SqlDBConnObj.doSql(['SELECT name FROM sqlite_master WHERE type=''table'' AND name=''' tablename ''';']);
            if(strcmp(obj.SqlDBConnObj.fetchRow(),tablename))
                obj.SqlDBConnObj.doSql(['DROP TABLE ' tablename ';']);
            end
        end
        
        function destroyAllTables(obj)
        % Destroy all known tables by applying the destroyTable method.
            tables = keys(obj.tableData);
            cellfun(@(t)obj.destroyTable(t), tables);         
        end

        function createTables(obj)
            % Create tables
            
            tables = keys(obj.tableData);
            cellfun(@(t)obj.createTable(t), tables);
            
            % Initialize tables
            
            % table Language(id, name).
            obj.SqlDBConnObj.doSql('INSERT INTO Language (Name) VALUES(''MATLAB'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Language (Name) VALUES(''CPP'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Language (Name) VALUES(''Java'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Language (Name) VALUES(''NET'');');
            obj.SqlDBConnObj.doSql('INSERT INTO Language (Name) VALUES(''Data'');');

            % table Symbol_Type(id, type)
            % consistent with types defined in matlab.depfun.internal.MatlabType
            allTypes = enumeration('matlab.depfun.internal.MatlabType');
            allTypes_char = arrayfun(@(t)char(t), allTypes, ...
                                     'UniformOutput', false);
            allTypes_int = int32(allTypes);            
            obj.SqlDBConnObj.insert('Symbol_Type', ...
                                    'Name', allTypes_char, ...
                                    'Value', allTypes_int);
            
            % table Proxy_Type(id, type)
            proxy_type = {...
                'MCOSClass','UDDClass','OOPSClass','BuiltinClass'};
            insert_cmd = ['INSERT INTO Proxy_Type (Type) ' ...
                          '  SELECT Symbol_Type.Value ' ...
                          '  FROM Symbol_Type ' ...
                          '  WHERE Symbol_Type.Name = ''proxy_type'';'];
            cellfun(@(p)obj.SqlDBConnObj.doSql( ...
                    regexprep(insert_cmd, 'proxy_type', p)), proxy_type);
            
            % table Target(id, name) -- same order as numerical values in
            % matlab.depfun.internal.Target.
            allTargets = arrayfun(@(t)char(t), ...
                           enumeration('matlab.depfun.internal.Target'),...
                           'UniformOutput',false);
            obj.SqlDBConnObj.insert('Target', 'Name', allTargets);
        end
        
        function cacheLanguageTable(obj)
            % initialize the map
            obj.Language2ID = containers.Map('KeyType', 'char', ...
                                             'ValueType', 'double');
            obj.ID2Language = containers.Map('KeyType', 'double', ...
                                             'ValueType', 'char');
            
            % load the table into the map
            obj.SqlDBConnObj.doSql('SELECT COUNT(*) from Language;');
            num_lang = obj.SqlDBConnObj.fetchRow();
            for k = 1:num_lang
                obj.SqlDBConnObj.doSql(...
                    sprintf('SELECT Name from Language where ID = %d;', k));
                Language = obj.SqlDBConnObj.fetchRow();
                obj.Language2ID(Language) = k;
                obj.ID2Language(k) = Language;
            end
        end
        
        function recordEdges(obj, graph, table)
            edges = graph.EdgeVectors;
            % convert vertexID to fileID using mapping if it exists
            if(~isempty(obj.Vertex2FileID))
                clientFID = obj.Vertex2FileID.values(num2cell(edges(:, 1)));
                dependencyFID = obj.Vertex2FileID.values(num2cell(edges(:, 2)));
                clientFID = [clientFID{:}];
                dependencyFID = [dependencyFID{:}];
            else
                clientFID = double(edges(:,1) + 1);
                dependencyFID = double(edges(:,2) + 1);
            end
            
            % insert the data at once
            obj.SqlDBConnObj.insert(table, ...
                'Client', clientFID, 'Dependency', dependencyFID);
        end
        
        function [graph, file2Vertex] = createGraphAndAddEdges(obj, table)
        % create a graph based on the File table
    
            % improvements for performance, g904544
            % (1) cache Language table
            if isempty(obj.ID2Language)
                cacheLanguageTable(obj);
            end
        
            % map from file path to vertex ID to be used to interact with
            % the graph outside of dependency depot
            file2Vertex = containers.Map('KeyType', 'char', ...
                                         'ValueType', 'uint64');
            % temporary map from file ID to vertex ID to read in edges 
            file2VertexID = containers.Map('KeyType', 'double', ...
                                           'ValueType', 'uint64');
                                       
            % (2) use bulk select for performance
            obj.SqlDBConnObj.doSql('SELECT ID, Path, Type, Symbol FROM File;');
            files = obj.SqlDBConnObj.fetchRows();
            num_files = numel(files);
            % if there were no files recorded in the File table, return an empty graph
            if(num_files == 0)
                graph = matlab.internal.container.graph.Graph('Directed', true);
                return
            end
            
            % preallocation
            fileID = zeros(num_files,1);
            sym(num_files).symbol = [];
         
            vertexID = 0;
            for i = 1:num_files
                fileID(i) = files{i}{1};
                Path = files{i}{2};
                TypeID = files{i}{3};
                Type = matlab.depfun.internal.MatlabType(TypeID);
                Symbol = files{i}{4};
                
                % unless the type is a built in, denormalize the path so it
                % contains the full path that WHICH would return
                if(~isBuiltin(Type))
                    Path = matlab.depfun.internal.PathNormalizer.denormalizeFiles(Path);
                end
                % create a symbol
                cur_sym = matlab.depfun.internal.MatlabSymbol(Symbol, Type, Path);
                % only create vertices for proxys and add principals to the
                % map for later use in recordProxyData
                if(isPrincipal(cur_sym))
                    obj.Principal2FileID(Path) = fileID(i);
                else
                    sym(vertexID + 1).symbol = cur_sym;
                    file2Vertex(Path) = vertexID;
                    file2VertexID(fileID(i)) = vertexID;
                    obj.Vertex2FileID(vertexID) = fileID(i);
                    vertexID = vertexID + 1;
                end
            end
            % get rid of the empty preallocated symbols
            sym = sym(1:length([sym.symbol]));
           
            % create a new graph
            graph = matlab.internal.container.graph.Graph('Directed', true);
            % add nodes to the graph
            addVertex(graph, sym);
              
            % add edges to the graph based on the specified table            
            obj.SqlDBConnObj.doSql(['SELECT Client, Dependency from ' table ';']);
            edges = obj.SqlDBConnObj.fetchRows();
            num_edges = numel(edges);
            clientFileID = zeros(num_edges,1);
            dependencyFileID = zeros(num_edges,1);
            for i = 1:num_edges
                % read in an edge
                clientFileID(i) = edges{i}{1};
                dependencyFileID(i) = edges{i}{2};
            end
            % convert from fileId to vertexId           
            clientVID = file2VertexID.values(num2cell(clientFileID));
            dependencyVID = file2VertexID.values(num2cell(dependencyFileID));
            
            % add the edge to the graph
            addEdge(graph, [clientVID{:}], [dependencyVID{:}]);          
        end
    end
end

% local helper function(s)
function output = decell(input)
    rows = numel(input);
    output = cell(rows,1);
    for i = 1:rows
        output{i} = input{i}{1};
    end
end

