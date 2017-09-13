function [Warnings,ImportantWarnings] = DeleteWarning(Warnings,...
    ImportantWarnings,fs,handles)
% This function deletes the warning along with the 3 other instances it
% occured in

% If the listbox is not empty
if ~isempty(get(handles.listbox,'String'))
    
    % Get the location to be deleted
    WarningID = get(handles.listbox,'Value');
    
    % Save the old warnings
    OldWarnings = Warnings;
    OldImportantWarnings = ImportantWarnings;
    
    WarningType = ImportantWarnings{WarningID,1};
    WarningLocation = ImportantWarnings{WarningID,2};
    
    % Empty the Warnings cell
    Warnings = cell(0,0);
    ImportantWarnings = cell(0,0);
    
    OldString = '';    
    NewString = '';

    WarningIDs = GetWarnings( OldWarnings,WarningType,WarningLocation,...
       WarningID,fs);

    % This loop saves all the warnings except for the one that has to be
    % deleted
    for k = 1:size(OldWarnings)
        % Boolean to indicate if we save the warning or not
        Save = 1;
        
        for z = 1:length(WarningIDs)
           if k == WarningIDs(z)
               Save = 0;
           end
        end
        
        if Save 
            Warnings{end+1,1} = OldWarnings{k,1};
            Warnings{end,2} = OldWarnings{k,2};
        end
    end
    
    % This loop saves all the important warnings except for the one that 
    % has to be deleted 
    % And creates a string to be displayed in the listbox
    for k = 1:size(OldImportantWarnings)
        if k ~= WarningID
            ImportantWarnings{end+1,1} = OldImportantWarnings{k,1};
            ImportantWarnings{end,2} = OldImportantWarnings{k,2};
            % combine the wanted warnings in one big string
            NewString = strvcat(OldString,OldImportantWarnings{k,1});
        end
        OldString = NewString;
    end

    % If the warning is the last in the list then we have to modify the
    % Value in the listbox 
    % Since the listbox tries to highlight the last value but it wont find
    % it; thats why we decrease it by one
    if WarningID == get(handles.listbox,'Value')&& WarningID ~= 1
       set(handles.listbox,'Value',WarningID - 1); 
    end
    % Add the warnings to the listbox
    set(handles.listbox,'String',NewString);
    
    % If all the warnings are deleted switch the color back to Grey
    if isempty(get(handles.listbox,'String'))
        set(handles.uipanel1,'BackgroundColor',[0.94 0.94 0.94]);
        set(handles.edit1,'BackgroundColor',[0.94 0.94 0.94]);
        set(handles.text3,'BackgroundColor',[0.94 0.94 0.94]);
        set(handles.edit1,'String','Healthy');
    end
    
end
end










