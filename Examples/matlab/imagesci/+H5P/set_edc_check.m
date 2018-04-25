function set_edc_check(plist_id, check)
%H5P.set_edc_check  Enable error-detection for dataset transfer.
%   H5P.set_edc_check(plist_id, check) sets the dataset transfer property
%   list specified by plist_id to enable or disable error detection when
%   reading data. check can have the value H5Z_ENABLE_EDC or
%   H5Z_DISABLE_EDC.
%
%   Example:  disable error detection for a default dataset transfer
%   property list.
%       dxpl = H5P.create('H5P_DATASET_XFER');
%       H5P.set_edc_check(dxpl,'H5Z_DISABLE_EDC');
%
%   See also H5P, H5P.get_edc_check.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_edc_check', plist_id, check);

