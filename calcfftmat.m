function [FFT_Mtrx] = calcfftmat(Sign_Mtrx, SR, TimeWindow)

step=TimeWindow*SR;
nfft = 2^nextpow2(step); % Calculate the next power of 2 for padding
window = hanning(step); % Hanning Window

FFT_Mtrx=[];

for s=1:size(Sign_Mtrx,2)
   Seg=[];
   Seg_fft=[];
   P1=[];
   p2=[];
   
    Seg=Sign_Mtrx(:,s);
    Seg=Seg-mean(Seg); % remove the DC component at 0 Hz
    Seg_fft=fft(Seg.*window,nfft); % compute the FFT for the segment Seg
    
    P2=abs(Seg_fft/step); % compute the spectrogram
    P1=P2(1:nfft/2+1);
    P1(2:end-1)=2*P1(2:end-1);
    FFT_Mtrx(:,s)=P1; % make a matrix containing all the FFTs
    
end

end




        
 