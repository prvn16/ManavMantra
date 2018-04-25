function addVariable(hVariableTable,hArg)
% Add the argument object, hArg, to the variable
% table which maps arguments to variable string names

% Copyright 2006-2015 The MathWorks, Inc.

% Special-case for variables with a name of '~'.  These are used to ignore
% output arguments.  They should never be renamed, and they can never be
% used later as the input to anything, so they don't need to be in the
% variable table at all.  We just need to make sure their string is
% correct.
if isequal(hArg.Name, '~')
    hArg.String = '~';
    return
end

% Get list of variables in table
hVarList = get(hVariableTable,'VariableList');
n_var = length(hVarList);
found_match = false;
hPossibleArgMatchList = [];
hRegisteredTable = get(hArg,'VariableTable');
if ~isempty(hRegisteredTable) && (hRegisteredTable ~= hVariableTable)
    error(message('MATLAB:codetools:codegen:InvalidRegistration'));
else
    set(hArg,'VariableTable',hVariableTable);
end

% Loop through and see if argument object is equal to any
% of the previously defined variables.
n = 1;
flag = false;
while ~flag && n <= n_var
   hCandidateArg = hVarList(n); 
   
   % If we find a match...
   if isequal(hArg,hCandidateArg)
       
       % Assign the input variable the string of the variable in
       % the table
       str = get(hCandidateArg,'String');
       set(hArg,'String',str);
       % Set the active variable property of the argument
       set(hArg,'ActiveVariable',hCandidateArg);
       found_match = true;
       
       % If the argument is an output argument, mark the argument in
       % the variable as an output argument too, so that we can keep
       % track of how many variables are getting created.
       if get(hArg,'IsOutputArgument')
           set(hCandidateArg,'IsOutputArgument',true);
       end
       flag = true;
   
   % args do not match
   % check to see if we are comparing a handle to an array
   % of vector handles
   else
      value_arg = get(hArg,'Value');
      value_candidate_arg = get(hCandidateArg,'Value');
      
      % flag possible match between a handle and a handle vector
      if isscalar(value_arg) && ishandle(value_arg) && ...
         strcmp(class(handle(value_arg)),class(value_candidate_arg)) && ...
         length(value_arg) ~= length(value_candidate_arg)
            hPossibleArgMatchList = [hPossibleArgMatchList;hCandidateArg];  
      end
   end
   n = n + 1;
end

% Check to see if the input handle is already referenced inside a 
% vector of handles
if ~found_match && ~isempty(hPossibleArgMatchList)
   n = 1;
   while ~found_match &&  n <= length(hPossibleArgMatchList)
      value_candidate_arg = get(hPossibleArgMatchList(n),'Value');
      value_arg = get(hArg,'Value');
      ind = find(value_candidate_arg==value_arg);
      
      % if handle is within vector
      if ~isempty(ind)
          % assign the variable a name that indexes the other variable
          var_name = get(hPossibleArgMatchList(n),'String');
          var_name = [var_name,'(',num2str(ind),')'];
          set(hArg,'String',var_name);
          set(hArg,'IsOutput',true); % prevents from being input arg
          % Set the active variable property of the argument
          set(hArg,'ActiveVariable',hPossibleArgMatchList(n));
           
          % add argument to variable list
          hVarList = [hArg, get(hVariableTable,'VariableList')];
          set(hVariableTable,'VariableList',hVarList); 
          found_match = true;
      end
      n = n + 1;
   end
end

% If this variable is not already in the table, then add it
% by creating a table entry and assigning the variable a 
% text name that will be used in the generated code.
if ~found_match

    % Add argument to variable list
    hVarList = [hArg, get(hVariableTable,'VariableList')];
    set(hVariableTable,'VariableList',hVarList);
    set(hArg,'ActiveVariable',hArg);

    % Assign the variable a name not already in use.
    % Variable name has the following template: 
    % <class>n
    % Examples: figure1, data2, axes5
    val = get(hArg,'Value');
    
    % Convert to handle if numeric handle
    if ishandle(val), val = handle(val); end
    
    % Generate string name for variable
    thisname = get(hArg,'Name');
    if isempty(thisname)
       % Create string representing the variable "type"
       if isnumeric(val)
          thisname = 'data';
       else
          thisname = class(val);  
       end
    end
    
    % Remove '.' characters from variable name 
    thisname = strrep(thisname,'.','_');
    
    % See if this variable type is already present in the 
    % variable list
    namelist = get(hVariableTable,'VariableNameList');
    namelistcount = get(hVariableTable,'VariableNameListCount'); 
    ind = find(strcmpi(namelist,thisname)==true);
    
    % If it is not in the list, then add it
    if isempty(ind) 
        count = 1;
        set(hVariableTable,'VariableNameList',[namelist, {thisname}]);
        set(hVariableTable,'VariableNameListCount',[namelistcount,count]);
    
    % If it is in the list, increment variable count
    else
        count = namelistcount(ind(1))+1;
        namelistcount(ind(1)) = count;
        set(hVariableTable,'VariableNameListCount',namelistcount);
    end
    newname = sprintf('%s%d',thisname,count);
    set(hArg,'String',newname);
end