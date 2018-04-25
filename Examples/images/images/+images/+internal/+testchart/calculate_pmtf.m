function PMTF = calculate_pmtf(dat,perc)

PMTF = {[nan nan nan nan]};
perc = perc/100;
for k =1:size(dat,1)
    current_dat = dat{k};
    freq = table2array(current_dat(:,1));
    current_PMTF = zeros(1,size(current_dat,2)-1);
    for i = 2:size(current_dat,2)
        dt1 = -1;
        dt2 = -1;
        data = table2array(current_dat(:,i));
        max_data = max(data);
        data_val = max_data*perc;
        for j=2:length(data)
            if((data(j-1)>data_val) && (data(j)<data_val))
                dt1 = data(j-1);
                dt2 = data(j);
                break;
            end
        end
        
        if dt1~= -1 && dt2~= -1
            fr1 = freq(j-1);
            fr2 = freq(j);
            current_PMTF(i-1) = fr1 + (data_val-dt1) *((fr2-fr1)/(dt2-dt1));
        else
            current_PMTF(i-1) = nan;
        end
    end
    PMTF{k} = current_PMTF;
end
PMTF = PMTF';