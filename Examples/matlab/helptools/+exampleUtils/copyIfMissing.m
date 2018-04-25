function copyIfMissing(src,target)
    if ~fileExists(target)
        copyfile(src,target,'f');
        fileattrib(target,'+w')
    end
end

function tf = fileExists(f)
tf = numel(dir(f)) == 1;
end