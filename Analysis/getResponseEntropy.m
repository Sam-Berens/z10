function [dH,zH,nValid] = getResponseEntropy(Data)
h = cellfun(@getH,Data.TaskIO);
nValid = cellfun(@getN,Data.TaskIO);

rng(196883);
nI = 1e5;
h0 = nan(nI,1);
for ii = 1:nI
    r = randi([0,1],198,1);
    B = crosstab(r(1:end-2),r(2:end-1),r(3:end));
    b = B(:);
    p = b./sum(b);
    h0(ii) = -sum(p.*log2(p));
end
zH = (mean(h0)-h)./std(h0);
dH = 3-h;
return

function [h] = getH(TaskIO)
r = categorical({TaskIO.Response}');
B = crosstab(r(1:end-2),r(2:end-1),r(3:end));
b = B(:);
p = b./sum(b);
h = -sum(p.*log2(p));
return

function [n] = getN(TaskIO)
r = [TaskIO.RT]';
n = numel(r);
return