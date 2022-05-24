function [Vm_Sub] = cutactpotent(MembranePotential, SR_Vm, Range)

% MembranePotential is the original Vm trace
% SR_Vm is the sampling rate of the Vm trace (Hz)
% Range = 'V' or 'mV' is the unit of the Vm trace

% Parameters

AP_Win=0.0015; % time (s) to search for AP's peak

AP_length=round(AP_Win*SR_Vm);
if strcmp(Range, 'V')
Min_AP_Amp= 0.005; % Minimum AP amplitude (V)
Vm_Deriv_Thrs=15;% AP threshold (V/s)
elseif strcmp(Range, 'mV')
Min_AP_Amp= 5; % Minimum AP amplitude (mV)
Vm_Deriv_Thrs=15000;  % AP threshold (mV/s)
end


%
AP_Thrs_Index=[];
AP_Param=[]; % 1col= Thrs_Times, 2col=Thrs_Vm, 3col=Peak_Times, 4col=Peak_Vm, 5col= Peal_Amp

%
Vm_Deriv=diff(MembranePotential)*SR_Vm;
AP_Thrs_Onset= diff((Vm_Deriv-Vm_Deriv_Thrs)./abs(Vm_Deriv-Vm_Deriv_Thrs));

Vm_Med=median(MembranePotential);

[Peaks, AP_Thrs_Index] = findpeaks(AP_Thrs_Onset, 'MinPeakHeight', 0.1, 'MinPeakProminence',0.5, 'MinPeakDistance',SR_Vm*0.001);

if isempty(AP_Thrs_Index)==0
    
    AP_cnt=1;
    
    for i=1:size(AP_Thrs_Index,1)
        
        pt1=AP_Thrs_Index(i,1);
        pt2=AP_Thrs_Index(i,1)+AP_length;
        
        if pt2<length(MembranePotential)
            
            AP_Seg=MembranePotential(pt1:pt2,1);
            [Max, Ind]=max(AP_Seg);
            
            if isempty(Ind)==0
                
                AP_Index=pt1+Ind(1,1)-1;
                
                AP_Amp=MembranePotential(AP_Index,1)-MembranePotential(pt1,1);
                
                if AP_Amp>Min_AP_Amp && MembranePotential(AP_Index,1)>Vm_Med
                    
                    AP_Param(AP_cnt,1)=AP_Thrs_Index(i,1)/SR_Vm; % Thrs Time
                    AP_Param(AP_cnt,2)=MembranePotential(AP_Thrs_Index(i,1),1); % Thrs Vm
                    AP_Param(AP_cnt,3)=AP_Index/SR_Vm; % Peak Time
                    AP_Param(AP_cnt,4)=MembranePotential(AP_Index,1); % Peak Vm            
                    AP_Param(AP_cnt,5)=AP_Amp; % Peak Amp
                                        
                    AP_cnt=AP_cnt+1;
                    
                end
            end
        end
    end
    
end

%% Remove APs that have peak height and Amplitude < 5x std

if isempty(AP_Param)==0
    
Amp_Lim_Inf=min(median(AP_Param(:,5))-5*std(AP_Param(:,5)), 0.03);
Peak_Lim_Inf= min(median(AP_Param(:,4))-5*std(AP_Param(:,4)), -0.02);


cnt_Max=size(AP_Param,1);

for i=1:cnt_Max
    
    cnt=cnt_Max-i+1; 
    if AP_Param(cnt,5)< Amp_Lim_Inf && AP_Param(cnt,4)< Peak_Lim_Inf
        AP_Param(cnt,:)=[];
    end
end


AP_Peak_Times=AP_Param(:,3);
AP_Thrs_Times=AP_Param(:,1);
% AP_Thrs_Vm=AP_Param(:,2);
% AP_Peak_Vm=AP_Param(:,4);
        
% Parameters

AP_End_Wind=0.015; % time window to look for AP end after AP peak (s)

%

Vm_Sub=[];
Vm_Sub=MembranePotential;

AP_Thrs_Index=round(AP_Thrs_Times.*SR_Vm);
AP_Peak_Index=round(AP_Peak_Times.*SR_Vm);

for Ind=1:size(AP_Peak_Index,1)
    
    pt1=AP_Thrs_Index(Ind,1);
    pt2=AP_Peak_Index(Ind,1);
    pt4=min(length(MembranePotential),pt2+round(AP_End_Wind*SR_Vm));
    
    Vm_Thrs=MembranePotential(pt1,1);
    
    AP_seg=smooth(MembranePotential(pt1:pt4,1),SR_Vm/2000);
    
    cond=0;
    n2=pt2-pt1+20;
    
    while cond==0
        
        n2=n2+1;
        
        if n2>length(AP_seg)
            pt_end=pt1+n2;
            cond=1;
        else
            D_Vm1=AP_seg(n2-1,1)-Vm_Thrs;
            D_Vm2=AP_seg(n2,1)-Vm_Thrs;
            
            if D_Vm2<0
                pt_end=pt1+n2;
                cond=1;
            end
            
            if D_Vm2>D_Vm1
                pt_end=pt1+n2;
                cond=1;
            end
        end
        
    end
    
    pt3=min(length(MembranePotential), pt_end);
    
    % make a segment 'in' between Vm(pt1) and Vm(pt2)
    Delta_Vm=MembranePotential(pt3)-MembranePotential(pt1);
    in=0:1:pt3-pt1; % create a small vector starting at 0, with increment of 1, of (pt2-pt1) points
    in=(in./(pt3-pt1))*Delta_Vm; % create a segment of (pt2-pt1) points from 0 to Delta_Vm
    in=in+MembranePotential(pt1); % add the Vm at pt1 to the segment in
    
    Vm_Sub(pt1:pt3,1)=in; 
end

else
    
Vm_Sub=MembranePotential;

end