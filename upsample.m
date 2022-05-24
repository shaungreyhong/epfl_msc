function [signal_upsmp] = upsample(Signal, Samp_Fact)

signal_upsmp=[];
idx=1;

for i=1:length(Signal)-1
    
    Seg=linspace(Signal(i),Signal(i+1), Samp_Fact+1)';
    
    for samp=1:Samp_Fact
        signal_upsmp(idx,1)=Seg(samp,1);
        idx=idx+1;
    end
    
end

Dsign=Signal(i+1)-Signal(i);
Seg=Seg-Dsign;

for samp=1:Samp_Fact
    signal_upsmp(idx,1)=Seg(samp,1);
    idx=idx+1;
end

end