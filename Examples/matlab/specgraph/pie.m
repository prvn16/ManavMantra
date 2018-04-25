function hh = pie(varargin)
%PIE    Pie chart.
%   PIE(X) draws a pie chart using the data in X. Each slice of the pie
%   chart represents an element in X.
%
%      If sum(X)<= 1, then the values in X directly specify the areas of the
%      pie slices. pie draws only a partial pie if sum(X) < 1.
%
%      If sum(X) > 1, then pie normalizes the values by X/sum(X) to
%      determine the area of each slice of the pie.
%      
%      If X is of data type categorical, the slices correspond to categories.
%      Area of each slice is the number of elements in the category divided
%      by the number of elements in X. <undefined> elements are ignored.
%
%   PIE(X,EXPLODE) offsets slices from the pie. explode is a vector or
%   matrix of zeros and nonzeros that correspond to X. The pie function
%   offsets slices for the nonzero elements only in explode. If X is of
%   data type categorical, then explode can be a vector of zeros and
%   nonzeros corresponding to categories, or a cell array of the names of
%   categories to offset.
%
%   PIE(X,LABELS) specifies text labels for the slices. X must be numeric.
%   The number of labels must equal the number of elements in X.
%
%   PIE(X,EXPLODE,LABELS) offsets slices and specifies text labels for
%   them. X can be numeric or categorical. For numeric X, the number of
%   labels must equal the number of elements in X. For categorical X, the
%   number of labels must equal the number of categories.
%
%   PIE(AX,...) plots into the axes specified by ax instead of into the
%   current axes (gca). The option ax can precede any of the input argument
%   combinations in the previous syntaxes.
%
%   H = PIE(...) returns a vector of patch and text graphics objects. The
%   input can be any of the input argument combinations in the previous
%   syntaxes.
%
%   Example
%   --------
%   Plot a pie chart from a numeric array with labels
%      pie([2 4 3 5],{'North','South','East','West'})
%
%   Plot a pie chart from a numeric array with label, and offset slices
%   'North' and 'South' using logical vector
%      pie([2 4 3 5],[true true false false],{'North','South','East','West'})
%
%   Plot a pie chart from a categorical array
%      X = categorical({'North','South','North','East','South','West'});
%      pie(X);
%
%   Plot a pie chart from a categorical array, and offset categories 'North' 
%   and 'South' using category names
%      X = categorical({'North','South','North','East','South','West'});
%      pie(X, {'North','South'});
%
%   See also PIE3.

%   Clay M. Thompson 3-3-94
%   Copyright 1984-2017 The MathWorks, Inc.

% Parse possible Axes input
[cax, args, nargs] = axescheck(varargin{:});
if nargs < 1
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nargs > 3
    error(message('MATLAB:narginchk:tooManyInputs'));
end

% Parse PIE inputs
[sliceCounts, explode, labels, displayNames] = parseArgs(args, nargs);

% Construct PIE and set display name for default legend labels
h = makePie(cax, sliceCounts, explode, labels);
if ~isequal(displayNames, {})
    set(h(isgraphics(h,'patch')), {'DisplayName'}, displayNames);
end

% Register handles with MATLAB code generator
if ~isempty(h)
    if ~isdeployed
        makemcode('RegisterHandle',h,'IgnoreHandle',h(1),'FunctionName','pie'); 
    end 
end

% Return handle if requested
if nargout>0, hh = h; end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%% HELPER PARSEARGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sliceCounts, explode, labels, displayNames] = parseArgs(args, numArgs)
    inData = args{1}(:); % Make sure it is a vector
    isCategoricalData = isa(inData, 'categorical');
    
    explode = {};
    supplied.explode = false;
    
    labels  = {};    
    supplied.labels  = false;
    
    switch numArgs
        case 1
            % Nothing to do
        case 2
            if isCategoricalData
                explode = args{2};
                supplied.explode = true;
            else
                if iscell(args{2}) || isstring(args{2})
                    labels = args{2};
                    supplied.labels = true;
                else
                    explode = args{2};
                    supplied.explode = true;
                end
            end
        case 3
            explode = args{2};
            supplied.explode = true;
            
            labels  = args{3};
            supplied.labels  = true;
    end
    
    labels = matlab.graphics.internal.convertStringToCharArgs(labels);
    explode = matlab.graphics.internal.convertStringToCharArgs(explode); 
    
    try
        [sliceCounts, ignoreIdx] = validateData(inData);
        explode = validateExplode(explode, supplied.explode, ignoreIdx, sliceCounts, inData);
        labels  = validateLabels(labels, supplied.labels, ignoreIdx, sliceCounts, inData);
        
        if isCategoricalData
            displayNames = categories(inData); 
            displayNames(ignoreIdx) = [];
        else
            displayNames = {};
        end
    catch ME
        throwAsCaller(ME);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% HELPER VALIDATEDATA %%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data, nonPositiveIdx] = validateData(data)
isDataCategorical = isa(data,'categorical');
if isDataCategorical
    if isempty(data) || all(isundefined(data))
        throwAsCaller(MException(message('MATLAB:pie:InvalidData')));
    else
        data = countcats(data);
    end
end

if ~isnumeric(data)
    throwAsCaller(MException(message('MATLAB:pie:NonNumericData')));
elseif ~all(isfinite(data))
    throwAsCaller(MException(message('MATLAB:pie:NonFiniteData')));
end
nonPositiveIdx = (data <= 0);
if all(nonPositiveIdx)
    throwAsCaller(MException(message('MATLAB:pie:NoPositiveData')));
end
if any(nonPositiveIdx)
    data(nonPositiveIdx) = [];
    
    if ~isDataCategorical
        warnState = warning('off','backtrace');
        restoreWarnState = onCleanup(@()warning(warnState));
        warning(message('MATLAB:pie:NonPositiveData'));
    end
end
dataSum = sum(data);
if dataSum > 1+sqrt(eps), data = data/dataSum; end
end

%%%%%%%%%%%%%%%%%%%%%%%%% HELPER VALIDATEEXPLODE %%%%%%%%%%%%%%%%%%%%%%%%%%
function explode = validateExplode(explode, supplied, ignoreIdx, sliceCounts, inData)

if supplied
    % If explode is specified as a list of category names (supported only by
    % categorical pie), convert into a logical vector.
    if iscategorical(inData) && matlab.internal.datatypes.isCharStrings(explode)
        if ~all(iscategory(inData,explode)) 
            throwAsCaller(MException(message('MATLAB:pie:InvalidExplodeName')));
        end
        explode = ismember(categories(inData), explode);
    end

    % Categorical pie has a special error message for invalid data type.
    if iscategorical(inData) && ~(islogical(explode) || (isnumeric(explode) && all(isfinite(explode))))
        throwAsCaller(MException(message('MATLAB:pie:InvalidExplodeType')));
    end
    
    % Make sure it is a logical vector.
    explode = logical(explode(:));
    
    % Make sure it is the right size.
    if isempty(explode)
        explode = false(size(ignoreIdx));
    elseif numel(ignoreIdx) ~= numel(explode)
        if iscategorical(inData)
            throwAsCaller(MException(message('MATLAB:pie:InvalidExplodeLogical')));
        else
            throwAsCaller(MException(message('MATLAB:pie:ExplodeLengthMismatch')));
        end
    end
    
    % Remove unoccupied slices.
    explode(ignoreIdx) = [];
else
    % No explode input provided.
    explode = false(numel(sliceCounts),1);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%% HELPER VALIDATELABEL %%%%%%%%%%%%%%%%%%%%%%%%%%%
function labels = validateLabels(labels, supplied, ignoreIdx, sliceCounts, inData)
if supplied
    if iscategorical(inData)
        if ~( iscellstr(labels) && all(cellfun(@(x)size(x,1),labels)==1) ) || ...
                numel(ignoreIdx) ~= numel(labels) %#ok<ISCLSTR>
            throwAsCaller(MException(message('MATLAB:pie:InvalidLabel')));
        end
    else
        if ~iscellstr(labels) %#ok<ISCLSTR>
            throwAsCaller(MException(message('MATLAB:pie:InvalidLabels')));
        elseif numel(ignoreIdx) ~= numel(labels)
            throwAsCaller(MException(message('MATLAB:pie:StringLengthMismatch')));
        end
    end
    labels(ignoreIdx) = [];
else
    if iscategorical(inData)
        catNames = categories(inData); catNames(ignoreIdx) = [];
        percentageStrings = num2str(round(100*nonzeros(sliceCounts)./sum(sliceCounts)), '(%d%%)');
        labels = strcat(catNames, {' '}, percentageStrings);
    else
        for i=1:length(sliceCounts)
            if sliceCounts(i)<.01
                labels{i} = '< 1%';
            else
                labels{i} = sprintf('%d%%',round(sliceCounts(i)*100));
            end
        end
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HELPER MAKEPIE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = makePie(cax, x, explode, labels)
% Make patches
cax = newplot(cax);
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

theta0 = pi/2;
maxpts = 100;

h = [];
for i=1:length(x)
    n = max(1,ceil(maxpts*x(i)));
    r = [0;ones(n+1,1);0];
    theta = theta0 + [0;x(i)*(0:n)'/n;0]*2*pi;
    [xtext,ytext] = pol2cart(theta0 + x(i)*pi,1.2);
    [xx,yy] = pol2cart(theta,r);
    if explode(i)
        [xexplode,yexplode] = pol2cart(theta0 + x(i)*pi,.1);
        xtext = xtext + xexplode;
        ytext = ytext + yexplode;
        xx = xx + xexplode;
        yy = yy + yexplode;
    end
    theta0 = max(theta);
    h = [h,...
        patch('XData',xx,'YData',yy,'CData',i*ones(size(xx)), ...
            'FaceColor','Flat','parent',cax), ...
        text(xtext,ytext,labels{i},...
            'HorizontalAlignment','center','parent',cax,'Layer','front')]; %#ok<AGROW>
end

if ~hold_state
    view(cax,2); set(cax,'NextPlot',next);
    axis(cax,'equal','off',[-1.2 1.2 -1.2 1.2])
end
end
