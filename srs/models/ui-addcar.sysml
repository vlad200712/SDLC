// Упрощённый ч/б макет экрана добавления автомобиля по VIN (NHTSA VIN API).
// Требования: REQ-FUNC-005, REQ-FUNC-006, REQ-INT-004, REQ-REL-003.
package UiAddCar {
    private import UiLibrary::*;

    part addCarScreen : Screen {
        attribute :>> width = 400;
        attribute :>> height = 470;
        attribute :>> caption = "AutoService - Добавить авто";

        part heading : Heading { attribute :>> posX = 20; attribute :>> posY = 50; attribute :>> width = 360; attribute :>> height = 22; attribute :>> caption = "Добавление автомобиля"; }

        part vinField : TextField { attribute :>> posX = 20; attribute :>> posY = 96; attribute :>> width = 360; attribute :>> height = 34; attribute :>> caption = "VIN-код (17 символов по ISO 3779)"; attribute :>> subcaption = "WBACR61090L123456"; }
        part decodeBtn : PrimaryButton { attribute :>> posX = 20; attribute :>> posY = 140; attribute :>> width = 360; attribute :>> height = 34; attribute :>> caption = "Определить по NHTSA VIN API"; }
        part decodeStatus : Label { attribute :>> posX = 20; attribute :>> posY = 182; attribute :>> width = 360; attribute :>> height = 20; attribute :>> caption = "Статус: найдено BMW X5 (2021), Кроссовер"; }

        part brandField : TextField { attribute :>> posX = 20; attribute :>> posY = 226; attribute :>> width = 172; attribute :>> height = 34; attribute :>> caption = "Марка"; attribute :>> subcaption = "BMW"; }
        part modelField : TextField { attribute :>> posX = 208; attribute :>> posY = 226; attribute :>> width = 172; attribute :>> height = 34; attribute :>> caption = "Модель"; attribute :>> subcaption = "X5 (G05)"; }

        part yearField : TextField { attribute :>> posX = 20; attribute :>> posY = 282; attribute :>> width = 172; attribute :>> height = 34; attribute :>> caption = "Год выпуска"; attribute :>> subcaption = "2021"; }
        part mileageField : TextField { attribute :>> posX = 208; attribute :>> posY = 282; attribute :>> width = 172; attribute :>> height = 34; attribute :>> caption = "Пробег (км)"; attribute :>> subcaption = "84200"; }

        part plateField : TextField { attribute :>> posX = 20; attribute :>> posY = 338; attribute :>> width = 172; attribute :>> height = 34; attribute :>> caption = "Госномер"; attribute :>> subcaption = "7788 AB-7"; }
        part bodyField : TextField { attribute :>> posX = 208; attribute :>> posY = 338; attribute :>> width = 172; attribute :>> height = 34; attribute :>> caption = "Тип кузова"; attribute :>> subcaption = "Кроссовер (x1.3)"; }

        part fallbackNote : Label { attribute :>> posX = 20; attribute :>> posY = 382; attribute :>> width = 360; attribute :>> height = 20; attribute :>> caption = "* При недоступности API поля вводятся вручную"; }

        part saveBtn : PrimaryButton { attribute :>> posX = 20; attribute :>> posY = 412; attribute :>> width = 172; attribute :>> height = 36; attribute :>> caption = "Сохранить"; }
        part cancelBtn : Button { attribute :>> posX = 208; attribute :>> posY = 412; attribute :>> width = 172; attribute :>> height = 36; attribute :>> caption = "Отмена"; }
    }
}
