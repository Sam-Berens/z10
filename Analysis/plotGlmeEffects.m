function [Models,Figs,PlotData] = plotGlmeEffects(varargin)
%PLOTGLMEEFFECTS Fit the GLMEs and plot their key fixed-effect patterns.
%   [Models,Figs,PlotData] = PLOTGLMEEFFECTS() calls FITMODELS() and
%   visualises the DyslexiaDiagnosis-by-SetId-by-RepetitionCount effects in
%   Glme01 and Glme02. By default it also draws an apCorrect figure for
%   Glme03.
%
%   Name-value pairs:
%       'IncludeGlme03'      - logical scalar, default true.
%       'AgeValue'           - scalar age used for Glme02/Glme03
%                              predictions. Default is the median age in
%                              DataTable02.
%       'Glme03BinCount'     - number of observed-data bins for Glme03,
%                              default 10.
%       'Visible'            - 'on' or 'off', default 'on'.
%       'UseShadedErrorBar'  - logical scalar, default true when
%                              shadedErrorBar() is on the MATLAB path.
%
%   Example:
%       addpath('Analysis');
%       plotGlmeEffects('IncludeGlme03',true);

opts = parseInputs(varargin{:});
analysisDir = fileparts(mfilename('fullpath'));
addpath(analysisDir);

[~,DataTable01,DataTable02] = getDataTables();
DataTable01 = DataTable01(DataTable01.nValid>100,:);
DataTable02 = DataTable02(DataTable02.nValid>100,:);

if isempty(opts.AgeValue)
    opts.AgeValue = localMedian(DataTable02.Age);
end

Models = fitModels();

setLevels = categories(DataTable01.SetId);
dxValues = [0,1];
dxLabels = {'No dyslexia','Dyslexia'};
dxColors = [0.08,0.44,0.70; 0.84,0.34,0.12];

obs01 = summariseByRepetition(DataTable01,'Correct');
pred01 = predictByRepetition(Models.Glme01.mdl,DataTable01,0:21,[],setLevels,dxValues);
pGlme01 = getTermPValue(Models.Glme01.anova,...
    'DyslexiaDiagnosis:SetId:RepetitionCount');
title01 = sprintf(['Glme01: accuracy by repetition and set ',...
    '(Dx x Set x Repetition p = %s)'],formatPValue(pGlme01));
Figs.Glme01 = createRepetitionFigure(obs01,pred01,setLevels,dxValues,...
    dxLabels,dxColors,'Probability correct',title01,[0,1],opts);

obs02 = summariseByRepetition(DataTable02,'RT');
pred02 = predictByRepetition(Models.Glme02.mdl,DataTable02,0:21,...
    opts.AgeValue,setLevels,dxValues);
pGlme02_3way = getTermPValue(Models.Glme02.anova,...
    'DyslexiaDiagnosis:SetId:RepetitionCount');
pGlme02_4way = getTermPValue(Models.Glme02.anova,...
    'Age:DyslexiaDiagnosis:SetId:RepetitionCount');
title02 = sprintf(['Glme02: RT by repetition and set at Age = %.1f years ',...
    '(3-way p = %s, Age 4-way p = %s)'],opts.AgeValue,...
    formatPValue(pGlme02_3way),formatPValue(pGlme02_4way));
Figs.Glme02 = createRepetitionFigure(obs02,pred02,setLevels,dxValues,...
    dxLabels,dxColors,'Reaction time (ms)',title02,[],opts);

PlotData.Glme01.Observed = obs01;
PlotData.Glme01.Predicted = pred01;
PlotData.Glme02.Observed = obs02;
PlotData.Glme02.Predicted = pred02;

if opts.IncludeGlme03
    validAp = DataTable02.apCorrect(~isnan(DataTable02.apCorrect));
    q = linspace(0,1,opts.Glme03BinCount+1);
    binEdges = quantile(validAp,q);
    binEdges = unique(binEdges);
    if numel(binEdges) < 3
        binEdges = linspace(min(validAp),max(validAp),opts.Glme03BinCount+1);
    end

    obs03 = summariseByBins(DataTable02,'RT','apCorrect',binEdges);
    apGrid = linspace(min(validAp),max(validAp),150);
    pred03 = predictByApCorrect(Models.Glme03.mdl,DataTable02,apGrid,...
        opts.AgeValue,setLevels,dxValues);

    pGlme03_lin = getTermPValue(Models.Glme03.anova,...
        'DyslexiaDiagnosis:SetId:apCorrect');
    pGlme03_quad = getTermPValue(Models.Glme03.anova,...
        'DyslexiaDiagnosis:SetId:(apCorrect^2)');
    title03 = sprintf(['Glme03: RT by apCorrect at Age = %.1f years ',...
        '(linear p = %s, quadratic p = %s)'],opts.AgeValue,...
        formatPValue(pGlme03_lin),formatPValue(pGlme03_quad));
    Figs.Glme03 = createApCorrectFigure(obs03,pred03,setLevels,dxValues,...
        dxLabels,dxColors,'Reaction time (ms)',title03,opts);

    PlotData.Glme03.Observed = obs03;
    PlotData.Glme03.Predicted = pred03;
else
    Figs.Glme03 = [];
end
return

function opts = parseInputs(varargin)
opts = struct;
opts.IncludeGlme03 = true;
opts.AgeValue = [];
opts.Glme03BinCount = 10;
opts.Visible = 'on';
opts.UseShadedErrorBar = exist('shadedErrorBar','file') == 2;

if mod(numel(varargin),2) ~= 0
    error('plotGlmeEffects:BadInput',...
        'Name-value arguments must come in pairs.');
end

for ii = 1:2:numel(varargin)
    name = varargin{ii};
    value = varargin{ii+1};
    switch lower(name)
        case 'includeglme03'
            opts.IncludeGlme03 = logical(value);
        case 'agevalue'
            opts.AgeValue = double(value);
        case 'glme03bincount'
            opts.Glme03BinCount = double(value);
        case 'visible'
            if islogical(value)
                opts.Visible = onOff(value);
            else
                opts.Visible = char(string(value));
            end
        case 'useshadederrorbar'
            opts.UseShadedErrorBar = logical(value);
        otherwise
            error('plotGlmeEffects:UnknownOption',...
                'Unknown option "%s".',name);
    end
end

if ~isscalar(opts.IncludeGlme03)
    error('plotGlmeEffects:BadInput',...
        'IncludeGlme03 must be a logical scalar.');
end

if ~isempty(opts.AgeValue) && (~isscalar(opts.AgeValue) || isnan(opts.AgeValue))
    error('plotGlmeEffects:BadInput',...
        'AgeValue must be a finite scalar.');
end

if ~isscalar(opts.Glme03BinCount) || opts.Glme03BinCount < 3
    error('plotGlmeEffects:BadInput',...
        'Glme03BinCount must be a scalar greater than or equal to 3.');
end
return

function predTbl = predictByRepetition(mdl,T,repValues,ageValue,setLevels,dxValues)
[dxGrid,setGrid,repGrid] = ndgrid(dxValues,1:numel(setLevels),repValues);
nRows = numel(dxGrid);

predTbl = table;
predTbl.SubjectId = repmat(T.SubjectId(1),nRows,1);
predTbl.DyslexiaDiagnosis = dxGrid(:);
predTbl.SetId = categorical(setLevels(setGrid(:)),setLevels);
predTbl.RepetitionCount = repGrid(:);

if ~isempty(ageValue)
    predTbl.Age = repmat(ageValue,nRows,1);
end

[mu,muCI] = predict(mdl,predTbl,'Conditional',false,'DFMethod','None');
predTbl.Predicted = mu;
predTbl.Lower = muCI(:,1);
predTbl.Upper = muCI(:,2);
predTbl = sortrows(predTbl,{'SetId','DyslexiaDiagnosis','RepetitionCount'});
return

function predTbl = predictByApCorrect(mdl,T,apValues,ageValue,setLevels,dxValues)
[dxGrid,setGrid,apGrid] = ndgrid(dxValues,1:numel(setLevels),apValues);
nRows = numel(dxGrid);

predTbl = table;
predTbl.SubjectId = repmat(T.SubjectId(1),nRows,1);
predTbl.DyslexiaDiagnosis = dxGrid(:);
predTbl.SetId = categorical(setLevels(setGrid(:)),setLevels);
predTbl.Age = repmat(ageValue,nRows,1);
predTbl.apCorrect = apGrid(:);

[mu,muCI] = predict(mdl,predTbl,'Conditional',false,'DFMethod','None');
predTbl.Predicted = mu;
predTbl.Lower = muCI(:,1);
predTbl.Upper = muCI(:,2);
predTbl = sortrows(predTbl,{'SetId','DyslexiaDiagnosis','apCorrect'});
return

function summaryTbl = summariseByRepetition(T,responseVar)
response = double(T.(responseVar));
valid = isfinite(response) & ...
    ~ismissing(T.SubjectId) & ...
    ~isnan(T.DyslexiaDiagnosis) & ...
    ~ismissing(T.SetId) & ...
    isfinite(T.RepetitionCount);

T = T(valid,:);
response = response(valid);

[gSubject,~,dxValue,setValue,repValue] = findgroups(...
    T.SubjectId,T.DyslexiaDiagnosis,T.SetId,T.RepetitionCount);
subjectMean = splitapply(@localMean,response,gSubject);

[gGroup,dxGroup,setGroup,repGroup] = findgroups(dxValue,setValue,repValue);
summaryTbl = table;
summaryTbl.DyslexiaDiagnosis = dxGroup;
summaryTbl.SetId = setGroup;
summaryTbl.RepetitionCount = repGroup;
summaryTbl.Mean = splitapply(@localMean,subjectMean,gGroup);
summaryTbl.SEM = splitapply(@localSEM,subjectMean,gGroup);
summaryTbl.N = splitapply(@localCount,subjectMean,gGroup);
summaryTbl = sortrows(summaryTbl,{'SetId','DyslexiaDiagnosis','RepetitionCount'});
return

function summaryTbl = summariseByBins(T,responseVar,xVar,binEdges)
x = T.(xVar);
y = double(T.(responseVar));
binIdx = discretize(x,binEdges);

valid = isfinite(x) & isfinite(y) & ...
    ~ismissing(T.SubjectId) & ...
    ~isnan(T.DyslexiaDiagnosis) & ...
    ~ismissing(T.SetId) & ...
    ~isnan(binIdx);

T = T(valid,:);
x = x(valid);
y = y(valid);
binIdx = binIdx(valid);

[gSubject,~,dxValue,setValue,binValue] = findgroups(...
    T.SubjectId,T.DyslexiaDiagnosis,T.SetId,binIdx);
subjectMeanX = splitapply(@localMean,x,gSubject);
subjectMeanY = splitapply(@localMean,y,gSubject);

[gGroup,dxGroup,setGroup,binGroup] = findgroups(dxValue,setValue,binValue);
summaryTbl = table;
summaryTbl.DyslexiaDiagnosis = dxGroup;
summaryTbl.SetId = setGroup;
summaryTbl.Bin = binGroup;
summaryTbl.X = splitapply(@localMean,subjectMeanX,gGroup);
summaryTbl.Mean = splitapply(@localMean,subjectMeanY,gGroup);
summaryTbl.SEM = splitapply(@localSEM,subjectMeanY,gGroup);
summaryTbl.N = splitapply(@localCount,subjectMeanY,gGroup);
summaryTbl = sortrows(summaryTbl,{'SetId','DyslexiaDiagnosis','Bin'});
return

function fig = createRepetitionFigure(obsTbl,predTbl,setLevels,dxValues,...
        dxLabels,dxColors,yLabel,titleText,yLimits,opts)
fig = figure('Color','w',...
    'Name',titleText,...
    'Visible',opts.Visible,...
    'Units','pixels',...
    'Position',[80,80,1320,460]);
tl = tiledlayout(fig,1,numel(setLevels),'TileSpacing','compact',...
    'Padding','compact');

legendHandles = gobjects(1,2*numel(dxValues));
legendLabels = cell(1,2*numel(dxValues));

for iSet = 1:numel(setLevels)
    ax = nexttile(tl);
    hold(ax,'on');
    setLevel = categorical(setLevels(iSet),setLevels);

    for iDx = 1:numel(dxValues)
        obsMask = obsTbl.DyslexiaDiagnosis == dxValues(iDx) & ...
            obsTbl.SetId == setLevel;
        predMask = predTbl.DyslexiaDiagnosis == dxValues(iDx) & ...
            predTbl.SetId == setLevel;

        obsSlice = sortrows(obsTbl(obsMask,:), 'RepetitionCount');
        predSlice = sortrows(predTbl(predMask,:), 'RepetitionCount');

        if ~isempty(yLimits)
            predSlice.Predicted = min(max(predSlice.Predicted,yLimits(1)),yLimits(2));
            predSlice.Lower = min(max(predSlice.Lower,yLimits(1)),yLimits(2));
            predSlice.Upper = min(max(predSlice.Upper,yLimits(1)),yLimits(2));
        else
            predSlice.Lower = max(predSlice.Lower,eps);
            predSlice.Upper = max(predSlice.Upper,eps);
        end

        hModel = plotPredictionBand(ax,predSlice.RepetitionCount,...
            predSlice.Predicted,predSlice.Lower,predSlice.Upper,...
            dxColors(iDx,:));
        hObs = plotObservedSummary(ax,obsSlice.RepetitionCount,obsSlice.Mean,...
            obsSlice.SEM,dxColors(iDx,:),opts.UseShadedErrorBar);

        if iSet == 1
            legendHandles(2*iDx-1) = hModel;
            legendHandles(2*iDx) = hObs;
            legendLabels{2*iDx-1} = sprintf('%s model',dxLabels{iDx});
            legendLabels{2*iDx} = sprintf('%s observed',dxLabels{iDx});
        end
    end

    title(ax,sprintf('Set %s',setLevels{iSet}),'FontWeight','bold');
    xlabel(ax,'Repetition count');
    if iSet == 1
        ylabel(ax,yLabel);
    end
    xlim(ax,[min(predTbl.RepetitionCount),max(predTbl.RepetitionCount)]);
    if ~isempty(yLimits)
        ylim(ax,yLimits);
    end
    styleAxes(ax);
end

sgtitle(tl,titleText,'FontWeight','bold');
attachLegend(legendHandles,legendLabels);
return

function fig = createApCorrectFigure(obsTbl,predTbl,setLevels,dxValues,...
        dxLabels,dxColors,yLabel,titleText,opts)
fig = figure('Color','w',...
    'Name',titleText,...
    'Visible',opts.Visible,...
    'Units','pixels',...
    'Position',[80,580,1320,460]);
tl = tiledlayout(fig,1,numel(setLevels),'TileSpacing','compact',...
    'Padding','compact');

legendHandles = gobjects(1,2*numel(dxValues));
legendLabels = cell(1,2*numel(dxValues));

for iSet = 1:numel(setLevels)
    ax = nexttile(tl);
    hold(ax,'on');
    setLevel = categorical(setLevels(iSet),setLevels);

    for iDx = 1:numel(dxValues)
        obsMask = obsTbl.DyslexiaDiagnosis == dxValues(iDx) & ...
            obsTbl.SetId == setLevel;
        predMask = predTbl.DyslexiaDiagnosis == dxValues(iDx) & ...
            predTbl.SetId == setLevel;

        obsSlice = sortrows(obsTbl(obsMask,:), 'X');
        predSlice = sortrows(predTbl(predMask,:), 'apCorrect');
        predSlice.Lower = max(predSlice.Lower,eps);
        predSlice.Upper = max(predSlice.Upper,eps);

        hModel = plotPredictionBand(ax,predSlice.apCorrect,...
            predSlice.Predicted,predSlice.Lower,predSlice.Upper,...
            dxColors(iDx,:));
        hObs = plotObservedSummary(ax,obsSlice.X,obsSlice.Mean,...
            obsSlice.SEM,dxColors(iDx,:),opts.UseShadedErrorBar);

        if iSet == 1
            legendHandles(2*iDx-1) = hModel;
            legendHandles(2*iDx) = hObs;
            legendLabels{2*iDx-1} = sprintf('%s model',dxLabels{iDx});
            legendLabels{2*iDx} = sprintf('%s observed',dxLabels{iDx});
        end
    end

    title(ax,sprintf('Set %s',setLevels{iSet}),'FontWeight','bold');
    xlabel(ax,'apCorrect');
    if iSet == 1
        ylabel(ax,yLabel);
    end
    xlim(ax,[min(predTbl.apCorrect),max(predTbl.apCorrect)]);
    styleAxes(ax);
end

sgtitle(tl,titleText,'FontWeight','bold');
attachLegend(legendHandles,legendLabels);
return

function hLine = plotPredictionBand(ax,x,y,yLow,yHigh,colorValue)
x = x(:);
y = y(:);
yLow = yLow(:);
yHigh = yHigh(:);

patch(ax,[x;flipud(x)],[yLow;flipud(yHigh)],colorValue,...
    'FaceAlpha',0.18,...
    'EdgeColor','none',...
    'HandleVisibility','off');
hLine = plot(ax,x,y,'-','Color',colorValue,'LineWidth',2.4);
return

function hLine = plotObservedSummary(ax,x,y,sem,colorValue,useShadedErrorBar)
x = x(:);
y = y(:);
sem = sem(:);
obsColor = lightenColor(colorValue,0.45);

if useShadedErrorBar && exist('shadedErrorBar','file') == 2
    try
        axes(ax); %#ok<LAXES>
        hold(ax,'on');
        hShade = shadedErrorBar(x,y,sem,'lineProps','--');
        set(hShade.mainLine,...
            'Color',obsColor,...
            'LineWidth',1.1,...
            'Marker','o',...
            'MarkerSize',4,...
            'MarkerFaceColor','w');
        set(hShade.patch,...
            'FaceColor',obsColor,...
            'FaceAlpha',0.10,...
            'HandleVisibility','off');
        if isfield(hShade,'edge')
            set(hShade.edge,...
                'Color',obsColor,...
                'LineStyle',':',...
                'HandleVisibility','off');
        end
        hLine = hShade.mainLine;
        return
    catch
    end
end

patch(ax,[x;flipud(x)],[y-sem;flipud(y+sem)],obsColor,...
    'FaceAlpha',0.08,...
    'EdgeColor','none',...
    'HandleVisibility','off');
hLine = plot(ax,x,y,'--o',...
    'Color',obsColor,...
    'LineWidth',1.1,...
    'MarkerSize',4,...
    'MarkerFaceColor','w');
return

function attachLegend(legendHandles,legendLabels)
validHandles = legendHandles(isgraphics(legendHandles));
validLabels = legendLabels(isgraphics(legendHandles));
if isempty(validHandles)
    return
end

try
    lgd = legend(validHandles,validLabels,...
        'Orientation','horizontal',...
        'Location','southoutside');
    lgd.Box = 'off';
    lgd.Layout.Tile = 'south';
catch
    legend(validHandles,validLabels,...
        'Orientation','horizontal',...
        'Location','southoutside',...
        'Box','off');
end
return

function styleAxes(ax)
box(ax,'off');
grid(ax,'on');
ax.TickDir = 'out';
ax.LineWidth = 1;
ax.GridAlpha = 0.15;
ax.MinorGridAlpha = 0.08;
ax.FontName = 'Helvetica';
ax.FontSize = 11;
ax.Layer = 'top';
return

function pValue = getTermPValue(anovaTable,termName)
pValue = NaN;
if istable(anovaTable)
    varNames = anovaTable.Properties.VariableNames;
else
    try
        varNames = anovaTable.Properties.VarNames;
    catch
        return
    end
end

if ~ismember('Term',varNames)
    return
end
termStrings = strtrim(cellstr(string(anovaTable.Term)));
idx = strcmp(termStrings,termName);
if any(idx)
    pValue = anovaTable.pValue(find(idx,1,'first'));
end
return

function txt = formatPValue(pValue)
if isnan(pValue)
    txt = 'n/a';
elseif pValue < 1e-3
    txt = sprintf('%.2g',pValue);
else
    txt = sprintf('%.3f',pValue);
end
return

function out = lightenColor(in,amount)
out = in + (1-in).*amount;
out = min(max(out,0),1);
return

function out = localMean(in)
in = in(~isnan(in));
if isempty(in)
    out = NaN;
else
    out = mean(in);
end
return

function out = localSEM(in)
in = in(~isnan(in));
if numel(in) <= 1
    out = NaN;
else
    out = std(in,0) ./ sqrt(numel(in));
end
return

function out = localCount(in)
out = sum(~isnan(in));
return

function out = localMedian(in)
in = in(~isnan(in));
if isempty(in)
    out = NaN;
else
    out = median(in);
end
return

function out = onOff(in)
if in
    out = 'on';
else
    out = 'off';
end
return
