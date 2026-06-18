function [h, stats] = IM_plot_scatter(X, Y, options)
%IM_scatter Gráfico de dispersión para validación entre datos observados y modelados.
%
%   h = IM_scatter(X, Y) genera un gráfico de dispersión comparando los
%   datos de referencia u observados X contra los datos modelados,
%   estimados o simulados Y. Además, se agrega una línea de referencia 1:1
%   y se muestran estadísticos de validación dentro de la gráfica.
%
%   [h, stats] = IM_scatter(X, Y) también devuelve una estructura con los
%   estadísticos de validación calculados mediante IM_validation_coefficients.
%
%   [h, stats] = IM_scatter(X, Y, Name=Value) permite especificar opciones
%   adicionales mediante argumentos Nombre-Valor.
%
%   ENTRADAS
%   --------
%   X : arreglo numérico
%       Datos de referencia u observados.
%
%   Y : arreglo numérico
%       Datos modelados, estimados o simulados. Deben tener el mismo número
%       de elementos que X.
%
%   ARGUMENTOS NOMBRE-VALOR
%   -----------------------
%   Marker : char o string
%       Tipo de marcador utilizado en el gráfico de dispersión.
%       Valor por defecto: "."
%
%   MarkerSize : escalar numérico positivo
%       Tamaño del marcador.
%       Valor por defecto: 9
%
%   Limits : vector numérico [min max]
%       Límites de los ejes X e Y. Si se deja vacío, los límites se calculan
%       automáticamente a partir de los datos válidos.
%       Valor por defecto: []
%
%   TextPosition : vector numérico [x y]
%       Posición del texto con los estadísticos dentro de la gráfica, en
%       unidades de los datos. Si se deja vacío, la posición se calcula
%       automáticamente a partir de los límites de los ejes.
%       Valor por defecto: []
%
%   TextSize : escalar numérico positivo
%       Tamaño de letra del texto con los estadísticos.
%       Valor por defecto: 10
%
%   Color : especificación de color de MATLAB
%       Color del marcador y del texto con los estadísticos. Puede ser un
%       triplete RGB, nombre de color, abreviatura de color o código
%       hexadecimal.
%       Valor por defecto: [0 0.4470 0.7410]
%
%   Units : char o string
%       Unidades mostradas junto a RMSE y BIAS.
%       Valor por defecto: ""
%
%   ShowStats : lógico
%       Si es true, muestra los estadísticos de validación en la gráfica.
%       Valor por defecto: true
%
%   Parent : objeto axes
%       Eje donde se genera la gráfica. Si se deja vacío, se usa el eje
%       actual.
%       Valor por defecto: []
%
%   SALIDAS
%   -------
%   h : objeto gráfico
%       Handle del gráfico de dispersión.
%
%   stats : struct
%       Estructura con los estadísticos de validación calculados.
%
%   EJEMPLO
%   -------
%   x = rand(100,1);
%   y = x + 0.1*randn(100,1);
%
%   [h, stats] = IM_scatter(x, y, ...
%       Marker = ".", ...
%       MarkerSize = 10, ...
%       Units = "m", ...
%       Color = "#0072BD");
%
%   EJEMPLO CON LÍMITES
%   -------------------
%   IM_scatter(x, y, ...
%       Limits = [0 2], ...
%       TextPosition = [0.1 1.8], ...
%       Units = "m");
%
%   See also IM_validation_coefficients, plot, text, axis.

arguments
    X {mustBeNumeric}
    Y {mustBeNumeric}

    options.Marker = "."
    options.MarkerSize (1,1) double {mustBePositive} = 9
    options.Limits double = []
    options.TextPosition double = []
    options.TextSize (1,1) double {mustBePositive} = 10
    options.Color = [0 0.4470 0.7410]
    options.Units = ""
    options.ShowStats (1,1) logical = true
    options.Parent = []
end

% -------------------------------------------------------------------------
% Validar tamaño de los datos de entrada
% -------------------------------------------------------------------------
if numel(X) ~= numel(Y)
    error("IM_scatter:SizeMismatch", ...
        "X e Y deben tener el mismo número de elementos.");
end

% Convertir los datos a vectores columna
X = X(:);
Y = Y(:);

% Eliminar pares de datos no válidos
validData = isfinite(X) & isfinite(Y);
Xv = X(validData);
Yv = Y(validData);

if isempty(Xv)
    error("IM_scatter:NoValidData", ...
        "No existen pares de datos válidos y finitos para graficar.");
end

% -------------------------------------------------------------------------
% Definir el eje donde se graficará
% -------------------------------------------------------------------------
if isempty(options.Parent)
    ax = gca;
else
    ax = options.Parent;
end

wasHold = ishold(ax);
hold(ax, "on")

% -------------------------------------------------------------------------
% Definir límites de los ejes
% -------------------------------------------------------------------------
if isempty(options.Limits)
    dataMin = min([Xv; Yv]);
    dataMax = max([Xv; Yv]);

    if dataMin == dataMax
        delta = max(abs(dataMin)*0.05, 1);
        lim1 = dataMin - delta;
        lim2 = dataMax + delta;
    else
        margin = 0.05 * (dataMax - dataMin);
        lim1 = dataMin - margin;
        lim2 = dataMax + margin;
    end
else
    if numel(options.Limits) ~= 2 || options.Limits(1) >= options.Limits(2)
        error("IM_scatter:InvalidLimits", ...
            "Limits debe ser un vector numérico con la forma [min max].");
    end

    lim1 = options.Limits(1);
    lim2 = options.Limits(2);
end

% -------------------------------------------------------------------------
% Graficar datos observados contra modelados
% -------------------------------------------------------------------------
h = plot(ax, Xv, Yv, ...
    options.Marker, ...
    "MarkerSize", options.MarkerSize, ...
    "Color", options.Color, ...
    "LineStyle", "none");

% Agregar línea de referencia 1:1
plot(ax, [lim1 lim2], [lim1 lim2], "-k");

% Aplicar límites y relación de aspecto 1:1
axis(ax, [lim1 lim2 lim1 lim2]);
daspect(ax, [1 1 1]);

% -------------------------------------------------------------------------
% Calcular y mostrar estadísticos de validación
% -------------------------------------------------------------------------
stats = IM_validation_coefficients(Xv, Yv);

if options.ShowStats
    RMSE = stats.RMSE;
    BIAS = stats.BIAS;
    CORR = stats.CORR;

    % Usar SI_centered si está disponible; de lo contrario, usar SI
    if isfield(stats, "SI_centered")
        SI = stats.SI_centered;
    else
        SI = stats.SI;
    end

    unitsText = string(options.Units);

    if strlength(unitsText) > 0
        unitsText = " " + unitsText;
    end

    rmseText = "RMSE = " + num2str(RMSE, "%.2f") + unitsText;
    biasText = "BIAS = " + num2str(BIAS, "%.2f") + unitsText;
    corrText = "CORR = " + num2str(CORR, "%.2f");
    siText   = "SI = "   + num2str(SI, "%.2f");

    % Definir ubicación del texto
    if isempty(options.TextPosition)
        dx = lim2 - lim1;
        textX = lim1 + 0.05 * dx;
        textY = lim2 - 0.10 * dx;
    else
        if numel(options.TextPosition) ~= 2
            error("TextPosition debe ser un vector numérico con la forma [x y].");
        end

        textX = options.TextPosition(1);
        textY = options.TextPosition(2);
    end

    text(ax, textX, textY, ...
        {rmseText, corrText; biasText, siText}, ...
        "FontSize", options.TextSize, ...
        "Color", options.Color);
end

% -------------------------------------------------------------------------
% Formato final de los ejes
% -------------------------------------------------------------------------
ax.XTick = ax.YTick;
ax.XTickLabelRotation = 0;
box(ax, "on");

% Restaurar el estado original de hold
if ~wasHold
    hold(ax, "off")
end

end