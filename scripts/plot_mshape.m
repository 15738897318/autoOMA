function varargout = plot_mshape(varargin)
% PLOT_MSHAPE MATLAB code for plot_mshape.fig
%      PLOT_MSHAPE, by itself, creates a new PLOT_MSHAPE or raises the existing
%      singleton*.
%
%      H = PLOT_MSHAPE returns the handle to a new PLOT_MSHAPE or the handle to
%      the existing singleton*.
%
%      PLOT_MSHAPE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOT_MSHAPE.M with the given input arguments.
%
%      PLOT_MSHAPE('Property','Value',...) creates a new PLOT_MSHAPE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plot_mshape_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plot_mshape_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plot_mshape

% Last Modified by GUIDE v2.5 15-Mar-2017 13:30:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plot_mshape_OpeningFcn, ...
                   'gui_OutputFcn',  @plot_mshape_OutputFcn, ...
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


% --- Executes just before plot_mshape is made visible.
function plot_mshape_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plot_mshape (see VARARGIN)

%store the modal parameter on application data
for i=1:length(varargin{1}.modepar)
    fn(i) = varargin{1}.modepar(i).fn;
    mshape(:,:,i) = varargin{1}.modepar(i).regrid;
end
fn_string = num2str(fn','%.2f Hz');

setappdata(0,'fn_string', fn_string);
setappdata(0,'fn', fn);
setappdata(0,'mshape', mshape);

%store the frf or singular values on application data
if strcmp(varargin{1}.type, 'ema')
    setappdata(0,'spectrum',varargin{1}.frf);
elseif strcmp(varargin{1}.type, 'oma')
    setappdata(0,'spectrum',varargin{1}.svalue);
end

%create initial global indexing for plot
setappdata(0,'index_left',1);
setappdata(0,'index_right',1);
setappdata(0,'maxindex',length(fn))

%initial plot
plot_axes(handles.plot_left, 1);
plot_axes(handles.plot_right,1);


%create dropdown list
set(handles.dropdown_left,'String',fn_string);
set(handles.dropdown_right,'String',fn_string);

% Choose default command line output for plot_mshape
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plot_mshape wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plot_mshape_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in dropdown_left.
function dropdown_left_Callback(hObject, eventdata, handles)
% hObject    handle to dropdown_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dropdown_left contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdown_left

%update the mode shape plot selection index
val = get(hObject,'Value');
setappdata(0,'index_left',val);

%plot the mode shape grid
plot_axes(handles.plot_left, val);


% --- Executes during object creation, after setting all properties.
function dropdown_left_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dropdown_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%obtain the list of fn


% --- Executes on selection change in dropdown_right.
function dropdown_right_Callback(hObject, eventdata, handles)
% hObject    handle to dropdown_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dropdown_right contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dropdown_right

%update the mode shape plot selection index
val = get(hObject,'Value');
setappdata(0,'index_right',val);

%plot the mode shape grid
plot_axes(handles.plot_right, val);



% --- Executes during object creation, after setting all properties.
function dropdown_right_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dropdown_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in prev_left.
function prev_left_Callback(hObject, eventdata, handles)
% hObject    handle to prev_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get current index value
index = getappdata(0,'index_left') - 1;
if index <= 0    
    index = 1;
end

%update index value
setappdata(0,'index_left', index);

%update the graph and dropdown
set(handles.dropdown_left, 'Value', index);
plot_axes(handles.plot_left, index);


% --- Executes on button press in next_left.
function next_left_Callback(hObject, eventdata, handles)
% hObject    handle to next_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get current index value
index = getappdata(0,'index_left') + 1;
if index > getappdata(0, 'maxindex')   
    index = getappdata(0, 'maxindex');
end

%update index value
setappdata(0,'index_left', index);

%update the graph and dropdown
set(handles.dropdown_left, 'Value', index);
plot_axes(handles.plot_left, index);


% --- Executes on button press in prev_right.
function prev_right_Callback(hObject, eventdata, handles)
% hObject    handle to prev_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get current index value
index = getappdata(0,'index_right') - 1;
if index <= 0    
    index = 1;
end

%update index value
setappdata(0,'index_right', index);

%update the graph and dropdown
set(handles.dropdown_right, 'Value', index);
plot_axes(handles.plot_right, index);


% --- Executes on button press in next_right.
function next_right_Callback(hObject, eventdata, handles)
% hObject    handle to next_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get current index value
index = getappdata(0,'index_right') + 1;
if index > getappdata(0, 'maxindex')   
    index = getappdata(0, 'maxindex');
end

%update index value
setappdata(0,'index_right', index);

%update the graph and dropdown
set(handles.dropdown_right, 'Value', index);
plot_axes(handles.plot_right, index);


% --- Executes on button press in show_frf.
function show_frf_Callback(hObject, eventdata, handles)
% hObject    handle to show_frf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ----------------helper functions----------------------- %

function plot_axes(handle, index)
% handle        handle of the plot_axes
% mshape_grid   index of mode shape
mshape_grid = getappdata(0, 'mshape');
surf(handle, mshape_grid(:,:,index));
rotate3d on;