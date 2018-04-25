function bool = isequal(hArg1,hArg2)
% Return true if both input args have equivalent value

% Copyright 2006-2015 The MathWorks, Inc.

if ~isa(hArg2,'codegen.codeargument')
    bool = false;
    
elseif hArg1 == hArg2
    % Return true if the two argument references are identical
    bool = true;
    
else
    % Compare values
    val1 = hArg1.Value;
    val2 = hArg2.Value;
    
    if isempty(val1) && isempty(val2)
        % Empty values are never treated as equal
        bool = false;
        
    else
        % Test for scalar doubles that are handles, for compatibility with
        % the old graphics system. If both val1 and val2 are scalar doubles then convert them check if they can be converted to hanldes        
        if localIsDoubleHandle(val1) && localIsDoubleHandle(val2)
             val1 = handle(val1);
             val2 = handle(val2);             
        end          
        
        if isa(val1, 'handle') && isa(val2, 'handle')
            % Compare handle references with eq operator
            if isequal(size(val1), size(val2))
                eqvals = val1==val2;
                bool = all(eqvals(:));
            else
                bool = false;
            end
            
        else
            % Perform all other tests with the standard isequal function
            bool = isequal(val1,val2);
        end
    end
end
end

function ret = localIsDoubleHandle(val)
 ret = isa(val, 'double') && isscalar(val) && ishghandle(val);
end
