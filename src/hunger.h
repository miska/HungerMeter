#ifndef HUNGER_H
#define HUNGER_H

#include <QObject>
#include <QString>
#include <queue>
#include <list>
#include <time.h>

#define CACHE_SIZE 100

class Hunger : public QObject{
    Q_OBJECT
public:
    std::list<double> hist;
    explicit Hunger(QObject* parent = 0) : QObject(parent) {}
    ~Hunger() {}
    Q_INVOKABLE void refresh();
    Q_INVOKABLE QString current_text(int number);
    Q_INVOKABLE QString avg_text();
};

#endif // HUNGER_H
