function [Ta,Tb] = getMiniTabs(TaskIO,SubjetId)
%% Ta for DataTable01
Ta = struct2table(TaskIO);
if iscell(Ta.Correct)
    missing = cellfun(@isempty,Ta.Correct);
    Ta.Correct(missing) = num2cell(rand(sum(missing),1)>0.5);
    Ta.RT(missing) = num2cell(nan(sum(missing),1));
    Ta.Correct = cell2mat(Ta.Correct);
    Ta.RT = cell2mat(Ta.RT);
end
Ta.StimId = categorical(Ta.StimId);
Ta.SetId = categorical(Ta.SetId);
Ta.DiscrimId = categorical(Ta.DiscrimId);
Ta.ReinforcedResponse = categorical(Ta.ReinforcedResponse);
Ta.Response = categorical(Ta.Response);
Ta.pCorrect = nan(size(Ta.Response));
Ta.apCorrect = nan(size(Ta.Response));

%% Ta for DataTable00
Tb = table;
Tb.SetId = categorical(repmat({''},3,1));
Tb.b0 = nan(3,1);
Tb.b1 = nan(3,1);
Tb.k = nan(3,1);
Tb.n = nan(3,1);
Tb.mRtc = nan(3,1);
iIn = 0;
x = (0:22)';
uSetId = unique(Ta.SetId);
for iSetId = 1:numel(uSetId)
    uDiscrimId = unique(Ta.DiscrimId);
    pmid = nan(23,3);
    for iDiscrimId = 1:3
        y = Ta.Correct(uSetId(iSetId)==Ta.SetId & ...
            uDiscrimId(iDiscrimId)==Ta.DiscrimId);
        [~, ~, cpmid, ~, ~] = runanalysis_sam(y, 1, 0.5, 0.005, 2);
        Ta.pCorrect(...
            Ta.SetId==uSetId(iSetId) & ...
            Ta.DiscrimId==categorical(iDiscrimId)) = cpmid(1:end-1);
        pmid(:,iDiscrimId) = cpmid(1:end)';
    end
    y = geomean(pmid,2);
    mdl = fitglm(table(x,y),'y ~ 1 + x','Link','logit');
    k = sum(Ta.Correct(uSetId(iSetId)==Ta.SetId));
    n = sum(uSetId(iSetId)==Ta.SetId);
    mRtc = nanmean(Ta.RT((uSetId(iSetId)==Ta.SetId)&(Ta.Correct)));
    
    iIn = iIn + 1;
    Tb.SetId(iIn) = uSetId(iSetId);
    Tb.b0(iIn) = mdl.Coefficients.Estimate(1);
    Tb.b1(iIn) = mdl.Coefficients.Estimate(2);
    Tb.k(iIn) = k;
    Tb.n(iIn) = n;
    Tb.mRtc(iIn) = mRtc;
end

%% Finish off
Ta.apCorrect = (Ta.pCorrect-0.5).*2;
Tc = table(repmat(SubjetId,size(Ta,1),1),'VariableNames',{'SubjectId'});
Ta = [Tc,Ta];
Tc = table(repmat(SubjetId,size(Tb,1),1),'VariableNames',{'SubjectId'});
Tb = [Tc,Tb];
return