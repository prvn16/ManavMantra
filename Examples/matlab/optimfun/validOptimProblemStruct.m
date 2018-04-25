function [isValid,errmsg,myStruct] = validOptimProblemStruct(myStruct,requiredFields,validValues)
%

%validOptimProblemStruct validates optimization problem structure.
%   Checks if 'myStruct' contains all the fields in the cell
%   array 'requiredFields'. To validate the values of 'requiredFields'
%   pass 'validValues'. The argument 'validValues' must be a nested cell
%   array of valid values. The output argument 'isValid' is a  boolean.
%
%   Example:
%
%    % Create a problem structure that has wrong value for 'solver' field
%      probStruct = struct('solver','fminx','options',optimset);
%    % Suppose requiredFields are 'solver' and 'options'
%    % Get valid solver names using createProblemStruct and assume options
%    % have no known valid values (any value is okay)
%      validValues = {fieldnames(createProblemStruct('solvers')), {} };
%    % Validate the structure 'probStruct'
%      [isValid,errmsg] = validProblem(probStruct,{'solver','options'},validValues)

%   Private to OPTIMTOOL

%   Copyright 2005-2011 The MathWorks, Inc.


isValid = true;
errmsg = '';
MissingRequiredField = '';
InvalidValueField = '';

for i = 1:length(requiredFields)
    field = requiredFields{i};
    if strcmpi(field,'solver')
        % Old style GA and patternsearch structures will not have the
        % 'solver' field; add the 'solver' field.
        myStruct = fixMyStruct(myStruct);
    end
    
    % Check the field name is valid
    if ~ismember(field,fieldnames(myStruct))
        MissingRequiredField = [MissingRequiredField ' ' field ','];
        continue;
    end

    % Now check the values of the field
    okayValues = validValues{i};
    if isempty(okayValues) % no values to compare; valid values
        continue;
    else
        validValue = false;
        for j = 1:length(okayValues)  % check against valid values
            if isequal(myStruct.(field),okayValues{j})
                validValue = true;
                break;
            end
        end
        if ~validValue
            InvalidValueField = [InvalidValueField ' ' field ','];
        end
    end
end

% Remove the last comma from the text and set isValid.
if ~isempty(MissingRequiredField)
    MissingRequiredField(end) = [];
    isValid = false;
end
if ~isempty(InvalidValueField)
    InvalidValueField(end) = [];
    isValid = false;
end

% Construct the final error message if isValid is false.
if ~isValid
  if isempty(MissingRequiredField)
    errmsg = getString(message('MATLAB:optimfun:validOptimProblemStruct:InvalidValueField', ...
                         InvalidValueField));
  elseif isempty(InvalidValueField)
    errmsg = getString(message('MATLAB:optimfun:validOptimProblemStruct:MissingRequiredField', ...
                         MissingRequiredField));
  else
    errmsg = getString(message('MATLAB:optimfun:validOptimProblemStruct:InvalidStructInput', ...
                         MissingRequiredField, ...
                         InvalidValueField));
  end
end

myStruct = fixRNGFields(myStruct);

% After we validate the structure, we also make it consistent by using the
% compatible case-sensitive field names.

% Get the correct field names
probFields = fieldnames(createProblemStruct('all'));
myStructFields = fieldnames(myStruct);
[commonFields,index] = ismember(lower(myStructFields),lower(probFields));
% Modify a field name only if it present in myStruct
for i = 1:length(myStructFields)
    % If fields are not case-sensitive then make them
   if commonFields(i) && ~strcmp(myStructFields{i},probFields{index(i)})
      myStruct.(probFields{index(i)}) = myStruct.(myStructFields{i});
      myStruct = rmfield(myStruct,myStructFields{i});
   end
end
%--------------------------------------------
function fixedStruct = fixMyStruct(myStruct)
%fixMyStruct detects if the structure is an old style GA or patternsearch
%   problem structure and adds the 'solver' field to it. 

fixedStruct = myStruct;
if isfield(fixedStruct,'solver')
    return;
end
% Try to fix problem structure for GA
if all(ismember({'fitnessfcn','options'},fieldnames(myStruct)))
    fixedStruct.solver = 'ga';
% Try to fix problem structure for patternsearch
elseif all(ismember({'objective','options'},fieldnames(myStruct))) && ...
        ismember('PollMethod',fieldnames(myStruct.options))
    fixedStruct.solver = 'patternsearch';
end

%--------------------------------------------
function fixedStruct = fixRNGFields(myStruct)
%fixRNGFields detects if the structure has old style randstate and randnstate
%   fields, and converts them to rngstate.

fixedStruct = myStruct;
if isfield(myStruct,'randstate') && isfield(myStruct,'randnstate')
    warning('MATLAB:validOptimProblemStruct:DeprecatedRNGFields',...
        getString(message('MATLAB:optimfun:validOptimProblemStruct:DeprecatedRNGFields')));
    if isempty(myStruct.randstate) && isempty(myStruct.randnstate)
        fixedStruct.rngstate = [];
    elseif isa(myStruct.randstate, 'uint32') && isequal(size(myStruct.randstate),[625, 1]) && ...
           isa(myStruct.randnstate, 'double') && isequal(size(myStruct.randnstate),[2, 1])
        % Save the default stream.  Since we'll be messing with the legacy
        % generators, we have to also save the default stream's state if it
        % is the legacy stream.
        dflt = RandStream.getGlobalStream;
        if strcmpi(dflt.Type, 'legacy'), legacyState = dflt.State; end
        % Use the randstate and randnstate fields to set the old generators directly.
        warnState = warning('off','MATLAB:RandStream:ActivatingLegacyGenerators');
        try
            rand('twister',myStruct.randstate);
            randn('state',myStruct.randnstate);
        catch
            error('MATLAB:validOptimProblemStruct:InvalidRNGFields',...
                getString(message('MATLAB:optimfun:validOptimProblemStruct:InvalidRNGFields')));
        end
        warning(warnState);
        % Create the new rngstate field based on the legacy stream's (combined) state.
        legacy = RandStream.getGlobalStream;
        fixedStruct.rngstate = struct('state',{legacy.State}, 'type',{legacy.Type});
        % Put the default stream back the way it was.
        RandStream.setGlobalStream(dflt);
        if strcmpi(dflt.Type, 'legacy'), dflt.State = legacyState; end

    else
        error('MATLAB:validOptimProblemStruct:InvalidRNGFields',...
            getString(message('MATLAB:optimfun:validOptimProblemStruct:InvalidRNGFields')));
    end
    % Remove the old fields from the structure.
    fixedStruct = rmfield(fixedStruct,{'randstate' 'randnstate'});
end
