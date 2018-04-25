function out = dicom_typecast(in, datatype, varargin)
%DICOM_TYPECAST Convert datatypes, swapping as requested.
%   Y = DICOM_TYPECAST(X, DATATYPE) calls to MATLAB's TYPECAST function
%   and does not swap data endianness.
%
%   Y = DICOM_TYPECAST(X, DATATYPE, SWAP) calls MATLAB's TYPECAST
%   function and changes the endianness if SWAP is true and leaves the
%   bytes alone otherwise.
%
%   Note: DATATYPE must be one of 'UINT8', 'INT8', 'UINT16', 'INT16',
%   'UINT32', 'INT32', 'SINGLE', or 'DOUBLE'.
%

%   Copyright 1993-2005 The MathWorks, Inc.

% Determine whether to swap.
if (nargin == 2)
    
    swap = false;
    
else
    
    swap = varargin{1};
    
end

% Change the type and swap as required.
if (swap)

    % Byte-sized inputs need to be swapped after casting.  Others
    % should be swapped first.
    switch (class(in))
    case {'uint8', 'int8'}

        out = swapbytes(typecast(in, datatype));
        
    otherwise
      
        out = typecast(swapbytes(in), datatype);
    
    end
    
else
    
    out = typecast(in, datatype);
    
end
