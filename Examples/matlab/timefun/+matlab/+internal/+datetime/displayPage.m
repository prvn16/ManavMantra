function displayPage(pageChars,sz,isLoose,maxWidth)
% Display one page's worth of date/time data

%   Copyright 2014 The MathWorks, Inc.

m = sz(1); n = sz(2);
pad = repmat('   ',m,1);
chars = repmat(' ',m,0);
jold = 1;
for j = 1:n
    colChars = pageChars((1:m)+(j-1)*m,:);
    
    % If we've reached the right margin, display the output built
    % up so far, and then restart for display starting at the left
    % margin.
    if j > 1 && (size(chars,2) + size(pad,2) + size(colChars,2)) > maxWidth
        displayHeader(jold,j-1);
        if (isLoose), fprintf('\n'); end
        disp(chars);
        if (isLoose), fprintf('\n'); end
        chars = repmat('',m,0);
        jold = j;
    end
    chars = [chars pad colChars]; %#ok<AGROW>
end
if jold > 1
    displayHeader(jold,j);
    if (isLoose), fprintf('\n'); end
end
disp(chars);


function displayHeader(fromCol,toCol)
if fromCol == toCol
    header = getString(message('MATLAB:datetime:uistrings:DisplayColumnHeaderShort',fromCol));
else
    header = getString(message('MATLAB:datetime:uistrings:DisplayColumnHeader',fromCol,toCol));
end
disp(header);
