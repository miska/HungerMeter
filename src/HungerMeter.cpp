#include <QtQuick>
#include <sailfishapp.h>
#include <stdio.h>
#include <time.h>

#include "hunger.h"

void Hunger::refresh() {
    FILE *I, *U;
    long u,i;
    double p = -0.0;

    I = fopen("/sys/class/power_supply/battery/current_now","r");
    if(I == NULL) return;
    U = fopen("/sys/class/power_supply/battery/voltage_now","r");
    if(I == NULL) goto close_i;

    // uV
    if(fscanf(U, "%ld", &u) != 1) goto close;
    // uA
    if(fscanf(I, "%ld", &i) != 1) goto close;
    // W
    p = (((double)u)/1000000)*(((double)i)/1000000);

    hist.push_back(p);
    if(hist.size() > CACHE_SIZE)
        hist.pop_front();
close:
    fclose(U);
close_i:
    fclose(I);
}

QString Hunger::current_text(int limit = 10) {
    static char buff[128];
    double value = 0.0;
    int j = 0;

    if(!hist.empty()) {
        for(auto i = hist.rbegin(); (i != hist.rend()) && (j < limit); i++,j++) {
            value += (*i);
        }
        if(j>0)
            value /= j;
    }

    sprintf(buff,"%.4lf W", value);
    return QString(buff);
}

QString Hunger::avg_text() {
    static char buff[128];
    double value = 0.0;

    if(! hist.empty()) {
        for(auto i : hist) {
            value += i;
        }
        value /= hist.size();
    }

    sprintf(buff,"%.4lf W", value);
    return QString(buff);
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qmlRegisterType<Hunger>("Hunger", 1, 0, "Hunger");

    return SailfishApp::main(argc, argv);
}

