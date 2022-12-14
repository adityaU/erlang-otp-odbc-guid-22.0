/*
 *  Warning: Do not edit this file.  It was automatically
 *  generated by 'make_tables' on Fri Aug 19 02:15:55 2022.
 */

#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif /* HAVE_CONFIG_H */
#include "erl_process.h"
#include "erl_nfunc_sched.h"
#include "erl_bif_table.h"
#include "erl_atom_table.h"

Eterm schedule_dirty_cpu_erts_debug_dirty_cpu_2(Process *c_p, Eterm *regs, BeamInstr *I)
{
    return erts_reschedule_bif(c_p, regs, I, erts_debug_dirty_cpu_2, ERTS_SCHED_DIRTY_CPU);
}

Eterm schedule_dirty_io_erts_debug_dirty_io_2(Process *c_p, Eterm *regs, BeamInstr *I)
{
    return erts_reschedule_bif(c_p, regs, I, erts_debug_dirty_io_2, ERTS_SCHED_DIRTY_IO);
}

Eterm schedule_dirty_cpu_erts_debug_lcnt_control_2(Process *c_p, Eterm *regs, BeamInstr *I)
{
    return erts_reschedule_bif(c_p, regs, I, erts_debug_lcnt_control_2, ERTS_SCHED_DIRTY_CPU);
}

Eterm schedule_dirty_cpu_erts_debug_lcnt_collect_0(Process *c_p, Eterm *regs, BeamInstr *I)
{
    return erts_reschedule_bif(c_p, regs, I, erts_debug_lcnt_collect_0, ERTS_SCHED_DIRTY_CPU);
}

Eterm schedule_dirty_cpu_erts_debug_lcnt_clear_0(Process *c_p, Eterm *regs, BeamInstr *I)
{
    return erts_reschedule_bif(c_p, regs, I, erts_debug_lcnt_clear_0, ERTS_SCHED_DIRTY_CPU);
}

