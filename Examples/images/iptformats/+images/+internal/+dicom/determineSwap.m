function [tf_file, tf_meta, tf_pixel] = determineSwap(txfr_syntax, uid_details)

% Copyright 2002-2017 The MathWorks, Inc.

[~, ~, endian] = computer;

switch (endian)
case 'B'
    
    if (isequal(txfr_syntax, '1.2.840.113619.5.2'))
        tf_file  = 1;
        tf_meta  = 1;
        tf_pixel = 0;
    elseif (isequal(uid_details.Endian, 'ieee-be'))
        tf_file  = 1;
        tf_meta  = 0;
        tf_pixel = 0;
    else
        tf_file  = 1;
        tf_meta  = 1;
        tf_pixel = 1;
    end

case 'L'
    
    if (isequal(txfr_syntax, '1.2.840.113619.5.2'))
        tf_file  = 0;
        tf_meta  = 0;
        tf_pixel = 1;
    elseif (isequal(uid_details.Endian, 'ieee-le'))
        tf_file  = 0;
        tf_meta  = 0;
        tf_pixel = 0;
    else
        tf_file  = 0;
        tf_meta  = 1;
        tf_pixel = 1;
    end
    
end
end
