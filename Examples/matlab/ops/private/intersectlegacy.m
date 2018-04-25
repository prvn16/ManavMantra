function [c,ia,ib] = intersectlegacy(a,b,isrows)
% INTERSECTLEGACY 'legacy' flag implementation for intersect.
%   Implements the 'legacy' behavior (prior to R2012a) of INTERSECT.

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
            error(message('MATLAB:INTERSECT:AandBvectorsOrRowsFlag'));
        end
        
        c = reshape([a([]);b([])],0,1);    % Predefined to determine class of output
        ia = zeros(0,1);
        ib = ia;
        
        % Handle empty: no elements.
        
        if (numelA == 0 || numelB == 0)
            
            % Do Nothing
            
        elseif (numelA == 1)
            
            % Scalar A: pass to ISMEMBER to determine if A exists in B.
            [tf,pos] = ismember(a,b,'legacy');
            if tf
                c = a;
                ib = pos;
                ia = 1;
            end
            
        elseif (numelB == 1)
            
            % Scalar B: pass to ISMEMBER to determine if B exists in A.
            [tf,pos] = ismember(b,a,'legacy');
            if tf
                c = b;
                ia = pos;
                ib = 1;
            end
            
        else % General handling.
            
            % Convert to columns.
            a = a(:);
            b = b(:);
            
            % Switch to sort shorter list.
            
            if numelA < numelB
                if nOut > 1
                    [a,ia] = sort(a);           % Return indices only if needed.
                else
                    a = sort(a);
                end
                
                [tf,pos] = ismember(b,a,'legacy');     % TF lists matches at positions POS.
                
                where = zeros(size(a));       % WHERE holds matching indices
                where(pos(tf)) = find(pos);   % from set B, 0 if unmatched.
                tfs = where > 0;              % TFS is logical of WHERE.
                
                % Create intersection list.
                ctemp = a(tfs);
                
                if nOut > 1
                    % Create index vectors if requested.
                    ia = ia(tfs);
                    if nOut > 2
                        ib = where(tfs);
                    end
                end
            else
                if nOut > 1
                    [b,ib] = sort(b);           % Return indices only if needed.
                else
                    b = sort(b);
                end
                
                [tf,pos] = ismember(a,b,'legacy');     % TF lists matches at positions POS.
                
                where = zeros(size(b));       % WHERE holds matching indices
                where(pos(tf)) = find(pos);   % from set B, 0 if unmatched.
                tfs = where > 0;              % TFS is logical of WHERE.
                
                % Create intersection list.
                ctemp = b(tfs);
                
                if nOut > 1
                    % Create index vectors if requested.
                    ia = where(tfs);
                    if nOut > 2
                        ib = ib(tfs);
                    end
                end
            end
            
            if isobject(c)
                c = eval([class(c) '(ctemp)']);
            else
                c = cast(ctemp,class(c));
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
            end
        elseif colsA ~= colsB && ~isempty(a) && ~isempty(b)
            error(message('MATLAB:INTERSECT:AandBColnumAgree'));
        end
        
        % Remove duplicates from A and B.  Only return indices if needed.
        if nOut > 1
            [a,ia] = unique(a,flag,'legacy');
            [b,ib] = unique(b,flag,'legacy');
            [c,ndx] = sortrows([a;b]);
        else
            a = unique(a,flag,'legacy');
            b = unique(b,flag,'legacy');
            c = sortrows([a;b]);
        end
        
        % Find matching entries in sorted rows.
        [rowsC,colsC] = size(c);
        if rowsC > 1 && colsC ~= 0
            % d indicates the location of matching entries
            d = c(1:rowsC-1,:) == c(2:rowsC,:);
        else
            d = zeros(rowsC-1,0);
        end
        
        d = find(all(d,2));
        
        c = c(d,:);         % Intersect is list of matching entries
        
        if nOut > 1
            n = size(a,1);
            ia = ia(ndx(d));      % IA: indices of first matches
            ib = ib(ndx(d+1)-n);  % IB: indices of second matches
        end
        
        % Automatically deblank strings
        if ischar(a) && ischar(b)
            rowsC = size(c,1);
            c = deblank(c);
            c = reshape(c,rowsC,size(c,2));
        end
    end
    
else
    % Handle objects that cannot be converted to doubles
    if isempty(flag)
        
        if length(a)~=numelA || length(b)~=numelB
            error(message('MATLAB:INTERSECT:AandBvectorsOrRowsFlag'));
        end
        
        c = [a([]);b([])];    % Predefined to determine class of output
        
        % Handle empty: no elements.
        
        if (numelA == 0 || numelB == 0)
            % Predefine index outputs to be of the correct type.
            ia = [];
            ib = [];
            % Ambiguous if no way to determine whether to return a row or column.
            ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
                ((size(b,1)==0 && size(b,2)==0) || length(b)==1);
            if ~ambiguous
                c = reshape(c,0,1);
                ia = reshape(ia,0,1);
                ib = reshape(ia,0,1);
            end
            
            % General handling.
            
        else
            
            % Make sure a and b contain unique elements.
            [a,ia] = unique(a(:),'legacy');
            [b,ib] = unique(b(:),'legacy');
            
            % Find matching entries
            [c,ndx] = sort([a;b]);
            d = find(c(1:end-1)==c(2:end));
            ndx = ndx([d;d+1]);
            c = c(d);
            n = length(a);
            
            if nOut > 1
                d = ndx > n;
                ia = ia(ndx(~d));
                ib = ib(ndx(d)-n);
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
            end
        elseif colsA ~= colsB && ~isempty(a) && ~isempty(b)
            error(message('MATLAB:INTERSECT:AandBColnumAgree'));
        end
        
        ia = [];
        ib = [];
        
        % Remove duplicates from A and B.  Only return indices if needed.
        if nOut <= 1
            a = unique(a,flag,'legacy');
            b = unique(b,flag,'legacy');
            c = sortrows([a;b]);
        else
            [a,ia] = unique(a,flag,'legacy');
            [b,ib] = unique(b,flag,'legacy');
            [c,ndx] = sortrows([a;b]);
        end
        
        % Find matching entries in sorted rows.
        [rowsC,colsC] = size(c);
        if rowsC > 1 && colsC ~= 0
            % d indicates the location of matching entries
            d = c(1:rowsC-1,:) == c(2:rowsC,:);
        else
            d = zeros(rowsC-1,0);
        end
        
        d = find(all(d,2));
        
        c = c(d,:);         % Intersect is list of matching entries
        
        if nOut > 1
            n = size(a,1);
            ia = ia(ndx(d));      % IA: indices of first matches
            ib = ib(ndx(d+1)-n);  % IB: indices of second matches
        end
        
        % Automatically deblank strings
        if ischar(a) && ischar(b)
            rowsC = size(c,1);
            c = deblank(c);
            c = reshape(c,rowsC,size(c,2));
        end
    end
end
end
