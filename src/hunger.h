#ifndef HUNGER_H
#define HUNGER_H

#include <QObject>
#include <QString>
#include <queue>
#include <list>
#include <time.h>

#define CACHE_SIZE 60

struct history {
    float data;
    time_t time;
};

class Hunger : public QObject{
    Q_OBJECT
public:
    std::list<history> hist;
    explicit Hunger(QObject* parent = 0) : QObject(parent) {}
    ~Hunger() {}
    Q_INVOKABLE void refresh();
    Q_INVOKABLE QString avg_text(int number);
};

#endif // HUNGER_H
