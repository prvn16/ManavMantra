function clearData(this)
%% CLEARMAP function clears all the records in ScopingTable
% Primarily used as a test hook to clean up scoping table before running
% each test point

%   Copyright 2016 The MathWorks, Inc.

    this.ScopingTable(:,:) = [];
    this.ChangesetTable(:,:) = [];
    this.CurScopingChangeset = {};
end