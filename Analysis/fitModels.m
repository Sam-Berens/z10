function [Models] = fitModels()
[DataTable00,DataTable01,DataTable02] = getDataTables();
DataTable00 = DataTable00(DataTable00.nValid>100,:);
DataTable01 = DataTable01(DataTable01.nValid>100,:);
DataTable02 = DataTable02(DataTable02.nValid>100,:);

Models = struct;

%% Glme00
Models.Glme00.formula = 'k ~ 1 + DyslexiaDiagnosis*SetId + (1|SubjectId)';
Models.Glme00.mdl = fitglme(DataTable00,...
    Models.Glme00.formula,...
    'Distribution','Binomial','BinomialSize',DataTable00.n,'Link','logit');
Models.Glme00.anova = anova(Models.Glme00.mdl);
disp(Models.Glme00.anova);

%% Glme01
Models.Glme01.formula = ...
    'Correct ~ 1 + DyslexiaDiagnosis*SetId*RepetitionCount + (1|SubjectId)';
Models.Glme01.mdl = fitglme(DataTable01,...
    Models.Glme01.formula,...
    'Distribution','Binomial','BinomialSize',1,'Link','logit');
Models.Glme01.anova = anova(Models.Glme01.mdl);
disp(Models.Glme01.anova);

%% Glme02
Models.Glme02.formula = ...
    'RT ~ 1 + DyslexiaDiagnosis*SetId*RepetitionCount*Age + (1|SubjectId)';
Models.Glme02.mdl = fitglme(DataTable02,...
     Models.Glme02.formula,...
    'Distribution','Gamma','Link','log');
Models.Glme02.anova = anova(Models.Glme02.mdl);
disp(Models.Glme02.anova);

%% Glme03
Models.Glme03.formula = ['RT ~ 1 + ',...
    'DyslexiaDiagnosis*SetId*Age*apCorrect + ',...
    'DyslexiaDiagnosis*SetId*Age*apCorrect^2 + ',...
    '(1|SubjectId)'];
Models.Glme03.mdl = fitglme(DataTable02,...
    Models.Glme03.formula,...
    'Distribution','Gamma','Link','log');
Models.Glme03.anova = anova(Models.Glme03.mdl);
disp(Models.Glme03.anova);
return