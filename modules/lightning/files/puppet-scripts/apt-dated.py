#!/usr/bin/env python
# encoding: utf8

import os, sys, time, subprocess

# root has no $PAGER
PAGER = "less -r"
HISTORY = "/root/.local/share/apt-dater/history"

os.chdir(os.path.dirname(__file__))

machines = [m[:-2] for m in os.listdir(HISTORY)]
machines.sort()

print "Known machines:", " ".join(machines)

m = None
while m not in machines:
  if m is not None:
    print "Don't lie to me."
  try:
    m = raw_input("Which? ")
  except KeyboardInterrupt:
    print "\nFine."
    sys.exit(0)

print
print "Entries:"
m_hist = "{0}/{1}:0".format(HISTORY, m)
m_hist_entries = os.listdir(m_hist)
m_hist_entries.sort()
histories = [time.asctime(time.localtime(int(d.split("-")[0]))) for d in m_hist_entries]
print "\n".join(["{0}) {1}".format(i, e) for i, e in enumerate(histories)])

t = None
while t is None or t < 0 or t > len(m_hist_entries):
  if t is not None:
    print "Don't lie to me."
  try:
    t = int(raw_input("Which? "))
  except KeyboardInterrupt:
    print "\nFine."
    sys.exit(0)
  except ValueError:
    print "I asked for a number."

m_entry = os.path.join(m_hist, m_hist_entries[t], "typescript")

# Jesus!
subprocess.call(PAGER + " " + m_entry, shell = True)
