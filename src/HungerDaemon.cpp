#include <QtSql/QtSql>
#include <unistd.h>
#include <time.h>
#include "hunger.h"

QSqlDatabase db;

QSettings* set = NULL;

bool updated = false;
bool persistent = false;

bool init_db() {

   static QString DATAPATH;

   // Init on first call as we need appname initialized
   if(set == NULL)
       set = new QSettings();

   // Check whether storage changed
   if(persistent != (set->value("persistent", false).toInt() > 0)) {
      if(db.isOpen())
         db.close();
      persistent =  (set->value("persistent", false).toInt() > 0);
   }

   // Anything to do?
   if(db.isOpen())
      return true;

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
   db = QSqlDatabase::addDatabase("QSQLITE");
   db.setDatabaseName(db_name);
   if(!db.open())
      return false;

   // Make sure it exists and is correctly setup
   QSqlQuery query(db);
   query.exec("CREATE TABLE data "
              "(time DATE PRIMARY KEY, energy BIGINT, state SMALLINT, uptime BIGINT);");
   return true;
}

void save_data() {
   static bool first_run = true;
   static int cleanup_time = 0;
   static QDateTime last = QDateTime::fromTime_t(0);
   int wait_time;

   if(!init_db())
      return;

   wait_time = set->value("long_time", 5).toInt() * 60;

   // Should we do something?
   if((last.secsTo(QDateTime::currentDateTime()) < wait_time) && (!first_run))
      return;

   // Insert data
   QString sql = QString("INSERT INTO data VALUES('%1',%2,%3,%4);")
                    .arg(QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss"))
                    .arg(get_bat_cur()).arg(get_charging()).arg(get_uptime());

   QSqlQuery query(db);
   if(!query.exec(sql))
      printf("Err: %s\n", query.lastError().text().toStdString().c_str());

   // Clean old records
   if(cleanup_time++ > 5) {
       int long_avg = set->value("long_avg",   24).toInt();
       sql = QString("DELETE FROM data WHERE time < '%1';").arg(QDateTime::currentDateTime().addSecs(-long_avg * 3600).toString("yyyy-MM-dd HH:mm:ss"));
       if(!query.exec(sql))
           printf("Err: %s\n", query.lastError().text().toStdString().c_str());
   }

   // Final settings
   updated = true;
   last = QDateTime::currentDateTime();
   first_run = false;
}

void close_db() {
   db.close();
   exit(0);
}

void hunger_long_iter() {
    save_data();
}


int get_long_avg() {
    static long last_avg = ERR_VAL;

    if(!init_db())
       return ERR_VAL;

    int long_avg = set->value("long_avg",   24).toInt();

    if((!updated) && (last_avg != ERR_VAL))
        return last_avg;

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
        if(time_in > 100)
            return last_avg = (e_in*36)/(time_in/100);
    } else {
        printf("Err: %s\n", query.lastError().text().toStdString().c_str());
    }
    updated = true;
    return ERR_VAL;
}
