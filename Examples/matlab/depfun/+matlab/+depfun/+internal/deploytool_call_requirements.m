% G1367573 - Unify the search path used by MCC and Deploytool
function [parts, resources] = deploytool_call_requirements(mcc_settings)
% Input checks
narginchk(1,1);

items      = checkCellInput(mcc_settings.source_file);
dashP_list = checkCellInput(mcc_settings.dash_p);
dashI_list = checkCellInput(mcc_settings.dash_I);
dashA_list = checkCellInput(mcc_settings.dash_a);
dashN      = mcc_settings.dash_N;

if ~islogical(dashN)
    error(message('MATLAB:depfun:req:UnexpectedInputType', ...
                  class(dashN), 'logical'));
end
% End of input checks

optional_inputs = {};
% Convert -N to -p matlab, -p compiler, and -p local
if dashN
    dashP_list = unique([dashP_list 'matlab' 'compiler' 'local']);
end
if ~isempty(dashP_list)
    optional_inputs = [ '-p' {dashP_list} ];
end

% Find containing directories of main file(s) and extra -a entries.
% When any entry is a directory, find sub-directories and
% files recursively under it.
[updated_items, more_dashI_dirs] = preprocessItems([items dashA_list]);

% Consistent with MCC. Adding containing directories to the -I list.
% filename2path rules out +, @, private directories.
dashI_list = unique(filename2path(strcat(dashI_list,filesep)), 'stable');
dashI_list = unique([dashI_list more_dashI_dirs], 'stable');
if ~isempty(dashI_list)
    optional_inputs = [ optional_inputs '-I' {dashI_list} ]; 
end

% Call REQUIREMENTS with the hybrid Deploytool target, which means
% 1. (MCR Target) Setup the MATLAB search path using the dependency database.
% 2. (MATLAB Target) Only return dependencies written by user WITHOUT using the dependency database.
% 3. (MATLAB Target) Required products are MATLAB products. This required
%    product list is used to prompt possibly required support packages in
%    deploytool.
[parts, resources] = matlab.depfun.internal.requirements(updated_items, 'Deploytool', ...
                                                         optional_inputs{:});
end

% ------------------------------------------------------------------------
% Local helper functions
% ------------------------------------------------------------------------
function input = checkCellInput(input)
    if ~iscell(input)
        if ischar(input)
            input = { input };
        else
            error(message('MATLAB:depfun:req:UnexpectedInputType', ...
                          class(input), 'cell or char'));
        end
    end

    % Preparation for concatenation in a later step.
    % Make sure items is a 1xN row vector.
    if iscolumn(input)
        input = input';
    end
end

function [updated_items, more_dashI_dirs] = preprocessItems(items)
% This function finds additional -I directories and additional -a files.
% It also updates the original list by removing directories and adding
% files under those directories.

    updated_items = unique(items);
    exist_results = cell2mat(cellfun(@(f)exist(f,'file'), updated_items, 'UniformOutput', false));
    dirIdx = (exist_results == 7);
    fileIdx = (exist_results > 0) & ~dirIdx;
    dirs = updated_items(dirIdx);
    files = updated_items(fileIdx);
    % Don't error for non-existing items in this function. They will be properly
    % flagged in a later step.
    non_dir_items = updated_items(~dirIdx);
    % The updated list contains no directory.
    updated_items = non_dir_items;

    % Find sub-directories and files in them recursively.
    num_dirs = numel(dirs);
    sub_dirs = cell(1, num_dirs);
    sub_dir_files = cell(1, num_dirs);
    for d = 1:num_dirs
        % Convert relative path to full path
        if isfullpath(dirs{d})
            base_dir = dirs{d};
        else
            base_dir = fullfile(pwd, dirs{d});
        end

        sub_dirs{d} = recursivelyFindSubDirContents(base_dir, 'dir');
        sub_dir_files{d} = recursivelyFindSubDirContents(base_dir, 'file');
    end
    sub_dirs = unique([sub_dirs{:}]);
    % Append files in those sub-directories to the updated list
    more_files = [sub_dir_files{:}];
    updated_items = unique([updated_items more_files]);

    matlab.depfun.internal.cacheExist();
    pathIdx = ~cellfun('isempty', strfind(files, filesep));
    % Combine containing directories (main files and -a files) and sub-directories
    % filename2path rules out +, @, private directories.
    dirs = strcat([dirs sub_dirs], filesep);
    more_dashI_dirs = unique(filename2path([dirs files(pathIdx)]));
end

function contents = recursivelyFindSubDirContents(baseDir, type)
    contents = {};

    if ispc
        if strcmp(type, 'dir')
            cmd = ['dir /s /A:D /B "' baseDir '"\*'];
        elseif strcmp(type, 'file')
            cmd = ['dir /s /A-D /B "' baseDir '"\*'];
        end
    elseif isunix
        if strcmp(type, 'dir')
            cmd = ['find "' baseDir '" -type d'];
        elseif strcmp(type, 'file')
            cmd = ['find "' baseDir '" -type f'];
        end
    else
        return;
    end

    [failed, msg] = system(cmd);
    if ~failed && ~isempty(msg)
        results = textscan(msg, '%s', 'Delimiter', '\n');
        if ~isempty(results)
            contents = results{1}';
        end
    end
end
