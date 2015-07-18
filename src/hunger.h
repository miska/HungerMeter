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

#define ERR_VAL -99999

struct history {
    int data;
    time_t time;
};

void save_data();

long get_bat_cur();

long get_bat_full();

long get_u();

long get_i();

long get_uptime();

int get_charging();

int get_long_avg();

long get_power();

QVariantList get_long_graph_data();

class Hunger : public QObject{
    Q_OBJECT
private:
    long tme_left_data();
public:
    std::list<history> hist;
    explicit Hunger(QObject* parent = 0) : QObject(parent) {}
    ~Hunger() {}
    Q_INVOKABLE void refresh(int limit);
    Q_INVOKABLE void long_iter() { save_data(); }
    Q_INVOKABLE QString avg_text(int number);
    Q_INVOKABLE long avg_val(int number);
    Q_INVOKABLE QString long_text();
    Q_INVOKABLE QString bat_cur();
    Q_INVOKABLE QString bat_cur_pr();
    Q_INVOKABLE float bat_cur_pr_val();
    Q_INVOKABLE int charging();
    Q_INVOKABLE QString bat_full();
    Q_INVOKABLE QString tme_left();
    Q_INVOKABLE QString tme_left_short();
    Q_INVOKABLE QVariantList graph(int number);
    Q_INVOKABLE QVariantList long_graph(int number);
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
