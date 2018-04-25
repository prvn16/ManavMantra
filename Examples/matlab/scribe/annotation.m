function hOut=annotation(varargin)
%ANNOTATION creates an annotation object
%   ANNOTATION(ANNOTATIONTYPE) creates a default annotation of type
%   ANNOTATIONTYPE in the current figure.  ANNOTATIONTYPE may be one of the
%   following:
%       'rectangle'
%       'ellipse'
%       'textbox'
%       'line'
%       'arrow'
%       'doublearrow' = two headed arrow
%       'textarrow' = arrow with text at tail end
%
%   ANNOTATION('rectangle',POSITION) creates a rectangle annotation at the
%   position specified in normalized figure units by the vector POSITION
%   ANNOTATION('ellipse',POSITION) creates an ellise annotation at the
%   position specified in normalized figure units by the vector POSITION
%   ANNOTATION('textbox',POSITION) creates a textbox annotation at the
%   position specified in normalized figure units by the vector POSITION
%   ANNOTATION('line',X,Y) creates a line annotation with endpoints
%   specified in normalized figure coordinates by the vectors X and Y
%   ANNOTATION('arrow',X,Y) creates an arrow annotation with endpoints
%   specified in normalized figure coordinates by the vectors X and Y. X(1)
%   and Y(1) specify the position of the tail end of the arrow and X(2) and
%   Y(2) specify the position at the tip of the arrow head.
%   ANNOTATION('doublearrow',X,Y) creates a doublearrow annotation with
%   endpoints specified in normalized figure coordinates by the vectors X
%   and Y
%   ANNOTATION('textarrow',X,Y) creates a textarrow annotation with
%   endpoints specified in normalized figure coordinates by the vectors X
%   and Y. X(1) and Y(1) specify the position of the tail end of the arrow
%   and X(2) and Y(2) specify the position at the tip of the arrow head.
%
%   ANNOTATION(HANDLE,...) creates the annotation in the figure, uipanel,
%   or uitab specified by HANDLE
%
%   H=ANNOTATION(...) returns a handle to the annotation object
%
%   The arguments to ANNOTATION can be followed by parameter/value pairs to
%   specify additional properties of the annotation object. The X and Y or
%   POSITION arguments to ANNOTATION can be omitted entirely, and all
%   properties specified using parameter/value pairs.
%
%   Examples: rh=annotation('rectangle',[.1 .1 .3 .3]); 
%             ah=annotation('arrow',[.9 .5],[.9,.5],'Color','r');
%             th=annotation('textarrow',[.3,.6],[.7,.4],'String','ABC');

%   Copyright 1984-2014 The MathWorks, Inc.

%Check if the parent property is specified, and warn if so
inds = find(strcmpi('parent',varargin));
if ~isempty(inds) 
    %Throw a warning - the hgcheck method will strip it off the args
    warning(message('MATLAB:annotation:BadParent'));
    inds = unique([inds inds+1]);
    varargin(inds) = [];
end

% Make sure we have at least one input arg
if (nargin == 0)
   error(message('MATLAB:annotation:BadNumArgs')); 
end

% Check for an input of a figure (or uipanel, or uitab, ...)
args = varargin;
if ~ischar(args{1}) && ~isstring(args{1}) && isa(args{1},'matlab.ui.container.CanvasContainer')
    container = args{1};
    args = args(2:end);
else
    container = [];
end
nargs = numel(args);

if (nargs == 0)
   error(message('MATLAB:annotation:BadNumArgs')); 
end
atypes = {'arrow','doublearrow','line','textarrow','rectangle','ellipse','textbox'};
if isempty(container)
    if (~ischar(args{1}) && ~isstring(args{1})) || isempty(find(strcmpi(args{1},atypes), 1))
        error(message('MATLAB:annotation:FirstArgFigureOrAnnotation'));
    end
    container = gcf;
elseif (~ischar(args{1}) && ~isstring(args{1})) || isempty(find(strcmpi(args{1},atypes), 1))
        error(message('MATLAB:annotation:SecondArgValidAnnotation'));
end
atype = lower(args{1});
args = args(2:end);
nargs = nargs-1;

scribeax = findAnnotationPane(container);
aargs = {'Parent',scribeax};

inpvp=false; % flag processing pv pairs
k=1; % current arg

% parse args
while k<=nargs
    if inpvp 
        % already in pvpairs
        aargs(end+1)= args(k); %#ok<AGROW>
    elseif k<=nargs-1 && isnumeric(args{k}) && isnumeric(args{k+1}) && ...
            length(args{k})==2 && length(args{k+1})==2 && ...
            any(strcmpi(atype,{'line','arrow','textarrow','doublearrow'}))
        if any(args{k}(:)<0) || any(args{k}(:)>1) || ...
                any(args{k+1}(:)<0) || any(args{k+1}(:)>1)
            error(message('MATLAB:annotation:IllegalXYArguments'));
        end
        aargs=[aargs(:);{'X'};args(k);{'Y'};args(k+1)];
        k=k+1;
    elseif k<=nargs && isnumeric(args{k}) && length(args{k})==4 && ...
            any(strcmpi(atype,{'textbox','rectangle','ellipse'}))
        if any(args{k}(:)<0) || any(args{k}(:)>1)
            error(message('MATLAB:annotation:IllegalPositionArgument'));
        end
        aargs=[aargs(:); {'Position'}; args(k)];
    elseif ischar(args{k}) || isstring(args{k})
        % Start of pvpairs
        inpvp = true;
        aargs(end+1)= args(k); %#ok<AGROW>
    else
        error(message('MATLAB:annotation:BadArguments'));
    end
    k=k+1;
end

switch atype
    case 'line'
        h = matlab.graphics.shape.Line(aargs{:});
    case 'arrow'
        h = matlab.graphics.shape.Arrow(aargs{:});
    case 'doublearrow'
        h = matlab.graphics.shape.DoubleEndArrow(aargs{:});
    case 'textarrow'
        h = matlab.graphics.shape.TextArrow(aargs{:});
    case 'rectangle'
        h = matlab.graphics.shape.Rectangle(aargs{:});
    case 'ellipse'
        h = matlab.graphics.shape.Ellipse(aargs{:});
    case 'textbox'
        h = matlab.graphics.shape.TextBox(aargs{:});
end

if nargout > 0
    hOut = h;
end


