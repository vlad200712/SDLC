// Упрощённый ч/б макет экрана записи на время, статуса заказа и истории ремонтов.
// Требования: REQ-FUNC-013..REQ-FUNC-024, REQ-INT-008.
package UiBooking {
    private import UiLibrary::*;

    part bookingScreen : Screen {
        attribute :>> width = 400;
        attribute :>> height = 620;
        attribute :>> caption = "AutoService - 3. Запись и история";

        part slotCard : Card {
            attribute :>> posX = 20; attribute :>> posY = 50; attribute :>> width = 360; attribute :>> height = 140;
            attribute :>> caption = "Запись (14.11.2026 | Пост: Бокс №2)";

            part slot1 : SlotChip { attribute :>> posX = 12; attribute :>> posY = 34; attribute :>> width = 104; attribute :>> height = 46; attribute :>> caption = "09:00"; attribute :>> subcaption = "Занято"; attribute :>> tone = "disabled"; }
            part slot2 : SlotChip { attribute :>> posX = 128; attribute :>> posY = 34; attribute :>> width = 104; attribute :>> height = 46; attribute :>> caption = "12:30"; attribute :>> subcaption = "Выбрано"; attribute :>> tone = "selected"; }
            part slot3 : SlotChip { attribute :>> posX = 244; attribute :>> posY = 34; attribute :>> width = 104; attribute :>> height = 46; attribute :>> caption = "16:00"; attribute :>> subcaption = "Свободно"; attribute :>> tone = "available"; }
            part cancelBtn : Button { attribute :>> posX = 12; attribute :>> posY = 92; attribute :>> width = 336; attribute :>> height = 34; attribute :>> caption = "Отменить / перенести (за >= 2 ч)"; }
        }

        part statusCard : Card {
            attribute :>> posX = 20; attribute :>> posY = 202; attribute :>> width = 360; attribute :>> height = 198;
            attribute :>> caption = "Текущий заказ #1042";

            part statusText : Heading { attribute :>> posX = 12; attribute :>> posY = 30; attribute :>> width = 336; attribute :>> height = 22; attribute :>> caption = "Статус: В РАБОТЕ (Антикор + ТО)"; }
            part progress : ProgressBar { attribute :>> posX = 12; attribute :>> posY = 58; attribute :>> width = 336; attribute :>> height = 38; attribute :>> progress = 70; attribute :>> steps = "принят -> диагностика -> [в работе] -> готов"; }

            part extraCard : Card {
                attribute :>> posX = 12; attribute :>> posY = 104; attribute :>> width = 336; attribute :>> height = 82;
                attribute :>> caption = "! Запрос мастера: замена втулок (+45 BYN)";

                part approveBtn : PrimaryButton { attribute :>> posX = 12; attribute :>> posY = 34; attribute :>> width = 150; attribute :>> height = 34; attribute :>> caption = "Подтвердить"; }
                part rejectBtn : Button { attribute :>> posX = 174; attribute :>> posY = 34; attribute :>> width = 150; attribute :>> height = 34; attribute :>> caption = "Отклонить"; }
            }
        }

        part historyCard : Card {
            attribute :>> posX = 20; attribute :>> posY = 412; attribute :>> width = 360; attribute :>> height = 190;
            attribute :>> caption = "История ремонтов (Облако + SQLite)";

            part hist1 : ListRow { attribute :>> posX = 12; attribute :>> posY = 32; attribute :>> width = 336; attribute :>> height = 48; attribute :>> caption = "02.09.2026 | Пробег: 81 400 км | 495.00 BYN"; attribute :>> subcaption = "Чип-тюнинг Stage 1, Мойка (Завершён)"; }
            part hist2 : ListRow { attribute :>> posX = 12; attribute :>> posY = 86; attribute :>> width = 336; attribute :>> height = 48; attribute :>> caption = "15.05.2026 | Пробег: 75 000 км | 544.00 BYN"; attribute :>> subcaption = "Покраска бампера, Ремонт ТО (Завершён)"; }
            part exportBtn : Button { attribute :>> posX = 12; attribute :>> posY = 144; attribute :>> width = 336; attribute :>> height = 34; attribute :>> caption = "Экспорт сервисной книжки (JSON / PDF)"; }
        }
    }
}
