function handles = makemenu(fig, labels, calls, tags)
% This function is undocumented and will change in a future release

%MAKEMENU Create menu structure.
%  MAKEMENU(FIG, LABELS, CALLS) creates a menu structure in
%  figure FIG according to the order in the string matrix
%  LABELS.  Cascaded menus are indicated by initial '>'
%  characters in the LABELS matrix.  CALLS is a string
%  matrix containing callbacks.  It should have the same
%  number of rows as LABELS.  A row of LABELS that contains
%  any number of '-' characters after the '>' indicators
%  causes a separator line to be placed in the appropriate
%  place.
%
%  MAKEMENU(FIG, LABELS, CALLS, TAGS) uses the TAGS string
%  matrix to assign the corresponding 'Tag' property of each
%  uimenu item.
%
%  LABELS, CALLS, and TAGS must have the same number of
%  rows.
%
%  H = MAKEMENU( ... ) returns a vector containing the
%  handles of all uimenu objects created.
%
%  Example:
%  labels = str2mat( ...
%    '&File', ...
%    '>&New^n', ...
%    '>&Open', ...
%    '>>Open &document^d', ...
%    '>>Open &graph^g', ...
%    '>-------', ...
%    '>&Save^s', ...
%    '&Edit', ...
%    '&View', ...
%    '>&Axis^a', ...
%    '>&Selection region^r' ...
%    );
%       calls = str2mat( ...
%    '', ...
%    'disp(''New'')', ...
%    '', ...
%    'disp(''Open doc'')', ...
%    'disp(''Open graph'')', ...
%    '', ...
%    'disp(''Save'')', ...
%    '', ...
%    '', ...
%    'disp(''View axis'')', ...
%    'disp(''View selection region'')' ...
%    );
%  handles = makemenu(gcf, labels, calls);
%
%  See also MENU, UIMENU.

%  Steven L. Eddins, 27 May 1994
%  Copyright 1984-2008 The MathWorks, Inc.

narginchk(3,4)

num_objects = size(labels,1);
if (num_objects ~= size(calls,1))
  error(message('MATLAB:makemenu:LabelsCallsSameRows'));
end
if (nargin == 4)
  if (num_objects ~= size(tags,1))
    error(message('MATLAB:makemenu:LabelsTagsSameRows'));
  end
end

remember_handles = fig;
handles = [];
current_level = 0;

tagStr = char([]);
separatorFlag=0;
for k = 1:num_objects

  labelStr = deblank(labels(k,:));
  if (nargin == 4)
    tagStr = deblank(tags(k,:));
  end

  % Determine which object to attach to by checking the level.
  loc = find(labelStr ~= '>');
  if (isempty(loc))
    error(message('MATLAB:makemenu:InvalidLabel'));
  end
  new_level = loc(1) - 1;
  labelStr = labelStr(loc(1):length(labelStr));
  if (new_level > current_level)
    remember_handles = [remember_handles handles(length(handles))]; %#ok
  elseif (new_level < current_level)
    N = length(remember_handles);
    remember_handles(N-(current_level-new_level)+1:N) = [];
  end
  current_level = new_level;

  if (labelStr(1) == '-')
    separatorFlag = 1;
  else
    if (separatorFlag)
      separator = 'on';
      separatorFlag = 0;
    else
      separator = 'off';
    end
  
    % Preprocess the label.
    [labelStr, acc] = menulabel(labelStr);
    if (isempty(labelStr))
      error(message('MATLAB:makemenu:EmptyField'));
    end
    
    % Note:  much of the overhead in this function is spent in calls
    % to deblank.  So we're going to trade off speed for figure memory
    % overhead and not deblank the callback string.
    h = uimenu(remember_handles(length(remember_handles)), ...
        'Label', labelStr, 'Accelerator', acc, 'Callback', calls(k,:), ...
        'Separator',separator,...
        'Tag', tagStr);
    
    handles = [handles ; h];
  end

end


