function additionalClasses = depfunprophelper(clsName)

% Copyright 2005-2006 The MathWorks, Inc.

    additionalClasses = {};
    cH = getClassFromName(clsName);
    if ~isempty(cH)
        for p = cH.Properties'
            cAdd = getClassFromName(p.DataType);
            if ~isempty(cAdd)
                additionalClasses{end+1} = p.DataType;
            end
        end
    end
end

function cH = getClassFromName(clsName)
    dot = find(clsName == '.');
    cH = [];
    if numel(dot) == 1
        pk = clsName(1:dot-1);
        cls = clsName(dot+1:end);
        pH = findpackage(pk);
        if ~isempty(pH)
            cH = findclass(pH, cls);
        end
    end
end