%% Do Simulations for the Paper
% a) Give input with PLE from 0 to 1.6 with steps of 0.2
% b) Give input as a boxcar on top of white noise with isis of 0.5, 1, 1.5
% and durations 0.5, 1, 1.5 seconds
% Calculate ACW values in all cases
cd C:\Users\user\Desktop\brain_stuff\Bianca\meditationpaper
init
%% Start with colored noise input

ple = 0:0.2:1.6;
figure;
for i = 1:length(ple)
    
    noisesource = dsp.ColoredNoise(ple(i), ntime, 1);    
    noise = noisesource();
    
    p.I_ext_E  = zeros([29 ntime]);
    p.I_ext_E(1,:) = noise;
    
    [v_E, time] = chaudhuri(p);
    
    acw_0 = zeros(1, nrois);
    for j = 1:size(v_E, 1)
        acw_0(j) = acw(v_E(j, :), (1/p.dt)*1000);
    end
    
    subplot(3, 3, i)
    stem(1:nrois, acw_0, 'k', 'filled')
    if any(i == [1 4 7]), ylabel('ACW-0'),end
    if any(i == [7 8 9]), xticks(1:nrois), xticklabels(rois), xtickangle(90), else, xticks({}), end
    ylim([0 6])
    
    title(['PLE of external stimulus: ', num2str(ple(i))])
end

saveas(gcf, [projectfolder, '\figures\noises.jpg'])
%% Proceed with boxcars with ISIs and durations

isis = [0.5 1 1.5]; % ISIs
durs = [0.5 1 1.5]; % Durations
str = 3; % Strength of boxcar
inputtrange = [54 115];
ninput = 20;
p.tspan = inputtrange(2);
timevector = 0:p.dt:p.tspan/p.dt*1000;
ntime = length(timevector);

figure;
c = 1;
for i = 1:length(isis)
    for j = 1:length(durs)
        isi = isis(i);
        dur = durs(j);
        
        boxcar = zeros([1 ntime]);
        noise = randn([1 ntime]);
        
        tstart = inputtrange(1);
        tend = tstart - isi;
        
        for m = 1:ninput
            tstart = tend+isi;
            tend = tstart + dur;
            boxcar(tstart*1000:p.dt:tend*1000) = str;
        end
        
        p.I_ext_E  = zeros([29 ntime]);
        p.I_ext_E(1,:) = noise + boxcar;
    
        [v_E, time] = chaudhuri(p);
        
        acw_0 = zeros(1, nrois);
        for m = 1:size(v_E, 1)
            acw_0(m) = acw(v_E(m, :), (1/p.dt)*1000);
        end
        
        subplot(3, 3, c)
        
        stem(1:nrois, acw_0, 'k', 'filled')
        if any(c == [1 4 7]), ylabel('ACW-0'),end
        if any(c == [7 8 9]), xticks(1:nrois), xticklabels(rois), xtickangle(90), else, xticks({}), end
%         ylim([0 5])
    
        title(['Duration: ', num2str(dur), ' ISI: ', num2str(isi)])
        c = c + 1;
    end
end

saveas(gcf, [projectfolder, '\figures\boxcars.jpg'])



















