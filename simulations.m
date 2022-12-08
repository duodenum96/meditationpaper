%% Do Simulations for the Paper
% a) Give input with PLE from 0 to 1.6 with steps of 0.2
% b) Give input as a boxcar on top of white noise with isis of 0.5, 1, 1.5
% and durations 0.5, 1, 1.5 seconds
% Calculate ACW values in all cases
cd C:\Users\user\Desktop\brain_stuff\Bianca\meditationpaper
init
%% Start with colored noise input

ple = 0:0.2:1.6;
ntrials = 50;
acw_0 = zeros(length(ple), nrois, ntrials);
for c = 1:ntrials
    tic
    disp(['Trial ' num2str(c), ' started'])
    for i = 1:length(ple)
        
        noisesource = dsp.ColoredNoise(ple(i), ntime, 1);
        noise = noisesource();
        
        p.I_ext_E  = zeros([nrois ntime]);
        p.I_ext_E(1,:) = noise;
        
        [v_E, time] = chaudhuri(p);
        
        
        
        for j = 1:nrois
            acw_0(i, j, c) = acw(v_E(j, :), (1/p.dt)*1000);
        end
    end
    disp(['Trial ' num2str(c), ' finished'])
    toc
end

save([projectfolder, '\data\acw_0results.mat'], 'acw_0')
%% Plot the results

means = mean(acw_0, 3);
ses = std(acw_0, [], 3) / sqrt(ntrials);

figure;
for i = 1:length(ple)
    subplot(3, 3, i)
    errorbar(1:nrois, means(i,:), ses(i,:), 'k')
    if any(i == [1 4 7]), ylabel('ACW-0'), end
    if any(i == [7 8 9]), xticks(1:nrois), xticklabels(rois), xtickangle(90), else, xticks([]), end
    title(['PLE of stimulation: ', num2str(ple(i))])
    ylim([0 7])
end
saveas(gcf, [projectfolder, '\figures\trials.jpg'])