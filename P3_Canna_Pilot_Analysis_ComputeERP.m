
ccc
%
exp = 'P3_Canna_Pilot';
subs = {'001';'002'; '003'; '005'; '006'};
%subs = {'006'}; %to test on just one sub 

nsubs = length(subs); 
conds =  {'Pre';'Post'};
nconds = length(conds);
Pathname = 'M:\Data\P3_Canna_Pilot\';
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;


i_count = 0;
for i_sub = 1:nsubs
    for i_cond = 1:nconds
        
        i_count = i_count + 1;
        Filename = [subs{i_sub} '_' exp '_' conds{i_cond}];
        EEG = pop_loadset('filename',[Filename '_Corrected_Target.set'],'filepath','M:\Data\P3_Canna_Pilot\segments\');
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = pop_loadset('filename',[Filename '_Corrected_Standard.set'],'filepath','M:\Data\P3_Canna_Pilot\segments\');
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );


    end
end
eeglab redraw

%compute grand average Erps
[erp1aw, erp2aw, diffaw] = pop_comperp( ALLEEG, 1, [1:6:i_sub*i_cond*2] ,[2:6:i_sub*i_cond*2],'addavg','on','addstd','off','subavg','on','diffavg','off','diffstd','off','tplotopt',{'ydir' -1});
[erp1pw, erp2pw, diffpw] = pop_comperp( ALLEEG, 1, [3:6:i_sub*i_cond*2] ,[4:6:i_sub*i_cond*2],'addavg','on','addstd','off','subavg','on','diffavg','off','diffstd','off','tplotopt',{'ydir' -1});
% [erp1ad, erp2ad, diffad, time] = pop_comperp( ALLEEG, 1, [5:6:i_sub*i_cond*2] ,[6:6:i_sub*i_cond*2],'addavg','on','addstd','off','subavg','on','diffavg','off','diffstd','off','tplotopt',{'ydir' -1});

%subject erps
electrode = 3;
erp_out = [];
for i_sub = 1:nsubs
    for i_cond = 1:nconds
        erp_out(:,1,:,i_cond,i_sub) = mean(ALLEEG(1+ 2*((i_sub-1)*2+(i_cond-1))).data,3)';
        erp_out(:,2,:,i_cond,i_sub) = mean(ALLEEG(2+ 2*((i_sub-1)*2+(i_cond-1))).data,3)';
    end
end
    
%grand average plots + difference
erp_diff_out = squeeze(erp_out(:,1,:,:,:)-erp_out(:,2,:,:,:)); 
figure('Color',[1 1 1]); 
for i_cond = 1:2
    switch i_cond
        case 1
            colour = 'b';
        case 2
            colour = 'g';
        case 3
            colour = 'r';
    end
    
    subplot(2,2,i_cond);
        boundedline(EEG.times,squeeze(mean(erp_out(:,1,electrode,i_cond,:),5)),squeeze(std(erp_out(:,1,electrode,i_cond,:),[],5))./sqrt(nsubs),colour,...
        EEG.times,squeeze(mean(erp_out(:,2,electrode,i_cond,:),5)),squeeze(std(erp_out(:,2,electrode,i_cond,:),[],5))./sqrt(nsubs),'k');
        set(gca,'Color',[1 1 1]);
        set(gca,'YDir','reverse');
        if i_cond == 2
            legend({'Targets', 'Standards'},'Location','SouthEast');
        end
        axis tight; ylim([-2.5 8]);
        line([-200 1000],[0 0],'color','k');
        line([0 0],[-2.5 8],'color','k');
        title(conds{i_cond});
        xlabel('Time (ms)');
        ylabel('Voltage (uV)');
    
    subplot(2,2,2+i_cond);
        boundedline(EEG.times,squeeze(mean(erp_diff_out(:,electrode,i_cond,:),4)),squeeze(std(erp_diff_out(:,electrode,i_cond,:),[],4))./sqrt(nsubs),colour);
        set(gca,'Color',[1 1 1]);
        set(gca,'YDir','reverse'); 
        if i_cond == 2
            legend('Targets-Standards','Location','SouthEast'); 
        end
        axis tight; ylim([-2.5 8]);
        line([-200 1000],[0 0],'color','k');
        line([0 0],[-2.5 8],'color','k');
        title(conds{i_cond});
        xlabel('Time (ms)');
        ylabel('Voltage (uV)');
        
end
%%
figure('Color',[1 1 1]); 
subplot(2,1,1);
        electrode = 6;
        boundedline(EEG.times,squeeze(mean(erp_diff_out(:,electrode,1,:),4)), squeeze(std(erp_diff_out(:,electrode,1,:),[],4))./sqrt(nsubs),'b',...
                    EEG.times,squeeze(mean(erp_diff_out(:,electrode,2,:),4)), squeeze(std(erp_diff_out(:,electrode,2,:),[],4))./sqrt(nsubs),'g'); %,...
%                     EEG.times,squeeze(mean(erp_diff_out(:,electrode,3,:),4)), squeeze(std(erp_diff_out(:,electrode,3,:),[],4))./sqrt(nsubs),'r');
               set(gca,'Color',[1 1 1]);
        set(gca,'YDir','reverse'); 
      line('XData', [100 100], 'YData', [9.25 -7], 'LineStyle', '-','LineWidth', 2, 'Color','r')
        line('XData', [175 175], 'YData', [9.25 -7], 'LineStyle', '-','LineWidth', 2, 'Color','r')
        line('XData', [180 180], 'YData', [9.25 -7], 'LineStyle', '-','LineWidth', 2, 'Color','m')
        line('XData', [275 275], 'YData', [9.25 -7], 'LineStyle', '-','LineWidth', 2, 'Color','m')
        
        legend('Pre','Post','Location','SouthEast'); 
       
        axis tight; ylim([-5 9]);
        line([-200 1000],[0 0],'color','k');
        line([0 0],[-5 9],'color','k');
        title('Difference Wave, Fz');
        xlabel('Time (ms)');
        ylabel('Voltage (uV)');
subplot(2,1,2);
        electrode = 3;
        boundedline(EEG.times,squeeze(mean(erp_diff_out(:,electrode,1,:),4)), squeeze(std(erp_diff_out(:,electrode,1,:),[],4))./sqrt(nsubs),'b',...
                    EEG.times,squeeze(mean(erp_diff_out(:,electrode,2,:),4)), squeeze(std(erp_diff_out(:,electrode,2,:),[],4))./sqrt(nsubs),'g'); %,...
%                     EEG.times,squeeze(mean(erp_diff_out(:,electrode,3,:),4)), squeeze(std(erp_diff_out(:,electrode,3,:),[],4))./sqrt(nsubs),'r');
               set(gca,'Color',[1 1 1]);
        set(gca,'YDir','reverse'); 
       line('XData', [100 100], 'YData', [9.25 -7], 'LineStyle', '-','LineWidth', 2, 'Color','r')
        line('XData', [175 175], 'YData', [9.25 -7], 'LineStyle', '-','LineWidth', 2, 'Color','r')
        line('XData', [180 180], 'YData', [9.25 -7], 'LineStyle', '-','LineWidth', 2, 'Color','m')
        line('XData', [275 275], 'YData', [9.25 -7], 'LineStyle', '-','LineWidth', 2, 'Color','m')
        
        legend('Pre','Post','Location','SouthEast'); 
       
        axis tight; ylim([-5 9]);
        line([-200 1000],[0 0],'color','k');
        line([0 0],[-5 9],'color','k');
        title('Difference Wave, Pz');
        xlabel('Time (ms)');
        ylabel('Voltage (uV)');
    %%
 %difference topographys
time_window = find(EEG.times>250,1)-1:find(EEG.times>450,1)-2;
figure('Color',[1 1 1]);
for i_cond = 1:2
    subplot(1,2,i_cond);
       set(gca,'Color',[1 1 1]);
        temp = mean(mean(erp_diff_out(time_window,:,i_cond,:),4),1)';
        temp(16:18) = NaN;
        topoplot(temp,'M:\Analysis\VR_P3\BrainAMP_EOG_VR.ced', 'whitebk','on','plotrad',.6,'maplimits',[-4 4]  )
        title(conds{i_cond});
        t = colorbar('peer',gca);
        set(get(t,'ylabel'),'String', 'Voltage Difference (uV)');

end
%%

% for i_set = 1:48; trial_count(i_set) = ALLEEG(i_set).trials; end
% trial_count = reshape(trial_count,[2,3,8]);
% min(trial_count,[],3)
% mean(trial_count,3)
% max(trial_count,[],3)
% 
% %mean and sd
% mean(mean(erp_diff_out(time_window,7,1:3,:),1),4)
% std(mean(erp_diff_out(time_window,7,1:3,:),1),[],4)
% 
% 
% 
% % ttest of each condition
% [h p ci stat] = ttest(squeeze(mean(erp_diff_out(time_window,7,1,:),1)),0,.05,'right',1)
% [h p ci stat] = ttest(squeeze(mean(erp_diff_out(time_window,7,2,:),1)),0,.05,'right',1)
% [h p ci stat] = ttest(squeeze(mean(erp_diff_out(time_window,7,3,:),1)),0,.05,'right',1)

%plot difference
%uncorrected
% pop_comperp( ALLEEG, 1, 4,5,'addavg','on','addstd','off','subavg','on','diffavg','off','diffstd','off','tplotopt',{'ydir' -1});
% %corrected
% [erp1aw, erp2aw, diffaw] = pop_comperp( ALLEEG, 1, [1:6:i_sub*i_cond*2] ,[2:6:i_sub*i_cond*2],'addavg','on','addstd','off','subavg','on','diffavg','off','diffstd','off','tplotopt',{'ydir' -1});
% [erp1pw, erp2pw, diffpw] = pop_comperp( ALLEEG, 1, [3:6:i_sub*i_cond*2] ,[4:6:i_sub*i_cond*2],'addavg','on','addstd','off','subavg','on','diffavg','off','diffstd','off','tplotopt',{'ydir' -1});
% [erp1ad, erp2ad, diffad, time] = pop_comperp( ALLEEG, 1, [5:6:i_sub*i_cond*2] ,[6:6:i_sub*i_cond*2],'addavg','on','addstd','off','subavg','on','diffavg','off','diffstd','off','tplotopt',{'ydir' -1});
% [erp1aw, erp2aw, diffaw] = pop_comperp( ALLEEG, 1, [4:15:i_sub*i_cond*5] ,[5:15:i_sub*i_cond*5],'addavg','off','addstd','off','subavg','off','substd','off','diffavg','on','diffstd','on','tplotopt',{'ydir' -1});
% [erp1pw, erp2pw, diffpw] = pop_comperp( ALLEEG, 1, [9:15:i_sub*i_cond*5] ,[10:15:i_sub*i_cond*5],'addavg','off','addstd','off','subavg','off','substd','off','diffavg','on','diffstd','on','tplotopt',{'ydir' -1});
% [erp1ad, erp2ad, diffad, time] = pop_comperp( ALLEEG, 1, [14:15:i_sub*i_cond*5] ,[15:15:i_sub*i_cond*5],'addavg','off','addstd','off','subavg','off','substd','off','diffavg','on','diffstd','on','tplotopt',{'ydir' -1});



eeglab redraw