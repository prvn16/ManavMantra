%?    METACLASS    Return META.CLASS object
%
%   MC = METACLASS(OBJECT) returns the META.CLASS object for the class   
%   of OBJECT.  OBJECT can be either a scalar object or an array of 
%   objects, but the returned object is always the scalar META.CLASS for 
%   the class of OBJECT.
%
%   MC = ? CLASSNAME will retrieve the META.CLASS object for the class 
%   with name CLASSNAME.  The ? syntax works only with a class name and
%   not with a class instance.
%
%   Examples:
%
%   %Example 1: Retrieve the meta-class for class inputParser
%   ?inputParser
%
%   %Example 2: Retrieve the meta-class for an instance of class MException
%   obj = MException('Msg:ID','MsgTxt');
%   mc = metaclass(obj);
%
%   See also META.CLASS, META.CLASS.FROMNAME, CLASSDEF.

%   Copyright 2007-2008 The MathWorks, Inc. 
%   Built-in function.
