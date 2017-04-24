Ts = (1/100);
[pks,slocs] = findpeaks(a,'MINPEAKHEIGHT',-1);
[~,lows] = findpeaks(-a,'MINPEAKHEIGHT',3);

if isempty(slocs)||isempty(lows)
    return
end

peaks = slocs(pks>3);
slocs = slocs(pks<3);
% pks = pks(pks<2);

plot(a)
% vline((peaks),':b')
% vline((valley_locs),':g')

%Remove pre-peaks within 0.1s of e/o

pre_spc = floor(0.2/Ts);
v_spc = floor(0.2/Ts);


for i = 1:length(lows)
    %Find the index of the closest peak, reject if valley is after peak
    [~,index] = min(abs(peaks-lows(i)));
    errs(i) = peaks(index)-lows(i);
    if peaks(index)-lows(i)<0 %|| peaks(index)-lows(i)<0.02/Ts
        lows(i) = 0;
    end
end

lows = lows(lows~=0);

for i = 1:length(slocs)
    %Find the index of the closest trough, reject if comp start too far
    [~,index] = min(abs(lows-slocs(i)));
    errs2(i) = lows(index)-slocs(i);
    if lows(index)-slocs(i)>v_spc || lows(index)-slocs(i)<0
        slocs(i) = 0;
    end
end
slocs = slocs(slocs~=0);
t_locs = slocs;

for i = 2:length(slocs)
    
    if slocs(i)-slocs(i-1) < pre_spc
        t_locs(i-1) = 0;
%         pks(i-1)  = 0;
    end
end
t_locs = t_locs(t_locs~=0);


(length(t_locs)-1 )/(t(t_locs(end))-t(t_locs(1)))*60

% vline((slocs),'-b')
vline(lows,':r')
vline(slocs,':b')
vline((t_locs),'--k')