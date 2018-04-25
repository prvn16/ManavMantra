function [b, className, whichComment] = isClassMFile(fullPath)
    [whichName, whichComment] = which(fullPath);
    if isempty(whichName)
        [explicitPath, fileName] = fileparts(fullPath);
        [explicitPart, implicitPart] = matlab.internal.language.introspective.separateImplicitDirs(explicitPath);
        [whichPath, whichComment] = which(fullfile(implicitPart, fileName));
        if ~isempty(whichComment)
            % verify that stripping the explicit part resolved back to the
            % original path
            resolvedExplicitPart = matlab.internal.language.introspective.separateImplicitDirs(fileparts(whichPath));
            canonical = what(resolvedExplicitPart);
            if ~strcmp([canonical.path, filesep], explicitPart)
                whichComment = '';
            end
        end        
    end
    classSplit = regexp(whichComment, '(?<name>\w*)\s*constructor$', 'names', 'once');
    b = ~isempty(classSplit);
    if b
        className = classSplit.name;
    else
        className = '';
    end
