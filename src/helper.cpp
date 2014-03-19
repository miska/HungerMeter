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

#include "hunger.h"

#include <sys/types.h>
#include <dirent.h>
#include <QString>
#include <QDir>
#include <stdio.h>

QString bat_path;

void init_bat_path() {
   if(!bat_path.isEmpty()) return;
   QDir pdir("/sys/class/power_supply/");
   QDir dir;

   foreach(QString entry, pdir.entryList()) {
      dir = pdir;
      dir.cd(entry);
      if(dir.exists("energy_now")) {
         bat_path = dir.absolutePath();
         return;
      }
   }
}

long get_data(QString file) {
   FILE *F;
   long ret = ERR_VAL;
   init_bat_path();
   F = fopen((bat_path+"/"+file).toLatin1().data(),"r");
   if(F != NULL) {
      if(fscanf(F, "%ld", &ret) != 1)
         return ERR_VAL;
      fclose(F);
   } else {
       return ERR_VAL;
   }
   return ret/1000;
}

long get_bat_cur() {
   return get_data("energy_now");
}

long get_uptime() {
    long ret=0;
    char tmp='0';
    FILE* F;

    F = fopen("/proc/uptime", "r");
    if(F != NULL) {
        while(isdigit(tmp = fgetc(F))) {
            ret = ret*10 + tmp - '0';
        }
        fclose(F);
    }
    return ret;
}

long get_bat_full() {
   return get_data("energy_full");
}

long get_u() {
   return get_data("voltage_now");
}

int get_charging() {
    FILE *F;
    char buff[4];
    init_bat_path();
    F = fopen((bat_path+"/status").toLatin1().data(),"r");
    if(F != NULL) {
       if(!fread(buff, 4, 1, F))
          return 0;
       fclose(F);
    } else {
        return 0;
    }
    if(strncmp(buff,"Discharging",4) == 0)
        return -1;
    if(strncmp(buff,"Charging",4) == 0)
        return 1;
    return 0;
}

long get_i() {
   return get_data("current_now");
}

long get_power() {
   long ret = get_data("power_now");
   if(ret == ERR_VAL) {
      long u = get_u();
      long i = get_i();
      if((u == ERR_VAL) || (i == ERR_VAL))
          return ERR_VAL;
      ret = (u * i)/1000;

   }
   return ret;
}
