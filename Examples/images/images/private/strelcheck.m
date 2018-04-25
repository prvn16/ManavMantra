function se = strelcheck(in,func_name,arg_name,arg_position)
%STRELCHECK Check validity of STREL object, or convert neighborhood to STREL.
%   SE = STREL(IN) returns IN if it is already a STREL; otherwise it
%   assumes IN is a neighborhood-style array and tries to convert it to a
%   STREL.

%   Copyright 1993-2011 The MathWorks, Inc.
  
if isa(in, 'strel')
    se = in;
else
    if ~( isnumeric(in) || islogical(in) )
        error(message('images:strelcheck:invalidStrelType', func_name, iptnum2ordinal( arg_position ), arg_name))
              
    else
        if issparse(in)
            in = full(in);
        end
        in = double(in);
        if ~isempty(in)
            bad_elements = (in ~= 0) & (in ~= 1);
            if any(bad_elements(:))
                error(message('images:strelcheck:invalidStrelValues', arg_name, iptnum2ordinal( arg_position ), func_name))
            end
        end
        se = strel(in);
    end
end
