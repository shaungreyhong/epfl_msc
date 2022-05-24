function  [Selected_Times] = findqaepochs(Stat_times, AT_times ,Window_Duration, Sweep_Duration, SR_WP)

Time_Exclu=0.1;

Sweep_length=round(Sweep_Duration*SR_WP);
Window_Length=round(Window_Duration*SR_WP);

Selected_Times=[];

Stat_vect=[];
AT_vect=[];
Stat_vect_clean=[];

Stat_vect(1:Sweep_length,1)=0;
AT_vect(1:Sweep_length,1)=1;

if isempty(Stat_times)==0
    for i=1:size(Stat_times,1)
        
        pt1=round(Stat_times(i,1)*SR_WP);
        pt2=round(Stat_times(i,2)*SR_WP);
        Stat_vect(pt1:pt2,1)=1;
    end
end

if isempty(AT_times)==0
    for i=1:size(AT_times,1)
        
        pt1=round((AT_times(i,1)-Time_Exclu)*SR_WP);
        pt2=round((AT_times(i,2)+Time_Exclu)*SR_WP);
        
        pt1=max([pt1 1]);
        pt2=min([pt2 Sweep_length]);
        AT_vect(pt1:pt2,1)=0;
    end
end


Stat_vect_clean=Stat_vect.*AT_vect;

% set first and last points to 0
Stat_vect_clean(1:5)=0;
Stat_vect_clean(end-5:end)=0;
% identify times of transitions
Stat_vect_clean_der=diff(Stat_vect_clean);
[Amp,Index_On]=findpeaks(Stat_vect_clean_der, 'MinPeakHeight',0.1);
Stat_vect_clean_der=Stat_vect_clean_der.*-1;
[Amp,Index_Off]=findpeaks(Stat_vect_clean_der, 'MinPeakHeight',0.1);

cnt=1;
for i=1:size(Index_On,1)
    
    Wind_Numb=floor((Index_Off(i,1)-Index_On(i,1))/Window_Length);
    
    if Wind_Numb>0
        
        for k=1:Wind_Numb
            
            Selected_Times(cnt,1)=Index_On(i,1)+Window_Length*(k-1);
            cnt=cnt+1;
        end
    end
    
end

Selected_Times=Selected_Times./SR_WP;

end