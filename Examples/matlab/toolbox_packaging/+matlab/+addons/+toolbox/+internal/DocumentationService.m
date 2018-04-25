classdef DocumentationService
    %DOCUMENTATIONSERVICE Services to assist with providing documentation 
    % for add-ons.  This service is intended for use with Java-based code
    % implementing toolbox publishing functionality.help 
    properties(Constant)
        ATTR_HELPTOC_XML_TARGET     = 'target';
        ELEMENT_HELPTOC_XML_TOCITEM = 'tocitem';
        ELEMENT_INFO_XML_RELEASE    = 'matlabrelease';
        ELEMENT_INFO_XML_TBXNAME    = 'name';
        ELEMENT_INFO_XML_HELPLOC    = 'help_location';
        FILE_HELPTOC_XML            = 'helptoc.xml';
        FILE_INFO_XML               = 'info.xml';
        FILE_GET_START_MLX          = 'GettingStarted.mlx';
        PATH_GET_START_FOLDER       = 'doc';
        PATH_HELPTOC_XML_TEMPLATE   = fullfile(matlabroot, 'help', 'techdoc', 'matlab_env', 'examples', 'templates', 'helptoc_template.xml');
        PATH_INFO_XML_TEMPLATE      = fullfile(matlabroot, 'help', 'techdoc', 'matlab_env', 'examples', 'templates', 'info_template.xml');
		
        PATH_GET_START_MLX_TEMPLATE = fullfile(matlabroot, 'help', 'templates', 'GettingStarted_template.mlx');
        
        STATUS_FAILURE = 0;
        STATUS_SUCCESS = 1;
    end
    
    methods(Static)
        function [statusInt, statusMessageList, generatedFilesList] = integrateToolboxHelp(toolboxName, toolboxRootFolder, htmlSubFolder)
        %INTEGRATETOOLBOXHELP Handles creation of meta-data files required to integrate with MATLAB Documentation.
        %
        %   [A, B, C] = INTEGRATETOOLBOXHELP(D, E, F)
        %
        %   IN:
        %       D = A toolbox name as a string.  Cannot be empty.
        %       E = Absolute path to the toolbox root folder, as a string.
        %           Cannot be empty.
        %       F = Relative path to subfolder of toolbox root folder that 
        %           holds the documentation, as a string.  An empty string
        %           can be provided to use the toolbox root folder.
        %
        %   OUT:
        %       A = 1 on success, 0 on error.
        %       B = List of messages describing errors, or empty on success.
        %       C = List of generated files on success, empty on error.  On
        %           success this will contain the absolute path to the 
        %           'info.xml' file first, and the optional 'helptoc.xml' 
        %           file second if it was generated.
        
            import matlab.addons.toolbox.internal.DocumentationService;
        
            % Start off assuming we'll succeed...
            statusInt = DocumentationService.STATUS_SUCCESS;
            statusMessageList = {};
            generatedFilesList = {};
            
            % Validate arguments
            % Toolbox name must be a valid, non-empty value.
            if strlength(toolboxName) == 0
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:ToolboxNameInvalid').getString()];
                return
            end
            
            % toolbox root folder must exists, convert to absolute path if needed.
            if exist(toolboxRootFolder, 'dir') ~= 7 
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:ToolboxRootNotFound', toolboxRootFolder).getString()];
                return
            end
            
            % html root folder must exist, also must be under toolbox root folder.
            htmlRootFolder = fullfile(toolboxRootFolder, htmlSubFolder);
            if exist(htmlRootFolder, 'dir') ~= 7 
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:DocumentationFolderNotFound', htmlRootFolder, toolboxRootFolder).getString()];
                return
            end

            % Determine location of info.xml file relative to the given toolbox root folder.
            allSubFoldersBFS = matlab.addons.toolbox.internal.FileSystemUtils.findSubdirectoriesByBFS(toolboxRootFolder);
            infoFilePath = matlab.addons.toolbox.internal.FileSystemUtils.findFileInFolders(DocumentationService.FILE_INFO_XML, allSubFoldersBFS, true);
            
            % If info.xml file already exists we return an error.  No overwriting allowed!
            if matlab.addons.toolbox.internal.FileSystemUtils.fileOrFolderExists(infoFilePath)
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:InfoFileAlreadyExists', infoFilePath).getString()];
                return;
            end
            
            % Create the info.xml file at the default location.
            infoFilePath = fullfile(toolboxRootFolder, DocumentationService.FILE_INFO_XML);
            
            % Determine location for helptoc.xml file relative to the given HTML root folder.
            helpTocFilePath = fullfile(htmlRootFolder, DocumentationService.FILE_HELPTOC_XML);
            %helpTocFilePath = matlab.addons.toolbox.internal.FileSystemUtils.findFileInFolders(DocumentationService.FILE_HELPTOC_XML, allSubFoldersBFS, true);
            
            % If a helptoc.xml file exists we'll reference that it, otherwise copy the template
            % file to the correct location.
            if ~matlab.addons.toolbox.internal.FileSystemUtils.fileOrFolderExists(helpTocFilePath)
                helpTocFilePath = fullfile(htmlRootFolder, DocumentationService.FILE_HELPTOC_XML);
                [copyStatus, copyMessage] = copyfile(DocumentationService.PATH_HELPTOC_XML_TEMPLATE, helpTocFilePath);
                if copyStatus == 0
                    statusInt = DocumentationService.STATUS_FAILURE;
                    statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:TemplateCopyError', matlab.internal.documentation.DocumentationService.PATH_HELPTOC_XML_TEMPLATE, helpTocFilePath, copyMessage).getString()];
                    return
                end
                % Make sure the file copy is writeable.
                fileattrib(helpTocFilePath, '+w');
                generatedFilesList = [generatedFilesList, helpTocFilePath];
            end
            
            % Generate info.xml content and write the file.
            [genStatus, genMessages, infoXmlContent] = DocumentationService.generateInfoXmlContent(DocumentationService.PATH_INFO_XML_TEMPLATE, version('-release'), toolboxName, htmlSubFolder);
            if genStatus ~= DocumentationService.STATUS_SUCCESS
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList; genMessages];
                return
            end
            
            try
                xmlwrite(infoFilePath, infoXmlContent)
            catch
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:InfoFileAlreadyExists', infoFilePath).getString()];
                return;
            end

            % Stack up the final results for the caller.
            generatedFilesList = [infoFilePath, generatedFilesList];
        end
        
        function [statusInt, statusMessageList, xmlDoc] = generateInfoXmlContent(xmlTemplate, matlabRelease, toolboxName, htmlSubFolder)
        %GENERATEINFOXMLCONTENT Uses a template to generate XML for the MATLAB Documentation integration meta-data files.

            import matlab.addons.toolbox.internal.DocumentationService;
        
            % Assume success.
            statusInt = DocumentationService.STATUS_SUCCESS;
            statusMessageList = {};
            xmlDoc = '';
        
            % Make sure to squawk if the given template file doesn't exist.
            if ~matlab.addons.toolbox.internal.FileSystemUtils.fileOrFolderExists(xmlTemplate)
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:ReadOrParseError', xmlTemplate).getString()];
                return;
            end
            
            % Read in the info.xml template so we can update the required elements
            % and provide the DOM Document to the caller.
            try
                xmlDoc = xmlread(xmlTemplate);
            catch
                xmlDoc = '';
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:ReadOrParseError', xmlTemplate).getString()];
                return
            end
            
            % Apply the current MATLAB release string to the template.
            try
                nodeList = xmlDoc.getElementsByTagName(DocumentationService.ELEMENT_INFO_XML_RELEASE);
                nodeTarget = nodeList.item(0);
                nodeTarget.replaceChild(xmlDoc.createTextNode(matlabRelease), nodeTarget.getFirstChild);
            catch
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:TemplateUpdateError', DocumentationService.ELEMENT_INFO_XML_RELEASE, xmlTemplate).getString()];
            end
            
            % Apply the toolbox name string to the template.
            try
                nodeList = xmlDoc.getElementsByTagName(DocumentationService.ELEMENT_INFO_XML_TBXNAME);
                nodeTarget = nodeList.item(0);
                nodeTarget.replaceChild(xmlDoc.createTextNode(toolboxName), nodeTarget.getFirstChild);
            catch
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:TemplateUpdateError', DocumentationService.ELEMENT_INFO_XML_TBXNAME, xmlTemplate).getString()];
            end
            
            % Apply the HTML sub-folder string to the template.
            try
                nodeList = xmlDoc.getElementsByTagName(DocumentationService.ELEMENT_INFO_XML_HELPLOC);
                nodeTarget = nodeList.item(0);
                htmlFolder = htmlSubFolder;
                if htmlFolder == ""
                    htmlFolder = "./";
                end
                nodeTarget.replaceChild(xmlDoc.createTextNode(htmlFolder), nodeTarget.getFirstChild);
            catch
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:TemplateUpdateError', DocumentationService.ELEMENT_INFO_XML_HELPLOC, xmlTemplate).getString()];
            end
        end
        
        function [statusInt, statusMessageList, helpFolder] = getHelpFolderForToolbox(toolboxRootFolder)
        %GETHELPFOLDERFORTOOLBOX Returns location of integrated help documentation for a given toolbox.
        %
        %   [A, B, C] = GETHELPFOLDERFORTOOLBOX(D)
        %
        %   IN:
        %       D = A toolbox installation folder, should be absolute path.
        %
        %   OUT:
        %       A = 1 on success, 0 on error.
        %       B = List of messages describing errors, or empty on success.
        %       C = Absolute path to the help documentation folder that is
        %           registered with MATLAB Documentation for the given toolbox.
        
            import matlab.addons.toolbox.internal.DocumentationService;
        
            % Assume success.
            statusInt = DocumentationService.STATUS_SUCCESS;
            statusMessageList = {};
            helpFolder = '';

            infoFilePath = matlab.addons.toolbox.internal.FileSystemUtils.findFileBFS(DocumentationService.FILE_INFO_XML, toolboxRootFolder, true);
            if ~matlab.addons.toolbox.internal.FileSystemUtils.fileOrFolderExists(infoFilePath)
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:ToolboxFileNotFound', infoFilePath).getString()];
                return
            end
            
            try
                infoDOM = xmlread(infoFilePath);
            catch
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:ReadOrParseError', infoFilePath).getString()];
                return
            end

            try
                nodeList = infoDOM.getElementsByTagName(DocumentationService.ELEMENT_INFO_XML_HELPLOC);
                nodeTarget = nodeList.item(0);
                htmlSubFolder = char(nodeTarget.getFirstChild.getData);
            catch
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:MissingValueError', DocumentationService.ELEMENT_INFO_XML_HELPLOC, infoFilePath).getString()];
                return
            end
            
            % Note that the help subfolder is relative to the folder 
            % containing the info.xml, NOT the toolbox root folder!
            [infoFolder,~,~] = fileparts(infoFilePath);
            helpFolder = fullfile(infoFolder, htmlSubFolder);
        end
        
        function [statusInt, statusMessageList, topHelpFile] = getHelpTopLevelFileForToolbox(toolboxRootFolder)
        %GETHELPTOPLEVELFILEFORTOOLBOX Returns initial integrated help document (index) for a given toolbox.
        %
        %   [A, B, C] = GETHELPTOPLEVELFILEFORTOOLBOX(D)
        %
        %   IN:
        %       D = A toolbox installation folder, should be absolute path.
        %
        %   OUT:
        %       A = 1 on success, 0 on error.
        %       B = List of messages describing errors, or empty on success.
        %       C = Absolute path to the top-level help documentation file that is
        %           registered with MATLAB Documentation for the given toolbox.
        
            import matlab.addons.toolbox.internal.DocumentationService;
            
            topHelpFile = '';
            [statusInt, statusMessageList, helpFolder] = DocumentationService.getHelpFolderForToolbox(toolboxRootFolder);
            if statusInt ~= DocumentationService.STATUS_SUCCESS
                return
            end
            
            helpTocFile = fullfile(helpFolder, DocumentationService.FILE_HELPTOC_XML);
            if ~matlab.addons.toolbox.internal.FileSystemUtils.fileOrFolderExists(helpTocFile)
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:ToolboxFileNotFound', helpTocFile).getString()];
                return
            end
            
            try
                helpTocDOM = xmlread(helpTocFile);
            catch
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:ReadOrParseError', helpTocFile).getString()];
                return
            end

            try
                tocItemList = helpTocDOM.getElementsByTagName(DocumentationService.ELEMENT_HELPTOC_XML_TOCITEM);
                tocItem = tocItemList.item(0);
            catch
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:MissingValueError', DocumentationService.ELEMENT_HELPTOC_XML_TOCITEM, helpTocFile).getString()];
                return
            end
            
            try
                helpFileName = char(tocItem.getAttributes.getNamedItem(DocumentationService.ATTR_HELPTOC_XML_TARGET).getNodeValue);
            catch
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:MissingValueError', DocumentationService.ATTR_HELPTOC_XML_TARGET, helpTocFile).getString()];
                return
            end
            
            topHelpFile = fullfile(helpFolder, helpFileName);
        end
        
        function [statusInt, statusMessageList, docFolder] = getDocFolderForToolbox(toolboxRootFolder)
        %GETDOCFOLDERFORTOOLBOX Returns location of 'getting started' documentation for the given toolbox.
        %
        %   [A, B, C] = GETDOCFOLDERFORTOOLBOX(D)
        %
        %   IN:
        %       D = A toolbox installation folder, should be absolute path.
        %
        %   OUT:
        %       A = 1 on success, 0 on error.
        %       B = List of messages describing errors, or empty on success.
        %       C = Absolute path to the folder location for the default
        %           'getting started' documentation.
        
            import matlab.addons.toolbox.internal.DocumentationService;
        
            % Assume success.
            statusInt = DocumentationService.STATUS_SUCCESS;
            statusMessageList = {};
            docFolder = fullfile(toolboxRootFolder, DocumentationService.PATH_GET_START_FOLDER);
        end
        
        function [statusInt, statusMessageList, mlxFile] = getDefaultDocForToolbox(toolboxRootFolder)
        %GETDEFAULTDOCFORTOOLBOX Returns location of 'getting started' MLX 
        % documentation file for the given toolbox.
        %
        %   [A, B, C] = GETDEFAULTDOCFORTOOLBOX(D)
        %
        %   IN:
        %       D = A toolbox installation folder, should be absolute path.
        %
        %   OUT:
        %       A = 1 on success, 0 on error.
        %       B = List of messages describing errors, or empty on success.
        %       C = Absolute path to the MLX file location for the default
        %           'getting started' documentation.
        
            import matlab.addons.toolbox.internal.DocumentationService;
        
            % Assume success.
            statusInt = DocumentationService.STATUS_SUCCESS;
            statusMessageList = {};
            mlxFile = '';
            
            docFolder = '';
            [statusInt, statusMessageList, docFolder] = DocumentationService.getDocFolderForToolbox(toolboxRootFolder);
            if statusInt ~= DocumentationService.STATUS_SUCCESS
                return
            end
            
            mlxFile = fullfile(docFolder, DocumentationService.FILE_GET_START_MLX);
            % Make sure to squawk if the default 'getting started' file doesn't exist.
            if ~matlab.addons.toolbox.internal.FileSystemUtils.fileOrFolderExists(mlxFile)
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:ToolboxFileNotFound', mlxFile).getString()];
                return
            end
        end
        
        function [statusInt, statusMessageList, generatedFilesList] = generateDefaultDocForToolbox(toolboxRootFolder)
        %GENERATEDEFAULTDOCFORTOOLBOX 
        %
        %   [A, B, C] = GENERATEDEFAULTDOCFORTOOLBOX(D)
        %
        %   IN:
        %       D = Absolute path to the toolbox root folder, as a string.
        %           Cannot be empty.
        %
        %   OUT:
        %       A = 1 on success, 0 on error.
        %       B = List of messages describing errors, or empty on success.
        %       C = List of generated files on success, empty on error.  On
        %           success this will contain the absolute path to the 
        %           MLX file first, and the placeholder HTML file second.
        
            import matlab.addons.toolbox.internal.DocumentationService;
        
            % Start off assuming we'll succeed...
            statusInt = DocumentationService.STATUS_SUCCESS;
            statusMessageList = {};
            generatedFilesList = {};
            
            % Validate arguments
            
            % toolbox root folder must exists, convert to absolute path if needed.
            if exist(toolboxRootFolder, 'dir') ~= 7 
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:ToolboxRootNotFound', toolboxRootFolder).getString()];
                return
            end
            
            % Determine location for default 'getting started' MLX file.
            docFolder = '';
            [statusInt, statusMessageList, docFolder] = DocumentationService.getDocFolderForToolbox(toolboxRootFolder);
            if statusInt ~= DocumentationService.STATUS_SUCCESS
                return
            end
            
            % Determine expected path to MLX file.
            docMLXFilePath = fullfile(docFolder, DocumentationService.FILE_GET_START_MLX);
            
            % If the MLX file already exists we're done.  No overwriting allowed!
            retVal = matlab.addons.toolbox.internal.FileSystemUtils.fileOrFolderExists(docMLXFilePath);
            if retVal ~= 0 
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:GettingStartedFileAlreadyExists', docMLXFilePath).getString()];
                return;
            end
            
            % Make sure the documentation folder exists.
            if exist(docFolder, 'dir') ~= 7 
                [dirStatus, dirMessage] = mkdir(docFolder);
                if dirStatus == 0
                    statusInt = DocumentationService.STATUS_FAILURE;
                    statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:FolderCreateError', docFolder, dirMessage).getString()];
                    return
                end
            end
            
            % Copy the template files to the target locations and report
            % the final locations to the caller.
            [copyStatus, copyMessage] = copyfile(DocumentationService.PATH_GET_START_MLX_TEMPLATE, docMLXFilePath);
            if copyStatus == 0
                statusInt = DocumentationService.STATUS_FAILURE;
                statusMessageList = [statusMessageList, message('MATLAB:toolbox_packaging:packaging:TemplateCopyError', DocumentationService.PATH_GET_START_MLX_TEMPLATE, docMLXFilePath, copyMessage).getString()];
                return
            end
            % Make sure the file copy is writeable.
            fileattrib(docMLXFilePath, '+w');            
            generatedFilesList = [generatedFilesList, docMLXFilePath];
        end
    end
end
