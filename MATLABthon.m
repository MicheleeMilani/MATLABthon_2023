%% MATLABthon - TEAM 6

% The goal of this script is to analyze data taken from the user's phone sensors. 
% The user will receive some statistics on the activity carried out, including Walking, 
% Running and Cycling, such as average speed, average acceleration, number of steps and 
% number of calories consumed, as well as some graphs such as speed vs. time, 
% topographic/satellite map of the route taken.

%% Collecting Data

% Load data from .mat file (called DATA)
load('DATA.mat')

% Extract position data
lat = Position.latitude;
lon = Position.longitude;
alt = Position.altitude;
speed = Position.speed;
course = Position.course;

% Extract acceleration data
accel_x = Acceleration.X;
accel_y = Acceleration.Y;
accel_z = Acceleration.Z;

% Transform the array containing the date and time of the DATA points collected 
% in an array of the time elapsed since the acquisition was started

time = Position.Timestamp;
time_pos_sec = timeElapsed(time); % array of position's time

time = Acceleration.Timestamp;
time_acc_sec = timeElapsed(time); % array of acceleration's time

%% Inputs

% Health data
fprintf('\n---- Health Data ----\n\n')
height = input('Insert your height [cm] : '); 
weight = input('Insert your weigth [kg] : ');

% Workout data
fprintf('\n\n---- Workout Data ----\n\n')
prompt = 'Insert the activity [Walking - Running - Cycling] : ';
activity = input(prompt, 's');

% Map view
fprintf('\n\n---- Map View ---- \n\n')
% User is asked to select a preference regarding the map view 
prompt = 'Choose how to see your Workout on map [Topographic - Satellite] : ';
type_of_view = input(prompt,"s");

%% Workout Details

% From this point of the script, 'Workout Details' will be computed and
% displayed on the 'Command Window'
fprintf('\n\n---- Workout Details ---- \n\n')

%% Activity duration

duration = time_pos_sec(end) - time_pos_sec(1); % seconds

% Convert time from seconds to hours : minutes : seconds

% Take the integer part of the time in hours
duration_hour = duration / 3600;
hour = fix(duration_hour);
% Take the decimal part of the result and multiply it by 60 and take the integer part
% of the new result
duration_min = (duration_hour - hour) * 60;
min = fix(duration_min);
% Take the decimal part of that result and multiply it by 60. Round the last result
% to the nearest integer
duration_sec = (duration_min - min) * 60;
sec = ceil(duration_sec);

fprintf('Workout Time: %d h : %d min : %d sec', hour, min, sec)

%% Step counter 

% To count the step we calculate the total distance traveled (in ft) and then dividing it 
% by your stride length (distance taken for one step). 
% In particular we have two different formulas to calculate the stride length: 
% in case you're walking the formula is the one below:
% stride_walk = height/4 + 1.2139107612,
% in case you're running the formula is:
% stride_run = height * (0.65/0.3048)

earthCirc = 24901; % Earth circumference 
totaldis = 0;

for i = 1: (length(lat)-1)

    lat1 = lat(i); % First latitude
    lat2 = lat(i+1); % Second latitude
    lon1 = lon(i); % First longitude
    lon2 = lon(i+1); % Second longitude

    [diff, az] = distance(lat1, lon1, lat2, lon2);
    dis = (diff/360) * earthCirc;

    totaldis = totaldis + dis; % kilometers 

end

height = (height*1e-2)/0.3048; % [ft]

stride_walk = height/4 + 1.2139107612; % stride during walk [ft]
stride_run = height * (0.65/0.3048); % stride during run [ft]

totaldis_ft = totaldis*3281; % ft
steps_walk = totaldis_ft/stride_walk;
steps_run = totaldis_ft/stride_run;

fprintf('\nDistance = %.2f m\n',totaldis*1e3)

if strcmp(activity, 'Walking')
    fprintf('Steps = %.0f\n',ceil(steps_walk))

elseif strcmp(activity, 'Running')
    fprintf('Steps = %.0f\n',ceil(steps_run))
end

%% Visualize data of speed / average speed vs. time

% Average speed calculation
mean_vel = mean(speed);
fprintf('\nAverage Speed: %.1f km/h', mean_vel * 3.6)

figure; hold on; grid on
plot(time_pos_sec, speed * 3.6, 'b', 'LineWidth', 1.5)
plot(time_pos_sec, mean_vel * 3.6 * ones(length(time_pos_sec)), 'r', 'LineWidth', 2)
title('Speed - Time','FontSize',16)
xlabel('Time [s]')
ylabel('Speed [km/h]')
legend('Speed', 'Average Speed','Location','northeast','fontsize',16)

%% Visualize data of acceleration / average acceleration vs. time

accel = [];
for i = 1: length(accel_x)
    accel(i) = sqrt(accel_x(i)^2 + accel_y(i)^2 + accel_z(i)^2);
end

% Average acceleration calculation
mean_acc = mean(accel);
fprintf('\nMean Acceleration: %.1f m/s^2\n', mean_acc)

figure; hold on; grid on
plot(time_acc_sec, accel', 'ko-', 'LineWidth', 0.5)
plot(time_acc_sec, mean_acc * ones(length(time_acc_sec)), 'r', 'LineWidth', 2)
title('Acceleration - Time','FontSize',16)
xlabel('Time [s]')
ylabel('Acceleration [m/s^2]')
legend('Acceleration', 'Average Acceleration','Location','northeast','fontsize',16)


%% Altitude diagram

figure; grid on;
plot(time_pos_sec,alt,'r',linewidth=1.5)
title('Altitude-time',FontSize=16)
xlabel('Time [s]',FontSize=16)
ylabel('Altitude [m]',FontSize=16)

%% Calories burned

% Calories coefficients
% Walking	0.653 kcal/(mi.lb)
% Running	0.790 kcal/(mi.lb)
% Cycling	0.28 kcal/(mi.lb)

if strcmp(activity, 'Walking')
    cal = 0.653 / (weight * 2.20462) / (totaldis * 0.621371); % [kcal]

elseif strcmp(activity, 'Running')
    cal = 0.790 / (weight * 2.20462) / (totaldis * 0.621371); % [kcal]

elseif strcmp(activity, 'Cycling')
    cal = 0.28 / (weight * 2.20462) / (totaldis * 0.621371); % [kcal]

end

fprintf('\nCalories Burned %f kcal \n', cal)

%% Tracking map

% Add On - Mapping Toolbox version 5.5

if strcmp(type_of_view,'Topographic') 
    figure;
    geodensityplot(lat,lon,alt,'FaceColor','#20B2AA','Radius',3); hold on
    geoplot(lat,lon,'Color','#1E90FF','LineWidth',3)
    geoplot(lat(1),lon(1),"Marker",".","MarkerFaceColor",'g','MarkerSize',40)
    geoplot(lat(end),lon(end),"Marker",".","MarkerFaceColor",'r','MarkerSize',40)
    text = strcat(num2str(totaldis),' KM',' - ',activity,' - Topographic view');
    title(text,'FontSize',16)
    geobasemap('topographic')
    legend('Elevation','Path','Starting Point','Ending Point','Location','northeast','fontsize',16)
    
elseif strcmp(type_of_view,'Satellite')
    figure;
    geodensityplot(lat,lon,alt,'FaceColor','#EE7600','Radius',3); hold on
    geoplot(lat,lon,'Color','#EE3B3B','LineWidth',3)
    geoplot(lat(1),lon(1),"Marker",".","MarkerFaceColor",'g','MarkerSize',40)
    geoplot(lat(end),lon(end),"Marker",".","MarkerFaceColor",'r','MarkerSize',40)
    text = strcat(num2str(totaldis),' KM',' - ',activity,' - Satellite view');
    title(text,'FontSize',16)
    geobasemap('satellite')
    legend('Elevation','Path','Starting Point','Ending Point','Location','northeast','fontsize',16)
end
