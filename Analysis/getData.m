function [Data] =  getData()

Data = webread('https://z10.learningandinference.org/GetData.php');
Data = struct2table(Data);

%% 1. SubjectId
Data.SubjectId = categorical(Data.SubjectId);

%% 2. Birth month+year
Data.DoB = datetime(Data.DoB,...
    'InputFormat','yyyy-MM-dd HH:mm:ss',...
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
Data.UkPrimary = binariseVar(Data.UkPrimary);

%% 5. UkSecondary
Data.UkSecondary = binariseVar(Data.UkSecondary);

%% 6. ThinkDyscalculia
Data.ThinkDyscalculia = binariseVar(Data.ThinkDyscalculia);

%% 7. DyscalculiaDiagnosis
Data.DyscalculiaDiagnosis = binariseVar(Data.DyscalculiaDiagnosis);

%% 8. EnjoyMaths
Data.EnjoyMaths = binariseVar(Data.EnjoyMaths);

%% 9. ThinkDyslexia
Data.ThinkDyslexia = binariseVar(Data.ThinkDyslexia);

%% 10. DyslexiaDiagnosis
Data.DyslexiaDiagnosis = binariseVar(Data.DyslexiaDiagnosis);

%% 11. Chess
Data.Chess = binariseVar(Data.Chess);

%% 12. Football
Data.Football = binariseVar(Data.Football);

%% 13. Golf
Data.Golf = binariseVar(Data.Golf);

%% 14. Jigsaw
Data.Jigsaw = binariseVar(Data.Jigsaw);

%% 15. Monopoly
Data.Monopoly = binariseVar(Data.Monopoly);

%% 16. Riding
Data.Riding = binariseVar(Data.Riding);

%% 17. Rugby
Data.Rugby = binariseVar(Data.Rugby);

%% 18. Swimming
Data.Swimming = binariseVar(Data.Swimming);

%% 19. Tennis
Data.Tennis = binariseVar(Data.Tennis);

%% 20. Trivia
Data.Trivia = binariseVar(Data.Trivia);

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
return

function [o] = binariseVar(in)
y = strcmpi(in,'Yes');
n = strcmpi(in,'No');
o = double(y);
o(~(y|n)) = NaN;
return