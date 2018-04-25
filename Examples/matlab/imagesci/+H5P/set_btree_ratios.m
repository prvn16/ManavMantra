function set_btree_ratios(plist_id, left, middle, right)
%H5P.set_btree_ratios  Set B-tree split ratios for dataset transfer.
%   H5P.set_btree_ratios(plist_id, left, middle, right) sets the B-tree
%   split ratios for the dataset transfer property list specified by
%   plist_id. left specifies the B-tree split ratio for left-most nodes;
%   right specifies the B-tree split ratio for right-most nodes and lone
%   nodes; middle specifies the B-tree split ratio for all other nodes.
%
%   Example:
%       dxpl = H5P.create('H5P_DATASET_XFER');
%       H5P.set_btree_ratios(dxpl, 0.2, 0.6, 0.95);
%
%   See also H5P, H5P.get_btree_ratios.

%   Copyright 2006-2013 The MathWorks, Inc.

H5ML.hdf5lib2('H5Pset_btree_ratios', plist_id, left, middle, right);            
