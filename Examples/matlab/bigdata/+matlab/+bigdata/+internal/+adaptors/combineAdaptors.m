function out = combineAdaptors(dim, inCell)
%combineAdaptors Combination of adaptors for horizontal or vertical concatenation

% Copyright 2016-2017 The MathWorks, Inc.

adaptorClasses = cellfun(@class, inCell, 'UniformOutput', false);

underlyingClasses = cellfun(@(x) x.Class, inCell, 'UniformOutput', false);
isKnownUniqueUnderlyingClass = numel(unique(underlyingClasses)) == 1 && ...
    ~isempty(underlyingClasses{1});

isTableAdaptor     = strcmp(adaptorClasses, 'matlab.bigdata.internal.adaptors.TableAdaptor');
isTimetableAdaptor = strcmp(adaptorClasses, 'matlab.bigdata.internal.adaptors.TimetableAdaptor');

% Allowed combinations:
% - all 'generic' adaptors, return a plain generic adaptor
% - all DatetimeFamilyAdaptor
%   - if classes all match
%   - or duration + calendarDuration -> calendarDuration
% - datetime and char/string -> datetime
% - duration|calendarDuration and numeric -> duration|calendarDuration
% - all TableAdaptor - concatenate VariableNames and Adaptors providing VariableNames unique
% - categorical can combine with string, char, cell(str), result is always categorical
% - string combined with any generic type is string

if all(strcmp(adaptorClasses, 'matlab.bigdata.internal.adaptors.GenericAdaptor'))
    out = matlab.bigdata.internal.adaptors.GenericAdaptor();
    if isKnownUniqueUnderlyingClass
        out = matlab.bigdata.internal.adaptors.getAdaptorForType(underlyingClasses{1});
    end
    
elseif any(strcmp(adaptorClasses, 'matlab.bigdata.internal.adaptors.DatetimeFamilyAdaptor'))
    % Here we still consider unknown (empty) classes
    uc = unique(underlyingClasses);
    if numel(uc) == 1
        out = matlab.bigdata.internal.adaptors.DatetimeFamilyAdaptor(underlyingClasses{1});
    else
        % We need to work out from the known-good combinations of classes. Disregard
        % unknown classes for now, treat them as if they'll work, and hope for
        % the best.
        uc(uc == "") = [];
        if isempty(setdiff(uc, { 'datetime', 'char', 'string', 'cell' }))
            outClass = 'datetime';
        elseif isempty(setdiff(uc, { 'duration', 'double', 'logical' }))
            outClass = 'duration';
        elseif isempty(setdiff(uc, { 'duration', 'calendarDuration', 'double', 'logical' }))
            outClass = 'calendarDuration';
        else
            error(message('MATLAB:bigdata:array:InvalidConcatenation', strjoin(uc, ' ')));
        end
        out = matlab.bigdata.internal.adaptors.DatetimeFamilyAdaptor(outClass);
    end
    
elseif all(isTableAdaptor)
    out = cat(dim, inCell{:});
    
elseif isTimetableAdaptor(1)
    if ~all(isTimetableAdaptor | isTableAdaptor)
        if dim == 1
            error(message('MATLAB:table:vertcat:TableAndTimetable'));
        else
            error(message('MATLAB:table:horzcat:TableAndTimetable'));
        end
    end
    out = cat(dim, inCell{:});
    
elseif any(isTableAdaptor) || any(isTimetableAdaptor)
    % Cannot concatenate - find the first tabular type in the argument list and use
    % that to throw an error.
    firstTabularArg   = find(isTableAdaptor | isTimetableAdaptor, 1, 'first');
    firstTabularClass = underlyingClasses{firstTabularArg};
    error(message('MATLAB:bigdata:table:InvalidTabularConcatenation', firstTabularClass));
    
elseif any(strcmp(adaptorClasses, 'matlab.bigdata.internal.adaptors.CategoricalAdaptor'))
    % categorical can combine with: string, char, cell(str) - result is always categorical.
    uc = unique(underlyingClasses);
    % Remove unknown classes (which might error later)
    uc(uc == "") = [];
    % Remove known-good classes, leaving only forbidden classes
    forbiddenClasses = setdiff(uc, { 'categorical', 'string', 'char', 'cell' });
    if isempty(forbiddenClasses)
        out = matlab.bigdata.internal.adaptors.CategoricalAdaptor();
    else
        error(message('MATLAB:bigdata:array:InvalidConcatenation', strjoin(uc, ' ')));
    end
    
elseif any(strcmp(adaptorClasses, 'matlab.bigdata.internal.adaptors.StringAdaptor'))
    % String can combine with any generic type. Result is always string.
    out = matlab.bigdata.internal.adaptors.StringAdaptor();
    
else
    % Throw a vague error about not being able to concatenate. Should never get
    % here, as all cases should be handled above.
    error(message('MATLAB:bigdata:array:InvalidConcatenationUnknownTypes'));
    
end

% Attempt to propagate known size information by concatenating the sizes, but
% only if all small dimensions are known, and all classes are known and match
% (see g1393370 for what can happen when classes don't match - sizes can
% change!)
allNdims = cellfun(@(a) a.NDims, inCell);

if isscalar(inCell)
    out = copySizeInformation(out, inCell{1});
elseif ~any(isnan(allNdims)) && isKnownUniqueUnderlyingClass
    % Function to get the size from the adaptor in a vector of length
    % effectiveNdims.
    szAsCellFcn = @(a) { a.Size };
    
    % Get a cell array of all sizes
    allSizesCell = cellfun(szAsCellFcn, reshape(inCell, [], 1));
    
    % If there are any arrays that *might* be "[]", we cannot use our CAT size
    % computation, since the computation takes a completely different path for
    % those arrays.
    if ~any(cellfun(@iArrayMightBeSquareEmpty, allSizesCell))
        newSize = matlab.bigdata.internal.util.computeCatSize(dim, allSizesCell);
        out = setKnownSize(out, newSize);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return TRUE if the size vector *might* correspond to a [] empty array, but it
% is not *guaranteed* to correspond to []. I.e. one of: [NaN, 0], [0, NaN],
% [NaN, NaN].
function tf = iArrayMightBeSquareEmpty(szVec)
tf = numel(szVec) == 2 && any(isnan(szVec)) && ...
     all(arrayfun(@(d) d == 0 || isnan(d), szVec));
end
