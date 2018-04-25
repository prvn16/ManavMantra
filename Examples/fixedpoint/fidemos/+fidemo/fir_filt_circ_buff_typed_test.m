function [y1,y2,y3,y4,y5,y6] = fir_filt_circ_buff_typed_test(b,x)
%FIR_FILT_CIRC_BUFF_TYPED_TEST Example function
%
%   See also FIR_FILT_CIRC_BUFF_FIXED_POINT_CONVERSION_EXAMPLE.

%   Copyright 2012 The MathWorks, Inc.

    y1 = zeros(size(x));
    y2 = zeros(size(x));
    y3 = zeros(size(x));
    y4 = zeros(size(x));
    y5 = zeros(size(x));
    y6 = zeros(size(x));

    for i=1:size(x,2)
        reset = true;
        [y1(:,i),y2(:,i),y3(:,i),y4(:,i),y5(:,i),y6(:,i)] = fir_filt_circ_buff_typed_entry_point_mex(b,x(:,i),reset);
    end

end
