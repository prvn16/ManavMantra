function varargout = subsref(h, S)
%SUBSREF  Overloaded subsref

%   Copyright 2005-2012 The MathWorks, Inc.

if length(S)>=1 && strcmp(S(1).type,'()') 
    % TS(IND)
    % Determine which members have been selected
    memberVars = gettimeseriesnames(h);
    
    % First dimension: sample index -- I
    % Second dimension: time series object index/names -- J
    % get J
    if length(S(1).subs)==2
        if islogical(S(1).subs{2})
            J = find(S(1).subs{2});
        elseif isnumeric(S(1).subs{2})        
            if (any(S(1).subs{2}<1) || any(S(1).subs{2}>length(memberVars)) || ...
                      ~isequal(round(S(1).subs{2}),S(1).subs{2}))
                 error(message('MATLAB:tscollection:subsref:indexOutOfRange'))
            end
             J = S(1).subs{2};
        elseif iscell(S(1).subs{2})
            [flag, J] = ismember(S(1).subs{2},memberVars);
            if ~any(flag)
                error(message('MATLAB:tscollection:subsref:notMember'))
            end
        elseif ischar(S(1).subs{2})
            if S(1).subs{2}~=':'
                [flag, J] = ismember(lower(S(1).subs{2}),lower(memberVars));
                if ~any(flag)
                    error(message('MATLAB:tscollection:subsref:notMember'))
                end
            else
                J = 1:length(memberVars);
            end
        end
    elseif length(S(1).subs)==1
        J = 1:length(memberVars);
        if isempty(S(1).subs{1})
            varargout{1} = tscollection;
            return
        end
    else
        error(message('MATLAB:tscollection:subsref:depthExceedsTwo'))
    end
    % get I
    if ischar(S(1).subs{1}) 
        % : case
        if S(1).subs{1}==':'
            I = 1:length(h.Time);
        else
            error(message('MATLAB:tscollection:subsref:badSep'))
        end
    elseif ~isempty(S(1).subs{1}) && isreal(S(1).subs{1})
        I = unique(S(1).subs{1});
        if isnumeric(I) && (any(I<1) || any(I>h.TimeInfo.Length) || ~isequal(round(I),I))
            error(message('MATLAB:tscollection:subsref:badIndex'))
        elseif islogical(I)
            I = find(I);
        end
    else
        return
    end
    
    % Initialize new @tscollection
    tscout = tscollection(h.Time(I));

    % Copy metadata
    tscout.timeInfo = reset(h.TimeInfo,h.Time(I));
    
    % Add subreferenced @timeseries one at a time
    for k=1:length(J)
        thists = getts(h,memberVars{J(k)});
        tscout = setts(tscout,thists.getsamples(I),...
            thists.Name);
    end   

    % If there are more subref arguments call the subsref
    % method on the time series with the remaining arguments
    if length(S)>1
        if nargout>0
            varargout = cell(1,nargout);
            [varargout{1:nargout}] = subsref(tscout,S(2:end));
        else
            varargout{1} = subsref(tscout,S(2:end)); 
        end
    else
        varargout{1} = tscout;
    end
% coll.MemberName
elseif length(S)>=1 && strcmp(S(1).type,'.') && ~isempty(h.Members_) && ...
        any(strcmpi(S(1).subs,{h.Members_.('Name')}))
    ind = find(strcmpi(S(1).subs,{h.Members_.('Name')}));
    ts = getts(h,h.Members_(ind(1)).Name);
    if length(S)>1
        if nargout>0
           varargout = cell(1,nargout);
           [varargout{1:nargout}] = builtin('subsref',ts,S(2:end));
        else
           clear ans;
           builtin('subsref',ts,S(2:end));
           if exist('ans','var')
              varargout{1} = ans; %#ok<NOANS>
           end  
        end
    else
        varargout{1} = ts;
    end       
else
    % TS.Fieldname
    if nargout>0
        varargout = cell(1,nargout);
        [varargout{1:nargout}] = builtin('subsref',h,S);
    else
        clear ans;
        builtin('subsref',h,S);
        if exist('ans','var')
            varargout{1} = ans; %#ok<NOANS>
        end
    end 
end



        
