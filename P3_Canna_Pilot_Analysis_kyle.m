ccc

%THIS IS THE CODE USED TO PRE-PROCESS THE EEG DATA PRIOR TO PLOTTING

exp = 'P3_Canna_Pilot';
subs = {'001';'002';'003';'005'; '006'};
%subs = {'001'}; %to test on just one sub

nsubs = length(subs);
conds = {'Pre';'Post'};
Pathname = 'M:\Data\P3_Canna_Pilot\';

if ~exist([Pathname 'segments\'])
    mkdir([Pathname 'segments\']);
end
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

for i_sub = 1:nsubs
    for i_cond = 1:2
        
        Filename = [subs{i_sub} '_' exp '_' conds{i_cond} '.vhdr'];
        % [Filename,Pathname] = uigetfile('\\MATHEWSON\Lab_Files\Data\P300\*.vhdr')
        setname = Filename(1:end-5)
        
        EEG = pop_loadbv(Pathname, Filename);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',setname,'gui','off');
        
        % get electrode locatoins
        EEG=pop_chanedit(EEG, 'load',{'M:\Analysis\P3 Canna Pilot 2\cannapilot_32channel_EOG.ced' 'filetype' 'autodetect'});
        EEG = eeg_checkset( EEG );
        
        % arithmetically rereference to linked mastoid
        %Adding a variable to specify the mastoid
        
        other_mastoid_chan_number = 1;
        for non_refdata=2:EEG.nbchan-2
            EEG.data(non_refdata) = (EEG.data(non_refdata)-((EEG.data(other_mastoid_chan_number))*.5));
        end
        
        %        Filter the data with low pass of 30
        EEG = pop_eegfilt( EEG, .1, 0, [], 0);  %high pass filter
        EEG = pop_eegfilt( EEG, 0, 30, [], 0);  %low pass filter
        
        %change markers so they can be used by the gratton_emcp script
        for i_event = 3:length(EEG.event)
            EEG.event(i_event).type = (EEG.event(i_event).type(end));
        end
        %epoch
        
        EEG = pop_epoch( EEG, {  '1'  '2'  '3'  '4'  '5'  }, [-.2  1], 'newname',  sprintf('%s epochs' , setname), 'epochinfo', 'yes');
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');
        EEG = pop_rmbase( EEG, [-200    0]);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2+ 5*((i_sub-1)*3+(i_cond-1)),'overwrite','on','gui','off');
        
        %         eeglab redraw
        %
        
        
        %    Artifact rejection, trials with range >500 uV
        EEG = pop_eegthresh(EEG,1,[1:size(EEG.data,1)],-500, 500,EEG.xmin,EEG.xmax,0,1); %changed to 500. D.R.
        
        %   EMCP occular correction
        temp_ocular = EEG.data(end-1:end,:,:); %to save the EYE data for after
        selection_cards = {'1','2 3 4 5' }; %different bin names, each condition should be separated by commas
        EEG = gratton_emcp(EEG,selection_cards,{'VEOG'},{'HEOG'}); %this assumes the eye channels are called the titles given here
        EEG.emcp.table %this prints out the regression coefficients
        EEG.data(end-1:end,:,:) = temp_ocular; %replace the eye data
        %    Artifact rejection, trials with range >250 uV
        EEG = pop_rmbase( EEG, [-200 0]); %baseline again since this changed it
        
        EEG = pop_eegthresh(EEG,1,[1:size(EEG.data,1)],-200,200,EEG.xmin,EEG.xmax,0,1); % CHANGED TO 200. D.R., more strict than previous artifact rejection
        
        % creating new set for preprocessed clean data, targets and
        % standards included
        [ALLEEG EEG CURRENTSET] =   pop_newset(ALLEEG, EEG, 3, 'setname', sprintf('%s corrected', setname), 'gui', 'off'); %replace the stored data with this new set
        
        tempEEG =   EEG;
        
        %now select the corrected trials for targets
        EEG = pop_selectevent( tempEEG, 'type',1,'renametype','Target','deleteevents','on','deleteepochs','on','invertepochs','off');
        EEG = pop_editset(EEG, 'setname',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Target']);
        EEG = pop_saveset( EEG, 'filename',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Target.set'],'filepath',[Pathname 'segments\']);
        
        %now select the corrected trials for standards
        EEG = pop_selectevent( tempEEG, 'type',[2:5] ,'renametype','Standard','deleteevents','on','deleteepochs','on','invertepochs','off');
        EEG = pop_editset(EEG, 'setname',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Standard']);
        EEG = pop_saveset( EEG, 'filename',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Standard.set'],'filepath',[Pathname 'segments\']);
        
    end %i_cond
end %i_sub
eeglab redraw %refresh the screen so you can see all the data you just finished working on