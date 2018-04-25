function [attrNames, methodsData]=methodsview(qcls, option)
%METHODSVIEW  View the methods for a class.
%   METHODSVIEW(CLASSNAME) displays the methods of a class along with
%   the arguments of each method.  CLASSNAME must be a character vector or
%   string scalar.
%
%   METHODSVIEW(OBJECT) displays the methods of OBJECT's class along
%   with the arguments of each method.
%
%   METHODSVIEW is a visual representation of the information returned
%   by methods -full.
%
%   Examples
%     methodsview java.lang.Double;
%
%   See also METHODS, WHAT, WHICH, HELP.

%   Internal use only: option is optional and if present and equal to
%   'noUI' this function returns methods information without displaying 
%   the table. Information is returned in two Java String arrays. attrNames
%   is 1-dimensional String array with attribute names and methodsData is
%   2-dimensional String array where each element of the first dimension
%   represents data for one method. 
%   If the option is 'libfunctionsview', then the output will be in a
%   libfunctionsview mode, changing "class" to "library" and some
%   formatting

%   
%   Copyright 1984-2017 The MathWorks, Inc.

if (nargin < 1)
  error(message('MATLAB:methodsview:nargin'));
end

%% option specified
% defaults
colMask = [1 1 1 1 1 0];
typeString = sprintf('class');
nouiFlag = false;
if nargin > 1
    switch(lower(option))
        case 'noui'
            if nargout ~= 2
                error(message('MATLAB:methodsview:InvalidNumberOfOutputs'));
            end
            nouiFlag = true;
        case 'libfunctionsview'
            colMask = [1 1 1 1 1 0];
            typeString = sprintf('library');
        otherwise           
            error(message('MATLAB:methodsview:InvalidInputOption'));
    end
end
 
%% one input
if nargin == 1 && nargout > 0
    error(message('MATLAB:methodsview:TooManyOutputs'));
end   

notChar = ~builtin('ischar', qcls) && ~isStringScalar(qcls);

%% Make sure input is a string or object (MATLAB or opaque).
if notChar && ...
    ~isobject(qcls) &&...
    ~builtin('isa', qcls, 'opaque') ||...
    (builtin('size', qcls, 1) > 1)
  error(message('MATLAB:methodsview:InvalidInput'));
end  
    
%% If input is an object, then get the class.
if notChar
  qcls = builtin('class', qcls);
end
  
[m,d] = methods(qcls,'-full');
callers_import = builtin('_toolboxCallerImports');

if size(m,1) == 0 && ~isempty(callers_import)
  for i=1:size(callers_import, 1)
    cls = callers_import{i};
    if cls(end) == '*'
      cls = cls(1:end-1);
      cls = [cls qcls]; %#ok<AGROW>
      [m,d] = methods(cls,'-full');
      if size(m,1) > 0
        break;
      end
    else
      scls = ['.' qcls];
      if size(cls,2) > size(scls,2) && strcmp(scls, cls(end-size(scls,2)+1:end))
        [m,d] = methods(cls,'-full');
        if size(m,1) > 0
          break;
        end
      end
    end
  end
end

if ~nouiFlag && size(m,1) == 0 
  error(message('MATLAB:methodsview:UnknownClassOrMethod', typeString, qcls, typeString));
end

clear(mfilename);
dflag = 1;
ncols = 6;

if isempty(d)
  dflag = 0;
  d = cell(size(m,1), ncols);
  for i=1:size(m,1)
    t = find(m{i}=='%',1,'last');
    if ~isempty(t)
      d{i,3} = m{i}(1:t-2);
      d{i,6} = m{i}(t+17:end);
    else
      d{i,3} = m{i};
    end
  end
end

%% Reorganize the columns
r = size(m,1);
t = d(:,4);
d(:,4:ncols-1) = d(:,5:ncols);
d(:,ncols) = t;
[~,x] = sort(d(:,3));
cls = '';
clss = 0;

w = num2cell(zeros(1,ncols));

for i=1:r
  if isempty(cls) && ~isempty(d{i,6})
    t = find(d{i,6}=='.', 1, 'last');
    if ~isempty(t)
      if strcmp(d{i,3},d{i,6}(t+1:end))
	cls = d{i,6};
        clss = length(cls);
      end
    end
  end
  for j=1:ncols
    if isnumeric(d{i,j})
      d{i,j} = '';
    end
    if j==4 && strcmp(d{i,j},'()')
      d{i,j} = '( )';
    else
      if j==6
        d{i,6} = deblank(d{i,6});
        if clss > 0 && strncmp(d{i,6},cls,clss) &&...
             (length(d{i,6}) == clss ||...
               (length(d{i,6}) > clss && d{i,6}(clss+1) == '.'))
          d{i,6} = '';
        else
            if ~isempty(d{i,6})
                t = find(d{i,6}=='.', 1, 'last');
                if ~isempty(t)
                    d{i,6} = d{i,6}(1:t-1);
                end
            end
        end
      end
    end
  end
end

if ~dflag
  for i=1:r
    d{i,6} = d{i,5};
    d{i,5} = '';
  end
end

%% find the applicable columns, and get the max item length
datacol = zeros(1, ncols);
for i=1:r
  for j=1:ncols
    if ~isempty(d{i,j})
      datacol(j) = 1;
      w{j} = max(w{j},length(d{i,j}));
    end
  end
end

if exist('colMask','var')
    % do not display certain columns
    datacol = datacol .* colMask;
end

%% Calculate the headers 
hdridx = find(datacol);
ndatacol = length(hdridx);
ch = java.lang.reflect.Array.newInstance(getClass(java.lang.String),ndatacol);
%fields from METHOD
hdrs = { getString(message('MATLAB:methodsview:LabelQualifiers')),... 
    getString(message('MATLAB:methodsview:LabelReturnType')),... 
    getString(message('MATLAB:methodsview:LabelName')),...
    getString(message('MATLAB:methodsview:LabelArguments')),...
    getString(message('MATLAB:methodsview:LabelOther')),...
    getString(message('MATLAB:methodsview:LabelInheritedFrom'))}; 

% convert the headers to a String arrray
for i=1:ndatacol
    ch(i) = java.lang.String(hdrs{hdridx(i)});
end


%% Fill out the Table's Data
% We can take advantage of the default table model for a 2D string array
ds = java.lang.reflect.Array.newInstance(getClass(java.lang.String),[r ndatacol]);
for i=1:r
  for j=1:ndatacol
      ds(i,j) = java.lang.String(d{x(i),hdridx(j)});
  end
end

%% Return method info if no UI is requested
if (nouiFlag)
    attrNames=ch;
    methodsData=ds;
    return;
end


%% Create & Set-up the MethodsView Figure Window

tableM = com.mathworks.mwswing.table.UneditableTableModel(ds,ch); % Use an uneditable default table model
table = javaObjectEDT('com.mathworks.mwswing.MJTable', tableM);
%set column widths for each column 
wb = 0;
for i=1:ndatacol
    wc = 7.5*max([length(hdrs{hdridx(i)}),w{hdridx(i)}]);
    col = table.getColumn(ch(i));
    col.setPreferredWidth(wc); %Set Column Width
    wb = wb+wc;
end
scrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',table); %make it scrollable & add headers
if (com.mathworks.util.PlatformInfo.getVersion > com.mathworks.util.PlatformInfo.VERSION_15)
    table.setAutoCreateRowSorter(true); %make sortable
end
table.setShowHorizontalLines(false);
table.setShowVerticalLines(false);
table.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);

%% The METHODSVIEW window
f = javaObjectEDT('com.mathworks.mwswing.MJFrame', makeTitle(qcls)); %window title
f.add(scrollPane);
f.setDefaultCloseOperation(com.mathworks.mwswing.MJFrame.DISPOSE_ON_CLOSE); %clean-up

%make the window look nice
dz = table.getToolkit.getScreenSize;
table.setPreferredScrollableViewportSize(java.awt.Dimension(min([dz.width-100, wb+45]),...
    min([dz.height-100, 2000 ,table.getRowHeight*min(r, 26)])));
% make the whole window white (or whatever the table default is). 
scrollPane.getViewport.setBackground(table.getBackground);
f.pack;
javaMethodEDT('centerWindowOnScreen', 'com.mathworks.mwswing.WindowUtils', f);

f.setVisible(true);


function title = makeTitle(qcls) 
%MAKETITLE subfunction makes an appropriate window header if the input is a
%function or a library
if strncmp(qcls,'lib.',4)
    %is a library
    title = getString(message('MATLAB:methodsview:TitleFunctionsInLibrary', strrep(qcls,'lib.','')));
else
    %is a class
    title = getString(message('MATLAB:methodsview:TitleMethodsForClass', qcls));
end
