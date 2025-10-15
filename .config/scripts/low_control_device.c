// grab_input.c
#define _GNU_SOURCE
#include <linux/input.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <poll.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>

static int g_fd = -1;
static const char *progname = "grab_input";

/* cleanup: зняти grab і закрити fd */
static void cleanup(void) {
    if (g_fd >= 0) {
        if (ioctl(g_fd, EVIOCGRAB, 0) < 0) {
            fprintf(stderr, "%s: EVIOCGRAB(0) failed: %s\n", progname, strerror(errno));
        } else {
            fprintf(stderr, "%s: EVIOCGRAB released\n", progname);
        }
        close(g_fd);
        g_fd = -1;
    }
}

/* signal handler для аварійного виходу */
static void handle_sig(int sig) {
    (void)sig;
    fprintf(stderr, "\n%s: signal received, exiting...\n", progname);
    cleanup();
    _exit(0); /* викликаємо _exit щоб гарантовано завершитись */
}

/* human-readable timestamp */
static void print_time(const struct input_event *ev) {
    struct tm tm;
    time_t secs = ev->time.tv_sec;
    localtime_r(&secs, &tm);
    char buf[64];
    strftime(buf, sizeof(buf), "%F %T", &tm);
    printf("%s.%06ld ", buf, (long)ev->time.tv_usec);
}

/* простий інтерпретатор типів/кодів для читабельності */
static void print_event(const struct input_event *ev) {
    print_time(ev);
    printf("type=0x%04x (%u) ", ev->type, ev->type);

    switch (ev->type) {
        case EV_KEY:
            printf("EV_KEY code=%u value=%d", ev->code, ev->value);
            /* value: 0 = release, 1 = press, 2 = autorepeat */
            if (ev->value == 0) printf(" (RELEASE)");
            else if (ev->value == 1) printf(" (PRESS)");
            else if (ev->value == 2) printf(" (REPEAT)");
            break;
        case EV_REL:
            printf("EV_REL code=%u value=%d", ev->code, ev->value);
            break;
        case EV_ABS:
            printf("EV_ABS code=%u value=%d", ev->code, ev->value);
            break;
        case EV_SW:
            printf("EV_SW code=%u value=%d", ev->code, ev->value);
            if (ev->code == SW_LID) {
                if (ev->value == 0) printf(" (LID OPEN)");
                else if (ev->value == 1) printf(" (LID CLOSED)");
                else printf(" (LID: %d)", ev->value);
            }
            break;
        case EV_MSC:
            printf("EV_MSC code=%u value=%d", ev->code, ev->value);
            break;
        case EV_SYN:
            printf("EV_SYN code=%u value=%d", ev->code, ev->value);
            break;
        default:
            printf("OTHER code=%u value=%d", ev->code, ev->value);
            break;
    }

    printf("\n");
}

int main(int argc, char **argv) {
    const char *device = NULL;
    if (argc < 2) {
        fprintf(stderr, "Usage: %s /dev/input/eventX\n", progname);
        return 2;
    }
    device = argv[1];

    /* обробка сигналів для коректного ungrab */
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = handle_sig;
    sigaction(SIGINT, &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);
    sigaction(SIGHUP, &sa, NULL);

    g_fd = open(device, O_RDONLY | O_NONBLOCK);
    if (g_fd < 0) {
        perror("open");
        return 1;
    }

    /* опціонально: дізнаємось ім'я пристрою */
    char name[256] = "Unknown";
    if (ioctl(g_fd, EVIOCGNAME(sizeof(name)), name) < 0) {
        /* ignore error */
    }
    printf("%s: opened %s (%s)\n", progname, device, name);

    /* встановлюємо grab (ексклюзивне перехоплення) */
    if (ioctl(g_fd, EVIOCGRAB, 1) < 0) {
        perror("EVIOCGRAB(1)");
        close(g_fd);
        g_fd = -1;
        return 1;
    }
    printf("%s: EVIOCGRAB set. Press Ctrl+C to exit.\n", progname);

    struct pollfd pfd;
    pfd.fd = g_fd;
    pfd.events = POLLIN;

    /* читаємо події поки не отримаємо сигнал */
    while (1) {
        int rv = poll(&pfd, 1, 500); /* timeout 500ms, щоб періодично перевіряти сигнали */
        if (rv < 0) {
            if (errno == EINTR) continue; /* сигнал — перевіримо ще раз */
            perror("poll");
            break;
        } else if (rv == 0) {
            /* timeout — нічого не робимо, повторюємо */
            continue;
        }

        if (pfd.revents & POLLIN) {
            struct input_event ev;
            ssize_t n = read(g_fd, &ev, sizeof(ev));
            if (n == (ssize_t)sizeof(ev)) {
                print_event(&ev);
            } else if (n < 0) {
                if (errno == EAGAIN || errno == EWOULDBLOCK) {
                    continue;
                }
                perror("read");
                break;
            } else {
                fprintf(stderr, "%s: short read (%zd bytes)\n", progname, n);
                break;
            }
        } else if (pfd.revents & (POLLERR | POLLHUP | POLLNVAL)) {
            fprintf(stderr, "%s: poll revents=0x%x\n", progname, pfd.revents);
            break;
        }
    }

    cleanup();
    return 0;
}
