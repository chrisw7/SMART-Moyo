function [RATE,DEPTH] = process(time, accel,OUTPUT)
    %process Compute mean rate & depth of compressions from acceleration signal
    %   [RATE,DEPTH] = process(T,A) returns vectors containing the rates and
    %   depths of a compression interval in bpm/cm, respectively.
    %
    %   [RATE,DEPTH] = process(T,A,OUTPUT) computes rate and depth with the
    %   default parameters replaced by values in OUTPUT.
    %   ---
    %   Authors: Chris Williams, Junaid Siddiqui | Last Updated: September 25, 2017
    %   McMaster University 2017
    
    %For debugging purposes
    OUTPUT.simple = 0;
    OUTPUT.debug = 1;
    clf
    
    %Check for idle IMU
    if ~activity(accel)
        RATE = [-3 -3];
        DEPTH = [-3 -3];
        fprintf('---\nNo compressions detected\n\n')
        return
    end
    
    %Official recommended ranges for CPR rate (cpm) & depth (cm)
    CPR_MINRATE  = 100; CPR_MAXRATE  = 120;
    CPR_MINDEPTH = 5; CPR_MAXDEPTH = 6;

    %Accepted tolerances for rate/depth approximations.
    TOL_RATE  = 5; TOL_DEPTH = 1;

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
    vel = zeros(length(time),1); dv = vel;
    dis = vel; ds = vel; 

    %Compute raw velocity & displacement
    for i = locs(1):length(vel)
        vel(i) = vel(i-1)+(accel(i)+accel(i-1))*(1/Fs)/2;
        dis(i) = dis(i-1)+(vel(i)+vel(i-1))*(1/Fs)/2;
    end

    %Zero-reset algorthim
    for i = locs(1):length(vel)
        if any(locs == i)
            dv(i) = 0;
            ds(i) = 0;
        else
            dv(i) = dv(i-1)+(accel(i)+accel(i-1))*(1/Fs)/2;
            ds(i) = ds(i-1)+(dv(i)+dv(i-1))*(1/Fs)/2;
        end
    end

    %==========================================================================
    %                               Calculations
    %--------------------------------------------------------------------------

    %Calculated compression depth (cm) and rate(per min)
    CD = zeros(length(locs)-1,1);
    [comp_accel, comp_time]  = findpeaks(accel, 'MINPEAKHEIGHT', max(accel)/2.5, 'MINPEAKDISTANCE', 25);
    comp_time = time(comp_time);
    CPM = 60/mean(diff(comp_time));
    for i = 2:length(locs)
        intv = ds(locs(i-1):locs(i));
        CD(i-1) = 100*(max(intv)-min(intv));
    end

    %-------------------------------------
    %        Spectral Analysis
    %-------------------------------------
    %Zero padding 
    N = length(time);
    
    %Apply hamming window over interval
    w = hann(length(accel));
    coherent_gain = sum(w)/length(accel);
    A_h = accel.*w/coherent_gain;

    %Extract windowed double sided-fft for phase and frequency analysis
    fft_polar_double = fft(A_h,N)/N;
    fft_polar_single = fft_polar_double(1:N/2 + 1);
    fft_polar_single(2:end - 1) = 2*fft_polar_single(2:end-1);

    fft_smooth_single = abs(fft_polar_single);
    fft_smooth_single(2:end - 1) = 2*fft_smooth_single(2:end - 1);
    

    %Scale frequency bins
    f_bin = Fs*(0:(N/2))/N;


    %Find first 3 largest peaks
    [ampl,Fs] = findpeaks(abs(fft_smooth_single),...
        'MINPEAKHEIGHT',max(abs(fft_smooth_single))/3,...
        'MINPEAKDISTANCE',2);

    %Number of harmonics to extract from fft
    harmonics = length(ampl);
    if harmonics > 3
        harmonics = 3;
   end
   
    %Calculating phase shift of acceleration
    z = fft_polar_single(Fs(1:harmonics));
    theta = atan(imag(z)./real(z));
    
    %Using fundamental frequency
    fcc = f_bin(Fs(1));

    %Calculting S_k (cm) given A_k (m/s^2 and fcc, and finding phase change 
    A_k = ampl';
    S_k = A_k(1:harmonics)./((2*pi*[1:harmonics]*fcc).^2)*100;
    phi = theta + pi;
    
    %Calculating displacement series  
    sofT = 0;
    for i= 1:harmonics
        sofT = sofT + S_k(i)*cos(2*pi*i*fcc*time + phi(i));
    end
    
    %Number of compressions/min and compressions depths
    %from spectral analysis
    sCPM = 60 * fcc;
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
        %RATE(2)  = floor(CPM);
        %DEPTH(2) = sCD;
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
        subplot(414);hold on;%--------------------------Segmented Signal
        plot(time,accel, 'b');
        xlabel('Elapsed Time (s)');
        ylabel('Acceleration (m/s/s)');
        title("Acceleration vs Time");
        vline(time(locs),':k');
        
        subplot(411);hold on;%--------------------------Windowed Signal
        plot(time, A_h, '');
        xlabel('Elapsed Time (s)');
        ylabel('Acceleration (m/s/s)');
        title("Hamming Window Applied");
        vline(time(locs),':k');

        subplot(412); hold on;%--------------------------Spectral Analysis
        plot(f_bin, fft_smooth_single, 'b');
        plot(f_bin(Fs), ampl,':vk');
        xlabel('Frequency (Hz)');
        ylabel('Spectral Amplitude');
        title("Fast Fourier Transformed Graph");
        xlim([0 25]);

        subplot(413); hold on;%--------------------------Displacement
        plot(time, sofT, 'g');
        plot(time, 100*ds,'-.r');
        xlabel('Elapsed Time (s)');
        ylabel('Displacement (cm)');
        title("Displacement vs Time");
        ylim( [ -min(DEPTH) max(DEPTH) ] );
        vline(time(locs),':k');
    end
end
