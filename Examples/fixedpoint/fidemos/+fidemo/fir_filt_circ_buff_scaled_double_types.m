function T = fir_filt_circ_buff_scaled_double_types()
%FIR_FILT_CIRC_BUFF_SCALED_DOUBLE_TYPES Example function
%
%   See also FIR_FILT_CIRC_BUFF_FIXED_POINT_CONVERSION_EXAMPLE.

%   Copyright 2012 The MathWorks, Inc.
    F = fimath('RoundingMethod','Floor',...
               'OverflowAction','Wrap',...
               'ProductMode','KeepLSB',...
               'ProductWordLength',32,...
               'SumMode','KeepLSB',...
               'SumWordLength',32);
    DT = 'ScaledDouble';
    T.acc=fi([],true,32,30,F,'DataType',DT);
    T.p=int16([]);
    T.b=fi([],true,16,17,F,'DataType',DT);
    T.x=fi([],true,16,14,F,'DataType',DT);
    T.y=fi([],true,16,14,F,'DataType',DT);
    T.z=fi([],true,16,14,F,'DataType',DT);
end
