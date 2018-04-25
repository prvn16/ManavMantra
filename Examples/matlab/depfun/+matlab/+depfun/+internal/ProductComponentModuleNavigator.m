classdef ProductComponentModuleNavigator < handle
% matlab.depfun.internal.ProductComponentModuleNavigator provides APIs to
% access the product-component-module (PCM) database.

    properties (Access = private)
        SqlDBConnObj
        db_path
    end

    properties
        sourceToComponentMap
        productDependencyMap
        uncompilableTbxRoot
        builtinRegistry
    end

    properties (Access = private, Hidden)
        env
        pathUtil
    end

    % Constructor and destructor
    methods
        function obj = ProductComponentModuleNavigator(varargin)
        % Create an instance of the navigator class.
        %     The input 'pcm_db' can be
        %         (1) the full path of the database;
        %         (2) the path of the database relative to 
        %             the current working directory.
        %     The output 'obj' is the instantiated object.
        % Connect to the given database if it is valid. 
        % Otherwise, it errors the given database cannot be found or opened.
            
            narginchk(0,1);
            
            % Create a database connector object.
            obj.SqlDBConnObj = matlab.depfun.internal.database.SqlDbConnector;
            
            obj.env = matlab.depfun.internal.reqenv;
            obj.pathUtil = matlab.depfun.internal.PathUtility;
            % connect to the database
            if nargin == 0
                dbFile = obj.env.PcmPath;
            else
                dbFile =  varargin{1};
            end
            obj.connect(dbFile);
        end

        function delete(obj)
        %?Destroy the instance of the navigator class.
        %  The destructor will be 
        %      (1) explicitly called when the object is deleted;
        %      (2) implicitly called when the object goes out of scope.
        %?Disconnecting to the database in the destructor can conveniently allow the client 
        %  not to write onCleanup(@()obj.disconnect()), which is pretty boring.
            obj.disconnect();
        end
    end
    
    methods
        function connect(obj, pcm_db)
        % (1) The class constructor calls it when initializing the instance.
        % (2) After the instance is created, it can be reset to connect to a different database.
        % connect() sets the database path, which is a private property, and then connects to it.
        % connect() errors if it fails to open the given database.
            obj.db_path = pcm_db;
            
            % disconnect the currently connected database
            if ~isempty(obj.SqlDBConnObj)
                obj.disconnect();
            end
            
            % The ProductComponentModuleNavigator supports only read operations
            % Connect read only
            obj.SqlDBConnObj.connectReadOnly(obj.db_path);
        end
        
        function disconnect(obj)
        % Calls the disconnect method in the instance of class
        % matlab.depfun.internal.database.SqlDbConnector.
        % Called by the class destructor.
            obj.SqlDBConnObj.disconnect();
        end
    end
    
    % ----- Public methods for querying product information -----
    methods
        function pinfo = productShippingFile(obj, afullpath, target)
        % Provide detailed information of products shipping the given file.
        % Inputs: 
        %     'afullpath' is a string, which must be the full path of the file.
        %     'target' is a string of one of matlab.depfun.internal.Target.
        %
        % The output 'pinfo' is a struct array of product information. 
        %     Each element contains the following information of a product:
        %         intPName - product internal name
        %         extPName - product external name
        %         extPID   - external product ID
        %         version  - product version
        %         LName    - product license name
        % The output is an empty struct array, if no product ships the given file.
            requiresChar(afullpath);
            
            pinfo = struct([]);
            if exist(afullpath, 'file')
                cname = obj.componentOwningFile(afullpath);
                pinfo = obj.productShippingComponent(cname, target);
            end
        end

        function pinfo = productShippingBuiltin(obj, abuiltin, target)
        % Provide detailed information of products shipping the given built-in.
        % Inputs:
        %     'abuiltin' is a string of a built-in symbol.
        %     'target' is a string of one of matlab.depfun.internal.Target.
        % The output 'pinfo' is a struct array of product information. 
        %     Each element contains the following information of a product:
        %         intPName - product internal name
        %         extPName - product external name
        %         extPID   - external product ID
        %         version  - product version
        %         LName    - product license name
        % The output is an empty struct array, if no product ships the given built-in.
            requiresChar(abuiltin);
        
            pinfo = struct([]);
            if isKey(obj.builtinRegistry, abuiltin)
                component = obj.builtinRegistry(abuiltin).component;
                pinfo = productShippingComponent(obj, component, target);
            end
        end
        
        function pinfo = productShippingSymbol(obj, asymbol, target)
        % Determine whether the given symbol is a file or a built-in,
        % then forward the call to productShippingFile() or productShippingBuilin().
        % Inputs:
        %     'asymbol' is a string of a symbol.
        %     'target' is a string of one of matlab.depfun.internal.Target.
        % Refer comments in productShippingFile() or productShippingBuilin() for the output 'pinfo'. 
        % The output is an empty struct array, if no product ships the given symbol.
            requiresChar(asymbol);
            
            w = which(asymbol);
            if ~isempty(strfind(w, ...
                    matlab.depfun.internal.requirementsConstants.BuiltInStr))
                pinfo = productShippingBuiltin(obj, asymbol, target);
            else
                pinfo = productShippingFile(obj, w, target);
            end
        end
        
        function pinfo = productShippingComponent(obj, acomponent, target)
        % Provide detailed information of products shipping the given component.
        % Inputs:
        %     'acomponent' is a string.
        %     'target' is a string of one of matlab.depfun.internal.Target.
        % The output 'pinfo' is a struct array of product information. 
        %     Each element contains the following information of a product:
        %         intPName - product internal name
        %         extPName - product external name
        %         extPID   - external product ID
        %         version  - product version
        %         LName    - product license name
        % The output is an empty struct array, if no product ships the given component.
            requiresChar(acomponent);
            
            pinfo = struct([]);
            if ~isempty(acomponent)
                pid_filter = perTargetProductFilter(target);                                    
                query = sprintf( ...
                    ['SELECT Product.Internal_Name, ' ...
                     '       Product.External_Name, ' ...
                     '       Product.External_Product_ID, ' ...
                     '       Product.Version, ' ...
                     '       Product.License_Name ' ...
                     'FROM Product, Component, Product_Component ' ...
                     'WHERE Component.Name = ''%s'' ' ...
                     '  AND Product_Component.Component = Component.ID ' ...
                     '  AND Product.ID = Product_Component.Product ' ...
                     pid_filter ';'], acomponent);
                obj.doSql(query);
                % More than one products may ship the same components
                result = obj.fetchRows();
                pinfo = productList(result);
            end
        end
        
        function pinfo = productInfo(obj, aproduct)
        % Provide detailed information of the given product.
        % Inputs:
        %     'aproduct' is a string (internal product name) 
        %                   or a number (external product id).
        % The output 'pinfo' is a struct of product information. 
        %     Each element contains the following information of a product:
        %         intPName - product internal name
        %         extPName - product external name
        %         extPID   - external product ID
        %         version  - product version
        %         LName    - product license name
        % The output is an empty struct, if the given product is unknown.
            pinfo = struct([]);
            if ~isempty(aproduct)
                if ischar(aproduct)
                    query = sprintf( ...
                            ['SELECT Internal_Name, ' ...
                             '       External_Name, ' ...
                             '       External_Product_ID, ' ...
                             '       Version, ' ...
                             '       License_Name ' ...
                             'FROM Product ' ...
                             'WHERE Product.Internal_Name = ''%s'';'], aproduct);
                    obj.doSql(query);
                    % More than one products may ship the same components
                    result = obj.fetchRows();
                    pinfo = productList(result);
                elseif isnumeric(aproduct)
                    query = sprintf( ...
                            ['SELECT Internal_Name, ' ...
                             '       External_Name, ' ...
                             '       External_Product_ID, ' ...
                             '       Version, ' ...
                             '       License_Name ' ...
                             'FROM Product ' ...
                             'WHERE Product.External_Product_ID = %d;'], aproduct);
                    obj.doSql(query);
                    % More than one products may ship the same components
                    result = obj.fetchRows();
                    pinfo = productList(result);
                end
            end
        end
        
        function pinfo = findProductWithIdentifyingComponent(obj, acomponent)
        % Find the product based on the given identifyingComponentName.
        % Inputs:
        %     'acomponent' is a string.
        % The output 'pinfo' is a struct of product information. 
        %     Each element contains the following information of a product:
        %         intPName - product internal name
        %         extPName - product external name
        %         extPID   - external product ID
        %         version  - product version
        %         LName    - product license name
        % The output is an empty struct, if the given product is unknown.
        
            requiresChar(acomponent);
            
            pinfo = struct([]);
            if ~isempty(acomponent)
                query = sprintf( ...
                    ['SELECT Product.Internal_Name, ' ...
                     '       Product.External_Name, ' ...
                     '       Product.External_Product_ID, ' ...
                     '       Product.Version, ' ...
                     '       Product.License_Name ' ...
                     'FROM Product, Component ' ...
                     'WHERE Component.Name = ''%s'' ' ...
                     '  AND Product.Identifying_Component = Component.ID;' ...
                    ], acomponent);
                obj.doSql(query);
                result = obj.fetchRows();
                pinfo = productList(result);
            end
        end

        function result = getUncompilableTbxRoot(obj)
            if isempty(obj.uncompilableTbxRoot)
                obj.doSql(['SELECT Path_Item.Location ' ...
                   'FROM Path_Item, Uncompilable_Toolbox ' ...
                   'WHERE Uncompilable_Toolbox.Toolbox_Root = Path_Item.ID;']);

                rawData = obj.fetchRows();
                result = cellfun(@(r)r{1},rawData,'UniformOutput',false);
                result = sort(result);
                result = fullfile(matlabroot, result);
                obj.uncompilableTbxRoot = result;
            else
                result = obj.uncompilableTbxRoot;
            end
        end

        function pinfo = requiredProducts(obj, aproduct)
        % Find the product-level dependencies based on the given product name.
        % Inputs:
        %     'aproduct' is a string.
        % The output 'pinfo' is a struct of product information.
        %     Each element contains the following information of a product:
        %         intPName - product internal name
        %         extPName - product external name
        %         extPID   - external product ID
        %         version  - product version
        %         LName    - product license name
        % The output is an empty struct, if the given product is unknown.

            requiresChar(aproduct);

            pinfo = struct([]);
            if ~isempty(aproduct)
                query = sprintf( ...
                    ['SELECT Product.Internal_Name, ' ...
                     '       Product.External_Name, ' ...
                     '       Product.External_Product_ID, ' ...
                     '       Product.Version, ' ...
                     '       Product.License_Name ' ...
                     'FROM Product ' ...
                     'WHERE Product.ID IN ' ...
                     '  (SELECT Product_Dependency.Service ' ...
                     '   FROM Product, Product_Dependency ' ...
                     '   WHERE Product.Internal_Name = ''%s'' ' ...
                     '     AND Product_Dependency.Client = Product.ID);'], aproduct);
                obj.doSql(query);
                % More than one products may ship the same components
                result = obj.fetchRows();
                pinfo = productList(result);
            end
        end

        function product_dependency_map = get.productDependencyMap(obj)
        % Generate a product-level dependency map
        % Key - product internal name
        % Value - cell array of required product internal name(s)

            if isempty(obj.productDependencyMap)
                obj.doSql(['SELECT Client, Service ' ...
                           'FROM Product_Dependency;']);
                result = obj.fetchRows();
                client_id = cell2mat(cellfun(@(r)r{1},result,'UniformOutput',false));
                service_id = cell2mat(cellfun(@(r)r{2},result,'UniformOutput',false));
                client_name = cell(size(client_id));
                service_name = cell(size(service_id));

                obj.doSql(['SELECT Internal_Name ' ...
                           'FROM Product;']);
                product_internal_name_list = obj.fetchRows();

                % replace id with product internal name
                for k = 1:numel(product_internal_name_list)
                    client_name(client_id==k) = product_internal_name_list{k};
                    service_name(service_id==k) = product_internal_name_list{k};
                end

                % generate a product dependency map
                obj.productDependencyMap = containers.Map('KeyType', 'char', ...
                                                        'ValueType', 'any');
                unique_client = unique(client_name);
                for k = 1:numel(unique_client)
                    obj.productDependencyMap(unique_client{k}) = ...
                        service_name(strcmp(client_name, unique_client{k}));
                end
            end

            product_dependency_map = obj.productDependencyMap;
        end
    end

    % ----- Public methods for querying component information -----
    methods
        function cname = componentOwningFile(obj, afullpath)
        % Find the owning component of the given file.
        % The input 'afullpath' is a string, which must be the full path of the file.
        %
        % The output 'cname' is a string of the component name.
        % The output is empty, if no component owns the given file.
            requiresChar(afullpath);

            cname = '';
            if exist(afullpath, 'file')
                relative_path = strrep(afullpath, [matlabroot filesep], '');

                while ~isempty(relative_path)
                    if isKey(obj.sourceToComponentMap, relative_path)
                        cname = obj.sourceToComponentMap(relative_path);
                        break;
                    else
                        % Trim off the last part.
                        relative_path = fileparts(relative_path);
                    end
                end
            end
        end

        function cname = componentOwningBuiltin(obj, abuiltin)
        % Find the owning component of the given built-in.
        % The input 'abuiltin' is a string of a built-in symbol.
        % The output 'cname' is a string of the component name.
        % The output is empty, if no component owns the given built-in.
            requiresChar(abuiltin);
            
            cname = '';
            if isKey(obj.builtinRegistry, abuiltin)
                cname = obj.builtinRegistry(abuiltin).component;
            end
        end
        
        function cname = componentOwningSymbol(obj, asymbol)
        % Determine whether the given symbol is a file or a built-in,
        % then forward the call to componentOwningFile() or componentOwningBuiltin().
        % The input 'asymbol' is a string of a symbol.
        % The output 'cname' is a string of the component name.
        % The output is empty, if no component owns the given symbol.
            requiresChar(asymbol);
            
            w = which(asymbol);
            if ~isempty(strfind(w, ...
                    matlab.depfun.internal.requirementsConstants.BuiltInStr))
                cname = componentOwningBuiltin(obj, asymbol);
            else
                cname = componentOwningFile(obj, w);
            end
        end
        
        function cinfo = componentInfo(obj, acomponent)
        % Provide detailed information of the given product.
        % Inputs:
        %     'acomponent' is a string.
        % The output 'cinfo' is a struct of component information. 
        %     Each element contains the following information of a component:
        %         Name        - component name
        %         Type        - component type
        %         IsPrincipal - 1 (principal), 0 (not principal)
        %         BaseDir     - Based directory
        %         RetailMTF   - Retail MTF file
        %         SdkMTF      - SDK MTF file
        % The output is an empty struct, if the given component is unknown.
            requiresChar(acomponent);
            
            cinfo = struct([]);
            if ~isempty(acomponent)
                query = sprintf( ...
                        ['SELECT Component.ID, ' ...
                         '       Component_Type.Name, ' ...
                         '       Component.Is_Principal, ' ...
                         '       Component.Package_On_Release ' ...
                         'FROM Component, Component_Type, Path_Item ' ...
                         'WHERE Component.Name = ''%s'' ' ...
                         '  AND Component.Type = Component_Type.ID;'], acomponent);
                obj.doSql(query);
                result = obj.fetchRows();
                if ~isempty(result)
                    comp_id = result{1}{1};
                    comp_type = result{1}{2};
                    comp_isprincipal = logical(result{1}{3}); 
                    comp_pack_on_release = logical(result{1}{4}); 
                    
                    query = sprintf( ...
                            ['SELECT Path_Item.Location ' ...
                             'FROM Component, Path_Item ' ...
                             'WHERE Component.ID = %d ' ...
                             '  AND Component.Base_Dir = Path_Item.ID;'], comp_id);
                    obj.doSql(query);
                    comp_base = obj.fetchRow();
                    
                    query = sprintf( ...
                            ['SELECT Path_Item.Location ' ...
                             'FROM Component, Path_Item ' ...
                             'WHERE Component.ID = %d ' ...
                             '  AND Component.Retail_MTF = Path_Item.ID;'], comp_id);
                    obj.doSql(query);
                    comp_retail_mtf = obj.fetchRow();
                    
                    query = sprintf( ...
                            ['SELECT Path_Item.Location ' ...
                             'FROM Component, Path_Item ' ...
                             'WHERE Component.ID = %d ' ...
                             '  AND Component.SDK_MTF = Path_Item.ID;'], comp_id);
                    obj.doSql(query);
                    comp_sdk_mtf = obj.fetchRow();
                    
                    cinfo = struct('Name', acomponent, ...
                                   'Type', comp_type, ...
                                   'BaseDir', fullfile(matlabroot, comp_base), ...
                                   'IsPrincipal', comp_isprincipal, ...
                                   'RetailMTF', fullfile(matlabroot, comp_retail_mtf), ...
                                   'SdkMTF', fullfile(matlabroot, comp_sdk_mtf), ...
                                   'PackageOnRelease', comp_pack_on_release);
                end
            end
        end
        
        function clist = componentShippedByProduct(obj, aproduct)
        % Provide the transitive closure of components shipped by the given product.
        % The input 'aproduct' is a string of a product's internal name.
        % The output 'clist' is a cell array of strings. Each string is the name of a component. 
        % The output is an empty cell array, if no component is shipped by the given product.
            clist = {};
            
            requiresChar(aproduct);
            
            query = sprintf([ ...
                    'SELECT Component.Name ' ...
                    'FROM Component, Product_Component, Product ' ...
                    'WHERE Product.Internal_Name = ''%s'' ' ...
                    '  AND Product.ID = Product_Component.Product ' ...
                    '  AND Product_Component.Component = Component.ID;'],...
                    aproduct);
            obj.doSql(query);
            result = obj.fetchRows();
            if ~isempty(result)
                clist = cellfun(@(r)r{1},result,'UniformOutput',false);
            end
        end
        
        function clist = componentShippedByMCRProducts(obj)
        % Provide the transitive closure of components shipped by MCR products.
        % The input 'aproduct' is a string of a product's internal name.
        % The output 'clist' is a cell array of strings. Each string is the name of a component. 
        % The output is an empty cell array, if no component is shipped by the given product.

            import matlab.depfun.internal.requirementsConstants
            
            clist = {};
            
            query = sprintf(...
                    ['SELECT External_Product_ID ' ...
                     'FROM Product ' ...
                     'WHERE External_Product_ID >= %d ' ...
                     '  AND External_Product_ID <= %d;'], ...
                     requirementsConstants.mcr_pid_min, ...
                     requirementsConstants.mcr_pid_max);
            obj.doSql(query);
            result = obj.fetchRows();
            if ~isempty(result)
                mcr_pid = cellfun(@(r)r{1},result,'UniformOutput',false);

                num_MCR_products = numel(mcr_pid);
                clist = cell(1,num_MCR_products);
                query_temp = ...
                    ['SELECT Component.Name ' ...
                     'FROM Component, Product, Product_Component ' ...
                     'WHERE Product.External_Product_ID = %d ' ...
                     '  AND Product.ID = Product_Component.Product ' ...
                     '  AND Product_Component.Component = Component.ID;' ];

                for k = 1:num_MCR_products
                    query = sprintf(query_temp, mcr_pid{k});
                    obj.doSql(query);
                    result = obj.fetchRows();
                    if ~isempty(result)
                        clist{k} = cellfun(@(r)r{1},result,'UniformOutput',false);
                    end
                end
            end
        end
        
        function m2c = MatlabModuleToComponentMap(obj)
        % The output 'm2c' is a containers.map object.
        %     Each key is the string of the path of a MATLAB module.
        %     Each value is the owning component of the correspondent key.
            m2c = containers.Map;
            
            query = ['SELECT Path_Item.Location, Component.Name ' ...
                     'FROM Path_Item, Module_Type, Module, Component, Component_Module ' ...
                     'WHERE Module_Type.Name = ''MATLAB'' ' ...                     
                     '  AND Module_Type.ID = Module.Type ' ...
                     '  AND Module.Path = Path_Item.ID ' ...
                     '  AND Module.ID = Component_Module.Module ' ...
                     '  AND Component_Module.Component= Component.ID;'];
            obj.doSql(query);
            result = obj.fetchRows();
            if ~isempty(result)
                matlabModule = cellfun(@(r)r{1},result,'UniformOutput',false);
                owningComponent = cellfun(@(r)r{2},result,'UniformOutput',false);

                % Convert recorded canonical relative paths to platform-specific full path
                matlabModule = fullfile(matlabroot, matlabModule);

                % The map of MATLAB modules to their owning components
                m2c = containers.Map(matlabModule, owningComponent);
            end
        end

        function s2c = get.sourceToComponentMap(obj)
        % The output 's2c' is a containers.map object.
        %     Each key is the string of the path of a source entry.
        %     Each value is the owning component of the correspondent key.
            if isempty(obj.sourceToComponentMap)
                obj.sourceToComponentMap = containers.Map;

                query = ['SELECT Path_Item.Location, Component.Name ' ...
                         'FROM Path_Item, Source, Component, Component_Source ' ...
                         'WHERE Component_Source.Is_Excluded = 0 ' ...
                         '  AND Component_Source.Source = Source.ID ' ...
                         '  AND Source.Path = Path_Item.ID ' ...
                         '  AND Component_Source.Component = Component.ID;'];
                obj.doSql(query);
                result = obj.fetchRows();
                if ~isempty(result)
                    source = cellfun(@(r)r{1},result,'UniformOutput',false);
                    owningComponent = cellfun(@(r)r{2},result,'UniformOutput',false);

                    % Ignore non-released src directories and non-sense for
                    % performance.
                    % Shorter the list, faster the look-up.
                    % Relative to the matlab root.
                    fs = filesep;
                    non_released_src_dir = { ...
                         'Contents' ...
                         'cefclient' ...
                         'coreui' ...
                        ['doc' fs ] ...
                        ['external' fs] ...
                        ['foundation' fs] ...
                         'foundation_libraries' ...
                        ['help' fs] ...
                        ['install' fs] ...
                        ['java' fs 'src'] ...
                        ['licenses' fs] ...
                        ['makefiles' fs] ...
                        ['makerules' fs] ...
                        ['math' fs] ...
                        ['osinteg' fs] ...
                        ['platform' fs] ...
                        ['resources' fs] ...
                        ['src' fs] ...
                        ['standalone' fs] ...
                        ['test' fs] ...
                        ['tools' fs] ...
                        };

                    remove = false(size(source));
                    for k = 1:numel(non_released_src_dir)
                        remove = remove | ...
                                 strncmp(source, non_released_src_dir{k}, ...
                                         length(non_released_src_dir{k}));
                    end
                    source(remove) = [];
                    owningComponent(remove) = [];

                    % Add p-files for correspondent m-files.
                    mIdx = ~cellfun('isempty',regexp(source, '.+\.m$', 'ONCE'));
                    s_p = regexprep(source(mIdx), '\.m$', '.p');
                    c_p = owningComponent(mIdx);
                    source = [source  s_p];
                    owningComponent = [owningComponent  c_p];

                    % The map of MATLAB modules to their owning components
                    obj.sourceToComponentMap = containers.Map(source, owningComponent);
                end
            end

            s2c = obj.sourceToComponentMap;
        end

        function b2c = builtinToComponentMap(obj)
        % The output 'b2c' is a containers.map object.
        %     Each key is the string of a CXX built-in symbol.
        %     Each value is the owning component of the correspondent key.

            builtinSymbol = keys(obj.builtinRegistry);
            tmp = values(obj.builtinRegistry);
            tmp = [tmp{:}];
            owningComponent = {tmp.component};
            b2c = containers.Map(builtinSymbol, owningComponent);
        end
    end
    
    % ----- Public methods for querying module information -----
    methods
        function mpath = moduleOwningFile(obj, afullpath)
        % Find the owning MATLAB module of the given file.
        % The input 'afullpath' is a string, which must be the full path of the file.
        %
        % The output 'mpath' is the full path of the MATLAB module directory.
        % The output is empty, if no module owns the given file.
            requiresChar(afullpath);
        
            mpath = '';
            if exist(afullpath, 'file')
                apath = allowedPath(afullpath);
                apath = strrep(apath, [matlabroot filesep], '');
                apath = matlab.depfun.internal.PathNormalizer.processPathsForSql(apath);

                query = sprintf( ...
                    ['SELECT Path_Item.Location ' ...
                     'FROM Path_Item, Module ' ...
                     'WHERE Path_Item.Location = ''%s'' ' ...
                     '  AND Path_Item.ID = Module.Path;'], ...
                     apath);
                obj.doSql(query);
                % More than one products may ship the same file
                result = obj.fetchRow();
                if ~isempty(result)
                    mpath = fullfile(matlabroot, result);
                end
            end
        end
        
        function [mname, libfile] = moduleOwningBuiltin(obj, abuiltin)
        % Find the owning CXX module of the given CXX built-in.
        % The input 'abuiltin' is a string of a built-in symbol.
        % Outputs:   'mname' is the name of the CXX module and 
        %            'libfile' is the full path of the shared library file.
        % The outputs are empty, if no CXX module owns the given built-in.
            requiresChar(abuiltin);
            
            mname = '';
            if isKey(obj.builtinRegistry, abuiltin)
                mname = obj.builtinRegistry(abuiltin).module;
            end
            
            if nargout == 2
                libfile = '';
                if ~isempty(mname)
                    query = sprintf([ ...
                        'SELECT Path_Item.Location ' ...
                        'FROM Path_Item, Module, Module_Type ' ...
                        'WHERE Module.Name = ''%s'' ' ...
                        '  AND Module.Type = Module_Type.ID ' ...
                        '  AND Module_Type.Name = ''CXX'' ' ...
                        '  AND Module.Path = Path_Item.ID;'], ...
                        mname);
                    obj.doSql(query);                
                    result = obj.fetchRow();
                    if ~isempty(result)
                        libfile = fullfile(matlabroot, result);
                    end
                end
            end
        end
        
        function [mpath, mname] = moduleOwningSymbol(obj, asymbol)
        % Determine whether the given symbol is a file or a built-in,
        % then forward the call to moduleOwningFile() or moduleOwningBuiltin().
        % The input 'asymbol' is a string of a symbol.
        % Refer comments in moduleOwningFile() or moduleOwningBuiltin() for outputs. 
        % The outputs are empty, if no module owns the given symbol.

            requiresChar(asymbol);

            w = which(asymbol);
            if ~isempty(strfind(w, ...
                    matlab.depfun.internal.requirementsConstants.BuiltInStr))
                [mname, mpath] = moduleOwningBuiltin(obj, asymbol);
            else
                mname = '';
                mpath = moduleOwningFile(obj, w);
            end 
        end
        
        function dlist = directoryOwnedByComponent(obj, acomponent)
        % Provide a list of directories owned by the given component.
        % The input 'acomponent' is a string of component.
        % The output 'dlist' is a cell array of strings. Each string is full path of a directory. 
        % The output is an empty cell array, if no directory is owned by the given component.
            dlist = obj.moduleOwnedByComponent(acomponent, 'MATLAB');
        end
        
        function mlist = moduleOwnedByComponent(obj, acomponent, type)
        % Provide a list of modules of the given type owned by the given component.
        % Inputs: 'acomponent' is a string of component.
        %         'type' can be 'MATLAB', 'JAVA', or 'CXX'.  
        % The output 'mlist' is a cell array of strings. 
        %         For CXX, mlist is a list of CXX Module names.
        %         For MATLAB and JAVA, mlist is a list of paths.
        % The output is an empty cell array, 
        % if no module is owned by the given component or type is unknown.
            mlist = {};
            
            requiresChar(acomponent);
            
            module_types = { 'MATLAB' 'JAVA' 'CXX' };
            module_sig = { 'Path_Item.Location' 'Path_Item.Location' 'Module.Name' };
            
            typeIdx = strcmpi(type, module_types);
            goal = module_sig(typeIdx);
            if isempty(goal)
                return;
            else
                goal = goal{1};
            end
            
            query = sprintf( ...
                [ 'SELECT %s ' ...
                  'FROM Path_Item, Module, Module_Type, Component_Module, Component ' ...
                  'WHERE Module_Type.Name = ''%s'' ' ...
                  '  AND Module_Type.ID = Module.Type ' ...
                  '  AND Module.Path = Path_Item.ID ' ...
                  '  AND Module.ID = Component_Module.Module ' ...
                  '  AND Component_Module.Component = Component.ID ' ...
                  '  AND Component.Name = ''%s'';'], ...
                  goal, type, acomponent);
            obj.doSql(query);
            result = obj.fetchRows();
            if ~isempty(result)
                mlist = cellfun(@(r)r{1},result,'UniformOutput',false);
                if strcmp(goal, 'Path_Item.Location')
                    mlist = fullfile(matlabroot, mlist);
                end
            end
        end
        
        function mlist = MatlabModulesInMatlabRuntime(obj)
        % Provide a list of MATLAB Modules in the monolithic MATLAB Runtime.
        % Note that, this list must not be used as a scoped path, 
        % because the order of those modules is undefined here.
            import matlab.depfun.internal.requirementsConstants
            
            mlist = {};

            % All mcr products depend on mcr_numerics    
            pid_mcr_numerics = num2str(requirementsConstants.mcr_numerics_pid);
            query = ['SELECT Product.External_Product_ID ' ...
                     'FROM Product ' ...
                     'WHERE Product.ID IN ' ...
                     '  (SELECT Product_Dependency.Client ' ...
                     '   FROM Product, Product_Dependency ' ...
                     '   WHERE Product.External_Product_ID = ' pid_mcr_numerics ...
                     '     AND Product_Dependency.Service = Product.ID);'];
            obj.doSql(query);
            result = obj.fetchRows();
            result = cellfun(@(r)r{1},result,'UniformOutput',false);
            pid_str = [pid_mcr_numerics sprintf(',%d', result{:})];
    
            query = [ 'SELECT ID FROM Path_Item ' ...
                      'WHERE Location = ''N/A'' OR Location = ''N\A'';' ];
            obj.doSql(query);
            na_path_id = obj.fetchRow();
            
            query = [ 'SELECT Path_Item.Location ' ...
                      'FROM Path_Item, Module, Module_Type, Component_Module,' ...
                      '     Component, Product_Component, Product ' ...
                      'WHERE Module_Type.Name = ''MATLAB'' ' ...
                      '  AND Module_Type.ID = Module.Type ' ...
                      '  AND Module.Path = Path_Item.ID ' ...
                      '  AND Module.ID = Component_Module.Module ' ...
                      '  AND Component_Module.Component = Component.ID ' ...
                      '  AND Component.MCR_MTF != ' num2str(na_path_id) ...
                      '  AND Component.ID NOT IN ' ...
                      '      (SELECT Component FROM MCR_Exclude_List) ' ...
                      '  AND Product_Component.Component = Component.ID ' ...
                      '  AND Product_Component.Product = Product.ID ' ...
                      '  AND Product.External_Product_ID IN (' pid_str ');'];
            obj.doSql(query);
            result = obj.fetchRows();
            if ~isempty(result)
                result = cellfun(@(r)r{1},result,'UniformOutput',false)';
                mlist = [fullfile(matlabroot, 'toolbox/compiler/deploy'); fullfile(matlabroot, result)];                
            end
        end
        
        function mlist = scopedMatlabModuleListForProduct(obj, aproduct)
        % Provide a list of MATLAB Modules owned by components shipped by 
        % a given product and its upstream product(s).
        %
        % mcr view is used for mcr products.
        % retail view is used for other products.
        %
        % Note that, this list must not be used as a scoped path for a 
        % given product, because the order of those modules is undefined here.
            import matlab.depfun.internal.requirementsConstants
            
            requiresChar(aproduct);
            mlist = {};
            
            query = ['SELECT External_Product_ID '...
                     'FROM Product '...
                     'WHERE Internal_Name = ''' aproduct ''';'];
            obj.doSql(query);
            pid = obj.fetchRow();
            if isempty(pid)
                return; % Unknown product name
            end
            
            if pid >= requirementsConstants.mcr_pid_min ...
                && pid <= requirementsConstants.mcr_pid_max
                package_view = 'MCR';
                % Special undefined MATLAB Module
                % owned by component compiler_toolbox 
                mlist = { fullfile(matlabroot, 'toolbox/compiler/deploy')};
            else
                package_view = 'Retail';
            end
            
            pid_str = ['''' num2str(pid) ''''];
            % Get upstream product(s)
            pinfo = requiredProducts(obj, aproduct);            
            if ~isempty(pinfo)
                upstream_pid = {pinfo.extPID};
                pid_str = [pid_str sprintf(',%d', upstream_pid{:})];
            end
            
            query = [ 'SELECT ID FROM Path_Item ' ...
                      'WHERE Location = ''N/A'' OR Location = ''N\A'';' ];
            obj.doSql(query);
            na_path_id = obj.fetchRow();
            
            query = [ 'SELECT Path_Item.Location ' ...
                      'FROM Path_Item, Module, Module_Type, Component_Module,' ...
                      '     Component, Product_Component, Product ' ...
                      'WHERE Module_Type.Name = ''MATLAB'' ' ...
                      '  AND Module_Type.ID = Module.Type ' ...
                      '  AND Module.Path = Path_Item.ID ' ...
                      '  AND Module.ID = Component_Module.Module ' ...
                      '  AND Component_Module.Component = Component.ID ' ...
                      '  AND Component.' package_view '_MTF != ' num2str(na_path_id) ...
                      '  AND Component.ID NOT IN ' ...
                      '      (SELECT Component FROM MCR_Exclude_List) ' ...
                      '  AND Product_Component.Component = Component.ID ' ...
                      '  AND Product_Component.Product = Product.ID ' ...
                      '  AND Product.External_Product_ID IN (' pid_str ');'];
            obj.doSql(query);
            result = obj.fetchRows();
            if ~isempty(result)
                result = cellfun(@(r)r{1},result,'UniformOutput',false)';
                mlist = [mlist; fullfile(matlabroot, result)];
            end
        end
        
        function [blist, mname, liblist] = builtinOwnedByComponent(obj, acomponent)
        % Provide a list of built-ins owned by the given component.
        % The input 'acomponent' is a string of component.
        % Outputs:  'blist' is a cell array of strings. Each string is a built-in symbol.
        %           'mname' is the name of the CXX module that defines the
        %                   built-in.
        %           'liblist' is a cell array of strings. Each string is the full path of 
        %                     the library which defines the correspondent built-in. 
        % The output is an empty cell array, if no built-in is owned by the given component.
            requiresChar(acomponent);
            
            builtinSymbol = keys(obj.builtinRegistry);
            tmp = values(obj.builtinRegistry);
            tmp = [tmp{:}];
            owningComponent = {tmp.component};
            owningModule = {tmp.module};

            idx = strcmp(owningComponent, acomponent);                
            blist = builtinSymbol(idx);
            mname = owningModule(idx);
                
            if nargout == 3
                [~,liblist] = cellfun(@obj.moduleOwningBuiltin, blist, ...
                                      'UniformOutput', false);
            end
        end
        
        function [blist, mlist, clist, liblist] = builtinShippedByProduct(obj, aproduct)
        % Provide a list of built-ins owned by the given component.
        % The input 'aproduct' is a string of product.
        % Outputs:  'blist' is a cell array of strings. Each string is a built-in symbol.
        %           'mname' is the name of the CXX module that defines the
        %                   built-in.
        %           'liblist' is a cell array of strings. Each string is the full path of 
        %                     the library which defines the correspondent built-in. 
        % The output is an empty cell array, if no built-in is owned by the given component.
            requiresChar(aproduct);
            
            blist = {};
            mlist = {};
            clist = {};
            liblist = {};
            
            components = obj.componentShippedByProduct(aproduct);
            
            if ~isempty(components)
                builtinSymbol = keys(obj.builtinRegistry);
                tmp = values(obj.builtinRegistry);
                tmp = [tmp{:}];
                owningComponent = {tmp.component};
                owningModule = {tmp.module};
            
                for k = 1:numel(components)
                    idx = strcmp(owningComponent, components{k});
                    if any(idx)
                        sym = builtinSymbol(idx);
                        mod = owningModule(idx);
                        comp = owningComponent(idx);
                
                        blist = [blist sym]; %#ok
                        mlist = [mlist mod]; %#ok
                        clist = [clist comp]; %#ok
                    end
                end
                
                if nargout == 4
                    [~,liblist] = cellfun(@obj.moduleOwningBuiltin, blist, ...
                                          'UniformOutput', false); 
                end
            end
        end
        
    end
        
    % ----- Public methods for executing native SQLite commands -----
    methods
        function doSql(obj, SqlCmd)
        % Pass the native SQLite command to the instance of 
        % class matlab.depfun.internal.database.SqlDbConnector.
            obj.SqlDBConnObj.doSql(SqlCmd);
        end
        
        function result = fetchRow(obj)
        % Fetch a row of the result returned by the instance of 
        % class matlab.depfun.internal.database.SqlDbConnector.
            result = obj.SqlDBConnObj.fetchRow();
        end
            
        function result = fetchRows(obj)
        % Fetch the complete result returned by the instance of 
        % class matlab.depfun.internal.database.SqlDbConnector.
            result = obj.SqlDBConnObj.fetchRows();
        end
    end
            
    % ----- Getter for builtinRegistry ------
    methods
        function map = get.builtinRegistry(obj)
        % Key - built-in symbol names
        % Value - a struct contains built-in type, toolbox location, owning
        % component name, owning module name.
        % (Other info in raw_data is not used at this point.)
        % If thre are more than one built-ins with the same name, the first
        % one on the MATLAB search path is returned.
            
            if isempty(obj.builtinRegistry)
                % Built-in registry returned by MATLAB dispatcher.
                % It contains built-ins from products available to the
                % current MATLAB.
                % Currently, there is no C++ API to create containers.Map,
                % so the raw data is stored in a struct array.
                raw_data = matlab.depfun.internal.builtinInfo();

                srchPth = strsplit(path, pathsep);
                srchPthTbl = containers.Map(srchPth, 1:numel(srchPth));

                % Create the output table
                obj.builtinRegistry = containers.Map;

                numSym = numel(raw_data);
                toolbox_root = obj.env.FullToolboxRoot;
                fs = filesep;
                builtin_type = containers.Map({0 1 2}, ...
                                              {matlab.depfun.internal.MatlabType.BuiltinFunction ...
                                               matlab.depfun.internal.MatlabType.BuiltinPackage ...
                                               matlab.depfun.internal.MatlabType.BuiltinClass});

                for k=1:numSym
                    symbol = raw_data(k).name;
                    symbolAttributes = raw_data(k).attributes;                    
                    path_entry = '';
                    if ~isempty(symbolAttributes.toolbox_loc)
                        path_entry = [toolbox_root fs symbolAttributes.toolbox_loc];
                    end

                    % Duplicate symbol?
                    if isKey(obj.builtinRegistry, symbol)
                    % Choose the builtin with a location, if possible.
                    % (Always write over empty locations.)
                        curSymData = obj.builtinRegistry(symbol);
                        curPathEntry = curSymData.path_entry;                        
                        if isempty(curPathEntry)
                            obj.builtinRegistry(symbol) = assembleSymData;
                        else
                            % Both have a location -- choose the location 
                            % that's first on the path.
                            idxCur = [];
                            if ~isempty(curPathEntry) && isKey(srchPthTbl, curPathEntry)
                                idxCur = srchPthTbl(curPathEntry);
                            end
                            
                            idxNew = [];
                            if ~isempty(path_entry) && isKey(srchPthTbl, path_entry)
                                idxNew = srchPthTbl(path_entry);
                            end

                            % If current location is not on the path, or current
                            % location occurs AFTER new location on the path,
                            % replace the current location with the new one.
                            if isempty(idxCur) || (~isempty(idxNew) && ...
                                                   idxNew < idxCur)
                                obj.builtinRegistry(symbol) = assembleSymData;
                            end
                        end
                    else
                        % New symbol. Add it to the table.
                        obj.builtinRegistry(symbol) = assembleSymData;
                    end
                end
            end

            map = obj.builtinRegistry;
            
            function symData = assembleSymData()
                symData.type = builtin_type(symbolAttributes.builtin_type);
                symData.module = symbolAttributes.module;
                symData.component = symbolAttributes.component;
                symData.path_entry = path_entry;
                
                loc = path_entry;
                if ~isempty(path_entry)
                    if ~isempty(symbolAttributes.class_type) && ~strcmp(symbolAttributes.class_type, ':all:')
                        loc = [path_entry fs '@' symbolAttributes.class_type];
                    end
                end
                symData.loc = loc;
            end
        end
    end
end

%--------------------------------------------------------------------------
% Local helper functions
%--------------------------------------------------------------------------
function filter = perTargetProductFilter(target)
    import matlab.depfun.internal.requirementsConstants
    import matlab.depfun.internal.Target
    
    if ischar(target)
        tgt = matlab.depfun.internal.Target.parse(target);
        if (tgt == matlab.depfun.internal.Target.Unknown)
            error(message('MATLAB:depfun:req:BadTarget', target));
        end
    elseif isa(target, 'matlab.depfun.internal.Target')
        tgt = target;
    else
        error(message('MATLAB:depfun:req:InvalidInputType',...
              1,class(target),'char or matlab.depfun.internal.Target'));
    end

    switch tgt
        case Target.MCR
            filter = sprintf( ...
                ['AND (Product.External_Product_ID >= %d ' ...
                 'AND Product.External_Product_ID <= %d)'], ...
                 requirementsConstants.mcr_pid_min, ...
                 requirementsConstants.mcr_pid_max );
        case {Target.MATLAB Target.PCTWorker Target.Deploytool}
            filter = sprintf( ...
                ['AND ((Product.External_Product_ID < %d ' ...
                 'OR Product.External_Product_ID > %d) ' ...
                 'AND Product.External_Product_ID != %d)'], ...
                 requirementsConstants.mcr_pid_min, ...
                 requirementsConstants.mcr_pid_max, ...
                 requirementsConstants.full_mcr_pid );
        otherwise % NONE target, etc.
            filter = '';
    end
end

%--------------------------------------------------------------------------
function allowed_path = allowedPath(apath)
% This function turns a full path into a path prefix suitable for 
% the MATLAB path. Since @, +, and private directories cannot appear 
% directly on the MATLAB path, this function removes them from the 
% returned path prefix.

    At_Plus_Private_Idx = at_plus_private_idx(apath);
    if ~isempty(At_Plus_Private_Idx)
        allowed_path = apath(1:At_Plus_Private_Idx-1);
    else
        if exist(apath,'dir')
            allowed_path = apath;
        else
            [allowed_path,~,~] = fileparts(apath);
        end
    end
end

%--------------------------------------------------------------------------
function product_list = productList(rawData)
    product_list = struct([]);
    if ~isempty(rawData)
        internal_name = cellfun(@(r)r{1},rawData,'UniformOutput',false);
        external_name = cellfun(@(r)r{2},rawData,'UniformOutput',false);
        external_pid = cellfun(@(r)double(r{3}),rawData,'UniformOutput',false);
        version = cellfun(@(r)r{4},rawData,'UniformOutput',false);
        license_name = cellfun(@(r)r{5},rawData,'UniformOutput',false);

        product_list = struct('intPName', internal_name, ...
                              'extPName', external_name, ...
                              'extPID', external_pid, ...
                              'version', version, ...
                              'LName', license_name);
    end
end

%--------------------------------------------------------------------------
function requiresChar(avariable)
    if ~ischar(avariable)
        error(message('MATLAB:depfun:req:InvalidInputType',...
                      1,class(avariable),'char'));
    end
end