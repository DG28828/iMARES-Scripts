function IM_check_folders(folders, opts)
%IM_check_folders Verifica y crea carpetas si no existen.
%
% Esta función recibe una o varias rutas de carpetas y comprueba si existen.
% Si alguna carpeta no existe, la crea automáticamente mediante mkdir.
%
% Uso:
%   IM_check_folders(folder)
%
%   IM_check_folders({folder1, folder2, folder3})
%
%   IM_check_folders(folders, "disp_flag", true)
%
% Entradas:
%   folders:
%       Ruta o conjunto de rutas a verificar. Puede ser:
%           - char
%           - string
%           - cell array de chars
%           - string array
%
% Argumentos opcionales:
%   "disp_flag":
%       true  : muestra mensajes en consola.
%       false : no muestra mensajes.
%
% Ejemplos:
%   IM_check_folders(save_dir_fig)
%
%   IM_check_folders({save_dir_dat, save_dir_fig, save_dir_CAROL})
%
%   IM_check_folders({save_dir_dat, save_dir_fig, save_dir_CAROL}, ...
%                    "disp_flag", true)

arguments
    folders
    opts.disp_flag (1,1) logical = false
end

%% Normalizar entrada

if ischar(folders) || isstring(folders)
    folders = string(folders);
elseif iscell(folders)
    folders = string(folders);
else
    error('folders debe ser char, string, cell array de chars o string array.');
end

folders = folders(:);

%% Verificar y crear carpetas

for i = 1:numel(folders)

    folder_i = strtrim(folders(i));

    if folder_i == ""
        warning('Se omitió una ruta vacía en folders.');
        continue
    end

    if ~isfolder(folder_i)

        [status, msg, msgID] = mkdir(folder_i);

        if ~status
            error(msgID, 'No se pudo crear la carpeta: %s\n%s', folder_i, msg);
        end

        if opts.disp_flag
            fprintf('Carpeta creada: %s\n', folder_i);
        end

    else
        if opts.disp_flag
            fprintf('Carpeta existente: %s\n', folder_i);
        end
    end
end

end