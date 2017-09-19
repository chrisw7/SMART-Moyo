function [RATE,DEPTH] = process(time, accel,OUTPUT)
    %process Compute mean rate & depth of compressions from acceleration signal
    %   [RATE,DEPTH] = process(T,A) returns vectors containing the rates and
    %   depths of a compression interval in bpm/cm, respectively.
    %
    %   [RATE,DEPTH] = process(T,A,OUTPUT) computes rate and depth with the
    %   default parameters replaced by values in OUTPUT.
    %   ---
    %   Authour: Chris Williams | Last Updated: April 18, 2017
    %   McMaster University 2017
    
    %For debugging purposes
    if OUTPUT.simple == 1
        OUTPUT.debug = 0;
    end
    
    %Check for idle IMU
    if ~activity(accel)
        RATE = [-3 -3];
        DEPTH = [-3 -3];
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

    %Sampling frequency
    Fs = 1/(time(2)-time(1));

    %Locate individual compressions
    locs = segmentSignal(accel,Fs);

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
    vel = zeros(length(time),1);
    dis = vel;
    dv = vel;
    zS = vel;

    %Compute raw velocity & displacement
    for i = locs(1):length(vel)%ERR: subscript must be integer (check first index in range)
        vel(i) = vel(i-1)+(accel(i)+accel(i-1))*(1/Fs)/2;
        dis(i) = dis(i-1)+(vel(i)+vel(i-1))*(1/Fs)/2;
    end

    %Zero-reset algorthim
    for i = locs(1):length(vel)
        if any(locs == i)
            dv(i) = 0;
            zS(i) = 0;
        else
            dv(i) = dv(i-1)+(accel(i)+accel(i-1))*(1/Fs)/2;
            zS(i) = zS(i-1)+(dv(i)+dv(i-1))*(1/Fs)/2;
        end
    end

    %==========================================================================
    %                               Calculations
    %--------------------------------------------------------------------------

    %Calculated compression depth (cm) and rate(per min)
    CD = zeros(length(locs)-1,1);
    CPM = (length(locs)-1 )/(time(locs(end))-time(locs(1)))*60;
    for i = 2:length(locs)
        intv = zS(locs(i-1):locs(i));
        CD(i-1) = 100*(max(intv)-min(intv));
    end

    %-----------------
    %Spectral Analysis
    %-----------------
    N = 2^nextpow2(length(time)*2);
    
    %Apply hamming window over interval
    w = hann(length(accel));
    coherent_gain = sum(w)/length(accel);
    A_h = accel.*w/coherent_gain;

    %Extract windowed double sided-fft
    fft_polar_double = fft(A_h,N)/N;
    fft_polar_single = fft_polar_double(1:N/2 + 1);
    fft_polar_single(2:end - 1) = 2*fft_polar_single(2:end-1);

    fft_smooth_double = abs(fft_polar_double);
    fft_smooth_single = fft_smooth_double(1:N/2 + 1);
    fft_smooth_single(2:end - 1) = 2*fft_smooth_single(2:end - 1);

    %Scale frequency bins
    f_bin = Fs*(0:(N/2))/N;
 
    %Find first 3 largest peaks
    %See what's the point of fft_raw_single
    [ampl,Fs] = findpeaks(abs(fft_smooth_single),...
        'MINPEAKHEIGHT',max(abs(fft_smooth_single))/3,...
        'MINPEAKDISTANCE',5);

    %Calculating phase shift of acceleration (Completed?)
    z = zeros(length(ampl), 1);
    for i = 1:length(ampl)
       z(i) = fft_polar_single(Fs(i));
    end
    theta = imag(z)./real(z);

    %Number of harmonics to extract from fft
    harmonics = length(ampl);
    if harmonics > 4
        harmonics = 4;
    end

    %Calculting S_k given A_k, fcc and number of harmonics
    A_k = ampl;
    S_k = zeros(length(harmonics),1);
    for i= 1:harmonics
        S_k(i) = (1000*A_k(i))/(2*pi*i*f_bin(Fs(i)))^2;
    end
       
    %Calculating displacement series, s(t)
    sofT=0;
    phi = theta + pi;
    for i = 1:harmonics
        sofT = sofT + S_k(i)*cos(2*pi*i*f_bin(Fs(i))*time + phi(i));
    end
    %Find rate, and  check to see if graph is right, because it looks too deep

    %Extract mean freq. (1/min) from first three harmonics (rate)
    sCPM = 0;
    for i = 1:harmonics
        sCPM = sCPM + f_bin(Fs(i))/i;
    end
    sCPM = sCPM/harmonics * 60;

    %Calculate compression depths from reconstructed displacement signal
    sCD = range(sofT);

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
        addpath('../utils');
        
        %Use CMU colors (dependency)
        c = @colors; g = c('office green'); o = c('deep carrot orange');

        %Console Output
        fprintf('\n======================================================\n')
        cprintf('*text','\t\t\t\t\tDebug Log\n\t\t\t  ')
        fprintf(datestr(now));
        fprintf('\n======================================================\n\n')
        cprintf('-text', '%i Compressions Detected in %is\n\n', ...
            [length(locs), round(time(end))])

        cprintf(o, 'Numerical Analysis\n')
        fprintf('------------------\n')
        fprintf('Compression Rate :\t\t%i\t\tbpm\n',    floor(CPM));
        fprintf('Compression Depth:\t\t%0.2f\tcm\n',    mean(CD));
        cprintf(o, '\nSpectral Analysis\n')
        fprintf('------------------\n')
        fprintf('Compression Rate :\t\t%i\t\tbpm\n',    floor(sCPM));
        fprintf('Compression Depth:\t\t%0.2f\tcm\n\n',  sCD);
        
        fprintf('Difference in Rate :\t\t%i\t\tbpm\n',    abs(diff(RATE)));
        fprintf('Difference in Depth:\t\t%0.2f\tcm\n\n',  abs(diff(DEPTH)));
        
        if floor(CPM) > (CPR_MAXRATE+TOL_RATE)
            cprintf('r', 'Too fast');
        elseif floor(CPM) < (CPR_MINRATE-TOL_RATE)
            cprintf('r', 'Too slow');
        else
            cprintf(g,'Good rate');
        end
        cprintf('text', '; ');
        
        if sCD > (CPR_MAXDEPTH+TOL_DEPTH)
            cprintf('r', 'too deep')
        elseif sCD < (CPR_MINDEPTH-TOL_DEPTH)
            cprintf('r', 'too shallow');
        else
            cprintf(g, 'good depth')
        end
        cprintf('text', '; ');
                     
        if abs(diff(RATE)) > TOL_RATE
            cprintf('r', 'inconsistent rate ')
        else
            cprintf(g, 'consistent rate ')
        end
            cprintf('text', 'calculation; ');
        
        if  abs(diff(DEPTH)) > TOL_DEPTH
            cprintf('r', 'inconsistent depth ')
        else
            cprintf(g, 'consistent depth ')
        end
        cprintf('text', 'calculation; \n');
        fprintf('======================================================\n\n')

        %---Plots
        %     figure
        subplot(411);hold on;%--------------------------Segmented Signal
        plot(time,accel, 'b');
        xlabel('Elapsed Time (s)');
        ylabel('Acceleration (m/s/s)');
        title("Acceleration vs Time");
        ylim([-10 10]);
        vline(time(locs),':k');
        
        subplot(412);hold on;%--------------------------Windowed Signal
        plot(time, A_h, '');
        xlabel('Elapsed Time (s)');
        ylabel('Acceleration (m/s/s)');
        title("Hamming Window Applied");
        ylim([-10 10]);
        vline(time(locs),':k');

        subplot(413); hold on;%--------------------------Spectral Analysis
        plot(f_bin, fft_smooth_single, 'b');
        plot(f_bin(Fs), ampl,':vk');
        xlabel('Frequency (Hz)');
        ylabel('Spectral Amplitude');
        title("Fast Fourier Transformed Graph");
        xlim([0 25]);

        subplot(414); hold on;%--------------------------Displacement
        plot(time, sofT, 'g');
        plot(time, 100*zS,'-.r');
        xlabel('Elapsed Time (s)');
        ylabel('Displacement (cm)');
        title("Displacement vs Time");
        ylim([-8 8]);
        vline(time(locs),':k');
    end
end
