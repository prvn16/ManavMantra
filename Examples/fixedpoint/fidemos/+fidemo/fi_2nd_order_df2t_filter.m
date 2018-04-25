function [y,z] = fi_2nd_order_df2t_filter(b,a,x,y,z)
%FI_2ND_ORDER_DF2T_FILTER  Second-order Direct-Form II Transpose Filter
     
% Copyright 2011 The MathWorks, Inc.
    for i=1:length(x)
        y(i) = b(1)*x(i) + z(1);
        z(1) = b(2)*x(i) + z(2) - a(2) * y(i);
        z(2) = b(3)*x(i)        - a(3) * y(i);
    end
end

