function layout = get_layout(dcpl)
%H5P.get_layout  Determine layout of raw data for dataset.
%   layout = H5P.get_layout(dcpl) returns the layout of the raw data for
%   the dataset specified by the dataset creation property list, dcpl.
%   Possible values are: possible values are: H5D_COMPACT, H5D_CONTIGUOUS,
%   or H5D_CHUNKED.
%
%   Example:
%       fid = H5F.open('example.h5');
%       dset_id = H5D.open(fid,'/g3/integer');
%       dcpl = H5D.get_create_plist(dset_id);
%       layout = H5P.get_layout(dcpl);
%       switch(layout)
%           case H5ML.get_constant_value('H5D_COMPACT')
%               fprintf('layout is compact\n');
%           case H5ML.get_constant_value('H5D_CONTIGUOUS')
%               fprintf('layout is contiguous\n');
%           case H5ML.get_constant_value('H5D_CHUNKED')
%               fprintf('layout is chunked\n');
%       end
%
%   See also H5P, H5P.set_layout.

%   Copyright 2006-2013 The MathWorks, Inc.

layout = H5ML.hdf5lib2('H5Pget_layout', dcpl);            
