// mainwindow.h
#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "model.h"
#include "controller.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(TextModel *model, TextController *controller, QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    //слот для вашей кнопки в главном окне
    void on_changeButton_clicked();

    //слоты для реакции на сигналы из MVC
    void onModelDataChanged(const QString &original, const QString &inverted);
    void onValidationFailed(const QString &errorMessage);

private:
    Ui::MainWindow *ui;
    TextModel *m_model;
    TextController *m_controller;
};

#endif // MAINWINDOW_H