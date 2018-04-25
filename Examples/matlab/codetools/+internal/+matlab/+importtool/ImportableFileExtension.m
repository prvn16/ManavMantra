classdef ImportableFileExtension
 % Copyright 2012 The MathWorks, Inc.
%   This class is unsupported and might change or be removed without
%   notice in a future version. 

    methods(Static)        
        % extensionsWithDotPrefix takes true/false. 
        % Ex: true : returns {'.mp4'}  false: returns  {'mp4'}
        function fileExt = getVideoFileExtensions(extentionsWithDotPrefix, varargin)
            if nargin < 1
                extentionsWithDotPrefix = true;
            end
            % Return a cell array of supported video file extensions
            fileExt = localVideoExtn(extentionsWithDotPrefix, varargin{:});
        end

        
        % extensionsWithDotPrefix takes true/false. 
        % Ex: true : returns {'.wav'}  false: returns  {'wav'}
        function fileExt = getAudioFileExtensions(extentionsWithDotPrefix, varargin)
            if nargin < 1
                extentionsWithDotPrefix = true;
            end
            % Return a cell array of supported audio file extensions
            fileExt = localAudioExtn(extentionsWithDotPrefix, varargin{:});
        end
        
        % extensionsWithDotPrefix takes true/false. 
        % Ex: true : returns {'.txt'}  false: returns  {'txt'}
        function fileExt = getTextFileExtensions(extentionsWithDotPrefix)
            if nargin < 1
                extentionsWithDotPrefix = true;
            end
            % Returns a cell array of supported text file extensions
            fileExt = localTextExtn(extentionsWithDotPrefix);
        end
        
        % extensionsWithDotPrefix takes true/false. 
        % Ex: true : returns {'.xls'}  false: returns  {'xls'}
        function fileExt = getSpreadsheetFileExtensions(extentionsWithDotPrefix)
            if nargin < 1
                extentionsWithDotPrefix = true;
            end
            % Returns a cell array of supported spreadsheet file extensions
            fileExt = localSpreadsheetExtn(extentionsWithDotPrefix);
        end
        
        % extensionsWithDotPrefix takes true/false. 
        % Ex: true : returns {'.png'}  false: returns  {'png'}
        function fileExt = getImageFileExtensions(extentionsWithDotPrefix)
            if nargin < 1
                extentionsWithDotPrefix = true;
            end
            % Returns a cell array of imporable image file extensions
            fileExt = localImportableImageExtn(extentionsWithDotPrefix);
        end
        
        % extensionsWithDotPrefix takes true/false. 
        % Ex: true : returns {'.png'}  false: returns  {'png'}
        function [fileExt,fileDesc] = getSupportedImageFileExtensions(extentionsWithDotPrefix)
            if nargin < 1
                extentionsWithDotPrefix = true;
            end
            % Returns a cell array of all MATLAB supported image file extensions
            [fileExt,fileDesc] = localSupportedImageExtn(extentionsWithDotPrefix);
        end
        
        % Returns cell array of displayed text and file extensions in Import Tools Recognized
        % Data Files dropdown.
        function [fileExtnDesc, fileExtList] = getImportToolFileChooserDropDownInfo
            [fileExtnDesc, fileExtList] = importToolRecognizableFileDropdownInfo;
        end

    end
end


function fileExt = localVideoExtn(extentionsWithDotPrefix, varargin)
    % Get the file extensions for Video files.
    fileExt  = {};

    % For testing purposes force failure
    forceFailure = false;
    if nargin>1
        forceFailure = true;
    end
    
    try
        if forceFailure
            error('VIDEOREADER:ERROR', 'VIDEO READER ERROR');
        end
        videoFileFormats = VideoReader.getFileFormats;
        fileExt = {videoFileFormats.Extension};
    catch e
        % Catch error and turn into a warning for the user
        warning(e.identifier, e.message);
    end
    % prefix a dot to the extensions if requested 
    if extentionsWithDotPrefix
        fileExt = strcat('.',fileExt);
    end
end

function fileExt = localAudioExtn(extentionsWithDotPrefix, varargin)
    % Get the file extensions for Audio files.
    fileExtTmp = {};

    % For testing purposes force failure
    forceFailure = false;
    if nargin>1
        forceFailure = true;
    end
    
    try
        if forceFailure
            error('AUDIOREADER:ERROR', 'AUDIO READER ERROR');
        end
        fileExtTmp = multimedia.internal.audio.file.PluginManager.getInstance.ReadableFileTypes;
    catch e
        % Catch error and turn into a warning for the user
        warning(e.identifier, e.message);
    end
    fileExtTmp{end+1} = 'snd'; % sound file extension.
    fileExtTmp = unique(fileExtTmp);
    % prefix a dot to the extensions if requested 
    if extentionsWithDotPrefix
        fileExtTmp = strcat('.',fileExtTmp);
    end
    fileExt = fileExtTmp';
end

function fileExt = localTextExtn(extentionsWithDotPrefix)
    % import tool supported text file extensions
    fileExt = {'.txt','.csv', '.dat', '.dlm', '.tab','.asc'};
    % strip off the dot prefix in the extensions if not requested  
    if ~extentionsWithDotPrefix
        fileExt = getExtenstionsWithDotPrefix(fileExt);
    end
end


function fileExt = localSpreadsheetExtn(extensionsWithDotPrefix)
    fExtList1 = {'.ods'}; % spreadsheet folmats supported by import tool
    fExtList2 = matlab.io.internal.xlsreadSupportedExtensions; % excel formats
    fileExt = unique([fExtList1 fExtList2]);
    % strip off the dot prefix in the extensions if not requested 
    if ~extensionsWithDotPrefix
        fileExt = getExtenstionsWithDotPrefix(fileExt);
    end

end

function [fileExt] = localImportableImageExtn(extentionsWithDotPrefix)
    % Import tool supported image file extensions.
    fileExt = {'.gif', '.cur','.hdf','.ico',{'.jpg','.jpeg'}, ...
        '.png',{'.tif','.tiff'},'.bmp','.pcx'};
    % strip off the dot prefix in the extensions if not requested 
    if ~extentionsWithDotPrefix
        fileExt = getExtenstionsWithDotPrefix(fileExt);
    end
end

function [fileExt,fileDescription] = localSupportedImageExtn(extentionsWithDotPrefix)
    f = imformats; % structure arrray
    fileExtTmp = {f.ext}; % extract file extensions into a cell array.
    fileDescription = {f.description}; % extract file extensions description into a cell array.
    fileExt = cell(size(fileExtTmp));
    % For prefixing the extensions with a dot
    if extentionsWithDotPrefix
        for i=1:length(fileExtTmp)
            fileExt{i}=strcat('.',fileExtTmp{i});
        end
    end
end

function [fileDropdownLabelList, recognizableFileExtList] = importToolRecognizableFileDropdownInfo
% For contents of Import Tool's Recognizable Data Files dropdown.
% Construct an array of decriptive text and list of recognizable extensions.
dropdownList = {getString(message('MATLAB:codetools:uiimport:AudioFormatStr')),localAudioExtn(true);...
        getString(message('MATLAB:codetools:uiimport:CGIFormatStr')),{'.gif'};...
        getString(message('MATLAB:codetools:uiimport:CursorFormatStr')),{'.cur'};...
        getString(message('MATLAB:codetools:uiimport:HDFFormatStr')),{'.hdf'};...
        getString(message('MATLAB:codetools:uiimport:IconFormatStr')),{'.ico'};...
        getString(message('MATLAB:codetools:uiimport:JPEGFormatStr')),{'.jpg','.jpeg'};...
        getString(message('MATLAB:codetools:uiimport:MATFileStr')),{'.mat'};...
        getString(message('MATLAB:codetools:uiimport:PNGFormatStr')),{'.png'};...
        getString(message('MATLAB:codetools:uiimport:SpreadsheetFormatStr')),localSpreadsheetExtn(true);...
        getString(message('MATLAB:codetools:uiimport:TIFFormatStr')),{'.tif','.tiff'};...
        getString(message('MATLAB:codetools:uiimport:TextFormatStr')),localTextExtn(true);...
        getString(message('MATLAB:codetools:uiimport:VideoFormatStr')),localVideoExtn(true);...
        getString(message('MATLAB:codetools:uiimport:BitMapStr')),{'.bmp'};...
        getString(message('MATLAB:codetools:uiimport:ZsoftPaintbrushStr')),{'.pcx'};...
        getString(message('MATLAB:codetools:uiimport:AllFilesStr')),{'.*'}};
    fileDropdownLabelList = dropdownList(:,1);
    recognizableFileExtList = dropdownList(:,2);    
end

function extensions = getExtenstionsWithDotPrefix(extensions)
    % strips off the dot prefix from all the extensions. 
    for i = 1:length(extensions)
        if ~isempty(strfind(extensions{i},'.'))
            extensions{i} = strtok(extensions{i},'.');
        end
    end
end



