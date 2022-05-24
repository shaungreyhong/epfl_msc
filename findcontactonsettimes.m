function [Selected_Times] = findcontactonsettimes(Contact_Times, Min_Event_Dur, Min_ITI)
Selected_Times=[];
cnt=1;

for i=1:size(Contact_Times, 1)
    
    Event_Dur=[];
    ITI=[];
    % compute the event duration
    Event_Dur=Contact_Times(i,2)-Contact_Times(i,1);
    % compute the ITI (ITI = event time for the 1st event)
    if i==1
        ITI=Contact_Times(i,1);
    else
        ITI=Contact_Times(i,1)-Contact_Times(i-1,2);
    end
    
    if Event_Dur> Min_Event_Dur && ITI>Min_ITI
       
       
            Selected_Times(cnt,1)=Contact_Times(i,1); 
            cnt=cnt+1;

        
    end
    
end



end