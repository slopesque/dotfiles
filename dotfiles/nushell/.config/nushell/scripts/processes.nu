#!/bin/nu

def psmem [] {
  ps |
    group-by name |
    transpose name processes |
    insert parent_process {|x| $x.processes | sort-by pid | first } |
    insert pid {|x| $x.parent_process.pid } |
    insert ppid { |x| $x.parent_process.ppid } |
    insert cpu { |x| $x.processes.cpu | math sum } |
    insert mem { |x| $x.processes.mem | math sum } |
    reject processes parent_process
}
