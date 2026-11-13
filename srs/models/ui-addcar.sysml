// Экран добавления автомобиля в гараж по VIN (NHTSA VIN API). Требования: REQ-FUNC-005, REQ-FUNC-006, REQ-INT-004, REQ-REL-003.
package UiAddCar {
    private import UiLibrary::*;

    part addCarScreen : Screen {
        attribute :>> width = 480;
        attribute :>> height = 880;
        attribute :>> caption = "AutoService · Добавление автомобиля";

        part heading : Heading { attribute :>> posX = 24; attribute :>> posY = 64; attribute :>> width = 432; attribute :>> height = 32; attribute :>> caption = "Добавить автомобиль в гараж"; }

        part vinField : TextField { attribute :>> posX = 24; attribute :>> posY = 112; attribute :>> width = 432; attribute :>> height = 46; attribute :>> caption = "VIN-код (17 символов по ISO 3779)"; attribute :>> subcaption = "WBACR61090L123456"; }
        part decodeBtn : PrimaryButton { attribute :>> posX = 24; attribute :>> posY = 182; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "Определить по NHTSA VIN API"; }
        part decodeStatus : Badge { attribute :>> posX = 24; attribute :>> posY = 238; attribute :>> width = 320; attribute :>> height = 30; attribute :>> caption = "Найдено: BMW X5 (2021), Кроссовер"; attribute :>> tone = "normal"; }

        part brandField : TextField { attribute :>> posX = 24; attribute :>> posY = 288; attribute :>> width = 208; attribute :>> height = 46; attribute :>> caption = "Марка"; attribute :>> subcaption = "BMW"; }
        part modelField : TextField { attribute :>> posX = 248; attribute :>> posY = 288; attribute :>> width = 208; attribute :>> height = 46; attribute :>> caption = "Модель"; attribute :>> subcaption = "X5 (G05)"; }

        part yearField : TextField { attribute :>> posX = 24; attribute :>> posY = 362; attribute :>> width = 208; attribute :>> height = 46; attribute :>> caption = "Год выпуска"; attribute :>> subcaption = "2021"; }
        part mileageField : TextField { attribute :>> posX = 248; attribute :>> posY = 362; attribute :>> width = 208; attribute :>> height = 46; attribute :>> caption = "Пробег (км)"; attribute :>> subcaption = "84200"; }

        part plateField : TextField { attribute :>> posX = 24; attribute :>> posY = 436; attribute :>> width = 208; attribute :>> height = 46; attribute :>> caption = "Госномер"; attribute :>> subcaption = "7788 AB-7"; }
        part bodyField : TextField { attribute :>> posX = 248; attribute :>> posY = 436; attribute :>> width = 208; attribute :>> height = 46; attribute :>> caption = "Тип кузова"; attribute :>> subcaption = "Кроссовер (x1.3)"; }

        part fallbackNote : Label { attribute :>> posX = 24; attribute :>> posY = 514; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "При недоступности NHTSA VIN API поля можно\nзаполнить и скорректировать вручную."; attribute :>> tone = "muted"; }

        part saveBtn : SuccessButton { attribute :>> posX = 24; attribute :>> posY = 584; attribute :>> width = 432; attribute :>> height = 50; attribute :>> caption = "СОХРАНИТЬ В ГАРАЖ"; }
        part cancelBtn : Button { attribute :>> posX = 24; attribute :>> posY = 648; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "Отмена"; }
    }
}
