///////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором служебных параметров приложения
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////

Перем КорневойПутьПроекта Экспорт;
Перем ЭтоWindows Экспорт;

Перем мВозможныеКоманды;

//	Возвращает идентификатор лога приложения
//
// Возвращаемое значение:
//   Строка   - Значение идентификатора лога приложения
//
Функция ИмяЛогаСистемы() Экспорт

	Возврат "oscript.app." + ИмяПродукта();

КонецФункции // ИмяЛогаСистемы

//	Возвращает текущую версию продукта
//
// Возвращаемое значение:
//   Строка   - Значение текущей версии продукта
//
Функция ВерсияПродукта() Экспорт

	Версия = "0.9.2";// присвоение "Версия = " важно для проверки Сонара
	Возврат Версия;

КонецФункции // ВерсияПродукта()

// Возвращает имя продукта
//
//  Возвращаемое значение:
//   Строка - имя продукта
//
Функция ИмяПродукта() Экспорт
	Возврат "vanessa-runner";
КонецФункции

Функция ВозможныеКоманды() Экспорт
	
	Если мВозможныеКоманды = Неопределено Тогда
		мВозможныеКоманды = Новый Структура;
		мВозможныеКоманды.Вставить("ИнициализацияОкружения", "init-dev");
		мВозможныеКоманды.Вставить("ОбновлениеОкружения", "update-dev");
		
		мВозможныеКоманды.Вставить("СборкаРасширений", "compileext");
		мВозможныеКоманды.Вставить("РазборкаРасширений", "decompileext");
		мВозможныеКоманды.Вставить("РазборкаВнешнихОбработок", "decompileepf");
		
		мВозможныеКоманды.Вставить("Тестирование_xUnitFor1C", "xunit");
		мВозможныеКоманды.Вставить("ТестироватьПоведение", "vanessa");
		
		мВозможныеКоманды.Вставить("ЗапуститьВРежимеПредприятия", "run");
		мВозможныеКоманды.Вставить("ОбновитьКонфигурациюБазыДанных", "updatedb");
		мВозможныеКоманды.Вставить("ВыгрузитьКонфигурациюВФайл", "unload");
		мВозможныеКоманды.Вставить("ПроверкаСинтаксиса", "syntax-check");

		мВозможныеКоманды.Вставить("ОбновитьИзХранилища", "loadrepo");
		
		мВозможныеКоманды.Вставить("Помощь", "help");
		мВозможныеКоманды.Вставить("ПомощьУстаревшая", "--help");
		мВозможныеКоманды.Вставить("ПоказатьВерсию", "version");
		мВозможныеКоманды = Новый ФиксированнаяСтруктура(мВозможныеКоманды);
	КонецЕсли;
	
	Возврат мВозможныеКоманды;
	
КонецФункции

Процедура ПриРегистрацииКомандПриложения(Знач КлассыРеализацииКоманд) Экспорт

	КлассыРеализацииКоманд[ВозможныеКоманды().Помощь]					= "КомандаСправкаПоПараметрам";
	КлассыРеализацииКоманд[ВозможныеКоманды().ПомощьУстаревшая]			= "КомандаСправкаПоПараметрам";
	КлассыРеализацииКоманд[ИмяКомандыВерсия()]							= "КомандаVersion";
	КлассыРеализацииКоманд[ВозможныеКоманды().ИнициализацияОкружения]	= "КомандаИнициализацияОкружения";
	КлассыРеализацииКоманд[ВозможныеКоманды().ОбновлениеОкружения]		= "КомандаОбновлениеОкружения";
	
	КлассыРеализацииКоманд[ВозможныеКоманды().СборкаРасширений]			= "КомандаСборкаРасширений";
	КлассыРеализацииКоманд[ВозможныеКоманды().РазборкаРасширений]			= "КомандаРазборкаРасширений";
	КлассыРеализацииКоманд[ВозможныеКоманды().РазборкаВнешнихОбработок]	= "КомандаРазборкаВнешнихОбработок";
	
	КлассыРеализацииКоманд[ВозможныеКоманды().Тестирование_xUnitFor1C]	= "КомандаТестирование_xUnitFor1C";
	КлассыРеализацииКоманд[ВозможныеКоманды().ТестироватьПоведение]		= "КомандаТестированиеПоведения";
	
	КлассыРеализацииКоманд[ВозможныеКоманды().ЗапуститьВРежимеПредприятия]	= "КомандаЗапуститьВРежимеПредприятия";
	КлассыРеализацииКоманд[ВозможныеКоманды().ОбновитьКонфигурациюБазыДанных]	= "КомандаОбновлениеКонфигурацииБД";
	КлассыРеализацииКоманд[ВозможныеКоманды().ВыгрузитьКонфигурациюВФайл]	= "КомандаВыгрузитьКонфигурациюВФайл";
	КлассыРеализацииКоманд[ВозможныеКоманды().ПроверкаСинтаксиса]	= "КомандаПроверкаСинтаксиса";
	
	КлассыРеализацииКоманд[ВозможныеКоманды().ОбновитьИзХранилища]	= "КомандаОбновитьИзХранилища";
    //...
    //КлассыРеализацииКоманд["<имя команды>"]	= "<КлассРеализации>";

КонецПроцедуры // ПриРегистрацииКомандПриложения

// Одна из команд может вызываться неявно, без указания команды.
// Иными словами, здесь указывается какой обработчик надо вызывать, если приложение запущено без какой-либо команды
//  myapp /home/user/somefile.txt будет аналогично myapp default-action /home/user/somefile.txt 
Функция ИмяКомандыПоУмолчанию() Экспорт
	Возврат ""; // Возврат "default-action";
КонецФункции

// Возвращает имя команды версия (ключ командной строки)
//
//  Возвращаемое значение:
//   Строка - имя команды
//
Функция ИмяКомандыВерсия() Экспорт
	Возврат ВозможныеКоманды().ПоказатьВерсию;
КонецФункции
