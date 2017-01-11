# language: ru

Функциональность: Выполнение команды продукта

Как разработчик
Я хочу иметь возможность выполнять команды продукта
Чтобы выполнять коллективную разработку проекта 1С

Контекст:
    Допустим Я очищаю параметры команды "oscript" в контексте 

Сценарий: Получение версии продукта
    Когда Я выполняю команду "oscript" c параметрами "tools/runner.os version"
    Тогда Я сообщаю вывод команды "oscript"
    И Вывод команды "oscript" содержит "."
    И Код возврата команды "oscript" равен 0

Структура сценария: <Имя сценария>
    Когда Я выполняю команду "oscript" c параметрами <ПараметрыКомандыПомощь>
    Тогда Вывод команды "oscript" содержит "Vanessa-runner v"
    И Код возврата команды "oscript" равен 0

Примеры:
  | Имя сценария                            | ПараметрыКомандыПомощь       |
  | Получение помощи продукта               | tools/runner.os --help |
  | Получение помощи продукта по умолчанию  | tools/runner.os |
