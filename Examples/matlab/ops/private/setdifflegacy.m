function [c,ia] = setdifflegacy(a,b,isrows)
% SETDIFFLEGACY 'legacy' flag implementation for setdiff.
%   Implements the 'legacy' behavior (prior to R2012a) of SETDIFF.

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

nOut = nargout;

if ~(isa(a,'opaque') || isa(b,'opaque')) 
    
    if isempty(flag)
        
        numelA = length(a);
        numelB = length(b);
        
        if numel(a)~=numelA || numel(b)~=numelB
            error(message('MATLAB:SETDIFF:AandBvectorsOrRowsFlag'));
        end
        
        % Handle empty arrays.
        
        if (numelA == 0)
            % Predefine outputs to be of the correct type.
            c = a([]);
            ia = [];
            % Ambiguous if no way to determine whether to return a row or column.
            ambiguous = (rowsA==0 && colsA==0) && ...
                ((rowsB==0 && colsB==0) || numelB == 1);
            if ~ambiguous
                c = reshape(c,0,1);
                ia = reshape(ia,0,1);
            end
        elseif (numelB == 0)
            % If B is empty, invoke UNIQUE to remove duplicates from A.
            if nOut <= 1
                c = unique(a,'legacy');
            else
                [c,ia] = unique(a,'legacy');
            end
            return
            
            % Handle scalar: one element.  Scalar A done only.
            % Scalar B handled within ISMEMBER and general implementation.
            
        elseif (numelA == 1)
            if ~ismember(a,b,'legacy')
                c = a;
                ia = 1;
            else
                c = [];
                ia = [];
            end
            return
            
            % General handling.
            
        else
            
            % Convert to columns.
            a = a(:);
            b = b(:);
            
            % Convert to double arrays, which sort faster than other types.
            
            whichclass = class(a);
            isdouble = strcmp(whichclass,'double');
            
            if ~isdouble
                a = double(a);
            end
             
            if ~isa(b,'double')
                b = double(b);
            end
            
            % Call ISMEMBER to determine list of non-matching elements of A.
            tf = ~(ismember(a,b,'legacy'));
            c = a(tf);
            
            % Call UNIQUE to remove duplicates from list of non-matches.
            if nargout <= 1
                c = unique(c,'legacy');
            else
                [c,ndx] = unique(c,'legacy');
                
                % Find indices by using TF and NDX.
                where = find(tf);
                ia = where(ndx);
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
            error(message('MATLAB:SETDIFF:AandBColnumAgree'));
        end
        
        % Handle empty arrays
        if rowsA == 0
            c = zeros(rowsA,colsA);
            ia = [];
        elseif colsA == 0 && rowsA > 0
            c = zeros(1,0);
            ia = rowsA;
            % General handling
        else
            % Remove duplicates from A; get indices only if needed
            if nOut > 1
                [a,ia] = unique(a,flag,'legacy');
            else
                a = unique(a,flag,'legacy');
            end
            
            % Create sorted list of unique A and B; want non-matching entries
            [c,ndx] = sortrows([a;b]);
            [rowsC,colsC] = size(c);
            if rowsC > 1 && colsC ~= 0
                % d indicates the location of non-matching entries
                d = c(1:rowsC-1,:) ~= c(2:rowsC,:);
            else
                d = zeros(rowsC-1,0);
            end
            d = any(d,2);
            d(rowsC,1) = 1;   % Final entry always included.
            
            % d = 1 now for any unmatched entry of A or of B.
            n = size(a,1);
            d = d & ndx <= n; % Now find only the ones in A.
            
            c = c(d,:);
            
            if nOut > 1
                ia = ia(ndx(d));
            end
        end
    end
    
    % Automatically deblank strings
    if ischar(a)
        c = deblank(c);
    end
    
else 
    % Handle objects that cannot be converted to doubles    
    if isempty(flag)
        
        numelA = length(a);
        numelB = length(b);
        
        if numel(a)~=numelA || numel(b)~=numelB
            error(message('MATLAB:SETDIFF:AandBvectorsOrRowsFlag'));
        end
        
        % Handle empty arrays.
        
        if (numelA == 0)
            % Predefine outputs to be of the correct type.
            c = a([]);
            ia = [];
            % Ambiguous if no way to determine whether to return a row or column.
            ambiguous = (rowsA==0 && colsA==0) && ...
                ((rowsB==0 && colsB==0) || numelB == 1);
            if ~ambiguous
                c = reshape(c,0,1);
                ia = reshape(ia,0,1);
            end
        elseif (numelB == 0)
            % If B is empty, invoke UNIQUE to remove duplicates from A.
            if nOut <= 1
                c = unique(a,'legacy');
            else
                [c,ia] = unique(a,'legacy');
            end
            return
            
            % General handling.
            
        else
            
            % Make sure a and b contain unique elements.
            if nOut > 1
                [a,ia] = unique(a(:),'legacy');
            else
                a = unique(a(:),'legacy');
            end
            
            b = unique(b(:),'legacy');
            
            % Find matching entries
            [c,ndx] = sort([a;b]);
            
            % d indicates the location of matching entries
            d = find(c(1:end-1)==c(2:end));
            
            % Remove all matching entries
            ndx([d;d+1]) = [];
            
            d = ndx <= length(a);     % Values in a that don't match.
            
            c = a(ndx(d));
            
            if nOut > 1
                ia = ia(ndx(d));
            end
        end
        
        % If row vector, return as row vector.
        if rowvec
            c = c.';
            if nOut > 1
                ia = ia.';
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
            error(message('MATLAB:SETDIFF:AandBColnumAgree'));
        end
        
        % Handle empty arrays
        if rowsA == 0
            c = zeros(rowsA,colsA);
            ia = [];
        elseif colsA == 0 && rowsA > 0
            c = zeros(1,0);
            ia = rowsA;
            % General handling
        else
            % Remove duplicates from A; get indices only if needed
            if nOut > 1
                [a,ia] = unique(a,flag,'legacy');
            else
                a = unique(a,flag,'legacy');
            end
            
            % Create sorted list of unique A and B; want non-matching entries
            [c,ndx] = sortrows([a;b]);
            [rowsC,colsC] = size(c);
            if rowsC > 1 && colsC ~= 0
                % d indicates the location of non-matching entries
                d = c(1:rowsC-1,:) ~= c(2:rowsC,:);
            else
                d = zeros(rowsC-1,0);
            end
            d = any(d,2);
            d(rowsC,1) = 1;   % Final entry always included.
            
            % d = 1 now for any unmatched entry of A or of B.
            n = size(a,1);
            d = d & ndx <= n; % Now find only the ones in A.
            
            c = c(d,:);
            
            if nOut > 1
                ia = ia(ndx(d));
            end
        end
    end
    
    % Automatically deblank strings
    if ischar(a)
        c = deblank(c);
    end
end
end
