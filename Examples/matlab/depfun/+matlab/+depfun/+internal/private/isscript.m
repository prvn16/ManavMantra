function tf = isscript(files)
% ISSCRIPT Is the file a script file?
    tf = false(1,numel(files));
    for k=1:numel(files)
        pth = files{k};
        % Can't be a script if it isn't a MATLAB file.
        if ~isempty(pth) && isMcode(pth) ...
            && matlab.depfun.internal.cacheExist(pth, 'file') == 2 
            mt = matlab.depfun.internal.cacheMtree(pth);
            tf(k) = (mt.FileType == mtree.Type.ScriptFile);
        end
    end

