function eachTable = filterbycolumn (dataTable, columnname, columnvalue)

% FILTERBYCOLUMN Filter the table by looking for column with fieldvalue 
%
%  dataTable = filterbycolumn (dataTable, columnname, columnvalue)
%
% where 
%      

i = ismember(dataTable.(columnname), columnvalue);
eachTable = dataTable(i,:);
end