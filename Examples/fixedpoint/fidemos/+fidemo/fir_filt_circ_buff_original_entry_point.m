function y = fir_filt_circ_buff_original_entry_point(b,x,reset)
%FIR_FILT_CIRC_BUFF_ORIGINAL_ENTRY_POINT Entry point file for FIR_FILT_CIRC_BUFF example.
%
%   Y = FIR_FILT_CIRC_BUFF_ORIGINAL_ENTRY_POINT(X,RESET) filters
%   the data in vector X using an FIR filter implemented as a circular
%   buffer.  If RESET=true, then the states in the circular buffer are reset
%   to zero.
%
%   See also FIR_FILT_CIRC_BUFF_FIXED_POINT_CONVERSION_EXAMPLE.
    
%   Copyright 2012 The MathWorks, Inc.

    if nargin<3, reset = true; end
    
    % Define the circular buffer z and buffer position index p.
    % They are declared persistent so the filter can be called in a streaming
    % loop, each section picking up where the last section left off.
    persistent z p
    if isempty(z) || reset
        p = 0;
        z = zeros(size(b));
    end
    [y,z,p] = fir_filt_circ_buff_original(b,x,z,p);
    
end
