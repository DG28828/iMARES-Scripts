function [f, count, speeds, directions, Table, ax] = IM_plot_rose(dir, dat, opts)
%IM_plot_rose Grafica rosas direccionales mediante la función WindRose.
%
% Esta función genera una rosa direccional a partir de un vector de
% direcciones náuticas y un vector de magnitudes asociadas. Las direcciones
% se convierten internamente de coordenadas náuticas a coordenadas
% cartesianas para ser usadas por WindRose.
%
% Uso mínimo:
%   IM_plot_rose(dir, dat)
%
% Uso con opciones:
%   IM_plot_rose(dir, dat, ...
%       "titulo", "Rosa direccional", ...
%       "legenvar", "Hm0", ...
%       "legenbar", "Magnitud de Hm0 [m]", ...
%       "mag_bar", 0:1:4, ...
%       "cmap", "jet")
%
% Uso para guardar figura:
%   IM_plot_rose(dir, dat, ...
%       "Name", "rosa_Hm0", ...
%       "save_dir", "C:\Figuras", ...
%       "ext", "png", ...
%       "dpi", 300)
%
% -------------------------------------------------------------------------
% Argumentos de entrada requeridos
% -------------------------------------------------------------------------
% dir:
%   Vector numérico de direcciones en coordenadas náuticas, en grados.
%   Convención náutica: 0°/360° = Norte, 90° = Este, 180° = Sur,
%   270° = Oeste.
%
% dat:
%   Vector numérico con las magnitudes asociadas a cada dirección.
%
% -------------------------------------------------------------------------
% Argumentos opcionales Nombre-Valor
% -------------------------------------------------------------------------
% Name:
%   Nombre del archivo de salida. Si se guarda la figura y no se especifica
%   un nombre, se utiliza "rose" por defecto.
%
% ext:
%   Extensión o formato de salida para guardar la figura. Por ejemplo:
%   "png", "jpg", "tiff", "pdf", "eps" o "fig".
%
% dpi:
%   Resolución de exportación en puntos por pulgada. Se utiliza cuando el
%   formato de salida no es ".fig".
%
% titulo:
%   Título del gráfico.
%
% legenvar:
%   Nombre de la variable representada en la rosa direccional.
%
% legenbar:
%   Texto de la leyenda o barra de magnitudes.
%
% font:
%   Tamaño de fuente base del gráfico.
%
% textfont:
%   Tipo de letra utilizado en el gráfico. Por ejemplo:
%   "Helvetica", "Calibri", "Cambria".
%
% color:
%   Color del texto del gráfico.
%
% ndir:
%   Número de sectores direccionales en los que se divide el círculo de
%   360 grados.
%
% cmap:
%   Mapa de colores utilizado para representar las magnitudes. Por ejemplo:
%   "jet", "parula", "hot", "cool", "gray", "turbo", "summer".
%
% mag_bar:
%   Vector con los intervalos de magnitud usados para discretizar la escala
%   de colores. Por ejemplo: 0:1:4.
%
% legendtype:
%   Tipo de leyenda:
%       1: leyenda continua.
%       2: leyenda por cajas o intervalos.
%
% positionlegend:
%   Posición de la leyenda. Por ejemplo:
%   "bestoutside", "eastoutside", "southoutside", "northeast".
%
% gridstyle:
%   Estilo de línea del grid. Por ejemplo:
%   "-", "--", ":".
%
% gridalpha:
%   Transparencia del grid.
%
% maxq:
%   Frecuencia máxima a representar en la rosa direccional.
%
% griddiv:
%   Número de divisiones radiales de frecuencia.
%
% freqangle:
%   Ángulo donde se colocan las etiquetas de frecuencia.
%
% rad:
%   Radio del círculo interior del gráfico.
%
% W:
%   Ancho de la figura en centímetros.
%
% H:
%   Alto de la figura en centímetros.
%
% save_dir:
%   Carpeta donde se guardará la figura. Si se deja vacío, la figura no se
%   guarda.
%
% Labels:
%   Etiquetas direccionales mostradas alrededor de la rosa.
%
% LegendOrientation:
%   Orientación de la leyenda. Por ejemplo:
%   "vertical" u "horizontal".
%
% LegendFontSize:
%   Tamaño de fuente de la leyenda.
%
% TextFontOffset:
%   Ajuste aplicado al tamaño de fuente de los textos internos del gráfico.
%   Por defecto es -6, por lo que los textos internos quedan con
%   font + TextFontOffset.
%
% FigColor:
%   Color de fondo de la figura.
%
% -------------------------------------------------------------------------
% Salidas
% -------------------------------------------------------------------------
% f:
%   Handle de la figura.
%
% count:
%   Conteo o frecuencias calculadas por WindRose.
%
% speeds:
%   Intervalos de magnitud calculados por WindRose.
%
% directions:
%   Intervalos direccionales calculados por WindRose.
%
% Table:
%   Tabla de frecuencias generada por WindRose.
%
% ax:
%   Handle de los ejes principales de la figura.
%
% -------------------------------------------------------------------------
% Nota
% -------------------------------------------------------------------------
% Esta función requiere que la función WindRose esté disponible en el path
% de MATLAB:
%   WindRose by Daniel Pereira
%   MATLAB Central File Exchange:
%   https://www.mathworks.com/matlabcentral/fileexchange/47248-wind-rose
%

%% Manejo de entradas

arguments
    dir {mustBeNumeric}
    dat {mustBeNumeric}

    opts.Name string = ""
    opts.ext string = "png"
    opts.dpi double = 300

    opts.titulo string = ""
    opts.legenvar string = ""
    opts.legenbar string = ""

    opts.font double = 14
    opts.textfont string = "Helvetica"
    opts.color = "k"

    opts.ndir double = 16
    opts.cmap string = "jet"
    opts.mag_bar = []

    opts.legendtype double = 2
    opts.positionlegend string = "bestoutside"

    opts.gridstyle string = "--"
    opts.gridalpha double = 0.35

    opts.maxq double = []
    opts.griddiv double = 5
    opts.freqangle double = 340
    opts.rad double = 1/10

    opts.W double = 20
    opts.H double = 20

    opts.save_dir string = ""

    opts.Labels = {'N','NE','E','SE','S','SO','O','NO'}
    opts.LegendOrientation string = "vertical"
    opts.LegendFontSize double = 15
    opts.TextFontOffset double = -6
    opts.FigColor = "w"
end

%% Verificaciones iniciales

if exist("WindRose", "file") ~= 2
    error("La función WindRose no está disponible en el path de MATLAB. " + ...
           "Instálela desde MATLAB File Exchange: " + ...
           "https://www.mathworks.com/matlabcentral/fileexchange/47248-wind-rose");
end

if numel(dir) ~= numel(dat)
    error("IM_plot_rose:DimensionMismatch", ...
        "dir y dat deben tener la misma cantidad de elementos.");
end

%% Convertir coordenadas náuticas a cartesianas
dir = dir(:);
dat = dat(:);

dirc = zeros(size(dir));

idx_1 = dir <= 90;
idx_2 = dir > 90;

dirc(idx_1) = 90 - dir(idx_1);
dirc(idx_2) = 450 - dir(idx_2);

%% Configuración general
set(groot, "DefaultTextFontSize", opts.font);

cleanupObj = onCleanup(@() set(groot, "DefaultTextFontSize", "remove"));

%% Opciones para WindRose
Options = { ...
    'titlestring', char(opts.titulo), ...
    'ndirections', opts.ndir, ...
    'lablegend', char(opts.legenbar), ...
    'legendvariable', char(opts.legenvar), ...
    'cmap', char(opts.cmap), ...
    'labels', opts.Labels, ...
    'legendtype', opts.legendtype, ...
    'LegendPosition', char(opts.positionlegend), ...
    'LegendOrientation', char(opts.LegendOrientation), ...
    'legendfontsize', opts.LegendFontSize, ...
    'vwinds', opts.mag_bar, ...
    'gridstyle', char(opts.gridstyle), ...
    'gridalpha', opts.gridalpha, ...
    'textfontname', char(opts.textfont), ...
    'titlefontname', char(opts.textfont), ...
    'legendfontname', char(opts.textfont), ...
    'textcolor', opts.color, ...
    'freqlabelangle', opts.freqangle, ...
    'nfreq', opts.griddiv, ...
    'scalefactor', 1, ...
    'min_radius', opts.rad, ...
    'height', opts.H/0.026458333, ...
    'width', opts.W/0.026458333, ...
    'figcolor', opts.FigColor};

if ~isempty(opts.maxq)
    Options = [Options, {'maxfrequency', opts.maxq}];
end

%% Graficar rosa direccional
[f, count, speeds, directions, Table] = WindRose(dirc, dat, Options);

ax = f.CurrentAxes;
ax.FontSize = opts.font;

%% Ajustar tamaño de textos internos del gráfico
hText = findall(ax, "Type", "Text");

for i = 1:numel(hText)
    if isprop(hText(i), "String") && ~isempty(hText(i).String)
        hText(i).FontSize = opts.font + opts.TextFontOffset;
    end
end

%% Guardar figura
if opts.save_dir ~= ""
    if opts.Name == ""
        opts.Name = "rose";
    end

    ext_clean = erase(opts.ext, ".");
    file_out = fullfile(opts.save_dir, opts.Name + "." + ext_clean);

    if strcmpi(ext_clean, "fig")
        savefig(f, file_out);
    else
        print(f, file_out, "-d" + ext_clean, "-r" + num2str(opts.dpi));
    end
end

end