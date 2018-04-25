function vecStr = vecToColonStr(vec)
    % VECTOCOLONSTR Converts the vector into colon format string, 
    % only supports horizontal vectors 
    
    % Copyright 2017 The MathWorks, Inc.
        
    % Convert to regular string format if length of the vector is 1    
    if length(vec) == 1
        vecStr = mat2str(vec); 
        return;
    end
    
    % Get min max values to create colon string
    x = minmax(vec);   
    
    % Convert the linear spaced vector to colon notation
    vecStr = strcat(num2str(x(1)), ':', num2str(x(2))); 
end

