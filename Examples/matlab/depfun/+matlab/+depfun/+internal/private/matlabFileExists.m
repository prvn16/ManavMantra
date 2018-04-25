function [tf, file] = matlabFileExists(fcnPath)
% Use the WHICH and EXIST caches to determine if the file exists.

    function tf = fileExists(file)
        tf = ~isempty(matlab.depfun.internal.cacheWhich(file)) || ...
             matlab.depfun.internal.cacheExist(file,'file') ~= 0;
    end

    % Test in order of expected frequency.
    tf = false;
    
    % If the file has an extension, don't add one.
    ext = extension(fcnPath);
    if ~isempty(ext)
        tf = fileExists(fcnPath);
        file = fcnPath;
        return;
    end
    
    % This could be a loop over some extList = {'.m', '.p', '.mlx'}.
    % I've unrolled the loop in hopes of better performance. Premature
    % optimization? Used nesting to avoid repeating ext strings.
    % note that MatlabInspector and genManifest use the reverse ordering
    %some day the ordering below may also need to be reversed.    
    import matlab.depfun.internal.requirementsConstants
    
    k = 1;
    while ~tf && k <= requirementsConstants.executableMatlabFileExtSize
        file = [fcnPath ...
                requirementsConstants.executableMatlabFileExt_reverseOrder{k}];
        tf = fileExists(file);
        k = k + 1;
    end
    
    if ~tf
        file = '';
    end
end
