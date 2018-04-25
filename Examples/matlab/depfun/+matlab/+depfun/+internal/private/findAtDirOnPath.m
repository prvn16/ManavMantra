function atDir = findAtDirOnPath(clsName, first)
% findAtDirOnPath Return all @-directories of the given class.
% If class is a dot-qualified name, look for MCOS or OOPS style classes,
% rather than UDD.
%

    if nargin < 2
        first = false;
    end
    atDir = {};
    foundAtDir = false;
    p = strsplit(path,pathsep);
    % Don't forget to check the darkness under the lamp.
    p = [pwd p];
    
    n = 1;
    partialPth = name2partial(clsName);
    while ((first == false || foundAtDir == false) && n <= numel(p))
        d = [p{n} partialPth ];
        if matlab.depfun.internal.cacheExist(d,'dir')
            atDir = [ atDir { d } ]; %#ok
            foundAtDir = true;
        end
        n = n + 1;
    end
    if first && ~isempty(atDir), atDir = atDir{1}; end
end

function pthSpec = name2partial(clsName)
    pthSpec = '';
    fs = filesep;
    nameParts = strsplit(clsName,'.');
    if ~isempty(nameParts)
        for n=1:numel(nameParts)-1
            pthSpec = [pthSpec fs '+' nameParts{n}];  %#ok
        end
        pthSpec = [pthSpec fs '@' nameParts{end}];
    end
end
