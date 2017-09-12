    function [locs] = segmentSignal(accel, freq)
    %segmentSignal Detect individual compressions in an accerleation signal
    %   Use MATLAB's built-in peak detection and a combination of filters and
    %   trimming parameters to locate the beginning of individual compression.
    %   Returns: index of each compression
    %   ---
    %   Authour: Chris Williams | Last Updated: April 10, 2017
    %   McMaster University 2017

    %Detect compression indicator peaks
    [pks,locs]  = findpeaks(accel,'MINPEAKHEIGHT',-1);
    [ ~ ,lows]  = findpeaks(-accel,'MINPEAKHEIGHT',3);

    %Seperate peaks and drop-offs
    highs = locs(pks>3);
    locs  = locs(pks<3);
    pks = pks(pks<3);

    %Define trimming params as a function of Fs
    min_spc =  floor(0.15/(1/freq));
    pk_spc  =  floor(0.2/(1/freq));

    %Discard lows that do not come before a peeak
    for i = 1:length(lows)
        [~,index] = min(abs(highs-lows(i)));
        if highs(index)-lows(i)<0 %| highs(index)-lows(i)<spc/5 %3 sample gap
            lows(i) = 0;
        end
    end
    lows = lows(lows~=0);

    %Look for compressions by detecting signal drop-off;
    for i = 1:length(locs)
        %Reject drop-off if too far from low
        [~,index] = min(abs(lows-locs(i)));
        if isempty(index)
            break
        end
        if lows(index)-locs(i)>pk_spc || lows(index)-locs(i)<0%CHECK OPERAND ERROR
            locs(i) = 0;
        end
    end
    locs = locs(locs~=0);

    %Remove redundant pre-peaks
    for i = 2:length(locs)
        if locs(i)-locs(i-1) < min_spc
            locs(i-1) = 0;
        end
    end
    locs = locs(locs~=0);

    %Check for no peak case
    if length(locs)<2||length(lows)<2
        locs = -2;
        return
    end

end

