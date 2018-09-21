#Использовать fs
#Использовать 1commands
#Использовать tempfiles
#Использовать json

Перем Лог;
Перем ПарсерJSON;

Перем РабочаяОбласть;
Перем СписокПапокСПроектами;
Перем СписокИменПроектов;
Перем ВерсияEDT;

Перем КаталогОтчетов;
Перем ПутьКФайламПроекта;

Перем ИмяФайлаРезультата;
Перем УдалятьФайлРезультата;
Перем ИмяПредыдущегоФайлаРезультата;
Перем ИсключенияВОшибках;
Перем ПропускиВОшибках;

Перем кэш;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Проверка проекта EDT");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--allure-results",
	"Путь к каталогу результатов Allure");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--exception-file",
	"Путь файла с указанием пропускаемых ошибок. Необязательный аргумент.
	|	Формат файла: в каждой строке файла указан текст пропускаемого исключения или его часть
	|	Кодировка: UTF-8");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--validation-result",
	"Путь к файлу, в который будут записаны результаты проверки проекта. Необязательный аргумент.");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--prev-validation-result",
	"Путь к файлу с предыдущими результатами проверки проекта. Необязательный аргумент.
	|	Если заполнен, то результат будет записан как разность новых ошибок и старых.
	|	Ошибки и предупреждения, которые есть в предыдущем файле, но которых нет в новом - будут помечены как passed (Исправлено).
	|	Ошибки и предупреждения, которые есть только в новом файле результатов - будут помечены как failed (Ошибки) и broken (Предупреждения).
	|	Все остальные ошибки и предупреждения, которые есть в обоих файлах, будут помечены как skipped (Пропущено).");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--project-url",
	"Путь к файлам проекта. Необязательный аргумент.
	|	Если заполнен, то в отчетах аллюр будут ссылки на конкретные строки с ошибками.
	|	Пример: --project-url https://github.com/1C-Company/GitConverter/tree/master/GitConverter/src ");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--EDTversion",
	"Используемая версия EDT. Необязательный аргумент.
	|	Необходима, если зарегистрировано одновременно несколько версий.
	|	Узнать доступные версии можно командой ""ring help""
	|	Пример: --EDTversion 1.9.1");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--workspace-location", 
	"Расположение рабочей области. Необязательный аргумент.
	|	Если не указан, то проверка выполнятся не будет. Актуально для создания отчетов по существующему файлу результатов.");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--project-list", 
	"Список папок, откуда загрузить проекты в формате EDT для проверки. Необязательный аргумент.
	|	Одновременно можно использовать только один агрумент: project-list или project-name-list");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--project-name-list",
	"Список имен проектов в текущей рабочей области, откуда загрузить проекты в формате EDT для проверки. Необязательный аргумент.
	|	Одновременно можно использовать только один агрумент: project-list или project-name-list.
	|
	|	Примеры выполнения:
	|		vanessa-runner edt-validate --project-list D:/project-1 D:/project-2 --workspace-location D:/workspace
	|		runner edt-validate --allure-results ""D:/allure-results/"" ^
	|			--workspace-location ""D:/workspace"" ^
	|			--project-list ""D:/GIT_Repo/GitConverter/"" ^
	|			--exception-file ""D:/WORKDIR%excp.txt"" ^
	|			--validation-result ""D:/validation-result.txt"" ^
	|			--prev-validation-result ""D:/validation-result.txt"" ^
	|			--project-url https://github.com/1C-Company/GitConverter/tree/master/GitConverter/src
	|
	|	ВНИМАНИЕ! Параметры, которые перечислены далее, не используются.
	|
	|");
	
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
	
КонецПроцедуры

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры - Соответствие -  (необязательно) дополнительные параметры
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт
	
	Лог = ДополнительныеПараметры.Лог;
	
	ИнициализацияПараметров( ПараметрыКоманды );
	
	Если ЗначениеЗаполнено( ИмяПредыдущегоФайлаРезультата ) Тогда
		
		тзРезультатПред = ПрочитатьТаблицуИзФайлаРезультата( ИмяПредыдущегоФайлаРезультата );
		
	КонецЕсли;
	
	Успешно = ВыполнитьПроверкуEDT();
	
	тзРезультат = ПрочитатьТаблицуИзФайлаРезультата( ИмяФайлаРезультата );
	
	УдалитьФайлРезультатовПриНеобходимости();
	
	Если ЗначениеЗаполнено( ИмяПредыдущегоФайлаРезультата ) Тогда
		
		тзРезультат = РазностнаяТаблицаРезультатов( тзРезультатПред, тзРезультат );
		
	КонецЕсли;
	
	СоздатьФайлыПоТаблицеПроверки(тзРезультат);
	
	РезультатыКоманд = МенеджерКомандПриложения.РезультатыКоманд();
	
	Возврат ?(Успешно, РезультатыКоманд.Успех, РезультатыКоманд.ОшибкаВремениВыполнения);
	
КонецФункции

// { приватная часть 

Процедура ИнициализацияПараметров( Знач ПараметрыКоманды )
	
	Лог.Отладка("Чтение параметров");
	
	КаталогОтчетов = ПараметрыКоманды["--allure-results"];
	
	Если КаталогОтчетов = Неопределено Тогда
		
		КаталогОтчетов = "";
		Лог.Отладка("	Каталог отчетов (--allure-results) не задан.");
		
	Иначе
		
		Лог.Отладка("	Каталог отчетов (--allure-results): %1", КаталогОтчетов);
		
	КонецЕсли;
	
	ВерсияEDT = ПараметрыКоманды["--EDTversion"];
	РабочаяОбласть = ПараметрыКоманды["--workspace-location"];
	СписокПапокСПроектами = ПараметрыКоманды["--project-list"];
	СписокИменПроектов = ПараметрыКоманды["--project-name-list"];
	ПутьКФайламПроекта = ПараметрыКоманды["--project-url"];
	
	Лог.Отладка("	Версия EDT (--EDTversion): %1", Строка( ВерсияEDT ) );
	Лог.Отладка("	Рабочая область (--workspace-location): %1", Строка( РабочаяОбласть ) );
	Лог.Отладка("	Список папок с проектами (--project-list): %1", Строка( СписокПапокСПроектами ) );
	Лог.Отладка("	Список имен проектов (--project-name-list): %1", Строка( СписокИменПроектов ) );
	Лог.Отладка("	Путь к файлам проекта (--project-url): %1", Строка( ПутьКФайламПроекта ) );
	
	ИмяФайлаРезультата = ПараметрыКоманды["--validation-result"];
	УдалятьФайлРезультата = Ложь;
	
	Если ИмяФайлаРезультата = Неопределено Тогда
		
		ИмяФайлаРезультата = ПолучитьИмяВременногоФайла("out");
		УдалятьФайлРезультата = Истина;
		Лог.Отладка("	Файл результата не задан (--validation-result). Будет использован временный файл.");
		
	КонецЕсли;
	
	Лог.Отладка("	Файл результата (--validation-result): %1", ИмяФайлаРезультата);
	
	ИмяПредыдущегоФайлаРезультата = ПараметрыКоманды["--prev-validation-result"];
	
	Лог.Отладка("	Файл предыдущего результата (--prev-validation-result): %1", Строка( ИмяПредыдущегоФайлаРезультата ));
	
	ИсключенияВОшибках = ИсключаемыеОшибки();
	ПропускиВОшибках = СодержимоеФайлаПропускаемыхОшибок( ПараметрыКоманды["--exception-file"] );
	
	ПарсерJSON  = Новый ПарсерJSON();
	
КонецПроцедуры

Функция ВыполнитьПроверкуEDT()
	
	Если Не ЗначениеЗаполнено( РабочаяОбласть ) Тогда
		
		Лог.Информация( "Рабочая область (--workspace-location) не указана. Проверка проекта пропущена." );
		
		Возврат Истина;
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено( СписокПапокСПроектами ) 
		И Не ЗначениеЗаполнено( СписокИменПроектов ) Тогда
		
		Лог.Информация( "Проекты к проверке (--project-list или project-name-list) не указаны. Проверка проекта пропущена." );
		
		Возврат Истина;
		
	КонецЕсли;
	
	Попытка
		
		// Для EDT критично, чтобы файла не существовало
		ОбщиеМетоды.УдалитьФайлЕслиОнСуществует( ИмяФайлаРезультата );
		
		Команда = Новый Команда;
		
		Если ЗначениеЗаполнено( ВерсияEDT ) Тогда
			
			строкаЗапуска = СтрШаблон( "ring edt@%1 workspace validate", ВерсияEDT );
			
		Иначе
			
			строкаЗапуска = "ring edt workspace validate";
			
		КонецЕсли;
		
		Команда.УстановитьСтрокуЗапуска( строкаЗапуска );
		Команда.УстановитьКодировкуВывода( КодировкаТекста.ANSI );
		Команда.ДобавитьПараметр( "--workspace-location " + ОбщиеМетоды.ОбернутьПутьВКавычки( РабочаяОбласть ) );
		Команда.ДобавитьПараметр( "--file " + ОбщиеМетоды.ОбернутьПутьВКавычки( ИмяФайлаРезультата ) );
		
		Если ЗначениеЗаполнено( СписокПапокСПроектами ) Тогда
			Команда.ДобавитьПараметр("--project-list " + ОбщиеМетоды.ОбернутьПутьВКавычки( СписокПапокСПроектами ) );
		КонецЕсли;
		
		Если ЗначениеЗаполнено( СписокИменПроектов ) Тогда
			Команда.ДобавитьПараметр("--project-name-list " + ОбщиеМетоды.ОбернутьПутьВКавычки( СписокИменПроектов ) );
		КонецЕсли;
		
		Лог.Информация( "Начало проверки EDT-проекта" );
		началоЗамера = ТекущаяДата();
		
		КодВозврата = Команда.Исполнить();
		
		Лог.Информация( "Проверка EDT-проекта завершена за %1с", Окр( ТекущаяДата() -  началоЗамера ) );
		
	Исключение
		
		УдалитьФайлРезультатовПриНеобходимости();
		ВызватьИсключение ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
	КонецПопытки;
	
	Возврат КодВозврата = 0;
	
КонецФункции

Процедура УдалитьФайлРезультатовПриНеобходимости()
	
	Если УдалятьФайлРезультата Тогда
		
		ОбщиеМетоды.УдалитьФайлЕслиОнСуществует(ИмяФайлаРезультата);
		
	КонецЕсли;
	
КонецПроцедуры

Функция СодержимоеФайлаПропускаемыхОшибок( Знач ИмяФайлаПропускаемыхОшибок )
	
	Результат = Новый Массив;
	
	Если Не ЗначениеЗаполнено( ИмяФайлаПропускаемыхОшибок ) Тогда
		Лог.Информация( "Файл пропускаемых ошибок (--exception-file) не указан. Пропуски не используются." );
		Возврат Результат;
	КонецЕсли;
	
	Файл = Новый Файл( ИмяФайлаПропускаемыхОшибок );
	Если Не Файл.Существует() Тогда
		
		// Отсутствие этого файла не критично, поэтому обойдемся без исключений
		
		Лог.Предупреждение( "Файл пропускаемых ошибок (--exception-file) %1 не найден.", ИмяФайлаПропускаемыхОшибок );
		
		Возврат Результат;
		
	КонецЕсли;
	
	Лог.Отладка( "Чтение файла пропускаемых ошибок из %1", ИмяФайлаПропускаемыхОшибок );
	
	ЧтениеТекста = Новый ЧтениеТекста( ИмяФайлаПропускаемыхОшибок, КодировкаТекста.UTF8 );
	ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
	Пока ПрочитаннаяСтрока <> Неопределено Цикл
		Если Не ПустаяСтрока(ПрочитаннаяСтрока) Тогда
			пропуск = СокрЛП(НРег(ПрочитаннаяСтрока));
			Результат.Добавить(пропуск);
			Лог.Отладка("Добавлено в пропуски: %1", пропуск);
		КонецЕсли;
		ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
	КонецЦикла;
	
	ЧтениеТекста.Закрыть();
	
	Лог.Отладка("Прочитано пропусков: %1", Результат.Количество());	
	
	Возврат Результат;
	
КонецФункции

Функция ИсключаемыеОшибки()
	
	// Определяем строки для исключения из ошибок 
	// См. стандарт "Обработчики событий модуля формы, подключаемые из кода"
	// https://its.1c.ru/db/v8std#content:-2145783155:hdoc
	МассивСтрокИсключений = Новый Массив();
	МассивСтрокИсключений.Добавить(Нрег("Неиспользуемый метод ""Подключаемый_"));
	МассивСтрокИсключений.Добавить(Нрег("Пустой обработчик: ""Подключаемый_"));
	
	Возврат МассивСтрокИсключений;
	
КонецФункции


// Создание таблицы результата
Функция ПрочитатьТаблицуИзФайлаРезультата( Знач пПутьКФайлу )
	
	Лог.Отладка( "Чтение файла результата %1", пПутьКФайлу );
	
	тз = Новый ТаблицаЗначений;
	тз.Колонки.Добавить( "ДатаОбнаружения" );
	тз.Колонки.Добавить( "Тип" );
	тз.Колонки.Добавить( "Проект" );
	тз.Колонки.Добавить( "Метаданные" );
	тз.Колонки.Добавить( "Положение" );
	тз.Колонки.Добавить( "Описание" );
	
	Файл = Новый Файл( пПутьКФайлу );
	Если Не Файл.Существует() Тогда
		
		// Файла может не быть если
		// 1) Это первый запуск получение разностной таблицы
		// 2) Нет ошибок (EDT просто не создает файл результата)
		// 3) EDT вернул ошибку
		// 4) Проверка EDT не запускалась, выполняется только построение отчета Аллюр
		// По пунктам 1-3 стоит вернуть пустую таблицу, 
		// по 4 не все так однозначно, но если и вызывать исключение, то при инициализации параметров
		
		Лог.Информация( "Файл отчета об ошибках %1 не найден.", пПутьКФайлу );
		
		Возврат тз;
		
	КонецЕсли;
	
	
	ЧтениеТекста = Новый ЧтениеТекста( пПутьКФайлу, КодировкаТекста.UTF8 );
	
	ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
	
	Пока Не ПрочитаннаяСтрока = Неопределено Цикл
		
		Если ПустаяСтрока( ПрочитаннаяСтрока ) Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Если СтрокаВходитВМассив( ПрочитаннаяСтрока, ИсключенияВОшибках ) Тогда
			ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;
		
		компонентыСтроки = СтрРазделить( ПрочитаннаяСтрока, "	" );
		
		новСтрока = тз.Добавить();
		
		Для ц = 0 По 4 Цикл
			
			новСтрока[ц] = компонентыСтроки[ц];
			
		КонецЦикла;
		
		// В описании могут быть и табы, по которым делим
		
		Для ц = 5 По компонентыСтроки.ВГраница() Цикл
			
			Если ЗначениеЗаполнено( новСтрока.Описание ) Тогда
				
				новСтрока.Описание = новСтрока.Описание + "	";
				
			Иначе
				
				новСтрока.Описание = "";
				
			КонецЕсли;
			
			новСтрока.Описание = новСтрока.Описание + компонентыСтроки[ц];
			
		КонецЦикла;
		
		Если СтрокаВходитВМассив( ПрочитаннаяСтрока, ПропускиВОшибках ) Тогда
			
			новСтрока.Тип = ТипОшибки_Пропущено();
			
		КонецЕсли;
		
		ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
		
	КонецЦикла;
	
	ЧтениеТекста.Закрыть();
	
	Лог.Отладка("Из файла %1 прочитано %2 строк", пПутьКФайлу, тз.Количество());
	
	Возврат тз;
	
КонецФункции

//Проверяет вхождение строк из массива в проверямой строке.
//Параметры:
//	ПроверяемаяСтрока - Строка - строка для проверки.
//	МассивСтрокИсключений - Массив - массив строк, для проверки. 
//
//Возвращаемое значение:
//	Булево - Истина, в проверяемой строке содежрится один из элементов массив.
//			 Ложь, не нашли
Функция СтрокаВходитВМассив( Знач ПроверяемаяСтрока, Знач МассивСтрокИсключений )
	
	Для Каждого СтрИсключения Из МассивСтрокИсключений Цикл
		
		Если СтрНайти(Нрег(ПроверяемаяСтрока), СтрИсключения) > 0 Тогда
			
			Возврат Истина;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

Функция РазностнаяТаблицаРезультатов( Знач пТЗ_пред, Знач пТЗ_нов )
	
	тз_стар = пТЗ_пред.Скопировать();
	тз_стар.Колонки.Добавить("Изменение");
	тз_стар.ЗаполнитьЗначения(1, "Изменение" );
	
	тз = пТЗ_нов.Скопировать();
	тз.Колонки.Добавить("Изменение");
	тз.ЗаполнитьЗначения( - 1, "Изменение" );
	
	Для Каждого цСтрока Из тз_стар Цикл
		
		ЗаполнитьЗначенияСвойств( тз.Добавить(), цСтрока );
		
	КонецЦикла;
	
	тз.Свернуть( "Тип,Проект,Метаданные,Положение,Описание" , "Изменение" );
	
	Для Каждого цСтрока Из тз Цикл
		
		Если цСтрока.Изменение = 0 Тогда
			
			// есть и в старой и в новой таблице
			цСтрока.Тип = ТипОшибки_Пропущено();
			
		ИначеЕсли цСтрока.Изменение > 0 Тогда
			
			// есть только в старой
			цСтрока.Тип = ТипОшибки_Исправлено();
			
		Иначе
			
			// Внесли новую ошибку
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат тз;
	
КонецФункции

Функция ТипОшибки_Пропущено()
	Возврат "Пропущено";
КонецФункции

Функция ТипОшибки_Исправлено()
	Возврат "Исправлено";
КонецФункции

// Создание файлов для отчета Allure

Процедура СоздатьФайлыПоТаблицеПроверки(Знач пТаблицаПроверки)
	
	Если Не ЗначениеЗаполнено( КаталогОтчетов ) Тогда
		
		Лог.Отладка("Каталог отчетов (--allure-results) не указан. Создание отчета Allure пропущено.");
		
		Возврат;
		
	КонецЕсли;
	
	началоЗамера = ТекущаяДата();
	
	Лог.Отладка("Создание файлов в каталоге %1.", КаталогОтчетов);
	Лог.Отладка("	Очистка каталога %1.", КаталогОтчетов);
	
	УдалитьФайлы( КаталогОтчетов, "*.json" );
	
	Лог.Отладка("	Создание файлов json по таблице проверки в каталоге %1.", КаталогОтчетов);
	
	количествоСозданныхФайлов = 0;
	
	Для Каждого цСтрока Из пТаблицаПроверки Цикл
		
		СтруктураВыгрузки           = ПолучитьОписаниеСценарияАллюр2();
		СтруктураВыгрузки.name      = цСтрока.Метаданные + ". " + цСтрока.Положение + ": " + цСтрока.Описание;
		СтруктураВыгрузки.fullName  = СтруктураВыгрузки.name;
		СтруктураВыгрузки.historyId = цСтрока.Метаданные + ". " + цСтрока.Положение + ": " + цСтрока.Описание;
		СтруктураВыгрузки.Вставить( "description", цСтрока.Описание );
		
		Если цСтрока.Тип = "Ошибка" Тогда
			
			СтруктураВыгрузки.status = "failed";
			
		ИначеЕсли цСтрока.Тип = "Предупреждение" Тогда
			
			СтруктураВыгрузки.status = "broken";
			
		ИначеЕсли цСтрока.Тип = "Пропущено" Тогда
			
			СтруктураВыгрузки.status = "skipped";
			
		ИначеЕсли цСтрока.Тип = "Исправлено" Тогда
			
			СтруктураВыгрузки.status = "passed";
			
		КонецЕсли;
		
		структ = Новый Структура( "name,value", "package", цСтрока.Метаданные );
		СтруктураВыгрузки.labels.Добавить( структ );
		
		Для Каждого цКонтекст Из ПолучитьКонтексты( цСтрока.Описание ) Цикл
			
			структ = Новый Структура( "name,value", "tag", цКонтекст );
			СтруктураВыгрузки.labels.Добавить( структ );
			
		КонецЦикла;
		
		структ = Новый Структура( "name,value", "story", ОписаниеФункциональности( цСтрока.Описание ) );
		СтруктураВыгрузки.labels.Добавить( структ );
		
		ссылкаНаСтроку = ПолучитьСсылкуНаСтроку( цСтрока.Метаданные, цСтрока.Положение );
		
		Если ЗначениеЗаполнено( ссылкаНаСтроку ) Тогда
			
			ОписаниеСсылки = Новый Структура("name,url,type");
			ОписаниеСсылки.name = "Перейти на строку с ошибкой";
			ОписаниеСсылки.url = ссылкаНаСтроку;
			ОписаниеСсылки.type = "";
			
			СтруктураВыгрузки.links.Добавить( ОписаниеСсылки );
			
		КонецЕсли;
		
		РеальноеИмяФайла = ОбъединитьПути( КаталогОтчетов, "" + СтруктураВыгрузки.uuid + "-result.json" );
		
		ЗаписатьФайлJSON( РеальноеИмяФайла, СтруктураВыгрузки);
		
		количествоСозданныхФайлов = количествоСозданныхФайлов + 1;
		
	КонецЦикла;
	
	лог.Отладка( "	Созданы файлы отчетов (%1) в каталоге %2 за %3с", количествоСозданныхФайлов, КаталогОтчетов, Окр( ТекущаяДата() - началоЗамера ));
	
	СоздатьФайлКатегорий();
	
КонецПроцедуры

Процедура СоздатьФайлКатегорий()
	
	имяФайлаКатегорий = ОбъединитьПути( КаталогОтчетов, "categories.json" );
	
	Лог.Отладка("	Создание файла категорий %1.", имяФайлаКатегорий);
	
	категории = Новый Массив;
	
	категории.Добавить( ОписаниеКатегории( "Ошибка", "failed" ) );
	категории.Добавить( ОписаниеКатегории( "Предупреждение", "broken" ) );
	категории.Добавить( ОписаниеКатегории( "Пропущено", "skipped" ) );
	категории.Добавить( ОписаниеКатегории( "Исправлено", "passed" ) );
	
	ЗаписатьФайлJSON( имяФайлаКатегорий, категории);
	
КонецПроцедуры

Функция ОписаниеКатегории( Знач пНаименование, Знач пСтатус )
	
	массивСтатусов = Новый Массив;
	массивСтатусов.Добавить( пСтатус );
	Возврат Новый Структура( "name,matchedStatuses", пНаименование, массивСтатусов );
	
КонецФункции

Функция ПолучитьКонтексты( Знач пОписание )
	
	начало = СтрНайти( пОписание, "[" );
	конец  = СтрНайти( пОписание, "]", НаправлениеПоиска.СКонца );
	
	Если начало < конец
		И конец > 0 Тогда
		
		стрКонтексты = Сред( пОписание, начало + 1, конец - начало - 1 );
		
		Возврат СтрРазделить( стрКонтексты, "," );
		
	Иначе
		
		Возврат Новый Массив;
		
	КонецЕсли;
	
КонецФункции

Функция ОписаниеФункциональности( Знач пОписание )
	
	начало = СтрНайти( пОписание, "[" );
	
	Если начало > 0 Тогда
		
		описаниеБезКонтекста = Лев( пОписание, начало - 1 );
		
	Иначе
		
		описаниеБезКонтекста = пОписание;
		
	КонецЕсли;
	
	ПозицияКавычки = СтрНайти( описаниеБезКонтекста, """" );
	
	Пока ПозицияКавычки > 0 Цикл
		
		ПозицияЗакрывающейКавычки = СтрНайти( Сред( описаниеБезКонтекста, ПозицияКавычки + 1 ), """" ) + ПозицияКавычки;
		
		Если ПозицияЗакрывающейКавычки = 0 Тогда
			
			Прервать;
			
		КонецЕсли;
		
		описаниеБезКонтекста = Лев( описаниеБезКонтекста, ПозицияКавычки - 1 ) + "<>" + Сред( описаниеБезКонтекста, ПозицияЗакрывающейКавычки + 1 );
		ПозицияКавычки       = СтрНайти( описаниеБезКонтекста, """" );
		
	КонецЦикла;
	
	ПозицияКавычки = СтрНайти( описаниеБезКонтекста, "'" );
	
	Пока ПозицияКавычки > 0 Цикл
		
		ПозицияЗакрывающейКавычки = СтрНайти( Сред( описаниеБезКонтекста, ПозицияКавычки + 1 ), "'" ) + ПозицияКавычки;
		
		Если ПозицияЗакрывающейКавычки = 0 Тогда
			
			Прервать;
			
		КонецЕсли;
		
		описаниеБезКонтекста = Лев( описаниеБезКонтекста, ПозицияКавычки - 1 ) + "<>" + Сред( описаниеБезКонтекста, ПозицияЗакрывающейКавычки + 1 );
		ПозицияКавычки       = СтрНайти( описаниеБезКонтекста, "'" );
		
	КонецЦикла;
	
	начало = СтрНайти( пОписание, ":", НаправлениеПоиска.СКонца );
	
	Если начало > 0 Тогда
		
		описаниеБезКонтекста = СокрЛП( Лев( описаниеБезКонтекста, начало - 1 ) );
		
	КонецЕсли;
	
	Возврат СокрЛП( описаниеБезКонтекста );
	
КонецФункции

Функция ПолучитьОписаниеСценарияАллюр2()
	
	СтруктураРезультата = Новый Структура();
	СтруктураРезультата.Вставить( "uuid", Строка( Новый УникальныйИдентификатор() ) );
	СтруктураРезультата.Вставить( "historyId", Неопределено );
	СтруктураРезультата.Вставить( "name", Неопределено );
	СтруктураРезультата.Вставить( "fullName", Неопределено );
	СтруктураРезультата.Вставить( "start", Неопределено );
	СтруктураРезультата.Вставить( "stop", Неопределено );
	СтруктураРезультата.Вставить( "statusDetails", Новый Структура( "known, muted,flaky", Ложь, Ложь, Ложь ) );
	СтруктураРезультата.Вставить( "status", Неопределено );
	СтруктураРезультата.Вставить( "stage", "finished" );
	СтруктураРезультата.Вставить( "steps", Новый Массив );
	СтруктураРезультата.Вставить( "parameters", Новый Массив );
	СтруктураРезультата.Вставить( "labels", Новый Массив );
	СтруктураРезультата.Вставить( "links", Новый Массив );
	СтруктураРезультата.Вставить( "attachments", Новый Массив );
	СтруктураРезультата.Вставить( "description", Неопределено );
	
	Возврат СтруктураРезультата;
	
КонецФункции

Функция ПолучитьСсылкуНаСтроку( Знач пМетаданные, Знач пСтрока )
	
	Если Не ЗначениеЗаполнено( ПутьКФайламПроекта ) Тогда
		
		Возврат "";
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено( пСтрока ) Тогда
		
		Возврат "";
		
	КонецЕсли;
	
	компоненты = СтрРазделить( пМетаданные, "." );
	
	Если компоненты.Количество() = 0 Тогда
		
		Возврат "";
		
	КонецЕсли;
	
	компонентыСсылки = Новый Массив;
	компонентыСсылки.Добавить( ПутьКФайламПроекта );
	
	// Тип метаданных
	
	Если кэш = Неопределено Тогда
		
		кэш = Новый Структура;
		
		кэш.Вставить( "Метаданные", СоответствиеМетаданнымКаталогам() );
		кэш.Вставить( "Модули", СоответствиеМодулейФайлам() );
		
	КонецЕсли;
	
	имяМетаданных = ВРег( компоненты[0] );
	
	каталог = кэш.Метаданные[ имяМетаданных ];
	
	Если Не ЗначениеЗаполнено( каталог ) Тогда
		
		Возврат "";
		
	КонецЕсли;
	
	Если компоненты.Количество() < 3 Тогда
		
		Возврат "";
		
	КонецЕсли;
	
	компонентыСсылки.Добавить( каталог );
	
	// Имя объекта	
	
	компонентыСсылки.Добавить( компоненты[1] );
	
	типОбъекта = ВРег( компоненты[2] );
	
	имяФайла = кэш.Модули[типОбъекта];
	
	Если ЗначениеЗаполнено( имяФайла ) Тогда
		
		компонентыСсылки.Добавить( имяФайла );
		
	ИначеЕсли типОбъекта = "ФОРМА" Тогда
		
		компонентыСсылки.Добавить( "Forms" );
		
		Если компоненты.Количество() > 3 Тогда
			
			компонентыСсылки.Добавить( компоненты[3] );
			
		КонецЕсли;
		
		Если компоненты.Количество() > 5 Тогда
			
			Если ВРег( компоненты[4] ) = "ФОРМА"
				И ВРег( компоненты[5] ) = "МОДУЛЬ" Тогда
				
				компонентыСсылки.Добавить( "Module.bsl" );
				
			КонецЕсли;
			
		КонецЕсли;
		
	ИначеЕсли типОбъекта = "КОМАНДА" Тогда
		
		компонентыСсылки.Добавить( "Commands" );
		
		Если компоненты.Количество() > 3 Тогда
			
			компонентыСсылки.Добавить( компоненты[3] );
			
		КонецЕсли;
		
		Если компоненты.Количество() > 4 Тогда
			
			Если ВРег( компоненты[4] ) = "МОДУЛЬКОМАНДЫ" Тогда
				
				компонентыСсылки.Добавить( "CommandModule.bsl" );
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат СтрСоединить( компонентыСсылки, "/" ) + "#L" + СтрЗаменить( ВРег( пСтрока ), "СТРОКА ", "" );
	
КонецФункции

Функция СоответствиеМетаданнымКаталогам()
	
	Соответствие = Новый Соответствие();
	
	Соответствие.Вставить( "РегистрБухгалтерии", "AccountingRegisters" );
	Соответствие.Вставить( "РегистрНакопления", "AccumulationRegisters" );
	Соответствие.Вставить( "БизнесПроцесс", "BusinessProcesses" );
	Соответствие.Вставить( "РегистрРасчета", "CalculationRegisters" );
	Соответствие.Вставить( "Справочник", "Catalogs" );
	Соответствие.Вставить( "ПланСчетов", "ChartsOfAccounts" );
	Соответствие.Вставить( "ПланВидовРасчета", "ChartsOfCalculationTypes" );
	Соответствие.Вставить( "ПланВидовХарактеристик", "ChartsOfCharacteristicTypes" );
	Соответствие.Вставить( "ОбщаяГруппа", "CommandGroups" );
	Соответствие.Вставить( "ОбщийРеквизит", "CommonAttributes" );
	Соответствие.Вставить( "ОбщаяКоманда", "CommonCommands" );
	Соответствие.Вставить( "ОбщаяФорма", "CommonForms" );
	Соответствие.Вставить( "ОбщийМодуль", "CommonModules" );
	Соответствие.Вставить( "ОбщаяКартинка", "CommonPictures" );
	Соответствие.Вставить( "ОбщийМакет", "CommonTemplates" );
	Соответствие.Вставить( "Константа", "Constants" );
	Соответствие.Вставить( "Обработка", "DataProcessors" );
	Соответствие.Вставить( "ОпределяемыйТип", "DefinedTypes" );
	Соответствие.Вставить( "ЖурналДокумента", "DocumentJournals" );
	Соответствие.Вставить( "Нумератор", "DocumentNumerators" );
	Соответствие.Вставить( "Документ", "Documents" );
	Соответствие.Вставить( "Перечисление", "Enums" );
	Соответствие.Вставить( "ПодпискаНаСобытие", "EventSubscriptions" );
	Соответствие.Вставить( "ПланОбмена", "ExchangePlans" );
	Соответствие.Вставить( "ВнешнийИсточник", "ExternalDataSources" );
	Соответствие.Вставить( "КритерийОтбора", "FilterCriteria" );
	Соответствие.Вставить( "ФункциональнаяОпция", "FunctionalOptions" );
	Соответствие.Вставить( "ПарамертФункциональыхОпций", "FunctionalOptionsParameters" );
	Соответствие.Вставить( "HTTPСервис", "HTTPServices" );
	Соответствие.Вставить( "РегистрСведений", "InformationRegisters" );
	Соответствие.Вставить( "Язык", "Languages" );
	Соответствие.Вставить( "Отчет", "Reports" );
	Соответствие.Вставить( "Роль", "Roles" );
	Соответствие.Вставить( "РегламентноеЗадание", "ScheduledJobs" );
	Соответствие.Вставить( "Последовательность", "Sequences" );
	Соответствие.Вставить( "ПарамертСеанса", "SessionParameters" );
	Соответствие.Вставить( "ХранилищеНастроек", "SettingsStorages" );
	Соответствие.Вставить( "ЭлементСтиля", "StyleItems" );
	Соответствие.Вставить( "Подсистема", "Subsystems" );
	Соответствие.Вставить( "Задача", "Tasks" );
	Соответствие.Вставить( "WebСервис", "WebServices" );
	Соответствие.Вставить( "XDTOПакет", "XDTOPackages" );
	
	соотВРег = Новый Соответствие;
	
	Для Каждого цЭлемент Из Соответствие Цикл
		
		соотВРег.Вставить( ВРег( цЭлемент.Ключ ), цЭлемент.Значение );
		
	КонецЦикла;
	
	Возврат соотВРег;
	
КонецФункции

Функция СоответствиеМодулейФайлам()
	
	Соответствие = Новый Соответствие();
	
	Соответствие.Вставить( "МОДУЛЬОБЪЕКТА", "ObjectModule.bsl" );
	Соответствие.Вставить( "МОДУЛЬ", "Module.bsl" );
	Соответствие.Вставить( "МОДУЛЬМЕНЕДЖЕРА", "ManagerModule.bsl" );
	Соответствие.Вставить( "МОДУЛЬНАБОРАЗАПИСЕЙ", "RecordSetModule.bsl" );
	
	Возврат Соответствие;
	
КонецФункции

Процедура ЗаписатьФайлJSON(Знач ИмяФайла, Знач пЗначение)
	
	Запись = Новый ЗаписьТекста;
	Запись.Открыть(ИмяФайла);
	Запись.Записать(ПарсерJSON.ЗаписатьJSON(пЗначение));
	Запись.Закрыть();
	
КонецПроцедуры

