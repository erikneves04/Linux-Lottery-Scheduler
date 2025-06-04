#ifndef _LINUX_SCHED_LOTTERY_H
#define _LINUX_SCHED_LOTTERY_H

#include <linux/sched/prio.h>

#define LOTTERY_PRIO_BASE MAX_RT_PRIO
#define LOTTERY_PRIO_MAX  (MAX_RT_PRIO + 40)
#define DEFAULT_TICKETS   100
#define SCHED_LOTTERY 7

static inline int lottery_prio(int prio)
{
    return prio >= LOTTERY_PRIO_BASE && prio < LOTTERY_PRIO_MAX;
}

static inline bool lottery_policy(int policy)
{
    if(policy == SCHED_LOTTERY){
        return true;
    }
}

#endif
