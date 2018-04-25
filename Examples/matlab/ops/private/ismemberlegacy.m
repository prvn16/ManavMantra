function [tf,loc] = ismemberlegacy(a,s,isrows)
% ISMEMBERLEGACY 'legacy' flag implementation for ismember.
%   Implement the 'legacy' behavior (prior to R2012a) of ISMEMBER.

%   Copyright 1984-2014 The MathWorks, Inc.

if nargin == 3 && isrows
    flag = 'rows';
else
    flag = [];
end

numelA = numel(a);
numelS = numel(s);
nOut = nargout;

if ~(isa(a,'opaque') || isa(s,'opaque'))
    
    if isempty(flag)
        
        % Initialize types and sizes.
        
        tf = false(size(a));
        
        if nOut > 1
            loc = zeros(size(a));
        end
        
        % Handle empty arrays and scalars.
        
        if numelA == 0 || numelS <= 1
            if (numelA == 0 || numelS == 0)
                return
                % Scalar A handled below.
                % Scalar S: find which elements of A are equal to S.
            elseif numelS == 1
                tf = (a == s);
                if nOut > 1
                    % Use DOUBLE to convert logical "1" index to double "1" index.
                    loc = double(tf);
                end
                return
            end
        else
            % General handling.
            % Use FIND method for very small sizes of the input vector to avoid SORT.
            scalarcut = 5;
            if numelA <= scalarcut
                if nOut <= 1
                    for i=1:numelA
                        tf(i) = any(a(i)==s(:));   % ANY returns logical.
                    end
                else
                    for i=1:numelA
                        found = find(a(i)==s(:));  % FIND returns indices for LOC.
                        if ~isempty(found)
                            tf(i) = 1;
                            loc(i) = found(end);
                        end
                    end
                end
            else
                % Use method which sorts list, then performs binary search.
                % Convert to double for quicker sorting, to full to work in C helper.
                a = double(a);
                if issparse(a)
                    a = full(a);
                end
                
                s = double(s);
                if issparse(s)
                    s = full(s);
                end
                
                if (isreal(s))
                    % Find out whether list is presorted before sort
                    % If the list is short enough, SORT will be faster than ISSORTED
                    % If the list is longer, ISSORTED can potentially save time
                    checksortcut = 1000;
                    if numelS > checksortcut
                        sortedlist = issorted(s(:));
                    else
                        sortedlist = 0;
                    end
                    if nOut > 1
                        if ~sortedlist
                            [s,idx] = sort(s(:));
                        end
                    elseif ~sortedlist
                        s = sort(s(:));
                    end
                else
                    sortedlist = 0;
                    [~,idx] = sort(real(s(:)));
                    s = s(idx);
                end
                
                % Two C-Helper Functions are used in the code below:
                
                % ISMEMBC  - S must be sorted - Returns logical vector indicating which
                % elements of A occur in S
                % ISMEMBC2 - S must be sorted - Returns a vector of the locations of
                % the elements of A occurring in S.  If multiple instances occur,
                % the last occurrence is returned
                
                % Check for NaN values - NaN values will be at the end of S,
                % but may be anywhere in A.
                
                nana = isnan(a(:));
                
                if (any(nana) || isnan(s(numelS)))
                    % If NaNs detected, remove NaNs from the data before calling ISMEMBC.
                    ida = (nana == 0);
                    ids = (isnan(s(:)) == 0);
                    if nOut <= 1
                        ainfn = ismembc(a(ida),s(ids));
                        tf(ida) = ainfn;
                    else
                        loc1 = ismembc2(a(ida),s(ids));
                        tf(ida) = (loc1 > 0);
                        loc(ida) = loc1;
                        loc(~ida) = 0;
                    end
                else
                    % No NaN values, call ISMEMBC directly.
                    if nOut <= 1
                        tf = ismembc(a,s);
                    else
                        loc = ismembc2(a,s);
                        tf = (loc > 0);
                    end
                end
                
                if nOut > 1 && ~sortedlist
                    % Re-reference loc to original list if it was unsorted
                    loc(tf) = idx(loc(tf));
                end
            end
        end
        
    else    % 'rows' case
        
        rowsA = size(a,1);
        colsA = size(a,2);
        rowsS = size(s,1);
        colsS = size(s,2);
        
        % Automatically pad strings with spaces
        if ischar(a) && ischar(s),
            if colsA > colsS
                s = [s repmat(' ',rowsS,colsA-colsS)];
            elseif colsA < colsS
                a = [a repmat(' ',rowsA,colsS-colsA)];
            end
        elseif colsA ~= colsS && ~isempty(a) && ~isempty(s)
            error(message('MATLAB:ISMEMBER:AandBColnumAgree'));
        end
        
        % Empty check for 'rows'.
        if rowsA == 0 || rowsS == 0
            if (isempty(a) || isempty(s))
                tf = false(rowsA,1);
                loc = zeros(rowsA,1);
                return
            end
        end
        
        % General handling for 'rows'.
        
        % Duplicates within the sets are eliminated
        if (rowsA == 1)
            au = repmat(a,rowsS,1);
            d = au(1:end,:)==s(1:end,:);
            d = all(d,2);
            tf = any(d);
            if nOut > 1
                if tf
                    loc = find(d, 1, 'last');
                else
                    loc = 0;
                end
            end
            return;
        else
            [au,~,an] = unique(a,'rows','legacy');
        end
        if nOut <= 1
            su = unique(s,'rows','legacy');
        else
            [su,sm] = unique(s,'rows','legacy');
        end
        
        % Sort the unique elements of A and S, duplicate entries are adjacent
        [c,ndx] = sortrows([au;su]);
        
        % Find matching entries
        d = c(1:end-1,:)==c(2:end,:);     % d indicates matching entries in 2-D
        d = find(all(d,2));               % Finds the index of matching entries
        ndx1 = ndx(d);                    % NDX1 are locations of repeats in C
        
        if nOut <= 1
            tf = ismember(an,ndx1,'legacy');         % Find repeats among original list
        else
            szau = size(au,1);
            [tf,loc] = ismember(an,ndx1,'legacy');   % Find loc by using given indices
            newd = d(loc(tf));              % NEWD is D for non-unique A
            where = sm(ndx(newd+1)-szau);  % Index values of SU through UNIQUE
            loc(tf) = where;                % Return last occurrence of A within S
        end
    end
else
    % Handle objects that cannot be converted to doubles
    if isempty(flag)
        
        % Handle empty arrays and scalars.
        
        if numelA == 0 || numelS <= 1
            if (numelA == 0 || numelS == 0)
                tf = false(size(a));
                loc = zeros(size(a));
                return
                
                % Scalar A handled below.
                % Scalar S: find which elements of A are equal to S.
            elseif numelS == 1
                tf = (a == s);
                if nOut > 1
                    % Use DOUBLE to convert logical "1" index to double "1" index.
                    loc = double(tf);
                end
                return
            end
        else
            % General handling.
            % Use FIND method for very small sizes of the input vector to avoid SORT.
            scalarcut = 5;
            if numelA <= scalarcut
                tf = false(size(a));
                loc = zeros(size(a));
                if nOut <= 1
                    for i=1:numelA
                        tf(i) = any(a(i)==s);   % ANY returns logical.
                    end
                else
                    for i=1:numelA
                        found = find(a(i)==s);  % FIND returns indices for LOC.
                        if ~isempty(found)
                            tf(i) = 1;
                            loc(i) = found(end);
                        end
                    end
                end
            else
                
                % Duplicates within the sets are eliminated
                [au,~,an] = unique(a(:),'legacy');
                if nOut <= 1
                    su = unique(s(:),'legacy');
                else
                    [su,sm] = unique(s(:),'legacy');
                end
                
                % Sort the unique elements of A and S, duplicate entries are adjacent
                [c,ndx] = sort([au;su]);
                
                % Find matching entries
                d = c(1:end-1)==c(2:end);         % d indicates matching entries in 2-D
                d = find(d);                      % Finds the index of matching entries
                ndx1 = ndx(d);                    % NDX1 are locations of repeats in C
                
                if nOut <= 1
                    tf = ismember(an,ndx1,'legacy');         % Find repeats among original list
                else
                    szau = size(au,1);
                    [tf,loc] = ismember(an,ndx1,'legacy');   % Find loc by using given indices
                    newd = d(loc(tf));              % NEWD is D for non-unique A
                    where = sm(ndx(newd+1)-szau);   % Index values of SU through UNIQUE
                    loc(tf) = where;                % Return last occurrence of A within S
                end
            end
            tf = reshape(tf,size(a));
            if nOut > 1
                loc = reshape(loc,size(a));
            end
        end
        
    else    % 'rows' case
        
        rowsA = size(a,1);
        colsA = size(a,2);
        rowsS = size(s,1);
        colsS = size(s,2);
        
        % Automatically pad strings with spaces
        if ischar(a) && ischar(s),
            if colsA > colsS
                s = [s repmat(' ',rowsS,colsA-colsS)];
            elseif colsA < colsS
                a = [a repmat(' ',rowsA,colsS-colsA)];
            end
        elseif size(a,2)~=size(s,2) && ~isempty(a) && ~isempty(s)
            error(message('MATLAB:ISMEMBER:AandBColnumAgree'));
        end
        
        % Empty check for 'rows'.
        if rowsA == 0 || rowsS == 0
            if (isempty(a) || isempty(s))
                tf = false(rowsA,1);
                loc = zeros(rowsA,1);
                return
            end
        end
        
        % Duplicates within the sets are eliminated
        [au,~,an] = unique(a,'rows','legacy');
        if nOut <= 1
            su = unique(s,'rows','legacy');
        else
            [su,sm] = unique(s,'rows','legacy');
        end
        
        % Sort the unique elements of A and S, duplicate entries are adjacent
        [c,ndx] = sortrows([au;su]);
        
        % Find matching entries
        d = c(1:end-1,:)==c(2:end,:);     % d indicates matching entries in 2-D
        d = find(all(d,2));               % Finds the index of matching entries
        ndx1 = ndx(d);                    % NDX1 are locations of repeats in C
        
        if nOut <= 1
            tf = ismember(an,ndx1,'legacy');         % Find repeats among original list
        else
            szau = size(au,1);
            [tf,loc] = ismember(an,ndx1,'legacy');   % Find loc by using given indices
            newd = d(loc(tf));              % NEWD is D for non-unique A
            where = sm(ndx(newd+1)-szau);   % Index values of SU through UNIQUE
            loc(tf) = where;                % Return last occurrence of A within S
        end
    end
end
end
