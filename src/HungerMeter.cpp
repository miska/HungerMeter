#include <QtQuick>
#include <sailfishapp.h>
#include <stdio.h>
#include <time.h>

#include "hunger.h"

void Hunger::refresh() {
    FILE *I, *U;
    long u,i;
    history p;

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

    hist.push_back(p);
    while((p.time - hist.begin()->time) > CACHE_SIZE)
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
        for(auto i = hist.rbegin(); (i != hist.rend()) && ((t - i->time) < limit); i++, j++) {
            value += i->data;
        }
        if(j>0)
            value /= j;
    }

    sprintf(buff,"%.4f W", value);
    return QString(buff);
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qmlRegisterType<Hunger>("Hunger", 1, 0, "Hunger");

    return SailfishApp::main(argc, argv);
}

