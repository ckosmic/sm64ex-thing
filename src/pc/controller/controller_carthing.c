#include <stdio.h>
#include <ultra64.h>
#include <fcntl.h>
#include <unistd.h>

#include "controller_api.h"
#include "controller_carthing.h"

static FILE *fd_gpio;
static FILE *fd_rotary;

char buf_gpio[256];
char buf_rotary[256];

u16 buttons[20];
char stick[2];

static void carthing_init(void) {
    fd_gpio = open("/dev/input/event0", O_RDWR | O_NOCTTY | O_NDELAY);
    if (fd_gpio == -1) {
        // Error opening gpio input
    }
    fd_rotary = open("/dev/input/event1", O_RDWR | O_NOCTTY | O_NDELAY);
    if (fd_rotary == -1) {
        // Error opening rotary input
    }

    stick[0] = 128;
    stick[1] = 128;

    fcntl(fd_gpio, F_SETFL, fcntl(fd_gpio, F_GETFL, 0) | O_NONBLOCK);
    fcntl(fd_rotary, F_SETFL, fcntl(fd_rotary, F_GETFL, 0) | O_NONBLOCK);
}

static void carthing_read(OSContPad *pad) {
    u32 buttons_down = 0;
    if (fd_gpio != -1) {
        int n = read(fd_gpio, (void*)buf_gpio, 255);
        if (n > 0) {
            struct input_event *gpio = (struct input_event*)buf_gpio;
            //printf("GPIO code: %d, value: %d\n", gpio->code, gpio->value);
            switch (gpio->code) {
                case 1:
                    buttons[0] = gpio->value ? START_BUTTON : 0;
                    break;
                case 2:
                    stick[0] = gpio->value ? 255 : 128;
                    break;
                case 3:
                    stick[0] = gpio->value ? 0 : 128;
                    break;
                case 4:
                    buttons[4] = gpio->value ? R_TRIG : 0;
                    break;
                case 5:
                    buttons[1] = gpio->value ? B_BUTTON : 0;
                    break;
                case 28:
                    buttons[2] = gpio->value ? A_BUTTON : 0;
                    break;
                case 50:
                    buttons[3] = gpio->value ? Z_TRIG : 0;
                    break;
            }
        }
    }
    
    for (int i = 0; i < sizeof(buttons) / sizeof(u16); i++) {
        if (buttons[i] > 0) {
            buttons_down |= buttons[i];
        }
    }
    if (fd_rotary != -1) {
        int n = read(fd_rotary, (void*)buf_rotary, 255);
        if (n > 0) {
            struct input_event *rotary = (struct input_event*)buf_rotary;
            //printf("ROTARY code: %d, value: %d\n", rotary->code, rotary->value);
            switch (rotary->code) {
                case 6:
                    pad->stick_x = rotary->value == 1 ? 127 : -128;
                    break;
            }
        }
    }
    pad->stick_y = stick[0] - 128;
    pad->button |= buttons_down;
}

static void carthing_shutdown(void) {
    if (fd_gpio != -1) {
        close(fd_gpio);
        fd_gpio = NULL;
    }
    if (fd_rotary != -1) {
        close(fd_rotary);
        fd_rotary = NULL;
    }
}

static u32 carthing_rawkey(void) {
    return VK_INVALID;
}

struct ControllerAPI controller_carthing = {
    VK_INVALID,
    carthing_init,
    carthing_read,
    carthing_rawkey,
    NULL, // no rumble_play
    NULL, // no rumble_stop
    NULL, // no rebinding
    carthing_shutdown
};
