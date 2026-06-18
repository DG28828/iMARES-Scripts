function [f, ax, p] = IM_plot_2D(X, Y, opts)
%IM_plot_2D Grafica curvas 2D.
%
% Esta función genera gráficos 2D a partir de vectores, matrices o celdas.
% Las entradas obligatorias son los datos del eje x y del eje y; el resto 
% de configuraciones se definen mediante argumentos opcionales Nombre-Valor.
%
% Uso mínimo:
%   IM_plot_2D(datosX, datosY)
%
% Uso con opciones:
%   IM_plot_2D(datosX, datosY, ...
%       "XLabel", "x", ...
%       "YLabel", "y", ...
%       "Grid", "on")
%
% Uso para guardar figura:
%   IM_plot_2D(datosX, datosY, ...
%       "Name", "figura_2D", ...
%       "save_dir", "C:\Figuras", ...
%       "ext", "png", ...
%       "dpi", 300)
%
% -------------------------------------------------------------------------
% Argumentos de entrada requeridos
% -------------------------------------------------------------------------
% X:
%   Vector, matriz o celda con los datos del eje x.
%
%   Puede usarse como:
%       - Vector numérico común para todas las series de Y.
%       - Matriz numérica compatible con Y.
%       - Celda, donde cada entrada contiene el vector x de cada curva.
%
% Y:
%   Vector, matriz o celda con los datos del eje y.
%
%   Puede usarse como:
%       - Vector numérico para una curva.
%       - Matriz numérica donde cada columna corresponde a una curva.
%       - Celda, donde cada entrada contiene el vector y de cada curva.
%
% -------------------------------------------------------------------------
% Argumentos opcionales Nombre-Valor
% -------------------------------------------------------------------------
% Name:
%   Nombre del archivo de salida. Si se guarda la figura y no se especifica
%   un nombre, se utiliza "plot_2D" por defecto.
%
% Num:
%   Número de figura. Si se especifica, se usa figure(Num). Si se deja
%   vacío, MATLAB crea una nueva figura automáticamente.
%
% titulo:
%   Título del gráfico.
%
% ext:
%   Extensión o formato de salida para guardar la figura. Por ejemplo:
%   "png", "jpg", "tiff", "pdf", "eps" o "fig".
%
% save_dir:
%   Carpeta donde se guardará la figura. Si se deja vacío, la figura no se
%   guarda.
%
% dpi:
%   Resolución de exportación en puntos por pulgada. Se utiliza cuando el
%   formato de salida no es ".fig".
%
% XLabel:
%   Etiqueta del eje x.
%
% YLabel:
%   Etiqueta del eje y.
%
% Limx:
%   Control de límites del eje x:
%       0: límites automáticos de MATLAB.
%       1: límites ajustados a los datos mediante XLimitMethod = "tight".
%       2: límites definidos con el mínimo y máximo de XTick.
%
% Limy:
%   Control de límites del eje y:
%       0: límites automáticos de MATLAB.
%       1: límites ajustados a los datos mediante YLimitMethod = "tight".
%       2: límites definidos con el mínimo y máximo de YTick.
%
% XTick:
%   Vector con las marcas del eje x. Por ejemplo: 0:0.5:4.5.
%
% YTick:
%   Vector con las marcas del eje y. Por ejemplo: 0:0.1:1.
%
% Label_Leg:
%   Celda, string array o arreglo de etiquetas para la leyenda. Si se deja
%   vacío, no se muestra leyenda.
%
% N_c:
%   Número de columnas de la leyenda.
%
% Font:
%   Tipo de letra utilizado en los ejes y texto principal de la figura.
%   Por ejemplo: "Helvetica", "Calibri", "Cambria".
%
% Back_Col:
%   Color de fondo de la figura y de los ejes. Puede definirse como RGB,
%   hexadecimal o nombre de color.
%
% TFax:
%   Tamaño de fuente de los valores de los ejes, en puntos.
%
% TFLabel:
%   Tamaño de fuente de las etiquetas de los ejes y del título, en puntos.
%
% TWax:
%   Peso de fuente de los valores de los ejes. Por ejemplo:
%   "normal" o "bold".
%
% TWLabel:
%   Peso de fuente de las etiquetas de los ejes. Por ejemplo:
%   "normal" o "bold".
%
% Style_Line:
%   Celda con el estilo de cada curva. Cada entrada debe tener el formato:
%
%       "Color,LineStyle,LineWidth,Marker,MarkerSize,MarkerEdgeColor,MarkerFaceColor"
%
%   Ejemplo:
%       Style_Line = {
%           "#22646e,-,1.5,none,6,#22646e,#22646e"
%           "k,--,1.2,o,4,k,white"
%       };
%
%   El color puede ser keyword, abreviatura o hexadecimal. Para colores RGB,
%   se recomienda configurar manualmente el objeto de salida p.
%
% Grid:
%   Configuración de la grilla. Puede usarse de dos formas:
%       "on"  : activa grilla en ambos ejes con estilo por defecto.
%       "off" : desactiva la grilla.
%
%   También admite el formato antiguo:
%       "XGrid,YGrid,LineStyle,Alpha,Color"
%
%   Ejemplo:
%       "off,off,--,0.5,k"
%
% Text:
%   Celda para agregar texto dentro del gráfico. Cada elemento debe tener
%   la forma:
%       {X, Y, Valor, Color, FontSize}
%
% units:
%   Unidades de la figura y de los ejes. Opciones comunes:
%       "normalized"  : no se predimensiona la figura.
%       "centimeters" : permite definir tamaño físico de figura.
%
% visible:
%   Visibilidad de la figura:
%       "on"  : muestra la figura en pantalla.
%       "off" : genera la figura sin mostrarla.
%
% W:
%   Ancho de la figura cuando units = "centimeters".
%
% H:
%   Alto de la figura cuando units = "centimeters".
%
% Of_W:
%   Offset horizontal de los ejes respecto al borde izquierdo de la figura,
%   cuando units = "centimeters".
%
% Of_H:
%   Offset vertical de los ejes respecto al borde inferior de la figura,
%   cuando units = "centimeters".
%
% Color_Letras_Ejes:
%   Color de los valores y líneas de los ejes.
%
% Color_Letras_Leyenda:
%   Color del texto de la leyenda.
%
% Color_Letras_Titulo:
%   Color del título.
%
% FontW_Leyend:
%   Peso de fuente del texto de la leyenda. Por ejemplo:
%   "normal" o "bold".
%
% Location_Leyend:
%   Ubicación de la leyenda. Por ejemplo:
%   "northeast", "northwest", "southeast", "southwest", "best".
%
% Box_Leyend:
%   Control del recuadro de la leyenda:
%       "on"  : muestra recuadro.
%       "off" : oculta recuadro.
%
% XTickLabelRot:
%   Rotación de las etiquetas del eje x, en grados.
%
% -------------------------------------------------------------------------
% Salidas
% -------------------------------------------------------------------------
% f:
%   Handle de la figura.
%
% ax:
%   Handle de los ejes.
%
% p:
%   Handle de las curvas graficadas. Si datosY es celda, p será una celda
%   con los handles de cada curva.
%
% -------------------------------------------------------------------------
% Ejemplo de uso
% -------------------------------------------------------------------------
%   IM_plot_2D({x1, x_q}, {f1, y_q}, ...
%       "Name", "figura_2D", ...
%       "XLabel", "x", ...
%       "YLabel", "f(x)", ...
%       "Limx", 2, ...
%       "Limy", 2, ...
%       "XTick", 0:0.5:4.5, ...
%       "YTick", 0:0.1:1, ...
%       "Style_Line", Est_Lineas, ...
%       "Grid", "off,off,--,0.5,k", ...
%       "units", "centimeters", ...
%       "W", 14, ...
%       "H", 10);

%% Manejo de entradas

    arguments
        X
        Y

        opts.Name string = ""
        opts.Num = []
        opts.titulo string = ""
        opts.ext string = "png"
        opts.save_dir string = ""
        opts.dpi double = 300

        opts.XLabel string = ""
        opts.YLabel string = ""
        opts.Limx double = 0
        opts.Limy double = 0
        opts.XTick = []
        opts.YTick = []

        opts.Label_Leg = []
        opts.N_c double = 1

        opts.Font string = "Helvetica"
        opts.Back_Col = "white"

        opts.TFax double = 10
        opts.TFLabel double = 11
        opts.TWax string = "normal"
        opts.TWLabel string = "normal"

        opts.Style_Line = []
        opts.Grid string = ""
        opts.Text = []

        opts.units string = "normalized"
        opts.visible string = "on"

        opts.W double = 16
        opts.H double = 10
        opts.Of_W double = 1.5
        opts.Of_H double = 1.2

        opts.Color_Letras_Ejes = "black"
        opts.Color_Letras_Leyenda = "black"
        opts.Color_Letras_Titulo = "black"

        opts.FontW_Leyend string = "bold"
        opts.Location_Leyend string = "best"
        opts.Box_Leyend string = "off"

        opts.XTickLabelRot double = 0
    end

    %% Configuración general
    r = groot;
    r.FixedWidthFontName = opts.Font;

    %% Figura
    if isempty(opts.Num)
        f = figure;
    else
        f = figure(opts.Num);
    end

    f.Color = opts.Back_Col;
    f.Units = opts.units;
    f.Visible = opts.visible;

    %% Graficar curvas
    if ~iscell(Y)

        p = plot(X, Y);

        if isvector(Y)
            n_series = 1;
        else
            [~, n_series] = size(Y);
        end

        if ~isempty(opts.Style_Line)
            for i = 1:n_series
                st = strsplit(opts.Style_Line{i}, ",");

                p(i).Color = strtrim(st{1});
                p(i).LineStyle = strtrim(st{2});
                p(i).LineWidth = str2double(st{3});
                p(i).Marker = strtrim(st{4});
                p(i).MarkerSize = str2double(st{5});
                p(i).MarkerEdgeColor = strtrim(st{6});
                p(i).MarkerFaceColor = strtrim(st{7});
            end
        end

    else

        p = cell(size(Y));
        hold on

        for i = 1:numel(Y)
            if ~isempty(Y{i})
                p{i} = plot(X{i}, Y{i});

                if ~isempty(opts.Style_Line)
                    st = strsplit(opts.Style_Line{i}, ",");

                    p{i}.Color = strtrim(st{1});
                    p{i}.LineStyle = strtrim(st{2});
                    p{i}.LineWidth = str2double(st{3});
                    p{i}.Marker = strtrim(st{4});
                    p{i}.MarkerSize = str2double(st{5});
                    p{i}.MarkerEdgeColor = strtrim(st{6});
                    p{i}.MarkerFaceColor = strtrim(st{7});
                end
            end
        end

        hold off
    end

    %% Ejes
    ax = gca;
    ax.Color = opts.Back_Col;
    ax.FontName = opts.Font;
    ax.Units = opts.units;

    ax.XColor = opts.Color_Letras_Ejes;
    ax.YColor = opts.Color_Letras_Ejes;

    ax.XAxis.FontWeight = opts.TWax;
    ax.XAxis.FontSize = opts.TFax;
    ax.YAxis.FontWeight = opts.TWax;
    ax.YAxis.FontSize = opts.TFax;

    ax.XLabel.String = opts.XLabel;
    ax.XLabel.FontWeight = opts.TWLabel;
    ax.XLabel.FontSize = opts.TFLabel;

    ax.YLabel.String = opts.YLabel;
    ax.YLabel.FontWeight = opts.TWLabel;
    ax.YLabel.FontSize = opts.TFLabel;

    ax.XTickLabelRotation = opts.XTickLabelRot;

    %% Grid
    if opts.Grid ~= ""
        switch lower(opts.Grid)
            case "on"
                ax.XGrid = "on";
                ax.YGrid = "on";
                ax.GridLineStyle = "-";
                ax.GridAlpha = 0.15;

            case "off"
                ax.XGrid = "off";
                ax.YGrid = "off";

            otherwise
                % Compatibilidad con formato antiguo:
                % "on,on,--,0.15,black"
                Grd = strsplit(opts.Grid, ",");

                if numel(Grd) >= 1, ax.XGrid = strtrim(Grd{1}); end
                if numel(Grd) >= 2, ax.YGrid = strtrim(Grd{2}); end
                if numel(Grd) >= 3, ax.GridLineStyle = strtrim(Grd{3}); end
                if numel(Grd) >= 4, ax.GridAlpha = str2double(Grd{4}); end
                if numel(Grd) >= 5, ax.GridColor = strtrim(Grd{5}); end
        end
    end

    %% Límites y ticks del eje x
    if opts.Limx == 1
        ax.XLimitMethod = "tight";
    end

    if ~isempty(opts.XTick)
        ax.XTick = opts.XTick;

        if opts.Limx == 2
            ax.XLim = [min(opts.XTick) max(opts.XTick)];
        end
    end

    %% Límites y ticks del eje y
    if opts.Limy == 1
        ax.YLimitMethod = "tight";
    end

    if ~isempty(opts.YTick)
        ax.YTick = opts.YTick;

        if opts.Limy == 2
            ax.YLim = [min(opts.YTick) max(opts.YTick)];
        end
    end

    %% Leyenda
    if ~isempty(opts.Label_Leg)
        lgd = legend(opts.Label_Leg, ...
            "FontSize", opts.TFax, ...
            "TextColor", opts.Color_Letras_Leyenda, ...
            "FontWeight", opts.FontW_Leyend, ...
            "Location", opts.Location_Leyend, ...
            "NumColumns", opts.N_c);

        lgd.Box = opts.Box_Leyend;
    end

    %% Texto adicional
    if ~isempty(opts.Text)
        for j = 1:numel(opts.Text)
            text(opts.Text{j}{1}, opts.Text{j}{2}, opts.Text{j}{3}, ...
                "Color", opts.Text{j}{4}, ...
                "FontSize", opts.Text{j}{5});
        end
    end

    %% Redimensionar figura
    if strcmpi(opts.units, "centimeters")
        set(0, "units", "centimeters");
        Tm = get(0, "screensize");

        W_Center = 0.5 * (Tm(3) - opts.W);
        H_Center = 0.5 * (Tm(4) - opts.H);

        f.Position = [W_Center H_Center opts.W opts.H];

        ax.Position = [ ...
            opts.Of_W, ...
            opts.Of_H, ...
            opts.W - 1.5 * opts.Of_W, ...
            opts.H - 1.5 * opts.Of_H];
    end

    %% Título
    title(opts.titulo, ...
        "FontSize", opts.TFLabel, ...
        "Color", opts.Color_Letras_Titulo);

    %% Guardar figura
    if opts.save_dir ~= ""
        if opts.Name == ""
            opts.Name = "plot_2D";
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