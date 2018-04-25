function ln = getlastexecutableline( o )
%GETLASTEXECUTABLELINE l = getlastexecutableline( o ) the last line
%   of executable code
%   This returns the last line of executable code for a given
%   subtree.

% Copyright 2006-2014 The MathWorks, Inc.

    lastNode = last(o);
    Pos5 = lastNode.T( lastNode.IX, 5 ); % these are positions
    Pos7 = lastNode.T( lastNode.IX, 7 ); %
    ln = zeros(length(Pos5),1);
    for i=1:length(Pos5)
        line5 = linelookup( lastNode, Pos5(i) );
        line7 = linelookup( lastNode, Pos7(i) );
        % In almost all cases column 5 will have the correct
        % position information, however when the last symbol in the
        % file is an 'end' this can only be picked up by looking at
        % column 7.
        if line5 > line7
            ln(i) = line5;
        else
            ln(i) = line7;
        end
    end
end
