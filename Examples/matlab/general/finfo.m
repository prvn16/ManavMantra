function [fileType, openAction, loadAction, description] = finfo(filename, ext)
% FINFO Identify file type against standard file handlers on path
%
%       [TYPE, OPENCMD, LOADCMD, DESCR] = finfo(FILENAME)
%
%       TYPE - contains type for FILENAME or 'unknown'.
%
%       OPENCMD - contains command to OPEN or EDIT the FILENAME or empty if
%                 no handler is found or FILENAME is not readable.
%
%       LOADCMD - contains command to LOAD data from FILENAME or empty if
%                 no handler is found or FILENAME is not readable.
%
%       DESCR   - contains description of FILENAME or error message if
%                 FILENAME is not readable.
%
% See also OPEN, LOAD

%   Copyright 1984-2017 The MathWorks, Inc.

if ~ischar(filename)
    error(message('MATLAB:finfo:InvalidType'));
end

if exist(filename,'file') == 0
    error(message('MATLAB:finfo:FileNotFound', filename))
end

if nargin == 2 && ~ischar(ext)
    error(message('MATLAB:finfo:ExtensionMustBeAString'));
end

% get file extension
if nargin == 1 || isempty(ext)
    [ext, description] = getExtension(filename);
else
    description = '';
end
ext = lower(ext);

% rip leading . from ext
if ~isempty(findstr(ext,'.'))
    ext = strtok(ext,'.');
end

% special case for .text files (textread will give false positive)
if strcmp(ext,'text')
    ext = '';
end

% check if open and load handlers exist
openAction = '';
loadAction = '';

% this setup will not allow users to override the default EXTread behavior
if ~isempty(ext)
    % known data formats go to uiimport and importdata
  
    % First, try to find open and load handlers on the path
    openAction = which(['open' ext '(''char'')']);
    loadAction = which([ext 'read(''char'')']);
    if any(strcmp(['.' ext], matlab.io.internal.xlsreadSupportedExtensions))  ||  ...
       any(strcmp(ext, ...
                        {'avi', ...                       % retaining avi file checks for backwards compatibility
                         'csv', 'dat', 'dlm', 'tab', ...  % text files
                         'ods'}));                        % other worksheet files           
             openAction = 'uiimport';
             loadAction = 'importdata';
    elseif (any(strncmp(ext, {'doc', 'ppt'},3)))
        %special cases for DOC and PPT formats
        if strncmp(ext, 'doc', 3)
            openAction = 'opendoc';
        elseif strncmp(ext, 'ppt', 3)
            openAction = 'openppt';
        end
    elseif isempty(openAction) % open handler
        % Attempt to open the file as a multimedia file i.e. image, audio
        % or video file
        [ext, description] = openAsMultimediaFile(filename, ext);
        if any(strcmp(ext, {'im','video','audio'}))
            openAction = 'uiimport';
            loadAction = 'importdata';
        end
    end
end

if ~isempty(openAction) || ~isempty(loadAction)
    fileType = ext;
else
    fileType = 'unknown';
end

% rip path stuff off commands
if ~isempty(openAction)
    [~,openAction] = fileparts(openAction);
end
if ~isempty(loadAction)
    [~,loadAction] = fileparts(loadAction);
end

% disable avifinfo,wavfinfo, and aufinfo warnings
avWarnState = warning('OFF', 'MATLAB:audiovideo:avifinfo:FunctionToBeRemoved');
avWarnCleaner = onCleanup(@()warning(avWarnState));

% make nice description and validate file format
if nargout == 4 && isempty(description) % only fetch descr if necessary
    if any(strcmp(['.' ext], matlab.io.internal.xlsreadSupportedExtensions)) || strncmp(ext, 'ods', 3)
        [status, description] = xlsfinfo(filename);
    % if the file is type mlx, use getCode instead of fread
    elseif strcmp(ext, 'mlx')
        try
            description = matlab.internal.getCode(filename);
            status = 'MLX-file';
        catch
            error(getString(message('MATLAB:finfo:MlxNotSupported'))); 
        end
    elseif ~isempty(ext) && ~isempty(which([ext 'finfo(''char'')']))
        [status, description] = feval([ext 'finfo'], filename);
    else
        % no finfo for this file, give back contents
        fid = fopen(filename);
        if fid > 0
            description = fread(fid,1024*1024,'*char')';
            fclose(fid);
        else
            description = getString(message('MATLAB:finfo:DescFileNotFound'));
        end
        status = 'NotFound';
    end    
    if isempty(status)
            % the file finfo util sez this is a bogus file.
            % return valid file type but empty actions
            openAction = '';
            loadAction = '';
            % generate failure message, used by IMPORTDATA
            description = 'FileInterpretError'; 
    end
end

function isVideo = isVideoFile(ext)
    try
        % Get the list of supported video file formats on this platform
        videoFileFormats = VideoReader.getFileFormats;
        % extracting video file extensions
        videoFileExt = {videoFileFormats.Extension};
    catch me %#ok<NASGU>
        videoFileExt = {}; % set the extensions list to empty and continue.
    end
    
    isVideo = any(strcmp(ext, videoFileExt));


function isAudio = isAudioFile(ext)
    try
        % Get the list of supported audio file formats
        audioFileExt = multimedia.internal.audio.file.PluginManager.getInstance.ReadableFileTypes;
    catch me %#ok<NASGU>
        audioFileExt = {}; % set the extensions list to empty and continue.
    end
    
    isAudio = any(strcmp(ext, audioFileExt));

function [ext, description] = openAsMultimediaFile(filename, fileextension)
% Attempt to open the file as an image, video, or audio file

if isCOrCppFile(fileextension)
    ext = fileextension;
    description = '';
    return;
end

if isKnownNonMultimediaFile(fileextension)
    ext = fileextension;
    description = '';
    return;
end

[ext, description] = getImageInfo(filename, fileextension);
if strcmp(ext,'im')
    return;
end

if isVideoFile(fileextension)
    [ext, description] = getVideoInfo(filename,fileextension);
    return;
end

if isAudioFile(fileextension)
    [ext, description] = getAudioInfo(filename,fileextension);
    return;
end
    

[ext, description] = getVideoInfo(filename,fileextension);
if strcmp(ext,'video')
    return;
end

[ext, description] = getAudioInfo(filename,fileextension);


function [ext, description] = getVideoInfo(filename, fileextension)
% to support additional codecs that the user may have installed
try
    videoObj = VideoReader(filename);
    
    % In some cases, a valid VideoReader object will be created even if the
    % file only has an audio stream.
    if ~hasVideo(videoObj)
        ext = fileextension; % return the same file extension.
        description = '';
        return;
    end
    
    ext = 'video';
    try
        description = getString(message('MATLAB:finfo:DescVideoFiles', ...
                            videoObj.Name, ...
                            sprintf('%.4f',videoObj.FrameRate), ...
                            videoObj.VideoFormat , ...
                            sprintf('%d',videoObj.Width),  ...
                            sprintf('%d',videoObj.Height) , ...
                            sprintf('%d',videoObj.NumberOfFrames)));
    catch exception  %#ok
        description = getString(message('MATLAB:finfo:DescVideoFileEmpty'));
    end
    
catch exception %#ok
    ext = fileextension;% return back the same file extension.
    description = '';
end

function [ext, description] = getAudioInfo(filename, fileextension)
% to support additional codecs that the user may have installed
try
    audioObj = audioinfo(filename);
    ext = 'audio';
    if isstruct(audioObj)
        try
            description = getString(message('MATLAB:finfo:DescAudioFiles', ...
                                        fileextension, audioObj.TotalSamples, ...
                                        audioObj.NumChannels));
        catch exception %#ok
            description = getString(message('MATLAB:finfo:DescAudioFileEmpty'));
        end
    else
        description = getString(message('MATLAB:finfo:DescAudioFileEmpty'));
    end
catch exception %#ok
    ext = fileextension;% return back the same file extension.
    description = '';
end

function [ext, description] = getImageInfo(filename, fileextension)
try
    s = imfinfo(filename);
    ext = 'im';
    if length(s) > 1
        description = getString(message('MATLAB:finfo:DescMultiImageFirstOnly', upper(s(1).Format), length(s), length(s)));
    else
        description = getString(message('MATLAB:finfo:DescNbitImage', s.BitDepth, s.ColorType, ...
            upper(s.Format)));
    end
catch exception %#ok
    ext = fileextension;
    description = '';
end

function  tf = isCOrCppFile(fileextension)
commonCAndCppFileExtensions = { 'h', 'hpp', 'hxx', 'c', 'cc', 'cpp', 'cxx' };
    
tf = ismember(lower(fileextension), commonCAndCppFileExtensions);

function tf = isKnownNonMultimediaFile(fileextension)
extensionsToFilter = {'cat', 'tdx', 'txt', 'log'};

tf = ismember(lower(fileextension), extensionsToFilter);

    
function [ext, description] = getExtension(filename)
%  try to get imfinfo (if file is image, use "im")

[~,~,ext]=fileparts(filename);
description = '';
return;

