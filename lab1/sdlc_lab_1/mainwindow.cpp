// mainwindow.cpp
#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "form.h"
#include <QMessageBox>

MainWindow::MainWindow(TextModel *model, TextController *controller, QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , m_model(model)
    , m_controller(controller)
{
    ui->setupUi(this);
    setWindowTitle("Инвертор слов (MVC)");

    //коннект на актив. модель
    connect(m_model, &TextModel::dataChanged, this, &MainWindow::onModelDataChanged);

    //коннект на ошибки от контроллера
    connect(m_controller, &TextController::validationFailed, this, &MainWindow::onValidationFailed);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_changeButton_clicked()
{
    //открываем второе окно, передавая ему последний валидный текст
    Form *form = new Form(m_model->getOriginalText(), this);

    //получаем введенные данные из формы и отправляем их в Контроллер
    connect(form, &Form::dataAccepted, this, [this, form](const QString &text) {
        m_controller->processInput(text);
        form->deleteLater(); //очищ. память
    });

    //если форму просто закрыли крестиком, тоже удаляем из памяти
    connect(form, &QWidget::destroyed, form, &QObject::deleteLater);

    form->show();
}

void MainWindow::onModelDataChanged(const QString &original, const QString &inverted)
{
    //вывод в textBrowser
    QString resultText = "<b>Исходное предложение:</b><br>" + original + "<br><br>"
                                                                         "<b>Инвертированное предложение:</b><br>" + inverted;

    ui->textBrowser->setHtml(resultText);
}

void MainWindow::onValidationFailed(const QString &errorMessage)
{
    //пказываем сообщение об ошибке
    QMessageBox::warning(this, "Ошибка ввода", errorMessage);
}