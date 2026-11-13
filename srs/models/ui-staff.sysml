// Упрощённый ч/б макет панели мастера и администратора СТО.
// Требования: REQ-FUNC-025..REQ-FUNC-030.
package UiStaff {
    private import UiLibrary::*;

    part staffScreen : Screen {
        attribute :>> width = 400;
        attribute :>> height = 560;
        attribute :>> caption = "AutoService - 4. Панель персонала";

        part masterCard : Card {
            attribute :>> posX = 20; attribute :>> posY = 50; attribute :>> width = 360; attribute :>> height = 224;
            attribute :>> caption = "Режим МАСТЕРА СТО (Бокс №2)";

            part orderTitle : Heading { attribute :>> posX = 12; attribute :>> posY = 30; attribute :>> width = 336; attribute :>> height = 22; attribute :>> caption = "Заказ #1042: BMW X5 (7788 AB-7)"; }
            part orderServices : Label { attribute :>> posX = 12; attribute :>> posY = 54; attribute :>> width = 336; attribute :>> height = 20; attribute :>> caption = "Услуги: Ремонт ТО, Мойка, Антикор"; }

            part st1 : Button { attribute :>> posX = 12; attribute :>> posY = 82; attribute :>> width = 162; attribute :>> height = 34; attribute :>> caption = "Принят в бокс"; }
            part st2 : Button { attribute :>> posX = 186; attribute :>> posY = 82; attribute :>> width = 162; attribute :>> height = 34; attribute :>> caption = "На диагностике"; }
            part st3 : PrimaryButton { attribute :>> posX = 12; attribute :>> posY = 124; attribute :>> width = 162; attribute :>> height = 34; attribute :>> caption = "[*] В РАБОТЕ"; }
            part st4 : Button { attribute :>> posX = 186; attribute :>> posY = 124; attribute :>> width = 162; attribute :>> height = 34; attribute :>> caption = "Готов к выдаче (Push)"; }

            part addWorkBtn : Button { attribute :>> posX = 12; attribute :>> posY = 172; attribute :>> width = 336; attribute :>> height = 36; attribute :>> caption = "+ Запросить доп. работы у клиента"; }
        }

        part adminCard : Card {
            attribute :>> posX = 20; attribute :>> posY = 288; attribute :>> width = 360; attribute :>> height = 254;
            attribute :>> caption = "Режим АДМИНИСТРАТОРА СТО";

            part t1 : Label { attribute :>> posX = 12; attribute :>> posY = 32; attribute :>> width = 336; attribute :>> height = 20; attribute :>> caption = "Тарифы: Ремонт 60 | Мойка 35 | Антикор 250 BYN"; }
            part t2 : Label { attribute :>> posX = 12; attribute :>> posY = 56; attribute :>> width = 336; attribute :>> height = 20; attribute :>> caption = "Покраска 280 | Чип-тюнинг 450 | Скидка 10%"; }
            part b1 : Label { attribute :>> posX = 12; attribute :>> posY = 86; attribute :>> width = 336; attribute :>> height = 20; attribute :>> caption = "Активные боксы: 4 (09:00 - 21:00)"; }
            part b2 : Label { attribute :>> posX = 12; attribute :>> posY = 110; attribute :>> width = 336; attribute :>> height = 20; attribute :>> caption = "Загрузка СТО сегодня: 85% (17 заказов)"; }

            part staffAccBtn : Button { attribute :>> posX = 12; attribute :>> posY = 148; attribute :>> width = 336; attribute :>> height = 36; attribute :>> caption = "Выдать логин/пароль мастеру СТО"; }
            part saveBtn : PrimaryButton { attribute :>> posX = 12; attribute :>> posY = 196; attribute :>> width = 336; attribute :>> height = 40; attribute :>> caption = "Сохранить в облако (PostgreSQL)"; }
        }
    }
}
