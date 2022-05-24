function [AP_PSTH] = histogrampsth(WhiskOnset_AVG_AP,SR_Vm, Pre_Window, Post_Window, bin_size)
 
AP_PSTH=[];
AP_PSTH_pre=[];
AP_PSTH_post=[];


bin_pt=round(bin_size*SR_Vm);
% PSTH_Numb_pt=floor(-1*Pre_Window*SR_Vm)+floor(Post_Window*SR_Vm)
% AP_PSTH(1:PSTH_Numb_pt,1:2)=0;

pt0=floor(-1*Pre_Window*SR_Vm);
pt2=pt0;
pt_min=pt0-floor(pt0/bin_pt)*bin_pt+1;

cnt=0;


while(pt2>pt_min)
    
    pt1=pt0-(bin_pt*(cnt));
    pt2=pt1-bin_pt+1;
    
    AP_PSTH_pre(cnt+1,1)=-1*bin_size*(cnt+1);
    AP_PSTH_pre(cnt+1,2)=sum(WhiskOnset_AVG_AP(pt2:pt1,1))/bin_size;
    cnt=cnt+1;
    
end

pt0=floor(-1*Pre_Window*SR_Vm);
pt2=pt0;
pt_max=pt0+floor((Post_Window*SR_Vm)/bin_pt)*bin_pt;

cnt=0;

while(pt2<pt_max)
    
    pt1=pt0+(bin_pt*cnt);
    pt2=pt1+bin_pt;
    
    AP_PSTH_post(cnt+1,1)=bin_size*(cnt);
    AP_PSTH_post(cnt+1,2)=sum(WhiskOnset_AVG_AP(pt1:pt2,1))/bin_size;
    
    cnt=cnt+1;
    
end


AP_PSTH=vertcat(AP_PSTH_pre, AP_PSTH_post);

AP_PSTH=sortrows(AP_PSTH);

end