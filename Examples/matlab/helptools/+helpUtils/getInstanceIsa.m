function msg = getInstanceIsa(varName, varType)
    if isempty(varName)
        msg = getString(message('MATLAB:help:InputIsA', varType));
    else
        % only use the firt part of the identifier, as it is the variable
        varNameParts = regexp(varName, '(?<obj>.*?)(?<method>\W.*)', 'names');
        if ~isempty(varNameParts)
            varName = varNameParts.obj;
            varType(end-length(varNameParts.method)+1:end) = [];
        end
        msg = getString(message('MATLAB:help:InstanceIsA', varName, varType));
    end
end

% Copyright 2015 The MathWorks, Inc.

