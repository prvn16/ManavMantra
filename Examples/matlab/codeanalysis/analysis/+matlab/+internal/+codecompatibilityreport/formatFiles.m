function fileTable = formatFiles(cca)
%formatFiles Convert Files from the input to a table
%   Convert the strings array from the input to a table

%   Copyright 2017 The MathWorks, Inc.

        fileTable = array2table(cca.Files, 'VariableNames', {'Files'});

end
