function [y,z,p] = fir_filt_circ_buff_typed(b,x,z,p,T)
%FIR_FILT_CIRC_BUFF_TYPED Finite impulse response filter with circular buffer
%
%    [y,z,p] = fir_filt_circ_buff_typed(b,x,z,p,T) filters the data in
%    vector x using an efficient circular buffer implementation with the
%    filter described by vector b to create the filtered data y.  
%
%    Output y(n) is equal to
% 
%      y(n) = b(1)*x(n) + b(2)*x(n-1) + ... + b(nb)*x(n-nb+1)
%
%    where nb=length(b).
%
%    The states are stored in a circular buffer, z, which should be
%    the same size as b.  For all zero initial states, initialize z as
%    
%      z = zeros(size(b));
%
%    The circular buffer position index p should be initialized to 
%
%      p = 0;
%
%   Example:
%
%     %% Input data
%     t = linspace(0,10*pi,200);
%     f0=0.1; f1=2;
%     x = sin(2*pi*t*f0) + 0.1*sin(2*pi*t*f1);
%
%     %% Filter coefficients
%     b = fir1(24,0.25);
%
%     %% Initialize the states
%     z = zeros(size(b));
%     p = 0;
%
%     %% Call the filter
%     [y,z,p] = fir_filt_circ_buff_typed(b,x,z,p,T);
%
%     %% Plot
%     clf
%     plot(t,x,t,y)
%     legend('Input','Filtered output');
%     figure(gcf)
%
%   See also FILTER, FIR_FILT_CIRC_BUFF_FIXED_POINT_CONVERSION_EXAMPLE. 

%   Copyright 2012 The MathWorks, Inc.

    y = zeros(size(x),'like',T.y);
    nx = length(x);
    nb = length(b);
    for n=1:nx
        p(:)=p+1; if p>nb, p(:)=1; end
        z(p) = x(n);
        acc = cast(0,'like',T.acc);
        k = p;
        for j=1:nb
            acc(:) = acc + b(j)*z(k);
            k(:)=k-1; if k<1, k(:)=nb; end
        end
        y(n) = acc;
    end
end
