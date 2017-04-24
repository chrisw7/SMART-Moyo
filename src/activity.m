function [COMPS] = activity(a)
%activity Check for movement in an acceleration signal
%   Check range/number of compressions, return true if motion detected
%   ---
%   Authour: Chris Williams | Last Updated: April 24, 2017
%   McMaster University 2017

if max(a) < 2 && min(a) > -2
    COMPS = false;
else
    
    locs = segmentSignal(a,100);
    
    if length(locs)<=2
        COMPS = false;
    else
        COMPS = true;
    end
        
    
end

