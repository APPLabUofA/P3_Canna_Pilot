clear all
close all
ccc

%THIS IS THE CODE USED TO PRE-PROCESS THE EEG DATA PRIOR TO PLOTTING

exp = 'P3_Canna_Pilot';
subs = {'001';'002';'003'}; %;
% subs = {'006'}; %to test on just one sub

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
        EEG=pop_chanedit(EEG, 'load',{'M:\Analysis\VR_P3\BrainAMP_EOG_VR.ced' 'filetype' 'autodetect'});
        EEG = eeg_checkset( EEG );

        % arithmetically rereference to linked mastoid
         for x=1:EEG.nbchan-2
             EEG.data(x,:) = (EEG.data(x,:)-((EEG.data(EEG.nbchan-2,:))*.5));
         end

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
        EEG = pop_eegthresh(EEG,1,[1:size(EEG.data,1)],-750,750,EEG.xmin,EEG.xmax,0,1);
        
        %   EMCP occular correction          
        temp_ocular = EEG.data(end-1:end,:,:); %to save the EYE data for after
        selection_cards = {'1','2 3 4 5' }; %different bin names, each condition should be separate
        EEG = gratton_emcp(EEG,selection_cards,{'VEOG'},{'HEOG'}); %this assumes the eye channels are called this
        EEG.emcp.table %this prints out the regression coefficients
        EEG.data(end-1:end,:,:) = temp_ocular; %replace the eye data
        %check 80,85,90 i_sub = 6; 95, 100, 105; 110, 115, 120
         %    Artifact rejection, trials with range >250 uV
        EEG = pop_rmbase( EEG, [-200 0]); %baseline again since this changed it
         EEG = pop_eegthresh(EEG,1,[1:size(EEG.data,1)],-500,500,EEG.xmin,EEG.xmax,0,1);

        [ALLEEG EEG CURRENTSET] =   pop_newset(ALLEEG, EEG, 3, 'setname', sprintf('%s corrected', setname), 'gui', 'off'); %replace the stored data with this new set

%         eeglab redraw

        % % select events from uncorrected
        % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'retrieve',2,'study',0); 
        % EEG = pop_selectevent( EEG, 'type',1,'renametype','Target','deleteevents','on','deleteepochs','on','invertepochs','off');
        % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',sprintf('%s Target', setname),'gui','off'); 
        % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'retrieve',2,'study',0); 
        % EEG = pop_selectevent( EEG, 'type',[2:5] ,'renametype','Standard','deleteevents','on','deleteepochs','on','invertepochs','off');
        % [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',sprintf('%s Standard', setname),'gui','off'); 
        % 

%      
%         
%         %now select the corrected trials
%         [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5,'retrieve',3+ 5*((i_sub-1)*3+(i_cond-1))    ,'study',0); 
%         EEG = pop_selectevent( EEG, 'type',1,'renametype','Target','deleteevents','on','deleteepochs','on','invertepochs','off');
% %         if i_sub ==5 %006
% %             EEG = pop_rejepoch( EEG, [25:29 31 32 35 37 42 43 48 57 63 64 68 70 71 72 81 83 90 91 100 103 110 112 119 127 130 143 146 147] ,0);
% %         end
%         [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',sprintf('%s corrected Target', setname),'gui','off');
%         EEG = pop_saveset( EEG, 'filename',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Target.set'],'filepath','\\MATHEWSON\Lab_Files\Data\P300\Segments');
% 
% 
%         [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6,'retrieve',3+ 5*((i_sub-1)*3+(i_cond-1)) ,'study',0); 
%         EEG = pop_selectevent( EEG, 'type',[2:5] ,'renametype','Standard','deleteevents','on','deleteepochs','on','invertepochs','off');
% %         if i_sub == 5 %006
% %             EEG = pop_rejepoch( EEG, [1 21 29 37 68 69:71 74 77 78 82 85 86:89 91 92 96 97:103 105 106:115 118 119 121 122:125 127 128:130 135 137 147 148 150 155 156 157 169 170 171 178 179:181 190 191:194 196 197 206 222 226 227:230 236 237 256 258 259:261 267 268 271 272:274 306 307:309 311 347 348 364 365 376 377 397 403 407 409 428 452 473 475 478 520 521:523 526:3:532 540 544 545 546 557 560 566 570:4:574] ,0);
% %         end
%         [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',sprintf('%s corrected Standard', setname),'gui','off'); 
%         EEG = pop_saveset( EEG, 'filename',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Standard.set'],'filepath','\\MATHEWSON\Lab_Files\Data\P300\Segments\');
% 


   tempEEG =   EEG;

 %now select the corrected trials
        EEG = pop_selectevent( tempEEG, 'type',1,'renametype','Target','deleteevents','on','deleteepochs','on','invertepochs','off');
        EEG = pop_editset(EEG, 'setname',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Target']);
        EEG = pop_saveset( EEG, 'filename',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Target.set'],'filepath',[Pathname 'segments\']);


        EEG = pop_selectevent( tempEEG, 'type',2 ,'renametype','Standard','deleteevents','on','deleteepochs','on','invertepochs','off');
        EEG = pop_editset(EEG, 'setname',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Standard']);
        EEG = pop_saveset( EEG, 'filename',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Standard.set'],'filepath',[Pathname 'segments\']);

    end %i_cond
end %i_sub
% 