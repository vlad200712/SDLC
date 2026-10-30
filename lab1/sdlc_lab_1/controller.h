// controller.h
#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include "model.h"

class TextController : public QObject {
    Q_OBJECT
public:
    explicit TextController(TextModel *model, QObject *parent = nullptr)
        : QObject(parent), m_model(model) {}

    //метод обработки ввода
    void processInput(const QString &input) {
        QString trimmedInput = input.trimmed();
        //обработка ошибки пустая строка
        if (trimmedInput.isEmpty()) {
            emit validationFailed("Ошибка: Введена пустая строка. Пожалуйста, введите предложение.");
            return;
        }

        //обработка ошибки : нет слов для инвертирования
        bool hasLetters = false;
        for (QChar c : trimmedInput) {
            if (c.isLetterOrNumber()) {
                hasLetters = true;
                break;
            }
        }

        if (!hasLetters) {
            emit validationFailed("Ошибка: Текст не содержит букв или цифр. Инвертировать нечего.");
            return;
        }

        //если данные корректны, передаем их в model
        m_model->setOriginalText(input);
    }

signals:
    void validationFailed(const QString &errorMessage);

private:
    TextModel *m_model;
};

#endif // CONTROLLER_H