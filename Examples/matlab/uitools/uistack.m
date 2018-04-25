function varargout=uistack(Handles,StackOpt,Step)
%UISTACK Reorder the visual stacking order of objects.
%   UISTACK(H) raises the visual stacking order of the objects specified by
%   the handles in H by one level (STEP of 1).
%
%   UISTACK(H, STACKOPT) where STACKOPT is 'up', 'down', 'top' or 'bottom'
%   specifies how to stack the objects specified by the handles in H.
%
%   UISTACK(H, STACKOPT, STEP) where STEP is the distance to move 'up' or
%   'down' applies the stacking option to the objects specified by the
%   handles in H. All handles in H must have the same parent.
%
%   Example: 
%       OriginalColorOrder='rgbyc';
%       Expected_Color531top='ygrbc';
%       close all force;
% 
%       Fig=figure('color','black');
%       for lp=1:5,
%           Orig_order(lp,1)=axes('Color'  ,OriginalColorOrder(lp), ...
%                             'Position',[.15*(lp-1) .15*(lp-1) .4 .4], ...
%                             'XTick',[], ...
%                             'YTick',[], ...
%                             'Tag',OriginalColorOrder(lp));
%       end
% 
%       %these blocks should be stacked in order 5, 3, 1
%       Tmp_order=uistack(Orig_order([5 3 1]),'top');
%       index=1;
%       ActualColorOrder9='';
%       for lp=1:size(Tmp_order,1);
%           if strcmp(Tmp_order(lp).Type,'axes'),
%               New_order(index)=Tmp_order(lp);
%               ActualColorOrder9=[New_order(index).Tag,ActualColorOrder9];
%               index=index+1;
%           end
%       end
%
%   See also ALIGN, UICONTROL, UIPANEL

%   Copyright 1984-2015 MathWorks, Inc.

nargoutchk(0,1);
narginchk(1,3);

if nargin > 1
    StackOpt = convertStringsToChars(StackOpt);
end

if isempty(Handles) && ~all(ishghandle(Handles))
    error(message('MATLAB:uistack:PassedInvalidHandles'));
end
matlab.ui.internal.UnsupportedInUifigure(Handles);
if nargin==1
    StackOpt='up';
    Step=1;
end
if nargin==2
    Step=1;
end
if Step<0
    Step = 0;
end

Parent = get(Handles, {'Parent'});
Parent=[Parent{:}];
UParent=unique(Parent);
if length(UParent)>1
    error(message('MATLAB:uistack:ParentMustBeSame'));
end

% move objects one type by one type
Hrest = Handles;
while ~isempty(Hrest)
    doRestack = true;

    % find handles of the same type
    SameType = Hrest(1);

    % if restacking children in an axes, don't check for the types
    % we only need to check the types if the parent is a figure or a
    % container. this prevents us from trying to put axes in front
    % of uicontrols (which will not work).
    if (ishghandle(UParent, 'axes') || ishghandle(UParent,'annotationpane'))
        % just do the restack
        Children = allchild(UParent);
        SameType = Handles;
        Hrest = [];
    else
        % check if the objects being moved are of the type where
        % different types of objects can be restack relative to each other

        % get a vector of items being restack
        % that correspond to each other either by type or by a special case
        for i=2:length(Hrest)
            if (canItemTypeMix(Hrest(1), Hrest(i)))
                SameType = [SameType;Hrest(i)];
            end
        end

        % keep the rest
        Hrest(ismember(Hrest,SameType)) = [];

        % get appropriate children based on type
        Children = getAppropriateChildren(SameType);
        doRestack = (length(Children) > length(SameType));
    end
    
    % if we got a row vector, convert it to a columb vector
    SameTypeCols = size(SameType, 2);
    if (SameTypeCols ~= 1)
        SameType = transpose(SameType);
    end

    if doRestack
        % change stack order. The NewOrder obtained here is always an
        % object array.
        NewOrder = getNewOrder(SameType, Children, StackOpt, Step);

        % update stack order
        % For figures, need to do something special
        if isequal(double(UParent),0)
            for lp=length(NewOrder):-1:1
                if strcmp(get(NewOrder(lp),'Visible'),'on')
                    figure(NewOrder(lp));
                end
            end
            drawnow;
        else
            AllChildren = allchild(UParent);
            if isnumeric(AllChildren)
                % @todo DoubleConversion: Forcing a double-conversion. 
                % If allchild returns doubles, we would like to do the
                % ismember check with 2 double arrays
                NewOrder = double(NewOrder);
            end
            AllChildren(ismember(AllChildren,NewOrder)) = NewOrder;
            set(UParent,'Children',AllChildren);
        end
    end

end %while

if nargout
    varargout{1}=allchild(UParent);
end


% --------------------------------------------------------------------
% This function now always returns object arrays instead of double arrays
function NewOrder = getNewOrder(SameType, Children, StackOpt, Step)
% @todo DoubleConversion: Forcing a double-conversion. 
SameType = double(SameType);
Children = double(Children);

NOUSE = -1;

HandleLoc=find(ismember(Children,SameType));

switch StackOpt
    case 'up'
        NewOrder=[ones(Step,1).*NOUSE;Children];
        HandleLoc = HandleLoc + Step;
        for lp=1:length(SameType)
            Idx=HandleLoc(lp);
            NewOrder= [NewOrder(1:Idx-Step-1);NewOrder(Idx);NewOrder(Idx-Step:Idx-1);NewOrder(Idx+1:length(NewOrder))];
        end % for lp
        NewOrder(NewOrder == NOUSE) = [];

    case 'down'
        NewOrder=[Children;ones(Step,1).*NOUSE];
        for lp=length(SameType):-1:1
            Idx=HandleLoc(lp);
            NewOrder = [NewOrder(1:Idx-1);NewOrder(Idx+1:Idx+Step);NewOrder(Idx);NewOrder(Idx+Step+1:length(NewOrder))];
        end % for lp
        NewOrder(NewOrder == NOUSE) = [];

    case 'top'
        % to preserve the child order instead of the input handle order, uncomment the following line
        % SameType = Children(HandleLoc);
        Children(HandleLoc)=[];
        NewOrder=[SameType;Children];

    case 'bottom'
        % to preserve the child order instead of the input handle order, uncomment the following line
        % SameType = Children(HandleLoc);
        Children(HandleLoc)=[];
        NewOrder=[Children;SameType];

    otherwise
        error(message('MATLAB:uistack:InvalidStackOption'));

end % switch
% Force an object array conversion.
NewOrder = handleConvert(NewOrder);


% --------------------------------------------------------------------
% This function does a conversion of double arrays to object arrays.
function handleOrder = handleConvert(order)
assert(isnumeric(order));
handleOrder = arrayfun(@(x) handle(x) , order, 'UniformOutput',false);
handleOrder = [handleOrder{:}];

% --------------------------------------------------------------------
function Children = getAppropriateChildren(SameType)
Parent = get(SameType(1), 'Parent');

% determine which children are of the same type or otherwise correspond to
% items in the SameType vector
Children = allchild(Parent);
selectChildren = [];
for i=1:length(Children)
    if (canItemTypeMix(SameType(1), Children(i)))
        selectChildren = [selectChildren;Children(i)];
    end
end
Children = selectChildren;

% --------------------------------------------------------------------
