function T = fir_filt_circ_buff_fixed_point_types()
%FIR_FILT_CIRC_BUFF_FIXED_POINT_TYPES Example function
%
%   See also FIR_FILT_CIRC_BUFF_FIXED_POINT_CONVERSION_EXAMPLE.

%   Copyright 2012 The MathWorks, Inc.
    T.acc=fi([],true,32,30);
    T.b=fi([],true,16,17);
    T.p=int16([]);
    T.x=fi([],true,16,14);
    T.y=fi([],true,16,14);
    T.z=fi([],true,16,14);
end
