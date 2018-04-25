function hdf4_sd_error(funcName)
%This private function invokes a generic error for the HDF4 SD package.

%   Copyright 2013 The MathWorks, Inc.

error(message('MATLAB:imagesci:sd:hdfLibraryError', funcName));

