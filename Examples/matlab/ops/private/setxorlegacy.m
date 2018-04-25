function [c,ia,ib] = setxorlegacy(a,b,isrows)
% SETXORLEGACY 'legacy' flag implementation for setxor.
%   Implements the 'legacy' behavior (prior to R2012a) of SETXOR.

%   Copyright 1984-2014 The MathWorks, Inc.

if nargin==3 && isrows
    flag = 'rows';
else
    isrows = 0;
    flag = [];
end

rowsA = size(a,1);
colsA = size(a,2);
rowsB = size(b,1);
colsB = size(b,2);

rowvec = ~((rowsA > 1 && colsB <= 1) || (rowsB > 1 && colsA <= 1) || isrows);

numelA = numel(a);
numelB = numel(b);
nOut = nargout;

if ~(isa(a,'opaque') || isa(b,'opaque')) 
    
    if isempty(flag)
        
        if length(a)~=numelA || length(b)~=numelB
            error(message('MATLAB:SETXOR:AandBvectorsOrRowsFlag'));
        end
        
        c = [a([]);b([])];
        
        % Handle empty arrays.
        
        if (numelA == 0 || numelB == 0)
            % Predefine outputs to be of the correct type.
            if (numelA == 0 && numelB == 0)
                ia = []; ib = [];
                if (max(size(a)) > 0 || max(size(b)) > 0)
                    c = reshape(c,0,1);
                    ia = reshape(ia,0,1);
                    ib = reshape(ia,0,1);
                end
            elseif (numelA == 0)
                [c, ib] = unique(b(:),'legacy');
                ia = zeros(0,1);
            else
                [c, ia] = unique(a(:),'legacy');
                ib = zeros(0,1);
            end
            
            % General handling.
            
        else
            
            % Convert to columns.
            a = a(:);
            b = b(:);
            
            % Convert to double arrays, which sort faster than other types.
            
            whichclass = class(c);
            isdouble = strcmp(whichclass,'double');
            
            if ~isdouble
%                 if ~strcmp(class(a),'double') %#ok<STISA> Should not pass Sub-classes of double
                if ~isa(a,'double')                
                    a = double(a);
                end
%                 if ~strcmp(class(b),'double') %#ok<STISA> Should not pass Sub-classes of double
                if ~isa(b,'double')
                    b = double(b);
                end
            end
            
            % Sort if unsorted.  Only check this for long lists.
            
            checksortcut = 1000;
            
            if nOut <= 1
                if numelA <= checksortcut || ~(issorted(a))
                    a = sort(a);
                end
                if numelB <= checksortcut || ~(issorted(b))
                    b = sort(b);
                end
            else
                if numelA <= checksortcut || ~(issorted(a))
                    [a,ia] = sort(a);
                else
                    ia = (1:numelA)';
                end
                if numelB <= checksortcut || ~(issorted(b))
                    [b,ib] = sort(b);
                else
                    ib = (1:numelB)';
                end
            end
            
            % Find members of the XOR set.  Pass to ISMEMBC directly if
            % possible (real, full, no NaN) since A and B are sorted double arrays.
            if (isreal(a) && isreal(b)) && (~issparse(a) && ~issparse(b))
                if ~isnan(b(numelB))    % Check final index of B for NaN.
                    tfa = ~ismembc(a,b);
                else
                    tfa = ~ismember(a,b,'legacy'); % Call ISMEMBER if NaN detected in B.
                end
                if ~isnan(a(numelA))    % Check final index of A for NaN.
                    tfb = ~ismembc(b,a);
                else
                    tfb = ~ismember(b,a,'legacy'); % Call ISMEMBER if NaN detected in A.
                end
            else
                tfa = ~ismember(a,b,'legacy');   % If wrong types, call ISMEMBER directly.
                tfb = ~ismember(b,a,'legacy');
            end
            
            % a(tfa) now contains all members of A which are not in B
            % b(tfb) now contains all members of B which are not in A
            if nOut <= 1
                c = unique([a(tfa);b(tfb)],'legacy');    % Remove duplicates from XOR list.
            else
                ia = ia(tfa);
                ib = ib(tfb);
                n = size(ia,1);
                [c,ndx] = unique([a(tfa);b(tfb)],'legacy');  % NDX holds indices to generate C.
                d = ndx > n;                        % Find indices of A and of B.
                ia = ia(ndx(~d));
                ib = ib(ndx(d) - n);
            end
            
            % Re-convert to correct output data type using FEVAL.
            if ~isdouble
                c = feval(whichclass,c);
            end
        end
        
        % If row vector, return as row vector.
        if rowvec
            c = c.';
            if nOut > 1
                ia = ia.';
                if nOut > 2
                    ib = ib.';
                end
            end
        end
        
    else    % 'rows' case

        % Automatically pad strings with spaces
        if ischar(a) && ischar(b)
            if colsA > colsB
                b = [b repmat(' ',rowsB,colsA-colsB)];
            elseif colsA < colsB
                a = [a repmat(' ',rowsA,colsB-colsA)];
                colsA = colsB;
            end
        elseif colsA ~= colsB
            error(message('MATLAB:SETXOR:AandBColnumAgree'));
        end
        
        % Handle empty arrays.
        
        if isempty(a) && isempty(b)
            % Predefine c to be of the correct type.
            c = [a([]);b([])];
            if (rowsA + rowsB == 0)
                c = reshape(c,0,colsA);
            elseif (colsA == 0)
                c = reshape(c,(rowsA > 0) + (rowsB > 0),0);   % Empty row array.
                if rowsA > 0
                    ia = rowsA;
                else
                    ia = [];
                end
                if rowsB > 0
                    ib = rowsB;
                else
                    ib = [];
                end
            end
            
        else
            % Remove duplicates from A and B and sort.
            if nOut <= 1
                a = unique(a,flag,'legacy');
                b = unique(b,flag,'legacy');
                c = sortrows([a;b]);
            else
                [a,ia] = unique(a,flag,'legacy');
                [b,ib] = unique(b,flag,'legacy');
                [c,ndx] = sortrows([a;b]);
            end
            
            % Find all non-matching entries in sorted list.
            [rowsC,colsC] = size(c);
            if rowsC > 1 && colsC ~= 0
                % d indicates the location of non-matching entries
                d = c(1:rowsC-1,:)~=c(2:rowsC,:);
            else
                d = zeros(rowsC-1,0);
            end
            
            d = any(d,2);
            d(rowsC,1) = 1;     % Last row is always unique.
            d(2:rowsC) = d(1:rowsC-1) & d(2:rowsC); % Remove both if match.
            
            c = c(d,:);         % Keep only the non-matching entries
            
            if nOut > 1
                ndx = ndx(d);     % NDX: indices of non-matching entries
                n = size(a,1);
                d = ndx <= n;     % Values in a that don't match.
                ia = ia(ndx(d));
                d = ndx > n;      % Values in b that don't match.
                ib = ib(ndx(d)-n);
            end
        end
        
        % Automatically deblank strings
        if ischar(a) && ischar(b)
            c = deblank(c);
        end
    end
    
else
    % Handle objects that cannot be converted to doubles 
    if isempty(flag)
        
        if length(a)~=numelA || length(b)~=numelB
            error(message('MATLAB:SETXOR:AandBvectorsOrRowsFlag'));
        end
        
        c = [a([]);b([])];
        
        % Handle empty arrays.
        
        if (numelA == 0 || numelB == 0)
            % Predefine outputs to be of the correct type.
            if (numelA == 0 && numelB == 0)
                ia = []; ib = [];
                if (max(size(a)) > 0 || max(size(b)) > 0)
                    c = reshape(c,0,1);
                    ia = reshape(ia,0,1);
                    ib = reshape(ia,0,1);
                end
            elseif (numelA == 0)
                [c, ib] = unique(b(:),'legacy');
                ia = zeros(0,1);
            else
                [c, ia] = unique(a(:),'legacy');
                ib = zeros(0,1);
            end
            
            % General handling.
            
        else
            
            % Make sure a and b contain unique elements.
            [a,ia] = unique(a(:),'legacy');
            [b,ib] = unique(b(:),'legacy');
            
            % Find matching entries
            e = [a;b];
            [c,ndx] = sort(e);
            
            % d indicates the location of matching entries
            d = find(c(1:end-1)==c(2:end));
            ndx([d;d+1]) = []; % Remove all matching entries
            
            c = e(ndx);
            
            if nOut > 1
                n = length(a);
                d = ndx <= n;
                ia = ia(ndx(d));        % Find indices for set A if needed.
                if nOut > 2
                    d = ndx > n;
                    ib = ib(ndx(d)-n);    % Find indices for set B if needed.
                end
            end
        end
        
        % If row vector, return as row vector.
        if rowvec
            c = c.';
            if nOut > 1
                ia = ia.';
                if nOut > 2
                    ib = ib.';
                end
            end
        end
        
    else    % 'rows' case

        % Automatically pad strings with spaces
        if ischar(a) && ischar(b)
            if colsA > colsB
                b = [b repmat(' ',rowsB,colsA-colsB)];
            elseif colsA < colsB
                a = [a repmat(' ',rowsA,colsB-colsA)];
                colsA = colsB;
            end
        elseif colsA ~= colsB
            error(message('MATLAB:SETXOR:AandBColnumAgree'));
        end
        
        % Handle empty arrays.
        
        if isempty(a) && isempty(b)
            % Predefine c to be of the correct type.
            c = [a([]);b([])];
            ia = []; ib = [];
            if (rowsA + rowsB == 0)
                c = reshape(c,0,colsA);
            elseif (colsA == 0)
                c = reshape(c,(rowsA > 0) + (rowsB > 0),0);   % Empty row array.
                if rowsA > 0
                    ia = rowsA;
                end
                if rowsB > 0
                    ib = rowsB;
                end
            end
            
        else
            % Remove duplicates from A and B and sort.
            if nOut <= 1
                a = unique(a,flag,'legacy');
                b = unique(b,flag,'legacy');
                c = sortrows([a;b]);
            else
                [a,ia] = unique(a,flag,'legacy');
                [b,ib] = unique(b,flag,'legacy');
                [c,ndx] = sortrows([a;b]);
            end
            
            % Find all non-matching entries in sorted list.
            [rowsC,colsC] = size(c);
            if rowsC > 1 && colsC ~= 0
                % d indicates the location of non-matching entries
                d = c(1:rowsC-1,:)~=c(2:rowsC,:);
            else
                d = zeros(rowsC-1,0);
            end
            
            d = any(d,2);
            d(rowsC,1) = 1;     % Last row is always unique.
            d(2:rowsC) = d(1:rowsC-1) & d(2:rowsC); % Remove both if match.
            
            c = c(d,:);         % Keep only the non-matching entries
            
            if nOut > 1
                ndx = ndx(d);     % NDX: indices of non-matching entries
                n = size(a,1);
                d = ndx <= n;     % Values in a that don't match.
                ia = ia(ndx(d));
                d = ndx > n;      % Values in b that don't match.
                ib = ib(ndx(d)-n);
            end
        end
        
        % Automatically deblank strings
        if ischar(a) && ischar(b)
            c = deblank(c);
        end
    end
end
end
