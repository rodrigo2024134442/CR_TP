function data = convert_categoricals(data)
% Converte variáveis categóricas para numéricas
% maintenance_level e operating_mode → ordinal (têm ordem natural)
% cooling_type e sensor_status → binário (apenas 2 valores, sem ordem)

% maintenance_level: Low=0, Medium=1, High=2
ml = data.maintenance_level;
data.maintenance_level = zeros(height(data), 1);
data.maintenance_level(strcmp(ml, 'Low'))    = 0;
data.maintenance_level(strcmp(ml, 'Medium')) = 1;
data.maintenance_level(strcmp(ml, 'High'))   = 2;

% operating_mode: Idle=0, Normal=1, Overload=2
om = data.operating_mode;
data.operating_mode = zeros(height(data), 1);
data.operating_mode(strcmp(om, 'Idle'))     = 0;
data.operating_mode(strcmp(om, 'Normal'))   = 1;
data.operating_mode(strcmp(om, 'Overload')) = 2;

% cooling_type: Air=0, Oil=1
ct = data.cooling_type;
data.cooling_type = zeros(height(data), 1);
data.cooling_type(strcmp(ct, 'Air')) = 0;
data.cooling_type(strcmp(ct, 'Oil')) = 1;

% sensor_status: OK=0, Warning=1
ss = data.sensor_status;
data.sensor_status = zeros(height(data), 1);
data.sensor_status(strcmp(ss, 'OK'))      = 0;
data.sensor_status(strcmp(ss, 'Warning')) = 1;

end