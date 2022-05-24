function [AP_vect] = times2vect(AP_times, SR_Vm, Length_Vect);

AP_vect=[];

AP_vect(1:Length_Vect,1)=0;

if ~isnan(AP_times)
    
    for t=1:size(AP_times,1)
        
        AP_pt=round(AP_times(t,1)*SR_Vm);
        AP_vect(AP_pt,1)=1;
        
    end
end


end