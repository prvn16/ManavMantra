function hdfeos_gd_error(error_code, funcName)
%This private function invokes a generic error for the HDFEOS Grid package.

%   Copyright 2010-2013 The MathWorks, Inc.

if error_code < 0
    error(message('MATLAB:imagesci:hdfeos:hdfEosLibraryError', funcName));
end

