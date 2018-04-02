#Использовать logos

Перем Лог;

Функция ПрочитатьНастройки(Знач ПутьКНастройкам) Экспорт
	Рез = Неопределено;

	Лог = Логирование.ПолучитьЛог(ПараметрыСистемы.ИмяЛогаСистемы());

	Если Не ПустаяСтрока(ПутьКНастройкам) Тогда
		Лог.Отладка("Читаю настройки из файла %1", ПутьКНастройкам);

		ФайлНастроек = Новый Файл(ОбщиеМетоды.ПолныйПуть(ПутьКНастройкам));
		СообщениеОшибки = СтрШаблон("Ожидали, что файл настроек %1 существует, а его нет.");
		Ожидаем.Что(ФайлНастроек.Существует(), СообщениеОшибки).ЭтоИстина();

		ЧтениеТекста = Новый ЧтениеТекста(ФайлНастроек.ПолноеИмя, КодировкаТекста.UTF8);
		
		СтрокаJSON = ЧтениеТекста.Прочитать();
		ЧтениеТекста.Закрыть();

		ПарсерJSON = Новый ПарсерJSON();
		Рез = ПарсерJSON.ПрочитатьJSON(СтрокаJSON);
		
		Лог.Отладка("Успешно прочитали настройки");
		Лог.Отладка("Настройки из файла:");
		Для каждого КлючЗначение Из Рез Цикл
			Лог.Отладка("	%1 = %2", КлючЗначение.Ключ, КлючЗначение.Значение);
		КонецЦикла;
	Иначе
		Лог.Отладка("Файл настроек не передан. Использую значение по умолчанию.");
	КонецЕсли;
	Возврат Рез;
КонецФункции

Функция ПолучитьНастройку(Знач Настройки, Знач ИмяНастройки, Знач ЗначениеПоУмолчанию, 
		Знач РабочийКаталогПроекта, Знач ОписаниеНастройки, Знач ПолучатьПолныйПуть = Истина) Экспорт

	Рез = ЗначениеПоУмолчанию;
	Если Настройки <> Неопределено Тогда
		Рез_Врем = Настройки.Получить(ИмяНастройки);
		Если Рез_Врем <> Неопределено Тогда
			Лог.Отладка("	Ключ %1, Значение %2", ИмяНастройки, Рез_Врем);

			Рез = Заменить_workspaceRoot_на_РабочийКаталогПроекта(Рез_Врем, РабочийКаталогПроекта);

			Лог.Отладка("В настройках нашли %1 %2", ОписаниеНастройки, Рез);
		КонецЕсли;
	КонецЕсли;
	Лог.Отладка("Использую %1 %2", ОписаниеНастройки, Рез);
	
	Если ПолучатьПолныйПуть Тогда
		Рез = ОбщиеМетоды.ПолныйПуть(Рез);
		Лог.Отладка("Использую %1 (полный путь) %2", ОписаниеНастройки, Рез);
	КонецЕсли;
	Возврат Рез;
КонецФункции

Функция Заменить_workspaceRoot_на_РабочийКаталогПроекта(Знач ИсходнаяСтрока, Знач РабочийКаталогПроекта)
	Возврат СтрЗаменить(ИсходнаяСтрока, "$workspaceRoot", РабочийКаталогПроекта);
КонецФункции
