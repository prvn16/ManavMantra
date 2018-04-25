classdef appbuilder < handle
    %   Creates the appbuilder object.
    %   This class runs error checks on the input files, gets a dependency list
    %   of all the MATLAB files and invokes the built-in to create the MLAPP.
    %
    %   appbuilder Properties:
    %   Name                - Name of the App being created.
    %   EntryPoint          - Entry point file for the App
    %   Version             - MATLAB App version number (string).
    %   FileList            - Cell array of all the user defined files picked
    %                         up by depfun.
    %   ToolboxFiles        - MATLAB Toolbox files picked up by DEPFUN.
    % 	UserPath            - Cell arrays of all paths to user defined MATLAB
    %                         files relative to the entry point file.
    %   MetadataStruct      - MATLAB Struct containing all the metadata to be
    %                         inserted into the appProperties file.
    %   GUID                - GUID for the MATLAB App.
    %   Platforms           - Platforms supported by the MATLAB App. Based on
    %                         user defined MEX files.
    %   Summary             - A brief summary of the MATLAB App.
    %   Description         - A detailed description of the MATLAB APP
    %   AuthorName
    %   AuthorEmail
    %   AuthorCompany
    %   AdditionalFiles     - A list of additional resource files to be added
    %                         to the package
    %   AppIcon             - Icon to be displayed in the App Gallery
    %   AppScreenshot
    %   Varargin
    %     AppScaledIcons    - List of the icons to be displayed in:
    %                         1. Reinstall dialog
    %                         2. App Gallery and tooltip
    %                         3. Quick Access toolbar
    %     GUID              - Unique GUID
    %
    %   appbuilder Methods
    %   build                     - Calls the built-in mlappbuild to create the
    %                               MLAPP file with appropriate files and metadata.
    %   errorCheck                - Will check for errors in finding files and
    %                               file formats for the entry point file.
    %   createAppManifestStruct   - Creates a MATLAB structure with all the
    %                               meta data needed by the appProperties.xml file.
    %
    %   Copyright 2012-2016 The MathWorks, Inc.
    %
    properties (SetAccess = private)
        Name;
        Path;
        Extension;
        EntryPoint;
        Version;
        FileList;
        ToolboxFiles;
        UserPath;
        MetadataStruct;
        GUID;
        Platforms;
        Summary;
        Description;
        AuthorName;
        AuthorEmail;
        AuthorCompany;
        AppIcon;
        AppScaledIcons;
        AppScreenshot;
        ProductInfo;
    end
    properties (Constant, Access=private)
        % Used to standardize file paths in the mlappinstall file across
        % platforms.
        NormalizedFileSep = '/';
    end
    
    methods
        %-----------------------------------
        %   appbuilder class public methods
        %-----------------------------------
        function obj = appbuilder(appname, entrypointfile, fileslist, ...
                product, platforms, appversion, summary, description, ...
                authorname, authorcontact, authorcompany, appicon, ...
                appscreenshot, varargin)%testGUID)
            try
                [obj.Path, obj.Name, obj.Extension] = fileparts(appname);
                [~, entryPoint, ~] = fileparts(entrypointfile);
                obj.EntryPoint = entryPoint;
                obj.Version = appversion;
                obj.AppIcon = appicon;
                obj.AppScreenshot = appscreenshot;
                
                % varargin can be the set of icons, the GUID, or both
                if (isempty(varargin) || numel(varargin) == 1 && isempty(varargin{1}))
                    % No icon or GUID provided
                    obj.AppScaledIcons = {};
                    obj.GUID = char(java.util.UUID.randomUUID);
                elseif (numel(varargin) == 1 && isa(varargin{1},'java.util.List'))
                    % Icons provided
                    gatherIconFiles(obj, varargin{1});
                    obj.GUID = char(java.util.UUID.randomUUID);
                elseif (numel(varargin) == 1)
                    % GUID provided
                    obj.AppScaledIcons = {};
                    obj.GUID = varargin{1};
                else
                    % Both provided
                    if (isa(varargin{1},'java.util.List'))
                        gatherIconFiles(obj, varargin{1});
                        obj.GUID = varargin{2};
                    else
                        obj.GUID = varargin{1};
                        gatherIconFiles(obj, varargin{2});
                    end
                end
                obj.Summary = summary;
                obj.Description = description;
                obj.AuthorName = authorname;
                obj.AuthorEmail = authorcontact;
                obj.AuthorCompany = authorcompany;
                if(~isempty(appscreenshot))
                    errorCheck(obj, entrypointfile, appscreenshot);
                else
                    errorCheck(obj, entrypointfile);
                end
                if(isempty(fileslist))
                    %Invoked from buildapp; filelist is empty
                    [depfileslist, depproductname, depproductversion, depproductid, platforms] = matlab.depfun.internal.DependencyFormatter.apptoolDependenciesFlattened(entrypointfile);
                    obj.FileList = depfileslist;
                    obj.Platforms = platforms;
                    obj.UserPath = appcreate.internal.appbuilder.getuniquepaths(depfileslist);
                    for i=1:numel(depproductname)
                        %                         ProductInfo is stored as a cell array with the
                        %                         elements in the following order {'Product ID' 'Product Name' 'Product Version'}
                        obj.ProductInfo{i,1} = {mat2str(cell2mat(depproductid(i))), cell2mat(depproductname(i)), cell2mat(depproductversion(i))};
                    end
                else
                    % Invoked from the UI 
                    % if the user adds a folder the list will contain the
                    % contents of the folder as well as the folder itself
                    % iterate through the filelist and remove any "folders"
                    % so that the list of just of files
                    initialFileList = cell(fileslist);
                    areFiles = cellfun (@(x) exist(x, 'dir'), initialFileList) ~= 7;
                    
                    obj.FileList = initialFileList(areFiles);
                    obj.UserPath = appcreate.internal.appbuilder.getuniquepaths(obj.FileList);
                    obj.Platforms = cell(platforms);
                    
                    for i=1:numel(product.name)
                        productid = product.id(i);
                        if isa(productid, 'double')
                            productid = mat2str(productid);
                        end
                        %                         ProductInfo is stored as a cell array with the
                        %                         elements in the following order {'Product ID' 'Product Name' 'Product Version'}
                        obj.ProductInfo{i,1} = {char(productid), char(product.name(i)), char(product.ver(i))};
                    end
                end
                createAppManifestStruct(obj);
            catch exception
                throw(exception);
            end
        end
        
        function build(appobj)
            extension = '.mlappinstall';
            if(numel(appobj.Path) > 0)
                fileName = [appobj.Path filesep appobj.Name];
            else
                fileName = appobj.Name;
            end
            if(isempty(regexp(fileName, [extension '$'])))
                fileName = [fileName extension];
            end
            
            archivepaths = cellfun(@(x) appcreate.internal.appbuilder.trimLeadingFileSep(x),appobj.UserPath,'UniformOutput', 0);
            mlappbuild(fileName, appobj.FileList, archivepaths, appobj.MetadataStruct);
            
        end
    end
    
    methods(Static)
        
        function alluniquepaths = getuniquepaths(depfileslist)

            % normalize any crazy file separators
            nDepFileList = cellfun(@(x)(fullfile(x)),depfileslist,'UniformOutput',0);
            
            %split each entry into separate strings per folder
            allFolders=cellfun(@(x)(regexp(x,filesep,'split')),nDepFileList,'UniformOutput',0);
            
            %find common parent directory, remove it from unique paths
            allFolders=appcreate.internal.appbuilder.findCommonFilePath(allFolders,filesep);
            alluniquepaths=cellfun(@(x) appcreate.internal.appbuilder.createFinalPath(x),allFolders,'UniformOutput', 0);
            alluniquepaths = appcreate.internal.appbuilder.normalizeFileSep(alluniquepaths)';
            alluniquepaths = appcreate.internal.appbuilder.washSpecialCharactersInPath(alluniquepaths)';
        end
        
         function filepath=trimLeadingFileSep(filepath)
            if isempty(filepath)
                return;
            end
            
            if(filepath(1) == appcreate.internal.appbuilder.NormalizedFileSep)
                filepath(1) = [];
            end
        end
        
        function filepath=washSpecialCharactersInPath(filepath)
            if isempty(filepath)
                return;
            end
            %change the invalid path character: ':', to an uncommon string: '$'
            filepath =regexprep(filepath,':', '__');
        end
        
        %converts a split filepath to a string filepath
        function uniquepath=createFinalPath(currentFilePath)
            currentFilePath(:)=strcat(filesep,currentFilePath(:));
            uniquepath=(strcat(currentFilePath{:}));
        end
        
        %allFolders contains split file paths. Each row is a different
        %file. This function compares values in each column to determine a
        %common parent folder for all the files.
        function [newAllFolders, commonPath]=findCommonFilePath(allFolders,commonPath)
            numberOfFiles=max(size(allFolders));
            
            % g1135849
            % changing from max length to min length since it doesn't make much 
            % sense to compare beyond the shortest path

            % Since this stops at min - 1 it also guarantees all of the
            % resulting cell arrays in newAllFolders will be non-empty
            
            % input of 
            % {1}   {2}   {3}
            % c:/   foo   bar.m
            % c:/   foo
            
            % results in 
            % {1}   {2}   
            % foo   bar.m
            % foo
            %------------
            % input of 
            % {1}   {2}   {3}
            % c:/   foo   bar.m
            % c:/   foo   foo.m
            
            % results in 
            % {1}      
            % bar.m
            % foo.m
            %------------
            % input of 
            % {1}   {2}   {3}
            % c:/   foo   bar.m
            % c:/   bar   foo.m
            
            % results in 
            % {1}   {2}   
            % foo   bar.m
            % bar   foo.m
            
            %------------
            % input of 
            % {1}   {2}   {3}
            % c:/   foo   bar.m
            % c:/   bar
            
            % results in 
            % {1}   {2}   
            % foo   bar.m
            % bar
            
            minLength=min(arrayfun(@(x) size(allFolders{x},2),(1:numberOfFiles)));
                for index=1:(minLength-1)
                    %store each column in a temporary structure
                    allCol=arrayfun(@(x) allFolders{x}(min(index,size(allFolders{x},2))),(1:numberOfFiles),'UniformOutput', 0);
                    %if all values are the same, then remove this column
                    %from the output file paths
                    %windows is a case insensitive platform so casing differences
                    %shouldn't cause 'C:/' to be different from 'c:/' 
                    comparisonFunction=@strcmp;
                    if(ispc)
                       comparisonFunction=@strcmpi; 
                    end
                    if all(comparisonFunction([allCol{1}],[allCol{:}]));
                        commonPath=fullfile(commonPath,[allCol{1}]);
                        newAllFolders=arrayfun(@(x) allFolders{x}(index+1:size([allFolders{x}],2)),(1:numberOfFiles),'UniformOutput', 0);
                    else
                        if index==1
                            newAllFolders=allFolders;
                        end
                        return;
                    end
                end
        end
        
        function filepath = removeCommonPath(filepath, uniquepath)
            pathcount = numel(uniquepath);
            for i=1:pathcount
                len = length(char(uniquepath(i)));
                filepath = cellfun(@(x)  appcreate.internal.appbuilder.replacepath( uniquepath{i}, x, len), filepath, 'UniformOutput', false);
            end
        end
        
        function filepath = replacepath(commonpath, filepath, len)
            if(strncmpi(commonpath, filepath, len))
                filepath = filepath(len+1:end);
                if(~strncmpi(filepath,filesep,1))
                    filepath = strcat(filesep, filepath);
                end
            end
        end
        
        function filepath = normalizeFileSep(filepath)
            if isempty(filepath)
                return;
            end
            
            % ssegench 2014-09-09
            % changing the regexp from [[\\][/]]* to use the platform
            % specific file separator
            
            % the file separator could be a special character in regexp so
            % escape it
   
            sep = regexptranslate('escape', filesep);
            
            % calling fullfile on filepath ensures the input has the
            % platform specific file separator
            filepath =regexprep(fullfile(filepath),['[' sep ']+'], appcreate.internal.appbuilder.NormalizedFileSep);
        end
        
        function filepath = denormalizeFileSep(filepath)
            if isempty(filepath)
                return;
            end
            filepath = strrep(filepath, appcreate.internal.appbuilder.NormalizedFileSep, filesep);
        end
        
        function [success, msg] = isValidMainFile(filename)
            try
                [success, reason] = matlab.depfun.internal.isdeployable(filename, 'MATLAB', true);
                if( success)
                    msg = '';
                else
                    switch reason.identifier
                        case {'MATLAB:depfun:req:BuiltinEntryPoint', ...
                                'MATLAB:depfun:req:ExpectedBy', ...
                                'MATLAB:depfun:req:ExcludedBy'}
                            msg = getString(message('MATLAB:apps:errorcheck:MathWorksEntryPoint', filename));
                        case 'MATLAB:depfun:req:ScriptEntryPoint'
                            [~,functionName,~]=fileparts(filename);
                            msg = getString(message('MATLAB:apps:errorcheck:ScriptEntryPoint',filename, filename, functionName));
                        case 'MATLAB:depfun:req:NonFunctionEntryPoint'
                            msg = getString(message('MATLAB:apps:errorcheck:NonFunctionEntryPoint',filename));
                        otherwise
                            msg = getString(message('MATLAB:apps:errorcheck:GenericErrorWithEntryPoint',...
                                filename, reason.message));
                    end
                end
            catch ME
                success = false;
                msg = getString(message('MATLAB:apps:errorcheck:UnknownErrorWithEntryPoint',...
                    filename, ME.message));
            end
        end
        
        function [f,msg] = filesNotToPackage(varargin)
            f=[]; msg='';
            try
                isDeployableFunc=@(x) matlab.depfun.internal.isdeployable(x, 'MATLAB', false);
                [allSuccess,allMessages]=cellfun(isDeployableFunc,varargin,'UniformOutput',0);
                
                success=cell2mat(arrayfun(@(x) all(cell2mat(x)),allSuccess,'UniformOutput',0));
                invalidInputs=cell2mat(arrayfun(@(x) (isempty(cell2mat(x))),allSuccess,'UniformOutput',0));
                success(find(invalidInputs))=0;%all (AND) returns 'true' on empty sets, change to 'false'
                
                func=@(x) (strcmp(x.identifier,'MATLAB:depfun:req:ExpectedBy'));
                comparisonResult=arrayfun(func, cell2mat(allMessages),'UniformOutput',0);
                
                if (any(cell2mat(comparisonResult)))
                    f=varargin(~success);
                    msg = getString(message('MATLAB:apps:errorcheck:CannotPackageMathWorksFiles'));
                elseif( any(~success) )
                    f=varargin(~success);
                    allErrorMessages = cellfun(@(x) (x.identifier),allMessages(~success),'UniformOutput',0);
                    msg=allErrorMessages{1};
                end
            catch ME
                f = varargin;
                msg = getString(message('MATLAB:apps:errorcheck:UnknownErrorWithIsdeployed', ME.message));
            end
        end
    end
    
    methods (Access = 'private')
        %------------------------------------
        %   appbuilder class private methods
        %------------------------------------
        
        function gatherIconFiles(obj, appScaledIcons)
            if (appScaledIcons.isEmpty)
                obj.AppScaledIcons = {};
            else
                for i=0:appScaledIcons.size-1
                    obj.AppScaledIcons = [obj.AppScaledIcons {appScaledIcons.get(i)}];
                end
            end
        end
        
        function errorCheck(~, varargin)
            %             inputfiles = varargin(1);
            fileexist = arrayfun(@(x)exist(cell2mat(x), 'file'), varargin);
            if(~all(fileexist))
                [~, c, ~] = find(fileexist == 0);
                error(message('MATLAB:apps:errorcheck:FileNotFound', varargin{c}));
            end
        end
        
        function mexfile = evalSupportedPlatforms(~, ext)
            foundmex = ext(strncmp(ext, '.mex', 3));
            if(size(foundmex,1))
                allmexfile = cell(size(foundmex,1),1);
                for i = 1:size(foundmex,1)
                    switch foundmex{i}
                        case '.mexw32'
                            allmexfile{i} = 'win32';
                        case '.mexw64'
                            allmexfile{i} = 'win64';
                        case '.mexmaci'
                            allmexfile{i} = 'maci64';
                        case '.mexa64'
                            allmexfile{i} = 'glnxa64';
                    end
                end
                mexfile = unique(allmexfile);
            else
                % No MEX files found by depfun
                mexfile = {''};
            end
        end
        
        function createAppManifestStruct(obj, varargin)
            v = ver('MATLAB');
            obj.MetadataStruct  = struct('entryPoint', obj.EntryPoint...
                ,'name', obj.Name...
                ,'version', num2str(obj.Version)...
                ,'createdByMATLABRelease',char(v.Release)...
                ,'GUID', obj.GUID...
                ,'summary', obj.Summary...
                ,'description', obj.Description...
                ,'authorName',obj.AuthorName...
                ,'authorContact',obj.AuthorEmail...
                ,'authorOrganization',obj.AuthorCompany...
                ,'supportedPlatforms',{obj.Platforms}...
                ,'requiredProducts',{obj.ProductInfo}...
                ,'appEntries',{obj.UserPath}...
                ,'numFiles',num2str(numel(obj.UserPath))...
                ,'appIcon',obj.AppIcon...
                ,'appScaledIcons',{obj.AppScaledIcons}...
                ,'appScreenShot',obj.AppScreenshot...
                );
        end
    end
end
