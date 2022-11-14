#ifndef CONTROLLER_CARTHING_H
#define CONTROLLER_CARTHING_H

#include <sys/time.h>

#include "controller_api.h"

struct input_event {
    struct timeval time;
    unsigned short type;
    unsigned short code;
    unsigned int value;
};

extern struct ControllerAPI controller_carthing;

#endif
