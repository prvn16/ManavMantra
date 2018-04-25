function [y,z] = fir_filt_linear_buff(b,x,z)
%FIR_FILT_LINEAR_BUFF Example function
%
%   See also FIR_FILT_CIRC_BUFF_FIXED_POINT_CONVERSION_EXAMPLE.

%   Copyright 2012 The MathWorks, Inc.
    y = zeros(size(x));
    for n=1:length(x)
        z = [x(n); z(1:end-1)];
        y(n) = b * z;
    end
end
    
