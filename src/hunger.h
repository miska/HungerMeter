/******************************************************************************
 *                                                                            *
 * HungerMeter - consumption measuring tool for SailfishOS                    *
 * Copyright (C) 2014 by Michal Hrusecky <Michal@Hrusecky.net>                *
 *                                                                            *
 * This program is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by       *
 * the Free Software Foundation, either version 3 of the License, or          *
 * (at your option) any later version.                                        *
 *                                                                            *
 * This program is distributed in the hope that it will be useful,            *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 * GNU General Public License for more details.                               *
 *                                                                            *
 * You should have received a copy of the GNU General Public License          *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.      *
 *                                                                            *
 ******************************************************************************/

#ifndef HUNGER_H
#define HUNGER_H

#include <QObject>
#include <QSettings>
#include <QString>
#include <QVariant>
#include <QVariantList>
#include <queue>
#include <list>
#include <time.h>

struct history {
    float data;
    time_t time;
};

long get_bat_cur();

long get_bat_full();

long get_u();

long get_i();

long get_power();

class Hunger : public QObject{
    Q_OBJECT
public:
    std::list<history> hist;
    explicit Hunger(QObject* parent = 0) : QObject(parent) {}
    ~Hunger() {}
    Q_INVOKABLE void refresh(int limit);
    Q_INVOKABLE QString avg_text(int number);
    Q_INVOKABLE QString bat_cur();
    Q_INVOKABLE QString bat_cur_pr();
    Q_INVOKABLE float bat_cur_pr_val();
    Q_INVOKABLE bool charging();
    Q_INVOKABLE QString bat_full();
    Q_INVOKABLE QString tme_left();
    Q_INVOKABLE QVariantList graph(int number);
};

class Settings : public QObject {
    Q_OBJECT
public:
    explicit Settings(QObject *parent = 0);
    Q_INVOKABLE void setValue(const QString & key, const QVariant & value);
    Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;
private:
    QSettings settings_;
};


#endif // HUNGER_H
