function [cnts,headings] = summary(a,dim)
%SUMMARY Print summary of a categorical array.
%   SUMMARY(A) displays the number of elements in the categorical array A
%   that are equal to each of A's categories.  If A contains any undefined
%   elements, the output also includes the number of undefined elements.
%
%   If A is a vector, SUMMARY displays counts for the entire vector.  If A is a
%   matrix or N-D array, SUMMARY displays counts separately for each column of A.
%
%   SUMMARY(A,DIM) displays the summary computed along the dimension DIM of A.
%
%   See also ISCATEGORY, ISMEMBER, COUNTCATS.

%   Copyright 2006-2016 The MathWorks, Inc.

if nargin==1
    dim = find(size(a)~=1,1,'first');
    if isempty(dim), dim = 1; end
end
c = countcats(a,dim);
catnames = a.categoryNames;
nundefs = sum(isundefined(a),dim);
if any(nundefs(:) > 0)
    c = cat(dim,c,nundefs);
    if nargout ~= 1
        catnames = [catnames;categorical.undefLabel];
    end
end

if nargout < 1
    % Blockwise process and output summary
    blockSize = 200;
    numCats = length(catnames);
    
    for jBegin = 1:blockSize:numCats
        % End of range for this block
        % -1 to avoid duplicating last/first category between blocks.
        jEnd = min(jBegin+blockSize-1, numCats);
        
        % Preserve quotes in category names by substituting with an obscure
        % character here. These quotes are recovered at the end after all
        % intermediate processing
        blockCatnames = strrep(catnames(jBegin:jEnd), '''', char(1));

        % Wrap bold-tags around each category name in the headings
        blockHeadings = permute(blockCatnames,circshift(1:max(dim,2),[0 dim-1]));
        if matlab.internal.display.isHot % verify display supports HTML parsing
            blockHeadings = strcat('<strong>', blockHeadings, '</strong>');
        end
        
        % Get categorical counts subset along the user specified dimension
        block_c_index = repmat({':'}, 1, ndims(c));
        block_c_index{dim} = jBegin:jEnd;
        block_c = c(block_c_index{:});

        % Add row headers for column summaries and column headers for row summaries.
        if dim < 3
            if ~ismatrix(block_c)
                tile = size(block_c); tile(1:2) = 1;
                blockHeadings = repmat(blockHeadings,tile);
            end
            block_c = cat(3-dim,blockHeadings,num2cell(block_c));
        end
        
        % Leverage and capture cell display output for proper formatting
        summaryStr = evalc('disp(block_c)');
        
        % Do some regexp magic to put the category names into summaries along higher dims.
        if dim > 2
            for i = 1:length(blockHeadings)
                pattern = ['(\(\:\,\:' repmat('\,[0-9]',[1,dim-3]) '\,)' ...
                    '(' num2str(i) ')' ...
                    '(' repmat('\,[0-9]',[1,ndims(block_c)-dim]) '\) *= *\n)'];
                rep = ['$1' blockHeadings{i} '$3'];
                summaryStr = regexprep(summaryStr,pattern,rep);
            end
        end
        
        % Remove trailing newlines.Their location varies with format loose
        % vs format compact, so use regexp.
        summaryStr = regexprep(summaryStr, '\n*$', '');
        % Find brackets containing numbers in any format, and preceded by
        % whitespace -- those are the counts.  Replace those enclosing brackets
        % with spaces.
        summaryStr = regexprep(summaryStr,'(\s)\[([^\]]+)\]','$1 $2 ');
        
        % Recover quotes originally in category names
        summaryStr = strrep(summaryStr, '''', ' ');
        summaryStr = strrep(summaryStr, char(1), '''');
        
        % Display summary text for this block
        disp(summaryStr);
    end
    
elseif isa(a,'nominal') || isa(a,'ordinal')
    cnts = c;
    headings = permute(catnames,circshift(1:max(dim,2),[0 dim-1]));
else
    error(message('MATLAB:TooManyOutputs'));
end
