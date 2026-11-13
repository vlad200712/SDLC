// Экран гаража и выбора услуг автосервиса. Требования: REQ-FUNC-005..REQ-FUNC-012, REQ-INT-004, REQ-INT-006.
package UiGarage {
    private import UiLibrary::*;

    part garageScreen : Screen {
        attribute :>> width = 480;
        attribute :>> height = 960;
        attribute :>> caption = "AutoService · 2. Гараж и Услуги СТО";

        part carCard : Card {
            attribute :>> posX = 24; attribute :>> posY = 64; attribute :>> width = 432; attribute :>> height = 148;
            attribute :>> caption = "Мой автомобиль [Авто по VIN]:";
            attribute :>> tone = "info";

            part carTitle : Heading { attribute :>> posX = 16; attribute :>> posY = 38; attribute :>> width = 400; attribute :>> height = 28; attribute :>> caption = "BMW X5 (G05) • 2021 г. • 84 200 км"; }
            part carVin : Mono { attribute :>> posX = 16; attribute :>> posY = 72; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "VIN: WBACR61090L123456 | Госномер: 7788 AB-7"; }
            part bodyType : Label { attribute :>> posX = 16; attribute :>> posY = 104; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "Тип кузова: Кроссовер (коэфф. x1.3)"; attribute :>> tone = "primary"; }
        }

        part addCarBtn : Button { attribute :>> posX = 24; attribute :>> posY = 224; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "+ Добавить авто (NHTSA VIN API)"; }

        part servicesLabel : Heading { attribute :>> posX = 24; attribute :>> posY = 284; attribute :>> width = 432; attribute :>> height = 28; attribute :>> caption = "Выберите услуги автосервиса:"; }

        part srv1 : CheckRow { attribute :>> posX = 24; attribute :>> posY = 318; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "[✓] 1. Ремонт (ТО и подвеска)"; attribute :>> subcaption = "180.00 BYN"; attribute :>> tone = "selected"; }
        part srv2 : CheckRow { attribute :>> posX = 24; attribute :>> posY = 370; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "[✓] 2. Мойка (комплекс x1.3)"; attribute :>> subcaption = "45.50 BYN"; attribute :>> tone = "selected"; }
        part srv3 : CheckRow { attribute :>> posX = 24; attribute :>> posY = 422; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "[✓] 3. Антикор днища (x1.3)"; attribute :>> subcaption = "325.00 BYN"; attribute :>> tone = "selected"; }
        part srv4 : CheckRow { attribute :>> posX = 24; attribute :>> posY = 474; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "[ ] 4. Покраска элемента (x1.3)"; attribute :>> subcaption = "364.00 BYN"; attribute :>> tone = "neutral"; }
        part srv5 : CheckRow { attribute :>> posX = 24; attribute :>> posY = 526; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "[ ] 5. Чип-тюнинг Stage 1"; attribute :>> subcaption = "450.00 BYN"; attribute :>> tone = "neutral"; }

        part calcCard : Card {
            attribute :>> posX = 24; attribute :>> posY = 588; attribute :>> width = 432; attribute :>> height = 186;
            attribute :>> caption = "Авторасчёт стоимости (Cloud API):";
            attribute :>> tone = "warning";

            part baseLine : Label { attribute :>> posX = 16; attribute :>> posY = 38; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "• Базовая сумма (3 услуги): 550.50 BYN"; }
            part discountLine : Label { attribute :>> posX = 16; attribute :>> posY = 68; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "• Скидка 10% (комплекс >= 3): -55.05 BYN"; attribute :>> tone = "normal"; }
            part durationLine : Label { attribute :>> posX = 16; attribute :>> posY = 98; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "• Длительность работ: ~4 ч 30 мин"; }
            part totalLine : Heading { attribute :>> posX = 16; attribute :>> posY = 136; attribute :>> width = 400; attribute :>> height = 30; attribute :>> caption = "ИТОГО: 495.45 BYN (~152 USD)"; }
        }

        part bookBtn : PrimaryButton { attribute :>> posX = 24; attribute :>> posY = 796; attribute :>> width = 432; attribute :>> height = 52; attribute :>> caption = "ВЫБРАТЬ ВРЕМЯ ЗАПИСИ →"; }
    }
}
