function dataout = utArithCommonData(ts1,ts2,operator,IsArrayFirst)
%UTARITHCOMMONDATA
%
 
% Copyright 2006-2011 The MathWorks, Inc.

% If ts1 is empty, null op
if ts1.Length==0
    dataout = [];
    return
end
% Get sample size
s1 = getdatasamplesize(ts1);
if isa(ts2,'timeseries')
    s2 = getdatasamplesize(ts2);
else
    s2 = size(ts2);
end
% Check arith operation condition: skip the scalar case
if isa(ts2,'timeseries') || ~isscalar(ts2)
    switch operator
        case {'+' '-' '.*' './' '.\'}
            if ~isequal(s1,s2) && ~isequal(s2,[1 1])
                error(message('MATLAB:timeseries:utArithCommon:nonconfdim', num2str( s1 ), num2str( s2 )))
            end
        case '*'
            if length(s1)>2 || length(s2)>2
                error(message('MATLAB:timeseries:utArithCommon:non3dimmax'))
            end
            if IsArrayFirst
                if s1(1)~=s2(2)
                        error(message('MATLAB:timeseries:utArithCommon:nonconfdimMatrixMultiply', num2str( s1 ), num2str( s2 )))
                end
            else
                if s1(2)~=s2(1)
                        error(message('MATLAB:timeseries:utArithCommon:nonconfdimMatrixMultiply', num2str( s1 ), num2str( s2 )))
                end
            end
        case '/'
            if length(s1)>2 || length(s2)>2
                error(message('MATLAB:timeseries:utArithCommon:non3dimmax'))
            end
            if s1(2)~=s2(2)
                error(message('MATLAB:timeseries:utArithCommon:nonconfdimMatrixDiv', num2str( s1 ), num2str( s2 )))
            end
        case '\'
            if length(s1)>2 || length(s2)>2
                error(message('MATLAB:timeseries:utArithCommon:non3dimmax'))
            end
            if s1(1)~=s2(1)
                error(message('MATLAB:timeseries:utArithCommon:nonconfdimMatrixLeftDiv', num2str( s1 ), num2str( s2 )))
            end
    end
end
% Load the data so its not extracted for each pass of the loop and check
% the dimensions
data1 = ts1.Data;
if isa(ts2,'timeseries')
    data2 = ts2.Data;
else
    data2 = ts2;
    if isscalar(data2) && ~strcmp(operator,'\') %except '\' which is special
        if IsArrayFirst
            dataout = localArith(data2,data1,operator);
        else
            dataout = localArith(data1,data2,operator);
        end
        return
    end
end
% Single sample case
if ts1.Length==1
    if IsArrayFirst
        dataout = localArith(data2,data1,operator);
    else
        dataout = localArith(data1,data2,operator);
    end
% More than one sample case
else
    if isa(ts2,'timeseries')
        dataout = localArithTS1TS2(ts1,ts2,s1,s2,operator);
    else
        dataout = localArithTS1DATA2(ts1,data2,s1,s2,operator,IsArrayFirst);
    end
end
dataout = squeeze(dataout);


function dataout=localArith(data1,data2,operator)

try
    switch operator
        case '+'
            dataout = squeeze(data1)+squeeze(data2);
        case '-'
            dataout = squeeze(data1)-squeeze(data2);
        case '.*'
            dataout = squeeze(data1).*squeeze(data2);
        case '*'
            dataout = squeeze(data1)*squeeze(data2);
        case './'
            dataout = squeeze(data1)./squeeze(data2);
        case '/'
            dataout = squeeze(data1)/squeeze(data2);
        case '.\'
            dataout = squeeze(data1).\squeeze(data2);
        case '\'
            dataout = squeeze(data1)\squeeze(data2);
    end
catch %#ok<CTCH>
    try
        switch operator
            case '+'
                dataout = squeeze(double(data1))+squeeze(double(data2));
            case '-'
                dataout = squeeze(double(data1))-squeeze(double(data2));
            case '.*'
                dataout = squeeze(double(data1)).*squeeze(double(data2));
            case '*'
                dataout = squeeze(double(data1))*squeeze(double(data2));
            case './'
                dataout = squeeze(double(data1))./squeeze(double(data2));
            case '/'
                dataout = squeeze(double(data1))/squeeze(double(data2));
            case '.\'
                dataout = squeeze(double(data1)).\squeeze(double(data2));
            case '\'
                dataout = squeeze(double(data1))\squeeze(double(data2));
        end
    catch me
        rethrow(me);
    end
end


function dataout = localArithTS1TS2(ts1,ts2,s1,s2,operator)

data1 = double(ts1.Data);
data2 = double(ts2.Data);
try
    switch operator
        case '+'
            if isequal(s2,[1 1]) && ~isequal(s1,[1 1])
                if ts1.IsTimeFirst && ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(i,:,:)+data2(i,:,:);
                    end
                elseif ts1.IsTimeFirst && ~ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(i,:,:)+data2(:,:,i);
                    end
                elseif ~ts1.IsTimeFirst && ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(:,:,i)+data2(i,:,:);
                    end
                elseif ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i) = data1(:,:,i)+data2(:,:,i);
                    end
                end
            else
                dataout = data1+data2;
            end
        case '-'
            if isequal(s2,[1 1]) && ~isequal(s1,[1 1])
                if ts1.IsTimeFirst && ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(i,:,:)-data2(i,:,:);
                    end
                elseif ts1.IsTimeFirst && ~ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(i,:,:)-data2(:,:,i);
                    end
                elseif ~ts1.IsTimeFirst && ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(:,:,i)-data2(i,:,:);
                    end
                elseif ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i) = data1(:,:,i)-data2(:,:,i);
                    end
                end
            else
                dataout = data1-data2;
            end
        case '.*'
            if isequal(s2,[1 1]) && ~isequal(s1,[1 1])
                if ts1.IsTimeFirst && ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(i,:,:).*data2(i,:,:);
                    end
                elseif ts1.IsTimeFirst && ~ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(i,:,:).*data2(:,:,i);
                    end
                elseif ~ts1.IsTimeFirst && ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(:,:,i).*data2(i,:,:);
                    end
                elseif ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i) = data1(:,:,i).*data2(:,:,i);
                    end
                end
            else
                dataout = data1.*data2;
            end
        case '*'
            if ts1.IsTimeFirst && ts2.IsTimeFirst
                dataout = zeros(ts1.Length,s1(1),s2(2));
                data1 = localShift(data1);
                data2 = localShift(data2);
                for i=1:ts1.Length
                    dataout(i,:,:) = data1(:,:,i)*data2(:,:,i);
                end
            elseif ts1.IsTimeFirst && ~ts2.IsTimeFirst
                dataout = zeros(ts1.Length,s1(1),s2(2));
                data1 = localShift(data1);
                for i=1:ts1.Length
                    dataout(i,:,:) = data1(:,:,i)*data2(:,:,i);
                end
            elseif ~ts1.IsTimeFirst && ts2.IsTimeFirst
                dataout = zeros(ts1.Length,s1(1),s2(2));
                data2 = localShift(data2);
                for i=1:ts1.Length
                    dataout(i,:,:) = data1(:,:,i)*data2(:,:,i);
                end
            elseif ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
                dataout = zeros(s1(1),s2(2),ts1.Length);
                for i=1:ts1.Length
                    dataout(:,:,i) = data1(:,:,i)*data2(:,:,i);
                end
            end
        case './'
            if isequal(s2,[1 1]) && ~isequal(s1,[1 1])
                if ts1.IsTimeFirst && ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(i,:,:)./data2(i,:,:);
                    end
                elseif ts1.IsTimeFirst && ~ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(i,:,:)./data2(:,:,i);
                    end
                elseif ~ts1.IsTimeFirst && ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(:,:,i)./data2(i,:,:);
                    end
                elseif ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i) = data1(:,:,i)./data2(:,:,i);
                    end
                end
            else
                dataout = data1./data2;
            end
        case '/'
            if ts1.IsTimeFirst && ts2.IsTimeFirst
                dataout = zeros(ts1.Length,s1(1),s2(1));
                data1 = localShift(data1);
                data2 = localShift(data2);
                for i=1:ts1.Length
                    dataout(i,:,:) = data1(:,:,i)/data2(:,:,i);
                end
            elseif ts1.IsTimeFirst && ~ts2.IsTimeFirst
                dataout = zeros(ts1.Length,s1(1),s2(1));
                data1 = localShift(data1);
                for i=1:ts1.Length
                    dataout(i,:,:) = data1(:,:,i)/data2(:,:,i);
                end
            elseif ~ts1.IsTimeFirst && ts2.IsTimeFirst
                dataout = zeros(ts1.Length,s1(1),s2(1));
                data2 = localShift(data2);
                for i=1:ts1.Length
                    dataout(i,:,:) = data1(:,:,i)/data2(:,:,i);
                end
            elseif ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
                dataout = zeros(s1(1),s2(1),ts1.Length);
                for i=1:ts1.Length
                    dataout(:,:,i) = data1(:,:,i)/data2(:,:,i);
                end
            end
        case '.\'
            if isequal(s2,[1 1]) && ~isequal(s1,[1 1])
                if ts1.IsTimeFirst && ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(i,:,:).\data2(i,:,:);
                    end
                elseif ts1.IsTimeFirst && ~ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(i,:,:).\data2(:,:,i);
                    end
                elseif ~ts1.IsTimeFirst && ts2.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(:,:,i).\data2(i,:,:);
                    end
                elseif ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data1(:,:,i).\data2(:,:,i);
                    end
                end
            else
                dataout = data1.\data2;
            end
        case '\'
            if ts1.IsTimeFirst && ts2.IsTimeFirst
                dataout = zeros(ts1.Length,s1(2),s2(2));
                data1 = localShift(data1);
                data2 = localShift(data2);
                for i=1:ts1.Length
                    dataout(i,:,:) = data1(:,:,i)\data2(:,:,i);
                end
            elseif ts1.IsTimeFirst && ~ts2.IsTimeFirst
                dataout = zeros(ts1.Length,s1(2),s2(2));
                data1 = localShift(data1);
                for i=1:ts1.Length
                    dataout(i,:,:) = data1(:,:,i)\data2(:,:,i);
                end
            elseif ~ts1.IsTimeFirst && ts2.IsTimeFirst
                dataout = zeros(ts1.Length,s1(2),s2(2));
                data2 = localShift(data2);
                for i=1:ts1.Length
                    dataout(i,:,:) = data1(:,:,i)\data2(:,:,i);
                end
            elseif ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
                dataout = zeros(s1(2),s2(2),ts1.Length);
                for i=1:ts1.Length
                    dataout(:,:,i) = data1(:,:,i)\data2(:,:,i);
                end
            end
    end
catch me
    rethrow(me);
end



function dataout = localArithTS1DATA2(ts1,data2,s1,s2,operator,IsArrayFirst)

data1 = double(ts1.Data);
if ~IsArrayFirst
    try
        switch operator
            case '+'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:) = data1(i,:,:)+data2;
                    end
                else
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data1(:,:,i)+data2;
                    end
                end
            case '-'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:)=data1(i,:,:)-data2;
                    end
                else
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data1(:,:,i)-data2;
                    end
                end
            case '.*'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:)=data1(i,:,:).*data2;
                    end
                else
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data1(:,:,i).*data2;
                    end
                end
            case '*'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s2(2));
                    data1 = localShift(data1);
                    for i=1:ts1.Length
                        dataout(i,:,:)=data1(:,:,i)*data2;
                    end
                else
                    dataout = zeros(s1(1),s2(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data1(:,:,i)*data2;
                    end
                end
            case './'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:)=data1(i,:,:)./data2;
                    end
                else
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data1(:,:,i)./data2;
                    end
                end
            case '/'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s2(1));
                    data1 = localShift(data1);
                    for i=1:ts1.Length
                        dataout(i,:,:)=data1(:,:,i)/data2;
                    end
                else
                    dataout = zeros(s1(1),s2(1),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data1(:,:,i)/data2;
                    end
                end
            case '.\'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:)=data1(i,:,:).\data2;
                    end
                else
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data1(:,:,i).\data2;
                    end
                end
            case '\'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(2),s2(2));
                    data1 = localShift(data1);
                    for i=1:ts1.Length
                        dataout(i,:,:)=data1(:,:,i)\data2;
                    end
                else
                    dataout = zeros(s1(2),s2(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data1(:,:,i)\data2;
                    end
                end
        end
    catch me
        rethrow(me);
    end
else
    try
        switch operator
            case '+'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:)=data2+data1(i,:,:);
                    end
                else
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data2+data1(:,:,i);
                    end
                end
            case '-'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:)=data2-data1(i,:,:);
                    end
                else
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data2-data1(:,:,i);
                    end
                end
            case '.*'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:)=data2.*data1(i,:,:);
                    end
                else
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data2.*data1(:,:,i);
                    end
                end
            case '*'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s2(2));
                    data1 = localShift(data1);
                    for i=1:ts1.Length
                        dataout(i,:,:)=data2*data1(:,:,i);
                    end
                else
                    dataout = zeros(s1(1),s2(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data2*data1(:,:,i);
                    end
                end
            case './'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:)=data2./data1(i,:,:);
                    end
                else
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data2./data1(:,:,i);
                    end
                end
            case '/'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s2(1));
                    data1 = localShift(data1);
                    for i=1:ts1.Length
                        dataout(i,:,:)=data2/data1(:,:,i);
                    end
                else
                    dataout = zeros(s1(1),s2(1),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data2/data1(:,:,i);
                    end
                end
            case '.\'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(1),s1(2));
                    for i=1:ts1.Length
                        dataout(i,:,:)=data2.\data1(i,:,:);
                    end
                else
                    dataout = zeros(s1(1),s1(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data2.\data1(:,:,i);
                    end
                end
            case '\'
                if ts1.IsTimeFirst
                    dataout = zeros(ts1.Length,s1(2),s2(2));
                    data1 = localShift(data1);
                    for i=1:ts1.Length
                        dataout(i,:,:)=data2\data1(:,:,i);
                    end
                else
                    dataout = zeros(s1(2),s2(2),ts1.Length);
                    for i=1:ts1.Length
                        dataout(:,:,i)=data2\data1(:,:,i);
                    end
                end
        end
    catch me
        rethrow(me);
    end
end    


function dataout = localShift(data)
%LOCALSHIFT Make the time dimension the last dimension
if length(size(data))==2
    dataout = reshape(data,[1 size(data,2) size(data,1)]);
else
    dataout = shiftdim(data,1);
end
