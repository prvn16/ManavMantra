function t = setProperty(t,name,p)
%SETPROPERTY Set a table property.

%   Copyright 2012-2016 The MathWorks, Inc.

% We may be given a name (when called from set), or a subscript expression
% that starts with a '.name' subscript (when called from subsasgn).  Get the
% name and validate it in any case.

import matlab.tabular.Continuity

if isstruct(name)
    s = name;
    if s(1).type ~= '.'
        error(message('MATLAB:table:InvalidSubscript'));
    end
    name = s(1).subs;
    haveSubscript = true;
else
    haveSubscript = false;
end
% Allow partial match for property names if this is via the set method;
% require exact match if it is direct assignment via subsasgn
name = tabular.matchPropertyName(name,t.propertyNames,haveSubscript);

if haveSubscript && ~isscalar(s)
    % If this is 1-D named parens/braces subscripting, convert labels to 
    % correct indices for properties that support subscripting with labels. 
    % e.g. t.Properties.RowNames('SomeRowName')
    if ~strcmp(s(2).type,'.') && isscalar(s(2).subs)
        sub = s(2).subs{1};
        if matlab.internal.datatypes.isCharStrings(sub) % a name, names, or colon
            switch name
            case {'VariableNames' 'VariableDescriptions' 'VariableUnits' 'VariableContinuity'}
                s(2).subs{1} = t.varDim.subs2inds(sub);
            case {'RowNames' 'RowTimes'}
                s(2).subs{1} = t.rowDim.subs2inds(sub);
            case 'DimensionNames'
                s(2).subs{1} = t.metaDim.subs2inds(sub);
            end
        end
    end
    % If there's cascaded subscripting into the property, get the existing
    % property value and let the property's subsasgn handle the assignment.
    % The property may currently be empty, ask for a non-empty default
    % version to allow assignment into only some elements. Guarantee correct
    % dispatch for the assignment by working inside a scalar cell and letting
    % built-in cell subscripting dispatch.
    LHScell = { t.getProperty(name,true) };
    
    s(1).type = '{}'; s(1).subs = {1};

    if strcmp(name,'UserData')
        LHScell = matlab.internal.tabular.private.subsasgnRecurser(LHScell,s,p);
    else
        % We want to catch assigning '' into the variable properties using parens
        % to throw a better error message. Assigning '' into an array means
        % deletion, but it most likely wasn't the user's intention for these
        % properties - they probably wanted to assign empty. Deleting a single
        % value from variable properties is not a possible operation since the
        % number of variable properties must match the number of variables. Thus,
        % an error will be thrown for incorrect number of continuity later on,
        % which will be confusing. Throw a better error here instead.
        if isequal(p,'') && strcmp(s(2).type,'()')
            if any(strcmp(name,{'VariableNames' 'VariableDescriptions' 'VariableUnits'}))
                error(message('MATLAB:invalidConversion','cell','char'));
            elseif strcmp(name,'VariableContinuity')
                error(message('MATLAB:table:InvalidContinuityValue'));
            end           
        end
        
        try
            LHScell = builtin('subsasgn',LHScell,s,p);
        catch ME 
            if strcmp(ME.identifier,'MATLAB:UnableToConvert') && strcmp(name,'VariableContinuity')
                % Need to check for invalid enum value, for better error message. 
                error(message('MATLAB:table:InvalidContinuityValue'));
            else
                rethrow(ME);
            end
        end   
    end
    p = LHScell{1};
    % The assignment may change the property's shape or size or otherwise make
    % it invalid; that gets checked by the individual setproperty methods called
    % below.
else
    % If we are not assigning into property, we want to error in one specific
    % case, when the assignment is for the whole VariableContinuity property
    % and the value being assigned is character vector.
    if ischar(p) && strcmp(name,'VariableContinuity')
    	error(message('MATLAB:table:InvalidContinuityFullAssignment')); 
    end
end

% Assign the new property value into the dataset.
switch name
case {'RowNames' 'RowTimes'}
    t.rowDim = t.rowDim.setLabels(p); % error if duplicate, or empty
case 'VariableNames'
    t.varDim = t.varDim.setLabels(p); % error if invalid, duplicate, or empty
    % Check for conflicts between the new VariableNames and the existing
    % DimensionNames. For backwards compatibility, a table will modify
    % DimensionNames and warn, while a timetable will error.
    t.metaDim = t.metaDim.checkAgainstVarLabels(t.varDim.labels);
case 'DimensionNames'
    t.metaDim = t.metaDim.setLabels(p); % error if duplicate, or empty
    % Check for conflicts between the new DimensionNames and the existing
    % VariableNames. For backwards compatibility, a table will modify
    % DimensionNames and warn, while a timetable will error.
    t.metaDim = t.metaDim.checkAgainstVarLabels(t.varDim.labels);
case 'VariableDescriptions'
    t.varDim = t.varDim.setDescrs(p);
case 'VariableUnits'
    t.varDim = t.varDim.setUnits(p);
case 'VariableContinuity'
    % Assigning single character vector to whole VariableContinuity property
    % should already be caught above.
    t.varDim = t.varDim.setContinuity(p);
case 'Description'
    t = t.setDescription(p);
case 'UserData'
    t = t.setUserData(p);
end
