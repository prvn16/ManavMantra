function fi_fft_demo_plot(x, y, y0, Fs, legend1, legend2,error_bound)
%FI_FFT_DEMO_PLOT  Plot FFT output of algorithm under test vs. known output
%   fi_fft_demo_plot(x, y, y0, Fs) plots three subplots: (1) time vs x, (2)
%   frequency vs abs([y(:) y0(:)]), (3) frequency vs error=y-y0, where Fs is
%   the sampling rate in Hz.  The time and frequency vectors start at 0.
%
%   fi_fft_demo_plot(x, y, y0, Fs, legend1, legend2,error_bound) uses legend1 to
%   label the first axis, and legend2 to label the second axis.  If error_bound
%   is provided, it is used to plot the error bound on the third axis.

%   Copyright 2003-2011 The MathWorks, Inc.
%   

n = length(x);
t  = (0:(n-1))/Fs;
f  = linspace(0,Fs,n);

figure(gcf)
subplot(311)
if isreal(x)
  plot(t,x,'.-')
else
  plot(t,real(x),t,imag(x))
end
legend(legend1)
xlabel('Time (s)')
subplot(312)
plot(f,abs(double(y)),'m.-',f,abs(double(y0)),'g.-')
legend(legend2)
xlabel('Frequency (Hz)')
ylabel('Magnitude')
subplot(313)
realerr = real(double(y(:))-double(y0(:)));
imagerr = imag(double(y(:))- double(y0(:)));
abserr = abs(double(y(:))-double(y0(:)));
if nargin<7
    plot(f,abserr,'r.-');
    if (norm(abserr)==0)
        set(gca,'ylim',[-eps eps])
    end
    legend('abs(error)')
else
    %errmean = mean([realerr(:) imagerr(:)]);
    errmean = 0;
    plot(f,realerr,'.-',...
        f,imagerr,'.-',...
        [f(1) f(end)],(error_bound*[1 1])+errmean,'r',...
        [f(1) f(end)],(-error_bound*[1 1])+errmean,'r')
    legend('Real error','Imag error','Error bound')
end

xlabel('Frequency (Hz)')
