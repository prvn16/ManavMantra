function tf = hasext(file, ext)
% hasext Does the file have the given extension?
%
% Input extension must include the leading dot, since that's what fileparts
% returns in its extension output.
    if ~iscell(file)
        file = {file};
    end
    
    tf = false(1,numel(file));
    for k=1:numel(file)
        e = extension(file{k});
        tf(k) = strcmp(ext, e);
    end
