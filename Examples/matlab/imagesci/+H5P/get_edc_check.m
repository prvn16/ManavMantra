function value = get_edc_check(plist_id)
%H5P.get_edc_check  Determine if error detection is enabled.
%   check = H5P.get_edc_check(plist_id) queries the dataset transfer
%   property list, specified by plist, to determine whether error detection
%   is enabled for data read operations. Returns either H5Z_ENABLE_EDC or
%   H5Z_DISABLE_EDC.
%
%   Example:
%       dxpl = H5P.create('H5P_DATASET_XFER');
%       check = H5P.get_edc_check(dxpl);
%       switch(check)
%           case H5ML.get_constant_value('H5Z_ENABLE_EDC')
%               fprintf('error detection enabled\n');
%           case H5ML.get_constant_value('H5Z_DISABLE_EDC');
%               fprintf('error detection disabled\n');
%       end
%
%   See also H5P, H5P.set_edc_check.

%   Copyright 2006-2013 The MathWorks, Inc.

value = H5ML.hdf5lib2('H5Pget_edc_check', plist_id);
