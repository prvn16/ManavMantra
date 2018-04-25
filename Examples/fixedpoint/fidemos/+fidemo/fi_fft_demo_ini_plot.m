function fi_fft_demo_ini_plot(t,x0,f,y0)
%FI_FFT_DEMO_INI_PLOT  Plot FFT output from built in MATLAB function
%   fi_fft_demo_ini_plot(t,x0,f,y0) plots two subplots:
%   (1) time vs x,
%   (2) frequency vs abs(y0(:))
%
%   Copyright 2015 The MathWorks, Inc.
%
    figure(gcf);
    clf;
    set(gcf,'Position',[100 100 1000 1000])

    g1 = subplot(211); % Time-domain plot
    plot(t,real(x0),'.-','Linewidth',2,'Markersize',20)
    xlabel('Time (s)')
    ylabel('Amplitude')
    legend('x0','Location','Best')
    g1.LineWidth = 2;
    g1.FontSize = 16;

    g2 = subplot(212); % Frequency-domain plot
    plot(f,abs(y0),'r.-','Linewidth',2,'Markersize',20)
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    legend('abs(fft(x0))','Location','Best')
    g2.LineWidth = 2;
    g2.FontSize = 16;

end
