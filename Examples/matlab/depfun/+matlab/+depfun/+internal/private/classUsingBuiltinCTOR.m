function [type, clsFile] = classUsingBuiltinCTOR(whichResult)
% A UDD class using the built-in constructor can appear to the
% naive to be a built-in class. But we know better if we find a 
% schema.m. It's important to catch this case, to ensure
% that we add the UDD class' schema.m to the dependency list.
    import matlab.depfun.internal.MatlabType;
    import matlab.depfun.internal.cacheExist;
    
    fs = filesep;
    type = MatlabType.NotYetKnown;
    clsFile = '';
    spaceIdx = strfind(whichResult,' ');
    if ~isempty(spaceIdx), spaceIdx = spaceIdx(1); end
    dotIdx = strfind(whichResult, '.');
    if ~isempty(dotIdx), dotIdx = dotIdx(1); end
    if dotIdx < spaceIdx
        pkgName = whichResult(1:dotIdx-1);
        clsName = whichResult(dotIdx+1:spaceIdx-1);
        pkg = what(['@' pkgName]);
        clsDir = [pkg.path fs ['@' clsName]];
        if ~isempty(pkg) && cacheExist(clsDir, 'dir') && ...
                matlabFileExists([clsDir fs 'schema'])
            type = MatlabType.UDDClass;
            %if the file exists, use it, otherwise make up a .m file
            %g1038142
            [fileExists,clsFile]=matlabFileExists([clsDir fs clsName]);
            if ~fileExists
                clsFile = [clsDir fs clsName '.m'];
            end
        end
    end
end
