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

%   Copyright 2011 The MathWorks, Inc.
