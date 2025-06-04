#include "sched.h"
#include <linux/random.h>
#include <linux/sched/lottery.h>

void init_lottery_rq(struct lottery_rq *lrq)
{
    INIT_LIST_HEAD(&lrq->queue);
    lrq->total_tickets = 0;
}

void __init init_sched_lottery_class(void)
{
	unsigned int i;

	for_each_possible_cpu(i) {
		init_lottery_rq(&cpu_rq(i)->lottery);
	}
}

static void enqueue_task_lottery(struct rq *rq, struct task_struct *p, int flags)
{
    struct lottery_rq *lrq = &rq->lottery;
    list_add_tail(&p->se.group_node, &lrq->queue);
    lrq->total_tickets += p->lottery.tickets;
}

static void dequeue_task_lottery(struct rq *rq, struct task_struct *p, int flags)
{
    struct lottery_rq *lrq = &rq->lottery;
    list_del_init(&p->se.group_node);
    lrq->total_tickets -= p->lottery.tickets;
}

static struct task_struct *pick_next_task_lottery(struct rq *rq)
{
    struct lottery_rq *lrq = &rq->lottery;
    if (list_empty(&lrq->queue))
        return NULL;

    u32 ticket = get_random_u32() % lrq->total_tickets;
    int acc = 0;
    struct task_struct *p;

    list_for_each_entry(p, &lrq->queue, se.group_node) {
        acc += p->lottery.tickets;
        if (acc > ticket)
            return p;
    }
    return NULL;
}

static void task_tick_lottery(struct rq *rq, struct task_struct *p, int queued)
{
    resched_curr(rq);
}

static void update_curr_lottery(struct rq *rq)
{
    struct task_struct *curr = rq->curr;
    u64 delta_exec = rq_clock_task(rq) - curr->se.exec_start;

    curr->se.sum_exec_runtime += delta_exec;
    curr->se.exec_start = rq_clock_task(rq);
}

DEFINE_SCHED_CLASS(lottery) = {
    .enqueue_task   = enqueue_task_lottery,
    .dequeue_task   = dequeue_task_lottery,
    .pick_next_task = pick_next_task_lottery,
    .task_tick      = task_tick_lottery,
    .update_curr    = update_curr_lottery,
};
