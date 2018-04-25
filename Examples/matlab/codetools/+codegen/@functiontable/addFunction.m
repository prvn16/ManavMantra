function addFunction(hFunctionTable,hFunc)
% Add the function object, hFunc, to the function
% table which maps sub functions to header string names

% Copyright 2006 The MathWorks, Inc.

% Get list of functions in table
hFuncList = get(hFunctionTable,'FunctionList');

% See if the function is already registered in the table
found_match = any(hFuncList == hFunc);

% If this function is not already in the table, then add it
% by creating a table entry and assigning the function a 
% text name that will be used in the generated code.
if ~found_match

    % Add argument to function list
    hFuncList = [hFunc, get(hFunctionTable,'FunctionList')];
    set(hFunctionTable,'FunctionList',hFuncList);
 
    % Generate string name for function
    thisname = get(hFunc,'Name');
    if isempty(thisname)
        thisname = 'function';
    end
    
    % See if this function name is already present in the 
    % function list
    namelist = get(hFunctionTable,'FunctionNameList');
    namelistcount = get(hFunctionTable,'FunctionNameListCount'); 
    ind = find(strcmpi(namelist,thisname)==true);
    
    % If it is not in the list, then add it
    if isempty(ind) 
        count = 1;
        newname = thisname;
        while exist(newname)
            count = count+1;
            newname = sprintf('%s%d',thisname,count-1);
        end
        set(hFunctionTable,'FunctionNameList',{namelist{:},thisname});
        set(hFunctionTable,'FunctionNameListCount',[namelistcount,count]);
    
    % If it is in the list, increment function count
    else
        count = namelistcount(ind(1))+1;
        namelistcount(ind(1)) = count;
        set(hFunctionTable,'FunctionNameListCount',namelistcount);
        newname = sprintf('%s%d',thisname,count-1);
    end
    set(hFunc,'String',newname);
end