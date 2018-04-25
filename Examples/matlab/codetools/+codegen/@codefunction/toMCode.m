function toMCode(hFunc,hText)
% Generates code based on input codefunction object

% Copyright 2006-2015 The MathWorks, Inc.

% Define the maximum line length for the buffer in order to automatically
% determine where to separate lines of code.
if usejava('jvm')
    maxTextLine = com.mathworks.widgets.text.EditorPrefsAccessor.getTextLimit;
else
    maxTextLine = 75;
end

% Generate comment before we call generate function
comment = get(hFunc,'Comment');

% Convert message objects to their string
if isa(comment, 'message')
    comment = getString(comment);
end

if ~isempty(comment) && ischar(comment)
    if strcmp(comment(1),'%')
        % Comment already has a % prefix
        if length(comment)>1
            % Only add comments with characters after the %
            hText.addln(comment);
        end
    else
        % Prefix comment with a '%' character if not already
        hText.addln(['% ',comment]);
    end
end

%---OUTPUT ARGUMENTS---%
% If function name empty, return early
hSubFunc = get(hFunc,'SubFunction');
if isempty(hSubFunc)
    fname = get(hFunc,'Name');
    if isempty(fname)
        return;
    end
    func_str = fname;
else
    func_str = get(hSubFunc,'String');
end

% Prepare the new line:
hText.addln('');

% Get output arguments
hArgoutList = get(hFunc,'Argout');
n_argout = length(hArgoutList);

% No output arguments
if n_argout<1
  str = sprintf('%s',func_str);
  hText.add(str);
  
% One output argument
elseif n_argout==1
  argout_str = get(hArgoutList,'String');
  if isempty(argout_str)
    argout_str = 'errornoargout';
  end
  str = sprintf('%s = ',argout_str);
  hText.add(str);
  % Add a new line iff we can't fit the text on the current one
  if (length(func_str) + hText.getLineLength) > maxTextLine && ...
          (hText.getLineLength ~= 0)
      hText.add('...');
      hText.addln('');
  end
  str = sprintf('%s',func_str);
  hText.add(str);

elseif n_argout>=2
    hText.add(['[' hArgoutList(1).String]);
    for i = 2:n_argout
        hText.add(',');
        argStr = hArgoutList(i).String;
        % Add a new line iff we can't fit the text on the current one
        if (length(argStr) + hText.getLineLength) > maxTextLine && ...
                (hText.getLineLength ~= 0)
            hText.add('...');
            hText.addln('');
        end
        hText.add(argStr);
    end
    hText.add('] = ');
    % Add a new line iff we can't fit the text on the current one
    if (length(func_str) + hText.getLineLength) > maxTextLine && ...
            (hText.getLineLength ~= 0)
        hText.add('...');
        hText.addln('');
    end
    hText.add(func_str);
end
  
%---INPUT ARGUMENTS---%
hArginList = get(hFunc,'Argin');

% Filter out objects that should be ignored
ind_remove = []; 
for n = 1:length(hArginList)
    if get(hArginList(n),'Ignore')
        ind_remove = [n,ind_remove];
    end
end
hArginList(ind_remove) = [];

n_argin = length(hArginList);

% No input arguments
if n_argin < 1
    hText.add(';');
else
  % Loop through and add the additional input arguments
  hText.add(['(' hArginList(1).String]);
  i = 2;
  propValueFlag = false;
  blockEntered = false;
  while i <= n_argin
      argStr = hArginList(i).String;
      % Work to keep property/value pairs together
      if strcmpi(hArginList(i).ArgumentType,'PropertyName')
          blockEntered = true;
          i = i+1;
          argStr = [argStr ',' hArginList(i).String];
      end
      hText.add(',');
      % Add a new line iff we can't fit the text on the current one or we
      % are adding property/value pairs
      if propValueFlag || ...
              (length(argStr) + hText.getLineLength) > maxTextLine && ...
              (hText.getLineLength ~= 0)
          hText.add('...');
          hText.addln('');
          if blockEntered
              propValueFlag = true;
          end
      end
      hText.add(argStr);
      i = i+1;
  end
  hText.add(');');
end

% If the function needs a pragma to remove an MLint Warning, add it here:
if hFunc.NeedPragma
    hText.add(' %#ok');
end
