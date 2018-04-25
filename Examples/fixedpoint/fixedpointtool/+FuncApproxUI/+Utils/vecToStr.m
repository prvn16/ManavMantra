function vecStr = vecToStr(vec, limit)
    % VEC2STR Converts the vector into a string, compresses linearly spaced
    % vectors into colon notation, only supports horizontal vectors 
      
    % Copyright 2017 The MathWorks, Inc.
    
    % Return the original vector in string format if length does not exceed
    % limit
    len = length(vec);
    if len < limit
        vecStr = mat2str(vec);
        return;
    end 
    
    % Construct the string for the colon format of the vector if possible
    vecStr = strcat('[', {' '});
    
    % Find elements that differ by 1 and include the final value in the 
    % array (which is why 0 is appended) 
    ad = [diff(vec) == 1 0];

    % Find the subsets that differ by 1
    numcells = sum(ad==0);
    
    % Create a cell array of subsets
    out = cell(1,numcells);
    
    % Find the bounds of the subsets 
    indends = find(ad == 0);
    
    % Loop through the subsets and convert them to colon format
    ind = 1;
    toColon = @FuncApproxUI.Utils.vecToColonStr;
    for k = 1:numcells
       out{k} = vec(ind:indends(k));
       ind = indends(k)+1;
       vecStr = strcat(vecStr, toColon(out{k}), {' '});
    end  
    
    % Wrapup the string for the colon format of the vector
    vecStr = strcat(vecStr,']');
    
    % Convert the cell array output to char 
    vecStr = char(vecStr);
end


