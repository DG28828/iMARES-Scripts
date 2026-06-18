%% ---   Caracterización de la base de datos de parámetros de viento   ---
%
% Tipo de datos de entrada:    (Reanálisis|Medido)
% Proyecto:     
%
%% INSTRUCCIONES PARA EL USUARIO: Importación, adaptación de datos y configuraciones del script
%
% Este script no requiere que los datos originales provengan de un formato
% específico. El usuario puede importar sus datos desde archivos .mat, .csv,
% .xlsx, .dat, NetCDF u otra fuente.
%
% Sin embargo, antes de continuar con el procesamiento, los datos deben
% reorganizarse en el struct "datos_usuario", con el formato estándar
% solicitado en dicha sección.
%
% El script asume que "datos_usuario" ya tiene los campos, dimensiones y 
% nombres requeridos.
%
% Pasos a seguir:
%
%   1) Modificar configuración general en sección en:   1. Configuración general.
%   2) Importar datos en sección en:                    2. Importación de datos.
%   3) Adaptar el código en:                            3. Adaptación al formato estándar.
%   4) Configurar opciones de gráficas en:              4. Configuración de gráficos.

%% Inicialización
clc; clear; close all
if ~isdeployed
    cd(fileparts(mfilename('fullpath')))
end

%% 1. Configuración general

% ------------------  Nombre para archivos de salida  ---------------------
% -------------------------------------------------------------------------
%
%Nombre clave o código que se desee agregar para identificar archivos de
%salida. Si no se desea agregar nada, dejar vacío nombre = ''.
nombre = '_Datos_Ejemplo_';

% -------------- Directorios para guardado de datos y figuras -------------
% -------------------------------------------------------------------------

% Directorio para guardado de datos organizados y separados por mes y temporadas
save_dir_dat = 'save_dir_dat\';

% Directorio para guardado de figuras
save_dir_fig = 'save_dir_fig\';

%Directorio para guardado de datos para programa CAROL
save_dir_CAROL = 'save_dir_CAROL\';

% ---------------------   Nodos o puntos de interés  ----------------------
% -------------------------------------------------------------------------
%
% Indicar los identificadores de los nodos/puntos que se desean analizar.
%
%  Ejemplo: nodos = [28, 29, 30]
% Para bases con un único punto, usar: nodos = 1;
nodos = 1;

% Índice dentro del vector "nodos" que se usará para gráficos/exportaciones
nodo = 1;

% ---------------------    Fechas de interés    ---------------------------
% -------------------------------------------------------------------------
%
% Si se desea usar todo el registro disponible, dejar ambas variables vacías:
%
%   Fecha_inicial = [];
%   Fecha_final   = [];
%
% Si se desea definir un rango específico, usar el formato:
%
%   Fecha_inicial = [AAAA, MM, DD, HH];
%   Fecha_final   = [AAAA, MM, DD, HH];
Fecha_inicial = [1979, 01, 01, 00];  
Fecha_final   = [2025, 10, 17, 23];

% ---------------      Configuración de temporadas       ------------------
% -------------------------------------------------------------------------
%
% Controla qué subconjuntos se generan, exportan y grafican.
%
% Opciones disponibles:
%   "all"  : serie completa.
%   "high" : temporada alta.
%   "low"  : temporada baja.
%
% Ejemplos:
%   seasons = ["all"];                 % Solo total
%   seasons = ["high", "low"];         % Solo temporadas
%   seasons = ["high", "low", "all"]; % Temporadas y total
seasons = ["all"];

% Meses asociados a cada temporada.
% Solo se usan si "high" o "low" están incluidos en seasons.
high_months = [12 1 2];
low_months  = [9 10];

% -----------   Variables para exportar datos para CAROL   ----------------
% -------------------------------------------------------------------------
%
% Controla que variables se exportan a formato de entrada para CAROL, por
% defecto se tiene: variables_CAROL = ["W", "Dw"];
%
% En caso de ser requerido, se puede eliminar del vector las variables que 
% no se deseen exportar.
%
variables_CAROL = ["W", "Dw"];

%% 2. Importación de datos
% -------------------------------------------------------------------------
% Se puede importar sus datos desde cualquier fuente.
% Este bloque es el único que debe modificarse si cambia el origen de datos.
% -------------------------------------------------------------------------

archivo_entrada = 'example_data\wind_parameters.dat';

viento_crudo = readtable(archivo_entrada);

%% 3. Adaptación al formato estándar
% -------------------------------------------------------------------------
% A partir de este punto, el script requiere que los datos queden guardados
% en el struct "datos_usuario", con los siguientes campos:
%
%   datos_usuario.fecha : [N x 4] o [N x 6] -> [Año Mes Día Hora Min Seg]
%   datos_usuario.W     : [N x P]
%   datos_usuario.Dw    : [N x P]
%   datos_usuario.nodes : [1 x P]
%
% Donde:
%   N = número de registros temporales.
%   P = número de nodos, puntos o ubicaciones.
% -------------------------------------------------------------------------

datos_usuario = struct();

datos_usuario.fecha = [ ...
    viento_crudo.Year, ...
    viento_crudo.Mes, ...
    viento_crudo.Dia, ...
    viento_crudo.Hora];

datos_usuario.W  = viento_crudo.W(:);
datos_usuario.Dw = viento_crudo.Dw(:);

datos_usuario.nodes = 1;

%% 4. Configuración de gráficos

graf = struct();

% =========================
% Parámetros generales
% =========================
graf.general.ext = "png";                % Extensión/formato de salida de las figuras
graf.general.dpi = 300;                  % Resolución de exportación en dpi
graf.general.font = "Calibri";           % Tipo de letra general
graf.general.back_col = "white";         % Color de fondo de la figura y ejes
graf.general.face_color = "#22646e";     % Color de relleno para histogramas
graf.general.visible = "on";             % Visibilidad de las figuras: "on" u "off"

graf.general.W = 14;                     % Ancho de la figura en centímetros
graf.general.H = 10;                     % Alto de la figura en centímetros
graf.general.Of_W = 1.5;                 % Offset horizontal de los ejes
graf.general.Of_H = 1.3;                 % Offset vertical de los ejes

graf.general.TFax = 12;                  % Tamaño de fuente de los valores de los ejes
graf.general.TFLabel = 12;               % Tamaño de fuente de etiquetas y título
graf.general.TWax = "normal";            % Peso de fuente de los valores de los ejes
graf.general.TWLabel = "bold";           % Peso de fuente de etiquetas y título

graf.general.grid_pdf = "on,on,--,0.5,k";    % Configuración de grilla para PDF
graf.general.grid_cdf = "off,off,--,0.5,k";  % Configuración de grilla para CDF

% =========================
% Boxplot mensual
% =========================
graf.box.ColorCaja = [0.4 0.6 0.4];      % Color de las cajas del boxplot
graf.box.MedianColor = [0.4 0.6 0.4];    % Color de la línea de la mediana
graf.box.Whisker = 1.5;                  % Longitud de bigotes respecto al rango intercuartílico
graf.box.Symbol = '*';                   % Símbolo para valores atípicos
graf.box.Widths = 0.6;                   % Ancho relativo de las cajas
graf.box.ShowMedianLine = false;         % Mostrar u ocultar línea que conecta medianas

% =========================
% W
% =========================
graf.W.unidad = "m/s";


graf.W.box.ylabel = "W (m/s)";           % Etiqueta del eje y para boxplot mensual
graf.W.box.ColorCaja = [0.4 0.6 0.4];      % Color de las cajas del boxplot
graf.W.box.MedianColor = [0.4 0.6 0.4];    % Color de la línea de la mediana
graf.W.box.Whisker = 1.5;                  % Longitud de bigotes respecto al rango intercuartílico
graf.W.box.Symbol = '*';                   % Símbolo para valores atípicos
graf.W.box.Widths = 0.6;                   % Ancho relativo de las cajas
graf.W.box.ShowMedianLine = false;         % Mostrar u ocultar línea que conecta medianas
graf.W.box.Limy = [-0.4, 14.5];

graf.W.pdf.nbins = 50;                  % Cantidad de bins para el histograma.
graf.W.pdf.Limx = 2;                    % Control de límites del eje x en PDF
graf.W.pdf.Limy = 2;                    % Control de límites del eje y en PDF
graf.W.pdf.XTick = 0:1:11;              % Marcas del eje x en PDF
graf.W.pdf.YTick = 0:0.1:0.5;           % Marcas del eje y en PDF
graf.W.pdf.TextX = 8.3;                 % Posición x del texto estadístico en PDF
graf.W.pdf.TextY = 0.28;                % Posición y inicial del texto estadístico en PDF
graf.W.pdf.TextStep = 0.04;             % Separación vertical entre textos en PDF
graf.W.pdf.TextSize = 11;

graf.W.cdf.Limx = 2;                    % Control de límites del eje x en CDF
graf.W.cdf.Limy = 2;                    % Control de límites del eje y en CDF
graf.W.cdf.XTick = 0:1:10;              % Marcas del eje x en CDF
graf.W.cdf.YTick = 0:0.1:1;             % Marcas del eje y en CDF
graf.W.cdf.TextX = 7.5;                 % Posición x del texto de cuantiles en CDF
graf.W.cdf.TextY = 0.5;                 % Posición y inicial del texto de cuantiles en CDF
graf.W.cdf.TextStep = 0.06;             % Separación vertical entre textos en CDF
graf.W.cdf.TextSize = 10;

graf.W.rose.ndir = 16;                  % Número de sectores direccionales de la rosa
graf.W.rose.mag_bar = 0:2:10;           % Intervalos de magnitud para la rosa
graf.W.rose.maxq = 100;                 % Frecuencia máxima radial de la rosa
graf.W.rose.griddiv = 5;                % Número de divisiones radiales de frecuencia
graf.W.rose.freqangle = 340;            % Ángulo de ubicación de etiquetas radiales
graf.W.rose.rad = 1/10;                 % Radio del círculo interior de la rosa

%% 5. Particionado de parámetros por meses y temporadas

tipo_datos = "viento";   % "oleaje" o "viento"

[datos_procesados, info_particionado] = IM_split_months_seasons(datos_usuario, tipo_datos, nodos, nodo, ...
                                                                "Fecha_inicial", Fecha_inicial, ...
                                                                "Fecha_final", Fecha_final, ...
                                                                "seasons", seasons, ...
                                                                "high_months", high_months, ...
                                                                "low_months", low_months);

month_names = info_particionado.month_names;
season_label = info_particionado.season_label;
direccion_variable = info_particionado.direccion_variable;

%% 6. Crear carpetas de guardado en caso de no existir

IM_check_folders({save_dir_dat, save_dir_fig, save_dir_CAROL}, ...
                "disp_flag", true);

%% 7. Exportar struct de datos para uso posterior

save(fullfile(save_dir_dat, ['Parametros_Oleaje_', nombre ,'_Temporadas.mat']), "datos_procesados", '-mat')

%% 8. Exportar .dat para Carol

IM_export_CAROL( ...
                datos_procesados, ...
                nodo, ...
                variables_CAROL, ...
                seasons, ...
                save_dir_CAROL, ...
                nombre);

%% Viento: W

variable = 'W'; % 'W', 'Dw'

IM_plot_statitics( ...
            datos_procesados, ...
            nodo, ...
            variable, ...
            direccion_variable, ...
            month_names, ...
            seasons, ...
            season_label, ...
            graf, ...
            nombre, ...
            save_dir_fig);


%% Graficos de series temporales

f = figure('Name', 'Grafico de series temporales de parámetros del oleaje');

subplot(2, 1, 1)
plot(datos_procesados.fechas.datetime, datos_procesados.params(nodo).W.all)
ylabel('W (m/s)'); grid on;

subplot(2, 1, 2)
plot(datos_procesados.fechas.datetime, datos_procesados.params(nodo).Dw.all)
ylabel('Dirección (°)'); grid on;

xlabel('Fecha');

f.Position = [200, 200, 1200, 600];

saveas(f, fullfile(save_dir_fig, 'series_temporales'), 'png');






