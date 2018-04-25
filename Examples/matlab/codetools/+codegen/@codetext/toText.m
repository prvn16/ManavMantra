function toText(hTextLine,hVariableTable)
% Determines text representation

% Copyright 2006 The MathWorks, Inc.

var = get(hTextLine,'Text');
for n = 1:length(var)
    if isa(var{n},'codegen.codeargument')
        hArgin = var{n};
        % Convert data type into text representation
        err = hArgin.toText(hVariableTable);
        % Prevent the variable from being removed during code generation:
        setRemovalPermissions(hArgin.ActiveVariable,false);
        
        % If an error occurred converting the argument into text
        % then ignore this property. 
        if err
            set(hArgin,'Ignore',true);
            set(hTextLine,'Ignore',true);
        end
    end
end