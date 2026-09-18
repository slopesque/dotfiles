#!/bin/nu

def lsmod [] {
    ^lsmod | parse --regex '(?P<module>\w+)\s+(?P<size>\d+)\s+(?P<used_by>\d+)\s(?P<users>\w*)'
}
