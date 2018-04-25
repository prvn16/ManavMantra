classdef CoberturaFormat < matlab.unittest.plugins.codecoverage.CoverageFormat
    % CoberturaFormat - A format to create a code coverage report using Cobertura XML format.
    %
    %   To produce code coverage results that conform with the Cobertura
    %   XML format, use an instance of the CoberturaFormat class with the
    %   CodeCoveragePlugin.
    %
    %   CoberturaFormat methods:
    %       CoberturaFormat - Class constructor
    %                                                                      
    %   Example:
    %                                                                      
    %       import matlab.unittest.plugins.CodeCoveragePlugin;
    %       import matlab.unittest.plugins.codecoverage.CoberturaFormat;
    %                                                                      
    %       % Construct the Cobertura XML coverage format 
    %       format = CoberturaFormat('CoverageResults.xml');
    %       
    %       % Construct a CodeCoveragePlugin with the Cobertura XML format
    %       plugin = CodeCoveragePlugin.forFolder('C:\projects\myproj',...
    %           'Producing',format);
    %                                                                      
    %   See also: matlab.unittest.plugins.CodeCoveragePlugin
    
    % Copyright 2017 The MathWorks, Inc. 
    
    properties (Hidden,SetAccess = private)
        Filename
    end

    
    methods
        function format = CoberturaFormat(filename)
            % CoberturaFormat - Construct a CoberturaFormat format.
            %
            % FORMAT = CoberturaFormat(FILENAME) constructs a CoberturaFormat format
            % and returns it as FORMAT. When used with the CodeCoveragePlugin,
            % the code coverage results are saved to the file FILENAME.
            
            filename = validateFileName(filename);
            format.Filename = filename;
        end
    end
    
    methods (Hidden, Access = {?matlab.unittest.internal.mixin.CoverageFormatMixin,...
            ?matlab.unittest.plugins.codecoverage.CoverageFormat})
        function generateCoverageReport(coberturaFormat,sources,profileData)
            import matlab.unittest.internal.coverage.CoberturaFormatter;
            import matlab.unittest.internal.getLargestCommonRootsFromSourceFolders
            
            sourceFolders = arrayfun(@getFolderName,sources);
            largestCommonRootSourceFolders = getLargestCommonRootsFromSourceFolders(sourceFolders);
            fileInformationArray = sources.produceFileInformation;
            overallCoverage = coberturaFormat.generateCoverageInformation(fileInformationArray,profileData);
            coberturaFomatter = CoberturaFormatter;
            coberturaFomatter.publishCoverageReport(coberturaFormat.Filename,overallCoverage,largestCommonRootSourceFolders);
        end
    end
    
    methods(Access = private)        
        function overallCoverage = generateCoverageInformation(coberturaFormat,fileInformationArray,profileData)
            import matlab.unittest.internal.coverage.FileCoverage
            % Gather profileData for each file in the source.
            fileProfileData = coberturaFormat.filterProfileData(profileData,{fileInformationArray.FullName});
            
            % Gather coverage information for all files.
            numFileInfo = numel(fileInformationArray);
            fileCoverageArray = repmat(FileCoverage.empty(1,0),1,numFileInfo);
            for idx = 1: numFileInfo
                fileCoverageArray(idx) = FileCoverage(fileInformationArray(idx),fileProfileData{idx});
            end            
            overallCoverage = buildPackageList(fileCoverageArray);
        end 
        
        function fileProfileDataCell = filterProfileData(~,profileData,fileNames)
            fileProfileDataCell = cell(size(fileNames));
            profiledFileList = {profileData.FunctionTable.FileName};
            for idx = 1:numel(fileNames)
                [containingFolder, shortName, ~] = fileparts(fileNames{idx});
                pFileName = fullfile(containingFolder,strcat(shortName,'.p')); 
                
                profiledSourceFilesMask = ismember(profiledFileList,{fileNames{idx},pFileName});
                fileProfileDataCell{idx} = profileData.FunctionTable(profiledSourceFilesMask);
            end
        end
    end
end
function fullFilename = validateFileName(filename)
validateattributes(filename,{'char','string'},{'scalartext'},'','fileName');
filename = char(filename);
validateattributes(filename,{'char'},{'nonempty'},'','fileName');

[parentFolder, filenamePart, extensionPart] = fileparts(filename);
if isempty(parentFolder)
    parentFolder = '.';
end
parentFolder = matlab.unittest.internal.folderResolver(parentFolder);
fullFilename = fullfile(parentFolder,[filenamePart, extensionPart]);
end