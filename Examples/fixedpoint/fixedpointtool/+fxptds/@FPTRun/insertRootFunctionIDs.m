function insertRootFunctionIDs(this, blockUniqueKey, RootFunctionIDs)
%% INSERTROOTFUNCTIONIDS function inserts an entry mapping a block unique key to the root function ids that maps to the block

 % Copyright 2016 The MathWorks, Inc.
    this.RootFunctionIDsMap.insert(blockUniqueKey, {RootFunctionIDs});
end
        