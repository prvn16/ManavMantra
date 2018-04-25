function [y1,y2,y3,y4,y5,y6] = fir_filt_circ_buff_typed_entry_point(b,x,reset)
%FIR_FILT_CIRC_BUFF_TYPED_ENTRY_POINT Example function
%
%   See also FIR_FILT_CIRC_BUFF_FIXED_POINT_CONVERSION_EXAMPLE.

%   Copyright 2012 The MathWorks, Inc.

    if nargin<3, reset = true; end
    
    % Each call to the filter needs to maintain its own states.
    T1 = fir_filt_circ_buff_original_types();
    persistent z1 p1
    if isempty(z1) || reset
        p1 = cast(0,'like',T1.p);
        z1 = zeros(size(b),'like',T1.z);
    end
    b1 = cast(b,'like',T1.b);
    x1 = cast(x,'like',T1.x);
    [y1,z1,p1] = fir_filt_circ_buff_typed(b1,x1,z1,p1,T1);
    
    % Each call to the filter needs to maintain its own states.
    T2 = fir_filt_circ_buff_fixed_point_types();
    persistent z2 p2
    if isempty(z2) || reset
        p2 = cast(0,'like',T2.p);
        z2 = zeros(size(b),'like',T2.z);
    end
    b2 = cast(b,'like',T2.b);
    x2 = cast(x,'like',T2.x);
    [y2,z2,p2] = fir_filt_circ_buff_typed(b2,x2,z2,p2,T2);

    % Each call to the filter needs to maintain its own states.
    T3 = fir_filt_circ_buff_dsp_types();
    persistent z3 p3
    if isempty(z3) || reset
        p3 = cast(0,'like',T3.p);
        z3 = zeros(size(b),'like',T3.z);
    end
    b3 = cast(b,'like',T3.b);
    x3 = cast(x,'like',T3.x);
    [y3,z3,p3] = fir_filt_circ_buff_typed_codegen(b3,x3,z3,p3,T3);

    % Each call to the filter needs to maintain its own states.
    T4 = fir_filt_circ_buff_scaled_double_types();
    persistent z4 p4
    if isempty(z4) || reset
        p4 = cast(0,'like',T4.p);
        z4 = zeros(size(b),'like',T4.z);
    end
    b4 = cast(b,'like',T4.b);
    x4 = cast(x,'like',T4.x);
    [y4,z4,p4] = fir_filt_circ_buff_typed_codegen(b4,x4,z4,p4,T4);


    % Each call to the filter needs to maintain its own states.
    T5 = fir_filt_circ_buff_dsp_types2();
    persistent z5 p5
    if isempty(z5) || reset
        p5 = cast(0,'like',T5.p);
        z5 = zeros(size(b),'like',T5.z);
    end
    b5 = cast(b,'like',T5.b);
    x5 = cast(x,'like',T5.x);
    [y5,z5,p5] = fir_filt_circ_buff_typed_codegen(b5,x5,z5,p5,T5);

    % Each call to the filter needs to maintain its own states.
    T6 = fir_filt_circ_buff_dsp_nearest_types();
    persistent z6 p6
    if isempty(z6) || reset
        p6 = cast(0,'like',T6.p);
        z6 = zeros(size(b),'like',T6.z);
    end
    b6 = cast(b,'like',T6.b);
    x6 = cast(x,'like',T6.x);
    [y6,z6,p6] = fir_filt_circ_buff_typed_codegen(b6,x6,z6,p6,T6);


end


