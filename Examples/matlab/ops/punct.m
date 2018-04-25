%Punctuation.
% .   Decimal point. 325/100, 3.25 and .325e1 are all the same.
%
% .   Array operations.  Element-by-element multiplicative operations
%     are obtained using .* , .^ , ./ , .\ or .'.  For example,
%     C = A ./ B is the matrix with elements c(i,j) = a(i,j)/b(i,j).
%
% .   Field access.  A.field and A(i).field, when A is a structure, access
%     the contents of the field with the name "field".  If A isn't a
%     scalar structure, this produces a comma separated list (see LISTS).
%     You can nest structure access as in X(2).field(3).name.  You can
%     also combine structure, cell array, and parentheses subscripting 
%     for arrays stored in the structure (see PAREN).
%
% ..  Parent directory.  See CD.
%
% ... Continuation. Three or more periods at the end of a line continue 
%     the current command or function call onto the next line. Three or 
%     more periods before the end of a line cause MATLAB to ignore the 
%     remaining text on the current line and continue the command or 
%     function call onto the next line. This effectively makes a comment 
%     out of anything on the current line that follows the periods.
%
% ,   Comma.  The comma is used to separate matrix subscripts
%     and arguments to functions.  It is also used to separate
%     statements in multi-statement lines. In this situation,
%     it may be replaced by a semicolon to suppress printing.
%
% ;   Semicolon.  The semicolon is used inside brackets to indicate
%     the ends of the rows of a matrix.  It is also used after an
%     expression or statement to suppress printing.
%
% %   Percent.  The percent symbol is used to begin comments.
%     Logically, it serves as an end-of-line character.  Any
%     following text on the line is ignored or printed by the
%     HELP system.
%
% %{  Percent-OpenBrace.  This symbol begins a block comment. Use this
%     symbol to enter a multiline comment. MATLAB ignores everything
%     within a block comment during execution including any program code.
%     The %{ symbol must appear alone on the line that precedes the comment.
%
%     You can also use block comments to comment out code in the middle 
%     of a multi-line statement. You cannot do this with the single-line 
%     comment operator, %. For example, the statement on the left below 
%     is valid, while the one on the right is not:
%
%            addpath(...               addpath( ... 
%                'dir1', ...               'dir1', ... 
%            %{                        %    'dir2', ...
%                'dir2', ...               'dir3'
%            %}                            )
%                'dir3' ...
%                )
%
% %}  Percent-CloseBrace.  This symbol ends a block comment. Use this
%     symbol to enter a multiline comment. MATLAB ignores everything
%     within a block comment during execution including any program code.
%     The %} symbol must appear alone on the line that follows the comment.
%     See the %{ symbol, above.
%
% !   Exclamation point.  Any text following the '!' is issued
%     as a command to the underlying computer operating system.
%     On the PC, adding & to the end of the ! command line, as in
%        !dir &
%     causes the output to appear in a separate window and for the window
%     to remain open after the command completes.
%
% '   Transpose.   X' is the complex conjugate transpose of X. 
%     X.' is the non-conjugate transpose.
%
% '   Quote. 'ANY TEXT' is a vector whose components are the
%     ASCII codes for the characters.  A quote within the text
%     is specified with two consecutive quotes.  For example: 'Don''t forget.'
%
% "   Double quote. "ANY TEXT" is a scalar string whose content matches 
%     the quoted text. A double quote within the text is specified with 
%     two consecutive double quotes.  For example: "the ""best-fit"" parameter"
%
% =   Assignment.  B = A stores the elements of A in B.
%
% @   At.  The at symbol is used to create a function_handle.
%     It is also used at the beginning of directory names that contain
%     matlab object methods and the constructor for the object, e.g.
%     the directory @inline contains the constructor inline.m for the 
%     inline object and all methods for inline objects.
%
% ~   The tilde character can be used in function definitions to
%     represent an input argument that is unused within the function.
%     It can also be used to indicate that an output argument of a
%     function call is to be ignored.  In this case, it must appear
%     within [ ] and separated by commas from any other arguments.
%
%
%     See also RELOP, COLON, LISTS, PAREN, CD, FUNCTION_HANDLE.

%   Copyright 1984-2016 The MathWorks, Inc.
