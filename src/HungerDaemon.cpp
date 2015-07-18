#include <QtSql/QtSql>
#include <unistd.h>
#include <time.h>
#include "hunger.h"

QSqlDatabase db;

QSettings* set = NULL;

bool updated = false;
QDateTime last = QDateTime::fromTime_t(0);

void close_db() {
    db.close();
}

bool init_db() {
   static bool first_init = true;
   static bool persistent = false;
   static QString DATAPATH;

   // Init on first call as we need appname initialized
   if(set == NULL)
       set = new QSettings();

   // Check whether storage changed
   if(persistent != (set->value("persistent", false).toInt() > 0)) {
      if(db.isOpen()) {
         close_db();
         first_init = true;
      }
      persistent =  (set->value("persistent", false).toInt() > 0);
   }

   // Anything to do?
  if(db.isOpen()) {
     return true;
   }

   if(first_init) {
   // Set parsistent/temporal path
   if(persistent) {
       DATAPATH = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
   } else {
       DATAPATH = QStandardPaths::writableLocation(QStandardPaths::TempLocation) + QDir::separator() + "harbour-hungermeter";
   }

   // Make datadir
   QDir home(QDir::homePath());
   home.mkpath(DATAPATH);
   QDir dir(DATAPATH);

   // Open database
   QString db_name = DATAPATH + QDir::separator() + "measurements.sqlite";
   static QString DB = "QSQLITE";
   static QString CONN_STR = "main_connection";
   if(db.driverName() != DB)
      db = QSqlDatabase::addDatabase(DB, CONN_STR);
   db.setDatabaseName(db_name);
   }

   if(!db.isOpen()) {
       db.open();
   }

   if(!db.isOpen()) {
      usleep(100);
      if(!db.open()) {
         printf("Can't open DB\n");
         close_db();
         return false;
      }
   }

   // Make sure it exists and is correctly setup
   if(first_init) {
   QSqlQuery query(db);
   query.exec("CREATE TABLE data "
              "(time DATE PRIMARY KEY, energy BIGINT, state SMALLINT, uptime BIGINT);");
   }
   first_init = false;
   return true;
}

void noop() {

}

void save_data() {
   static bool first_run = true;
   static int cleanup_time = 0;
   int wait_time;

   if(!init_db())
      return;

   wait_time = set->value("long_time", 5).toInt() * 60;

   {
   QSqlQuery query(db);
   QString sql;

   // Should we do something?
   if((last.secsTo(QDateTime::currentDateTime()) < wait_time) && (!first_run))
      goto save_end;

   // Are we sure?
   if(query.exec(QString("SELECT time ORDER BY time DESC LIMIT 1;")) && query.size() > 0 &&
      query.value(0).toDateTime().secsTo(QDateTime::currentDateTime()) < wait_time)
         goto save_end;

   // Insert data
   sql = QString("INSERT INTO data VALUES('%1',%2,%3,%4);")
                    .arg(QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss"))
                    .arg(get_bat_cur()).arg(get_charging()).arg(get_uptime());

   if(!query.exec(sql))
      printf("Err: %s\n", query.lastError().text().toStdString().c_str());

   // Clean old records
   if(cleanup_time++ > 10) {
       int long_avg = set->value("long_avg",   24).toInt();
       sql = QString("DELETE FROM data WHERE time < '%1';").arg(QDateTime::currentDateTime().addSecs(-long_avg * 3600).toString("yyyy-MM-dd HH:mm:ss"));
       if(!query.exec(sql))
           printf("Err: %s\n", query.lastError().text().toStdString().c_str());
       else
           cleanup_time = 0;
   }

   // Final settings
   updated = true;
   last = QDateTime::currentDateTime();
   first_run = false;

save_end:
   noop();
   }
   close_db();

   return;
}

int get_long_avg() {
    static long last_avg = ERR_VAL;

    if(!init_db())
       return ERR_VAL;

    int long_avg = set->value("long_avg",   24).toInt();

    if((!updated) && (last_avg != ERR_VAL))
        return last_avg;

    {
    QSqlQuery query(db);
    
    if(query.exec(QString("SELECT time,energy,state FROM data WHERE time > '%1' ORDER BY time ASC;").arg(QDateTime::currentDateTime().addSecs(-long_avg * 3600).toString("yyyy-MM-dd HH:mm:ss"))))
    {
        QDateTime now_t, last_t;
        long time_in = 0;
        int now_e, last_e = -1;
        long e_in = 0;
        int state = 0;

        while(query.next())
        {
            now_t = query.value(0).toDateTime();
            now_e = query.value(1).toInt();
            state = query.value(2).toInt();
            if((last_e >= now_e) && (state<0)) {
                time_in += abs(last_t.secsTo(now_t));
                e_in    += abs(last_e - now_e);
            }
            last_e = now_e;
            last_t = now_t;
        }
        updated = false;
        if(time_in > 100) {
            last_avg = (e_in*36)/(time_in/100);
        }
    } else {
        printf("Err: %s\n", query.lastError().text().toStdString().c_str());
    }
    }
    updated = true;
    close_db();
    return last_avg;
}

QVariantList get_long_graph_data() {
    static QVariantList ret;
    int long_avg = set->value("long_avg",   24).toInt();
    static QDateTime last_t = QDateTime::currentDateTime().addSecs(-long_avg * 3600);
    if(!init_db() || last_t >= last) {
        return ret;
    }
    time_t now_t;
    int now_e;

    {
    QSqlQuery query(db);

    if(query.exec(QString("SELECT time,energy,state FROM data WHERE time > '%1' ORDER BY time ASC;").arg(last_t.toString("yyyy-MM-dd HH:mm:ss")))) {
        while(query.next()) {
            QVariantList tmp;
            last_t = query.value(0).toDateTime();
            now_t = last_t.toTime_t();
            now_e = query.value(1).toInt();
            tmp.push_back(((double)now_e)/1000.0);
            tmp.push_back((double)now_t);
            ret.push_front(tmp);
        }
    } else {
        printf("Err: %s\n", query.lastError().text().toStdString().c_str());
    }
    }
    close_db();
    while(ret.back().toList()[1].toDouble() < last_t.addSecs(-long_avg * 3600).toTime_t())
        ret.pop_back();
    return ret;
}
