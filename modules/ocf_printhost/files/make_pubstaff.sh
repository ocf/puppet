#!/bin/bash
# creates pubstaff user and grants it 500 daily page quota
/usr/local/bin/pkusers -a pubstaff
/usr/local/bin/pkusers -b +500 pubstaff
