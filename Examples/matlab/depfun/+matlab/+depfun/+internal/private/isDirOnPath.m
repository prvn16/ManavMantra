function onPath = isDirOnPath(pth)
    p = [pwd strsplit(path,pathsep)];
    onPath = any(strcmp(pth,p)); 
end
