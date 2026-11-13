// Упрощённый ч/б макет экрана входа и ролей (RBAC).
// Требования: REQ-FUNC-001, REQ-FUNC-003, REQ-FUNC-004, REQ-SEC-003, REQ-SEC-005.
package UiAuth {
    private import UiLibrary::*;

    part authScreen : Screen {
        attribute :>> width = 400;
        attribute :>> height = 500;
        attribute :>> caption = "AutoService - 1. Вход и роли";

        part clientTab : TabActive { attribute :>> posX = 20; attribute :>> posY = 52; attribute :>> width = 176; attribute :>> height = 34; attribute :>> caption = "Клиент СТО"; }
        part staffTab : TabInactive { attribute :>> posX = 204; attribute :>> posY = 52; attribute :>> width = 176; attribute :>> height = 34; attribute :>> caption = "Мастер / Админ"; }

        part loginHeading : Heading { attribute :>> posX = 20; attribute :>> posY = 102; attribute :>> width = 360; attribute :>> height = 22; attribute :>> caption = "Вход в систему"; }
        part phoneField : TextField { attribute :>> posX = 20; attribute :>> posY = 148; attribute :>> width = 360; attribute :>> height = 36; attribute :>> caption = "Телефон / Email или логин"; attribute :>> subcaption = "+375 (29) 123-45-67"; }
        part passField : TextField { attribute :>> posX = 20; attribute :>> posY = 208; attribute :>> width = 360; attribute :>> height = 36; attribute :>> caption = "Пароль"; attribute :>> subcaption = "********"; }

        part loginBtn : PrimaryButton { attribute :>> posX = 20; attribute :>> posY = 260; attribute :>> width = 360; attribute :>> height = 38; attribute :>> caption = "Войти"; }
        part registerBtn : Button { attribute :>> posX = 20; attribute :>> posY = 308; attribute :>> width = 360; attribute :>> height = 34; attribute :>> caption = "Регистрация нового клиента"; }

        part staffCard : Card {
            attribute :>> posX = 20; attribute :>> posY = 360; attribute :>> width = 360; attribute :>> height = 116;
            attribute :>> caption = "Служебный вход и защита (JWT)";

            part staffNote : Label { attribute :>> posX = 12; attribute :>> posY = 34; attribute :>> width = 336; attribute :>> height = 34; attribute :>> caption = "Персонал (Мастер/Админ): корпоративный логин\nвыдаётся Администратором СТО."; }
            part lockNote : Label { attribute :>> posX = 12; attribute :>> posY = 76; attribute :>> width = 336; attribute :>> height = 24; attribute :>> caption = "Защита: блок на 15 мин после 5 неверных попыток."; }
        }
    }
}
