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
#include <QDebug>
#include <stdio.h>

QString bat_path;
bool fallback = false;

void init_bat_path() {
   if(!bat_path.isEmpty()) return;
   QDir pdir("/sys/class/power_supply/");
   QDir dir;

   foreach(QString entry, pdir.entryList()) {
      dir = pdir;
      dir.cd(entry);
      if(dir.exists("energy_now") || dir.exists("charge_now") || dir.exists("capacity")) {
         bat_path = dir.absolutePath();
         return;
      }
   }
}

long get_data(QString file, bool micro) {
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
   if(micro) {
       return ret / 1000;
   } else {
       return ret;
   }
}

long get_bat_full() {
   static long ret = ERR_VAL;
   if(ret != ERR_VAL && ret != 0)
      return ret;
   ret = get_data("energy_full");
   if(ret == ERR_VAL) {
      // Ugly hack for JollaC
      FILE *F;
      F = fopen("/sys/class/power_supply/bms/battery_type","r");
      if(F == NULL)
          return ERR_VAL;
      char buff[256];
      memset(buff, 0, sizeof(char) * 256);
      fgets(buff, 255, F);
      fclose(F);
      if(strstr(buff,"qrd_skue_4v35_2500mah") != NULL) {
          return 435 * 25;
      } else {
          return ERR_VAL;
      }
   }
   if(ret > 200000)
      ret = ret / 1000;
   return ret;
}

long get_bat_cur() {
   long ret = get_data("energy_now");
   if(ret == ERR_VAL) {
      long tmp;
      if(!fallback &&
         ((ret = get_data("charge_now")) != ERR_VAL) &&
         ((tmp = get_data("voltage_now")) != ERR_VAL)) {
         ret = ret * (tmp / 1000);
      } else {
         ret = get_bat_full();
         tmp = get_data("capacity", false);
         if(ret == ERR_VAL || tmp == ERR_VAL)
            return ERR_VAL;
         ret = (ret * tmp) / 100;
      }
   }
   return ret;
}

long get_uptime() {
    long ret=ERR_VAL;
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
