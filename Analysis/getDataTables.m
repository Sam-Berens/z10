function [DataTable00,DataTable01,DataTable02] = getDataTables()

if exist('DataTables.mat','file')
    X = load('DataTables.mat');
    DataTable00 = X.DataTable00;
    DataTable01 = X.DataTable01;
    DataTable02 = X.DataTable02;
    return
end

%% Get the data
Data =  getData();

%% Call getMiniTabs()
rng(1729);
fh = waitbar(0,'Processing...');
for iSubject = 1:size(Data,1)
    [Ta,Tb] = getMiniTabs(...
        Data.TaskIO{iSubject},...
        Data.SubjectId(iSubject));
    if iSubject == 1
        DataTable00 = Tb;
        DataTable01 = Ta;
    else
        DataTable00 = [DataTable00;Tb]; %#ok<*AGROW>
        DataTable01 = [DataTable01;Ta];
    end
    waitbar(iSubject/size(Data,1),fh);
end
close(fh);

%% Extract columns from Data to join
Data2Add = table;
Data2Add.SubjectId = Data.SubjectId;
Data2Add.ClientTimeZone = Data.ClientTimeZone;
Data2Add.TaskDuration = Data.TaskDuration;
Data2Add.Age = years(Data.DateTime_Start-Data.DoB);
Data2Add = [Data2Add,Data(:,3:20)];

%% Make the output tables
DataTable00 = outerjoin(Data2Add,DataTable00);
DataTable00.Properties.VariableNames{1} = 'SubjectId';
DataTable00.SubjectId_DataTable00 = [];

DataTable01 = outerjoin(Data2Add,DataTable01);
DataTable01.Properties.VariableNames{1} = 'SubjectId';
DataTable01.SubjectId_DataTable01 = [];

DataTable02 = DataTable01;
DataTable01.RT = [];
S = DataTable02.ReinforcedResponse==DataTable02.Response;
DataTable02 = DataTable02(S,:);
DataTable02 = DataTable02(DataTable02.RT>200,:);

%% Save
save('DataTables.mat','DataTable00','DataTable01','DataTable02');
retrun