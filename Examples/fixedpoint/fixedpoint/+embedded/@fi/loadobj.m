function y = loadobj(x)
% LOADOBJ Load filter for fi objects from MAT file saved in R2012b 
%         or earlier releases

%   Copyright 2003-2016 The MathWorks, Inc.

if isstruct(x) 
    % Code to convert struct x to a fi object: y
    % Create an embedded.fi and set its properties from structure x
    % Note: in 12b and earlier releases, DataTypeMode field is saved. 
    %       start from 13a, DataType field is saved instead.    
    y = embedded.fi;
    
    if isfield(x, 'DataTypeMode')
        swExpr = x.DataTypeMode;
        x = rmfield(x, 'Tag'); %remove the empty Tag field
    else 
        % MCOS Fi becomes a struct when error happens during load, 
        % one case: Fixed-Point Designer license is not available
        swExpr = x.DataType;        
    end
    
    switch lower(swExpr)
      case 'double'
        y.DataType = 'double';
        y.data = x.Data;
      case 'single'
        y.DataType = 'single';
        y.intarray = x.intarray;
      case 'boolean'
        y.DataType = 'boolean';
        y.intarray = x.intarray;
      otherwise
        cellXVals = struct2cell(x);
        cellXFields = fieldnames(x);
        tmpLength = length(cellXFields);
        for i = 1:tmpLength
            y.(cellXFields{i}) = cellXVals{i};
        end
    end % switch
    
else
    % When Fixed-Point Designer license is available
    y = x;
end
