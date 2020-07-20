function gPPI_wrapper_SEL2_anatomical_roi()

% %%%%%%%%%%%%%%%%%%%
% %encoding gPPI
% %%%%%%%%%%%%%%%%%%%%%%%
%clear all

addpath('C:\Program Files\MATLAB\spm8\toolbox\gPPI\PPPI') %make sure that the toolbox is installed in this path


basedir = 'C:\fMRI_Data\SEL2\ANALYSIS_SPM8\';% Root location of analysis folder
gPPI_dir='gPPI';

addpath(fullfile(basedir,gPPI_dir));
addpath(fullfile(basedir,gPPI_dir,'first_level_scripts'));
%funcdir = 'bold'; % Location of functional runs directories
%templdir='templates'; % Location of template files
subj_resultsdir='results_pairsRep_smt_unnorm_msessions';
masks_dir='masks';
onsetsdir='onsets';
%ppi_dir='gPPI';


subs= {...
    '200615TF';...
     '230615ZD';...
     '230615EF';...
     '230615RE';...
     '270615SA';...
     '270615NK';...
     '270615RP';...
     '110715DA';...
     '110715YB';...
     '110715YL';...
       '240715TP';...
       '250715LK';...
       '250715AG';...
       '250715EB';...
       '080815EF';...
       '080815LR';...
       '080815RM';...
       '080815TN';...
       '110815EZ';...
    }; 

firstsubject=1;
lastsubject=length(subs);

region={...
    'epi_lhipp_ant';
       };


load(fullfile(basedir,gPPI_dir,'PairsRepContrasts.mat'));
nsessions=4;
num_cont_per_sess=6; %in each session, there are 3 reps of each of two conditions, makes 6 - that is used to sero pad the PPI contrasts - no time derivative there

for regionnumber=1:numel(region)

    %User input required (change directory to where the input structure should
    %be saved)
    %save(['E:\fMRI_data\Relatedness\Analysis_spm8\GROUP_NO_HS_LZ_TM_SL\GROUP_ret\gPPI\' region{regionnumber} '.mat'],'P');%create P mat file of the contrast for each region

    for s=firstsubject:lastsubject
        load(fullfile(basedir,gPPI_dir,'PairsRep_gPPI.mat'));
        subj_path=fullfile(basedir,subs{s}); % define current subject
        Directory=fullfile(subj_path,subj_resultsdir);
%         if ~isdir(fullfile(Directory,ppi_dir)), mkdir(fullfile(Directory,ppi_dir)); end
        copyfile(fullfile(Directory,'SPM.mat'),fullfile(Directory,'SPMprePPI.mat')); %save a coppy of the original spm before we mess with it
        %Directory=fullfile(Directory,ppi_dir);
        cd(Directory);
        %prepare the P mat:
        
        %Generate Task List
        tasks=[];
        %take the tasks from the subjects' SPM:
        load('SPM.mat');
        for ss=1:numel(SPM.Sess)
            for tt=1:numel(SPM.Sess(ss).U)
                tasks=[tasks SPM.Sess(ss).U(tt).name]; %#ok<AGROW>
            end
        end
        Tasks=unique(tasks);
        P.Tasks={'0'};
        for t=1:numel(Tasks)
            P.Tasks(t+1)=Tasks(t);
        end
        
        %set up the contrasts:
        %the interesting ppi contrasts are in the add_con_mat matrix that
        %was prepared ahead
        %zero padding:
        %1. before the interesting PPI contrasts: all the conditions+time
        %derivative for each condition
        %2. after the interesting PPI contrasts: need to add zeros for the
        %task pairs (I evaluated the PPI for them as well, and for the
        %regressor of the sead's activity (hence the +1 there).
        %A)for the task pairs, each subject sometimes have no items in a
        %repetition, so need to zero pad based on that, hence why I took it
        %based on the onsets file.
        %B)note that for the PPI regressors, no time derivative regressor
        %was evaluated, so no need to multiply the zero padding by two,
        %like in the sero padding before add_con_mat
        con_mat=[];
        for sess=1:nsessions
            sub_onsets_file=fullfile(subj_path,onsetsdir,sprintf('onsets_SEL2_pairsRep_sess%d.mat',sess));
            load(sub_onsets_file,'names');
            con_mat_singleSess=add_con_mat(:,:,sess);
            con_mat_singleSess=[zeros(size(con_mat_singleSess,1),numel(names)*2) con_mat_singleSess zeros(size(con_mat_singleSess,1),numel(names)-num_cont_per_sess+1)];
            con_mat=[con_mat con_mat_singleSess];
        end
        
        %now put them in place:
        for con=1:size(con_mat,1)
             P.Contrasts(con).left=con_mat(con,:);
        end
        

         P.VOI=fullfile(subj_path,masks_dir,sprintf('%s.nii',region{regionnumber}));
         P.Region=region{regionnumber};
         
         P.subject=subs{s};
         P.directory=Directory;
         P.maskdir=Directory;
         %save the P structure:
         save([subs{s} '_PairsRep_gPPI_' region{regionnumber} '.mat'],'P');
    
        try
            PPPI_oded([subs{s} '_PairsRep_gPPI_' region{regionnumber} '.mat']);
        catch
            disp(['Failed: ' subs{s}])
        end
    end %ends the subjects loop
end %ends the regions loop

clear all;

end

%% some code I used to just prepare the P structure, no need to run it again: 
% P.Tasks={'0' 'Famous1' 'Famous2' 'Famous3' 'Famous4' 'Famous5' 'Famous6' 'Famous7' 'Famous8' 'Famous9' 'Famous10' 'Famous11' 'Famous12'...
%             'NonFamous1' 'NonFamous2' 'NonFamous3' 'NonFamous4' 'NonFamous5' 'NonFamous6' 'NonFamous7' 'NonFamous8' 'NonFamous9' 'NonFamous10' 'NonFamous11' 'NonFamous12'};
% % now put the contrasts in place:
%          for con=1:size(con_mat,1)
%              P.Contrasts(con)=P.Contrasts(1);%just to get the fields, now update the correct values:
%              P.Contrasts(con).name=cond_names{con};
%          end
       
% nsessions=4;
% cond_names = {... % array of all contrasts names; this is the way they will appear in the results menu;
% 'FamousAndNonFamousAll',...
% 'Famous',...
% 'Nonfamous',...
% 'Famous_Nonfamous',...
% 'Nonfamous_Famous',...
% 'FamousLinDecrease',...
% 'NonFamousLinDecrease',...
% 'FlinAndNFlin',...
% 'FlinMinusNFlin',...
% 'FamousExpDecreaseNatlog',...
% 'NonFamousExpDecreaseNatlog',...
% 'FandNF_ExpDecreaseNatLog',...
% 'FminusNF_ExpDecreaseNatLog',...
% 'FamousExpDecrease2PowerRep',...
% 'NonFamousExpDecrease2PowerRep',...
% 'Famous1',...
% 'Famous2',...
% 'Famous3',...
% 'Famous4',...
% 'Famous5',...
% 'Famous6',...
% 'Famous7',...
% 'Famous8',...
% 'Famous9',...
% 'Famous10',...
% 'Famous11',...
% 'Famous12',...
% 'NonFamous1',...
% 'NonFamous2',...
% 'NonFamous3',...
% 'NonFamous4',...
% 'NonFamous5',...
% 'NonFamous6',...
% 'NonFamous7',...
% 'NonFamous8',...
% 'NonFamous9',...
% 'NonFamous10',...
% 'NonFamous11',...
% 'NonFamous12',...
% 'Famous123',...
% 'NonFamous123',...
% 'F123andNF123',...
% 'F123minusNF123',...
% };
% 
% cond_names=cond_names'; %just for convinenience
% 
% %preparing the linear decrease regresssor
% LinDecrease=[12:-1:1]-mean(12:-1:1);
% FamousLinDecrease=[];
% NonFamousLinDecrease=[];
% FamousAndNonFamousAll=[];
% Famous=[];
% Nonfamous=[];
% Famous_Nonfamous=[];
% Nonfamous_Famous=[];
% for i=1:nsessions
%     FamousAndNonFamousAll=[FamousAndNonFamousAll;1	0	1	0	1	0	1	0	1	0	1	0];
%     Famous=[Famous;1	0	1	0	1	0	0	0	0	0	0	0];
%     Nonfamous=[Nonfamous;0	0	0	0	0	0	1	0	1	0	1	0];
%     Famous_Nonfamous=[Famous_Nonfamous;1	0	1	0	1	0	-1	0	-1	0	-1	0];
%     Nonfamous_Famous=[Nonfamous_Famous;-1	0	-1	0	-1	0	1	0	1	0	1	0];
%     FamousLinDecreaseCurrSess=[LinDecrease((i-1)*3+1) 0 LinDecrease((i-1)*3+2) 0 LinDecrease((i-1)*3+3) 0 zeros(1,6)];
%     NonFamousLinDecreaseCurrSess=[zeros(1,6) LinDecrease((i-1)*3+1) 0 LinDecrease((i-1)*3+2) 0 LinDecrease((i-1)*3+3) 0];
%     FamousLinDecrease=[FamousLinDecrease;FamousLinDecreaseCurrSess];
%     NonFamousLinDecrease=[NonFamousLinDecrease;NonFamousLinDecreaseCurrSess];
% end
% 
% FlinAndNFlin=FamousLinDecrease+NonFamousLinDecrease;
% FlinMinusNFlin=FamousLinDecrease-NonFamousLinDecrease;
% 
% %preparing the natural log exponential decay regresssor
% ExpDecay=-log(1:1:12)-mean(-log(1:1:12));
% FamousExpDecreaseNatlog=[];
% NonFamousExpDecreaseNatlog=[];
% for i=1:nsessions
%     FamousExpDecreaseCurrSess=[ExpDecay((i-1)*3+1) 0 ExpDecay((i-1)*3+2) 0 ExpDecay((i-1)*3+3) 0 zeros(1,6)];
%     NonFamousExpDecreaseCurrSess=[zeros(1,6) ExpDecay((i-1)*3+1) 0 ExpDecay((i-1)*3+2) 0 ExpDecay((i-1)*3+3) 0];
%     FamousExpDecreaseNatlog=[FamousExpDecreaseNatlog;FamousExpDecreaseCurrSess];
%     NonFamousExpDecreaseNatlog=[NonFamousExpDecreaseNatlog;NonFamousExpDecreaseCurrSess];
% end
% 
% FandNF_ExpDecreaseNatLog=FamousExpDecreaseNatlog+NonFamousExpDecreaseNatlog;
% FminusNF_ExpDecreaseNatLog=FamousExpDecreaseNatlog-NonFamousExpDecreaseNatlog;
% 
% %preparing the 2^rep exponential decay regresssor
% ExpDecay=((2.^(12:-1:1))-mean(2.^(12:-1:1)))/1000;
% FamousExpDecrease2PowerRep=[];
% NonFamousExpDecrease2PowerRep=[];
% 
% for i=1:nsessions
%     FamousExpDecreaseCurrSess=[ExpDecay((i-1)*3+1) 0 ExpDecay((i-1)*3+2) 0 ExpDecay((i-1)*3+3) 0 zeros(1,6)];
%     NonFamousExpDecreaseCurrSess=[zeros(1,6) ExpDecay((i-1)*3+1) 0 ExpDecay((i-1)*3+2) 0 ExpDecay((i-1)*3+3) 0];
%     FamousExpDecrease2PowerRep=[FamousExpDecrease2PowerRep;FamousExpDecreaseCurrSess];
%     NonFamousExpDecrease2PowerRep=[NonFamousExpDecrease2PowerRep;NonFamousExpDecreaseCurrSess];
% end
% 
% %preparing the contrast for each repetition (1st rep was done already):
% Famous1=[1 zeros(1,11); zeros(1,12); zeros(1,12); zeros(1,12)];
% Famous2=[0 0 1 0 0 0 zeros(1,6); zeros(1,12); zeros(1,12); zeros(1,12)];
% Famous3=[0 0 0 0 1 0 zeros(1,6); zeros(1,12); zeros(1,12); zeros(1,12)];
% Famous4=[zeros(1,12); 1 0 0 0 0 0 zeros(1,6); zeros(1,12); zeros(1,12)];
% Famous5=[zeros(1,12); 0 0 1 0 0 0 zeros(1,6); zeros(1,12); zeros(1,12)];
% Famous6=[zeros(1,12); 0 0 0 0 1 0 zeros(1,6); zeros(1,12); zeros(1,12)];
% Famous7=[zeros(1,12); zeros(1,12); 1 0 0 0 0 0 zeros(1,6); zeros(1,12)];
% Famous8=[zeros(1,12); zeros(1,12); 0 0 1 0 0 0 zeros(1,6); zeros(1,12)];
% Famous9=[zeros(1,12); zeros(1,12); 0 0 0 0 1 0 zeros(1,6); zeros(1,12)];
% Famous10=[zeros(1,12); zeros(1,12); zeros(1,12); 1 0 0 0 0 0 zeros(1,6)];
% Famous11=[zeros(1,12); zeros(1,12); zeros(1,12); 0 0 1 0 0 0 zeros(1,6)];
% Famous12=[zeros(1,12); zeros(1,12); zeros(1,12); 0 0 0 0 1 0 zeros(1,6)];
% 
% NonFamous1=[0 0 0 0 0 0 1 0 0 0 0 0; zeros(1,12); zeros(1,12); zeros(1,12)];
% NonFamous2=[zeros(1,6) 0 0 1 0 0 0; zeros(1,12); zeros(1,12); zeros(1,12)];
% NonFamous3=[zeros(1,6) 0 0 0 0 1 0; zeros(1,12); zeros(1,12); zeros(1,12)];
% NonFamous4=[zeros(1,12); zeros(1,6) 1 0 0 0 0 0; zeros(1,12); zeros(1,12)];
% NonFamous5=[zeros(1,12); zeros(1,6) 0 0 1 0 0 0; zeros(1,12); zeros(1,12)];
% NonFamous6=[zeros(1,12); zeros(1,6) 0 0 0 0 1 0; zeros(1,12); zeros(1,12)];
% NonFamous7=[zeros(1,12); zeros(1,12);zeros(1,6) 1 0 0 0 0 0; zeros(1,12)];
% NonFamous8=[zeros(1,12); zeros(1,12);zeros(1,6) 0 0 1 0 0 0; zeros(1,12)];
% NonFamous9=[zeros(1,12); zeros(1,12);zeros(1,6) 0 0 0 0 1 0; zeros(1,12)];
% NonFamous10=[zeros(1,12); zeros(1,12); zeros(1,12);zeros(1,6) 1 0 0 0 0 0];
% NonFamous11=[zeros(1,12); zeros(1,12); zeros(1,12);zeros(1,6) 0 0 1 0 0 0];
% NonFamous12=[zeros(1,12); zeros(1,12); zeros(1,12);zeros(1,6) 0 0 0 0 1 0];
% 
% Famous123=[1 0 1 0 1 0 zeros(1,6); zeros(1,12); zeros(1,12); zeros(1,12)];
% NonFamous123=[zeros(1,6) 1 0 1 0 1 0; zeros(1,12); zeros(1,12); zeros(1,12)];
% F123andNF123=Famous123+NonFamous123;
% F123minusNF123=Famous123-NonFamous123;
% 
% 
% add_con_mat=zeros(10,12,nsessions);
% 
% for i=1:nsessions
%     add_con_mat(1,:,i)=FamousAndNonFamousAll(i,:);
%     add_con_mat(2,:,i)=Famous(i,:);
%     add_con_mat(3,:,i)=Nonfamous(i,:);
%     add_con_mat(4,:,i)=Famous_Nonfamous(i,:);
%     add_con_mat(5,:,i)=Nonfamous_Famous(i,:);
%     
%     add_con_mat(6,:,i)=FamousLinDecrease(i,:);
%     add_con_mat(7,:,i)=NonFamousLinDecrease(i,:);
%     add_con_mat(8,:,i)=FlinAndNFlin(i,:);
%     add_con_mat(9,:,i)=FlinMinusNFlin(i,:);
%     
%     add_con_mat(10,:,i)=FamousExpDecreaseNatlog(i,:);
%     add_con_mat(11,:,i)=NonFamousExpDecreaseNatlog(i,:);
%     add_con_mat(12,:,i)=FandNF_ExpDecreaseNatLog(i,:);
%     add_con_mat(13,:,i)=FminusNF_ExpDecreaseNatLog(i,:);
%     
%     add_con_mat(14,:,i)=FamousExpDecrease2PowerRep(i,:);
%     add_con_mat(15,:,i)=NonFamousExpDecrease2PowerRep(i,:);
%     
%     add_con_mat(16,:,i)=Famous1(i,:);
%     add_con_mat(17,:,i)=Famous2(i,:);
%     add_con_mat(18,:,i)=Famous3(i,:);
%     add_con_mat(19,:,i)=Famous4(i,:);
%     add_con_mat(20,:,i)=Famous5(i,:);
%     add_con_mat(21,:,i)=Famous6(i,:);
%     add_con_mat(22,:,i)=Famous7(i,:);
%     add_con_mat(23,:,i)=Famous8(i,:);
%     add_con_mat(24,:,i)=Famous9(i,:);
%     add_con_mat(25,:,i)=Famous10(i,:);
%     add_con_mat(26,:,i)=Famous11(i,:);
%     add_con_mat(27,:,i)=Famous12(i,:);
%     
%     add_con_mat(28,:,i)=NonFamous1(i,:);
%     add_con_mat(29,:,i)=NonFamous2(i,:);
%     add_con_mat(30,:,i)=NonFamous3(i,:);
%     add_con_mat(31,:,i)=NonFamous4(i,:);
%     add_con_mat(32,:,i)=NonFamous5(i,:);
%     add_con_mat(33,:,i)=NonFamous6(i,:);
%     add_con_mat(34,:,i)=NonFamous7(i,:);
%     add_con_mat(35,:,i)=NonFamous8(i,:);
%     add_con_mat(36,:,i)=NonFamous9(i,:);
%     add_con_mat(37,:,i)=NonFamous10(i,:);
%     add_con_mat(38,:,i)=NonFamous11(i,:);
%     add_con_mat(39,:,i)=NonFamous12(i,:);
%     
%     add_con_mat(40,:,i)=Famous123(i,:);
%     add_con_mat(41,:,i)=NonFamous123(i,:);
%     add_con_mat(42,:,i)=F123andNF123(i,:);
%     add_con_mat(43,:,i)=F123minusNF123(i,:);
% end

