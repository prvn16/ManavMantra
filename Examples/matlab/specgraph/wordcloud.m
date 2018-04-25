function h = wordcloud(varargin)
%WORDCLOUD Word cloud chart
%   WC = WORDCLOUD(TBL,WORDVAR,SIZEVAR) creates a word cloud plot from table
%   TBL and returns the WordCloudChart object WC. WORDVAR and SIZEVAR are
%   the table variables for the words to display and the sizes of those words,
%   respectively.
%
%   WC = WORDCLOUD(C) creates a word cloud plot from elements of
%   categorical array C and returns the WordCloudChart object WC. The
%   frequency of each categorical item is computed using HISTCOUNTS. Use WC
%   to modify the word cloud after it is created.
%
%   WC = WORDCLOUD(WORDS, SIZEDATA) creates a word cloud plot with words
%   from WORDS and sizes SIZEDATA. WORDS must be a string vector,
%   categorical vector, or a cell vector of character vectors.
%   The length of WORDS must match the length of SIZEDATA.
%
%   WC = WORDCLOUD(TEXT) tokenizes and preprocesses the text in TEXT and
%   creates a word cloud using the word frequency counts (requires Text
%   Analytics Toolbox(TM)). TEXT can be a string, character vector, or cell
%   array of character vectors. If the toolbox is installed, then the
%   result is the same as
%       T = wordCloudCounts(TEXT);
%       wordcloud(T.Word, T.Count);
%
%   WC = WORDCLOUD(__, NAME, VALUE) specifies additional WordCloudChart
%   property name and value pairs.
%   WC = WORDCLOUD(PARENT,__) creates the word cloud in the figure, panel,
%   or tab specified by PARENT.
%
%   See also: histcounts, wordCloudCounts

% Copyright 2016-2017 The MathWorks, Inc.

args = varargin;
parent = gobjects(0);

% Check if the first input argument is a graphics object to use as parent.
if ~isempty(args) && isa(args{1},'matlab.graphics.Graphics')
  % wordcloud(parent,___)
  parent = args{1};
  args = args(2:end);
end

if isempty(args)
  error(message('MATLAB:narginchk:notEnoughInputs'));
end

% for wordcloud(fig,obj,...), forward to standard overloading,
% as if called by wordcloud(obj,...,'Parent',fig)
if ~isempty(parent) && ismethod(class(args{1}),'wordcloud')
  h = wordcloud(args{:},'Parent',parent);
  return;
end

if isa(args{1}, 'tabular')
  % Table syntax
  %   wordcloud(tbl,xvar,yvar,Name,Value)
  [extraArgs, args] = parseTableInputs(args);
else
  [extraArgs, args] = parseMatrixInputs(args);
end

args = matlab.graphics.internal.convertStringToCharArgs(args);

% Look for a Parent name-value pairs.
inds = find(strcmpi('Parent',args(1:2:end)));
if ~isempty(inds) && (inds(end)*2) <= numel(args)
  inds = inds*2-1;
  parent = args{inds(end)+1};
  args([inds inds+1]) = [];
end

% Look for a Position, InnerPosition, OuterPosition, name-value pairs.
posArgsPresent = ~isempty(find(strcmpi('OuterPosition',args(1:2:end)),1)) || ...
    ~isempty(find(strcmpi('InnerPosition',args(1:2:end)),1)) || ...
    ~isempty(find(strcmpi('Position',args(1:2:end)),1));

% Build the full list of name-value pairs.
args = [extraArgs args];

% If position not specified, use replaceplot behavior
if ~posArgsPresent
  if ~isempty(parent)
    validateParent(parent);
  end
  % Construct the WordcloudChart.
  constructor = @(varargin) matlab.graphics.chart.WordCloudChart(varargin{:},args{:});
  try
    h = matlab.graphics.internal.prepareCoordinateSystem('matlab.graphics.chart.WordCloudChart',parent, constructor);
  catch e
    throw(e)
  end
else % Caller specified a position
  % Check parent argument if specified
  if isempty(parent)
    % If position specified, but not parent, assume current figure
    parent = gcf;
  else
    validateParent(parent);
  end
  
  % Construct wordcloud without replacing gca
  try
    h = matlab.graphics.chart.WordCloudChart('Parent', parent, args{:});
  catch e
    throw(e)
  end
end

% Make the new chart the CurrentAxes
fig = ancestor(h,'figure');
if isscalar(fig)
  fig.CurrentAxes = h;
end

end


function validateParent(parent)

if ~isa(parent, 'matlab.graphics.Graphics') || ~isscalar(parent) || ~isvalid(parent)
  % Parent must be a valid scalar graphics object.
  error(message('MATLAB:graphics:wordcloud:InvalidParent'));
elseif isa(parent,'matlab.graphics.axis.AbstractAxes')
  % WordcloudChart cannot be a child of Axes.
  error(message('MATLAB:hg:InvalidParent',...
    'WordCloudChart', fliplr(strtok(fliplr(class(parent)), '.'))));
end

end

function [extraArgs, args] = parseMatrixInputs(args)
n = 1;
w = args{n};
validW = isstring(w) || iscategorical(w) || iscellstr(w) || ischar(w);
if ~validW
  error(message('MATLAB:graphics:wordcloud:WordInput'));
end
if length(args) > 1 && isnumeric(args{2})
  n = n+1;
  s = full(double(args{n}));
  w = string(w);
elseif iscategorical(w) || hasTextAnalyticsToolbox
  [w,s] = computeWordsAndCounts(w);
else
  error(message('MATLAB:graphics:wordcloud:SingleWordInput'));
end
if numel(string(w)) ~= numel(s)
  error(message('MATLAB:graphics:wordcloud:DataSizeMismatch'));
end
extraArgs = {'WordData',w,'SizeData',s};
args = args(n+1:end);
end

function ok = hasTextAnalyticsToolbox
ok = false;
if ~isempty(ver('textanalytics')) % check if toolbox installed
  % use the two-output form to avoid displaying any error to the command line
  [status, ~] = builtin('license', 'checkout', 'Text_Analytics_Toolbox');
  ok = status == 1;
end
end

function [words,counts] = computeWordsAndCounts(txt)
if iscategorical(txt)
  [counts,cats] = histcounts(txt);
  words = string(cats);
  [counts,inds] = sort(counts,'descend');
  words = words(inds);
else
  txt = string(txt);
  tbl = wordCloudCounts(txt);
  words = tbl.Word;
  counts = tbl.Count;
end
end

function [extraArgs, args] = parseTableInputs(args)
% Parse the table syntax:
%   wordcloud(tbl,wordvar,sizevar,..)

import matlab.graphics.chart.internal.validateTableSubscript

% Three input arguments are required for the table syntax.
if numel(args)<3
  throwAsCaller(MException(message('MATLAB:graphics:wordcloud:InvalidTableArguments')));
end

% Collect the first three input arguments.
tbl = args{1};
wordvar = args{2};
sizevar = args{3};
args = args(4:end);

% Validate the wordvar table subscript.
[varname, wordvar, err] = validateTableSubscript(tbl, wordvar, 'WordVariable');
if ~isempty(err)
  throwAsCaller(err);
elseif isempty(varname)
  throwAsCaller(MException(message('MATLAB:Chart:NonScalarTableSubscript', 'WordVariable')));
end

% Validate the sizevar table subscript.
[varname, sizevar, err] = validateTableSubscript(tbl, sizevar, 'SizeVariable');
if ~isempty(err)
  throwAsCaller(err);
elseif isempty(varname)
  throwAsCaller(MException(message('MATLAB:Chart:NonScalarTableSubscript', 'SizeVariable')));
end

% Build the name-value pairs for the table syntax.
extraArgs = {'SourceTable', tbl, 'WordVariable', wordvar, 'SizeVariable', sizevar};
end
