function fir_filt_circ_buff_plot(fig,titles,t,x,y)
%FIR_FILT_CIRC_BUFF_PLOT Example function
%
%   See also FIR_FILT_CIRC_BUFF_FIXED_POINT_CONVERSION_EXAMPLE.

%   Copyright 2012 The MathWorks, Inc.

    figure(fig)
    clf reset
    sub_plot = 1;
    for i=1:size(x,2)
        subplot(4,1,sub_plot); sub_plot = sub_plot+1;
        plot(t,x(:,i),'c',t,y(:,i),'k')
        axis('tight')
        xlabel('t');
        title(titles{i});
        legend('Input','Baseline Output','Location','BestOutside')
        figure(gcf)
    end

