function [Whisking_Times]= findwhisktime(WPsweep, SR) % Classify Whisker movement states

detect_Thrs=0.3; % Threshold to detect Active states
merge_on=0.4; % threshold to merge active states (s)
delete_Act=0.1; % threshold to delete active states (s)

% substract median value and filter WP between 0.01 Hz and 40 Hz
WPsweep=WPsweep-median(WPsweep);
[Zs, Ps, K] = ellip(4,.1,20,[0.01 40]*2/SR);
[SOS, G] = zp2sos(Zs,Ps,K);
filt_WPsweep=filtfilt(SOS,G,WPsweep);
% compute power of 1st derivative
filt_WPsweep_der = diff(filt_WPsweep);
WPsweep_Pow = filt_WPsweep_der.^2;

clear filt_WPsweep filt_WPsweep_der
% Compute whisking states / Threshold (Thrs) => 1= active, 0= inactive
WP_Stat1=(WPsweep_Pow-detect_Thrs);
WP_Stat1=WP_Stat1./abs(WP_Stat1);
WP_Stat1=(WP_Stat1+1)./2;
% set first and last points to 0
WP_Stat1(1:5)=0;
WP_Stat1(end-5:end)=0;
% identify times of transitions
WP_Stat1_der = diff(WP_Stat1);
[Amp, Time_On] = findpeaks(WP_Stat1_der, 'MinPeakHeight',0.1);
WP_Stat1_der = WP_Stat1_der.*-1;
[Amp, Time_Off] = findpeaks(WP_Stat1_der, 'MinPeakHeight',0.1);
% Compute the time difference between 2 consecutive Active states and merge
% them if < merge_on time
merge_on=merge_on*SR;
if isempty(Time_On)~=1
    Time_On(1)=[];
    Time_Off(end)=[];
    
    Delta_Act=Time_On-Time_Off;
    
    WP_Stat2=WP_Stat1;
    
    for int=1:length(Delta_Act)
        
        if Delta_Act(int)<merge_on
            WP_Stat2(Time_Off(int):Time_On(int))=1;
        end
        
    end
    
    clear WP_Stat1 WP_Stat1_der
    
    % Compute duration of Active states and delete them if < delete_Act
    
    delete_Act=delete_Act*SR;
    
    WP_Stat2_der=diff(WP_Stat2);
    [Amp, Time_On]=findpeaks(WP_Stat2_der, 'MinPeakHeight',0.1);
    WP_Stat2_der=WP_Stat2_der.*-1;
    [Amp, Time_Off]=findpeaks(WP_Stat2_der, 'MinPeakHeight',0.1);
    Delta_On=Time_Off-Time_On;
    
    WP_Stat3=WP_Stat2;
    
    for int=1:length(Delta_On)
        
        if Delta_On(int)<delete_Act+1
            WP_Stat3(Time_On(int):Time_Off(int))=0;
        end
        
    end
    
    clear WP_Stat2 WP_Stat2_der
    
    WP_Stat3_der=diff(WP_Stat3);
    [Amp, Time_On]=findpeaks(WP_Stat3_der, 'MinPeakHeight',0.1);
    WP_Stat3_der=WP_Stat3_der.*-1;
    [Amp, Time_Off]=findpeaks(WP_Stat3_der, 'MinPeakHeight',0.1);
    
    
    Whisking_Times=horzcat(Time_On, Time_Off);
    Whisking_Times=Whisking_Times./SR;
    
else
    Whisking_Times=[];
end

end
