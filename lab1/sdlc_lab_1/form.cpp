#include "form.h"
#include "ui_form.h"

Form::Form(const QString &lastText, QWidget *parent) :
    QWidget(parent),
    ui(new Ui::Form)
{
    ui->setupUi(this);
    setWindowFlags(Qt::Window);
    setWindowModality(Qt::ApplicationModal);
    setWindowTitle("Ввод данных");

    ui->textEdit->setText(lastText);
}

Form::~Form()
{
    delete ui;
}

void Form::on_OKButton_clicked()
{
    //отправляем сигнал с текстом из textEdit и закрываем форму
    emit dataAccepted(ui->textEdit->toPlainText());
    close();
}