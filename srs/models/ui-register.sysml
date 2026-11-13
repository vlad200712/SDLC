// Упрощённый ч/б макет экрана регистрации нового клиента СТО.
// Требования: REQ-FUNC-001, REQ-FUNC-002, REQ-SEC-001, REQ-COMP-003.
package UiRegister {
    private import UiLibrary::*;

    part registerScreen : Screen {
        attribute :>> width = 400;
        attribute :>> height = 520;
        attribute :>> caption = "AutoService - Регистрация";

        part heading : Heading { attribute :>> posX = 20; attribute :>> posY = 50; attribute :>> width = 360; attribute :>> height = 22; attribute :>> caption = "Регистрация клиента СТО"; }

        part nameField : TextField { attribute :>> posX = 20; attribute :>> posY = 96; attribute :>> width = 360; attribute :>> height = 34; attribute :>> caption = "ФИО клиента"; attribute :>> subcaption = "Кожемякин В. О."; }
        part phoneField : TextField { attribute :>> posX = 20; attribute :>> posY = 152; attribute :>> width = 360; attribute :>> height = 34; attribute :>> caption = "Телефон"; attribute :>> subcaption = "+375 (29) 123-45-67"; }
        part emailField : TextField { attribute :>> posX = 20; attribute :>> posY = 208; attribute :>> width = 360; attribute :>> height = 34; attribute :>> caption = "Email"; attribute :>> subcaption = "vlad@example.by"; }
        part passField : TextField { attribute :>> posX = 20; attribute :>> posY = 264; attribute :>> width = 360; attribute :>> height = 34; attribute :>> caption = "Пароль (не менее 8 символов)"; attribute :>> subcaption = "********"; }
        part passConfirmField : TextField { attribute :>> posX = 20; attribute :>> posY = 320; attribute :>> width = 360; attribute :>> height = 34; attribute :>> caption = "Повторите пароль"; attribute :>> subcaption = "********"; }

        part consentRow : CheckRow { attribute :>> posX = 20; attribute :>> posY = 370; attribute :>> width = 360; attribute :>> height = 34; attribute :>> caption = "[x] Согласие на обработку ПД (Закон РБ 99-З)"; attribute :>> tone = "selected"; }
        part roleNote : Label { attribute :>> posX = 20; attribute :>> posY = 412; attribute :>> width = 360; attribute :>> height = 20; attribute :>> caption = "* Самостоятельная регистрация только для Клиента СТО"; }

        part submitBtn : PrimaryButton { attribute :>> posX = 20; attribute :>> posY = 438; attribute :>> width = 360; attribute :>> height = 36; attribute :>> caption = "Зарегистрироваться"; }
        part backBtn : Button { attribute :>> posX = 20; attribute :>> posY = 480; attribute :>> width = 360; attribute :>> height = 30; attribute :>> caption = "Назад ко входу"; }
    }
}
