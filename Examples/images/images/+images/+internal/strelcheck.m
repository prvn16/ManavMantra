function se = strelcheck(in,func_name,arg_name,arg_position) %#codegen
%STRELCHECK Check validity of STREL object, or convert neighborhood to STREL.
%   SE = STREL(IN) returns IN if it is already a STREL; otherwise it
%   assumes IN is a neighborhood-style array and tries to convert it to a
%   STREL.

%   Copyright 2013-2015 The MathWorks, Inc.
  
coder.extrinsic('iptnum2ordinal');

if isa(in, 'strel') || isa(in, 'offsetstrel')
    se = in;
else
    
    coder.internal.errorIf(~( isnumeric(in) || islogical(in) ),...
        'images:strelcheck:invalidStrelType', ...
        func_name, coder.internal.const(iptnum2ordinal( arg_position )), arg_name);
    
    if issparse(in)
        in = full(in);
    end
    in = double(in);
    if ~isempty(in)
        bad_elements = (in ~= 0) & (in ~= 1);
        coder.internal.errorIf(any(bad_elements(:)),...
            'images:strelcheck:invalidStrelValues', ...
                arg_name, coder.internal.const(iptnum2ordinal( arg_position )), func_name);
    end
    se = strel(in);
end
