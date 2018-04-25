function seOut = strelcheck(se,func_name,arg_name,arg_pos)
%Check validity of structuring element and convert to STREL object.
%  The structuring element can be any of the following:
%  * Real, UINT8 gpuArray with 0's and 1's (neighborhood).
%  * Real, LOGICAL gpuArray.
%  * Real neighborhood-style array.
%  * STREL object.
%  * Array of STREL objects.

%   Copyright 2012 The MathWorks, Inc.

% If strel object.
if isa(se,'strel')
    seOut = se;
else
    % If gpuArray.
    if isa(se,'gpuArray')
        % Convert to neighborhood-style array.
        se = gather(se);
    end
    % Neighborhood-style array    
    if ~( isnumeric(se) || islogical(se) )
        error(message('images:strelcheck:invalidStrelType',func_name,...
                            iptnum2ordinal(arg_pos),arg_name));
    else
        if issparse(se)
            se = full(se);
        end
        se = double(se);
        if ~isempty(se)
            bad_elements = (se ~= 0) & (se ~= 1);
            if any(bad_elements(:))
                error(message('images:strelcheck:invalidStrelValues',...
                                arg_name,iptnum2ordinal(arg_pos),...
                                func_name));
            end
        end
        seOut = strel(se);
    end
end 
%--------------------------------------------------------------------------