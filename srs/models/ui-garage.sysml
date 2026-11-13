// Упрощённый ч/б макет экрана гаража и выбора услуг СТО.
// Требования: REQ-FUNC-007..REQ-FUNC-012, REQ-INT-006.
package UiGarage {
    private import UiLibrary::*;

    part garageScreen : Screen {
        attribute :>> width = 400;
        attribute :>> height = 590;
        attribute :>> caption = "AutoService - 2. Гараж и услуги";

        part carCard : Card {
            attribute :>> posX = 20; attribute :>> posY = 50; attribute :>> width = 360; attribute :>> height = 84;
            attribute :>> caption = "Авто: BMW X5 (2021) | 7788 AB-7";

            part carVin : Label { attribute :>> posX = 12; attribute :>> posY = 30; attribute :>> width = 336; attribute :>> height = 20; attribute :>> caption = "VIN: WBACR61090L123456 | Пробег: 84 200 км"; }
            part bodyType : Label { attribute :>> posX = 12; attribute :>> posY = 54; attribute :>> width = 336; attribute :>> height = 20; attribute :>> caption = "Тип кузова: Кроссовер (коэфф. x1.3)"; }
        }

        part addCarBtn : Button { attribute :>> posX = 20; attribute :>> posY = 144; attribute :>> width = 360; attribute :>> height = 34; attribute :>> caption = "+ Добавить авто (NHTSA VIN API)"; }
        part servicesLabel : Heading { attribute :>> posX = 20; attribute :>> posY = 192; attribute :>> width = 360; attribute :>> height = 22; attribute :>> caption = "Выберите услуги:"; }

        part srv1 : CheckRow { attribute :>> posX = 20; attribute :>> posY = 220; attribute :>> width = 360; attribute :>> height = 32; attribute :>> caption = "[x] 1. Ремонт (ТО и подвеска)"; attribute :>> subcaption = "180.00 BYN"; attribute :>> tone = "selected"; }
        part srv2 : CheckRow { attribute :>> posX = 20; attribute :>> posY = 258; attribute :>> width = 360; attribute :>> height = 32; attribute :>> caption = "[x] 2. Мойка (x1.3)"; attribute :>> subcaption = "45.50 BYN"; attribute :>> tone = "selected"; }
        part srv3 : CheckRow { attribute :>> posX = 20; attribute :>> posY = 296; attribute :>> width = 360; attribute :>> height = 32; attribute :>> caption = "[x] 3. Антикор днища (x1.3)"; attribute :>> subcaption = "325.00 BYN"; attribute :>> tone = "selected"; }
        part srv4 : CheckRow { attribute :>> posX = 20; attribute :>> posY = 334; attribute :>> width = 360; attribute :>> height = 32; attribute :>> caption = "[ ] 4. Покраска элемента (x1.3)"; attribute :>> subcaption = "364.00 BYN"; }
        part srv5 : CheckRow { attribute :>> posX = 20; attribute :>> posY = 372; attribute :>> width = 360; attribute :>> height = 32; attribute :>> caption = "[ ] 5. Чип-тюнинг Stage 1"; attribute :>> subcaption = "450.00 BYN"; }

        part calcCard : Card {
            attribute :>> posX = 20; attribute :>> posY = 416; attribute :>> width = 360; attribute :>> height = 104;
            attribute :>> caption = "Авторасчёт стоимости";

            part baseLine : Label { attribute :>> posX = 12; attribute :>> posY = 28; attribute :>> width = 336; attribute :>> height = 20; attribute :>> caption = "Сумма (3 усл.): 550.50 | Скидка 10% (>=3): -55.05"; }
            part durationLine : Label { attribute :>> posX = 12; attribute :>> posY = 50; attribute :>> width = 336; attribute :>> height = 20; attribute :>> caption = "Длительность работ: ~4 ч 30 мин"; }
            part totalLine : Heading { attribute :>> posX = 12; attribute :>> posY = 74; attribute :>> width = 336; attribute :>> height = 22; attribute :>> caption = "ИТОГО: 495.45 BYN (~152 USD)"; }
        }

        part bookBtn : PrimaryButton { attribute :>> posX = 20; attribute :>> posY = 534; attribute :>> width = 360; attribute :>> height = 38; attribute :>> caption = "Выбрать время записи ->"; }
    }
}
