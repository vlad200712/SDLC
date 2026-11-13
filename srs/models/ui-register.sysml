// Экран регистрации нового клиента СТО. Требования: REQ-FUNC-001, REQ-FUNC-002, REQ-SEC-001, REQ-COMP-003.
package UiRegister {
    private import UiLibrary::*;

    part registerScreen : Screen {
        attribute :>> width = 480;
        attribute :>> height = 840;
        attribute :>> caption = "AutoService · Регистрация клиента";

        part heading : Heading { attribute :>> posX = 24; attribute :>> posY = 64; attribute :>> width = 432; attribute :>> height = 32; attribute :>> caption = "Создание учётной записи клиента"; }

        part nameField : TextField { attribute :>> posX = 24; attribute :>> posY = 114; attribute :>> width = 432; attribute :>> height = 46; attribute :>> caption = "ФИО клиента"; attribute :>> subcaption = "Кожемякин Владислав Олегович"; }
        part phoneField : TextField { attribute :>> posX = 24; attribute :>> posY = 186; attribute :>> width = 432; attribute :>> height = 46; attribute :>> caption = "Номер телефона"; attribute :>> subcaption = "+375 (29) 123-45-67"; }
        part emailField : TextField { attribute :>> posX = 24; attribute :>> posY = 258; attribute :>> width = 432; attribute :>> height = 46; attribute :>> caption = "Email"; attribute :>> subcaption = "vlad@example.by"; }
        part passField : TextField { attribute :>> posX = 24; attribute :>> posY = 330; attribute :>> width = 432; attribute :>> height = 46; attribute :>> caption = "Пароль (не менее 8 символов)"; attribute :>> subcaption = "••••••••••••"; }
        part passConfirmField : TextField { attribute :>> posX = 24; attribute :>> posY = 402; attribute :>> width = 432; attribute :>> height = 46; attribute :>> caption = "Повторите пароль"; attribute :>> subcaption = "••••••••••••"; }

        part consentRow : CheckRow { attribute :>> posX = 24; attribute :>> posY = 474; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "[✓] Согласие на обработку персональных данных"; attribute :>> tone = "normal"; }
        part policyNote : Label { attribute :>> posX = 24; attribute :>> posY = 530; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "Регистрация доступна только для роли «Клиент СТО».\nУчётные записи персонала создаются администратором."; attribute :>> tone = "muted"; }

        part submitBtn : SuccessButton { attribute :>> posX = 24; attribute :>> posY = 602; attribute :>> width = 432; attribute :>> height = 50; attribute :>> caption = "ЗАРЕГИСТРИРОВАТЬСЯ"; }
        part backBtn : Button { attribute :>> posX = 24; attribute :>> posY = 668; attribute :>> width = 432; attribute :>> height = 44; attribute :>> caption = "← Назад ко входу"; }
    }
}
