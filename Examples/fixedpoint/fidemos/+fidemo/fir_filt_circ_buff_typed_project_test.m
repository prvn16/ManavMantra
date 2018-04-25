function [t,x,y1,y2,y3,y4] = fir_filt_circ_buff_typed_project_test
%FIR_FILT_CIRC_BUFF_TYPED_PROJECT_TEST Example function
%
%   See also FIR_FILT_CIRC_BUFF_FIXED_POINT_CONVERSION_EXAMPLE.

%   Copyright 2012 The MathWorks, Inc.

    % The filter coefficients were computed using the FIR1 function from
    % Signal Processing Toolbox.
    %   b = fir1(11,0.25);
    b = [-0.004465461051254
         -0.004324228005260
         +0.012676739550326
         +0.074351188907780
         +0.172173206073645
         +0.249588554524763
         +0.249588554524763
         +0.172173206073645
         +0.074351188907780
         +0.012676739550326
         -0.004324228005260
         -0.004465461051254]';


    % Input signal
    nx = 256;
    t = linspace(0,10*pi,nx)';

    % Impulse
    x_impulse = zeros(nx,1); x_impulse(1) = 1;

    % Max Gain
    % The maximum gain of a filter will occur when the inputs line up with the
    % signs of the filter's impulse response.
    x_max_gain = sign(b)';
    x_max_gain = repmat(x_max_gain,ceil(nx/length(b)),1);
    x_max_gain = x_max_gain(1:nx);

    % Sums of sines
    f0=0.1; f1=2;
    x_sines = sin(2*pi*t*f0) + 0.1*sin(2*pi*t*f1);

    % Chirp
    f_chirp = 1/16;                  % Target frequency
    x_chirp = sin(pi*f_chirp*t.^2);  % Linear chirp

    x = [x_impulse, x_max_gain, x_sines, x_chirp];
    
    y1 = zeros(size(x)); % T1 = fir_filt_circ_buff_original_types();
    y2 = zeros(size(x)); % T2 = fir_filt_circ_buff_fixed_point_types();
    y3 = zeros(size(x)); % T3 = fir_filt_circ_buff_dsp_types();
    y4 = zeros(size(x)); % T4 = fir_filt_circ_buff_scaled_double_types();
    y5 = zeros(size(x)); % T5 = fir_filt_circ_buff_dsp_types2();
    y6 = zeros(size(x)); % T6 = fir_filt_circ_buff_dsp_nearest_types();

    for i=1:size(x,2)
        reset = true;
        [y1(:,i),y2(:,i),y3(:,i),y4(:,i),y5(:,i),y6(:,i)] = ...
            fir_filt_circ_buff_typed_entry_point(b,x(:,i),reset);
    end
    
    titles = {'Impulse', 'Max output', 'Sum of sines', 'Chirp'};

    fir_filt_circ_buff_plot2(1,titles,t,x,y1,y2);
    set(gcf,'Name','Fixed Point Types');

    fir_filt_circ_buff_plot2(2,titles,t,x,y1,y3);
    set(gcf,'Name','DSP Types');

    fir_filt_circ_buff_plot2(3,titles,t,x,y1,y4);
    set(gcf,'Name','Scaled Double Types');

    fir_filt_circ_buff_plot2(4,titles,t,x,y1,y5);
    set(gcf,'Name','DSP Types without overflow');

    fir_filt_circ_buff_plot2(5,titles,t,x,y1,y6);
    set(gcf,'Name','DSP Nearest Types')

end
