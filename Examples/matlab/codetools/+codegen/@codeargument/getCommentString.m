function str = getCommentString(hArg)
%getCommentString Create a comment string for the variable
%
%  getCommentString(arg) returns a string describing the variable, for use
%  as a comment line.  If the Comment property has been set then this will
%  be used as part of the string.  The returned string will not have a '%'
%  sign prefixed.

% Copyright 2015 The MathWorks, Inc.

comment = hArg.Comment;
if isa(comment, 'message')
    comment = getString(comment);
end

varname = hArg.String;
if ~isempty(comment) && ischar(comment)
    % Force variable description to use upper/lower case format
    % MYVARIABLE myvariable description
    str = [upper(varname),':  ',lower(comment)];
else
    str = upper(varname);
end
