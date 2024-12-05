function lab_01()
    clc;
    findMax = 0;
    debugFlg = 1;
    [base_color, red, green, yellow, blue, purple] = getColors();

    matr = [
        4 7 1 5 5;
        6 8 3 7 6;
        6 4 5 7 7;
        4 2 3 4 9;
        8 1 8 3 8
    ];

    fprintf('%sМатрица стоимостей для 9 варианта:%s\n', green, base_color);
    disp(matr);

    C = matr;

    if findMax == 1
        C = convertToMin(matr);

        if debugFlg == 1
            fprintf('%s\nМатрица после приведения к задаче минимизации:%s\n', blue, base_color);
            disp(C);
        end
    end

    C = updateColumns(C);
    if debugFlg == 1
        fprintf('%s\nРезультат вычитания наименьшего элемента по столбцам:%s\n', blue, base_color);
        disp(C);
    end

    C = updateRows(C);
    if debugFlg == 1 
        fprintf('%s\nРезультат вычитания наименьшего элемента по строкам:%s\n', blue, base_color);
        disp(C);
    end

    [numRows, numCols] = size(C);

    matrSIZ = getSIZInit(C);
    if debugFlg == 1 
        fprintf('%s\nНачальная СНН:%s\n', blue, base_color);
        printSIZ(C, matrSIZ);
    end

    k = sum(sum(matrSIZ));
    if debugFlg == 1
        fprintf('%s\nЧисло нулей в построенной СНН:%s k = %d\n', blue, base_color, k);
    end 

    iteration = 1;
    while k < numCols
        if debugFlg == 1 
            fprintf('%s\n______________________________ Итерация №%d ______________________________\n%s', green, iteration, base_color);
        end

        matrStreak = zeros(numRows, numCols); % матрица, в которой отмечаются позиции 0'
        selectedColumns = sum(matrSIZ);
        selectedRows = zeros(numRows);
        selection = getSelection(numRows, numCols, selectedColumns);
        
        if debugFlg == 1 
            fprintf('%s\nРезультат выделения столбцов, в которых стоит 0*:%s\n', blue, base_color);
            printMarkedMatr(C, matrSIZ, matrStreak, selectedColumns, selectedRows);
        end

        flag = true;
        streakPnt = [-1 -1];
        while flag 
            streakPnt = findStreak(C, selection);
            if streakPnt(1) == -1
                C = updateMatrNoZero(C, numRows, numCols, selection, selectedRows, selectedColumns);

                if debugFlg == 1 
                    fprintf('%s\nСреди невыделенных элементов нет 0, преобразуем матрицу:%s\n', blue, base_color);
                    printMarkedMatr(C, matrSIZ, matrStreak, selectedColumns, selectedRows);
                end

                streakPnt = findStreak(C, selection);
            end
        
            matrStreak(streakPnt(1), streakPnt(2)) = 1;
            if debugFlg == 1 
                fprintf("%s\nСреди невыделенных элементов есть 0, отметим 0':%s\n", blue, base_color);
                printMarkedMatr(C, matrSIZ, matrStreak, selectedColumns, selectedRows);
            end

            zeroStarInRow = getZeroStarInRow(streakPnt, numCols, matrSIZ);
            if zeroStarInRow(1) == -1
                flag = false;
            else
                % снять выделение со столбца с 0*
                selection(:, zeroStarInRow(2)) = selection(:, zeroStarInRow(2)) - 1;
                selectedColumns(zeroStarInRow(2)) = 0;

                % перенести выделение на строку с 0'
                selection(zeroStarInRow(1), :) = selection(zeroStarInRow(1), :) + 1; 
                selectedRows(zeroStarInRow(1)) = 1;
                if debugFlg == 1 
                    fprintf("%s\nВ одной строке с 0' есть 0*, перебросим выделение со столбца на строку:%s\n", blue, base_color);
                    printMarkedMatr(C, matrSIZ, matrStreak, selectedColumns, selectedRows);
                end
            end
        end

        [matrStreak, matrSIZ] = createL(numRows, numCols, streakPnt, matrStreak, matrSIZ, debugFlg);

        k = sum(sum(matrSIZ));
        if debugFlg == 1
            fprintf("%s\nВ пределах L-цепочки 0* заменем на 0, а 0' на 0*:\n%s", blue, base_color);
            printSIZ(C, matrSIZ); 
            fprintf('%s\nЧисло нулей в построенной СНН:%s k = %d\n', blue, base_color, k);
        end
        
        iteration = iteration + 1;
    end

    if debugFlg == 1
        fprintf('%s\nКонечная СНН:\n%s', blue, base_color);
        printSIZ(C, matrSIZ);
    end

    fprintf('%s\nX =\n%s', green, base_color);
    disp(matrSIZ);

    fOpt = getFOpt(matr, matrSIZ);
    fprintf('%s\nf opt = %s%d\n', green, base_color, fOpt);
end 

% Найти первый нулевой элемент среди невыделенных, в одной строке с которым не стоит 0*
function [streakPnt] = findStreak(matr, selection) 
    streakPnt = [-1 -1];
    [numRows, numCols] = size(matr);
    for i = 1 : numCols
        for j = 1 : numRows
           if selection(j, i) == 0 && matr(j, i) == 0 
                streakPnt(1) = j;
                streakPnt(2) = i;
                return;
           end
        end 
    end
end

function [] = printSIZ(matr, matrSIZ)
    [base_color, red, green, yellow, blue, purple] = getColors();
    [numRows, numCols] = size(matr);

    for i = 1 : numRows
        for j = 1 : numCols
            if matrSIZ(i, j) == 1
                fprintf("%s\t%d*\t%s", purple, matr(i, j), base_color);
            else
                fprintf("\t%d\t", matr(i, j));
            end
        end
        fprintf("\n");
    end
end

function [] = printMarkedMatr(matr, matrSIZ, matrStreak, selectedCols, selectedRows)
    [base_color, red, green, yellow, blue, purple] = getColors();
    [numRows, numCols] = size(matr);

    for i = 1 : numRows
        if selectedRows(i) == 1
            fprintf("%s+%s", green, base_color);
        end

        for j = 1 : numCols
            if matrSIZ(i, j) == 1 
                fprintf("%s\t%d*\t%s", purple, matr(i, j), base_color);
            elseif matrStreak(i, j) == 1
                fprintf("%s\t%d'\t%s", red, matr(i, j), base_color);
            else
                fprintf("\t%d\t", matr(i, j));
            end
        end
        fprintf('\n');
    end

    for i = 1 : numCols
        if selectedCols(i) == 1
            fprintf("%s\t+\t%s", green, base_color);
        else 
            fprintf(" \t\t");
        end 
    end
    fprintf('\n');
end

% Приведение задачи максимизации к задаче минимизации
function matr = convertToMin(matr)
    maxElem = max(max(matr));
    matr = matr * (-1) + maxElem;
end

% Нахождение наименьшего элемента в каждом столбце матрицы C 
% и вычитание его из соответствующего столбца
function matr = updateColumns(matr)
    minElemArr = min(matr);
    for i = 1 : length(minElemArr)
        matr(:, i) = matr(:, i) - minElemArr(i);
    end
end

% Нахождение наименьшего элемента в каждой строке матрицы C 
% и вычитание его из соответствующей строки
function matr = updateRows(matr)
    minElemArr = min(matr, [], 2);
    for i = 1 : length(minElemArr)
        matr(i, :) = matr(i, :) - minElemArr(i);
    end
end

% Начальное состояние СНН (системы независимых нулей)
function matrSIZ = getSIZInit(matr)
    [numRows, numCols] = size(matr);
    matrSIZ = zeros(numRows, numCols);

    for i = 1 : numCols
        for j = 1 : numRows
            if matr(j, i) == 0
                count = 0;
                for k = 1 : numCols
                   count = count + matrSIZ(j, k);
                end
                for k = 1 : numRows
                   count = count + matrSIZ(k, i);
                end
                if count == 0 
                    matrSIZ(j, i) = 1;
                end 
            end
        end 
    end
end

% Выделение столбцов, в которых стоит 0*
function [selection] = getSelection(numRows, numCols, selectedColumns)
    selection = zeros(numRows, numCols);
    for j = 1 : numCols
        if selectedColumns(j) == 1 
            selection(:, j) = selection(:, j) + 1;
        end 
    end
end

% Изменить матрицу в случае, если среди невыделенных элементов нет нуля
function [matr] = updateMatrNoZero(matr, numRows, numCols, selection, selectedRows, selectedColumns)
    h = 1e5; % Наименьший элемент среди невыделенных
    for i = 1 : numCols
        for j = 1 : numRows
            if selection(j, i) == 0 && matr(j, i) < h
                h = matr(j, i);
            end
        end 
    end

    for i = 1 : numCols
        if selectedColumns(i) == 0
            matr(:, i) = matr(:, i) - h;
        end 
    end
    for i = 1 : numRows
        if selectedRows(i) == 1
            matr(i, :) = matr(i, :) + h;
        end 
    end
end

% Найти 0* в той же строке, что и 0'
function [zeroStarInRow] = getZeroStarInRow(streakPnt, numCols, matrSIZ)
    j = streakPnt(1);
    zeroStarInRow = [-1 -1];
    for i = 1 : numCols
       if matrSIZ(j, i) == 1
           zeroStarInRow(1) = j;
           zeroStarInRow(2) = i;
           break
       end 
    end
end

% Построить L-цепочку
function [matrStreak, matrSIZ] = createL(numRows, numCols, streakPnt, matrStreak, matrSIZ, debugFlg)
    [base_color, red, green, yellow, blue, purple] = getColors();

    if debugFlg == 1 
        fprintf('%s\nПостроенная L-цепочка: %s', blue, base_color);
    end

    i = streakPnt(1);
    j = streakPnt(2);
    while i > 0 && j > 0 && i <= numRows && j <= numCols
        % Снять *
        matrStreak(i, j) = 0;
        % Заменить ' на *
        matrSIZ(i, j) = 1;
        
        if debugFlg == 1 
            fprintf("[%d, %d] ", i, j);
        end

        % Дойти до 0* по столбцу от 0'
        kRow = 1;
        while kRow <= numRows && (matrSIZ(kRow, j) ~= 1 || kRow == i)
            kRow = kRow + 1;
        end

        if (kRow <= numRows)  
            % Дойти до 0' по строке от 0*
            lCol = 1;
            while lCol <= numCols && (matrStreak(kRow, lCol) ~= 1 || lCol == j)
                lCol = lCol + 1;
            end

            if lCol <= numCols
                matrSIZ(kRow,j) = 0;

                if debugFlg == 1 
                    fprintf("-> [%d, %d] -> ", kRow, j);
                end
            end
            j = lCol;
        end
        i = kRow;
    end

    if debugFlg == 1
        fprintf('\n');
    end
end

function [fOpt] = getFOpt(matr, matrSIZ)
    fOpt = 0;
    [numRows, numCols] = size(matr);

    for i = 1 : numCols
        for j = 1 : numRows
            if matrSIZ(j, i) == 1 
                fOpt = fOpt + matr(j, i);
            end
        end
    end
end

function [base_color, red, green, yellow, blue, purple] = getColors()
    base_color = "\x1B[0m";
    red        = "\x1B[31m";
    green      = "\x1B[32m";
    yellow     = "\x1B[33m";
    blue       = "\x1B[34m";
    purple     = "\x1B[35m";
end
