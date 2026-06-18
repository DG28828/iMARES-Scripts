function IM_export_CAROL(datos_procesados, nodo, variables_CAROL, seasons, save_dir_CAROL, nombre)
%IM_export_CAROL Exporta archivos .dat para el programa CAROL.
%
% Esta función exporta archivos de entrada para CAROL a partir del struct
% datos_procesados. Permite exportar la serie completa y/o subconjuntos
% estacionales definidos previamente, como temporada alta y temporada baja.
%
% Uso:
%   IM_export_CAROL(datos_procesados, nodo, variables_CAROL, seasons, save_dir_CAROL, nombre)
%
% Entradas:
%   datos_procesados:
%       Struct generado por IM_split_months_seasons. Debe contener:
%
%           datos_procesados.fechas.vect
%           datos_procesados.fechas.fechas_high
%           datos_procesados.fechas.fechas_low
%           datos_procesados.params(nodo).Variable.all
%           datos_procesados.params(nodo).Variable.high
%           datos_procesados.params(nodo).Variable.low
%
%   nodo:
%       Índice del nodo/punto que se desea exportar.
%
%   variables_CAROL:
%       String array con las variables que se exportarán a CAROL.
%       Ejemplos:
%
%           variables_CAROL = ["Hs", "Tp", "DD"];
%           variables_CAROL = ["W", "Dw"];
%
%   seasons:
%       String array con las temporadas o subconjuntos a exportar.
%       Opciones:
%
%           "all"  : serie completa.
%           "high" : temporada alta.
%           "low"  : temporada baja.
%
%   save_dir_CAROL:
%       Carpeta donde se guardarán los archivos .dat.
%
%   nombre:
%       Texto adicional para identificar los archivos de salida.
%
% Salida:
%   La función no devuelve variables. Exporta archivos .dat en save_dir_CAROL.
%
% Nota:
%   Si una temporada no tiene datos disponibles, la exportación se omite.

arguments
    datos_procesados struct
    nodo (1,1) double {mustBeInteger, mustBePositive}
    variables_CAROL (1,:) string
    seasons (1,:) string
    save_dir_CAROL string
    nombre string = ""
end

%% Verificaciones iniciales

if ~isfolder(save_dir_CAROL)
    mkdir(save_dir_CAROL)
end

seasons_validas = ["all", "high", "low"];

if any(~ismember(seasons, seasons_validas))
    error('Las temporadas en "seasons" deben ser: "all", "high" o "low".');
end

if nodo > numel(datos_procesados.params)
    error('"nodo" excede la cantidad de nodos disponibles en datos_procesados.params.');
end

%% Exportación por temporada

for s = 1:numel(seasons)

    season = seasons(s);

    switch season
        case "all"
            fechas_CAROL = datos_procesados.fechas.vect;

        case "high"
            if ~isfield(datos_procesados.fechas, "fechas_high")
                fprintf('Se omite exportación CAROL para high: no existe datos_procesados.fechas.fechas_high.\n');
                continue
            end

            fechas_CAROL = datos_procesados.fechas.fechas_high;

        case "low"
            if ~isfield(datos_procesados.fechas, "fechas_low")
                fprintf('Se omite exportación CAROL para low: no existe datos_procesados.fechas.fechas_low.\n');
                continue
            end

            fechas_CAROL = datos_procesados.fechas.fechas_low;
    end

    % Omitir exportación si no hay fechas para esta temporada
    if isempty(fechas_CAROL)
        fprintf('Se omite exportación CAROL para %s: sin datos disponibles.\n', char(season));
        continue
    end

    % Inicializar matriz con fecha + dos columnas vacías
    CAROL_data = [fechas_CAROL, zeros(size(fechas_CAROL, 1), 2)];

    % Agregar variables solicitadas
    for v = 1:numel(variables_CAROL)

        var_name = variables_CAROL(v);

        if ~isfield(datos_procesados.params(nodo), var_name)
            error('No existe la variable datos_procesados.params(%d).%s.', nodo, var_name);
        end

        if ~isfield(datos_procesados.params(nodo).(var_name), season)
            fprintf('Se omite variable %s para %s: no existe el campo correspondiente.\n', ...
                char(var_name), char(season));
            continue
        end

        var_data = datos_procesados.params(nodo).(var_name).(season);

        if isempty(var_data)
            fprintf('Se omite exportación CAROL para %s: la variable %s está vacía.\n', ...
                char(season), char(var_name));
            continue
        end

        CAROL_data = [CAROL_data, var_data]; %#ok<AGROW>
    end

    % Exportar matriz a .dat
    writematrix(CAROL_data, ...
        fullfile(save_dir_CAROL, ['CAROL_input_', char(season), char(nombre), '.dat']), ...
        'FileType', 'text', ...
        'Delimiter', ' ');

    fprintf('Archivo CAROL exportado: %s\n', ...
        fullfile(save_dir_CAROL, ['CAROL_input_', char(season), char(nombre), '.dat']));

end

end