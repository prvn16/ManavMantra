function groups = getGroups(this)
    % GETGROUPS this function return the registered data type groups cell 
    % array from the interface
    
    % Copyright 2016 The MathWorks, Inc.
    
    % return all registered data type groups in the interface
    groups = this.dataTypeGroups.values;
end