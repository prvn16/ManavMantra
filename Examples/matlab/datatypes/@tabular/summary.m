function s = summary(t)
%SUMMARY Print summary of a table or a timetable.
%   SUMMARY(T) prints a summary of T and the variables that it contains. If
%   T is a table, then SUMMARY displays the description from
%   T.Properties.Description followed by a summary of the table variables.
%   If T is a timetable, then SUMMARY additionally displays a summary of
%   the row times.
%
%   S = SUMMARY(T) returns a summary of T as a structure. Each field of S
%   contains a summary for the corresponding variable in T. If T is a
%   timetable, S contains an additional field for a summary of the row
%   times.

% Copyright 2012-2017 The MathWorks, Inc.

descr = t.getProperty('Description',true);
vardescr = t.getProperty('VariableDescriptions',true);
units = t.getProperty('VariableUnits',true);
varnames = t.getProperty('VariableNames',true);
continuity = t.getProperty('VariableContinuity',false);
outputStruct = struct;

% Handle row times if it exists
rowLabelsStruct = t.summarizeRowLabels();
if numel(fieldnames(rowLabelsStruct))
    rowLabelsName = t.metaDim.labels{1};
    outputStruct.(rowLabelsName) = rowLabelsStruct;
end

% Loop through the variables to calculate individual variable summary
for j = 1:t.varDim.length
    var_j = t.data{j};

    % Add size, type to struct for variable summary
    varStruct = struct; % Create new every loop
	varStruct.Size = size(var_j);
    varStruct.Type = class(var_j);
    
    % Add units and var descr if they exist
    varStruct.Description = vardescr{j};
    varStruct.Units = units{j};
    if ~isempty(continuity)
        varStruct.Continuity = continuity(j);
    else
        varStruct.Continuity = [];
    end

    if ismatrix(var_j) % skip N-D
        if (isnumeric(var_j) && (~isinteger(var_j) || isreal(var_j))) || ... % median doesn't work on complex integers
           isdatetime(var_j) || isduration(var_j) 
            varStruct = datatypeSummary(var_j, varStruct);
        elseif islogical(var_j)
            varStruct = logicalSummary(var_j, varStruct);
        elseif isa(var_j,'categorical')
            varStruct = categoricalSummary(var_j, varStruct);
        end
    end
    
    % Save resulting variable summary struct into output struct
    outputStruct.(varnames{j}) = varStruct;
end

if nargout == 0 
    isLoose = strcmp(matlab.internal.display.formatSpacing,'loose');
    if (isLoose), fprintf('\n'); end
    
    if ~isempty(descr)
        fprintf('Description:  %s\n',descr);
        if (isLoose), fprintf('\n'); end
    end
    
    %Print all the variables
    printSummary(outputStruct,t);
else
    s = outputStruct;
end

%-----------------------------------------------------------------------------
function printSummary(outputStruct,t)
   
% clean up this code. isLoose =
isLoose = strcmp(matlab.internal.display.formatSpacing,'loose');

if matlab.internal.display.isHot
    varnameFmt = '<strong>%s</strong>';
else
    varnameFmt = '%s';
end

dimName = t.getProperty('DimensionNames');
varNames = t.getProperty('VariableNames');

% Print row times information if needed
if isfield(outputStruct, dimName{1})
    rowLabelsStruct = outputStruct.(dimName{1});
    t.printRowLabelsSummary(rowLabelsStruct);
end

% Variables
fprintf([dimName{2} ':\n']);
if (isLoose), fprintf('\n'); end

% Print information about each variable 
for i = 1:length(varNames)
    var = t.data{i};
    varStruct = outputStruct.(varNames{i});        
    
    sz = varStruct.Size;
    szStr = [sprintf('%d',sz(1)) sprintf([matlab.internal.display.getDimensionSpecifier,'%d'],sz(2:end))];
    
    % Display size, type, units, description for the variable, then remove the
    % fields from the struct since they will not be displayed later.
    if iscellstr(var)
        fprintf(['    ' varnameFmt ': %s cell array of character vectors\n'],varNames{i},szStr);
    elseif iscategorical(var)
        if isordinal(var)
            fprintf(['    ' varnameFmt ': %s ordinal categorical\n'],varNames{i},szStr);
        else
            fprintf(['    ' varnameFmt ': %s categorical\n'],varNames{i},szStr);
        end
    else
        fprintf(['    ' varnameFmt ': %s %s\n'],varNames{i},szStr,varStruct.Type);
    end

	if (isLoose), fprintf('\n'); end
    
    if ~isempty(varStruct.Units)
        fprintf('        Units:  %s\n',varStruct.Units);
    end
    if ~isempty(varStruct.Description)
        fprintf('        Description:  %s\n',varStruct.Description);
    end
    if isfield(varStruct,'Continuity') && ~isempty(varStruct.Continuity)
        fprintf('        Continuity:  %s\n',varStruct.Continuity);
    end
    % Nothing else to print for N-D
    if ~ismatrix(var)
        continue; 
    end
    
    % Parse struct depending on type
    labels = {};
    if isdatetime(var) || isduration(var) || (isnumeric(var) && (~isinteger(var) || ...
       isreal(var)))
        if ~isempty(varStruct.Min) % Nothing to print for empty
            labels = {'Min';'Median';'Max'};
            values = [varStruct.Min; varStruct.Median; varStruct.Max];
            if any(varStruct.NumMissing) 
                if isnumeric(values)
                     values = sprintfc('%.5g',values);
                end
                values = [cellstr(values); sprintfc('%g',varStruct.NumMissing)]; %#ok<*AGROW>
                labels = [labels; 'NumMissing']; 
            end
        end
    elseif iscategorical(var)
        labels = varStruct.Categories;
        values = varStruct.Counts;
        numundef = sum(isundefined(var),1);      
        if any(numundef)
            labels = [labels; 'NumMissing']; 
            values = [values; numundef];  
        end
    elseif islogical(var)
        if any([varStruct.True varStruct.False])
            labels = {'True'; 'False'};
            values = [varStruct.True; varStruct.False];
        end
    end
    
    if ~isempty(labels)
        % Create numbered names based on number of columns in the variable
        vn = matlab.internal.datatypes.numberedNames([varNames{i} '_'],1:sz(2)); 

        vt = array2table(values,'RowNames',labels,'VariableNames',vn);
        c = evalc('disp(vt,false,12)');
        
        c = strrep(c, '''', ' '); % Remove the single quotes from cell display

        if iscolumn(values)
            lf = newline;
            firstTwoLineFeeds = find(c==lf,2,'first');
            c(1:firstTwoLineFeeds(end)) = [];
        end

        fprintf('        Values:\n');
        fprintf('%s',c);
    end
end
    
%-----------------------------------------------------------------------------
function varStruct = categoricalSummary(x,varStruct)  
numundef = sum(isundefined(x),1);
counts = countcats(x,1);
cats = categories(x);

varStruct.Categories = cats;
varStruct.Counts = counts;
varStruct.NumMissing = numundef;

%-----------------------------------------------------------------------------
% Single summary function for multiple datatypes - numeric, datetime and
% duration. Need to pass in the missing indicator.
function varStruct = datatypeSummary(x, varStruct)
labs = getSummaryLabels; % min, median, max labels
nummissing = sum(ismissing(x),1);

% We always want to work by column, and also ignore NaN/NaT.
varStruct.(labs{1}) = min(x,[],1,'omitnan'); 
varStruct.(labs{2}) = median(x,1,'omitnan'); 
varStruct.(labs{3}) = max(x,[],1,'omitnan');

% Missing values count
varStruct.(labs{4}) = nummissing;

%-----------------------------------------------------------------------------
function varStruct = logicalSummary(x,varStruct)
varStruct.True = sum(x,1);
varStruct.False = sum(1-x,1);

%-----------------------------------------------------------------------------
function labs = getSummaryLabels
labs = { 'Min'; ...
         'Median'; ...
         'Max'; ...
         'NumMissing'};
     
%-----------------------------------------------------------------------------


