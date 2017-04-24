function [RATE,DEPTH] = process(T,A,OUTPUT)
%process Compute mean rate & depth of compressions from acceleration signal
%   [RATE,DEPTH] = process(T,A) returns vectors containing the rates and
%   depths of a compression interval in bpm/cm, respectively.
%
%   [RATE,DEPTH] = process(T,A,OUTPUT) computes rate and depth with the
%   default parameters replaced by values in OUTPUT.
%   ---
%   Authour: Chris Williams | Last Updated: April 18, 2017
%   McMaster University 2017

%Check for idle IMU
if ~activity(A)
    RATE = -3;
    DEPTH = -3;
    fprintf('---\nNo compressions detected\n\n')
    return
end

%Official recommended ranges for CPR rate (cpm) & depth (cm)
CPR_MINRATE  = 100;
CPR_MAXRATE  = 120;

CPR_MINDEPTH = 5;
CPR_MAXDEPTH = 6;

%Accepted tolerances for rate/depth approximations.
TOL_RATE  = 5;
TOL_DEPTH = 1;

%Calculate sampling period and freq.
Fs = 1/(T(2)-T(1));

%Locate individual compressions
locs = segmentSignal(A,Fs);
if locs(1) == -2
    RATE = -2;
    DEPTH = -2;
    fprintf('---\nBad compressions\n\n')
    return
end

%==========================================================================
%                           Numerical Integration
%--------------------------------------------------------------------------

%Initialize integrated values
V = zeros(length(T),1);
S = V;
zV = V;
zS = V;

%Compute raw velocity & displacement
for i = locs(1):length(V)%ERR: subscript must be integer (check first index in range)
    V(i) = V(i-1)+(A(i)+A(i-1))*(1/Fs)/2;
    S(i) = S(i-1)+(V(i)+V(i-1))*(1/Fs)/2;
end

%Zero-reset algorthim
for i = locs(1):length(V)
    if any(locs == i)
        zV(i) = 0;
        zS(i) = 0;
    else
        zV(i) = zV(i-1)+(A(i)+A(i-1))*(1/Fs)/2;
        zS(i) = zS(i-1)+(zV(i)+zV(i-1))*(1/Fs)/2;
    end
end

%==========================================================================
%                               Calculations
%--------------------------------------------------------------------------

CD = zeros(length(locs)-1,1);
for i = 2:length(locs)
    intv = zS(locs(i-1):locs(i));
    CD(i-1) = 100*(max(intv)-min(intv));
end
CPM = (length(locs)-1 )/(T(locs(end))-T(locs(1)))*60;

%-----------------
%Spectral Analysis
%-----------------
N = 8192;

%Apply hamming window over interval
A_h = A.*hamming(length(A));

%Compute DFT, extract single-sided amplitude
fft_raw = fft(A,N)/length(A);

%Extract windowed fft
fft_smooth = fft(A_h,N)/length(A_h);
fft_single = fft_smooth(1:N/2+1);
fft_single(2:end-1) = 2*fft_single(2:end-1);

%Scale frequency bins
f = Fs*(0:N/2)/N;

[ampl,freq] = findpeaks(abs(fft_single),...
    'MINPEAKHEIGHT',max(abs(fft_raw))/3,...
    'MINPEAKDISTANCE',10);

%Number of harmonics to extract from fft
Nf=length(ampl);
if Nf >5
    Nf = 5;
end

%Extract mean freq. from first three harmonics
if length(freq)>=3
    sCPM = 60 *( f(freq(1))  + f(freq(2))/2 + f(freq(3))/3 )/3;
else
    sCPM = 60 * f(freq(1));
end

%Reconstruct displacement signal
A_k = 2*ampl;
S_k = zeros(length(T),1);
for k = 1:Nf
    S_k = S_k + ...
        (100*A_k(k)/(2*pi*k*f(freq(k)))^2)*cos(2*pi*f(freq(k))*T) ...
        + (100*A_k(k)/(2*pi*k*f(freq(k)))^2)*sin(2*pi*f(freq(k))*T);
end

%Calculate compression depths from reconstructed displacement signal
sCD = range(S_k);

%==========================================================================
%                               Output
%--------------------------------------------------------------------------
RATE  = [floor(CPM) floor(sCPM)];
DEPTH = [mean(CD)   sCD];

if OUTPUT.simple
    if floor(CPM) > (CPR_MAXRATE+TOL_RATE)
        RATE = 1;
    elseif floor(CPM) < (CPR_MINRATE-TOL_RATE)
        RATE = -1;
    else
        RATE = 0;
    end
    
    if sCD > (CPR_MAXDEPTH+TOL_DEPTH)
        DEPTH = 1;
    elseif sCD < (CPR_MINDEPTH-TOL_DEPTH)
        DEPTH = -1;
    else
        DEPTH = 0;
    end
    
    %FOR TESTING PURPOSES
    RATE(2)  = floor(CPM);
    DEPTH(2) = sCD;
else
    fprintf('%i Compressions Detected\n\n',            length(locs));
    fprintf('Compression Rate :\t\t%i\tbpm\n',         RATE(1));
    fprintf('Compression Depth:\t\t%0.2f\tcm\n',       DEPTH(1));
end

if OUTPUT.debug
    %Use CMU colors (dependency)
    c = @colors; g = c('office green');o = c('deep carrot orange');
    
    
    %Console Output
    fprintf('\n======================================================\n')
    cprintf('*text','\t\t\t\t\tDebug Log\n\t\t\t  ')
    fprintf(datestr(now));
    fprintf('\n=======================================================\n\n')
    cprintf('-text', '%i Compressions Detected in %is\n\n', ...
        [length(locs), round(T(end))])
    
    cprintf(o, 'Numerical Analysis\n')
    fprintf('------------------\n')
    fprintf('Compression Rate :\t\t%i\t\tbpm\n',    floor(CPM));
    fprintf('Compression Depth:\t\t%0.2f\tcm\n',    mean(CD));
    cprintf(o, '\nSpectral Analysis\n')
    fprintf('------------------\n')
    fprintf('Compression Rate :\t\t%i\t\tbpm\n',    floor(sCPM));
    fprintf('Compression Depth:\t\t%0.2f\tcm\n\n',  sCD);
    
    if floor(CPM) > (CPR_MAXRATE+TOL_RATE)
        cprintf('r', '(Too fast');
        cprintf('text', ', ');
    elseif floor(CPM) < (CPR_MINRATE-TOL_RATE)
        cprintf('r', '(Too slow');
        cprintf('text', ', ');
    else
        cprintf(g,'(Good rate');
        cprintf('text', ', ');
    end
    
    if sCD > (CPR_MAXDEPTH+TOL_DEPTH)
        cprintf('r', 'too deep')
        cprintf('text', '; ');
    elseif sCD < (CPR_MINDEPTH-TOL_DEPTH)
        cprintf('r', 'too shallow');
        cprintf('text', '; ');
    else
        cprintf(g, 'good depth')
        cprintf('text', '; ');
    end
    
    if abs(diff(RATE)) > TOL_RATE || abs(diff(DEPTH)) > TOL_DEPTH
        cprintf('r', 'inconsistent ')
    else
        cprintf(g, 'consistent ')
    end
    cprintf('text', 'calculations)\n');
    fprintf('=======================================================\n\n')
    
    %---Plots
    %     figure
    subplot(311);hold on;%--------------------------Segmented Signal
    plot(T,A);
    xlabel('Elapsed Time (s)');
    ylabel('Acceleration (m/s/s)');
    ylim([-10 10]);
    vline(T(locs),':k');
    
    subplot(312);hold on;%--------------------------Spectral Analysis
    plot(f,abs(fft_single));
    plot(f(freq),ampl+0.02,'vk');
    xlabel('Frequency (Hz)')
    ylabel('Spectral Amplitude')
    xlim([0 25]);
    
    subplot(313);hold on;%--------------------------Displacment
    plot(T,S_k-max(S_k));plot(T,100*zS,':k')
    xlabel('Elapsed Time (s)')
    ylabel('Displacement (cm)')
end
end

