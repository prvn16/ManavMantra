%meta.EnumeratedValue    Describe enumeration member of MATLAB class
%    The meta.EnumeratedValue class contains descriptive information about
%    enumeration members defined by MATLAB classes.  Properties of a
%    meta.EnumeratedValue instance correspond to attributes of the
%    enumeration member being described.
%
%    All meta.EnumeratedValue properties are read-only.  You can query the
%    meta.EnumeratedValue instance to obtain information about the
%    enumeration member it describes.
%
%    Obtain a meta.EnumeratedValue instance from the EnumerationMemberList
%    property of the meta.class instance.  EnumerationMemberList is an
%    array of Meta.EnumeratedValue instances, one per enumeration member.
%    
%    % Example: Given the following class which defines two enumeration
%    members.
%
%           classdef OnOff < logical
%               enumeration
%                   On(true)
%                   Off(false)
%               end
%           end
%
%    The code below shows the information about the first enumeration
%    member:
%
%           mc = ?OnOff; elist = mc.EnumerationMemberList; elist(1)
%
%    See also meta.class, enumeration
