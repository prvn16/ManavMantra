function gpucoderdemo_setup(demoFunctionName)

% Copyright 2010-2018 The MathWorks, Inc.

currentDir = fullfile(pwd);

[currentDirBase, currentDirName] = fileparts(currentDir);
if strcmp(currentDirName, demoFunctionName)
  warning('Current directory contains demo files from a previous run. Creating a new demo directory');
  cd(currentDirBase);
  currentDir = currentDirBase;
end

if exist(demoFunctionName, 'dir')
    [basedir,name,~] = fileparts(demoFunctionName);
else
    [basedir,name,~] = fileparts(which(demoFunctionName));
end
% Assume the contents of the example files is in the directory with
% same name as the file (without the .m extension)
srcdir = fullfile(basedir,name);

if isempty(srcdir)
    % if empty try codegendemos directory with the same name
    srcdir = fullfile(matlabroot, 'toolbox', 'gpucoder', 'gpucoderdemos', demoFunctionName);
    name = demoFunctionName;
    
    if isempty(srcdir)
        disp('Unable to find files in directory ''%s''', srcdir);
        return
    end
    
end


% Find a destination directory in the current directory that does
% not exist. We append a number until the directory name becomes
% unique.
basedstdir = fullfile(currentDir, name);
exists = true;
cnt = 1;
while exists
    if cnt > 1
        dstdir = [basedstdir num2str(cnt)];
    else
        dstdir = basedstdir;
    end
    exists = exist(dstdir, 'dir');
    if exists
        cnt = cnt + 1;
    end
end

% Create the destination directory. Should always succeed.
mkdir(dstdir);

% Save current workspace
evalin('caller', ['save(''' fullfile(dstdir, 'old_workspace') ''')']);

% Store the current figure windows
assignin('caller', 'currentFigures', findall(0, 'type', 'figure'));

cleanup_command('reset', fullfile(dstdir, 'cleanup.m'));
% Add cleanup command: Close all figure windows caused by this example
cleanup_command('if ~exist(''currentfigures'') || isempty(currentFigures), currentFigures = []; end;');
cleanup_command('close(setdiff(findall(0, ''type'', ''figure''), currentFigures))');
% Add cleanup command: Clear mex (unload DLLs)
cleanup_command('clear mex');
% Add cleanup command: Remove MEX files
cleanup_command(['delete *.' mexext]);
% Add cleanup command: Cleanup the codegen/ directory
cleanup_command(['[~,~,~] = rmdir(''' fullfile(dstdir, 'codegen') ''',''s'');']);
% Copy files with different extensions
copyall_ext(srcdir, dstdir, 'm');
copyall_ext(srcdir, dstdir, 'png');
copyall_ext(srcdir, dstdir, 'jpg');
copyall_ext(srcdir, dstdir, 'ppm');
copyall_ext(srcdir, dstdir, 'mat');
copyall_ext(srcdir, dstdir, 'txt');
copyall_ext(srcdir, dstdir, 'avi');
copyall_ext(srcdir, dstdir, 'mp4');
copyall_ext(srcdir, dstdir, 'sh');
copyall_ext(srcdir, dstdir, 'c');
copyall_ext(srcdir, dstdir, 'cu');
copyall_ext(srcdir, dstdir, 'cpp');
copyall_ext(srcdir, dstdir, 'hpp');
copyall_ext(srcdir, dstdir, 'h');
copyall_ext(srcdir, dstdir, 'mk');
copyall_ext(srcdir, dstdir, 'bat');
if strcmp(demoFunctionName,'gpucoderdemo_multitarget_cnncodegen')
    srcfile = 'logos_dataset';
    mkdir(dstdir,srcfile)
    copyfile(fullfile(srcdir,srcfile),fullfile(dstdir,srcfile));
end
    
if (exist(fullfile(srcdir, 'Makefile'), 'file'))
    copyfile(fullfile(srcdir, 'Makefile'), dstdir, 'f');
    cleanup_command(['delete(''' fullfile(dstdir, 'Makefile') ''')']);
end

copyall_ext(srcdir, dstdir, 'slx');
% Add cleanup command: Restore workspace
cleanup_command('clear');
cleanup_command('load old_workspace');
cleanup_command('delete old_workspace.mat');
% Add cleanup command: Cleanup myself
cleanup_command(['delete(''' fullfile(dstdir, 'cleanup.m') ''')']);
% Add cleanup command: Go back to the original directory
cleanup_command(['cd(''' currentDir ''')']);
% Add cleanup command: Remove directory
cleanup_command(['rmdir(''' fullfile(dstdir) ''',''s'');']);

% Go to new directory
cd(dstdir);

%
% Copy all files in srcdir\*.ext to dstdir\*.ext with extension 'ext'
%
function copyall_ext(srcdir,dstdir,ext)
allFiles = dir(fullfile(srcdir, ['*.' ext]));
if ~isempty(allFiles)
    for i = 1:numel(allFiles)
        srcFile = fullfile(srcdir, allFiles(i).name);
        dstFile = fullfile(dstdir, allFiles(i).name);
        copyfile(srcFile, dstdir, 'f');
        if strcmp(ext,'m')
            % Clears persistent data, freeing up any classes used here.
            cleanup_command(['clear(''' dstFile ''')']);
        end
        cleanup_command(['delete(''' dstFile ''')']);
    end
end

%
% Adds a cleanup command to cleanup.m
%
function cleanup_command(command, varargin)
persistent cleanupFile;
if strcmp(command, 'reset')
    file = varargin{1};
    cleanupFile = file;
    fid = fopen(cleanupFile, 'w');
    fclose(fid);
else
    fid = fopen(cleanupFile, 'a+');
    fprintf(fid, '%s\n', command);
    fclose(fid);
end
