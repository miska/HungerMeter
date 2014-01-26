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
#include <sailfishapp.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "hunger.h"

long get_bat_cur() {
    FILE *F;
    long ret = 0;
    F = fopen("/sys/class/power_supply/battery/energy_now","r");
    if(F != NULL) {
        if(fscanf(F, "%ld", &ret) != 1)
            ret = 0;
        fclose(F);
        ret = ret / 1000;
    }
    return ret;
}

long get_bat_full() {
    FILE *F;
    static long ret = 0;
    if(ret!=0) return ret;
    F = fopen("/sys/class/power_supply/battery/energy_full","r");
    if(F != NULL) {
        if(fscanf(F, "%ld", &ret) != 1)
            ret = 0;
        fclose(F);
        ret = ret / 1000;
    }
    return ret;
}

QString Hunger::tme_left() {
    // mWs
    int res = -1;
    int j = 0;
    float value = 0.0;
    char buff[32];

    if(!hist.empty()) {
        for(auto i = hist.rbegin(); (i != hist.rend()); i++) {
            j++;
            value += i->data;
        }
        value = value / (float)j;
    }
    if(value > 0.01) {
        value = (((float)get_bat_cur()) * 3.6)/value;
    } else if(value < -0.01) {
        value = (((float)abs(get_bat_full() - get_bat_cur())) * 3.6)/abs(value);
    } else {
        value=-120.0;
    }
    res = round(value/60.0);
    if((res>=0) && (res<6000)) {
        if(res>60)
            sprintf(buff,"%d hours and %d minutes",res/60, (res%60));
        else
            sprintf(buff,"%d minutes", (res%60));
    } else {
        sprintf(buff,"Estimating...");
    }
    return buff;
}

QString Hunger::bat_cur() {
    long ret = get_bat_cur();
    char buff[16];
    if(ret>1000)
        sprintf(buff,"%ld %ld mWh", ret/1000, ret%1000);
    else
        sprintf(buff,"%ld mWh", ret);
    return buff;
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

QString Hunger::bat_full() {
    long ret = get_bat_full();
    char buff[16];
    if(ret>1000)
        sprintf(buff,"%ld %ld mWh", ret/1000, ret%1000);
    else
        sprintf(buff,"%ld mWh", ret);
    return buff;
}

void Hunger::refresh(int limit) {
    FILE *I, *U;
    long u,i;
    history p;
    static int j;

    I = fopen("/sys/class/power_supply/battery/current_now","r");
    if(I == NULL) return;
    U = fopen("/sys/class/power_supply/battery/voltage_now","r");
    if(I == NULL) goto close_i;

    // uV
    if(fscanf(U, "%ld", &u) != 1) goto close;
    // uA
    if(fscanf(I, "%ld", &i) != 1) goto close;
    // W
    p.data = (((double)u)/1000000)*(((double)i)/1000000);
    p.time = time(NULL);

    if(hist.empty() || hist.back().time != p.time) {
        hist.push_back(p);
        j=1;
    } else {
        hist.back().data = (hist.back().data * ((float)j) + p.data) / ((float)(j+1));
        j++;
    }

    while((p.time - hist.begin()->time) > (limit+2))
        hist.pop_front();
close:
    fclose(U);
close_i:
    fclose(I);
}

QString Hunger::avg_text(int limit = 10) {
    static char buff[128];
    float value = 0.0;
    int j = 0;
    time_t t = time(NULL);
    if(hist.rbegin()->time != t)
        t--;

    if(!hist.empty()) {
        for(auto i = hist.rbegin(); (i != hist.rend()) && ((t - i->time) < limit); i++) {
            j++;
            value += i->data;
        }
    }

    sprintf(buff,"%.4f W", value/((float)std::max(j,1)));
    return QString(buff);
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
            ret.push_front(i->data);
        }
    }

    while(t-l_t < limit) {
        ret.push_front(0.0);
        l_t --;
    }
    return ret;
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qmlRegisterType<Hunger>("harbour.hungermeter.hunger", 1, 0, "Hunger");

    return SailfishApp::main(argc, argv);
}

