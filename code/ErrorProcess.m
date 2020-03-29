%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Description:   plot mean error rates (figure 2 in the manuscript)
%% Author: Xuelian Zang
%% Contact: zangxuelian@gmail.com or lianlian81821@126.com
%% Date: 15/10/2013
%% updatedate : 28/03/2020
%% modified by Fiona
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = ErrorProcess(dataAll, dataErr, nEpAll, nExp, subNum)

lineType = ['ko-';  'k.-'; 'k^-';  'k*-'; 'k>-' ; 'k<-'];
figure();  set(gcf,'Units','inches','Position',[4.5 0.5 6.83*0.55 6.83*0.45] ); hold on;
for iExp = 1:nExp
    fieldName = ['p' num2str(iExp)];
    dataErrCurr = dataErr(dataErr.NExp == iExp, :);
    dataAllCurr = dataAll(dataAll.NExp == iExp, :);
    % process miss trial
    out.misSpss.(fieldName) =  dataErrorProcess( dataErrCurr(dataErrCurr.Crr == -1, :), subNum, nEpAll);
    out.misRates.(fieldName) = mean( mean(out.misSpss.(fieldName), 2));
    
    % process error trial
    out.errSpss.(fieldName) = dataErrorProcess( dataErrCurr( dataErrCurr.Crr == 0, :), subNum, nEpAll);
    out.errRates.(fieldName) = mean( mean(out.errSpss.(fieldName), 2));
    
    %analysis of speed accuracy trade-off by separate error rates
    %into 4 quantiles
    out.errRTTradeOff.(fieldName)  = speedAccuracyTradeOff( dataAllCurr, dataErrCurr, subNum);
    plot(1 : 4,  mean(out.errRTTradeOff.(fieldName) ) ,  lineType(iExp,:) ,'linewidth', 1.5);
end
legend('Exp.1', 'Exp.2', 'Exp.3', 'Exp.4' , 'Exp.5', 'Exp.6');
legend('Location', 'NorthWest');
legend('boxoff');
xlabel('The four quartile regions of RTs');
ylabel('Error rates (%)');
set(gca,'yLim',[0 3]);
set(gca,'xLim',[0.5 4.5]);
set(gca,'xTick',[1:4]);
set(gca,'xTicklabel', [' < Q1' ; 'Q1-Q2' ; 'Q2-Q3' ; ' > Q3'] );
hold off;

end

function errRTTradeOff  = speedAccuracyTradeOff(dataValid, dataErr,  subNum)
errRTTradeOff = [];
for iSub = 1 : subNum
    arrayRTTmp =  dataValid(dataValid.NSub == iSub, :);
    arrayErrTmp = dataErr(dataErr.NSub == iSub & dataErr.Crr == 0, :);
    quantileTmp = quantile(arrayRTTmp.RT, [.25  .5  .75  ]) ;
    %error trial per region
    errArray25 = 0;  errArray50 = 0;  errArray75 = 0;  errArray100 = 0;
    if ~isempty(arrayErrTmp(arrayErrTmp.RT <= quantileTmp(1) , :) )
        errArray25 =  length(arrayErrTmp(arrayErrTmp.RT <= quantileTmp(1) , :) );
    end
    
    if ~isempty(arrayErrTmp(arrayErrTmp.RT> quantileTmp(1)  & arrayErrTmp.RT <= quantileTmp(2) , :) )
        errArray50 =  length(arrayErrTmp(arrayErrTmp.RT> quantileTmp(1)  & arrayErrTmp.RT <= quantileTmp(2) , :) );
    end
    
    if ~isempty(arrayErrTmp(arrayErrTmp.RT> quantileTmp(2) & arrayErrTmp.RT <= quantileTmp(3) , :) )
        errArray75 =  length(arrayErrTmp(arrayErrTmp.RT> quantileTmp(2)  & arrayErrTmp.RT <= quantileTmp(3) , :) );
    end
    
    if ~isempty(arrayErrTmp(arrayErrTmp.RT> quantileTmp(3), :) )
        errArray100 =   length(arrayErrTmp(arrayErrTmp.RT> quantileTmp(3), :) ) ;
    end
    errRTTradeOff = [errRTTradeOff; errArray25, errArray50, errArray75, errArray100 ];
    
end
errRTTradeOff = 100* errRTTradeOff./ 480;
end



function errOut = dataErrorProcess(dataIn, subNum, nEpAll)
[mErr eErr cErr gErr] = grpstats(dataIn.RT, {dataIn.NSub, dataIn.New, dataIn.NE}); % old/new NE
   tmpArray = [];
   for i = 1:length(mErr)
       tmpArray  = [tmpArray; mErr(i), cErr(i), eval(gErr{i,1}), eval(gErr{i,2}), eval(gErr{i,3})];
   end
   
   tmpErrorArray = [];
   for i = 1:subNum
       for t = 0:1
           for j = 1:nEpAll
                tmp = tmpArray(tmpArray(:,3) == i & tmpArray(:,4) == t & tmpArray(:,5) == j,:);
                if isempty (tmp)
                    tmpErrorArray = [tmpErrorArray; -1, 0, i, t,j];
                else
                    tmpErrorArray = [tmpErrorArray;tmp];
                end
           end
       end
   end
   errOut = 100*reshape(tmpErrorArray(:,2),[],subNum)'/40;
end
