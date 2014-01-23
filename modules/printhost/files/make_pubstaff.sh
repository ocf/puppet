#!/bin/bash
# creates pubstaff user and grants it 500 daily page quota
pkusers -a pubstaff
pkusers -b +500 pubstaff
