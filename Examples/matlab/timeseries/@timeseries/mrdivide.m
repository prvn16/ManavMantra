function tsout = mrdivide(ts1,ts2)
%MRDIVIDE  Overloaded 2-D matrix right division.
%
%    TS1/TS2: TS1 and TS2 must have the same length. The number of columns
%    of TS1.Data and the number of columns of TS2.Data must be the same.
%    Note: the quality array of the output time series will be the
%    element-by-element minimum of the two quality arrays from TS1 and TS2.
%
%    TS1/B: The number of columns of TS1.Data and the number of columns of
%    B must be the same.  
%
%    A/TS1: The number of columns of A and the number of columns of
%    TS1.Data must be the same.   
%

%   Copyright 2004-2015 The MathWorks, Inc.

if isa(ts1,'timeseries')
    if numel(ts1)~=1
        error(message('MATLAB:timeseries:mrdivide:noarray'));
    end
    if isa(ts2,'timeseries')
        if numel(ts2)~=1
           error(message('MATLAB:timeseries:mrdivide:noarray'));
        end
        tsout = localmrdivide(ts1,ts2);
    elseif isnumeric(ts2) || islogical(ts2)
        % Use option 'false' for ts\N
        tsout = localmrdivide(ts1, ts2, false);
    else
        % Second input is not valid for operation
        error(message('MATLAB:timeseries:arith:typemix', class( ts2 )));
    end
else
    if isnumeric(ts1) || islogical(ts1)
        if numel(ts2)~=1
           error(message('MATLAB:timeseries:mrdivide:noarray'));
        end
        % Use option 'true' for N\ts
        tsout = localmrdivide(ts2,ts1,true);
    else
        error(message('MATLAB:timeseries:arith:typemix', class( ts1 )));
    end
end

function tsout = localmrdivide(ts1,ts2,varargin)

% A_OPR_TS1 case or TS1_OPR_B case
if nargin==3
    isArrayFirst = varargin{1};
% TS1_OPR_TS2 case
else
    isArrayFirst = false;
end
% TS1_OPR_TS2 case
if isa(ts2,'timeseries')
    % deal with time first
    [commomTimeVector,outprops,warningFlag] = utArithCommonTime(ts1,ts2);
    
    
    % deal with empty object: return an empty ts which is consistent with
    % Matlab command 2+[], 2./[] etc.
    if isempty(commomTimeVector)
        tsout = timeseries;
        return
    end

    % If the IsTimeFirst properties of the two timeseries are different,
    % the output timeseries defaults to IsTimeFirst == true
    if ts1.IsTimeFirst == ts2.IsTimeFirst
        tsout = ts1;
        if ts1.DataInfo.isstorage
            try
                tsout.DataInfo = mrdivide(ts1.DataInfo,ts2.DataInfo);
            catch %#ok<*CTCH>
                [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(ts1.DataInfo,ts2.DataInfo,ts1.Data,ts2.Data,ts2.IsTimeFirst);
            end
        else
            [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(ts1.DataInfo,ts2.DataInfo,ts1.Data,ts2.Data,ts2.IsTimeFirst);
        end
        %tsout.DataInfo = mrdivide(ts1.DataInfo,ts2.DataInfo);
    else
        % due to deprecation of IsTimeFirst,
        % transpose function cannot be used any more. will error out
        error(message('MATLAB:timeseries:arith:timeDimMismatch'));
    end

    tsout.Name = 'unnamed';
    tsout.Quality = [];
    tsout.timeInfo.StartDate = outprops.ref;
    tsout.timeInfo.Units = outprops.outunits;
    tsout.timeInfo.Format = outprops.outformat;
 
    % Build output time series. 
    tsout = timeseries.utarithcommonoutput(ts1,ts2,tsout,warningFlag);

% A_OPR_TS1 case or TS1_OPR_B case
elseif isnumeric(ts2) || islogical(ts2)
    commomTimeVector = ts1.Time;
    
    % deal with empty object: return an empty ts which is consistent with
    % Matlab command 2+[], 2./[] etc.
    if isempty(commomTimeVector)
        tsout = timeseries;
        return
    end
    tsout = ts1;
    
    % Duplicate non-scalar numeric inputs over each sample (see command
    % line help for TS1/B or A/TS1)
    if isscalar(ts2)
        if ~isArrayFirst
            if ts1.DataInfo.isstorage
                try
                   tsout.DataInfo = mrdivide(ts1.DataInfo,ts2,ts1.isTimeFirst);
                catch
                     [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(...
                        ts1.DataInfo,[],ts1.Data,ts2,ts1.isTimeFirst);        
                end
            else
               [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(...
                 ts1.DataInfo,[],ts1.Data,ts2,ts1.isTimeFirst);
            end
            %tsout.DataInfo = mrdivide(ts1.DataInfo,ts2,ts1.isTimeFirst);
        else
            if ts1.DataInfo.isstorage
                try
                    tsout.DataInfo = mrdivide(ts2,ts1.DataInfo,ts1.isTimeFirst);
                catch
                    [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(...
                        [],ts1.DataInfo,ts2,ts1.Data,ts1.isTimeFirst); 
                end
            else
               [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(...
                  [],ts1.DataInfo,ts2,ts1.Data,ts1.isTimeFirst);
            end
            %tsout.DataInfo = mrdivide(ts2,ts1.DataInfo,ts1.isTimeFirst);
        end
    else
        if ~isArrayFirst
            if ts1.isTimeFirst
                if ts1.DataInfo.isstorage
                    try
                        tsout.DataInfo = mrdivide(ts1.DataInfo,reshape(repmat(ts2,ts1.length,1),size(ts1.Data)),...
                           ts1.isTimeFirst  );
                    catch
                         [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(...
                            ts1.DataInfo,[],ts1.Data,reshape(repmat(ts2,ts1.length,1),size(ts1.Data)),...
                            ts1.isTimeFirst);
                    end
                else
                        [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(...
                            ts1.DataInfo,[],ts1.Data,reshape(repmat(ts2,ts1.length,1),size(ts1.Data)),...
                            ts1.isTimeFirst);
                end
%                 tsout.DataInfo = mrdivide(ts1.DataInfo,reshape(repmat(ts2,ts1.length,1),size(ts1.Data)),...
%                     ts1.isTimeFirst  );
            else
                [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(...
                    ts1.DataInfo,[],ts1.Data,reshape(repmat(ts2,1,ts1.length),size(ts1.Data)),...
                    ts1.isTimeFirst);                
%                 tsout.DataInfo = mrdivide(ts1.DataInfo,reshape(repmat(ts2,1,ts1.length),size(ts1.Data)),...
%                     ts1.isTimeFirst  );
            end        
        else        
            if ts1.isTimeFirst 
                if ts1.DataInfo.isstorage
                    try
                        tsout.DataInfo = mrdivide(reshape(repmat(ts2,ts1.length,1),size(ts1.Data)),ts1.DataInfo,...
                          ts1.isTimeFirst  );
                    catch
                         [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(...
                            [],ts1.DataInfo,reshape(repmat(ts2,ts1.length,1),size(ts1.Data)),...
                            ts1.Data,ts1.isTimeFirst); 
                    end
                else                   
                   [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(...
                       [],ts1.DataInfo,reshape(repmat(ts2,ts1.length,1),size(ts1.Data)),...
                       ts1.Data,ts1.isTimeFirst);
                end
%                 tsout.DataInfo = mrdivide(reshape(repmat(ts2,ts1.length,1),size(ts1.Data)),ts1.DataInfo,...
%                     ts1.isTimeFirst  );
            else
                if ts1.DataInfo.isstorage
                    try
                        tsout.DataInfo = mrdivide(reshape(repmat(ts2,1,ts1.length),size(ts1.Data)),ts1.DataInfo,...
                           ts1.isTimeFirst  );
                    catch
                        [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(...
                            [],ts1.DataInfo,reshape(repmat(ts2,1,ts1.length),size(ts1.Data)),...
                            ts1.Data,ts1.isTimeFirst);
                    end
                else
                   [tsout.DataInfo,tsout.Data] = tsdata.datametadata.defaultmrdivide(...
                       [],ts1.DataInfo,reshape(repmat(ts2,1,ts1.length),size(ts1.Data)),...
                       ts1.Data,ts1.isTimeFirst);  
                end
%                 tsout.DataInfo = mrdivide(reshape(repmat(ts2,1,ts1.length),size(ts1.Data)),ts1.DataInfo,...
%                     ts1.isTimeFirst  );
            end    
        end
    end
end
tsout.Time = commomTimeVector;