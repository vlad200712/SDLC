#ifndef MODEL_H
#define MODEL_H

#include <QObject>
#include <QString>
#include <algorithm>

class TextModel : public QObject {
    Q_OBJECT
public:
    explicit TextModel(QObject *parent = nullptr) : QObject(parent) {}

    QString getOriginalText() const { return originalText; }
    QString getInvertedText() const { return invertedText; }

    void setOriginalText(const QString &text) {
        originalText = text;
        invertWords();
        //активная модель оповещает  об изменении состояния
        emit dataChanged(originalText, invertedText);
    }

signals:
    void dataChanged(const QString &original, const QString &inverted);

private:
    QString originalText;
    QString invertedText;

    void invertWords() {
        invertedText = originalText;
        int start = -1;
        //проходим по строке и инвертируем слова (последовательности букв и цифр)
        for (int i = 0; i <= invertedText.length(); ++i) {
            if (i < invertedText.length() && invertedText[i].isLetterOrNumber()) {
                if (start == -1) start = i;
            } else {
                if (start != -1) {
                    std::reverse(invertedText.begin() + start, invertedText.begin() + i);
                    start = -1;
                }
            }
        }
    }
};

#endif // MODEL_H