// main.cpp
#include "mainwindow.h"
#include "model.h"
#include "controller.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    //QSS
    QString redDiagnosticStyle =
        "QWidget { "
        "   background-color: #2b0505; "
        "   color: #ffcccc; "
        "   font-family: 'Consolas', 'Courier New', monospace; "
        "   font-size: 11pt; "
        "}"
        "QPushButton { "
        "   background-color: #590000; "
        "   border: 1px solid #ff3333; "
        "   color: #ffffff; "
        "   padding: 6px 15px; "
        "   border-radius: 3px; "
        "}"
        "QPushButton:hover { "
        "   background-color: #800000; "
        "   border: 1px solid #ff6666; "
        "}"
        "QPushButton:pressed { "
        "   background-color: #330000; "
        "}"
        "QTextBrowser, QTextEdit { "
        "   background-color: #1a0000; "
        "   border: 1px solid #aa0000; "
        "   color: #ff6666; "
        "   padding: 5px; "
        "}";

    //применяем qss ко всей программе
    a.setStyleSheet(redDiagnosticStyle);

    //инициализируем Модель
    TextModel model;

    //инициализируем Контроллер, даем ему ссылку на Модель
    TextController controller(&model);

    //создаем Главное окно (View), передавая и Модель (для чтения), и Контроллер (для записи)
    MainWindow w(&model, &controller);
    w.show();

    return a.exec();
}