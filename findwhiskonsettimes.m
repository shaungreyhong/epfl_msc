function [Selected_Times] = findwhiskonsettimes(Whisk_Onset_Times, Contact_Times , Min_Event_Dur, Min_ITI)
Selected_Times=[];
cnt=1;

for i=1:size(Whisk_Onset_Times, 1)
    
    Event_Dur=[];
    ITI=[];
    % compute the event duration
    Event_Dur=Whisk_Onset_Times(i,2)-Whisk_Onset_Times(i,1);
    % compute the ITI (ITI = event time for the 1st event)
    if i==1
        ITI=Whisk_Onset_Times(i,1);
    else
        ITI=Whisk_Onset_Times(i,1)- Whisk_Onset_Times(i-1,2);
    end
    
    if Event_Dur> Min_Event_Dur && ITI>Min_ITI
       
        if isempty(Contact_Times)         
            Selected_Times(cnt,1)=Whisk_Onset_Times(i,1); 
            cnt=cnt+1;
        else
            if min(abs(Contact_Times(:,1)-Whisk_Onset_Times(i,1)))>Min_ITI && min(abs(Whisk_Onset_Times(i,1)-Contact_Times(:,2)))>Min_ITI
                Selected_Times(cnt,1)=Whisk_Onset_Times(i,1); 
                cnt=cnt+1;
            end
        end
        
    end
    
end



end