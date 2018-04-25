function T = fi_m_radix2fft_scaled_fixed_types()
%FI_M_RADIX2FFT_SCALED_FIXED_TYPES Example function
%
%   Copyright 2015 The MathWorks, Inc.

    DT = 'ScaledDouble';                % Data type to be used for fi
                                        % constructor
    T.x = fi([],1,16,14,'DataType',DT); % Picked the following types to
    T.w = fi([],1,16,14,'DataType',DT); % ensure that the inputs have
                                        % maximum precision and will not
                                        % overflow
    T.n = int32([]);                    % Picked int32 as n is an index

end
