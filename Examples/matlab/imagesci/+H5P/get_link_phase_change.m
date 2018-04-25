function [max_compact,min_dense] = get_link_phase_change(gcpl_id)
%H5P.get_link_phase_change  Query settings for conversion between groups.
%   [max_compact,min_dense] = H5P.get_link_phase_change(gcpl_id) 
%   retrieves the settings for conversion between compact and dense 
%   groups.
%
%   max_compact is the maximum number of links to store as header messages
%   in the group header before converting the group to the dense format.
%   Groups that are in the compact format and exceed this number of links
%   are automatically converted to the dense format.
%
%   min_dense is the minimum number of links to store in the dense format.
%   Groups which are in dense format and in which the number of links
%   falls below this number are automatically converted back to the
%   compact format.
%
%   Example:
%       gcpl = H5P.create('H5P_GROUP_CREATE');
%       [max_compact, min_dense] = H5P.get_link_phase_change(gcpl);
% 
%   See also H5P, H5P.set_link_phase_change.

%   Copyright 2009-2013 The MathWorks, Inc.

[max_compact, min_dense] = H5ML.hdf5lib2('H5Pget_link_phase_change', gcpl_id);            
