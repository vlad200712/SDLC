// Панель управления мастера и администратора СТО. Требования: REQ-FUNC-025..REQ-FUNC-030.
package UiStaff {
    private import UiLibrary::*;

    part staffScreen : Screen {
        attribute :>> width = 480;
        attribute :>> height = 980;
        attribute :>> caption = "AutoService · 4. Панель персонала";

        part masterCard : Card {
            attribute :>> posX = 24; attribute :>> posY = 64; attribute :>> width = 432; attribute :>> height = 434;
            attribute :>> caption = "Режим МАСТЕРА СТО (Бокс №2):";
            attribute :>> tone = "warning";

            part orderTitle : Heading { attribute :>> posX = 16; attribute :>> posY = 38; attribute :>> width = 400; attribute :>> height = 26; attribute :>> caption = "Заказ #1042: BMW X5 (7788 AB-7)"; }
            part orderServices : Label { attribute :>> posX = 16; attribute :>> posY = 68; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "Услуги: Ремонт ТО, Мойка, Антикор"; attribute :>> tone = "muted"; }
            part statusPrompt : Label { attribute :>> posX = 16; attribute :>> posY = 100; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "Установить статус обслуживания:"; }

            part st1 : Button { attribute :>> posX = 16; attribute :>> posY = 130; attribute :>> width = 400; attribute :>> height = 42; attribute :>> caption = "Принят в бокс"; }
            part st2 : Button { attribute :>> posX = 16; attribute :>> posY = 180; attribute :>> width = 400; attribute :>> height = 42; attribute :>> caption = "На диагностике"; }
            part st3 : SuccessButton { attribute :>> posX = 16; attribute :>> posY = 230; attribute :>> width = 400; attribute :>> height = 44; attribute :>> caption = "● В РАБОТЕ (Активен)"; }
            part st4 : Button { attribute :>> posX = 16; attribute :>> posY = 282; attribute :>> width = 400; attribute :>> height = 42; attribute :>> caption = "Готов к выдаче (Push)"; attribute :>> tone = "primary-outline"; }
            part addWorkBtn : WarningButton { attribute :>> posX = 16; attribute :>> posY = 340; attribute :>> width = 400; attribute :>> height = 46; attribute :>> caption = "+ Запросить доп. работы у клиента"; }
        }

        part adminCard : Card {
            attribute :>> posX = 24; attribute :>> posY = 516; attribute :>> width = 432; attribute :>> height = 428;
            attribute :>> caption = "Режим АДМИНИСТРАТОРА СТО:";
            attribute :>> tone = "purple";

            part sec1 : Heading { attribute :>> posX = 16; attribute :>> posY = 40; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "1. Управление базовыми тарифами:"; }
            part t1 : Label { attribute :>> posX = 16; attribute :>> posY = 70; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "• Ремонт (н/ч): [ 60 BYN ]  Мойка: [ 35 BYN ]"; }
            part t2 : Label { attribute :>> posX = 16; attribute :>> posY = 98; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "• Антикор: [ 250 BYN ]  Покраска: [ 280 BYN ]"; }
            part t3 : Label { attribute :>> posX = 16; attribute :>> posY = 126; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "• Чип-тюнинг: [ 450 BYN ]  Скидка: [ 10% ]"; }

            part sec2 : Heading { attribute :>> posX = 16; attribute :>> posY = 170; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "2. Управление боксами и мастерами:"; }
            part b1 : Label { attribute :>> posX = 16; attribute :>> posY = 200; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "• Активные боксы: 4 (09:00 - 21:00)"; }
            part b2 : Label { attribute :>> posX = 16; attribute :>> posY = 228; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "• Выдать логин/пароль мастеру СТО"; attribute :>> tone = "purple"; }
            part b3 : Label { attribute :>> posX = 16; attribute :>> posY = 256; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "• Загрузка СТО сегодня: 85% (17 заказов)"; attribute :>> tone = "normal"; }

            part saveCloudBtn : PrimaryButton { attribute :>> posX = 16; attribute :>> posY = 326; attribute :>> width = 400; attribute :>> height = 50; attribute :>> caption = "СОХРАНИТЬ В ОБЛАКО (PostgreSQL)"; attribute :>> tone = "purple"; }
        }
    }
}
