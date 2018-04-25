function enumeratedStrings = getListOfEnumeratedStrings(input)
% This function retrieves the list of possible values corresponding to a
% meta.property
%   Input - meta.property
%   Output - Cell array of possible values, if any
% 
% The function returns the possible values for the following types of
% properties:
%
% a) Property whose type is an enumeration - Possible values returned as a
%    cell array of char vectors
% b) Property restricted to a set of char vectors by the mustBeMember
%    validation function - Possible values returned as a cell array of
%    char vectors
% c) Property restricted to a set of strings by the mustBeMember validation
%    function - Possible values returned as a cell array of strings
% d) Property restricted to a set of numbers by the mustBeMember validation
%    function - Possible values returned as a cell array of numeric values
%
% When the function returns an empty cell array, one of the following is
% true:
% a) The property is defined using the old property validation syntax 
% b) The property is not typed
% c) There is an error in the property definition

% Copyright 2017 The MathWorks, Inc.

    enumeratedStrings = {};  
    
    % If input is not a meta.property, we must issue an error
    if ~isa(input, 'meta.property')
        error('MATLAB:class:RequireClass', 'Input must be a meta.property');
    else
        if ~isempty(input)
            % The property could correspond to a meta.Type, in which case
            % we must retrieve the possible values from the PossibleValues
            % property
            if isa(input.Type, 'meta.EnumeratedType')
                enumeratedStrings = input.Type.PossibleValues;
            else
                % The property corresponds to a meta.Type and in order to
                % get the list of possible values, we do the following:
                % STEP 1: Get the meta.Validation for the property - This
                %         shows up only if a property has been defined
                %         using the new property type validation syntax
                % STEP 2: Once the meta.Validation has been retrieved, it
                %         has 3 properties. We first check to see what the
                %         Class property points to. If it is a enumeration,
                %         we get the possible values from the
                %         EnumerationMemberList property of the meta.class.
                % STEP 3: If the property does not correspond to an
                %         enumeration, check if any validators have been
                %         defined by looking at the ValidatorFunctions
                %         property. If that correpsonds to the mustBeMember
                %         validator,we retrieve the possible values from it
                
                
                % STEP 1: Identifying properties defined using the new
                % property validation syntax
                validation = [];        
                try
                    validation = input.Validation;
                catch 
                    % Propetry defined using the old validation syntax
                end
                
                if ~isempty(validation)
                    % STEP 2: Identifying enum typed properties
                    cls = validation.Class;
                    if ~isempty(cls)
                        enumeratedStrings = {cls.EnumerationMemberList.Name}'; 
                    end
                
                    % STEP 3: Identifying properties defined using the
                    % mustBeMember validator - Checking for validation
                    % functions if enumeratedStrings is still empty
                    if isempty(enumeratedStrings) && ~isempty(validation.ValidatorFunctions)
                        % If the property validation defines a finite list
                        % of possible values                        
                        enumeratedStrings = getListOfPossibleValues(validation);
                        
                        if ~iscell(enumeratedStrings)
                            % Values must be validated against all the
                            % validator functions defined
                            if validatePossibleValuesDetermined(validation, enumeratedStrings)
                                if isnumeric(enumeratedStrings(1)) || islogical(enumeratedStrings(1))
                                    enumeratedStrings = num2cell(enumeratedStrings);
                                elseif isa(enumeratedStrings(1), 'string')
                                    enumeratedStrings = arrayfun(@(x){x},enumeratedStrings);
                                end
                            else
                                enumeratedStrings = {};
                            end
                        end
                        
                    elseif ~isempty(enumeratedStrings) && ~isempty(validation.ValidatorFunctions)
                        % If a property type is a enumeration and it also
                        % has a mustBeMember validtor correpsonding to a
                        % different set of possible values which cannot be
                        % coerced, we return an empty cell array
                        if ~validatePossibleValuesDetermined(validation, enumeratedStrings)
                            enumeratedStrings = {};
                        end
                    end                    
                end              
            end
            
            % Making sure the output is always a cell column vector
             if ~isempty(enumeratedStrings) && ~iscolumn(enumeratedStrings)
                 enumeratedStrings = reshape(enumeratedStrings,numel(enumeratedStrings),1);
             end
        else
            % Input must not be an empty meta.property
            error('MATLAB:class:RequireScalar', 'Input must be scalar');
        end
    end
end

function out = getListOfPossibleValues(validation)
    % Helper function to get the list of possible values from the
    % ValidatorFunctions propetry of meta.Validation, for properties
    % defined using the mustBeMember validator
    out = {};
    valfcns = validation.ValidatorFunctions;
    for i=1:numel(valfcns)
        [a,~] = regexp(regexprep(func2str(valfcns{i}),'\(|\)',''), 'mustBeMember(.+?),','split');   
        if numel(a) > 1
            out = evalin('base',a{2});
        end  
    end
    
    if isnumeric(out)
        % Coerce the numeric value to the class defined
        if ~isempty(validation.Class)
            cls = validation.Class;
            evalstr = ['out = ' cls.Name '(out);'];
            evalc(evalstr);
        end
    end
end

function validValues = validatePossibleValuesDetermined(validation, enumeratedStrings)
    % This helper function validates the posisble values retrieved by the
    % matlab.internal.getListOfEnumeratedStrings using the validateValue
    % method of meta.Validation. This ensures that we return nothing when
    % properties have been incorrectly defined
    % Validate the possible values determined
    validValues = true;
    try
        validateValue(validation, enumeratedStrings);
    catch
        validValues = false;
    end   
end