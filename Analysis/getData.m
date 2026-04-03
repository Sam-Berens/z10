function [Data] =  getData()

Data = webread('https://c01.learningandinference.org/GetData.php');
Data = struct2table(Data);

%% 1. SubjectId
Data.SubjectId = categorical(Data.SubjectId);

%% 2. Birth month+year
Data.DoB = datetime(Data.DoB,...
    'InputFormat','yyyy-MM',...
    'TimeZone','Europe/London') ...
    + duration(30.44*24/2,0,0);
% We add on 1/2 the average number of days in a month to minimise the
% expected error.

%% 3. Gender
female = cellfun(@(s)strcmpi(s(1),'f'),Data.Gender);
male = cellfun(@(s)strcmpi(s(1),'m'),Data.Gender);
nonbinary = ~(male|female);
Data.Gender = categorical(...
    cellstr(char([female,male,nonbinary]*double('fmn')')));

%% 4. UkPrimary
Data.UkPrimary = categorical(Data.UkPrimary);

%% 5. UkSecondary
Data.UkSecondary = categorical(Data.UkSecondary);

%% 6. ThinkDyscalculia
Data.ThinkDyscalculia = categorical(Data.ThinkDyscalculia);

%% 7. DyscalculiaDiagnosis
Data.DyscalculiaDiagnosis = categorical(Data.DyscalculiaDiagnosis);

%% 8. EnjoyMaths
Data.EnjoyMaths = categorical(Data.EnjoyMaths);

%% 9. ThinkDyslexia
Data.ThinkDyslexia = categorical(Data.ThinkDyslexia);

%% 10. DyslexiaDiagnosis
Data.DyslexiaDiagnosis = categorical(Data.DyslexiaDiagnosis);

%% 11. Chess
Data.Chess = categorical(Data.Chess);

%% 12. Football
Data.Football = categorical(Data.Football);

%% 13. Golf
Data.Golf = categorical(Data.Golf);

%% 14. Jigsaw
Data.Jigsaw = categorical(Data.Jigsaw);

%% 15. Monopoly
Data.Monopoly = categorical(Data.Monopoly);

%% 16. Riding
Data.Riding = categorical(Data.Riding);

%% 17. Rugby
Data.Rugby = categorical(Data.Rugby);

%% 18. Swimming
Data.Swimming = categorical(Data.Swimming);

%% 19. Tennis
Data.Tennis = categorical(Data.Tennis);

%% 20. Trivia
Data.Trivia = categorical(Data.Trivia);

%% 21-22. DateTime_*
varNames = Data.Properties.VariableNames;
for ii = 21:22
    s = varNames{ii};
    Data.(s) = datetime(Data.(s),'TimeZone','Europe/London');
end

%% 23. ClientTimeZone
Data.ClientTimeZone = categorical(Data.ClientTimeZone);

%% 24-25. TaskIO
TaskIO = cellfun(@decodeTaskIO,Data.TaskIO);
TaskIO = struct2table(TaskIO);
TaskIO.Properties.VariableNames{1} = 'DateTime_Start';
TaskIO.Properties.VariableNames{2} = 'TaskIO';
TaskIO.TaskDuration = Data.DateTime_Train - ...
    TaskIO.DateTime_Start;
TaskIO = [TaskIO(:,1),TaskIO(:,3),TaskIO(:,2)];
Data = [Data(:,1:23),TaskIO];
return

function [out] = decodeTaskIO(in)
if isempty(in)
    out.DateTime_Start = NaT;
    out.DateTime_Start.TimeZone = 'Europe/London';
    out.Trials = struct();
    return
end
out = jsondecode(in);
out.DateTime_Start = datetime(out.DateTime_Start,...
    'InputFormat','yyyyMMdd_HHmmss',...
    'TimeZone','Europe/London');
out = rmfield(out,'SubjectId');
out = rmfield(out,'ClientTimeZone');
out = rmfield(out,'GroupId');
out = rmfield(out,'Pairs');
return