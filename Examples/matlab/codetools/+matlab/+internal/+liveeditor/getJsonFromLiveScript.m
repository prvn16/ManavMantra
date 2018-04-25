function jsonContent = getJsonFromLiveScript( fileName, varargin )
    % getOpcFromLiveScriptInJson - This file is used to create a JSON version of the OPC package of a
    % Live Script
    % If:
    % Local file: Both filename and file path need to be provided
    % Cloud: Like GDS, then GDS token and path to file need to be provided.
    % If open url then, just the file name and url needs to be provided
    
    % Examples: 
    % For Local File:
    % matlab.internal.liveeditor.getJsonFromLiveScript('foo.mlx', 'Source', 'Local File', 'LocalFilePath', pwd)
    
    % For GDS file:
    % matlab.internal.liveeditor.getJsonFromLiveScript('foo.mlx', 'Source', 'GDS', 'Url', 'https://gds.mathworks.com/gds/service/v1/files/', 'GDStoken', 'asdasdasdasd1234213da')
    
    % For External Url on web
    % matlab.internal.liveeditor.getJsonFromLiveScript('foo.mlx', 'Source', 'External', 'Url', 'http://192.168.100.1:8080/')
    
    
    % Get path to the file and file info after parsing inputs
    [fullFilePath, isFileOnCloud] = parseInputsAndGetFileInfo(fileName, varargin{:});
    
    % Read file and grab OPC Package
    file = java.io.File(fullFilePath);
    
    % Get JSOn content
    opcPackage = readFile(file);
    jsonContent = matlab.internal.liveeditor.getJsonFromOpcPackage(opcPackage);
    
    % Clean up if required
    if isFileOnCloud
        file.delete();
    end
end
function opcPackage = readFile(file)
    isMLX = com.mathworks.services.mlx.MlxFileUtils.isMlxFile(file.getAbsolutePath());
    
    if isMLX
        opcPackage = com.mathworks.services.mlx.MlxFileUtils.read(file);
    else
        opcPackage = com.mathworks.publishparser.PublishParser.convertMToRichScript(file);
    end
end
function [fullFilePath, isFileOnCloud] = parseInputsAndGetFileInfo( fileName, varargin)
    % Assume the file is located on cloud
    isFileOnCloud = true;
    
    % Check for optional Url parameter to switch modes to file on cloud.
    p = inputParser;
    % Default values
    defaultSource = '';
    defaultGdsToken = '';
    defaultUrl = '';
    defaultLocalFilePath = '';
    validationFcn = @(x) ischar(x) || isstring(x);
    p.addParameter('Source', defaultSource, validationFcn);
    p.addParameter('Url', defaultUrl, validationFcn);
    p.addParameter('GDStoken', defaultGdsToken, validationFcn);
    p.addParameter('LocalFilePath', defaultLocalFilePath, validationFcn);
    p.parse(varargin{:});
    
    % Fetch values from the parser
    sourceName = convertStringsToChars(p.Results.Source);
    fileLocationOnCloud = convertStringsToChars(p.Results.Url);
    gdsToken = convertStringsToChars(p.Results.GDStoken);
    filePath = convertStringsToChars(p.Results.LocalFilePath);
    tempFileName = 'tempLiveScript.mlx';

    switch sourceName
        case 'External'
            % Download file
            fullFilePath = websave(tempFileName, [fileLocationOnCloud fileName]);

        case 'GDS'
            if (isempty(gdsToken) || isempty(fileLocationOnCloud))
                throw(MException('MATLAB:Connector:emptyInputNotAllowed', ...
                    'File location on cloud and GDStoken both need to be provided.'));
            end
            
            % Has to download from MATLAB Drive
            webOptions = weboptions('HeaderFields',{'x-mw-gds-session-id' gdsToken});
            
            % Download file
            fullFilePath = websave(tempFileName, [fileLocationOnCloud fileName], webOptions);

        case 'Local File'
            % Correct asumption since file is located on disk
            isFileOnCloud = false;

            if isempty(filePath) || isempty(fileName)
                throw(MException('MATLAB:Connector:emptyInputNotAllowed', ...
                    'Argument filePath or fileName cannot be empty.'));
            end
            
            fullFilePath = fullfile(filePath, fileName);
        otherwise
            error('Unexpected source type');
    end
end