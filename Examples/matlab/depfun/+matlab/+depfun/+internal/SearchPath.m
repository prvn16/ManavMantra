classdef SearchPath < handle
% SearchPath manages the source code search path for the requirements function.
    properties (Constant, Hidden)
        % When Components == AllComponents the path includes all the
        % directories needed for the given target.
        AllComponents = { '*' };
    end
    
    properties
        % A SearchPath is specific to a given target. The MCR and MATLAB 
        % targets, for example, have very different search paths.
        Target
        
        % Expect to find the information required to initialize the search 
        % path in this database. Note: database has architecture-specific
        % name.
        Database
            
        % Find the list of uncompilable toolboxes from the PCM database
        pcm_db

        % Is the path sorted?
        Sort = false;

        % What components (toolboxes) does the SearchPath span? '*' == all
        % of them.
        Components = matlab.depfun.internal.SearchPath.AllComponents;
        
        % Limit the MATLAB path to just these directories. The PathLimit
        % directories must be on the MATLAB path (extras cause no error,
        % but have no effect -- that is, if a PathLimit directory is not on
        % the path, it is not added). Preserve the order of the directories
        % on the MATLAB path -- ignore the order in which they appear in
        % the PathLimit list.
        PathLimit
        
    end

    properties (Dependent = true)
        % A string suitable for passing to MATLAB's PATH function. A read-only
        % property.
        PathString
        
        % How many items in the path string?
        PathCount
    end
    
    properties (SetAccess = private)
        % The list of search locations, in order. A cell array of strings.
        % PathString is computed from PathList.
        PathList
        
        % Class and package directories (those that start with + or @) are
        % never added to the path directly, so their contents cannot be
        % excluded by manipulating the path. Collect these directories in a
        % cell array while processing the configuration data.
        ExcludeList
    end

    properties (Access = private)
        % Path items may contain variables, $MATLAB for example, which need
        % to be expanded before the items can be used on the MATLAB path.
        Variables
        
        % The set functions need to behave differently when called from the
        % constructor.
        Constructed

        % The database only contains information about these targets
        KnownTargets
        
        % List of extra directories to be added to the PathList during
        % "assembly." A structure with two fields: atStart, atEnd, each of
        % which contains a cell array. 
        IncludePath
        
        % Use the database by default
        % If REQUIREMENTS_DATABASE is set to 0, then do not use database.
        useDB
        
        PathUtility
    end

    methods (Access = private)
        
        function r = find_dir(obj, d, mustExist)
        % Look for d (a directory) on the PathList. It must be there.
        % Return d's index on the PathList.
            r = 0;
            idx = strcmp(d, obj.PathList);
            if any(idx)
                r = find(idx);
            elseif mustExist
                error(message('MATLAB:depfun:req:NonExistSearchDir', d))
            end
        end

        function n = position(obj, directoryList)
        % Look for the directories in directoryList on the PathList. 
        % Return a vector of their locations on the list. Position 0 means
        % not on the list.
            n = cellfun(@(d)find_dir(obj, d, false), directoryList);
        end

        function remember_exclude_dirs(obj, exclude)
        % Search the exclude list for directories that cannot be put on the
        % path (class and package directories). Remember them by recording
        % them on the exclude list.
        
            function keepers = finder(string, pattern)
                found = strfind(string, pattern);
                keepers = ~cellfun('isempty', found);
            end
            
            % Paths in the database on all platforms are unified 
            % with forward slashes.
            % Find class directories
            cls = finder(exclude, '/@');
            % Find package directories
            pkg = finder(exclude, '/+');
            keep = cls | pkg;
            obj.ExcludeList = exclude(keep);
        end
        
        function removeUncompilableTbxFromPath(obj)
        % Remove uncompilable toolboxes from the path for MCR target.    
            
            if strcmpi(obj.Target, 'MCR')
                pm = matlab.depfun.internal.ProductComponentModuleNavigator(...
                                                               obj.pcm_db);

                % Extract the list of uncompilable toolboxes from the database.
                uncompilableTbxRoot = pm.getUncompilableTbxRoot();

                % Remove uncompilable toolbox directories and sub-directories
                % off the MATLAB path.
                pth = regexprep(obj.PathList, '[\/\\]', filesep);
                rmIdx = false(size(pth));
                for k = 1:numel(uncompilableTbxRoot)
                    rmIdx = rmIdx | obj.findDirAndItsSubDirsOnPath( ...
                                              pth, uncompilableTbxRoot{k});
                end

                if any(rmIdx)
                    obj.PathList(rmIdx) = [];
                end
            end
        end
        
        function assemble_path(obj, include, exclude)
        % Put the path together. Start with the MATLAB path, add the include
        % items and remove the exclude items.
            fs = filesep;
            pth = path;

            % Split the path into a cell array of strings. Use of pathsep
            % accomodates platform-specific path formatting.
            pth = regexp(pth, ['[^' pathsep ']+'], 'match');
            
            % Copy the orginal path, but canonicalize the file separators
            % to match the database, which leans towards Unix. origPath
            % helps filter and order path items from the database, so the
            % file separators must match.
            origPath = strrep(pth, fs, '/');
            
            % Limit the path, if PathLimit is not empty
            path_limit = obj.PathLimit;         
            
            if ~isempty(path_limit)
                % Determine if any of the path_limit items represent
                % partial paths beginning at the toolbox root. Split the
                % path_limit list into two -- tbx_path contains full paths
                % of path_limit items originating in matlab/toolbox, and
                % path_limit contains the remaining obj.PathLimit items
                % that do not.
                [tbx_path, path_limit] = realize_toolbox_path(path_limit); 
                
                % Include the children of any toolbox roots
                tbx_children = include_children(tbx_path);
                
                % Recompose the path_limit list to consist of full paths to
                % toolbox roots and their children and any remaining
                % original path limit directories.
                path_limit = [tbx_path tbx_children path_limit];
                path_limit = unique(path_limit, 'stable');  % No duplicates

                % Limit the PathLimit items to those that are already on the
                % MATLAB path. realized is a logical index indicating which
                % members of path_limit were found on the MATLAB path.
                [path_items, match] = realize_partial_path(path_limit);
                path_limit = path_items(match);
                
                % Expand the list of path_limit items to include any
                % subdirectories of the original list. Only include those
                % sub-directories which are already on the MATLAB path.
                path_limit = include_children(path_limit);
               
                % Filter for duplicates again, since include_children might
                % have added a duplicate.
                path_limit = unique(path_limit,'stable');
            end
            
            if ~isequal(obj.Components, ...
                    matlab.depfun.internal.SearchPath.AllComponents) || ...
                    ~isempty(obj.PathLimit)
                % If Components not equal to the AllComponents constant,
                % this path should span ONLY the listed components. So,
                % remove all components from the base MATLAB path,
                % trusting that the include list will have the required
                % component directories. (Never remove toolbox/matlab.)
                
                pth = pth(obj.PathUtility.keepOnPath(pth));
            end

            % Assemble the path from these path item sets:
            %   * pth: The MATLAB path, with component directories removed
            %          as indicated by -c.
            %
            %   * path_limit: Component-specific directories to add back
            %          to the path. Determined by -p. May be empty.
            %
            %   * include: Component-specific dependent directories 
            %          retrieved from the database.
            %
            %   * exclude: Directories excluded by the given target and
            %          component list.
            %
            %   * obj.IncludePath: User-specified include directories. Add
            %          at the beginning or end of the path, as directed by
            %          user.
            %
            % The directories in the path_limit and include sets must be
            % added to the path in the relative order in which they appear
            % on the MATLAB path.
            
            % Because the paths in the database all use Unix-style
            % forward slash file separators (which means the regular
            % expressions in the database are Unix-style too) convert the
            % path items to forward slash, temporarily, for matching.
            pth = strrep(pth, fs, '/');

            % Initialize obj.PathList
            obj.PathList = pth;
            
            % Files in exclude directory will be excluded by REQUIREMENTS
            % with a clear reason. If those directories are removed off the
            % path, REQUIREMENTS will think those files don't exist and 
            % hard error. (g938819)
            % Filter the edited MATLAB path against the exclude list.
            % obj.PathList = filter(pth, exclude);
            
            % Filter the path_limit items against the exclude list. (Make
            % sure their file separators lean the right way.) And remove
            % from the path_limit list any path_items already on the
            % PathList.
            if ~isempty(path_limit)
                path_limit = strrep(path_limit, fs, '/');
                path_limit = filter(path_limit, exclude);
                path_limit = path_limit(~ismember(path_limit, obj.PathList));
            end

            % Add the path_limit items to the PathList. Thus, the next step
            % will remove path_limit as well as PathList duplicates from
            % the include list.
            obj.PathList = [obj.PathList path_limit];
            
            % Remove from the include list any path items 
            % already on the PathList. (MATLAB gets angry if you put 
            % duplicate items on the path.)
            include = include(~ismember(include, obj.PathList));
            
            % Require that the remaining include list items actually exist
            % as directories. MATLAB cries out in protest at any attempt to
            % add non-existent directories to the path. We wait until this
            % point to filter because ISDIR is an expensive operation, and
            % include has been reduced to minimum size by previous steps.
            % (ISDIR ignores file separator direction.)
            %
            % We do not need to filter path_limit or PathList items because
            % they are drawn from the MATLAB path and the file system. The
            % SearchPath constructor checks that +I and -I path items
            % exist.
            keep = cellfun(@isdir, include);
            include = include(keep);
            
            % Add the include items to the PathList. Note
            % that include trumps exclude, so never filter the include
            % items against the exclude list.
            obj.PathList = [obj.PathList include];
            
            % Remove from the PathList any items that are not on the
            % original MATLAB path. These removed items will later be added
            % to the end of the path.
            [invaders, iLoc]= setdiff(obj.PathList, origPath);
            obj.PathList(iLoc) = [];
            
            % Reorder the PathList so that all path items have the same
            % relative order they did on the MATLAB path. This ensures that
            % path_limit and include items maintain their relative order.
            %
            % The MATLAB path is supposed to be free of duplicates, so
            % no need for 'UniformOutput', false here. We can pass the
            % strcmp result right to find.
            order = cellfun(@(d)find(strcmp(d,origPath)), obj.PathList);
            [~,k] = sort(order);
            obj.PathList = obj.PathList(k);
            
            % Add back the path_limit and include path items that were not
            % on the original MATLAB path.
            obj.PathList = [ obj.PathList invaders ];
            
            % Add the include paths, if specified, to the path.
            add(obj, obj.IncludePath.atStart, false);
            add(obj, obj.IncludePath.atEnd, true);
            
            % Remove uncompilable toolboxes and sub-directories 
            % from obj.PathList.
            obj.removeUncompilableTbxFromPath();
            
            % Convert the path list to native file separators.
            obj.PathList = strrep(obj.PathList, '/', fs);

            % Finally, make sure the assemble list has no duplicates. 
            % Performing this operation on the entire list allows +I to 
            % override (modify) the position of a directory in the list, 
            % actually moving it to the front if it is already on the path.
            %
            % Doing this last ensures that the file separators have been
            % normalized, so that directories cannot differ only by
            % file separator direction.
            obj.PathList = unique(obj.PathList,'stable');
        end
        
        function assemble_path_without_database(obj)
        % Assemble the MATLAB path without using the database            
            
            dashP_dir = {};
            if ~isempty(obj.PathLimit)
            % Normalize -p directories.
            % A valid -p direcroty can be 
            %   a toolbox directory name under $MATLAB/toolbox,e.g.,images
            %   the full path of a directory,
            %   the partial path of a directory relative to pwd.
    
                % Based on the frequency of those three usages above,
                % check toolbox names first.
                dir_list = realize_toolbox_path(obj.PathLimit);
                
                % Check existence of unresolved directories.
                % EXIST works for both full path and partial path.
                if ~isempty(dir_list)
                    idx = logical( ...                        
                           cellfun(@(d)exist(d,'dir'),dir_list) == 7);
                    dashP_dir = dir_list(idx);
                    unresolved = dir_list(~idx);
                    if ~isempty(unresolved)
                        if numel(unresolved) == 1
                            error(message( ...
                                'MATLAB:depfun:req:InvalidSearchDirectory',...
                                unresolved{1}))
                        else
                            error(message( ...
                                'MATLAB:depfun:req:InvalidSearchDirectories',...
                                strjoin(unresolved, ', ')))
                        end
                    end
                end
            end
            
            % Assemble the path.
            % Exhaustive combinations of -N, -p, -I/+I:
            % (1) -N, this is currently neglected in requirements.cpp.
            % (2) -p, -N is implied when -p is used.
            % (3) -I/+I, only modify the path based on -I/+I.
            % (4) -N -p, same as (2).
            % (5) -N -I/+I, same as (3) because of the reason in (1).
            % (6) -p -I/+I
            % (7) -N -p -I/+I, same as (6).
            
            % Therefore, only need to handle (2), (3), (6). 
            % (2) only -p
            % (3) only -I/+I
            % (6) -p and -I/+I            
            
            % Original path.
            % Split the path into a cell array of strings. Use of pathsep
            % accomodates platform-specific path formatting.
            obj.PathList = strsplit(path, pathsep);
            
            % Apply -N and -P, if specified
            if ~isempty(dashP_dir)
                % -N is implied when -p is used.
                % Core directories which are preserved when -N is applied.
                % $MATLAB/toolbox/matlab and its sub-dirs
                % $MATLAB/toolbox/local and its sub-dirs
                % $MATLAB/toolbox/compiler/deploy and its sub-dirs
                tbx_matlab = fullfile(matlabroot,'toolbox','matlab');
                tbx_local = fullfile(matlabroot,'toolbox','local');
                tbx_compiler = fullfile(matlabroot,...
                                            'toolbox','compiler','deploy');
                
                keep_dir = [ dashP_dir tbx_matlab tbx_local tbx_compiler ];
                
                keep = false(size(obj.PathList));
                for k = 1:numel(keep_dir)
                    keep = keep | obj.findDirAndItsSubDirsOnPath( ...
                                                obj.PathList, keep_dir{k});
                end
                
                % remove non-preserving directories
                obj.PathList(~keep) = [];
            end
            
            % Add the include paths, if specified, to the path.
            % -I
            if ~isempty(obj.IncludePath.atStart)
                add(obj, obj.IncludePath.atStart, false);
            end
            
            % +I
            if ~isempty(obj.IncludePath.atEnd)
                add(obj, obj.IncludePath.atEnd, true);
            end
            
            % Remove uncompilable toolboxes and sub-directories 
            % from obj.PathList.
            obj.removeUncompilableTbxFromPath();
        end
        
        function idx = findDirAndItsSubDirsOnPath(obj, p, d)
            if ischar(p)
                p = {p};
            end

            % For example, a/b/c, a/bd, a/b/c/d, a/b are on the path
            % if we are looking for a/b and its sub-dirs,
            % a/bd should not be picked up.
            % Thus, the pattern should be '^a/b$|^a/b/'.
            dir_pat1 = regexptranslate('escape', d);
            dir_pat2 = regexptranslate('escape', [d filesep]);
            pat = ['^' dir_pat1 '$|^' dir_pat2];
            idx = ~cellfun('isempty', regexp(p, pat));
        end
        
        function components = toolbox_components(obj, partial)
        % Given a list of partial paths, return a list of component names
        % the partial paths represent.
            components = {};
            [tbx_paths, ~] = realize_toolbox_path(partial);
            if ~isempty(tbx_paths)
                tbx_roots = unbind(obj.Variables, tbx_paths);
                % Form the query -- a toolbox path indicates a component if
                % the toolbox path matches the component location.
                query = ['SELECT name FROM component WHERE ' ...
                         'location = ''' tbx_roots{1} ''' '];
                if numel(tbx_roots) > 1
                    q = sprintf('OR location = ''%s'' ', tbx_roots{2:end});
                    query = [query q];
                end
                
                % Open a connection to the database.
                [db, disconnect] = connectDB(obj.Database);
                
                % Retrieve the names of the components whose roots match
                % the user-provided toolbox roots.
                db.doSql(query);
                
                c = db.fetchRow;
                while ~isempty(c)
                    components = [components {c}]; %#ok -- can't preallocate, size unknown
                    c = db.fetchRow;
                end
            end
        end
        
        function initialize_path(obj)
        % Three steps to constructing the path:
        %   1. Get component and target specific path items from the
        %      database.
        %
        %   2. Bind (expand) path item variables.
        %
        %   3. Modify the MATLAB path by adding the include items and 
        %      removing the exclude items.
        %
            if obj.useDB
                [include, exclude] = read_paths_from_database(obj);
                include = bind(obj.Variables, include);
                exclude = bind(obj.Variables, exclude);
                remember_exclude_dirs(obj, exclude);
                assemble_path(obj, include, exclude);
            else
                assemble_path_without_database(obj);
            end
        end

        function names = read_targets_from_database(obj)
        % Get the list of valid targets from the database
        
            [db, disconnect] = connectDB(obj.Database);
                    
            query = [...
                'SELECT Name FROM Target WHERE ID IN ' ...
                    '(SELECT DISTINCT Target FROM Component_Path_Item)' ];
            % Always support "None" target, which sets the SearchPath to
            % the current MATLAB path.
            names = {'None'}; 
            db.doSql(query);
            t = db.fetchRow;
            while ~isempty(t)
                names = [names {t}]; %#ok -- can't preallocate, size unknown
                t = db.fetchRow;
            end  
        end
        
        function [include, exclude] = read_paths_from_database(obj)
        % Extract include and exclude path information from the database
        % for the given component list and target environment.
        %
        % INCLUDE and EXCLUDE contain no duplicates upon return. (If
        % duplicates leak in, ASSEMBLE_PATH is likely to fail.)

            [db, disconnect] = connectDB(obj.Database);
                        
            % Insist that the given target (if supplied) matches one of the
            % targets in the database.
            if ~isempty(obj.Target) && ...
                isempty(ismember(obj.KnownTargets, obj.Target))
                tgtList = strjoin(obj.KnownTargets, ', ');
                error(message('MATLAB:depfun:req:TargetInfoNotInDB', ...
                              obj.Database, obj.Target, tgtList))
            end
            
            % The selection query varies depending on the target and 
            % component properties. But the prefix is always the same:
            % we're selecting path entries, which the database stores in the
            % path_item table. Note, in the first query, we retrieve the
            % items to be added to the path (those with operation = '+').
            %
            % Because the union of components may cause path_item
            % duplication, specifically request SELECT DISTINCT.

            select = 'SELECT DISTINCT path_item.location'; 
            from = ' FROM path_item,component_path_item';
            where = [' WHERE (component_path_item.operation = ''+'' AND ' ...
                     'path_item.id = component_path_item.item)'];

            % If there's a target, narrow the search by target
            if ~isempty(obj.Target)
                from = [from ',target'];
                where = [where ' AND (target.name = ''' obj.Target ...
                  ''' AND component_path_item.target = target.id AND ' ...
                  'component_path_item.item = path_item.id)'];
            end

            % Determine if the path limit directories specify known
            % components. If they do, add those components to the component
            % list for lookup.
            components = obj.Components;
            if ~isempty(obj.PathLimit)
                pth_components = toolbox_components(obj, obj.PathLimit);
                if isequal(components, ...
                        matlab.depfun.internal.SearchPath.AllComponents)
                    components = pth_components;
                else
                    components = [components pth_components];
                end
            end
            
            % If the Components property equals the AllComponents constant,
            % the path spans all the components in the installation. 
            % Otherwise, scope the selection to the specified components.
            if ~isequal(components, ...
                        matlab.depfun.internal.SearchPath.AllComponents)

                % We'll be querying component.name, so we need to add the
                % component table to the FROM clause.
                from = [from ',component'];
                
                % Create an "OR-list" of component names, and connect that 
                % to the where-clause with an AND.
                conjunction = ...
                    [' AND (component.name = ''' components{1} '''' ];

                % cellfun does the boring iterative work for us. Remember to
                % skip the first component name in the list, since we added it
                % to the conjunction already -- this trick allows the sprintf
                % statement to be uniform, and eliminates the need for tricky 
                % code that skips writing the "OR" after the last component 
                % name.
                 disjunction = cellfun(...
                     @(c)sprintf(' OR component.name = ''%s''', c), ...
                     components(2:end), 'UniformOutput', false);

                 % Add the scoping predicate to the where-clause
                 cscope = [ conjunction disjunction{:} ...
                     ') AND component_path_item.component = component.id'];
                 where = [ where cscope ];
            end

            query = [ select from where ];
            db.doSql(query);

            % Get all the rows of the result. Each consists of a single string,
            % one of the path items. Put all these strings into the path list.
            
            include = {};
            p = db.fetchRow;
            while ~isempty(p)
                include = [include {p}];
                p = db.fetchRow;
            end

            % The include list now consists of all the items that must be added
            % to the MATLAB path. In order to form a more perfect union, as
            % it were, we need to fetch the path items that need to be 
            % removed from the MATLAB path. Fortunately, we can reuse the 
            % query with a small modification: look for paths with
            % component_path_item.operation = '-' (instead of '+').
            
            query = strrep(query, 'component_path_item.operation = ''+''', ...
                           'component_path_item.operation = ''-''');
            db.doSql(query);

            % Get all the rows of the result
            exclude = {};
            p = db.fetchRow;
            while ~isempty(p)
                exclude = [exclude {p}];
                p = db.fetchRow;
            end
        end
    end

    methods
        function s = SearchPath(target, varargin)
        % Create a SearchPath object. 
        %
        %   target: Name of a target environment -- 'MCR', 'MATLAB', etc.
        %       The SearchPath will include and exclude items on the MATLAB
        %       path based on target-specific information in the database.
        %
        %   -p { directory list }: Drop all toolboxes from the path, then 
        %       the specified directories to the path. Limits the path to
        %       these directories and their sub-directories. Makes analysis
        %       quicker and more accurate. Directories in this list may be
        %       relative paths. If the relative path appears to originate
        %       in matlab/toolbox, then the effect is to add the toolbox's
        %       directories back to the path.  -p {'comm'}, for example,
        %       adds the Communication Toolbox back to the path.
        %       Directories are added to the path in the same order in
        %       which they appeared in the original path (before toolbox
        %       directories were removed).
        %
        %  -I { directory list }: Add the directories to the end of the
        %       MATLAB path. The directories may be specified as relative
        %       paths, but they must be relative to the current directory
        %       -- they are not tested for origin in matlab/toolbox. Use +I
        %       to add directories to the front of the path.
        %
        %  -c { component list}: Modify the path according to the include
        %       exclude list of the given component. Data for the component
        %       must be present in the database.
        %      
        % s = SearchPath('MCR') 
        %   MCR-specific path, all toolboxes, default database.
        %
        % s = SearchPath('MCR', '-p', 'matlab'}
        %   MCR-specific path, MATLAB toolbox only, default database.
        %
        % s = SearchPath('MCR', '-p', 'images')
        %   MCR-specific path, Image Processing toolbox only, default database.
        % 
        % s = SearchPath('MCR', 'tbxData.db')
        %   MCR-specific path, all toolboxes, specified database.
        %
        % s = SearchPath('MCR', '-p', {'images', 'stats' });
        %   MCR-specific path, Image and Statistics toolboxes, default database.
        %
        % s = SearchPath('MCR', '-p', {'images', 'stats'}, 'tbxData.db')
        %   MCR-specific path, Image and Statistics toolboxes, given database.
        %
        % s = SearchPath('MCR', '-p', {'images', 'stats'}, ...
        %                '-i', { '/some/directory' }, 'tbxData.db')
        %   MCR-specific path, Image and Statistics toolboxes, an include
        %   directory, given database.
        %
        % s = SearchPath('MCR', '-p', {'images', 'stats'}, 
        %                '-c', ... 'compiler', 'tbxData.db');
        %
        %   MCR-specific path, Images and Statistics toolbox directories on
        %   the path, Compiler component dependencies on the path,
        %   tbxData.db as the database.
               
            % Not fully initialized yet. Must set first, so property set
            % functions behave properly.
            s.Constructed = false;
        
            % Validate number of inputs
            narginchk(1, 8);
            
            % Target must be a character string
            if ~ischar(target)
                error(message('MATLAB:depfun:req:InvalidInputType', ...
                    1, class(target), 'char'))
            end
            
            s.useDB = true;
            reqDB = getenv('REQUIREMENTS_DATABASE');
            if (~isempty(reqDB) && reqDB == '0')
                s.useDB = false;
            end
            
            % Set include path cell arrays to emtpy.
            s.IncludePath.atStart = {};
            s.IncludePath.atEnd = {};
            
            % Initialize pcm_db
            env = matlab.depfun.internal.reqenv;
            s.pcm_db = env.PcmPath;
            
            % Initialize PathUtility
            s.PathUtility = matlab.depfun.internal.PathUtility;
            
            % Process variable argument list. Argument interpretation based on
            % both position and type -- tricky code, but better usability.
            
            idx = 1;
            path_limit_idx = 0;
            include_path_end_idx = 0; 
            include_path_start_idx = 0;
            components_idx = 0;
            while idx <= numel(varargin)
                
                % Always look for a string -- each valid argument group
                % must begin with a string.
                if ~ischar(varargin{idx})
                    error(message('MATLAB:depfun:req:InvalidInputType', ...
                        idx, class(varargin{idx}), 'character'))
                end
                
                % Case does not matter for -p and -I switches. Safe to call
                % lower since we detect non-character arguments just above.
                ps = lower(varargin{idx});   % Parse Switch
                switch ps
                    case '-p'
                        if idx+1 > numel(varargin)
                            error(message(...
                                'MATLAB:depfun:req:MissingPathArg', ...
                                idx, varargin{idx}))
                        end
                        idx = idx + 1;
                        % Path Limit validity checking performed by 
                        % set.PathLimit.
                        s.PathLimit = varargin{idx};
                        path_limit_idx = idx;
                    case '-i'
                        % Consistent with '-I' in mcc.
                        idx = idx + 1;
                        if idx <= numel(varargin)
                            incDir = varargin{idx};
                            if ischar(incDir), incDir = { incDir }; end
                            s.IncludePath.atStart = incDir;
                            include_path_start_idx = idx;
                        else
                            error(message(...
                             'MATLAB:depfun:req:InvalidSearchDirectory', ''))
                        end
                    case '+i'
                        % Add directories to the end of the path.
                        idx = idx + 1;
                        if idx <= numel(varargin)
                            incDir = varargin{idx};
                            if ischar(incDir), incDir = { incDir }; end
                            s.IncludePath.atEnd = incDir; 
                            include_path_end_idx = idx;
                        else
                            error(message(...
                             'MATLAB:depfun:req:InvalidSearchDirectory', ''))
                        end
                    case '-c'
                        idx = idx + 1;
                        s.Components = varargin{idx};
                        components_idx = idx;
                    otherwise
                        s.Database = varargin{idx};
                end
                idx = idx + 1;
            end
            
            % Use default Database if not set yet
            if s.useDB && isempty(s.Database)
                s.Database = env.DependencyDatabasePath;
            end

            % IncludePath must be empty or a string or a cell array.
            if isfield(s.IncludePath, 'atStart') ...
                    && ~ischar(s.IncludePath.atStart) ...
                    && ~iscell(s.IncludePath.atStart)
                error(message('MATLAB:depfun:req:InvalidIncludePathType', ...
                    include_path_start_idx, class(s.IncludePath.atStart)))
            end
            
            if isfield(s.IncludePath, 'atEnd') ...
                    && ~ischar(s.IncludePath.atEnd) ...
                    && ~iscell(s.IncludePath.atEnd)
                error(message('MATLAB:depfun:req:InvalidIncludePathType', ...
                    include_path_end_idx, class(s.IncludePath.atEnd)))
            end   
            
            function revise_include_paths(obj, location)
            % Make sure include paths exist, and if they're partials on the
            % MATLAB path, expand them to full paths. Remove non-existent
            % paths from the include list (without warning or error).
                dirList = obj.IncludePath.(location);
                existing = cellfun(@(d)exist(d, 'dir') == 7, dirList);

                % Empty include path: error! It is OK to try and add
                % non-existent directories to the list -- they just
                % won't show up (but it is only an error if the directory
                % name is actually empty).
                if any(~existing)
                     if any(cellfun('isempty',dirList))
                        error(message(...
                            'MATLAB:depfun:req:InvalidSearchDirectory', ''))
                    end
                end

                obj.IncludePath.(location) = dirList(existing);

                [pathItems, realized] = realize_partial_path(dirList);
                obj.IncludePath.(location)(realized) = pathItems(realized);
            end
            
            if isfield(s.IncludePath, 'atStart')
                revise_include_paths(s, 'atStart');           
            end
            
            if isfield(s.IncludePath, 'atEnd')
                revise_include_paths(s, 'atEnd');           
            end
  
            % Database must exist.
            if s.useDB && exist(s.Database, 'file') ~= 2
              error(message('MATLAB:depfun:req:NonExistDatabase', ...
                  s.Database))
            end
            
            % If -p and no -c, then set Components to 'matlab'. 
            % Components defaults to 'all components' and assemble_path
            % creates the search path from the union of -c, -p and -I
            % arguments. -p implicitly clears the path of all but the
            % MATLAB toolbox -- we must clear the component list as well.
            if path_limit_idx > 0 && components_idx == 0
                s.Components = 'matlab';
            end
            
            % Component list may not be empty (is not allowed to be empty).
            % It may be empty here if the caller passes {}, '' or, most
            % deviously, {''}, but those are all invalid values.
            if isempty(s.Components) || ...
               (iscell(s.Components) && ...
                any(cellfun('isempty', s.Components)))
                error(...
                  message('MATLAB:depfun:req:InvalidSearchComponent',''))
            end
            
            s.Variables = matlab.depfun.internal.IxfVariables('/');
            
            if s.useDB
                % Must read targets from DB before setting target
                s.KnownTargets = read_targets_from_database(s);
            end
            
            % Lock on target
            s.Target = target;
                        
            % Get the target-specific path from the database
            initialize_path(s);
            
            % Object has been constructed.
            s.Constructed = true;
        end
        
        function list = match(obj, pattern)
            % Escape backslashes
            pattern = strrep(pattern, '\', '\\');
    
            list = regexp(obj.PathList, pattern, 'once');
            keep = ~cellfun('isempty',list);
            list = obj.PathList(keep);
        end
        
        function add(obj, directoryList, atEnd)
        % Add a one or more directories to the search path. The directories
        % must exist (and be directories). Don't allow duplicates. If a
        % directory we're adding already exists in the path list, keep them
        % in the original order on the path.
        
            % Add to the end by default.
            if nargin == 2
                atEnd = true;
            end
            
            % Uniform processing: directory list always a cell array.
            if ischar(directoryList)
                directoryList = { directoryList };
            end
            
            if ~iscell(directoryList)
                error(message('MATLAB:depfun:req:InvalidInputType', 2, ...
                    class(directoryList), 'cell array'))
            end

            % Don't allow duplicates in the directory list.
            directoryList = unique(directoryList, 'stable');

            % Determine if any directories are already on the PathList; if
            % they are, keep them in the order-sensitive context.
            % See help document of MCC for details.
            [~,~,rm] = intersect(obj.PathList, directoryList);
            directoryList(rm) = [];
            
            % TODO: Filter directoryList against exclude list?
            
            function add_dir(d, atEnd)
                if exist(d, 'dir') == 7
                    if atEnd
                        obj.PathList{end+1} = d;
                    else
                        obj.PathList = [ d obj.PathList ];
                    end
                else
                    error(message('MATLAB:depfun:req:NonExistDir', d))
                end
            end
            
            % If adding to the front of the list, reverse the directory
            % list first to maintain its original order. (Otherwise the
            % last element of the directory list ends up at the very front
            % of the path -- the list is added in reverse order.)
            if atEnd == false
                directoryList = directoryList(end:-1:1);
            end
            
            cellfun(@(d)add_dir(d, atEnd), directoryList);
        end

        function remove(obj, directoryList)
        % Remove a directory from the search path. The directory must
        % be on the search path.
        
            % Allow the input directory list to be a single string.
            if ischar(directoryList)
                directoryList = { directoryList };
            end
            % If it wasn't a string or a cell array, mistakes have been
            % made.
            if ~iscell(directoryList)
                error(message('MATLAB:depfun:req:InvalidInputType', 2, ...
                    class(directoryList), 'cell array'))
            end
            % Collect the indices of directories to remove from the path.
            rm = cellfun(@(d)find_dir(obj, d, true), directoryList);
            % Remove the doomed directories.
            obj.PathList(rm) = [];
        end

        % Property set/get methods
        
        function k = get.PathCount(obj)
            k = numel(obj.PathList);
        end
        
        function str = get.PathString(obj)
        % Merge the strings in PathList into a single pathsep-separated
        % string suitable for passing to MATLAB's path function.

            str = ''; % Always assign to output variables
            
            if ~isempty(obj.PathList)
                % Create a cell array where each entry begins with pathsep.
                fmtStr = [pathsep '%s'];
                str = cellfun(@(p)sprintf(fmtStr, p), obj.PathList, ...
                          'UniformOutput', false);

                % Concatentate them into a single string.
                str = [ str{:} ];

                % Chop off the first pathsep, since it has no purpose.
                str = str(2:end);
            end
        end
                
        function set.Sort(obj, flag)
        % Set the sort flag. Setting it to true reorders the path using
        % lexicographic order.
        
            % Allow the words 'true' and 'false' as well as logical values.
            if ischar(flag)
                switch flag
                    case 'true'
                        flag = true;
                    case 'false'
                        flag = false;
                end
            end
            
            % Logical values only, after this point.
            if ~islogical(flag)
                error(message(...
                        'MATLAB:depfun:req:IllogicalSortProperty', ...
                        flag, class(flag)))
            end       
            
            obj.Sort = flag;
            if obj.Sort == true
                obj.PathList = sort(obj.PathList);  %#ok -- being careful
            end
        end
        
        function set.PathLimit(obj, pathItems)
        % Set the PathLimit list. Recalculate the path based on the new
        % component list. 
        
            % The list must not be empty. This catches empty character
            % strigs as well as empty cell arrays.
            if isempty(pathItems)
                error(message('MATLAB:depfun:req:InvalidSearchDirectory',''))
            end
            
            % Convert character array to cell array
            if ischar(pathItems) && isvector(pathItems)
                pathItems = { pathItems };
            % Not a character string? Better be a cell array of strings
            elseif ~iscell(pathItems)
                error(message('MATLAB:depfun:req:InvalidPathLimitType', ...
                    class(pathItems)))
            else
                strItems = cellfun(@ischar, pathItems);
                if ~all(strItems)
                    offenders = find(~strItems);
                    error(message('MATLAB:depfun:req:InvalidPathLimitType', ...
                        class(pathItems{offenders(1)})))
                end
            end
            
            % TODO: Complain about path items that aren't on MATLAB's path?
            
            % No wild cards here. Must set this field before setting
            % s.Components, because set.Components calls initialize_path,
            % which references PathLimit.
            obj.PathLimit = pathItems;
            
            % Setting PathLimit is equivalent to passing -p to the
            % constructor. If the user did not set the component list in
            % the constructor or via set.Components, this -p must set the 
            % component list to 'matlab'.
            init_path = true;
            if isequal(obj.Components, ...  
                    matlab.depfun.internal.SearchPath.AllComponents)  %#ok
                obj.Components = {'matlab'}; %#ok
                init_path = false;
            end

            if obj.Constructed && init_path %#ok -- set first in constructor
                initialize_path(obj);
            end            
        end
        
        function set.Components(obj, componentList)
        % Set the component list. Recalculate the path based on the new
        % component list. Component list contains toolbox "locations",
        % the directory under $MATLAB/toolbox containing the toolbox.

            % The list must not be empty.
            if isempty(componentList)
                error(message('MATLAB:depfun:req:InvalidSearchComponent',''))
            end
            
            % The rest of the machinery expects the list to be a cell
            % array. We allow it to be a singleton for convenience, but
            % convert it here to a cell array.
            if ~iscell(componentList)
                componentList = { componentList };
            end
            
            % If the list == AllComponents, set obj.Components to
            % AllComponents. Otherwise, look up the component names.
            if isequal(componentList, ...
                    matlab.depfun.internal.SearchPath.AllComponents)
                obj.Components = ...
                    matlab.depfun.internal.SearchPath.AllComponents;                
            else
                obj.Components = toolbox_location_to_name(componentList);
            end
            
            if obj.Constructed  %#ok -- set first in constructor
                initialize_path(obj);
            end
        end
        
        function set.Target(obj, target)
        % Set the search path's target. Recalculate the path based on the
        % new target. It is OK to reference KnownTargets here because
        % KnownTargets is set in the constructor.
            if matlab.depfun.internal.Target.parse(target) == ...
                matlab.depfun.internal.Target.Unknown
                if ~isempty(obj.KnownTargets)%#ok
                    tgtList = strjoin(obj.KnownTargets, ', '); %#ok
                else
                    tgtList = '';
                end
                error(message('MATLAB:depfun:req:InvalidTarget', ...
                    target, tgtList))
            end
            if obj.useDB && ~any(ismember(obj.KnownTargets, target)) %#ok
                tgtList = strjoin(obj.KnownTargets, ', '); %#ok 
                error(message('MATLAB:depfun:req:TargetInfoNotInDB', ...
                              obj.Database, target, tgtList)) %#ok
            end
            obj.Target = target;
            if obj.Constructed  %#ok -- set first in constructor
                initialize_path(obj);
            end
        end

        function set.Database(obj, database)
        % Set the path to the database that contains component information.
        % The database must exist. Recalculate the path based on the new
        % database.
            if exist(database,'file') ~= 2
                error(message('MATLAB:depfun:req:NonExistDatabase', ...
                    database))
            end
            
            obj.Database = database;
            if obj.Constructed  %#ok -- set first in constructor
                initialize_path(obj);
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local functions

function tf = isregexp(str)
% Doesn't include . and +, which are valid file name characters. So I'm
% guessing here, and will sometimes be wrong.
    meta = '[]^\()|$*?{}';  
    tf = false;
    k = 1;
    while tf == false && k <= numel(meta)
        tf = ~isempty(strfind(str, meta(k)));
        k = k + 1;
    end
end

function clean = filter(list, pattern)
% Filter a list by removing all the items that match expressions in the
% pattern list. patterns may be strings or regular expressions. For
% performance, only use regexp on those patterns that are regular
% expressions (strcmp is WAAAAAY faster than regexp for regular strings).

    clean = {};
    
    useRegexp = cellfun(@(p)isregexp(p), pattern);
    useStrcmp = ~useRegexp;
    
    rexp = pattern(useRegexp);
    str = pattern(useStrcmp);
    
    for k=1:numel(list)
        % Add the directories on the list to the clean list unless
        % they match an excluded path item. Excluded path items can
        % be regular expressions.

        % regexp loops over rexp, producing a cell array of
        % match indices.
        noMatch = true;
        if ~isempty(rexp)
            match = regexp(list{k}, rexp, 'once');
            noMatch = all(cellfun('isempty',match));
        end
        if noMatch
            if ~isempty(str) 
                noMatch = all(~strcmp(list{k}, str));
            end  
        end
        if noMatch
            clean = [ clean list(k) ];
        end
    end
end

function nameList = toolbox_location_to_name(locationList)
% Given a cell array of MATLAB toolbox locations return a list of MATLAB
% toolbox names. A toolbox location is the rightmost directory in the
% toolbox's root directory. For example, the root directory of the Image
% Processing Toolbox is '$MATLAB/toolbox/images'. The "location" of the
% Image Processing Toolbox is therefore 'images'. Locations can be passed
% to MATLAB's VER function.

    function name = lookup_tbx_name(loc)
        v = ver(loc);
        
        % filerdesign is not an independent product. VER does not know
        % about it.
        % This patch should be removed when g1038572 is fixed.
        if strcmp(loc, 'filterdesign') && isempty(v)
            v(1).Name = 'MATLAB:$MATLAB/toolbox/dsp/filterdesign';
        end
        
        if isempty(v)
            error(message('MATLAB:depfun:req:InvalidSearchComponent', ...
                loc))
        end
        name = v.Name;
    end

    nameList = cellfun(@(loc)lookup_tbx_name(loc), ...
                       locationList, 'UniformOutput', false);
end

function [path_list, partial] = realize_toolbox_path(partial)
% If a partial path exists relative to the toolbox root, return the
% corresponding full path. partial is a cell array of strings.

    % Replace partial paths that originate in matlab/toolbox with their
    % full paths. Remove the realized paths from the input list of partial
    % paths.
    pthutil = matlab.depfun.internal.PathUtility;
    path_list = cellfun(@(d)pthutil.parent_to_toolbox(d), partial, ...
        'UniformOutput', false);
    unchanged = strcmp(path_list, partial);
    partial = partial(unchanged);
end

function [path_items, match] = realize_partial_path(partial)
% Look for MATLAB path entries that match the input paths. Paths may be
% partial or full. Replace the input partial paths with their matches. 
% Leave unmatched partials alone and matched or unmatched full paths alone. 
% Also return a logical index indicating which partials and full paths 
% matched.
    ps = pathsep;
    % The MATLAB path always uses platform-specific file separators.
    % Convert the partial path to use platform-specific separators or else
    % the partial path items might not match.
    partial = strrep(partial,'\','/');  % Normalize to one true separator

    % Escaped platform-specific; each partial becomes part of a regular
    % expression, escape required.
    partial = strrep(partial,'/',['\' filesep]); 

    % REGEXP will return empty for directories that don't match anything on 
    % the path string. Make sure to use the platform-specific path separator,
    % or REGEXP will match way too much.
    path_items = cellfun(@(d) ...
         regexp(path,['(^|' ps ')[^' ps ']*' d '(' ps '|$)'],...
                'match','once'), ...
        partial, 'UniformOutput', false);

    % Locate partial path items that were found on the MATLAB path
    match = ~cellfun('isempty',path_items);

    % Remove extra semi-colons (path separators). These are an
    % artifact of the regular expression match; noise, at this
    % point.
    path_items = strrep(path_items,ps,'');

    % Replace empty path_items (these were not found on the MATLAB
    % path) with the corresponding input partial paths.
    path_items(~match) = partial(~match);
end

function data = flatten(data)
% flatten Flatten a cell array (remove all nesting).

    if iscell(data)
        data = cellfun(@flatten,data,'UniformOutput',false);
        if any(cellfun(@iscell,data))
            data = [data{:}];
        end
    end
end

function path_items = include_children(parents)
% Given a list of parent directories, construct a list that consists of
% those parents and all their children which are on the MATLAB path.

    % TODO: escape all regexp chars. valid in a file name
    parents = strrep(parents,'\','\\');
    
    function kids = find_children(p)
        % Chop off terminal file separator so we can replace it with 
        % uniform, platform-specific file separator.
        fs = filesep;
        if p(end) == fs
            p(end) = [];
        end
    
        % Find all the children of this parent which are on the path (all
        % the directories which have this parent as a proper prefix).
        pth = regexp(path, pathsep, 'split');  
        found = regexp(pth, [p '\' fs],'once');
        
        % Locate partial path items that were found on the MATLAB path
        kids = {};
        if ~isempty(found)
            keep = ~cellfun('isempty',found);
            kids = pth(keep);  
        end
    end

    % Assemble a cell array of cell arrays of children
    path_items = cellfun(@(p)find_children(p), parents, ...
                         'UniformOutput', false);
    
    % Flatten all the directories -- parents and children -- into a single
    % cell array.
    path_items = flatten([ path_items parents ]);
    
    % Remove escapes, since we must return actual, valid path items.
    path_items = strrep(path_items, '\\', '\');
end

function [db, disconnect] = connectDB(file)
% Connect to the given database using the SqlDbConnector
    if exist(file, 'file') ~= 2
        error(message('MATLAB:depfun:req:NonExistDatabase', file))
    end

    
    % Open the database and connect to it.
    db = matlab.depfun.internal.database.SqlDbConnector;
    % SearchPath only supports read operation
    % Connect read only
    db.connectReadOnly(file);
    disconnect = onCleanup(@()db.disconnect);
end
                      
