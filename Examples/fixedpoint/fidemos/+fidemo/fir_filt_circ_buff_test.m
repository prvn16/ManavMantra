function y = fir_filt_circ_buff_test(b,x)
%FIR_FILT_CIRC_BUFF_TEST Example function
%
%   See also FIR_FILT_CIRC_BUFF_FIXED_POINT_CONVERSION_EXAMPLE.

%   Copyright 2012 The MathWorks, Inc.

    y = zeros(size(x));

    for i=1:size(x,2)
        reset = true;
        y(:,i) = fir_filt_circ_buff_original_entry_point_mex(b,x(:,i),reset);
    end

end
