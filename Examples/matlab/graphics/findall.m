function ObjList=findall(HandleList,varargin)
%FINDALL find all objects.
%   ObjList=FINDALL(HandleList) returns the list of all objects 
%   beneath the Handles passed in.  FINDOBJ is used and all objects
%   including those with HandleVisibility set to 'off' are found.
%   FINDALL is called exactly as FINDOBJ is called.  For instance,
%   ObjList=findall(HandleList,Param1,Val1,Param2,Val2, ...).
%  
%   Example:
%     plot(1:10)
%     xlabel xlab
%     a=findall(gcf)
%     b=findobj(gcf)
%     c=findall(b,'Type','text') % return the xlabel handle twice
%     d=findobj(b,'Type','text') % can't find the xlabel handle
%
%   See also ALLCHILD, FINDOBJ.

%   Loren Dean
%   Copyright 1984-2017 The MathWorks, Inc.


if ~isa(HandleList,'matlab.graphics.Graphics') && nnz(~ishghandle(HandleList))
    error(message('MATLAB:findall:InvalidHandles'));
end
    
rootobj = 0;
if ~isempty( HandleList )
    rootobj = groot;
end

%Set up an onCleanup object that would restore the root global state after
%we do a findobj. We are explicitly making sure that there are no
%nested/anonymous functions involved here because findall executed through
%a timer callback is causing unexpected failure modes with onCleanup.
%Making a sub-function return an anonymous function handle is safer here.
c = onCleanup(showHiddenHandlesToFindAllHandles(rootobj));


try
  ObjList=findobj(HandleList,varargin{:});
catch ex %#ok
  ObjList=-1;
end

if isequal(ObjList,-1)
  error(message('MATLAB:findall:InvalidParameter'));
end

%-----------------------------------------------------------
function task = showHiddenHandlesToFindAllHandles(rootobj)
Temp=get(rootobj,'ShowHiddenHandles');
set(rootobj,'ShowHiddenHandles','on');
task = @() set(rootobj, 'ShowHiddenHandles',Temp);

