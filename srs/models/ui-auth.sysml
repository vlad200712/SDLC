// Экран входа и выбора роли (RBAC). Требования: REQ-FUNC-001, REQ-FUNC-003, REQ-SEC-001, REQ-SEC-003, REQ-SEC-005.
package UiAuth {
    private import UiLibrary::*;

    part authScreen : Screen {
        attribute :>> width = 480;
        attribute :>> height = 920;
        attribute :>> caption = "AutoService · 1. Вход и роли (RBAC)";

        part clientTab : TabActive { attribute :>> posX = 24; attribute :>> posY = 64; attribute :>> width = 216; attribute :>> height = 44; attribute :>> caption = "Клиент СТО"; }
        part staffTab : TabInactive { attribute :>> posX = 240; attribute :>> posY = 64; attribute :>> width = 216; attribute :>> height = 44; attribute :>> caption = "Мастер / Админ"; }

        part clientHeading : Heading { attribute :>> posX = 24; attribute :>> posY = 128; attribute :>> width = 432; attribute :>> height = 28; attribute :>> caption = "Вход для автовладельца:"; }
        part phoneField : TextField { attribute :>> posX = 24; attribute :>> posY = 166; attribute :>> width = 432; attribute :>> height = 46; attribute :>> caption = "Телефон / Email"; attribute :>> subcaption = "+375 (29) 123-45-67"; }
        part passField : TextField { attribute :>> posX = 24; attribute :>> posY = 236; attribute :>> width = 432; attribute :>> height = 46; attribute :>> caption = "Пароль"; attribute :>> subcaption = "••••••••••••"; }
        part clientLoginBtn : SuccessButton { attribute :>> posX = 24; attribute :>> posY = 302; attribute :>> width = 432; attribute :>> height = 48; attribute :>> caption = "ВОЙТИ КАК КЛИЕНТ"; }
        part registerBtn : Button { attribute :>> posX = 24; attribute :>> posY = 362; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "Регистрация нового клиента"; attribute :>> tone = "primary-outline"; }

        part staffCard : Card {
            attribute :>> posX = 24; attribute :>> posY = 432; attribute :>> width = 432; attribute :>> height = 390;
            attribute :>> caption = "Служебный вход (Персонал СТО):";
            attribute :>> tone = "warning";

            part staffLoginField : TextField { attribute :>> posX = 16; attribute :>> posY = 48; attribute :>> width = 400; attribute :>> height = 46; attribute :>> caption = "Корпоративный логин"; attribute :>> subcaption = "master_box2@autoservice.by"; }
            part staffPassField : TextField { attribute :>> posX = 16; attribute :>> posY = 122; attribute :>> width = 400; attribute :>> height = 46; attribute :>> caption = "Служебный пароль"; attribute :>> subcaption = "••••••••••"; }
            part roleLabel : Label { attribute :>> posX = 16; attribute :>> posY = 192; attribute :>> width = 400; attribute :>> height = 28; attribute :>> caption = "Роль: [ Мастер СТО | Админ СТО ]"; }
            part lockWarning : Label { attribute :>> posX = 16; attribute :>> posY = 228; attribute :>> width = 400; attribute :>> height = 26; attribute :>> caption = "Блокировка после 5 неудачных попыток (15 мин)"; attribute :>> tone = "danger"; }
            part staffLoginBtn : WarningButton { attribute :>> posX = 16; attribute :>> posY = 270; attribute :>> width = 400; attribute :>> height = 48; attribute :>> caption = "ВХОД ПЕРСОНАЛА (JWT)"; }
            part staffNote : Label { attribute :>> posX = 16; attribute :>> posY = 336; attribute :>> width = 400; attribute :>> height = 28; attribute :>> caption = "* Логины мастеров выдаются Администратором СТО"; attribute :>> tone = "muted"; }
        }

        part apiStatus : Badge { attribute :>> posX = 24; attribute :>> posY = 844; attribute :>> width = 200; attribute :>> height = 34; attribute :>> caption = "Cloud API доступен"; attribute :>> tone = "normal"; }
    }
}
