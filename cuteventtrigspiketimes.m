function [Mtrx] = cuteventtrigspiketimes(Duration, SpikeTimes, Event_Times, Pre_Window, Post_Window, Bin_Size)

Pre_bin=round(Pre_Window/Bin_Size);
Post_bin=round(Post_Window/Bin_Size);

Mtrx=[];
cnt=1;
  
for i=1:size(Event_Times, 1)
         
        pt1=floor((Event_Times(i,1)+Pre_Window)*SR); 
        pt2=pt1+floor((Post_Window-Pre_Window)*SR)-1;
        
        if pt1>0 && pt2<length(Signal)
            
            Mtrx(:,cnt)=Signal(pt1:pt2,1); % cut the Vm around the event time
            
            cnt=cnt+1;
        end
    end
    
end



