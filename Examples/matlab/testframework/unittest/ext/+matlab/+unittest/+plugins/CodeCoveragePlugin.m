classdef CodeCoveragePlugin < matlab.unittest.internal.plugins.CodeCoverageCollectionPlugin & ...
                                matlab.unittest.internal.mixin.CoverageFormatMixin
    % CodeCoveragePlugin - Plugin to produce code coverage results.
    %
    %   The CodeCoveragePlugin can be added to the TestRunner to produce
    %   code coverage results for MATLAB source code. The results show
    %   which lines of code were executed by the tests that were run. The
    %   coverage results are based on source code located in one or more
    %   files, folders or packages.
    %
    %   The CodeCoveragePlugin relies on the MATLAB profiler to determine the
    %   lines of code executed by the tests. Neither the tests nor the source
    %   code should interact with the profiler. Also note that the plugin
    %   clears any data collected by the profiler before running a suite of
    %   tests. To produce valid coverage results, the source code being
    %   measured must be on the path throughout the entire test suite run.
    %
    %   CodeCoveragePlugin methods:
    %       forFolder  - Construct a CodeCoveragePlugin for reporting on one or more folders.
    %       forPackage - Construct a CodeCoveragePlugin for reporting on one or more packages.
    %       forFile    - Construct a CodeCoveragePlugin for reporting on one or more files.
    %
    %   Example:
    %
    %       import matlab.unittest.TestRunner;
    %       import matlab.unittest.TestSuite;
    %       import matlab.unittest.plugins.CodeCoveragePlugin;
    %       import matlab.unittest.plugins.codecoverage.CoberturaFormat;
    %
    %       % Create a TestSuite array
    %       suite = TestSuite.fromClass(?myproj.MyTestClass);
    %       % Create a TestRunner with no plugins
    %       runner = TestRunner.withNoPlugins;
    %
    %       % Add a new plugin to the TestRunner
    %       runner.addPlugin(CodeCoveragePlugin.forFolder('C:\projects\myproj'));
    %
    %       % Run the suite. A report is opened upon completion of testing.
    %       result = runner.run(suite)       
    %
    %       % Create a new TestRunner instance with no plugins
    %       runner = TestRunner.withNoPlugins;
    %
    %       % Add a new plugin to the TestRunner with a coverage format
    %       runner.addPlugin(CodeCoveragePlugin.forPackage('myproj.sources',...
    %            'Producing',CoberturaFormat('CoverageResults.xml')));
    %
    %       % Run the suite. Code coverage results conforming to the Cobertura XML format are
    %       % generated in 'CoverageResults.xml' after testing.
    %       result = runner.run(suite)
    %
    %   See also: TestRunnerPlugin, profile
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    properties (Access=private)
        % Sources - a matlab.unittest.internal.coverage.Sources instance.
        % Stores information about the source.
        Sources
        
    end
    
    
    methods (Static)
        function plugin = forFolder(folder, varargin)
            % forFolder  - Construct a CodeCoveragePlugin for reporting on one or more folders.
            %
            %   PLUGIN = matlab.unittest.plugins.CodeCoveragePlugin.forFolder(FOLDER)
            %   constructs a CodeCoveragePlugin and returns it as PLUGIN. The plugin
            %   reports on the source code residing inside FOLDER. FOLDER is the
            %   absolute or relative path to one or more folders, specified as a 
            %   character vector, string array, or cell array of character
            %   vectors.
            %
            %   PLUGIN = matlab.unittest.plugins.CodeCoveragePlugin.forFolder(FOLDER, 'IncludingSubfolders',true)
            %   constructs a CodeCoveragePlugin and returns it as PLUGIN. The plugin
            %   reports on the source code residing inside FOLDER and all its
            %   subfolders. FOLDER is the absolute or relative path to one or more
            %   folders, specified as a character vector, string array, or cell
            %   array of character vectors.
            %
            %   PLUGIN = matlab.unittest.plugins.CodeCoveragePlugin.forFolder(FOLDER,'Producing',FORMAT)
            %   constructs a CodeCoveragePlugin that generates code coverage results in
            %   the style specified by FORMAT. FORMAT is an instance of a class in the
            %   matlab.unittest.plugins.codecoverage package.
            %
            %   Example:
            %       import matlab.unittest.plugins.CodeCoveragePlugin;
            %       plugin = CodeCoveragePlugin.forFolder('C:\projects\myproj');
            %
            %   See also: forPackage, forFile
            
            import matlab.unittest.internal.folderResolver;
            import matlab.unittest.plugins.codecoverage.ProfileReport;
            import matlab.unittest.internal.coverage.Folder;
            
            parser = matlab.unittest.internal.strictInputParser;
            parser.addRequired('folder', @validateFolder);
            parser.addParameter('IncludingSubfolders',false, @(x)validateIncludeSub(x,'IncludingSubfolders'));
            parser.addParameter('IncludeSubfolders',false, @(x)validateIncludeSub(x,'IncludeSubfolders')); % supported alias
            parser.addParameter('Producing',ProfileReport, @(x)validateReportFormat(x));
            parser.parse(folder, varargin{:});
            
            checkForOverdeterminedParameters(parser,'IncludingSubfolders','IncludeSubfolders');
            
            folders = cellstr(parser.Results.folder);
            folders = cellfun(@folderResolver, folders, 'UniformOutput',false);
            
            if parser.Results.IncludingSubfolders || parser.Results.IncludeSubfolders
                folders = findAllSubfolders(folders);
            end
            
            format = parser.Results.Producing;
            folders = addClassAndPrivateFolders(folders);
            foldersObj = Folder(folders);
            plugin = matlab.unittest.plugins.CodeCoveragePlugin(foldersObj,'Producing',format);
        end
        
        function plugin = forPackage(package, varargin)
            % forPackage  - Construct a CodeCoveragePlugin for reporting on one or more packages.
            %
            %   PLUGIN = matlab.unittest.plugins.CodeCoveragePlugin.forPackage(PACKAGE)
            %   constructs a CodeCoveragePlugin and returns it as PLUGIN. The plugin
            %   reports on the source code that makes up PACKAGE. PACKAGE is a
            %   character vector, string array, or cell array of character
            %   vectors containing the name of one or more packages.
            %
            %   PLUGIN = matlab.unittest.plugins.CodeCoveragePlugin.forPackage(PACKAGE, 'IncludingSubpackages',true)
            %   constructs a CodeCoveragePlugin and returns it as PLUGIN. The plugin
            %   reports on the source code that makes up PACKAGE and all its
            %   subpackages. PACKAGE is a character vector, string array, or cell
            %   array of character vectors containing the name of one or more
            %   packages.
            %
            %   PLUGIN = matlab.unittest.plugins.CodeCoveragePlugin.forPackage(PACKAGE,'Producing',FORMAT)
            %   constructs a CodeCoveragePlugin that generates code coverage results in
            %   the style specified by FORMAT. FORMAT is an instance of a class in the
            %   matlab.unittest.plugins.codecoverage package.
            %
            %   Example:
            %       import matlab.unittest.plugins.CodeCoveragePlugin;
            %       plugin = CodeCoveragePlugin.forPackage('myproject.controller');
            %
            %   See also: forFolder, forFile
            
            import matlab.unittest.plugins.codecoverage.ProfileReport;
            import matlab.unittest.internal.coverage.Folder;
            
            parser = matlab.unittest.internal.strictInputParser;
            parser.addRequired('package', @validatePackage);
            parser.addParameter('IncludingSubpackages',false, @(x)validateIncludeSub(x,'IncludingSubpackages'));
            parser.addParameter('IncludeSubpackages',false, @(x)validateIncludeSub(x,'IncludeSubpackages')); % supported alias
            parser.addParameter('Producing',ProfileReport, @(x)validateReportFormat(x));
            parser.parse(package, varargin{:});
            
            checkForOverdeterminedParameters(parser,'IncludingSubpackages','IncludeSubpackages');
            
            packages = cellstr(parser.Results.package);
            
            if parser.Results.IncludingSubpackages || parser.Results.IncludeSubpackages
                packages = findAllSubpackages(packages);
            end
            
            % Build up the list of all the folders that define all the packages.
            folders = cell(1, numel(packages));
            for idx = 1:numel(packages)
                folderName = ['+', strrep(packages{idx}, '.', [filesep, '+'])];
                info = what(folderName);
                
                % The package may not exist or it may contain only built-in code.
                % In either case, WHAT returns an empty struct.
                if isempty(info)
                    error(message('MATLAB:unittest:CodeCoveragePlugin:PackageDoesNotExist',packages{idx}));
                end
                
                folders{idx} = {info.path};
            end
            
            format = parser.Results.Producing;
            folders = addClassAndPrivateFolders([folders{:}]);
            foldersObj = Folder(folders);
            plugin = matlab.unittest.plugins.CodeCoveragePlugin(foldersObj,'Producing',format);
        end
        
        function plugin = forFile(file,varargin)
            % forFile  - Construct a CodeCoveragePlugin for reporting on one or more files.
            %
            %   PLUGIN = matlab.unittest.plugins.CodeCoveragePlugin.forFile(FILE,'Producing',FORMAT)
            %   constructs a CodeCoveragePlugin and returns it as PLUGIN. The plugin
            %   reports the code coverage for FILE. FILE is the absolute or relative
            %   path to one or more .m or .mlx files, specified as a character vector,
            %   string array, or cell array of character vectors. The plugin generates
            %   code coverage results in the style specified by FORMAT. FORMAT is an
            %   instance of matlab.unittest.plugins.codecoverage.CoberturaFormat class.
            %
            %   Example:
            %       import matlab.unittest.plugins.CodeCoveragePlugin;
            %       import matlab.unittest.plugins.codecoverage.CoberturaFormat;
            %
            %       plugin = CodeCoveragePlugin.forFile('C:\projects\foo.m',...
            %            'Producing',CoberturaFormat('CodeCoverageReport.xml'));
            %
            %   See also: forFolder, forPackage
            
            import matlab.unittest.plugins.codecoverage.CoberturaFormat;
            import matlab.unittest.internal.coverage.File;
            import matlab.unittest.internal.fileResolver;
            
            parser = matlab.unittest.internal.strictInputParser;
            parser.addRequired('file', @validateFile);
            parser.addParameter('Producing','default',@validateReportFormatForFile);
            parser.parse(file, varargin{:});
            
            if ismember('Producing',parser.UsingDefaults)
                error(message('MATLAB:unittest:CodeCoveragePlugin:EmptyCoverageFormat'));
            end
            
            files = cellstr(parser.Results.file);
            files = cellfun(@fileResolver, files, 'UniformOutput',false);

            format = parser.Results.Producing;
            filesObj = File(files);
            plugin = matlab.unittest.plugins.CodeCoveragePlugin(filesObj,'Producing',format);
        end
        
    end
    
    methods (Access=protected)
        function runTestSuite(plugin, pluginData)
            
            % Collect the code coverage data
            runTestSuite@matlab.unittest.internal.plugins.CodeCoverageCollectionPlugin(plugin, pluginData);

            profileData = plugin.Collector.Results;
            for format = plugin.Format
                format.generateCoverageReport(plugin.Sources,profileData);
            end
        end
    end
    
    methods (Access=private)
        function plugin = CodeCoveragePlugin(sources,varargin)
            % Private constructor. Must use a static method to construct an instance.
            
            import matlab.unittest.internal.plugins.ProfilerCollector;
            
            plugin@matlab.unittest.internal.plugins.CodeCoverageCollectionPlugin(ProfilerCollector);
            plugin.Sources = sources;
            plugin.parse(varargin{:});
        end
    end
end


function validateFolder(folders)
validateattributes(folders,{'cell','string','char'},{});
if isempty(folders)
    error(message('MATLAB:unittest:CodeCoveragePlugin:EmptyFolder'));
end
if iscell(folders) && ~iscellstr(folders)
     error(message('MATLAB:unittest:StringInputValidation:InvalidInputStringCellArray'));
end
folders = string(folders);
for idx = 1:numel(folders)
    matlab.unittest.internal.validateNonemptyText(folders(idx))
    if ~isfolder(folders{idx})
        error(message('MATLAB:unittest:CodeCoveragePlugin:FolderDoesNotExist',folders{idx}));
    end
end
end

function validatePackage(packages)
validateattributes(packages,{'cell','string','char'},{});
if isempty(packages)
    error(message('MATLAB:unittest:CodeCoveragePlugin:EmptyPackage'));
end
if iscell(packages) && ~iscellstr(packages)
     error(message('MATLAB:unittest:StringInputValidation:InvalidInputStringCellArray'));
end
packages = string(packages);
for idx = 1:numel(packages)
    matlab.unittest.internal.validateNonemptyText(packages(idx))
    if isempty(meta.package.fromName(packages{idx}))
        error(message('MATLAB:unittest:CodeCoveragePlugin:PackageDoesNotExist',packages{idx}));
    end
end
end

function validateFile(files)
import matlab.unittest.internal.fileResolver
validateattributes(files,{'cell','string','char'},{'nonempty'});
if iscell(files) && ~iscellstr(files)
     error(message('MATLAB:unittest:StringInputValidation:InvalidInputStringCellArray'));
end
files = string(files);
for idx = 1:numel(files)
    fileResolver(files(idx));
    [~,~,extension] = fileparts(files(idx));
    if ~any(extension == [".m",".mlx"])
        error(message('MATLAB:unittest:CodeCoveragePlugin:InvalidFileType',files(idx)));
    end
end
end

function validateIncludeSub(value,varname)
validateattributes(value,{'logical'},{'scalar'},'',varname)
end

function allFolders = addClassAndPrivateFolders(folders)
allFolders = findAllSubcontent(folders, @getClassAndPrivateFolders);
end

function allFolders = findAllSubfolders(folders)
allFolders = findAllSubcontent(folders, @getSubfolders);
end

function subfolders = getSubfolders(folder)
folderInfo = dir(folder);
subfolders = {folderInfo([folderInfo.isdir]).name};
subfolders(subfolders == "." | subfolders == ".." | subfolders == "private" | ...
    startsWith(subfolders, "@")) = [];
subfolders = fullfile(folder, subfolders);
end

function subfolders = getClassAndPrivateFolders(folder)
folderInfo = dir(folder);
subfolders = {folderInfo([folderInfo.isdir]).name};
subfolders = subfolders(subfolders == "private" | startsWith(subfolders, "@"));
subfolders = fullfile(folder, subfolders);
end

function allPackages = findAllSubpackages(packages)
allPackages = findAllSubcontent(packages, @getSubpackages);
end

function subpackages = getSubpackages(package)
packageInfo = meta.package.fromName(package);
subpackages = {packageInfo.PackageList.Name};
end

function allContent = findAllSubcontent(content, getSubContentFcn)
% Function to find all subcontent recursively contained in content.
% Function getSubContentFcn(content) should return the subcontent directly
% contained in content.

allContent = content;
for idx = 1:numel(content)
    thisContent = content{idx};
    subContent = findAllSubcontent(getSubContentFcn(thisContent), getSubContentFcn);
    allContent = [allContent, subContent]; %#ok<AGROW>
end
end

function checkForOverdeterminedParameters(parser,p1,p2)
if ~any(ismember({p1,p2},parser.UsingDefaults))
    error(message('MATLAB:unittest:NameValue:OverdeterminedParameters',p1,p2));
end
end

function validateReportFormat(format)
% validate class
if ~isa(format,'matlab.unittest.plugins.codecoverage.CoverageFormat')
    error(message('MATLAB:unittest:CodeCoveragePlugin:InvalidCoverageFormat',...
        'matlab.unittest.plugins.codecoverage.CoberturaFormat',...
        'matlab.unittest.plugins.codecoverage.ProfileReport'));    
end

end

function validateReportFormatForFile(format)
validateattributes(format,{'matlab.unittest.plugins.codecoverage.CoberturaFormat'},...
    {'row','nonempty'},'CoverageFormat');
end

% LocalWords:  myproj myproject noaddressbox Subfolders subfolders Subpackages
% LocalWords:  subpackages Subcontent subcontent varname
