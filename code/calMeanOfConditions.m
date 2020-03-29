%Name:                calMeanOfConditions.m
%
%Autor:               Xuelian Zang
%Description:         calculate the mean of the data (e.g., RT, dFix, nFix)
%with context and epoch as factors
%Date:                07/07/2014 
function out = calMeanOfConditions(DependFactor, factor1, factor2, factor3,  nSub, nEp, nEpT, titleIn)

   
%dataN.RTSpssArray: o1e1 o1e2 o1e3...
   [m e c g] = grpstats(DependFactor, {factor1, factor2, factor3}); % old/new  NE
   testArray = [];
   for i = 1:length(m)
       testArray  = [testArray ; m(i), e(i), eval(g{i,1}), eval(g{i,2}), eval(g{i,3})];
   end
   dataOut.test = dataset({reshape(testArray(:,1),[],nSub)', ...
       'o1e1', 'o1e2', 'o1e3', 'o1e4','o1e5','o1e6', 'o2e1', 'o2e2', 'o2e3', 'o2e4','o2e5','o2e6'}); 
   
   %% adjust error bar
   out.spssArray = double(dataOut.test );
   [m e c g] = grpstats(testArray(:,1),{testArray(:,4), testArray(:,5)});
   out.m = m;
   out.e = e; 
   out.c = c;
   out.g = g;
   
   %contextual cueing
   ccArray = [(testArray(testArray(:, 4) == 1, 1) - testArray(testArray(:, 4) == 0, 1)) ,  testArray(testArray(:, 4) == 1, 3:end)];
   ccArray(:, 3) = []; 
 
   ccArray = dataset( {ccArray, 'CC','NSub',  'NEp'}) ;
   out.CCArray = dataset( { reshape( ccArray.CC,  [], nSub)' , ...
       'e1', 'e2', 'e3', 'e4','e5','e6'}); 
   meanAll = grpstats( ccArray, 'NEp', {'mean', 'sem'}, 'DataVars', 'CC');
   out.mCC = meanAll.mean_CC;
   out.eCC = meanAll.sem_CC; 
   
   %normalized cueing effect
   ccArray = [(testArray(testArray(:, 4) == 1, 1) - testArray(testArray(:, 4) == 0, 1)) ./ testArray(testArray(:, 4) == 1, 1), ...
       testArray(testArray(:, 4) == 1, 3:end)];
   ccArray(:, 3) = []; 
 
   ccArray = dataset( {ccArray, 'CC','NSub',  'NEp'}) ;
   out.CCArrayNorm = dataset( { reshape( ccArray.CC,  [], nSub)' , ...
       'e1', 'e2', 'e3', 'e4','e5','e6', }); 
   meanAll = grpstats( ccArray, 'NEp', {'mean', 'sem'}, 'DataVars', 'CC');
   out.mCCNorm = meanAll.mean_CC;
   out.eCCNorm  = meanAll.sem_CC; 
  
 