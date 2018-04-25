function varargout = sysobjupdate(varargin)
%SYSOBJUPDATE Updates System object code to work in the current release
%    SYSOBJUPDATE updates MATLAB files containing System object code to
%    be compliant with the current release.
%
%    This application recursively searches the specified directory and
%    sub-directories for MATLAB (.m) files that contain System object
%    packages, classes, and properties that have been renamed in the
%    current release.
%
%    SYSOBJUPDATE(DIRNAME) specifies the search directory, DIRNAME, as a 
%    character vector or string scalar. By default DIRNAME is the current
%    working directory.
%
%    SYSOBJUPDATE(DIRNAME,INTERACTIVE) specifies a logical, INTERACTIVE,
%    which indicates whether to prompt the user. INTERACTIVE is set to true
%    by default, and therefore will prompt the user. If INTERACTIVE is set
%    to false then the changes are carried out without prompting.
%
%    SYSOBJUPDATE(DIRNAME,INTERACTIVE,'OperatingMode',MODE) specifies
%    the mode, as a character vector or string scalar, to run the 
%    application. The choices for MODE are:
%        Analyze     - find MATLAB files that need updating
%        GenerateNew - update the code by generating new MATLAB files 
%        Overwrite   - update the code by overwriting existing MATLAB files
%
%    By default OperationMode is set to 'GenerateNew'. The generated files
%    have the postfix "_<VERSION>" added to the original file name and are
%    saved in the same directory as the original file. For example, if you
%    run this application on MATLAB version R2010b, the postfix will be
%    "_R2010b".
%
%    REPORT = SYSOBJUPDATE(...) returns a data structure with the
%    following fields:
%
%        Message: character vector containing a summary message of the results
%          Files: cell array of files that need updating
%        Changes: cell array of changes
%
%    Example:
%    % Search the dspdemos directory for MATLAB files that contain System
%    % object code that needs to be updated to be compliant with R2010b.
%
%        dirName =  fullfile(matlabroot,'toolbox','dsp','dspdemos');
%        sysobjupdate(dirName)

%   Copyright 2010-2017 The MathWorks, Inc.

% Initialize output structure.
report.Message = getString(...
  message('MATLAB:system:sysobjupdateMessage',mfilename));

% Define defaults and validate inputs.
[dirName,fnamePostfix,interactiveFlag,analyzeOnlyFlag] = ...
    inputValidation(varargin{:});


% Get changes for text.
[oldNames,newNames] = strs2replace;

% Find files.
[fileList,Changes] = findFiles(oldNames,dirName,analyzeOnlyFlag);
% need to combine file names
report.Files = fileList;
report.Changes = matchOldnNew(oldNames,newNames,Changes,analyzeOnlyFlag);

if interactiveFlag && ~isempty(fileList) && ~analyzeOnlyFlag
    % Launch file selection dialog.
    [fileList,selected] = fileSelectionDlg(fileList);
    if ~selected
        fprintf([getString(message('MATLAB:system:noFilesSelected')) '\n']);
    end
end

% Apply changes. Generate new files or overwrite original file.
if ~isempty(fileList) && ~analyzeOnlyFlag
    applyChanges(fileList,fnamePostfix,oldNames,newNames);
end

% Return output.
if nargout
    varargout{1} = report;
end

end

%--------------------------------------------------------------------------
function [dirName,fnamePostfix,interactiveFlag,analyzeOnlyFlag] = ...
         inputValidation(varargin)

% Default settings.
dirName         = pwd;
overwriteFlag   = false;
interactiveFlag = true;
fnamePostfix    = sprintf('_R%s', version('-release'));
analyzeOnlyFlag = false;

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
  
    dirName = varargin{1};

    if ~ischar(dirName) || ~exist(dirName,'dir')
      matlab.system.internal.error(...
        'MATLAB:system:invalidDir',dirName);
    end
end

if nargin > 1
    if islogical(varargin{2})
        interactiveFlag = varargin{2};
    else
        error(message('MATLAB:system:sysobjupdateInvalidInteractive'));
    end
end

if nargin > 2
    modeStr = varargin{3};
    if ~strcmpi(modeStr,'OperatingMode')
        error(message('MATLAB:system:sysobjupdateInvalidInput', mfilename));
    end
    
    if nargin > 3
        valArg = varargin{4};
    else
        error(message('MATLAB:system:sysobjupdateInvalidNumInputs'));
    end
    
    if strcmpi(valArg,'Analyze')
        analyzeOnlyFlag = true;
    elseif strcmpi(valArg,'GenerateNew')
        % default
        overwriteFlag = false;
    elseif strcmpi(valArg,'Overwrite')
        overwriteFlag = true;
    else
      error(message('MATLAB:system:sysobjupdateInvalidOperatingMode'));
    end
end

if overwriteFlag
    fnamePostfix = ''; % use original file name, i.e., overwrite original
end

end % function
%--------------------------------------------------------------------------
function [oldNames,newNames] = strs2replace
%strs2replace Syntax, package, class, and property names that changed
%   [oldNames,newNames] = strs2replace returns two cell arrays containing
%   the old (oldNames) and new (newNames) names for System object packages,
%   classes, and properties that have been renamed between releases and
%   need to be updated. 

%--------------------------------------------------------------------------------%
% Signal Processing Blockset and Video and Image Processing Blockset             %
% Syntax changes between release R2010a and R2010b.                              %
%                                                                                %
% Refer to the following links for the Release Notes:                            %
% https://www.mathworks.com/access/helpdesk/help/toolbox/dsp/rn/bqm9yvg.html  %
% https://www.mathworks.com/access/helpdesk/help/toolbox/vision/rn/rn_intro.html %
%--------------------------------------------------------------------------------%

% Get the current version number of MATLAB
versionStr = version;
dotLocations = strfind(versionStr, '.');
currentVersion.Major = eval(versionStr(1:dotLocations(1)-1));
currentVersion.Minor = eval(versionStr(dotLocations(1)+1:dotLocations(2)-1));

s.old.PropNames = {};
s.new.PropNames = {};
s.old.MethodNames = {};
s.new.MethodNames = {};
s.new.ClassNames = {};
s.old.ClassNames = {};
s.old.PkgNames = {};
s.new.PkgNames = {};

if (currentVersion.Major > 7) || ...
        ((currentVersion.Major == 7) && (currentVersion.Minor >= 11))
    % Changes for R2010b and later
        
    % Class names.
    s.new.ClassNames = {'dsp.AudioFileReader','dsp.AudioFileWriter',...
        'video.Histogram'};
    s.old.ClassNames = {'signalblks.MultimediaFileReader','signalblks.MultimediaFileWriter',...
        'video.Histogram2D'};
    
    % Package names.
    s.old.PkgNames = {'signalblks.'};
    s.new.PkgNames = {'dsp.'};
    
    % Property names. Search both in quotes and dot notation.
    s.old.PropNames = {'''SamplesPerAudioFrame''','.SamplesPerAudioFrame',...
        '''AudioOutputDataType''', '.AudioOutputDataType',...
        '''AudioSampleRate''',     '.AudioSampleRate',...
        '''WindowCaption''',       '.WindowCaption',...
        '''WindowLocation''',      '.WindowLocation',...
        '''WindowPosition''',      '.WindowPosition',...
        '''WindowSize''',          '.WindowSize',...
        '''CustomWindowSize''',    '.CustomWindowSize',...
        };
    s.new.PropNames = {'''SamplesPerFrame''',     '.SamplesPerFrame',...
        '''OutputDataType''',      '.OutputDataType',...
        '''SampleRate''',          '.SampleRate',...
        '''Name''',                '.Name',...
        '''Location''',            '.Location',...
        '''Position''',            '.Position',...
        '''Size''',                '.Size',...
        '''CustomSize''',          '.CustomSize',...
        };
end

if (currentVersion.Major > 7) || ...
        ((currentVersion.Major == 7) && (currentVersion.Minor >= 12))
    % For R2011a and later
    
    % Class names.
    s.old.ClassNames = [s.old.ClassNames ...
        {'video.AlphaBlender', 'video.Autocorrelator2D', ...
        'video.Autothresholder', 'video.BinaryFileReader', ...
        'video.BinaryFileWriter', 'video.BlobAnalysis', ...
        'video.BlockMatcher', ...
        'video.ColorSpaceConverter', 'video.ConnectedComponentLabeler', ...
        'video.Contents', 'video.ContrastAdjuster', ...
        'video.Convolver2D', 'video.CornerDetector', ...
        'video.Crosscorrelator2D', 'video.DCT2D', ...
        'video.Deinterlacer', 'video.DemosaicInterpolator', ...
        'video.DeployableVideoPlayer', 'video.EdgeDetector', ...
        'video.FFT2D', 'video.GammaCorrector', ...
        'video.GeometricRotator', 'video.GeometricScaler', ...
        'video.GeometricShearer', 'video.GeometricTransformEstimator', ...
        'video.GeometricTransformer', 'video.GeometricTranslator', ...
        'video.Histogram', 'video.Histogram2D', ...
        'video.HoughLines', ...
        'video.HoughTransform', 'video.IDCT2D', ...
        'video.IFFT2D', 'video.ImageComplementer', ...
        'video.ImageDataTypeConverter', 'video.ImageFilter', ...
        'video.ImagePadder', 'video.LocalMaximaFinder', ...
        'video.MarkerInserter', 'video.Maximum', ...
        'video.MedianFilter2D', 'video.Minimum', ...
        'video.Mean', 'video.Median', ...
        'video.MorphologicalBottomHat', 'video.MorphologicalClose', ...
        'video.MorphologicalDilate', 'video.MorphologicalErode', ...
        'video.MorphologicalOpen', 'video.MorphologicalTopHat', ...
        'video.OpticalFlow', ...
        'video.Pyramid', 'video.ShapeInserter', ...
        'video.StandardDeviation', 'video.TemplateMatcher', ...
        'video.TextInserter', 'video.Variance', ...
        'video.VideoPlayer'...
        }];
    s.new.ClassNames = [s.new.ClassNames ...
        {'vision.AlphaBlender', 'vision.Autocorrelator', ...
        'vision.Autothresholder', 'vision.BinaryFileReader', ...
        'vision.BinaryFileWriter', 'vision.BlobAnalysis', ...
        'vision.BlockMatcher', ...
        'vision.ColorSpaceConverter', 'vision.ConnectedComponentLabeler', ...
        'vision.Contents', 'vision.ContrastAdjuster', ...
        'vision.Convolver', 'vision.CornerDetector', ...
        'vision.Crosscorrelator', 'vision.DCT', ...
        'vision.Deinterlacer', 'vision.DemosaicInterpolator', ...
        'vision.DeployableVideoPlayer', 'vision.EdgeDetector', ...
        'vision.FFT', 'vision.GammaCorrector', ...
        'vision.GeometricRotator', 'vision.GeometricScaler', ...
        'vision.GeometricShearer', 'vision.GeometricTransformEstimator', ...
        'vision.GeometricTransformer', 'vision.GeometricTranslator', ...
        'vision.Histogram', 'vision.Histogram', ...
        'vision.HoughLines', ...
        'vision.HoughTransform', 'vision.IDCT', ...
        'vision.IFFT', 'vision.ImageComplementer', ...
        'vision.ImageDataTypeConverter', 'vision.ImageFilter', ...
        'vision.ImagePadder', 'vision.LocalMaximaFinder', ...
        'vision.MarkerInserter', 'vision.Maximum', ...
        'vision.MedianFilter', 'vision.Minimum', ...
        'vision.Mean', 'vision.Median', ...
        'vision.MorphologicalBottomHat', 'vision.MorphologicalClose', ...
        'vision.MorphologicalDilate', 'vision.MorphologicalErode', ...
        'vision.MorphologicalOpen', 'vision.MorphologicalTopHat', ...
        'vision.OpticalFlow', ...
        'vision.Pyramid', 'vision.ShapeInserter', ...
        'vision.StandardDeviation', 'vision.TemplateMatcher', ...
        'vision.TextInserter', 'vision.Variance', ...
        'vision.VideoPlayer' ...
        }];
    
    % Note that, if two names match partially (i.e. Median and
    % MedianFilter2D), the longer one shoudl be listed first.
    
    % Package names.
    s.old.PkgNames = [s.old.PkgNames ...
        {}];
    s.new.PkgNames = [s.new.PkgNames...
        {}];

    % Property names. Search both in quotes and dot notation.
    s.old.PropNames = [s.old.PropNames ...
        {}];
    s.new.PropNames = [s.new.PropNames ...
        {}];
end

if (currentVersion.Major > 7) || ...
        ((currentVersion.Major == 7) && (currentVersion.Minor >= 13))
    % Changes for R2011b and later
        
    % Class names - none so far
    s.new.ClassNames = [s.new.ClassNames {}];
    s.old.ClassNames = [s.old.ClassNames {}];
    
    % Package names - none so far
    s.old.PkgNames = [s.old.PkgNames {}];
    s.new.PkgNames = [s.new.PkgNames {}];
    
    % Property names. Search both in quotes and dot notation.
    s.old.PropNames = [s.old.PropNames ...
        {}];
    s.new.PropNames = [s.new.PropNames ...
        {}];
end

if (currentVersion.Major > 7) || ...
        ((currentVersion.Major == 7) && (currentVersion.Minor >= 14))
    % Changes for R2012a and later
        
    % Class names 
    %   DSP System Toolbox changes for R2012b
    %       class name change:  SignalReader-> SignalSource
    %                           SignalLogger-> SignalSink
    s.new.ClassNames = [s.new.ClassNames ...
                        {'dsp.SignalSource','dsp.SignalSink'}];
    s.old.ClassNames = [s.old.ClassNames ...
                        {'dsp.SignalReader', 'dsp.SignalLogger'}];
    
    % Package names - none so far
    s.old.PkgNames = [s.old.PkgNames {}];
    s.new.PkgNames = [s.new.PkgNames {}];
    
    % Property names  - none so far
    s.old.PropNames = [s.old.PropNames {}];
    s.new.PropNames = [s.new.PropNames {}];
end

if (currentVersion.Major > 8) || ...
        ((currentVersion.Major == 8) && (currentVersion.Minor >= 2))
    % Changes for R2012a and later
        
    % Class names - none so far
    s.new.ClassNames = [s.new.ClassNames {}];
    s.old.ClassNames = [s.old.ClassNames {}];
        
    % Package names - none so far
    s.old.PkgNames = [s.old.PkgNames {}];
    s.new.PkgNames = [s.new.PkgNames {}];
    
    % Property names. Search both in quotes and dot notation.
    s.old.PropNames = [s.old.PropNames ...
        {}];
    s.new.PropNames = [s.new.PropNames ...
        {}];

    % Method names. Search both in '@foo' and 'foo(' notation.
    s.old.MethodNames = {...
        '@inputSize','inputSize(',...
        '@outputSize','outputSize(',...
        '@inputFixedSize','inputFixedSize(',...
        '@outputFixedSize','outputFixedSize(',...
        '@inputDataType','inputDataType(',...
        '@outputDataType','outputDataType(',...
        '@inputComplexity','inputComplexity(',...
        '@outputComplexity','outputComplexity(',...
        };
    s.new.MethodNames = {...
        '@propagatedInputSize','propagatedInputSize(',...
        '@propagatedOutputSize','propagatedOutputSize(',...
        '@propagatedInputFixedSize','propagatedInputFixedSize(',...
        '@propagatedOutputFixedSize','propagatedOutputFixedSize(',...
        '@propagatedInputDataType','propagatedInputDataType(',...
        '@propagatedOutputDataType','propagatedOutputDataType(',...
        '@propagatedInputComplexity','propagatedInputComplexity(',...
        '@propagatedOutputComplexity','propagatedOutputComplexity(',...
        };
end


if (currentVersion.Major > 10) || ...
        ((currentVersion.Major == 9) && (currentVersion.Minor >= 3))
    % Changes for R2018a and later
        
    % Class names - none so far
    s.new.ClassNames = [s.new.ClassNames {}];
    s.old.ClassNames = [s.old.ClassNames {}];
        
    % Package names - none so far
    s.old.PkgNames = [s.old.PkgNames {}];
    s.new.PkgNames = [s.new.PkgNames {}];
    
    % Property names. Search both in quotes and dot notation.
    s.old.PropNames = [s.old.PropNames {}];
    s.new.PropNames = [s.new.PropNames {}];

    % Method names. Search both in '@foo' and 'foo(' notation.
    s.old.MethodNames = [s.old.MethodNames {}];
    s.new.MethodNames = [s.new.MethodNames {}];

    % Method names. Search both in '@foo' and 'foo(' notation.
    s.old.Command = { ...
      'Class attribute to add: StrictDefaults'
      };
    s.new.Command = { ...
      'Added class attribute: StrictDefaults'
      };
end


if isempty(s.old.PkgNames)
    error(message('MATLAB:system:sysobjupdateUnsupportedVersion', ...
      version('-release')));
end

% The property 'SampleTime' was renamed to 'SampleRate', but this only
% affects the three objects listed below and can't be detected, and
% therefore updated, automatically.
%
%   dsp.BurgSpectrumEstimator
%   dsp.Chirp
%   dsp.SineWave
oldNames = struct2cell(s.old);
newNames = struct2cell(s.new);
oldNames = [oldNames{:}];
newNames = [newNames{:}];

assert(numel(oldNames)==numel(newNames),...
  getString(message('MATLAB:system:sysobjupdateSizeMismatch')));
end

%--------------------------------------------------------------------------
function [fileList,Changes] = findFiles(searchStr, dirName, analyzeOnlyFlag)
%findFiles Find files containing the specified text
%    findFiles(STR, DIRNAME, ANALYZE) lists the files in the directory
%    specified by DIRNAME (and its sub-directories) that contain the
%    strings specified in the cell array STR. By default the search
%    directory is the current directory. If ANALYZE is specified as true
%    then the results are displayed in the command window.
%
%    Example:
%
%       dirName =  fullfile(matlabroot,'toolbox','dsp','dspdemos');
%       findFiles({'FFT'},dirName)

if nargin < 3
    analyzeOnlyFlag = false;
end
if nargin < 2
    dirName = pwd;
end

if ~exist(dirName,'dir')
    error(message('MATLAB:system:invalidDir',dirName));
end

if analyzeOnlyFlag
    % List strings being searched.
    fprintf(['\nSearching for MATLAB files in the %s directory (and ',...
        'sub-directories)\nthat contain the following strings:\n'],dirName)
    fprintf('    %s\n',searchStr{:})
end

% Find files containing the search strings.
[fileList,Changes] = getFileList(searchStr,dirName);

if analyzeOnlyFlag
    if ~isempty(fileList) % Files found
        fprintf(['\nThe following files were found containing System ',...
            'object code that needs to be updated...\n']);
        
        for m = 1:numel(fileList)
            fprintf('<a href="matlab: edit(''%s'')">%s</a>\n',...
                fileList{m}, fileList{m})
        end
        
        fprintf('Finished searching.\n')
    end        
end

if isempty(fileList) % No files found
    fprintf(['\nNo MATLAB files found in the %s directory\nthat ',...
        'contain System object code that needs to be updated.\n'],dirName)
end

end

%--------------------------------------------------------------------------
function [fileList,changesList] = getFileList(str,dirName)

extensions = {'.m'};
fileList   = {};
matchedStrs= {};
changesList= {};
thisdir    = pwd;
cd(dirName);

% Add escape character to strings with parens and periods.
str = regexptranslate('escape',str);

searchFilesRecursively();
cd(thisdir);
                    
    function searchFilesRecursively
        d = dir;
        for i=1:numel(d)
            if ~strcmp(d(i).name, '.') && ~strcmp(d(i).name, '..')
                if d(i).isdir
                    origdir = pwd;
                    cd(d(i).name);
                    searchFilesRecursively();
                    cd(origdir);
                    
                elseif ~isempty(regexp(d(i).name,...
                        [extensions{1},'$'],'once')) &&... 
                         ~strcmp(d(i).name,[mfilename,'.m']) % exclude this file
                     
                    fileName =  [pwd filesep d(i).name];
                    buf = readFile(fileName);
                    
                    matchedStrs = regexp(buf,str,'match');

                    classAttribName = 'StrictDefaults';
                    command =  getActionCommands(buf,classAttribName);
                    if ~isempty(command)
                      matchedStrs{end+1} = ['Class attribute to add: ' classAttribName];%#ok<AGROW>
                    end
                    
                    matchedStrs = [matchedStrs{:}];
                    if ~isempty(matchedStrs) 
                        [~, p] = unique(matchedStrs);
                        matchedStrs = matchedStrs(sort(p));
                        changesList{end+1} = matchedStrs;  %#ok<AGROW>
                        fileList{end+1,1} = fileName;              %#ok<AGROW>
                    end

                end
            end
        end
    end

end

%--------------------------------------------------------------------------
function command =  getActionCommands(buf,attribute)
  mt = mtree(buf);  
  classDefNode = mtfind(mt, 'Kind', 'CLASSDEF');
  classDefAttrNode = classDefNode.Cattr;
  % Only Authored System objects can have the 'StrictDefaults' attribute
  % Does this buffer have a classdef that inherits from matlab.System
  classString = tree2str(classDefNode.Cexpr);
  className = strtrim( strtok(classString,'<'));
  metaCls = meta.class.fromName(className);
  
  if isempty(metaCls) || ~(metaCls < ?matlab.System)
    command = {};
    return;
  end
  if isnull(classDefAttrNode)
      % There are no class attributes, so insert new one to left
      % of class name
      classNameNode = classDefNode.Cexpr.Left;
      [L, C] = pos2lc(classNameNode, lefttreepos(classNameNode));
      code = sprintf('(%s)', attribute);
      command = {struct('Action', 'insert', ...
          'Text', code, 'Line', L, 'Column', C)};
  else
      subtreeClassDefAttrNode = classDefAttrNode.Tree;
      if ~anystring(subtreeClassDefAttrNode,attribute)
          [L, C] = pos2lc(classDefAttrNode, righttreepos(classDefAttrNode));
          code = sprintf(',%s', attribute);
          command = {struct('Action', 'insert', ...
              'Text', code, 'Line', L, 'Column', C+1)};
      else
          command = {};
      end
  end
end

%--------------------------------------------------------------------------
function [newFileList,selected] =  fileSelectionDlg(fList)
%fileSelectionDlg File selection dialog
%    NEWFILELIST =  fileSelectionDlg(FILELIST) displays a file selection
%    dialog with the files in FILELIST and returns the selected files in
%    the output variable NEWFILELIST.

promptStr = 'Files containing System object code that needs to be updated.';
[idxs,selected] = listdlg(...
    'Name','File Selection',...
    'PromptString',{promptStr,'','Select files to update:'},...
    'ListSize',[400 300],...
    'ListString',fList);

newFileList = {};
% Cache the files selected by the user.
if selected
    newFileList = fList(idxs);
end
end

%--------------------------------------------------------------------------
function applyChanges(filelist,fnamePostfix,oldNames,newNames)
%applyChanges Renames System object packages, classes, and properties

% Add escape character to strings with parens and periods.
oldNames =  regexptranslate('escape',oldNames);

% For each file, open it, read contents, update contents, and write it back.
for m = 1:numel(filelist)
    buf = readFile(filelist{m});               % Open and read content
    
    buf = regexprep(buf, oldNames, newNames);  % Apply changes
    
    if any(contains(newNames,'Added class attribute: StrictDefaults'))
      classAttribName = 'StrictDefaults';
      commands =  getActionCommands(buf,classAttribName); 
      while ~isempty(commands)
        command = commands{1}; % only first command    
        sbuf = splitlines(buf);
        newLine = strjoin({sbuf{command.Line}(1:command.Column-1), ...
          command.Text, ...
          sbuf{command.Line}(command.Column:end)},'');

        sbuf(command.Line) = {newLine};
        buf = strjoin(sbuf,'\n');     
        commands =  getActionCommands(buf,classAttribName); 
      end
    end

    [pathstr,name,ext] = fileparts(filelist{m});
    newfilelist{m} = fullfile(pathstr,[name,fnamePostfix,ext]); %#ok<AGROW>
    writeFile(buf, newfilelist{m});             % Write new content
end

if isempty(fnamePostfix)
    fprintf('\nThe following files were updated:\n');
else
    fprintf('\nThe following files were generated:\n');
end

for n = 1:numel(newfilelist)
    fprintf('<a href="matlab: edit(''%s'')">%s</a>\n',...
        newfilelist{n}, newfilelist{n});
end
end

%--------------------------------------------------------------------------
function buf = readFile(filename)
%readFile Open the file, read and return all the text
%   BUF = readFile(FILENAME) opens and reads the content of the text file
%   specified by FILENAME. The contents of the file is returned in the
%   output variable BUF as a character array.

% filePath = which(filename);
buf = []; 
if ~isempty(filename)
    [fid,msg] = fopen(filename);
    if fid==-1
       error(message('MATLAB:system:fileOpenFailed',filename,msg));
    end

    buf = fread(fid, inf, '*char')';
    fclose(fid);
end
end

%--------------------------------------------------------------------------
function writeFile(buf, filename)
%writeFile Write to file
%   writeFile(BUF,FILENAME) opens a new file named FILENAME and writes the
%   text specified in the input variable BUF to the file. BUF must be a
%   character array.

[newfid,msg] = fopen(filename, 'w');
if newfid==-1
  error(message('MATLAB:system:fileOpenFailed',filename,msg));
end
fwrite(newfid, buf);
fclose(newfid);
end

%--------------------------------------------------------------------------
function cellChanges = matchOldnNew(oldNames,newNames,Changes, analyzeOnly)
% Store changes in output structure.

cellChanges = cell(numel(Changes),1);
changesNewNames = cell(numel(Changes),1);

for k = 1:numel(Changes) % all changes in a file that need changing
    
    changesOldNames = Changes{k};
    for n = 1:numel(Changes{k}) % changes per file
        % Find corresponding new name idx
        matches = strcmp(Changes{k}{n},oldNames);
        
        changesNewNames{n} = newNames{matches};
    end
    
    % Compress the changes if more than one is applied to the same entity,
    % i.e. changed in more than one release
    idxToRemove = [];
    for n=1:numel(changesOldNames)
        idx = strcmpi(changesOldNames{n}, changesNewNames);
        if any(idx)
            changesNewNames{idx} = changesNewNames{n};
            idxToRemove(end+1) = n; %#ok<AGROW>
        end
    end
    changesNewNames(idxToRemove) = [];
    changesOldNames(idxToRemove) = [];
    
    for n=1:numel(changesOldNames)
      if contains(changesOldNames{n}, 'Class attribute')
        if analyzeOnly
          cellChanges{k}{n} = changesOldNames{n};
        else
          cellChanges{k}{n} = changesNewNames{n};
        end
      else
        cellChanges{k}{n} = sprintf(['''%s'' ',...
            'is replaced with ''%s''.'],...
            changesOldNames{n},changesNewNames{n});
      end
    end
end
end
