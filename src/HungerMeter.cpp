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

#include <QtQuick>
#include <QVariant>
#include <QVariantList>
#include <QObject>
#include <QSettings>
#include <sailfishapp.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "hunger.h"

QString format_str(long ret, const char* unit = "mW") {
    static char buff[16];
    if(ret == ERR_VAL) {
        sprintf(buff,"----- %s", unit);
    } else if(abs(ret)>1000)
        sprintf(buff,"%ld %03d %s", ret/1000, abs(ret%1000), unit);
    else
        sprintf(buff,"%ld %s", ret, unit);
    return QString(buff);
}

long Hunger::tme_left_data() {
    long value = 0;

    if(get_charging()>0) {
        value = avg_val(5);
        if(value > 0)
            value = avg_val(1);
    } else {
        value = get_long_avg();
        if((value == ERR_VAL) || (value == 0))
            value = avg_val(-1);
    }

    if(value == ERR_VAL)
        return value;

    if(value > 0) {
        value = (get_bat_cur() * 3600)/value;
    } else if(value < 0) {
        value = ((get_bat_full() - get_bat_cur()) * 3600)/abs(value);
    }

    return value;
}

QString Hunger::tme_left_short() {
    long value = tme_left_data();
    char buff[8];

    if(value == ERR_VAL) {
        return "-----";
    }

    value = value/60;

    if(value == 0 || value > 60*24*31)
        return "∞";

    if(value > 60*72) {
        value /= 60;
        return tr("%1 day(s)", 0,value/24).arg(value/24);
    } else {
        sprintf(buff,"%02ld:%02ld",value/60,value%60);
        return buff;
    }

}

QString Hunger::tme_left() {
    long value = tme_left_data();

    if(value == ERR_VAL) {
        return tr("Estimating...");
    }

    value = value/60;

    if(value == 0 || value > 60*24*31)
        return tr("Eternity");

    if(value>60)
        if(value>60*24) {
            value /= 60;
            return (tr("%1 day(s)", 0,value/24).arg(value/24)) + ((value%24 == 0)?"":(tr(" and ")+tr("%2 hour(s)",  0,value%24)).arg(value%24));
        } else
            return (tr("%1 hour(s)",0,value/60).arg(value/60)) + ((value%60 == 0)?"":(tr(" and ")+tr("%2 minute(s)",0,value%60)).arg(value%60));
    else
        return tr("%1 minute(s)",0,value).arg(value);
}

QString Hunger::bat_cur() {
    return format_str(get_bat_cur(), "mWh");
}

QString Hunger::bat_full() {
    return format_str(get_bat_full(), "mWh");
}

float Hunger::bat_cur_pr_val() {
    long full = get_bat_full();
    long cur = get_bat_cur()*100;
    if(full != 0) {
        return std::min((float)100.0,((float)cur)/((float)full));
    } else {
        return 0.0;
    }
}

QString Hunger::bat_cur_pr() {
    char buff[16];
    float pr = bat_cur_pr_val();
    sprintf(buff,"%.2f %%", pr);
    return buff;
}

void Hunger::refresh(int limit) {
    history p;
    static int j;

    p.data = get_power();
    p.time = time(NULL);

    if(p.data != ERR_VAL) {
        if(hist.empty() || hist.back().time != p.time) {
            hist.push_back(p);
            j=1;
        } else {
            hist.back().data = ((hist.back().data * j) + p.data) / (j+1);
            j++;
        }
    }

    while((p.time - hist.begin()->time) > (limit+2))
        hist.pop_front();
}

int Hunger::charging() {
    return get_charging();
}

long Hunger::avg_val(int limit = 10) {
    long value = 0;
    int j = 0;
    time_t t = time(NULL);
    if(hist.rbegin()->time != t)
        t--;

    if(!hist.empty()) {
        for(auto i = hist.rbegin(); (i != hist.rend()) && (((t - i->time) < limit) || (limit < 0) ); i++) {
            j++;
            value += i->data;
        }
    }

    if(j<1)
        return ERR_VAL;

    return value/std::max(j,1);
}


QString Hunger::avg_text(int limit = 10) {
    return format_str(avg_val(limit), "mW");
}

QString Hunger::long_text() {
    return format_str(get_long_avg(),"mW");
}

QVariantList Hunger::graph(int limit) {
    QVariantList ret;
    time_t t = time(NULL);
    time_t l_t;

    l_t = t;
    if(!hist.empty()) {
        auto i = hist.rbegin();
        if(i->time == l_t)
            i++;
        t--;
        l_t--;
        for(l_t = t; (i != hist.rend()) && ((t - l_t) < limit); i++) {
            l_t = i->time;
            QVariantList val;
            val.push_back(((double)i->data)/1000.0);
            val.push_back((double)l_t);
            ret.push_back(val);
        }
    }
    return ret;
}

Settings::Settings(QObject *parent): QObject(parent) {}

void Settings::setValue(const QString & key, const QVariant & value) {
    settings_.setValue(key, value);
}

QVariant Settings::value(const QString &key, const QVariant &defaultValue) const {
    return settings_.value(key, defaultValue);
}

Q_DECL_EXPORT int main(int argc, char *argv[]) {
    qmlRegisterType<Hunger>("harbour.hungermeter.hunger", 1, 0, "Hunger");
    qmlRegisterType<Settings>("harbour.hungermeter.settings", 1, 0, "Settings");

    return SailfishApp::main(argc, argv);
}

