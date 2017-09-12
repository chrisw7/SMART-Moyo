function [COMPS] = activity(accel)
%activity Check for movement in an acceleration signal
%   Check range/number of compressions, return true if motion detected
%   ---
%   Authour: Chris Williams | Last Updated: April 24, 2017
%   McMaster University 2017

if max(accel) < 2 && min(accel) > -2
    COMPS = false;
else
    
    locs = segmentSignal(accel,100);
    
    if length(locs)<=2
        COMPS = false;
    else
        COMPS = true;
    end
        
    
end

