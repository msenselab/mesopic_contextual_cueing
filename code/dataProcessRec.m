%Name:                dataProcessRec.m
%Autor:               Xuelian Zang
%Description:         process recogntion data
%Date:                07/07/2014
function  dataProcessRec(dataIn, nSub, nEp,nEpT)
 % check if a certain subject keeping on press a same key in a session
 minNumBlk = 31;
 maxNumBlk = 31;
 dataIn(dataIn.NB == 32, :) = []; % remove the second block
 nSubArray = nSub * ones(1,6) ;
 for iExp = 1:6
     for iSub = 1:nSub
         for iB = minNumBlk:maxNumBlk
             % remove onld have new or old trials (experiment was abort in
             % the middle    
             oldIdx = dataIn.NExp == iExp & dataIn.NSub == iSub & dataIn.NB == iB & dataIn.New == 0 & dataIn.Crr == 1;
             newIdx = dataIn.NExp == iExp & dataIn.NSub == iSub & dataIn.NB == iB & dataIn.New == 1 & dataIn.Crr == 1;
             if isempty(dataIn(newIdx, :)) || isempty(dataIn(oldIdx, :))
                 dataIn(dataIn.NExp == iExp & dataIn.NSub == iSub,:) = [];
                 nSubArray(iExp) = nSubArray(iExp) - 1;
                 %sprintf('remove Experiment %d, subject %d due to missing trials or no correct trials under a specific condition', iExp, iSub)
                 break;  
             end

             idx = dataIn.NExp == iExp & dataIn.NSub == iSub & dataIn.NB == iB;
             dataTmp = dataIn(idx, :);
             if isempty(dataTmp(dataTmp.RP == 0, :)) || isempty(dataTmp(dataTmp.RP == 1, :)) 
                 idxRm = dataIn.NExp == iExp & dataIn.NSub == iSub; %remove the whole experiment
                 dataIn(idxRm, :) = [];
                 nSubArray(iExp) = nSubArray(iExp) - 1;
                 %sprintf('remove Experiment %d, subject %d due to pure press on key 1 in recognition test', iExp, iSub)
                 break; 
             end
         end
         
     end
 end

 %% recognition test
    allOldArray = dataIn(dataIn.New == 0,:);
    hitArray =  allOldArray( allOldArray.RP==0,:);
        
    hitGroup = grpstats(hitArray, {'NExp','NSub','NB'},{'mean','numel'},'DataVars','New');
    allOldGroup = grpstats(allOldArray, {'NExp','NSub','NB'},{'mean','numel'},'DataVars','New');
    
    hitAddMissGroup = [];
    % add miss condition
    if length(hitGroup) ~= length(allOldGroup)
        for iExp = 1:6
            for iSub = 1 : nSub
                for iB = minNumBlk:maxNumBlk
                    idxHit = hitGroup.NB == iB & hitGroup.NSub == iSub & hitGroup.NExp == iExp;
                    idxAllOld = allOldGroup.NB == iB & allOldGroup.NSub == iSub & allOldGroup.NExp == iExp;
                    if ~isempty(allOldGroup(idxAllOld, :))
                        if isempty(hitGroup(idxHit,:))
                            addArray = mat2dataset([iB iSub iExp, 0, -1, -1], 'VarNames',{'NExp', 'NSub','NB', 'GroupCount', 'mean_New', 'numel_New'});
                            hitAddMissGroup = [hitAddMissGroup; addArray ];
                            sprintf('add missed response under a specific condition to hit group: Experiment %d Subject %d Blk %d in old context.', iExp, iSub, iB)
                        else
                            hitAddMissGroup = [hitAddMissGroup; hitGroup(idxHit,:) ];
                        end
                    end
                end
            end
        end
    else
        hitAddMissGroup = hitGroup;
    end
    
    allNewArray = dataIn(dataIn.New == 1,:);
    crrRejArray = allNewArray(allNewArray.Crr == 1,:);
    crrRejGroup = grpstats(crrRejArray, {'NExp','NSub','NB'},{'mean','numel'},'DataVars','New');
    allNewGroup = grpstats(allNewArray, {'NExp','NSub','NB'},{'mean','numel'},'DataVars','New');

    crrRejAddMissGroup = [];  
    if length(crrRejGroup) ~= length(allNewGroup)
        for iExp = 1:6
            for iSub = 1 : nSub
                for iB = minNumBlk:maxNumBlk
                    idxCrrRej = crrRejGroup.NB == iB & crrRejGroup.NSub == iSub & crrRejGroup.NExp == iExp;
                    idxAllOld = allNewGroup.NB == iB & allNewGroup.NSub == iSub & allNewGroup.NExp == iExp;
                    if ~isempty(allNewGroup(idxAllOld,:))
                        if isempty(crrRejGroup(idxCrrRej,:)) 
                            addArray = mat2dataset([iB iSub iExp, 0, -1, -1], {'NExp', 'NSub','NB',  'GroupCount', 'mean_New', 'numel_New'});
                            crrRejAddMissGroup = [crrRejAddMissGroup; addArray ];
                            sprintf('add missed response under a specific condition to corrRej group: Experiment %d Subject %d Blk %d in old context.')
                        else
                            crrRejAddMissGroup = [crrRejAddMissGroup; crrRejGroup(idxCrrRej,:) ];
                        end
                    end
                end
            end
        end
    else
        crrRejAddMissGroup = crrRejGroup;
    end
    
    hitAddMissGroup.hitRates = hitAddMissGroup.GroupCount ./ allOldGroup.GroupCount;
    crrRejAddMissGroup.crrRejRates = crrRejAddMissGroup.GroupCount ./ allNewGroup.GroupCount;
 
    hitAddMissGroup.hitRates(hitAddMissGroup.hitRates == 0) = 0.0001;
    hitAddMissGroup.hitRates(hitAddMissGroup.hitRates == 1) = 0.9999;
 
    crrRejAddMissGroup.crrRejRates(crrRejAddMissGroup.crrRejRates == 0) = 0.0001;
    crrRejAddMissGroup.crrRejRates(crrRejAddMissGroup.crrRejRates == 1) = 0.9999;    
   
    % H1E1   H2E1  
    hitFalseArray = [];
    hitFalseArray = [hitAddMissGroup.hitRates 1-crrRejAddMissGroup.crrRejRates hitAddMissGroup.NExp hitAddMissGroup.NSub hitAddMissGroup.NB]; 
    %% calculate d' and c
   
    hitFalseArray(:,end+1) = norminv(hitFalseArray (:,1)) - norminv(hitFalseArray (:,2));
    hitFalseArray(:,end+1) = -[norminv(hitFalseArray (:,1)) + norminv(hitFalseArray (:,2)) ] / 2;
    
    hitFalseArray = mat2dataset(hitFalseArray,'VarNames',{'hit','FA', 'NExp', 'NSub','NB','d', 'c'});
    tmp = grpstats(hitFalseArray, {'NExp'},{'mean','sem'},'DataVars',{'d', 'c'});
    
    
    %% Figure 6 in the Manuscript
    %plot  Mean recognition sensitivity on the left side and Mean response
    %bias C on the right side
    barWidth= 0.35;   
    figure(); hold on;
    set(gcf,'Units','inches','Position',[6 0.2 6.83 6.83*0.5] );    
   
    subplot(1,2,1); hold on;
    bar([1;3;5], tmp.mean_d([1,3,5]), barWidth,'FaceColor',[0 0 0]);
    bar([2;4;6], tmp.mean_d([2,4,6]), barWidth,'FaceColor',[1 1 1]);
    
    x=[2.5 6.5 6.5 2.5];
    y = [0 0 0.6 0.6];
    fill(x,y, [.5 .5 .5]);
    bar([1;3;5], tmp.mean_d([1,3,5]), barWidth,'FaceColor',[0 0 0 ]);
    bar([2;4;6], tmp.mean_d([2,4,6]), barWidth,'FaceColor',[1 1 1]);
    for i = 1:length(tmp.mean_d)
        errorbar(i, tmp.mean_d(i), tmp.sem_d(i), 'k', 'linewidth',2);
    end
    ylabel("Recognition sensitivity (d')");
    xlim([0.5 6.5]);
%     xlabel('Experiment');
    xticks([1:6]);
    xticklabels({'Exp.1A', 'Exp.1B','Exp.2A', 'Exp.2B', 'Exp.3A', 'Exp.3B'});
    set(gca,'XTickLabelRotation',70);
    title('(A)');
    hold off;
    
    
    subplot(1,2,2); hold on;
    bar([1;3;5], tmp.mean_c([1,3,5]), barWidth,'FaceColor',[0 0 0]);
    bar([2;4;6], tmp.mean_c([2,4,6]), barWidth,'FaceColor',[1 1 1 ]);
    
    % plot background
    x=[2.5 6.5 6.5 2.5];
    y = [0 0 -0.35 -0.35];
    fill(x,y, [.5 .5 .5]);
    % plot for a second time in order to set correct background and legend
    bar([1;3;5], tmp.mean_c([1,3,5]), barWidth,'FaceColor',[0 0 0]);
    bar([2;4;6], tmp.mean_c([2,4,6]), barWidth,'FaceColor',[1 1 1]);   
    
    for i = 1:length(tmp)
        errorbar(i, tmp.mean_c(i), tmp.sem_c(i), 'k', 'linewidth',2);
    end
    legend('High Contrast', 'Low Contrast', 'Mesopic');
    ylabel("Recognition bias (c)");
    xlim([0.5 6.5]);
    ylim([-0.4 0.1]);
    
    xticks([1:6]);
    xticklabels({'Exp.1A', 'Exp.1B','Exp.2A', 'Exp.2B', 'Exp.3A', 'Exp.3B'});
    set(gca,'XTickLabelRotation',70);
    title('(B)');
    saveas(gcf,'../figures/fig6_responsebias.png')
    hold off;
    
end
  
  