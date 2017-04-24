function [ comps ] = activity(a)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if max(a) < 2 && min(a) > -2
    comps = false;
else
    
    [pks,locs] = findpeaks(a,'MINPEAKHEIGHT',-.5);
    locs = locs(pks<1.25);
    pks = pks(pks<1.25);
    
    %Remove pre-peaks
    for i = 2:length(locs)
        if locs(i)-locs(i-1) < 15
            locs(i-1) = 0;
            pks(i-1)  = 0;
        end
    end
    
    % pks = pks(LOCS~=0);
    locs = locs(locs~=0);
    
    if length(locs)<=2
        comps = false;
    else
        comps = true;
    end
        
    
end

