#ifndef FORM_H
#define FORM_H

#include <QWidget>

namespace Ui {
class Form;
}

class Form : public QWidget {
    Q_OBJECT

public:
    //lastText для восстановления предыдущего ввода
    explicit Form(const QString &lastText, QWidget *parent = nullptr);
    ~Form();

signals:
    //сигнал, который отдаст введенный текст в главное окно
    void dataAccepted(const QString &text);

private slots:
    //слот
    void on_OKButton_clicked();

private:
    Ui::Form *ui;
};

#endif // FORM_H