function varargout = plotpickerfunc(action,fname,inputnames,inputvals)
%PLOTPICKERFUNC  Support function for Plot Picker component.

% Copyright 2009-2017 The MathWorks, Inc.

% Default display functions for MATLAB plots
if strcmp(action,'defaultshow')
    n = length(inputvals);
    toshow = false;
    % A single empty should always return false
    if isempty(inputvals) ||  isempty(inputvals{1})
        varargout{1} = false;
        return
    end
    switch lower(fname)
        % A single matrix or a vector and matrix of compatible size.
        % Either choice with an optional scalar bar width
        case {'bar','barh','bar3','bar3h'} 
            x = inputvals{1};
            if n==1                
                toshow = (isnumeric(x) || islogical(x)) && ~isscalar(x) && ...
                    isBasicMatrix(x) && (isBasicVector(x) || isreal(x));
                
                %bar and barh suport datetimes, duration and categorical
                if strcmp(fname, 'bar') || strcmp(fname, 'barh')
                    toshow = toshow || ((isdatetime(x)  || isduration(x))...
                        && ~isscalar(x) && ismatrix(x) && isvector(x));
                end
                
            elseif n==2 || n==3
                toshow = localAreaArgFcn(inputvals);
                
                %bar and barh suport datetimes, duration and categoricals
                if strcmp(fname, 'bar') || strcmp(fname, 'barh')
                    toshow = toshow || localAreaTimeArgFcn(inputvals);
                    toshow = toshow && ~(isdatetime(inputvals{1}) && isdatetime(inputvals{2}));
                    toshow = toshow && ~(iscategorical(inputvals{1}) && iscategorical(inputvals{2}));
                end
                
                % Check for unique bins if time performance allows 
                if toshow && isBasicVector(x) && length(x)<=1000
                    toshow = min(diff(sort(x(:))))>0;
                end
                if toshow && n==3
                    p = inputvals(3);
                    toshow = isnumeric(p) && isscalar(p);
                end
            end
        case {'barstacked','barhstacked'} 
            % A single matrix or a vector and matrix of compatible size.
            % Either choice with an optional scalar bar width
            x = inputvals{1};
            if n==1                
                toshow = (isnumeric(x) || islogical(x)) && ~isscalar(x) && ...
                    isBasicMatrix(x) && ~isBasicVector(x);
            elseif n==2 || n==3
                toshow = localAreaArgFcn(inputvals);
                if isBasicVector(inputvals{2}) % Stacked should not show for single bar plots
                    toshow = false;
                end
                % Check for unique bins if time performance allows 
                if toshow && isBasicVector(x) && length(x)<=1000
                    toshow = min(diff(sort(x(:))))>0;
                end
                if toshow && n==3
                    p = inputvals(3);
                    toshow = isnumeric(p) && isscalar(p);
                end
            end            
        % A matrix/vector or 2 vectors/matrices of compatible size with an
        % optional linespec
        case 'plot'
            if n==1
                x = inputvals{1};
                if isnumeric(x) || islogical(x)
                     toshow =  ~isscalar(x) && ndims(x)<=2;
                elseif isa(x,'timeseries')
                     toshow =  x.TimeInfo.Length>1;
                elseif isa(x,'fints') || isdatetime(x) || isduration(x) ||...
                        iscategorical(x)
                     toshow = true;
                elseif isa(x, 'Simulink.SimulationData.Dataset')
                    % For Simulink Dataset, we enable plotting of the object if
                    % it is non-empty
                     toshow = x.numElements() > 0;
                elseif isa(x, 'Simulink.SimulationOutput')
                    % For SimulationOutput, we enable plotting if the object is
                    % non-empty
                     toshow = numel(x.who()) > 0;
                end
            elseif n==2
                toshow = localPlotArgFcn(inputvals);  
            elseif n==3
                toshow = localPlotArgFcn(inputvals(1:2));
                toshow = toshow && ischar(inputvals{3});
            end 
         case 'graph'
            if n==1
                x = inputvals{1};
                toshow = isa(x,'graph');
            end
         case 'digraph'
            if n==1
                x = inputvals{1};
                toshow = isa(x,'digraph');
            end
        case 'plot_multiseriesfirst'
            if n>=3
               x = inputvals{1};
               toshow = (isnumeric(x) || isdatetime(x) || isduration(x)) && ~isscalar(x);
                   % cases : d,x1,...xn; x,d1,...,dn; d1,d2,...dn;
                   % case 1: if x = datetime/duration, then xn's should not be
                   % duration/datetime
                   % case 2: if x = numeric, then xn's should either be all
                   % datetime or all duration or all numerics
                   % case 1
                   if (isdatetime(x) || isduration(x))
                       % all the subsequent ones should either be
                       % datetime/duration or numeric
                       % if second is the same type as the first
                       if cellfun('isclass', inputvals(1:2), class(x))
                           % then all the subsequent ones should be same
                           % type
                           if ~all(cellfun('isclass',inputvals(2:end),class(inputvals{2})))
                               toshow = false;
                           end 
                       elseif isnumeric(inputvals{2})
                           % then all the subsequent ones should be numeric
                           if ~all(cellfun('isclass', inputvals(2:end), class(inputvals{2})))
                               toshow = false;
                           end
                       else
                           toshow = false;
                       end
                                               
                   % case 2
                    elseif ~(isduration(x) || isdatetime(x))
                        
                        % if the first one is numeric
                        if isnumeric(x)
                            % if second value is duration/datetime then all
                            % should be duration/datetime
                            if isduration(inputvals{2}) || isdatetime(inputvals{2})
                                if ~all(cellfun('isclass', inputvals(2:end), class(inputvals{2})))
                                    toshow = false;
                                end
                            % if second value is not datetime/duration then none of 
                            % them should be datetime/duration    
                            else
                                if any(cellfun('isclass', inputvals(2:end),'datetime')) || ... 
                                    any(cellfun('isclass', inputvals(2:end),'duration')) 
                                    toshow = false;
                                end
                            end
                        end
                   end
                 
                   % check the dimensions are the same
                   for k=2:length(inputvals) 
                        xn = inputvals{k};
                        if ~((isnumeric(xn) || islogical(xn) || isdatetime(xn) || isduration(xn)) && isvector(xn) && ...
                           length(xn)==length(x))
                           toshow = false;
                           break;
                        end
                   end
                   
            end
        % A matrix/vector or 2 vectors/matrices of compatible size with an
        % optional linespec
        case {'stem','stairs'}
            if n==1
                x = inputvals{1};
                toshow =  (isnumeric(x) || islogical(x)) && ~isscalar(x) && ...
                    ndims(x)<=2 && (isBasicVector(x) || isreal(x));
                toshow = toshow || ((isdatetime(x)  || isduration(x) || iscategorical(x))...
                    && ~isscalar(x) && ndims(x)<=2 && isvector(x));
            elseif n==2
                toshow = localAreaArgFcn(inputvals) || localAreaTimeArgFcn(inputvals);  
                toshow = toshow || localAreaCategoricalArgFcn(inputvals);
                toshow = toshow || (iscategorical(inputvals{1}) && iscategorical(inputvals{2})...
                    && isequal(size(inputvals{1}),size(inputvals{2})));
            elseif n==3
                toshow = localAreaArgFcn(inputvals(1:2)) || localAreaTimeArgFcn(inputvals(1:2));
                toshow = toshow && ischar(inputvals{3});
            end
        case 'plot_multiseries'
            if n>=2
               x = inputvals{1};
               toshow = (isnumeric(x) || isdatetime(x) || isduration(x)) && ~isscalar(x) && isvector(x) && (~isobject(x) || isdatetime(x) || isduration(x));
               for k=2:length(inputvals)
                   xn = inputvals{k};
                   % datetime against duration and vice versa cannot be
                   % plotted
                   if ~((isnumeric(xn) || islogical(xn) || isdatetime(xn) || isduration(xn)) && isvector(xn) &&...
                       (~isobject(x) || isdatetime(x) || isduration(x)) && ...
                           length(xn)==length(x)) 
                       toshow = false;
                       break;
                   end                       
               end
               
               % 2 special cases : 
               % case 1 : show plot if all are datetimes or all are
               % durations
               % case 2 : show plot if there are alternating
               % datetimes/duration objects. These are plotted as pairs
               allTimeObjects = 0; 
               plotPairs = 0;
               
               if toshow && (any(cellfun('isclass',inputvals,'datetime')) || ... 
                   any(cellfun('isclass',inputvals,'duration')))
                   if isdatetime(inputvals{1}) || isduration(inputvals{1}) 
                        allTimeObjects = all(cellfun('isclass', inputvals, class(inputvals{1})));
                   end
                    if ~(allTimeObjects) && n > 2 && mod(length(inputvals),2) == 0
                        plotPairs = localPlotPairs(inputvals);
                    end
                    
                    if allTimeObjects == 0
                        if ~(plotPairs == 1) 
                            toshow = false;
                        end
                    end                 
                end
            end                       
        % A matrix/vector or 2 vectors/matrices of compatible size with an
        % optional base value
        case 'area'
            if n==1
                x = inputvals{1};
                toshow =  (isnumeric(x) || islogical(x)) && ~isscalar(x) && ...
                    ndims(x)<=2 && (isBasicVector(x) || isreal(x));
                toshow = toshow || ((isdatetime(x)  || isduration(x))...
                    && ~isscalar(x) && ndims(x)<=2 && isvector(x));                
            elseif n==2
                toshow = localAreaArgFcn(inputvals) || localAreaTimeArgFcn(inputvals);                  
                toshow = toshow || localAreaCategoricalArgFcn(inputvals);              
                toshow = toshow && ~(isdatetime(inputvals{1}) && isdatetime(inputvals{2}));
                toshow = toshow && ~(iscategorical(inputvals{1}) && iscategorical(inputvals{2}));
            elseif n==3
                toshow = localAreaArgFcn(inputvals(1:2)) || localAreaTimeArgFcn(inputvals(1:2));  
                toshow = toshow || localAreaCategoricalArgFcn(inputvals(1:2));  
                toshow = toshow && ischar(inputvals{3});
            end    
        % A vector/matrix with optional cell array of labels or
        % explosion parameter
        case {'pie','pie3'} 
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ~isscalar(x) && isBasicMatrix(x) && isreal(x) && ...
                    isfloat(x);
                if strcmp(fname, 'pie')
                    toshow = toshow || iscategorical(x);
                end
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isnumeric(x) && ~isscalar(x) && isBasicMatrix(x) && isfloat(x);
                toshow = toshow && ((iscell(y) && isequal(size(y),size(x)) && ...
                    all(cellfun('isclass',y,'char'))) || (isnumeric(y) && isequal(size(y),size(x))));
            end
        % An array with optional scalar or monotonic vector bin parameter
        case 'histogram' 
            if n==1
                x = inputvals{1};
                toshow = (isnumeric(x) && ~isscalar(x) && isreal(x)) || ...
                    islogical(x) && ~isscalar(x) || ...
                    iscategorical(x) || isdatetime(x) || isduration(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};                
                toshow = isnumeric(x) && ~isscalar(x) && isreal(x) && ...
                    isnumeric(y) && isreal(y);
                toshow = toshow && (isscalar(y) || ...
                        (isBasicVector(y) && issorted(y)));
                toshow = toshow || (iscategorical(x) && isvector(y) && ...
                    (iscategorical(y) || (iscell(y) && ...
                    all(cellfun('isclass',y,'char')))));
                toshow = toshow || ((isdatetime(x) || isduration(x)) && ...
                    ((isscalar(y) && isnumeric(y) && isreal(y)) || ...
                    (isequal(class(x),class(y)) && isvector(y) && issorted(y))));
            end
        % Two equally sized matrices and a vector of max size 2  
        case 'histogram2'
            if n == 2 || n == 3
               x = inputvals{1};
               y = inputvals{2};
               toshow = isnumeric(x) && isnumeric(y) && isreal(x) && isreal(y) && isequal(size(x),size(y));             
              if n == 3
                  p = inputvals{3};
                  toshow = toshow && isnumeric(p) && isBasicVector(p) && (numel(p) == 1 || numel(p) == 2);
              end
            end
        % A matrix or 3 vectors/matrices of compatible size with an optional scalar/vector of
        % contour levels or linespec
        case {'contour','contourf','contour3'} 
            if n==1
                x = inputvals{1};
                %Exclude datetime and duration until supported
                toshow = isnumeric(x) && localIsMatrix(x);
            elseif n==2
                x = inputvals{1};
                v = inputvals{2};
                toshow = isnumeric(v) && localIsMatrix(x);
                if isscalar(v)
                    toshow = toshow && isscalar(v) && round(v)==v;
                elseif isBasicVector(v)
                    toshow = toshow && issorted(v);
                elseif ischar(v)
                    toshow = true;
                else
                    toshow = false;
                end              
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                
                % dateteime and duration not supported
                isDateInput = (isdatetime(x) || isduration(x) ||...
                    isdatetime(y) || isduration(y) ||...
                    isdatetime(z) || isduration(z));
                
                if ~isDateInput
                    if localIsMatrix(x)
                        toshow = localIsMatrix(y) && localIsMatrix(z) && ...
                            isequal(size(x),size(z)) && isequal(size(x),size(y));
                    elseif localIsVector(x)
                        toshow = localIsVector(y) && localIsMatrix(z) && ...
                            length(y)==size(z,1) && length(x)==size(z,2);
                    end
                end
                
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                v = inputvals{4};
                toshow = isscalar(v) && isnumeric(v) && round(v)==v; 
                
                % dateteime and duration not supported
                if (isdatetime(x) || isduration(x) ||...
                    isdatetime(y) || isduration(y) ||...
                    isdatetime(z) || isduration(z))
                    toshow = false;
                end 
                
                if toshow
                    if localIsMatrix(x) 
                        toshow = localIsMatrix(y) && localIsMatrix(z) && ...
                            isequal(size(x),size(z)) && isequal(size(x),size(y));
                    elseif localIsVector(x)
                        toshow = localIsVector(y) && localIsMatrix(z) && ...
                            length(y)==size(z,1) && length(x)==size(z,2);
                    end
                end                 
            end
        % 1 to 4 x,y,z, and color matrices of compatible size. x and y 
        % matrices may optionally replaced by compatible vectors.
        case {'surf','mesh','surfc','meshc','meshz','waterfall'}
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && localIsMatrix(x);
                
                % datetime and duration only supported in surf and mesh
                if strcmp(fname, 'surf') || strcmp(fname, 'mesh')
                    toshow = toshow || (isdatetime(x) || isduration(x) || ...
                        iscategorical(x)) && ismatrix(x) && ~isvector(x);
                end
                
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isnumeric(x) && isnumeric(y) && isBasicMatrix(x)...
                    && min(size(x))>1 && isequal(size(x),size(y));
                % datetime and duration only supported in surf and mesh
                if strcmp(fname, 'surf') || strcmp(fname, 'mesh')
                    toshow = toshow || (isdatetime(x) || isduration(x) ||...
                        iscategorical(x))&& ismatrix(x) && isnumeric(y) &&...
                        min(size(x))>1 && isequal(size(x),size(y));
                end                
            elseif n==3 || n==4
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                toshow = isnumeric(x) && isnumeric(y) && isnumeric(z);
                
                hasDatetimeArg = false;
                
                % datetime and duration only supported in surf and mesh
                if strcmp(fname, 'surf') || strcmp(fname, 'mesh')
                    toshow = (isnumeric(x) || isdatetime(x) || isduration(x) || iscategorical(x))...
                        && (isnumeric(y) || isdatetime(y) || isduration(y) || iscategorical(y))...
                        && (isnumeric(z) || isdatetime(z) || isduration(z) || iscategorical(z));
                    % At least one of my arguments is a datetime or duration
                    hasDatetimeArg = toshow;
                end
                
                % If one of my arguments is a datetime or duration, do not
                % use the local isBasicMatrix functions as they always
                % return false for datetime/duration objects
                if hasDatetimeArg
                    if toshow
                        toshow = (ismatrix(x) && min(size(x))>1 && isequal(size(x),size(y)) && isequal(size(x),size(z))) || ...
                            (ismatrix(z) && isvector(x) && isvector(y) && length(x)==size(z,2) && length(y)==size(z,1));
                    end
                else
                    if toshow
                        toshow = (isBasicMatrix(x) && min(size(x))>1 && isequal(size(x),size(y)) && isequal(size(x),size(z))) || ...
                            (isBasicMatrix(z) && isBasicVector(x) && isBasicVector(y) && length(x)==size(z,2) && length(y)==size(z,1));
                    end
                end
                if n==4 && toshow
                    c = inputvals{4};
                    toshow = isnumeric(c) && isequal(size(z),size(x));
                end
                
            end
        % A matrix, 2 vectors and a matrix, or 3 matrices of compatible
        % size. The number of rows and columns of matrix inputs must be >=3.
        case 'surfl'
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && localIsMatrix(x) && min(size(x))>=3;
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                toshow = isnumeric(x) && isnumeric(y) && isnumeric(z) && min(size(z))>=3;
                if toshow
                   toshow = (isBasicMatrix(x) && min(size(x))>1 && isequal(size(x),size(y)) && isequal(size(x),size(z))) || ...
                     (isBasicMatrix(z) && isBasicVector(x) && isBasicVector(y) && length(x)==size(z,2) && length(y)==size(z,1));
                end
            end
        % 4 vectors of the same length
        case 'plotyy' 
            if n==4
                % If the first parameter pair and the second parameter pair
                % are both compatible with a regular plot, they should be
                % compatible with plotyy
                toshow = localPlotArgFcn(inputvals(1:2)) &&...
                    localPlotArgFcn(inputvals(3:4));
            end
        % A vector/matrix or 2 vectors/matrices of the compatible size with
        % an optional linespec parameter
        case {'semilogx','semilogy','loglog'} 
            if n==1
                x = inputvals{1};
                toshow = (isnumeric(x) || islogical(x)) && ~isscalar(x) && isBasicMatrix(x);
                
                % datetime and duration only supported in semilogx and
                % semilogy
                if strcmp(fname, 'semilogx') 
                    toshow = toshow || (isdatetime(x) || isduration(x) || iscategorical(x))...
                        && ~isscalar(x) && ismatrix(x);
                end
                
                 if strcmp(fname, 'semilogy')
                    toshow = toshow || (isdatetime(x) || isduration(x))...
                        && ~isscalar(x) && ismatrix(x);                     
                 end
                
            elseif n==2
                toshow = localAreaArgFcn(inputvals);
                % datetime and duration only supported in semilogx and
                % semilogy
                if strcmp(fname, 'semilogx') || strcmp(fname, 'semilogy')
                    toshow = toshow || localAreaTimeArgFcn(inputvals) || ...
                        iscategorical(inputvals{1}) || iscategorical(inputvals{2});
                    
                    if toshow && strcmp(fname, 'semilogx')
                        toshow = toshow && isnumeric(inputvals{1});
                    end
                    
                    if toshow && strcmp(fname, 'semilogy')
                        toshow = toshow && isnumeric(inputvals{2});
                    end
                end
            elseif n==3
                toshow = localAreaArgFcn(inputvals(1:2));
                % datetime and duration only supported in semilogx and
                % semilogy
                if strcmp(fname, 'semilogx') || strcmp(fname, 'semilogy')
                    toshow = toshow || localAreaTimeArgFcn(inputvals(1:2));
                    if toshow && strcmp(fname, 'semilogx')
                        toshow = toshow && isnumeric(inputvals{1});
                    end
                    
                    if toshow && strcmp(fname, 'semilogy')
                        toshow = toshow && isnumeric(inputvals{2});
                    end
                end
                toshow = toshow && ischar(inputvals{3});
            end
        case {'errorbar','errorbarhorz'} %Between 2, 3, 4, or 6 vectors of the same size
            if n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isBasicMatrix(x) && isnumeric(x) && ...
                    ~isscalar(x) && isBasicMatrix(y) && (isnumeric(y) || islogical(y)) && ...
                    all(size(x)==size(y));
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                l = inputvals{3};
                toshow = isBasicMatrix(x) && isnumeric(x) && ~isscalar(x) && ...
                    isBasicMatrix(y) && (isnumeric(y) || islogical(y)) && all(size(x)==size(y));
                toshow = toshow && isBasicMatrix(l) && (isnumeric(l) || islogical(l)) && ...
                    all(size(x)==size(l));
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                l = inputvals{3};
                u = inputvals{4};
                toshow = isBasicMatrix(x) && isnumeric(x) && ~isscalar(x) && isBasicMatrix(y) && ...
                    (isnumeric(y) || islogical(y)) && all(size(x)==size(y));
                toshow = toshow && isBasicMatrix(l) && (isnumeric(l) || islogical(l)) && ...
                    all(size(x)==size(l));
                toshow = toshow && isBasicMatrix(u) && (isnumeric(u) || islogical(u)) && ...
                    all(size(x)==size(u));
            elseif n==6 && strcmpi(fname, 'errorbar') % 6 only allowed for vertical
                x = inputvals{1};
                y = inputvals{2};
                yneg = inputvals{3};
                ypos = inputvals{4};
                xneg = inputvals{5};
                xpos = inputvals{6};
                toshow = isBasicMatrix(x) && isnumeric(x) && ~isscalar(x) && isBasicMatrix(y) && ...
                    (isnumeric(y) || islogical(y)) && all(size(x)==size(y));
                toshow = toshow && isBasicMatrix(yneg) && (isnumeric(yneg) || islogical(yneg)) && ...
                    all(size(x)==size(yneg));
                toshow = toshow && isBasicMatrix(ypos) && (isnumeric(ypos) || islogical(ypos)) && ...
                    all(size(x)==size(ypos));
                toshow = toshow && isBasicMatrix(xneg) && (isnumeric(xneg) || islogical(xneg)) && ...
                    all(size(x)==size(xneg));
                toshow = toshow && isBasicMatrix(xpos) && (isnumeric(xpos) || islogical(xpos)) && ...
                    all(size(x)==size(xpos));
            end
        case {'plot3','stem3'} %3 vectors or matrices of compatible size with an optional 4th linespec
            if n==3
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                allVectors = localIsVector(x) && localIsVector(y) && localIsVector(z) && ...
                    length(x)==length(y) && length(x)==length(z);
                allMatrices = localIsMatrix(x) && localIsMatrix(y) && localIsMatrix(z) && ...
                    isequal(size(x),size(y)) && isequal(size(x),size(z));                
                toshow = allVectors || allMatrices;
                % dateteime and duration only supported in plot3
                if strcmp(fname, 'stem3') && (isdatetime(x) || isduration(x) ||...
                        iscategorical(x) || isdatetime(y) || isduration(y) || iscategorical(y)...
                        || isdatetime(z) || isduration(z) || iscategorical(z))
                    toshow = false;
                end
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                c = inputvals{4};
                allVectors = localIsVector(x) && localIsVector(y) && localIsVector(z) && ...
                    length(x)==length(y) && length(x)==length(z);
                allMatrices = localIsMatrix(x) && localIsMatrix(y) && localIsMatrix(z) && ...
                    isequal(size(x),size(y)) && isequal(size(x),size(z));
                toshow = (allVectors || allMatrices) && ischar(c);
                % dateteime and duration only supported in plot3
                if strcmp(fname, 'stem3') && (isdatetime(x) || isduration(x) ||...
                        iscategorical(x) || isdatetime(y) || isduration(y) || iscategorical(y)...
                        || isdatetime(z) || isduration(z) || iscategorical(z))
                    toshow = false;
                end
            end
        case 'comet' %1 or 2 vectors of the same size with optional additional tail length
            if n==1
                x = inputvals{1};
                toshow = isBasicVector(x) && (isnumeric(x) || islogical(x)) && ...
                    ~isscalar(x) && isreal(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isBasicVector(x) && isnumeric(x) && ~isscalar(x) ;
                toshow = toshow && (isBasicVector(y) || islogical(y)) && isnumeric(y)  && length(x)==length(y);
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                p = inputvals{3};
                toshow =isBasicVector(x) && isnumeric(x) && ~isscalar(x) ;
                toshow = toshow && isBasicVector(y) && (isnumeric(y) || islogical(y)) && ...
                    length(x)==length(y);
                toshow = toshow && isnumeric(p) && isscalar(p);
            end
        case 'pareto' %A vector and a cell array of labels or 2 vectors of the same size
            if n==1
                x = inputvals{1};
                toshow = isBasicVector(x) && isnumeric(x) && ~isscalar(x) && isfloat(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isBasicVector(x) && isnumeric(x) && ~isscalar(x) && isfloat(x) && ...
                    isfloat(y);
                toshow = toshow && ((isnumeric(y) && isBasicVector(y) && length(x)==length(y)) || ...
                    (iscell(y) && length(y)==length(x) && all(cellfun('isclass',y,'char'))));
            end
        % 1 or 2 matrices with the same number of rows either with an
        % optional linespec
        case 'plotmatrix' 
            if n==1
                x = inputvals{1};
                toshow = (isnumeric(x) || islogical(x)) && isBasicMatrix(x) && ...
                    min(size(x))>=2 && isreal(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = (isnumeric(x) || islogical(x)) && (ischar(y) || ...
                    (size(x,1)==size(y,1) && size(x,1)>1 && ...
                    size(x,2)>1 && size(y,2)>1 && isBasicMatrix(x) && isBasicMatrix(y))) && ...
                    isreal(x) && isreal(y);
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                l = inputvals{3};
                toshow = (isnumeric(x) || islogical(x)) && ischar(l) && ...
                    size(x,1)==size(y,1) && size(x,1)>1 && ...
                    size(x,2)>1 && size(y,2)>1 && isBasicMatrix(x) && isBasicMatrix(y) && ...
                    isreal(x) && isreal(y);
            end   
        case 'scatter' %A 2-column matrix or 2 vectors of the same size with an optional area parameter or linespec
            if n==1
                x = inputvals{1};
                toshow = (isnumeric(x) || islogical(x)) && ~isscalar(x) && size(x,1)>1 && ...
                    size(x,2)==2;
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                xnumeric = isnumeric(x) || islogical(x) || iscategorical(x);
                ynumeric = isnumeric(y) || islogical(y) || iscategorical(y);
                toshow = isBasicVector(x) && xnumeric && ~isscalar(x) && ...
                    ((ynumeric && isBasicVector(y) && length(x)==length(y)) || ischar(y));
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                s = inputvals{3};
                xnumeric = isnumeric(x) || islogical(x) || iscategorical(x);
                ynumeric = isnumeric(y) || islogical(y) || iscategorical(y);
                toshow = isBasicVector(x) && xnumeric && ~isscalar(x) && ...
                    ynumeric && isBasicVector(y) && length(x)==length(y);
                toshow = toshow && (ischar(s) || (isnumeric(s) && ...
                    (isscalar(s) || (isBasicVector(s) && all(s>0) && length(s)==length(x)))));
            end
        %3 vectors of the same size with an optional area parameter or linespec       
        case 'scatter3' 
            if n==3
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                xnumeric = isnumeric(x) || islogical(x) || iscategorical(x);
                ynumeric = isnumeric(y) || islogical(y) || iscategorical(y);
                znumeric = isnumeric(z) || islogical(z) || iscategorical(z);
                toshow = isBasicVector(x) && xnumeric && ~isscalar(x) && isBasicVector(y) && ...
                    ynumeric && ~isscalar(y) && isBasicVector(z) && znumeric && ...
                    ~isscalar(z) && length(x)==length(y) && length(y)==length(z);
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                s = inputvals{4};
                xnumeric = isnumeric(x) || islogical(x) || iscategorical(x);
                ynumeric = isnumeric(y) || islogical(y) || iscategorical(y);
                znumeric = isnumeric(z) || islogical(z) || iscategorical(z);
                toshow = isBasicVector(x) && xnumeric && ~isscalar(x) && isBasicVector(y) && ...
                    ynumeric && ~isscalar(y) && isBasicVector(z) && znumeric && ...
                    ~isscalar(z) && length(x)==length(y) && length(y)==length(z);               
                toshow = toshow && (ischar(s) || (isnumeric(s) && isscalar(s)));
            end
     
        % 1 vector or matrix with optional scalar/string marker size and linespec arguments       
        case 'spy' 
            if n==1
                s = inputvals{1};
                toshow = (isnumeric(s) || islogical(s)) && ~isscalar(s) && isBasicMatrix(s);
            elseif n==2
                s = inputvals{1};
                l = inputvals{2};
                toshow = (isnumeric(s) || islogical(s)) && ~isscalar(s) && isBasicMatrix(s);
                toshow = toshow && (ischar(l) || (isnumeric(l) && isscalar(l)));
            elseif n==3
                s = inputvals{1};
                l = inputvals{2};
                m = inputvals{3};
                toshow = (isnumeric(s) || islogical(s)) && ~isscalar(s) && isBasicMatrix(s);
                toshow = toshow && (ischar(l) || (isnumeric(l) && isscalar(l)));
                toshow = toshow && (ischar(m) || (isnumeric(m) && isscalar(m)));
            end
        case 'rose' %1 or 2 vectors of the same size
            if n==1
                x = inputvals{1};
                toshow = isBasicVector(x) && (isnumeric(x) || islogical(x)) && ...
                    ~isscalar(x) && isreal(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isBasicVector(x) && (isnumeric(x) || islogical(x)) && ~isscalar(x);
                toshow = toshow && isBasicVector(y) && isnumeric(y) && length(x)==length(y);
            end
        case 'polar' %2 vectors or matrices of the same size with optional linepsec string
            if n==1
                rho = inputvals{1};
                toshow = ndims(rho)<=2 && isnumeric(rho)  && ~isscalar(rho);
            elseif n==2 || n==3
                theta = inputvals{1};
                rho = inputvals{2};
                toshow = ndims(theta)<=2 && isnumeric(theta) && ~isscalar(theta) && ...
                    isnumeric(rho) && isequal(size(theta),size(rho));
                if toshow && n==3
                    toshow = ischar(inputvals{3});
                end
            end 
        case 'compass' %1 or 2 vectors or matrixes of compatible size with optional linepsec string
            if n==1
                u = inputvals{1};
                toshow = (isnumeric(u) || islogical(u)) && ~isscalar(u) && ...
                    isBasicMatrix(u) && isfloat(u);
            elseif n==2
                u = inputvals{1};
                v = inputvals{2};
                toshow = isnumeric(u) && ~isscalar(u) && isBasicMatrix(u) && isfloat(u) && ...
                    isfloat(v);
                toshow = toshow && (isnumeric(v) || islogical(v)) && ...
                    ((isBasicVector(u) && isBasicVector(v) && length(u)==length(v)) || ...
                    isequal(size(u),size(v)));
            elseif n==3
                u = inputvals{1};
                v = inputvals{2};
                s = inputvals{3};
                toshow = isnumeric(u) && ~isscalar(u) && isBasicMatrix(u) && isfloat(u) && ...
                    isfloat(v);
                toshow = toshow && (isnumeric(v) || islogical(v)) && ...
                    ((isBasicVector(u) && isBasicVector(v) && length(u)==length(v)) || ...
                    isequal(size(u),size(v)));
                toshow = toshow && ischar(s);
            end
        case 'geobubble'
            if n == 2
                % geobubble(lat, lon)
                lat = inputvals{1};
                lon = inputvals{2};
                toshow = isGeoCoordinates(lat, lon);
            elseif n == 3
                if isa(inputvals{1}, 'tabular')
                    % When 'geobubble' is called with a table as the
                    % first input argument, the next two arguments are
                    % required and must be subscripts into the table.
                    % The subscripts can be in the form of strings,
                    % character vectors, cellstrs, numeric, logical,
                    % or one of the table subscript objects. That
                    % checking is being done by
                    % isScalarTableSubscript.
                    %
                    % geobubble(tbl, latvar, lonvar)
                    
                    tbl = inputvals{1};
                    latvar = inputvals{2};
                    lonvar = inputvals{3};
                    if isScalarTableSubscript(tbl, latvar) && ...
                            isScalarTableSubscript(tbl, lonvar)
                        % geobubble(tbl, latvar, lonvar)
                        toshow = true;
                    else
                        % One of the input arguments is not a valid table
                        % subscript, or refers to more than one column in
                        % the table.
                        toshow = false;
                    end
                else
                    % geobubble(lat, lon, sizedata)
                    lat = inputvals{1};
                    lon = inputvals{2};
                    s = inputvals{3};
                    if isGeoCoordinates(lat, lon)
                        toshow = isnumeric(s) && length(s) == length(lat);
                    else
                        toshow = false;
                    end
                end
            elseif n == 4
                % geobubble(lat, lon, sizedata, colordata)
                lat = inputvals{1};
                lon = inputvals{2};
                s = inputvals{3};
                c = inputvals{4};
                if isGeoCoordinates(lat, lon)
                    toshow = isnumeric(s) && length(s) == length(lat);
                    toshow = toshow && iscategorical(c) && ...
                        length(c) == length(lat);
                else
                    toshow = false;
                end
            end
        case {'image','imagesc'} %1 color array or 2 vectors and an color array of compatible size
            if n==1
                x = inputvals{1};
                if (isnumeric(x) || islogical(x)) && min(size(x))>1
                    if isBasicMatrix(x)
                        toshow = true;
                    elseif ndims(x)==3 && size(x,3)==3
                        if isfloat(x)
                            toshow = (max(x(:))<=1 && min(x(:))>=0);
                        elseif isinteger(x)
                            toshow =  isa(x,'uint8') || isa(x,'uint16');
                        end
                    else
                        toshow = false;
                    end
                end
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                C = inputvals{3};
                if isBasicVector(x) && isnumeric(x) && isBasicVector(y) && ...
                       isnumeric(y) && (isnumeric(C) || islogical(C))
                    if isBasicMatrix(C)
                        toshow = true;
                    elseif ndims(C)==3 && size(C,3)==3
                        if isfloat(C)
                            toshow = (max(C(:))<=1 && min(C(:))>=0);
                        elseif isinteger(x)
                            toshow =  isa(C,'uint8') || isa(C,'uint16');
                        end
                    else
                        toshow = false;
                    end
                end
            end
        case 'pcolor' %1 color array or 2 vectors and an color array of compatible size
            if n==1
                x = inputvals{1};
                if isnumeric(x)  && min(size(x))>1
                    if isBasicMatrix(x)
                        toshow = true;
                    elseif ndims(x)==3 && size(x,3)==3
                        toshow = max(x(:))<=1 && min(x(:))>=0;
                    else
                        toshow = false;
                    end
                end
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                C = inputvals{3};
                if isBasicVector(x) && isnumeric(x) && isBasicVector(y) && ...
                       isnumeric(y) && isnumeric(C)
                    if isBasicMatrix(C) && size(C,1)==length(y) && size(C,2)==length(x)
                        toshow = true;
                    elseif ndims(C)==3 && size(C,3)==3
                        toshow = max(C(:))<=1 && min(C(:))>=0;
                    else
                        toshow = false;
                    end
                end
            end
        case 'heatmap'
            if (n == 3 || n == 4) && isa(inputvals{1}, 'tabular')
                % When 'heatmap' is called with a table as the first input
                % argument, the next two arguments are required and must be
                % subscripts into the table. The subscripts can be in the
                % form of strings, character vectors, cellstrs, numeric,
                % logical, or one of the table subscript objects. That
                % checking is being done by isScalarTableSubscript.
                %
                % Valid syntaxes:
                % table + 2 subscripts: heatmap(tbl, xvar, yvar)
                % table + 3 subscripts: heatmap(tbl, xvar, yvar, 'ColorVariable', cvar)
                
                tbl = inputvals{1};
                xvar = inputvals{2};
                yvar = inputvals{3};
                if isScalarTableSubscript(tbl, xvar) && isScalarTableSubscript(tbl, yvar)
                    % Check if the 4th input is a valid ColorVariable.
                    if n == 4
                        % heatmap(tbl, xvar, yvar, 'ColorVariable', cvar)
                        toshow = isScalarTableSubscript(tbl, inputvals{4});
                    else
                        % heatmap(tbl, xvar, yvar)
                        toshow = true;
                    end
                else
                    % One of the input arguments is not a valid table
                    % subscript, or refers to more than one column in the
                    % table.
                    toshow = false;
                end
            elseif n == 1 && isnumeric(inputvals{1}) && ismatrix(inputvals{1}) && ~isvector(inputvals{1})
                % heatmap(cdata)
                toshow = true;
            elseif n == 3 && isnumeric(inputvals{3}) && ismatrix(inputvals{3})
                % heatmap(xdata, ydata, cdata)
                xdata = inputvals{1};
                ydata = inputvals{2};
                cdata = inputvals{3};
                
                % XData can be numeric, string, cellstr, or categorical.
                toshow = isstring(xdata) || iscellstr(xdata) || isnumeric(xdata) || iscategorical(xdata);
                
                % YData can be numeric, string, cellstr, or categorical.
                toshow = toshow && (isstring(ydata) || iscellstr(ydata) || isnumeric(ydata) || iscategorical(ydata));
            
                % The size of XData/YData must match the ColorData.
                toshow = toshow && numel(xdata) == size(cdata,2) && numel(ydata) == size(cdata,1);
            else
                toshow = false;
            end

       case 'imshow'
            
            if n == 1 || n == 2
                
                I = inputvals{1};
                
                % a filename is a string containing a '.'.  We put this
                % check in first so that we can bail out on non-filename
                % strings before calling EXIST which will hit the file
                % system.
                isStringContainingDot = ischar(I) && numel(I) > 2 && ...
                    ~isempty(strfind(I(2:end-1),'.'));
                
                isfile = false;
                if isStringContainingDot

                    dotLoc = strfind(I,'.');
                    fileExt = I( (dotLoc+1) : end);
                    
                    [~,extNames] = iptui.parseImageFormats;
                    
                    % Check to see whether file extention matches any of
                    % the valid IPT file extentions
                    isValidExtention = false;
                    for i = 1:length(extNames)
                        if any(strcmp(fileExt,extNames{i}))
                            isValidExtention = true;
                            break;
                        end
                    end
                    
                    % If string is filename with a valid image file
                    % extention, do final most exensive operation of
                    % hitting filesystem to see whether this file exists.
                    if isValidExtention
                        isfile = exist(which(I),'file');
                    end
                end
                          
                is2d = ndims(I) == 2; %#ok<*ISMAT>
                is3d = ndims(I) == 3;
                isntVector = min(size(I)) > 1;
                
                % define image types
                isgrayscale = ~isfile && isnumeric(I) && is2d && isntVector;
                isindexed = isgrayscale && isinteger(I);
                istruecolor = ~isfile && isnumeric(I) && is3d && ...
                    isntVector && size(I,3) == 3;
                isbinary = ~isfile && islogical(I) && is2d && isntVector;
                
                toshow = isfile || isgrayscale || isindexed || ...
                    istruecolor || isbinary;
                
                % if 2 variables are selected...
                if toshow && n == 2
                    
                    arg2 = inputvals{2};
                    
                    iscolormap = ndims(arg2) == 2 && size(arg2,2) == 3 && ...
                        all(arg2(:) >= 0 & arg2(:) <= 1);
                    isdisplayrange = isnumeric(arg2) && isvector(arg2) && ...
                        length(arg2) == 2 && arg2(2) > arg2(1);
                    
                    if isindexed && iscolormap
                        % imshow(X,map)
                        toshow = true;
                        
                    elseif isgrayscale && isdisplayrange
                        % imshow(I,[low high])
                        toshow = true;
                        
                    else
                        toshow = false;
                        
                    end
                    
                end
                
            end
        case 'ribbon' %1 matrix with 2 matrices or vectors of the same size with an optional scalar width parameter
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && isBasicMatrix(x) && size(x,1)>1 && size(x,2)>1;
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                if isnumeric(y) && isscalar(y)
                    toshow = isnumeric(x) && isBasicMatrix(x) && size(x,1)>1 && size(x,2)>1;
                else
                    toshow = isnumeric(x) && isnumeric(y) && ...
                        ((isBasicVector(x) && isBasicVector(y) && length(x)==length(y)) || ...
                        isequal(size(x),size(y)));
                end
            end
        case 'ezplot' % A function handle with an optional range of x values  
            if n==1
                fcn = inputvals{1};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==1;
            elseif n==2
                fcn = inputvals{1};
                x = inputvals{2};
                toshow = isa(fcn,'function_handle') && isnumeric(x) && isBasicVector(x) && ...
                    nargin(fcn)==1;
            end
        case 'ezplot3' % 3 parametric function handles with an optional domain range vector
            if n==3
               fcnx = inputvals{1};
               fcny = inputvals{2};
               fcnz = inputvals{3};
               toshow = isa(fcnx,'function_handle') && isa(fcny,'function_handle') && ...
                   isa(fcnz,'function_handle') && nargin(fcnx)==1 && nargin(fcny)==1 && ...
                   nargin(fcnz)==1;
            elseif n==4
               fcnx = inputvals{1};
               fcny = inputvals{2};
               fcnz = inputvals{3};
               range = inputvals{4};
               toshow = isa(fcnx,'function_handle') && isa(fcny,'function_handle') && ...
                   isa(fcnz,'function_handle') && nargin(fcnx)==1 && nargin(fcny)==1 && ...
                   nargin(fcnz)==1; 
               toshow = toshow && isnumeric(range) && isBasicVector(range) && ...
                   length(range)==2 && range(2)>range(1);
            end
        case 'ezpolar' % A function handle with an optional range of theta values  
            if n==1
                fcn = inputvals{1};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==1;
            elseif n==2
                fcn = inputvals{1};
                theta = inputvals{2};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==1 && ...
                    isnumeric(theta) && isBasicVector(theta) && ...
                    length(theta)==2 && theta(2)>theta(1);
            end
        case {'ezcontour','ezcontourf'} % A 2-input function handle with an optional integer grid parameter or a 2 or 4 element domain vector
             if n==1
                fcn = inputvals{1};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==2;
             elseif n==2
                fcn = inputvals{1};
                domain = inputvals{2};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==2 && ...
                    isnumeric(domain) && (isequal(size(domain),[2 1]) ||  ...
                    isequal(size(domain),[4 1]) || (isBasicMatrix(domain) && ...
                    size(domain,1)==size(domain,2)));
             end
        case {'ezsurf','ezsurfc','ezmesh','ezmeshc'} % A 2-input function handle or 3 2-input function handles with an optional 2 or 4 element domain vector
             if n==1
                fcn = inputvals{1};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==2;
             elseif n==2
                fcn = inputvals{1};
                domain = inputvals{2};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==2 && ...
                    isnumeric(domain) && (isequal(size(domain),[2 1]) ||  ...
                    isequal(size(domain),[4 1]));
             elseif n==3
               fcnx = inputvals{1};
               fcny = inputvals{2};
               fcnz = inputvals{3};
               toshow = isa(fcnx,'function_handle') && isa(fcny,'function_handle') && ...
                   isa(fcnz,'function_handle') && nargin(fcnx)==2 && nargin(fcny)==2 && ...
                   nargin(fcnz)==2; 
             end
        case 'slice' % 3 dimensional array with 3 vectors defining slice planes
            if n==4
                V = inputvals{1};
                sx = inputvals{2};
                sy = inputvals{3};
                sz = inputvals{4};
                toshow = isnumeric(V) && ndims(V)==3 && isnumeric(sx) && ...
                    isBasicVector(sx) && isnumeric(sy) && isBasicVector(sy) && ...
                    isnumeric(sz) && isBasicVector(sz);
            end
        case 'feather' % A numeric array or 2 numeric arrays of the same size
             if n==1
                Z = inputvals{1};
                toshow = (isnumeric(Z) || islogical(Z)) && ~isscalar(Z) && isfloat(Z);
             elseif n==2;
                U = inputvals{1};
                V = inputvals{2};
                toshow = (isnumeric(U) || islogical(U)) && (isnumeric(V) || islogical(V)) && ...
                    ~isscalar(U) && isfloat(U) && isfloat(V) && isequal(size(U),size(V));
             end
        case 'quiver' % 2 or 4 numeric arrays of the same size
            if n==2;
                u = inputvals{1};
                v = inputvals{2};
                toshow = (isnumeric(u) || islogical(u)) && ~isscalar(u) && ...
                    (isnumeric(v) || islogical(v)) && isequal(size(u),size(v));
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                u = inputvals{3};
                v = inputvals{4};
                numericx = (isnumeric(x) || islogical(x));
                numericy = (isnumeric(y) || islogical(y));
                numericu = (isnumeric(u) || islogical(u));
                numericv = (isnumeric(v) || islogical(v));
                toshow = numericu && ~isscalar(u) && numericv && ...
                    numericx && numericy && isequal(size(u),size(v)) && ...
                    isequal(size(x),size(u)) && isequal(size(y),size(u));
            end
        case 'quiver3' % 4 numeric arrays of the same size
           if n==4
                z = inputvals{1};
                u = inputvals{2};
                v = inputvals{3};
                w = inputvals{4};
                numericz = (isnumeric(z) || islogical(z));
                numericu = (isnumeric(u) || islogical(u));
                numericv = (isnumeric(v) || islogical(v));
                numericw = (isnumeric(w) || islogical(w));
                toshow = numericz && ~isscalar(z) && numericu && ...
                    numericv && numericw && isequal(size(z),size(u)) && ...
                    isequal(size(z),size(v)) && isequal(size(z),size(w));
           end
        case 'streamslice' % Either 2 or 4 3-dimensional arrays of the same size
            if n==2;
                u = inputvals{1};
                v = inputvals{2};
                toshow = (isnumeric(u) || islogical(u))  && ~isscalar(u) && ...
                    (isnumeric(v) || islogical(v)) && ndims(u)==3 && ...
                    isequal(size(u),size(v));
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                u = inputvals{3};
                v = inputvals{4};
                toshow = (isnumeric(u) || islogical(u)) && ~isscalar(u) && ...
                    (isnumeric(v) || islogical(v)) && ...
                    isnumeric(x) && isnumeric(y) && ndims(x)==3 && isequal(size(u),size(v)) && ...
                    isequal(size(x),size(u)) && isequal(size(y),size(u));
            end    
        case 'streamline' 
            % Cell array of double vertex arrays produced by stream2 or stream3
            % Necessary condition is that the cell array is a vector
            % containing 2 or 3 column matrices of vertices.
            if n==1 && ~isempty(inputvals{1}) && iscell(inputvals{1}) && isBasicVector(inputvals{1}) && ...
                    all(cellfun('ndims',inputvals{1})==2) && all(cellfun('isclass',inputvals{1},'double'))
                  colCount = cellfun('size',inputvals{1},2);
                  toshow = all(colCount>=2 & colCount<=3);
            end
        case 'wordcloud'
            % Wordcloud accepts inputs of type categorical, cellstr, string
            % char and the wordcoutner type as single inputs. The same are
            % accepted as the first argument when provided 2 inputs 
            % but at least one input is a size array of doubles of the same
            % length as the first array. The combination of wordlist object
            % and size array also works when 2 inputs provided
             if n==1
                inputs = inputvals{1};
                
                toshow = (iscategorical(inputs) || iscellstr(inputs) || ...
                    isstring(inputs)) || ischar(inputs) || ...
                    isa(inputs, 'wordCounter');
             elseif n==2
                 words = inputvals{1};
                 sizes = inputvals{2};
                 
                 toshow = isvector(words) && isvector(sizes) && ...
                     length(words) == length(sizes) && ...
                     isnumeric(sizes) && ...
                     (iscategorical(words) || isstring(words) ||...
                     iscellstr(words));
                 
                 if isa(words, 'wordCounter')
                     toshow = isvector(sizes) && isnumeric(sizes) && ...
                         (length(words.Vocabulary) == length(sizes));
                 end
             end            
    end
    varargout{1} = toshow;
% Default execution strings for MATLAB plots
elseif strcmp(action,'defaultdisplay') 
    n = length(inputnames);
    appendedInputs = repmat({','},1,2*n-1);
    appendedInputs(1:2:end) = inputnames;
    inputStr = cat(2,appendedInputs{:});  
    
    dispStr = '';
    holdStr = 'hold on;';

    switch lower(fname)
        case {'plot','semilogx','semilogy','loglog','stem',...
                'stairs'}
            if (n==1 && (isBasicVector(inputvals{1}) || isa(inputvals{1},'timeseries') || ...
                    isa(inputvals{1},'fints') || isdatetime(inputvals{1})  )) || ... 
                    (n>=2 && isvector(inputvals{2})) || isa(inputvals{1}, 'Simulink.SimulationData.Dataset') 
                dispStr =  [lower(fname) '(' inputStr ')'];              
            elseif isa(inputvals{1}, 'Simulink.SimulationOutput')
                % Plot the SimulationOutput object in the sdi viewer
                dispStr = ['Simulink.sdi.openVariable('''  inputStr ''', ' inputStr ')'];
            else
                dispStr =  [lower(fname) '(' inputStr ',''DisplayName'',''' ...
                  inputnames{n} ''')']; 
            end
        case {'area','bar','barh'}
            if (n==1 && (isBasicVector(inputvals{1}) || isa(inputvals{1},'timeseries') || ...
                    isa(inputvals{1},'fints') || isdatetime(inputvals{1})))
                dispStr =  [lower(fname) '(' inputStr ')'];
            elseif (n==2 && (isvector(inputvals{2}) && isdatetime(inputvals{2}) ||...
                    isduration(inputvals{2})))
                % If the second argument is a datetime, swap them since
                % area, bar and barh expect datetimes as first argument                
                dispStr =  [lower(fname) '(' inputnames{2} ',' inputnames{1}...
                    ',''DisplayName'',''' inputnames{1} ''')'];                
            else
                dispStr =  [lower(fname) '(' inputStr ',''DisplayName'',''' ...
                    inputnames{n} ''')'];
            end
        case {'graph','digraph'}
            dispStr =  ['plot(' inputStr ')'];
        case 'scatter'
           if n==2
              dispStr =  [lower(fname) '(' inputnames{1} ',' inputnames{2} ')'];
           elseif n==1
               % if the selection has parens, i.e. it is a subselect
               % Parse the string to find the rows and columns so
               % we can plot them as column vectors
               if length(regexpi(inputnames{1},'\(.*\)'))==1
                   
                   % Cell array selection start with cell2mat
                   isCellSelection = startsWith(inputnames{1}, 'cell2mat(');
                   
                   % Get the name of the variable to plot
                   if isCellSelection
                       varName = char(extractBetween(inputnames{1}, 'cell2mat(', '('));
                   else
                       varName = char(extractBefore(inputnames{1}, '('));
                   end
                   
                   % extractBetween will get the logicl indices for us to
                   % parse
                   args = extractBetween(inputnames{1}, [varName '('], ')');
                   
                   % Seperate the row indices from the columns
                   % e.g. [1,3],[2,end]
                   if startsWith(args, '[')
                       rowArgs = char(extractBetween(args, '[', '],', 'Boundaries', 'inclusive'));
                       rowArgs = strip(rowArgs, ',');
                       colArgs = char(extractAfter(args, '],'));
                   else
                       rowArgs = char(extractBefore(args, ','));
                       colArgs = char(extractAfter(args, ','));
                   end
                   
                   % Find the individual columns 
                   [cols, ~] = strsplit(char(extractBetween(colArgs, '[', ']')), {',', ':'});
                   
                   % If the columns are contiguous e.g. 2:3
                   if isempty(cols{1})
                       cols = strsplit(colArgs, {',', ':'});
                       
                       % If it is empty at this point I have the special
                       % case where I only have 2 columns in my array
                       if isempty(cols{1}) && isempty(cols{2})
                           cols{1} = '1';
                           cols{2} = '2';
                       end
                   end
                   
                   % Build the code gen string
                   if isCellSelection
                       dispStr = [lower(fname) '(cell2mat(' varName '(' rowArgs ',' cols{1} ')),cell2mat(' varName '(' rowArgs ',' cols{2} ')))'];
                   else
                       dispStr = [lower(fname) '(' varName '(' rowArgs ',' cols{1} '),' varName '(' rowArgs ',' cols{2} '))'];
                   end
               else
                   dispStr =  [lower(fname) '(' inputnames{1} '(:,1),' inputnames{1} '(:,2))'];
               end
           elseif n==3
              dispStr =  [lower(fname) '(' inputnames{1} ',' inputnames{2} ',' inputnames{3} ')']; 
           end
            
        case 'barstacked'
             dispStr =  ['bar(' inputStr ',''stacked'',''DisplayName'',''' inputnames{1} ''')'];
        case 'barhstacked'
             dispStr =  ['barh(' inputStr ',''stacked'',''DisplayName'',''' inputnames{1} ''')'];
        case 'errorbarhorz'
             dispStr =  ['errorbar(' inputStr ',''horizontal'')'];
        case 'heatmap'
            if n == 4
                % heatmap(tbl, xvar, yvar, 'ColorVariable', cvar)
                dispStr =  ['heatmap(' inputnames{1} ',' inputnames{2} ',' inputnames{3} ',''ColorVariable'',' inputnames{4} ');'];
            else
                % heatmap(cdata)
                % heatmap(xdata, ydata, cdata)
                % heatmap(tbl, xvar, yvar)
                dispStr =  ['heatmap(' inputStr ');'];
            end
        case 'geobubble'
                % geobubble(tbl, latvar, lonvar)
                % geobubble(lat, lon)
                % geobubble(lat, lon, sizedata)
                % geobubble(lat, lon, sizedata, colordata)
                dispStr =  ['geobubble(' inputStr ');'];
        case 'plot as multiple series' 
            % if alternate ones are datetimes/duration objects then the
            % plot action command has to be in pairs.
            % Eg: (t1,x1,t2,x2,t3,x3) -> (t1,x1)(t2,x2)(t3,x3)
            isSpecialCase = 0;
            if n > 2 && mod(length(inputvals),2) == 0
                isSpecialCase = localPlotPairs(inputvals);
            end
            if isSpecialCase == 1
                dispStr = [dispStr sprintf('plot(%s,%s,''DisplayName'',''%s'');', ...
                    inputnames{1},inputnames{2},inputnames{2}) holdStr];
                for k=3:2:length(inputnames)
                    dispStr = [dispStr sprintf('plot(%s,%s,''DisplayName'',''%s'');',inputnames{k},inputnames{k+1},inputnames{k+1})]; %#ok<AGROW>
                end;
                dispStr = [dispStr,'hold off;'];
            else
                dispStr = [dispStr sprintf('plot(%s,''DisplayName'',''%s'');', ...
                    inputnames{1},inputnames{1}) holdStr];
                for k=2:length(inputnames)
                    dispStr = [dispStr sprintf('plot(%s,''DisplayName'',''%s'');',inputnames{k},inputnames{k})]; %#ok<AGROW>
                end;
                dispStr = [dispStr,'hold off;'];
            end
        case 'plot as multiple series vs. first input'
            if length(inputnames)>=2
                for k=2:length(inputnames)
                    dispStr = [dispStr sprintf('plot(%s,%s,''DisplayName'',''%s'');',inputnames{1},inputnames{k},inputnames{k})]; %#ok<AGROW>
                    if k==2
                        dispStr = [dispStr, holdStr]; %#ok<AGROW>
                    end
                end;
                dispStr = [dispStr,'hold off;'];    
            end
        case 'plot selected columns'
              dispStr =  ['plot(' inputnames{1} ')'];
        case 'wordcloud'
              dispStr =  ['wordcloud(' inputStr ');'];             
    end                    
    varargout{1} = dispStr;
elseif strcmp(action,'defaultlabel')
    n = length(inputnames);       
    lblStr = '';
    switch lower(fname)
        case 'plot'            
            if n==1 
                varname = inputnames{1};
                vardata = inputvals{1};
                if ismatrix(vardata) && (~isobject(vardata) || isdatetime(vardata) || isduration(vardata)) 
                    if length(regexpi(varname,'\(.*\)'))==1   
                        lblStr = getString(message('MATLAB:codetools:plotpickerfunc:PlotSelectedColumns'));
                    elseif min(size(vardata))>1
                        lblStr = getString(message('MATLAB:codetools:plotpickerfunc:PlotAllColumns'));
                    else
                        lblStr = [fname '(' varname ')'];
                    end
                else
                    lblStr = '';
                end
            else
                lblStr = '';
            end
        case 'scatter'
            if n==1 
                vardata = inputvals{1};
                varname = inputnames{1};
                if isBasicMatrix(vardata) && size(vardata,2)==2
                    if length(regexpi(varname,'\(.*\)'))==1  
                        lblStr = getString(message('MATLAB:codetools:plotpickerfunc:ScatterPlotForSelectedColumns'));
                    else
                        lblStr = [fname '(' varname '(:,1), ' varname '(:,2)' ')'];
                    end
                else
                    lblStr = '';
                end
            else
                lblStr = '';
            end
        case 'plot_multiseriesfirst'
            lblStr = getString(message('MATLAB:codetools:plotpickerfunc:PlotAsMultipleSeriesVsFirstInput'));
        case 'plot_multiseries' 
            lblStr = getString(message('MATLAB:codetools:plotpickerfunc:PlotAsMultipleSeries'));
    end
    varargout{1} = lblStr;
% Return all the class names for the specified object
elseif strcmp(action,'getclassnames')
    h = inputvals;
    
    % Cache the lasterror state
    errorState = lasterror; %#ok<LERR,NASGU>
    
    try
        % Try mcos first
        if isobject(h)
           varargout{1} = [class(h);superclasses(h)];
           return;
        end

        % Now try UDD
        try 
            classH = classhandle(h);
        catch %#ok<CTCH>
            varargout{1} = {};
            return;
        end

        % There is no multiple inheritance in udd, so just ascend the class
        % hierarchy
        classArray = classH;
        while ~isempty(classH.Superclasses)
            classArray = [classArray;classH.Superclasses]; %#ok<AGROW>
            classH = classH.Superclasses;
        end
        classNames = get(classArray,{'Name'}); 
        for k=1:length(classArray)
            if ~isempty(classArray(k).Package)
                classNames{k} = sprintf('%s.%s',classArray(k).Package.Name,classNames{k});
            end
        end
        varargout{1} = classNames;
    catch %#ok<CTCH>
        % Prevent drooling of the lasterror state
        lasterror(errorstate); %#ok<LERR>
        varargout{1} = {};
    end
    
%end plotpickerfunc
end

function isUnique = isUniqueCategorical(x)
isUnique = false;

if iscategorical(x)
uniqueCat = unique(x);
if length(uniqueCat) == length(x)
    isUnique = true;
end
end

function status = localIsVector(x)
status = (isnumeric(x) || islogical(x)) && ~isscalar(x) && isvector(x) && ~isobject(x);
if (isdatetime(x) || isduration(x))
    status = status || (~isscalar(x) && isvector(x));
end

function status = localIsMatrix(x)
status = (isnumeric(x) || islogical(x)) && ~isscalar(x) && ismatrix(x) && ...
     ~isobject(x) && min(size(x))>1;
if (isdatetime(x) || isduration(x) || iscategorical(x))
    status = status || (~isscalar(x) && ismatrix(x) && min(size(x))>1);
end

function toshow = localPlotArgFcn(inputvals)

x = inputvals{1};
y = inputvals{2};
toshow =  (isnumeric(x) && ~isscalar(x) && ndims(x)<=2 && isreal(x)) ||...
    isdatetime(x) || isduration(x) || iscategorical(x);
toshow =  toshow && (isnumeric(y) || islogical(y) || isdatetime(y) ||...
    iscategorical(y) || isduration(y)) && ~isscalar(y) && ...
    ndims(y)<=2 && xor(isreal(y),(isdatetime(y) || isduration(y) || iscategorical(y)));
% case where x is datetime and y is duration or vice versa is not valid 
toshow = toshow && ~(isdatetime(x) && isduration(y)) && ~(isdatetime(y) && isduration(x));
if toshow && (isdatetime(x) || isduration(x) || ~isBasicVector(x)) && (isdatetime(y) || isduration(y) || ~isBasicVector(y))
    toshow = any(ismember(size(x), size(y)));
elseif toshow && (isdatetime(x) || isduration(x) || ~isBasicVector(x))
    toshow = any(ismember(length(y), size(x)));
elseif toshow && (isdatetime(y) || isduration(y) || ~isBasicVector(y))
    toshow = any(ismember(length(x), size(y)));
elseif toshow
    toshow = length(x)==length(y);
end

function toshow = localAreaArgFcn(inputvals)

x = inputvals{1};
y = inputvals{2};
toshow =  isnumeric(x) && ~isscalar(x) && ndims(x)<=2 && isreal(x);
toshow =  toshow && (isnumeric(y) || islogical(y)) && ~isscalar(y) && ndims(y)<=2 && isreal(y);
if toshow && ~isBasicVector(x)
    toshow = isequal(size(x),size(y));
elseif toshow && isBasicVector(x)
    toshow = any(length(x)==size(y));
end

function toshow = localAreaCategoricalArgFcn(inputvals)

x = inputvals{1};
y = inputvals{2};
toshow = iscategorical(x) && ~isscalar(x) && ndims(x)<=2;
toshow = toshow && (isnumeric(y) || islogical(y)) &&...
    ~isscalar(y) && ndims(y)<=2 && isreal(y);
if toshow && ~isBasicVector(x)
    toshow = isequal(size(x),size(y));
elseif toshow && isBasicVector(x)
    toshow = any(length(x)==size(y));
end

function toshow = localAreaTimeArgFcn(inputvals)

x = inputvals{1};
y = inputvals{2};
toshow =  isnumeric(x) && ~isscalar(x) && ndims(x)<=2 && isreal(x) ||...
    ((isdatetime(x) || isduration(x) || isUniqueCategorical(x)) &&...
    ~isscalar(x) && ndims(x)<=2 );
toshow =  toshow && (isnumeric(y) || islogical(y)) && ~isscalar(y) &&...
    ndims(y)<=2 && isreal(y) ||...
    ((isdatetime(y) || isduration(y)) &&...
    ~isscalar(y) && ndims(y)<=2 );
if toshow && isdatetime(x) || isduration(x) || iscategorical(x)
    if toshow && ~isvector(x)
        toshow = isequal(size(x),size(y));
    elseif toshow && isvector(x)
        toshow = any(length(x)==size(y));
    end
else
    if toshow && ~isBasicVector(x)
        toshow = isequal(size(x),size(y));
    elseif toshow && isBasicVector(x)
        toshow = any(length(x)==size(y));
    end
end

function plotPairs = localPlotPairs(inputvals)
% if the first entry is datetime or duration
if isdatetime(inputvals{1}) || isduration(inputvals{1})
    plotPairs = all(cellfun('isclass', inputvals(1:2:end),class(inputvals{1})));
    plotPairs = plotPairs && ~(any(cellfun('isclass', inputvals(2:2:end), 'datetime')));
    plotPairs = plotPairs && ~(any(cellfun('isclass', inputvals(2:2:end), 'duration')));
    % if the second entry is datetime or duration
elseif isdatetime(inputvals{2}) || isduration(inputvals{2})
    plotPairs = all(cellfun('isclass', inputvals(2:2:end),class(inputvals{2})));
    plotPairs = plotPairs && ~(any(cellfun('isclass', inputvals(1:2:end), 'datetime')));
    plotPairs = plotPairs && ~(any(cellfun('isclass', inputvals(1:2:end), 'duration')));
else
    plotPairs = 0;
end

function isgeocoords = isGeoCoordinates(latinputval, loninputval)
% Check if the inputs for latitude and longitude
% are a valid vector coordinate pair.

vectorInput = isBasicVector(latinputval) && isBasicVector(loninputval);

if isnumeric(latinputval) && isnumeric(loninputval) && vectorInput
    latinrange = max(latinputval) < 90 && min(latinputval) > -90;
    loninrange = max(loninputval) < 360 && min(loninputval) > -360;
    lengthsequal = length(latinputval) == length(loninputval);
    
    isgeocoords = latinrange && loninrange && lengthsequal;
else
    isgeocoords = false;
end

function isbasicmatrix = isBasicMatrix(inputval)
isbasicmatrix = ismatrix(inputval) && ~isobject(inputval);

function isbasicvector = isBasicVector(inputval)
isbasicvector = isvector(inputval) && ~isobject(inputval);

function issubscript = isScalarTableSubscript(tbl, subscript)
% Check if 'subscript' is a valid table subscript which refers to a single
% column in 'tbl'.

issubscript = ~isempty(matlab.graphics.chart.internal.validateTableSubscript(tbl, subscript));
