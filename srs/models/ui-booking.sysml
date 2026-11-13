// Экран записи на время, статуса заказа и истории ремонтов. Требования: REQ-FUNC-013..REQ-FUNC-024.
package UiBooking {
    private import UiLibrary::*;

    part bookingScreen : Screen {
        attribute :>> width = 480;
        attribute :>> height = 980;
        attribute :>> caption = "AutoService · 3. Запись и история";

        part slotCard : Card {
            attribute :>> posX = 24; attribute :>> posY = 64; attribute :>> width = 432; attribute :>> height = 192;
            attribute :>> caption = "Запись на свободное время:";
            attribute :>> tone = "neutral";

            part dateInfo : Label { attribute :>> posX = 16; attribute :>> posY = 38; attribute :>> width = 400; attribute :>> height = 24; attribute :>> caption = "Дата: [ 14.11.2026 (Сб) ]  Пост: Бокс №2"; }
            part slot1 : SlotChip { attribute :>> posX = 16; attribute :>> posY = 72; attribute :>> width = 124; attribute :>> height = 52; attribute :>> caption = "09:00"; attribute :>> subcaption = "Занято"; attribute :>> tone = "disabled"; }
            part slot2 : SlotChip { attribute :>> posX = 154; attribute :>> posY = 72; attribute :>> width = 124; attribute :>> height = 52; attribute :>> caption = "12:30"; attribute :>> subcaption = "Выбрано"; attribute :>> tone = "selected"; }
            part slot3 : SlotChip { attribute :>> posX = 292; attribute :>> posY = 72; attribute :>> width = 124; attribute :>> height = 52; attribute :>> caption = "16:00"; attribute :>> subcaption = "Свободно"; attribute :>> tone = "available"; }
            part cancelRule : Label { attribute :>> posX = 16; attribute :>> posY = 142; attribute :>> width = 400; attribute :>> height = 28; attribute :>> caption = "[Отменить / Перенести запись (за >= 2 ч)]"; attribute :>> tone = "danger"; }
        }

        part statusCard : Card {
            attribute :>> posX = 24; attribute :>> posY = 272; attribute :>> width = 432; attribute :>> height = 304;
            attribute :>> caption = "Текущий статус заказа #1042:";
            attribute :>> tone = "info";

            part statusText : Heading { attribute :>> posX = 16; attribute :>> posY = 38; attribute :>> width = 400; attribute :>> height = 28; attribute :>> caption = "Статус: В РАБОТЕ (Антикор + ТО)"; attribute :>> tone = "normal"; }
            part progress : ProgressBar { attribute :>> posX = 16; attribute :>> posY = 74; attribute :>> width = 400; attribute :>> height = 44; attribute :>> progress = 70; attribute :>> steps = "принят → диагностика → [в работе] → готов"; }

            part extraCard : Card {
                attribute :>> posX = 16; attribute :>> posY = 134; attribute :>> width = 400; attribute :>> height = 148;
                attribute :>> caption = "! Запрос мастера: замена втулок (+45 BYN)";
                attribute :>> tone = "danger";

                part approveBtn : SuccessButton { attribute :>> posX = 16; attribute :>> posY = 72; attribute :>> width = 176; attribute :>> height = 46; attribute :>> caption = "Подтвердить"; }
                part rejectBtn : DangerButton { attribute :>> posX = 208; attribute :>> posY = 72; attribute :>> width = 176; attribute :>> height = 46; attribute :>> caption = "Отклонить"; }
            }
        }

        part historyCard : Card {
            attribute :>> posX = 24; attribute :>> posY = 594; attribute :>> width = 432; attribute :>> height = 344;
            attribute :>> caption = "История ремонтов (Облако + SQLite):";
            attribute :>> tone = "neutral";

            part hist1 : ListRow { attribute :>> posX = 16; attribute :>> posY = 44; attribute :>> width = 400; attribute :>> height = 96; attribute :>> caption = "1) 02.09.2026 | Пробег: 81 400 км"; attribute :>> subcaption = "Услуги: Чип-тюнинг Stage 1, Мойка\nСумма: 495.00 BYN | Статус: Завершён"; attribute :>> tone = "normal"; }
            part hist2 : ListRow { attribute :>> posX = 16; attribute :>> posY = 154; attribute :>> width = 400; attribute :>> height = 96; attribute :>> caption = "2) 15.05.2026 | Пробег: 75 000 км"; attribute :>> subcaption = "Услуги: Покраска бампера, Ремонт ТО\nСумма: 544.00 BYN | Статус: Завершён"; attribute :>> tone = "normal"; }
            part exportBtn : Button { attribute :>> posX = 16; attribute :>> posY = 270; attribute :>> width = 400; attribute :>> height = 48; attribute :>> caption = "Экспорт сервисной книжки (JSON/PDF)"; }
        }
    }
}
