# c7bifu — Instruction Fetch Unit of cpu7b

c7bifu fetches instructions for the cpu7b LA32R core. It translates the
fetch address, requests 64-bit blocks from the instruction cache (or the
BIU when the cache is disabled), queues the instructions, decodes them
and hands one instruction per cycle to the EXU.

```
             exu_ifu_branch / except / ertn (redirect, from W)
                              |
                              v
  +-------------+   +----------------+   +---------+   +----------+   +---------+
  | c7bifu_fcl  |-->| pf_vaddr_q     |-->| c7btlb  |-->| ICU/BIU  |-->| c7bifu  |
  | fetch ctrl  |   | (PF address)   |   | (ITLB)  |   | request  |   | _iq     |
  +-------------+   +----------------+   +---------+   +----------+   +---------+
                                                                          |
                                                                          v
                                                                    +-----------+
                                                                    | c7bifu_dec|--> EXU (_d)
                                                                    +-----------+
```

## Files

| File | Module | Purpose |
|---|---|---|
| `rtl/c7bifu.v` | `c7bifu` | Top: fetch address, ITLB, physical address, exceptions, glue |
| `rtl/c7bifu_fcl.v` | `c7bifu_fcl` | Fetch control: request/ack/data handshake, address select, flush |
| `rtl/c7bifu_iq.v` | `c7bifu_iq` | Instruction queue, 4 x 32-bit entries |
| `rtl/c7bifu_dec.v` | `c7bifu_dec` | Decode stage register and dispatch signals |
| `rtl/decoder.v`, `rtl/c7bifu_imd.v`, `rtl/dec_defs.v` | | Opcode decoder, immediates, decode definitions |

The ITLB is an instance of `c7btlb` (32 entries, shared module with the DTLB).

## Pipeline stages

| Stage | Where | What happens |
|---|---|---|
| PF | `pf_vaddr_q` | Fetch virtual address. ITLB search is issued from it. |
| IC1 | `ifu_icu_req_ic1` | Request to the ICU with the physical address; ICU acks. |
| IC2 | `icu_ifu_data_valid_ic2` | 64-bit data returns (hit: one cycle after ack). |
| F | `c7bifu_iq` | Data written into the IQ, read out one 32-bit instruction per cycle. |
| D | `c7bifu_dec` | Decode register, signals to EXU (`ifu_exu_*_d`). |

Only one fetch is outstanding at a time. A new request is issued only
after the data of the previous one has returned.

## Address translation

`pf2_phyaddr` (in `c7bifu.v`) selects the physical address:

| Mode | Physical address |
|---|---|
| DA (`crmd.da`=1) | `pf_vaddr_q & 0x1FFFFFFF` |
| PG, DMW0 hit | `{dmw0_pseg, pf_vaddr_q[28:0]}` |
| PG, DMW1 hit | `{dmw1_pseg, pf_vaddr_q[28:0]}` |
| PG, otherwise | `{tlb_s_pfn, pf_vaddr_q[11:0]}` |

### ITLB timing

`c7btlb` takes **one cycle** per search. The request (`s_vppn`,
`s_odd_page`, `s_asid`, `s_vld`) is latched into `*_g` registers, and
`s_found` / `s_pfn` / `s_v` / `s_plv` are combinational from the latched
request. So the result seen in cycle N belongs to the search issued in
cycle N-1.

```
cycle        N-1          N
s_vld        1            x
s_vppn       VA(N-1)      x
s_found      -            result for VA(N-1)   (= match & s_vld_g)
```

`tlb_s_vld = fcl_req & pg_mode & ~dmw_hit`, i.e. the ITLB searches
`pf_vaddr_q` every cycle that fetch is requesting. The search port is
shared with TLBSRCH (`exu_itlb_tlbsrch_vld_e` has priority).

Because of the one-cycle latency, the fetch request may only use the TLB
result when it belongs to the current `pf_vaddr_q`:

- Sequential fetch: guaranteed by fcl. After an ack, `fcl_req` is 0 for
  at least one cycle before `pf_vaddr_q` changes, so `s_vld_g` is 0 in
  the first cycle with the new address and `s_found` is 0.
- After a flush (branch/except/ertn) or a TLBSRCH this gap does not
  exist. The request and the TLBR/PIF/PPI checks are masked in the cycle
  after a flush (`flush_dly1`) and after TLBSRCH (`tlbsrch_vld_m`).

## Fetch control (c7bifu_fcl)

### Signals

```verilog
req       = ((~req_q & ~d_stall_in) | flush) & ~iq_full & ~wait_bus_clr_in
            & (~hold_fcl_req | flush);
req_in    = ~ack & (req | req_q);                 // held until ack
fcl_req   = req_q & ~iq_full & ~wait_bus_clr_in & ~hold_fcl_req;

d_stall_in = (d_stall_q & ~data_vld) | ack;       // waiting for data
fcl_data_vld = data_vld & ~data_cancel_q;         // drop pre-flush data

pf_addr_en = pf_addr_sel_init | fcl_data_vld | flush;
```

`pf_vaddr_in` selects one of:

| Select | Value | When |
|---|---|---|
| `init` | `0x1C000000` | first cycle after reset |
| `inc` | `pf_vaddr_q + 8` | data returned, no flush in this or the previous cycle |
| `brn` | `exu_ifu_brn_addr` | branch taken (W) |
| `isr` | `exu_ifu_isr_addr` | exception (W); TLBR uses `tlbrentry` |
| `ert` | `exu_ifu_ert_addr` | ertn (W) |
| `old` | `pf_vaddr_q` | otherwise |

### Timeline: sequential fetch, mapped page, icache hit

```
cycle            t     t+1    t+2    t+3    t+4    t+5
pf_vaddr_q       A     A      A      A+8    A+8    A+8
fcl_req          1     1      0      1      1      0
tlb_s_vld        1     1      0      1      1      0
s_found          0     1(A)   -      0      1(A+8) -
ifu_icu_req_ic1  0     1      0      0      1      0
icu ack          0     1      0      0      1      0
data_vld         0     0      1      0      0      1
pf_addr_en       0     0      1      0      0      1
IQ write                      A                    A+8
```

- t: first cycle with A. `s_vld_g`=0, so `s_found`=0 and no request.
- t+1: TLB result for A is valid, request goes out, ICU acks
  (`req_in`=0).
- t+2: data returns, `fcl_data_vld` updates `pf_vaddr_q` to A+8 and the
  data is written into the IQ. `req` rises again because `d_stall_in`
  is 0.
- t+3: new address, TLB search only (same as t).

Steady state is 8 bytes every 3 cycles. In DA/DMW mode there is no
TLB cycle (request at t+3), so 8 bytes every 2 cycles. On an icache miss,
`data_vld` comes when the linefill delivers the critical word
(`biu_icu_data_last`), and fetch waits in `d_stall`.

### Timeline: redirect (branch / exception / ertn)

The redirect comes from the W stage of the EXU. `flush` is
`except | branch | ertn`.

```
cycle            F            F+1          F+2          F+3
flush            1            0            0            0
flush_dly1       0            1            0            0
pf_vaddr_q       old          T            T            T
req_q            x            1            1            0
tlb search       old/-        T            T            -
s_found          -            old result   T            -
request          masked       masked(*)    yes          -
IQ               flushed      flushed      -            data T
```

- F: `pf_vaddr_in` = target T, `pf_addr_en`=1. `req` is forced to 1.
  The IQ and decode register are flushed. If a fetch is outstanding
  (`data_stall | ack`), `data_cancel_q` is set and the next `data_vld`
  is dropped.
- F+1: `pf_vaddr_q` = T. The IQ is flushed again (`flush_dly1`) and
  `pf_addr_sel_inc` is blocked. The TLB result still belongs to the old
  address, so (*) the request is masked with `~flush_dly1`; the search
  for T is issued.
- F+2: TLB result for T, request goes out.

In DA/DMW mode the request can go out at F+1.

### Hold on fetch exception

`hold_fcl_req` is set by `fetch_except_hold` (TLBR/PIF/PPI or a fetch
bus fault) and stops new requests until the exception is taken. It is
cleared by `exu_ifu_except` (or, with the fetch-exception patch, by any
flush, so a fetch exception dropped by a branch or ertn cannot block
fetch forever).

### wait_bus_clr

When the icache is switched on (`csr_ifu_ic_en_pls`), fetch is held
until the outstanding uncached fetch has returned (`~data_stall`), then
`ic_en` takes the new value.

## Instruction queue (c7bifu_iq)

- 4 entries of {addr, inst}. Each fetch writes 2 entries (64 bits).
- `iq_full` = fewer than 2 free entries; fcl stops requesting.
- After a redirect to an address with bit 2 set, the first returned block
  only writes its upper half (`skip_first_half`).
- Read: `rd_en = ~stall & ~empty & ~flush`. The output (`inst_vld`,
  `inst_addr`, `inst`) is registered, so an instruction appears one
  cycle after `rd_en`.
- `flush` (`flush | flush_dly1` from c7bifu) empties the queue and clears
  the output register.

## Decode (c7bifu_dec) and stall

The decode register (`ifu_exu_pc_d`, `inst_d`, `inst_vld_d`) loads when
`reg_en = ~stall | flush`. The instruction is presented to the EXU as
`ifu_exu_vld_d = inst_vld_d & ~stall & ~flush`.

`exu_ifu_stall` (from `c7bexu_ecl`) holds decode while an LSU, DIV, CSR
or TLB instruction is in progress. Because the IQ output is one cycle
behind `rd_en`, the IQ is stalled one cycle earlier by `stall_iq`, which
also includes the decoded LSU/CSR/DIV/TLB valid signals, so no
instruction is read out of the IQ while it cannot be accepted.

```
cycle           d      d+1    d+2 ... e
D               ld     ld     ld      next
stall_iq        1      1      1       0      (ld decoded in d -> IQ stops)
exu_ifu_stall   0      1      1       0      (ld in E/M until data)
```

## Fetch exceptions

| Exception | Detected | Request sent | BADV |
|---|---|---|---|
| TLBR | `tlb_res_vld & ~tlb_s_found` | no | `pf_vaddr_q` |
| PIF | `tlb_s_found & ~tlb_s_v` | no | `pf_vaddr_q` |
| PPI | `tlb_s_found & tlb_s_v & plv > tlb_plv` | see note | `pf_vaddr_q` |
| ADEF | `icu_ifu_fault_ic2 | biu_ifu_fault` on the response | yes | `pf_vaddr_q` |

All are masked in the cycle after a flush or TLBSRCH (see ITLB timing).
On detection, `fetch_except_hold` stops further requests.

The exception address is the fetch address `pf_vaddr_q`, which is younger
than every instruction still in the IQ or in decode. The exception must
therefore reach the EXU with that address as its PC (ERA = BADV), after
all older instructions have issued. Two implementations are available:

- **IQ entry**: the latched exception is written into the IQ as an entry
  with its own address and reaches decode in program order.
- **Held in IFU**: the latched exception is sent to the EXU only when the
  IQ, the IQ output register and decode are empty and `exu_ifu_stall`
  is 0.

A flush drops a pending fetch exception; the fetch is repeated if the
path comes back to the address.

Note: PPI should also block the request (`tlb_s_plv` check in the
request condition). Otherwise the instructions of a page that may not be
executed are fetched into the IQ before the exception is taken.

## Interface summary

| Signal | Dir | Description |
|---|---|---|
| `ifu_icu_req_ic1` / `ifu_icu_addr_ic1` | out | Cached fetch request, physical address |
| `icu_ifu_ack_ic1` | in | Request accepted (ICU free) |
| `icu_ifu_data_valid_ic2` / `icu_ifu_data_ic2` | in | 64-bit fetch data |
| `icu_ifu_fault_ic2` | in | Bus error on the fetch |
| `ifu_biu_rd_req` / `ifu_biu_rd_addr` | out | Uncached fetch (`ic_en`=0) |
| `exu_ifu_branch` / `exu_ifu_brn_addr` | in | Branch redirect (W) |
| `exu_ifu_except` / `exu_ifu_isr_addr` | in | Exception redirect (W) |
| `exu_ifu_ertn` / `exu_ifu_ert_addr` | in | ertn redirect (W) |
| `exu_ifu_stall` | in | Hold decode |
| `ifu_exu_vld_d`, `ifu_exu_pc_d`, ... | out | Decoded instruction to EXU |
| `ifu_exu_exc_vld_d` / `_code_d` / `_badv_d` | out | Exception carried by the instruction in D |
| `csr_itlb_*`, `exu_itlb_*` | in | ITLB write/search/invalidate from CSR and EXU |
| `itlb_csr_*` | out | ITLB read and TLBSRCH results to CSR |
