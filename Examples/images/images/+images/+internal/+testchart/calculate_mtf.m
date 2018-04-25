function MTF = calculate_mtf(dat,perc)

MTF = {[nan nan nan nan]};

perc = perc/100;
for k =1:size(dat,1)    
    current_dat = dat{k};
    freq = table2array(current_dat(:,1));
    current_MTF = zeros(1,size(current_dat,2)-1);
    for i = 2:size(current_dat,2)
        dt1 = -1;
        dt2 = -1;
        data = table2array(current_dat(:,i));
        for j=2:length(data)
            if((data(j-1)>perc) && (data(j)<perc))
                dt1 = data(j-1);
                dt2 = data(j);
                break;
            end
        end
        
        if dt1~= -1 && dt2~= -1
            fr1 = freq(j-1);
            fr2 = freq(j);
            current_MTF(i-1) = fr1 + (perc-dt1) *((fr2-fr1)/(dt2-dt1));
        else
            current_MTF(i-1) = nan;
        end
    end
    MTF{k} = current_MTF;
end
MTF = MTF';