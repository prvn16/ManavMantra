function fir_filt_circ_buff_plot2(fig,titles,t,x,y0,y1)
%FIR_FILT_CIRC_BUFF_PLOT2 Example function
%
%   See also FIR_FILT_CIRC_BUFF_FIXED_POINT_CONVERSION_EXAMPLE.

%   Copyright 2012 The MathWorks, Inc.

    figure(fig)
    clf reset
    sub_plot = 1;
    for i=1:size(x,2)
        subplot(4,2,sub_plot); sub_plot = sub_plot+1;
        plot(t,x(:,i),'c',t,y1(:,i),'k')
        axis('tight')
        xlabel('t');
        title(titles{i});
        subplot(4,2,sub_plot); sub_plot = sub_plot+1;
        plot(t,y0(:,i)-y1(:,i),'r')
        axis('tight')
        xlabel('t');
        title([titles{i},' error']);
    end
    figure(gcf)
end
