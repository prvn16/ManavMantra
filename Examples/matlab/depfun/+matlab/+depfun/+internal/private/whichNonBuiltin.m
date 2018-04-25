function w_new = whichNonBuiltin(name, w)
% w_new = whichNonBuiltin(sym, w)
% whichNonBuiltin returns the WHICH result (w_new) of the first non-builtin
% user file before the built-in symbol (sym) on the MATLAB path.
% The result (w_new) is empty if there is no non-builtin symbol before the built-in
% symbol (sym).
%
% Author: Yufei Shen
% Date: Jun 10th, 2013

import matlab.depfun.internal.*

w_new = '';

% Find the location of the built-in
pathInfo = regexp(w, ['^' requirementsConstants.BuiltInStrAndATrailingSpace ...
                  '\((.+?)\)'],'tokens');
builtinDir = '';
if ~isempty(pathInfo)
    pathInfo = pathInfo{1}{1};
    [builtinDir,~,~] = fileparts(pathInfo);
else
    env = reqenv;
    pcm_db_navigator = ProductComponentModuleNavigator(env.PcmPath);
    tbl = pcm_db_navigator.builtinRegistry;
    if isKey(tbl, name)
        builtinDir = tbl(name).loc;
    end
end

if ~isempty(builtinDir)
    % remove '/+' or '/@' or '/private'
    if ismac
        % Temp directories start with '/private/' on Mac. 
        builtinDir = regexprep(builtinDir, ...
                  '(?!^[/\\]private[/\\].+)[/\\]([@+]|private[/\\]).+','');
    else
        builtinDir = regexprep(builtinDir, '[/\\]([@+]|private[/\\]).+', '');
    end
    
    % preserve the original path
    orgPath = path;

    % find the position of the built-in dir on the MATLAB path
    % STRFIND is 2 to 3 times faster than REGEXP in this case.
    builtinDirPos = strfind(orgPath, builtinDir);
    if ~isempty(builtinDirPos)%#ok contains is no good here
        % Remove builtinDir and entries behind it from the MATLAB path
        % If the position of the built-in dir is less than 2, trimmedPath
        % will be empty.
        trimmedPath = orgPath(1:builtinDirPos-2);
        if ispc
            pathItems = strsplit(trimmedPath,';');
        elseif isunix
            pathItems = strsplit(trimmedPath,':');
        end
        % Add pwd to the top of the path
        pathItems = [{pwd} pathItems];

        matlabDir_pat = ['^' regexptranslate('escape', matlabroot)];
        userDirIdx = cellfun('isempty',regexp(pathItems,matlabDir_pat,'ONCE'));
        
        % treat toolbox/compiler/patch as user directory, since files in
        % that directory are used to shadow original files/built-ins.
        patchDir = fullfile(matlabroot,'toolbox/compiler/patch');
        if exist(patchDir, 'dir') == 7
            compiler_patch_dir_pat = ['^' regexptranslate('escape', patchDir)];
            patchDirIdx = ~cellfun('isempty',regexp(pathItems, ...
                                           compiler_patch_dir_pat,'ONCE'));
            userDirIdx = userDirIdx | patchDirIdx;
        end
        
        % Shadowing is not allowed in the entire mathworks code base,        
        % so only need to find the first non-builtin user file 
        % before the cached built-in on the MATLAB path.
        userPathItems = pathItems(userDirIdx);
        
        if ~isempty(userPathItems)
            % If there is a non-builtin user file with the identical name before the
            % built-in, WHICH can find it. If not, WHICH returns an empty string.
            w_probable = matlab.depfun.internal.which.callWhich(name);
            
            % Check if the returned file is located in one of the user
            % folders.
            if ~isempty(w_probable) && isempty(strfind(w_probable, ...
                    requirementsConstants.BuiltInStrAndATrailingSpace))
                w_probable_dir = fileparts(w_probable);
                if ismember(w_probable_dir, userPathItems)
                    w_new = w_probable;
                end
            end
        end
    end
end

end