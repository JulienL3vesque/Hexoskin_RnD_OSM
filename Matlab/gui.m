function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 09-Mar-2017 12:05:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

% Get saved variables
TimeStart = getappdata(0,'TimeStart');
TimeEnd = getappdata(0,'TimeEnd');
Buffer = getappdata(0,'Buffer');
Index = getappdata(0,'Index');
fs = getappdata(0,'fs');
LongRQuality = getappdata(0,'LongRQuality');
Interval = getappdata(0,'Interval');
Segment = getappdata(0,'Segment');
Value = getappdata(0,'Value');
RIndex = getappdata(0,'RIndex');
RealTime = getappdata(0,'RealTime');
Warnings = getappdata(0,'Warnings');
ImportantWarnings = getappdata(0,'ImportantWarnings');

Temp = findall(0,'tag','Msgbox_Warning Dialog');

if ~isempty(Temp)
    set(handles.uipanel1,'BackgroundColor','red');
    set(handles.edit1,'BackgroundColor','red');
    set(handles.text3,'BackgroundColor','red');
    set(handles.edit1,'String','Alert Detected');
end

% Get the displayed warnings
ListBoxStrings = get(handles.listbox,'String');

[ImportantWarnings] = SelectImportantWarnings(ImportantWarnings,...
     Warnings, fs, RealTime);
 
setappdata(0,'ImportantWarnings',ImportantWarnings);

for i = size(ListBoxStrings)+1:size(ImportantWarnings)
    OldString = get(handles.listbox,'String'); 
    NewString = strvcat(OldString,ImportantWarnings{i,1});
    set(handles.listbox,'String',NewString);
    if isempty(Temp)
        % When a warning occurs change background color to yellow
        set(handles.uipanel1,'BackgroundColor','yellow');
        set(handles.edit1,'BackgroundColor','yellow');
        set(handles.text3,'BackgroundColor','yellow');
        set(handles.edit1,'String','Warning Detected');
    end
end

% Realtime Plot
Axis1 = NewPlot( TimeStart, TimeEnd, Buffer, Index, fs, ...
    LongRQuality, Interval, Segment, Value,handles,RIndex);

% Clear the axis to reduce number of plots to prevent crashing
cla (handles.axes);
% Select the axis for plotting
axes(handles.axes);
% Plot again after we clear so no chnage is noticed
title('Lead II Filtered ECG');
xlabel('Time(sec)'),ylabel('mV');

if TimeEnd + 1 - 2*fs < 1
    Time = ((TimeStart)/fs:1/fs:(TimeEnd)/fs);
	Plot1 = plot(Axis1,Time,Buffer.Plot(TimeStart+1 :TimeEnd+1));
    PlotPoints(TimeStart, TimeEnd, Buffer, Index, fs, ...
        LongRQuality, Interval, Segment, Value, TimeEnd+1, Time,RIndex);
else
    Time = ((TimeEnd)/fs-2:1/fs:(TimeEnd)/fs);
    Plot1 = plot(Axis1,Time,Buffer.Plot(TimeEnd + 1 - 2*fs :TimeEnd+1));
    PlotPoints(TimeEnd - 2*fs, TimeEnd, Buffer, Index, fs, ...
        LongRQuality, Interval, Segment, Value, TimeEnd+1, Time,RIndex);
end
set(Plot1,'Color','b');
hold on;

varargout{1} = handles.output;


% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Warnings = getappdata(0,'Warnings');
ImportantWarnings = getappdata(0,'ImportantWarnings');
Buffer = getappdata(0,'Buffer');
fs = getappdata(0,'fs');

GraphWarning(Warnings,ImportantWarnings,fs,Buffer);

% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in pushbutton2.
uiwait();

function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume();


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)

Warnings = getappdata(0,'Warnings');
ImportantWarnings = getappdata(0,'ImportantWarnings');
fs = getappdata(0,'fs');

[Warnings,ImportantWarnings] = DeleteWarning(Warnings,...
    ImportantWarnings,fs,handles);

setappdata(0,'Warnings',Warnings);
setappdata(0,'ImportantWarnings',ImportantWarnings);




