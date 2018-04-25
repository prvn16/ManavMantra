function tf = isClassdef(files)
% isClassdef Does file contain a MATLAB class defintion?
    import matlab.depfun.internal.requirementsConstants
    
    if ischar(files)
        files = { files };
    end
    
    tf = false(1,numel(files));
    for f = 1:numel(files)
        file  = files{f};
        % Make sure this is a MATLAB function (file name must end with .m 
        % or .mlx). If it's a .p file, look for the .m file instead.
        ext = extension(file);
        if strcmp(ext, '.p')
            file(end-1:end) = '.m';
            ext = '.m';
        end

        if ismember(ext, requirementsConstants.analyzableMatlabFileExt_reverseOrder)
            tf = hasClassDef(file);
        elseif isempty(ext)
            k = 1;
            while ~tf && k <= requirementsConstants.analyzableMatlabFileExtSize
                tf = hasClassDef([file ...
                        requirementsConstants.analyzableMatlabFileExt{k}]);
                k = k + 1;
            end
        end
    end
end

function tf = hasClassDef(file)
    tf = false;
    % If the MATLAB file exists, does it contain CLASSDEF?
    if matlab.depfun.internal.cacheExist(file, 'file')
        mt = matlab.depfun.internal.cacheMtree(file);
        if ~isempty(mt)
            tf = (mt.FileType == mtree.Type.ClassDefinitionFile);
        end
    end
end
